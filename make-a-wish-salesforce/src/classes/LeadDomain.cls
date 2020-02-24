/**
 * @description Domain class for the Lead trigger
 * @author		Mason Buhler, Traction on Demand
 * @createdDate	7-26-2019
 */
public with sharing class LeadDomain extends trac_TriggerHandlerBase {
	List<Lead> newLeadsList = (List<Lead>) newRecordsList;
	Map<Id, Lead> newLeadsMap = (Map<Id, Lead>) newRecordsMap;
	Map<Id, Lead> oldLeadsMap = (Map<Id, Lead>) oldRecordsMap;

	/**
	 * Before insert of Lead
	 */
	public override void handleBeforeInsert() {
        Lead_OnBeforeInsertTriggerHandler.OnBeforeInsert(newLeadsList);
	}

	/**
	 * Before update of Lead
	 */
	public override void handleBeforeUpdate() {
        Lead_OnBeforeUpdateTriggerHandler.onBeforeUpdate(newLeadsMap, oldLeadsMap);
	}

	/**
	 * Before delete of Lead
	 */
	public override void handleBeforeDelete() {
		Lead_OnBeforeDeleteTriggerHandler.onBeforeDelete(Trigger.old);
	}

	/**
	 * After insert of Lead
	 */
	public override void handleAfterInsert() {
        Lead_OnAfterInsertTriggerHandler.onAfterInsert(newLeadsList);
	}

	/**
	 * After update of Lead
	 */
	public override void handleAfterUpdate() {
        Lead_OnAfterUpdateTriggerHandler.onAfterUpdate(newLeadsMap, oldLeadsMap);
	}

}