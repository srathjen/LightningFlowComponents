/*****************************************************************************************************************
Author      : MST Solutions
Date        : 6/1/2016
Description : This class is used to create tasks when a task is completed and used to change the ownership
of the 'Brithday Remainder Task' to the primary volunteer and assign tasks to cae team member based on roles
*******************************************************************************************************************/
public class TaskHandler {
    
    // This method is used to create task after closing related task
    /*public static void CreateNextTask(List<Task> statusUpdatedTaskList, Set<Id> taskRelatedCaseIdsSet) {
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
    }*/
    
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
        
        for(Case getTaskDetails : [SELECT Id, ChapterName__c,ChapterName__r.Name,RecordType.Name,Wish_Type__c, RecordTypeId FROM Case WHERE Id IN : actionTracksRelatedCaseIdsSet]) {
            if(getTaskDetails.ChapterName__c !=null && getTaskDetails.Wish_type__c != null) {
                wishTypesSet.add(getTaskDetails.Wish_type__c);
                wishStagesSet.add(getTaskDetails.RecordType.Name);
                wishChaptersSet.add(getTaskDetails.ChapterName__r.Name);
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
                    if(caseIdsMap.containsKey(assignOwner.WhatId) && assignOwner.Subject == chapterAction.Task_Name__c && chapterAction.Chapter_Name__r.Name == caseIdsMap.get(assignOwner.WhatId).ChapterName__r.Name) {
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
        
        for(Volunteer_Roles__c currRole : [SELECT Id,Name,Chapter_Role__c,Status__c,Chapter_Role__r.Background_Check_Required__c,Volunteer_Name__c From Volunteer_Roles__c  WHERE Volunteer_Name__c  IN:volunteerContactSet])
        {
            Volunteer_Roles__c updateStatus = new Volunteer_Roles__c();
            
            updateStatus.id = currRole.id;
            if(currRole.Status__c != 'Chapter Review' && currRole.Status__c != 'Trained')
            {
                updateStatus.Status__c = 'Pending Training';
                updateVolunteerRoleStatus.add(updateStatus);
            }
           
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
    
    public static void updateCheckinDate(Set<Id> checkInTaskParentIdsSet){
        Constant_AC  constant = new Constant_Ac(); 
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        
        List<Case> caseFamilyCheckinUpdate = new List<Case>();
        for(Case getCase : [SELECT Id, CheckedInFamily__c FROM Case WHERE RecordTypeId =: parentWishRecordTypeId AND CheckedInFamily__c = null AND Id IN : checkInTaskParentIdsSet]) {
            getCase.CheckedInFamily__c = System.today();
            caseFamilyCheckinUpdate.add(getCase);
        }
        if(caseFamilyCheckinUpdate.size() > 0) {
            update caseFamilyCheckinUpdate;
        }
    }
    
    public static void createCheckinRecurrenceTask(List<Task> createCheckinTaskList, Set<Id> checkinTaskIdSet){
        Constant_AC  constant = new Constant_Ac();    
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Id defaultRecordTypeId = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.taskRT).getRecordTypeId();
        List<Task> newRecTaskList = new List<Task>();
        Map<Id,Case> parentCaseMap = new Map<Id,Case>([SELECT Id,Status,ParentId FROM Case WHERE RecordTypeId = :parentWishRecordTypeId AND Id IN :checkinTaskIdSet]);
      
        for(Task recCheckinTask : createCheckinTaskList) {
            if((parentCaseMap.containsKey(recCheckinTask.WhatId) && (parentCaseMap.get(recCheckinTask.WhatId).Status != 'Granted'))) {
                Task newSubTask = new Task();
                newSubTask.Subject = recCheckinTask.Subject;
                newSubTask.ActivityDate = System.Today() + 30;
                newSubTask.WhatId = recCheckinTask.WhatId;
                newSubTask.WhoId = recCheckinTask.WhoId;
                newSubTask.RecordTypeId = defaultRecordTypeId;
                newSubTask.OwnerId = recCheckinTask.OwnerId;
                newRecTaskList.add(newSubTask);
            }
        }
        if(newRecTaskList.size() > 0) {
            insert newRecTaskList;
        }
    }
    
    public static void sneakPeekTask(Map<Id, Task> flightBookTaskMap,Map<Id, Task> budgetBookTaskMap, Map<Id, Task> passportRequestMap){
        
        List<Task> updateTaskList = new List<Task>();
        if(flightBookTaskMap.size() > 0) {
            for(Task sneakPeek : [SELECT Id, ActivityDate FROM Task WHERE WhatId IN : flightBookTaskMap.keySet() AND isClosed = false AND Subject ='Sneak Peek Letter']) {
                if(sneakPeek.ActivityDate != null) {
                    sneakPeek.ActivityDate = sneakPeek.ActivityDate.addDays(7);
                } else {
                    sneakPeek.ActivityDate = System.today() + 7;
                }
                
                updateTaskList.add(sneakPeek);
            } 
        }
        if(budgetBookTaskMap.size() > 0) {
            for(Task sneakPeek : [SELECT Id, ActivityDate FROM Task WHERE WhatId IN : budgetBookTaskMap.keySet() AND isClosed = false AND (Subject ='Request Passports from family' OR Subject = 'Passports Requested from family')]) {
                if(sneakPeek.ActivityDate != null) {
                    sneakPeek.ActivityDate = sneakPeek.ActivityDate.addDays(7);
                } else {
                    sneakPeek.ActivityDate = System.today() + 7;
                }
                updateTaskList.add(sneakPeek);
            } 
        }
        if(passportRequestMap.size() > 0) {
            for(Task sneakPeek : [SELECT Id, ActivityDate FROM Task WHERE WhatId IN : passportRequestMap.keySet() AND isClosed = false AND Subject ='Cruise request form']) {
                if(sneakPeek.ActivityDate != null) {
                    sneakPeek.ActivityDate = sneakPeek.ActivityDate.addDays(14);
                } else {
                    sneakPeek.ActivityDate = System.today() + 14;
                }
                updateTaskList.add(sneakPeek);
            } 
        }
        
        if(updateTaskList.size() > 0) {
            update updateTaskList;
        }
    }
    
    
    public static void createUploadTaskForWishOwner(Map<id,id> createUploadTaskWishMap){
        Constant_AC  constant = new Constant_Ac();    
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Id defaultRecordTypeId = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.taskRT).getRecordTypeId();
        List<Task> newRecTaskList = new List<Task>();
      
        Map<Id,String> wishContactIdMap = new Map<Id,String>();
        
        for(Case getChildInfo : [SELECT Id, Contact.Name FROM Case WHERE Id IN : createUploadTaskWishMap.keySet() AND RecordTypeId =:parentWishRecordTypeId]) {
            wishContactIdMap.put(getChildInfo.Id, getChildInfo.Contact.Name);
        }
        for(Id parentId : createUploadTaskWishMap.Keyset()) {
            Task newSubTask = new Task();
            newSubTask.Subject = 'Review Photos and Videos for '+wishContactIdMap.get(parentId);
            newSubTask.WhatId = parentId;
            System.debug('WhatId>>>>'+parentId);
            System.debug('createUploadTaskWishMap>>>>'+createUploadTaskWishMap);
            newSubTask.RecordTypeId = defaultRecordTypeId;
            newSubTask.ActivityDate = System.today() + 5;
            newSubTask.OwnerId = createUploadTaskWishMap.get(parentId);
            System.debug('>>>>createUploadTaskWishMap.get(parentId)'+createUploadTaskWishMap.get(parentId));
            newRecTaskList.add(newSubTask);
            
        }
        if(newRecTaskList.size() > 0) {
            insert newRecTaskList;
        }
    }
    
    Public static void checkWishGrantTask(Set<Id> wishGrantTaskWhatIdSet) {
        System.debug('checkWishGrantTask>>>>>>>');
        Constant_AC  constant = new Constant_Ac(); 
        Id wishGrantTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.wishGrantTaskRT).getRecordTypeId();
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        List<Case> wishGrankClosedWishList = new List<Case>();
        Map<Id,Case> parentWishMap = new Map<Id,Case>([SELECT Id, isWishGrantTasksClosed__c FROM Case WHERE Id IN : wishGrantTaskWhatIdSet AND RecordTypeId =: parentWishRecordTypeId]);
        List<Task> wishGrantOpenTaskCheckList = [SELECT Id FROM Task WHERE IsClosed = FALSE AND RecordTypeId =: wishGrantTaskRT];
        Set<Id> childTaskExistParentIdSet = new Set<Id>();
        
        System.debug('wishGrantTaskWhatIdSet>>>>>'+wishGrantTaskWhatIdSet);
        for(AggregateResult agg : [SELECT count(Id) recCount, WhatId parentWishId FROM Task WHERE WhatId IN : wishGrantTaskWhatIdSet  AND isClosed = FALSE GROUP BY WhatId]) {
            /*System.debug('Record Exist>>>>>>>');
            if(agg.get('recCount') == 0) {
                System.debug('Count Zero>>>>>>>');
                Id parentRecId = (ID)agg.get('recCount');
                if(parentWishMap.containsKey(parentRecId)) {
                    parentWishMap.get(parentRecId).isWishGrantTasksClosed__c = true;
                    wishGrankClosedWishList.add(parentWishMap.get(parentRecId));
                }
            }*/
            if(parentWishMap.containsKey((ID)agg.get('parentWishId'))) {
                childTaskExistParentIdSet.add(parentWishMap.get((ID)agg.get('parentWishId')).Id);
            }
        }
        
        if(parentWishMap.size() > 0) {
            for(Id parentWishId : parentWishMap.keySet()) {
                if(!childTaskExistParentIdSet.contains(parentWishId)) {
                    if(parentWishMap.containsKey(parentWishId)) {
                        parentWishMap.get(parentWishId).isWishGrantTasksClosed__c = true;
                        wishGrankClosedWishList.add(parentWishMap.get(parentWishId));
                    }
                }
            }
        }
        
        
        if(wishGrankClosedWishList.size() > 0) {
            update wishGrankClosedWishList;
        }
    }
    
    public static void checkFollowUpTask(Map<Id, Task> followUpTaskMap, Set<Id> followUpTaskOwnerId) {
        
        Set<Id> communityUserIdSet = new Set<Id>();
        Set<Id> openTaskIdSet = new Set<Id>();
        for(User communityUser : [SELECT Id, ContactId FROM User WHERE ContactId != null AND Id IN :followUpTaskOwnerId]) {
            communityUserIdSet.add(communityUser.Id);
        }
        
        for(Task existingTask : [SELECT Id, WhatId, OwnerId FROM Task WHERE WhatId IN : followUpTaskMap.keySet() AND isClosed = false]) {
            if(communityUserIdSet.contains(existingTask.OwnerId)) {
                openTaskIdSet.add(existingTask.WhatId);
            }
        }
        
        for(Task checkOpenTask : followUpTaskMap.values()) {
            if(openTaskIdSet.contains(checkOpenTask.WhatId)) {
                checkOpenTask.addError('Please close other follow up task before closing this task');
            }
        }
    }
    
   public static void updateVolunteerRecord(Map<Id,Task> taskMap,Set<Id> ownerIds, Set<Id> caseIds)
   {
       Map<Id,User> volunteerMap = new Map<Id,User>();
       Map<Id, Set<Id>> caseTeamMemberMap = new Map<Id, Set<Id>>();
       List<Contact> updateContactList = new List<Contact>();
           for(CaseTeamMember currMemb : [SELECT id,ParentId,MemberId FROM CaseTeamMember WHERE ParentId = :caseIds AND TeamRole.Name = 'Wish Granter'])
           {
             ownerIds.add(currMemb.MemberId);
                if(!caseTeamMemberMap.containsKey(currMemb.ParentId))
                {
                     caseTeamMemberMap.put(currMemb.ParentId, new set<Id>{currMemb.memberid});
                     
                }
                else
                {
                     caseTeamMemberMap.get(currMemb.ParentId).add(currMemb.memberid);
                }
            }
           
           
           for(User currVol : [SELECT Id,ContactId,Contact.Date_of_last_engagement__c  FROM User WHERE Id IN :ownerIds AND Profile.Name = 'Active Volunteer'])
           {
              volunteerMap.put(currVol.id,currVol);
           }
           
           for(Task currTask : taskMap.values())
           {
            
               if(caseTeamMemberMap.containsKey(currTask.whatId))
               {
                   for(Id currId : caseTeamMemberMap.get(currTask.whatId))
                   {
                       if(volunteerMap.containsKey(currId))
                       {
                               if(volunteerMap.get(currId).Contact.Date_of_last_engagement__c == Null || volunteerMap.get(currId).Contact.Date_of_last_engagement__c < Date.Today())
                                {
                                   Contact updateContact = new Contact();
                                   updateContact.id = volunteerMap.get(currId).ContactId;
                                   updateContact.Date_of_last_engagement__c = Date.Today();
                                   updateContactList.add(updateContact);
                                }
                       }
                   }
               }
             
            
            }
       
          if(updateContactList.size() > 0)
            update updateContactList;
     
   }
    
    public static void colseTaskValidation(List<Task> validationTaskList) {
        
        System.debug('colseTaskValidation>>>>>>>');
        Constant_AC  constant = new Constant_Ac(); 
        Id wishGrantTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.wishGrantTaskRT).getRecordTypeId();
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        
        Set<Id> conceptTaskParentSet = new Set<Id>();
        List<Task> conceptTask = new List<Task>();
        for(Task checkSubject : validationTaskList) {
            if(checkSubject.subject == 'Wish concept approval1') {
                conceptTaskParentSet.add(checkSubject.WhatId);
                conceptTask.add(checkSubject);
            }
        }
        
        if(conceptTaskParentSet.size() > 0) {
            Map<Id, Case> conceptApprovalMap = new Map<Id, Case>();
            
            for(Case conceptApprovalCheck : [SELECT Id, Status, Sub_Status__c FROM Case WHERE RecordTypeId =: parentWishRecordTypeId AND Id IN : conceptTaskParentSet]) {
                conceptApprovalMap.put(conceptApprovalCheck.Id, conceptApprovalCheck);
            }
            if(conceptApprovalMap.size() > 0) {
                for(Task throwError : conceptTask) {
                    System.debug('FB>>>>>>>>');
                    if(conceptApprovalMap.containsKey(throwError.WhatId)) {
                        System.debug('FB>>>>>>>>1');
                        System.debug(conceptApprovalMap.get(throwError.WhatId).Status);
                        System.debug(conceptApprovalMap.get(throwError.WhatId).Sub_Status__c);
                        if(conceptApprovalMap.get(throwError.WhatId).Status != 'Wish Determined' && conceptApprovalMap.get(throwError.WhatId).Sub_Status__c != 'Within Policy') {
                            System.debug('FB2>>>>>>>>');
                            throwError.addError('Wish Determination is not within the policy');
                        }
                    }
                }
            }
        }
    }
    
}