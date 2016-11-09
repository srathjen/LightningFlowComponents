/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kesavakumar Murugesan
Date        : 7/12/2016
Description : This trigger is used to add volunteer to appropriate chatter group based on their role
*******************************************************************************************************************/
trigger AffiliationTrigger_AT on npe5__Affiliation__c (after update) {
    
  /*  List<npe5__Affiliation__c> affilationsList = new List<npe5__Affiliation__c>();
    Set<Id> affiliationsIdsSet = new Set<Id>();
    Set<Id> volunteerContactIds = new Set<Id>();
    for(npe5__Affiliation__c modifiedAffiliation : Trigger.New) {
        if(modifiedAffiliation.npe5__Status__c == 'Active' && Trigger.oldMap.get(modifiedAffiliation.Id).npe5__Status__c != modifiedAffiliation.npe5__Status__c) {
            //chatterUsersList.add(newContact);
            volunteerContactIds.add(modifiedAffiliation.npe5__Contact__c);
            affilationsList.add(modifiedAffiliation);
            affiliationsIdsSet.add(modifiedAffiliation.Id);
        }
    }
    
    if(affilationsList.size()>0 && volunteerContactIds.size()>0 && affiliationsIdsSet.size()>0) {
        AffiliationTriggerHandler.AddUserToChaptterGroup(affilationsList, volunteerContactIds,affiliationsIdsSet);
    }*/
    
}