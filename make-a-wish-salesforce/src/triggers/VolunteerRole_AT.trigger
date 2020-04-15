/**
 * @description Volunteer Role Trigger
 * @author		Gustavo Mayer, Traction on Demand
 * @date 		04-15-2020
 */
trigger VolunteerRole_AT on Volunteer_Roles__c (before insert, before update, after insert, after update, before delete) {
	trac_TriggerHandlerBase.triggerHandler(new VolunteerRoleDomain());
}