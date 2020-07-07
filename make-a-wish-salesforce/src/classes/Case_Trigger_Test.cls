/**
 * @author Steve Doucette, Traction on Demand 
 * @date 10/24/2019
 */
@IsTest
private class Case_Trigger_Test {

    @TestSetup
    public static void setUp() {
        trac_TriggerHandlerBase.blockTrigger = true;
        User currentUser = Utils.currentUser;
        List<Account> accounts = TestDataFactory.createAccount(1);
        Account account = accounts.get(0);
        account.Name = 'Make-A-Wish Arizona';
        account.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
        account.Volunteer_Manager__c = currentUser.Id;
        account.Alert_for_Unassigned_Wishes__c = 1;
        insert accounts;

        String profileName = 'Full Access National Staff';
        String portalRole = 'Manager';
        Id userRoleId = [
                SELECT Id
                FROM UserRole
                WHERE Name = 'National Staff'
        ].Id;

        List<User> users = TestDataFactory.createUser(2);
        User nationalStaffUser1 = users.get(0);
        User nationalStaffUser2 = users.get(1);
        System.runAs(Utils.currentUser) {
            Profile profile = [
                    SELECT Id,Name
                    FROM Profile
                    WHERE Name = :profileName
                    LIMIT 1
            ];
            nationalStaffUser1.ProfileId = profile.Id;
            nationalStaffUser1.PortalRole = portalRole;
            nationalStaffUser1.UserRoleId = userRoleId;
            nationalStaffUser1.LastName = 'Doe1';
            nationalStaffUser1.Username = 'doe1@emailmawtest.com';
            nationalStaffUser1.ManagerId = Utils.currentUser.Id;

            nationalStaffUser2.ProfileId = profile.Id;
            nationalStaffUser2.PortalRole = portalRole;
            nationalStaffUser2.UserRoleId = userRoleId;
            nationalStaffUser2.LastName = 'Doe2';
            nationalStaffUser2.Username = 'doe2@emailmawtest.com';
            nationalStaffUser2.ManagerId = Utils.currentUser.Id;
            insert users;
        }

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

        User volunteerUser = TestDataFactory.createVolunteerUser(1, 'Active Volunteer (Login)', 'Manager').get(0);
        volunteerUser.LastName = 'Smith0';
        System.runAs(TestDataFactory.adminUser) {
            insert volunteerUser;
        }

        List<Contact> contacts = TestDataFactory.createContact(1);
        Contact contact1 = contacts.get(0);
        contact1.FirstName = 'Test1';
        contact1.LastName = 'User2';
        contact1.AccountId = account.Id;
        contact1.ICD_10_Code__c = icdCode.Id;
        insert contacts;

        trac_TriggerHandlerBase.blockTrigger = false;
    }

    @IsTest
    static void createUpdateCase() {
        Lead lead = [
                SELECT Id
                FROM Lead
                LIMIT 1
        ];
        Contact contact = [
                SELECT Id, AccountId
                FROM Contact
                LIMIT 1
        ];
        User nationalStaffUser1 = [
                SELECT Id
                FROM User
                WHERE LastName = 'Doe1'
        ];
        User nationalStaffUser2 = [
                SELECT Id
                FROM User
                WHERE LastName = 'Doe2'
        ];

        List<Case> cases = TestDataFactory.createCase(4);
        Case wish1 = cases.get(0);
        wish1.Lead__c = lead.Id;
        wish1.RecordTypeId = Constant_AC.WISH_RT_ID;
        wish1.ChapterName__c = contact.AccountId;
        wish1.Subject = 'Wish1';
        wish1.Interview_date__c = System.today();
        wish1.Wish_Type__c = 'Hawaii';
        wish1.Start_Date__c = System.today();
        wish1.End_Date__c = System.today();
        wish1.ContactId = contact.Id;
        wish1.Rush__c = false;
        wish1.Start_Date__c = System.today();
        wish1.Budget_Submitted_Date__c = System.today();
        wish1.Budget_Approved_Date__c = System.today();
        wish1.Update_Wish_Child_Form_Info__c = true;
        wish1.Status = Constant_AC.CASE_STATUS_NEW;
        wish1.OwnerId = nationalStaffUser1.Id;

        Case wish2 = cases.get(1);
        wish2.Lead__c = lead.Id;
        wish2.RecordTypeId = Constant_AC.WISH_RT_ID;
        wish2.ChapterName__c = contact.AccountId;
        wish2.Subject = 'Wish1';
        wish2.Interview_date__c = System.today();
        wish2.Wish_Type__c = 'Hawaii';
        wish2.Start_Date__c = System.today();
        wish2.End_Date__c = System.today();
        wish2.ContactId = contact.Id;
        wish2.Rush__c = false;
        wish2.Start_Date__c = System.today();
        wish2.Budget_Submitted_Date__c = System.today();
        wish2.Budget_Approved_Date__c = System.today();
        wish2.Update_Wish_Child_Form_Info__c = true;
        wish2.Status = Constant_AC.CASE_STATUS_READY_TO_INTERVIEW;
        wish2.OwnerId = nationalStaffUser1.Id;

        Case wish3 = cases.get(2);
        wish3.Lead__c = lead.Id;
        wish3.RecordTypeId = Constant_AC.WISH_RT_ID;
        wish3.ChapterName__c = contact.AccountId;
        wish3.Subject = 'Wish1';
        wish3.Interview_date__c = System.today();
        wish3.Wish_Type__c = 'Hawaii';
        wish3.Start_Date__c = System.today();
        wish3.End_Date__c = System.today();
        wish3.ContactId = contact.Id;
        wish3.Rush__c = false;
        wish3.Start_Date__c = System.today();
        wish3.Budget_Submitted_Date__c = System.today();
        wish3.Budget_Approved_Date__c = System.today();
        wish3.Update_Wish_Child_Form_Info__c = true;
        wish3.Status = Constant_AC.CASE_STATUS_WISH_DETERMINED;
        wish3.OwnerId = nationalStaffUser1.Id;

        Case wish4 = cases.get(3);
        wish4.Lead__c = lead.Id;
        wish4.RecordTypeId = Constant_AC.DIAGNOSIS_RT_ID;
        wish4.ChapterName__c = contact.AccountId;
        wish4.Subject = 'Wish1';
        wish4.Interview_date__c = System.today();
        wish4.Wish_Type__c = 'Hawaii';
        wish4.Start_Date__c = System.today();
        wish4.End_Date__c = System.today();
        wish4.ContactId = contact.Id;
        wish4.Rush__c = false;
        wish4.Start_Date__c = System.today();
        wish4.Budget_Submitted_Date__c = System.today();
        wish4.Budget_Approved_Date__c = System.today();
        wish4.Update_Wish_Child_Form_Info__c = true;
        wish4.Status = Constant_AC.CASE_STATUS_ESCALATED;
        wish1.OwnerId = nationalStaffUser1.Id;

        Test.startTest();
        insert cases;

        wish1.Subject = 'WishUpdate';
        wish1.Comment_1__c = 'Abc';
        wish1.Appropriate_Comments__c = 'Abc';
        wish1.Please_Explain__c = 'Abc';
        wish1.Wish_Clearance_Needed__c = 'Yes';
        wish1.Status = Constant_AC.CASE_STATUS_READY_TO_INTERVIEW;
        wish1.OwnerId = nationalStaffUser2.Id;

        wish2.Subject = 'WishUpdate';
        wish2.Comment_1__c = 'Abc';
        wish2.Status = Constant_AC.CASE_STATUS_READY_TO_ASSIGN;
        wish2.Sub_Status__c = Constant_AC.CASE_SUB_STATUS_PENDING;
        wish2.OwnerId = nationalStaffUser2.Id;

        wish3.Subject = 'WishUpdate';
        wish3.Comment_1__c = 'Abc';
        wish3.Status = Constant_AC.CASE_STATUS_WISH_DETERMINED;
        wish3.OwnerId = nationalStaffUser2.Id;

        wish4.Subject = 'WishUpdate';
        wish4.Comment_1__c = 'Abc';
        wish4.Status = Constant_AC.CASE_STATUS_ESCALATED;
        wish4.OwnerId = nationalStaffUser2.Id;

        update cases;
        Test.stopTest();
    }
}