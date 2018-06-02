/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/27/2016
Description : When a new Relationship record is insert then it will call the corresponding methods based 
on the collection size() > 0.
Modification Log: 
04/18/2018 - Kanagaraj - WVC-1885
*******************************************************************************************************************/

Public class RelationshipOnAfterInsertTriggerHelper{
    
    static Constant_AC  constant = new Constant_Ac();
    static Id familyContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.wishFamilyRT).getRecordTypeId();
    static Id medicalProfRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Medical Professional').getRecordTypeId();
    static String parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
    
    //This method is used to update the medical physician name and email value into contact record.
    Public static void updatePhysicianDetails(Set<Id> relatedContactId,List<npe4__Relationship__c> relationShipList){
    RecursiveTriggerHandler.isFirstTime = false;
    Map<id,Contact> medicalProfContactMap = new Map<id,Contact>();
    Map<Id,Contact> updateContactMap = new Map<Id,Contact>();
      
      try{  
         if(relatedContactId.size() > 0){
                for(Contact dbWishChildCon : [SELECT Id,Name,Email,RecordTypeId FROM Contact WHERE Id In:relatedContactId AND RecordTypeId =: medicalProfRecordTypeId ]){
                    medicalProfContactMap.put(dbWishChildCon.Id,dbWishChildCon);
                }
         }
         
          if(medicalProfContactMap.size() > 0){
                for(npe4__Relationship__c newRecord : relationShipList){
                    if(medicalProfContactMap.containsKey(newRecord.npe4__RelatedContact__c)){
                        contact newContact = new Contact();
                        newContact.Id = newRecord.npe4__Contact__c;
                        newContact.Hidden_Medical_Physician__c = medicalProfContactMap.get(newRecord.npe4__RelatedContact__c).Name;
                        newContact.Hidden_Medical_Physician_Email__c = medicalProfContactMap.get(newRecord .npe4__RelatedContact__c).Email;
                        updateContactMap.put(newContact.Id,newContact); 
                    }
                }
            }
            
            if(updateContactMap.size() > 0){
                RecursiveTriggerHandler.isFirstTime = false;
                update  updateContactMap.Values();
            }
        }
        
         catch(Exception ex){
           for(npe4__Relationship__c currRec : relationShipList){
                ErrorMessage_AC.createdebugRec('OnAfterInsertRelationshipTriggerHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'updatePhysicianDetails',currRec.Id,ex.getStackTraceString(),'Error');
            }
            for(npe4__Relationship__c currRec : relationShipList ){
                currRec.addError(Label.Debug_log_error_message);
            }
       }
    }
    
     /*This method is used to once wishchild form get approved then all the relationship record are created then it will update the 
       Update_Wish_Child_Form_Info__c field in case record.*/
     public static void updateApprovedCase(set<Id> wishChildIdSet,List<npe4__Relationship__c> relationShipList){
        RecursiveTriggerHandler.relationShipRecursive = false;
         List<Case> updateCaseList = new List<Case>();
        try{
        if(wishChildIdSet.size() > 0){
            
            for(Case dbCase : [SELECT Id,ContactId,RecordTypeId,Update_Wish_Child_Form_Info__c FROM Case WHERE ContactId IN: wishChildIdSet AND Update_Wish_Child_Form_Info__c =: True
                                AND RecordTypeId =: parentWishRecordTypeId ]){
                If(wishChildIdSet.contains(dbCase.ContactId)){
                    
                    dbCase.Update_Wish_Child_Form_Info__c  = false;
                    updateCaseList.add(dbCase);
                }
            }
        }
        If(updateCaseList.size() > 0)
        update updateCaseList;
      }
      catch(Exception ex){
           for(npe4__Relationship__c currRec : relationShipList){
                ErrorMessage_AC.createdebugRec('OnAfterInsertRelationshipTriggerHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'updateApprovedCase',currRec.Id,ex.getStackTraceString(),'Error');
            }
            for(npe4__Relationship__c currRec : relationShipList ){
                currRec.addError(Label.Debug_log_error_message);
            }
       }
    }
     
     //This method is used to update the type of relationship in contact record. 
     public static void updateRelationshipType(Map<Id,String> relationshipMap){
        List<Contact> familyContactList = new List<Contact>();
        try{
        if(relationshipMap.size() > 0){
            for(Contact dbContact : [SELECT Id,Name,Relationship_Type__c,RecordTypeId FROM Contact WHERE Id IN: relationshipMap.KeySet() AND RecordTypeId =: familyContactRecordTypeId Limit 50000]){
                if(relationshipMap.containsKey(dbContact.Id)){
                    dbContact.Relationship_Type__c = relationshipMap.get(dbContact.Id);
                    familyContactList.add(dbContact);
                } 
            }
        }
        if(familyContactList.size() > 0){
        update familyContactList;
        }
       }
       
       catch(Exception ex){
           for(npe4__Relationship__c currRec : [SELECT Id,npe4__Contact__c,npe4__Type__c FROM npe4__Relationship__c WHERE npe4__Contact__c IN:relationshipMap.KeySet()]){
                ErrorMessage_AC.createdebugRec('OnAfterInsertRelationshipTriggerHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'updateRelationshipType',currRec.Id,ex.getStackTraceString(),'Error');
            }
            for(npe4__Relationship__c currRec : [SELECT Id,npe4__Contact__c,npe4__Type__c FROM npe4__Relationship__c WHERE npe4__Contact__c IN:relationshipMap.KeySet()]){
                currRec.addError(Label.Debug_log_error_message);
            }
       }
    }
}