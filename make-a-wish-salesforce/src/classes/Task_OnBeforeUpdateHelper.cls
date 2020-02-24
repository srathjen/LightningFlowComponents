/*****************************************************************************************************************
Author      : MST Solutions
Date        : 6/1/2016
Description : When new Task is updated  then Task_OnBeforeUpdateHelper is called by Task_OnBeforeUpdateHandler
then it will call the corresponding methods in this class.
*******************************************************************************************************************/

public class Task_OnBeforeUpdateHelper {

	private final static Id wishRecordTypeId = Constant_AC.WISH_RT_ID;
	private final static Id wishGrantTaskRT = Constant_AC.GRANT_TASK_RT_ID;

	/******************************************************************************************************
	This method is used to prevent volunteer to close the task when the wish presentation date is not set.
	*******************************************************************************************************/
	public static void closeTaskValidation(List<Task> validationTaskList) {
		Set<Id> conceptTaskParentSet = new Set<Id>(); //Holds parent Id for Concept Task
		Set<Id> wishNotClosedParentIdSet = new Set<Id>(); //Holds parent Id for Wish Not Closed Task
		Set<Id> presentationParentIdSet = new Set<Id>(); //Holds parent Id for Presentation Close Task
		List<Task> conceptTask = new List<Task>(); // Holds Concept Task List
		List<Task> wishPresentationTaskList = new List<Task>(); // Holds Presentation Date Task List
		List<Task> wishNotClosedTaskList = new List<Task>(); // Holds Wish Not Closed Task List
		Map<Id, Case> conceptApprovalMap = new Map<Id, Case>();
		Map<Id, Date> presentationCaseMap = new Map<Id, Date>();
		Set<Id> openCaseIdSet = new Set<Id>();

		//Used to split task based on subject
		for (Task checkSubject : validationTaskList) {
			if (checkSubject.Subject == 'Wish concept approval') {
				conceptTaskParentSet.add(checkSubject.WhatId);
				conceptTask.add(checkSubject);
			} else if (checkSubject.Subject == 'Wish Presentation not set') {
				wishPresentationTaskList.add(checkSubject);
				presentationParentIdSet.add(checkSubject.WhatId);
			} else if (checkSubject.Subject == 'Wish not closed') {
				wishNotClosedParentIdSet.add(checkSubject.WhatId);
				wishNotClosedTaskList.add(checkSubject);
			}
		}

		if (conceptTaskParentSet.size() > 0) {
			for (Case conceptApprovalCheck : [
					SELECT Id, Status, Sub_Status__c
					FROM Case
					WHERE RecordTypeId = :wishRecordTypeId
					AND Id IN :conceptTaskParentSet
			]) {
				conceptApprovalMap.put(conceptApprovalCheck.Id, conceptApprovalCheck);
			}
			if (conceptApprovalMap.size() > 0) {
				for (Task throwError : conceptTask) {
					if (conceptApprovalMap.containsKey(throwError.WhatId)) {
						/**
						 * WLP-428
						 * Deprecating Sub Status when Status is Wish Determined
						 */
						if (conceptApprovalMap.get(throwError.WhatId).Status != 'Wish Determined'
//								&& conceptApprovalMap.get(throwError.WhatId).Sub_Status__c != 'Within Policy'
								) {
							throwError.addError('Wish Determination is not within the policy');
						}
					}
				}
			}
		}
/*
		if (presentationParentIdSet.size() > 0) {
			for (Case parentCasePresentationDateCheck : [
					SELECT Id, Presentation_Date__c, RecordTypeId, ParentId
					FROM Case
					WHERE ParentId IN :presentationParentIdSet
					AND Presentation_Date__c = NULL
					AND RecordTypeId = :wishGrantTaskRT
			]) {
				presentationCaseMap.put(parentCasePresentationDateCheck.ParentId,
						parentCasePresentationDateCheck.Presentation_Date__c);
			}

			if (presentationCaseMap.size() > 0) {
				for (Task presentationValidate : wishPresentationTaskList) {
					if (presentationCaseMap.containsKey(presentationValidate.WhatId)) {
						presentationValidate.addError('Please enter presentation date before closing this task');
					}
				}
			}
		}
*/
		if (wishNotClosedParentIdSet.size() > 0) {
			for (Case wishStatusCheck : [
					SELECT Id, Status, RecordTypeId
					FROM Case
					WHERE Id IN :wishNotClosedParentIdSet
					AND (Status != 'Completed'
					OR Status != 'Closed')
					AND RecordTypeId = :wishRecordTypeId
			]) {
				openCaseIdSet.add(wishStatusCheck.Id);
			}

			if (openCaseIdSet.size() > 0) {
				for (Task preventTaskClose : wishNotClosedTaskList) {
					if (openCaseIdSet.contains(preventTaskClose.WhatId)) {
						preventTaskClose.addError('Please close the wish before closing this task');
					}
				}
			}
		}
	}
	/************************************************************************************************
	This method is used to fetch the values from associated contact of task and assign with the
	corresponding task fields to merge with email template
	*************************************************************************************************/
	public static void updateTaskEmailMergeFields(Set<Id> volunteerConatctIdsSet, List<Task> updatedTaskList) {
		Map<Id, Contact> contactInfoMap = new Map<Id, Contact>();

		if (volunteerConatctIdsSet.size() > 0) {
			for (Contact getContactInfo : [
					SELECT Id, Name, Account.Name, Account.Phone, Account.Email__c
					FROM Contact
					WHERE Id IN:volunteerConatctIdsSet
			]) {
				if (!contactInfoMap.containsKey(getContactInfo.Id)) {
					contactInfoMap.put(getContactInfo.Id, getContactInfo);
				}
			}
		}
		for (Task currRec : updatedTaskList) {
			if (currRec.WhoId != null && contactInfoMap.containsKey(currRec.WhoId)) {
				currRec.Account_Name__c = contactInfoMap.get(currRec.WhoId).Account.Name;
				currRec.Account_Phone__c = contactInfoMap.get(currRec.WhoId).Account.Phone;
				currRec.Account_Email__c = contactInfoMap.get(currRec.WhoId).Account.Email__c;
				currRec.Contact_Name_Hidden__c = contactInfoMap.get(currRec.WhoId).Name;
			}
		}
	}
}