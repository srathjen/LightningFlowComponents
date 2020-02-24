/*****************************************************************************************************************
Author      : MST Solutions
Date        : 6/1/2016
Description : When new Task is updated  then Task_OnBeforeUpdateHandler is called by before update event in Task trigger
then it will assign the values to the corresponding fields and it will call the Task_OnBeforeUpdateHandleHelper class
based on the collection size().
*******************************************************************************************************************/
public class Task_OnBeforeUpdateHandler {

	private final static Id wishGrantTaskRT = Constant_AC.GRANT_TASK_RT_ID;
	private final static Id backgroundCheckTaskRT = Constant_AC.BACKGROUND_RT_ID;
	private final static Id contactUpdateTaskRT = Constant_AC.UPDATE_CONTACT_RT_ID;
	private final static Id planningTaskRT = Constant_AC.PLANNING_ANTICIPATION_TASK_RT_ID;
	private final static Id determinationTaskRT = Constant_AC.DETERMINATION_TASK_RT_ID;
	private final static Id volunteerTaskRT = Constant_AC.VOLUNTEER_TASK_RT_ID;
	private final static Id chapterRT = Constant_AC.STAFF_TASK_RT_ID;
	private final static Id DefaultTask = Constant_AC.TASK_RT_ID;
	private final static Id interviewTask = Constant_AC.INTERVIEW_RT_ID;

	/**********************************************************************************************************************
	This method will assign the values to the corresponding fields and it will call the Task_OnBeforeUpdateHandleHelper class
based on the collection size().
*****************************************************************************************************************************/
	public static void OnBeforeUpdate(Map<Id, Task> newTaskMap, Map<Id, Task> oldTaskMap) {
		List<Task> validateTaskList = new List<Task>();
		Set<Id> contactIdset = new Set<Id>();
		List<Task> updateTaskList = new List<Task>();
		Map<Id, Id> caseInfoMap = new Map<Id, Id>();
		for (Task newTask : newTaskMap.values()) {
			String id = newTask.WhoId;
			if (newTask.RecordTypeId == wishGrantTaskRT || newTask.RecordTypeId == planningTaskRT
					|| newTask.RecordTypeId == determinationTaskRT || newTask.RecordTypeId == volunteerTaskRT
					|| newTask.RecordTypeId == chapterRT || newTask.RecordTypeId == backgroundCheckTaskRT
					|| newTask.RecordTypeId == contactUpdateTaskRT || newTask.RecordTypeId == DefaultTask
					|| newTask.RecordTypeId == interviewTask) {
				if (newTask.Confirmed_Date__c != null && oldTaskMap.get(newTask.Id).Confirmed_Date__c == null)
					newTask.Status = 'Scheduled';
				if (newTask.Confirmed_Date__c != null && newTask.Confirmed_Time__c == null)
					newTask.addError('Please Enter Confirmed Time');
				if (newTask.Confirmed_Date__c == null && newTask.Confirmed_Time__c != null)
					newTask.addError('Please Enter Confirmed Date');
				if (newTask.Confirmed_Date__c != null && newTask.Confirmed_Date__c < Date.today()
						&& newTask.Confirmed_Date__c != oldTaskMap.get(newTask.Id).Confirmed_Date__c)
					newTask.addError('Confirm Date should be greater than Today');
				if (newTask.Confirmed_Date__c != null && newTask.Venue__c == null)
					newTask.addError('Please Enter Venue');
				if (newTask.Availability_Time_Other1__c != null && newTask.Available_Time1__c != 'Other') {
					newTask.Availability_Time_Other1__c = '';
				}
				if (newTask.Subject.contains(' ET : ') && newTask.Status == 'Completed'
						&& (newTask.SystemGeneratedTask__c == false || newTask.ActivityDate != null)) {
					newTask.SystemGeneratedTask__c = true;
					newTask.ActivityDate = null;
				}
				if (newTask.Availability_Time_Other2__c != null && newTask.Available_Time2__c != 'Other') {
					newTask.Availability_Time_Other2__c = '';
				}
				if (newTask.Availability_Time_Other3__c != null && newTask.Available_Time3__c != 'Other') {
					newTask.Availability_Time_Other3__c = '';
				}
				if (newTask.Status == 'Completed' && oldTaskMap.get(newTask.Id).Status != newTask.Status) {
					validateTaskList.add(newTask);
				}
				if (newTask.WhoId != null && id.startsWith('003') && oldTaskMap.get(newTask.Id).WhoId != newTask.WhoId) {
					contactIdset.add(newTask.WhoId);
					updateTaskList.add(newTask);
				}
				/********** Closure Rules *********/
				if (newTask.Status == 'Completed' && oldTaskMap.get(newTask.Id).Status != newTask.Status
						&& newTask.Subject == 'wish presentation date entered') {
					caseInfoMap.put(newTask.Id, newTask.WhatId);
				}
			}
		}
		if (validateTaskList.size() > 0) {
			Task_OnBeforeUpdateHelper.closeTaskValidation(validateTaskList);
		}
		if ((contactIdset.size() > 0) && (updateTaskList.size() > 0)) {
			Task_OnBeforeUpdateHelper.updateTaskEmailMergeFields(contactIdset, updateTaskList);
		}
	}
}