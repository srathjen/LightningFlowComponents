/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 11/15/2016
Description : DocusignRecipientTrigger_AT is used to update the publicity field from contact when the ParentGuardian are signed the docusign document.
              also used to display recipient name in docusign status record.
*****************************************************************************************************/

trigger DocusignRecipientTrigger_AT on dsfs__DocuSign_Recipient_Status__c (before insert, before update, before delete,
        after insert, after update, after delete, after undelete) {
    trac_TriggerHandlerBase.triggerHandler(new DocusignRecipientDomain());
}