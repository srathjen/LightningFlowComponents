/*******************************************************************************
Description : Mapping fields from Contact to Conflict Of Interest. These fields are mail merge fields in email template.
*********************************************************************************/

trigger ConflictOfInterestTrigger_AT on Conflict_Of_Interest__c (before insert,before update,after update,after insert) {    
  
        if(Trigger.isBefore && Trigger.isInsert){
           COI_OnBeforeInsertTriggerHandler.OnBeforeInsert(Trigger.new);
        }
        if(Trigger.isBefore && Trigger.isUpdate){
            COI_OnBeforeUpdateTriggerHandler.onBeforeUpdate(Trigger.new,trigger.oldMap);       
        }
         if(Trigger.isAfter && Trigger.isInsert){
            COI_OnAfterInsertTriggerHandler.onAfterInsert(Trigger.new);
        }
        if(Trigger.isAfter && Trigger.isUpdate){   
            COI_OnAfterUpdateTriggerHandler.onAfterUpdate(Trigger.new,trigger.oldMap);
        } 
}