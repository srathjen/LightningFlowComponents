/**
 * @description Relationship Trigger
 * @author Kanagaraj, MST Solutions
 * @createdDate 5/27/2016
 */
trigger Relationship_AT on npe4__Relationship__c (before insert, before update, before delete,
		after insert, after update, after delete, after undelete) {
	trac_TriggerHandlerBase.triggerHandler(new RelationshipsDomain());
}