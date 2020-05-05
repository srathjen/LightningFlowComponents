/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/27/2016
Description : When a new Volunteer Opportunity record is created or updated or delete then it will call the corresponding apex class.
Modification Log: 
04/17/2018 - Kanagaraj - WVC-1885
*******************************************************************************************************************/

trigger VolunteerOpportunityTrigger_AT on Volunteer_Opportunity__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	trac_TriggerHandlerBase.triggerHandler(new VolunteerOpportunityDomain());
}