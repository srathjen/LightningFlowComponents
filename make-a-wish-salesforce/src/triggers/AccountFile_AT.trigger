/*******************************************************************************************
Author : MST Solutions
Created DAte:
Description: This trigger is used to update the accountfile file path with the attachment stored in Amazon.  

**********************************************************************************************/
trigger AccountFile_AT on cg__AccountFile__c (After insert) {
    List<Id> accountIds = new List<Id>();
    for(cg__AccountFile__c acc: Trigger.new){
        accountIds.add(acc.Id);
    }
    AWSFilePath_AC.updateAccountFilePath(accountIds);
}