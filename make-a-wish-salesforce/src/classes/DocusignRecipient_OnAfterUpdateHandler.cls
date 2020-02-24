/**************************************************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 11/15/2016
Description : DocusignRecipient_OnAfterUpdateHandler is used to call the UpdateRecipientName() when the recipient status is updated as 'completed'.
*****************************************************************************************************************************************************/

Public class DocusignRecipient_OnAfterUpdateHandler{
    
    Public static void OnAfterUpdate(Map<Id,dsfs__DocuSign_Recipient_Status__c> newRecipientMap,Map<Id,dsfs__DocuSign_Recipient_Status__c> oldRecipientMap){
        Set<String> completedNameString = new Set<String>();
        Set<Id> completedIdSet = new Set<Id>();
        Set<String> recipientstatusSet = new Set<String>();
        List<dsfs__DocuSign_Recipient_Status__c> DSrecipiantList = new List<dsfs__DocuSign_Recipient_Status__c>();
        for(dsfs__DocuSign_Recipient_Status__c dsfs : newRecipientMap.Values()){
             if(dsfs.dsfs__Parent_Status_Record__c != Null && (dsfs.dsfs__Recipient_Status__c == 'Completed' && (oldRecipientMap.get(dsfs.Id).dsfs__Recipient_Status__c == 'Delivered'
                               || oldRecipientMap.get(dsfs.Id).dsfs__Recipient_Status__c == 'Sent'))){
                    completedIdSet.add(dsfs.dsfs__Parent_Status_Record__c);
                    completedNameString.add(dsfs.Name);
                    recipientstatusSet.add(oldRecipientMap.get(dsfs.Id).dsfs__Recipient_Status__c);
                    DSrecipiantList.add(dsfs);
                }
        }
        if(completedIdSet.size() > 0 && completedNameString.size() > 0){
        DocusignRecipient_OnAfterUpdateHelper.UpdateRecipientName(completedIdSet,completedNameString,recipientstatusSet,DSrecipiantList);
        }
        if(completedIdSet.size() > 0){
        DocusignRecipient_OnAfterUpdateHelper.updateAttachmentId(completedIdSet,DSrecipiantList);
        }
    }
    
}