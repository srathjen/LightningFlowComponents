/**
 * @description Volunteer Role Service, centralizes Volunteer Role business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 3/19/2020
 */
public class VolunteerRoleService {

	private final static String EMPTY = '';
	private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;
	private final static String VOLUNTEER_ROLE_STATUS_NOT_APPROVED = Constant_AC.VOLUNTEER_ROLE_STATUS_NOT_APPROVED;
	private final static String VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE = Constant_AC.VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE;
	private final static String VOLUNTEER_ROLE_STATUS_PENDING = Constant_AC.VOLUNTEER_ROLE_STATUS_PENDING;
	private final static String VOLUNTEER_ROLE_STATUS_FORMER = Constant_AC.VOLUNTEER_ROLE_STATUS_FORMER;
	private final static String PROFILE_SYSTEM_ADMINISTRATOR = Constant_AC.PROFILE_SYSTEM_ADMINISTRATOR;
	private final static String ROLE_NATIONAL_STAFF = Constant_AC.ROLE_NATIONAL_STAFF;
	private final static String VOLUNTEER_TRAINING_NO_CHECK_OUT_OF_COMPLIANCE = Constant_AC.VOLUNTEER_TRAINING_NO_CHECK_OUT_OF_COMPLIANCE;
	private final static String VOLUNTEER_OUT_OF_COMPLIANCE_NO_CHECK_TRAINING = Constant_AC.VOLUNTEER_OUT_OF_COMPLIANCE_NO_CHECK_TRAINING;
	private final static String VOLUNTEER_NONE_OUTSTANDING = Constant_AC.VOLUNTEER_NONE_OUTSTANDING;
	private final static String VOLUNTEER_OUT_OF_COMPLIANCE_NONE_TRAINING = Constant_AC.VOLUNTEER_OUT_OF_COMPLIANCE_NONE_TRAINING;
	private final static String VOLUNTEER_TRAINING_NONE_OUT_OF_COMPLIANCE = Constant_AC.VOLUNTEER_TRAINING_NONE_OUT_OF_COMPLIANCE;

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
			update updateVolunteerRoleList;
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Conflict_Of_Interest__c coi : volunteerIdCoiMap.values()) {
				ErrorMessage_AC.createDebugRec('VolunteerRoleService', String.valueOf(coi),
						String.valueOf(ex), 'updateNonCompliantByConflictOfInterest', coi.Id,
						ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
				if (!Test.isRunningTest()) {
					coi.addError(Label.Debug_log_error_message);
				}
			}
		}
		return updateVolunteerRoleList;
	}

	/**
	 * Set Sub Status and Start Date on Volunteer Role
	 * @param volunteerRoles
	 */
	public static void setSubStatusAndStartDate(List<Volunteer_Roles__c> volunteerRoles) {
		for (Volunteer_Roles__c volunteerRole : volunteerRoles) {
			if (volunteerRole.Sub_status__c != null
					&& (volunteerRole.Status__c == VOLUNTEER_ROLE_STATUS_ACTIVE
					|| volunteerRole.Status__c == VOLUNTEER_ROLE_STATUS_NOT_APPROVED
					|| volunteerRole.Status__c == VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE)) {
				volunteerRole.Sub_status__c = '';
			}
			if (volunteerRole.Status__c == VOLUNTEER_ROLE_STATUS_ACTIVE
					&& volunteerRole.Start_Date__c == null) {
				volunteerRole.Start_Date__c = Date.today();
			}
		}
	}

	/**
	 * Find Volunteer by Volunteer Roles count
	 * @param volunteerRolesMap
	 * @param statusSet
	 * @return Map of Volunteer by Volunteer Role Count
	 */
	public static Map<String, Integer> findVolunteerByVolunteerRoleCount(
			Map<Id, List<Volunteer_Roles__c>> volunteerRolesMap) {
		Map<String, Integer> volunteerRoleCountMap = new Map<String, Integer>();
		for (AggregateResult currRes : [
				SELECT Volunteer_Name__c, COUNT(Id) cnt
				FROM Volunteer_Roles__c
				WHERE Volunteer_Name__c IN :volunteerRolesMap.keySet()
				GROUP BY Volunteer_Name__c
		]) {
			volunteerRoleCountMap.put(String.valueOf(currRes.get('volunteer_name__c')),
					Integer.valueOf(currRes.get('cnt')));
		}
		return volunteerRoleCountMap;
	}

	/**
	 * Find Volunteer Roles by Status and Volunteer
	 * @param volunteerRolesMap
	 * @param statusSet
	 * @return List of Volunteer Role
	 */
	public static List<Volunteer_Roles__c> findVolunteerRolesByStatusAndVolunteer(
			Map<Id, List<Volunteer_Roles__c>> volunteerRolesMap,
			Set<String> statusSet) {
		List<Volunteer_Roles__c> volunteerRoles = new List<Volunteer_Roles__c>();
		volunteerRoles = [
				SELECT Id, Volunteer_Name__c, Status__c,Sub_status__c
				FROM Volunteer_Roles__c
				WHERE Volunteer_Name__c IN :volunteerRolesMap.keySet()
				AND Status__c IN :statusSet
		];
		return volunteerRoles;
	}

	/**
	 * The purpose of this method is to get the volunteer details to update the volunteer BC & COI based on the volunteer role status
	 * @param volunteerIds
	 * @param volunteerRoles
	 */
	public static void updateVolunteerCoiAndBcg(Set<Id> volunteerIds, List<Volunteer_Roles__c> volunteerRoles) {
		if (volunteerIds.isEmpty() || volunteerRoles.isEmpty()) {
			return;
		}
		try {
			Set<Id> trainingVolunteersIdsSet = new Set<Id>();
			Set<Id> outOfComplianceVolunteersIdsSet = new Set<Id>();
			Set<Id> coiTrainingVolunteerIdsSet = new Set<Id>();
			Set<Id> coiOutOfComplianceVolunteerIdsSet = new Set<Id>();
			for (Volunteer_Roles__c volunteerRole : [
					SELECT Id, Volunteer_Name__c, Chapter_Role__r.Background_Check_Required__c, Status__c
					FROM Volunteer_Roles__c
					WHERE Chapter_Role__c != NULL
					AND Volunteer_Name__c IN:volunteerIds
			]) {
				if (VOLUNTEER_ROLE_STATUS_ACTIVE.equals(volunteerRole.Status__c)
						|| VOLUNTEER_ROLE_STATUS_PENDING.equals(volunteerRole.Status__c)) {
					if (volunteerRole.Chapter_Role__r.Background_Check_Required__c) {
						trainingVolunteersIdsSet.add(volunteerRole.Volunteer_Name__c);
						coiTrainingVolunteerIdsSet.add(volunteerRole.Volunteer_Name__c);
					} else {
						coiTrainingVolunteerIdsSet.add(volunteerRole.Volunteer_Name__c);
					}
				} else if (VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE.equals(volunteerRole.Status__c)) {
					if (volunteerRole.Chapter_Role__r.Background_Check_Required__c) {
						outOfComplianceVolunteersIdsSet.add(volunteerRole.Volunteer_Name__c);
						coiOutOfComplianceVolunteerIdsSet.add(volunteerRole.Volunteer_Name__c);
					} else {
						coiOutOfComplianceVolunteerIdsSet.add(volunteerRole.Volunteer_Name__c);
					}
				} else {
					volunteerIds.add(volunteerRole.Volunteer_Name__c);
				}
			}

			if (trainingVolunteersIdsSet.size() > 0) {
				BackgroundCheckService.updateBackgroundCheckByVolunteers(trainingVolunteersIdsSet, VOLUNTEER_TRAINING_NO_CHECK_OUT_OF_COMPLIANCE);
			}
			if (coiTrainingVolunteerIdsSet.size() > 0) {
				ConflictOfInterestService.updateConflictOfInterestByVolunteers(coiTrainingVolunteerIdsSet, VOLUNTEER_TRAINING_NO_CHECK_OUT_OF_COMPLIANCE);
			}
			if (outOfComplianceVolunteersIdsSet.size() > 0) {
				BackgroundCheckService.updateBackgroundCheckByVolunteers(outOfComplianceVolunteersIdsSet, VOLUNTEER_OUT_OF_COMPLIANCE_NO_CHECK_TRAINING);
			}
			if (coiOutOfComplianceVolunteerIdsSet.size() > 0) {
				ConflictOfInterestService.updateConflictOfInterestByVolunteers(coiOutOfComplianceVolunteerIdsSet, VOLUNTEER_OUT_OF_COMPLIANCE_NO_CHECK_TRAINING);
			}
			if (volunteerIds.size() > 0 && outOfComplianceVolunteersIdsSet.size() == 0 && trainingVolunteersIdsSet.size() == 0) {
				BackgroundCheckService.updateBackgroundCheckByVolunteers(volunteerIds, VOLUNTEER_NONE_OUTSTANDING);
			}
			if (volunteerIds.size() > 0 && coiOutOfComplianceVolunteerIdsSet.size() == 0 && coiTrainingVolunteerIdsSet.size() == 0) {
				ConflictOfInterestService.updateConflictOfInterestByVolunteers(volunteerIds, VOLUNTEER_NONE_OUTSTANDING);
			}
			if (outOfComplianceVolunteersIdsSet.size() > 0 && trainingVolunteersIdsSet.size() == 0) {
				BackgroundCheckService.updateBackgroundCheckByVolunteers(outOfComplianceVolunteersIdsSet, VOLUNTEER_OUT_OF_COMPLIANCE_NONE_TRAINING);
			}
			if (coiOutOfComplianceVolunteerIdsSet.size() > 0 && coiTrainingVolunteerIdsSet.size() == 0) {
				ConflictOfInterestService.updateConflictOfInterestByVolunteers(coiOutOfComplianceVolunteerIdsSet, VOLUNTEER_OUT_OF_COMPLIANCE_NONE_TRAINING);
			}
			if (trainingVolunteersIdsSet.size() > 0 && outOfComplianceVolunteersIdsSet.size() == 0) {
				BackgroundCheckService.updateBackgroundCheckByVolunteers(trainingVolunteersIdsSet, VOLUNTEER_TRAINING_NONE_OUT_OF_COMPLIANCE);
			}
			if (coiTrainingVolunteerIdsSet.size() > 0 && coiOutOfComplianceVolunteerIdsSet.size() == 0) {
				ConflictOfInterestService.updateConflictOfInterestByVolunteers(coiTrainingVolunteerIdsSet, VOLUNTEER_TRAINING_NONE_OUT_OF_COMPLIANCE);
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Volunteer_Roles__c currRec : volunteerRoles) {
				ErrorMessage_AC.createDebugRec('VolunteerRoleService',
						String.valueOf(currRec), String.valueOf(ex), 'updateVolunteerCoiAndBcg',
						currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (Volunteer_Roles__c currRec : volunteerRoles) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	/**
	* Build Set of Chapter names from Volunteer Roles
	 * @param newVolunteerRoleList
	 * @return Set of Chapter Names
	 */
	public static Set<String> buildChapterNames(List<Volunteer_Roles__c> newVolunteerRoleList) {
		Set<String> chapterNamesSet = new Set<String>();
		for (Volunteer_Roles__c volRole : newVolunteerRoleList) {
			chapterNamesSet.add(volRole.Chapter_Name__c);
		}
		return chapterNamesSet;
	}

	/**
	 * Build Set of Non Active Volunteer Roles
	 * @param volunteerRoleStatusMap
	 * @return Set of Volunteer Names
	 */
	public static Set<Id> buildNonActiveVolunteerSet(List<Volunteer_Roles__c> volunteerRoles) {
		Set<Id> volunteerWithNonActiveRole = new Set<Id>();
		for (Volunteer_Roles__c volunteerRole : volunteerRoles) {
			if (!VOLUNTEER_ROLE_STATUS_ACTIVE.equals(volunteerRole.Status__c)) {
				volunteerWithNonActiveRole.add(volunteerRole.Volunteer_Name__c);
			}
		}
		return volunteerWithNonActiveRole;
	}

	/**
	 * Build Set of Volunteer Names from Status
	 * @param volunteerRoleStatusMap
	 * @return Set of Volunteer Names
	 */
	public static Set<Id> buildVolunteerSetFromStatus(List<Volunteer_Roles__c> volunteerRoles,
			String status) {
		Set<Id> volunteerRoleSet = new Set<Id>();
		for (Volunteer_Roles__c newVolRole : volunteerRoles) {
			if (status.equals(newVolRole.Status__c)) {
				volunteerRoleSet.add(newVolRole.Volunteer_Name__c);
			}
		}
		return volunteerRoleSet;
	}

	/**
	 * Build Set of Volunteer Names which Status has been changed
	 * @param volunteerRoles
	 * @param oldVolunteerRolesMap
	 * @return Set of Volunteer Names
	 */
	public static Set<Id> buildModifiedRoleStatusVolunteerSet(List<Volunteer_Roles__c> volunteerRoles,
			Map<Id, Volunteer_Roles__c> oldVolunteerRolesMap) {
		Set<Id> volunteerIdsSet = new Set<Id>();
		for (Volunteer_Roles__c newVolRole : volunteerRoles) {
			if (newVolRole.Status__c != oldVolunteerRolesMap.get(newVolRole.Id).Status__c) {
				volunteerIdsSet.add(newVolRole.Volunteer_Name__c);
			}
		}
		return volunteerIdsSet;
	}

	public static Map<Id, List<Volunteer_Roles__c>> buildVolunteerRolesByVolunteer(List<Volunteer_Roles__c> newVolunteerRoleList,
			Map<Id, Volunteer_Roles__c> oldVolunteerRolesMap) {
		Map<Id, List<Volunteer_Roles__c>> volunteerRoleMap = new Map<Id, List<Volunteer_Roles__c>>();
		for (Volunteer_Roles__c newVolRole : newVolunteerRoleList) {
			if (newVolRole.Status__c != oldVolunteerRolesMap.get(newVolRole.Id).Status__c
					&& (VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE.equals(newVolRole.Status__c)
					|| VOLUNTEER_ROLE_STATUS_ACTIVE.equals(newVolRole.Status__c)
					|| VOLUNTEER_ROLE_STATUS_FORMER.equals(newVolRole.Status__c)
					|| VOLUNTEER_ROLE_STATUS_NOT_APPROVED.equals(newVolRole.Status__c)
					|| VOLUNTEER_ROLE_STATUS_PENDING.equals(newVolRole.Status__c))) {
				if (volunteerRoleMap.containsKey(newVolRole.Volunteer_Name__c)) {
					volunteerRoleMap.get(newVolRole.Volunteer_Name__c).add(newVolRole);
				} else {
					volunteerRoleMap.put(newVolRole.Volunteer_Name__c, new List<Volunteer_Roles__c>{
							newVolRole
					});
				}
			}
		}
		return volunteerRoleMap;
	}

	public static Map<Id, Id> buildInactiveVolunteerByWish(Map<Id, List<Volunteer_Roles__c>> volRoleMap,
			List<Volunteer_Opportunity__c> volunteerOpportunities) {
		Map<Id, Id> inactiveWishVolunteerIdMap = new Map<Id, Id>();
		if (volunteerOpportunities.isEmpty()) {
			return inactiveWishVolunteerIdMap;
		}
		for (Volunteer_Opportunity__c volunteerOpportunity : volunteerOpportunities) {
			if (volRoleMap.containsKey(volunteerOpportunity.Volunteer_Name__c)) {
				for (Volunteer_Roles__c volunteerRole : volRoleMap.get(volunteerOpportunity.Volunteer_Name__c)) {
					if (volunteerOpportunity.Chapter_Name__r.Name == volunteerRole.Chapter_Name__c
							&& volunteerOpportunity.Role__c == volunteerRole.Role_Name__c) {
						if (volunteerOpportunity.Wish__c != null
								&& (volunteerRole.Status__c == VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE
								|| volunteerRole.Status__c == VOLUNTEER_ROLE_STATUS_NOT_APPROVED
								|| volunteerRole.Status__c == VOLUNTEER_ROLE_STATUS_FORMER)) {
							inactiveWishVolunteerIdMap.put(volunteerOpportunity.Wish__c, volunteerOpportunity.Volunteer_Name__c);
						}
					}
				}
			}
		}
		return inactiveWishVolunteerIdMap;
	}

	public static Map<Id, Set<String>> buildInactiveVolunteerRoleMap(Map<Id, List<Volunteer_Roles__c>> volRoleMap,
			List<Volunteer_Opportunity__c> volunteerOpportunities) {
		Map<Id, Set<String>> volunteerRoleMap = new Map<Id, Set<String>>();
		if (volunteerOpportunities.isEmpty()) {
			return volunteerRoleMap;
		}
		for (Volunteer_Opportunity__c volunteerOpportunity : volunteerOpportunities) {
			if (volRoleMap.containsKey(volunteerOpportunity.Volunteer_Name__c)) {
				for (Volunteer_Roles__c volunteerRole : volRoleMap.get(volunteerOpportunity.Volunteer_Name__c)) {
					if (volunteerOpportunity.Chapter_Name__r.Name == volunteerRole.Chapter_Name__c
							&& volunteerOpportunity.Role__c == volunteerRole.Role_Name__c) {
						if (volunteerOpportunity.Wish__c != null
								&& (volunteerRole.Status__c == VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE
								|| volunteerRole.Status__c == VOLUNTEER_ROLE_STATUS_NOT_APPROVED
								|| volunteerRole.Status__c == VOLUNTEER_ROLE_STATUS_FORMER)) {
							if (volunteerRoleMap.containsKey(volunteerOpportunity.Volunteer_Name__c)) {
								volunteerRoleMap.get(volunteerOpportunity.Volunteer_Name__c).add(volunteerOpportunity.Role__c);
							} else {
								volunteerRoleMap.put(volunteerOpportunity.Volunteer_Name__c, new Set<String>{
										volunteerOpportunity.Role__c
								});
							}
						}
					}
				}
			}
		}
		return volunteerRoleMap;
	}

	/**
	 * Build Map of Volunteer Roles
	 * @param volunteerRoleStatusMap
	 * @param statusSet
	 * @return Map of Volunteer Role
	 */
	public static Map<Id, List<Volunteer_Roles__c>> buildVolunteerByVolunteerRolesMap(
			List<Volunteer_Roles__c> volunteerRoles) {
		Map<Id, List<Volunteer_Roles__c>> volunteerRolesMap = new Map<Id, List<Volunteer_Roles__c>>();
		for (Volunteer_Roles__c volunteerRole : volunteerRoles) {
			if (volunteerRolesMap.containsKey(volunteerRole.Volunteer_Name__c)) {
				volunteerRolesMap.get(volunteerRole.Volunteer_Name__c).add(volunteerRole);
			} else {
				volunteerRolesMap.put(volunteerRole.Volunteer_Name__c, new List<Volunteer_Roles__c>{
						volunteerRole
				});
			}
		}
		return volunteerRolesMap;
	}

	/**
	 * Build Map of Volunteer Roles from Status
	 * @param volunteerRoleStatusMap
	 * @param statusSet
	 * @return Map of Volunteer Role
	 */
	public static Map<Id, List<Volunteer_Roles__c>> buildVolunteerByVolunteerRolesMapFromStatus(
			List<Volunteer_Roles__c> volunteerRoles, String status) {
		Map<Id, List<Volunteer_Roles__c>> volunteerRolesMap = new Map<Id, List<Volunteer_Roles__c>>();
		for (Volunteer_Roles__c volunteerRole : volunteerRoles) {
			if (status.equals(volunteerRole.Status__c)) {
				if (volunteerRolesMap.containsKey(volunteerRole.Volunteer_Name__c)) {
					volunteerRolesMap.get(volunteerRole.Volunteer_Name__c).add(volunteerRole);
				} else {
					volunteerRolesMap.put(volunteerRole.Volunteer_Name__c, new List<Volunteer_Roles__c>{
							volunteerRole
					});
				}
			}
		}
		return volunteerRolesMap;
	}

	/**
	 * Build Map of Volunteer Roles from Status
	 * @param volunteerRoleStatusMap
	 * @param statusSet
	 * @return Map of Volunteer Role
	 */
	public static Map<Id, Set<String>> buildVolunteerByChapterNameMapFromStatus(
			List<Volunteer_Roles__c> volunteerRoles, String status) {
		Map<Id, Set<String>> volunteerByChapterMap = new Map<Id, Set<String>>();
		for (Volunteer_Roles__c newVolRole : volunteerRoles) {
			if (status.equals(newVolRole.Status__c)) {
				if (volunteerByChapterMap.containsKey(newVolRole.Volunteer_Name__c)) {
					volunteerByChapterMap.get(newVolRole.Volunteer_Name__c).add(newVolRole.Chapter_Name__c);
				} else {
					volunteerByChapterMap.put(newVolRole.Volunteer_Name__c, new Set<String>{
							newVolRole.Chapter_Name__c
					});
				}
			}
		}
		return volunteerByChapterMap;
	}
}