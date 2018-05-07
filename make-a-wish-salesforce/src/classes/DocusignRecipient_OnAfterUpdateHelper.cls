/**************************************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 11/15/2016
Description : DocusignRecipient_OnAfterUpdateHelper is update the recipient name in wishchild form record. 
**************************************************************************************************************************************/

Public class DocusignRecipient_OnAfterUpdateHelper{
    
    //UpdateRecipientName() is used to update the recipient name when the recipient status is updated as completed or delivered.
    public static void UpdateRecipientName(Set<Id> completedIdSet,set<String> completedNameString,set<String> recipientstatusSet){
      system.debug('@@ completedIdSet @@'+completedIdSet);
      system.debug('@@ completedNameString @@'+completedNameString);
      Set<Id> completedWishIdSet = new Set<Id>();
      List<Wish_Child_Form__c> deliverednameList = new List<Wish_Child_Form__c>();
      string subject;
     if(completedIdSet.size() > 0){
             for(dsfs__DocuSign_Status__c dsfsStatusRec : [SELECT Id,dsfs__Case__c,dsfs__Subject__c,dsfs__Case__r.ContactId,dsfs__Case__r.LiabilitySignerMapKeyPair__c FROM dsfs__DocuSign_Status__c WHERE Id IN: completedIdSet
                                                          AND dsfs__Case__c != Null AND (dsfs__Subject__c =: 'Signature Required - Liability And Publicity Release Form' OR dsfs__Subject__c =: 'Signature Required - Wish Form & Liability And Publicity Release Form')  Limit 50000]){
                                                              
                                                              completedWishIdSet.add(dsfsStatusRec.dsfs__Case__c);
                                                              subject = dsfsStatusRec.dsfs__Subject__c; 
                                                              
                                                              
             }
        }
        system.debug('@@ completedWishIdSet @@'+completedWishIdSet);
        if(completedWishIdSet.size() > 0 ) {
             for(Wish_Child_Form__c dbWishPaperCase : [SELECT Id,Hidden_Wish_Fmaily_Contact_Name__c,Hidden_Contact_Name__c,Wish_Liability_Envolep__c,Delivered_Hidden_Envelop_Id__c,LiabilitySignerMapKeyPair__c,Delivered_LiabilitySignerMapKeyPair__c  From Wish_Child_Form__c WHERE Case__c =: completedWishIdSet  Limit 50000]){
                
                if(subject == 'Signature Required - Liability And Publicity Release Form' && recipientstatusSet.contains('Delivered')){
                for(String processString : dbWishPaperCase.Hidden_Wish_Fmaily_Contact_Name__c.split('#')){
                      if(completedNameString.contains(processString) && dbWishPaperCase.Delivered_Hidden_Envelop_Id__c != Null && dbWishPaperCase.Delivered_LiabilitySignerMapKeyPair__c != Null){
                        
                        dbWishPaperCase.Wish_Liability_Envolep__c = dbWishPaperCase.Delivered_Hidden_Envelop_Id__c ; 
                        dbWishPaperCase.Delivered_Hidden_Envelop_Id__c = null;
                        dbWishPaperCase.LiabilitySignerMapKeyPair__c = dbWishPaperCase.Delivered_LiabilitySignerMapKeyPair__c ;
                        dbWishPaperCase.Delivered_LiabilitySignerMapKeyPair__c = null;
                     }
                    
                }
                }
                 if(subject == 'Signature Required - Wish Form & Liability And Publicity Release Form'){
                    
                    for(String processString : completedNameString){
                        if(dbWishPaperCase.Hidden_Contact_Name__c == Null){
                            dbWishPaperCase.Hidden_Contact_Name__c = processString;
                            dbWishPaperCase.Signers__c = processString;
                            dbWishPaperCase.Id = dbWishPaperCase.Id;
                            //updateWishPaperMap.put(dbWishPaperCase.Id,dbWishPaperCase);
                        }
                        else{
                            dbWishPaperCase.Hidden_Contact_Name__c += '#'+processString;
                            dbWishPaperCase.Signers__c += '#'+processString;
                            dbWishPaperCase.Id = dbWishPaperCase.Id;
                            //updateWishPaperMap.put(dbWishPaperCase.Id,dbWishPaperCase);
                        }
                    }
                }
                deliverednameList.add(dbWishPaperCase);
            }
            system.debug('@@ deliverednameList @@'+deliverednameList);
            if(deliverednameList.size() > 0)
            update deliverednameList;
        }
        
    }
}