/**************************************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 11/15/2016
Description : DocusignRecipient_OnAfterInsertHelper is update the recipient name in wishchild form object and also update the 
recipient name when the recipient record is created.
**************************************************************************************************************************************/
Public class DocusignRecipient_OnAfterInsertHelper{
    
    //UpdateCompletedRecipient() is used to update the recipient name when the recipient record is created.
    Public static void UpdateCompletedRecipient(Set<Id> dsfsStatusSet,Set<Id> deliveredSet,Set<Id> completedIdSet,Set<String> completedNameString,Map<String,String> nameMap){
        Set<Id> WishIdSet = new Set<Id>();
        String subject;
        Set<Id> deliveredWishIdSet = new Set<Id>();
        Set<Id> completedWishIdSet = new Set<Id>();
        List<Wish_Child_Form__c> deliverednameList = new List<Wish_Child_Form__c>();
        Set<Id> contactIdSet = new Set<Id>();
       
        Map<Id,Wish_Child_Form__c > updateWishPaperMap = new Map<Id,Wish_Child_Form__c>();
        if(dsfsStatusSet.size() > 0){
            for(dsfs__DocuSign_Status__c dsfsStatusRec : [SELECT Id,dsfs__Case__c,dsfs__Subject__c,dsfs__Case__r.ContactId,dsfs__Case__r.LiabilitySignerMapKeyPair__c FROM dsfs__DocuSign_Status__c WHERE Id IN:dsfsStatusSet 
                                                          AND dsfs__Case__c != Null AND (dsfs__Subject__c =: 'Signature Required - Liability And Publicity Release Form' OR dsfs__Subject__c =: 'Signature Required - Wish Form & Liability And Publicity Release Form') Limit 50000]){
                                                              
                                                              WishIdSet.add(dsfsStatusRec.dsfs__Case__c);
                                                              subject = dsfsStatusRec.dsfs__Subject__c;
                                                          }
        }
        
        if(deliveredSet.size() > 0){
            for(dsfs__DocuSign_Status__c dsfsStatusRec : [SELECT Id,dsfs__Case__c,dsfs__Subject__c,dsfs__Case__r.ContactId,dsfs__Case__r.LiabilitySignerMapKeyPair__c FROM dsfs__DocuSign_Status__c WHERE Id IN: deliveredSet
                                                          AND dsfs__Case__c != Null AND dsfs__Subject__c =: 'Signature Required - Liability And Publicity Release Form'  Limit 50000]){
                                                              
                                                              deliveredWishIdSet.add(dsfsStatusRec.dsfs__Case__c);
                                                              
                                                          }
         }
        system.debug('@@ completedIdSet @@'+completedIdSet);
        if(completedIdSet.size() > 0){
             for(dsfs__DocuSign_Status__c dsfsStatusRec : [SELECT Id,dsfs__Case__c,dsfs__Subject__c,dsfs__Case__r.ContactId,dsfs__Case__r.LiabilitySignerMapKeyPair__c FROM dsfs__DocuSign_Status__c WHERE Id IN: completedIdSet
                                                          AND dsfs__Case__c != Null AND dsfs__Subject__c =: 'Signature Required - Liability And Publicity Release Form'  Limit 50000]){
                                                              
                                                              completedWishIdSet.add(dsfsStatusRec.dsfs__Case__c);
                                                              
                                                              
             }
        }
        
        if(completedWishIdSet.size() > 0){
             for(Wish_Child_Form__c dbWishPaperCase : [SELECT Id,Hidden_Wish_Fmaily_Contact_Name__c,Wish_Liability_Envolep__c,Delivered_Hidden_Envelop_Id__c,LiabilitySignerMapKeyPair__c,Delivered_LiabilitySignerMapKeyPair__c  From Wish_Child_Form__c WHERE Case__c =: completedWishIdSet  Limit 50000]){
                
                for(String processString : dbWishPaperCase.Hidden_Wish_Fmaily_Contact_Name__c.split('#')){
                      if(completedNameString.contains(processString)){
                        dbWishPaperCase.Wish_Liability_Envolep__c = dbWishPaperCase.Delivered_Hidden_Envelop_Id__c ; 
                        dbWishPaperCase.Delivered_Hidden_Envelop_Id__c = null;
                        dbWishPaperCase.LiabilitySignerMapKeyPair__c = dbWishPaperCase.Delivered_LiabilitySignerMapKeyPair__c ;
                        dbWishPaperCase.Delivered_LiabilitySignerMapKeyPair__c = null;
                     }
                    
                }
                deliverednameList.add(dbWishPaperCase);
            }
            if(deliverednameList.size() > 0)
            update deliverednameList;
        }
        
          if(WishIdSet.Size() > 0){
            Wish_Child_Form__c newWishChildForm = new Wish_Child_Form__c ();
            for(Wish_Child_Form__c dbWishPaperCase : [SELECT Id,Hidden_Email_List__c,Hidden_Name_List__c,Hidden_Contact_Name__c,Signers__c,Case__c,Case__r.contactId From Wish_Child_Form__c WHERE Case__c =: WishIdSet  Limit 50000]){
                
                if(subject == 'Signature Required - Liability And Publicity Release Form'){
                    
                    /*for(String processString : nameMap.keyset()){
                        if(dbWishPaperCase.Hidden_Name_List__c == Null && dbWishPaperCase.Hidden_Email_List__c == Null){
                            dbWishPaperCase.Hidden_Name_List__c = processString;
                            dbWishPaperCase.Hidden_Email_List__c = nameMap.get(processString);
                            dbWishPaperCase.Id = dbWishPaperCase.Id;
                            updateWishPaperMap.put(dbWishPaperCase.Id,dbWishPaperCase);
                        }
                        else{
                            dbWishPaperCase.Hidden_Name_List__c  += '#'+processString;
                            dbWishPaperCase.Hidden_Email_List__c += '#'+nameMap.get(processString);
                            dbWishPaperCase.Id = dbWishPaperCase.Id;
                            //updateWishPaperMap.put(dbWishPaperCase.Id,dbWishPaperCase);
                        }
                    }*/
                    contactIdSet.add(dbWishPaperCase.Case__r.contactId);
                }
                
                if(subject == 'Signature Required - Wish Form & Liability And Publicity Release Form'){
                    
                    for(String processString : nameMap.keyset()){
                        if(dbWishPaperCase.Hidden_Contact_Name__c == Null){
                            dbWishPaperCase.Hidden_Contact_Name__c = processString;
                            dbWishPaperCase.Signers__c = processString;
                            dbWishPaperCase.Id = dbWishPaperCase.Id;
                            updateWishPaperMap.put(dbWishPaperCase.Id,dbWishPaperCase);
                        }
                        else{
                            dbWishPaperCase.Hidden_Contact_Name__c += '#'+processString;
                            dbWishPaperCase.Signers__c += '#'+processString;
                            dbWishPaperCase.Id = dbWishPaperCase.Id;
                            updateWishPaperMap.put(dbWishPaperCase.Id,dbWishPaperCase);
                        }
                    }
                }
            }
            
            update updateWishPaperMap.values();
        }
         If(contactIdSet.size() > 0){
            List<Contact> updateContactList = new List<Contact>();
            for(Contact dbContact : [SELECT Id,Name,Email,Publicity_OK__c FROM Contact WHERE Id IN: contactIdSet  Limit 50000]){
                dbContact.Publicity_OK__c = 'Yes';
                updateContactList.add(dbContact);
            }
            If(updateContactList.size() > 0){
                RecursiveTriggerHandler.blockBeforeUpdate = true;
                RecursiveTriggerHandler.blockAfterUpdate = true;
                update updateContactList;
            }
        }
    }
    
    //UpdateCompletedRecipient() is used to update the recipient name in docusign status record when the recipient record is created.
    public static void UpdateStatusRecord(Map<Id,String> envelopMap){
        List<dsfs__DocuSign_Status__c> updatedsfsList = new List<dsfs__DocuSign_Status__c>();
        if(envelopMap.size() > 0){
            for(dsfs__DocuSign_Status__c dbStatusRec : [SELECT Id,Recipient_names__c,dsfs__Sender__c,dsfs__Sender_Email__c FROM dsfs__DocuSign_Status__c WHERE Id IN: envelopMap.KeySet() Limit 50000]){
                if(envelopMap.containsKey(dbStatusRec.Id)){
                    if(dbStatusRec.Recipient_names__c == Null)
                    dbStatusRec.Recipient_names__c = envelopMap.get(dbStatusRec.Id);
                    else
                    dbStatusRec.Recipient_names__c =dbStatusRec.Recipient_names__c+','+' '+envelopMap.get(dbStatusRec.Id);
                    updatedsfsList.add(dbStatusRec);
                }
            }
        }
        if(updatedsfsList.size() > 0)
        update updatedsfsList;
    }
}