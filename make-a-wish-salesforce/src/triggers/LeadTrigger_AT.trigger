/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 26/05/2016
Description : When a new Lead record is created or updated and deleted then it will call the corresponding apex class
*****************************************************************************************************/

trigger LeadTrigger_AT on Lead (Before insert,Before Update,After insert,After Update,Before delete) 
{
    
    
    if(Trigger.isBefore && Trigger.isInsert){
       Lead_OnBeforeInsertTriggerHandler.OnBeforeInsert(Trigger.new);
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        Lead_OnBeforeUpdateTriggerHandler.onBeforeUpdate(trigger.newMap,trigger.oldMap);       
    }
     if(Trigger.isAfter && Trigger.isInsert){
        Lead_OnAfterInsertTriggerHandler.onAfterInsert(Trigger.new);
    }
    if(Trigger.isAfter && Trigger.isUpdate){   
    Lead_OnAfterUpdateTriggerHandler.onAfterUpdate(trigger.newMap,trigger.oldMap);
    } 
    
    If(Trigger.isBefore && Trigger.isDelete){
       Lead_OnBeforeDeleteTriggerHandler.onBeforeDelete(trigger.old);
    } 
    
    
}