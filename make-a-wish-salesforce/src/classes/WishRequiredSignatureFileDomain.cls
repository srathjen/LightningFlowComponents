/**
 * @description Domain class for the Wish Required Signature File trigger
 * @author Mitali Nahar, Traction on Demand
 * @date 08/01/2019
 */
public with sharing class WishRequiredSignatureFileDomain extends trac_TriggerHandlerBase {
    List<Wish_Required_Signature_File__c> newList = (List<Wish_Required_Signature_File__c>) newRecordsList;
    List<Wish_Required_Signature_File__c> oldList = (List<Wish_Required_Signature_File__c>) oldRecordsList;
    Map<Id, Wish_Required_Signature_File__c> newMap = (Map<Id, Wish_Required_Signature_File__c>) newRecordsMap;
    Map<Id, Wish_Required_Signature_File__c> oldMap = (Map<Id, Wish_Required_Signature_File__c>) oldRecordsMap;

    /**
     * @description Handles logic to perform after Wish Signature File records are inserted
     */
    public override void handleAfterInsert() {
        WishRequiredSignatureFileService.onAfterInsert(newList);
    }
}