/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 11/15/2016
Description : DocusignRecipientTrigger_AT is used to update the publicity field from contact when the ParentGuardian are signed the docusign document.
              also used to display recipient name in docusign status record.
*****************************************************************************************************/

Trigger DocusignRecipientTrigger_AT on dsfs__DocuSign_Recipient_Status__c (After update,After insert) {
    
    if(Trigger.isAfter && Trigger.isInsert){
     
        DocusignRecipient_OnAfterInsertHandler.OnAfterInsert(trigger.new);
    } 
    if(Trigger.isAfter && Trigger.isUpdate){
         DocusignRecipient_OnAfterUpdateHandler.OnAfterUpdate(trigger.newMap,trigger.oldMap);
    }
}