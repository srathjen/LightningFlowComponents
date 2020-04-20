/**
 * @author Steve Doucette, Traction on Demand 
 * @date 3/16/2020
 */
public class CaseFileDomain extends trac_TriggerHandlerBase {
    List<cg__CaseFile__c> newCaseFiles = (List<cg__CaseFile__c>) newRecordsList;
    List<cg__CaseFile__c> oldCaseFiles = (List<cg__CaseFile__c>) oldRecordsList;
    Map<Id, cg__CaseFile__c> newCaseFilesMap = (Map<Id, cg__CaseFile__c>) newRecordsMap;
    Map<Id, cg__CaseFile__c> oldCaseFilesMap = (Map<Id, cg__CaseFile__c>) oldRecordsMap;

    public override void handleBeforeInsert() {
        CaseFileService.updateCaseFileFolderId(newCaseFiles);
    }

    public override void handleAfterInsert() {
        CaseFileService.updateAttachmentPath(newCaseFiles);
        CaseFileService.updateCaseFilePath(newCaseFilesMap);
    }

    public override void handleAfterUpdate() {
        CaseFileService.updateCaseFilePath(newCaseFilesMap, oldCaseFilesMap);
    }

    public override void handleAfterDelete() {
        CaseFileService.updateCaseFilePathOnDelete(oldCaseFiles);
    }
}