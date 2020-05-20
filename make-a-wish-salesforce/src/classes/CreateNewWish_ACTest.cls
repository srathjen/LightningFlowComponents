/*
 * @description     Test class for CreateNewWish_AC.
 * @author          unknown
 * @createdDate     unknown
 */
@isTest
private class CreateNewWish_ACTest {
    @testSetup
    static void setup() {
        List<Account> accounts = TestDataFactory.createAccount(2);
        accounts[0].Name = Constant_AC.ACCOUNT_NAME_MAW_ALABAMA;
        accounts[0].RecordTypeId = Constant_AC.CHAPTER_RT_ID;
        accounts[0].Alert_for_Unassigned_Wishes__c = 1;
        accounts[1].Name = Constant_AC.ACCOUNT_NAME_MAW_AMERICA;
        accounts[1].RecordTypeId = Constant_AC.CHAPTER_RT_ID;
        accounts[1].MAC_Email_del__c = 'testMAC@maw.com.test';
        insert accounts;

        List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
        icdCodes[0].Name = 'Q917';
        insert icdCodes;

        List<Contact> contacts = TestDataFactory.createContact(2);

        contacts[0].FirstName = 'Steven';
        contacts[0].LastName = 'Smith';
        contacts[0].Parent_Guardian_Name__c = 'Jonathan Edwards';
        contacts[0].RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
        contacts[0].ICD_10_Code__c = icdCodes[0].Id;
        contacts[0].Birthdate = Date.today().addDays(+21);
        contacts[0].Birthdate = contacts[0].Birthdate.addYears(-3);
        contacts[0].MailingPostalCode = '94105-5188';
        contacts[0].MailingStreet = '7540 E Gold Dust Ave';
        contacts[0].MailingCountry = 'United States';
        contacts[0].MailingState = 'Arizona';
        contacts[0].MailingCity = 'Scottsdale';
        contacts[0].MailingLatitude = -24.355798;
        contacts[0].MailingLongitude = 69.830469;

        contacts[1].FirstName = 'Moss';
        contacts[1].LastName = 'Smith';
        contacts[1].Birthdate = System.today() - 1;
        contacts[1].Parent_Guardian_Name__c = 'Steve Smith';
        contacts[1].RecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
        contacts[1].Title = 'Mr';
        contacts[1].Birth_Month__c = 'January';
        contacts[1].Birth_Day__c = '12';
        contacts[1].Birth_Year__c = '1985';
        contacts[1].Alternate_Phone_Type__c = 'Home';
        contacts[1].npe01__PreferredPhone__c = 'Mobile';
        contacts[1].OtherPhone = '3332211144';
        contacts[1].HomePhone = '9003910426';
        contacts[1].MobilePhone = '9003910426';
        contacts[1].I_m_on_LinkedIn__c = 'Yes';
        contacts[1].How_did_you_hear_about_Make_A_Wish__c = 'Family';
        contacts[1].MailingPostalCode = '94105-5188';
        contacts[1].MailingStreet = 'One Market Street';
        contacts[1].MailingCountry = 'United States';
        contacts[1].MailingState = 'Texas';
        contacts[1].MailingCity = 'San Francisco';
        contacts[1].MailingLatitude = -24.355798;
        contacts[1].MailingLongitude = 69.830469;
        contacts[1].Emergency_Contact__c = 'Test';
        contacts[1].Emergency_Contact_Relationship__c = 'Father';
        contacts[1].Emergency_Contact_Phone__c = '9003910426';
        contacts[1].Read__c = 'English';
        contacts[1].Language__c = 'English';
        contacts[1].Speak__c = 'English';
        contacts[1].Understand__c = 'English';
        contacts[1].Professional_Skills__c = 'Photography';
        contacts[1].Language_Notes__c = 'Test';
        contacts[1].Volunteer_Role__c = 'Special Events';
        contacts[1].is_Application__c = 'Partial Submit';
        contacts[1].AccountId = accounts[0].Id;
        contacts[1].Volunteer_Role__c = 'Water Handler';
        contacts[1].npe01__Preferred_Email__c = 'test@gmail.com';
        contacts[1].Email = 'test@gmail.com';

        insert contacts;

        List<Case> cases = TestDataFactory.createCase(1);
        cases[0].RecordTypeId = Constant_AC.WISH_RT_ID;
        cases[0].ChapterName__c = accounts[0].Id;
        cases[0].Subject = 'Parent Wish';
        cases[0].Interview_date__c = System.today();
        cases[0].Wish_Type__c = 'Disney World';
        cases[0].Start_Date__c = System.today();
        cases[0].End_Date__c = System.today();
        cases[0].ContactId = contacts[0].Id;
        cases[0].Status = 'New';
        cases[0].Start_Date__c = System.today();
        cases[0].LiabilitySignerMapKeyPair__c = 'Vennila';
        cases[0].Budget_Submitted_Date__c = System.today();
        cases[0].Budget_Approved_Date__c = System.today();
        insert cases;

        List<User> users;
        System.runAs(TestDataFactory.adminUser) {
            users = TestDataFactory.createVolunteerUser(1, 'Active Volunteer (Login)', 'Manager');
            insert users;
        }

        CaseTeamRole roleRec = [
            SELECT Id
            FROM CaseTeamRole
            WHERE Name = :Constant_AC.CASE_TEAM_ROLE_WISH_GRANTER
        ];

        List<CaseTeamMember> caseTeamMembers = TestDataFactory.createCaseTeamMember(1);
        caseTeamMembers[0].ParentId = cases[0].Id;
        caseTeamMembers[0].MemberId = users[0].Id;
        caseTeamMembers[0].TeamRoleId = roleRec.Id;
        insert caseTeamMembers;
    }

    @isTest
    static void createParentWish() {
        Case parentCase = [SELECT Id FROM Case];

        Id returnedId;

        Test.startTest();
        returnedId = CreateNewWish_AC.createCase(parentCase.Id);
        Test.stopTest();

        System.assert(returnedId != null);
    }
}