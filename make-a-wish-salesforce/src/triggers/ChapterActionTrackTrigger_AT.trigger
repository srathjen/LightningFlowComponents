/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Description: Prevent outside chapter user cannot create chapter action track record for other chapter.
 Modification Log
                    ----------------
          SonarQube    Pavithra G 04/11/2018
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

trigger ChapterActionTrackTrigger_AT on Chapter_Action_Track__c (after Insert,before Insert,after Update,before Update) {
   
    if(Trigger.isInsert && Trigger.isBefore){
        ChapterActionTrack_onBeforeInsertHandler.beforeInsert(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isBefore){
        ChapterActionTrack_onBeforeUpdateHandler.beforeIUpdate(Trigger.newMap,Trigger.oldMap);
    }
    if(Trigger.isInsert && Trigger.isAfter){
        ChapterActionTrack_onAfterInsertHandler.afterInsert(Trigger.newMap);
    }
    if(Trigger.isUpdate && Trigger.isAfter){
        ChapterActionTrack_onAfterUpdateHandler.afterUpdate(Trigger.newMap,Trigger.oldMap);
    }
}