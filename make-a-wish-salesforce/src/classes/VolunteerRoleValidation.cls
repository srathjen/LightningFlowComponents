/**
 * @description Volunteer Validation, centralizes validations of Volunteer Role.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 3/19/2020
 */
public class VolunteerRoleValidation {

	private final static String PROFILE_SYSTEM_ADMINISTRATOR = Constant_AC.PROFILE_SYSTEM_ADMINISTRATOR;
	private final static String ROLE_NATIONAL_STAFF = Constant_AC.ROLE_NATIONAL_STAFF;

	/**
	 * Validate if User / Profile has permission, add Permission Error message on record
	 * @param volunteerRoles
	 * @param chapterRoleMap
	 */
	public static void validatePermission(List<Volunteer_Roles__c> volunteerRoles,
			Map<String, String> chapterRoleMap) {
		User currUser = Utils.currentUser;
		for (Volunteer_Roles__c volRole : volunteerRoles) {
			if (chapterRoleMap.get(volRole.Chapter_Name__c) != currUser.UserRole.Name
					&& currUser.UserRole.Name != ROLE_NATIONAL_STAFF
					&& currUser.Profile.Name != PROFILE_SYSTEM_ADMINISTRATOR
					&& Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null) {
				volRole.addError(Label.Volunteer_Role_Error_Update);
			}
		}
	}
}