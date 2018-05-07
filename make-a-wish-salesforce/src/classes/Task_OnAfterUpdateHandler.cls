/*****************************************************************************************************************
Author      : MST Solutions
Date        : 6/1/2016
Description : When new Task is updated then Task_OnAfterUpdateHandler is called by before update event in Task trigger
then it will assign the value to the corresponding fields and then it will the methods in Task_OnAfterUpdateHandlerHelper
class based on the collection size().
*******************************************************************************************************************/

Public class Task_OnAfterUpdateHandler{
    
    Static Constant_AC  constant = new Constant_Ac();
    Static String wishGrantTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
    Static String backrgroundcheckTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.backgroundRT).getRecordTypeId();
    Static String contactUpdateTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.updateContactRT).getRecordTypeId();
    Static String  planningTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();
    Static String determinationTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
    Static String volunteerTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.volunteerTaskRT).getRecordTypeId();
    Static String chapterRT = Schema.SObjectType.Task.getRecordTypeInfosByName().get(constant.staffTaskRT).getRecordTypeId();
    Static String DefaultTask= Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.taskRT).getRecordTypeId();
    Static String interviewTask = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.interviewRT).getRecordTypeId();
    Static String wishEffectRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishEffectRT).getRecordTypeId();
    Static String diagnosisVerificationRT = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.diagnosisRT).getRecordTypeId();
    Static String wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();     
    Static String wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();    
    Static String wishAssistRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishAssistRT).getRecordTypeId();
    Static String wishGrantRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
    Static String parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
    Static String taskInterviewRecordType = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.interviewRT).getRecordTypeId();
    Static String triainingRecordTypeId = Schema.Sobjecttype.Orientation_Training__c.getRecordTypeInfosByName().get(constant.trainingRT).getRecordTypeId();
    
    /*********************************************************************************************************************
    This method is used to assign the value to the corresponding fields and then it will the methods in Task_OnAfterUpdateHandlerHelper
class based on the collection size().
    **********************************************************************************************************************/
    public static void OnAfterUpdate(Map<Id,Task> newCaseMap,Map<Id,Task> oldCaseMap){
        Set<Id> declinedTaskVolunteerIds = new Set<Id>();
        Set<Id> volunteerIdsSet = new Set<Id>();
        Set<Id> completedTaskParentIdSet = new Set<Id>();
        Map<Id, Task> flightBookTaskMap = new Map<Id, Task>();
        Map<Id, Task> budgetBookTaskMap = new Map<Id, Task>();
        Map<Id, Task> passportRequestMap = new Map<Id, Task>();
        Map<Id,Id> uploadParentTaskIdMap = new Map<Id,Id>();
        Set<Id> wishGrantTaskWhatIdSet = new Set<Id>();
        List<Task> createCheckinTaskList = new List<Task>();
        Set<Id> checkinTaskIdSet = new Set<Id>();
        Map<Id,Task> taskMap = new Map<Id,Task>();
        Set<Id> taskOwnerIds = new Set<Id>();
        Set<Id> caseIds = new Set<Id>();
        Map<Id,Task> followUpTaskMap = new Map<Id,Task>();
        List<Task> validateTaskList = new List<Task>();
        List<Id> leadIdList = new List<Id>();
        Set<Id> followUpTaskOwnerIdSet = new Set<Id>();
        Set<Id> interviewTaskVolunteerIdsSet = new Set<Id>();
        
        for(Task newTask : newCaseMap.values()){
            if(newTask.RecordTypeId == wishGrantTaskRT || newTask.RecordTypeId == planningTaskRT || newTask.RecordTypeId == determinationTaskRT || newTask.RecordTypeId == volunteerTaskRT || newTask.RecordTypeId == chapterRT || newTask.RecordTypeId == backrgroundcheckTaskRT 
               || newTask.RecordTypeId == contactUpdateTaskRT || newTask.RecordTypeId == DefaultTask || newTask.RecordTypeId == interviewTask){ 
                   if(newTask.Status == 'Completed' && oldCaseMap.get(newTask.Id).Status != newTask.Status && newTask.subject == 'Volunteer wish follow-up activities not complete') {
                       followUpTaskMap.put(newTask.WhatId, newTask);
                       followUpTaskOwnerIdSet.add(newTask.OwnerId);
                   }
                   
                   if(newTask.Status == 'Approved' && oldCaseMap.get(newTask.id).Status != 'Approved'){
                       if(newTask.Subject == 'Interview Task' && newTask.WhoId != Null && newTask.RecordTypeId == taskInterviewRecordType ){
                           interviewTaskVolunteerIdsSet.add(newTask.WhoId);
                       }
                   }
                   
                   if(newTask.Status == 'Completed' && oldCaseMap.get(newTask.id).Status != 'Completed')
                   {   
                       if(newTask.whatId != null) {
                           if(String.valueOf(newTask.whatId).startsWith('500'))
                           {
                               taskMap.put(newTask.id,newTask);
                               taskOwnerIds.add(newTask.OwnerId);
                               caseIds.add(newTask.whatId);
                           }
                       }
                   }
                   if(newTask.status=='Completed' && oldCaseMap.get(newTask.Id).Status != newTask.Status && newTask.Subject != 'Volunteer wish follow-up activities not complete') {
                       validateTaskList.add(newTask);
                       completedTaskParentIdSet.add(newTask.WhatId);
                   }
                   if(newTask.Status == 'Completed' && oldCaseMap.get(newTask.Id).Status != newTask.Status && newTask.Task_Type__c == 'Wish Granting') {
                       wishGrantTaskWhatIdSet.add(newTask.WhatId);
                   }
                   if(newTask.Status == 'Completed' && oldCaseMap.get(newTask.Id).Status != newTask.Status && newTask.subject == 'Check in with the family every 30 days') {
                       createCheckinTaskList.add(newTask);
                       checkinTaskIdSet.add(newTask.WhatId);
                   }
                   if(newTask.Status == 'Completed' && (oldCaseMap.get(newTask.Id).Status != newTask.Status && newTask.subject == 'Flights booked')) {
                       flightBookTaskMap.put(newTask.WhatId,newTask);
                   }
                   
                   if(newTask.Status == 'Completed' && (oldCaseMap.get(newTask.Id).Status != newTask.Status && newTask.subject == 'Budget')) {
                       budgetBookTaskMap.put(newTask.WhatId,newTask);
                   }
                   if(newTask.Status == 'Completed' && (oldCaseMap.get(newTask.Id).Status != newTask.Status && newTask.subject == 'Request Passports from family')) {
                       passportRequestMap.put(newTask.WhatId,newTask);
                   }
                   
                   if((newTask.Status == 'Approved'  && oldCaseMap.get(newTask.Id).Status != 'Approved')&& newTask.RecordTypeId ==taskInterviewRecordType )
                   {
                       volunteerIdsSet.add(newTask.WhoId);
                   }
                   if((newTask.Status == 'Declined') && newTask.RecordTypeId ==taskInterviewRecordType && oldCaseMap.get(newTask.Id).Status != newTask.Status){
                       declinedTaskVolunteerIds.add(newTask.WhoId);
                   }
                   
                   //Update the Lead Closed Date.
                   if(newTask.Status == 'Completed' && (oldCaseMap.get(newTask.Id).Status != newTask.Status && newTask.subject == 'Referral DNQ')){
                       leadIdList.add(newTask.whoId);
                   }
               }
        }
        
        if(interviewTaskVolunteerIdsSet.size() > 0){
            Task_OnAfterInsertHelper.updateVolunteerInterviewDate(interviewTaskVolunteerIdsSet, 'update');
        }
        if(followUpTaskMap.size() > 0) {
            Task_OnAfterUpdateHelper.checkFollowUpTask(followUpTaskMap, followUpTaskOwnerIdSet);
        }
        if(taskMap.size() > 0){
            Task_OnAfterUpdateHelper.updateVolunteerRecord(taskMap,taskOwnerIds,caseIds);
        }
        if(wishGrantTaskWhatIdSet.size() > 0) {
            Task_OnAfterUpdateHelper.checkWishGrantTask(wishGrantTaskWhatIdSet);
        }
        if(createCheckinTaskList.size() > 0 && checkinTaskIdSet.size() > 0) {
            Task_OnAfterUpdateHelper.createCheckinRecurrenceTask(createCheckinTaskList, checkinTaskIdSet);
        }
        if(declinedTaskVolunteerIds.size() > 0){
            Task_OnAfterUpdateHelper.UpdateAffiliationStatusAsDeclined(declinedTaskVolunteerIds);
        }
        if(volunteerIdsSet.size() > 0){
            Task_OnAfterUpdateHelper.UpdateAffiliationStatus(volunteerIdsSet);
        }
        if(flightBookTaskMap.size() > 0 || budgetBookTaskMap.size() > 0 || passportRequestMap.size() > 0) {
            Task_OnAfterUpdateHelper.sneakPeekTask(flightBookTaskMap,budgetBookTaskMap, passportRequestMap);
        }
        if(validateTaskList.size() > 0 && completedTaskParentIdSet.size() > 0) {
            Task_OnAfterUpdateHelper.autoCloseTask(validateTaskList,completedTaskParentIdSet);
        }
        if(leadIdList.Size() > 0){
            Task_OnAfterUpdateHelper.updateLeadCloseDate(leadIdList);
        }
    }
}