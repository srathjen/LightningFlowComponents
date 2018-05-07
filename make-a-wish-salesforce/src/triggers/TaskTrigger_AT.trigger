/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kesavakumar Murugesan
Date        : 6/1/2016
Description : When a new case record is created or updated then it will call the corresponding apex class.
*******************************************************************************************************************/
trigger TaskTrigger_AT on Task (before insert, before update, after insert, after update) {
    
    if((trigger.isBefore && trigger.isUpdate && RecursiveTriggerHandler.blockBeforeUpdate == true) || (trigger.isAfter && trigger.isUpdate && RecursiveTriggerHandler.blockAfterUpdate)){
        return; 
    }
    if(Trigger.isBefore && Trigger.isInsert){
        Task_OnBeforeInsertHandler.onBeforeInsert(trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isBefore &&  RecursiveTriggerHandler.blockAfterUpdate == false){
        Task_OnBeforeUpdateHandler.OnBeforeUpdate(trigger.newMap,trigger.oldMap);
    }
    if(trigger.isInsert && trigger.isAfter){
       Task_OnAfterInsertHandler.OnAfterInsert(trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isAfter && RecursiveTriggerHandler.blockAfterUpdate == false){
        Task_OnAfterUpdateHandler.OnAfterUpdate(trigger.newMap,trigger.oldMap);
    }
    
    
}