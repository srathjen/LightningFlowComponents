/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/26/2016
Description : When a new case record updated then it will update the values to corresponding fields and also
it update the field values to related objects like Account, contact, VolunteerOpportunity.
Modification Log:
23/03/2018 - Sankar - WVC-1835
*******************************************************************************************************************/
public class Case_OnBeforeUpdateTriggerHandler {

	private static final String ACCOUNT_NAME_MAW_AMERICA = Constant_AC.ACCOUNT_NAME_MAW_AMERICA;
	private static final String CASE_STATUS_WISH_DETERMINED = Constant_AC.CASE_STATUS_WISH_DETERMINED;
	private static final String CASE_STATUS_WISH_SCHEDULED = Constant_AC.CASE_STATUS_WISH_SCHEDULED;
	private static final String CASE_STATUS_PENDING_APPROVAL = Constant_AC.CASE_STATUS_PENDING_APPROVAL;
	private static final String CASE_STATUS_CLOSED = Constant_AC.CASE_STATUS_CLOSED;
	private static final String CASE_STATUS_COMPLETED = Constant_AC.CASE_STATUS_COMPLETED;
	private static final String CASE_STATUS_GRANTED = Constant_AC.CASE_STATUS_GRANTED;
	private static final String CASE_STATUS_DNQ = Constant_AC.CASE_STATUS_DNQ;
	public static final String CASE_STATUS_DNQ_NATIONAL_STAFF = Constant_AC.CASE_STATUS_DNQ_NATIONAL_STAFF;
	public static final String CASE_STATUS_DNQ_NATIONAL_MEDICAL_COUNCIL = Constant_AC.CASE_STATUS_DNQ_NATIONAL_MEDICAL_COUNCIL;
	public static final String CASE_STATUS_DNQ_CHAPTER_STAFF = Constant_AC.CASE_STATUS_DNQ_CHAPTER_STAFF;
	public static final String CASE_STATUS_DNQ_CHAPTER_MEDICAL_ADVISOR = Constant_AC.CASE_STATUS_DNQ_CHAPTER_MEDICAL_ADVISOR;
	private static final String CASE_STATUS_INACTIVE = Constant_AC.CASE_STATUS_INACTIVE;
	private static final String CASE_STATUS_ESCALATED = Constant_AC.CASE_STATUS_ESCALATED;
	private static final String CASE_STATUS_READY_TO_ASSIGN = Constant_AC.CASE_STATUS_READY_TO_ASSIGN;
	private static final String CASE_STATUS_READY_TO_INTERVIEW = Constant_AC.CASE_STATUS_READY_TO_INTERVIEW;
	private static final String CASE_SUB_STATUS_PENDING = Constant_AC.CASE_SUB_STATUS_PENDING;
	private static final String CASE_SUB_STATUS_ABANDONED = Constant_AC.CASE_SUB_STATUS_ABANDONED;
	private static final String CASE_WISH_CLEARANCE_APPROPRIATE = Constant_AC.CASE_WISH_CLEARANCE_APPROPRIATE;
	private static final String CASE_WISH_CLEARANCE_NOT_APPROPRIATE = Constant_AC.CASE_WISH_CLEARANCE_NOT_APPROPRIATE;
	private static final String MEET_PWL_CRITERIA_YES = Constant_AC.MEET_PWL_CRITERIA_YES;

	/**********************************************************************************************************************
	This method is used to get the case records new values and old values and those values are added into collections
	then it will passed to the coressponding controller method.
	*******************************************************************************************************************/
	public static void OnBeforeUpdate(Map<Id, Case> newCaseMap, Map<Id, Case> oldCaseMap) {
		/**
		 * WLP-428
		 * Commenting unused variables being instantiated
		 */
		Id wishRecordTypeId = Constant_AC.WISH_RT_ID;
		Id chapterRecordTypeId = Constant_AC.CHAPTER_RT_ID;
		Id diagnosisVerificationRT = Constant_AC.DIAGNOSIS_RT_ID;
		Id wishAssistRecordTypeId = Constant_AC.WISH_ASSIST_RT_ID;
		UserSetting__c usc = UserSetting__c.getValues(UserInfo.getUserId());
		List<Case> budgetCaseList = new List<Case>();
		List<Case> receiveDateCaseList = new List<Case>();
		Set<Id> wishOwnerIdSet = new Set<Id>();
//		Map<String, Case> wishChildInfoMap = new Map<String, case>();
		Map<Id, Case> caseMap = new Map<Id, Case>();
		Map<Id, Case> parentCaseMap = new Map<Id, Case>();
		Set<Id> contactSet = new Set<Id>();
//		Set<Id> parentWishIdsSet = new Set<Id>();
//		List<Case>updateChildCaseList = new List<Case>();
//		Set<Id> parentGrantedIdSet = new Set<Id>();
		Set<Id> parentIdSet = new Set<Id>();
		Map<Id, User> wishOwnerMap = new Map<Id, User>();
		Set<Id> compltedParentIdSet = new Set<Id>();
		Map<Id, Account> managerUserMap = new Map<Id, Account>();
		//Map<Id, contact> contactMap = new Map<Id, Contact>();
		//Set<Id> contactIds = new Set<Id>();
		Map<Id, Case> changedNationalTypeCaseMap = new Map<Id, Case>();
//		Profile dbprofile = [
//				SELECT Id, Name
//				FROM Profile
//				WHERE Id = :userinfo.getProfileId()
//				LIMIT 1
//		];
		List<Account> dbAccountList = [
				SELECT Id,MAC_Email_del__c,Name,RecordTypeId
				FROM Account
				WHERE Name = :ACCOUNT_NAME_MAW_AMERICA
				AND RecordTypeId = :chapterRecordTypeId
				LIMIT 1
		];
//		User currUser = [
//				SELECT Id,UserRole.Name
//				FROM User
//				WHERE Id = :UserInfo.getUserId()
//				LIMIT 1
//		];
//		List<Chapter_Vs_Role__c> currUserChapter = [
//				SELECT Chapter_Name__c
//				FROM Chapter_Vs_Role__c
//				WHERE Role_Name__c = :currUser.UserRole.Name
//				LIMIT 1
//		];
		for (Case currentCase : newCaseMap.values()) {
			/**
			 * WLP-428
			 * Simplifying if statement
			 */
//			if (currentCase.RecordTypeId == wishRecordTypeId
//					|| currentCase.RecordTypeId == wishAssistRecordTypeId
//					|| currentCase.RecordTypeId == diagnosisVerificationRT)
//				if (currentCase.RecordTypeId == wishRecordTypeId) {
			if (currentCase.RecordTypeId == wishRecordTypeId
					|| currentCase.RecordTypeId == wishAssistRecordTypeId
					|| currentCase.RecordTypeId == diagnosisVerificationRT) {
				if (currentCase.OwnerId != null
						&& currentCase.OwnerId != oldCaseMap.get(currentCase.Id).OwnerId) {
					wishOwnerIdSet.add(currentCase.OwnerId);
				}
				if (currentCase.Comment_1__c != null
						&& oldCaseMap.get(currentCase.Id).Comment_1__c != currentCase.Comment_1__c) {
					currentCase.Comment__c = currentCase.Comment_1__c;
				}
				/**
				 * WLP-333
				 */
				// 	else if (currentCase.Comment_2__c != Null
				// 			&& oldCaseMap.get(currentCase.id).Comment_2__c != currentCase.Comment_2__c) {
				// 		currentCase.Comment__c = currentCase.Comment_2__c;
				// 	}
				// 	else if (currentCase.Comments__c != Null
				// 			&& oldCaseMap.get(currentCase.id).Comments__c != currentCase.Comments__c) {
				// 		currentCase.Comment__c = currentCase.Comments__c;
				// 	}
			}
			if ((CASE_STATUS_READY_TO_ASSIGN.equals(currentCase.Status))
					&& !CASE_STATUS_READY_TO_ASSIGN.equals(oldCaseMap.get(currentCase.Id).Status)
					&& currentCase.RecordTypeId == wishRecordTypeId) {
				caseMap.put(currentCase.ChapterName__c, currentCase);
				currentCase.Ready_to_Assign_Date__c = Date.today();
				parentCaseMap.put(currentCase.Id, currentCase);
				contactSet.add(currentCase.ContactId);
			}
			/**
			 * WLP-428
			 * Deprecating the Hidden_bypass_Validation__c field
			 */
//			if (currentCase.RecordTypeId == wishRecordTypeId
//					&& (currentCase.status == 'Ready to Interview'
//					|| currentCase.status == 'Wish Determined')
//					&& oldCaseMap.get(currentCase.Id).Status == 'Ready to Assign'
//					&& (!currentCase.Wish_Assist__c) && currentCase.Case_Member_Count__c < 2
//					&& currentCase.Hidden_bypass_Validation__c != 'Proceed Rush Wish') {
//				If (currentCase.status == 'Ready to Interview')
//					currentCase.Hidden_bypass_Validation__c = 'Ready to Interview/' + currentCase.Sub_Status__c; else If (currentCase.status == 'Wish Determined' && (currentCase.Sub_Status__c == Null
//						|| currentCase.Sub_Status__c == ''))
//					currentCase.adderror('You should enter value for sub status when the status is Wish Determined.'); else currentCase.Hidden_bypass_Validation__c = 'Wish Determined/' + currentCase.Sub_Status__c;
//				// currentCase.addError('<html><head><script>alert(\'Test\');</script></head></html>');
//				currentCase.Status = oldCaseMap.get(currentCase.Id).Status;
//				currentCase.Sub_Status__c = oldCaseMap.get(currentCase.Id).Sub_Status__c;
//			}
//			If (currentCase.RecordTypeId == wishRecordTypeId && (currentCase.status == 'Ready to Interview'
//					|| currentCase.status == 'Wish Determined')
//					&& oldCaseMap.get(currentCase.Id).Status == 'Ready to Assign'
//					&& (!currentCase.Wish_Assist__c) && currentCase.Case_Member_Count__c < 2
//					&& currentCase.Hidden_bypass_Validation__c == 'Proceed Rush Wish') {
//				currentCase.Hidden_bypass_Validation__c = '';
//			}
			/**
			 * WLP-428
			 * Deprecating Hidden_bypass_Validation__c field
			 */
//			if (currentCase.RecordTypeId == wishRecordTypeId
//					&& (currentCase.Status == 'Ready to Interview'
//					|| currentCase.Status == 'Wish Determined')
//					&& oldCaseMap.get(currentCase.Id).Status == 'Ready to Assign'
//					&& (!currentCase.Wish_Assist__c) && currentCase.Case_Member_Count__c < 2
//					&& currentCase.Hidden_bypass_Validation__c == 'Proceed Rush Wish') {
//				currentCase.Hidden_bypass_Validation__c = '';
//			}

			/**
			 * WLP-333
			 */
//			if ((!currentCase.Rush__c) && oldCaseMap.get(currentCase.Id).Rush__c == True
//					&& currentCase.RecordTypeId == wishRecordTypeId) {
//				currentCase.Rush_Timeframe__c = Null;
//				currentCase.Rush_Explanation__c = Null;
//			}

			/*
			if (currentCase.status == 'Hold'
					&& currentCase.status != oldCaseMap.get(currentCase.Id).Status
					&& currentCase.RecordTypeId == wishRecordTypeId
					&& (oldCaseMap.get(currentCase.Id).Status != 'Hold'
					|| oldCaseMap.get(currentCase.Id).Status != 'Budget Approval - Approved'
					|| oldCaseMap.get(currentCase.Id).Status != 'Budget Approval - Submitted')) {
				currentCase.Hidden_Hold_Status_Value__c = oldCaseMap.get(currentCase.Id).Status;
			}
			if (currentCase.status == 'Inactive' && currentCase.status != oldCaseMap.get(currentCase.Id).Status
					&& currentCase.RecordTypeId == wishRecordTypeId
					&& (oldCaseMap.get(currentCase.Id).Status != 'Inactive'
					|| oldCaseMap.get(currentCase.Id).Status != 'Budget Approval - Approved'
					|| oldCaseMap.get(currentCase.Id).Status != 'Budget Approval - Submitted')) {
				currentCase.Hidden_Hold_Status_Value__c = oldCaseMap.get(currentCase.Id).Status;
			}
			if (currentCase.status == 'Closed' && currentCase.status != oldCaseMap.get(currentCase.Id).Status
					&& currentCase.RecordTypeId == wishRecordTypeId
					&& (oldCaseMap.get(currentCase.Id).Status != 'Closed'
					|| oldCaseMap.get(currentCase.Id).Status != 'Budget Approval - Approved'
					|| oldCaseMap.get(currentCase.Id).Status != 'Budget Approval - Submitted')) {
				currentCase.Hidden_Hold_Status_Value__c = oldCaseMap.get(currentCase.Id).Status;
			}
			if (currentCase.status == 'DNQ' && currentCase.status != oldCaseMap.get(currentCase.Id).Status
					&& currentCase.RecordTypeId == wishRecordTypeId
					&& (oldCaseMap.get(currentCase.Id).Status != 'DNQ'
					|| oldCaseMap.get(currentCase.Id).Status != 'Budget Approval - Approved'
					|| oldCaseMap.get(currentCase.Id).Status != 'Budget Approval - Submitted')) {
				currentCase.Hidden_Hold_Status_Value__c = oldCaseMap.get(currentCase.Id).Status;
			}*/
			if (CASE_STATUS_READY_TO_INTERVIEW.equals(currentCase.Status)
					&& CASE_STATUS_READY_TO_ASSIGN.equals(oldCaseMap.get(currentCase.Id).Status)
					&& currentCase.RecordTypeId == wishRecordTypeId) {
				currentCase.Sub_Status__c = CASE_SUB_STATUS_PENDING;
			}
			/**
			 * WLP-333
			 */
			/*if (currentCase.RecordTypeId == diagnosisVerificationRT && currentCase.Local_MCA_Team__c
					!= oldCaseMap.get(currentCase.Id).Local_MCA_Team__c) {
				currentCase.Chapter_MACEmail__c = currentCase.Medical_Advisor_Email__c;
			}*/
			if (currentCase.RecordTypeId == diagnosisVerificationRT
					&& CASE_STATUS_ESCALATED.equals(currentCase.Status)
					&& CASE_STATUS_ESCALATED.equals(oldCaseMap.get(currentCase.Id).Status)
					&& currentCase.Case_Comment__c != oldCaseMap.get(currentCase.Id).Case_Comment__c) {
				currentCase.isNationalReply__c = true;
			}
// 			if (currentCase.Comments__c != oldCaseMap.get(currentCase.Id).Comments__c
// 					&& currentCase.RecordTypeId == wishRecordTypeId)
// 				currentCase.Air_Travel_Details__c = 'This wish does not involve air travel';
			if (currentCase.Comment_1__c != oldCaseMap.get(currentCase.Id).Comment_1__c
					&& currentCase.RecordTypeId == wishRecordTypeId) {
				currentCase.Air_Travel_Details__c = 'I am fully aware of the medical research regarding air travel and feel it is appropriate for this child. I will make any necessary adjustments to the medical treatment plan prior to their travel dates';
			}
// 			if (currentCase.Comment_2__c != oldCaseMap.get(currentCase.Id).Comment_2__c
// 					&& currentCase.RecordTypeId == wishRecordTypeId)
// 				currentCase.Air_Travel_Details__c = 'I do not support air travel for this child';
			if (currentCase.Appropriate_Comments__c != oldCaseMap.get(currentCase.Id).Appropriate_Comments__c
					&& currentCase.RecordTypeId == wishRecordTypeId) {
				currentCase.Wish_Clearance__c = CASE_WISH_CLEARANCE_APPROPRIATE;
			}
			if (currentCase.Please_Explain__c != oldCaseMap.get(currentCase.Id).Please_Explain__c
					&& currentCase.RecordTypeId == wishRecordTypeId) {
				currentCase.Wish_Clearance__c = CASE_WISH_CLEARANCE_NOT_APPROPRIATE;
			}
			/**
			 * WLP-428
			 * Deprecating Sub Status when Status is Wish Determined
			 */
			if (currentCase.RecordTypeId == wishRecordTypeId
					&& Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null
					&& CASE_STATUS_WISH_DETERMINED.equals(currentCase.Status)
//					&& currentCase.Sub_Status__c == 'Within Policy'
					&& currentCase.Wish_Type__c == null) {
				currentCase.Wish_Type__c.addError('Please Enter the value for Wish Type');
			}
			/**
			 * WLP-428
			 * Deprecating Sub Status when Status is Wish Determined
			 */
			if (currentCase.RecordTypeId == wishRecordTypeId
					&& CASE_STATUS_WISH_DETERMINED.equals(currentCase.Status)
//					&& currentCase.Sub_Status__c == 'Within Policy'
					&& currentCase.Wish_Type__c != null) {
				caseMap.put(currentCase.ChapterName__c, currentCase);
			}
			//Update the wish clearance needed when teh wish national type is changed.
			if (currentCase.RecordTypeId == wishRecordTypeId
					&& currentCase.Wish_Type__c != null
					&& currentCase.Wish_Type__c != oldCaseMap.get(currentCase.Id).Wish_Type__c) {
				changedNationalTypeCaseMap.put(currentCase.Id, currentCase);
			}
			/* Used to close the wish determine case and open the new planning and Granting and Impact sub cases will open. */
			/**
			 * WLP-428
			 * Deprecating Sub Status when Status is Wish Determined
			 */
			if (CASE_STATUS_WISH_DETERMINED.equals(currentCase.Status)
//					&& currentCase.Sub_Status__c != oldCaseMap.get(currentCase.Id).Sub_Status__c
//					&& currentCase.Sub_Status__c == 'Within Policy'
					&& currentCase.Wish_Type__c != null
					&& currentCase.RecordTypeId == wishRecordTypeId) {
				currentCase.Meet_PWL_Criteria__c = MEET_PWL_CRITERIA_YES;
				currentCase.Concept_Approval_Date__c = Date.today();
				/**
				 * JIRA: WLP-286
				 * Author: Gustavo Mayer
				 * Update: List adds case but is not used anywhere else
				 */
//				updateChildCaseList.add(currentCase);
			}
			if (CASE_STATUS_WISH_DETERMINED.equals(currentCase.Status)
					&& !CASE_STATUS_WISH_DETERMINED.equals(oldCaseMap.get(currentCase.Id).Status)
					&& currentCase.RecordTypeId == wishRecordTypeId) {
				currentCase.Wish_Determined_Date__c = System.today();
			}
			/**
			 * WLP-428
			 * Refactoring status change
			 */
			if (currentCase.RecordTypeId == wishRecordTypeId
//					&& (currentCase.Status == 'Budget Approval - Submitted'
//					&& oldCaseMap.get(currentCase.Id).Status != 'Budget Approval - Submitted')
//					|| (currentCase.Status == 'Budget Approval - Approved'
//					&& oldCaseMap.get(currentCase.Id).Status != 'Budget Approval - Approved')
					&& (CASE_STATUS_PENDING_APPROVAL.equals(currentCase.Status)
					&& !CASE_STATUS_PENDING_APPROVAL.equals(oldCaseMap.get(currentCase.Id).Status))) {
				currentCase.Sub_Status__c = null;
			}
			if (CASE_STATUS_ESCALATED.equals(currentCase.Status)
					&& currentCase.RecordTypeId == diagnosisVerificationRT
					&& !CASE_STATUS_ESCALATED.equals(oldCaseMap.get(currentCase.Id).Status)) {
				currentCase.isNational__c = true;
				currentCase.MAC_Email__c = dbAccountList[0].MAC_Email_del__c;
			}
			if ((CASE_STATUS_DNQ_NATIONAL_STAFF.equals(currentCase.Status)
					|| CASE_STATUS_DNQ_NATIONAL_MEDICAL_COUNCIL.equals(currentCase.Status)
					|| CASE_STATUS_DNQ_CHAPTER_STAFF.equals(currentCase.Status)
					|| CASE_STATUS_DNQ_CHAPTER_MEDICAL_ADVISOR.equals(currentCase.Status))
					&& currentCase.RecordTypeId == diagnosisVerificationRT) {
				currentCase.DNQ_Date__c = Date.today();
			}
			if ((CASE_STATUS_COMPLETED.equals(currentCase.Status))
					&& (!CASE_STATUS_COMPLETED.equals(oldCaseMap.get(currentCase.Id).Status))
					&& currentCase.RecordTypeId == wishRecordTypeId) {
				budgetCaseList.add(currentCase);
			}
			if (currentCase.RecordTypeId == wishRecordTypeId
					&& currentCase.Status != oldCaseMap.get(currentCase.Id).Status
					&& ((CASE_STATUS_GRANTED.equals(currentCase.Status)
					&& (CASE_STATUS_WISH_SCHEDULED.equals(oldCaseMap.get(currentCase.Id).Status)))
					|| ((CASE_STATUS_COMPLETED.equals(currentCase.Status))
					&& (!CASE_STATUS_COMPLETED.equals(oldCaseMap.get(currentCase.Id).Status)))
					/* || ( currentCase.Status == 'DNQ'  || currentCase.Status == 'Closed' ) */)) {
				receiveDateCaseList.add(currentCase);
			}
			if ((CASE_STATUS_DNQ.equals(currentCase.Status)
					|| CASE_STATUS_COMPLETED.equals(currentCase.Status)
					|| CASE_STATUS_CLOSED.equals(currentCase.Status))
					&& currentCase.RecordTypeId == wishRecordTypeId) {
				currentCase.IsLocked__c = true;
			}
			if ((!CASE_STATUS_DNQ.equals(currentCase.Status)
					&& CASE_STATUS_DNQ.equals(oldCaseMap.get(currentCase.Id).Status))
					|| (!CASE_STATUS_COMPLETED.equals(currentCase.Status)
					&& CASE_STATUS_COMPLETED.equals(oldCaseMap.get(currentCase.Id).Status))
					|| (!CASE_STATUS_CLOSED.equals(currentCase.Status)
					&& CASE_STATUS_CLOSED.equals(oldCaseMap.get(currentCase.Id).Status))
					|| (currentCase.IsClosed == false
					&& oldCaseMap.get(currentCase.Id).IsClosed == true) &&
					currentCase.RecordTypeId == wishRecordTypeId) {
				currentCase.IsLocked__c = false;
			}
			/**
			 * WLP-429
			 * Modify verification on Case permission to check against Closed_Case_Editing_Security_Settings__c,
			 * if current user or current user's profile has restricted permissions on Case
			 */
			Boolean userHasRestrictedPermissionOnCase = CaseService.userHasRestrictedPermissionOnCase();
			if ((currentCase.RecordTypeId == wishRecordTypeId || currentCase.RecordTypeId == wishAssistRecordTypeId
					|| currentCase.ParentId != null)
					&& userHasRestrictedPermissionOnCase
//					&& (dbprofile.Name != 'System Administrator'
//					&& Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null
//					&& RecursiveTriggerHandler.allowToEditRecord == FALSE)
					) {
				parentIdSet.add(currentCase.ParentId);
			}

			/**
			 * WLP-429
			 * Modify verification on Case permission to check against Closed_Case_Editing_Security_Settings__c,
			 * if current user or current user's profile has restricted permissions on Case
			 */
			/**
			 * WLP-428
			 * Refactoring status change
			 */
			if (currentCase.IsLocked__c == true
					&& oldCaseMap.get(currentCase.Id).IsLocked__c == true
					&& usc != null) {
				if (usc.All_Closed_Cases_except_Abandoned__c == false
//						&& !CASE_SUB_STATUS_ABANDONED.equals(currentCase.Sub_Status__c)
						&& currentCase.IsClosed == true
						&& userHasRestrictedPermissionOnCase
//						&& dbprofile.Name != 'System Administrator'
//						&& Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null
//						&& RecursiveTriggerHandler.allowToEditRecord == FALSE
						&& currentCase.RecordTypeId == wishRecordTypeId
						&& (!(CASE_STATUS_COMPLETED.equals(currentCase.Status)
						&& (currentCase.Adoptable__c != oldCaseMap.get(currentCase.Id).Adoptable__c
						|| currentCase.Adopted__c != oldCaseMap.get(currentCase.Id).Adopted__c
						|| currentCase.Adopted_By__c != oldCaseMap.get(currentCase.Id).Adopted_By__c)))) {
					currentCase.addError('You do not have permission to edit this record.');
				}

				/**
				 * WLP-429
				 * Modify verification on Case permission to check against Closed_Case_Editing_Security_Settings__c,
				 * if current user or current user's profile has restricted permissions on Case
				 */
				/**
				 * WLP-428
				 * Refactoring status change
				 */
				if (usc.Edit_Abandoned_Cases__c == false
//						&& CASE_SUB_STATUS_ABANDONED.equals(currentCase.Sub_Status__c)
						&& currentCase.IsClosed == true
						&& userHasRestrictedPermissionOnCase
//						&& dbprofile.Name != 'System Administrator'
//						&& Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null
//						&& RecursiveTriggerHandler.allowToEditRecord == FALSE
						&& currentCase.RecordTypeId == wishRecordTypeId) {
					currentCase.addError('You do not have permission to edit this record.');
				}
			} else if (currentCase.IsLocked__c == true
					&& oldCaseMap.get(currentCase.Id).IsLocked__c == true
					&& userHasRestrictedPermissionOnCase
//					&& usc == Null && dbprofile.Name != 'System Administrator'
//					&& Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null
//					&& RecursiveTriggerHandler.allowToEditRecord == FALSE
					&& currentCase.RecordTypeId == wishRecordTypeId
					&& (!(CASE_STATUS_COMPLETED.equals(currentCase.Status)
					&& (currentCase.Adoptable__c != oldCaseMap.get(currentCase.Id).Adoptable__c
					|| currentCase.Adopted__c != oldCaseMap.get(currentCase.Id).Adopted__c
					|| currentCase.Adopted_By__c != oldCaseMap.get(currentCase.Id).Adopted_By__c)))) {
				currentCase.addError('You do not have permission to edit this record.');
			}
			/**
			 * WLP-428
			 * Refactoring status change
			 */
			if (CASE_SUB_STATUS_ABANDONED.equals(currentCase.Sub_Status__c)
					&& CASE_STATUS_GRANTED.equals(oldCaseMap.get(currentCase.Id).Status)
					&& usc == null
					&& Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null
					&& currentCase.RecordTypeId == wishRecordTypeId) {
				currentCase.addError('You do not have permission to update the granted case as abandoned');
			} else if (CASE_SUB_STATUS_ABANDONED.equals(currentCase.Sub_Status__c)
					&& CASE_STATUS_GRANTED.equals(oldCaseMap.get(currentCase.Id).Status)
					&& usc != null
					&& Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null
					&& currentCase.RecordTypeId == wishRecordTypeId) {
				if (usc.Abandon_the_Granted_case__c == false) {
					currentCase.addError('You do not have permission to update the granted case as abandoned');
				}
			}
			/**
			 * WLP-428
			 * Hold transformed to Status Inactive
			 */
//			if (CASE_STATUS_HOLD.equals(currentCase.Status)
//					&& !CASE_STATUS_HOLD.equals(oldCaseMap.get(currentCase.Id).Status)
//					&& currentCase.RecordTypeId == wishRecordTypeId) {
//				currentCase.Hold_Date__c = Date.today();
//			} else
			if (CASE_STATUS_INACTIVE.equals(currentCase.Status)
					&& !CASE_STATUS_INACTIVE.equals(oldCaseMap.get(currentCase.Id).Status)
					&& currentCase.RecordTypeId == wishRecordTypeId) {
				currentCase.Inactive_Date__c = Date.today();
			} else if ((CASE_STATUS_CLOSED.equals(currentCase.Status)
					|| CASE_STATUS_COMPLETED.equals(currentCase.Status))
					&& CASE_STATUS_GRANTED.equals(oldCaseMap.get(currentCase.Id).Status)
					&& currentCase.RecordTypeId == wishRecordTypeId) {
				currentCase.Completed_Date__c = Date.today();
			}
			if (CASE_SUB_STATUS_ABANDONED.equals(currentCase.Sub_Status__c)
					&& !CASE_SUB_STATUS_ABANDONED.equals(currentCase.Sub_Status__c)
					&& currentCase.RecordTypeId == wishRecordTypeId) {
				currentCase.Closed_Date__c = Date.today();
			}

// 			if (currentCase.Update_Wish_Child_Form_Info__c == True
// 					&& oldCaseMap.get(currentCase.id).Update_Wish_Child_Form_Info__c != True
// 					&& currentCase.RecordTypeId == wishRecordTypeId) {
			//   If(currUserChapter[0].Chapter_Name__c != currentCase.Hidden_Chapter_Name__c){
			//  currentCase.addError('You don\'t have access to approve this record.Please contact your Administrator');
			// }
			// else
// 				wishChildInfoMap.put(currentCase.id, currentCase);
// 			}
			/*if (currentCase.contactId != Null && currentCase.birthdate__c == Null
					&& currentCase.RecordTypeId == wishRecordTypeId) {
				contactIds.add(currentCase.contactId);
			}*/
		}

		/*	if (contactIds.size() > 0) {
				contactMap.putAll([
						SELECT id,birthdate
						FROM Contact
						WHERE Id IN :contactIds
						LIMIT 50000
				]);
			}*/

		if (wishOwnerIdSet.size() > 0) {
			for (User wishOwner : [
					SELECT Id,ManagerId,Manager.Name,Manager.Email,Email
					From User
					WHERE Id IN:wishOwnerIdSet AND ManagerId != Null
					LIMIT 50000
			]) {
				wishOwnerMap.put(wishOwner.id, wishOwner);
			}
		}
		if (parentIdSet.size() > 0) {
			for (Case parentCase : [
					SELECT Id,Status
					FROM Case
					WHERE Status = :CASE_STATUS_COMPLETED
					AND Id IN :parentIdSet
					AND RecordTypeId = :wishRecordTypeId
					LIMIT 50000
			]) {
				compltedParentIdSet.Add(parentCase.Id);
			}
		}

		for (Case newCase : newCaseMap.values()) {
			if (wishOwnerMap.containsKey(newCase.OwnerId)) {
				if (wishOwnerMap.get(newCase.OwnerId).ManagerId != Null && newCase.RecordTypeId == wishRecordTypeId) {
					newCase.Hidden_Wish_Owner_Manager__c = wishOwnerMap.get(newCase.OwnerId).Manager.Name;
					newCase.Hidden_Wish_Owner_Email__c = wishOwnerMap.get(newCase.OwnerId).Manager.Email;
				}
			}
			/*if (contactMap.containsKey(newCase.contactId) && newCase.RecordTypeId == wishRecordTypeId) {
				if (contactMap.get(newCase.contactId).birthdate != Null)
					newCase.birthdate__c = contactMap.get(newCase.contactId).birthdate;
			}*/
			if (compltedParentIdSet.contains(newCase.ParentId)) {
				newCase.addError('You do not have permission to edit this record.');
			}
		}

		//Case Owner Old Logic
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
		/* WLP-453 Remove automation for case ownership*/
		/*if (managerUserMap.size() > 0) {
			for (Case currentCase : newCaseMap.values()) {

				if (managerUserMap.containsKey(currentCase.ChapterName__c)
						&& currentCase.Status == 'Ready to Assign'
						&& currentCase.Status != oldCaseMap.get(currentCase.Id).Status
						&& currentCase.RecordTypeId == wishRecordTypeId) {
					if (managerUserMap.get(currentCase.ChapterName__c).Volunteer_Manager__c != null) {
						currentCase.OwnerId = managerUserMap.get(currentCase.ChapterName__c).Volunteer_Manager__c;
					}
				}
				if (managerUserMap.containsKey(currentCase.ChapterName__c)
						&& currentCase.RecordTypeId == wishRecordTypeId
						&& currentCase.Status == 'Wish Determined'
						&& currentCase.Sub_Status__c == 'Within Policy'
						&& (oldCaseMap.get(currentCase.Id).Status != currentCase.Status
						|| oldCaseMap.get(currentCase.Id).Sub_Status__c != currentCase.Sub_Status__c)) {
					if (managerUserMap.get(currentCase.ChapterName__c).Wish_Co_ordinator__c != null)
						currentCase.OwnerId = managerUserMap.get(currentCase.ChapterName__c).Wish_Co_ordinator__c ;
				}
			}
		}*/
		//This is used to update the wish clearance needed based on the wish national type.
		//WVC-1804
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
/*WLP-467 remove automated task creation */
//		if (wishChildInfoMap.size() > 0) {
//			WishChildFormValUpdate_AC.updateWishType(wishChildInfoMap);
//		}
	}
}