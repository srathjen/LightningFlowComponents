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

    /*
     * @description		OnAfterInsert trigger handler for the Case object
     *
     * @author 			MST Solutions
     * @createdDate		2016-05-26
     */
    public static void OnAfterInsert(List<Case> newCaseList) {
        List<Case> eligibilityReviewCaseList = new List<Case>();
        Set<Id> parentIdsSet = new Set<Id>();
        Map<Id, Case> parentCaseIntakeOwnerMap = new Map<Id, Case>();
        Set<Id> chapterNames = new Set<Id>();
        Set<Id> wishFormCaseIdSet = new Set<Id>();
        List<Case> newCaseFileList = new List<Case>();
        List<Case> potentialRushList = new List<Case>();

        for (Case newWish : newCaseList) {
            if (newWish.RecordTypeId == diagnosisVerificationRT || newWish.RecordTypeId == wishRecordTypeId || newWish.RecordTypeId == wishAssistRecordTypeId) {
                if (newWish.RecordTypeId == diagnosisVerificationRT && newWish.Subject == Constant_AC.CASE_SUBJECT_ELIGIBILITY_REVIEW) {
                    eligibilityReviewCaseList.add(newWish);
                }

                if (newWish.RecordTypeId == wishAssistRecordTypeId) {
                    if (newWish.IsClosed != true && newWish.Status != Constant_AC.CASE_STATUS_COMPLETED) {
                        parentIdsSet.add(newWish.ParentId);
                    }
                } else if (newWish.RecordTypeId == wishRecordTypeId) {
                    wishFormCaseIdSet.add(newWish.Id);
                    if (newWish.IsClosed != true) {
                        parentCaseIntakeOwnerMap.put(newWish.Id, newWish);
                        parentIdsSet.add(newWish.Id);
                        chapterNames.add(newWish.ChapterName__c);
                    }

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

        if (parentCaseIntakeOwnerMap.size() > 0) {
            Case_OnAfterInsertTriggerHandlerHelper.caseTeamInTakeManager(parentCaseIntakeOwnerMap);
        }

        if (newCaseFileList.size() > 0) {
            Case_OnAfterInsertTriggerHandlerHelper.createCaseFile(newCaseFileList);
        }

        if (wishFormCaseIdSet.size() > 0) {
            Case_OnAfterInsertTriggerHandlerHelper.wishFormChildRec(wishFormCaseIdSet);
            Case_OnAfterInsertTriggerHandlerHelper.reParentDvTask(wishFormCaseIdSet);
        }
    }
}