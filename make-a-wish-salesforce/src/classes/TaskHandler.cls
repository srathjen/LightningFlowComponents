/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kesavakumar Murugesan
Date        : 6/1/2016
Description : This class is used to create tasks when a task is completed and used to change the ownership
of the 'Brithday Remainder Task' to the primary volunteer and assign tasks to cae team member based on roles
*******************************************************************************************************************/
public class TaskHandler {
    
    // This method is used to create task after closing related task
    public static void CreateNextTask(List<Task> statusUpdatedTaskList, Set<Id> taskRelatedCaseIdsSet) {
        Constant_AC  constant = new Constant_Ac(); 
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Id wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        
        Set<String> taskParentDetailsSet = new  Set<String>();
        Map<Id,String> idsTaskNamesMap = new Map<Id,String>();
        
        Map<Id,Case> recurrenceTaskCasesMap = new Map<Id,Case>();
        
        for(Case getRelatedCase : [SELECT Id, RecordTypeId, ContactId, Wish_type__c, Chapter_Name__c,Subject, Status FROM Case WHERE isClosed = false AND Id IN : taskRelatedCaseIdsSet]) {
            recurrenceTaskCasesMap.put(getRelatedCase.Id, getRelatedCase);
        }
        
        Map<String,List<Task>> taskDetailsMap = new Map<String,List<Task>>();
        for(Task taskDetails : statusUpdatedTaskList) {
            if(taskDetails.WhatId != Null) {
                if(recurrenceTaskCasesMap.containsKey(taskDetails.WhatId)) {
                    if(recurrenceTaskCasesMap.get(taskDetails.WhatId).Wish_Type__c != null) {
                        if(taskDetailsMap.containsKey(recurrenceTaskCasesMap.get(taskDetails.WhatId).Wish_Type__c)) {
                            taskDetailsMap.get(recurrenceTaskCasesMap.get(taskDetails.WhatId).Wish_Type__c).add(taskDetails);
                        } else {
                            taskDetailsMap.put(recurrenceTaskCasesMap.get(taskDetails.WhatId).Wish_Type__c, new List<Task>{taskDetails});
                        }
                    } 
                }
            }
        } 
        List<Task> newTaskList = new List<Task>();
        Set<Id> newTaskCreatedWishesIdsSet = new Set<Id>();
        Map<String,Chapter_Action_Track__c> chapterDetailsMap = new Map<String,Chapter_Action_Track__c>();
        for(Chapter_Action_Track__c chapterActionList : [SELECT Id,Task_Name__c,Assigned_To__c, Recurring_Frequency__c,Recurring__c,Wish_Type__c,Chapter_Name__r.Name,Case_Type_Stage__c,Sort_Order__c,Due_Date__c FROM Chapter_Action_Track__c WHERE Wish_Type__c IN :taskDetailsMap.keySet() ORDER BY Sort_Order__c ASC]) {
            for(String wishTypes : taskDetailsMap.keySet()) {
                if(taskDetailsMap.containsKey(wishTypes)) {
                    for(Task createNextTask : taskDetailsMap.get(wishTypes)) {
                        if(recurrenceTaskCasesMap.get(createNextTask.WhatId).Wish_type__c == wishTypes && recurrenceTaskCasesMap.get(createNextTask.WhatId).Subject == chapterActionList.Case_Type_Stage__c && recurrenceTaskCasesMap.get(createNextTask.WhatId).Chapter_Name__c == chapterActionList.Chapter_Name__r.Name) {
                            if(createNextTask.Sort_Order__c < chapterActionList.Sort_Order__c && !newTaskCreatedWishesIdsSet.contains(createNextTask.WhatId)) {
                                newTaskCreatedWishesIdsSet.add(createNextTask.WhatId);
                                Task newTask = new Task();
                                newTask.WhatId = createNextTask.WhatId;
                                newTask.WhoId = createNextTask.WhoId;
                                newTask.Subject = chapterActionList.Task_Name__c;
                                newTask.ActivityDate = System.today() + Integer.valueOf(chapterActionList.Due_Date__c);
                                newTask.Sort_Order__c = chapterActionList.Sort_Order__c;
                                newTask.TaskVolunteerRole__c = chapterActionList.Assigned_To__c;
                                newTaskList.add(newTask);
                            } 
                        } 
                    }
                }
            }
        }
        if(newTaskList.size()>0) {
            insert newTaskList;
        }
    }
    
    // This method is used to assign the 'Birthday Remainder Task' to primary volunteer
    public static void BirthdayTaskPrimaryVolunteerAssign(List<Task> birthdayTasksList, Set<Id> taskRelatedContactIdsSet) {
        
        Set<Id> caseIdsSet = new Set<Id>();
        Map<Id,Id> caseContactIdsMap = new map<Id,Id>();
        Map<Id,Id> taskRelatedCaseIdsMap = new Map<Id,Id>();
        for(Case caseDetails : [SELECT Id, ContactId FROM Case WHERE Id IN : taskRelatedContactIdsSet]) {
            caseIdsSet.add(caseDetails.Id);
            caseContactIdsMap.put(caseDetails.Id, caseDetails.ContactId);
            taskRelatedCaseIdsMap.put(caseDetails.Id, caseDetails.contactId);
        }
        if(caseIdsSet.size()>0) {
            Map<Id,Id> caseTeamMembersMap = new Map<Id,Id>();
            for(CaseTeamMember memberDetails : [SELECT Id, MemberId, ParentId FROM CaseTeamMember WHERE ParentId IN : caseIdsSet ORDER BY CreatedDate ASC]) {
                
                if(!caseTeamMembersMap.containsKey(memberDetails.ParentId)) {
                    caseTeamMembersMap.put(memberDetails.ParentId,memberDetails.MemberId);
                }
            }
            if(caseTeamMembersMap.size()>0) {
                Map<Id,Id> contactRelatedUsersIdsMap = new Map<Id,Id>();
                for(User getUserDetails : [SELECT Id, ContactId FROM User WHERE ContactId IN : caseTeamMembersMap.values()]) {
                    if(!contactRelatedUsersIdsMap.containsKey(getUserDetails.ContactId)) {
                        contactRelatedUsersIdsMap.put(getUserDetails.ContactId, getUserDetails.Id);
                    }
                }
                
                for(Task assignTaskOwner : birthdayTasksList) {
                    if(caseTeamMembersMap.containsKey(assignTaskOwner.whatId)) {
                        assignTaskOwner.OwnerId=contactRelatedUsersIdsMap.get(caseTeamMembersMap.get(assignTaskOwner.whatId));
                    }
                    if(taskRelatedCaseIdsMap.containsKey(assignTaskOwner.whatId)) {
                        assignTaskOwner.whoId= taskRelatedCaseIdsMap.get(assignTaskOwner.whatId);
                    }
                }
            }
        }
    }
    
    //This method is used to assign task to caseteammembers based on roles
    public static void TaskAssignmentToVolunteer(List<Task> actionTrackTasksList, Set<Id> actionTracksRelatedCaseIdsSet) {
        
        Constant_AC  constant = new Constant_Ac(); 
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Id wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        
        Map<Id,Case> caseIdsMap = new Map<Id,Case>();
        Set<String> wishTypesSet = new Set<String>();
        Set<String> wishStagesSet = new Set<String>();
        Set<String> wishChaptersSet = new Set<String>();
        
        for(Case getTaskDetails : [SELECT Id, Chapter_Name__c,RecordType.Name,Wish_Type__c, RecordTypeId FROM Case WHERE Id IN : actionTracksRelatedCaseIdsSet]) {
            if(getTaskDetails.Chapter_Name__c !=null && getTaskDetails.Wish_type__c != null) {
                wishTypesSet.add(getTaskDetails.Wish_type__c);
                wishStagesSet.add(getTaskDetails.RecordType.Name);
                wishChaptersSet.add(getTaskDetails.Chapter_Name__c);
            }
            caseIdsMap.put(getTaskDetails.Id,getTaskDetails);
            
        }
        
        Map<String, List<Chapter_Action_Track__c>> chapterActionsMap = new Map<String, List<Chapter_Action_Track__c>>();
        
        for(Chapter_Action_Track__c chapterActionTrack : [SELECT Id, Task_Name__c,Wish_Type__c,Chapter_Name__r.Name, Case_Type_Stage__c, Assigned_To__c FROM Chapter_Action_Track__c WHERE Wish_Type__c IN : wishTypesSet AND Case_Type_Stage__c IN : wishStagesSet AND  Chapter_Name__r.Name IN : wishChaptersSet]) {
            if(chapterActionsMap.containsKey(chapterActionTrack.Wish_type__c)) {
                chapterActionsMap.get(chapterActionTrack.Wish_type__c).add(chapterActionTrack);
            } else{
                chapterActionsMap.put(chapterActionTrack.Wish_type__c, new List<Chapter_Action_Track__c>{chapterActionTrack});
            }
        }
        Map<Id, List<CaseTeamMember>> wishTeamMembersMap = new Map<Id, List<CaseTeamMember>>();
        Set<Id> contactIdsSet = new Set<Id>();
        for(CaseTeamMember memberDetails : [SELECT Id, MemberId, ParentId, TeamRoleId, TeamRole.Name FROM CaseTeamMember WHERE ParentId IN : actionTracksRelatedCaseIdsSet]) {
            contactIdsSet.add(memberDetails.MemberId);
            
            if(wishTeamMembersMap.containsKey(memberDetails.parentId)) {
                wishTeamMembersMap.get(memberDetails.parentId).add(memberDetails);
            } else {
                wishTeamMembersMap.put(memberDetails.parentId, new List<CaseTeamMember>{memberDetails});
            }
        }
        
        Map<Id,Id> contactUsers = new Map<Id,Id>();
        if(contactIdsSet.size()>0) {
            for(User relatedUser : [SELECT Id, ContactId FROM User WHERE ContactId IN : contactIdsSet]) {
                contactUsers.put(relatedUser.ContactId, relatedUser.Id);
            }
        }
        
        Set<Id> taskDuplicateCheck = new Set<id>();
        for(Task assignOwner : actionTrackTasksList) {
            for(String wishes : chapterActionsMap.keySet()) {
                for(Chapter_Action_Track__c chapterAction : chapterActionsMap.get(wishes)) {
                    if(caseIdsMap.containsKey(assignOwner.WhatId) && assignOwner.Subject == chapterAction.Task_Name__c && chapterAction.Chapter_Name__r.Name == caseIdsMap.get(assignOwner.WhatId).Chapter_Name__c) {
                        if(wishes==caseIdsMap.get(assignOwner.WhatId).Wish_Type__c) {
                            if(wishTeamMembersMap.containsKey(assignOwner.WhatId)) {
                                for(CaseTeamMember caseTeam : wishTeamMembersMap.get(assignOwner.WhatId)) {
                                    if(assignOwner.TaskVolunteerRole__c == caseTeam.TeamRole.Name) {
                                        //if(String.valueOf(caseTeam.MemberId).startsWith('005')) {
                                        //Used the check whether Member is a user
                                        if(String.valueOf(caseTeam.MemberId).substring(0,3) == USER.sobjecttype.getDescribe().getKeyPrefix()) {
                                            assignOwner.OwnerId = caseTeam.MemberId;
                                        } else if(contactUsers.containsKey(caseTeam.MemberId)) {
                                            assignOwner.OwnerId = contactUsers.get(caseTeam.MemberId);
                                        }
                                    } 
                                }
                            }
                        }                         
                    }
                }
            }
        }        
    }
    
    
    public static void UpdateAffiliationStatus(Set<Id> volunteerContactSet)
    {
        Constant_AC  constant = new Constant_Ac(); 
        Id triainingRecordTypeId = Schema.Sobjecttype.Orientation_Training__c.getRecordTypeInfosByName().get(constant.trainingRT).getRecordTypeId();
        Set<Id> bgRequiredvolIdsSet = new Set<Id>();
        Set<Id> chapterRoleSet = new Set<Id>();
        Set<Id> contactIdSet = new Set<Id>();
        Map<String, Set<String>> volunteerChapterRoleMap = new Map<String, Set<String>>();
        Map<Id,Volunteer_Orientation_Training__c > volunteerMap = new Map<Id,Volunteer_Orientation_Training__c>();
        Set<String> chapterRoleOandTsSet = new Set<String>();
        Map<String,Conflict_Of_Interest__c> coiMap = new Map<String,Conflict_Of_Interest__c>();
        List<npe5__Affiliation__c> updateAffliationList = new List<npe5__Affiliation__c>();
        Set<Id> activeContactIdsSet = new Set<Id>();
        List<Volunteer_Roles__c> updateVolunteerRoleStatus = new List<Volunteer_Roles__c>();
        
        for(Volunteer_Roles__c currRole : [SELECT Id,Name,Chapter_Role__c,Chapter_Role__r.Background_Check_Required__c,Volunteer_Name__c From Volunteer_Roles__c  WHERE Volunteer_Name__c  IN:volunteerContactSet])
        {
            Volunteer_Roles__c updateStatus = new Volunteer_Roles__c();
            updateStatus.id = currRole.id;
            updateStatus.Status__c = 'Pending Training';
            updateVolunteerRoleStatus.add(updateStatus);
           
            if(currRole.Chapter_Role__r.Background_Check_Required__c == TRUE)
                bgRequiredvolIdsSet.add(currRole.Volunteer_Name__c);
            chapterRoleSet.add(currRole.Chapter_Role__c);
            if(volunteerChapterRoleMap.containsKey(currRole.Volunteer_Name__c))
                volunteerChapterRoleMap.get(currRole.Volunteer_Name__c).add(currRole.Chapter_Role__c);
            else
                volunteerChapterRoleMap.put(currRole.Volunteer_Name__c, new Set<String>{currRole.Chapter_Role__c});
        }
        
        if(chapterRoleSet.size() > 0)
        {
            for(Chapter_Role_O_T__c currChapterRole : [SELECT Id,Name,Orientation_Training__c,Orientation_Training__r.RecordTypeId,Required__c,Chapter_Role__c FROM Chapter_Role_O_T__c WHERE Chapter_Role__c IN :chapterRoleSet AND Required__c = TRUE AND Orientation_Training__r.RecordTypeId =:triainingRecordTypeId])
            {
                chapterRoleOandTsSet.add(currChapterRole.Chapter_Role__c);
            }
        }
        
        
        for(Conflict_Of_Interest__c currCOI : [SELECT  id, Volunteer_Contact__c, Expiration_Date__c FROM Conflict_Of_Interest__c  WHERE Volunteer_Contact__c IN :volunteerContactSet AND Expiration_Date__c > : Date.Today()])
        {
            coiMap.put(currCOI.Volunteer_Contact__c, currCOI);
        }
        
        
        for(npe5__Affiliation__c currRec : [SELECT Id,npe5__Contact__c,npe5__Primary__c,npe5__Status__c,npe5__Organization__c FROM npe5__Affiliation__c WHERE npe5__Contact__c IN :volunteerContactSet AND npe5__Status__c != 'Active'])
        {
            npe5__Affiliation__c currAffiliation = new npe5__Affiliation__c();
            currAffiliation.id = currRec.id;
            if(coiMap.containsKey(currRec.npe5__Contact__c))
                currAffiliation.npe5__Status__c = 'Active';
            else
                currAffiliation.npe5__Status__c = 'Pending';
            
            if(bgRequiredvolIdsSet.contains(currRec.npe5__Contact__c))
            {
                currAffiliation.npe5__Status__c = 'Pending';
            }
            if(volunteerChapterRoleMap.containsKey(currRec.npe5__Contact__c)){
            for(String currChapterRole : volunteerChapterRoleMap.get(currRec.npe5__Contact__c))
            {
                if(chapterRoleOandTsSet.contains(currChapterRole))
                {
                    currAffiliation.npe5__Status__c = 'Pending';
                }
                
            }
            }
            
            if(currAffiliation.npe5__Status__c == 'Active')
                activeContactIdsSet.add(currRec.npe5__Contact__c);
            
            updateAffliationList.add(currAffiliation);
            
        }
        
        if(updateVolunteerRoleStatus.size() > 0)
           update updateVolunteerRoleStatus;
        
        if(updateAffliationList.size() > 0)
        {
            Update updateAffliationList;
            if(activeContactIdsSet.size() > 0)
                VolunteerOandTHandler.updateUser(activeContactIdsSet);
        }
        
    }
    
    /*This method is used to update the Affiliation status to 'Declined' when the task status is 'Declined'*/
    public static void UpdateAffiliationStatusAsDeclined(Set<Id> volunteerContactSet)
    {
        List<npe5__Affiliation__c> affiliationList = new List<npe5__Affiliation__c>();
        for(npe5__Affiliation__c dbAffiliationRec : [SELECT Id,npe5__Contact__c,npe5__Primary__c,npe5__Status__c,npe5__Organization__c FROM npe5__Affiliation__c WHERE npe5__Contact__c IN :volunteerContactSet AND npe5__Status__c != 'Active']){
            dbAffiliationRec.npe5__Status__c = 'Declined';
            affiliationList.add(dbAffiliationRec);
        }
        if(affiliationList.size() > 0 ){
            update affiliationList;
        }
    }
    /* This method is used to fetch the values from associated contact of task and assign with the 
       corresponding task fields to merge with email template */
    public static void updateTaskEmailMergeFields(Set<id> volunteerConatctIdsSet,list<Task> updatedTaskList){
        Map<Id,Contact> contactInfoMap = new Map<Id,Contact>();
        
        for(Contact getContactInfo : [SELECT ID, Name, Account.Name, Account.Phone, Account.Email__c FROM contact where id IN:volunteerConatctIdsSet]) {
            if(!contactInfoMap.containsKey(getContactInfo.Id)) {
                contactInfoMap.put(getContactInfo.Id, getContactInfo);
            }
        }
        for(Task currRec : updatedTaskList){
            if(currRec.WhoId != Null && contactInfoMap.containsKey(currRec.WhoId)){
                currRec.Account_Name__c = contactInfoMap.get(currRec.WhoId).Account.Name;
                currRec.Account_Phone__c = contactInfoMap.get(currRec.WhoId).Account.Phone;
                currRec.Account_Email__c = contactInfoMap.get(currRec.WhoId).Account.Email__c;
                currRec.Contact_Name_Hidden__c = contactInfoMap.get(currRec.WhoId).Name;
            }
        }
    }
}