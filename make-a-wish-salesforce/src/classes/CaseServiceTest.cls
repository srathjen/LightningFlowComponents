/**
 * @description Case Service Test Class
 * @author Gustavo Mayer, Traction on Demand
 * @date 8/20/2019
 */
@IsTest
public with sharing class CaseServiceTest {

    @TestSetup
    public static void setUpData() {
        trac_TriggerHandlerBase.blockTrigger = true;

        Regions__c region = TestDataFactory.createRegions(1)[0];
        insert region;

        List<Account> accounts = TestDataFactory.createChapterAccount(2);
        Account account1 = accounts.get(0);
        Account account2 = accounts.get(1);
        account1.Name = account2.Name = Constant_AC.ACCOUNT_NAME_MAW_AMERICA;
        insert accounts;

        List<Contact> contacts = TestDataFactory.createContact(2);
        Contact contact1 = contacts.get(0);
        contact1.FirstName = 'Test1';
        contact1.LastName = 'User2';
        contact1.AccountId = account1.Id;
        contact1.Region_Code__c = region.Id;
        contact1.County__c = 'Test';
        contact1.RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
        Contact contact2 = contacts.get(1);
        contact2.FirstName = 'Test2';
        contact2.LastName = 'User3';
        contact2.AccountId = account2.Id;
        contact2.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;

        contact1.Diagnosis__c = contact2.Diagnosis__c = 'Test';
        insert contacts;

        List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
        insert icdCodes;

        List<Lead> leads = TestDataFactory.createLead(1);
        Lead lead = leads.get(0);
        lead.ChapterName__c = account2.Id;
        lead.FirstName = 'Jack';
        lead.LastName = 'Smith';
        lead.Hidden_Chapter_Change_Confirmation__c = account2.Id;
        lead.is_Family_Aware_of_Referral__c = 'Yes';
        lead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
        lead.PD_ICD_Code__c = icdCodes.get(0).Id;
        lead.Company = 'MAW';
        lead.DOB__c = Date.today().addDays(-1400);
        lead.I_am_Recognized_To_Practice_As_a__c = 'Physician';
        insert lead;

        List<dsfs__DocuSign_Status__c> docuSignStatuses = TestDataFactory.createDocusignStatus(1);
        dsfs__DocuSign_Status__c docuSignStatus = docuSignStatuses.get(0);
        docuSignStatus.dsfs__Lead__c = lead.Id;
        docuSignStatus.dsfs__Completed_Date_Time__c = Date.today();
        insert docuSignStatuses;

        trac_TriggerHandlerBase.blockTrigger = false;
    }

    @IsTest
    static void shouldRestrictUserCasePermission() {
        User communityUser = TestDataFactory.createCommunityUser(1).get(0);
        System.runAs(TestDataFactory.adminUser) {
            insert communityUser;
            insert new Closed_Case_Editing_Security_Settings__c(SetupOwnerId = communityUser.Id, Restrict_Access__c = true);
        }
        System.runAs(communityUser) {
            Boolean result = CaseService.userHasRestrictedPermissionOnCase();
            System.assertEquals(true, result);
        }
    }

    @IsTest
    static void shouldNotRestrictUserCasePermission() {
        User communityUser = TestDataFactory.createCommunityUser(1).get(0);
        System.runAs(TestDataFactory.adminUser) {
            insert communityUser;
        }
        System.runAs(communityUser) {
            Boolean result = CaseService.userHasRestrictedPermissionOnCase();
            System.assertEquals(false, result);
        }
    }

    @IsTest
    static void shouldDeleteCase() {
        Lead lead = getLead();

        Test.startTest();
        CaseService.deleteByLeadIdAndRecordTypeNames(lead.Id,
                new List<String>{
                        Constant_AC.CASE_RECORD_TYPE_DIAGNOSIS_VERIFICATION_REVIEW
                });
        Test.stopTest();

        List<Case> cases = [
                SELECT Id
                FROM Case
                WHERE Lead__c = :lead.Id
        ];
        System.assertEquals(0, cases.size());
    }

    @IsTest
    static void shouldUpdateCaseStatusByLead() {
        Lead lead = getLead();
        List<Case> cases = createCases(lead);
        insert cases;

        Test.startTest();
        Map<Id, Case> results = CaseService.updateStatusByLeadAndRecordType(
                new Set<Id>{
                        lead.Id
                },
                new Set<Id>{
                        Constant_AC.DIAGNOSIS_RT_ID
                },
                Constant_AC.CASE_STATUS_PENDING_CLARIFICATION_CHAPTER);
        Test.stopTest();

        System.assertEquals(Constant_AC.CASE_STATUS_PENDING_CLARIFICATION_CHAPTER, results.get(cases.get(1).Id).Status);
    }

    @IsTest
    static void shouldUpdateCaseRushByLead() {
        Lead lead = getLead();
        List<Case> cases = createCases(lead);
        insert cases;

        Map<Id, Boolean> rushLeadMap = new Map<Id, Boolean>();
        rushLeadMap.put(lead.Id, true);

        Test.startTest();
        Map<Id, Case> results = CaseService.updateRushByLeadAndRecordType(
                rushLeadMap,
                new Set<Id>{
                        Constant_AC.DIAGNOSIS_RT_ID
                });
        Test.stopTest();

        System.assertEquals(true, results.get(cases.get(1).Id).Rush__c);
    }

    @IsTest
    static void shouldSetDVReceiveDate() {
        Lead lead = getLead();
        List<dsfs__DocuSign_Status__c> docuSignStatus = [
                SELECT Id, dsfs__Completed_Date_Time__c, dsfs__Lead__c
                FROM dsfs__DocuSign_Status__c
                WHERE dsfs__Lead__c = :lead.Id
        ];
        List<Case> cases = createCases(lead);
        insert cases;

        Map<Id, Case> leadIdByCaseMap = new Map<Id, Case>();
        leadIdByCaseMap.put(lead.Id, cases[0]);

        Test.startTest();
        Map<Id, Case> results = CaseService.setDVReceiveDate(docuSignStatus, leadIdByCaseMap);
        Test.stopTest();

        System.assertEquals(Date.today(), results.get(lead.Id).Diagnosis_Verification_Receive_Date__c);
    }

    @IsTest
    static void shouldBuildQualifiedCaseFromLead() {
        Lead lead = getLead();

        Test.startTest();
        Case result = CaseService.buildQualifiedCaseFromLead(lead, true);
        Test.stopTest();

        System.assertEquals('Qualified', result.Status);
    }

    @IsTest
    static void testUserWithManager() {
        User currentUser = Utils.currentUser;
        User employee = [
                SELECT Id
                FROM User
                WHERE ManagerId != NULL AND IsActive = TRUE AND Id != :UserInfo.getUserId()
                LIMIT 1
        ];

        System.runAs(employee) {
            Lead lead = getLead();
            Account chapterAccount = TestDataFactory.createAccount(1)[0];
            insert chapterAccount;

            Contact contact = TestDataFactory.createContact(1)[0];
            insert contact;

            List<Case> cases = createCases(lead);
            for (Case c : cases) {
                c.OwnerId = currentUser.Id;
            }
            insert cases;

            for (Case c : cases) {
                c.Status = Constant_AC.CASE_STATUS_CLOSED;
                c.Closed_Date__c = Date.today();
                c.OwnerId = employee.Id;
            }
            update cases;
        }
    }

    @IsTest
    static void coverRecursiveTriggerHandlerBlocks() {
        RecursiveTriggerHandler.blockAfterUpdate = true;
        RecursiveTriggerHandler.blockBeforeUpdate = true;
        RecursiveTriggerHandler.blockCaseLockRecursive = true;

        Lead lead = getLead();
        List<Case> cases = createCases(lead);
        insert cases;
        update cases;
    }

    @IsTest
    static void testWishAssistChange() {
        Lead lead = getLead();
        List<Case> cases = createCases(lead);
        insert cases;

        cases[0].Wish_Assist__c = true;
        update cases;
    }

    @IsTest
    static void testChangeToGranted() {
        Lead lead = getLead();
        List<Case> cases = createCases(lead);
        insert cases;

        cases[0].Status = Constant_AC.CASE_STATUS_GRANTED;
        update cases;
    }

    @IsTest
    static void testChangeToMACReviewed() {
        Lead lead = getLead();
        List<Case> cases = createCases(lead);
        cases[1].Sub_Status__c = Constant_AC.LEAD_SUB_STATUS_PENDING_PART_A;
        insert cases;

        lead.Qualifying_ICD__c = [
                SELECT Id
                FROM ICD_Codes__c
                LIMIT 1
        ].Id;
        lead.Any_medical_reason_for_moving_quickly__c = 'Test';
        lead.Part_A_Received__c = Date.today();
        lead.Migrated_Record__c = true;
        update lead;

        cases[1].Status = Constant_AC.CASE_STATUS_APPROVED_NATIONAL_MAC_REVIEW;
        cases[1].Diagnosis_Verification_Receive_Date__c = Date.today();
        update cases;
    }

    @IsTest
    static void testChangeToCompleted() {
        Lead lead = getLead();
        List<Case> cases = createCases(lead);
        insert cases;

        cases[0].Status = Constant_AC.CASE_STATUS_COMPLETED;
        cases[0].Diagnosis_Verification_Receive_Date__c = cases[0].Referral_Date__c = Date.today();
        update cases;
    }

    @IsTest
    static void testChangeToReadyToAssign() {
        Lead lead = getLead();
        List<Case> cases = createCases(lead);
        insert cases;

        cases[0].Status = Constant_AC.CASE_STATUS_READY_TO_ASSIGN;
        cases[0].Sub_Status__c = Constant_AC.CASE_SUB_STATUS_ABANDONED;
        update cases;
    }

    @IsTest
    static void testWishPendingApproval() {
        Lead lead = getLead();
        List<Case> cases = createCases(lead);
        insert cases;

        cases[0].Status = Constant_AC.CASE_STATUS_PENDING_APPROVAL;
        cases[0].Sub_Status__c = Constant_AC.CASE_SUB_STATUS_NON_VIEWABLE;
        update cases;
    }

    @IsTest
    static void testDNQStatus() {
        Lead lead = getLead();
        List<Case> cases = createCases(lead);
        insert cases;

        cases[0].Status = Constant_AC.CASE_STATUS_DNQ_NATIONAL_STAFF;
        cases[0].Sub_Status__c = Constant_AC.CASE_SUB_STATUS_NON_VIEWABLE;
        update cases;
    }

    @IsTest
    static void testCaseReadyToInterview() {
        Lead lead = getLead();
        List<Case> cases = createCases(lead);
        for (Case c : cases) {
            c.Status = Constant_AC.CASE_STATUS_READY_TO_ASSIGN;
            c.Sub_Status__c = Constant_AC.CASE_SUB_STATUS_PENDING;
        }
        insert cases;

        for (Case c : cases) {
            c.Status = Constant_AC.CASE_STATUS_READY_TO_INTERVIEW;
        }
        update cases;
    }

    @IsTest
    static void testCaseEscalated() {
        Lead lead = getLead();
        List<Case> cases = createCases(lead);
        for (Case c : cases) {
            c.Status = Constant_AC.CASE_STATUS_ESCALATED;
        }
        insert cases;

        for (Case c : cases) {
            c.Case_Comment__c = 'TEST';
        }
        update cases;

        for (Case c : cases) {
            c.Status = Constant_AC.CASE_STATUS_NEW;
        }
        update cases;

        Contact medicalContact = [
                SELECT Id
                FROM Contact
                WHERE RecordTypeId = :Constant_AC.MEDICAL_PROFESSIONAL_RT_ID
        ];
        for (Case c : cases) {
            c.Status = Constant_AC.CASE_STATUS_ESCALATED;
            c.Local_MCA_Team__c = medicalContact.Id;
        }
        update cases;
    }

    @IsTest
    static void testChangeWishType() {
        Lead lead = getLead();
        List<Case> cases = createCases(lead);
        insert cases;

        cases[0].Wish_Type__c = Constant_AC.CASE_WISH_TYPE_CRUISE_DISNEY;
        cases[0].Comment_1__c = 'Test';
        cases[0].Appropriate_Comments__c = 'Test';
        cases[0].Please_Explain__c = 'Test';
        update cases;
    }

    private static Lead getLead() {
        return [
                SELECT Id, ConvertedContactId, Qualified_Date__c, Migrated_Record__c,
                        Treating_Medical_Professional_First_Name__c, Treating_Medical_Professional_Last_Name__c,
                        Treating_Medical_Professional_Email__c, ConvertedAccountId,
                        Why_do_you_feel_would_be_eligible_Wish__c, Part_A_Received__c, Part_A_Sent__c, ChapterName__c,
                        PD_Condition_Description__c, ChapterName__r.Qualified_Wish_Owner__c, FirstName, LastName, Rush__c,
                        Please_Explain__c, Referred_Date__c, Inquiry_Date__c, Out_of_Territory__c, unique_wish_identifier__c
                FROM Lead
                WHERE Name = 'Jack Smith'
        ];
    }

    private static List<Case> createCases(Lead lead) {
        List<Account> accounts = [
                SELECT Id
                FROM Account
                ORDER BY CreatedDate
        ];
        List<Contact> contacts = [
                SELECT Id
                FROM Contact
                ORDER BY CreatedDate
        ];
        Case wish = TestDataFactory.createCase(1).get(0);
        wish.Lead__c = lead.Id;
        wish.RecordTypeId = Constant_AC.WISH_RT_ID;
        wish.ChapterName__c = accounts.get(0).Id;
        wish.Subject = 'Wish1';
        wish.Interview_date__c = System.today();
        wish.Wish_Type__c = 'Hawaii';
        wish.Start_Date__c = System.today();
        wish.End_Date__c = System.today();
        wish.ContactId = contacts.get(0).Id;
        wish.Status = 'New';
        wish.Rush__c = false;
        wish.Start_Date__c = System.today();
        wish.Budget_Submitted_Date__c = System.today();
        wish.Budget_Approved_Date__c = System.today();
        wish.Update_Wish_Child_Form_Info__c = true;
        Case diagnosis = wish.clone();
        diagnosis.RecordTypeId = Constant_AC.DIAGNOSIS_RT_ID;
        return new List<Case>{
                wish, diagnosis
        };
    }
}