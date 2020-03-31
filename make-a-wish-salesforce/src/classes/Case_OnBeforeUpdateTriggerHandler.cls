/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/26/2016
Description : When a new case record updated then it will update the values to corresponding fields and also
it update the field values to related objects like Account, contact, VolunteerOpportunity.
Modification Log:
23/03/2018 - Sankar - WVC-1835
*******************************************************************************************************************/
public class Case_OnBeforeUpdateTriggerHandler {
	private static final Set<Id> WISH_OWNER_CHECK_RECORD_TYPE_IDS = new Set<Id>
	{Constant_AC.WISH_RT_ID, Constant_AC.WISH_ASSIST_RT_ID, Constant_AC.DIAGNOSIS_RT_ID};
	private static final Set<String> DNQ_DATE_STATUSES = new Set<String>{
		Constant_AC.CASE_STATUS_DNQ_NATIONAL_STAFF,
		Constant_AC.CASE_STATUS_DNQ_NATIONAL_MEDICAL_COUNCIL,
		Constant_AC.CASE_STATUS_DNQ_CHAPTER_STAFF,
		Constant_AC.CASE_STATUS_DNQ_CHAPTER_MEDICAL_ADVISOR
	};
	private static final Set<String> IS_LOCKED_STATUSES = new Set<String>
	{Constant_AC.CASE_STATUS_DNQ, Constant_AC.CASE_STATUS_COMPLETED, Constant_AC.CASE_STATUS_CLOSED};

	/*
     * @description		OnBeforeUpdate trigger handler for the Case object
     *
     * @author 			MST Solutions
     * @createdDate		2018-03-23
     */
	public static void OnBeforeUpdate(Map<Id, Case> newCaseMap, Map<Id, Case> oldCaseMap) {
		Id wishRecordTypeId = Constant_AC.WISH_RT_ID;
		Id chapterRecordTypeId = Constant_AC.CHAPTER_RT_ID;
		Id diagnosisVerificationRT = Constant_AC.DIAGNOSIS_RT_ID;
		Id wishAssistRecordTypeId = Constant_AC.WISH_ASSIST_RT_ID;
		UserSetting__c usc = UserSetting__c.getValues(UserInfo.getUserId());
		List<Case> budgetCaseList = new List<Case>();
		List<Case> receiveDateCaseList = new List<Case>();
		Set<Id> wishOwnerIdSet = new Set<Id>();
		Map<Id, Case> caseMap = new Map<Id, Case>();
		Map<Id, Case> parentCaseMap = new Map<Id, Case>();
		Set<Id> contactSet = new Set<Id>();
		Set<Id> parentIdSet = new Set<Id>();
		Map<Id, User> wishOwnerMap = new Map<Id, User>();
		Set<Id> compltedParentIdSet = new Set<Id>();
		Map<Id, Account> managerUserMap = new Map<Id, Account>();
		Map<Id, Case> changedNationalTypeCaseMap = new Map<Id, Case>();

		List<Account> dbAccountList = [
			SELECT Id,MAC_Email_del__c,Name,RecordTypeId
			FROM Account
			WHERE Name = :Constant_AC.ACCOUNT_NAME_MAW_AMERICA
			AND RecordTypeId = :chapterRecordTypeId
			LIMIT 1
		];

		for (Case currentCase : newCaseMap.values()) {
			if (WISH_OWNER_CHECK_RECORD_TYPE_IDS.contains(currentCase.RecordTypeId)) {
				if (currentCase.OwnerId != null && currentCase.OwnerId != oldCaseMap.get(currentCase.Id).OwnerId) {
					wishOwnerIdSet.add(currentCase.OwnerId);
				}
				if (currentCase.Comment_1__c != null && oldCaseMap.get(currentCase.Id).Comment_1__c != currentCase.Comment_1__c) {
					currentCase.Comment__c = currentCase.Comment_1__c;
				}
			}

			if ((Constant_AC.CASE_STATUS_READY_TO_ASSIGN.equals(currentCase.Status))
				&& !Constant_AC.CASE_STATUS_READY_TO_ASSIGN.equals(oldCaseMap.get(currentCase.Id).Status)
				&& currentCase.RecordTypeId == wishRecordTypeId) {

				caseMap.put(currentCase.ChapterName__c, currentCase);
				currentCase.Ready_to_Assign_Date__c = Date.today();
				parentCaseMap.put(currentCase.Id, currentCase);
				contactSet.add(currentCase.ContactId);
			}

			if (Constant_AC.CASE_STATUS_READY_TO_INTERVIEW.equals(currentCase.Status)
				&& Constant_AC.CASE_STATUS_READY_TO_ASSIGN.equals(oldCaseMap.get(currentCase.Id).Status)
				&& currentCase.RecordTypeId == wishRecordTypeId) {

				currentCase.Sub_Status__c = Constant_AC.CASE_SUB_STATUS_PENDING;
			}

			if (currentCase.RecordTypeId == diagnosisVerificationRT
				&& Constant_AC.CASE_STATUS_ESCALATED.equals(currentCase.Status)
				&& Constant_AC.CASE_STATUS_ESCALATED.equals(oldCaseMap.get(currentCase.Id).Status)
				&& currentCase.Case_Comment__c != oldCaseMap.get(currentCase.Id).Case_Comment__c) {

				currentCase.isNationalReply__c = true;
			}

			if (currentCase.Comment_1__c != oldCaseMap.get(currentCase.Id).Comment_1__c
				&& currentCase.RecordTypeId == wishRecordTypeId) {

				currentCase.Air_Travel_Details__c = Label.CaseTrigger_Air_Travel_Aware;
			}

			if (currentCase.Appropriate_Comments__c != oldCaseMap.get(currentCase.Id).Appropriate_Comments__c
				&& currentCase.RecordTypeId == wishRecordTypeId) {

				currentCase.Wish_Clearance__c = Constant_AC.CASE_WISH_CLEARANCE_APPROPRIATE;
			}

			if (currentCase.Please_Explain__c != oldCaseMap.get(currentCase.Id).Please_Explain__c
				&& currentCase.RecordTypeId == wishRecordTypeId) {

				currentCase.Wish_Clearance__c = Constant_AC.CASE_WISH_CLEARANCE_NOT_APPROPRIATE;
			}

			if (currentCase.RecordTypeId == wishRecordTypeId
				&& Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null
				&& Constant_AC.CASE_STATUS_WISH_DETERMINED.equals(currentCase.Status)
				&& currentCase.Wish_Type__c == null) {

				currentCase.Wish_Type__c.addError(Label.CaseTrigger_Enter_Wish_Type);
			}

			if (currentCase.RecordTypeId == wishRecordTypeId
				&& Constant_AC.CASE_STATUS_WISH_DETERMINED.equals(currentCase.Status)
				&& currentCase.Wish_Type__c != null) {

				caseMap.put(currentCase.ChapterName__c, currentCase);
			}

			//Update the wish clearance needed when the wish national type is changed.
			if (currentCase.RecordTypeId == wishRecordTypeId
				&& currentCase.Wish_Type__c != null
				&& currentCase.Wish_Type__c != oldCaseMap.get(currentCase.Id).Wish_Type__c) {

				changedNationalTypeCaseMap.put(currentCase.Id, currentCase);
			}

			/* Used to close the wish determine case and open the new planning and Granting and Impact sub cases will open. */
			if (Constant_AC.CASE_STATUS_WISH_DETERMINED.equals(currentCase.Status)
				&& currentCase.Wish_Type__c != null
				&& currentCase.RecordTypeId == wishRecordTypeId) {

				currentCase.Meet_PWL_Criteria__c = Constant_AC.MEET_PWL_CRITERIA_YES;
				currentCase.Concept_Approval_Date__c = Date.today();
			}

			if (Constant_AC.CASE_STATUS_WISH_DETERMINED.equals(currentCase.Status)
				&& !Constant_AC.CASE_STATUS_WISH_DETERMINED.equals(oldCaseMap.get(currentCase.Id).Status)
				&& currentCase.RecordTypeId == wishRecordTypeId) {

				currentCase.Wish_Determined_Date__c = System.today();
			}

			if (currentCase.RecordTypeId == wishRecordTypeId
				&& (Constant_AC.CASE_STATUS_PENDING_APPROVAL.equals(currentCase.Status)
				&& !Constant_AC.CASE_STATUS_PENDING_APPROVAL.equals(oldCaseMap.get(currentCase.Id).Status))) {

				currentCase.Sub_Status__c = null;
			}

			if (Constant_AC.CASE_STATUS_ESCALATED.equals(currentCase.Status)
				&& currentCase.RecordTypeId == diagnosisVerificationRT
				&& !Constant_AC.CASE_STATUS_ESCALATED.equals(oldCaseMap.get(currentCase.Id).Status)) {

				currentCase.isNational__c = true;
				currentCase.MAC_Email__c = dbAccountList[0].MAC_Email_del__c;
			}

			if (DNQ_DATE_STATUSES.contains(currentCase.Status)
				&& currentCase.RecordTypeId == diagnosisVerificationRT) {

				currentCase.DNQ_Date__c = Date.today();
			}

			if ((Constant_AC.CASE_STATUS_COMPLETED.equals(currentCase.Status))
				&& (!Constant_AC.CASE_STATUS_COMPLETED.equals(oldCaseMap.get(currentCase.Id).Status))
				&& currentCase.RecordTypeId == wishRecordTypeId) {

				budgetCaseList.add(currentCase);
			}

			if (currentCase.RecordTypeId == wishRecordTypeId
				&& currentCase.Status != oldCaseMap.get(currentCase.Id).Status
				&& ((Constant_AC.CASE_STATUS_GRANTED.equals(currentCase.Status)
				&& (Constant_AC.CASE_STATUS_WISH_SCHEDULED.equals(oldCaseMap.get(currentCase.Id).Status)))
				|| ((Constant_AC.CASE_STATUS_COMPLETED.equals(currentCase.Status))
				&& (!Constant_AC.CASE_STATUS_COMPLETED.equals(oldCaseMap.get(currentCase.Id).Status))))) {

				receiveDateCaseList.add(currentCase);
			}

			if (IS_LOCKED_STATUSES.contains(currentCase.Status)
				&& currentCase.RecordTypeId == wishRecordTypeId) {

				currentCase.IsLocked__c = true;
			}

			if ((!Constant_AC.CASE_STATUS_DNQ.equals(currentCase.Status)
				&& Constant_AC.CASE_STATUS_DNQ.equals(oldCaseMap.get(currentCase.Id).Status))
				|| (!Constant_AC.CASE_STATUS_COMPLETED.equals(currentCase.Status)
				&& Constant_AC.CASE_STATUS_COMPLETED.equals(oldCaseMap.get(currentCase.Id).Status))
				|| (!Constant_AC.CASE_STATUS_CLOSED.equals(currentCase.Status)
				&& Constant_AC.CASE_STATUS_CLOSED.equals(oldCaseMap.get(currentCase.Id).Status))
				|| (currentCase.IsClosed == false
				&& oldCaseMap.get(currentCase.Id).IsClosed == true) &&
				currentCase.RecordTypeId == wishRecordTypeId) {

				currentCase.IsLocked__c = false;
			}

			Boolean userHasRestrictedPermissionOnCase = CaseService.userHasRestrictedPermissionOnCase();
			if ((currentCase.RecordTypeId == wishRecordTypeId || currentCase.RecordTypeId == wishAssistRecordTypeId
				|| currentCase.ParentId != null) && userHasRestrictedPermissionOnCase) {

				parentIdSet.add(currentCase.ParentId);
			}

			if (currentCase.IsLocked__c == true
				&& oldCaseMap.get(currentCase.Id).IsLocked__c == true
				&& usc != null) {
				if (usc.All_Closed_Cases_except_Abandoned__c == false
					&& currentCase.IsClosed == true
					&& userHasRestrictedPermissionOnCase
					&& currentCase.RecordTypeId == wishRecordTypeId
					&& (!(Constant_AC.CASE_STATUS_COMPLETED.equals(currentCase.Status)
					&& (currentCase.Adoptable__c != oldCaseMap.get(currentCase.Id).Adoptable__c
					|| currentCase.Adopted__c != oldCaseMap.get(currentCase.Id).Adopted__c
					|| currentCase.Adopted_By__c != oldCaseMap.get(currentCase.Id).Adopted_By__c)))) {

					currentCase.addError(Label.CaseTrigger_Permission_Error);
				}

				if (usc.Edit_Abandoned_Cases__c == false
					&& currentCase.IsClosed == true
					&& userHasRestrictedPermissionOnCase
					&& currentCase.RecordTypeId == wishRecordTypeId) {

					currentCase.addError(Label.CaseTrigger_Permission_Error);
				}
			} else if (currentCase.IsLocked__c == true
				&& oldCaseMap.get(currentCase.Id).IsLocked__c == true
				&& userHasRestrictedPermissionOnCase
				&& currentCase.RecordTypeId == wishRecordTypeId
				&& (!(Constant_AC.CASE_STATUS_COMPLETED.equals(currentCase.Status)
				&& (currentCase.Adoptable__c != oldCaseMap.get(currentCase.Id).Adoptable__c
				|| currentCase.Adopted__c != oldCaseMap.get(currentCase.Id).Adopted__c
				|| currentCase.Adopted_By__c != oldCaseMap.get(currentCase.Id).Adopted_By__c)))) {

				currentCase.addError(Label.CaseTrigger_Permission_Error);
			}

			if (Constant_AC.CASE_SUB_STATUS_ABANDONED.equals(currentCase.Sub_Status__c)
				&& Constant_AC.CASE_STATUS_GRANTED.equals(oldCaseMap.get(currentCase.Id).Status)
				&& usc == null
				&& Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null
				&& currentCase.RecordTypeId == wishRecordTypeId) {

				currentCase.addError(Label.CaseTrigger_Permission_Error_Abandoned);
			} else if (Constant_AC.CASE_SUB_STATUS_ABANDONED.equals(currentCase.Sub_Status__c)
				&& Constant_AC.CASE_STATUS_GRANTED.equals(oldCaseMap.get(currentCase.Id).Status)
				&& usc != null
				&& Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null
				&& currentCase.RecordTypeId == wishRecordTypeId) {
				if (usc.Abandon_the_Granted_case__c == false) {

					currentCase.addError(Label.CaseTrigger_Permission_Error_Abandoned);
				}
			}

			if (Constant_AC.CASE_STATUS_INACTIVE.equals(currentCase.Status)
				&& !Constant_AC.CASE_STATUS_INACTIVE.equals(oldCaseMap.get(currentCase.Id).Status)
				&& currentCase.RecordTypeId == wishRecordTypeId) {

				currentCase.Inactive_Date__c = Date.today();
			} else if ((Constant_AC.CASE_STATUS_CLOSED.equals(currentCase.Status)
				|| Constant_AC.CASE_STATUS_COMPLETED.equals(currentCase.Status))
				&& Constant_AC.CASE_STATUS_GRANTED.equals(oldCaseMap.get(currentCase.Id).Status)
				&& currentCase.RecordTypeId == wishRecordTypeId) {

				currentCase.Completed_Date__c = Date.today();
			}
			if (Constant_AC.CASE_SUB_STATUS_ABANDONED.equals(currentCase.Sub_Status__c)
				&& !Constant_AC.CASE_SUB_STATUS_ABANDONED.equals(currentCase.Sub_Status__c)
				&& currentCase.RecordTypeId == wishRecordTypeId) {

				currentCase.Closed_Date__c = Date.today();
			}
		}

		if (wishOwnerIdSet.size() > 0) {
			for (User wishOwner : [
				SELECT Id,ManagerId,Manager.Name,Manager.Email,Email
				FROM User
				WHERE Id IN :wishOwnerIdSet AND ManagerId != null
				LIMIT 50000
			]) {
				wishOwnerMap.put(wishOwner.Id, wishOwner);
			}
		}

		if (parentIdSet.size() > 0) {
			for (Case parentCase : [
				SELECT Id,Status
				FROM Case
				WHERE Status = :Constant_AC.CASE_STATUS_COMPLETED
				AND Id IN :parentIdSet
				AND RecordTypeId = :wishRecordTypeId
				LIMIT 50000
			]) {
				compltedParentIdSet.add(parentCase.Id);
			}
		}

		for (Case newCase : newCaseMap.values()) {
			if (wishOwnerMap.containsKey(newCase.OwnerId)) {
				if (wishOwnerMap.get(newCase.OwnerId).ManagerId != null && newCase.RecordTypeId == wishRecordTypeId) {
					newCase.Hidden_Wish_Owner_Manager__c = wishOwnerMap.get(newCase.OwnerId).Manager.Name;
					newCase.Hidden_Wish_Owner_Email__c = wishOwnerMap.get(newCase.OwnerId).Manager.Email;
				}
			}

			if (compltedParentIdSet.contains(newCase.ParentId)) {
				newCase.addError(Label.CaseTrigger_Permission_Error);
			}
		}

		// Case Owner Old Logic
		if (caseMap.size() > 0) {
			for (Account currentAccount : [
				SELECT Id,Volunteer_Manager__c,Wish_Co_ordinator__c
				FROM Account
				WHERE Id IN:caseMap.keySet()
				LIMIT 50000
			]) {
				managerUserMap.put(currentAccount.Id, currentAccount);
			}
		}

		if (changedNationalTypeCaseMap.size() > 0) {
			Case_OnBeforeUpdateTriggerHandlerHelper.updateWishClearanceNeeded(changedNationalTypeCaseMap);
		}
		if (parentCaseMap.size() > 0) {
			Case_OnBeforeUpdateTriggerHandlerHelper.wishChildRegionValidation(parentCaseMap, contactSet);
		}
		if (budgetCaseList.size() > 0) {
			Case_OnBeforeUpdateTriggerHandlerHelper.checkBudgetActuals(budgetCaseList);
		}
		if (receiveDateCaseList.size() > 0) {
			Case_OnBeforeUpdateTriggerHandlerHelper.checkReceivedDates(receiveDateCaseList);
		}
	}
}