/**
 * @description Domain class for the Affiliation trigger
 * @author	Gustavo Mayer, Traction on Demand
 * @createdDate	3-19-2020
 */
public with sharing class AffiliationDomain extends trac_TriggerHandlerBase {

    List<npe5__Affiliation__c> newList = (List<npe5__Affiliation__c>) newRecordsList;
    List<npe5__Affiliation__c> oldList = (List<npe5__Affiliation__c>) oldRecordsList;
    Map<Id, npe5__Affiliation__c> newMap = (Map<Id, npe5__Affiliation__c>) newRecordsMap;
    Map<Id, npe5__Affiliation__c> oldMap = (Map<Id, npe5__Affiliation__c>) oldRecordsMap;

    /**
     * Before insert of Affiliation
     */
    public override void handleBeforeInsert() {
        // Whenever first Affiliation record has fallen under contact, assigning that record as primary.
        Affiliation_OnBeforeInsertTriggerHandler.OnBeforeInsert(newList);
    }

    /**
     * Before update of Affiliation
     */
    public override void handleBeforeUpdate() {
        //This used to get affiliation's corresponding username and email to merge in active user welcome email template
        if (RecursiveTriggerHandler.blockBeforeUpdate == false) {
            Affiliation_BeforeUpdateTriggerHandler.OnBeforeUpdate(newList, oldMap);
        }
    }

    /**
     * After insert of Affiliation
     */
    public override void handleAfterInsert() {
        // After insert trigger is used to add the user to the public group to access the approved In-Kind donor
        // account record based on the affiliation record
        Affiliation_OnAfterUpdateTriggerHandler.OnAfterUpsert(newList, oldMap);
    }

    /**
     * After update of Affiliation
     */
    public override void handleAfterUpdate() {
        if (!RecursiveTriggerHandler.blockAfterUpdate) {
            //Used to add user to chatter group when a user becomes active to particular chapter
            Affiliation_OnAfterUpdateTriggerHandler.OnAfterUpdate(newList, oldMap);
            if (RecursiveTriggerHandler.blockAfterUpdate == false) {
                Affiliation_OnAfterUpdateTriggerHandler.OnAfterUpsert(newList, oldMap);
            }
        }
    }

    /**
     * After update of Affiliation
     */
    public override void handleAfterDelete() {
        // After delete trigger is used to remove the user to the public group to restrict the approved
        // In-Kind donor account record based on the affiliation record
        Affiliation_OnAfterDeleteTriggerHandler.OnAfterDelete(oldList);
    }
}