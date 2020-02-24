/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : VolunteerRole_OnAfterInsertHandler_AC is used to call the Helper class when the
              new volunteer Role record is created.
              
              Modification Log
              ------------------
              WVC-1889    Pavithra G 07/31/2018
              
*****************************************************************************************************/
public class VolunteerRole_OnAfterInsertHandler_AC {

	private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;
	private final static String VOLUNTEER_ROLE_STATUS_PENDING_TRAINING = 'Pending Training';

	public static void OnAfterInsert(List<Volunteer_Roles__c> newVolunteerRoleList) {
		Map<Id, List<Volunteer_Roles__c>> volunteerRoleStatusMap = new Map<Id, List<Volunteer_Roles__c>>();
		Set<Id> volunteerRoleIdsSet = new Set<Id>();
		Set<Id> volunteerIdsSet = new Set<Id>();
		Set<Id> volunteerWithNonActiveRole = new Set<Id>();
		Map<Id, Set<String>> volunteerWithActiveRoleByChapter = new Map<Id, Set<String>>();
		List<Volunteer_Roles__c> pendingTrainingExceptionList = new List<Volunteer_Roles__c>();
		for (Volunteer_Roles__c newVolRole : newVolunteerRoleList) {
			if (volunteerRoleStatusMap.containsKey(newVolRole.Volunteer_Name__c)) {
				volunteerRoleStatusMap.get(newVolRole.Volunteer_Name__c).add(newVolRole);
			} else {
				volunteerRoleStatusMap.put(newVolRole.Volunteer_Name__c, new List<Volunteer_Roles__c>{
						newVolRole
				});
			}
			if (newVolRole.Status__c == VOLUNTEER_ROLE_STATUS_PENDING_TRAINING) {
				volunteerRoleIdsSet.add(newVolRole.Id);
				volunteerIdsSet.add(newVolRole.Volunteer_Name__c);
				pendingTrainingExceptionList.add(newVolRole);
			} else if(newVolRole.Status__c != VOLUNTEER_ROLE_STATUS_ACTIVE){
				volunteerWithNonActiveRole.add(newVolRole.Volunteer_Name__c);
			} else if(newVolRole.Status__c == VOLUNTEER_ROLE_STATUS_ACTIVE){
				if(volunteerWithActiveRoleByChapter.containsKey(newVolRole.Volunteer_Name__c)){
					volunteerWithActiveRoleByChapter.get(newVolRole.Volunteer_Name__c).add(newVolRole.Chapter_Name__c);
				} else {
					Set<String> chapterNames = new Set<String>();
					chapterNames.add(newVolRole.Chapter_Name__c);
					volunteerWithActiveRoleByChapter.put(newVolRole.Volunteer_Name__c, chapterNames);
				}
			}
		}
		if (volunteerRoleStatusMap.size() > 0) {
			VolunteerRole_OnAfterInsertHelper_AC.updateVolunteerRoleStatus(volunteerRoleStatusMap, 'Insert', newVolunteerRoleList);
		}
		if (volunteerRoleIdsSet.size() > 0 && volunteerIdsSet.size() > 0) {
			VolunteerRole_OnAfterInsertHelper_AC.getVolunteerBasedOnVolunteerRoleStatus(volunteerRoleIdsSet, volunteerIdsSet, pendingTrainingExceptionList);
		}
		/**
		 * WLP-619
		 * Process Volunteers to try to Activate its Volunteer Role, User and Organization Affiliation
		 */
		if (!volunteerWithNonActiveRole.isEmpty()) {
			VolunteerJourneyService.processVolunteersChapterRequirements(volunteerWithNonActiveRole);
		}
		if (!volunteerWithActiveRoleByChapter.isEmpty()) {
			VolunteerJourneyService.processVolunteersRoleActiveBypass(volunteerWithActiveRoleByChapter);
		}
	}
}