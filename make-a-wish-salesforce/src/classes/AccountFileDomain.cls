/**
 * @description
 * @author Steve Doucette, Traction on Demand
 * @date 3/16/2020
 */
public class AccountFileDomain extends trac_TriggerHandlerBase {
    List<cg__AccountFile__c> newAccountFiles = (List<cg__AccountFile__c>) newRecordsList;
    List<cg__AccountFile__c> oldAccountFiles = (List<cg__AccountFile__c>) oldRecordsList;
    Map<Id, cg__AccountFile__c> newAccountFilesMap = (Map<Id, cg__AccountFile__c>) newRecordsMap;
    Map<Id, cg__AccountFile__c> oldAccountFilesMap = (Map<Id, cg__AccountFile__c>) oldRecordsMap;

    public override void handleAfterInsert() {
        AccountFileService.updateAccountFilePath(newAccountFiles);
    }
}