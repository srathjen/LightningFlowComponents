/**
* @description Nonwish Event Service, centralizes Nonwish Events business rules
* @author Michelle Cominotto, Make-A-Wish
* @createdDate 4/08/2020
*/
public class NonwishEventService {
    /**
    * Checks if chapter already has event with same priority and displays error
    * @param nonwishEventsList
    */
    public static void checkChapterPriority(List<Non_Wish_Events__c> nonwishEventsList) {
        if(nonwishEventsList.isEmpty()) {
            return;
        }
        try{
            Set<Id> eventChapterSet = new Set<Id>();
            Set<String> eventPrioritySet = new Set<String>();
            Set<String> chapterPrioritySet = new Set<String>();
            for(Non_Wish_Events__c event : nonwishEventsList) {
                eventChapterSet.add(event.Chapter__c);
                eventPrioritySet.add(event.Priority__c);
            }
            for(Non_Wish_Events__c event : [
                SELECT Id, Chapter__c, Priority__c, Event_Date__c, RecordTypeId
                FROM Non_Wish_Events__c
                WHERE Chapter__c IN :eventChapterSet
                AND Priority__c != null 
                AND Priority__c = :eventPrioritySet 
                AND Event_Date__c > :Date.today()
            ]) {
                chapterPrioritySet.add(event.Chapter__c + '-' + event.Priority__c);
            }
            if(!chapterPrioritySet.isEmpty()) {
                for(Non_Wish_Events__c event : nonwishEventsList) {
                    if(event.Priority__c != null && chapterPrioritySet.contains(event.Chapter__c + '-' + event.Priority__c) 
                       && Bypass_Triggers__c.getValues(userInfo.getUserId()) == null) {
                           event.addError('This Chapter already has event for same priority. Please select some other priority.');
                       }
                }
            }
        } catch(Exception e) {
            for(Non_Wish_Events__c event : nonwishEventsList) {
                ErrorMessage_AC.createdebugRec('NonwishEventService', String.valueof(event), String.valueOf(e), 
                                               'checkChapterPriority', event.Id, e.getStackTraceString(), 'Error');
                event.addError(Label.Debug_log_error_message);
            }
        }
    }
    
    /**
    * Checks if event priority has changed
    * @param nonwishEventsList
    * @param oldNonwishEventsMap
    */
    public static void checkPriorityChange(List<Non_Wish_Events__c> nonwishEventsList, Map<Id, Non_Wish_Events__c> oldNonwishEventsMap) {
        if(nonwishEventsList.isEmpty()) {
            return;
        }
        List<Non_Wish_Events__c> priorityChangeList = new List<Non_Wish_Events__c>();
        for(Non_Wish_Events__c newEvent : nonwishEventsList) {
            if(newEvent.Priority__c != oldNonwishEventsMap.get(newEvent.Id).Priority__c) {
                priorityChangeList.add(newEvent);
            }
        }
        checkChapterPriority(priorityChangeList);
    }
}