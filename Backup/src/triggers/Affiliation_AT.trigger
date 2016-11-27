/**************************************************************************************
Created By: Vennila Paramasivam
Author : MST Solutions
Created Date : 06/28/2016
Description : Updating Primary as True when affiliation record is creating for contact as a first record
and used to add user to chatter group when the user becomes active for the chapter
***************************************************************************************/

trigger Affiliation_AT on npe5__Affiliation__c (Before Insert,Before Update,After Update,After Insert) {
    
    Set<Id> contactIds = new Set<Id>();
    Map<String,Integer> contactsMap = new Map<String,Integer>();
    Map<id,String> contactMap=new Map<id,String>();
    
   // Whenever first Affiliation record is fallon under contact, assigning that record as primary.
    if(Trigger.isBefore && Trigger.isInsert) 
    {
        for(npe5__Affiliation__c currRec : Trigger.new) 
        {
            contactIds.add(currRec.npe5__Contact__c);
        }
    
        for(AggregateResult ar : [SELECT npe5__Contact__c, count(Id) cnt FROM npe5__Affiliation__c 
                                  WHERE npe5__Contact__c IN :contactIds 
                                  GROUP BY npe5__Contact__c])
        {
            contactsMap.put(String.valueOf(ar.get('npe5__Contact__c')), Integer.valueOf(ar.get('cnt')));
        }
        
         for(npe5__Affiliation__c currRec : Trigger.new) 
         {
            if(!(contactsMap.containsKey(currRec.npe5__Contact__c))) {
                currRec.npe5__Primary__c = True;
            }
         }
    
     }
    //This used to get affiliation's crossponding user name and email to merge in active user welcome email template
    if(trigger.isBefore&& trigger.isUpdate)
    {
        set<Id> contactIdsSet = new set<Id>();
        list<npe5__Affiliation__c> UpdateAffiliationList = new List<npe5__Affiliation__c>();
        Map<Id,User>volunteerUserMap = new map<Id,User>();
        for(npe5__Affiliation__c currRec : Trigger.new){
            if((currRec.npe5__Status__c != Null && currRec.npe5__Status__c == 'Active') && (trigger.oldmap.get(currRec.id).npe5__Status__c != currRec.npe5__Status__c)){
                contactIdsSet.add(currRec.npe5__Contact__c);
            }
        }
        for(User currUser : [SELECT ID,Username,ContactId,Email FROM User WHERE ContactId IN:contactIdsSet]){
            if(contactIdsSet.contains(currUser.ContactId)){
                volunteerUserMap.put(currUser.ContactId, currUser);
            }
        }
        
        for(npe5__Affiliation__c currRec : Trigger.new){
            if((currRec.npe5__Status__c != Null && currRec.npe5__Status__c == 'Active') && (volunteerUserMap.containsKey(currRec.npe5__Contact__c))){
                currRec.User_Name_Hidden__c = volunteerUserMap.get(currRec.npe5__Contact__c).Username;
                currRec.User_Email_Hidden__c = volunteerUserMap.get(currRec.npe5__Contact__c).Email;
            }
        }
        
    }
    
    //Used to add user to chatter group when a user becomes active to particular chapter
    if(Trigger.isAfter && Trigger.isUpdate) {
        List<npe5__Affiliation__c> affilationsList = new List<npe5__Affiliation__c>();
        Set<Id> affiliationsIdsSet = new Set<Id>();
        Set<Id> volunteerContactIdsSet = new Set<Id>();
        for(npe5__Affiliation__c modifiedAffiliation : Trigger.New) {
            if(modifiedAffiliation.npe5__Status__c == 'Active' && Trigger.oldMap.get(modifiedAffiliation.Id).npe5__Status__c != modifiedAffiliation.npe5__Status__c) {
                volunteerContactIdsSet.add(modifiedAffiliation.npe5__Contact__c);
                affilationsList.add(modifiedAffiliation);
                affiliationsIdsSet.add(modifiedAffiliation.Id);
            }
        }
        
        if(affilationsList.size()>0 && volunteerContactIdsSet.size()>0 && affiliationsIdsSet.size()>0) {
            AffiliationTriggerHandler.addUserToChaptterGroup(volunteerContactIdsSet,affiliationsIdsSet);
        }
    }
    if(Trigger.isAfter){
        for(npe5__Affiliation__c currRec:trigger.new){
            if(trigger.isinsert || currRec.npe5__Status__c!=trigger.oldMap.get(currRec.id).npe5__Status__c){
                contactMap.put(currRec.npe5__Contact__c,currRec.npe5__Status__c);
            }
        }
        if(contactMap != null && contactMap.size() >0){
            AffiliationTriggerHandler.updateContact(contactMap);
        }
 
    }
}