/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : 
              
              Modification Log
              ------------------
              WVC-1887    Pavithra G  07/03/2018
              
*****************************************************************************************************/
Public class ChapterActionTrack_onBeforeInsertHandler{    
    /*******************
       This method is handle all logic for after inserting the ChapterRole O&T record Event.
       **********************/
    public static void beforeInsert(List<Chapter_Action_Track__c> chapterActionTrackList){
        String userRole = [SELECT UserRole.Name FROM User WHERE id =:userInfo.getUserId() Limit 1].UserRole.Name;
        Set<Id> chapterIdSet = new Set<Id>();
        Map<Id,Chapter_Action_Track__c> chapterActionMap = new Map<Id,Chapter_Action_Track__c>();
          for(Chapter_Action_Track__c currRec : chapterActionTrackList){
               if(currRec.Chapter_Name__c != Null && userRole != 'National Staff')
                   chapterIdSet.add(currRec.Chapter_Name__c);
                   chapterActionMap.put(currRec.Id,currRec);
           }
           if(chapterIdSet.Size() > 0)
               ChapterActionTrack_onBeforeInsertHelper.showErrorMessageDistinctRole(chapterIdSet,chapterActionMap);
        
             
    }
}