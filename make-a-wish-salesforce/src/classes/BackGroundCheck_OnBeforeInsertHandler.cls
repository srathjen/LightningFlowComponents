/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : BackGroundCheck_OnBeforeInsertHandler is used to call the Helper class when the
              new BackGroundCheck record is created.
              
              Modification Log
              ------------------
              WVC-1866    Pavithra G  05/08/2018
              
*****************************************************************************************************/
public class BackGroundCheck_OnBeforeInsertHandler{

     public static void OnBeforeInsert(List<Background_check__c> newBCList){
         Set<Id> volunteerIds = new Set<Id>();
         Map<Id,Contact> conMap = new Map<Id, Contact>();
         for(Background_check__c  currRec : newBCList)
         {
             if(Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null)
             {
                 if(!Test.isRunningTest())
                 {
                     if(currRec.Date_Completed__c != null && (currRec.Status__c != Null))
                         currRec.current__c = True;
                 }
                 volunteerIds.add(currRec.Volunteer__c);
             }
             if(currRec.Date_Completed__c != null)
             {
                 currRec.Date__c = currRec.Date_Completed__c.addYears(3);
             }
         }
         
         if(volunteerIds.size() > 0)
         {
             BackGroundCheck_OnBeforeInsertHelper.UpdateHiddenEmailField(volunteerIds,newBCList);
         }
     }
}