trigger DocusignRecipientTrigger_AT on dsfs__DocuSign_Recipient_Status__c (After update) {
    
    if(Trigger.isAfter && Trigger.isUpdate){
        Set<Id> dsfsStatusSet = new Set<Id>();
        Set<Id> wishChildIdSet = new Set<Id>();
        Set<Id> wishIdSet = new Set<Id>();
        Set<Id> liabilityWishChild = new Set<Id>();
        List<String> NameList = new List<String>();
        List<Wish_Child_Form__c> wishChildFormList = new List<Wish_Child_Form__c>();
        Map<String,String> recipentMap = new Map<String,String>();
        for(dsfs__DocuSign_Recipient_Status__c  dsfs : Trigger.new){
           if(dsfs.dsfs__Parent_Status_Record__c != Null && dsfs.dsfs__Recipient_Status__c == 'Completed' ){
            dsfsStatusSet.add(dsfs.dsfs__Parent_Status_Record__c);
            recipentMap.put(dsfs.Name,dsfs.dsfs__DocuSign_Recipient_Email__c);
            NameList.add(dsfs.Name);
            }
        }
        
        if(dsfsStatusSet.size() > 0){
           
           for(dsfs__DocuSign_Status__c dsfsStatusRec : [SELECT Id,dsfs__Case__c,dsfs__Case__r.ContactId,dsfs__Case__r.LiabilitySignerMapKeyPair__c FROM dsfs__DocuSign_Status__c WHERE Id IN:dsfsStatusSet 
                                                           AND dsfs__Case__c != Null]){
              
               wishChildIdSet.add(dsfsStatusRec.dsfs__Case__r.ContactId);
               wishIdSet.add(dsfsStatusRec.dsfs__Case__c);
               if(dsfsStatusRec.dsfs__Case__r.LiabilitySignerMapKeyPair__c != Null)
               {
                   liabilityWishChild.add(dsfsStatusRec.dsfs__Case__r.ContactId);
               }
           }
           
           if(NameList.Size() > 0){
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
           If(wishChildIdSet.size() > 0){
           List<Contact> wishChildList = new List<Contact>();
            for(npe4__Relationship__c npsp : [SELECT Id,npe4__Contact__c,npe4__RelatedContact__c,npe4__RelatedContact__r.IsParentGuardian__c,npe4__RelatedContact__r.Name FROM npe4__Relationship__c
                                              WHERE npe4__Contact__c IN:wishChildIdSet ]){
               
               if(recipentMap.containsKey(npsp.npe4__RelatedContact__r.Name ) && (npsp.npe4__RelatedContact__r.IsParentGuardian__c  == 'ParentGuardian')){
                   
                   Contact newCon = new Contact();
                   newCon.Id = npsp.npe4__Contact__c;
                   newCon.Publicity_OK__c = 'Yes';
                   wishChildList.add(newCon);
               
               }
               
               if(recipentMap.containsKey(npsp.npe4__RelatedContact__r.Name)){
                   
                   Contact newliabilityCon = new Contact();
                   newliabilityCon.Id = npsp.npe4__RelatedContact__c;
                   newliabilityCon.Wish_Liability_IsSigned__c = true;
                   wishChildList.add(newliabilityCon);
               
               }
               
           }
           if(wishChildList.size() > 0)
           update wishChildList;
           }
           if(wishChildFormList.size() > 0)
           update wishChildFormList;
        }
    }

}