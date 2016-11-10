public class DDP_Controler{
    public list<case> newCase{get;set;}
    public map<string,npe4__Relationship__c> relatedContactMap{get;set;}
    public List<SelectOption> relatedConatctNameOptions{get;set;}
    public list<string> selectedContacts{get;set;}
    public list<Contact> updatedConatctList{get;set;}
    string caseId{get;set;}
    string variables;
    public DDP_Controler(ApexPages.StandardController controller) {
        this.caseId=   ApexPages.currentPage().getParameters().get('caseId');
        string wishChildRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Wish Child').getRecordTypeId();
        newCase = new list<case>();
        relatedContactMap = new map<string,npe4__Relationship__c>();
        relatedConatctNameOptions = new List<SelectOption>();
        updatedConatctList = new list<Contact>();
        selectedContacts = new list<string>();
        newCase = [SELECT ID,ParentId,Parent.ContactId,AccountId,ContactId,Parent.Contact.First_Recipient_Name__c,Parent.Contact.Recipient_Email__c,Parent.Contact.Second_Recipient_Name__c,
                   Parent.Contact.Second_Recipient_Email__c FROM Case WHERE ID =:caseId];
        for(npe4__Relationship__c newRelationship : [SELECT ID,Wish_Family_participants__c,npe4__Contact__c,npe4__Contact__r.First_Recipient_Name__c,npe4__Contact__r.Second_Recipient_Name__c,npe4__Contact__r.Recipient_Email__c,npe4__Contact__r.Second_Recipient_Email__c,
                                                     npe4__RelatedContact__c,npe4__RelatedContact__r.Name,npe4__RelatedContact__r.Email FROM npe4__Relationship__c WHERE npe4__Contact__c =: newCase[0].Parent.ContactId AND Wish_Family_participants__c = 'Parent/Guardian' ]){
                                                         relatedContactMap.put(newRelationship.npe4__RelatedContact__r.Name,newRelationship);
                                                     }
        if(relatedContactMap.size()>0){
            for(string currentCon : relatedContactMap.keySet()){
                relatedConatctNameOptions.add(new SelectOption(relatedContactMap.get(currentCon).npe4__RelatedContact__c,relatedContactMap.get(currentCon).npe4__RelatedContact__r.Name));
            }
        }
        system.debug('Case Size');
    }
    public PageReference massMerge(){
        System.debug('Inside massmerg function');
        PageReference pageRef = new PageReference('/apex/loop__looplus');    
        pageRef.getParameters().put('accountId', newCase[0].AccountId);
        pageRef.getParameters().put('eid',newCase[0].Id);
        pageRef.getParameters().put('hidecontact','True');
        system.debug('Inside pagref');
        pageRef.getParameters().put('hideddp','True');
        pageRef.getParameters().put('sidebar','False');
        pageRef.getParameters().put('autorun','true');
        //pageRef.getParameters().put('sessionId','GETSESSIONID()');
        pageRef.setRedirect(true);
        system.debug('################URL'+ ApexPages.currentPage().getURL());
        System.debug('End of massmerg function');
        return pageRef ;
    }
    
    public void UpdateRecipient(){
        /* if(selectedContacts.size()>2){
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You can select only two recipients'));
}*/
        Contact updateConatct = new Contact();
        integer i=0;
        for(string selectedCon : selectedContacts){
            if(relatedContactMap.containsKey(selectedCon)){
                updateConatct.id = relatedContactMap.get(selectedCon).npe4__Contact__c;
                if(i==0){
                    updateConatct.First_Recipient_Name__c = relatedContactMap.get(selectedCon).npe4__RelatedContact__r.Name;
                    updateConatct.Recipient_Email__c = relatedContactMap.get(selectedCon).npe4__RelatedContact__r.Email;
                    updatedConatctList.add(updateConatct);
                }
                if(i==1){
                    updateConatct.Second_Recipient_Name__c = relatedContactMap.get(selectedCon).npe4__RelatedContact__r.Name;
                    updateConatct.Second_Recipient_Email__c = relatedContactMap.get(selectedCon).npe4__RelatedContact__r.Email;
                    updatedConatctList.add(updateConatct);
                }
            }
            i++;
        }
        if(updatedConatctList.size()>0){
            update updatedConatctList;
        }
    }
}