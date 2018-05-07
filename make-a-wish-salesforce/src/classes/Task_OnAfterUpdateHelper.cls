/*****************************************************************************************************************
Author      : MST Solutions
Date        : 6/1/2016
Description : When new Task is updated then Task_OnAfterUpdateHelper is called by Task_OnAfterUpdateHandler
then it will call the corresponding methods from Task_OnAfterUpdateHandler.
******************************************************************************************************************/
Public class Task_OnAfterUpdateHelper{
    
   Static Constant_AC  constant = new Constant_Ac();
   Static String wishGrantTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
   Static String  planningTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();
   Static String determinationTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
   Static String volunteerTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.volunteerTaskRT).getRecordTypeId();
   Static String chapterRT = Schema.SObjectType.Task.getRecordTypeInfosByName().get(constant.staffTaskRT).getRecordTypeId();
   Static String wishEffectRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishEffectRT).getRecordTypeId();
   Static String diagnosisVerificationRT = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.diagnosisRT).getRecordTypeId();
   Static String wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();     
   Static String wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();    
   Static String wishAssistRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishAssistRT).getRecordTypeId();
   Static String wishGrantRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
   Static String parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
   Static String taskInterviewRecordType = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.interviewRT).getRecordTypeId();
   Static String triainingRecordTypeId = Schema.Sobjecttype.Orientation_Training__c.getRecordTypeInfosByName().get(constant.trainingRT).getRecordTypeId();
     
     /************************************************
     Check volunteer followup task.
     ************************************************/
     public  static void checkFollowUpTask(Map<Id, Task> followUpTaskMap, Set<Id> followUpTaskOwnerId) {
        Set<Id> communityUserIdSet = new Set<Id>();
        Set<Id> openTaskIdSet = new Set<Id>();
        Set<Id> ownerIdSet = new Set<Id>();
        for(CaseTeamMember caseTeamMem : [SELECT ParentId,MemberId,TeamRoleId,TeamRole.Name,Parent.RecordTypeId FROM CaseTeamMember WHERE TeamRole.Name = 'Wish Granter' AND ParentId IN : followUpTaskMap.keySet()
                                          AND Parent.RecordTypeId =: parentWishRecordTypeId  ]) {
            ownerIdSet.add(caseTeamMem.MemberId);
        }
        
        for(Task existingTask : [SELECT Id, WhatId, OwnerId FROM Task WHERE WhatId IN : followUpTaskMap.keySet() AND isClosed = false AND OwnerId IN : ownerIdSet]) {
            openTaskIdSet.add(existingTask.WhatId);
        }
        for(Task checkOpenTask : followUpTaskMap.values()) {
            if(openTaskIdSet.contains(checkOpenTask.WhatId)) {
                checkOpenTask.addError('Please close other follow up task before closing this task');
            }
        }
    }
    
    /***********************************************************************************************
    This method is used to update the volunteer record for tracing the last engagement date.
    ************************************************************************************************/
    public static void updateVolunteerRecord(Map<Id,Task> taskMap,Set<Id> ownerIds, Set<Id> caseIds)
    {
        Map<Id,User> volunteerMap = new Map<Id,User>();
        Map<Id, Set<Id>> caseTeamMemberMap = new Map<Id, Set<Id>>();
        List<Contact> updateContactList = new List<Contact>();
        for(CaseTeamMember currMemb : [SELECT id,ParentId,MemberId,Parent.RecordTypeId FROM CaseTeamMember WHERE ParentId = :caseIds AND TeamRole.Name = 'Wish Granter' AND Parent.RecordTypeId =: parentWishRecordTypeId])
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
    
    /***************************************
    Volunteer wish granted task check.
    ****************************************/
    Public static void checkWishGrantTask(Set<Id> wishGrantTaskWhatIdSet) {
        List<Case> wishGrankClosedWishList = new List<Case>();
        Map<Id,Case> parentWishMap = new Map<Id,Case>([SELECT Id, isWishGrantTasksClosed__c FROM Case WHERE Id IN : wishGrantTaskWhatIdSet AND RecordTypeId =: parentWishRecordTypeId  AND isClosed = FALSE]);
        List<Task> wishGrantOpenTaskCheckList = [SELECT Id FROM Task WHERE IsClosed = FALSE AND RecordTypeId =: wishGrantTaskRT];
        Set<Id> childTaskExistParentIdSet = new Set<Id>();
        
        for(AggregateResult agg : [SELECT count(Id) recCount, WhatId parentWishId FROM Task WHERE WhatId IN : wishGrantTaskWhatIdSet  AND isClosed = FALSE GROUP BY WhatId]) {
            
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
    
    /*********************************************************************************************************************************************
    This methode is used to create a Checkin with famil task for every 30 days after the previous task is completed untill the case is completed.
    ***********************************************************************************************************************************************/
    public static void createCheckinRecurrenceTask(List<Task> createCheckinTaskList, Set<Id> checkinTaskIdSet){
        List<Task> newRecTaskList = new List<Task>();
        Map<Id,Case> parentCaseMap = new Map<Id,Case>();
        List<Case> updateCheckinDate = new List<Case>();
        
        for(Case checkinTaskCase : [SELECT Id,CheckedInFamily__c,Status,ParentId FROM Case WHERE RecordTypeId = :parentWishRecordTypeId AND Id IN :checkinTaskIdSet]) {
            parentCaseMap.put(checkinTaskCase.Id, checkinTaskCase);
        }
        for(Task recCheckinTask : createCheckinTaskList) {
            if((parentCaseMap.containsKey(recCheckinTask.WhatId) && (parentCaseMap.get(recCheckinTask.WhatId).Status != 'Granted' && parentCaseMap.get(recCheckinTask.WhatId).Status != 'Completed' && parentCaseMap.get(recCheckinTask.WhatId).Status != 'Closed' && parentCaseMap.get(recCheckinTask.WhatId).Status != 'DNQ' && parentCaseMap.get(recCheckinTask.WhatId).Status != 'Hold'))) {
                Task newSubTask = new Task();
                newSubTask.Subject = recCheckinTask.Subject;
                newSubTask.ActivityDate = System.Today() + 30;
                newSubTask.WhatId = recCheckinTask.WhatId;
                newSubTask.Task_Type__c = recCheckinTask.Task_Type__c;
                newSubTask.WhoId = recCheckinTask.WhoId;
                newSubTask.SystemGeneratedTask__c = true;
                newSubTask.RecordTypeId = volunteerTaskRT;
                if(recCheckinTask.OwnerId != Null) {
                    newSubTask.OwnerId = recCheckinTask.OwnerId;
                }
                newRecTaskList.add(newSubTask);
                updateCheckinDate.add(parentCaseMap.get(recCheckinTask.WhatId));
            }
        }
        if(newRecTaskList.size() > 0) {
            insert newRecTaskList;
        }
        if(updateCheckinDate.size() > 0) {
            update updateCheckinDate;
        }
    }
    
    /*********************************************************************************************************
    This method is used to update the Affiliation status to 'Declined' when the task status is 'Declined'.
    **********************************************************************************************************/
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
    /********************************************************************
    Used to update Affiliation Status when the created task is declined.
    *********************************************************************/
    public static void UpdateAffiliationStatus(Set<Id> volunteerContactSet)
    {
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
    /*********************************************
    For creating sneakpeek task for chapter staff
    **********************************************/
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
    
    /**************************************
    Below method is for sprint 12 ticket
    **************************************/
    public static void autoCloseTask(List<Task> closeTaskList, Set<Id> closeTaskParentIdsSet) {
        Set<Id> caseTeamMemberSet = new Set<Id>();
        for(CaseTeamMember caseTeamMem : [SELECT ParentId, MemberId, TeamRoleId, TeamRole.Name FROM CaseTeamMember WHERE TeamRole.Name = 'Wish Granter' AND ParentId IN : closeTaskParentIdsSet]) {
            caseTeamMemberSet.add(caseTeamMem.MemberId);
        }
        
        if(closeTaskParentIdsSet.size() > 0) {
            Map<Id, Integer> taskCount = new Map<Id, Integer>();
            for(AggregateResult aggr : [SELECT Count(Id) recCount,  WhatId parentRecId FROM Task WHERE WhatId IN : closeTaskParentIdsSet AND Subject != 'Volunteer wish follow-up activities not complete' AND status != 'Completed' AND OwnerId IN : caseTeamMemberSet  GROUP BY WhatId] ) {
                taskCount.put((Id)aggr.get('parentRecId'), (Integer)aggr.get('recCount'));
            }
            
            Set<Id> closeFolowupTaskIdSet = new Set<Id>();
            for(Id parentId : closeTaskParentIdsSet) {
                if(!taskCount.containsKey(parentId)) {
                    closeFolowupTaskIdSet.add(parentId);
                }
            }
            
            if(closeFolowupTaskIdSet.size() > 0) {
                List<Task> closeFolowUpTaskList = new List<Task>();
                for(Task closeFollowUpTask : [SELECT Id FROM Task WHERE WhatId IN : closeFolowupTaskIdSet AND Subject = 'Volunteer wish follow-up activities not complete']) {
                    closeFollowUpTask.Status = 'Completed';
                    closeFolowUpTaskList.add(closeFollowUpTask);
                }
                if(closeFolowUpTaskList.size() > 0) {
                    update closeFolowUpTaskList;
                }
            }
        } 
    }
    
    /***********************************
    Update the Lead Closed Date.
    ************************************/
    public static void updateLeadCloseDate(List<Id> leadIdList){
        List<Lead> updateLeadList = new List<Lead>();
        
        for(Lead currLead : [SELECT Id,Closed_Date__C FROM Lead WHERE Id IN :leadIdList]){
            currLead.Closed_Date__c = System.Today();
            updateLeadList.add(currLead);
        }
        if(updateLeadList.Size() > 0)
            Update updateLeadList;
    }   
}