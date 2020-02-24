/**
 * Base class for all triggers handlers.
 * How to use it:
 * 1) Create a domain class for your SObject (trac_Opportunity for example) that extends trac_TriggerHandlerBase.
 * 2) Override the handler methods that you need.
 * 3) On the trigger, call trac_TriggerHandlerBase.triggerHandler passing a instance of your handler (like trac_Opportunity).
 *    Example: trac_TriggerHandlerBase.triggerHandler(new trac_CaseComment());
 */

/**
 * Steve Doucette
 * ex.
        trac_CaseExampleOne.execute((List<Case>) newRecordsList);
        trac_CaseExampleTwo.execute((Map<Id, Case>) oldRecordsMap);
        ...
 */
public virtual class trac_TriggerHandlerBase {
	public static Boolean blockTrigger = (Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null ? false : true);

	protected List<SObject> newRecordsList;
	protected Map<Id, SObject> oldRecordsMap;
	protected Map<Id, SObject> newRecordsMap;

	public trac_TriggerHandlerBase() {
		oldRecordsMap = Trigger.oldMap;
		newRecordsMap = Trigger.newMap;
		newRecordsList = Trigger.new;
	}

	public static void triggerHandler(trac_TriggerHandlerBase triggerHandler) {
		// Must ALWAYS run regardless of bypass
		if(Trigger.isBefore) {
			if(Trigger.isInsert) triggerHandler.handleBeforeInsertIgnoreBypass();
			else if(Trigger.isUpdate) triggerHandler.handleBeforeUpdateIgnoreBypass();
			else if(Trigger.isDelete) triggerHandler.handleBeforeDeleteIgnoreBypass();
		} else {
			if(Trigger.isInsert) triggerHandler.handleAfterInsertIgnoreBypass();
			else if(Trigger.isUpdate) triggerHandler.handleAfterUpdateIgnoreBypass();
			else if(Trigger.isDelete) triggerHandler.handleAfterDeleteIgnoreBypass();
			else if(Trigger.isUndelete) triggerHandler.handleAfterUndeleteIgnoreBypass();
		}

		if (blockTrigger) {
			return;
		}

		// Only run if current user doesn't have bypass_trigger record
		if(Trigger.isBefore) {
			if(Trigger.isInsert) triggerHandler.handleBeforeInsert();
			else if(Trigger.isUpdate) triggerHandler.handleBeforeUpdate();
			else if(Trigger.isDelete) triggerHandler.handleBeforeDelete();
		} else {
			if(Trigger.isInsert) triggerHandler.handleAfterInsert();
			else if(Trigger.isUpdate) triggerHandler.handleAfterUpdate();
			else if(Trigger.isDelete) triggerHandler.handleAfterDelete();
			else if(Trigger.isUndelete) triggerHandler.handleAfterUndelete();
		}
	}

	public virtual void handleBeforeInsert() {}

	public virtual void handleBeforeUpdate() {}

	public virtual void handleAfterInsert() {}

	public virtual void handleAfterUpdate() {}

	public virtual void handleBeforeDelete() {}

	public virtual void handleAfterDelete() {}

	public virtual void handleAfterUndelete() {}

	public virtual void handleBeforeInsertIgnoreBypass() {}

	public virtual void handleBeforeUpdateIgnoreBypass() {}

	public virtual void handleAfterInsertIgnoreBypass() {}

	public virtual void handleAfterUpdateIgnoreBypass() {}

	public virtual void handleBeforeDeleteIgnoreBypass() {}

	public virtual void handleAfterDeleteIgnoreBypass() {}

	public virtual void handleAfterUndeleteIgnoreBypass() {}
}