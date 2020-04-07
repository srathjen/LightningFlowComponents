/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 12/07/2016
Description : DocusignStatusTrigger_AT  is used when the docusign status record is created and its status
is completed then it will create a new conflict of interest records.
*****************************************************************************************************/
trigger DocusignStatusTrigger_AT on dsfs__DocuSign_Status__c (before insert, before update, before delete,
        after insert, after update, after delete, after undelete) {
    trac_TriggerHandlerBase.triggerHandler(new DocusignStatusDomain());
}