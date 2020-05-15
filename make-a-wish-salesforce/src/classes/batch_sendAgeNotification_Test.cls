/*******************************************************************************************
Author : MST Solutions
Created Date:3/15/2018 
Description: This class is used to increase the code coverage for batch_sendAgeNotificationToCaseOwner_AC. 

**********************************************************************************************/
@IsTest
public class batch_sendAgeNotification_Test {
    
    @TestSetup
    static void setUp() {
        trac_TriggerHandlerBase.blockTrigger = true;
        
        List<Account> accountList = TestDataFactory.createAccount(1);
        Account accountAzChapter = accountList.get(0);
        accountAzChapter.Name = 'Make-A-Wish Arizona';
        accountAzChapter.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
        insert accountList;
        
        List<Contact> contactList = TestDataFactory.createContact(4);
        Contact wishChildJuniper = contactList.get(0);
        wishChildJuniper.FirstName = 'Juniper';
        wishChildJuniper.LastName = 'Lee';
        wishChildJuniper.RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
        wishChildJuniper.Birthdate = Date.today().addYears(-18);
        wishChildJuniper.MailingPostalCode = '94105-5188';
        wishChildJuniper.MailingStreet = '7540 E Gold Dust Ave';
        wishChildJuniper.MailingCountry = 'United States';
        wishChildJuniper.MailingState = 'Arizona';
        wishChildJuniper.MailingCity = 'Scottsdale';
        wishChildJuniper.MailingLatitude = -24.355798;
        wishChildJuniper.MailingLongitude = 69.830469;
        Contact wishFamilyRoger = contactList.get(1);
        wishFamilyRoger.FirstName = 'Roger';
        wishFamilyRoger.LastName = 'Lee';
        wishFamilyRoger.RecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
        wishFamilyRoger.Birthdate = Date.today().addYears(-18);
        wishFamilyRoger.Email = 'testmawa@gmail.com';
        wishFamilyRoger.MailingPostalCode = '94105-5188';
        wishFamilyRoger.MailingStreet = '7540 E Gold Dust Ave';
        wishFamilyRoger.MailingCountry = 'United States';
        wishFamilyRoger.MailingState = 'Arizona';
        wishFamilyRoger.MailingCity = 'Scottsdale';
        wishFamilyRoger.MailingLatitude = -24.355798;
        wishFamilyRoger.MailingLongitude = 69.830469;
        wishFamilyRoger.Region_Chapter__c = accountAzChapter.Id;
        Contact wishChildKali = contactList.get(2);
        wishChildKali.FirstName = 'Kali';
        wishChildKali.LastName = 'Sol';
        wishChildKali.Parent_Guardian_Name__c = 'Luna Sol';
        wishChildKali.RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
        wishChildKali.Birthdate = System.today().addMonths(1).addYears(-18);
        wishChildKali.MailingPostalCode = '94105-5188';
        wishChildKali.MailingStreet = '7545 E Gold Dust Ave';
        wishChildKali.MailingCountry = 'United States';
        wishChildKali.MailingState = 'Arizona';
        wishChildKali.MailingCity = 'Scottsdale';
        wishChildKali.MailingLatitude = -24.355798;
        wishChildKali.MailingLongitude = 69.830469;
        Contact wishFamilyLuna = contactList.get(3);
        wishFamilyLuna.FirstName = 'Luna';
        wishFamilyLuna.LastName = 'Sol';
        wishFamilyLuna.RecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
        wishFamilyLuna.Birthdate = System.today().addMonths(1).addYears(-18);
        wishFamilyLuna.Email = 'testmawa2@gmail.com';
        wishFamilyLuna.MailingPostalCode = '94105-5188';
        wishFamilyLuna.MailingStreet = '7545 E Gold Dust Ave';
        wishFamilyLuna.MailingCountry = 'United States';
        wishFamilyLuna.MailingState = 'Arizona';
        wishFamilyLuna.MailingCity = 'Scottsdale';
        wishFamilyLuna.MailingLatitude = -24.355798;
        wishFamilyLuna.MailingLongitude = 69.830469;
        wishFamilyLuna.Region_Chapter__c = accountAzChapter.Id;
        insert contactList;
        
        List<npe4__Relationship__c> relationshipList = TestDataFactory.createRelationship(2);
        npe4__Relationship__c relationshipLeeFamily = relationshipList.get(0);
        relationshipLeeFamily.npe4__Contact__c = wishChildJuniper.Id;
        relationshipLeeFamily.npe4__RelatedContact__c = wishFamilyRoger.Id;
        relationshipLeeFamily.npe4__Status__c = 'Active';
        relationshipLeeFamily.npe4__Type__c = 'Sibling';
        npe4__Relationship__c relationshipSolFamily = relationshipList.get(1);
        relationshipSolFamily.npe4__Contact__c = wishChildKali.Id;
        relationshipSolFamily.npe4__RelatedContact__c = wishFamilyLuna.Id;
        relationshipSolFamily.npe4__Status__c = 'Active';
        relationshipSolFamily.npe4__Type__c = 'Sibling';
        insert relationshipList;
        
        List<Case> caseList = TestDataFactory.createCase(2);
        Case wishCaseLee = caseList.get(0);
        wishCaseLee.RecordTypeId = Constant_AC.WISH_RT_ID;
        wishCaseLee.ChapterName__c = accountAzChapter.Id;
        wishCaseLee.Subject = 'Juniper Lee Wish';
        wishCaseLee.Interview_date__c = System.today();
        wishCaseLee.Wish_Type__c = 'Disney World';
        wishCaseLee.Start_Date__c = System.today();
        wishCaseLee.End_Date__c = System.today();
        wishCaseLee.ContactId = wishChildJuniper.Id;
        Case wishCaseSol = caseList.get(1);
        wishCaseSol.RecordTypeId = Constant_AC.WISH_RT_ID;
        wishCaseSol.ChapterName__c = accountAzChapter.Id;
        wishCaseSol.Subject = 'Kali Sol Wish';
        wishCaseSol.Interview_date__c = System.today();
        wishCaseSol.Wish_Type__c = 'Disney World';
        wishCaseSol.Start_Date__c = System.today();
        wishCaseSol.End_Date__c = System.today();
        wishCaseSol.ContactId = wishChildKali.Id;
        insert caseList;
        
        Profile sysAdmin = [
            SELECT Id 
            FROM Profile 
            WHERE Name = 'System Administrator'
        ];
        
        List<User> userList = TestDataFactory.createUser(2);
        User tempUserInactive = userList.get(0);
        tempUserInactive.ProfileId = sysAdmin.Id;
        tempUserInactive.Username = 'sysAdminInactive@tempUser.com';
        tempUserInactive.IsActive = false;
        User tempUserActive = userList.get(1);
        tempUserActive.ProfileId = sysAdmin.Id;
        tempUserActive.Username = 'sysAdminActive@tempUser.com';
        tempUserActive.IsActive = true;
        insert userList;
        
        trac_TriggerHandlerBase.blockTrigger = false;
    }
    
    @IsTest 
    static void wishChildAge18Birthday() {
        Test.startTest();
        Database.executeBatch(new batch_sendAgeNotificationToCaseOwner_AC());
        Test.stopTest();
        Case caseUpdate = [
            SELECT Id, Subject, HiddenChildAgeEmailNotification__c 
            FROM Case 
            WHERE Subject = 'Juniper Lee Wish'
        ];
    }
    
    @IsTest
    static void inActivateCaseOwner() {
        User inactiveUser = [
            SELECT Id, IsActive 
            FROM User 
            WHERE Username = 'sysAdminInactive@tempUser.com'
        ];
        Case caseUpdate = [
            SELECT Id, OwnerId 
            FROM Case 
            WHERE Subject = 'Kali Sol Wish'
        ];
        caseUpdate.OwnerId = inactiveUser.Id;
        update caseUpdate;
        
        User activeUser = [
            SELECT Id, IsActive 
            FROM User 
            WHERE Username = 'sysAdminActive@tempUser.com'
        ];
        
        Test.startTest();
        System.runAs(activeUser) {
            Database.executeBatch(new batch_sendAgeNotificationToCaseOwner_AC());
        }
        Test.stopTest();
        
        Case caseNotUpdated = [
            SELECT Id, HiddenChildAgeEmailNotification__c 
            FROM Case 
            WHERE Subject = 'Kali Sol Wish'
        ];
        System.assert(caseNotUpdated.HiddenChildAgeEmailNotification__c == null);
    }
    
    @isTest
    static void validateScheduler() {
        test.startTest();
        String CRON_EXP = '0 0 23 * * ? *';
        System.schedule('testJobSchedule', CRON_EXP, new batch_sendAgeNotificationToCaseOwner_AC());
        test.stopTest();
        List<AsyncApexJob> batchJobs = [
            SELECT Id, ApexClass.Name 
            FROM AsyncApexJob 
            WHERE JobType = 'ScheduledApex'
            AND ApexClass.Name = 'batch_sendAgeNotificationToCaseOwner_AC'
        ];
        system.assert(!batchJobs.isEmpty());
    }
}