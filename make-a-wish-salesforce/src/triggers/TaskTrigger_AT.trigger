/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kesavakumar Murugesan
Date        : 6/1/2016
Description : This trigger is used to create tasks after opend task is closed and assign to the wish team member based on roles
and used to change the ownership of the 'Brithday Remainder Task' to the primary volunteer. 
*******************************************************************************************************************/
trigger TaskTrigger_AT on Task (before insert, before update, after insert, after update) {
    Constant_AC  constant = new Constant_Ac();
    //Affiliation status update.
    if(Trigger.isUpdate && Trigger.isAfter){

        Id taskInterviewRecordType = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.interviewRT).getRecordTypeId();
        Id wishGrantTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
        List<Task> statusUpdatedTaskList = new List<Task>();
        Set<Id> taskRelatedCaseIdsSet = new Set<Id>();
        set<Id> volunteerContactSet = new Set<Id>();
        Set<Id> declinedTaskVolunteerIds = new Set<Id>();
        Set<Id> volunteerIdsSet = new Set<Id>();
        Map<Id, Task> flightBookTaskMap = new Map<Id, Task>();
        Map<Id, Task> budgetBookTaskMap = new Map<Id, Task>();
        Map<Id, Task> passportRequestMap = new Map<Id, Task>();
        Map<Id,Id> uploadParentTaskIdMap = new Map<Id,Id>();
        Set<Id> wishGrantTaskWhatIdSet = new Set<Id>();
        String chapterNameDetails;
        List<Task> createCheckinTaskList = new List<Task>();
        Set<Id> checkinTaskIdSet = new Set<Id>();
        Set<Id> completedTaskParentIdSet = new Set<Id>();
        Map<Id,Task> taskMap = new Map<Id,Task>();
        Set<Id> taskOwnerIds = new Set<Id>();
        Set<Id> caseIds = new Set<Id>();
        Map<Id,Task> followUpTaskMap = new Map<Id,Task>();
        List<Task> validateTaskList = new List<Task>();
        Set<Id> followUpTaskOwnerIdSet = new Set<Id>();
        for(Task updatedTask : Trigger.New) {
            if(updatedTask.Status == 'Completed' && updatedTask.isRecurrenceTask__c == false) {
                statusUpdatedTaskList.add(updatedTask);
                taskRelatedCaseIdsSet.add(updatedTask.WhatId);
            }
            
            if(updatedTask.Status == 'Completed' && updatedTask.subject == 'Volunteer wish follow-up activities not complete') {
                followUpTaskMap.put(updatedTask.WhatId, updatedTask);
                followUpTaskOwnerIdSet.add(updatedTask.OwnerId);
            }
            
            if(updatedTask.Status == 'Completed' && Trigger.oldMap.get(updatedTask.id).Status != 'Completed')
            {
                if(String.valueOf(updatedTask.whatId).startsWith('500'))
                {
                    taskMap.put(updatedTask.id,updatedTask);
                    taskOwnerIds.add(updatedTask.OwnerId);
                    caseIds.add(updatedTask.whatId);
                    
                }
            }
            if(updatedTask.status=='Completed' && updatedTask.Subject != 'Volunteer wish follow-up activities not complete') {
                validateTaskList.add(updatedTask);
                completedTaskParentIdSet.add(updatedTask.WhatId);
                
            }
            if(updatedTask.Status == 'Completed' && Trigger.oldMap.get(updatedTask.Id).Status != updatedTask.Status && updatedTask.RecordTypeId == wishGrantTaskRT) {
                wishGrantTaskWhatIdSet.add(updatedTask.WhatId);
            }
            if(updatedTask.Status == 'Completed' && Trigger.oldMap.get(updatedTask.Id).Status != updatedTask.Status && updatedTask.subject == 'Check in with the family every 30 days') {
                createCheckinTaskList.add(updatedTask);
                checkinTaskIdSet.add(updatedTask.WhatId);
            }
            if(updatedTask.Status == 'Completed' && (Trigger.oldMap.get(updatedTask.Id).Status != updatedTask.Status && updatedTask.subject == 'Flights booked')) {
                flightBookTaskMap.put(updatedTask.WhatId,updatedTask);
            }
            
            if(updatedTask.Status == 'Completed' && (Trigger.oldMap.get(updatedTask.Id).Status != updatedTask.Status && updatedTask.subject == 'Budget')) {
                budgetBookTaskMap.put(updatedTask.WhatId,updatedTask);
            }
            if(updatedTask.Status == 'Completed' && (Trigger.oldMap.get(updatedTask.Id).Status != updatedTask.Status && updatedTask.subject == 'Request Passports from family')) {
                passportRequestMap.put(updatedTask.WhatId,updatedTask);
            }
            
            if((updatedTask.Status == 'Approved'  && trigger.oldMap.get(updatedTask.Id).Status != 'Approved')&& updatedTask.RecordTypeId ==taskInterviewRecordType )
            {
                volunteerIdsSet.add(updatedTask.WhoId);
            }
            if((updatedTask.Status == 'Declined') && updatedTask.RecordTypeId ==taskInterviewRecordType ){
                declinedTaskVolunteerIds.add(updatedTask.WhoId);
            }
             if(updatedTask.Status == 'Completed' && (Trigger.oldMap.get(updatedTask.Id).Status != updatedTask.Status && updatedTask.subject == 'Review photos/videos')) {
                 System.debug('Photo OwnerId>>>>>>>>>'+updatedTask.OwnerId);
                 System.debug('Photo WhatId>>>>>>>>>'+updatedTask.WhatId);
                //uploadParentTaskIdMap.put(updatedTask.WhatId,updatedTask.OwnerId);
            }
            
            if(followUpTaskMap.size() > 0) {
                TaskHandler.checkFollowUpTask(followUpTaskMap, followUpTaskOwnerIdSet);
            }
            
        }
        if(taskMap.size() > 0)
        {
           TaskHandler.updateVolunteerRecord(taskMap,taskOwnerIds,caseIds);
        }
        //To check for wish Grant open task
        if(wishGrantTaskWhatIdSet.size() > 0) {
            System.debug('wishGrantTaskWhatIdSet>>>>>>>');
            TaskHandler.checkWishGrantTask(wishGrantTaskWhatIdSet);
        }
        if(createCheckinTaskList.size() > 0 && checkinTaskIdSet.size() > 0) {
            TaskHandler.createCheckinRecurrenceTask(createCheckinTaskList, checkinTaskIdSet);
        }
        if(statusUpdatedTaskList.size()>0) {
            //TaskHandler.CreateNextTask(statusUpdatedTaskList, taskRelatedCaseIdsSet);
        }
        
        if(declinedTaskVolunteerIds.size() > 0){
            TaskHandler.UpdateAffiliationStatusAsDeclined(declinedTaskVolunteerIds);
        }
        
        if(volunteerIdsSet.size() > 0){
            TaskHandler.UpdateAffiliationStatus(volunteerIdsSet);
        }
        
        if(flightBookTaskMap.size() > 0 || budgetBookTaskMap.size() > 0 || passportRequestMap.size() > 0) {
            TaskHandler.sneakPeekTask(flightBookTaskMap,budgetBookTaskMap, passportRequestMap);
        }
        if(uploadParentTaskIdMap.size() > 0) {
            TaskHandler.createUploadTaskForWishOwner(uploadParentTaskIdMap);
        }
        
        if(validateTaskList.size() > 0 && completedTaskParentIdSet.size() > 0) {
            TaskHandler.autoCloseTask(validateTaskList,completedTaskParentIdSet);
        }
    }
    
    // Task Assign to Volunteer and Email Merge Fields update.
    if(Trigger.isBefore && Trigger.isInsert){
        List<Task> birthdayTasksList = new List<Task>();
        Set<Id> taskRelatedContactIdsSet = new Set<Id>();
        List<Task> actionTrackTasksList = new List<Task>();
        Set<Id> actionTracksRelatedCaseIdsSet = new Set<Id>();
        set<ID> contactIdset = new set<ID>();
        Map<Id,Contact> contactInfoMap = new Map<Id,Contact>();
        List<Task> updateTaskList = new List<Task>();
        
        for(Task updatedTask : Trigger.New) {
            string contactId = updatedTask.WhoId;
            if(updatedTask.Subject == 'Wish Child Birthday Reminder') {
                birthdayTasksList.add(updatedTask);
                taskRelatedContactIdsSet.add(updatedTask.whatId);
            }
            
            if(updatedTask.Sort_Order__c != null) {
                actionTrackTasksList.add(updatedTask);
                actionTracksRelatedCaseIdsSet.add(updatedTask.WhatId);
            }
            //if(updatedTask.WhoId != null && contactId.startsWith('003') ){
            if(updatedTask.WhoId != null){
                contactIdset.add(updatedTask.WhoId);
                updateTaskList.add(updatedTask);
            }
            
        }
        
        if((contactIdset.size()>0) && (updateTaskList.size()>0)){
            TaskHandler.updateTaskEmailMergeFields(contactIdset,updateTaskList);
        }
        
        if(birthdayTasksList.size()>0 && taskRelatedContactIdsSet.size()>0) {
            TaskHandler.BirthdayTaskPrimaryVolunteerAssign(birthdayTasksList,taskRelatedContactIdsSet);
        }
        if(actionTrackTasksList.size()>0 && actionTracksRelatedCaseIdsSet.size()>0) {
            TaskHandler.TaskAssignmentToVolunteer(actionTrackTasksList,actionTracksRelatedCaseIdsSet);
        }
    }
    
    // Field validation and updating mail merge fields.
    if(Trigger.isUpdate && Trigger.isBefore){
        Id wishGrantedRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId(); 
        set<ID> contactIdset = new set<ID>();
        Map<Id,Contact> contactInfoMap = new Map<Id,Contact>();
        List<Task> updateTaskList = new List<Task>();
        Set<Id> checkInTaskParentIdsSet = new Set<Id>();
        Map<Id,id> caseInfoMap=new Map<Id,id>();
        List<Task> validateTaskList = new List<Task>();
        Set<Id> completedTaskParentIdSet = new Set<Id>();
        for(Task currRec : Trigger.new){ 
            if(currRec.Subject == 'Check in with the family every 30 days' && currRec.Status == 'Completed') {
                checkInTaskParentIdsSet.add(currRec.WhatId);
            }
            string id = currRec.WhoId;
            if(currRec.Confirmed_Date__c != Null && Trigger.oldMap.get(currRec.id).Confirmed_Date__c  == Null)
                currRec.Status = 'Scheduled';
            if(currRec.Confirmed_Date__c != Null && CurrRec.Confirmed_Time__c == Null) 
                currRec.addError('Please Enter Confirmed Time');
            if(currRec.Confirmed_Date__c == Null && CurrRec.Confirmed_Time__c != Null) 
                currRec.addError('Please Enter Confirmed Date');
            if(currREc.Confirmed_Date__c != Null && currRec.Confirmed_Date__c <= Date.Today())
                currRec.addError('Confirm Date should be greater than Today');
            if(currREc.Confirmed_Date__c != Null && currRec.venue__c == Null)
                currRec.addError('Please Enter Venue');
            if(currRec.Availability_Time_Other1__c != Null && currRec.Available_Time1__c != 'Other')
            {
                currRec.Availability_Time_Other1__c = '';
            }
            if(currRec.Availability_Time_Other2__c != Null && currRec.Available_Time2__c != 'Other')
            {
                currRec.Availability_Time_Other2__c = '';
            }
            if(currRec.Availability_Time_Other3__c != Null && currRec.Available_Time3__c != 'Other')
            {
                currRec.Availability_Time_Other3__c = '';
            }
            
            if(currRec.WhoId != null && id.startsWith('003') ){
                contactIdset.add(currRec.WhoId);
                updateTaskList.add(currRec);
            }
            /********** Closure Rules *********/
             if(currRec.status=='completed' && currRec.subject=='wish presentation date entered'){
                 caseInfoMap.put(currRec.id,currRec.whatid);
            }
            
            if(currRec.status=='Completed') {
                validateTaskList.add(currRec);
                
                
            }
            
        }
        if(validateTaskList.size() > 0) {
            TaskHandler.colseTaskValidation(validateTaskList);
        }
        if((contactIdset.size()>0) && (updateTaskList.size()>0)){
            TaskHandler.updateTaskEmailMergeFields(contactIdset,updateTaskList);
        }
        
        if(checkInTaskParentIdsSet.size() > 0 ) {
            TaskHandler.updateCheckinDate(checkInTaskParentIdsSet);
        }
        if(caseInfoMap.size() >0){
            map<id,case> caseMap=new Map<id,case>([SELECT id from case where Presentation_Date__c=:Null and Id IN:caseInfoMap.values() and  RecordTypeId=:wishGrantedRecordTypeId]);
            
            for(Task t:trigger.new){
                if(caseMap.containsKey(caseInfoMap.get(t.id))){
                    t.adderror('error');
                }
            }
        }
        
       
    }
}