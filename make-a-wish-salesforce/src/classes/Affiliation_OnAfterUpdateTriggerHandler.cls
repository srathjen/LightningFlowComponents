/**************************************************************************************
Author       : MST Solutions
Created Date : 08/11/2016
Description  : This class is used as handler to AffiliationReviewTrigger_AT for updating 
               Primary as True when affiliation record is creating for contact as a first record
               and used to add user to chatter group when the user becomes active for the chapter
***************************************************************************************/
public class Affiliation_OnAfterUpdateTriggerHandler
{
     /* This method will be called after record is updated and it is fired,
       to add user to chatter group when a user becomes active to particular chapter*/
    public static void OnAfterUpdate(List<npe5__Affiliation__c> afterUpdateList,Map<Id,npe5__Affiliation__c> oldMapAfterUpdate)
    {
        List<npe5__Affiliation__c> affilationsList = new List<npe5__Affiliation__c>();
        Set<String> vlounteerNameSet = new Set<String>();
        Set<String> chapterNameSet = new Set<String>();
        Set<Id> affiliationSet = new set<Id>();
        Set<Id> affiliationsIdsSet = new Set<Id>();
        Set<Id> volunteerContactIdsSet = new Set<Id>();
        Set<Id> VolunteerOppIdSet=new Set<Id>();
        Set<Id> volunteerContactIdSet = new Set<Id>();
        Set<Id> activeVolunteerIdSet = new Set<Id>();
        Map<String,String> memberRemoveMap = new Map<String,String>();
        for(npe5__Affiliation__c modifiedAffiliation : afterUpdateList)
        {
            if(Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null)
            {
                if(modifiedAffiliation.npe5__Status__c == 'Active' && oldMapAfterUpdate.get(modifiedAffiliation.Id).npe5__Status__c != modifiedAffiliation.npe5__Status__c) 
                {
                    volunteerContactIdsSet.add(modifiedAffiliation.npe5__Contact__c);
                    affilationsList.add(modifiedAffiliation);
                    affiliationsIdsSet.add(modifiedAffiliation.Id);
                }
                if(modifiedAffiliation.npe5__Status__c== 'Inactive' && oldMapAfterUpdate.get(modifiedAffiliation.id).npe5__Status__c != 'Inactive')
                {
                    VolunteerOppIdSet.add(modifiedAffiliation.npe5__Contact__c);//npe5__Contact__c,currRec.npe5__Status__c);
                }
                System.debug('@@@@@@@@@'+modifiedAffiliation.npe5__Status__c+'&&&&&&&&&&'+oldMapAfterUpdate.get(modifiedAffiliation.id).npe5__Status__c);
                if(modifiedAffiliation.npe5__Status__c != 'Active' && oldMapAfterUpdate.get(modifiedAffiliation.id).npe5__Status__c == 'Active')
                {
                    volunteerContactIdSet.add(modifiedAffiliation.npe5__Contact__c);
                }
                if(modifiedAffiliation.npe5__Status__c == 'Active' && oldMapAfterUpdate.get(modifiedAffiliation.id).npe5__Status__c != 'Active')
                {
                    activeVolunteerIdSet.add(modifiedAffiliation.npe5__Contact__c);
                }
            }  
        }
        if(affilationsList.size()>0 && volunteerContactIdsSet.size()>0 && affiliationsIdsSet.size()>0)
        {
            Affiliation_OnAfterUpdateTriggerHelper.addUserToChaptterGroup(volunteerContactIdsSet,affiliationsIdsSet,afterUpdateList);
        }
        if(VolunteerOppIdSet.size() > 0 && VolunteerOppIdSet != Null)
        {
            
            Affiliation_OnAfterUpdateTriggerHelper.createTaskforVolunteerManager(VolunteerOppIdSet,afterUpdateList);
            
        }
        if(volunteerContactIdSet.Size() > 0 && volunteerContactIdSet != Null)
        {
            Affiliation_OnAfterUpdateTriggerHelper.inactiveAffiliations(volunteerContactIdSet,afterUpdateList);
        }
        if(activeVolunteerIdSet.Size() > 0)
        {
            Affiliation_OnAfterUpdateTriggerHelper.activeAffiliations(activeVolunteerIdSet,afterUpdateList);
        }
    }
    
    /* This method will be called after record is updated/inserted and it is fired,
       used to add the user to the public group to access the approved In-Kind donor account record based on the affiliation record*/   
    public static void OnAfterUpsert(List<npe5__Affiliation__c> upsertlist,Map<Id,npe5__Affiliation__c> oldMapUpsert)
    {   Constant_AC  constant = new Constant_AC();
        Id volunteerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.volunteerRT).getRecordTypeId();
        Map<Id,npe5__Affiliation__c> affiliationMap = new Map<Id,npe5__Affiliation__c>();
        Set<Id> affiliationIds = new Set<Id>();
        Set<String> vlounteerNameSet = new Set<String>();
        Set<String> chapterNameSet = new Set<String>();
        Set<Id> affiliationSet = new Set<Id>();
        Map<Id,String> affliationRecMap = new Map<Id,String>();
        Id groupId;
        Id userId;
        boolean createUserGroup;
        
        for(npe5__Affiliation__c currRec : upsertlist)
        {
            if(trigger.isinsert || currRec.npe5__Status__c!=oldMapUpsert.get(currRec.id).npe5__Status__c || currRec.Constituent_code__c != oldMapUpsert.get(currRec.id).Constituent_code__c)
            {
                affiliationMap.put(currRec.npe5__Contact__c,currRec);
                affiliationIds.add(currRec.npe5__Organization__c);
            }
            
            if(trigger.isinsert && currRec.npe5__Contact__c != Null && currRec.npe5__Organization__c != Null)
            {
                
                vlounteerNameSet.add(currRec.npe5__Contact__c);
                chapterNameSet.add(currRec.npe5__Organization__c);  
                affiliationSet.add(currRec.id);
                affliationRecMap.put(currRec.id,String.valueOf(currRec));
            }
        }
        System.debug('###########'+affiliationMap.size()+'&&&&&&&'+RecursiveTriggerHandler.isFirstTime);
        if(affiliationMap.size() >0 &&  RecursiveTriggerHandler.isFirstTime == true)
        {
            Affiliation_OnAfterUpdateTriggerHelper.updateContact(affiliationMap,affiliationIds,upsertlist);
        }
        
        if(vlounteerNameSet.size() > 0 && chapterNameSet.size() > 0 && affiliationSet.size() > 0)
        {   system.debug('@@@@@@@@@@ createUserGroup  @@@@@@@'+createUserGroup);
            for(Contact dbVolunteerContact : [SELECT Id,RecordTypeId,Name FROM Contact WHERE Id IN:vlounteerNameSet AND RecordTypeId =: volunteerRecordTypeId]){
                    if(dbVolunteerContact.Id != Null){
                    createUserGroup = true;
                    }
                    else
                    createUserGroup = false;
            }
            system.debug('@@@@@@@@@@ createUserGroup  @@@@@@@'+createUserGroup);
            if(createUserGroup == true){
            Affiliation_OnAfterUpdateTriggerHelper.insertGroupMember(vlounteerNameSet,chapterNameSet,affiliationSet,affliationRecMap);
            }
        }
    }
}