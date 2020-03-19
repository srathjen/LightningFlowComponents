/**
 * @description Conflict Of Interest Trigger
 * @author	Gustavo Mayer, Traction on Demand
 * @date 3-04-2020
 */
trigger ConflictOfInterestTrigger_AT on Conflict_Of_Interest__c (before insert, before update, after update, after insert) {
	trac_TriggerHandlerBase.triggerHandler(new ConflictOfInterestDomain());
}