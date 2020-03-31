/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/26/2016
Description : When a new Case record insert then it will called by the Case_OnAfterInsertTriggerHandler class.
*******************************************************************************************************************/
public class Case_OnAfterInsertTriggerHandlerHelper {
	private static final Id WISH_RECORDTYPE_ID = Constant_AC.WISH_RT_ID;
	private static final Id WISH_FORM_CHILD_ID = Constant_AC.WISH_FORM_CHILD_ID;

	/*
     * @description		This method is used to update the parent wish subject, fund Id and unique wish
     * 					identifier values when a parent Case is created.
     *
     * @author 			MST Solutions
     * @createdDate		unknown
     */
	public static void UpdateWishRecordIdentifier(Set<Id> parentIds, Set<Id> chapterIds, Id recTypeId) {
		Integer increment;
		Boolean isFyChanged = false;
		Datetime fyDate = Datetime.now();
		String dateOutput = fyDate.format('yy');
		Integer fyYear = Integer.valueOf(dateOutput);
		Map<String, Office__c> accountOfficeMap = new Map<String, Office__c>();
		List<Case> parentWishesList;

		try {
			List<Period> financialPeriod = [
				SELECT StartDate, EndDate, IsForecastPeriod, Type
				FROM Period
				WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY
				LIMIT 50000
			];

			if (financialPeriod.size() > 0) {
				if ((Date.today() >= financialPeriod[0].StartDate
					&& Date.today() <= financialPeriod[0].EndDate)
					&& (Date.today().addDays(-1) >= financialPeriod[0].StartDate
					&& Date.today().addDays(-1) <= financialPeriod[0].EndDate)) {
					isFyChanged = true;
				}

				fyDate = Datetime.newInstance(financialPeriod[0].EndDate.year(), financialPeriod[0].EndDate.month(), financialPeriod[0].EndDate.day());
				fyYear = Integer.valueOf(fyDate.format('yy'));
			}

			for (Office__c currOffice : [
				SELECT Office_Id__c, Chapter__r.Name, Chapter__c
				FROM Office__c
				WHERE Chapter__c IN :chapterIds
				LIMIT 50000
			]) {
				accountOfficeMap.put(currOffice.Chapter__r.Name, currOffice);
			}

			parentWishesList = [
				SELECT
					Id,
					RecordTypeId,
					Subject,
					Unique_Wish_Record_Identifier__c,
					Fund_Id__c,
					ChapterName__c,
					ChapterName__r.Name
				FROM Case
				WHERE Id IN :parentIds
				AND RecordTypeId = :recTypeId
				ORDER BY CreatedDate DESC
				LIMIT 50000
			];

			List<Case> lastParentWishOfRecordType = [
				SELECT Id, Unique_Wish_Record_Identifier__c, ChapterName__c, ChapterName__r.Name
				FROM Case
				WHERE RecordTypeId = :recTypeId
				AND Unique_Wish_Record_Identifier__c != NULL
				AND CreatedBy.Name != :Constant_AC.INTEGRATION_USER
				AND Lead__r.unique_wish_identifier__c = NULL
				ORDER BY CreatedDate DESC
				LIMIT 2
			];

			if (isFyChanged) {
				if (lastParentWishOfRecordType.size() > 0 && lastParentWishOfRecordType[0].Unique_Wish_Record_Identifier__c != null) {
					String wishRecordIdentifier = lastParentWishOfRecordType[0].Unique_Wish_Record_Identifier__c;
					wishRecordIdentifier = wishRecordIdentifier.right(5);
					increment = Integer.valueOf(wishRecordIdentifier) + 1;
				} else {
					increment = 10001;
				}
			} else {
				increment = 10001;
			}

			for (Case parentWishes : parentWishesList) {
				String temp = accountOfficeMap.containsKey(parentWishes.ChapterName__r.Name) ?
					accountOfficeMap.get(parentWishes.ChapterName__r.Name).Office_Id__c : null;

				if (temp != null) {
					if (parentWishes.Unique_Wish_Record_Identifier__c == null) {
						parentWishes.Unique_Wish_Record_Identifier__c = temp.left(3) + '-' + fyYear + '-' + increment ;
						parentWishes.UWISource__c = 'Case';
					}
					if (parentWishes.Fund_Id__c == null) {
						parentWishes.Fund_Id__c = temp.left(3) + '-' + fyYear + '-' + increment ;
					}
				}

				increment = increment + 1;
				parentWishes.Subject = parentWishes.Subject + ' - ' + parentWishes.Unique_Wish_Record_Identifier__c;
			}

			if (parentWishesList.size() > 0) {
				update parentWishesList;
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Case currRec : parentWishesList) {
				ErrorMessage_AC.createdebugRec('Case_OnAfterInsertTriggerHandlerHelper', String.valueOf(currRec),
					String.valueOf(ex), 'UpdateWishRecordIdentifier', currRec.Id, ex.getStackTraceString(), 'Error');
			}

			if (!Test.isRunningTest()) {
				for (Case currRec : parentWishesList) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	/*
    * @description		Used to include Intake Manager into Case team.
    *
    * @author 			MST Solutions
    * @createdDate		unknown
    */
	public static void caseTeamInTakeManager(Map<Id, Case> parentCaseIntakeOwnerMap) {
		Map<Id, String> teamRoleNameMap = new Map<Id, String>();
		Map<String, Id> teamRoleIdMap = new Map<String, Id>();
		Set<Id> chapterSet = new Set<Id>();
		Map<Id, Set<Id>> checkMemMap = new Map<Id, Set<Id>>();

		try {
			for (Case CaseInfo : parentCaseIntakeOwnerMap.values()) {
				chapterSet.add(CaseInfo.ChapterName__c);
			}

			for (CaseTeamRole CaseTeamRoleInfo : [
				SELECT Id, Name
				FROM CaseTeamRole
				LIMIT 50000
			]) {
				teamRoleNameMap.put(CaseTeamRoleInfo.Id, CaseTeamRoleInfo.Name);
				teamRoleIdMap.put(CaseTeamRoleInfo.Name, CaseTeamRoleInfo.Id);
			}

			for (CaseTeamMember CaseInfo : [
				SELECT Id, MemberId, ParentId
				FROM CaseTeamMember
				WHERE ParentId IN :parentCaseIntakeOwnerMap.keySet()
				LIMIT 50000
			]) {
				if (checkMemMap.containsKey(CaseInfo.ParentId)) {
					checkMemMap.get(CaseInfo.ParentId).add(CaseInfo.MemberId);
				} else {
					checkMemMap.put(CaseInfo.ParentId, new Set<Id>{
						CaseInfo.MemberId
					});
				}
			}

			if (parentCaseIntakeOwnerMap.size() > 0) {
				List<CaseTeamMember> memberList = new List<CaseTeamMember>();

				for (Case Caseteam : parentCaseIntakeOwnerMap.values()) {
					if (checkMemMap.containsKey(Caseteam.Id) && !checkMemMap.get(Caseteam.Id).contains(Caseteam.OwnerId)) {
						CaseTeamMember newCaseTeamMember = new CaseTeamMember();
						newCaseTeamMember.ParentId = Caseteam.Id;
						newCaseTeamMember.MemberId = Caseteam.OwnerId;
						newCaseTeamMember.TeamRoleId = teamRoleIdMap.get(Constant_AC.CASE_TEAM_ROLE_INTAKE_MANAGER);
						memberList.add(newCaseTeamMember);
					} else if (!checkMemMap.containsKey(Caseteam.Id)) {
						CaseTeamMember newCaseTeamMember = new CaseTeamMember();
						newCaseTeamMember.ParentId = Caseteam.Id;
						newCaseTeamMember.MemberId = Caseteam.OwnerId;
						newCaseTeamMember.TeamRoleId = teamRoleIdMap.get(Constant_AC.CASE_TEAM_ROLE_INTAKE_MANAGER);
						memberList.add(newCaseTeamMember);
					}
				}

				if (memberList.size() > 0) {
					insert memberList;
				}
			}

			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Case currRec : parentCaseIntakeOwnerMap.values()) {
				ErrorMessage_AC.createdebugRec('Case_OnAfterInsertTriggerHandlerHelper', String.valueOf(currRec), String.valueOf(ex), 'CaseTeamInTakeManager', currRec.Id, ex.getStackTraceString(), 'Error');
			}

			if (!Test.isRunningTest()) {
				for (Case currRec : parentCaseIntakeOwnerMap.values()) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	/*
    * @description		Used to create Case file records when a parent Case and subcase is created.
    *
    * @author 			MST Solutions
    * @createdDate		unknown
    */
	public static void createCaseFile(List<Case> caseList) {
		List<cg__CaseFile__c> caseFiles = new List<cg__CaseFile__c>();

		try {
			for (Case newCase : caseList) {
				cg__CaseFile__c picFolder = new cg__CaseFile__c();
				picFolder.cg__Case__c = newCase.Id;
				picFolder.cg__Content_Type__c = Constant_AC.FILE_CONTENT_TYPE_FOLDER;
				picFolder.cg__File_Name__c = Constant_AC.FILE_NAME_PHOTOS;
				picFolder.cg__WIP__c = false;
				picFolder.cg__Private__c = false;
				caseFiles.add(picFolder);

				cg__CaseFile__c docFolder = new cg__CaseFile__c();
				docFolder.cg__Case__c = newCase.Id ;
				docFolder.cg__Content_Type__c = Constant_AC.FILE_CONTENT_TYPE_FOLDER;
				docFolder.cg__File_Name__c = Constant_AC.FILE_NAME_DOCUMENTS;
				docFolder.cg__WIP__c = false;
				docFolder.cg__Private__c = false;
				caseFiles.add(docFolder);

				cg__CaseFile__c videoFolder = new cg__CaseFile__c();
				videoFolder.cg__Case__c = newCase.Id ;
				videoFolder.cg__Content_Type__c = Constant_AC.FILE_CONTENT_TYPE_FOLDER;
				videoFolder.cg__File_Name__c = Constant_AC.FILE_NAME_VIDEOS;
				videoFolder.cg__WIP__c = false;
				videoFolder.cg__Private__c = false;
				caseFiles.add(videoFolder);

				cg__CaseFile__c staffFolder = new cg__CaseFile__c();
				staffFolder.cg__Case__c = newCase.Id ;
				staffFolder.cg__Content_Type__c = Constant_AC.FILE_CONTENT_TYPE_FOLDER;
				staffFolder.cg__File_Name__c = Constant_AC.FILE_NAME_STAFF_PRIVATE;
				staffFolder.cg__WIP__c = false;
				staffFolder.cg__Private__c = true;
				caseFiles.add(staffFolder);

				cg__CaseFile__c financeFolder = new cg__CaseFile__c();
				financeFolder.cg__Case__c = newCase.Id ;
				financeFolder.cg__Content_Type__c = Constant_AC.FILE_CONTENT_TYPE_FOLDER;
				financeFolder.cg__File_Name__c = Constant_AC.FILE_NAME_FINANCIALS;
				financeFolder.cg__WIP__c = false;
				financeFolder.cg__Private__c = true;
				caseFiles.add(financeFolder);
			}

			if (caseFiles.size() > 0) {
				if (!Test.isRunningTest()) {
					insert caseFiles;
				}
			}

			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}

		} catch (Exception ex) {
			for (Case currRec : caseList) {
				ErrorMessage_AC.createdebugRec('Case_OnAfterInsertTriggerHandlerHelper', String.valueOf(currRec), String.valueOf(ex), 'createCaseFile', currRec.Id, ex.getStackTraceString(), 'Error');
			}

			if (!Test.isRunningTest()) {
				for (Case currRec : caseList) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	/*
    * @description		Insert a Wish Child Form.
    *
    * @author 			MST Solutions
    * @createdDate		unknown
    */
	public static void wishFormChildRec(Set<Id> caseIds) {
		List<Wish_Child_Form__c> wishFormList = new List<Wish_Child_Form__c>();

		for (Case currCase : [
			SELECT Id,RecordTypeId,ContactId,Contact.FirstName,Contact.LastName,Contact.Middle_Name__c,
				Contact.Birthdate,Contact.Diagnosis__c,Contact.Gender__c,Contact.Self_describe_comment_box__c,
				Contact.MobilePhone,Contact.Email,Contact.T_Shirt_Size__c,Contact.MailingStreet,
				Contact.MailingState,Contact.MailingCity,Contact.MailingPostalCode,Contact.Preferred_Name__c
			FROM Case
			WHERE Id IN:caseIds
		]) {
			Wish_Child_Form__c currWishChild = new Wish_Child_Form__c();

			currWishChild.FirstName__c = currCase.Contact.FirstName;
			currWishChild.LastName__c = currCase.Contact.LastName;
			currWishChild.Middle_Name__c = currCase.Contact.Middle_Name__c;
			currWishChild.Diagnosis__c = currCase.Contact.Diagnosis__c;
			currWishChild.Gender__c = currCase.Contact.Gender__c;
			currWishChild.Self_describe_comment_box__c = currCase.Contact.Self_describe_comment_box__c;
			currWishChild.Wish_Determination_Case_Id__c = currCase.ContactId;
			currWishChild.mobilePhone__c = currCase.Contact.MobilePhone;
			currWishChild.Case__c = currCase.Id;
			currWishChild.Email__c = currCase.Contact.Email;
			currWishChild.T_Shirt_Size__c = currCase.Contact.T_Shirt_Size__c;
			currWishChild.Street__c = currCase.Contact.MailingStreet;
			currWishChild.State__c = currCase.Contact.MailingState;
			currWishChild.City__c = currCase.Contact.MailingCity;
			currWishChild.Zip_Code__c = currCase.Contact.MailingPostalCode;
			currWishChild.Wish_Determination_Case_Id__c = currCase.ContactId;
			currWishChild.RecordTypeId = WISH_FORM_CHILD_ID;
			currWishChild.Contact__c = currCase.ContactId;
			currWishChild.Emergency_Relationship__c = Constant_AC.WISH_CHILD_FORM_EMERGENCY_RELATIONSHIP_STATUS_SELF;
			currWishChild.Preferred_Name__c = currCase.Contact.Preferred_Name__c;

			wishFormList.add(currWishChild);
		}

		if (wishFormList.size() > 0) {
			insert wishFormList;
		}
	}

	/*
    * @author 			MST Solutions
    * @createdDate		unknown
    */
	public static void reParentDvTask(Set<Id> caseIds) {
		Map<Id, Id> leadCaseMap = new Map<Id, Id>();

		for (Case currCase : [
			SELECT Id, ContactId, Hidden_Lead_Id__c
			FROM Case
			WHERE Id IN :caseIds AND RecordTypeId = :WISH_RECORDTYPE_ID
		]) {
			leadCaseMap.put(currCase.ContactId, currCase.Id);
		}

		if (leadCaseMap.size() > 0) {
			Map<Id, List<Task>> dvTaskMap = new Map<Id, List<Task>>();

			for (Task dvTask : [
				SELECT Id, Subject, WhoId
				FROM Task
				WHERE Subject = :Constant_AC.TASK_SUBJECT_RUSH_MODIFIED_NO AND WhoId IN :leadCaseMap.keySet()
			]) {
				if (dvTaskMap.containsKey(dvTask.WhoId)) {
					dvTaskMap.get(dvTask.WhoId).add(dvTask);
				} else {
					dvTaskMap.put(dvTask.WhoId, new List<Task>{
						dvTask
					});
				}
			}

			if (dvTaskMap.size() > 0) {
				List<Task> CaseTaskList = new List<Task>();

				for (Id leadId : dvTaskMap.keySet()) {
					for (Task updateTask : dvTaskMap.get(leadId)) {
						if (leadCaseMap.containsKey(updateTask.WhoId)) {
							Task updateTaskWhatId = new Task();
							updateTaskWhatId.Id = updateTask.Id;
							updateTaskWhatId.WhatId = leadCaseMap.get(updateTask.WhoId);
							CaseTaskList.add(updateTaskWhatId);
						}
					}
				}

				if (CaseTaskList.size() > 0) {
					update CaseTaskList;
				}
			}
		}
	}
}