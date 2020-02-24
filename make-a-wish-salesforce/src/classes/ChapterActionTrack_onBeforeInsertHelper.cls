/***************************************************************************************************
Author      : MST Solutions
Date        : 10/15/2016
Description : 
              
              Modification Log
              ------------------
              WVC-1887    Pavithra G  07/03/2018
              
*****************************************************************************************************/
Public class ChapterActionTrack_onBeforeInsertHelper{    
   /***************
       Show the error message when the current logged in user role and chapter name are diffrent. 
   ******************/
    public static void showErrorMessageDistinctRole(set<Id> chapterIdSet,Map<Id,Chapter_Action_Track__c> chapterActionTrackMap){
         Map<Id,String> chapterIdNameMap = New Map<Id,String>();
         chapterIdNameMap = ChapterStaffRecordSharing_AC.getChapterName(chapterIdSet);
         String userRole = [SELECT UserRole.Name FROM User WHERE id =:userInfo.getUserId() Limit 1].UserRole.Name; 
           for(Chapter_Action_Track__c currRec : chapterActionTrackMap.values()){
               if(Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null && userRole != chapterIdNameMap.get(currRec.Chapter_Name__c) && !Test.isRunningTest()){
                   currRec.addError('You have no access to create Chapter Action Track records for other chapters');
               }
           }
    }
}