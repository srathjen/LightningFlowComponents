/**
 * @description Case Service Test Class
 * @author Gustavo Mayer, Traction on Demand
 * @date 8/20/2019
 */
@IsTest
public with sharing class CaseServiceTest {
  private static final Integer NUM_RECORDS = 3; 
    @TestSetup
    public static void setUpData() {
        trac_TriggerHandlerBase.blockTrigger = true;

        Regions__c region = TestDataFactory.createRegions(1)[0];
        insert region;
        
        //causes error because method does not assign role to the user List<User> wishManagers = TestDataFactory.createUser(1);
        //insert wishManagers;

        List<Account> accounts = TestDataFactory.createChapterAccount(2);
        Account account1 = accounts.get(0);
        Account account2 = accounts.get(1);
        account1.Name = account2.Name = Constant_AC.ACCOUNT_NAME_MAW_AMERICA;
        //account1.qualified_wish_owner__c = wishManagers[0].id;
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
        lead.gender__c = 'Male';
        lead.country = Constant_AC.LEAD_COUNTRY_UNITED_STATES;
        lead.street = '55 Chevy Dr';
        lead.city = 'Phoenix';
        lead.state = 'Arizona';
        lead.postalcode = '85016';
        lead.phone = '5555555555';
        lead.Hidden_Chapter_Change_Confirmation__c = account2.Id;
        lead.is_Family_Aware_of_Referral__c = 'Yes';
        lead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
        lead.PD_ICD_Code__c = icdCodes.get(0).Id;
        lead.Company = 'MAW';
        lead.DOB__c = Date.today().addDays(-1400);
        lead.I_am_Recognized_To_Practice_As_a__c = 'Physician';
        lead.Sub_Status__c = 'Pending Paper DV';
        lead.Appeal__c = true;
        lead.unique_wish_identifier__c = 'testIdentifier';
        lead.hospital_treatment_facility_treating__c = 'County Hospital';
        lead.Treating_Medical_Professional_First_Name__c = 'Doc';
        lead.Treating_Medical_Professional_Last_Name__c = 'Thomas';
        lead.Treating_Medical_Professional_Email__c = 'dthomas@countyhospital.org';
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
        List<Case> cases = createWishCases(lead);
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
        List<Case> cases = createWishCases(lead);
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
        List<Case> cases = createWishCases(lead);
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
        lead.rush__c = true;
        lead.referred_date__c = lead.inquiry_date__c = Date.today().addmonths(-1);
        update lead;

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

            List<Case> cases = createWishCases(lead);
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
        List<Case> cases = createWishCases(lead);
        insert cases;
        update cases;
    }

    @IsTest
    static void testWishAssistChange() {
        Lead lead = getLead();
        List<Case> cases = createWishCases(lead);
        insert cases;

        cases[0].Wish_Assist__c = true;
        update cases;
    }

    @IsTest
    static void testChangeToGranted() {
        Lead lead = getLead();
        List<Case> cases = createWishCases(lead);
        insert cases;

        cases[0].Status = Constant_AC.CASE_STATUS_GRANTED;
        update cases;
    }

    @IsTest
    static void testChangeToMACReviewed() {
        Lead lead = getLead();
        List<Case> cases = createWishCases(lead);
        cases[1].Sub_Status__c = Constant_AC.LEAD_SUB_STATUS_PENDING_PART_A;
        insert cases;

        lead.Qualifying_ICD__c = [
                SELECT Id
                FROM ICD_Codes__c
                LIMIT 1
        ].Id;
        lead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        lead.please_explain__c = 'reason for expediting';
        lead.Part_A_Received__c = Date.today();
        lead.Migrated_Record__c = true;
        update lead;

        cases[1].Status = Constant_AC.CASE_STATUS_APPROVED_NATIONAL_MAC_REVIEW;
        cases[1].Diagnosis_Verification_Receive_Date__c = Date.today();
        update cases;
    }
@IsTest
    static void testChangeToMACReviewedForElse() {
        Lead lead = getLead();
        List<Case> cases = createWishCases(lead);
        cases[1].Sub_Status__c = Constant_AC.LEAD_SUB_STATUS_PENDING_PART_A;
        insert cases;

        lead.Qualifying_ICD__c = [
                SELECT Id
                FROM ICD_Codes__c
                LIMIT 1
        ].Id;
        lead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        lead.please_explain__c = 'reason for expediting';
        lead.Part_A_Received__c = null;
        lead.Migrated_Record__c = true;
        lead.DOB__c=null;
        lead.Any_medical_reason_for_moving_quickly__c=null;
        lead.I_am_Recognized_To_Practice_As_a__c=null;
        update lead;

        cases[1].Status = Constant_AC.CASE_STATUS_APPROVED_NATIONAL_MAC_REVIEW;
        cases[1].Diagnosis_Verification_Receive_Date__c = Date.today();
        
        try{
            update cases;
        }
        catch(exception e){
           
        }
    }
    @IsTest
    static void testChangeToCompleted() {
        Lead lead = getLead();
        List<Case> cases = createWishCases(lead);
        insert cases;
       
        
		List<Wish_Expense_Type__c> wishExpTypeList = TestDataFactory.createWishExpenseTypes(1, 'Airfare');
        insert wishExpTypeList;
		
		List<Wish_Expense_Transaction_Code__c> wishExpTransCode = TestDataFactory.createWishTransCodes(1, 'Airfare Westjet');
        wishExpTransCode[0].Wish_Expense_Type__c = wishExpTypeList[0].Id;
        insert wishExpTransCode;
		List<Wish_Budget__c> wishBudgetList = TestDataFactory.createWishBudget(5, cases[0].Id);
        insert wishBudgetList;
        Test.startTest();
        List<Wish_Expense__c> wishExpenseList = TestDataFactory.createWishExpense(1, wishBudgetList[0].Id);
        wishExpenseList[0].Case__c = cases[0].Id;
        wishExpenseList[0].FE_Posted_Cash__c = 100;
        wishExpenseList[0].Wish_Expense_Transaction_Code__c = wishExpTransCode[0].Id;
		wishExpenseList[0].Budget_Cash__c = wishExpenseList[0].Projected_Cash__c =wishExpenseList[0].FE_Posted_In_Kind__c = wishExpenseList[0].Actual_Cash__c=10;
		wishExpenseList[0].Budget_In_Kind__c = wishExpenseList[0].Projected_In_Kind__c =wishExpenseList[0].Actual_In_Kind__c= 20;
        wishExpenseList[0].RecordTypeId = Constant_AC.WISH_EXPENSE_RT_FINANCE;
        insert wishExpenseList; 
		
        cases[0].Status = Constant_AC.CASE_STATUS_COMPLETED;
        cases[0].Diagnosis_Verification_Receive_Date__c = cases[0].Referral_Date__c = Date.today();
        try{
        update cases;
        }
        catch(exception e){
            
        }
    }
	@IsTest
    static void testChangeToCompletedUpdate() {
        Lead lead = getLead();
        List<Case> cases = createWishCases(lead);
        insert cases;

        cases[0].Status = Constant_AC.CASE_STATUS_COMPLETED;
        cases[0].Diagnosis_Verification_Receive_Date__c = cases[0].Referral_Date__c = Date.today();
        update cases;
    }
    @IsTest
    static void testChangeToReadyToAssign() {
        Lead lead = getLead();
        List<Case> cases = createWishCases(lead);
        contact con=new contact();
        con.id=cases[0].contactid;
        con.Region_Code__c=null;
        try{
        update con;
        }
        catch(exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Please add region on the wish child') ? true : false;

System.AssertEquals(expectedExceptionThrown, true);
        }
        insert cases;

        cases[0].Status = Constant_AC.CASE_STATUS_READY_TO_ASSIGN;
        cases[0].Sub_Status__c = Constant_AC.CASE_SUB_STATUS_ABANDONED;
        try{
        update cases;
        }
        catch(exception e){
            
        }
    }
 @IsTest
    static void testChangeToReadyToAssignRegion() {
        Lead lead = getLead();
        List<Case> cases = createWishCases(lead);
        insert cases;
		
        cases[0].Status = Constant_AC.CASE_STATUS_READY_TO_ASSIGN;
        cases[0].Sub_Status__c = Constant_AC.CASE_SUB_STATUS_ABANDONED;
		
        update cases;
    }
    @IsTest
    static void CaseMemberRegion() {
        Lead lead = getLead();
        List<Case> cases = createWishCases(lead);
        insert cases;
		List<User> users;
        System.runAs(TestDataFactory.adminUser) {
            users = TestDataFactory.createVolunteerUser(1, 'Active Volunteer (Login)', 'Manager');
            insert users;
        }

        CaseTeamRole roleRec = [
            SELECT Id
            FROM CaseTeamRole
            WHERE Name = :Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER
        ];

        List<CaseTeamMember> caseTeamMembers = TestDataFactory.createCaseTeamMember(1);
        caseTeamMembers[0].ParentId = cases[0].Id;
        caseTeamMembers[0].MemberId = users[0].Id;
        caseTeamMembers[0].TeamRoleId = roleRec.Id;
        insert caseTeamMembers;
        cases[0].Status = Constant_AC.CASE_STATUS_READY_TO_ASSIGN;
        cases[0].Sub_Status__c = Constant_AC.CASE_SUB_STATUS_ABANDONED;
		cases[0].ownerid=users[0].Id;
        update cases;
    }
    @IsTest
    static void testChangeToReadyToAssignRegionElsePart() {
        Lead lead = getLead();
        List<Case> cases = createWishCases(lead);
        insert cases;
		List<User> users;
        System.runAs(TestDataFactory.adminUser) {
            users = TestDataFactory.createVolunteerUser(1, 'Active Volunteer (Login)', 'Manager');
            insert users;
        }

        CaseTeamRole roleRec = [
            SELECT Id
            FROM CaseTeamRole
            WHERE Name = :Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER
        ];

        List<CaseTeamMember> caseTeamMembers = TestDataFactory.createCaseTeamMember(1);
        caseTeamMembers[0].ParentId = cases[0].Id;
        caseTeamMembers[0].MemberId = users[0].Id;
        caseTeamMembers[0].TeamRoleId = roleRec.Id;
        insert caseTeamMembers;
        cases[0].Status = Constant_AC.CASE_STATUS_READY_TO_ASSIGN;
        cases[0].Sub_Status__c = Constant_AC.CASE_SUB_STATUS_ABANDONED;
		
        update cases;
    }
    @IsTest
    static void testWishPendingApproval() {
        Lead lead = getLead();
        List<Case> cases = createWishCases(lead);
        insert cases;

        cases[0].Status = Constant_AC.CASE_STATUS_PENDING_APPROVAL;
        cases[0].Sub_Status__c = Constant_AC.CASE_SUB_STATUS_NON_VIEWABLE;
        update cases;
    }

    @IsTest
    static void testDNQStatus() {
        Lead lead = getLead();
        List<Case> cases = createWishCases(lead);
        insert cases;

        cases[0].Status = Constant_AC.CASE_STATUS_DNQ_NATIONAL_STAFF;
        cases[0].Sub_Status__c = Constant_AC.CASE_SUB_STATUS_NON_VIEWABLE;
        update cases;
    }

    @IsTest
    static void testCaseReadyToInterview() {
        Lead lead = getLead();
        List<Case> cases = createWishCases(lead);
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
        List<Case> cases = createWishCases(lead);
        for (Case c : cases) {
            c.Status = Constant_AC.CASE_STATUS_ESCALATED;
        }
        insert cases;

        for (Case c : cases) {
            c.Case_Comment__c = 'TEST';
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
        List<Case> cases = createWishCases(lead);
        insert cases;

        cases[0].Wish_Type__c = Constant_AC.CASE_WISH_TYPE_CRUISE_DISNEY;
        cases[0].Comment_1__c = 'Test';
        cases[0].Appropriate_Comments__c = 'Test';
        cases[0].Please_Explain__c = 'Test';
        update cases;
    }
    
    @IsTest
    static void testReopenCases()    {
        Lead lead = getLead();
        
        lead.status = Constant_AC.LEAD_STATUS_REFERRED;
        lead.sub_status__c = Constant_AC.LEAD_SUB_STATUS_PENDING_PAPER_DV;
        update lead;
        
        lead.status = Constant_AC.LEAD_STATUS_ELIGIBILITY_REVIEW;
        lead.Is_in_a_Comatose_Vegetative_State__c = Constant_AC.LEAD_COMATOSE_VEGETATIVE_STATE_YES;
        update lead; //creates diagnosis verification review case
        
        lead.status = Constant_AC.LEAD_STATUS_DNQ;
        lead.sub_status__c = Constant_AC.LEAD_SUB_STATUS_MEDICAL_REVIEWED;
        update lead;
        
        lead.status = Constant_AC.LEAD_STATUS_ELIGIBILITY_REVIEW;
        lead.appeal__c = true;
        update lead;
        
    } 

    private static Lead getLead() {
        return [
                SELECT Id, ConvertedContactId, Qualified_Date__c, Migrated_Record__c,
                        Treating_Medical_Professional_First_Name__c, Treating_Medical_Professional_Last_Name__c,
                        Treating_Medical_Professional_Email__c, ConvertedAccountId,
                        Why_do_you_feel_would_be_eligible_Wish__c, Part_A_Received__c, Part_A_Sent__c, ChapterName__c,
                        PD_Condition_Description__c, ChapterName__r.Qualified_Wish_Owner__c, FirstName, LastName, Rush__c,
                        Please_Explain__c, Referred_Date__c, Inquiry_Date__c, Out_of_Territory__c, unique_wish_identifier__c,
                        hospital_treatment_facility_treating__c
                FROM Lead
                WHERE Name = 'Jack Smith'
        ];
    }

    private static List<Case> createWishCases(Lead lead) {
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
     @IsTest
    static void testfindById() {
        
        Lead lead = getLead();
        List<Case> cases = createWishCases(lead);
        insert cases;
        set<id> CaseId = new set<id>();
        for(case Caseloop:cases)
            CaseId.add(Caseloop.id);
        Map<Id, Id> caseContactMap= new Map<Id, Id>();
        caseContactMap.put(cases[0].id,cases[0].ContactId);
        Test.startTest();
         CaseTeamRole ctr = new CaseTeamRole(AccessLevel = 'Edit', Name = 'Test  (Wish Closed)');
        CaseTeamRole ctrInactive = new CaseTeamRole(AccessLevel = 'Edit', Name = 'Test ' + CaseTeamMemberService.INACTIVE);
        System.runAs(Utils.currentUser) {
            insert new List<CaseTeamRole>{
                    ctr, ctrInactive
            };
        }
        User communityUser = TestDataFactory.createCommunityUser(4).get(3);
        System.runAs(TestDataFactory.adminUser) {
            insert communityUser;
            insert new Closed_Case_Editing_Security_Settings__c(SetupOwnerId = communityUser.Id, Restrict_Access__c = true);
        }
        List<CaseTeamMember> caseTeamMembers = TestDataFactory.createCaseTeamMember(1);
     
            caseTeamMembers[0].ParentId = cases[0].id;
            caseTeamMembers[0].MemberId = communityUser.Id;
            
                caseTeamMembers[0].TeamRoleId = ctr.Id;
            
               
            
       
        insert caseTeamMembers;
        Map<Id, Case> results = CaseService.findById(CaseId);
        CaseService.changeAccessPermission(caseContactMap);
        
        Test.stopTest();
        
    }
    @IsTest
    static void testupdateGrantingCaseDevStaffEmail() {
        
        Account chapterAccount = TestDataFactory.createAccount(1)[0];
        chapterAccount.DevStaffEmail__c='test@test.com';
        insert chapterAccount;
        Map<Id, String> chapterEmailMap = new  Map<Id, String>();
        chapterEmailMap.put(chapterAccount.id,chapterAccount.DevStaffEmail__c);
        Test.startTest();
        CaseService.updateGrantingCaseDevStaffEmail(chapterEmailMap);
        Test.stopTest();
        
    }
    @IsTest
    static void testupdateHiddenVolunteerInactive() {
        
        Lead lead = getLead();
        List<Case> cases = createWishCases(lead);
        insert cases;
        set<id> CaseId = new set<id>();
        CaseId.add(cases[0].id);
        Test.startTest();
        List<case> Caselist=CaseService.updateHiddenVolunteerInactive(CaseId);
        Test.stopTest();
        
    }	
    
    @IsTest
    public static void CreateCaseTeamMember() {
	

        User currentUser = Utils.currentUser;
        List<Account> accounts = TestDataFactory.createAccount(1);
        Account account = accounts.get(0);
        account.Name = 'Make-A-Wish Arizona';
        account.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
        account.Volunteer_Manager__c = currentUser.Id;
        account.Alert_for_Unassigned_Wishes__c = 1;
        insert accounts;

        List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
        ICD_Codes__c icdCode = icdCodes.get(0);
        insert icdCode;

        List<Lead> leadsDataFactory = TestDataFactory.createLead(1);
        Lead lead = leadsDataFactory.get(0);
        lead.ChapterName__c = accounts[0].Id;
        lead.FirstName = 'Jack';
        lead.LastName = 'Smith';
        lead.Hidden_Chapter_Change_Confirmation__c = account.Id;
        lead.is_Family_Aware_of_Referral__c = 'Yes';
        lead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
        lead.PD_ICD_Code__c = icdCode.Id;
        lead.Company = 'MAW';
        insert lead;

        List<Contact> contacts = TestDataFactory.createContact(2);
        Contact contact1 = contacts.get(0);
        contact1.FirstName = 'Test1';
        contact1.LastName = 'User2';
        contact1.AccountId = account.Id;
        contact1.ICD_10_Code__c = icdCode.Id;
        insert contacts;

        User volunteerUser = TestDataFactory.createVolunteerUser(1, 'Active Volunteer (Login)', 'Manager').get(0);
        volunteerUser.LastName = 'Smith0';
        volunteerUser.Email = 'js@email.com';
        System.runAs(TestDataFactory.adminUser) {
            insert volunteerUser;
        }

        Contact volunteerUserContact = [
                SELECT AccountId, Account.Name
                FROM Contact
                WHERE Id = :volunteerUser.ContactId
        ];

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
        wish.ContactId = contact1.Id;
        wish.Status = 'New';
        wish.Rush__c = false;
        wish.Start_Date__c = System.today();
        wish.Budget_Submitted_Date__c = System.today();
        wish.Budget_Approved_Date__c = System.today();
        wish.Update_Wish_Child_Form_Info__c = true;
        insert cases;
		
        List<Non_Wish_Events__c> nonWishEvents = TestDataFactory.createNonWishEvent(2);
        Non_Wish_Events__c nonWishEvent = nonWishEvents.get(0);
        nonWishEvent.Event_Name__c = 'Send Off';
        nonWishEvent.Event_Date__c = System.today() + 5;
        nonWishEvent.Event_Text__c = 'Sending Wish Child';
        nonWishEvent.Priority__c = '1';
        nonWishEvent.Chapter__c = volunteerUserContact.AccountId;
        nonWishEvent.RecordTypeId = Constant_AC.EVENTS_ID;
        Non_Wish_Events__c nonWishEvent2 = nonWishEvents.get(1);
        nonWishEvent2.Event_Name__c = 'Send Off';
        nonWishEvent2.Event_Date__c = System.today() + 5;
        nonWishEvent2.Event_Text__c = 'Sending Wish Child';
        nonWishEvent2.Priority__c = '2';
        nonWishEvent2.Chapter__c = volunteerUserContact.AccountId;
        nonWishEvent2.RecordTypeId = Constant_AC.EVENTS_ID;
        insert nonWishEvents;
		
		List<Role__c> roles = TestDataFactory.createRole(1, true);
        Role__c wishGranterRole = roles.get(0);
        wishGranterRole.Name = 'Wish Granter';
        wishGranterRole.isWishRole__c = true;
        insert roles;

        List<Chapter_Role__c> chapterRoles = TestDataFactory.createChapterRole(1);
        Chapter_Role__c chapterRole = chapterRoles.get(0);
        chapterRole.Chapter_Name__c = account.Id;
        chapterRole.Role_Name__c = wishGranterRole.Id;
        chapterRole.Background_Check_Required__c = true;
        insert chapterRoles;
		List<Volunteer_Opportunity__c> volunteerOpportunities = TestDataFactory.createVolunteerOpportunity(1);
        Volunteer_Opportunity__c volunteerOpportunity = volunteerOpportunities.get(0);
        volunteerOpportunity.Chapter_Role_Opportunity__c = chapterRole.Id;
        volunteerOpportunity.Wish__c = wish.Id;
        volunteerOpportunity.Non_Wish_Event__c = nonWishEvent.Id;
        volunteerOpportunity.Chapter_Name__c = wish.AccountId;
        volunteerOpportunity.RecordTypeId = Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID;
        volunteerOpportunity.Status__c = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_PENDING;
        insert volunteerOpportunities;
        Case wish1 = [
                SELECT Id, AccountId
                FROM Case
                WHERE Subject = 'Wish1'
        ][0];
        Chapter_Role__c chapterRole1 = [
                SELECT Id
                FROM Chapter_Role__c
                WHERE Chapter_Name__c = :wish1.AccountId
        ][0];
        User volunteerUser1 = [
                SELECT Id, ContactId
                FROM User
                WHERE Email = 'js@email.com'
        ][0];
        Volunteer_Opportunity__c volunteerOpportunity1 = [
                SELECT Id
                FROM Volunteer_Opportunity__c
        ][0];
        System.runAs(Utils.currentUser) {
            Volunteer_Opportunity__c updateVolunteerOpportunity = new Volunteer_Opportunity__c();
            updateVolunteerOpportunity.Id = volunteerOpportunity1.Id;
            updateVolunteerOpportunity.Status__c = 'Approved';
            updateVolunteerOpportunity.Chapter_Role_Opportunity__c = chapterRole1.Id;
            updateVolunteerOpportunity.Volunteer_Name__c = volunteerUser1.ContactId;
            Test.startTest();
            update updateVolunteerOpportunity;
       		Set<Id> volunteerIds = new Set<Id>();
            volunteerIds.add(updateVolunteerOpportunity.id);
            list<Volunteer_Opportunity__c> volunteerOpportunities1 = new list<Volunteer_Opportunity__c>();
            volunteerOpportunities1.add(updateVolunteerOpportunity);
            CaseService.updateInActiveWishGranter(volunteerIds,volunteerOpportunities1);
            Test.stopTest();
        }
    }
    

    private static List<Case> createDVReviewCases(Lead lead) {
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
        Case dvCase = TestDataFactory.createCase(1).get(0);
        dvCase.Lead__c = lead.Id;
        dvCase.RecordTypeId = Constant_AC.DIAGNOSIS_RT_ID;
        dvCase.ChapterName__c = accounts.get(0).Id;
        dvCase.Subject = lead.firstName + ' ' + lead.lastname;
        dvCase.Interview_date__c = System.today();
        dvCase.Status = Constant_AC.CASE_STATUS_NEW;
        return new List<Case>{
                dvCase
        };
    }
}