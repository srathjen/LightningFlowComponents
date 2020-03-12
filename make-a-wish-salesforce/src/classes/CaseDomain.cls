/**
 * @description     Domain class for the Case object
 *
 * @author          Chris Shinnimin, Traction on Demand
 * @date            2020-03-12
 */
public with sharing class CaseDomain extends trac_TriggerHandlerBase {
    List<Case> newCasesList = (List<Case>) newRecordsList;
    Map<Id, Case> newCasesMap = (Map<Id, Case>) newRecordsMap;
    Map<Id, Case> oldCasesMap = (Map<Id, Case>) oldRecordsMap;

    // BEFORE INSERT
    public override void handleBeforeInsert() {
        Case_OnBeforeInsertTriggerHandler.OnBeforeInsert(newCasesList);
    }

    // BEFORE UPDATE
    public override void handleBeforeUpdate() {
        // During code cleanup, RecursiveTrigger.blockBeforeUpdate was found to manage BEFORE UPDATE
        // trigger recursion. It isn't presently clear what the consequences of removing this check
        // will be, so leaving it here for the time being.
        if (RecursiveTriggerHandler.blockBeforeUpdate) {
            return;
        }

        Case_OnBeforeUpdateTriggerHandler.OnBeforeUpdate(newCasesMap, oldCasesMap);
    }

    // BEFORE DELETE
    public override void handleBeforeDelete() {

    }

    // AFTER INSERT
    public override void handleAfterInsert() {
        Case_OnAfterInsertTriggerHandler.OnAfterInsert(newCasesList);
    }

    // AFTER UPDATE
    public override void handleAfterUpdate() {
        // During code cleanup, RecursiveTrigger.blockBeforeUpdate was found to manage BEFORE UPDATE
        // trigger recursion. It isn't presently clear what the consequences of removing this check
        // will be, so leaving it here for the time being.
        if (RecursiveTriggerHandler.blockAfterUpdate) {
            return;
        }

        Case_OnAfterUpdateTriggerHandler.onAfterUpdate(newCasesMap, oldCasesMap);
    }
}