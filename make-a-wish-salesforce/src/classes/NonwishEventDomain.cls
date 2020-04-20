/**
* @description Domain class for Non-wish Event trigger
* @author Michelle Cominotto, Make-A-Wish
* @createdDate 4/08/2020
*/

public class NonwishEventDomain extends trac_TriggerHandlerBase {
    private List<Non_Wish_Events__c> newNonwishEventsList = (List<Non_Wish_Events__c>)newRecordsList;
    private List<Non_Wish_Events__c> oldNonwishEventsList = (List<Non_Wish_Events__c>)oldRecordsList;
    private Map<Id, Non_Wish_Events__c> newNonwishEventsMap = (Map<Id, Non_Wish_Events__c>)newRecordsMap;
    private Map<Id, Non_Wish_Events__c> oldNonwishEventsMap = (Map<Id, Non_Wish_Events__c>)oldRecordsMap;
    
    /**
    * Before insert of non-wish event
    */
    public override void handleBeforeInsert() {
        for(Non_Wish_Events__c event : newNonwishEventsList) {
            if(event.Event_Date__c < Date.today() && !Test.isRunningTest() && !blockTrigger) {
                event.addError('Event Date should be greater than Today');
            }
        }
        NonwishEventService.checkChapterPriority(newNonwishEventsList);
    }
    
    /**
    * Before update of non-wish event
    */
    public override void handleBeforeUpdate() {
        for(Non_Wish_Events__c newEvent : newNonwishEventsList) {
            Non_Wish_Events__c oldEvent = oldNonwishEventsMap.get(newEvent.Id);
            if(newEvent.Event_Date__c != oldEvent.Event_Date__c && newEvent.Event_Date__c < Date.today() && !Test.isRunningTest() && !blockTrigger) {
                newEvent.addError('Event Date should be greater than Today');
            }
        }
        NonwishEventService.checkPriorityChange(newNonwishEventsList, oldNonwishEventsMap);
    }
}