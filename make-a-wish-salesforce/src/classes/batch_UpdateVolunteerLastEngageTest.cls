@isTest
private class batch_UpdateVolunteerLastEngageTest {
    
    private final static Id CHAPTER_RT_ID = Constant_AC.CHAPTER_RT_ID;
    private final static Id VOLUNTEER_RT_ID = Constant_AC.VOLUNTEER_RT_ID;
    private final static Id NON_WISH_EVENT_RT_ID = Constant_AC.NON_WISH_EVENT_RT_ID;
    private final static Date fiveDaysPast = Date.today().addDays(-5);
    
    @TestSetup
    private static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;
        
        List<Account> accounts = TestDataFactory.createAccount(1);
        Account accountAzChapter = accounts.get(0);
        accountAzChapter.Name = 'Make-A-Wish Arizona';
        accountAzChapter.RecordTypeId = CHAPTER_RT_ID;
        insert accounts;
        
        List<Contact> contactList = TestDataFactory.createContact(1);
        Contact volunteerAgnes = contactList.get(0);
        volunteerAgnes.RecordTypeId = VOLUNTEER_RT_ID;
        volunteerAgnes.AccountId = accountAzChapter.Id;
        volunteerAgnes.FirstName = 'Agnes';
        volunteerAgnes.LastName = 'Reynolds';
        insert contactList;
        
        List<Non_Wish_Events__c> nonWishEvents = TestDataFactory.createNonwishEvent(2);
        Non_Wish_Events__c nonWishEventMeetup = nonWishEvents.get(0);
        nonWishEventMeetup.Event_Name__c = 'Team Engagement Meeting';
        nonWishEventMeetup.Chapter__c = accountAzChapter.Id;
        nonWishEventMeetup.Event_Date__c = Date.today().addDays(-7);
        Non_Wish_Events__c nonWishEventTraining = nonWishEvents.get(1);
        nonWishEventTraining.Event_Name__c = 'Volunteer Training Updates';
        nonWishEventTraining.Chapter__c = accountAzChapter.Id;
        nonWishEventTraining.Event_Date__c = fiveDaysPast;
        insert nonWishEvents;
        
        List<Volunteer_Opportunity__c> volOppsList = TestDataFactory.createVolunteerOpportunity(2);
        Volunteer_Opportunity__c volOpp1 = volOppsList.get(0);
        volOpp1.Volunteer_Name__c = volunteerAgnes.Id;
        volOpp1.Non_Wish_Event__c = nonWishEventMeetup.Id;
        volOpp1.RecordTypeId = NON_WISH_EVENT_RT_ID;
        Volunteer_Opportunity__c volOpp2 = volOppsList.get(1);
        volOpp2.Volunteer_Name__c = volunteerAgnes.Id;
        volOpp2.Non_Wish_Event__c = nonWishEventTraining.Id;
        volOpp2.RecordTypeId = NON_WISH_EVENT_RT_ID;
        insert volOppsList;
        
        trac_TriggerHandlerBase.blockTrigger = false;
    }
    
    @isTest
    private static void validateBatchUpdate() {
        Test.startTest();
        Database.executeBatch(new batch_UpdateVolunteerLastEngage());
        Test.stopTest();
        Contact contactAgnes = [
            SELECT Id, Date_of_last_engagement__c 
            FROM Contact
            WHERE Name = 'Agnes Reynolds'];
        system.assert(contactAgnes.Date_of_last_engagement__c == fiveDaysPast);
    }
    
    @isTest
    private static void validateScheduler() {
        test.startTest();
        String CRON_EXP = '0 0 23 * * ? *';
        System.schedule('testJobSchedule', CRON_EXP, new batch_UpdateVolunteerLastEngage());
        test.stopTest();
        List<AsyncApexJob> batchJobs = [
            SELECT Id, ApexClass.Name 
            FROM AsyncApexJob 
            WHERE JobType = 'ScheduledApex'
            AND ApexClass.Name = 'batch_UpdateVolunteerLastEngage'];
        system.assert(!batchJobs.isEmpty());
    }
}