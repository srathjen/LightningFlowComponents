/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : BackGroundCheck_OnBeforeUpdateHandler is used to call the Helper class when the
              new BackGroundCheck record is created.
              
              Modification Log
              ------------------
              WVC-1866    Pavithra G  05/08/2018
              
*****************************************************************************************************/
public class BackGroundCheck_OnAfterUpdateHandler {

	private final static String BACKGROUND_CHECK_STATUS_APPROVED = 'Approved';
	private final static String BACKGROUND_CHECK_STATUS_APPROVED_WITH_CONDITIONS = 'Approved w/ Conditions';
	private final static String BACKGROUND_CHECK_STATUS_REJECTED = 'Rejected';

	public static void OnAfterUpdate(List<Background_check__c> newBCList, Map<Id, Background_check__c> oldBCMap) {
		Set<Id> rejectedIds = new Set<Id>();
//		Set<Id> approvedVolunteerIds = new Set<Id>();
		Map<Id, Background_check__c> expirationDateMap = new Map<Id, Background_check__c>();
		Set<Id> newRecordIds = new Set<Id>();
		Set<Id> volunteerIds = new Set<Id>();
//		Set<Id> ownerIds = new Set<Id>();
		Set<Id> volunteerContactIdSet = new Set<Id>();
		Set<Id> backgroundRejectedSet = new Set<Id>();
//		Map<String, List<Background_check__c>> bgcMap = new Map<String, List<Background_check__c>>();
		Set<String> chapterNamesSet = new Set<String>();
		Map<Id, String> chapterNameMap = new Map<Id, String>();
		Map<String, String> chapterRoleMap = new Map<String, String>();
		List<Background_check__c> reviewTaskBCList = new List<Background_check__c>();
		Set<Id> volunteerIdsBgcApprovedCurrent = new Set<Id>();
		List<User> currUser = [
				SELECT Id,UserRole.Name,Profile.Name,Profile.Id
				FROM User
				WHERE Id = :UserInfo.getUserId()
				LIMIT 1
		];
		for (Background_check__c bgc : newBCList) {
//			if ((bgc.Status__c == 'Approved'
//					|| bgc.Status__c == 'Approved w/ Conditions')
//					&& bgc.Status__c != null
//					&& oldBCMap.get(bgc.Id).Status__c != bgc.Status__c
//					&& bgc.Current__c == true) {
//				approvedVolunteerIds.add(bgc.Volunteer__c);
//			}
			if (bgc.Status__c != null
					&& BACKGROUND_CHECK_STATUS_REJECTED.equals(bgc.Status__c)
					&& !BACKGROUND_CHECK_STATUS_REJECTED.equals(oldBCMap.get(bgc.Id).Status__c)) {
				rejectedIds.add(bgc.Volunteer__c);
			}
			if (bgc.Date__c != null
					&& oldBCMap.get(bgc.Id).Date__c <> bgc.Date__c
					&& bgc.Current__c == true) {
				expirationDateMap.put(bgc.Volunteer__c, bgc);
			}
			if (bgc.Current__c == true
					&& oldBCMap.get(bgc.Id).Current__c == false) {
				newRecordIds.add(bgc.Id);
				volunteerIds.add(bgc.Volunteer__c);
			}
			if (bgc.HiddenBackgroundExpire__c == true
					&& oldBCMap.get(bgc.Id).HiddenBackgroundExpire__c == false) {
				volunteerContactIdSet.add(bgc.Volunteer__c);
			}
			if (bgc.Hidden_Background_Rejected__c == true
					&& oldBCMap.get(bgc.Id).Hidden_Background_Rejected__c == false) {
				backgroundRejectedSet.add(bgc.Volunteer__c);
			}
			// if(dbBackgroundCheckRec.ownerId != Trigger.oldMap.get(dbBackgroundCheckRec.id).ownerId)
			//  ownerIds.add(dbBackgroundCheckRec.ownerId);
			if (bgc.Account_Name__c != null && currUser[0].UserRole.Name != 'National Staff' &&
					currUser[0].Profile.Name != 'System Administrator' && currUser[0].Profile.Name != 'Integration' &&
					currUser[0].Profile.Id != Label.Active_Volunteer_Profile &&
					currUser[0].Profile.Id != Label.Prospective_Volunteer_Profile) {
				chapterNamesSet.add(bgc.Account_Name__c);
				chapterNameMap.put(bgc.Id, bgc.Account_Name__c);
			}
			/**************** WVC-493 ****************/
			if (bgc.Status__c == 'Received from First Advantage'
					&& bgc.Status__c != oldBCMap.get(bgc.Id).Status__c) {
				reviewTaskBCList.add(bgc);
			}
			/************* End WVC-493 ****************/
			if ((BACKGROUND_CHECK_STATUS_APPROVED.equals(bgc.Status__c)
					|| BACKGROUND_CHECK_STATUS_APPROVED_WITH_CONDITIONS.equals(bgc.Status__c))
					&& oldBCMap.get(bgc.Id).Status__c != bgc.Status__c
					&& bgc.Current__c == true
					&& oldBCMap.get(bgc.Id).Current__c != bgc.Current__c) {
				volunteerIdsBgcApprovedCurrent.add(bgc.Volunteer__c);
			}
		}
		if (chapterNamesSet.size() > 0) {
			chapterRoleMap = ChapterStaffRecordSharing_AC.FindChapterRole(chapterNamesSet);

			for (Background_check__c currRec : newBCList) {
				if ((chapterRoleMap.get(chapterNameMap.get(currRec.Id)) != currUser[0].UserRole.Name
						|| currRec.Account_Name__c != oldBCMap.get(currRec.Id).Account_Name__c)
						&& !Test.isRunningTest()) {
					currRec.addError('Insufficient previlege to update this record. Please contact system administrator.');
				}
			}
		}
		/*   Map<id, String> userRoleMap = UserRoleUtility.getUserRole(ownerIds);
		for(Background_check__c currRec : Trigger.new)
		{
		if(currRec.Account_Name__c != Null && userRoleMap.get(currRec.OwnerId) == 'National Staff'
		&& currRec.OwnerId != Trigger.oldMap.get(currRec.id).ownerId)
		{
		if(bgcMap.containsKey(currRec.Account_Name__c))
		{
		bgcMap.get(currRec.Account_Name__c).add(currRec);
		}
		else
		bgcMap.put(currRec.Account_Name__c,new List<Background_check__c>{currRec});
		}
		}*/

		/* if(volunteerIds.size() > 0)
		{
		BackGroundCheckTriggerHandler.UpdateHiddenEmailField(volunteerIds,Trigger.new);
		}*/
		if (newRecordIds.size() > 0 && volunteerIds.size() > 0) {
			BackGroundCheck_OnAfterInsertHelper.DeactivateExistingRecords(newRecordIds, volunteerIds, newBCList);
		}
		if (rejectedIds.size() > 0) {
			BackGroundCheck_OnAfterUpdateHelper.UpdateAffiliationStatusToDeclined(rejectedIds, newBCList);
		}
		if (volunteerIdsBgcApprovedCurrent.size() > 0) {
			BackGroundCheck_OnAfterUpdateHelper.UpdateAffiliationStatusToPending(volunteerIdsBgcApprovedCurrent, newBCList);
			BackGroundCheck_OnAfterUpdateHelper.updateVolunteerHiddenVolOTStatus(volunteerIdsBgcApprovedCurrent, newBCList);
		}
		if (expirationDateMap.size() > 0) {
			BackGroundCheck_OnAfterInsertHelper.UpdateVolunteerExpirationDate(expirationDateMap);
		}
		if (volunteerContactIdSet.size() > 0) {
			BackGroundCheck_OnAfterUpdateHelper.UpdateVOppAndVRoleStatus(volunteerContactIdSet, 'backgroundcheck', newBCList);
		}
		if (backgroundRejectedSet.size() > 0) {
			BackGroundCheck_OnAfterUpdateHelper.UpdateVOppAndVRoleStatus(backgroundRejectedSet, 'backgroundcheck', newBCList);
		}
		if (reviewTaskBCList.size() > 0) {
			BackGroundCheck_OnAfterUpdateHelper.createReviewBCTask(reviewTaskBCList);
		}
		/**
		* WLP-619
		* Process Volunteers to try to Activate its Volunteer Role, User and Organization Affiliation
		*/
		if (!volunteerIdsBgcApprovedCurrent.isEmpty()) {
			VolunteerJourneyService.processVolunteersChapterRequirements(volunteerIdsBgcApprovedCurrent);
		}
	}
}