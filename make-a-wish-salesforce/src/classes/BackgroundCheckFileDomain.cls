/**
 * @author Steve Doucette, Traction on Demand 
 * @date 3/16/2020
 */
public with sharing class BackgroundCheckFileDomain extends trac_TriggerHandlerBase{
    List<Background_Check_File__c> newBackgroundCheckFiles = (List<Background_Check_File__c>) newRecordsList;
    List<Background_Check_File__c> oldBackgroundCheckFiles = (List<Background_Check_File__c>) oldRecordsList;
    Map<Id, Background_Check_File__c> newBackgroundCheckFileMap = (Map<Id, Background_Check_File__c>) newRecordsMap;
    Map<Id, Background_Check_File__c> oldBackgroundCheckFileMap = (Map<Id, Background_Check_File__c>) oldRecordsMap;

    public override void handleAfterInsert() {
        BackgroundCheckFileService.updateBackgroundCheckFilePath(newBackgroundCheckFiles);
    }
}