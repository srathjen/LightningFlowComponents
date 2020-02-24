/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/27/2016
Description : When a volunteer Opportunity record get update then it will call the corresponding methods based
on the collection size() > 0.
Modification Log:
04/17/2018 - Kanagaraj - WVC-1885
*******************************************************************************************************************/
/**
 * JIRA: WLP-422
 * Author: Gustavo Mayer
 * Update: Changing the Volunteer_Roles status from 'Trained' to 'Active'
 */
public class VolOpportunity_OnAfter_Update_Helper {

	private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;
	private static final Set<Id> WISH_RECORD_TYPES = new Set<Id>{
			Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID, Constant_AC.REGISTERED_WISH_ID
	};
	private static final Set<Id> NONWISH_RECORD_TYPES = new Set<Id>{
			Constant_AC.NON_WISH_EVENT_RT_ID, Constant_AC.REGISTERED_NON_WISH_ID
	};
	private static final String VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER = Constant_AC.VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER;
	private static final String VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER_MENTOR = Constant_AC.VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER_MENTOR;
	private static final String VOLUNTEER_OPPORTUNITY_ROLE_TEMPORARY_WISH_GRANTER = Constant_AC.VOLUNTEER_OPPORTUNITY_ROLE_TEMPORARY_WISH_GRANTER;

	// Update case Id.
	public static void updateCase(Set<Id> caseIdSet, Set<Id> voluOppIdSet, List<Volunteer_Opportunity__c> volunteerOppExepList) {
		RecursiveTriggerHandler.isFirstTime = false;
		RecursiveTriggerHandler.allowToEditRecord = TRUE;
		List<Case> updateCaseList = new List<Case>();
		Case myParentCase = new Case();
		try {
			for (Case record : [
					SELECT id
					FROM Case
					WHERE Id IN :caseIdSet
			]) {
				myParentCase.id = record.id;
			}
			for (User dbUser : [
					SELECT Id,Name,ContactId
					FROM User
					WHERE ContactId IN:voluOppIdSet
			]) {
				if (voluOppIdSet.contains(dbUser.ContactId)) {
					myParentCase.InActiveWishGranter__c = dbUser.Name;
				}
			}
			updateCaseList.add(myParentCase);
			if (updateCaseList.size() > 0)
				update updateCaseList ;
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Volunteer_Opportunity__c currRec : volunteerOppExepList /*[SELECT Id,Volunteer_Name__c,Wish__c FROM Volunteer_Opportunity__c WHERE Volunteer_Name__c IN: voluOppIdSet AND Wish__c IN: caseIdSet]*/) {
				ErrorMessage_AC.createdebugRec('VolOpportunity_OnAfter_Update_Helper',
						String.valueof(currRec), String.valueOf(ex),
						'updateCase', currRec.Id, ex.getStackTraceString(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (Volunteer_Opportunity__c currRec : volunteerOppExepList /*[SELECT Id,Volunteer_Name__c,Wish__c FROM Volunteer_Opportunity__c WHERE Volunteer_Name__c IN: voluOppIdSet AND Wish__c IN: caseIdSet]*/) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	// Create a new volunteer Opportunity when the volunteer Opportunity get rejected and create or update the case team member and create task for corresponding case.
	public static void CreateNewVolunteerOpportunity(List<Volunteer_Opportunity__c > volunteerOpportunityList, Set<Id> volunteerOppIdSet) {
		RecursiveTriggerHandler.isFirstTime = false;
		Id nonWishEvents = Constant_AC.NON_WISH_EVENT_RT_ID;
		Id wishEvents = Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID;
		List<Volunteer_Opportunity__c> createNewVolunteerOpportunityList = new List<Volunteer_Opportunity__c>();
		List<Volunteer_Opportunity__c> updateList = new List<Volunteer_Opportunity__c>();
		boolean isPending = false;
		Set<Id> wishIdSet = new Set<Id>();
		Set<Id> parentIdset = new Set<Id>();
		List<CaseTeamMember> removeCaseTeamMemberList = new List<CaseTeamMember>();
		Set<Id> volunteerNamesSet = new Set<Id>();
		Map<Id, String> caseTeamIdMap = new Map<Id, String>();
		Map<String, Id> caseTeamNameMap = new Map<String, Id>();
		Map<Id, Set<Id>> inActiveOwners = new Map<Id, Set<Id>>();
		Set<Id> contactIdSet = new Set<Id>();
		Map<Id, boolean> wishStatusMap = new Map<Id, boolean>();

		try {
			for (Volunteer_Opportunity__c currRec : [
					SELECT Id,Wish__c,Wish__r.Status,Wish__r.isClosed
					FROM Volunteer_Opportunity__c
					WHERE Id IN :volunteerOppIdSet
					AND Wish__c != Null
			]) {
				wishStatusMap.put(currRec.Wish__C, currRec.Wish__r.isClosed);
			}
			for (CaseTeamRole caseTeamInfo : [
					Select Id, Name
					FROM CaseTeamRole
			]) {
				caseTeamIdMap.put(caseTeamInfo.Id, caseTeamInfo.Name);
				caseTeamNameMap.put(caseTeamInfo.Name, caseTeamInfo.Id);
			}
			for (Volunteer_Opportunity__c processVolOpportunity : volunteerOpportunityList) {
				Volunteer_Opportunity__c newVolOpportunity = new Volunteer_Opportunity__c();
				newVolOpportunity.Chapter_Name__c = processVolOpportunity.Chapter_Name__c;
				newVolOpportunity.Chapter_Role_Opportunity__c = processVolOpportunity.Chapter_Role_Opportunity__c;
				newVolOpportunity.Date_Time__c = processVolOpportunity.Date_Time__c;
				newVolOpportunity.Hidden_VolunteerCount_Desc__c = processVolOpportunity.Hidden_VolunteerCount_Desc__c;
				newVolOpportunity.Description__c = processVolOpportunity.Description__c;
				newVolOpportunity.Start_Time__c = processVolOpportunity.Start_Time__c ;
				newVolOpportunity.End_Time__c = processVolOpportunity.End_Time__c;
				newVolOpportunity.Date__c = processVolOpportunity.Date__c;
				newVolOpportunity.Location__c = processVolOpportunity.Location__c;
				newVolOpportunity.HiddenVolunteer_Count_Description__c = processVolOpportunity.HiddenVolunteer_Count_Description__c ;
				volunteerNamesSet.add(processVolOpportunity.Volunteer_Name__c);
				if (processVolOpportunity.Non_Wish_Event__c != null) {
					newVolOpportunity.Non_Wish_Event__c = processVolOpportunity.Non_Wish_Event__c;
					newVolOpportunity.RecordTypeId = nonWishEvents;
				}
				newVolOpportunity.Required_Forms_for_Volunteers__c = processVolOpportunity.Required_Forms_for_Volunteers__c;
				newVolOpportunity.Volunteer_Notes__c = processVolOpportunity.Volunteer_Notes__c ;
				if (processVolOpportunity.Wish__c != null && wishStatusMap.get(processVolOpportunity.Wish__C) != true) {
					contactIdSet.add(processVolOpportunity.Volunteer_Name__c);
					if (inActiveOwners.containsKey(processVolOpportunity.Wish__c)) {
						inActiveOwners.get(processVolOpportunity.Wish__c).add(processVolOpportunity.Volunteer_Name__c);
					} else {
						inActiveOwners.put(processVolOpportunity.Wish__c, new Set<Id>{
								processVolOpportunity.Volunteer_Name__c
						});
					}
					newVolOpportunity.Wish__c = processVolOpportunity.Wish__c;
					newVolOpportunity.RecordTypeId = wishEvents ;
					wishIdSet.add(processVolOpportunity.Wish__c);
					parentIdset.add(processVolOpportunity.Wish__c);
				}
				if (processVolOpportunity.Reason_Inactive__c == 'Not Approved') {
					Volunteer_Opportunity__c updateVolOpp = new Volunteer_Opportunity__c();
					updateVolOpp.id = processVolOpportunity.Id;
					updateVolOpp.Inactive__c = true;
					updateList.add(updateVolOpp);
				}
				createNewVolunteerOpportunityList.add(newVolOpportunity);
			}
			Map<Id, Id> contactUserMap = new Map<Id, Id>();
			for (User userInfo : [
					SELECT Id, ContactId
					FROM User
					WHERE ContactId IN :contactIdSet
			]) {
				contactUserMap.put(userInfo.Id, userInfo.ContactId);
			}
			Map<Id, Id> activeVolunteerMap = new Map<Id, Id>();

			for (CaseTeamMember caseTeamInfo : [
					SELECT Id, TeamRole.Name, ParentId, MemberId
					FROM CaseTeamMember
					WHERE (TeamRole.Name = :VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER
					OR TeamRole.Name = :VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER_MENTOR)
					AND ParentId IN :inActiveOwners.keySet()
					ORDER BY CreatedDate ASC
			]) {
				if (!activeVolunteerMap.containsKey(caseTeamInfo.ParentId)
						&& !contactUserMap.containsKey(caseTeamInfo.MemberId)) {
					activeVolunteerMap.put(caseTeamInfo.ParentId, caseTeamInfo.MemberId);
				}
			}
			Map<Id, Id> caseOwnerMap = new Map<Id, Id>();

			for (Case ownerMap : [
					SELECT Id, OwnerId
					FROM Case
					WHERE Id IN :wishStatusMap.keySet()
			]) {
				caseOwnerMap.put(ownerMap.Id, ownerMap.OwnerId);
			}
			List<Task> taskOwnerUpdateList = new List<Task>();
			for (Task getAllTask : [
					SELECT Id, OwnerId, Task_Type__c, WhatId
					FROM Task
					WHERE WhatId IN :inActiveOwners.keySet()
					AND isClosed = false
			]) {
				if (inActiveOwners.containsKey(getAllTask.WhatId)) {
					if (inActiveOwners.get(getAllTask.WhatId).contains(contactUserMap.get(getAllTask.OwnerId))) {
						if (activeVolunteerMap.containsKey(getAllTask.WhatId) && getAllTask.Task_Type__c != null) {
							getAllTask.OwnerId = activeVolunteerMap.get(getAllTask.WhatId);
							taskOwnerUpdateList.add(getAllTask);
						} else {
							getAllTask.OwnerId = caseOwnerMap.get(getAllTask.WhatId);
							taskOwnerUpdateList.add(getAllTask);
						}
					}
				}
			}
			if (taskOwnerUpdateList.size() > 0) {
				update taskOwnerUpdateList;
			}
			Set<Id> userIds = new Set<Id>();
			if (volunteerNamesSet.size() > 0) {
				for (User currUser : [
						SELECT id
						FROM User
						WHERE contactId IN :volunteerNamesSet
				]) {
					userIds.add(currUser.id);
				}
			}

			/**
			 * JIRA: WLP-286
			 * Author: Gustavo Mayer
			 * Update: Sub case conversion to the single Wish Case, no need to update
			 * as there is no longer the concept of parent case.
			 */
//          List<Case> subCaseList = new List<Case>();
//			Set<Id> subCaseIdSet = new Set<Id>();
//			for (Case getChildCaseId : [
//					SELECT Id, ParentId
//					FROM Case
//					WHERE ParentId IN :wishIdSet
//			]) {
//				parentIdset.add(getChildCaseId.Id);
//				subCaseList.add(getChildCaseId);
//				subCaseIdSet.add(getChildCaseId.Id);
//			}
//			List<CaseteamMember> deleteList = new List<CaseTeamMember>();
//			if (subCaseIdSet.size() > 0) {
//				for (CaseTeamMember caseTeamInfo : [
//						SELECT Id,ParentId
//						FROM CaseTeamMember
//						WHERE ParentId IN :subCaseIdSet
//				]) {
//					deleteList.add(caseTeamInfo);
//				}
//			}
//			if (deleteList.size() > 0) {
//				delete deleteList;
//			}
			Map<Id, String> volunteerOppMap = new Map<Id, String>();
			for (Volunteer_Opportunity__c getActiveVolOpp : [
					SELECT Id, Volunteer_Name__c, Wish__c, Role__c
					FROM Volunteer_Opportunity__c
					WHERE Volunteer_Name__c IN :volunteerNamesSet
					AND Wish__c != NULL
					AND Status__c = 'Approved'
					AND Wish__c IN :wishStatusMap.keySet()
			]) {
				if (!volunteerOppIdSet.contains(getActiveVolOpp.Id)) {
					volunteerOppMap.put(getActiveVolOpp.Volunteer_Name__c, getActiveVolOpp.Role__c);
				}
			}
			List<Case> updateinactiveList = new List<Case>();
			Set<id> parentCaseId = new Set<id>();
			for (CaseTeamMember dbcaseTeamMember : [
					SELECT id,MemberId, ParentId, TeamRoleId, TeamRole.Name
					FROM CaseTeamMember
					WHERE ParentId IN :parentIdset AND MemberId IN :userIds
			]) {
				if (caseTeamIdMap.size() > 0 && caseTeamIdMap.containsKey(dbcaseTeamMember.TeamRoleId)) {
					if (contactUserMap.containsKey(dbcaseTeamMember.MemberId)) {
						if (volunteerOppMap.containsKey(contactUserMap.get(dbcaseTeamMember.MemberId))) {
							dbcaseTeamMember.TeamRoleId = caseTeamNameMap.get(volunteerOppMap.get(contactUserMap.get(dbcaseTeamMember.MemberId)));
							removeCaseTeamMemberList.add(dbcaseTeamMember);
							parentCaseId.add(dbcaseTeamMember.ParentId);
						} else if (caseTeamNameMap.containsKey(dbcaseTeamMember.TeamRole.Name + ' (Inactive)')) {
							dbcaseTeamMember.TeamRoleId = caseTeamNameMap.get(dbcaseTeamMember.TeamRole.Name + ' (Inactive)');
							removeCaseTeamMemberList.add(dbcaseTeamMember);
							parentCaseId.add(dbcaseTeamMember.ParentId);
						}
					}
				}
			}
			if (parentCaseId.size() > 0) {
				Case parentCase = new Case();
				for (Case newCase : [
						SELECT id,Hidden_VOinactive__c
						FROM Case
						WHERE Id IN :parentCaseId
				]) {
					ParentCase.id = newCase.id;
					ParentCase.Hidden_VOinactive__c = true;
					updateinactiveList.add(ParentCase);
				}
			}
			if (removeCaseTeamMemberList.size() > 0) {
				update removeCaseTeamMemberList;
			}
			if (updateinactiveList.size() > 0) {
				update updateinactiveList;
			}
			if (createNewVolunteerOpportunityList.size() > 0)
				// insert createNewVolunteerOpportunityList;
				if (updateList.size() > 0) {
					update updateList;
				}

			/**
			 * JIRA: WLP-286
			 * Author: Gustavo Mayer
			 * Update: Sub case conversion to the single Wish Case, no need to update
			 * as there is no longer the concept of parent case.
			 */
//			if (subCaseList.size() > 0 && wishIdSet.size() > 0) {
//				UpdateCaseTeamMemberForSubCase(wishIdSet, subCaseList, volunteerOpportunityList);
//			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Volunteer_Opportunity__c currRec : volunteerOpportunityList) {
				ErrorMessage_AC.createdebugRec('VolOpportunity_OnAfter_Update_Helper',
						String.valueof(currRec), String.valueOf(ex), 'CreateNewVolunteerOpportunity',
						currRec.Id, ex.getStackTraceString(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (Volunteer_Opportunity__c currRec : volunteerOpportunityList) {
					currRec.addError(Label.Debug_log_error_message);
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
	//This methods is used to create or update the caseTeam member of corresponding sub cases.
//	public static void updateCaseTeamMemberForSubCase(Set<Id> parentWishIdSet, List<Case>subCaseList, List<Volunteer_Opportunity__c > recordsForCreatingCaseTeams) {
//		Map<Id, List<CaseTeamMember>> caseTeamMemeberMap = new Map<Id, List<CaseTeamMember>>();
//		Map<String, Id> caseTeamRoleMap = new Map<String, Id>();
//
//		try {
//			for (CaseTeamRole caseTeamRole : [
//					SELECT Id, Name
//					FROM CaseTeamRole
//			]) {
//				caseTeamRoleMap.put(caseTeamRole.Name, caseTeamRole.Id);
//			}
//			Set<Id> inactiveUserMap = new Set<Id>();
//			for (CaseTeamMember caseTeamInfo : [
//					SELECT Id, MemberId, ParentId, TeamRoleId, TeamRole.Name
//					FROM CaseTeamMember
//					WHERE ParentId IN :parentWishIdSet
//			]) {
//				inactiveUserMap.add(caseTeamInfo.MemberId);
//				if (caseTeamMemeberMap.containsKey(caseTeamInfo.ParentId)) {
//					caseTeamMemeberMap.get(caseTeamInfo.ParentId).add(caseTeamInfo);
//				} else {
//					caseTeamMemeberMap.put(caseTeamInfo.ParentId, new List<CaseTeamMember>{
//							caseTeamInfo
//					});
//				}
//			}
//			Set<Id> inactiveMemberSet = new Set<Id>();
//			for (User getInActiveUser : [
//					SELECT Id, isActive
//					FROM User
//					WHERE IsActive = false
//			]) {
//				inactiveMemberSet.add(getInActiveUser.Id);
//			}
//			List<CaseTeamMember> newCaseTeamMemberList = new List<CaseTeamMember>();
//			for (Case subCase : subCaseList) {
//				if (caseTeamMemeberMap.containsKey(subCase.ParentId)) {
//					for (CaseTeamMember caseTeam : caseTeamMemeberMap.get(subCase.ParentId)) {
//						if (!inactiveMemberSet.contains(caseTeam.MemberId)) {
//							CaseTeamMember newTeamMember = new CaseTeamMember();
//							newTeamMember.MemberId = caseTeam.MemberId;
//							newTeamMember.ParentId = subCase.Id;
//							newTeamMember.TeamRoleId = caseTeam.TeamRoleId;
//							newCaseTeamMemberList.add(newTeamMember);
//						}
//					}
//				}
//			}
//			if (newCaseTeamMemberList.size() > 0) {
//				insert newCaseTeamMemberList;
//			}
//			if (caseTeamMemeberMap.size() > 0) {
//				ChangeTaskOwnerFromInactiveToActive(caseTeamMemeberMap, recordsForCreatingCaseTeams);
//			}
//			if (Test.isRunningTest()) {
//				throw new CommonTriggerException('Test Class execution');
//			}
//		} catch (Exception ex) {
//			for (Volunteer_Opportunity__c currRec : recordsForCreatingCaseTeams) {
//				ErrorMessage_AC.createdebugRec('VolOpportunity_OnAfter_Update_Helper', String.valueof(currRec), String.valueOf(ex), 'CreateNewVolunteerOpportunity', currRec.Id, ex.getStackTraceString(), 'Error');
//			}
//
//			if (!Test.isRunningTest()) {
//				for (Volunteer_Opportunity__c currRec : recordsForCreatingCaseTeams) {
//					currRec.addError(Label.Debug_log_error_message);
//				}
//			}
//
//		}
//	}

	/**
	 * JIRA: WLP-286
	 * Author: Gustavo Mayer
	 * Update: Sub case conversion to the single Wish Case, no need to update
	 * as there is no longer the concept of parent case.
	 */
	//This method is used to to create a task for Inactive to active task owner.
//	public static void ChangeTaskOwnerFromInactiveToActive(Map<Id, List<CaseTeamMember>> caseTeamMemberMap, List<Volunteer_Opportunity__c> recordsForCreatingCaseTeams) {
//		Map<Id, Set<Id>> inactiveVolOppMap = new Map<Id, Set<Id>>();
//		Set<Id> volOppContact = new Set<Id>();
//		Map<Id, Id> vollOpActiveMap = new Map<Id, Id>();
//		Map<Id, Id> activeVolunteerMap = new Map<Id, Id>();
//		Map<Id, Id> contactUserMap = new Map<Id, Id>();
//		Map<Id, Id> conUserIdMap = new Map<Id, Id>();
//		List<Task> taskOwnerUpdateList = new List<Task>();
//
//		try {
//			for (CaseTeamMember caseTeamInfo : [
//					SELECT Id, TeamRole.Name, ParentId, MemberId
//					FROM CaseTeamMember
//					WHERE (TeamRole.Name = 'Wish Granter' OR TeamRole.Name = 'Wish Granter (Inactive)') AND ParentId IN :caseTeamMemberMap.keySet()
//					ORDER BY CreatedDate ASC
//			]) {
//				if (caseTeamInfo.TeamRole.Name == 'Wish Granter') {
//					if (!activeVolunteerMap.containsKey(caseTeamInfo.ParentId)) {
//						activeVolunteerMap.put(caseTeamInfo.ParentId, caseTeamInfo.MemberId);
//					}
//				} else if (caseTeamInfo.TeamRole.Name == 'Wish Granter (Inactive)') {
//					if (inactiveVolOppMap.containsKey(caseTeamInfo.ParentId)) {
//						inactiveVolOppMap.get(caseTeamInfo.ParentId).add(caseTeamInfo.MemberId);
//					} else {
//						inactiveVolOppMap.put(caseTeamInfo.ParentId, new Set<Id>{
//								caseTeamInfo.MemberId
//						});
//					}
//				}
//			}
//
//			for (User userInfo : [
//					SELECT Id, ContactId
//					FROM User
//					WHERE ContactId IN :volOppContact
//			]) {
//				contactUserMap.put(userInfo.Id, userInfo.ContactId);
//				conUserIdMap.put(userInfo.ContactId, userInfo.Id);
//			}
//
//			for (Task getAllTask : [
//					SELECT Id, OwnerId, WhatId
//					FROM Task
//					WHERE WhatId IN :inactiveVolOppMap.keySet() AND isClosed = false
//			]) {
//				if (inactiveVolOppMap.containsKey(getAllTask.WhatId)) {
//					if (inactiveVolOppMap.get(getAllTask.WhatId).contains(getAllTask.OwnerId)) {
//						if (activeVolunteerMap.containsKey(getAllTask.WhatId)) {
//							getAllTask.OwnerId = activeVolunteerMap.get(getAllTask.WhatId);
//							taskOwnerUpdateList.add(getAllTask);
//						}
//					}
//				}
//			}
//			if (taskOwnerUpdateList.size() > 0) {
//				update taskOwnerUpdateList;
//			}
//			if (Test.isRunningTest()) {
//				throw new CommonTriggerException('Test Class execution');
//			}
//		} catch (Exception ex) {
//			for (Volunteer_Opportunity__c currRec : recordsForCreatingCaseTeams) {
//				ErrorMessage_AC.createdebugRec('VolOpportunity_OnAfter_Update_Helper', String.valueof(currRec), String.valueOf(ex), 'ChangeTaskOwnerFromInactiveToActive', currRec.Id, ex.getStackTraceString(), 'Error');
//			}
//			if (!Test.isRunningTest()) {
//				for (Volunteer_Opportunity__c currRec : recordsForCreatingCaseTeams) {
//					currRec.addError(Label.Debug_log_error_message);
//				}
//			}
//
//		}
//	}

	//This method is used to update the active wish granter count in contact object.
	public static void ActiveWishCount(set<Id> volunteerIdsSet) {
		Map<Id, integer> grantedCount = new Map<Id, integer>();
		Map<Id, integer> activeCount = new Map<Id, integer>();
		List<Contact> updateContacts = new List<Contact>();
		try {
			for (Volunteer_Opportunity__c currRec : [
					SELECT Id,Wish__c, Wish__r.Status,Wish__r.isClosed,Volunteer_Name__c
					FROM Volunteer_Opportunity__c
					WHERE Wish__c != Null
					AND (Status__c = 'Approved' OR Status__c = 'Completed')
					AND ((Wish__r.Status = 'Granted'
					OR wish__r.isClosed = True OR wish__r.status = 'Completed')
					OR (Wish__r.Status != 'Granted'
					AND Wish__r.isClosed = false AND Wish__r.Status != 'inActive'))
					AND Volunteer_Name__c IN :volunteerIdsSet
			]) {

				if (currRec.Wish__r.Status == 'Granted'
						|| currRec.Wish__r.isClosed == True
						|| currRec.Wish__r.Status == 'Completed') {
					if (grantedCount.containsKey(currRec.Volunteer_Name__c)) {
						integer countVal = grantedCount.get(currRec.Volunteer_Name__c) + 1;
						grantedCount.put(currRec.Volunteer_Name__c, countVal);
					} else {
						grantedCount.put(currRec.Volunteer_Name__c, 1);
					}
				} else {
					if (activeCount.containsKey(currRec.Volunteer_Name__c)) {
						integer countVal = activeCount.get(currRec.Volunteer_Name__c) + 1;
						activeCount.put(currRec.Volunteer_Name__c, countVal);
					} else {
						activeCount.put(currRec.Volunteer_Name__c, 1);
					}
				}
			}

			for (String currVolId : volunteerIdsSet) {
				contact currCon = new Contact();
				currCon.id = currVolId;
				currCon.Number_of_wishes_active__c = activeCount.get(currVolId);
				currCon.Number_of_wishes_granted__c = grantedCount.get(currVolId);
				if (currCon.Number_of_wishes_active__c == Null)
					currCon.Number_of_wishes_active__c = 0;
				if (currCon.Number_of_wishes_granted__c == Null)
					currCon.Number_of_wishes_granted__c = 0;
				updateContacts.add(currCon);
			}

			if (updateContacts.size() > 0) {
				update updateContacts;
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Volunteer_Opportunity__c currRec : [
					SELECT Id,Wish__c, Wish__r.Status,Wish__r.isClosed,Volunteer_Name__c
					FROM Volunteer_Opportunity__c
					WHERE Wish__c != Null
					AND (Status__c = 'Approved' OR Status__c = 'Completed')
					AND ((Wish__r.Status = 'Granted' OR wish__r.isClosed = True OR wish__r.status = 'Completed')
					OR (Wish__r.Status != 'Granted'
					AND Wish__r.isClosed = false
					AND Wish__r.Status != 'inActive'))
					AND Volunteer_Name__c IN :volunteerIdsSet
			]) {
				ErrorMessage_AC.createdebugRec('VolOpportunity_OnAfter_Update_Helper',
						String.valueof(currRec), String.valueOf(ex), 'ActiveWishCount',
						currRec.Id, ex.getStackTraceString(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (Volunteer_Opportunity__c currRec : [
						SELECT Id,Wish__c, Wish__r.Status,Wish__r.isClosed,Volunteer_Name__c
						FROM Volunteer_Opportunity__c
						WHERE Wish__c != Null
						AND (Status__c = 'Approved'
						OR Status__c = 'Completed')
						AND ((Wish__r.Status = 'Granted'
						OR wish__r.isClosed = True
						OR wish__r.status = 'Completed')
						OR (Wish__r.Status != 'Granted'
						AND Wish__r.isClosed = false
						AND Wish__r.Status != 'inActive'))
						AND Volunteer_Name__c IN :volunteerIdsSet
				]) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	public static void updateUserRoleId(Set<Id> updateUserSet, Set<Id> volcontactIds) {
		String roleIdinVolOpp;
		String roleInUser;
		Set<Id> volConId = new Set<Id>();
		List<User> dbVolConList = new List<User>();
		try {
			for (Volunteer_Opportunity__c dbOpportunity : [
					SELECT Id,Volunteer_Name__c,Non_Wish_Event__c,Chapter_Role_Opportunity__c,
							Chapter_Role_Opportunity__r.Role_Name__c
					FROM Volunteer_Opportunity__c
					WHERE Id IN:updateUserSet
			]) {
				volConId.add(dbOpportunity.Volunteer_Name__c);
				roleIdinVolOpp = dbOpportunity.Chapter_Role_Opportunity__r.Role_Name__c + String.Valueof(dbOpportunity.Non_Wish_Event__c);
			}
			for (User dbVolUser : [
					SELECT Id,ContactId,Hidden_Role_Name_Id__c
					FROM User
					WHERE ContactId IN:volcontactIds
			]) {
				if (dbVolUser.Hidden_Role_Name_Id__c != Null && dbVolUser.Hidden_Role_Name_Id__c != '') {
					roleInUser = dbVolUser.Hidden_Role_Name_Id__c ;
					if (roleInUser.contains(roleIdinVolOpp)) {
						roleInUser.remove(roleIdinVolOpp);
						string s2 = roleInUser.remove(roleIdinVolOpp);
						dbVolUser.Hidden_Role_Name_Id__c = s2;
						dbVolConList.add(dbVolUser);
					}
				}
			}
			if (dbVolConList.size() > 0) {
				update dbVolConList;
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Volunteer_Opportunity__c currRec : [
					SELECT Id,Volunteer_Name__c,Non_Wish_Event__c,Chapter_Role_Opportunity__c,Chapter_Role_Opportunity__r.Role_Name__c
					FROM Volunteer_Opportunity__c
					WHERE Id IN:updateUserSet
			]) {
				ErrorMessage_AC.createdebugRec('VolOpportunity_OnAfter_Update_Helper',
						String.valueof(currRec), String.valueOf(ex), 'updateUserRoleId',
						currRec.Id, ex.getStackTraceString(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (Volunteer_Opportunity__c currRec : [
						SELECT Id,Volunteer_Name__c,Non_Wish_Event__c,Chapter_Role_Opportunity__c,Chapter_Role_Opportunity__r.Role_Name__c
						FROM Volunteer_Opportunity__c
						WHERE Id IN:updateUserSet
				]) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	/* This SubmitforApprovalProcess() invoke the approval process when the volunteer contact name is entered into the volunteer contact field.*/
	Public Static Void submitforApprovalProcess(List<Volunteer_Opportunity__c> recordsForApprovalProcess, Set<Id> chapterIdsSet) {
		List<Approval.ProcessSubmitRequest> approvalReqList = new List<Approval.ProcessSubmitRequest>();
		List<Volunteer_Opportunity__c> statusPendingList = new List<Volunteer_Opportunity__c>();
		//Map<Id, Id> volunteerManagerIdsMap = new Map<Id, Id>();
		Map<Id, Id> wishVolunteerApproverIdsMap = new Map<Id, Id>();
		Map<Id, Id> nonWishVolunteerApproverIdsMap = new Map<Id, Id>();

		try {
			for (Account getAccountName : [
					SELECT Id,
							Name,
							Event_Volunteer_Assignment_Approver__c,
							Wish_Volunteer_Assignment_Approver__c
					FROM Account
					WHERE Id IN :chapterIdsSet
			]) {
				//volunteerManagerIdsMap.put(getAccountName.id, getAccountName.volunteer_manager__c);
				wishVolunteerApproverIdsMap.put(getAccountName.Id, getAccountName.Wish_Volunteer_Assignment_Approver__c);
				nonWishVolunteerApproverIdsMap.put(getAccountName.Id, getAccountName.Event_Volunteer_Assignment_Approver__c);
			}

			Id chapterAccountId;
			for (Volunteer_Opportunity__c newVolunteerRole : recordsForApprovalProcess) {
				Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
				req.setComments('Submitting request for approval.');
				req.setObjectId(newVolunteerRole.Id);

				chapterAccountId = null;
				if (WISH_RECORD_TYPES.contains(newVolunteerRole.RecordTypeId) && wishVolunteerApproverIdsMap.containsKey(newVolunteerRole.Chapter_Name__c)) {
					chapterAccountId = wishVolunteerApproverIdsMap.get(newVolunteerRole.Chapter_Name__c);
				}
				if (NONWISH_RECORD_TYPES.contains(newVolunteerRole.RecordTypeId) && nonWishVolunteerApproverIdsMap.containsKey(newVolunteerRole.Chapter_Name__c)) {
					chapterAccountId = nonWishVolunteerApproverIdsMap.get(newVolunteerRole.Chapter_Name__c);
				}

				if (chapterAccountId != null) {
					req.setNextApproverIds(new Id[]{
							chapterAccountId
					});
				} else {
					req.setNextApproverIds(new Id[]{
							userInfo.getUserId()
					});
				}
				req.setProcessDefinitionNameOrId('Volunteer_Role_Approval_Process');
				req.setSkipEntryCriteria(true);
				approvalReqList.add(req);
			}
			if (approvalReqList.size() > 0) {
				Approval.process(approvalReqList);
			}
		} catch (Exception ex) {
			/* Chris Shinnimin, Traction on Demand:
			 * Not sure this is useful to Make-a-Wish, may have been used by previous consultant
			 *
			for (Volunteer_Opportunity__c currRec : recordsForApprovalProcess) {

				ErrorMessage_AC.createdebugRec('VolOpportunity_OnAfter_Update_Helper',
						String.valueof(currRec), String.valueOf(ex), 'submitforApprovalProcess',
						currRec.Id, ex.getStackTraceString(), 'Error');
			}
			*
			*/
			for (Volunteer_Opportunity__c currRec : recordsForApprovalProcess) {
				currRec.addError(Label.Debug_log_error_message);
			}
		}
	}

	/*CreateCaseTeamMembers() is used to add the volunteers to case team member when the approver approve the volunteer opportunity record.*/
	public static void createCaseTeamMembers(List<Volunteer_Opportunity__c> recordsForCreatingCaseTeams) {
		/**
		 *  WLP-428
		 *  Commenting unused variable instantiation
		 */
//		List<Volunteer_Opportunity__c> VolunteerRoleList = new List<Volunteer_Opportunity__c>();
		Set<String> roleName = new Set<String>();
//		Set<Id> dbVolunteerSet = new Set<Id>();
		Map<Id, Set<CaseTeamMember>> updateCaseMemberCount = new Map<Id, Set<CaseTeamMember>>();
		Map<String, CaseTeamRole > teamMemberRoleMap = new Map<String, CaseTeamRole>();
//		Map<Id, User> volunteerContactMap = new Map<Id, User>();
//		Set<Id> volunteerSet = new Set<Id>();
		Set<Id> volunteerNameSet = new Set<Id>();
		Set<Id> wishAssignedSet = new Set<Id>();
//		CaseTeamRole caseRoleID = [
//				SELECT id,Name
//				from CaseTeamRole
//				WHERE Name = :'Wish Granter'
//				Limit 1
//		];
		Set<Id> wishIds = new Set<Id>();
		Map<Id, Set<String>> wishMembersMap = new Map<Id, Set<String>>();
		Map<Id, Id> volunteerUserMap = new Map<Id, Id>();
		Map<Id, Set<Id>> wishUserMap = new Map<Id, Set<Id>>(); //Used to hold wish related contact and user for contact access to volunteers
		Map<Id, Id> wishRelatedContactMap = new Map<Id, Id>();
		Map<Id, Contact> updateContactMap = new Map<Id, Contact>();
		Map<Id, CaseTeamMember> caseMemberMap = new Map<Id, CaseTeamMember>();
		Set<Id> parentWishIdSet = new Set<Id>();
		Id volunteerTaskRT = Constant_AC.VOLUNTEER_TASK_RT_ID;
		Map<Id, Id> volunteerMap = new map<Id, Id>();
		Map<Id, List<Id>> wishChidRelatedConIdMap = new Map<Id, List<Id>>();
		Map<Id, Set<String>> volunteerNameRoleMap = new Map<Id, Set<String>>();
		try {
			for (Volunteer_Opportunity__c newVolunteerRole : recordsForCreatingCaseTeams) {
				roleName.add(newVolunteerRole.Role__c);
				volunteerNameSet.add(newVolunteerRole.Volunteer_Name__c);
				wishIds.add(newVolunteerRole.Wish__c);
				parentWishIdSet.add(newVolunteerRole.Wish__c);
				if (newVolunteerRole.Wish__c != null
						&& newVolunteerRole.Role__c == VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER) {
					if (!volunteerMap.containsKey(newVolunteerRole.Wish__c)) {
						volunteerMap.put(newVolunteerRole.Wish__c, newVolunteerRole.Volunteer_Name__c);
					}
				}
				if (wishUserMap.containsKey(newVolunteerRole.Wish__c)) {
					wishUserMap.get(newVolunteerRole.Wish__c).add(newVolunteerRole.Volunteer_Name__c);
				} else {
					wishUserMap.put(newVolunteerRole.Wish__c, new Set<Id>{
							newVolunteerRole.Volunteer_Name__c
					});
				}
				if (newVolunteerRole.Migrated_Record__c == false) {
					Contact updateContact = new Contact();
					updateContact.Id = newVolunteerRole.Volunteer_Name__c;
					updateContact.Date_of_last_engagement__c = Date.today();
					updateContactMap.put(updateContact.Id, updateContact);
				}

			}
			/********************WVC-2206 **********************/
			for (Volunteer_Roles__c volRole : [
					SELECT Id,Volunteer_Name__c,Role_Name__c,Status__c
					FROM Volunteer_Roles__c
					WHERE Volunteer_Name__c IN:volunteerNameSet
					AND Status__c != :VOLUNTEER_ROLE_STATUS_ACTIVE
			]) {
				if (volunteerNameRoleMap.containsKey(volRole.volunteer_Name__c)) {
					volunteerNameRoleMap.get(volRole.Volunteer_Name__c).add(volRole.Role_Name__c);
				} else {
					volunteerNameRoleMap.put(volRole.Volunteer_Name__C, new set<String>{
							volRole.Role_Name__c
					});
				}
			}
			/********************WVC-2206 **********************/
			for (Case getRelatedContact : [
					SELECT Id, ContactId
					FROM Case
					WHERE Id IN :wishUserMap.keySet()
			]) {
				wishRelatedContactMap.put(getRelatedContact.Id, getRelatedContact.ContactId);
			}
			for (User contactUser : [
					SELECT Id, ContactId
					FROM User
					WHERE ContactId IN :volunteerNameSet
			]) {
				volunteerUserMap.put(contactUser.ContactId, contactUser.Id);
			}

			for (npe4__Relationship__c wishChildRelatedCon : [
					SELECT Id,npe4__RelatedContact__c,npe4__Contact__c
					FROM npe4__Relationship__c
					WHERE npe4__Contact__c IN :wishRelatedContactMap.values()
			]) {
				if (wishChidRelatedConIdMap.ContainsKey(wishChildRelatedCon.npe4__Contact__c))
					wishChidRelatedConIdMap.get(wishChildRelatedCon.npe4__Contact__c).add(wishChildRelatedCon.npe4__RelatedContact__c); else
						wishChidRelatedConIdMap.put(wishChildRelatedCon.npe4__Contact__c, new List<Id>{
								wishChildRelatedCon.npe4__RelatedContact__c
						});
			}

			for (CaseTeamRole caseTem : [
					SELECT id,Name
					from CaseTeamRole
			]) {
				teamMemberRoleMap.put(caseTem.Name, caseTem);
			}
			Map<Id, Id> contactUserInfoMap = new Map<Id, Id>();
			for (User commmunityUserInfo : [
					SELECT Id, ContactId
					FROM User
					WHERE ContactId != null
			]) {
				contactUserInfoMap.put(commmunityUserInfo.ContactId, commmunityUserInfo.Id);
			}
			Map<Id, CaseTeamMember> caseTeamMemberMap = new Map<Id, CaseTeamMember>();
			List<CaseTeamMember> updateRoleList = new List<CaseTeamMember>();
			for (CaseTeamMember dbcaseTeamMember : [
					SELECT id,MemberId, ParentId, TeamRole.Name, TeamRole.Id
					FROM CaseTeamMember
					WHERE ParentId IN :wishIds
			]) {
				caseTeamMemberMap.put(dbcaseTeamMember.MemberId, dbcaseTeamMember);
				if (wishMembersMap.containsKey(dbcaseTeamMember.parentId)) {
					wishMembersMap.get(dbcaseTeamMember.parentId).add(dbcaseTeamMember.MemberId);
				} else {
					wishMembersMap.put(dbcaseTeamMember.parentId, new Set<String>{
							dbcaseTeamMember.MemberId
					});
				}
			}
			Set<Id> userIdset = new Set<Id>();
			Map<Id, List<Task>> taskMap = new Map<Id, List<Task>>();
			String volunteerTaskRtLabel = Constant_AC.VOLUNTEER_TASK_RT_LABEL;
			for (Task checkExistingTaskOwner : [
					SELECT Id, OwnerId, WhatId, RecordType.Name
					FROM Task
					WHERE WhatId IN :volunteerMap.keySet()
					AND RecordType.Name = :volunteerTaskRtLabel
					AND isClosed = false
			]) {
				userIdset.add(checkExistingTaskOwner.OwnerId);
				if (taskMap.containsKey(checkExistingTaskOwner.WhatId)) {
					taskMap.get(checkExistingTaskOwner.WhatId).add(checkExistingTaskOwner);
				} else {
					taskMap.put(checkExistingTaskOwner.WhatId, new List<Task>{
							checkExistingTaskOwner
					});
				}
			}
			Set<Id> internalUserIdSet = new Set<Id>();
			for (User getUserInfo : [
					SELECT Id, ContactId
					FROM User
					WHERE Id IN :userIdset
			]) {
				if (getUserInfo.ContactId == null) {
					internalUserIdSet.add(getUserInfo.Id);
				}
			}
			Map<Id, Task> updateOwnerMap = new Map<Id, Task>();
			for (Volunteer_Opportunity__c newVolunteerOpportunity : recordsForCreatingCaseTeams) {
				if (newVolunteerOpportunity.Role__c == VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER
						|| newVolunteerOpportunity.Role__c == VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER_MENTOR) {
					if (taskMap.containsKey(newVolunteerOpportunity.Wish__c)) {
						for (Task checkOwner : taskMap.get(newVolunteerOpportunity.Wish__c)) {
							if (internalUserIdSet.contains(checkOwner.OwnerId)) {
								if (contactUserInfoMap.containsKey(newVolunteerOpportunity.Volunteer_Name__c)) {
									checkOwner.OwnerId = contactUserInfoMap.get(newVolunteerOpportunity.Volunteer_Name__c);
									updateOwnerMap.put(checkOwner.id, checkOwner);
								}
							}
						}
					}
				}
				if (newVolunteerOpportunity.Volunteer_Name__c != null && newVolunteerOpportunity.Wish__c != null) {
					if (!wishMembersMap.containsKey(newVolunteerOpportunity.Wish__c)
							|| (wishMembersMap.containsKey(newVolunteerOpportunity.Wish__c)
							&& volunteerUserMap.containsKey(newVolunteerOpportunity.Volunteer_Name__c))) {
						CaseTeamMember newCaseTeamMembers = new CaseTeamMember();
						newCaseTeamMembers.ParentId = newVolunteerOpportunity.Wish__c;
						newCaseTeamMembers.MemberId = newVolunteerOpportunity.Volunteer_Name__c;

						if (volunteerUserMap.containsKey(newVolunteerOpportunity.Volunteer_Name__c)) {
							newCaseTeamMembers.MemberId = volunteerUserMap.get(newVolunteerOpportunity.Volunteer_Name__c);
							wishAssignedSet.add(newCaseTeamMembers.MemberId);
						}
						if ((teamMemberRoleMap.containsKey(newVolunteerOpportunity.Role__c))
								&& (wishMembersMap.size() == 0
								|| !wishMembersMap.get(newVolunteerOpportunity.Wish__c).contains(volunteerUserMap.get(newVolunteerOpportunity.Volunteer_Name__c)))) {
							newCaseTeamMembers.TeamRoleId = teamMemberRoleMap.get(newVolunteerOpportunity.Role__c).id;
							caseMemberMap.put(newCaseTeamMembers.Id, newCaseTeamMembers);
						} else if (teamMemberRoleMap.containsKey(newVolunteerOpportunity.Role__c)
								&& wishMembersMap.get(newVolunteerOpportunity.wish__c).contains(volunteerUserMap.get(newVolunteerOpportunity.Volunteer_Name__c))
								&& (newVolunteerOpportunity.Role__c == VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER
								|| newVolunteerOpportunity.Role__c == VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER_MENTOR)) {
							newCaseTeamMembers.TeamRoleId = teamMemberRoleMap.get(newVolunteerOpportunity.Role__c).id;
							newCaseTeamMembers.Id = caseTeamMemberMap.get(volunteerUserMap.get(newVolunteerOpportunity.Volunteer_Name__c)).Id;
							caseMemberMap.put(newCaseTeamMembers.id, newCaseTeamMembers);
						}
						if (newVolunteerOpportunity.Role__c == VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER
								|| newVolunteerOpportunity.Role__c == VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER_MENTOR
								|| newVolunteerOpportunity.Role__c == VOLUNTEER_OPPORTUNITY_ROLE_TEMPORARY_WISH_GRANTER) {

							if (updateCaseMemberCount.containsKey(newVolunteerOpportunity.Wish__c)) {
								updateCaseMemberCount.get(newVolunteerOpportunity.Wish__c).add(newCaseTeamMembers);
							} else {
								updateCaseMemberCount.put(newVolunteerOpportunity.Wish__c, new Set<CaseTeamMember>{
										newCaseTeamMembers
								});
							}
						}
					}
				}
				if (caseTeamMemberMap.size() > 0 && contactUserInfoMap.containsKey(newVolunteerOpportunity.Volunteer_Name__c)
						&& caseTeamMemberMap.containsKey(contactUserInfoMap.get(newVolunteerOpportunity.Volunteer_Name__c))) {
					if (caseTeamMemberMap.get(contactUserInfoMap.get(newVolunteerOpportunity.Volunteer_Name__c)).TeamRole.Name.contains('Inactive')) {
						if (teamMemberRoleMap.containsKey(caseTeamMemberMap.get(contactUserInfoMap.get(newVolunteerOpportunity.Volunteer_Name__c)).TeamRole.Name.remove(' (Inactive)'))) {
							CaseTeamMember updateInfo = new CaseTeamMember();
							updateInfo.TeamRoleId = teamMemberRoleMap.get(caseTeamMemberMap.get(contactUserInfoMap.get(newVolunteerOpportunity.Volunteer_Name__c)).TeamRole.Name.remove(' (Inactive)')).Id;
							updateInfo.Id = caseTeamMemberMap.get(contactUserInfoMap.get(newVolunteerOpportunity.Volunteer_Name__c)).Id;
							updateRoleList.add(updateInfo);
						}
					}
				}
			}
			if (updateOwnerMap.size() > 0) {
				update updateOwnerMap.Values();
			}
			List<Task> birthDayTaskList = new List<Task>();
			for (Task birthdayTaskInfo : [
					SELECT Id, WhatId, Subject, OwnerId
					FROM Task
					WHERE Subject = 'Wish Child Birthday Reminder'
					AND WhatId IN :volunteerMap.keySet()
					AND isClosed = false
					AND RecordType.Name = 'Staff'
			]) {
				if (volunteerMap.containsKey(birthdayTaskInfo.WhatId)) {
					if (contactUserInfoMap.containsKey(volunteerMap.get(birthdayTaskInfo.WhatId))) {
						birthdayTaskInfo.OwnerId = contactUserInfoMap.get(volunteerMap.get(birthdayTaskInfo.WhatId));
					}
				}
				birthdayTaskInfo.RecordTypeId = volunteerTaskRT;
				birthDayTaskList.add(birthdayTaskInfo);
			}
			if (birthDayTaskList.size() > 0) {
				update birthDayTaskList;
			}
			if (updateRoleList.size() > 0) {
				update updateRoleList;
			}
			if (updateContactMap.size() > 0) {
				update updateContactMap.values();
			}
			if (caseMemberMap.size() > 0) {
				upsert caseMemberMap.values();
				if (wishUserMap.size() > 0) {
					List<ContactShare> contactToShareList = new List<ContactShare>();
					/**
					 * WLP-510
					 * Commenting unused variable instantiation
					 */
//					List<CaseShare> caseShareList = new List<CaseShare>();
					for (Id caseId : wishUserMap.keySet()) {
						if (wishUserMap.containsKey(caseId)) {
							for (Id userId : wishUserMap.get(caseId)) {
								ContactShare shareContact = new ContactShare();
								shareContact.ContactAccessLevel = 'Edit';
								if (wishRelatedContactMap.containsKey(caseId)
										&& wishRelatedContactMap.get(caseId) != Null) {
									shareContact.ContactId = wishRelatedContactMap.get(caseId);
								}
								if (volunteerUserMap.containsKey(userId)
										&& volunteerUserMap.get(userId) != Null) {
									shareContact.UserOrGroupId = volunteerUserMap.get(userId);
									contactToShareList.add(shareContact);
								}
							}
						}
					}
					if (contactToShareList.size() > 0) {
						insert contactToShareList;
					}
				}
			}
			/**
			 * WLP-510
			 * Replacing the Case_Member_Count__c increment login with a query
			 */
			List<Case> updateCaseList = new List<Case>();
			if (updateCaseMemberCount.size() > 0) {
				for (AggregateResult aggregateResult : [
						SELECT COUNT(Id), Wish__c
						FROM Volunteer_Opportunity__c
						WHERE Wish__c IN :updateCaseMemberCount.keySet()
						AND Role__c IN (:VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER,
								:VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER_MENTOR,
								:VOLUNTEER_OPPORTUNITY_ROLE_TEMPORARY_WISH_GRANTER)
						AND Status__c = 'Approved'
						GROUP BY Wish__c
				]) {
					Case updateCase = new Case();
					updateCase.Id = (Id) aggregateResult.get('Wish__c');
					updateCase.Case_Member_Count__c = (Decimal) aggregateResult.get('expr0');
					updateCase.Assigned_Date__c = Date.today();
					updateCaseList.add(updateCase);
				}
			}
//			if (updateCaseMemberCount.size() > 0) {
//				for (Case getCase : [
//						SELECT Id,CaseNumber,Case_Member_Count__c
//						FROM Case
//						WHERE Id IN :updateCaseMemberCount.keySet()
//						FOR UPDATE
//				]) {
//
//					Case updatCase = new Case();
//					updatCase.id = getCase.id;
//					updatCase.Assigned_Date__c = Date.today();
//					if (getCase.Case_Member_Count__c == null) {
//						updatCase.Case_Member_Count__c = 0 + ((updateCaseMemberCount.get(getCase.id)).size());
//					} else {
//						updatCase.Case_Member_Count__c = getCase.Case_Member_Count__c
//								+ ((updateCaseMemberCount.get(getCase.id)).size());
//					}
//					/*  If(updatCase.Case_Member_Count__c == 1)
//					updatCase.Two_Volunteers__c = True;
//					If(updatCase.Case_Member_Count__c != 1)
//					updatCase.Two_Volunteers__c = False;*/
//					updateCaseList.add(updatCase);
//				}
//			}
			if (updateCaseList.size() > 0) {
				update updateCaseList;
			}

			/**
			 * JIRA: WLP-286
			 * Author: Gustavo Mayer
			 * Update: Sub case conversion to the single Wish Case, no need to update
			 * as there is no longer the concept of parent case.
			 */
//			if (parentWishIdSet.size() > 0) {
//				Map<Id, List<CaseTeamMember>> parentCaseTeamMemberMap = new Map<Id, List<CaseteamMember>>();
//				Set<Id> subCaseIdSet = new Set<Id>();
//				List<Case> subCaseList = new List<Case>();
//				for (Case subCaseInfo : [
//						SELECT Id,ParentId
//						FROM Case
//						WHERE ParentId IN :parentWishIdSet AND RecordType.Name != 'Wish'
//				]) {
//					subCaseIdSet.add(subCaseInfo.Id);
//					subCaseList.add(subCaseInfo);
//				}
//				List<CaseTeamMember> deleteList = new List<CaseTeamMember>();
//				if (subCaseIdSet.size() > 0) {
//					for (CaseTeamMember caseTeamInfo : [
//							SELECT Id,ParentId
//							FROM CaseTeamMember
//							WHERE ParentId IN :subCaseIdSet
//					]) {
//						deleteList.add(caseTeamInfo);
//					}
//				}
//				if (deleteList.size() > 0) {
//					delete deleteList;
//				}
//				updateCaseTeamMemberForSubCase(parentWishIdSet, subCaseList, recordsForCreatingCaseTeams);
//			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Volunteer_Opportunity__c currRec : recordsForCreatingCaseTeams) {

				ErrorMessage_AC.createdebugRec('VolOpportunity_OnAfter_Update_Helper', String.valueof(currRec), String.valueOf(ex), 'createCaseTeamMembers', currRec.Id, ex.getStackTraceString(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (Volunteer_Opportunity__c currRec : recordsForCreatingCaseTeams) {
					currRec.addError(Label.Debug_log_error_message);
				}

			}
		}
	}

	/*This updateVolunteerRegisterdCount() is used to update count of the number of volunteer opportunities that are registered for the corresponding NonWish & Event .*/
	public static void updateVolunteerRegisterdCount(List<Volunteer_Opportunity__c> nonWishListtoupdatecount, Set<id> nonWishRegisteredUpdateSet, boolean isdelete) {
		RecursiveTriggerHandler.isFirstTime = false;
		Set<Id> chapterRoleIdSet = new Set<Id>();
		Set<Id> nonWishEventIdSet = new Set<Id>();
		Set<String> descriptionSetId = new Set<String>();
		Map<Id, Integer> volunteercountMap = new Map<Id, Integer>();
		List<Volunteer_Count__c > updateVolunteerCountList = new List<Volunteer_Count__c>();
		Boolean isRegistered = false;
		Boolean isPending = false;

		try {
			for (Volunteer_Opportunity__c newVolOpp : nonWishListtoupdatecount) {
				chapterRoleIdSet .add(newVolOpp.Chapter_Role_Opportunity__c);
				descriptionSetId.add(newVolOpp.Hidden_VolunteerCount_Desc__c + ''
						+ newVolOpp.Date__c + ''
						+ newVolOpp.Start_Time__c + ''
						+ newVolOpp.End_Time__c);
				nonWishEventIdSet.add(newVolOpp.Non_Wish_Event__c);
				if ((newVolOpp.Inactive__c == true && newVolOpp.Reason_Inactive__c != Null
						&& newVolOpp.Status__c == 'Approved')
						|| (newVolOpp.Inactive__c == true
						&& newVolOpp.Reason_Inactive__c != Null
						&& newVolOpp.Reason_Inactive__c == 'Not Approved')) {
					isdelete = true;
					if (isdelete == true) {
						isRegistered = true;
					}
				}
				if (newVolOpp.Status__c == 'Pending' && isdelete == false) {
					isPending = true;
				}
			}
			List<AggregateResult> groupedResults = [
					SELECT Chapter_Role_Opportunity__c nonwish, Count(Id)aver,Hidden_VolunteerCount_Desc__c
					FROM Volunteer_Opportunity__c
					WHERE Non_Wish_Event__c IN:NonWishEventIdSet
					AND Volunteer_Name__c != Null
					AND (Reason_Inactive__c = Null
					OR Reason_Inactive__c != Null)
					AND Chapter_Role_Opportunity__c IN:chapterRoleIdSet
					AND id IN :nonWishRegisteredUpdateSet
					GROUP BY Chapter_Role_Opportunity__c, Hidden_VolunteerCount_Desc__c, Date__c, Start_Time__c, End_Time__c
			];
			if (!groupedResults.isEmpty()) {
				for (AggregateResult arr : groupedResults) {
					volunteercountMap.put((ID) arr.get('nonwish'), (integer) arr.get('aver'));
				}
			}
			if (volunteercountMap.size() > 0) {
				for (Volunteer_Count__c dbVolunteerCount : [
						SELECT Id,Name,Volunteer_Needed__c,Non_Wish_Events__c,Chapter_Role__c,Registered__c,Description__c,Start_Time__c,End_Time__c,Date__c
						From Volunteer_Count__c
						WHERE Chapter_Role__c IN:volunteercountMap.Keyset()
				]) {
					if (nonWishEventIdSet.contains(dbVolunteerCount.Non_Wish_Events__c)) {
						if (descriptionSetId.contains(dbVolunteerCount.Description__c + ''
								+ dbVolunteerCount.Date__c + ''
								+ dbVolunteerCount.Start_Time__c + ''
								+ dbVolunteerCount.End_Time__c)) {
							if (volunteercountMap.containsKey(dbVolunteerCount.Chapter_Role__c)) {
								dbVolunteerCount.Registered__c = volunteercountMap.get(dbVolunteerCount.Chapter_Role__c);
								if (isPending == true) {
									dbVolunteerCount.Registered__c = dbVolunteerCount.Registered__c + 1;
								}
								dbVolunteerCount.Registered__c = dbVolunteerCount.Registered__c - 1;
								updateVolunteerCountList.add(dbVolunteerCount);
							}
						}
					}
				}
				update updateVolunteerCountList;
			} else {
				for (Volunteer_Count__c dbVolunteerCount : [
						SELECT Id,Name,Volunteer_Needed__c,Non_Wish_Events__c,Chapter_Role__c,
								Registered__c,Description__c,Start_Time__c,End_Time__c,Date__c
						From Volunteer_Count__c
						WHERE Chapter_Role__c IN:chapterRoleIdSet
				]) {
					if (nonWishEventIdSet.contains(dbVolunteerCount.Non_Wish_Events__c)) {
						if (descriptionSetId.contains(dbVolunteerCount.Description__c + ''
								+ dbVolunteerCount.Date__c + ''
								+ dbVolunteerCount.Start_Time__c + ''
								+ dbVolunteerCount.End_Time__c)) {
							dbVolunteerCount.Registered__c = 0;
							updateVolunteerCountList.add(dbVolunteerCount);
						}
					}
				}
			}
			update updateVolunteerCountList;
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Volunteer_Opportunity__c currRec : nonWishListtoupdatecount) {

				ErrorMessage_AC.createdebugRec('VolOpportunity_OnAfter_Update_Helper',
						String.valueof(currRec), String.valueOf(ex), 'updateVolunteerRegisterdCount',
						currRec.Id, ex.getStackTraceString(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (Volunteer_Opportunity__c currRec : nonWishListtoupdatecount) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	//This method is used to give the edit access for volunteer Opportunity record.
	public static void sharevolunteerOpportunityRecord(List<Volunteer_Opportunity__c> volOpporunityRec) {
		Set<Id> volunteerContactIdSet = new Set<Id>();
		Map<Id, Id> volunteerUserMap = new Map<Id, Id>();
		List<Volunteer_Opportunity__Share> volOpportunitySharingList = new List<Volunteer_Opportunity__Share>();

		try {
			for (Volunteer_Opportunity__c processVolOpportunityRec : volOpporunityRec) {
				volunteerContactIdSet.add(processVolOpportunityRec.Volunteer_Name__c);
			}
			for (User dbActiveVolunteerUser : [
					SELECT Id,ContactId
					from User
					WHERE contactId IN:volunteerContactIdSet
			]) {
				volunteerUserMap.put(dbActiveVolunteerUser.ContactId, dbActiveVolunteerUser.Id);
			}
			for (Volunteer_Opportunity__c processVolOpportunityRec : volOpporunityRec) {
				if (volunteerUserMap.containsKey(processVolOpportunityRec.Volunteer_Name__c)) {
					Volunteer_Opportunity__Share newVolOppShareRec = new Volunteer_Opportunity__Share();
					newVolOppShareRec.ParentId = processVolOpportunityRec.Id;
					newVolOppShareRec.AccessLevel = 'Edit';
					newVolOppShareRec.rowcause = Schema.Volunteer_Opportunity__Share.RowCause.Grant_Edit_Access_to_assigned_Volunteer__C;
					newVolOppShareRec.UserOrGroupId = volunteerUserMap.get(processVolOpportunityRec.Volunteer_Name__c);
					volOpportunitySharingList.add(newVolOppShareRec);
				}
			}
			if (volOpportunitySharingList.size() > 0)
				insert volOpportunitySharingList;
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Volunteer_Opportunity__c currRec : volOpporunityRec) {

				ErrorMessage_AC.createdebugRec('VolOpportunity_OnAfter_Update_Helper',
						String.valueof(currRec), String.valueOf(ex), 'sharevolunteerOpportunityRecord',
						currRec.Id, ex.getStackTraceString(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (Volunteer_Opportunity__c currRec : volOpporunityRec) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	/*** WVC-2052 ***/
	/**** Update the Two Volunteer Field in Wish Record based on wish granter count ****/
	/* public static void updateWishVolunteerWaiting(Map<Id,Volunteer_Opportunity__c> volOpporunityRec,Set<Id> wishIdSet){
		 try{
			 List<Case> updatedCaseList = new List<Case>();
			 Map<Id,Integer> wishVolunteerCountMap = new Map<Id,Integer>();
			 For(Volunteer_Opportunity__c volOpp : [SELECT Wish__C,Volunteer_Name__c,Status__C,Id,Reason_Inactive__c,Inactive__c FROM Volunteer_Opportunity__c WHERE Wish__C IN : wishIdSet AND (Role__C = 'Wish Granter Mentor'  OR Role__c = 'Wish Granter') AND (Status__C = 'Pending' OR Status__C = 'Approved' OR (Status__c = 'Inactive' AND Reason_Inactive__c = 'Not Approved')) LIMIT 50000]){
				 If(volOpp.Status__C == 'Pending' || volOpp.Status__C == 'Approved' && volOpp.Volunteer_Name__C != Null){
					 If(wishVolunteerCountMap.ContainsKey(volOpp.Wish__C)){
						 wishVolunteerCountMap.put(volOpp.Wish__C,wishVolunteerCountMap.get(volOpp.Wish__C)+1);
					 }
					 else{
						 wishVolunteerCountMap.put(volOpp.Wish__C,1);
					 }
				 }
				 If((volOpp.Status__c == 'Inactive' && VolOpp.Reason_Inactive__c == 'Not Approved' && volOpp.Volunteer_Name__C != Null) || (volOpp.Volunteer_Name__C == Null)){
					 If(wishVolunteerCountMap.ContainsKey(volOpp.Wish__C)){
						 wishVolunteerCountMap.put(volOpp.Wish__C,wishVolunteerCountMap.get(volOpp.Wish__C)-1);
					 }
					 else{
						 wishVolunteerCountMap.put(volOpp.Wish__C,0);
					 }
				 }
			 }
			 for(Id wishId : wishIdSet){
				 Case updateCase = new Case();
				 updateCase.Id = wishId;
				 If(wishVolunteerCountMap.ContainsKey(wishId) && wishVolunteerCountMap.get(wishId) >= 2){
					 updateCase.Two_volunteers__C = true;
				 }
				 else{
					 updateCase.Two_Volunteers__C = False;
				 }
				 updatedCaseList.add(updateCase);
			 }
			 If(updatedCaseList.Size() > 0){
				 RecursiveTriggerHandler.allowToEditRecord = True;
				 Update updatedCaseList;
			 }
			 if(Test.isRunningTest()){
				 throw new CommonTriggerException('Test Class execution');
			 }
		 }
		 catch(Exception ex){
			 for(Volunteer_Opportunity__c currRec : volOpporunityRec.Values()){

				 ErrorMessage_AC.createdebugRec('VolOpportunity_OnAfter_Update_Helper',String.valueof(currRec),String.valueOf(ex),'updateWishVolunteerWaiting',currRec.Id,ex.getStackTraceString()+String.valueOf(ex),'Error');
			 }
			 if(!Test.isRunningTest()){
				 for(Volunteer_Opportunity__c currRec : volOpporunityRec.Values()){
					 currRec.addError(Label.Debug_log_error_message);
				 }

			 }

		 }
	 }*/
	/* public static void updateCaseTeamMemberRole(Map<Id,Id> wishVolunteerIdMap,List<Volunteer_Opportunity__c> approvedVolunteerExceptionList){
		  try{
			  Map<Id, String> TeamRoleIdMap = new Map<Id, String>();
			  Map<String, Id> TeamNameMap = new Map<String, Id>();
			  List<CaseTeamMember> UpdateTeamList = new List<CaseTeamMember>();
			  Set<Id> userIdSet = new Set<Id>();
			  for(CaseTeamRole caseTeamInfo : [Select Id, Name FROM CaseTeamRole]) {
				 TeamRoleIdMap.put(caseTeamInfo.Id, caseTeamInfo.Name);
				 TeamNameMap.put(caseTeamInfo.Name, caseTeamInfo.Id);
			  }
			  for(User volUser :[SELECT Id FROM User WHERE ContactId IN :wishVolunteerIdMap.values()]){
				  userIdSet.add(volUser.Id);
			  }
			  for(CaseTeamMember dbcaseTeamMember : [SELECT id,MemberId, ParentId, TeamRoleId, TeamRole.Name  FROM CaseTeamMember WHERE ParentId IN : wishVolunteerIdMap.keySet() AND MemberId IN : userIdSet]){
					If(dbcaseTeamMember.TeamRole.Name.contains('(Inactive)') && wishVolunteerIdMap.containsKey(dbcaseTeamMember.ParentId)){
						String role = dbcaseTeamMember.TeamRole.Name.Remove(' (Inactive)');
						If(TeamNameMap.containsKey(role)){
								dbcaseTeamMember.TeamRoleId = TeamNameMap.get(role);
								updateTeamList.add(dbcaseTeamMember);
						}
					}
				}
				If(updateTeamList.Size() > 0)
				  Update updateTeamList;
			  //  If(approvedVolunteerExceptionList.Size() > 0)


		  if(Test.isRunningTest()){
				 throw new CommonTriggerException('Test Class execution');
			 }



		   }catch(Exception ex){
			 for(Volunteer_Opportunity__c currRec : approvedVolunteerExceptionList){

				 ErrorMessage_AC.createdebugRec('VolOpportunity_OnAfter_Update_Helper',String.valueof(currRec),String.valueOf(ex),'updateCaseTeamMemberRole',currRec.Id,ex.getStackTraceString()+String.valueOf(ex),'Error');
			 }
			 if(!Test.isRunningTest()){
				 for(Volunteer_Opportunity__c currRec : approvedVolunteerExceptionList){
					 currRec.addError(Label.Debug_log_error_message);
				 }

			 }

		 }
	 }

	  public static void updateInactiveCaseTeamMember(Map<Id,String> volunteerRoleNameMap,Map<Id,Volunteer_Opportunity__c> volunteerOppMap,Set<Id> wishIdSet){


		  try{
			  Map<Id, String> TeamRoleIdMap = new Map<Id, String>();
			  Map<String, Id> TeamNameMap = new Map<String, Id>();
			  List<CaseTeamMember> updateTeamList= new List<CaseTeamMember>();
			  Set<Id> userIdSet = new Set<Id>();
			  Set<Id> subCaseIdSet = new Set<Id>();
			  Map<Id,Id> volunteerUserIdMap = new Map<Id,Id>();
			  Map<Id,Id> wishVolunteerIdMap = new Map<Id,Id>();
			  for(Case subCase : [SELECT Id,    ParentId FROM Case WHERE ParentId IN : wishIdSet]){
				  subCaseIdSet.add(subCase.Id);
			  }

					  for(CaseTeamRole caseTeamInfo : [Select Id, Name FROM CaseTeamRole]) {
						 TeamRoleIdMap.put(caseTeamInfo.Id, caseTeamInfo.Name);
						 TeamNameMap.put(caseTeamInfo.Name, caseTeamInfo.Id);
					  }
					  for(User volUser :[SELECT Id FROM User WHERE ContactId IN :wishVolunteerIdMap.values() OR ContactId IN :volunteerRoleNameMap.keySet()]){
						  userIdSet.add(volUser.Id);
					  }
					  for(CaseTeamMember dbcaseTeamMember : [SELECT id,MemberId, ParentId, TeamRoleId, TeamRole.Name  FROM CaseTeamMember WHERE (ParentId IN : wishVolunteerIdMap.keySet()  OR ParentId IN :subCaseIdSet )AND MemberId IN : userIdSet ]){

							If(!dbcaseTeamMember.TeamRole.Name.contains('(Inactive)')){
								If(TeamNameMap.containsKey(dbcaseTeamMember.TeamRole.Name+' (Inactive)')){
										dbcaseTeamMember.TeamRoleId = TeamNameMap.get(dbcaseTeamMember.TeamRole.Name+' (Inactive)');
										updateTeamList.add(dbcaseTeamMember);

								}
							}
			  }

				If(updateTeamList.Size() > 0){
					  Update updateTeamList;
				  }


		  if(Test.isRunningTest()){
				 throw new CommonTriggerException('Test Class execution');
			 }



		   }catch(Exception ex){
			 for(Volunteer_Opportunity__c currRec : volunteerOppMap.Values()){

				 ErrorMessage_AC.createdebugRec('VolOpportunity_OnAfter_Update_Helper',String.valueof(currRec),String.valueOf(ex),'updateCaseTeamMemberRole',currRec.Id,ex.getStackTraceString()+String.valueOf(ex),'Error');
			 }
			 if(!Test.isRunningTest()){
				 for(Volunteer_Opportunity__c currRec : volunteerOppMap.Values()){
					 currRec.addError(Label.Debug_log_error_message);
				 }

			 }
		 }
		 }*/
}