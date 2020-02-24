/**
* @description: Trigger handler Volunteer Role records before insert
* @author: Gustavo Mayer, Traction on Demand
* @createdDate: 29-10-2019
*/
public class VolunteerRole_OnBeforeInsertHandler_AC {

	private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;
	/**
	 * @description: Act on Volunteer Role records before the insert
	 * @param newVolunteerRoleList
	 */
	public static void OnBeforeInsert(List<Volunteer_Roles__c> newVolunteerRoleList) {
		for (Volunteer_Roles__c volRole : newVolunteerRoleList) {
			// Set Start Date on Volunteer Role if its Active
			if (volRole.Status__c == VOLUNTEER_ROLE_STATUS_ACTIVE
					&& volRole.Start_Date__c == null) {
				volRole.Start_Date__c = Date.today();
			}
		}
	}
}