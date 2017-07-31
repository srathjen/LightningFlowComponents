/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 11/15/2016
Description : DocusignRecipientTrigger_AT is used to update the publicity field from contact when the ParentGuardian are signed the docusign document.
*****************************************************************************************************/


Trigger DocusignRecipientTrigger_AT on dsfs__DocuSign_Recipient_Status__c (After update) {
    
    if(Trigger.isAfter && Trigger.isUpdate){
        Set<Id> dsfsStatusSet = new Set<Id>();
        Set<Id> wishChildIdSet = new Set<Id>();
        Set<Id> wishIdSet = new Set<Id>();
        Set<Id> liabilityWishChild = new Set<Id>();
        String subject;
        List<String> NameList = new List<String>();
        List<Case> wishList = new List<Case>();
        List<Wish_Child_Form__c > wishChildFormList = new List<Wish_Child_Form__c >();
        Map<String,String> recipentMap = new Map<String,String>();
        for(dsfs__DocuSign_Recipient_Status__c  dsfs : Trigger.new){
           if(dsfs.dsfs__Parent_Status_Record__c != Null && dsfs.dsfs__Recipient_Status__c == 'Completed' ){
            dsfsStatusSet.add(dsfs.dsfs__Parent_Status_Record__c);
            
            NameList.add(dsfs.Name);
            system.debug('@@@@@ NameList @@@@'+NameList);
            }
        }
        
        if(dsfsStatusSet.size() > 0){
           
           for(dsfs__DocuSign_Status__c dsfsStatusRec : [SELECT Id,dsfs__Case__c,dsfs__Subject__c,dsfs__Case__r.ContactId,dsfs__Case__r.LiabilitySignerMapKeyPair__c FROM dsfs__DocuSign_Status__c WHERE Id IN:dsfsStatusSet 
                                                           AND dsfs__Case__c != Null]){
              
               wishChildIdSet.add(dsfsStatusRec.dsfs__Case__r.ContactId);
               wishIdSet.add(dsfsStatusRec.dsfs__Case__c);
                subject = dsfsStatusRec.dsfs__Subject__c;
               if(dsfsStatusRec.dsfs__Case__r.LiabilitySignerMapKeyPair__c != Null)
               {
                   liabilityWishChild.add(dsfsStatusRec.dsfs__Case__r.ContactId);
               }
           }
           
           if(NameList.Size() > 0 && subject == 'Signature Required - Liability And Publicity Release Form'){
           
               for(Case dbCase : [SELECT Id,Hidden_Name_List__c,ContactId,Contact.Name,Contact.Email FROM Case WHERE Id IN:wishIdSet]){
               recipentMap.put(dbCase.Contact.Name,dbCase.Contact.Email);
               for(String processName : NameList){
                   
                    
                   if(dbCase.Hidden_Name_List__c == Null)
                   dbCase.Hidden_Name_List__c = processName;
                   else
                   dbCase.Hidden_Name_List__c = dbCase.Hidden_Name_List__c+','+processName;
                   
                   wishList.add(dbCase);
                   
               }
           }
           
            if(NameList.Size() > 0 && subject == 'Signature Required - Wish Paperwork Packet'){
           
               for(Wish_Child_Form__c dbWishChildForm : [SELECT Id,Case__c,Hidden_Contact_Name__c FROM Wish_Child_Form__c  WHERE Case__c IN:wishIdSet]){
               
               for(String processName : NameList){
                   if(dbWishChildForm.Hidden_Contact_Name__c == Null)
                   dbWishChildForm.Hidden_Contact_Name__c  = processName;
                   else
                   dbWishChildForm.Hidden_Contact_Name__c = dbWishChildForm.Hidden_Contact_Name__c+','+processName;
                   
                   wishChildFormList.add(dbWishChildForm);
               }
           }
           }
           
           
           }
           If(wishChildIdSet.size() > 0){
           List<Contact> wishChildList = new List<Contact>();
           for(Contact dbContact : [SELECT Id,Name,Email FROM Contact WHERE Id IN:wishChildIdSet]){
            
               
               if(recipentMap.containsKey(dbContact.Name)){
                   
                   Contact newCon = new Contact();
                   newCon.Id = dbContact.Id;
                   newCon.Publicity_OK__c = 'Yes';
                   wishChildList.add(newCon);
               
               }
               
              
           }
           if(wishChildList.size() > 0)
           update wishChildList;
          
           }
           if(wishChildFormList.size() > 0)
           update wishChildFormList;
           if(wishList.size() > 0)
           update wishList;
          
        }
    }

}