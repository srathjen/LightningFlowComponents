/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : NonwishEvent_OnBeforeInsertTriggerHandler is used to call the Helper class when the
              Non wish event record is get inserted.
              
              Modification Log
              ------------------
              WVC-1889    Pavithra 07/11/2018
              
*****************************************************************************************************/
Public class NonwishEvent_OnBeforeInsertHandler {
     public static void onBeforeInsert(List<Non_Wish_Events__c> newNonwishEventList){
          Set<Id> chapterIds = new Set<Id>();
          Set<String> prioritysSet = new Set<String>();
          for(Non_Wish_Events__c currRec : newNonwishEventList)
           {
                chapterIds.add(currRec.chapter__c);
                prioritysSet.add(currRec.Priority__c);
                
                if(currRec.Event_Date__c < Date.Today() && !Test.isRunningTest() && Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null)
                {
                    currRec.addError('Event Date should be greater than Today');
                }
                
            }
            if(chapterIds.size() > 0 && prioritysSet.size() > 0)
                NonwishEvent_OnBeforeInsertHelper.checkChapterPriority(chapterIds,prioritysSet,newNonwishEventList);
     }
}