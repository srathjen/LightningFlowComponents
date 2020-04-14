/**
* @description Test class for Nonwish Event Service
* @author Michelle Cominotto, Make-A-Wish
* @createdDate 4/08/2020
*/
@isTest
private class NonwishEventServiceTest {
    
    private final static Id CHAPTER_RT_ID = Constant_AC.CHAPTER_RT_ID;
    
    @TestSetup
    private static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;
        List<Account> accounts = TestDataFactory.createAccount(1);
        Account account1 = accounts.get(0);
        account1.Name = 'Make-A-Wish Arizona';
        account1.RecordTypeId = CHAPTER_RT_ID;
        insert accounts;
        
        List<Non_Wish_Events__c> nonWishEvents = TestDataFactory.createNonwishEvent(1);
        Non_Wish_Events__c event1 = nonWishEvents.get(0);
        event1.Event_Name__c = 'Monthly Team Meeting';
        event1.Event_Text__c = 'Monthly touchpoint for the Arizona volunteer team.';
        event1.Priority__c = '2';
        event1.Chapter__c = account1.Id;
        event1.Event_Date__c = Date.today().addDays(2);
        insert nonWishEvents;
        trac_TriggerHandlerBase.blockTrigger = false;
    }
    
    @isTest
    private static void validateCheckChapterPriority() {
        Account account = [
            SELECT Id 
            FROM Account 
            WHERE Name = 'Make-A-Wish Arizona'];
        List<Non_Wish_Events__c> nonWishEvents = TestDataFactory.createNonwishEvent(1);
        Non_Wish_Events__c event1 = nonWishEvents.get(0);
        event1.Event_Name__c = 'Monthly Team Review';
        event1.Event_Text__c = 'Monthly review for the Arizona volunteer team.';
        event1.Priority__c = '2';
        event1.Chapter__c = account.Id;
        event1.Event_Date__c = Date.today().addDays(4);
        Test.startTest();
        NonwishEventService.checkChapterPriority(nonWishEvents);
        Test.stopTest();
        List<Non_Wish_Events__c> newNonWishEvents = [
            SELECT Id 
            FROM Non_Wish_Events__c 
            WHERE Event_Name__c = 'Monthly Team Review'];
        System.assert(newNonWishEvents.isEmpty(), 'Conflicting event with same priority has been saved');
    }
    
    @isTest
    private static void validateCheckPriorityChange() {
        Non_Wish_Events__c updateNonwishEvent = [
            SELECT Id, Event_Name__c, Event_Text__c, Priority__c, Chapter__c, Event_Date__c 
            FROM Non_Wish_Events__c 
            WHERE Event_Name__c = 'Monthly Team Meeting'];
        updateNonwishEvent.Priority__c = '3';
        Test.startTest();
        update updateNonwishEvent;
        Test.stopTest();
        Non_Wish_Events__c teamEvent = [
            SELECT Id, Priority__c 
            FROM Non_Wish_Events__c 
            WHERE Event_Name__c = 'Monthly Team Meeting'];
        System.assert(teamEvent.Priority__c == '3', 'Priority conflicts with existing event and cannot update to 3');
    }
}