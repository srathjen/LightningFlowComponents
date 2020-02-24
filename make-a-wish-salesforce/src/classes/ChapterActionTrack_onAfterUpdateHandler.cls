/**************************************************************************************************
Author      : MST Solutions
Date        : 
Description : 
              
              Modification Log
              ------------------
              WVC-1887    Pavithra G  07/03/2018
              
*****************************************************************************************************/
Public class ChapterActionTrack_onAfterUpdateHandler{    
    /*******************
       This method is handle all logic for after inserting the ChapterRole Action Recordrecord Event.
       **********************/
    public static void afterUpdate(Map<Id,Chapter_Action_Track__c> chapterActionTrackNewMap,Map<Id,Chapter_Action_Track__c> chapterActionTrackOldMap){         
         Map<Id,Chapter_Action_Track__c> ownerChangedChapterActionMap = new Map<Id,Chapter_Action_Track__c>();
         for(Chapter_Action_Track__c currRec : chapterActionTrackNewMap.values()){
             If(currRec.OwnerId != chapterActionTrackOldMap.get(currRec.id).OwnerId)
                 ownerChangedChapterActionMap.put(currRec.Id,currRec);
         }
         
         If(ownerChangedChapterActionMap.Size() > 0)
             ChapterActionTrack_onAfterInsertHelper.shareNationalStaffRecords(ownerChangedChapterActionMap);
    }
}