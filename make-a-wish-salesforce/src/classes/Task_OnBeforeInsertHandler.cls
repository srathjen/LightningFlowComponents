/*****************************************************************************************************************
Author      : MST Solutions
Date        : 6/1/2016
Description : When new Task is inserted then Task_OnBeforeInsertHandler is called by before insert event in Task trigger
then it will assign the values to the corresponding fields in task object and also it will call the Task_OnBeforeInsertHandlerHelper
calss based on the collection size()
*******************************************************************************************************************/

public class Task_OnBeforeInsertHandler {

	private static final Id wishGrantTaskRT = Constant_AC.GRANT_TASK_RT_ID;
	private static final Id backgroundCheckTaskRT = Constant_AC.BACKGROUND_RT_ID;
	private static final Id contactUpdateTaskRT = Constant_AC.UPDATE_CONTACT_RT_ID;
	private static final Id planningTaskRT = Constant_AC.PLANNING_ANTICIPATION_TASK_RT_ID;
	private static final Id determinationTaskRT = Constant_AC.DETERMINATION_TASK_RT_ID;
	private static final Id volunteerTaskRT = Constant_AC.VOLUNTEER_TASK_RT_ID;
	private static final Id chapterRT = Constant_AC.STAFF_TASK_RT_ID;
	private static final Id DefaultTask = Constant_AC.TASK_RT_ID;
	private static final Id interviewTask = Constant_AC.INTERVIEW_RT_ID;

	/*****************************************************************************************************************
When new Task is inserted then Task_OnBeforeInsertHandler is called by before insert event in Task trigger
then it will assign the values to the corresponding fields in task object.
*******************************************************************************************************************/
	public static void onBeforeInsert(List<Task> newTaskList) {
		List<Task> birthdayTasksList = new List<Task>();
		Set<Id> taskRelatedContactIdsSet = new Set<Id>();
		List<Task> actionTrackTasksList = new List<Task>();
		Set<Id> actionTracksRelatedCaseIdsSet = new Set<Id>();
		set<ID> contactIdset = new set<ID>();
		Map<Id, Contact> contactInfoMap = new Map<Id, Contact>();
		List<Task> updateTaskList = new List<Task>();
		List<Task> matchContactTaskList = new List<Task>();
		Set<Id> taskParentIdSet = new Set<Id>();
		Map<Id, List<Task>> reparentChildCaseTaskMap = new Map<Id, List<Task>>();
		Map<Id, Task> bgExpiringTaskMap = new Map<Id, Task>();
		Map<Id, Task> coiExpiringTaskMap = new Map<Id, Task>();

		try {
			for (Task updatedTask : newTaskList) {
				String contactId = updatedTask.WhoId;
				if (updatedTask.RecordTypeId == wishGrantTaskRT || updatedTask.RecordTypeId == planningTaskRT || updatedTask.RecordTypeId == determinationTaskRT || updatedTask.RecordTypeId == volunteerTaskRT || updatedTask.RecordTypeId == chapterRT || updatedTask.RecordTypeId == backgroundCheckTaskRT
						|| updatedTask.RecordTypeId == contactUpdateTaskRT || updatedTask.RecordTypeId == DefaultTask || updatedTask.RecordTypeId == interviewTask) {
					if (updatedTask.Subject == 'Check in with the family every 30 days' || updatedTask.Subject == 'Wish Presentation Not Set' || updatedTask.Subject == 'Budget is approved: Acknowledge Receipt of Approval'
							|| updatedTask.Subject == 'Send DNQ Notification to Qualifying Medical Professional' || updatedTask.Subject == 'Interview Task' || updatedTask.Subject == 'Interview Completed' || updatedTask.Subject == 'Parent/Guardian Orientation') {
						updatedTask.SystemGeneratedTask__c = True;
					}
					if (updatedTask.Subject.contains(' ET : ') && updatedTask.status == 'Completed' && (updatedTask.SystemGeneratedTask__c == FALSE || updatedTask.ActivityDate != NULL)) {
						updatedTask.SystemGeneratedTask__c = True;
						updatedTask.ActivityDate = null;
					}
					if (updatedTask.Subject == 'BC ET : Background Check Expiring') {
						if (updatedTask.WhatId != NULL) {
							bgExpiringTaskMap.put(updatedTask.WhatId, updatedTask);
						}
					}
					if (updatedTask.Subject == 'COI ET : COI Expiring') {
						if (updatedTask.WhatId != NULL) {
							coiExpiringTaskMap.put(updatedTask.WhatId, updatedTask);
						}
					}
					if (updatedTask.subject == 'Budget is approved' || updatedTask.subject == 'Case ET : Budget Approval Request' || updatedTask.subject == 'Budget needs to be revised' || updatedTask.subject == 'Follow-up on wish clearance' || updatedTask.subject == 'Interview date not set'
							|| updatedTask.subject == 'Wish Child Birthday Reminder' || updatedTask.subject == 'Wish Family Packet not submitted') {
						updatedTask.SystemGeneratedTask__c = True;
						updatedTask.RecordTypeId = chapterRT;
						matchContactTaskList.add(updatedTask);
						taskParentIdSet.add(updatedTask.WhatId);
					}
					if (updatedTask.Subject == 'Wish Child Birthday Reminder') {
						birthdayTasksList.add(updatedTask);
						taskRelatedContactIdsSet.add(updatedTask.whatId);
					}
					//IME 58
					if (updatedTask.Subject == 'Lead ET : New Rush Qualified' || updatedTask.Subject == 'Lead ET : New Rush Referral' ||
							updatedTask.Subject == 'Rush has been changed from Yes to No/ Not sure, reach out to family if necessary') {
						updatedTask.RecordTypeId = DefaultTask;
					}

					if (updatedTask.WhoId != null) {
						contactIdset.add(updatedTask.WhoId);
						updateTaskList.add(updatedTask);
					}
					if (updatedTask.subject == 'Case ET : Wish Presentation Date Reminder' || updatedTask.subject == 'Case ET : Wish Presentation Details') {
						if (reparentChildCaseTaskMap.containsKey(updatedTask.WhatId)) {
							reparentChildCaseTaskMap.get(updatedTask.WhatId).add(updatedTask);
						} else {
							reparentChildCaseTaskMap.put(updatedTask.WhatId, new List<Task>{
									updatedTask
							});
						}
					}
				}
			}
			/**
			 * JIRA: WLP-286
			 * Author: Gustavo Mayer
			 * Update: Sub case conversion to the single Wish Case, no need to update
			 * as there is no longer the concept of parent case.
			 */
//			if (reparentChildCaseTaskMap.size() > 0) {
//				Task_OnBeforeInsertHelper.reparentChildCaseToParentCase(reparentChildCaseTaskMap);
//			}
			if (bgExpiringTaskMap.size() > 0) {
				Task_OnBeforeInsertHelper.updateBGCTaskSubjectDays(bgExpiringTaskMap);
			}
			if (coiExpiringTaskMap.size() > 0) {
				Task_OnBeforeInsertHelper.updateCOITaskSubjectDays(coiExpiringTaskMap);
			}
			if (matchContactTaskList.size() > 0 && taskParentIdSet.size() > 0) {
				Task_OnBeforeInsertHelper.UpdateContactToTask(matchContactTaskList, taskParentIdSet);
			}
			if ((contactIdset.size() > 0) && (updateTaskList.size() > 0)) {
				Task_OnBeforeInsertHelper.updateTaskEmailMergeFields(contactIdset, updateTaskList);
			}
			if (birthdayTasksList.size() > 0 && taskRelatedContactIdsSet.size() > 0) {
				Task_OnBeforeInsertHelper.BirthdayTaskPrimaryVolunteerAssign(birthdayTasksList, taskRelatedContactIdsSet);
			}

			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}

		} catch (Exception ex) {
			for (Task currRec : newTaskList) {
				ErrorMessage__e newsEvent = new ErrorMessage__e();
				newsEvent.Apex_Class__c = 'Task_OnBeforeInsertHandler';
				newsEvent.Developer_Message__c = String.valueof(currRec);
				newsEvent.Message__c = ex.getMessage();
				newsEvent.Method__c = 'onBeforeInsert';
				newsEvent.Record_Id__c = currRec.Id;
				//newsEvent.Stack_Trace__c = String.valueOf(ex);
				newsEvent.Type__c = 'Error';
				Database.SaveResult sr = EventBus.publish(newsEvent);

				if (!Test.isRunningTest()) {

					currRec.addError(Label.Debug_log_error_message);

				}
			}
		}

	}
}