/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kesavakumar Murugesan
Date        : 6/1/2016
Description : This trigger is used to create tasks after opend task is closed and assign to the wish team member based on roles
and used to change the ownership of the 'Brithday Remainder Task' to the primary volunteer. 
*******************************************************************************************************************/
trigger TaskTrigger_AT on Task (before insert, before update, after insert, after update) {
    
    //Affiliation status update.
    if(Trigger.isUpdate && Trigger.isAfter){
        Constant_AC  constant = new Constant_Ac(); 
        Id taskInterviewRecordType = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.interviewRT).getRecordTypeId();
        List<Task> statusUpdatedTaskList = new List<Task>();
        Set<Id> taskRelatedCaseIdsSet = new Set<Id>();
        set<Id> volunteerContactSet = new Set<Id>();
        Set<Id> declinedTaskVolunteerIds = new Set<Id>();
        Set<Id> volunteerIdsSet = new Set<Id>();
        String chapterNameDetails;
        for(Task updatedTask : Trigger.New) {
            if(updatedTask.Status == 'Completed' && updatedTask.isRecurrenceTask__c == false) {
                statusUpdatedTaskList.add(updatedTask);
                taskRelatedCaseIdsSet.add(updatedTask.WhatId);
            }
            if((updatedTask.Status == 'Approved'  && trigger.oldMap.get(updatedTask.Id).Status != 'Approved')&& updatedTask.RecordTypeId ==taskInterviewRecordType )
            {
                volunteerIdsSet.add(updatedTask.WhoId);
            }
            if((updatedTask.Status == 'Declined') && updatedTask.RecordTypeId ==taskInterviewRecordType ){
                declinedTaskVolunteerIds.add(updatedTask.WhoId);
            }
            
        }
        if(statusUpdatedTaskList.size()>0) {
            TaskHandler.CreateNextTask(statusUpdatedTaskList, taskRelatedCaseIdsSet);
        }
        
        if(declinedTaskVolunteerIds.size() > 0){
            TaskHandler.UpdateAffiliationStatusAsDeclined(declinedTaskVolunteerIds);
        }
        
        if(volunteerIdsSet.size() > 0){
            TaskHandler.UpdateAffiliationStatus(volunteerIdsSet);
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
            if(updatedTask.WhoId != null && contactId.startsWith('003') ){
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
        set<ID> contactIdset = new set<ID>();
        Map<Id,Contact> contactInfoMap = new Map<Id,Contact>();
        List<Task> updateTaskList = new List<Task>();
        for(Task currRec : Trigger.new){ 
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
            
        }
        if((contactIdset.size()>0) && (updateTaskList.size()>0)){
            TaskHandler.updateTaskEmailMergeFields(contactIdset,updateTaskList);
        }
    }
}