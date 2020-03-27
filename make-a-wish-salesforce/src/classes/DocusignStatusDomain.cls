/**
 * @author Steve Doucette, Traction on Demand 
 * @date 3/25/2020
 */
public with sharing class DocusignStatusDomain extends trac_TriggerHandlerBase {

    List<dsfs__DocuSign_Status__c> newList = (List<dsfs__DocuSign_Status__c>) newRecordsList;
    List<dsfs__DocuSign_Status__c> oldList = (List<dsfs__DocuSign_Status__c>) oldRecordsList;
    Map<Id, dsfs__DocuSign_Status__c> newMap = (Map<Id, dsfs__DocuSign_Status__c>) newRecordsMap;
    Map<Id, dsfs__DocuSign_Status__c> oldMap = (Map<Id, dsfs__DocuSign_Status__c>) oldRecordsMap;

    public override void handleAfterInsert() {
        DocusignStatusService.updateWishSignatures(newList);
    }

    public override void handleBeforeUpdate() {
        if (!RecursiveTriggerHandler.blockBeforeUpdate) {
            DocusignStatusService.updateRelatedParentRecords(newList, oldMap, Date.today());
        }
    }

    public override void handleAfterUpdate() {
        if (!RecursiveTriggerHandler.blockAfterUpdate) {
            DocusignStatusService.updateLeads(newList, oldMap);
        }
    }
}