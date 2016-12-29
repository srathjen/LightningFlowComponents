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
    public static void UpdateVolunteerInfo(Map<Id,User> prospectiveUserMap){
       List<Contact> updateContactList = new List<Contact>();
       List<npe5__Affiliation__c> updateAffiliationList = new List<npe5__Affiliation__c>();
       List<ContactShare> contactSharingList = new List<ContactShare>();
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
               
               contactShare currContactSharing = new contactShare();
               currContactSharing.ContactId = currRec.id;
               currContactSharing.UserOrGroupId = prospectiveUserMap.get(currRec.id).id;
               currContactSharing.ContactAccessLevel = 'Edit';
               currContactSharing.RowCause = Schema.contactshare.RowCause.Manual;
               contactSharingList.add(currContactSharing);
           }
           
           
       }
       if(updateContactList.size() > 0)
           update updateContactList;
       if(contactSharingList.size() >0)
           insert contactSharingList;
           
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
    
    @future
    public static void updateUser(Set<Id> inactiveUserIdSet){
      List<Case> caseList = new List<Case>();
      List<Case> dbcaseList = new List<Case>();
      Map<Id,String> caseTeamMemberMap = new Map<Id,String>();
       for(CaseTeamMember dbCaseTeamMember : [SELECT Id,MemberId,Member.FirstName,Member.LastName,ParentId,TeamRoleId,TeamRole.Name FROM CaseTeamMember  WHERE TeamRole.Name =: 'Wish Granter' AND MemberId IN: inactiveUserIdSet]){
                 
                 caseTeamMemberMap.put(dbCaseTeamMember.ParentId,dbCaseTeamMember.Member.FirstName+ ' '+' ' +dbCaseTeamMember.Member.LastName);
         }
         for(Case dbCase : [SELECT Id,isEmailWishGranter__c ,InActiveWishGranter__c  From Case WHERE Id IN:caseTeamMemberMap.KeySet()]){
             if(dbCase.isEmailWishGranter__c  == True &&  dbCase.InActiveWishGranter__c != null){
                 case newCase = new case();
                 newCase.Id =dbCase.Id;
                 newcase.isEmailWishGranter__c = false;
                 newcase.InActiveWishGranter__c = null;
                 dbcaseList.add(newCase);
             }
         }
         if(dbcaseList.size() > 0 )
         update dbcaseList;
         
         for(Id caseIds : caseTeamMemberMap.KeySet()){
              
              case newCase = new case();
              newCase.Id =caseIds;
              newcase.isEmailWishGranter__c = true;
              newcase.InActiveWishGranter__c = caseTeamMemberMap.get(caseIds);
              caseList.add(newCase); 
         }
         
         if(caseList.size() > 0)
         update caseList;
    }
    
    //Used to add Salesforce internal user to chatter group based on their Role
    @future
    public static void AddInternalUserToChatterGroup(Map<Id,Id> newUserRoleIdMap) {
      
      Set<String> userRoleName = new Set<String>(); //Used to hold chapter name after removal of '- Chapter' form Name
      Map<Id, String> groupInfoMap = new Map<Id, String>(); // Used to hold the group Id and Name
      Map<String, Id> chatterGroupNameIdsMap = new Map<String, Id>(); //Used to hold Group Name and Group Id
      List<CollaborationGroupMember> chatterGroupMembersList = new List<CollaborationGroupMember>();

      for(UserRole getUserRoleName : [SELECT Id, Name FROM UserRole WHERE Id IN : newUserRoleIdMap.values()]) {
          if(getUserRoleName.Name.contains(' - Chapter')) {
              userRoleName.add(getUserRoleName.Name.remove(' - Chapter'));
              groupInfoMap.put(getUserRoleName.Id, getUserRoleName.Name.remove(' - Chapter'));
          }
      }
      
      if(userRoleName.size() > 0) {
          for(CollaborationGroup getgroupInfo : [SELECT Id, Name FROM CollaborationGroup WHERE Name IN : userRoleName]) {
              chatterGroupNameIdsMap.put(getgroupInfo.Name,getgroupInfo.Id);
          }

          for(Id newUserId : newUserRoleIdMap.KeySet()) {
              if(groupInfoMap.containsKey(newUserRoleIdMap.get(newUserId))) {
                  CollaborationGroupMember newCollaborationMemberGroup = new CollaborationGroupMember ();
                  newCollaborationMemberGroup.MemberId = newUserId;
                  newCollaborationMemberGroup.CollaborationGroupId = chatterGroupNameIdsMap.get(groupInfoMap.get(newUserRoleIdMap.get(newUserId)));
                  chatterGroupMembersList.add(newCollaborationMemberGroup);
              }
          }
      }

      if(chatterGroupMembersList.size() > 0) {
        insert chatterGroupMembersList;
      }
    }


    @future
    public static void RemoveInternalUserToChatterGroup(Map<Id,Id> oldUserRoleIdMap) {
      Set<String> userRoleName = new Set<String>(); //Used to hold chapter name after removal of '- Chapter' form Name
      List<CollaborationGroupMember> chatterGroupMembersList = new List<CollaborationGroupMember>();
      Map<String, Id> userRoleNameIdMap = new Map<String, Id>();
      
      for(UserRole getUserRoleName : [SELECT Id, Name FROM UserRole WHERE Id IN : oldUserRoleIdMap.values()]) {
          if(getUserRoleName.Name.contains(' - Chapter')) {
              userRoleName.add(getUserRoleName.Name.remove(' - Chapter'));
              userRoleNameIdMap.put(getUserRoleName.Name.remove(' - Chapter'), getUserRoleName.Id);
          }
      }

      Map<Id, String> roleChapterMap = new map<Id, String>();
      if(userRoleName.size() > 0) {
          for(CollaborationGroup getgroupInfo : [SELECT Id, Name FROM CollaborationGroup WHERE Name IN : userRoleName]) {
              roleChapterMap.put(getgroupInfo.Id, getgroupInfo.Name);
          }

          for(CollaborationGroupMember chatterInfo : [SELECT Id, MemberId, CollaborationGroupId FROM CollaborationGroupMember WHERE MemberId IN : oldUserRoleIdMap.KeySet()]) {
              if(userRoleNameIdMap.get(roleChapterMap.get(chatterInfo.CollaborationGroupId)) == oldUserRoleIdMap.get(chatterInfo.MemberId)) {
                  chatterGroupMembersList.add(chatterInfo);
              }
          }

          if(chatterGroupMembersList.size() > 0) {
            delete chatterGroupMembersList;
          }
      }

    }
}