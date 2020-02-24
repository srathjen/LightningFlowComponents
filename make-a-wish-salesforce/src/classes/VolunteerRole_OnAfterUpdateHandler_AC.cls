/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : VolunteerRole_OnAfterUpdateHandler_AC is used to call the Helper class when the
new volunteer Role record is updated.

Modification Log
------------------
WVC-1889    Pavithra G 07/31/2018
WVC-2199    Pavithra G 8/08/2018 
*****************************************************************************************************/
/**
 * JIRA: WLP-422
 * Author: Gustavo Mayer
 * Update: Changing the Volunteer_Roles status from 'Trained' to 'Active'
 */
public class VolunteerRole_OnAfterUpdateHandler_AC {

	private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;

	public static void OnAfterUpdate(List<Volunteer_Roles__c> newVolunteerRoleList, Map<Id, Volunteer_Roles__c> oldVolunteerRoleMap) {
		Map<Id, List<Volunteer_Roles__c>> volunteerRoleMap = new Map<Id, List<Volunteer_Roles__c>>();
		Map<Id, List<Volunteer_Roles__c>> volunteerRoleStatusMap = new Map<Id, List<Volunteer_Roles__c>>();
		Set<Id> volunteerRoleIdsSet = new Set<Id>();
		Set<Id> volunteerIdsSet = new Set<Id>();
		Map<Id, Set<String>> volunteerWithActiveRoleByChapter = new Map<Id, Set<String>>();
		for (Volunteer_Roles__c newVolRole : newVolunteerRoleList) {
			if (newVolRole.Status__c != oldVolunteerRoleMap.get(newVolRole.id).Status__c
					&& (newVolRole.Status__c == 'Out of Compliance'
					|| newVolRole.Status__c == VOLUNTEER_ROLE_STATUS_ACTIVE
					|| (newVolRole.Status__c == 'Former')
					|| (newVolRole.Status__c == 'Former')
					|| newVolRole.Status__c == 'Not Approved'
					|| newVolRole.Status__c == 'Pending')) {
				if (volunteerRoleMap.containsKey(newVolRole.Volunteer_Name__c)) {
					volunteerRoleMap.get(newVolRole.Volunteer_Name__c).add(newVolRole);
				} else {
					volunteerRoleMap.put(newVolRole.Volunteer_Name__c, new list<Volunteer_Roles__c>{
							newVolRole
					});
				}
			}
			/***********WVC - 2199 change status value former - chapter & former - volunteer to status is former and sun status is chapter and volunteer ****/
			if (((newVolRole.Status__c == 'Former') || (newVolRole.Status__c == 'Former')
					|| newVolRole.Status__c == 'Not Approved'
					|| newVolRole.Status__c == 'Out of Compliance'
					|| newVolRole.Status__c == VOLUNTEER_ROLE_STATUS_ACTIVE
					|| newVolRole.Status__c == 'Pending')
					&& (newVolRole.Status__c != oldVolunteerRoleMap.get(newVolRole.id).Status__c)) {
				if (volunteerRoleStatusMap.containsKey(newVolRole.Volunteer_Name__c)) {
					volunteerRoleStatusMap.get(newVolRole.Volunteer_Name__c).add(newVolRole);
				} else {
					volunteerRoleStatusMap.put(newVolRole.Volunteer_Name__c, new list<Volunteer_Roles__c>{
							newVolRole
					});
				}
			}
			if (newVolRole.Status__c != oldVolunteerRoleMap.get(newVolRole.id).Status__c) {
				volunteerRoleIdsSet.add(newVolRole.id);
				volunteerIdsSet.add(newVolRole.Volunteer_Name__c);
			}
			if (newVolRole.Status__c == VOLUNTEER_ROLE_STATUS_ACTIVE) {
				if (volunteerWithActiveRoleByChapter.containsKey(newVolRole.Volunteer_Name__c)) {
					volunteerWithActiveRoleByChapter.get(newVolRole.Volunteer_Name__c).add(newVolRole.Chapter_Name__c);
				} else {
					Set<String> chapterNames = new Set<String>();
					chapterNames.add(newVolRole.Chapter_Name__c);
					volunteerWithActiveRoleByChapter.put(newVolRole.Volunteer_Name__c, chapterNames);
				}
			}
		}
		if (volunteerRoleMap.size() > 0) {
			VolunteerRole_OnAfterUpdateHelper_AC.updateVolunteerOpportunity(volunteerRoleMap, newVolunteerRoleList);
		}
		if (volunteerRoleStatusMap.size() > 0) {
			VolunteerRole_OnAfterInsertHelper_AC.updateVolunteerRoleStatus(volunteerRoleStatusMap, 'Update', newVolunteerRoleList);
		}
		if (volunteerRoleIdsSet.size() > 0 && volunteerIdsSet.size() > 0) {
			VolunteerRole_OnAfterInsertHelper_AC.getVolunteerBasedOnVolunteerRoleStatus(volunteerRoleIdsSet, volunteerIdsSet, newVolunteerRoleList);
		}
		/**
		 * WLP-619
		 * Process Volunteers to try to Activate its Volunteer Role, User and Organization Affiliation
		 */
		if (!volunteerWithActiveRoleByChapter.isEmpty()) {
			VolunteerJourneyService.processVolunteersRoleActiveBypass(volunteerWithActiveRoleByChapter);
		}
	}
}