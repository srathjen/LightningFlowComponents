/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kesavakumar Murugesan, Chandrasekar Nallusamy
Date        : 5/26/2016
Description :
1.'CreateActionTracks' method is used to carry CaseTeamMembers from Parent Wish to Child Wishes and Used to create
Tasks based on Chapters and Wish type from 'Chapter Action Track' custom object.
2.'CreateChildWish' method is used to create Child Wishes for Parent Wish.
3.'SubmitForApproval' method used to automatically submit Parent Wish for approval when required number of
Volunteers added to Parent Wish.
*******************************************************************************************************************/

public class CaseTriggerHandler {
    
    /* Used to create action track for different stages based on Chapter and used to pull Case team members to child wishes*/
    public static void createActionTracks(String caseType, Map<Id, Case> caseChapterIdsMap, Set<Id> parentWishIdsSet) {
        Constant_AC  constant = new Constant_Ac();    
        Id wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        Map<String, Case> chaptersWishMap = new Map<String, Case>();
        if(parentWishIdsSet.size()>0){
            Map<Id, List<CaseTeamMember>> parentCaseMembersMap = new Map<Id, List<CaseTeamMember>>();
            
            //Used to get case and its case team members
            for(CaseTeamMember caseTeamMem : [SELECT Id, ParentId, MemberId, TeamRoleId  FROM CaseTeamMember WHERE ParentId IN : parentWishIdsSet]) {
                if(parentCaseMembersMap.containsKey(caseTeamMem.ParentId)) {
                    parentCaseMembersMap.get(caseTeamMem.ParentId).add(caseTeamMem);
                } else {
                    parentCaseMembersMap.put(caseTeamMem.ParentId, new list<CaseTeamMember>{caseTeamMem});
                }
            }
            List<CaseTeamMember> childWishTeamMembersList = new List<CaseTeamMember>();
            Map<String, List<Case>> wishDeterminationCases = new Map<String, List<Case>>();
            
            //Used to include the parent wish case team members to child wish case team
            for(Case addTeamMember : caseChapterIdsMap.values()) {
                chaptersWishMap.put(addTeamMember.Chapter_Name__c, addTeamMember);
                if(parentCaseMembersMap.containsKey(addTeamMember.ParentId)) {
                    for(CaseTeamMember createWishTeamMember : parentCaseMembersMap.get(addTeamMember.ParentId)){
                        CaseTeamMember addWishTeamMember = new CaseTeamMember(MemberId = createWishTeamMember.MemberId,TeamRoleId = createWishTeamMember.TeamRoleId,ParentId = addTeamMember.Id);
                        childWishTeamMembersList.add(addWishTeamMember);
                    }
                }
                if(addTeamMember.RecordTypeId == wishDeterminationRecordTypeId) {
                    if(wishDeterminationCases.containsKey(addTeamMember.Chapter_Name__c)) {
                        wishDeterminationCases.get(addTeamMember.Chapter_Name__c).add(addTeamMember);
                    } else {
                        wishDeterminationCases.put(addTeamMember.Chapter_Name__c, new List<Case>{addTeamMember});
                    }
                }
            }
            if(childWishTeamMembersList.size()>0) {
                insert childWishTeamMembersList;
            }
        }
        if(caseChapterIdsMap.size()>0) {
            List<Task> newTaskList = new List<Task>();
            Map<String,List<Chapter_Action_Track__c>> chapterActionTracksMap = new Map<string, List<Chapter_Action_Track__c>>();
            
            //Used to get chapter action details based on wish chapter
            for(Chapter_Action_Track__c chapterActions : [SELECT Id, Wish_Type__c, Assigned_To__c ,Due_Date__c,Recurring__c, Recurring_Frequency__c, Name, Chapter_Name__r.Name, Case_Type_Stage__c,Sort_Order__c,Task_Name__c FROM Chapter_Action_Track__c WHERE Chapter_Name__r.Name IN : chaptersWishMap.keySet() ORDER BY Sort_Order__c ASC]) {
                if(chapterActionTracksMap.containsKey(chapterActions.Wish_type__c)) {
                    chapterActionTracksMap.get(chapterActions.Wish_type__c).add(chapterActions);
                } else {
                    chapterActionTracksMap.put(chapterActions.Wish_type__c, new List<Chapter_Action_Track__c>{chapterActions});
                }
                
            }
            
            List<Task> taskList = new List<Task>();
            
            //Used to create new task for wish by looking into chapter action track object based on wish chapter, wish type and wish stage
            for(Case createTasks : caseChapterIdsMap.values()) {
                if(chapterActionTracksMap.containsKey(createTasks.Wish_type__c)) {
                    for(Chapter_Action_Track__c actionTrack : chapterActionTracksMap.get(createTasks.Wish_type__c)) {
                        if(createTasks.Wish_type__c == actionTrack.Wish_type__c && createTasks.Subject == actionTrack.Case_Type_Stage__c && createTasks.Chapter_Name__c == actionTrack.Chapter_Name__r.Name && actionTrack.Sort_Order__c == 1) {
                            Task newTask = new Task();
                            newTask.WhatId = createTasks.Id;
                            newTask.WhoId = createTasks.ContactId;
                            newTask.Subject = actionTrack.Task_Name__c;
                            newTask.ActivityDate = System.today() + Integer.valueOf(actionTrack.Due_Date__c);
                            newTask.Sort_Order__c = actionTrack.Sort_Order__c;
                            newTask.TaskVolunteerRole__c = actionTrack.Assigned_To__c;
                            taskList.add(newTask);
                        }
                    } 
                }
            }
            if(taskList.size()>0) {
                insert taskList;
            }
        }
    }    
    
    //Used to create child wish for Parent wish
    public static void createChildWish (List<Case> childCreationWishList, String wishType) {
        Constant_AC  constant = new Constant_Ac(); 
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Id wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        
        List<Case> newWishList = new List<Case>();
        for(Case wishDetails : childCreationWishList) {
            if(wishDetails.RecordTypeId == parentWishRecordTypeId) {
                Case newWish = new Case(Chapter_Name__c = wishDetails.Chapter_Name__c, Wish_Type__c ='Standard', Subject = wishType.split('-')[0], ParentId = wishDetails.Id, AccountId=wishDetails.AccountId,ContactId=wishDetails.ContactId,Origin = 'Web',RecordTypeId=wishType.split('-')[1], OwnerId = wishDetails.OwnerId);
                newWishList.add(newWish);
            } else{
                Case newWish = new Case(Chapter_Name__c = wishDetails.Chapter_Name__c, Wish_Type__c = wishDetails.Wish_type__c ,Subject = wishType.split('-')[0], ParentId = wishDetails.ParentId, AccountId=wishDetails.AccountId,ContactId=wishDetails.ContactId,Origin = 'Web',RecordTypeId=wishType.split('-')[1], OwnerId = wishDetails.OwnerId);
                newWishList.add(newWish);
            }
        }
        if(newWishList.size()>0) {
            insert newWishList;
        }
    }
    
    //Used to submit parent wish for approval once the required volunteer assigend to Wish
    public static void submitForApproval(List<Case> wishListForApproval) {
        List<Approval.ProcessSubmitRequest> approvalRequestList = new List<Approval.ProcessSubmitRequest>();
        for(Case wishForApproval : wishListForApproval) {
            Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
            approvalRequest.setComments('Parent Wish Approval');
            approvalRequest.setObjectId(wishForApproval.id);
            approvalRequest.setProcessDefinitionNameOrId('Wish_Approval');
            approvalRequest.setSkipEntryCriteria(true);
            approvalRequestList.add(approvalRequest);
        }
        if(approvalRequestList.size()>0) {
            List<Approval.ProcessResult> resultList = Approval.process(approvalRequestList);
        }
    }
    // When the case status is updated the corresponding lead status should be update.
    public static void UpdateLeadStatus(List<Case> caseList){
     Map<Id,Case> caseMap = new Map<Id,Case>();
     List<Lead> updateLeadList = new List<Lead>();
      for(Case processdbcaseList : caseList){
            caseMap.Put(processdbcaseList.Lead__c,processdbcaseList);
            system.debug('@@@@@ caseMap @@@@@@@'+caseMap.Values());
      }
      
      if(caseMap.size() > 0){
          for(Lead dbLeads: [SELECT Id,Status,Sub_Status__c  FROM Lead WHERE Id in: caseMap.KeySet()]){
              if(caseMap.get(dbLeads.Id).Status == 'In progress')
              {
                  dbLeads.Sub_Status__c = 'Local';
              }
              
              if(caseMap.get(dbLeads.Id).Status == 'Escalated')
              {
                   system.debug('@@@@@ caseMap @@@@@@@'+caseMap.get(dbLeads.Id).Status);
                   dbLeads.Sub_Status__c = 'National';
              }
              
               if(caseMap.get(dbLeads.Id).Status == 'Medical Eligible')
              {
                  dbLeads.Status = 'Qualified';
              }
              
               if(caseMap.get(dbLeads.Id).Status == 'Denied')
              {
                  dbLeads.Status = 'DNQ';
              }
              
              updateLeadList.add(dbLeads);
              system.debug('@@@@@ updateLeadList @@@@@@@'+updateLeadList);
          }
         
      }
      
      if(updateLeadList.size() > 0)
      update updateLeadList;
    }
    
    
    public static void UpdateVolunteerWishGranted(Set<Id> wishIds)
    {
    
      List<Contact> updateContactList = new List<Contact>();
      for(Volunteer_Opportunity__c currVolOpp : [SELECT id,Volunteer_Name__c, Volunteer_Name__r.Number_of_wishes_active__c,
                                                 Volunteer_Name__r.Number_of_wishes_granted__c FROM Volunteer_Opportunity__c WHERE Wish__c IN :wishIds AND Volunteer_Name__c != Null])
      {
          
          if(currVolOpp.Volunteer_Name__c != Null)
          {
         
          Contact updateContact = new Contact();
          updateContact.id = currVolOpp.Volunteer_Name__c;
          if(currVolOpp.Volunteer_Name__r.Number_of_wishes_active__c > 0)
            updateContact.Number_of_wishes_active__c = currVolOpp.Volunteer_Name__r.Number_of_wishes_active__c - 1;
          if(currVolOpp.Volunteer_Name__r.Number_of_wishes_granted__c > 0)
            updateContact.Number_of_wishes_granted__c = currVolOpp.Volunteer_Name__r.Number_of_wishes_granted__c + 1;
          updateContactList.add(updateContact);
          }
      
      }
      if(updateContactList.size() > 0)
        Update updateContactList;
       
    }
}