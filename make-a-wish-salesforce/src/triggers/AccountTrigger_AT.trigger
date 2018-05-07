/***************************************************************************************************
Author      : MST Solutions
Date        : 10/15/2016
Description : AccountTrigger_AT is used to call the Account trigger Handler classes and helper classes when the
              new account record is created and updated.
              
              Modification Log
              ------------------
              WVC-1884    KANAGARAJ  03/04/2018
              
*****************************************************************************************************/
trigger AccountTrigger_AT on Account (before insert,after insert,after update,before update) {
    if(trigger.isBefore && trigger.isInsert) {
        Account_OnBeforeInsertTriggerHandler.OnBeforeInsert(trigger.new);
    }
    if((trigger.isBefore && trigger.isUpdate && RecursiveTriggerHandler.blockBeforeUpdate == true) || (trigger.isAfter && trigger.isUpdate && RecursiveTriggerHandler.blockAfterUpdate)){
      return; 
    }
    if(trigger.isBefore && trigger.isUpdate && RecursiveTriggerHandler.blockBeforeUpdate == false){
        Account_OnBeforeUpdateTriggerHandler.OnBeforeUpdate(trigger.newMap,trigger.oldMap);
    }
    if(trigger.isAfter && trigger.isInsert) {
        Account_OnAfterInsertTriggerHandler.OnAfterInsert(trigger.new);
    }
    if(trigger.isAfter && trigger.isUpdate && RecursiveTriggerHandler.blockAfterUpdate == false){
        Account_OnAfterUpdateTriggerHandler.OnAfterUpdate(trigger.newMap,trigger.oldMap);
    }
}