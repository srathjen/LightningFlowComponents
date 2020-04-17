/**
 * @description Class Offering Trigger
 * @author		Gustavo Mayer, Traction on Demand
 * @date 		4-16-2020
 */
trigger ClassOffering_AT on Class_Offering__c(before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	trac_TriggerHandlerBase.triggerHandler(new ClassOfferingDomain());
}