/**
 * @description Batch_UpdateVolunteerStatus_Test is used to increase the code coverage for Batch_UpdateVolunteerStatus_AC class.
 * @author Pavithra, MST Solutions
 * @date 10/05/2016
 **/
@IsTest
private class Batch_UpdateVolunteerStatus_Test {

    private final static Id CHAPTER_RT_ID = Constant_AC.CHAPTER_RT_ID;
    private final static Id VOLUNTEER_RT_ID = Constant_AC.VOLUNTEER_RT_ID;
    private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;
    private final static String CHAPTER_ROLE_WISH_GRANTER = Constant_AC.CHAPTER_ROLE_WISH_GRANTER;
    private final static String BACKGROUND_CHECK_STATUS_APPROVED = Constant_AC.BACKGROUND_CHECK_STATUS_APPROVED;
    private final static String AFFILIATION_STATUS_ACTIVE = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
    private final static Date todayDate = Date.today();
    private final static Date sixtyDays = Date.today().addDays(60);

    @TestSetup
    private static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;

        List<Account> accounts = TestDataFactory.createAccount(1);
        Account accountAzChapter = accounts.get(0);
        accountAzChapter.Name = 'Make-A-Wish Arizona';
        accountAzChapter.RecordTypeId = CHAPTER_RT_ID;
        insert accounts;

        List<Contact> contactList = TestDataFactory.createContact(1);
        Contact volunteerJoe = contactList.get(0);
        volunteerJoe.FirstName = 'Joe';
        volunteerJoe.LastName = 'Smith';
        volunteerJoe.Email = 'joe.smith@testmail.com';
        volunteerJoe.RecordTypeId = VOLUNTEER_RT_ID;
        volunteerJoe.AccountId = accountAzChapter.Id;
        volunteerJoe.B_C_Expiration_Date__c = sixtyDays;
        volunteerJoe.COI_Expiration_Date__c = sixtyDays;
        volunteerJoe.Active_Wish_Granter__c = false;
        insert contactList;

        List<npe5__Affiliation__c> affiliationList = TestDataFactory.createAffiliation(1);
        npe5__Affiliation__c affiliationJoe = affiliationList.get(0);
        affiliationJoe.npe5__Contact__c = volunteerJoe.Id;
        affiliationJoe.npe5__Organization__c = accountAzChapter.Id;
        affiliationJoe.npe5__Status__c = AFFILIATION_STATUS_ACTIVE;
        insert affiliationList;

        List<Background_check__c> backgroundCheckList = TestDataFactory.createBackgroundCheck(1);
        Background_check__c joeBackgroundCheck = backgroundCheckList.get(0);
        joeBackgroundCheck.Current__c = true;
        joeBackgroundCheck.Volunteer__c = volunteerJoe.Id;
        joeBackgroundCheck.Status__c = BACKGROUND_CHECK_STATUS_APPROVED;
        joeBackgroundCheck.Current__c = true;
        joeBackgroundCheck.Date_Completed__c = todayDate;
        joeBackgroundCheck.Date__c = sixtyDays;
        insert backgroundCheckList;

        List<Conflict_Of_Interest__c> conflictOfInterestList = TestDataFactory.createConflictOfInterest(1);
        Conflict_Of_Interest__c joeConflict = conflictOfInterestList.get(0);
        joeConflict.Volunteer_Contact__c = volunteerJoe.Id;
        joeConflict.Expiration_Date__c = sixtyDays;
        insert conflictOfInterestList;

        List<Role__c> wishRolesList = TestDataFactory.createRole(1, true);
        Role__c wishGranter = wishRolesList.get(0);
        wishGranter.Name = CHAPTER_ROLE_WISH_GRANTER;
        insert wishRolesList;

        List<Chapter_Role__c> chapterRoleList = TestDataFactory.createChapterRole(1);
        Chapter_Role__c chapterRoleWishGranter = chapterRoleList.get(0);
        chapterRoleWishGranter.Chapter_Name__c = accountAzChapter.Id;
        chapterRoleWishGranter.Role_Name__c = wishGranter.Id;
        chapterRoleWishGranter.Background_Check_Required__c = true;
        insert chapterRoleList;

        List<Volunteer_Roles__c> volunteerRolesList = TestDataFactory.createVolunteerRole(1);
        Volunteer_Roles__c wishGranterVolRole = volunteerRolesList.get(0);
        wishGranterVolRole.Chapter_Role__c = chapterRoleWishGranter.Id;
        wishGranterVolRole.Volunteer_Name__c = volunteerJoe.Id;
        wishGranterVolRole.Status__c = VOLUNTEER_ROLE_STATUS_ACTIVE;
        insert volunteerRolesList;

        trac_TriggerHandlerBase.blockTrigger = false;
    }

    @IsTest
    private static void testBatch() {
        Test.startTest();
        String CRON_EXP = '0 0 22 * * ? *';
        System.schedule('testJob1', CRON_EXP, new Batch_UpdateVolunteerStatus_AC());
        Test.stopTest();
        List<AsyncApexJob> batchJobs = [
                SELECT Id, ApexClass.Name
                FROM AsyncApexJob
                WHERE JobType = 'ScheduledApex'
                AND ApexClass.Name = 'Batch_UpdateVolunteerStatus_AC'
        ];
        System.assert(!batchJobs.isEmpty());
    }
}