/**
 * @author Steve Doucette, Traction on Demand 
 * @date 3/16/2020
 */
public with sharing class ContactFileDomain extends trac_TriggerHandlerBase{
    List<cg__ContactFile__c> newContactFiles = (List<cg__ContactFile__c>) newRecordsList;
    List<cg__ContactFile__c> oldContactFiles = (List<cg__ContactFile__c>) oldRecordsList;
    Map<Id, cg__ContactFile__c> newContactFilesMap = (Map<Id, cg__ContactFile__c>) newRecordsMap;
    Map<Id, cg__ContactFile__c> oldContactFilesMap = (Map<Id, cg__ContactFile__c>) oldRecordsMap;

    public override void handleBeforeInsert() {
        ContactFileService.updateContactFileFolderId(newContactFiles);
    }

    public override void handleAfterInsert() {
        ContactFileService.updateContactFilePath(newContactFiles);
    }
}