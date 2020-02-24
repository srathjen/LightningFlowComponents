/***************************************************************************************************
Author      : MST Solutions
Date        : 10/15/2016
Description : 
              
              Modification Log
              ------------------
              WVC-1887    Pavithra G  07/03/2018
              
*****************************************************************************************************/
Public class ChapterRoleOT_OnAfterInsertHandler{    
    /*******************
       This method is handle all logic for after inserting the ChapterRole O&T record Event.
       **********************/
    public static void afterInsert(Map<Id,Chapter_Role_O_T__c> chapterRoleOTMap){
        If(chapterRoleOTMap.Size() > 0)
            ChapterRoleOT_OnAfterInsertHelper.shareNationalStaffRecords(chapterRoleOTMap);
    }
}