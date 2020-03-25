/**
 * @author Steve Doucette, Traction on Demand 
 * @date 3/25/2020
 */
public with sharing class DocusignRecipientDomain extends trac_TriggerHandlerBase {

    List<dsfs__DocuSign_Recipient_Status__c> newList = (List<dsfs__DocuSign_Recipient_Status__c>) newRecordsList;
    List<dsfs__DocuSign_Recipient_Status__c> oldList = (List<dsfs__DocuSign_Recipient_Status__c>) oldRecordsList;
    Map<Id, dsfs__DocuSign_Recipient_Status__c> newMap = (Map<Id, dsfs__DocuSign_Recipient_Status__c>) newRecordsMap;
    Map<Id, dsfs__DocuSign_Recipient_Status__c> oldMap = (Map<Id, dsfs__DocuSign_Recipient_Status__c>) oldRecordsMap;

    public override void handleAfterInsert() {
        DocusignRecipient_OnAfterInsertHandler.OnAfterInsert(newList);
    }

    public override void handleAfterUpdate() {
        DocusignRecipient_OnAfterUpdateHandler.OnAfterUpdate(newMap, oldMap);
    }
}