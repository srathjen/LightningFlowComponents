/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : NonwishEvent_OnBeforeUpdateHandler is used to call the Helper class when the
              Non wish event record is get updated.
              
              Modification Log
              ------------------
              WVC-1889    Pavithra 07/11/2018
              
*****************************************************************************************************/
Public class NonwishEvent_OnBeforeUpdateHandler {
     public static void onBeforeUpdate(List<Non_Wish_Events__c> newNonwishEventList,Map<Id,Non_Wish_Events__c> oldNonwishEventMap){
         Set<Id> chapterIds = new Set<Id>();
         Set<String> prioritysSet = new Set<String>();
         for(Non_Wish_Events__c currRec : newNonwishEventList){
            if(currRec.chapter__c != Null)
            {
                chapterIds.add(currRec.chapter__c);
            }
            if(currRec.Priority__c!= oldNonwishEventMap.get(currRec.id).Priority__c)
                prioritysSet.add(currRec.Priority__c);
            
            if(currRec.Event_Date__c != oldNonwishEventMap.get(currRec.id).event_date__c  && currRec.Event_Date__c < Date.Today() && !Test.isRunningTest() && Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null)
            {
                currRec.addError('Event Date should be greater than Today');
            }
        }
         if(chapterIds.size() > 0 && prioritysSet.size() > 0)
                NonwishEvent_OnBeforeInsertHelper.checkChapterPriority(chapterIds,prioritysSet,newNonwishEventList);
     }
}