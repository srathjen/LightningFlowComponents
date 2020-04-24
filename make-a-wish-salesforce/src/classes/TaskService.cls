/**
 * @description Task Service class
 * @author	Gustavo Mayer, Traction on Demand
 * @createdDate	3-04-2020
 */
public class TaskService {

	private final static Id STAFF_TASK_RECORD_TYPE_ID = Constant_AC.STAFF_TASK_RT_ID;
	private static final String STATUS_COMPLETED = Constant_AC.TASK_STATUS_COMPLETED;
	private static final String STATUS_NOT_STARTED = Constant_AC.TASK_STATUS_NOT_STARTED;
	private static final String STATUS_IN_PROGRESS = Constant_AC.TASK_STATUS_IN_PROGRESS;
	private static final String PRIORITY_NORMAL = Constant_AC.TASK_PRIORITY_NORMAL;
	private static final String DESCRIPTION_RUSH_QUALIFIED = Constant_AC.TASK_DESCRIPTION_RUSH_QUALIFIED;
	private static final String SUBJECT_SEND_WELCOME_LETTER = Constant_AC.TASK_SUBJECT_SEND_WELCOME_LETTER;
	private static final String SUBJECT_RUSH_QUALIFIED = Constant_AC.TASK_SUBJECT_RUSH_QUALIFIED;
	private static final String SUBJECT_RUSH_MODIFIED_NO = Constant_AC.TASK_SUBJECT_RUSH_MODIFIED_NO;
	private static final String TASK_RT_STAFF_LABEL = Constant_AC.TASK_RT_STAFF_LABEL;
	private static final String WISH_BIRTHDAY_SUBJECT = 'Wish Child Birthday Reminder';

	public static Task buildSendWelcomeLetter(Contact contact) {
		return new Task(
				OwnerId = contact.OwnerId,
				SystemGeneratedTask__c = true,
				Subject = SUBJECT_SEND_WELCOME_LETTER,
				WhoId = contact.Id,
				Description = SUBJECT_SEND_WELCOME_LETTER,
				Status = STATUS_IN_PROGRESS,
				ActivityDate = System.today() + 10,
				RecordTypeId = STAFF_TASK_RECORD_TYPE_ID
		);
	}

	/**
	 * Build Rush Task
	 * @param contact
	 * @return Task
	 */
	public static Task buildRush(Contact contact) {
		return new Task(
				Description = DESCRIPTION_RUSH_QUALIFIED,
				Priority = PRIORITY_NORMAL,
				Status = STATUS_COMPLETED,
				Subject = SUBJECT_RUSH_QUALIFIED,
				OwnerId = Label.Salesforce_Support_User_Id,
				ActivityDate = System.today(),
				WhoId = contact.Id
		);
	}

	/**
	 * Create Rush Task
	 * @param leadList
	 */
	public static void createRushTask(List<Lead> leadList) {
		List<Task> newTaskList = new List<Task>();
		for (Lead processLead : leadList) {
			Task newRushTask = new Task(
					Priority = PRIORITY_NORMAL,
					Status = STATUS_NOT_STARTED,
					Subject = SUBJECT_RUSH_MODIFIED_NO,
					OwnerId = processLead.OwnerId,
					ActivityDate = System.today() + 3,
					SystemGeneratedTask__c = true,
					WhoId = processLead.Id);
			newTaskList.add(newRushTask);
		}
		if (!newTaskList.isEmpty()) {
			insert newTaskList;
		}
	}

	/**
	 * Create Lead Task
	 * @param leadMap
	 * @return Save Result
	 */
	public static List<Database.SaveResult> createLeadTask(Set<Id> leadIds) {
		List<Task> newTaskList = new List<Task>();
		for (Lead newLead : [
				SELECT Id, Migrated_Record__c, OwnerId, Owner.UserRole.Name, Status,
						ChapterName__c,ChapterName__r.Name, PD_Condition_Description__c
				FROM Lead
				WHERE Id IN :leadIds
		]) {
			Task newTask = new Task();
			if (newLead.Status == Constant_AC.LEAD_STATUS_INQUIRY) {
				newTask.Subject = Constant_AC.TASK_SUBJECT_NEW_INQUIRY_SUBMITTED;
				newTask.ActivityDate = Date.today().addDays(30);
			}
			if (newLead.Status == Constant_AC.LEAD_STATUS_REFERRED) {
				newTask.Subject = Constant_AC.TASK_SUBJECT_NEW_REFERRAL_SUBMITTED;
				newTask.ActivityDate = Date.today().addDays(10);
			}
			newTask.OwnerId = newLead.OwnerId;
			newTask.RecordTypeId = Constant_AC.STAFF_TASK_RT_ID;
			newTask.WhoId = newLead.Id;
			newTask.Priority = Constant_AC.TASK_PRIORITY_NORMAL;
			newTask.SystemGeneratedTask__c = true;
			newTaskList.add(newTask);
		}
		if (!newTaskList.isEmpty()) {
			return Database.insert(newTaskList, false);
		}
		return new List<Database.SaveResult>();
	}

	/**
	 * Close Lead Tasks
	 * @param leadIds
	 */
	public static void updateCompleted(Set<Id> leadIds) {
		List<Task> taskList = [
				SELECT Id,Status
				FROM Task
				WHERE WhoId IN :leadIds
				AND Status != :STATUS_COMPLETED
		];
		List<Task> updateTask = new List<Task>();
		for (Task processTask : taskList) {
			processTask.Status = STATUS_COMPLETED;
			updateTask.add(processTask);
		}
		update updateTask;
	}

	/**
	* @description	Used to update Background Check Subject based on day difference.
	*
	* @param         Map<Id,Task> bgExpiringTaskMap
	*
	* @author        MST Solutions
	* @createdDate   unknown
	*/
	public static void updateBGCTaskSubjectDays(Map<Id, Task> bgExpiringTaskMap) {
		if (bgExpiringTaskMap == null || bgExpiringTaskMap.isEmpty()) {
			return;
		}

		for (Background_check__c bgInfo : [
				SELECT Id, Date__c, Current__c, Volunteer__c, Volunteer__r.Name
				FROM Background_check__c
				WHERE Current__c = TRUE
				AND Date__c = NEXT_N_DAYS:30
				AND Id IN :bgExpiringTaskMap.keySet()
		]) {
			if (bgExpiringTaskMap.containsKey(bgInfo.Id)) {
				if (bgInfo.Date__c.daysBetween(Date.today()) == -30) {
					bgExpiringTaskMap.get(bgInfo.Id).Subject += ' (30 Days)';
				} else if (bgInfo.Date__c.daysBetween(Date.today()) == -23) {
					bgExpiringTaskMap.get(bgInfo.Id).Subject += ' (23 Days)';
				} else if (bgInfo.Date__c.daysBetween(Date.today()) == -16) {
					bgExpiringTaskMap.get(bgInfo.Id).Subject += ' (16 Days)';
				} else if (bgInfo.Date__c.daysBetween(Date.today()) == -9) {
					bgExpiringTaskMap.get(bgInfo.Id).Subject += ' (9 Days)';
				} else if (bgInfo.Date__c.daysBetween(Date.today()) == -2) {
					bgExpiringTaskMap.get(bgInfo.Id).Subject += ' (2 Days)';
				}

				bgExpiringTaskMap.get(bgInfo.Id).ActivityDate = null;
			}
		}
	}

	/**
	 * @description     Used to update COI Subject based on day difference.
	 *
	 * @param           Map<Id,Task> coiExpiringTaskMap
	 *
	 * @author          MST Solutions
	 * @createdDate     unknown
	 */
	public static void updateCOITaskSubjectDays(Map<Id, Task> coiExpiringTaskMap) {
		if (coiExpiringTaskMap == null || coiExpiringTaskMap.isEmpty()) {
			return;
		}

		for (Conflict_Of_Interest__c coiInfo : [
				SELECT Id, Expiration_Date__c, Current__c, Volunteer_Contact__c, Volunteer_Contact__r.Name
				FROM Conflict_Of_Interest__c
				WHERE Current__c = TRUE
				AND Expiration_Date__c = NEXT_N_DAYS:30
				AND Id IN :coiExpiringTaskMap.keySet()
		]) {
			if (coiExpiringTaskMap.containsKey(coiInfo.Id)) {
				if (coiInfo.Expiration_Date__c.daysBetween(Date.today()) == -30) {
					coiExpiringTaskMap.get(coiInfo.Id).Subject += ' (30 Days)';
				} else if (coiInfo.Expiration_Date__c.daysBetween(Date.today()) == -23) {
					coiExpiringTaskMap.get(coiInfo.Id).Subject += ' (23 Days)';
				} else if (coiInfo.Expiration_Date__c.daysBetween(Date.today()) == -16) {
					coiExpiringTaskMap.get(coiInfo.Id).Subject += ' (16 Days)';
				} else if (coiInfo.Expiration_Date__c.daysBetween(Date.today()) == -9) {
					coiExpiringTaskMap.get(coiInfo.Id).Subject += ' (9 Days)';
				} else if (coiInfo.Expiration_Date__c.daysBetween(Date.today()) == -2) {
					coiExpiringTaskMap.get(coiInfo.Id).Subject += ' (2 Days)';
				}

				coiExpiringTaskMap.get(coiInfo.Id).ActivityDate = null;
			}
		}
	}

	/**
	 * @description     This method is used to fetch the values from associated contact of task and assign with the
	 *                  corresponding task fields to merge with email template.
	 *
	 * @param           Set<Id> volunteerContactIdsSet
	 * @param           List<Task> updatedTaskList
	 *
	 * @author          MST Solutions
	 * @createdDate     unknown
	 */
	public static void updateTaskEmailMergeFields(Set<Id> volunteerContactIdsSet, List<Task> updatedTaskList) {
		if (volunteerContactIdsSet == null || volunteerContactIdsSet.isEmpty() ||
				updatedTaskList == null || updatedTaskList.isEmpty()) {

			return;
		}

		Map<Id, Contact> contactInfoMap = new Map<Id, Contact>();

		if (volunteerContactIdsSet.size() > 0) {
			for (Contact getContactInfo : [
					SELECT Id, Name, Account.Name, Account.Phone, Account.Email__c
					FROM Contact
					WHERE Id IN :volunteerContactIdsSet
			]) {
				if (!contactInfoMap.containsKey(getContactInfo.Id)) {
					contactInfoMap.put(getContactInfo.Id, getContactInfo);
				}
			}
		}

		Contact contact;
		for (Task currRec : updatedTaskList) {
			if (currRec.WhoId != null && contactInfoMap.containsKey(currRec.WhoId)) {
				contact = contactInfoMap.get(currRec.WhoId);

				currRec.Account_Name__c = contact.Account.Name;
				currRec.Account_Phone__c = contact.Account.Phone;
				currRec.Account_Email__c = contact.Account.Email__c;
				currRec.Contact_Name_Hidden__c = contact.Name;
			}
		}
	}

	/**
	 * @description     This method is used to assign the 'Birthday Remainder Task' to primary volunteer.
	 *
	 * @param           List<Task> birthdayTasksList
	 * @param           Set<Id> taskRelatedContactIdsSet
	 *
	 * @author          MST Solutions
	 * @createdDate     unknown
	 */
	public static void birthdayTaskPrimaryVolunteerAssign(List<Task> birthdayTasksList, Set<Id> taskRelatedContactIdsSet) {
		if (birthdayTasksList == null || birthdayTasksList.isEmpty() ||
				taskRelatedContactIdsSet == null || taskRelatedContactIdsSet.isEmpty()) {

			return;
		}

		Set<Id> caseIdsSet = new Set<Id>();
		Map<Id, Id> caseContactIdsMap = new Map<Id, Id>();
		Map<Id, Id> taskRelatedCaseIdsMap = new Map<Id, Id>();

		for (Case caseDetails : [
				SELECT Id, ContactId
				FROM Case
				WHERE Id IN :taskRelatedContactIdsSet
		]) {
			caseIdsSet.add(caseDetails.Id);
			caseContactIdsMap.put(caseDetails.Id, caseDetails.ContactId);
			taskRelatedCaseIdsMap.put(caseDetails.Id, caseDetails.ContactId);
		}

		if (caseIdsSet.isEmpty()) {
			return;
		}

		Map<Id, Id> caseTeamMembersMap = new Map<Id, Id>();

		for (CaseTeamMember memberDetails : [
				SELECT Id, MemberId, ParentId
				FROM CaseTeamMember
				WHERE ParentId IN :caseIdsSet AND TeamRole.Name = :Constant_AC.CASE_TEAM_ROLE_WISH_GRANTER
				ORDER BY CreatedDate ASC
		]) {
			if (!caseTeamMembersMap.containsKey(memberDetails.ParentId)) {
				caseTeamMembersMap.put(memberDetails.ParentId, memberDetails.MemberId);
			}
		}

		if (caseTeamMembersMap.isEmpty()) {
			return;
		}

		for (Task assignTaskOwner : birthdayTasksList) {
			if (caseTeamMembersMap.containsKey(assignTaskOwner.WhatId)) {
				assignTaskOwner.OwnerId = caseTeamMembersMap.get(assignTaskOwner.WhatId);
			}
			if (taskRelatedCaseIdsMap.containsKey(assignTaskOwner.WhatId)) {
				assignTaskOwner.WhoId = taskRelatedCaseIdsMap.get(assignTaskOwner.WhatId);
			}
		}
	}

	public static List<Task> updateOwner(Map<Id, Set<Id>> inActiveOwnersMap,
			Map<Id, Id> activeVolunteerMap, Map<Id, Case> caseOwnerMap, Map<Id, Id> contactUserMap) {
		List<Task> taskOwnerUpdateList = new List<Task>();
		if (inActiveOwnersMap.isEmpty()) {
			return taskOwnerUpdateList;
		}
		for (Task task : [
				SELECT Id, OwnerId, Task_Type__c, WhatId
				FROM Task
				WHERE WhatId IN :inActiveOwnersMap.keySet()
				AND IsClosed = FALSE
		]) {
			if (inActiveOwnersMap.containsKey(task.WhatId)) {
				if (inActiveOwnersMap.get(task.WhatId).contains(contactUserMap.get(task.OwnerId))) {
					if (activeVolunteerMap.containsKey(task.WhatId) && task.Task_Type__c != null) {
						task.OwnerId = activeVolunteerMap.get(task.WhatId);
						taskOwnerUpdateList.add(task);
					} else {
						task.OwnerId = caseOwnerMap.get(task.WhatId).OwnerId;
						taskOwnerUpdateList.add(task);
					}
				}
			}
		}
		update taskOwnerUpdateList;
		return taskOwnerUpdateList;
	}

	public static List<Task> updateBirthday(Map<Id, Id> volunteerMap, Map<Id, Id> contactUserInfoMap) {
		List<Task> tasks = new List<Task>();
		for (Task birthdayTaskInfo : [
				SELECT Id, WhatId, Subject, OwnerId
				FROM Task
				WHERE Subject = :WISH_BIRTHDAY_SUBJECT
				AND WhatId IN :volunteerMap.keySet()
				AND IsClosed = FALSE
				AND RecordType.Name = :TASK_RT_STAFF_LABEL
		]) {
			if (volunteerMap.containsKey(birthdayTaskInfo.WhatId)) {
				if (contactUserInfoMap.containsKey(volunteerMap.get(birthdayTaskInfo.WhatId))) {
					birthdayTaskInfo.OwnerId = contactUserInfoMap.get(volunteerMap.get(birthdayTaskInfo.WhatId));
				}
			}
			birthdayTaskInfo.RecordTypeId = Constant_AC.VOLUNTEER_TASK_RT_ID;
			tasks.add(birthdayTaskInfo);
		}
		update tasks;
		return tasks;
	}
}