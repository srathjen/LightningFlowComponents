/*******************************************************************************************
Author : MST Solutions
Created DAte:11/27/2016
Description: This trigger is used to update the background check file file path with the attachment stored in Amazon.  

**********************************************************************************************/
trigger BackgroundCheckFile_AT on Background_Check_File__c (After insert) {
    List<Id> bcIds = new List<Id>();
    for(Background_Check_File__c bc: Trigger.new){
        bcIds.add(bc.Id);
    }
    AWSFilePath_AC.UpdateBackgroundCheckFilePath(bcIds);
}