/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/26/2016
Description : When a new Case record insert then it will called by the Case_OnAfterInsertTriggerHandler class.
*******************************************************************************************************************/

public class Case_OnAfterInsertTriggerHandlerHelper {

	private static final Id wishRecordTypeId = Constant_AC.WISH_RT_ID;

	/******************************************************************************************************
This method is used to uppdate the parent wish subject, Fund Id and Unique wish Identifier values. When
a parent Case is created.
******************************************************************************************************/
	public static void UpdateWishRecordIdentifier(Set<Id> ParentIdsSet, Set<Id> chapterIds, Id recTypeId) {

		Integer increment;
		Boolean IsFYChanged = false;
		Datetime FYDate = Datetime.now();
		String dateOutput = FYDate.format('yy');
		Integer FYYear = Integer.valueOf(dateOutput);
		Map<String, Office__c> accountOfficeMap = new Map<String, Office__c>();
		List<Case> lstParentWishes;
		try {
			List<Period> financialPeriod = [
					SELECT StartDate, EndDate,IsForecastPeriod,Type
					FROM Period
					WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY
					LIMIT 50000
			];
			if (financialPeriod.size() > 0) {
				if ((Date.today() >= financialPeriod[0].StartDate
						&& Date.today() <= financialPeriod[0].EndDate)
						&& (Date.today().addDays(-1) >= financialPeriod[0].StartDate
						&& Date.today().addDays(-1) <= financialPeriod[0].EndDate)) {
					IsFYChanged = true;
				}
				FYDate = Datetime.newInstance(financialPeriod[0].EndDate.year(), financialPeriod[0].EndDate.month(), financialPeriod[0].EndDate.day());
				FYYear = Integer.valueOf(FYDate.format('yy'));
			}
			for (Office__c currOffice : [
					SELECT Office_Id__c, Chapter__r.name,Chapter__c
					FROM Office__c
					WHERE Chapter__c IN :chapterIds
					LIMIT 50000
			]) {
				accountOfficeMap.put(currOffice.Chapter__r.Name, currOffice);
			}
			lstParentWishes = [
					SELECT Id, RecordTypeId, Subject, Unique_Wish_Record_Identifier__c,Fund_Id__c, ChapterName__c,ChapterName__r.Name
					FROM Case
					WHERE Id IN:ParentIdsSet
					AND RecordTypeId = :recTypeId
					ORDER BY CreatedDate DESC
					LIMIT 50000
			];
			List<Case> lstParentWisheRecordTypes = [
					SELECT Id, Unique_Wish_Record_Identifier__c, ChapterName__c,ChapterName__r.Name
					FROM Case
					WHERE RecordTypeId = :recTypeId
					AND Unique_Wish_Record_Identifier__c != NULL
					AND CreatedBy.Name != 'Integration User'
					AND Lead__r.unique_wish_identifier__c = NULL
					ORDER BY CreatedDate DESC
					LIMIT 2
			];
			if (IsFYChanged) {
				if (lstParentWisheRecordTypes.size() > 0 && lstParentWisheRecordTypes[0].Unique_Wish_Record_Identifier__c != null) {
					String wishRecordIdentifier = lstParentWisheRecordTypes[0].Unique_Wish_Record_Identifier__c;
					wishRecordIdentifier = wishRecordIdentifier.right(5);
					increment = Integer.valueOf(wishRecordIdentifier) + 1;
				} else {
					increment = 10001;
				}
			} else {
				increment = 10001;
			}
			for (Case parentWishes : lstParentWishes) {
				String temp = accountOfficeMap.containsKey(parentWishes.ChapterName__r.Name) ? accountOfficeMap.get(parentWishes.ChapterName__r.Name).Office_Id__c : null;
				if (temp != null) {

					if (parentWishes.Unique_Wish_Record_Identifier__c == null) {
						parentWishes.Unique_Wish_Record_Identifier__c = temp.left(3) + '-' + FYYear + '-' + increment ;
						parentWishes.UWISource__c = 'Case';
					}
					if (parentWishes.Fund_Id__c == null) {
						parentWishes.Fund_Id__c = temp.left(3) + '-' + FYYear + '-' + increment ;
					}
				}
				increment = increment + 1;
				parentWishes.Subject = parentWishes.Subject + ' - ' + parentWishes.Unique_Wish_Record_Identifier__c;
			}
			if (lstParentWishes.size() > 0) {
				update lstParentWishes;
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Case currRec : lstParentWishes) {
				ErrorMessage_AC.createdebugRec('Case_OnAfterInsertTriggerHandlerHelper', String.valueof(currRec),
						String.valueOf(ex), 'UpdateWishRecordIdentifier', currRec.Id, ex.getStackTraceString(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (Case currRec : lstParentWishes) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	/**
	 * JIRA: WLP-286
	 * Author: Gustavo Mayer
	 * Update: Sub case conversion to the single Wish Case, no need to update as there is no longer the concept of parent case.
	 */
	/*************************************************************************************************
	Related to STT-11 for populating survey email field on parent wish from the Wish Impact sub Case.
	***************************************************************************************************/
//	public static void updateSurveyField(Map<Id, Case> surveyEmailMap, Set<Id> idSet) {
//		RecursiveTriggerHandler.allowToEditRecord = true;
//		Map<Id, Case> parentCaseMap = new Map<Id, Case>();
//		try {
//			for (Case case : [
//					SELECT Id, Wish_Impact_Survey_Email__c,Survey_Sent__c
//					FROM Case
//					WHERE Id IN :idSet
//					LIMIT 50000
//			]) {
//				parentCaseMap.put(case.Id, case);
//			}
//			for (Case wishCase : surveyEmailMap.values()) {
//				if (parentCaseMap.containsKey(wishCase.Id)) {
//					parentCaseMap.get(wishCase.Id).Wish_Impact_Survey_Email__c = wishCase.Survey_Email__c;
//					parentCaseMap.get(wishCase.Id).Survey_Sent__c = wishCase.Survey_Sent__c ;
//				}
//			}
//			if (parentCaseMap.size() > 0) {
//				update parentCaseMap.values();
//			}
//
//			if (Test.isRunningTest()) {
//				throw new CommonTriggerException('Test Class execution');
//			}
//
//		} catch (Exception ex) {
//			for (Case currRec : surveyEmailMap.values()) {
//				ErrorMessage_AC.createdebugRec('Case_OnAfterInsertTriggerHandlerHelper', String.valueof(currRec), String.valueOf(ex), 'updateSurveyField', currRec.Id, ex.getStackTraceString(), 'Error');
//			}
//
//			if (!Test.isRunningTest()) {
//				for (Case currRec : surveyEmailMap.values()) {
//					currRec.addError(Label.Debug_log_error_message);
//				}
//			}
//		}
//	}

	/**
	 * JIRA: WLP-286
	 * Author: Gustavo Mayer
	 * Update: Sub case conversion to the single Wish Case
	 */
	/***********************************************************************************************************************
Used to create action track for different stages based on Chapter and used to pull Case team members to child wishes.
***********************************************************************************************************************/
//	public static void createActionTracks(Map<Id, Case> CaseChapterIdsMap, Set<Id> parentWishIdsSet) {
//		Id wishRecordTypeId = Constant_AC.WISH_RT_ID;
//		Map<String, Case> chaptersWishMap = new Map<String, Case>();
//		List<CaseTeamMember> childWishTeamMembersList = new List<CaseTeamMember>();
//		Map<String, List<Case>> wishDeterminationCases = new Map<String, List<Case>>();
//		Map<Id, List<CaseTeamMember>> parentCaseMembersMap = new Map<Id, List<CaseTeamMember>>();
//		try {
//			if (parentWishIdsSet.size() > 0) {
//				//Used to get Case and its Case team members
//				for (CaseTeamMember caseTeamMember : [
//						SELECT Id,ParentId,Parent.RecordTypeId,MemberId,TeamRoleId
//						FROM CaseTeamMember
//						WHERE ParentId IN :parentWishIdsSet
//						AND Parent.RecordTypeId = :wishRecordTypeId
//						LIMIT 50000
//				]) {
//					if (parentCaseMembersMap.containsKey(caseTeamMember.ParentId)) {
//						parentCaseMembersMap.get(caseTeamMember.ParentId).add(caseTeamMember);
//					} else {
//						parentCaseMembersMap.put(caseTeamMember.ParentId, new List<CaseTeamMember>{
//								caseTeamMember
//						});
//					}
//				} 
//				//Used to include the parent wish Case team members to child wish Case team
//				for (Case addTeamMember : CaseChapterIdsMap.values()) {
//					chaptersWishMap.put(addTeamMember.ParentId, addTeamMember);
//					if (parentCaseMembersMap.containsKey(addTeamMember.ParentId)) {
//						for (CaseTeamMember createWishTeamMember : parentCaseMembersMap.get(addTeamMember.ParentId)) {
//							CaseTeamMember addWishTeamMember = new CaseTeamMember(MemberId = createWishTeamMember.MemberId, TeamRoleId = createWishTeamMember.TeamRoleId, ParentId = addTeamMember.Id);
//							childWishTeamMembersList.add(addWishTeamMember);
//						}
//					}
//					if (addTeamMember.RecordTypeId != wishRecordTypeId) {
//						if (wishDeterminationCases.containsKey(addTeamMember.Id)) {
//							wishDeterminationCases.get(addTeamMember.Id).add(addTeamMember);
//						} else {
//							wishDeterminationCases.put(addTeamMember.Id, new List<Case>{
//									addTeamMember
//							});
//						}
//					}
//				}
//				if (childWishTeamMembersList.size() > 0) {
//					insert childWishTeamMembersList;
//				}
//			}
//
//			if (Test.isRunningTest()) {
//				throw new CommonTriggerException('Test Class execution');
//			}
//
//		} catch (Exception ex) {
//			for (Case currRec : CaseChapterIdsMap.values()) {
//				ErrorMessage_AC.createdebugRec('Case_OnAfterInsertTriggerHandlerHelper', String.valueof(currRec),
//						String.valueOf(ex), 'createActionTracks', currRec.Id, ex.getStackTraceString(), 'Error');
//			}
//
//			if (!Test.isRunningTest()) {
//				for (Case currRec : CaseChapterIdsMap.values()) {
//					currRec.addError(Label.Debug_log_error_message);
//				}
//			}
//		}
//	}

	/*********************************************************
Used to include Intake Manager into Case team.
*********************************************************/
	public static void CaseTeamInTakeManager(Map<Id, Case> parentCaseIntakeOwnerMap) {
		Map<Id, String> teamRoleNameMap = new Map<Id, String>();
		Map<String, Id> teamRoleIdMap = new Map<String, Id>();
		Set<Id> chapterSet = new Set<Id>();
		List<Case> CaseUpdateList = new List<Case>();
		Map<Id, Set<Id>> checkMemMap = new map<Id, Set<Id>>();
		try {
			for (Case CaseInfo : parentCaseIntakeOwnerMap.values()) {
				chapterSet.add(CaseInfo.chapterName__c);
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
						newCaseTeamMember.parentId = Caseteam.Id;
						newCaseTeamMember.MemberId = Caseteam.OwnerId;
						newCaseTeamMember.TeamRoleId = teamRoleIdMap.get('Intake Manager');
						memberList.add(newCaseTeamMember);
					} else if (!checkMemMap.containsKey(Caseteam.Id)) {
						CaseTeamMember newCaseTeamMember = new CaseTeamMember();
						newCaseTeamMember.parentId = Caseteam.Id;
						newCaseTeamMember.MemberId = Caseteam.OwnerId;
						newCaseTeamMember.TeamRoleId = teamRoleIdMap.get('Intake Manager');
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
				ErrorMessage_AC.createdebugRec('Case_OnAfterInsertTriggerHandlerHelper', String.valueof(currRec), String.valueOf(ex), 'CaseTeamInTakeManager', currRec.Id, ex.getStackTraceString(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (Case currRec : parentCaseIntakeOwnerMap.values()) {
					currRec.addError(Label.Debug_log_error_message);
				}

			}
		}
	}

	/*********************************************************************************
Used to create a Case file records when a Parent Case and sub Cases is created.
**********************************************************************************/
	public static void createCaseFile(List<Case> CaseList) {
		List<cg__CaseFile__c> Casefiles = new List<cg__CaseFile__c>();
		try {
			for (Case newCase : CaseList) {

				cg__CaseFile__c PicFolder = new cg__CaseFile__c();
				PicFolder.cg__Case__c = newCase .Id;
				PicFolder.cg__Content_Type__c = 'Folder';
				PicFolder.cg__File_Name__c = 'Photos';
				PicFolder.cg__WIP__c = false;
				PicFolder.cg__Private__c = false;
				Casefiles.add(PicFolder);

				cg__CaseFile__c DocFolder = new cg__CaseFile__c();
				DocFolder.cg__Case__c = newCase.Id ;
				DocFolder.cg__Content_Type__c = 'Folder';
				DocFolder.cg__File_Name__c = 'Documents';
				DocFolder.cg__WIP__c = false;
				DocFolder.cg__Private__c = false;
				Casefiles.add(DocFolder);

				cg__CaseFile__c VedioFolder = new cg__CaseFile__c();
				VedioFolder.cg__Case__c = newCase.Id ;
				VedioFolder.cg__Content_Type__c = 'Folder';
				VedioFolder.cg__File_Name__c = 'Videos';
				VedioFolder.cg__WIP__c = false;
				VedioFolder.cg__Private__c = false;
				Casefiles.add(VedioFolder);

				cg__CaseFile__c StaffFolder = new cg__CaseFile__c();
				StaffFolder.cg__Case__c = newCase.Id ;
				StaffFolder.cg__Content_Type__c = 'Folder';
				StaffFolder.cg__File_Name__c = 'Staff - Private';
				StaffFolder.cg__WIP__c = false;
				StaffFolder.cg__Private__c = true;
				Casefiles.add(StaffFolder);

				cg__CaseFile__c FinanceFolder = new cg__CaseFile__c();
				FinanceFolder.cg__Case__c = newCase.Id ;
				FinanceFolder.cg__Content_Type__c = 'Folder';
				FinanceFolder.cg__File_Name__c = 'Financials';
				FinanceFolder.cg__WIP__c = false;
				FinanceFolder.cg__Private__c = true;
				Casefiles.add(FinanceFolder);
			}

			if (Casefiles.size() > 0) {
				if (!Test.isRunningTest()) {
					insert Casefiles;
				}
			}

			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}

		} catch (Exception ex) {
			for (Case currRec : CaseList) {
				ErrorMessage_AC.createdebugRec('Case_OnAfterInsertTriggerHandlerHelper', String.valueof(currRec), String.valueOf(ex), 'createCaseFile', currRec.Id, ex.getStackTraceString(), 'Error');
			}

			if (!Test.isRunningTest()) {
				for (Case currRec : CaseList) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}

		}
	}

	/**********************************************************************************************************
This method is used to update the wish receipt items velues in parent Case when a Granting Case is created.
**********************************************************************************************************
	public static void wishReciptValues(Map<Id,Case> wishReciptMap,Map<Id,Case> ParentCase){
		list<Case> wishReceiptCaseList = new list<Case>();
		try{
		if(wishReciptMap.size() > 0){
			for(Case currentCase : ParentCase.values()){
				if(wishReciptMap.containsKey(currentCase.Id)){
					currentCase.Wish_Receipt_Items__c = wishReciptMap.get(currentCase.id).Wish_Receipt_Items__c;
					wishReceiptCaseList.add(currentCase);
				}
			}
		}
		if(wishReceiptCaseList.size() > 0){
			update wishReceiptCaseList;
		}
	   }
	   catch(Exception ex){
			for(Case currRec : wishReciptMap.values()){
				ErrorMessage_AC.createdebugRec('Case_OnAfterInsertTriggerHandlerHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'wishReciptValues',currRec.Id,ex.getStackTraceString(),'Error');
			}
			for(Case currRec : wishReciptMap.values()){
				currRec.addError(Label.Debug_log_error_message);
			}
		}
	} */

	//IME-107
	/*public static void createPotentialRushTask(List<Case> CaseList){
		List<Task> newTaskList = new List<Task>();

		for(Case processCase: CaseList){
			Task newRushTask = new Task(Priority = 'Normal',
											Status = 'Not Started',
											Subject = 'Rush has been changed from Yes to No/ Not sure, reach out to family if necessary',
											OwnerId =  processCase.OwnerId,
											ActivityDate = System.today()+3,
											SystemGeneratedTask__c = true,
											WhatId = processCase.Id);
				newTaskList.add(newRushTask);
		}
		if(newTaskList.size() > 0){
			insert newTaskList;
		}
	}*/

	public static void wishFormChildRec(Set<Id> CaseIdSet) {
		Id wichChildRecordTypeId = Constant_AC.WISH_FORM_CHILD_ID;
		List<Wish_Child_Form__c > WishFormList = new List<Wish_Child_Form__c>();
		for (Case currCase : [
				SELECT Id,RecordTypeId,ContactId,Contact.FirstName,Contact.LastName,Contact.Middle_Name__c,
						Contact.Birthdate,Contact.Diagnosis__c,Contact.Gender__c,Contact.Self_describe_comment_box__c,
						Contact.MobilePhone,Contact.Email,Contact.T_Shirt_Size__c,Contact.MailingStreet,
						Contact.MailingState,Contact.MailingCity,Contact.MailingPostalCode,Contact.Preferred_Name__c
				FROM Case
				WHERE Id IN:CaseIdSet
		]) {

			Wish_Child_Form__c currWishChild = new Wish_Child_Form__c();
			currWishChild.FirstName__c = currCase.Contact.FirstName;
			currWishChild.LastName__c = currCase.Contact.LastName;
			currWishChild.Middle_Name__c = currCase.Contact.Middle_Name__c;
			//currWishChild.BirthDate__c = currCase.Contact.Birthdate;
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
			currWishChild.RecordTypeId = wichChildRecordTypeId;
			currWishChild.Contact__c = currCase.ContactId;
			currWishChild.Emergency_Relationship__c = 'Self';
			currWishChild.Preferred_Name__c = currCase.Contact.Preferred_Name__c;
			WishFormList.add(currWishChild);
		}
		if (WishFormList.size() > 0)
			insert WishFormList;
	}

	public static void reParentDvTask(Set<Id> CaseIdSet) {
		Map<Id, Id> leadCaseMap = new Map<Id, Id>();
		for (Case currCase : [
				SELECT Id, ContactId, Hidden_Lead_Id__c
				FROM Case
				WHERE Id IN:CaseIdSet AND RecordTypeId = :wishRecordTypeId
		]) {
			leadCaseMap.put(currCase.ContactId, currCase.Id);
		}
		if (leadCaseMap.size() > 0) {
			Map<Id, List<Task>> dvTaskMap = new Map<Id, List<Task>>();
			//Used to query all the DV Task
			for (Task dvTask : [
					SELECT Id, Subject, WhoId
					FROM Task
					WHERE Subject = 'Rush has been changed from Yes to No/ Not sure, reach out to family if necessary' AND WhoId IN :leadCaseMap.keySet()
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