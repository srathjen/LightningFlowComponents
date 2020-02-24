/*************************************************************************************************
Author   : MST Solutions
CreatedBy: Kanagaraj 
CreatedDate : 05/27/2015
Description : This UserTrigger_AT is used to create a public group and public group member when ever a new
              user record is created.
*************************************************************************************************/

trigger UserTrigger_AT on User (after insert,after update,before update,before insert) {   
    if(Trigger.isAfter && Trigger.isInsert)
    {
        User_OnAfterInsertHandler_AC.OnAfterInsert(Trigger.New);
    }    
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        User_OnAfterUpdateHandler_AC.OnAfterUpdate(Trigger.new,Trigger.oldMap);
    }
    if(Trigger.isbefore && Trigger.isInsert)
     {
      User_OnBeforeInsertHandler_AC.OnBeforeInsert(Trigger.new);      
     }
     if(Trigger.isbefore && Trigger.isUpdate)
     {
         User_OnBeforeUpdateHandler_AC.OnBeforeUpdate(Trigger.new,Trigger.oldMap);
     }
}