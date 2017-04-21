trigger Relationship_AT on npe4__Relationship__c (after insert,before insert) 
{
    if(trigger.isBefore && Trigger.isInsert)
    {
        Set<Id> relatedContactId = new Set<Id>();
        Id familyContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Wish Family').getRecordTypeId();
        for(npe4__Relationship__c newRecord :trigger.new)
        {
            if(newRecord.Migrated_Record__c == false)
            {
                relatedContactId.add(newRecord.npe4__RelatedContact__c);
            }
        }
        
        Map<Id,Contact> relatedConMap = new Map<Id,Contact>([SELECT Id,Name,IsParentGuardian__c,RecordTypeId FROM Contact WHERE Id IN:relatedContactId AND (IsParentGuardian__c = 'ParentGuardian' OR IsParentGuardian__c = 'Participant') AND RecordTypeId =:familyContactRecordTypeId ]);
        
        for(npe4__Relationship__c newRecord :trigger.new){
            if(relatedConMap.containsKey(newRecord.npe4__RelatedContact__c) && relatedConMap.get(newRecord.npe4__RelatedContact__c).IsParentGuardian__c ==  'ParentGuardian'){
                newRecord.Parent_Legal_Guardian__c = true;
            }
            if(relatedConMap.containsKey(newRecord.npe4__RelatedContact__c) && relatedConMap.get(newRecord.npe4__RelatedContact__c).IsParentGuardian__c ==  'Participant'){
                newRecord.Wish_Participant__c = true;
            }
        }
    }
    if(trigger.isInsert && trigger.isAfter)
    {
        if(RecursiveTriggerHandler.isFirstTime == true ) {
            Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Wish Child').getRecordTypeId();
            Id familyContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Wish Family').getRecordTypeId();
            Id medicalProfRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Medical Professional').getRecordTypeId();
            list<Contact> contactList = new list<Contact>();
            list<Contact> updatedConList = new list<Contact>();
            Map<id,Contact> medicalProfContactMap = new Map<id,Contact>();
            set<id> relatedContactId = new set<id>();
            Map<Id,Contact> updateChildContactMap = new Map<Id,Contact>();
            list<Contact> updateContactList = new list<Contact>();
            List<contact> updateChildContactList = new List<contact>();
            Set<Id> wishChildRelationShipSet = new Set<Id>();
            List<npe4__Relationship__c > relationShipListtoDelete = new List<npe4__Relationship__c>();
            for(npe4__Relationship__c newRecord :trigger.new)
            {
                if(newRecord.Migrated_Record__c == false)
                {
                    
                    if(newRecord.npe4__Contact__c != Null && newRecord.npe4__Type__c== 'Medical Professional' && newRecord.Qualifying_Medical_Professional__c == true && newRecord.npe4__Status__c == 'Active'){
                        
                        relatedContactId.add(newRecord.npe4__RelatedContact__c);
                    }
                }
            }
            
            if(relatedContactId.size() > 0){
                for(Contact dbWishChildCon : [SELECT Id,Name,Email,RecordTypeId FROM Contact WHERE Id In:relatedContactId AND RecordTypeId =: medicalProfRecordTypeId ]){
                    medicalProfContactMap.put(dbWishChildCon.Id,dbWishChildCon);
                }
            }
            
            if(medicalProfContactMap.size() > 0){
                for(npe4__Relationship__c newRecord :trigger.new){
                    if(medicalProfContactMap.containsKey(newRecord.npe4__RelatedContact__c)){
                        contact newContact = new Contact();
                        newContact.Id = newRecord.npe4__Contact__c;
                        newContact.Hidden_Medical_Physician__c = medicalProfContactMap.get(newRecord.npe4__RelatedContact__c).Name;
                        newContact.Hidden_Medical_Physician_Email__c = medicalProfContactMap.get(newRecord .npe4__RelatedContact__c).Email;
                        updateContactList.add(newContact);
                    }
                }
            }
            
            if(updateContactList.size() > 0)
            {
                RecursiveTriggerHandler.isFirstTime = false;
                update updateContactList;
                System.debug('updateChildContactList++++++++++++++++++++++++++++ ' + updateChildContactList);
            }
        } 
    }
    
}