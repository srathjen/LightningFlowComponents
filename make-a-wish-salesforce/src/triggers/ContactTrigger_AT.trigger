/***************************************************************************************************
Author      : MST Solutions
Date        : 10/15/2016
Description : ContactTrigger_AT is used to call the Account trigger Handler classes and helper classes when the
              new account record is created and updated.
              
              Modification Log
              ------------------
              WVC-1884    KANAGARAJ  04/04/2018
              
*****************************************************************************************************/
trigger ContactTrigger_AT on Contact(Before Insert, after insert, Before Update,After update,After delete, Before delete) {
    
    if(Trigger.isBefore && Trigger.isInsert)
    {
        Contact_OnBeforeInsertTriggerHandler.onBeforeInsert(trigger.new);
    }
    if((trigger.isBefore && trigger.isUpdate && RecursiveTriggerHandler.blockBeforeUpdate == true) || (trigger.isAfter && trigger.isUpdate && RecursiveTriggerHandler.blockAfterUpdate)){
        return; 
    }
    if(Trigger.isBefore && Trigger.isUpdate && RecursiveTriggerHandler.blockBeforeUpdate == false){
        Contact_OnBeforeUpdateTriggerHandler.OnBeforeUpdate(trigger.newMap,trigger.oldMap);
    }
    if(Trigger.isAfter && Trigger.isInsert){
        Contact_OnAfterInsertTriggerHandler.OnAfterInsert(trigger.new);
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        Contact_OnAfterUpdateTriggerHandler.onAfterUpdate(trigger.newMap,trigger.oldMap);
    }
    if(Trigger.isBefore && Trigger.isDelete){
        Contact_OnBeforeDeleteTriggerHandler.onBeforeDelete(trigger.old);
    }
   
}