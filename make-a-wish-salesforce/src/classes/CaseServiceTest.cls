/**
 * @description Case Service Test Class
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 8/20/2019
 */
@IsTest
public with sharing class CaseServiceTest {

    @TestSetup
    public static void setUpData() {
        trac_TriggerHandlerBase.blockTrigger = true;
        List<Account> accounts = TestDataFactory.createAccount(2);
        Account account1 = accounts.get(0);
        Account account2 = accounts.get(1);
        insert accounts;

        List<Contact> contacts = TestDataFactory.createContact(2);
        Contact contact1 = contacts.get(0);
        contact1.FirstName = 'Test1';
        contact1.LastName = 'User2';
        contact1.AccountId = account1.Id;
        Contact contact2 = contacts.get(1);
        contact2.FirstName = 'Test2';
        contact2.LastName = 'User3';
        contact2.AccountId = account2.Id;
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

        List<Case> cases = TestDataFactory.createCase(1);
        Case wish = cases.get(0);
        wish.Lead__c = lead.Id;
        wish.RecordTypeId = Constant_AC.DIAGNOSIS_RT_ID;
        wish.ChapterName__c = accounts.get(0).Id;
        wish.Subject = 'Wish1';
        wish.Interview_date__c = System.today();
        wish.Wish_Type__c = 'Hawaii';
        wish.Start_Date__c = System.today();
        wish.End_Date__c = System.today();
        wish.ContactId = contact2.Id;
        wish.Status = 'New';
        wish.Rush__c = false;
        wish.Start_Date__c = System.today();
        wish.Budget_Submitted_Date__c = System.today();
        wish.Budget_Approved_Date__c = System.today();
        wish.Update_Wish_Child_Form_Info__c = true;
        insert cases;
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
        Lead lead = [
                SELECT Id
                FROM Lead
                WHERE Name = 'Jack Smith'
        ];

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
        Lead lead = [
                SELECT Id
                FROM Lead
                WHERE Name = 'Jack Smith'
        ];
        List<Case> cases = [
                SELECT Id
                FROM Case
                WHERE Lead__c = :lead.Id
        ];

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

        System.assertEquals(Constant_AC.CASE_STATUS_PENDING_CLARIFICATION_CHAPTER, results.get(cases.get(0).Id).Status);
    }

    @IsTest
    static void shouldUpdateCaseRushByLead() {
        Lead lead = [
                SELECT Id
                FROM Lead
                WHERE Name = 'Jack Smith'
        ];
        List<Case> cases = [
                SELECT Id
                FROM Case
                WHERE Lead__c = :lead.Id
        ];
        Map<Id, Boolean> rushLeadMap = new Map<Id, Boolean>();
        rushLeadMap.put(lead.Id, true);

        Test.startTest();
        Map<Id, Case> results = CaseService.updateRushByLeadAndRecordType(
                rushLeadMap,
                new Set<Id>{
                        Constant_AC.DIAGNOSIS_RT_ID
                });
        Test.stopTest();

        System.assertEquals(true, results.get(cases.get(0).Id).Rush__c);
    }
}