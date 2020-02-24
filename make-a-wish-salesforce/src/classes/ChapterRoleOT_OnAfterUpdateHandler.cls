/***************************************************************************************************
Author      : MST Solutions
Date        : 10/15/2016
Description : 
              
              Modification Log
              ------------------
              WVC-1887    Pavithra G  07/03/2018
              
*****************************************************************************************************/
Public class ChapterRoleOT_OnAfterUpdateHandler{    
    /*******************
       This method is handle all logic for after Update the Chapter Role O&T record Event.
       **********************/
    public static void afterUpdate(Map<Id,Chapter_Role_O_T__c> chapterRoleOTMap,Map<Id,Chapter_Role_O_T__c> chapterRoleOTOldMap){
        Map<Id,Chapter_Role_O_T__c> ownerchangedChapterRoleOTMap = new Map<Id,Chapter_Role_O_T__c>();
        for(Chapter_Role_O_T__c currRec : chapterRoleOTMap.values())
        {
            if(chapterRoleOTOldMap.get(currRec.Id).OwnerId != currRec.OwnerId){
                ownerchangedChapterRoleOTMap.put(currRec.Id,currRec);
            }
        }
        If(ownerchangedChapterRoleOTMap.Size() > 0)
           ChapterRoleOT_OnAfterInsertHelper.shareNationalStaffRecords(ownerchangedChapterRoleOTMap);

    }
}