/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : 
              
              Modification Log
              ------------------
              WVC-1887    Pavithra G  07/03/2018
              
*****************************************************************************************************/
Public class ChapterActionTrack_onAfterInsertHandler{    
    /*******************
       This method is handle all logic for after inserting the ChapterRole Action Recordrecord Event.
       **********************/
    public static void afterInsert(Map<Id,Chapter_Action_Track__c> chapterActionTrackMap){         
         If(chapterActionTrackMap.Size() > 0)
             ChapterActionTrack_onAfterInsertHelper.shareNationalStaffRecords(chapterActionTrackMap);
    }
}