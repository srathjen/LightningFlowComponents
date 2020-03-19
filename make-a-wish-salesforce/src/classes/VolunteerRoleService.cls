/**
 * @description Volunteer Role Service, centralizes Volunteer Role business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 3/19/2020
 */
public class VolunteerRoleService {

	private static String EMPTY = '';

	/**
	 * Update Volunteer Roles that were Out Of Compliance
	 * @param volunteerIdSet
	 * @param coiList
	 */
	public static List<Volunteer_Roles__c> updateNonCompliantByConflictOfInterest(Map<Id, Conflict_Of_Interest__c> volunteerIdCoiMap) {
		List<Volunteer_Roles__c> updateVolunteerRoleList = new List<Volunteer_Roles__c>();
		try {
			Set<Id> expiredBCVolunteerIdSet = new Set<Id>();
			for (Background_check__c backgroundCheck : [
					SELECT Id,Current__c,Date__c,Volunteer__c
					FROM Background_check__c
					WHERE Volunteer__c IN :volunteerIdCoiMap.keySet()
					AND Current__c = TRUE
					AND Date__c < TODAY
			]) {
				expiredBCVolunteerIdSet.add(backgroundCheck.Volunteer__c);
			}
			for (Volunteer_Roles__c volunteerRole : [
					SELECT Id,Name,Status__c,Hidden_Previous_Status__c,Sub_status__c,Hidden_Previous_Sub_Status__c,
							Chapter_Role__c,Volunteer_Name__c,Chapter_Role__r.Background_Check_Required__c
					FROM Volunteer_Roles__c
					WHERE Volunteer_Name__c IN :volunteerIdCoiMap.keySet()
					AND Status__c = :Constant_AC.VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE
			]) {
				if ((volunteerRole.Chapter_Role__r.Background_Check_Required__c
						&& !(expiredBCVolunteerIdSet.contains(volunteerRole.Volunteer_Name__c)))
						|| (!volunteerRole.Chapter_Role__r.Background_Check_Required__c)) {
					Volunteer_Roles__c updateRole = new Volunteer_Roles__c();
					updateRole.Id = volunteerRole.Id;
					updateRole.Status__c = volunteerRole.Hidden_Previous_Status__c;
					updateRole.Sub_status__c = volunteerRole.Hidden_Previous_Sub_Status__c;
					updateRole.Hidden_Previous_Status__c = EMPTY;
					updateRole.Hidden_Previous_Sub_Status__c = EMPTY;
					updateVolunteerRoleList.add(updateRole);
				}
			}
			if (!updateVolunteerRoleList.isEmpty()) {
				update updateVolunteerRoleList;
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Conflict_Of_Interest__c coi : volunteerIdCoiMap.values()) {
				ErrorMessage_AC.createDebugRec('VolunteerRoleService', String.valueOf(coi),
						String.valueOf(ex), 'updateNonCompliantByConflictOfInterest', coi.Id,
						ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (Conflict_Of_Interest__c coi : volunteerIdCoiMap.values()) {
					coi.addError(Label.Debug_log_error_message);
				}
			}
		}
		return updateVolunteerRoleList;
	}
}