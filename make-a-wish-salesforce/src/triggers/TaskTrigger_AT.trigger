/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kesavakumar Murugesan
Date        : 6/1/2016
Description : When a new case record is created or updated then it will call the corresponding apex class.
*******************************************************************************************************************/
trigger TaskTrigger_AT on Task (before insert, before update, after insert, after update) {

	if ((Trigger.isBefore
			&& Trigger.isUpdate
			&& RecursiveTriggerHandler.blockBeforeUpdate == true)
			|| (Trigger.isAfter && Trigger.isUpdate
			&& RecursiveTriggerHandler.blockAfterUpdate)) {
		return;
	}
	if (Trigger.isBefore && Trigger.isInsert) {
		Task_OnBeforeInsertHandler.onBeforeInsert(Trigger.new);
	}
	if (Trigger.isUpdate && Trigger.isBefore
			&& RecursiveTriggerHandler.blockAfterUpdate == false) {
		Task_OnBeforeUpdateHandler.OnBeforeUpdate(Trigger.newMap, Trigger.oldMap);
	}
	/**
	 * WLP-434
	 * Deprecate Interview Fields on Contact
	 */
//    if(trigger.isInsert && trigger.isAfter){
//       Task_OnAfterInsertHandler.OnAfterInsert(trigger.new);
//    }
	if (Trigger.isUpdate && Trigger.isAfter
			&& RecursiveTriggerHandler.blockAfterUpdate == false) {
		Task_OnAfterUpdateHandler.OnAfterUpdate(Trigger.newMap, Trigger.oldMap);
	}
}