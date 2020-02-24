/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/26/2016
Description : When a new case record is created from Manually or lead convertion then this calss has been called by
theCase_OnBeforeInsertTriggerHandler and we are updating the Dev staff Email Id in this class.
Modification Log: 
23/03/2018 - Sankar - WVC-1835
*******************************************************************************************************************/
public class Case_OnBeforeInsertTriggerHandler {

	/******************************************************************************************************************
	This method is called when ever a new case record is created then the value is assigned to the corresponding
	fields in case record.
	******************************************************************************************************************/
	public static void OnBeforeInsert(List<Case> beforeInsertCaseList) {
		Id wishRecordTypeId = Constant_AC.WISH_RT_ID;
		Set<Id> wishOwnerIdSet = new Set<Id>();
		Map<Id, User> wishOwnerMap = new Map<Id, User>();
		Map<Id, Case> caseMap = new Map<Id, Case>();
		Set<Id> chapterSet = new Set<Id>();

		for (Case newCase : beforeInsertCaseList) {
			if (Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null && newCase.RecordTypeId == wishRecordTypeId) {
				wishOwnerIdSet.add(newCase.OwnerId);
			}
			if (newCase.RecordTypeId == wishRecordTypeId && newCase.ParentId != null) {
				caseMap.put(newCase.Id, newCase);
			}
			if (newCase.RecordTypeId == wishRecordTypeId) {
				chapterSet.add(newCase.ChapterName__c);
			}
			if (!newCase.Rush__c && newCase.RecordTypeId == wishRecordTypeId) {
				newCase.Rush_Timeframe__c = null;
				newCase.Rush_Explanation__c = null;
			}
		}

		if (wishOwnerIdSet.size() > 0) {
			for (User wishOwner : [
					SELECT Id,ManagerId,Manager.Name,Manager.Email
					FROM User
					WHERE Id IN:wishOwnerIdSet
					AND ManagerId != NULL
					LIMIT 50000
			]) {
				wishOwnerMap.put(wishOwner.Id, wishOwner);
			}
		}

		for (Case newCase : beforeInsertCaseList) {
			if (wishOwnerMap.containsKey(newCase.OwnerId) && newCase.RecordTypeId == wishRecordTypeId) {
				if (wishOwnerMap.get(newCase.OwnerId).ManagerId != null) {
					newCase.Hidden_Wish_Owner_Manager__c = wishOwnerMap.get(newCase.OwnerId).Manager.Name;
					newCase.Hidden_Wish_Owner_Email__c = wishOwnerMap.get(newCase.OwnerId).Manager.Email;
				}
			}
		}
		/**
		 * JIRA: WLP-286
		 * Author: Gustavo Mayer
		 * Update: Method is called but does not do anything, is this an existing bug?
		 */
//		if (caseMap.size() > 0) {
//			Case_OnBeforeInsertTriggerHandlerHelper.updateCaseDevEmail(caseMap, wishRecordTypeId);
//		}
	}
}