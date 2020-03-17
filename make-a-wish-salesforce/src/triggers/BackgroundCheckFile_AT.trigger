/*******************************************************************************************
Author : MST Solutions
Created DAte:11/27/2016
Description: This trigger is used to update the background check file file path with the attachment stored in Amazon.  

**********************************************************************************************/
trigger BackgroundCheckFile_AT on Background_Check_File__c (before insert, before update, before delete,
        after insert, after update, after delete, after undelete) {
    trac_TriggerHandlerBase.triggerHandler(new BackgroundCheckFileDomain());
}