@IsTest
public class AffiliationTrigger_Test {

    @IsTest
    public static void insertUpdateAffiliation() {
        trac_TriggerHandlerBase.blockTrigger = true;

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

        List<Contact> contacts = TestDataFactory.createContact(1);
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

        trac_TriggerHandlerBase.blockTrigger = false;

        Test.startTest();
        RecursiveTriggerHandler.isFirstTime = true;
        List<npe5__Affiliation__c> affiliations = TestDataFactory.createAffiliation(2);
        npe5__Affiliation__c affiliation1 = affiliations[0];
        affiliation1.npe5__Contact__c = contact1.Id;
        affiliation1.npe5__Organization__c = account.Id;
        affiliation1.npe5__Primary__c = true;
        affiliation1.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_PENDING;
        affiliation1.Constituent_Code__c = Constant_AC.BOARD_MEMBER_RT_LABEL;

        npe5__Affiliation__c affiliation2 = affiliations[1];
        affiliation2.npe5__Contact__c = volunteerUser.ContactId;
        affiliation2.npe5__Organization__c = account.Id;
        affiliation2.npe5__Primary__c = true;
        affiliation2.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_PENDING;
        affiliation2.Constituent_Code__c = Constant_AC.BOARD_MEMBER_RT_LABEL;
        insert affiliations;

        affiliation2.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
        update affiliation2;

        delete affiliation2;
        Test.stopTest();
    }
}