/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/27/2016
Description : When a new RelationShip record is created or updated then it will call the corresponding apex class.
Modification Log: 
04/18/2018 - Kanagaraj - WVC-1885
*******************************************************************************************************************/
trigger Relationship_AT on npe4__Relationship__c (before insert, before update, before delete,
		after insert, after update, after delete, after undelete) {
	if ((Trigger.isBefore && Trigger.isUpdate && RecursiveTriggerHandler.blockBeforeUpdate)
			|| (Trigger.isAfter && Trigger.isUpdate && RecursiveTriggerHandler.blockAfterUpdate)) {
		return;
	}
	trac_TriggerHandlerBase.triggerHandler(new RelationshipsDomain());
}