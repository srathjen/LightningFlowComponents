/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Description: Sharing the records to Chatper Staff with Read permission 
for their corresponding chapter records.
Prevent outside chapter user cannot create broadcase record for other chapter.
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

trigger BroadcastTrigger_AT on Broadcast__c (after Insert,before Insert,after Update,before Update) 
{
        if(Trigger.isBefore && Trigger.isInsert){
           Broadcast_OnBeforeInsertTriggerHandler.OnBeforeInsert(Trigger.new);
        }
        if(Trigger.isBefore && Trigger.isUpdate){
            Broadcast_OnBeforeUpdateTriggerHandler.onBeforeUpdate(Trigger.new,trigger.oldMap);       
        }
         if(Trigger.isAfter && Trigger.isInsert){
            Broadcast_OnAfterInsertTriggerHandler.onAfterInsert(Trigger.newMap);
        }
        if(Trigger.isAfter && Trigger.isUpdate){   
            Broadcast_OnAfterUpdateTriggerHandler.onAfterUpdate(Trigger.newMap,trigger.oldMap);
        } 
}