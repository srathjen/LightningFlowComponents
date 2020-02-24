/*
Modification Log
1. 26/03/18 - Vignesh SM - IME 18 - Line No 92, 518-520, 385-392
*/
public class Case_OnAfterUpdateTriggerHandler {

	private static final Id wishRecordTypeId = Constant_AC.WISH_RT_ID;
	private static final Id wishAssistRecordTypeId = Constant_AC.WISH_ASSIST_RT_ID;
	private static final Id diagnosisVerificationRT = Constant_AC.DIAGNOSIS_RT_ID;
	private static final String CASE_STATUS_WISH_DETERMINED = Constant_AC.CASE_STATUS_WISH_DETERMINED;
	private static final String CASE_STATUS_WISH_DESIGN = Constant_AC.CASE_STATUS_WISH_DESIGN;
	private static final String CASE_STATUS_WISH_SCHEDULED = Constant_AC.CASE_STATUS_WISH_SCHEDULED;
	private static final String CASE_STATUS_PENDING_APPROVAL = Constant_AC.CASE_STATUS_PENDING_APPROVAL;
	private static final String CASE_STATUS_CLOSED = Constant_AC.CASE_STATUS_CLOSED;
	private static final String CASE_STATUS_COMPLETED = Constant_AC.CASE_STATUS_COMPLETED;
	private static final String CASE_STATUS_GRANTED = Constant_AC.CASE_STATUS_GRANTED;
	private static final String CASE_STATUS_APPROVED_NATIONAL_MEDICAL_REVIEW = Constant_AC.CASE_STATUS_APPROVED_NATIONAL_MEDICAL_REVIEW;
	private static final String CASE_STATUS_APPROVED_NATIONAL_MAC_REVIEW = Constant_AC.CASE_STATUS_APPROVED_NATIONAL_MAC_REVIEW;
	private static final String CASE_STATUS_DNQ_NATIONAL_MEDICAL_REVIEW = Constant_AC.CASE_STATUS_DNQ_NATIONAL_MEDICAL_REVIEW;
	private static final String CASE_STATUS_DNQ_NATIONAL_MAC_REVIEW = Constant_AC.CASE_STATUS_DNQ_NATIONAL_MAC_REVIEW;
//	private static final String CASE_STATUS_DNQ = Constant_AC.CASE_STATUS_DNQ;
	private static final String CASE_STATUS_INACTIVE = Constant_AC.CASE_STATUS_INACTIVE;
	private static final String CASE_STATUS_ESCALATED = Constant_AC.CASE_STATUS_ESCALATED;
	private static final String CASE_STATUS_OPEN = Constant_AC.CASE_STATUS_OPEN;
	private static final String CASE_STATUS_QUALIFIED = Constant_AC.CASE_STATUS_QUALIFIED;
	private static final String CASE_STATUS_READY_TO_ASSIGN = Constant_AC.CASE_STATUS_READY_TO_ASSIGN;
	private static final String CASE_STATUS_READY_TO_INTERVIEW = Constant_AC.CASE_STATUS_READY_TO_INTERVIEW;
	private static final String CASE_STATUS_NEW = Constant_AC.CASE_STATUS_NEW;
	private static final String CASE_STATUS_PENDING_CLARIFICATION_MAC = Constant_AC.CASE_STATUS_PENDING_CLARIFICATION_MAC;
	private static final String CASE_STATUS_PENDING_CLARIFICATION_MAC_CONSULT_REQ = Constant_AC.CASE_STATUS_PENDING_CLARIFICATION_MAC_CONSULT_REQ;
	private static final String CASE_STATUS_PENDING_CLARIFICATION_CHAPTER = Constant_AC.CASE_STATUS_PENDING_CLARIFICATION_CHAPTER;
	private static final String CASE_WISH_TYPE_CELEBRITY_DOMESTIC_TRAVEL = Constant_AC.CASE_WISH_TYPE_CELEBRITY_DOMESTIC_TRAVEL;
	private static final String CASE_WISH_TYPE_CELEBRITY_LOCAL = Constant_AC.CASE_WISH_TYPE_CELEBRITY_LOCAL;
	private static final String CASE_WISH_TYPE_CELEBRITY_INTERNATIONAL_TRAVEL = Constant_AC.CASE_WISH_TYPE_CELEBRITY_INTERNATIONAL_TRAVEL;
	private static final String CASE_WISH_TYPE_CRUISE_CELEBRITY_ROYAL = Constant_AC.CASE_WISH_TYPE_CRUISE_CELEBRITY_ROYAL;
	private static final String CASE_WISH_TYPE_CRUISE_DISNEY = Constant_AC.CASE_WISH_TYPE_CRUISE_DISNEY;
	private static final String CASE_WISH_TYPE_CRUISE_OTHER = Constant_AC.CASE_WISH_TYPE_CRUISE_OTHER;
	private static final String CASE_WISH_TYPE_TRAILER_CAMPER = Constant_AC.CASE_WISH_TYPE_TRAILER_CAMPER;
	private static final String CASE_WISH_TYPE_TRAVEL_OTHER = Constant_AC.CASE_WISH_TYPE_TRAVEL_OTHER;
	private static final String CASE_WISH_TYPE_TRAVEL_INTERNATIONAL = Constant_AC.CASE_WISH_TYPE_TRAVEL_INTERNATIONAL;
	private static final String CASE_WISH_TYPE_TRAVEL_HAWAII = Constant_AC.CASE_WISH_TYPE_TRAVEL_HAWAII;
	private static final String CASE_BUDGET_APPROVAL_STATUS_APPROVED = Constant_AC.CASE_BUDGET_APPROVAL_STATUS_APPROVED;

	/**********************************************************************************************************************
	This method is used to get the case records new values and old values and those values are added into collections
	then it will passed to the coressponding controller method.
	*******************************************************************************************************************/
	public static void onAfterUpdate(Map<Id, Case>newCaseMap, Map<Id, Case> oldCaseMap) {
		/**
		 * JIRA: WLP-286
		 * Author: Gustavo Mayer
		 * Update: Sub case conversion to the single Wish Case,
		 * no need to instantiate the unused attributes in the method below.
		 */
//		Set<Id> contactIds = new Set<Id>();
//		Map<Id, Contact> contactMap = new Map<Id, Contact>();
		Set<Id> newWishClearanceSet = new Set<Id>();
//		Set<Id> newMedicalWishClearanceSet = new Set<Id>();
		//Map<Id, Case> birthdayDateUpdateMap = new Map<Id, Case>();
		//Set<Id> bdayWishChildSet = new Set<Id>();
//		Map<Id, Case> surveyEmailMap = new Map<Id, Case>();
//		Set<Id> impactparentIdSet = new Set<Id>();
//		Set<Id> caseParentIdSet = new Set<Id>();
		Set<Id> closeTaskParentIdSet = new Set<Id>();
//		Map<Id, Case> parentWishInfoMap = new Map<Id, Case>();
//		Set<Id> TaskParentIdSet = new Set<Id>();
		Set<Id> caseIdSetForVolOpp = new Set<Id>();
//		Map<Id, Case> wishPlanningAndGrantinTaskParentMap = new Map<Id, Case>();
		Map<Id, Case> updateVolunteerManagerCaseTeamMap = new Map<Id, Case>();
		Set<Id> volunteerManagerIdSet = new Set<Id>();
		Set<Id> wishCoordinatorIdSet = new Set<Id>();
		Map<Id, Id> caseContactMap = new Map<Id, Id>();
//		Map<Id, Id> newCaseOwnerMap = new Map<Id, Id>();
		Set<Id> volunteerCaseIdSet = new Set<Id>();
		Map<Id, Case> caseIdsMap = new Map<Id, Case>();
		Set<String> newWishTypeSet = new Set<String>();
//		Map<Id, String> wishReceiptMap = new Map<Id, String>();
//		List<Case> diagnosisVerificationCaseList = new List<Case>();
		Set<String> updatedApprovedLeadInfoSet = new Set<String>();
		Set<String> updatedDnqLeadInfoSet = new Set<String>();
		Map<Id, Case> UpdateAllOpenTasks = new Map<Id, Case>();
//		Set<Id> interViewCloseTaskIdsSet = new Set<Id>();
//		Map<Id, Case> interviewTaskParentIdMap = new Map<Id, Case>();
//		Map<Id, Date> dueDateMap = new Map<Id, Date>();
//		Set<Id> interViewOpenTaskIdsSet = new Set<Id>();
//		Set<Id> insertInterViewOpenTaskIdSet = new Set<Id>();
		Set<Id> caseTeamMemberParentIdSet = new Set<Id>();
		Set<Id> revokingContactIdSet = new Set<Id>();
//		Set<Id> presentatationIdentifySet = new Set<Id>();
//		Set<Id> presentationIdsSet = new Set<Id>();
		Set<Id> presentationCloseTaskIdsSet = new Set<Id>();
		Map<Id, Case> presentationCloseTaskParentIdMap = new Map<Id, Case>();
		Set<Id> presentationOpenTaskIdsSet = new Set<Id>();
		Set<Id> endDateIdSet = new Set<Id>();
//		Map<Id, Case> wishchildIdMap = new Map<Id, Case>();
		Set<Id> newMedicalSummarySet = new Set<Id>();
		Map<Id, Case> wishClearanceMap = new Map<Id, Case>();
//		Set<Id> conceptApprovalParentIdSet = new Set<Id>();
//		Set<Id> approvedBudgetIdsSet = new Set<Id>();
		Map<Id, String> approvedBudgetStatus = new Map<Id, String>();
//		Set<Id> wishIdsSet = new Set<Id>();
		Set<Id> wishIds = new Set<Id>();
		Map<Id, Case> updateWishChildInfo = new Map<Id, Case>();
		List<Case> PartAWishList = new List<Case>();
		Map<Id, Case> removeAnticipationTaskMap = new Map<Id, Case>();
		Map<Id, Case> updateAnticipationTaskMap = new Map<Id, Case>();
		Set<String> wishTypes = new Set<String>();
		Set<Id> inProgressUnCheckCaseIdsSet = new Set<Id>();
		Map<Id, Case> readyToAssignParentCaseMap = new Map<Id, Case>();
		Set<Id> readyToAssignChapterIdSet = new Set<Id>();
		List<Case> wishGrantedIdList = new List<Case>();
		Set<Id> parentWishIdSet = new Set<Id>();
		Set<Id> closedCaseIdSet = new Set<Id>();
		Set<Id> completedCaseIdSet = new Set<Id>();
		List<Case> exceptionList = new List<Case>();
		Set<Id> wishGrantedSet = new Set<Id>();
//		Set<Id> closedWishSet = new Set<Id>();
//		List<Approval.ProcessSubmitRequest> approvalReqList = new List<Approval.ProcessSubmitRequest>();
//		Map<Id, Case> forTrackingMap = new Map<Id, Case>();
		Map<Id, Case> parentWishClearanceMap = new Map<Id, Case>();
		Map<Id, String> caseToLeadSubStatusUpdate = new Map<Id, String>(); //IME 18
		Set<Id> closeBirthDayTaskSet = new Set<Id>();

		for (Case caseMemberCheck : newCaseMap.values()) {
			if (caseMemberCheck.RecordTypeId == diagnosisVerificationRT
					|| caseMemberCheck.RecordTypeId == wishRecordTypeId
					|| caseMemberCheck.RecordTypeId == wishAssistRecordTypeId) {

				/*if (caseMemberCheck.Birthdate__c != oldCaseMap.get(caseMemberCheck.Id).Birthdate__c
						&& caseMemberCheck.RecordTypeId == wishRecordTypeId) {
					birthdayDateUpdateMap.put(caseMemberCheck.Id, caseMemberCheck);
					bdayWishChildSet.add(caseMemberCheck.ContactId);
				}*/
				/**
				 * JIRA: WLP-286
				 * Author: Gustavo Mayer
				 * Update: Sub case conversion to the single Wish Case,
				 * no need to update as there is no longer the concept of parent case.
				 */
				// Below four lines are related to STT-11 for populating Survey email to parent case when Wish Impact subcase has value for Survey Email field.
//				if ((caseMemberCheck.Survey_Email__c != oldCaseMap.get(caseMemberCheck.Id).Survey_Email__c
//						|| caseMemberCheck.Survey_Sent__c != oldCaseMap.get(caseMemberCheck.Id).Survey_Sent__c)
//						&& caseMemberCheck.RecordTypeId == wishRecordTypeId && caseMemberCheck.ParentId != null) {
//					surveyEmailMap.put(caseMemberCheck.Id, caseMemberCheck);
//					impactparentIdSet.add(caseMemberCheck.ParentId);
//				}
				/**
				 * JIRA: WLP-286
				 * Author: Gustavo Mayer
				 * Update: Sub case conversion to the single Wish Case,
				 * no need to update as there is no longer the concept of parent case.
				 */
				//Used to update parent case tracking note fields when the field is updated in Planning case
//				if (caseMemberCheck.Form_Tracking_Notes__c != oldCaseMap.get(caseMemberCheck.Id).Form_Tracking_Notes__c
//						&& caseMemberCheck.RecordTypeId == wishPlanningRecordTypeId && caseMemberCheck.ParentId != null) {
//					forTrackingMap.put(caseMemberCheck.ParentId, caseMemberCheck);
//				}
				/**
				 * JIRA: WLP-286
				 * Author: Gustavo Mayer
				 * Update: Sub case conversion to the single Wish Case,
				 * no need to update as there is no longer the concept of parent case.
				 */
				// Used to Open all sub cases when the status from "DNQ","Completed" and "Closed".
//				if ((caseMemberCheck.Status == 'Ready to Interview'
//						|| caseMemberCheck.Status == 'Wish Determined'
//						|| caseMemberCheck.Status == 'Wish Design'
//						|| caseMemberCheck.Status == 'Wish Scheduled'
//						|| caseMemberCheck.Status == 'Granted'
//						|| caseMemberCheck.Status == 'Qualified'
//						|| caseMemberCheck.Status == 'Ready to Assign')
//						&& (oldCaseMap.get(caseMemberCheck.Id).Status == 'DNQ'
//						|| oldCaseMap.get(caseMemberCheck.Id).Status == 'Completed'
//						|| oldCaseMap.get(caseMemberCheck.Id).Status == 'Closed')
//						&& (caseMemberCheck.RecordTypeId == wishRecordTypeId
//						&& RecursiveTriggerHandler.blockCaseLockRecursive == true)) {
//					caseParentIdSet.add(caseMemberCheck.Id);
//				}
				if (caseMemberCheck.RecordTypeId == wishRecordTypeId && caseMemberCheck.Wish_Assist__c == true
						&& oldCaseMap.get(caseMemberCheck.Id).Wish_Assist__c != true) {
					closeTaskParentIdSet.add(caseMemberCheck.Id);
				}
				/**
				 * WLP-428
				 * Condition only used to update a map that is then used to update tasks,
				 * the tasks is deprecated as part of WLP-467
				 */
				//Used to create wish determination type tasks when the status is updated to "Ready to Interview"
//				if ((caseMemberCheck.Wish_Assist__c == false && ((oldCaseMap.get(caseMemberCheck.Id).Status == 'Ready to Assign'
//						&& caseMemberCheck.Status == 'Ready to Interview')
//						|| (oldCaseMap.get(caseMemberCheck.Id).Status == 'DNQ'
//						|| oldCaseMap.get(caseMemberCheck.Id).Status == 'Completed'
//						|| oldCaseMap.get(caseMemberCheck.Id).Status == 'Closed'))
//						&& (RecursiveTriggerHandler.blockCaseLockRecursive == true
//						&& caseMemberCheck.RecordTypeId == wishRecordTypeId
//						&& caseMemberCheck.Status != oldCaseMap.get(caseMemberCheck.Id).Status
//						&& caseMemberCheck.Status == 'Ready to Interview'))) {
//					parentWishInfoMap.put(caseMemberCheck.Id, caseMemberCheck);
//				}
				/**
				 * WLP-428
				 * Condition only used to update a map that is then used to update tasks,
				 * the tasks is deprecated as part of WLP-467
				 */
				//Used to close all the System genareated  task when the status is updated to "DNQ", "Closed", "Completed"'
//				if ((caseMemberCheck.Status == 'DNQ' || caseMemberCheck.Status == 'Closed' ||
//						caseMemberCheck.Status == 'Completed') && (caseMemberCheck.RecordTypeId == wishRecordTypeId && RecursiveTriggerHandler.blockCaseLockRecursive == true) && (caseMemberCheck.Status != oldCaseMap.get(caseMemberCheck.Id).Status)) {
//					TaskParentIdSet.add(caseMemberCheck.Id);
//				}

				/**
				 * WLP-428
				 * Deprecating DNQ, replacing with Closed
				 */
				if ((
//						CASE_STATUS_DNQ.equals(caseMemberCheck.Status) ||
						CASE_STATUS_CLOSED.equals(caseMemberCheck.Status))
						&& caseMemberCheck.RecordTypeId == wishRecordTypeId
						&& caseMemberCheck.Status != oldCaseMap.get(caseMemberCheck.Id).Status) {
					caseIdSetForVolOpp.add(caseMemberCheck.Id);
				}

				if ((CASE_STATUS_GRANTED.equals(caseMemberCheck.Status)
						|| CASE_STATUS_CLOSED.equals(caseMemberCheck.Status))
						&& caseMemberCheck.Status != oldCaseMap.get(caseMemberCheck.Id).Status
						&& caseMemberCheck.RecordTypeId == wishRecordTypeId) {
					wishGrantedSet.add(caseMemberCheck.Id);
				}
				/**
				 * WLP-428
				 * Condition only used to create a map that is then used to create tasks,
				 * the tasks is deprecated as part of WLP-467
				 */
				//Used to create wish planning and granting task
//				if (caseMemberCheck.Wish_Assist__c == false
//						&& (((caseMemberCheck.Status != oldCaseMap.get(caseMemberCheck.Id).Status
//						|| caseMemberCheck.Sub_Status__c != oldCaseMap.get(caseMemberCheck.Id).Sub_Status__c)
//						&& (caseMemberCheck.RecordTypeId == wishRecordTypeId && RecursiveTriggerHandler.blockCaseLockRecursive == true))
//						&& ((oldCaseMap.get(caseMemberCheck.Id).Status == 'DNQ' || oldCaseMap.get(caseMemberCheck.Id).Status == 'Completed'
//						|| oldCaseMap.get(caseMemberCheck.Id).Status == 'Closed') || (caseMemberCheck.Sub_Status__c == 'Within Policy'
//						&& caseMemberCheck.Status == 'Wish Determined'))) &&
//						(caseMemberCheck.Sub_Status__c == 'Within Policy' && caseMemberCheck.Status == 'Wish Determined')) {
//					wishPlanningAndGrantinTaskParentMap.put(caseMemberCheck.Id, caseMemberCheck);
//				}

				if (CASE_STATUS_READY_TO_ASSIGN.equals(caseMemberCheck.Status)
						&& caseMemberCheck.Status != oldCaseMap.get(caseMemberCheck.Id).Status
						&& RecursiveTriggerHandler.blockCaseLockRecursive == true
						&& caseMemberCheck.RecordTypeId == wishRecordTypeId) {
					updateVolunteerManagerCaseTeamMap.put(caseMemberCheck.Id, caseMemberCheck);
					volunteerManagerIdSet.add(caseMemberCheck.Id);
				} else if ((CASE_STATUS_READY_TO_ASSIGN.equals(caseMemberCheck.Status)
						|| CASE_STATUS_READY_TO_INTERVIEW.equals(caseMemberCheck.Status))
						&& caseMemberCheck.OwnerId != oldCaseMap.get(caseMemberCheck.Id).OwnerId
						&& RecursiveTriggerHandler.blockCaseLockRecursive == true
						&& caseMemberCheck.RecordTypeId == wishRecordTypeId) {
					updateVolunteerManagerCaseTeamMap.put(caseMemberCheck.Id, caseMemberCheck);
					volunteerManagerIdSet.add(caseMemberCheck.Id);
				}

				/**
				 * WLP-428
				 * Refactoring status change
				 */
				if (caseMemberCheck.Status != oldCaseMap.get(caseMemberCheck.Id).Status
						&& CASE_STATUS_WISH_DETERMINED.equals(caseMemberCheck.Status)
						&& RecursiveTriggerHandler.blockCaseLockRecursive == true
						&& caseMemberCheck.RecordTypeId == wishRecordTypeId) {
					updateVolunteerManagerCaseTeamMap.put(caseMemberCheck.Id, caseMemberCheck);
					wishCoordinatorIdSet.add(caseMemberCheck.Id);
				} else if ((caseMemberCheck.OwnerId != oldCaseMap.get(caseMemberCheck.Id).OwnerId
						&& RecursiveTriggerHandler.blockCaseLockRecursive == true)
						&& (CASE_STATUS_WISH_DETERMINED.equals(caseMemberCheck.Status)
						|| CASE_STATUS_WISH_DESIGN.equals(caseMemberCheck.Status)
						|| CASE_STATUS_WISH_SCHEDULED.equals(caseMemberCheck.Status)
						|| CASE_STATUS_PENDING_APPROVAL.equals(caseMemberCheck.Status))
//						|| caseMemberCheck.Status == 'Budget Approval - Approved'
//						|| caseMemberCheck.Status == 'Budget Approval - Submitted')
						&& caseMemberCheck.RecordTypeId == wishRecordTypeId) {
					updateVolunteerManagerCaseTeamMap.put(caseMemberCheck.Id, caseMemberCheck);
					wishCoordinatorIdSet.add(caseMemberCheck.Id);
				}
				if ((!CASE_STATUS_CLOSED.equals(caseMemberCheck.Status)
						&& !CASE_STATUS_COMPLETED.equals(caseMemberCheck.Status)
						&& RecursiveTriggerHandler.blockCaseLockRecursive == true)
						&& (CASE_STATUS_CLOSED.equals(oldCaseMap.get(caseMemberCheck.Id))
						|| CASE_STATUS_COMPLETED.equals(oldCaseMap.get(caseMemberCheck.Id)))
						&& caseMemberCheck.RecordTypeId == wishRecordTypeId) {
					caseContactMap.put(caseMemberCheck.Id, caseMemberCheck.ContactId);
				}
				/**
				 * JIRA: WLP-286
				 * Author: Gustavo Mayer
				 * Update: Sub case conversion to the single Wish Case,
				 * no need to update as there is no longer the concept of parent case.
				 */
//				if (caseMemberCheck.OwnerId != oldCaseMap.get(caseMemberCheck.Id).OwnerId
//						&& caseMemberCheck.RecordTypeId == wishRecordTypeId
//						&& RecursiveTriggerHandler.blockCaseLockRecursive == true) {
//					newCaseOwnerMap.put(caseMemberCheck.Id, caseMemberCheck.OwnerId);
//				}
				/**
				 * WLP-428
				 * Refactoring status change
				 */
				if ((CASE_STATUS_WISH_DETERMINED.equals(caseMemberCheck.Status)
						|| CASE_STATUS_PENDING_APPROVAL.equals(caseMemberCheck.Status)
						|| CASE_STATUS_WISH_DESIGN.equals(caseMemberCheck.Status)
						|| CASE_STATUS_WISH_SCHEDULED.equals(caseMemberCheck.Status)
						|| CASE_STATUS_GRANTED.equals(caseMemberCheck.Status))
						&& caseMemberCheck.RecordTypeId == wishRecordTypeId
						&& RecursiveTriggerHandler.blockCaseLockRecursive == true
						&& !CASE_STATUS_WISH_DETERMINED.equals(oldCaseMap.get(caseMemberCheck.Id).Status)
						&& !CASE_STATUS_PENDING_APPROVAL.equals(oldCaseMap.get(caseMemberCheck.Id).Status)
						&& !CASE_STATUS_WISH_DESIGN.equals(oldCaseMap.get(caseMemberCheck.Id).Status)
						&& !CASE_STATUS_WISH_SCHEDULED.equals(oldCaseMap.get(caseMemberCheck.Id).Status)
						&& !CASE_STATUS_GRANTED.equals(oldCaseMap.get(caseMemberCheck.Id).Status)) {
					volunteerCaseIdSet.add(caseMemberCheck.Id);
				}
				if (oldCaseMap.get(caseMemberCheck.Id).Wish_Type__c != caseMemberCheck.Wish_Type__c
						&& caseMemberCheck.RecordTypeId == wishRecordTypeId) {
					caseIdsMap.put(caseMemberCheck.Id, caseMemberCheck);
					newWishTypeSet.add(caseMemberCheck.Wish_Type__c);
				}
				/**
				 * JIRA: WLP-286
				 * Author: Gustavo Mayer
				 * Update: Sub case conversion to the single Wish Case,
				 * no need to update as there is no longer the concept of parent case.
				 */
//				if (caseMemberCheck.RecordTypeId == wishGrantRecordTypeId && caseMemberCheck.Wish_Receipt_Items__c != null &&
//						caseMemberCheck.Wish_Receipt_Items__c != oldCaseMap.get(caseMemberCheck.Id).Wish_Receipt_Items__c) {
//					wishReceiptMap.put(caseMemberCheck.ParentId, caseMemberCheck.Wish_Receipt_Items__c);
//				}

				/* Removing as per IME 4
				 if(caseMemberCheck.Status == 'Escalated' && caseMemberCheck.RecordTypeId == diagnosisVerificationRT && caseMemberCheck.Status != oldCaseMap.get(caseMemberCheck.Id).Status && caseMemberCheck.MAC_Email__c != null) {
				 diagnosisVerificationCaseList.add(caseMemberCheck);
				 }*/
				//(caseMemberCheck.Status == 'Approved - Chapter Staff' && oldCaseMap.get(caseMemberCheck.Id).Status != 'Approved - Chapter Staff') ||
				//(caseMemberCheck.Status == 'Approved - Chapter Medical Advisor' && oldCaseMap.get(caseMemberCheck.Id).Status != 'Approved - Chapter Medical Advisor') ||  - Removing as per IME 4
				//Modified as per IME 4
				if ((CASE_STATUS_APPROVED_NATIONAL_MEDICAL_REVIEW.equals(caseMemberCheck.Status)
						&& !CASE_STATUS_APPROVED_NATIONAL_MEDICAL_REVIEW.equals(oldCaseMap.get(caseMemberCheck.Id).Status))
						|| (CASE_STATUS_APPROVED_NATIONAL_MAC_REVIEW.equals(caseMemberCheck.Status)
						&& !CASE_STATUS_APPROVED_NATIONAL_MAC_REVIEW.equals(oldCaseMap.get(caseMemberCheck.Id).Status))
						&& caseMemberCheck.RecordTypeId == diagnosisVerificationRT) {
					updatedApprovedLeadInfoSet.add(caseMemberCheck.Lead__c);
				}//caseMemberCheck.Status == 'DNQ - Chapter Staff' || caseMemberCheck.Status == 'DNQ - Chapter Medical Advisor' || - Removing as per IME 4
				else if ((CASE_STATUS_DNQ_NATIONAL_MEDICAL_REVIEW.equals(caseMemberCheck.Status)
						|| CASE_STATUS_DNQ_NATIONAL_MAC_REVIEW.equals(caseMemberCheck.Status))
						&& caseMemberCheck.RecordTypeId == diagnosisVerificationRT
						&& oldCaseMap.get(caseMemberCheck.Id).Status != caseMemberCheck.Status) {
					updatedDnqLeadInfoSet.add(caseMemberCheck.Lead__c);
				}

				/**
				 * WLP-428
				 * Condition only used to update a map that is then used to update tasks,
				 * the tasks is deprecated as part of WLP-467
				 */
//				if (caseMemberCheck.Sub_Status__c == 'Abandoned' && oldCaseMap.get(caseMemberCheck.Id).Sub_Status__c != 'Abandoned'
//						&& caseMemberCheck.RecordTypeId == wishRecordTypeId && caseMemberCheck.IsClosed == true) {
//					UpdateAllOpenTasks.put(caseMemberCheck.Id, caseMemberCheck);
//				}

				/**
				 * WLP-428
				 * Condition only used to update a map that is then used to update tasks,
				 * the tasks is deprecated as part of WLP-467
				 */
				//1.Used to update "Wish Determination" task due date when "Interview Date" field is updated
				//2.Used to Close & Open "Enter Interview" task based on interview date entered and cleard
//				if (caseMemberCheck.Interview_date__c != null && oldCaseMap.get(caseMemberCheck.Id).Interview_date__c == null && caseMemberCheck.RecordTypeId == wishRecordTypeId) {
//					interViewCloseTaskIdsSet.add(caseMemberCheck.Id);
//					interviewTaskParentIdMap.put(caseMemberCheck.Id, caseMemberCheck);
//					dueDateMap.put(caseMemberCheck.Id, caseMemberCheck.Interview_date__c);
//				} else if (caseMemberCheck.Interview_date__c == null && oldCaseMap.get(caseMemberCheck.Id).Interview_date__c != null && caseMemberCheck.RecordTypeId == wishRecordTypeId) {
//					dueDateMap.put(caseMemberCheck.Id, caseMemberCheck.Interview_date__c);
//					interViewOpenTaskIdsSet.add(caseMemberCheck.Id);
//					interviewTaskParentIdMap.put(caseMemberCheck.Id, caseMemberCheck);
//					if (caseMemberCheck.Wish_Assist__c == false)
//						insertInterViewOpenTaskIdSet.add(caseMemberCheck.Id);
//				}
//				else if (caseMemberCheck.Interview_date__c != null
//						&& oldCaseMap.get(caseMemberCheck.Id).Interview_date__c != null
//						&& oldCaseMap.get(caseMemberCheck.Id).Interview_date__c
//						!= caseMemberCheck.Interview_date__c && caseMemberCheck.RecordTypeId == wishRecordTypeId) {
//					dueDateMap.put(caseMemberCheck.Id, caseMemberCheck.Interview_date__c);
//				}

				//Used to remove the access for Volunteer user to Wish, when the parent wish is completed.
				////Used to update child cases if Parent Case Status is changed to 'Completed' or 'Closed'
				/**
				 * WLP-428
				 * Deprecating DNQ, replacing with Closed
				 */
				if ((CASE_STATUS_COMPLETED.equals(caseMemberCheck.Status)
						|| CASE_STATUS_CLOSED.equals(caseMemberCheck.Status)
//						|| CASE_STATUS_DNQ.equals(caseMemberCheck.Status)
				)
						&& (oldCaseMap.get(caseMemberCheck.Id).Status != caseMemberCheck.Status
						&& caseMemberCheck.RecordTypeId == wishRecordTypeId)) {
					caseTeamMemberParentIdSet.add(caseMemberCheck.Id);
					revokingContactIdSet.add(caseMemberCheck.ContactId);
				}
				/**
				 * WLP-428
				 * Deprecating DNQ, replacing with Closed
				 */
				if ((CASE_STATUS_COMPLETED.equals(caseMemberCheck.Status)
						|| CASE_STATUS_CLOSED.equals(caseMemberCheck.Status)
//						|| CASE_STATUS_DNQ.equals(caseMemberCheck.Status)
						|| CASE_STATUS_GRANTED.equals(caseMemberCheck.Status)
						|| CASE_STATUS_GRANTED.equals(caseMemberCheck.Status)
						|| CASE_STATUS_INACTIVE.equals(caseMemberCheck.Status))
						&& (oldCaseMap.get(caseMemberCheck.Id).Status != caseMemberCheck.Status
						&& caseMemberCheck.RecordTypeId == wishRecordTypeId)) {
					closeBirthDayTaskSet.add(caseMemberCheck.Id);
				}

				/**
				 * JIRA: WLP-286
				 * Author: Gustavo Mayer
				 * Update: Sub case conversion to the single Wish Case,
				 * no need to update as there is no longer the concept of parent case.
				 */
				// Wish Granted task
//				if (caseMemberCheck.Presentation_Date__c != null
//						&& oldCaseMap.get(caseMemberCheck.Id).Presentation_Date__c
//						!= caseMemberCheck.Presentation_Date__c
//						&& caseMemberCheck.RecordTypeId == wishRecordTypeId) {
//					presentatationIdentifySet.add(caseMemberCheck.ParentId);
//					presentationIdsSet.add(caseMemberCheck.ParentId);
//					presentationCloseTaskIdsSet.add(caseMemberCheck.ParentId);
//					presentationCloseTaskParentIdMap.put(caseMemberCheck.ParentId, caseMemberCheck);
//				}
//				if (caseMemberCheck.Presentation_Date__c == null
//						&& oldCaseMap.get(caseMemberCheck.Id).Presentation_Date__c
//						!= caseMemberCheck.Presentation_Date__c
//						&& caseMemberCheck.RecordTypeId == wishRecordTypeId) {
//					presentatationIdentifySet.add(caseMemberCheck.ParentId);
//					presentationIdsSet.add(caseMemberCheck.ParentId);
//					if (caseMemberCheck.Wish_Assist__c == false)
//						presentationOpenTaskIdsSet.add(caseMemberCheck.ParentId);
//					presentationCloseTaskParentIdMap.put(caseMemberCheck.ParentId, caseMemberCheck);
//				}

				// Wish Granted task
				if (caseMemberCheck.End_Date__c != null
						&& oldCaseMap.get(caseMemberCheck.Id).End_Date__c
						!= caseMemberCheck.End_Date__c
						&& caseMemberCheck.RecordTypeId == wishRecordTypeId) {
					endDateIdSet.add(caseMemberCheck.Id);
					presentationCloseTaskIdsSet.add(caseMemberCheck.Id);
					presentationCloseTaskParentIdMap.put(caseMemberCheck.Id, caseMemberCheck);

				}

				/**
				 * JIRA: WLP-286
				 * Author: Gustavo Mayer
				 * Update: wishchildIdMap not used anywhere else
				 */
				//Update the Relationship object when the start date and end date is updated in parent case.
//				if (((oldCaseMap.get(caseMemberCheck.Id).End_Date__c != caseMemberCheck.End_Date__c)
//						|| (caseMemberCheck.Start_Date__c != oldCaseMap.get(caseMemberCheck.Id).Start_Date__c))
//						&& caseMemberCheck.ContactId != null && caseMemberCheck.RecordTypeId == wishRecordTypeId) {
//					wishchildIdMap.put(caseMemberCheck.ContactId, caseMemberCheck);
//				}

				//New medical summary needed
				if ((caseMemberCheck.Start_Date__c != oldCaseMap.get(caseMemberCheck.Id).Start_Date__c)
						&& (caseMemberCheck.Wish_Type__c == CASE_WISH_TYPE_CRUISE_CELEBRITY_ROYAL
						|| caseMemberCheck.Wish_Type__c == CASE_WISH_TYPE_CRUISE_DISNEY
						|| caseMemberCheck.Wish_Type__c == CASE_WISH_TYPE_CRUISE_OTHER
						|| caseMemberCheck.Wish_Type__c == CASE_WISH_TYPE_TRAVEL_INTERNATIONAL
						|| caseMemberCheck.Wish_Type__c == CASE_WISH_TYPE_TRAVEL_HAWAII
						|| caseMemberCheck.Wish_Type__c == CASE_WISH_TYPE_TRAILER_CAMPER
						|| caseMemberCheck.Wish_Type__c == CASE_WISH_TYPE_TRAVEL_OTHER)
						&& caseMemberCheck.RecordTypeId == wishRecordTypeId) {
					if ((caseMemberCheck.Start_Date__c == null) || ((caseMemberCheck.Start_Date__c != null))) {
						newMedicalSummarySet.add(caseMemberCheck.Id);
						wishClearanceMap.put(caseMemberCheck.Id, caseMemberCheck);
					}
				}

				//New wish clearance needed
				if (caseMemberCheck.End_Date__c != null
						&& caseMemberCheck.End_Date__c != oldCaseMap.get(caseMemberCheck.Id).End_Date__c
						&& caseMemberCheck.RecordTypeId == wishRecordTypeId) {
					if ((caseMemberCheck.Wish_Clearance_Received_Date__c == null)
							|| (Date.today().monthsBetween(caseMemberCheck.Wish_Clearance_Received_Date__c) > 6)) {
						newWishClearanceSet.add(caseMemberCheck.Id);
						wishClearanceMap.put(caseMemberCheck.Id, caseMemberCheck);
					}
					if (caseMemberCheck.Wish_Type__c == CASE_WISH_TYPE_CELEBRITY_DOMESTIC_TRAVEL
							|| caseMemberCheck.Wish_Type__c == CASE_WISH_TYPE_CELEBRITY_LOCAL
							|| caseMemberCheck.Wish_Type__c == CASE_WISH_TYPE_CELEBRITY_INTERNATIONAL_TRAVEL
							|| caseMemberCheck.Wish_Type__c == CASE_WISH_TYPE_TRAVEL_INTERNATIONAL
							|| caseMemberCheck.Wish_Type__c == CASE_WISH_TYPE_TRAVEL_HAWAII
							|| caseMemberCheck.Wish_Type__c == CASE_WISH_TYPE_TRAILER_CAMPER
							|| caseMemberCheck.Wish_Type__c == CASE_WISH_TYPE_TRAVEL_OTHER
							&& caseMemberCheck.RecordTypeId == wishRecordTypeId) {
						// 		if ((caseMemberCheck.Child_s_Medical_Summary_received_date__c == null)
						// 				|| ((Date.today().monthsBetween(caseMemberCheck.Child_s_Medical_Summary_received_date__c) > 6))) {
						// 			newMedicalWishClearanceSet.add(caseMemberCheck.Id);
						// 			wishClearanceMap.put(caseMemberCheck.Id, caseMemberCheck);
						// 		}
					}
				}

				if (caseMemberCheck.End_Date__c == null
						&& oldCaseMap.get(caseMemberCheck.Id).End_Date__c != caseMemberCheck.End_Date__c
						&& caseMemberCheck.RecordTypeId == wishRecordTypeId) {
					endDateIdSet.add(caseMemberCheck.Id);
					if (caseMemberCheck.Wish_Assist__c == false) {
						presentationOpenTaskIdsSet.add(caseMemberCheck.Id);
					}
					presentationCloseTaskParentIdMap.put(caseMemberCheck.Id, caseMemberCheck);
				}

				/**
				 * WLP-428
				 * Condition only used to update a map that is then used to update tasks,
				 * the tasks is deprecated as part of WLP-467
				 */
				//For closing concept approval task when wish status set to Wish Determined within policy
//				if ((caseMemberCheck.Status == 'Wish Determined'
//						&& caseMemberCheck.Sub_Status__c == 'Within Policy')
//						&& (caseMemberCheck.Status != oldCaseMap.get(caseMemberCheck.Id).Status
//						|| caseMemberCheck.Sub_Status__c
//						!= oldCaseMap.get(caseMemberCheck.Id).Sub_Status__c)
//						&& caseMemberCheck.RecordTypeId == wishRecordTypeId) {
//					conceptApprovalParentIdSet.add(caseMemberCheck.Id);
//				}

				/**
				 * JIRA: WLP-286
				 * Author: Gustavo Mayer
				 * Update: Sub case conversion to the single Wish Case,
				 * approved budget status referenced on Wish Case
				 */
				if (CASE_BUDGET_APPROVAL_STATUS_APPROVED.equals(caseMemberCheck.Budget_Approval_Status__c)
						&& caseMemberCheck.Budget_Approval_Status__c != oldCaseMap.get(caseMemberCheck.Id).Budget_Approval_Status__c
						&& caseMemberCheck.RecordTypeId == wishRecordTypeId) {
					approvedBudgetStatus.put(caseMemberCheck.Id, caseMemberCheck.Budget_Approval_Status__c);
				}
				/**
				 * WLP-428
				 * Deprecating DNQ, replacing with Closed
				 */
				if (CASE_STATUS_GRANTED.equals(caseMemberCheck.Status)
						&& (!CASE_STATUS_GRANTED.equals(oldCaseMap.get(caseMemberCheck.Id).Status)
						&& !CASE_STATUS_COMPLETED.equals(oldCaseMap.get(caseMemberCheck.Id).Status)
//						&& !CASE_STATUS_DNQ.equals(oldCaseMap.get(caseMemberCheck.Id).Status)
						&& !CASE_STATUS_CLOSED.equals(oldCaseMap.get(caseMemberCheck.Id).Status))
						&& wishRecordTypeId == caseMemberCheck.RecordTypeId) {
					wishIds.add(caseMemberCheck.Id);
				}

				// if (caseMemberCheck.Update_Wish_Child_Form_Info__c == true
				// 		&& oldCaseMap.get(caseMemberCheck.Id).Update_Wish_Child_Form_Info__c != true
				// 		&& wishRecordTypeId == caseMemberCheck.RecordTypeId) {
				// 	updateWishChildInfo.put(caseMemberCheck.Id, caseMemberCheck);
				// }

				if (caseMemberCheck.Status != oldCaseMap.get(caseMemberCheck.Id).Status
						&& caseMemberCheck.RecordTypeId == diagnosisVerificationRT
						&& caseMemberCheck.Lead__c != null) {
					if (CASE_STATUS_OPEN.equals(caseMemberCheck.Status)
							|| CASE_STATUS_ESCALATED.equals(caseMemberCheck.Status)) {
						PartAWishList.add(caseMemberCheck);
					}
				}

				if (caseMemberCheck.RecordTypeId == wishRecordTypeId
						&& caseMemberCheck.Start_Date__c == null
						&& oldCaseMap.get(caseMemberCheck.Id).Start_Date__c != null) {
					removeAnticipationTaskMap.put(caseMemberCheck.Id, caseMemberCheck);
				} else if (caseMemberCheck.RecordTypeId == wishRecordTypeId
						&& caseMemberCheck.Start_Date__c != null
						&& caseMemberCheck.Start_Date__c != oldCaseMap.get(caseMemberCheck.Id).Start_Date__c) {
					updateAnticipationTaskMap.put(caseMemberCheck.Id, caseMemberCheck);
					wishTypes.add(caseMemberCheck.Wish_Type__c);
				}

				/**
				 * WLP-428
				 * Hold transformed to Status Inactive
 				 * Deprecating DNQ, replacing with Closed
				 */
				if ((
//						CASE_STATUS_DNQ.equals(caseMemberCheck.Status) ||
						CASE_STATUS_CLOSED.equals(caseMemberCheck.Status)
								|| CASE_STATUS_COMPLETED.equals(caseMemberCheck.Status)
								|| CASE_STATUS_INACTIVE.equals(caseMemberCheck.Status)
//						|| CASE_STATUS_HOLD.equals(caseMemberCheck.Status)
								|| CASE_STATUS_QUALIFIED.equals(caseMemberCheck.Status)
								|| CASE_STATUS_READY_TO_ASSIGN.equals(caseMemberCheck.Status)
								|| CASE_STATUS_READY_TO_INTERVIEW.equals(caseMemberCheck.Status))
						&& (caseMemberCheck.RecordTypeId == wishRecordTypeId
//						&& !CASE_STATUS_DNQ.equals(oldCaseMap.get(caseMemberCheck.Id).Status)
						&& !CASE_STATUS_CLOSED.equals(oldCaseMap.get(caseMemberCheck.Id).Status)
						&& !CASE_STATUS_COMPLETED.equals(oldCaseMap.get(caseMemberCheck.Id).Status)
						&& !CASE_STATUS_INACTIVE.equals(oldCaseMap.get(caseMemberCheck.Id).Status)
//						&& !CASE_STATUS_HOLD.equals(oldCaseMap.get(caseMemberCheck.Id).Status)
						&& !CASE_STATUS_READY_TO_ASSIGN.equals(oldCaseMap.get(caseMemberCheck.Id).Status)
						&& !CASE_STATUS_READY_TO_INTERVIEW.equals(oldCaseMap.get(caseMemberCheck.Id).Status)
						&& !CASE_STATUS_QUALIFIED.equals(oldCaseMap.get(caseMemberCheck.Id).Status))) {
					inProgressUnCheckCaseIdsSet.add(caseMemberCheck.Id);
				}

				//For creating 2 volunteer opportunity record when the case status changed to "Ready to Assign" from "Qualified".
				if ((CASE_STATUS_READY_TO_ASSIGN.equals(caseMemberCheck.Status))
						&& CASE_STATUS_QUALIFIED.equals(oldCaseMap.get(caseMemberCheck.Id).Status)
						&& caseMemberCheck.RecordTypeId == wishRecordTypeId
						&& caseMemberCheck.Wish_Assist__c == false) {
					if (RecursiveTriggerHandler.isFirstTime == true) {
						readyToAssignParentCaseMap.put(caseMemberCheck.Id, caseMemberCheck);
						readyToAssignChapterIdSet.add(caseMemberCheck.ChapterName__c);
					}
				}

				//if Status is 'Granted' then populate the hiddengranteddate in Contact
				if (CASE_STATUS_GRANTED.equals(caseMemberCheck.Status)
						&& !CASE_STATUS_GRANTED.equals(oldCaseMap.get(caseMemberCheck.Id).Status)
						&& caseMemberCheck.ContactId != null
						&& caseMemberCheck.RecordTypeId == wishRecordTypeId) {
					wishGrantedIdList.add(caseMemberCheck);
				}

				//When the case is Updated as Granted,Completed,DNQ,Closed,Hold,Inactive statuses delete any volunteer opportunities that do not have a volunteer assigned
				/**
				 * WLP-428
				 * Hold transformed to Status Inactive
 				 * Deprecating DNQ, replacing with Closed
				 */
				if (caseMemberCheck.RecordTypeId == wishRecordTypeId
						&& (CASE_STATUS_GRANTED.equals(caseMemberCheck.Status)
						|| CASE_STATUS_COMPLETED.equals(caseMemberCheck.Status)
//						|| CASE_STATUS_DNQ.equals(caseMemberCheck.Status)
						|| CASE_STATUS_CLOSED.equals(caseMemberCheck.Status)
//						|| CASE_STATUS_HOLD.equals(caseMemberCheck.Status)
						|| CASE_STATUS_INACTIVE.equals(caseMemberCheck.Status))
						&& oldCaseMap.get(caseMemberCheck.Id).Status != caseMemberCheck.Status
						&& RecursiveTriggerHandler.blockCaseLockRecursive == true) {
					parentWishIdSet.add(caseMemberCheck.Id);
				}

				if (CASE_STATUS_COMPLETED.equals(caseMemberCheck.Status)
						&& !CASE_STATUS_COMPLETED.equals(oldCaseMap.get(caseMemberCheck.Id).Status)
						&& caseMemberCheck.RecordTypeId == wishRecordTypeId) {
					completedCaseIdSet.add(caseMemberCheck.Id);
				}
				if (!CASE_STATUS_CLOSED.equals(oldCaseMap.get(caseMemberCheck.Id).Status)
						&& CASE_STATUS_CLOSED.equals(caseMemberCheck.Status)
						&& caseMemberCheck.RecordTypeId == wishRecordTypeId) {
					closedCaseIdSet.add(caseMemberCheck.Id);
				}
				//This lines are related to WVC-1804 update the wish Clearance Form field in the Planning case.
				if (caseMemberCheck.Wish_Clearance_Needed__c != oldCaseMap.get(caseMemberCheck.Id).Wish_Clearance_Needed__c
						&& caseMemberCheck.RecordTypeId == wishRecordTypeId
						&& caseMemberCheck.Wish_Clearance_Needed__c != null) {
					parentWishClearanceMap.put(caseMemberCheck.Id, caseMemberCheck);
				}

				exceptionList.add(caseMemberCheck);
			}
			/*Adding as per IME 18*/
			if (caseMemberCheck.RecordTypeId == diagnosisVerificationRT
					&& ((CASE_STATUS_NEW.equals(caseMemberCheck.Status)
					&& !CASE_STATUS_NEW.equals(oldCaseMap.get(caseMemberCheck.Id).Status))
					|| (CASE_STATUS_PENDING_CLARIFICATION_MAC.equals(caseMemberCheck.Status)
					&& !CASE_STATUS_PENDING_CLARIFICATION_MAC.equals(oldCaseMap.get(caseMemberCheck.Id).Status))
					|| (CASE_STATUS_PENDING_CLARIFICATION_MAC_CONSULT_REQ.equals(caseMemberCheck.Status)
					&& !CASE_STATUS_PENDING_CLARIFICATION_MAC_CONSULT_REQ.equals(oldCaseMap.get(caseMemberCheck.Id).Status))
					|| (CASE_STATUS_PENDING_CLARIFICATION_CHAPTER.equals(caseMemberCheck.Status)
					&& !CASE_STATUS_PENDING_CLARIFICATION_CHAPTER.equals(oldCaseMap.get(caseMemberCheck.Id).Status)))) {
				caseToLeadSubStatusUpdate.put(caseMemberCheck.Lead__c, caseMemberCheck.Status);
			}
		}

		if (wishGrantedSet.size() > 0) {
			Case_OnAfterUpdateTriggerHandlerHelper.populateEndDate(wishGrantedSet);
		}

		/**
		 * JIRA: WLP-286
		 * Author: Gustavo Mayer
		 * Update: Sub case conversion to the single Wish Case,
		 * no need to update as there is no longer the concept of parent case.
		 */
//		if (surveyEmailMap.size() > 0) {
//			Case_OnAfterUpdateTriggerHandlerHelper.updateSurveyField(surveyEmailMap, impactparentIdSet);
//		}
		if (closeTaskParentIdSet.size() > 0) {
			Case_OnAfterUpdateTriggerHandlerHelper.deleteWishAssitTask(closeTaskParentIdSet, exceptionList);
		}

		/*if (birthdayDateUpdateMap.size() > 0) {
			Case_OnAfterUpdateTriggerHandlerHelper.updateContactBirthDate(birthdayDateUpdateMap, bdayWishChildSet);
		}*/
		/**
		 * JIRA: WLP-286
		 * Author: Gustavo Mayer
		 * Update: Sub case conversion to the single Wish Case,
		 * no need to update as there is no longer the concept of parent case.
		 */
//		if (wishReceiptMap.size() > 0) {
//			Case_OnAfterUpdateTriggerHandlerHelper.UpdateWishRecipetItems(wishReceiptMap, exceptionList);
//		}
		/**
		 * WLP-428
		 * Condition only used to call update tasks,
		 * the tasks is deprecated as part of WLP-467
		 */
//		if (TaskParentIdSet.size() > 0) {
//			Case_OnAfterUpdateTriggerHandlerHelper.closeAllOpenTask(TaskParentIdSet, exceptionList);
//		}
		if (parentWishIdSet.size() > 0) {
			Case_OnAfterUpdateTriggerHandlerHelper.deleteUnassignedVolunteerOpp(parentWishIdSet, exceptionList);
		}
		if (caseIdSetForVolOpp.size() > 0) {
			Case_OnAfterUpdateTriggerHandlerHelper.closeVolOpp(caseIdSetForVolOpp, exceptionList);
		}
		if (updatedApprovedLeadInfoSet.size() > 0 || updatedDnqLeadInfoSet.size() > 0) {
			Case_OnAfterUpdateTriggerHandlerHelper.updateLeadStatus(updatedApprovedLeadInfoSet, updatedDnqLeadInfoSet, exceptionList);
		}
		if (volunteerCaseIdSet.size() > 0) {
			Case_OnAfterUpdateTriggerHandlerHelper.updateVolunteerOpp(volunteerCaseIdSet, true, exceptionList);
		}
		if (inProgressUnCheckCaseIdsSet.size() > 0) {
			Case_OnAfterUpdateTriggerHandlerHelper.updateVolunteerOpp(inProgressUnCheckCaseIdsSet, false, exceptionList);
		}
		if (wishGrantedIdList.size() > 0) {
			Case_OnAfterUpdateTriggerHandlerHelper.updateGrantedDate(wishGrantedIdList);
		}
		/**
		 * JIRA: WLP-286
		 * Author: Gustavo Mayer
		 * Update: Sub case conversion to the single Wish Case,
		 * no need to update as there is no longer the concept of parent case.
		 */
//		if (caseParentIdSet.size() > 0) {
//			Case_OnAfterUpdateTriggerHandlerHelper.UpdateSubCaseStatus(caseParentIdSet, exceptionList);
//		}
		if (updateVolunteerManagerCaseTeamMap.size() > 0) {
			Case_OnAfterUpdateTriggerHandlerHelper.CreateAndUpdateUserCaseTeamRole(updateVolunteerManagerCaseTeamMap, volunteerManagerIdSet, wishCoordinatorIdSet);
		}
		if (caseContactMap.size() > 0) {
			Case_OnAfterUpdateTriggerHandlerHelper.changeAccessPermission(caseContactMap, exceptionList);
		}
		/*WLP-467 remove automated task creation */
//		if (wishPlanningAndGrantinTaskParentMap.size() > 0) {
//			Case_OnAfterUpdateTriggerHandlerHelper.wishPlaningAnticipationTaskCreation(wishPlanningAndGrantinTaskParentMap);
//			Case_OnAfterUpdateTriggerHandlerHelper.wishGrantedSubCaseTaskCreation(wishPlanningAndGrantinTaskParentMap);
//		}
		/**
		 * JIRA: WLP-286
		 * Author: Gustavo Mayer
		 * Update: Sub case conversion to the single Wish Case,
		 * no need to update as there is no longer the concept of parent case.
		 */
//		if (newCaseOwnerMap.size() > 0) {
//			Case_OnAfterUpdateTriggerHandlerHelper.changeChildCasesOwner(newCaseOwnerMap, exceptionList);
//		}

		/*WLP-467 remove automated task creation */
//		if (wishClearanceMap.size() > 0 && (newWishClearanceSet.size() > 0 || newMedicalSummarySet.size() > 0 || newMedicalWishClearanceSet.size() > 0)) {
//			Case_OnAfterUpdateTriggerHandlerHelper.wishClearanceTask(wishClearanceMap, newWishClearanceSet, newMedicalSummarySet, newMedicalWishClearanceSet);
//		}
//
//		if (parentWishInfoMap.size() > 0) {
//			Case_OnAfterUpdateTriggerHandlerHelper.wishDeterminationSubCaseTaskCreation(parentWishInfoMap);
//		}
//		if (caseIdsMap.size() > 0) {
//			Case_OnAfterUpdateTriggerHandlerHelper.deleteAnticipationTask(caseIdsMap, newWishTypeSet);
//		}
//		if (updateAniticipationTaskMap.size() > 0 || removeAniticipationTaskMap.size() > 0) {
//			Case_OnAfterUpdateTriggerHandlerHelper.updateAnticipationTasks(updateAniticipationTaskMap, removeAniticipationTaskMap, wishTypes);
//		}
//		if (UpdateAllOpenTasks.size() > 0) {
//			Case_OnAfterUpdateTriggerHandlerHelper.UpdateTasksAsAbondoned(UpdateAllOpenTasks);
//		}
		/*if(diagnosisVerificationCaseList.size() > 0 && RecursiveTriggerHandler.nationalEmailRecurrence == false) {
			Case_OnAfterUpdateTriggerHandlerHelper.sendEmailToNationalMACTeam(diagnosisVerificationCaseList);
		}*/
		if (caseTeamMemberParentIdSet.size() > 0 && revokingContactIdSet.size() > 0) {
			Case_OnAfterUpdateTriggerHandlerHelper.revokeWishPermissionForVolunteers(caseTeamMemberParentIdSet, revokingContactIdSet);
		}
		if (approvedBudgetStatus.size() > 0) {
			//Case_OnAfterUpdateTriggerHandlerHelper.matchBudgetData(approvedBudgetStatus);
		}
		if (PartAWishList.size() > 0) {
			Case_OnAfterUpdateTriggerHandlerHelper.UpdateLeadStatus(PartAWishList);
		}
		if (wishIds.size() > 0) {
			Case_OnAfterUpdateTriggerHandlerHelper.grantedWishCount(wishIds);
		}
		/*if (updateWishChildInfo.size() > 0) {
			WishChildFormValUpdate_AC.UpdateWishChildandWishFamily(updateWishChildInfo);
		}*/
		/**
		 * WLP-428
		 * Condition only used to call update tasks,
		 * the tasks is deprecated as part of WLP-467
		 */
//		if (dueDateMap.size() > 0) {
//			Case_OnAfterUpdateTriggerHandlerHelper.updateDeterminationTaskDueDates(dueDateMap, exceptionList);
//		}
		/**
		 * WLP-428
		 * Condition only used to call update tasks,
		 * the tasks is deprecated as part of WLP-467
		 */
//		if ((interViewCloseTaskIdsSet.size() > 0 || insertInterViewOpenTaskIdSet.size() > 0) && interviewTaskParentIdMap.size() > 0) {
//			Case_OnAfterUpdateTriggerHandlerHelper.inTerviewTask(interViewCloseTaskIdsSet, insertInterViewOpenTaskIdSet, interviewTaskParentIdMap);
//		}
		/**
		 * JIRA: WLP-286
		 * Author: Gustavo Mayer
		 * Update: Sub case conversion to the single Wish Case,
		 * updating the interview date on the Wish Case itself.
		 */
//		if (interViewCloseTaskIdsSet.size() > 0) {
//			Case_OnAfterUpdateTriggerHandlerHelper.updateWishDeterminationInterviewDateNotSet(interViewCloseTaskIdsSet, exceptionList);
//		}
//		if (interViewOpenTaskIdsSet.size() > 0) {
//			Case_OnAfterUpdateTriggerHandlerHelper.updateWishDeterminationInterviewDateNotSet(interViewOpenTaskIdsSet, exceptionList);
//		}
		/**
		 * WLP-428
		 * Condition only used to call update tasks,
		 * the tasks is deprecated as part of WLP-467
		 */
//		if ((presentationCloseTaskIdsSet.size() > 0 || presentationOpenTaskIdsSet.size() > 0) && presentationCloseTaskParentIdMap.size() > 0) {
//			Case_OnAfterUpdateTriggerHandlerHelper.wishGrantedPresentationTask(presentationCloseTaskIdsSet, presentationOpenTaskIdsSet, presentationCloseTaskParentIdMap, presentationIdsSet, endDateIdSet, presentatationIdentifySet, exceptionList);
//		}
		/**
		 * WLP-428
		 * Condition only used to call update tasks,
		 * the tasks is deprecated as part of WLP-467
		 */
//		if (conceptApprovalParentIdSet.size() > 0) {
//			Case_OnAfterUpdateTriggerHandlerHelper.autoCloseTask(conceptApprovalParentIdSet, exceptionList);
//		}
		if (completedCaseIdSet.size() > 0 && completedCaseIdSet != null) {
			Case_OnAfterUpdateTriggerHandlerHelper.updateVolunteerOpportunityStatus(completedCaseIdSet, exceptionList);
		}
		if (readyToAssignParentCaseMap.size() > 0 && readyToAssignChapterIdSet.size() > 0) {
			Case_OnAfterUpdateTriggerHandlerHelper.createVolunteerOpportunity(readyToAssignParentCaseMap, readyToAssignChapterIdSet);
		}
		if (closedCaseIdSet.size() > 0) {
			Case_OnAfterUpdateTriggerHandlerHelper.updateVolunteerOpportunityasInactive(closedCaseIdSet, exceptionList);
		}
		/**
		 * JIRA: WLP-286
		 * Author: Gustavo Mayer
		 * Update: Sub case conversion to the single Wish Case,
		 * no need to update as there is no longer the concept of parent case.
		 */
//		if (forTrackingMap.size() > 0) {
//			Case_OnAfterUpdateTriggerHandlerHelper.updateCaseFormTracking(forTrackingMap);
//		}

		//WVC-1804
		if (parentWishClearanceMap.size() > 0) {
			Case_OnAfterUpdateTriggerHandlerHelper.updateWishClearanceForm(parentWishClearanceMap);
		}
		//IME 18
		if (caseToLeadSubStatusUpdate.size() > 0) {
			Case_OnAfterUpdateTriggerHandlerHelper.updateCaseToLeadSubStatus('Eligibility Review', caseToLeadSubStatusUpdate);
		}
	}
}