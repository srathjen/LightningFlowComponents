/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : BackGroundCheck_OnAfterInsertHandler is used to call the Helper class when the
              new BackGroundCheck record is created.
              
              Modification Log
              ------------------
              WVC-1866    Pavithra G  05/08/2018
              
*****************************************************************************************************/
public class BackGroundCheck_OnAfterInsertHandler {

	public static void OnAfterInsert(List<Background_check__c> newBCList) {
		Set<Id> newRecordIds = new Set<Id>();
		Set<Id> volunteerIds = new Set<Id>();
		Set<Id> ownerIds = new Set<Id>();
		Map<String, List<Background_check__c>> bgcMap = new Map<String, List<Background_check__c>>();
		Map<Id, Background_check__c> expirationDateMap = new Map<Id, Background_check__c>();
		for (Background_check__c currRec : newBCList) {
			ownerIds.add(currRec.OwnerId);
		}
		Map<Id, String> userRoleMap = UserRoleUtility.getUserRole(ownerIds);
		//  Map<String,List<Background_check__c>> bgcMap = new Map<String,List<Background_check__c>>();
		for (Background_check__c bgc : newBCList) {
			if (Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null) {
				if (bgc.Current__c == true) {
					newRecordIds.add(bgc.Id);
					volunteerIds.add(bgc.Volunteer__c);
				}
				if (bgc.Account_Name__c != null && userRoleMap.get(bgc.OwnerId) == 'National Staff') {
					if (bgcMap.containsKey(bgc.Account_Name__c)) {
						bgcMap.get(bgc.Account_Name__c).add(bgc);
					} else {
						bgcMap.put(bgc.Account_Name__c, new List<Background_check__c>{
								bgc
						});
					}
				}
				if (bgc.Date__c != null && bgc.Current__c == true) {
					expirationDateMap.put(bgc.Id, bgc);
				}
			}
		}
		if (newRecordIds.size() > 0 && volunteerIds.size() > 0) {
			BackGroundCheck_OnAfterInsertHelper.DeactivateExistingRecords(newRecordIds, volunteerIds, newBCList);
		}
		if (bgcMap.size() > 0) {
			ChapterStaffRecordSharing_AC.BGCRecordSharing(bgcMap);
		}
		if (expirationDateMap.size() > 0) {
			BackGroundCheck_OnAfterInsertHelper.UpdateVolunteerExpirationDate(expirationDateMap);
		}
		/**
		* WLP-619
		* Process Volunteers to try to Activate its Volunteer Role, User and Organization Affiliation
		*/
		if (!volunteerIds.isEmpty()) {
			VolunteerJourneyService.processVolunteersChapterRequirements(volunteerIds);
		}
	}
}