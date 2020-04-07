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
        Set<Id> dsfsIdSet = new Set<Id>();
        Map<String, String> nameMap = new Map<String, String>();
        Set<Id> deliveredSet = new Set<Id>();
        Map<Id, String> envelopMap = new Map<Id, String>();
        List<dsfs__DocuSign_Recipient_Status__c> dsRecipientList = new List<dsfs__DocuSign_Recipient_Status__c>();
        for (dsfs__DocuSign_Recipient_Status__c dsfs : newList) {
            if (dsfs.dsfs__Parent_Status_Record__c != null) {
                envelopMap.put(dsfs.dsfs__Parent_Status_Record__c, dsfs.Name);
                dsRecipientList.add(dsfs);
                if (dsfs.dsfs__Recipient_Status__c == Constant_AC.DOCUSIGN_RECIPIENT_STATUS_COMPLETED) {
                    dsfsIdSet.add(dsfs.dsfs__Parent_Status_Record__c);
                    nameMap.put(dsfs.Name, dsfs.dsfs__DocuSign_Recipient_Email__c);
                } else if (dsfs.dsfs__Recipient_Status__c == Constant_AC.DOCUSIGN_RECIPIENT_STATUS_DELIVERED) {
                    dsfsIdSet.add(dsfs.dsfs__Parent_Status_Record__c);
                }
            }
        }
        DocusignRecipientService.updateCompletedRecipient(dsfsIdSet, nameMap, newList);
        DocusignRecipientService.updateStatusRecord(envelopMap, dsRecipientList);
    }

    public override void handleAfterUpdate() {
        Set<String> completedNameString = new Set<String>();
        Set<Id> completedIdSet = new Set<Id>();
        Set<String> recipientstatusSet = new Set<String>();
        List<dsfs__DocuSign_Recipient_Status__c> dsRecipientList = new List<dsfs__DocuSign_Recipient_Status__c>();
        for (dsfs__DocuSign_Recipient_Status__c dsfs : newMap.values()) {
            if (dsfs.dsfs__Parent_Status_Record__c != null
                    && (dsfs.dsfs__Recipient_Status__c == Constant_AC.DOCUSIGN_RECIPIENT_STATUS_COMPLETED
                    && (oldMap.get(dsfs.Id).dsfs__Recipient_Status__c == Constant_AC.DOCUSIGN_RECIPIENT_STATUS_DELIVERED || oldMap.get(dsfs.Id).dsfs__Recipient_Status__c == Constant_AC.DOCUSIGN_RECIPIENT_STATUS_SENT))) {
                completedIdSet.add(dsfs.dsfs__Parent_Status_Record__c);
                completedNameString.add(dsfs.Name);
                recipientstatusSet.add(oldMap.get(dsfs.Id).dsfs__Recipient_Status__c);
                dsRecipientList.add(dsfs);
            }
        }
        DocusignRecipientService.updateRecipientName(completedIdSet, completedNameString, dsRecipientList);
        DocusignRecipientService.updateAttachmentId(completedIdSet, dsRecipientList);
    }
}