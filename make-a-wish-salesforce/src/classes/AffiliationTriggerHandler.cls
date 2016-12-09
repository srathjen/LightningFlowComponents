/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kesavakumar Murugesan
Date        : 7/12/2016
Description : This class is used to add the volunteer to appropriate chatter group based on their chapter when they become an active volunteer
*******************************************************************************************************************/
public class AffiliationTriggerHandler {
    
    // Used to add a user to chatter group based on their chapter when the volunter become active.
  
    public static void addUserToChaptterGroup(Set<Id> volunteerContactIdsSet, Set<Id> affiliationsIdsSet) {
        
        Map<Id,String> volunteerChaptersMap = new Map<Id,String>();
        Set<String> chapterNamesSet = new Set<String>();
        Map<Id, Id> volunteerUsersMap = new Map<Id,Id>();
        Map<String,Id> chatterGroupNameIdsMap = new Map<String,Id>();
        List<CollaborationGroupMember> chatterGroupMembersList = new List<CollaborationGroupMember>();
        
        for(npe5__Affiliation__c getChapters : [SELECT Id, npe5__Organization__r.Name, npe5__Contact__c FROM npe5__Affiliation__c WHERE npe5__Contact__c IN : volunteerContactIdsSet AND Id IN : affiliationsIdsSet]) {
            if(!chapterNamesSet.contains(getChapters.npe5__Organization__r.Name)) {
                chapterNamesSet.add(String.valueOf(getChapters.npe5__Organization__r.Name).removeStart('Make-A-Wish '));
            }
            volunteerChaptersMap.put(getChapters.npe5__Contact__c, String.valueOf(getChapters.npe5__Organization__r.Name).removeStart('Make-A-Wish '));
        }
        
        System.debug('ChapterName Set'+ chapterNamesSet);
        // Used to get volunteer user id and volunteer contact id
        for(User relatedUsers : [SELECT Id, ContactId FROM User WHERE ContactId IN : volunteerContactIdsSet]) {
            volunteerUsersMap.put(relatedUsers.ContactId ,relatedUsers.Id);
        }        
        if(chapterNamesSet.size()>0) {
            // Used to get the group name based on the chapter names
            for(CollaborationGroup getgroupId : [SELECT Id, Name FROM CollaborationGroup WHERE Name IN : chapterNamesSet]) {
                chatterGroupNameIdsMap.put(getgroupId.Name,getgroupId.Id);
            }
        }
        System.debug('chatterGroupNameIdsMap>>>'+chatterGroupNameIdsMap);
        Set<String> chatterGroupsMembersSet = new Set<String>();
        for(CollaborationGroupMember chatterGroupMemberExistCheck : [SELECT Id, MemberId, CollaborationGroupId FROM CollaborationGroupMember WHERE MemberId IN : volunteerUsersMap.values()])  {
            chatterGroupsMembersSet.add(chatterGroupMemberExistCheck.CollaborationGroupId+'-'+chatterGroupMemberExistCheck.MemberId);
        }
        //Used to check whether a user exists in the chatter group before adding the user to group
        for(Id volunteerContact : volunteerContactIdsSet) {
            if(volunteerChaptersMap.containsKey(volunteerContact) && chatterGroupNameIdsMap.containsKey(volunteerChaptersMap.get(volunteerContact)) && volunteerChaptersMap.containsKey(volunteerContact)) {
                if(!chatterGroupsMembersSet.contains(chatterGroupNameIdsMap.get(volunteerChaptersMap.get(volunteerContact))+'-'+volunteerUsersMap.get(volunteerContact))) {
                    chatterGroupMembersList.add(new CollaborationGroupMember (CollaborationGroupId = chatterGroupNameIdsMap.get(volunteerChaptersMap.get(volunteerContact)), MemberId = volunteerUsersMap.get(volunteerContact)));
                }
            }            
        }
        if(chatterGroupMembersList.size()>0) {
            if(!Test.isRunningTest()) {
                insert chatterGroupMembersList; // adding members to the group.
            }
        }
    }
    //used to update the status field in contact for reporting purpose
    public static void updateContact(Map<id,String>contactMap){
        List<Contact> conList=[SELECT id,Hidden_Status__c  from contact where id IN:contactMap.keyset()];
       for(Contact currContact:conList){
           currContact.Hidden_Status__c=contactMap.get(currContact.id);
       } 
       update conList;
        
    }
}