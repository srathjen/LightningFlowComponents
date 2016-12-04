trigger ContactConstituentCodeTrigger_AT on Contact_Constituent_Code__c (before insert,before update) {
    
     
   Set<Id> affiliationIdSet= new Set<Id>();
    if(trigger.isbefore && (trigger.isinsert || trigger.isupdate)){

        for(Contact_Constituent_Code__c currRec: trigger.new){
            if(currRec.hidden_contact__c == Null && (trigger.isinsert || currRec.Affiliation__c != trigger.oldmap.get(currRec.id).Affiliation__c)){
                affiliationIdSet.add(currRec.Affiliation__c);
             }
        }
      if(affiliationIdSet.size() > 0 && affiliationIdSet!= Null){
           Map<Id,npe5__Affiliation__c> contactIdMap=new Map<Id,npe5__Affiliation__c>([SELECT id,npe5__Contact__c from npe5__Affiliation__c  WHERE id IN: affiliationIdSet]);
           for(Contact_Constituent_Code__c currRec: trigger.new){
               if(affiliationIdSet.contains(currRec.Affiliation__c)){
                   currRec.hidden_contact__c=contactIdMap.get(currRec.Affiliation__c).npe5__Contact__c ;
               }
            }
        }
        
    }
}