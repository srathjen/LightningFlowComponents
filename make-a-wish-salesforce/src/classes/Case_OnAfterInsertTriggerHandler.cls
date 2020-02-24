/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/26/2016
Description : When a new case record insert then it will call the case_OnAfterInsertTriggerHandlerHelper class based
on the collection size() > 0.
*******************************************************************************************************************/

public class Case_OnAfterInsertTriggerHandler {

	private static final Id wishRecordTypeId = Constant_AC.WISH_RT_ID;
	private static final Id diagnosisVerificationRT = Constant_AC.DIAGNOSIS_RT_ID;
	private static final Id wishAssistRecordTypeId = Constant_AC.WISH_ASSIST_RT_ID;

	/***************************************************************************************************************
This method is used to get the new case record values then it will added into the collections, then
It will call the corresponding methods in Case_OnAfterInsertTriggerHandlerHelper calss.
*****************************************************************************************************************/

	/**
	 * JIRA: WLP-286
	 * Author: Gustavo Mayer
	 * Update: Sub case conversion to the single Wish Case,
	 * no need to instantiate the unused attributes in the method below.
	 */
	public static void OnAfterInsert(List<Case> newCaseList) {
		List<Case> eligibilityReviewCaseList = new List<Case>();
//		Map<Id, Case> surveyEmailMap = new Map<Id, Case>();
//		Set<Id> impactparentIdSet = new Set<Id>();
		Set<Id> parentIdsSet = new Set<Id>();
//		Map<Id, Case> wishChapterIdsMap = new Map<Id, Case>();
//		Map<Id, Case> wishReceiptMap = new Map<Id, Case>();
//		Set<Id> wishGrantedSubCaseIdSet = new Set<Id>();
//		List<Case> wishGrantedSubCaseList = new List<Case>();
		Map<Id, Case> parentCaseIntakeOwnerMap = new Map<Id, Case>();
		Set<Id> chapterNames = new Set<Id>();
		Set<Id> wishFormCaseIdSet = new Set<Id>();
		List<Case> newCaseFileList = new List<Case>();
		List<Case> potentialRushList = new List<Case>();

		for (Case newWish : newCaseList) {
			if (newWish.RecordTypeId == diagnosisVerificationRT || newWish.RecordTypeId == wishRecordTypeId || newWish.RecordTypeId == wishAssistRecordTypeId) {
				if (newWish.RecordTypeId == diagnosisVerificationRT && newWish.Subject == 'Eligibility Review') {
					eligibilityReviewCaseList.add(newWish);
				}
				/**
				 * JIRA: WLP-286
				 * Author: Gustavo Mayer
				 * Update: Sub case conversion to the single Wish Case,
				 * no need to update as there is no longer the concept of parent case.
				 */
				// Below four lines are related to STT-11 for populating Survey email to parent case when Wish Impact sub case has value for Survey Email field.
//				if ((newWish.Survey_Email__c != null || newWish.Survey_Sent__c) && newWish.RecordTypeId == wishRecordTypeId) {
//					surveyEmailMap.put(newWish.Id, newWish);
//					impactparentIdSet.add(newWish.Id);
//				}
				/**
				 * WLP-704
				 * Commenting out this condition as there is it is duplicated.
				 */
//				if (newWish.RecordTypeId == wishRecordTypeId) {
//					wishFormCaseIdSet.add(newWish.Id);
//				}
				/**
				* JIRA: WLP-286
				* Author: Gustavo Mayer
				* Update: Sub case conversion to the single Wish Case.
				*/
//				if(newWish.RecordTypeId == wishDeterminationRecordTypeId)
//				{
//					if(newWish.isClosed != True && newWish.Status != 'Completed')
//					{
//						parentIdsSet.add(newWish.ParentId);
//						wishChapterIdsMap.put(newWish.Id, newWish);
//						wishType = constant.wishDeterminationRT;
//					}
//				}
//				else if(newWish.RecordTypeId == wishPlanningRecordTypeId) {
//					if(newWish.isClosed != True && newWish.Status != 'Completed')
//					{
//						wishTypeSet.add(newWish.Wish_Type__c);
//						wishPlaningAnticipationSubCaseMap.put(newWish.Id, newWish);
//						parentIdsSet.add(newWish.ParentId);
//						wishChapterIdsMap.put(newWish.Id, newWish);
//						wishType = constant.wishPlanningAnticipationRT;
//					}
//				}

				if (newWish.RecordTypeId == wishAssistRecordTypeId) {
					if (newWish.IsClosed != true && newWish.Status != 'Completed') {
						parentIdsSet.add(newWish.ParentId);
					}
				}
				/**
				* JIRA: WLP-286
				* Author: Gustavo Mayer
				* Update: Sub case conversion to the single Wish Case.
				* WishReceiptMap, wishGrantedSubCaseList and never used anywhere else.
				* WishChapterIdsMap creates team members for sub cases,
				* as there is no longer the concept of parent case this is not needed
				*/
//				else if(newWish.RecordTypeId == wishGrantRecordTypeId) {
//					if(newWish.Wish_Receipt_Items__c != Null && newWish.ParentId != Null){
//						wishReceiptMap.put(newWish.ParentId,newWish);
//					}
//
//					if(newWish.isClosed != True && newWish.Status != 'Completed')
//					{
//						parentIdsSet.add(newWish.ParentId);
//						wishChapterIdsMap.put(newWish.Id,newWish);
//						wishType = constant.wishGrantRT;
//						wishGrantedSubCaseList.add(newWish);
//						wishGrantedSubCaseIdSet.add(newWish.ParentId);
//					}
//				}
//				else if(newWish.RecordTypeId == wishEffectRecordTypeId) {
//					if(newWish.isClosed != True && newWish.Status != 'Completed')
//					{
//						parentIdsSet.add(newWish.ParentId);
//						wishChapterIdsMap.put(newWish.Id, newWish);
//						wishType = constant.wishGrantRT;
//					}
//				}
				/**
				* WLP-704
				* Fixing UpdateWishRecordIdentifier not being called.
				*/
				else if (newWish.RecordTypeId == wishRecordTypeId) {
					wishFormCaseIdSet.add(newWish.Id);
					if (newWish.IsClosed != true) {
						parentCaseIntakeOwnerMap.put(newWish.Id, newWish);
						parentIdsSet.add(newWish.Id);
						chapterNames.add(newWish.ChapterName__c);
					}
					//IME-107
					if (!newWish.Rush__c) {
						potentialRushList.add(newWish);
					}
				}
			}
			newCaseFileList.add(newWish);
		}
		if (parentIdsSet.size() > 0 && chapterNames.size() > 0) {
			Case_OnAfterInsertTriggerHandlerHelper.UpdateWishRecordIdentifier(parentIdsSet, chapterNames, wishRecordTypeId);
		}

		/**
		 * JIRA: WLP-286
		 * Author: Gustavo Mayer
		 * Update: Sub case conversion to the single Wish Case, no need to update
		 * as there is no longer the concept of parent case.
		 */
//		if (surveyEmailMap.size() > 0) {
//			Case_OnAfterInsertTriggerHandlerHelper.updateSurveyField(surveyEmailMap, impactparentIdSet);
//		}

		/**
		 * JIRA: WLP-286
		 * Author: Gustavo Mayer
		 * Update: Sub case conversion to the single Wish Case, no create team members for sub cases
		 * as there is no longer the concept of parent case.
		 */
//		if (wishChapterIdsMap.size() > 0 && parentIdsSet.size() > 0) {
//			Case_OnAfterInsertTriggerHandlerHelper.createActionTracks(wishChapterIdsMap, parentIdsSet);
//		}
		if (parentCaseIntakeOwnerMap.size() > 0) {
			Case_OnAfterInsertTriggerHandlerHelper.CaseTeamInTakeManager(parentCaseIntakeOwnerMap);
		}
		/*if(wishReceiptMap.size() > 0){
			Case_OnAfterInsertTriggerHandlerHelper.wishReciptValues(wishReceiptMap,parentCaseIntakeOwnerMap);
		}*/
		if (newCaseFileList.size() > 0)
			Case_OnAfterInsertTriggerHandlerHelper.createCaseFile(newCaseFileList);

		//IME-107
		if (potentialRushList.size() > 0) {
			//Case_OnAfterInsertTriggerHandlerHelper.createPotentialRushTask(potentialRushList);
		}
		if (wishFormCaseIdSet.size() > 0) {
			Case_OnAfterInsertTriggerHandlerHelper.wishFormChildRec(wishFormCaseIdSet);
			Case_OnAfterInsertTriggerHandlerHelper.reParentDvTask(wishFormCaseIdSet);
		}
	}
}