/**
 * @description 	Task Trigger
 */
trigger TaskTrigger_AT on Task (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	trac_TriggerHandlerBase.triggerHandler(new TaskDomain());
}