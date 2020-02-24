/**
 * @description Trigger for the Wish_Change_Request
 * @author		Gustavo Mayer, Traction on Demand
 * @date 		9-11-2019
 */
trigger Wish_Change_Request on Wish_Change_Request__c (before insert, before update, before delete,
		after insert, after update, after delete, after undelete) {
	trac_TriggerHandlerBase.triggerHandler(new Wish_Change_RequestDomain());
}