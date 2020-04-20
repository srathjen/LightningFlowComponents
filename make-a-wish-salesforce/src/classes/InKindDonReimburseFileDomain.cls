/**
 * @author Steve Doucette, Traction on Demand 
 * @date 3/16/2020
 */
public class InKindDonReimburseFileDomain extends trac_TriggerHandlerBase {
    List<InkindDon_reimburseFile__c> newInKindDonReimburseFiles = (List<InkindDon_reimburseFile__c>) newRecordsList;
    List<InkindDon_reimburseFile__c> oldInKindDonReimburseFiles = (List<InkindDon_reimburseFile__c>) oldRecordsList;
    Map<Id, InkindDon_reimburseFile__c> newInKindDonReimburseFilesMap = (Map<Id, InkindDon_reimburseFile__c>) newRecordsMap;
    Map<Id, InkindDon_reimburseFile__c> oldInKindDonReimburseFilesMap = (Map<Id, InkindDon_reimburseFile__c>) oldRecordsMap;

    public override void handleAfterInsert() {
        InKindDonReimburseFileService.updateInKindReimburseFilePath(newInKindDonReimburseFiles);
    }

    public override void handleAfterDelete() {
        InKindDonReimburseFileService.setReimbursementFilesToNotAvailable(oldInKindDonReimburseFiles);
    }
}