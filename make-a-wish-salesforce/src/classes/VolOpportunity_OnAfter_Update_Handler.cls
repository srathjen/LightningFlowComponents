/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/27/2016
Description : When a new volunteer Opportunity record get update then it will call the VolOpportunity_OnAfter_Update_Helper class based 
on the collection size() > 0.
Modification Log: 
04/17/2018 - Kanagaraj - WVC-1885
*******************************************************************************************************************/
public class VolOpportunity_OnAfter_Update_Handler {

	// This method is used to call the corresponding methods based on the condition that current record met.
	public static void onAfterUpdate(Map<Id, Volunteer_Opportunity__c> newMap, Map<Id, Volunteer_Opportunity__c> oldMap) {
		List<Volunteer_Opportunity__c> volunteerOpportunityList = new List<Volunteer_Opportunity__c>();
		Set<Id> chapterIdsSet = new Set<Id>();
		Set<Id> volunteerIdsSet = new Set<Id>();
		List<Volunteer_Opportunity__c> recordsForApprovalProcess = new List<Volunteer_Opportunity__c>();
		List<Volunteer_Opportunity__c> recordsForCreatingCaseTeams = new List<Volunteer_Opportunity__c>();
		Map<Id, Volunteer_Opportunity__c> volunteerforApexSharing = new Map<Id, Volunteer_Opportunity__c>();
		Map<String, Set<String>> volunteerCaseMap = new Map<String, Set<String>>();
		Map<String, List<Volunteer_Opportunity__c >> volunteerOppMap = new Map<String, List<Volunteer_Opportunity__c>>();
		List<Volunteer_Opportunity__c> nonWishListtoupdatecount = new List<Volunteer_Opportunity__c>();
		Set<Id> updateUserSet = new Set<Id>();
		Set<Id> volconId = new Set<Id>();
		List<Volunteer_Opportunity__c> volOpportunitySharingList = new List<Volunteer_Opportunity__c>();
		Set<Id> caseIdSet = new Set<Id>();
		Set<Id> voluOppIdSet = new Set<Id>();
		Boolean isdelete;
		Set<Id> volunteerOppIdSet = new Set<Id>();
		Set<Id> recallApprovalIdSet = new Set<Id>();
		Set<Id> volunteerOppName = new Set<Id>();
		Map<Id, Id> wishVolunteerIdMap = new Map<Id, Id>();
		List<Volunteer_Opportunity__c> approvedVolunteerExceptionList = new List<Volunteer_Opportunity__c>();
		Map<Id, Volunteer_Opportunity__c> volOpportunityMap = new Map<Id, Volunteer_Opportunity__c>();
		Map<Id, String> volunteerRoleNameMap = new Map<Id, String>();
		Set<Id> inactiveWishIdSet = new Set<Id>();
		List<Volunteer_Opportunity__c> volunteerOppExepList = new List<Volunteer_Opportunity__c>();
		for (Volunteer_Opportunity__c currRec : newMap.values()) {

			if (currRec.Status__c != oldMap.get(currRec.Id).Status__c
					&& oldMap.get(currRec.Id).Status__c == 'Pending'
					&& (currRec.Status__c == 'Inactive'
					|| currRec.Status__c == 'Out of Compliance')) {
				recallApprovalIdSet.add(currRec.Id);
			}

			if (currRec.Status__c != 'Approved' && (currRec.Volunteer_Name__c != null && oldMap.get(currRec.Id).Volunteer_Name__c == null)
					&& (currRec.Wish__c != null && currRec.Reason_Inactive__c == null)) {
				recordsForApprovalProcess.add(currRec);
				chapterIdsSet.add(currRec.Chapter_Name__c);
			}

			if ((currRec.Status__c == 'Approved' && currRec.Volunteer_Name__c != null
					&& oldMap.get(currRec.Id).Reason_Inactive__c == null
					&& currRec.Reason_Inactive__c != null) ||
					(currRec.Reason_Inactive__c == 'Not Approved'
							&& currRec.Reason_Inactive__c != oldMap.get(currRec.Id).Reason_Inactive__c)
					|| (currRec.Inactive__c == true && currRec.Inactive__c != oldMap.get(currRec.Id).Inactive__c)) {
				if (RecursiveTriggerHandler.isFirstTime == true || Test.isRunningTest()) {
					volunteerOpportunityList.add(currRec);
					volunteerOppIdSet.add(currRec.Id);
				}
			} else if (currRec.Status__c != 'Approved' && (currRec.Volunteer_Name__c != null && oldMap.get(currRec.Id).Volunteer_Name__c == null) && (currRec.Wish__c == null) && (currRec.Non_Wish_Event__c != null && currRec.Reason_Inactive__c == null)) {
				recordsForApprovalProcess.add(currRec);
				chapterIdsSet.add(currRec.Chapter_Name__c);
			}
			if ((currRec.Status__c == 'Approved' && oldMap.get(currRec.Id).Status__c == 'Pending')
					&& currRec.Volunteer_Name__c != null && (currRec.Wish__c != null || currRec.Non_Wish_Event__c != null)
					&& currRec.Reason_Inactive__c == null) {
				volOpportunitySharingList.add(currRec);
				if (currRec.Wish__c != null) {
					recordsForCreatingCaseTeams.add(currRec);
				}
			}
			if ((currRec.Volunteer_Name__c != null) && (currRec.Wish__c != null)) {
				volunteerforApexSharing.put(currRec.Id, currRec);
				if (volunteerCaseMap.containsKey(currRec.Volunteer_Name__c)) {
					volunteerCaseMap.get(currRec.Wish__c).add(currRec.Volunteer_Name__c);
				} else {
					volunteerCaseMap.put(currRec.Wish__c, new Set<String>{
							currRec.Volunteer_Name__c
					});
				}
			}
			if (currRec.Volunteer_Name__c != null && currRec.Non_Wish_Event__c != null && currRec.Status__c != 'Approved' && currRec.Status__c == 'Pending' && currRec.Reason_Inactive__c == null) {
				if (RecursiveTriggerHandler.isFirstTime == true) {
					nonWishListtoupdatecount.add(currRec);
					voluOppIdSet.add(currRec.Id);
					isdelete = false;
				}
			}
			/****** WVC-2206 ******/
			if (currRec.Status__c == 'Out of Compliance' && oldMap.get(currRec.Id).Status__c == 'Approved'
					&& currRec.Volunteer_Name__c != null && currRec.Wish__c != null) {
				inactiveWishIdSet.add(currRec.Wish__c);
				volOpportunityMap.put(currRec.Volunteer_Name__c, currRec);
				volunteerRoleNameMap.put(currRec.Volunteer_Name__c, currRec.Role__c);

			}
			if (currRec.Volunteer_Name__c == null && oldMap.get(currRec.Id).Volunteer_Name__c != null) {
				updateUserSet.add(currRec.Id);
				volconId.add(oldMap.get(currRec.Id).Volunteer_Name__c);
			}
			if ((currRec.Volunteer_Name__c != null && currRec.Non_Wish_Event__c != null && currRec.Status__c == 'Approved' && currRec.Reason_Inactive__c != null) || (currRec.Volunteer_Name__c != null && currRec.Non_Wish_Event__c != null && currRec.Status__c != 'Approved' && currRec.Reason_Inactive__c != null)) {
				if (RecursiveTriggerHandler.isFirstTime == true) {
					nonWishListtoupdatecount.add(currRec);
					voluOppIdSet.add(currRec.Id);
					isdelete = false;
				}
			}
			if (currRec.Volunteer_Name__c != null && currRec.Wish__c != null && currRec.Status__c == 'Approved' && oldMap.get(currRec.Id).Status__c != 'Approved') {
				volunteerIdsSet.add(currRec.Volunteer_Name__c);
			}

			if (currRec.Volunteer_Name__c != null && currRec.Wish__c != null && currRec.Status__c == 'Approved' && oldMap.get(currRec.Id).Status__c != 'Pending' && oldMap.get(currRec.Id).Status__c != currRec.Status__c) {
				// volunteerIdsSet.add(currRec.Volunteer_Name__c);
				wishVolunteerIdMap.put(currRec.Wish__c, currRec.Volunteer_Name__c);
				approvedVolunteerExceptionList.add(currRec);
			}
			/******** WVC-2052 *********/
			/*  If(((currRec.Volunteer_Name__c != null && currRec.Wish__c != null && currRec.Status__c != oldMap.get(CurrRec.Id).Status__c && (currRec.Status__c == 'Approved' || currRec.Status__c == 'Pending'  || (currRec.Status__c == 'Inactive' && currRec.Reason_Inactive__c == 'Not Approved' && currRec.Inactive__c == True && oldMap.get(currRec.Id).Reason_Inactive__c != currRec.Reason_Inactive__c))) || (currRec.Volunteer_Name__c == null && currRec.Wish__c != null && oldMap.get(currRec.Id).Volunteer_Name__c != null)) &&
			   (currRec.Role__c == 'Wish Granter' || currRec.Role__c == 'Wish Granter Mentor')){
				 wishIdSet.add(currRec.Wish__c);
				 volunteerOpportunityMap.put(currRec.Id,currRec);
			  }*/
			//Related to STT-62
			/*if(currRec.Volunteer_Name__c != null && currRec.Wish__c != null && currRec.inActive__c == TRUE && Trigger.oldMap.get(currRec.Id).inActive__c == FALSE){
				caseIdSet.add(currRec.Wish__c);
				voluOppIdSet.add(currRec.Volunteer_Name__c );
			}*/
			if (currRec.Volunteer_Name__c != null
					&& currRec.Wish__c != null
					&& (currRec.Status__c == 'Approved'
					|| currRec.Status__c != 'Approved')
					&& currRec.Reason_Inactive__c != null
					&& currRec.Inactive__c == true) {
				volunteerOppExepList.add(currRec);
				caseIdSet.add(currRec.Wish__c);
				voluOppIdSet.add(currRec.Volunteer_Name__c);
			}

			if (currRec.Status__c == 'Approved' && oldMap.get(currRec.Id).Status__c != 'Approved') {
				volunteerOppName.add(currRec.Volunteer_Name__c);
			}
		}

		for (Volunteer_Opportunity__c currRec : [
				SELECT Id, OwnerId, Owner.UserRoleId, Owner.UserRole.Name, Chapter_Name__c,
						Chapter_Name__r.Name
				FROM Volunteer_Opportunity__c
				WHERE Id IN :Trigger.newMap.keySet()
		]) {

			if (currRec.OwnerId != oldMap.get(currRec.Id).OwnerId && currRec.Chapter_Name__c != null && currRec.Owner.UserRole.Name == 'National Staff') {
				if (volunteerOppMap.containsKey(currRec.Chapter_Name__r.Name)) {
					volunteerOppMap.get(currRec.Chapter_Name__r.Name).add(currRec);
				} else {
					volunteerOppMap.put(currRec.Chapter_Name__r.Name, new List<Volunteer_Opportunity__c>{
							currRec
					});
				}
			}
		}

		if (recallApprovalIdSet.size() > 0) {
			Case_OnAfterUpdateTriggerHandlerHelper.recallVolOppApproval(recallApprovalIdSet);
		}
		if (caseIdSet.size() > 0 && voluOppIdSet.size() > 0) {
			if (RecursiveTriggerHandler.isFirstTime == true) {
				VolOpportunity_OnAfter_Update_Helper.updateCase(caseIdSet, voluOppIdSet, volunteerOppExepList);
			}
		}
		if (volunteerOpportunityList.size() > 0) {
			VolOpportunity_OnAfter_Update_Helper.CreateNewVolunteerOpportunity(volunteerOpportunityList, volunteerOppIdSet);
		}

		if (volunteerIdsSet.size() > 0) {
			VolOpportunity_OnAfter_Update_Helper.ActiveWishCount(volunteerIdsSet);
		}
		if (updateUserSet.size() > 0) {
			VolOpportunity_OnAfter_Update_Helper.updateUserRoleId(updateUserSet, volconId);
		}

		//Used to create approval process for volunteer opportunity record
		if (recordsForApprovalProcess.size() > 0 && chapterIdsSet.size() > 0) {
			VolOpportunity_OnAfter_Update_Helper.submitforApprovalProcess(recordsForApprovalProcess, chapterIdsSet);
		}
		//Adding to volunteer to case team member once it is approved
		if (recordsForCreatingCaseTeams.size() > 0) {
			VolOpportunity_OnAfter_Update_Helper.createCaseTeamMembers(recordsForCreatingCaseTeams);
		}
		if (nonWishListtoupdatecount.size() > 0) {
			VolOpportunity_OnAfter_Update_Helper.updateVolunteerRegisterdCount(nonWishListtoupdatecount, voluOppIdSet, isdelete);
		}
		if (volOpportunitySharingList.size() > 0) {
			VolOpportunity_OnAfter_Update_Helper.sharevolunteerOpportunityRecord(volOpportunitySharingList);
		}
		if (volunteerOppName.size() > 0) {
			VolOpportunity_OnAfter_Insert_Helper.Updatecontacts(volunteerOppName);
		}
		if (volunteerOppMap.size() > 0) {
			ChapterStaffRecordSharing_AC.volunteerOpportunitySharing(volunteerOppMap);
		}
		/* If(volunteerOpportunityMap.size() > 0){
			 VolOpportunity_OnAfter_Update_Helper.updateWishVolunteerWaiting(volunteerOpportunityMap,wishIdSet);
		 }*/
		if (wishVolunteerIdMap.size() > 0) {
			//VolOpportunity_OnAfter_Update_Helper.updateCaseTeamMemberRole(wishVolunteerIdMap,approvedVolunteerExceptionList);
			VolOpportunity_OnAfter_Update_Helper.createCaseTeamMembers(approvedVolunteerExceptionList);
		}
		if (volOpportunityMap.size() > 0) {
			// VolOpportunity_OnAfter_Update_Helper.updateInactiveCaseTeamMember(volunteerRoleNameMap,volOpportunityMap,inactiveWishIdSet);
		}
	}
}