trigger Relationship_AT on npe4__Relationship__c (after insert,before insert) {

    if(trigger.isBefore && Trigger.isInsert){
        Set<Id> relatedContactId = new Set<Id>();
        
        for(npe4__Relationship__c newRecord :trigger.new){
           relatedContactId.add(newRecord.npe4__RelatedContact__c);
        }
        
        Map<Id,Contact> relatedConMap = new Map<Id,Contact>([SELECT Id,Name,IsParentGuardian__c FROM Contact WHERE Id IN:relatedContactId AND (IsParentGuardian__c = 'ParentGuardian' OR IsParentGuardian__c = 'Participant')]);
        
        for(npe4__Relationship__c newRecord :trigger.new){
            if(relatedConMap.containsKey(newRecord.npe4__RelatedContact__c) && relatedConMap.get(newRecord.npe4__RelatedContact__c).IsParentGuardian__c ==  'ParentGuardian'){
                newRecord.Wish_Family_participants__c = 'Parent/Guardian';
            }
            if(relatedConMap.containsKey(newRecord.npe4__RelatedContact__c) && relatedConMap.get(newRecord.npe4__RelatedContact__c).IsParentGuardian__c ==  'Participant'){
                newRecord.Wish_Family_participants__c = 'Participants';
            }
        }
    }
    if(trigger.isInsert && trigger.isAfter){
        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Wish Child').getRecordTypeId();
        list<Contact> contactList = new list<Contact>();
        list<Contact> updatedConList = new list<Contact>();
        set<string> relationshipIdsSet = new set<string>();
        map<string,list<npe4__Relationship__c>> relationshipMap = new map<string,list<npe4__Relationship__c>>();
        for(npe4__Relationship__c newRecord :trigger.new){
            if(newRecord.npe4__Contact__c != Null && newRecord.Wish_Family_participants__c == 'Parent/Guardian'){
                relationshipIdsSet.add(newRecord.id);
            }
        }
        for(npe4__Relationship__c currrentRlationShip : [SELECT ID,npe4__Contact__c,npe4__RelatedContact__r.Name,npe4__RelatedContact__r.Email,npe4__RelatedContact__c,Wish_Family_participants__c FROM npe4__Relationship__c 
                                                         WHERE ID IN:relationshipIdsSet AND Wish_Family_participants__c = 'Parent/Guardian']){
                                                             if(relationshipMap.containsKey(currrentRlationShip.npe4__Contact__c)){
                                                                 relationshipMap.get(currrentRlationShip.npe4__Contact__c).add(currrentRlationShip);
                                                             }else{
                                                                 list<npe4__Relationship__c> relationList = New list<npe4__Relationship__c>();
                                                                 relationList.add(currrentRlationShip);
                                                                 relationshipMap.put(currrentRlationShip.npe4__Contact__c, relationList);
                                                             }
                                                         }
        for(Contact currentContact :[SELECT ID,Name,Parent_Legal_Guardian__c,Recipient_Email__c,First_Recipient_Name__c,Second_Recipient_Name__c,
                                    Second_Recipient_Email__c FROM Contact WHERE ID IN:relationshipMap.keySet() AND RecordTypeID =:contactRecordTypeId]){
            contactList.add(currentContact);
                                        
        }
        system.debug('!!!!!!!!!!!contactList'+ contactList);
        for(Contact upadteContact :contactList ){
            if(relationshipMap.containsKey(upadteContact.id)){
               system.debug('########relationshipMap.get(upadteContact.id'+relationshipMap.get(upadteContact.id));
                for(npe4__Relationship__c currRecoed : relationshipMap.get(upadteContact.id)){
                string parentGuardianNames;
                if(upadteContact.Parent_Legal_Guardian__c == Null){
                    upadteContact.Parent_Legal_Guardian__c = currRecoed.npe4__RelatedContact__r.Name;
                }
                else{
                    parentGuardianNames =  upadteContact.Parent_Legal_Guardian__c;
                    if(!parentGuardianNames.contains(currRecoed.npe4__RelatedContact__r.Name))
                        upadteContact.Parent_Legal_Guardian__c = upadteContact.Parent_Legal_Guardian__c + ',' + currRecoed.npe4__RelatedContact__r.Name;
                }
                system.debug('upadteContact.Recipient_Email__c'+ upadteContact.Recipient_Email__c);
                if( String.isBlank(upadteContact.Recipient_Email__c) && String.isBlank(upadteContact.First_Recipient_Name__c) ) {
                    system.debug('run if');
                    upadteContact.Recipient_Email__c = currRecoed.npe4__RelatedContact__r.Email;
                    upadteContact.First_Recipient_Name__c = currRecoed.npe4__RelatedContact__r.Name;
                }
               else if(String.isBlank(upadteContact.Second_Recipient_Name__c) && String.isBlank(upadteContact.Second_Recipient_Email__c)) {
                    system.debug('run else');
                    upadteContact.Second_Recipient_Name__c =  currRecoed.npe4__RelatedContact__r.Name;
                    upadteContact.Second_Recipient_Email__c = currRecoed.npe4__RelatedContact__r.Email;
                }
                }
                updatedConList.add(upadteContact);
            }
        }
        if(updatedConList.size()>0){
            update updatedConList;
        }
        
    }
    
}