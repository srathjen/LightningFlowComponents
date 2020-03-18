/**
 * @description Lead Trigger
 * @author		Gustavo Mayer, Traction on Demand
 * @date 		3-04-2020
 */
trigger LeadTrigger_AT on Lead (before insert, before update, after insert, after update, before delete) {
	trac_TriggerHandlerBase.triggerHandler(new LeadDomain());
}