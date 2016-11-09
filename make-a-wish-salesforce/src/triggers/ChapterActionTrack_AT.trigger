/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kesavakumar Murugesan
Date        : 6/1/2016
Description : This trigger is used to prevent duplicate sort order creation for chapter action track record 
*******************************************************************************************************************/
trigger ChapterActionTrack_AT on Chapter_Action_Track__c (after update, before insert, before update) {
    
   // Doing field level validation and checking duplicates.
    if(Trigger.isInsert && Trigger.isBefore) {
        List<Chapter_Action_Track__c> newActionsList = new List<Chapter_Action_Track__c>();
        
        for(Chapter_Action_Track__c chapterAction : Trigger.New) {
            newActionsList.add(chapterAction);
            if(chapterAction.Case_Type_Stage__c == 'Wish Determination') {
                chapterAction.Wish_type__c = 'Standard';
            }
        }
        if(newActionsList.size()>0) {
            ChapterActionTrackHandler.validations(newActionsList);
        }
    }
    
    if(Trigger.isUpdate && Trigger.isBefore) {
        List<Chapter_Action_Track__c> newActionsList = new List<Chapter_Action_Track__c>();
        
        for(Chapter_Action_Track__c chapterAction : Trigger.New) {
            if((chapterAction.Sort_Order__c != Trigger.oldMap.get(chapterAction.Id).Sort_Order__c) || (chapterAction.Case_Type_Stage__c != Trigger.oldMap.get(chapterAction.Id).Case_Type_Stage__c)
              || (chapterAction.Wish_type__c != Trigger.oldMap.get(chapterAction.Id).Wish_type__c) || (chapterAction.Chapter_Name__c != Trigger.oldMap.get(chapterAction.Id).Chapter_Name__c)) {
                newActionsList.add(chapterAction);
            }
        }
        if(newActionsList.size()>0) {
            ChapterActionTrackHandler.validations(newActionsList);
        }
    }
}