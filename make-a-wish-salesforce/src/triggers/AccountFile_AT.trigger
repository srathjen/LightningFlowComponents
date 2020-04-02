/*******************************************************************************************
Author : MST Solutions
Created DAte:
Description: This trigger is used to update the Account file path with the attachment stored in Amazon.

**********************************************************************************************/
trigger AccountFile_AT on cg__AccountFile__c (before insert, before update, before delete,
        after insert, after update, after delete, after undelete) {
    trac_TriggerHandlerBase.triggerHandler(new AccountFileDomain());
}