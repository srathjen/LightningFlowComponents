trigger MinorParticipant_AT on Minor_Participant__c (after update) {
   
   if(trigger.isAfter && trigger.isUpdate){
       MinorParticipantTrigger_Handler.OnAfterUpdate(trigger.newMap,trigger.oldMap);
   }
}