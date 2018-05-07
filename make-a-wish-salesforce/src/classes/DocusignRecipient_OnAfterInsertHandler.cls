/**********************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 11/15/2016
Description : DocusignRecipient_OnAfterInsertHandler is used to call the UpdateCompletedRecipient() and UpdateStatusRecord() when
              the recipient status is created as completed or delivered.
             
************************************************************************************************************/
Public class DocusignRecipient_OnAfterInsertHandler{
    
    public static Void OnAfterInsert(List<dsfs__DocuSign_Recipient_Status__c> recipientList){
    Set<Id> dsfsStatusSet = new Set<Id>();
    Map<String,String> nameMap = new Map<String,String>();
    Set<Id> deliveredWishIdSet = new Set<Id>();
    Set<Id> completedWishIdSet = new Set<Id>();
    Set<String> completedNameString = new Set<String>();
    Set<Id> deliveredSet = new Set<Id>();
    Set<String> deliveredNameStringSet = new Set<String>();
    Set<Id> completedIdSet = new Set<Id>();
    Map<Id,String> envelopMap = new Map<Id,String>();
    
    for(dsfs__DocuSign_Recipient_Status__c dsfs : recipientList){
         if(dsfs.dsfs__Parent_Status_Record__c != Null && dsfs.dsfs__Recipient_Status__c == 'Completed' ){
                dsfsStatusSet.add(dsfs.dsfs__Parent_Status_Record__c);
                nameMap.put(dsfs.Name,dsfs.dsfs__DocuSign_Recipient_Email__c);
            }
            
            if(dsfs.dsfs__Parent_Status_Record__c != Null && (dsfs.dsfs__Recipient_Status__c == 'Delivered') ){
                deliveredSet.add(dsfs.dsfs__Parent_Status_Record__c);
                deliveredNameStringSet.add(dsfs.Name);
                
            }
            
            if(dsfs.dsfs__Parent_Status_Record__c != Null && (dsfs.dsfs__Recipient_Status__c == 'Completed')){
                completedIdSet.add(dsfs.dsfs__Parent_Status_Record__c);
                completedNameString.add(dsfs.Name);
            }
            
            if(dsfs.dsfs__Parent_Status_Record__c != Null){
                envelopMap.put(dsfs.dsfs__Parent_Status_Record__c,dsfs.Name);
            }
            
      }
      if(dsfsStatusSet.size() > 0 || deliveredSet.size() > 0 || completedIdSet.size() > 0 || nameMap.size() > 0){
      DocusignRecipient_OnAfterInsertHelper.UpdateCompletedRecipient(dsfsStatusSet,deliveredSet,completedIdSet,completedNameString,nameMap);
      }
      
      if(envelopMap.size() > 0){
      
      DocusignRecipient_OnAfterInsertHelper.UpdateStatusRecord(envelopMap);
      }
    }
}