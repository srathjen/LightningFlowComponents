trigger AffiliationUpdatecontact_AT on npe5__Affiliation__c (after insert,after update) {
    
    Map<id,String> contactMap=new Map<id,String>();
    
    for(npe5__Affiliation__c currRec:trigger.new){
        if(trigger.isinsert || currRec.npe5__Status__c!=trigger.oldMap.get(currRec.id).npe5__Status__c){
            contactMap.put(currRec.npe5__Contact__c,currRec.npe5__Status__c);
        }
    }
    
    if(contactMap != null && contactMap.size() >0){
       List<Contact> conList=[SELECT id,Hidden_Status__c from contact where id IN:contactMap.keyset()];
       for(Contact currContact:conList){
           currContact.Hidden_Status__c=contactMap.get(currContact.id);
       } 
       update conList;
    }

}