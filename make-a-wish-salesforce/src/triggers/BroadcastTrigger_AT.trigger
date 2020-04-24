/**
 * Broadcast Trigger
 */
trigger BroadcastTrigger_AT on Broadcast__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	trac_TriggerHandlerBase.triggerHandler(new BroadcastDomain());
}