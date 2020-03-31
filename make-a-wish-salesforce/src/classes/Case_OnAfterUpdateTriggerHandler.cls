/*
Modification Log
1. 26/03/18 - Vignesh SM - IME 18 - Line No 92, 518-520, 385-392
*/
public class Case_OnAfterUpdateTriggerHandler {
	private static final Id WISH_RECORDTYPE_ID = Constant_AC.WISH_RT_ID;
	private static final Id WISH_ASSIST_RECORDTYPE_ID = Constant_AC.WISH_ASSIST_RT_ID;
	private static final Id DIAGNOSIS_VERIFICATION_RECORDTYPE_ID = Constant_AC.DIAGNOSIS_RT_ID;

	private static final Set<Id> CASE_MEMBER_CHECK_IDS = new Set<Id>
	{WISH_RECORDTYPE_ID, WISH_ASSIST_RECORDTYPE_ID, DIAGNOSIS_VERIFICATION_RECORDTYPE_ID};
	private static final Set<String> WISH_COORDINATOR_ID_CHECK_STATUSES = new Set<String>{
		Constant_AC.CASE_STATUS_WISH_DETERMINED, Constant_AC.CASE_STATUS_WISH_DESIGN,
		Constant_AC.CASE_STATUS_WISH_SCHEDULED, Constant_AC.CASE_STATUS_PENDING_APPROVAL
	};
	private static final Set<String> VOLUNTEER_CASE_ID_CHECK_HAS_STATUS = new Set<String>{
		Constant_AC.CASE_STATUS_WISH_DETERMINED, Constant_AC.CASE_STATUS_PENDING_APPROVAL,
		Constant_AC.CASE_STATUS_WISH_DESIGN, Constant_AC.CASE_STATUS_WISH_SCHEDULED,
		Constant_AC.CASE_STATUS_GRANTED
	};
	private static final Set<String> VOLUNTEER_CASE_ID_CHECK_NOT_HAS_STATUSES = new Set<String>{
		Constant_AC.CASE_STATUS_WISH_DETERMINED, Constant_AC.CASE_STATUS_PENDING_APPROVAL,
		Constant_AC.CASE_STATUS_WISH_DESIGN, Constant_AC.CASE_STATUS_WISH_SCHEDULED,
		Constant_AC.CASE_STATUS_GRANTED
	};
	private static final Set<String> CLOSE_BIRTHDAY_TASK_SET_STATUSES = new Set<String>{
		Constant_AC.CASE_STATUS_COMPLETED, Constant_AC.CASE_STATUS_CLOSED,
		Constant_AC.CASE_STATUS_GRANTED, Constant_AC.CASE_STATUS_INACTIVE
	};
	private static final Set<String> CASE_MEMBER_WISH_TYPE_CHECK = new Set<String>{
		Constant_AC.CASE_WISH_TYPE_CRUISE_CELEBRITY_ROYAL, Constant_AC.CASE_WISH_TYPE_CRUISE_DISNEY,
		Constant_AC.CASE_WISH_TYPE_CRUISE_OTHER, Constant_AC.CASE_WISH_TYPE_TRAVEL_INTERNATIONAL,
		Constant_AC.CASE_WISH_TYPE_TRAVEL_HAWAII, Constant_AC.CASE_WISH_TYPE_TRAILER_CAMPER,
		Constant_AC.CASE_WISH_TYPE_TRAVEL_OTHER
	};
	private static final Set<String> IN_PROGRESS_UNCHECK_HAS_STATUS = new Set<String>{
		Constant_AC.CASE_STATUS_CLOSED, Constant_AC.CASE_STATUS_COMPLETED,
		Constant_AC.CASE_STATUS_INACTIVE, Constant_AC.CASE_STATUS_QUALIFIED,
		Constant_AC.CASE_STATUS_READY_TO_ASSIGN, Constant_AC.CASE_STATUS_READY_TO_INTERVIEW
	};
	private static final Set<String> IN_PROGRESS_UNCHECK_NOT_HAS_STATUSES = new Set<String>{
		Constant_AC.CASE_STATUS_CLOSED, Constant_AC.CASE_STATUS_COMPLETED,
		Constant_AC.CASE_STATUS_INACTIVE, Constant_AC.CASE_STATUS_READY_TO_ASSIGN,
		Constant_AC.CASE_STATUS_READY_TO_INTERVIEW, Constant_AC.CASE_STATUS_QUALIFIED
	};
	private static final Set<String> PARENT_WISH_ID_SET_STATUSES = new Set<String>{
		Constant_AC.CASE_STATUS_COMPLETED, Constant_AC.CASE_STATUS_CLOSED,
		Constant_AC.CASE_STATUS_GRANTED, Constant_AC.CASE_STATUS_INACTIVE
	};


	/*
     * @description		OnAfterUpdate trigger handler for the Case object
     *
     * @author 			MST Solutions
     * @createdDate		2018-03-26
     */
	public static void onAfterUpdate(Map<Id, Case>newCaseMap, Map<Id, Case> oldCaseMap) {
		Set<Id> newWishClearanceSet = new Set<Id>();
		Set<Id> closeTaskParentIdSet = new Set<Id>();
		Set<Id> caseIdSetForVolOpp = new Set<Id>();
		Map<Id, Case> updateVolunteerManagerCaseTeamMap = new Map<Id, Case>();
		Set<Id> volunteerManagerIdSet = new Set<Id>();
		Set<Id> wishCoordinatorIdSet = new Set<Id>();
		Map<Id, Id> caseContactMap = new Map<Id, Id>();
		Set<Id> volunteerCaseIdSet = new Set<Id>();
		Map<Id, Case> caseIdsMap = new Map<Id, Case>();
		Set<String> newWishTypeSet = new Set<String>();
		Set<String> updatedApprovedLeadInfoSet = new Set<String>();
		Set<String> updatedDnqLeadInfoSet = new Set<String>();
		Map<Id, Case> UpdateAllOpenTasks = new Map<Id, Case>();
		Set<Id> caseTeamMemberParentIdSet = new Set<Id>();
		Set<Id> revokingContactIdSet = new Set<Id>();
		Set<Id> presentationCloseTaskIdsSet = new Set<Id>();
		Map<Id, Case> presentationCloseTaskParentIdMap = new Map<Id, Case>();
		Set<Id> presentationOpenTaskIdsSet = new Set<Id>();
		Set<Id> endDateIdSet = new Set<Id>();
		Set<Id> newMedicalSummarySet = new Set<Id>();
		Map<Id, Case> wishClearanceMap = new Map<Id, Case>();
		Map<Id, String> approvedBudgetStatus = new Map<Id, String>();
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
		Map<Id, Case> parentWishClearanceMap = new Map<Id, Case>();
		Map<Id, String> caseToLeadSubStatusUpdate = new Map<Id, String>();
		Set<Id> closeBirthDayTaskSet = new Set<Id>();

		for (Case caseMemberCheck : newCaseMap.values()) {
			if (CASE_MEMBER_CHECK_IDS.contains(caseMemberCheck.RecordTypeId)) {

				if (caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID && caseMemberCheck.Wish_Assist__c == true
					&& oldCaseMap.get(caseMemberCheck.Id).Wish_Assist__c != true) {

					closeTaskParentIdSet.add(caseMemberCheck.Id);
				}

				if ((Constant_AC.CASE_STATUS_CLOSED.equals(caseMemberCheck.Status))
					&& caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID
					&& caseMemberCheck.Status != oldCaseMap.get(caseMemberCheck.Id).Status) {

					caseIdSetForVolOpp.add(caseMemberCheck.Id);
				}

				if ((Constant_AC.CASE_STATUS_GRANTED.equals(caseMemberCheck.Status)
					|| Constant_AC.CASE_STATUS_CLOSED.equals(caseMemberCheck.Status))
					&& caseMemberCheck.Status != oldCaseMap.get(caseMemberCheck.Id).Status
					&& caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID) {

					wishGrantedSet.add(caseMemberCheck.Id);
				}

				if (Constant_AC.CASE_STATUS_READY_TO_ASSIGN.equals(caseMemberCheck.Status)
					&& caseMemberCheck.Status != oldCaseMap.get(caseMemberCheck.Id).Status
					&& RecursiveTriggerHandler.blockCaseLockRecursive == true
					&& caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID) {

					updateVolunteerManagerCaseTeamMap.put(caseMemberCheck.Id, caseMemberCheck);
					volunteerManagerIdSet.add(caseMemberCheck.Id);
				} else if ((Constant_AC.CASE_STATUS_READY_TO_ASSIGN.equals(caseMemberCheck.Status)
					|| Constant_AC.CASE_STATUS_READY_TO_INTERVIEW.equals(caseMemberCheck.Status))
					&& caseMemberCheck.OwnerId != oldCaseMap.get(caseMemberCheck.Id).OwnerId
					&& RecursiveTriggerHandler.blockCaseLockRecursive == true
					&& caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID) {

					updateVolunteerManagerCaseTeamMap.put(caseMemberCheck.Id, caseMemberCheck);
					volunteerManagerIdSet.add(caseMemberCheck.Id);
				}

				if (caseMemberCheck.Status != oldCaseMap.get(caseMemberCheck.Id).Status
					&& Constant_AC.CASE_STATUS_WISH_DETERMINED.equals(caseMemberCheck.Status)
					&& RecursiveTriggerHandler.blockCaseLockRecursive == true
					&& caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID) {

					updateVolunteerManagerCaseTeamMap.put(caseMemberCheck.Id, caseMemberCheck);
					wishCoordinatorIdSet.add(caseMemberCheck.Id);
				} else if ((caseMemberCheck.OwnerId != oldCaseMap.get(caseMemberCheck.Id).OwnerId
					&& RecursiveTriggerHandler.blockCaseLockRecursive == true)
					&& WISH_COORDINATOR_ID_CHECK_STATUSES.contains(caseMemberCheck.Status)
					&& caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID) {

					updateVolunteerManagerCaseTeamMap.put(caseMemberCheck.Id, caseMemberCheck);
					wishCoordinatorIdSet.add(caseMemberCheck.Id);
				}

				if ((!Constant_AC.CASE_STATUS_CLOSED.equals(caseMemberCheck.Status)
					&& !Constant_AC.CASE_STATUS_COMPLETED.equals(caseMemberCheck.Status)
					&& RecursiveTriggerHandler.blockCaseLockRecursive == true)
					&& (Constant_AC.CASE_STATUS_CLOSED.equals(oldCaseMap.get(caseMemberCheck.Id))
					|| Constant_AC.CASE_STATUS_COMPLETED.equals(oldCaseMap.get(caseMemberCheck.Id)))
					&& caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID) {

					caseContactMap.put(caseMemberCheck.Id, caseMemberCheck.ContactId);
				}

				if (VOLUNTEER_CASE_ID_CHECK_HAS_STATUS.contains(caseMemberCheck.Status)
					&& caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID
					&& RecursiveTriggerHandler.blockCaseLockRecursive == true
					&& !VOLUNTEER_CASE_ID_CHECK_NOT_HAS_STATUSES.contains(oldCaseMap.get(caseMemberCheck.Id).Status)) {

					volunteerCaseIdSet.add(caseMemberCheck.Id);
				}

				if (oldCaseMap.get(caseMemberCheck.Id).Wish_Type__c != caseMemberCheck.Wish_Type__c
					&& caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID) {

					caseIdsMap.put(caseMemberCheck.Id, caseMemberCheck);
					newWishTypeSet.add(caseMemberCheck.Wish_Type__c);
				}

				if ((Constant_AC.CASE_STATUS_APPROVED_NATIONAL_MEDICAL_REVIEW.equals(caseMemberCheck.Status)
					&& !Constant_AC.CASE_STATUS_APPROVED_NATIONAL_MEDICAL_REVIEW.equals(oldCaseMap.get(caseMemberCheck.Id).Status))
					|| (Constant_AC.CASE_STATUS_APPROVED_NATIONAL_MAC_REVIEW.equals(caseMemberCheck.Status)
					&& !Constant_AC.CASE_STATUS_APPROVED_NATIONAL_MAC_REVIEW.equals(oldCaseMap.get(caseMemberCheck.Id).Status))
					&& caseMemberCheck.RecordTypeId == DIAGNOSIS_VERIFICATION_RECORDTYPE_ID) {

					updatedApprovedLeadInfoSet.add(caseMemberCheck.Lead__c);
				} else if ((Constant_AC.CASE_STATUS_DNQ_NATIONAL_MEDICAL_REVIEW.equals(caseMemberCheck.Status)
					|| Constant_AC.CASE_STATUS_DNQ_NATIONAL_MAC_REVIEW.equals(caseMemberCheck.Status))
					&& caseMemberCheck.RecordTypeId == DIAGNOSIS_VERIFICATION_RECORDTYPE_ID
					&& oldCaseMap.get(caseMemberCheck.Id).Status != caseMemberCheck.Status) {

					updatedDnqLeadInfoSet.add(caseMemberCheck.Lead__c);
				}

				if ((Constant_AC.CASE_STATUS_COMPLETED.equals(caseMemberCheck.Status)
					|| Constant_AC.CASE_STATUS_CLOSED.equals(caseMemberCheck.Status))
					&& (oldCaseMap.get(caseMemberCheck.Id).Status != caseMemberCheck.Status
					&& caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID)) {

					caseTeamMemberParentIdSet.add(caseMemberCheck.Id);
					revokingContactIdSet.add(caseMemberCheck.ContactId);
				}

				if (CLOSE_BIRTHDAY_TASK_SET_STATUSES.contains(caseMemberCheck.Status)
					&& (oldCaseMap.get(caseMemberCheck.Id).Status != caseMemberCheck.Status
					&& caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID)) {

					closeBirthDayTaskSet.add(caseMemberCheck.Id);
				}

				// Wish Granted task
				if (caseMemberCheck.End_Date__c != null
					&& oldCaseMap.get(caseMemberCheck.Id).End_Date__c
					!= caseMemberCheck.End_Date__c
					&& caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID) {

					endDateIdSet.add(caseMemberCheck.Id);
					presentationCloseTaskIdsSet.add(caseMemberCheck.Id);
					presentationCloseTaskParentIdMap.put(caseMemberCheck.Id, caseMemberCheck);
				}

				// New medical summary needed
				if ((caseMemberCheck.Start_Date__c != oldCaseMap.get(caseMemberCheck.Id).Start_Date__c)
					&& CASE_MEMBER_WISH_TYPE_CHECK.contains(caseMemberCheck.Wish_Type__c)
					&& caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID) {

					if ((caseMemberCheck.Start_Date__c == null) || ((caseMemberCheck.Start_Date__c != null))) {
						newMedicalSummarySet.add(caseMemberCheck.Id);
						wishClearanceMap.put(caseMemberCheck.Id, caseMemberCheck);
					}
				}

				// New wish clearance needed
				if (caseMemberCheck.End_Date__c != null
					&& caseMemberCheck.End_Date__c != oldCaseMap.get(caseMemberCheck.Id).End_Date__c
					&& caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID) {

					if ((caseMemberCheck.Wish_Clearance_Received_Date__c == null)
						|| (Date.today().monthsBetween(caseMemberCheck.Wish_Clearance_Received_Date__c) > 6)) {
						newWishClearanceSet.add(caseMemberCheck.Id);
						wishClearanceMap.put(caseMemberCheck.Id, caseMemberCheck);
					}
				}

				if (caseMemberCheck.End_Date__c == null
					&& oldCaseMap.get(caseMemberCheck.Id).End_Date__c != caseMemberCheck.End_Date__c
					&& caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID) {

					endDateIdSet.add(caseMemberCheck.Id);
					if (caseMemberCheck.Wish_Assist__c == false) {
						presentationOpenTaskIdsSet.add(caseMemberCheck.Id);
					}

					presentationCloseTaskParentIdMap.put(caseMemberCheck.Id, caseMemberCheck);
				}

				if (Constant_AC.CASE_BUDGET_APPROVAL_STATUS_APPROVED.equals(caseMemberCheck.Budget_Approval_Status__c)
					&& caseMemberCheck.Budget_Approval_Status__c != oldCaseMap.get(caseMemberCheck.Id).Budget_Approval_Status__c
					&& caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID) {

					approvedBudgetStatus.put(caseMemberCheck.Id, caseMemberCheck.Budget_Approval_Status__c);
				}

				if (Constant_AC.CASE_STATUS_GRANTED.equals(caseMemberCheck.Status)
					&& (!Constant_AC.CASE_STATUS_GRANTED.equals(oldCaseMap.get(caseMemberCheck.Id).Status)
					&& !Constant_AC.CASE_STATUS_COMPLETED.equals(oldCaseMap.get(caseMemberCheck.Id).Status)
					&& !Constant_AC.CASE_STATUS_CLOSED.equals(oldCaseMap.get(caseMemberCheck.Id).Status))
					&& WISH_RECORDTYPE_ID == caseMemberCheck.RecordTypeId) {

					wishIds.add(caseMemberCheck.Id);
				}

				if (caseMemberCheck.Status != oldCaseMap.get(caseMemberCheck.Id).Status
					&& caseMemberCheck.RecordTypeId == DIAGNOSIS_VERIFICATION_RECORDTYPE_ID
					&& caseMemberCheck.Lead__c != null) {

					if (Constant_AC.CASE_STATUS_OPEN.equals(caseMemberCheck.Status)
						|| Constant_AC.CASE_STATUS_ESCALATED.equals(caseMemberCheck.Status)) {

						PartAWishList.add(caseMemberCheck);
					}
				}

				if (caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID
					&& caseMemberCheck.Start_Date__c == null
					&& oldCaseMap.get(caseMemberCheck.Id).Start_Date__c != null) {

					removeAnticipationTaskMap.put(caseMemberCheck.Id, caseMemberCheck);
				} else if (caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID
					&& caseMemberCheck.Start_Date__c != null
					&& caseMemberCheck.Start_Date__c != oldCaseMap.get(caseMemberCheck.Id).Start_Date__c) {

					updateAnticipationTaskMap.put(caseMemberCheck.Id, caseMemberCheck);
					wishTypes.add(caseMemberCheck.Wish_Type__c);
				}


				if (IN_PROGRESS_UNCHECK_HAS_STATUS.contains(caseMemberCheck.Status)
					&& caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID
					&& !IN_PROGRESS_UNCHECK_NOT_HAS_STATUSES.contains(oldCaseMap.get(caseMemberCheck.Id).Status)) {

					inProgressUnCheckCaseIdsSet.add(caseMemberCheck.Id);
				}

				// For creating 2 volunteer opportunity record when the case status changed to "Ready to Assign" from "Qualified".
				if ((Constant_AC.CASE_STATUS_READY_TO_ASSIGN.equals(caseMemberCheck.Status))
					&& Constant_AC.CASE_STATUS_QUALIFIED.equals(oldCaseMap.get(caseMemberCheck.Id).Status)
					&& caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID
					&& caseMemberCheck.Wish_Assist__c == false) {
					if (RecursiveTriggerHandler.isFirstTime == true) {

						readyToAssignParentCaseMap.put(caseMemberCheck.Id, caseMemberCheck);
						readyToAssignChapterIdSet.add(caseMemberCheck.ChapterName__c);
					}
				}

				// if Status is 'Granted' then populate the hiddengranteddate in Contact
				if (Constant_AC.CASE_STATUS_GRANTED.equals(caseMemberCheck.Status)
					&& !Constant_AC.CASE_STATUS_GRANTED.equals(oldCaseMap.get(caseMemberCheck.Id).Status)
					&& caseMemberCheck.ContactId != null
					&& caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID) {

					wishGrantedIdList.add(caseMemberCheck);
				}

				if (caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID
					&& PARENT_WISH_ID_SET_STATUSES.contains(caseMemberCheck.Status)
					&& oldCaseMap.get(caseMemberCheck.Id).Status != caseMemberCheck.Status
					&& RecursiveTriggerHandler.blockCaseLockRecursive == true) {

					parentWishIdSet.add(caseMemberCheck.Id);
				}

				if (Constant_AC.CASE_STATUS_COMPLETED.equals(caseMemberCheck.Status)
					&& !Constant_AC.CASE_STATUS_COMPLETED.equals(oldCaseMap.get(caseMemberCheck.Id).Status)
					&& caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID) {

					completedCaseIdSet.add(caseMemberCheck.Id);
				}
				if (!Constant_AC.CASE_STATUS_CLOSED.equals(oldCaseMap.get(caseMemberCheck.Id).Status)
					&& Constant_AC.CASE_STATUS_CLOSED.equals(caseMemberCheck.Status)
					&& caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID) {

					closedCaseIdSet.add(caseMemberCheck.Id);
				}

				if (caseMemberCheck.Wish_Clearance_Needed__c != oldCaseMap.get(caseMemberCheck.Id).Wish_Clearance_Needed__c
					&& caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID
					&& caseMemberCheck.Wish_Clearance_Needed__c != null) {

					parentWishClearanceMap.put(caseMemberCheck.Id, caseMemberCheck);
				}

				exceptionList.add(caseMemberCheck);
			}

			if (caseMemberCheck.RecordTypeId == DIAGNOSIS_VERIFICATION_RECORDTYPE_ID
				&& ((Constant_AC.CASE_STATUS_NEW.equals(caseMemberCheck.Status)
				&& !Constant_AC.CASE_STATUS_NEW.equals(oldCaseMap.get(caseMemberCheck.Id).Status))
				|| (Constant_AC.CASE_STATUS_PENDING_CLARIFICATION_MAC.equals(caseMemberCheck.Status)
				&& !Constant_AC.CASE_STATUS_PENDING_CLARIFICATION_MAC.equals(oldCaseMap.get(caseMemberCheck.Id).Status))
				|| (Constant_AC.CASE_STATUS_PENDING_CLARIFICATION_MAC_CONSULT_REQ.equals(caseMemberCheck.Status)
				&& !Constant_AC.CASE_STATUS_PENDING_CLARIFICATION_MAC_CONSULT_REQ.equals(oldCaseMap.get(caseMemberCheck.Id).Status))
				|| (Constant_AC.CASE_STATUS_PENDING_CLARIFICATION_CHAPTER.equals(caseMemberCheck.Status)
				&& !Constant_AC.CASE_STATUS_PENDING_CLARIFICATION_CHAPTER.equals(oldCaseMap.get(caseMemberCheck.Id).Status)))) {

				caseToLeadSubStatusUpdate.put(caseMemberCheck.Lead__c, caseMemberCheck.Status);
			}
		}

		if (wishGrantedSet.size() > 0) {
			Case_OnAfterUpdateTriggerHandlerHelper.populateEndDate(wishGrantedSet);
		}
		if (closeTaskParentIdSet.size() > 0) {
			Case_OnAfterUpdateTriggerHandlerHelper.deleteWishAssistTask(closeTaskParentIdSet, exceptionList);
		}
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
		if (updateVolunteerManagerCaseTeamMap.size() > 0) {
			Case_OnAfterUpdateTriggerHandlerHelper.createAndUpdateUserCaseTeamRole(updateVolunteerManagerCaseTeamMap, volunteerManagerIdSet, wishCoordinatorIdSet);
		}
		if (caseContactMap.size() > 0) {
			Case_OnAfterUpdateTriggerHandlerHelper.changeAccessPermission(caseContactMap, exceptionList);
		}
		if (caseTeamMemberParentIdSet.size() > 0 && revokingContactIdSet.size() > 0) {
			Case_OnAfterUpdateTriggerHandlerHelper.revokeWishPermissionForVolunteers(caseTeamMemberParentIdSet, revokingContactIdSet);
		}
		if (PartAWishList.size() > 0) {
			Case_OnAfterUpdateTriggerHandlerHelper.updateLeadStatus(PartAWishList);
		}
		if (wishIds.size() > 0) {
			Case_OnAfterUpdateTriggerHandlerHelper.grantedWishCount(wishIds);
		}
		if (completedCaseIdSet.size() > 0 && completedCaseIdSet != null) {
			Case_OnAfterUpdateTriggerHandlerHelper.updateVolunteerOpportunityStatus(completedCaseIdSet, exceptionList);
		}
		if (readyToAssignParentCaseMap.size() > 0 && readyToAssignChapterIdSet.size() > 0) {
			Case_OnAfterUpdateTriggerHandlerHelper.createVolunteerOpportunity(readyToAssignParentCaseMap, readyToAssignChapterIdSet);
		}
		if (closedCaseIdSet.size() > 0) {
			Case_OnAfterUpdateTriggerHandlerHelper.updateVolunteerOpportunityasInactive(closedCaseIdSet, exceptionList);
		}
		if (parentWishClearanceMap.size() > 0) {
			Case_OnAfterUpdateTriggerHandlerHelper.updateWishClearanceForm(parentWishClearanceMap);
		}
		if (caseToLeadSubStatusUpdate.size() > 0) {
			Case_OnAfterUpdateTriggerHandlerHelper.updateCaseToLeadSubStatus(Constant_AC.LEAD_STATUS_ELIGIBILITY_REVIEW, caseToLeadSubStatusUpdate);
		}
	}
}