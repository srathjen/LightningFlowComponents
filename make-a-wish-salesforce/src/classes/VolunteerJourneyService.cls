/**
 * @description
 * The purpose of this class is to centralize the change of Status to
 * the Volunteers Role, User and Affiliation when either:
 *
 * A) A change occurs on the
 * Volunteers Role, Conflict of Interest, Background Check and verify if the
 * Volunteer has met all of the requirements to become Active
 *
 * B) Volunteer Role was manually set to Active
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 10/21/2019
 
 * Revision Log: 
     1. 02/06/2020 - SIW-488 - C Smith - Removed "With Sharing" from class definition to allow Volunteer Profiles to update based on a change a user made.
 
 */
public /*SIW-488 with sharing */ class VolunteerJourneyService {

	private final static String BACKGROUND_CHECK_STATUS_APPROVED = 'Approved';
	private final static String BACKGROUND_CHECK_STATUS_APPROVED_WITH_CONDITIONS = 'Approved w/ Conditions';
	private static final String VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED = 'Completed';
	private static final String VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_NOT_APPROVED = 'Not Approved';
	private static final String VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_FOLLOW_UP_REQUESTED = 'Follow-up Requested';
	private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;
	private final static String ORG_AFFILIATION_STATUS_STATUS_ACTIVE = 'Active';
	private final static String USER_PROFILE_ACTIVE_VOLUNTEER_PROFILE = Label.Active_Volunteer_Profile;
	private final static String CHAPTER_ROLE_ALL_ROLES = 'All Roles';
	private final static Id CONTACT_BOARD_MEMBER_RECORD_TYPE_ID = Constant_AC.BOARD_MEMBER_RT_ID;
	private final static Id CONTACT_VOLUNTEER_RECORD_TYPE_ID = Constant_AC.VOLUNTEER_RT_ID;

	/**
	 * Process Volunteers when a change occurs on Volunteer's Role, COI,
	 * Background Check and Volunteer Orientation and Training,
	 * in order to change the Status of the Volunteers Role to Active
	 * @param volunteerContactIds
	 */
	public static Map<Id, Boolean> processVolunteersChapterRequirements(Set<Id> volunteerContactIds) {
		Map<Id, Boolean> activeVolunteersMap = new Map<Id, Boolean>();
		if (volunteerContactIds.isEmpty()) {
			return activeVolunteersMap;
		}
		/**
		 * Find the chapter names from the Volunteers to reduce the search on chapter by role requirements
		 */
		Set<String> chapterNames = new Set<String>();
		Map<Id, List<Volunteer_Roles__c>> volunteerByVolunteerRoles = new Map<Id, List<Volunteer_Roles__c>>();
		for (Volunteer_Roles__c volRole : [
				SELECT Id, Chapter_Name__c, Chapter_Role__r.Name, Volunteer_Name__c, Role_Name__c, Start_Date__c
				FROM Volunteer_Roles__c
				WHERE Volunteer_Name__c IN :volunteerContactIds
				AND Status__c <> :VOLUNTEER_ROLE_STATUS_ACTIVE
		]) {
			chapterNames.add(volRole.Chapter_Name__c);
			if (volunteerByVolunteerRoles.containsKey(volRole.Volunteer_Name__c)) {
				volunteerByVolunteerRoles.get(volRole.Volunteer_Name__c).add(volRole);
			} else {
				List<Volunteer_Roles__c> volunteerRoles = new List<Volunteer_Roles__c>();
				volunteerRoles.add(volRole);
				volunteerByVolunteerRoles.put(volRole.Volunteer_Name__c, volunteerRoles);
			}
		}

		/**
		* Map Chapters to Chapter Roles, and Chapter Roles to the requirements:
		* - Conflict Of Interest
		* - Background Check
		* - Orientation and Training
		*/
		Map<String, Map<String, ChapterRoleRequirementWrapper>> chapterByRoleRequirementMap = findChapterByRoleRequirements(chapterNames);

		/**
		 * Find Volunteer Conflict of Interest, Background Check and Volunteer Orientations and Trainings
		 */
		List<Contact> volunteers = findVolunteers(volunteerContactIds);

		/**
		 * Map Volunteer to Approved Conflict Of Interests
		 */
		Map<Id, Set<String>> volunteerWithApprovedCoiMap = findVolunteerApprovedConflictOfInterest(volunteers);
		/**
		 * Map Volunteer to Approved Background Checks
		 */
		Map<Id, Set<String>> volunteerWithApprovedBgcMap = findVolunteerApprovedBackgroundCheck(volunteers);
		/**
		 * Map Volunteer to Approved Volunteer Orientation and Training
		 */
		Map<Id, Set<String>> volunteerWithApprovedOtMap = findVolunteerApprovedOrientationAndTraining(volunteerContactIds);
		/**
		 * Check Volunteer's Volunteer Role is Active by checking the Chapters requirements and Volunteer
		 * has achieved the requirements to become Active
		 */

		List<Volunteer_Roles__c> volunteerRolesActiveUpdate = new List<Volunteer_Roles__c>();
		Map<Id, Set<String>> volContactIdByChapterIdWithActiveRoleMap = new Map<Id, Set<String>>();
		for (Id volunteerContactId : volunteerByVolunteerRoles.keySet()) {
			for (Volunteer_Roles__c volRole : volunteerByVolunteerRoles.get(volunteerContactId)) {
				Boolean isVolunteerRoleActive = isVolunteerRoleActive(volRole, chapterByRoleRequirementMap,
						volunteerWithApprovedCoiMap, volunteerWithApprovedBgcMap, volunteerWithApprovedOtMap);
				if (isVolunteerRoleActive) {
					Volunteer_Roles__c volunteerRoleUpdate = new Volunteer_Roles__c();
					volunteerRoleUpdate.Id = volRole.Id;
					volunteerRoleUpdate.Status__c = VOLUNTEER_ROLE_STATUS_ACTIVE;
					if (volRole.Start_Date__c == null) {
						volunteerRoleUpdate.Start_Date__c = Date.today();
					}
					volunteerRolesActiveUpdate.add(volunteerRoleUpdate);
					if (volContactIdByChapterIdWithActiveRoleMap.containsKey(volunteerContactId)) {
						volContactIdByChapterIdWithActiveRoleMap.get(volunteerContactId).add(volRole.Chapter_Name__c);
					} else {
						Set<String> chapterNamesOfActiveVolunteerRole = new Set<String>();
						chapterNamesOfActiveVolunteerRole.add(volRole.Chapter_Name__c);
						volContactIdByChapterIdWithActiveRoleMap.put(volunteerContactId, chapterNamesOfActiveVolunteerRole);
					}
				}
			}
		}
		/**
		 * Set Volunteer's User Profile and Organization Affiliation to Active
		 */
		List<npe5__Affiliation__c> activeAffiliations = new List<npe5__Affiliation__c>();
		if (!volunteerRolesActiveUpdate.isEmpty()) {
			update volunteerRolesActiveUpdate;
			//Run User update Asynchronously to avoid Mixed Dml Operation Exception
			setVolunteerUserToActive(volContactIdByChapterIdWithActiveRoleMap.keySet());
			activeAffiliations = setVolunteerAffiliationToActive(volContactIdByChapterIdWithActiveRoleMap);
			update activeAffiliations;
			Map<Id, Contact> contactMap = new Map<Id, Contact>([
					SELECT Id,Active_Board_Member__c,Active_Wish_Granter__c,
							Active_Non_Wish_Granter__c,B_C_Expiration_Date__c,
							COI_Expiration_Date__c
					FROM Contact
					WHERE Id IN :volContactIdByChapterIdWithActiveRoleMap.keySet()
					AND RecordTypeId IN (:CONTACT_VOLUNTEER_RECORD_TYPE_ID, :CONTACT_BOARD_MEMBER_RECORD_TYPE_ID)
			]);
			ContactService.setVolunteerContactActive(contactMap);
		}
		/**
		 * Return a map of Volunteers that are now Active
		 */
		for (npe5__Affiliation__c affiliation : activeAffiliations) {
			if (affiliation.npe5__Status__c == ORG_AFFILIATION_STATUS_STATUS_ACTIVE) {
				activeVolunteersMap.put(affiliation.npe5__Contact__c, true);
			}
		}
		return activeVolunteersMap;
	}

	/**
	 * Process Volunteers Role that has been manually set to Active
	  * bypassing the normal Volunteer Activation process that occurs
	  * within processVolunteersChapterRequirements
	 * @param volunteerContactIdByChapterIdWithActiveRoleMap
	 */
	public static Map<Id, Boolean> processVolunteersRoleActiveBypass(Map<Id, Set<String>> volunteerContactIdByChapterIdWithActiveRoleMap) {
		Map<Id, Boolean> activeVolunteersMap = new Map<Id, Boolean>();
		if (volunteerContactIdByChapterIdWithActiveRoleMap.isEmpty()) {
			return activeVolunteersMap;
		}
		//Run User update Asynchronously to avoid Mixed Dml Operation Exception
		setVolunteerUserToActive(volunteerContactIdByChapterIdWithActiveRoleMap.keySet());
		List<npe5__Affiliation__c> activeAffiliations = setVolunteerAffiliationToActive(volunteerContactIdByChapterIdWithActiveRoleMap);
		update activeAffiliations;
		Map<Id, Contact> contactMap = new Map<Id, Contact>([
				SELECT Id,Active_Board_Member__c,Active_Wish_Granter__c,
						Active_Non_Wish_Granter__c,B_C_Expiration_Date__c,
						COI_Expiration_Date__c
				FROM Contact
				WHERE Id IN :volunteerContactIdByChapterIdWithActiveRoleMap.keySet()
				AND RecordTypeId IN (:CONTACT_VOLUNTEER_RECORD_TYPE_ID, :CONTACT_BOARD_MEMBER_RECORD_TYPE_ID)
		]);
		ContactService.setVolunteerContactActive(contactMap);
		/**
		 * Return a map of Volunteers that are now Active
		 */
		for (npe5__Affiliation__c affiliation : activeAffiliations) {
			if (ORG_AFFILIATION_STATUS_STATUS_ACTIVE.equals(affiliation.npe5__Status__c)) {
				activeVolunteersMap.put(affiliation.npe5__Contact__c, true);
			}
		}
		return activeVolunteersMap;
	}

	/**
	 * Find Chapter Role Requirements
	 * @param chapterNames
	 * @return Map of Chapter Role Requirements Wrapper
	 */
	private static Map<String, Map<String, ChapterRoleRequirementWrapper>> findChapterByRoleRequirements(Set<String> chapterNames) {
		Map<String, Map<String, ChapterRoleRequirementWrapper>> chapterByRoleRequirementMap =
				new Map<String, Map<String, ChapterRoleRequirementWrapper>>();
		for (Chapter_Role__c chapterRole : [
				SELECT Id, Chapter_Name__r.Name, Role_Name__r.Name, COI_Required__c, Background_Check_Required__c
				FROM Chapter_Role__c
				WHERE Chapter_Name__r.Name IN :chapterNames
				AND Chapter_Name__c <> NULL
				AND Role_Name__c <> NULL
		]) {
			// Conflict Of Interest
			// Background Check
			if (chapterByRoleRequirementMap.containsKey(chapterRole.Chapter_Name__r.Name)) {
				if (!chapterByRoleRequirementMap.get(chapterRole.Chapter_Name__r.Name).containsKey(chapterRole.Role_Name__r.Name)) {
					ChapterRoleRequirementWrapper chapterRoleRequirement = new ChapterRoleRequirementWrapper(
							chapterRole.Chapter_Name__r.Name, chapterRole.Role_Name__r.Name,
							chapterRole.COI_Required__c, chapterRole.Background_Check_Required__c,
							new Set<String>());
					chapterByRoleRequirementMap.get(chapterRole.Chapter_Name__r.Name).
							put(chapterRole.Role_Name__r.Name, chapterRoleRequirement);
				}
			} else {
				chapterByRoleRequirementMap.put(chapterRole.Chapter_Name__r.Name, new Map<String, ChapterRoleRequirementWrapper>());
				ChapterRoleRequirementWrapper chapterRoleRequirement = new ChapterRoleRequirementWrapper(
						chapterRole.Chapter_Name__r.Name, chapterRole.Role_Name__r.Name,
						chapterRole.COI_Required__c, chapterRole.Background_Check_Required__c,
						new Set<String>());
				chapterByRoleRequirementMap.get(chapterRole.Chapter_Name__r.Name).
						put(chapterRole.Role_Name__r.Name, chapterRoleRequirement);
			}
		}
		// Orientation and Training
		for (Chapter_Role_O_T__c chapterRoleOrtAndTrgRequired : [
				SELECT Name, Chapter_Name__c, Role_Name__c, Required__c
				FROM Chapter_Role_O_T__c
				WHERE Chapter_Name__c IN :chapterNames
				AND Required__c = TRUE
				AND Chapter_Name__c <> NULL
				AND Role_Name__c <> NULL
		]) {
			if (chapterByRoleRequirementMap.containsKey(chapterRoleOrtAndTrgRequired.Chapter_Name__c)
					&& chapterByRoleRequirementMap.get(chapterRoleOrtAndTrgRequired.Chapter_Name__c)
					.containsKey(chapterRoleOrtAndTrgRequired.Role_Name__c)) {
				chapterByRoleRequirementMap.get(chapterRoleOrtAndTrgRequired.Chapter_Name__c)
						.get(chapterRoleOrtAndTrgRequired.Role_Name__c).orientationAndTrainingsRequired.add(chapterRoleOrtAndTrgRequired.Name);
			}
		}
		return chapterByRoleRequirementMap;
	}

	/**
	 * Find Volunteers
	 * @param volunteerContactIds
	 * @return List of Contacts
	 */
	private static List<Contact> findVolunteers(Set<Id> volunteerContactIds) {
		return [
				SELECT Id, Name, (
						SELECT Volunteer_Contact__c, Account_Name__c
						FROM Conflict_Of_Interest__r
						WHERE Current__c = TRUE
						AND Account_Name__c <> NULL
				), (
						SELECT Volunteer__c, Account_Name__c
						FROM Background_Checks__r
						WHERE Current__c = TRUE
						AND Status__c IN (:BACKGROUND_CHECK_STATUS_APPROVED, :BACKGROUND_CHECK_STATUS_APPROVED_WITH_CONDITIONS)
						AND Account_Name__c <> NULL
				), (
						SELECT Volunteer__c, Class_Offering__r.Chapter_Role_O_T__r.Name
						FROM Volunteer_Orientation_Trainings__r
						WHERE Volunteer_Attendance__c = :VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED
						AND Completion_Status__c NOT IN (
								:VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_NOT_APPROVED,
								:VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_FOLLOW_UP_REQUESTED)
						AND Class_Offering__r.Chapter_Role_O_T__r.Name <> NULL
				)
				FROM Contact
				WHERE Id IN :volunteerContactIds
		];
	}

	/**
	 * Find Volunteer's Approved Conflict of Interests
	 * @param volunteers
	 * @return Map of Volunteer by Chapter Name
	 */
	private static Map<Id, Set<String>> findVolunteerApprovedConflictOfInterest(List<Contact> volunteers) {
		Map<Id, Set<String>> volunteerWithApprovedCoi = new Map<Id, Set<String>>();
		for (Contact ctc : volunteers) {
			if (!ctc.Conflict_Of_Interest__r.isEmpty()) {
				for (Conflict_Of_Interest__c coi : ctc.Conflict_Of_Interest__r) {
					if (volunteerWithApprovedCoi.containsKey(coi.Volunteer_Contact__c)) {
						volunteerWithApprovedCoi.get(coi.Volunteer_Contact__c).add(coi.Account_Name__c);
					} else {
						Set<String> chapterNames = new Set<String>();
						chapterNames.add(coi.Account_Name__c);
						volunteerWithApprovedCoi.put(coi.Volunteer_Contact__c, chapterNames);
					}
				}
			}
		}
		return volunteerWithApprovedCoi;
	}

	/**
	 * Find Volunteer's Approved Background Check
	 * @param volunteers
	 * @return Map of Volunteer by Chapter Name
	 */
	private static Map<Id, Set<String>> findVolunteerApprovedBackgroundCheck(List<Contact> volunteers) {
		Map<Id, Set<String>> volunteerWithApprovedBgc = new Map<Id, Set<String>>();
		for (Contact ctc : volunteers) {
			if (!ctc.Background_Checks__r.isEmpty()) {
				for (Background_check__c bgc : ctc.Background_Checks__r) {
					if (volunteerWithApprovedBgc.containsKey(bgc.Volunteer__c)) {
						volunteerWithApprovedBgc.get(bgc.Volunteer__c).add(bgc.Account_Name__c);
					} else {
						Set<String> chapterNames = new Set<String>();
						chapterNames.add(bgc.Account_Name__c);
						volunteerWithApprovedBgc.put(bgc.Volunteer__c, chapterNames);
					}
				}
			}
		}
		return volunteerWithApprovedBgc;
	}

	/**
	 * Find Volunteer's Approved Orientation and Training
	 * @param volunteerContactIds
	 * @return Map of Volunteer by Chapter Name
	 */
	private static Map<Id, Set<String>> findVolunteerApprovedOrientationAndTraining(Set<Id> volunteerContactIds) {
		Map<Id, Set<String>> volunteerWithApprovedOrnAndTrn = new Map<Id, Set<String>>();
		for (Volunteer_Orientation_Training__c vot : [
				SELECT Volunteer__c, Class_Offering__r.Chapter_Role_O_T__r.Name
				FROM Volunteer_Orientation_Training__c
				WHERE Volunteer__c IN :volunteerContactIds
				AND Volunteer_Attendance__c = :VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED
				AND Completion_Status__c NOT IN (
						:VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_NOT_APPROVED,
						:VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_FOLLOW_UP_REQUESTED)
				AND Class_Offering__r.Chapter_Role_O_T__r.Name <> NULL
		]) {
			if (volunteerWithApprovedOrnAndTrn.containsKey(vot.Volunteer__c)) {
				volunteerWithApprovedOrnAndTrn.get(vot.Volunteer__c).add(vot.Class_Offering__r.Chapter_Role_O_T__r.Name);
			} else {
				Set<String> chapterNames = new Set<String>();
				chapterNames.add(vot.Class_Offering__r.Chapter_Role_O_T__r.Name);
				volunteerWithApprovedOrnAndTrn.put(vot.Volunteer__c, chapterNames);
			}
		}
		return volunteerWithApprovedOrnAndTrn;
	}

	/**
	 * Check if Volunteer Role is Active
	 * @param volRole
	 * @param chapterByRoleRequirementMap
	 * @param volunteerWithApprovedCoiMap
	 * @param volunteerWithApprovedBgcMap
	 * @param volunteerWithApprovedOtMap
	 * @return Boolean
	 */
	private static Boolean isVolunteerRoleActive(Volunteer_Roles__c volRole,
			Map<String, Map<String, ChapterRoleRequirementWrapper>> chapterByRoleRequirementMap,
			Map<Id, Set<String>> volunteerWithApprovedCoiMap,
			Map<Id, Set<String>> volunteerWithApprovedBgcMap,
			Map<Id, Set<String>> volunteerWithApprovedOtMap) {

		if (!chapterByRoleRequirementMap.containsKey(volRole.Chapter_Name__c)
				&& !chapterByRoleRequirementMap.get(volRole.Chapter_Name__c).containsKey(volRole.Role_Name__c)) {
			return false;
		}
		Boolean coiRequired = chapterByRoleRequirementMap.get(volRole.Chapter_Name__c)
				.get(volRole.Role_Name__c).coiRequired;
		if (coiRequired) {
			if (!volunteerWithApprovedCoiMap.containsKey(volRole.Volunteer_Name__c)) {
				return false;
			} else if (!volunteerWithApprovedCoiMap.get(volRole.Volunteer_Name__c).contains(volRole.Chapter_Name__c)) {
				return false;
			}
		}
		Boolean bgcRequired = chapterByRoleRequirementMap.get(volRole.Chapter_Name__c)
				.get(volRole.Role_Name__c).bgcRequired;
		if (bgcRequired) {
			if (!volunteerWithApprovedBgcMap.containsKey(volRole.Volunteer_Name__c)) {
				return false;
			} else if (!volunteerWithApprovedBgcMap.get(volRole.Volunteer_Name__c).contains(volRole.Chapter_Name__c)) {
				return false;
			}
		}
		Boolean orientationAndTrainingRequired = !chapterByRoleRequirementMap.get(volRole.Chapter_Name__c)
				.get(volRole.Role_Name__c).orientationAndTrainingsRequired.isEmpty();
		if (orientationAndTrainingRequired) {
			Set<String> orientationAndTrainingsRequired = chapterByRoleRequirementMap.get(volRole.Chapter_Name__c)
					.get(volRole.Role_Name__c).orientationAndTrainingsRequired;
			if (chapterByRoleRequirementMap.get(volRole.Chapter_Name__c)
					.containsKey(CHAPTER_ROLE_ALL_ROLES)) {
				orientationAndTrainingsRequired.addAll(chapterByRoleRequirementMap.get(volRole.Chapter_Name__c)
						.get(CHAPTER_ROLE_ALL_ROLES).orientationAndTrainingsRequired);
			}
			if (!volunteerWithApprovedOtMap.containsKey(volRole.Volunteer_Name__c)) {
				return false;
			} else if (!volunteerWithApprovedOtMap.get(volRole.Volunteer_Name__c).containsAll(orientationAndTrainingsRequired)) {
				return false;
			}
		}
		return true;
	}

	/**
	* Set Volunteer Contact's User to Active for the
	* Volunteer Role's Chapter previously set to Active
	*/
	@Future
	private static void setVolunteerUserToActive(Set<Id> volunteersWithActiveRoles) {
		List<User> volunteerUsersProfileUpdate = new List<User>();
		for (User volunteerUser : [
				SELECT Id,UserRole.Name,Profile.Name,Profile.Id
				FROM User
				WHERE ContactId IN :volunteersWithActiveRoles
		]) {
			if (!USER_PROFILE_ACTIVE_VOLUNTEER_PROFILE.equals(volunteerUser.ProfileId)) {
				volunteerUser.ProfileId = USER_PROFILE_ACTIVE_VOLUNTEER_PROFILE;
				volunteerUsersProfileUpdate.add(volunteerUser);
			}
		}
		try {
			update volunteerUsersProfileUpdate;
		} catch (Exception e) {
			System.debug('Volunteer Journey setVolunteerUserToActive Exception' + e);
		}
	}

	/**
	* Set Volunteer Contact's Organization Affiliation Status to Active for the
	* Volunteer Role's Chapter previously set to Active
	*/
	private static List<npe5__Affiliation__c> setVolunteerAffiliationToActive(Map<Id, Set<String>> volContactIdByChapterIdWithActiveRoleMap) {
		List<npe5__Affiliation__c> affiliationsActiveUpdate = new List<npe5__Affiliation__c>();
		for (npe5__Affiliation__c affiliation : [
				SELECT Id, npe5__Contact__c, npe5__Status__c, npe5__Organization__r.Name
				FROM npe5__Affiliation__c
				WHERE npe5__Contact__c IN :volContactIdByChapterIdWithActiveRoleMap.keySet()
				AND Constituent_Code__c = :Constant_AC.VOLUNTEER_TASK_RT_LABEL
		]) {
			if (volContactIdByChapterIdWithActiveRoleMap.containsKey(affiliation.npe5__Contact__c)
					&& volContactIdByChapterIdWithActiveRoleMap.get(affiliation.npe5__Contact__c).contains(affiliation.npe5__Organization__r.Name)) {
				affiliation.npe5__Status__c = ORG_AFFILIATION_STATUS_STATUS_ACTIVE;
				affiliationsActiveUpdate.add(affiliation);
			}
		}
		return affiliationsActiveUpdate;
	}

	/**
	 * Wrapper class
	 */
	public class ChapterRoleRequirementWrapper {
		public String chapterName;
		public String chapterRoleName;
		public Boolean coiRequired;
		public Boolean bgcRequired;
		public Set<String> orientationAndTrainingsRequired;
		public ChapterRoleRequirementWrapper(
				String chapterName, String chapterRoleName, Boolean coiRequired,
				Boolean bgcRequired, Set<String> orientationAndTrainingsRequired
		) {
			this.chapterName = chapterName;
			this.chapterRoleName = chapterRoleName;
			if (coiRequired != null) {
				this.coiRequired = coiRequired;
			} else {
				this.coiRequired = false;
			}
			if (bgcRequired != null) {
				this.bgcRequired = bgcRequired;
			} else {
				this.bgcRequired = false;
			}
			if (orientationAndTrainingsRequired != null) {
				this.orientationAndTrainingsRequired = orientationAndTrainingsRequired;
			} else {
				this.orientationAndTrainingsRequired = new Set<String>();
			}
		}
	}
}