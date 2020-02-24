/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : VolunteerRole_OnBeforeInsertHandler_AC is used to call the Helper class when the
              new volunteer Role record is created.
              
              Modification Log
              ------------------
              WVC-1889    Pavithra G 07/31/2018
              
*****************************************************************************************************/
/**
 * JIRA: WLP-422
 * Author: Gustavo Mayer
 * Update: Changing the Volunteer_Roles status from 'Trained' to 'Active'
 */
public class VolunteerRole_OnBeforeUpdateHandler_AC {

	private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;
	private final static String VOLUNTEER_ROLE_STATUS_NOT_APPROVED = 'Not Approved';
	private final static String VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE = 'Out of Compliance';

	public static void OnBeforeUpdate(List<Volunteer_Roles__c> newVolunteerRoleList, Map<Id, Volunteer_Roles__c> oldVolunteerRoleMap) {
		Set<String> chapterNamesSet = new Set<String>();
		for (Volunteer_Roles__c volRole : newVolunteerRoleList) {
			chapterNamesSet.add(volRole.Chapter_Name__c);
			if (volRole.Sub_status__c != null
					&& (volRole.Status__c == VOLUNTEER_ROLE_STATUS_ACTIVE
					|| volRole.Status__c == VOLUNTEER_ROLE_STATUS_NOT_APPROVED
					|| volRole.Status__c == VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE)) {
				volRole.Sub_status__c = '';
			}
			/**
			 * WLP-620
			 * Set Start Date when Volunteer Role is set to Active
			 */
			if (volRole.Status__c == VOLUNTEER_ROLE_STATUS_ACTIVE
					&& volRole.Start_Date__c == null) {
				volRole.Start_Date__c = Date.today();
			}
		}
		Map<String, String> chapterRoleMap = new Map<String, String>();
		if (chapterNamesSet.size() > 0) {
			chapterRoleMap = ChapterStaffRecordSharing_AC.FindChapterRole(chapterNamesSet);
		}
		List<User> currUser = [
				SELECT Id, UserRole.Name, Profile.Name
				FROM User
				WHERE Id = :UserInfo.getUserId()
				LIMIT 1
		];
		for (Volunteer_Roles__c volRole : newVolunteerRoleList) {
			if (chapterRoleMap.get(volRole.Chapter_Name__c) != currUser[0].UserRole.Name
					&& currUser[0].UserRole.Name != 'National Staff'
					&& currUser[0].Profile.Name != 'System Administrator'
					&& Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null) {
				volRole.addError(Label.Volunteer_Role_Error_Update);
			}
		}
	}
}