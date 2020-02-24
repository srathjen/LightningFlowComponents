/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : 
              
              Modification Log
              ------------------
              WVC-1887    Pavithra G  07/03/2018
              
*****************************************************************************************************/
Public class ChapterActionTrack_onBeforeUpdateHandler{    
    /*******************
       This method is handle all logic for after inserting the ChapterRole O&T record Event.
       **********************/
    public static void beforeIUpdate(Map<Id,Chapter_Action_Track__c> chapterActionNewMap,Map<Id,Chapter_Action_Track__c> chapterActionOldMap){
        String userRole = [SELECT UserRole.Name FROM User WHERE id =:userInfo.getUserId() Limit 1].UserRole.Name;
        Set<Id> chapterIdSet = new Set<Id>();
        Map<Id,Chapter_Action_Track__c> chapterActionMap = new Map<Id,Chapter_Action_Track__c>();
          for(Chapter_Action_Track__c currRec : chapterActionNewMap.Values()){
               if(currRec.Chapter_Name__c != Null && userRole != 'National Staff' && chapterActionOldMap.get(currRec.Id).Chapter_Name__c != currRec.Chapter_Name__c)
                   chapterIdSet.add(currRec.Chapter_Name__c);
                   chapterActionMap.put(currRec.Id,currRec);
           }
           if(chapterIdSet.Size() > 0)
               ChapterActionTrack_onBeforeInsertHelper.showErrorMessageDistinctRole(chapterIdSet,chapterActionMap); 
    }
}