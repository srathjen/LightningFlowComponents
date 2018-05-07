/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/26/2016
Description : When a new case record is created or updated then it will call the corresponding apex class.
*******************************************************************************************************************/

trigger CaseTrigger_AT on Case (after insert, after update,before update, after delete,before insert) {
    
    if((trigger.isBefore && trigger.isUpdate && RecursiveTriggerHandler.blockBeforeUpdate == true) || (trigger.isAfter && trigger.isUpdate && RecursiveTriggerHandler.blockAfterUpdate)){
        return;
    } 
    if(Trigger.isInsert && Trigger.isBefore){
        Case_OnBeforeInsertTriggerHandler.OnBeforeInsert(trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isBefore &&  RecursiveTriggerHandler.blockBeforeUpdate == false){
        Case_OnBeforeUpdateTriggerHandler.OnBeforeUpdate(trigger.newMap,trigger.oldMap);
    }
    if(Trigger.isInsert && Trigger.isAfter) {
       Case_OnAfterInsertTriggerHandler.OnAfterInsert(trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isAfter && RecursiveTriggerHandler.blockAfterUpdate == false) {  
        Case_OnAfterUpdateTriggerHandler.onAfterUpdate(trigger.newMap,trigger.oldMap);
    }
}