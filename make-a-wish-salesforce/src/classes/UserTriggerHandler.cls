/*************************************************************************************************
Author   : MST Solutions
CreatedBy: Kanagaraj 
CreatedDate : 05/27/2015
Description : This UserTriggerHandler is used to create a public group and public group member when a new
              user record is created.
              
              Updating the Volunteer Contact details based on the user record info as well as updating the
              Affiliation record status as Prospective.
*************************************************************************************************/

Public class UserTriggerHandler{
    set<String> chapterNameSet = new Set<String>();
    Map<String,Group> existingGroupMap = new Map<String,Group>();
    Map<String,Group> newGroupMap = new Map<String,Group>();
    List<Group> groupList = new List<Group>();
    List<GroupMember> groupMemberList = new List<GroupMember>();
    
    /* Create a public group and group member.*/
     /*  public void createpublicGroup(List<User> userList){
        for(User processUserRec : userList){
            if(processUserRec.State != null){
                chapterNameSet.add(processUserRec.State);
            }
        }
        for(Group processGroupRec : [SELECT id,Name from Group WHERE Name =:chapterNameSet ]){
            existingGroupMap .put(processGroupRec.Name,processGroupRec );
        }
        for(User processUserRec : userList){
            if(existinggroupMap.containsKey(processUserRec .State)){
                GroupMember newGroupMem = new GroupMember();
                newGroupMem.GroupId= existinggroupMap.get(processUserRec .State).Id;
                newGroupMem.UserOrGroupId = processUserRec .Id;
                groupMemberList.add(newGroupMem);
            }
            else{
                Group newGroup = new Group();
                newGroup.Name = processUserRec.State;
                newgroupMap.put(newGroup.Name,newGroup);
            }
        }
        if(newgroupMap.size() > 0){
            insert newgroupMap.values();
            for(User processUserRec : userList){
                if(newgroupMap.containsKey(processUserRec .State)){
                    GroupMember newGroupMem = new GroupMember();
                    newGroupMem.GroupId= newgroupMap.get(processUserRec .State).Id;
                    newGroupMem.UserOrGroupId = processUserRec .Id;
                    groupMemberList .add(newGroupMem);}
            }
        }
        if(groupMemberList.size() > 0)
            insert groupMemberList ;
    }*/
    
    /* Update Volunteer Contact Details based on the User record details*/
    public void UpdateVolunteerInfo(Map<Id,User> prospectiveUserMap){
       List<Contact> updateContactList = new List<Contact>();
       List<npe5__Affiliation__c> updateAffiliationList = new List<npe5__Affiliation__c>();
        System.debug('prospectiveUserMap>>>>>>>>>>>>>>>'+prospectiveUserMap);
       
       for(Contact currRec : [SELECT id,MailingState,MailingPostalCode, MailingCity,Account.Volunteer_Manager__c, HomePhone FROM Contact WHERE Id IN :prospectiveUserMap.keySet()])
       {
           System.debug('Volunteer Manager>>>>>>>>>>>'+currRec.Account.Volunteer_Manager__c);
           System.debug('Record Exists>>>>>>>>>'+currRec);
           if(prospectiveUserMap.containsKey(currRec.id))
           {
               System.debug('Map contains key>>>>>>>>>>>>>>');
               Contact updateContact = new Contact();
               updateContact.id = currRec.id;
               updateContact.MailingState = prospectiveUserMap.get(currRec.id).State;
               updateContact.MailingCity = prospectiveUserMap.get(currRec.id).City;
               updateContact.MailingPostalCode = prospectiveUserMap.get(currRec.id).PostalCode;
               updateContact.HomePhone= prospectiveUserMap.get(currRec.id).Phone;
               if(currRec.Account.Volunteer_Manager__c != null) {
                   updateContact.OwnerId = currRec.Account.Volunteer_Manager__c;
               }
               updateContactList.add(updateContact);
           }
       }
       if(updateContactList.size() > 0)
           update updateContactList;
           
       // Updating the Affiliation Record status As Prospective.    
       for(npe5__Affiliation__c currRec : [SELECT id, npe5__Status__c FROM npe5__Affiliation__c  WHERE npe5__Contact__c IN :prospectiveUserMap.keySet() AND npe5__Status__c = 'Current'])
       {
         npe5__Affiliation__c updateRec = new npe5__Affiliation__c();
         updateRec.id = currRec.id;
         updateRec.npe5__Status__c  = 'Prospective';
         updateAffiliationList.add(updateRec);
       }
           
       if(updateAffiliationList.size() > 0)  
           update updateAffiliationList;   
           
    }
    
}