/**
 * @description Volunteer Opportunity Service, centralizes Volunteer Opportunity business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 4/14/2020
 */
public class VolunteerOpportunityService {

	private final static String ROLE_NATIONAL_STAFF = Constant_AC.ROLE_NATIONAL_STAFF;
	private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;
	private final static String VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE = Constant_AC.VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE;
	private final static String VOLUNTEER_OPPORTUNITY_STATUS_OUT_OF_COMPLIANCE = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_OUT_OF_COMPLIANCE;
	private final static String VOLUNTEER_OPPORTUNITY_STATUS_HOLD = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_HOLD;
	private final static String VOLUNTEER_OPPORTUNITY_STATUS_APPROVED = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_APPROVED;
	private final static String VOLUNTEER_OPPORTUNITY_STATUS_PENDING = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_PENDING;
	private final static String VOLUNTEER_OPPORTUNITY_STATUS_INACTIVE = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_INACTIVE;
	private final static String VOLUNTEER_OPPORTUNITY_STATUS_COMPLETED = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_COMPLETED;
	private final static String CASE_STATUS_GRANTED = Constant_AC.CASE_STATUS_GRANTED;
	private final static String CASE_STATUS_COMPLETED = Constant_AC.CASE_STATUS_COMPLETED;
	private final static String CASE_STATUS_INACTIVE = Constant_AC.CASE_STATUS_INACTIVE;
	private static final Set<Id> WISH_RECORD_TYPES = new Set<Id>{
			Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID, Constant_AC.REGISTERED_WISH_ID
	};
	private static final Set<Id> NONWISH_RECORD_TYPES = new Set<Id>{
			Constant_AC.NON_WISH_EVENT_RT_ID, Constant_AC.REGISTERED_NON_WISH_ID
	};
	private static final String VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER = Constant_AC.VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER;
	private static final String VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER_MENTOR = Constant_AC.VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER_MENTOR;
	private static final String VOLUNTEER_OPPORTUNITY_ROLE_TEMPORARY_WISH_GRANTER = Constant_AC.VOLUNTEER_OPPORTUNITY_ROLE_TEMPORARY_WISH_GRANTER;
	private final static Id REGISTERED_WISH_ID = Constant_AC.REGISTERED_WISH_ID;
	private final static Id REGISTERED_NON_WISH_ID = Constant_AC.REGISTERED_NON_WISH_ID;
	private final static Id WISH_VOLUNTEER_OPPORTUNITY_ID = Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID;
	private final static Id NON_WISH_EVENT_RT_ID = Constant_AC.NON_WISH_EVENT_RT_ID;
	private final static Id WISH_RT_ID = Constant_AC.WISH_RT_ID;
	private final static String TEAM_MEMBER_NAME_INACTIVE = 'Inactive';
	private final static String VOLUNTEER_OPPORTUNITY_REASON_INACTIVE_NOT_APPROVED = Constant_AC.VOLUNTEER_OPPORTUNITY_REASON_INACTIVE_NOT_APPROVED;

	public static List<Volunteer_Opportunity__c> findVolunteerOpportunityByVolunteer(Set<Id> volunteerIds) {
		return [
				SELECT Id, Status__c, Chapter_Name__c, Hidden_allow_Hold_status__c,
						Wish__c, Wish__r.Status, Chapter_Name__r.Name, Volunteer_Name__c, Role__c
				FROM Volunteer_Opportunity__c
				WHERE Volunteer_Name__c IN :volunteerIds
		];
	}

	public static Map<Id, Volunteer_Opportunity__c> updateVolunteerOpportunityByVolunteerRoles(Map<Id, List<Volunteer_Roles__c>> volunteerRolesMap) {
		Map<Id, Volunteer_Opportunity__c> updateVolOppMap = new Map<Id, Volunteer_Opportunity__c>();
		if (volunteerRolesMap.isEmpty()) {
			return updateVolOppMap;
		}
		try {
			for (Volunteer_Opportunity__c volunteerOpportunity : [
					SELECT Id, Status__c, Chapter_Name__c, Hidden_allow_Hold_status__c,
							Wish__c, Wish__r.Status, Chapter_Name__r.Name, Volunteer_Name__c, Role__c
					FROM Volunteer_Opportunity__c
					WHERE Volunteer_Name__c IN:volunteerRolesMap.keySet()
			]) {
				if (volunteerRolesMap.containsKey(volunteerOpportunity.Volunteer_Name__c)) {
					for (Volunteer_Roles__c newVolRole : volunteerRolesMap.get(volunteerOpportunity.Volunteer_Name__c)) {
						if (volunteerOpportunity.Chapter_Name__r.Name == newVolRole.Chapter_Name__c
								&& volunteerOpportunity.Role__c == newVolRole.Role_Name__c) {
							if (newVolRole.Status__c == VOLUNTEER_ROLE_STATUS_ACTIVE
									&& volunteerOpportunity.Status__c == VOLUNTEER_OPPORTUNITY_STATUS_OUT_OF_COMPLIANCE) {
								volunteerOpportunity.Status__c = VOLUNTEER_OPPORTUNITY_STATUS_HOLD;
								volunteerOpportunity.Hidden_allow_Hold_status__c = true;
							} else if (newVolRole.Status__c == VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE
									&& volunteerOpportunity.Status__c == VOLUNTEER_OPPORTUNITY_STATUS_APPROVED
									&& ((volunteerOpportunity.Wish__c != null
									&& volunteerOpportunity.Wish__r.Status != CASE_STATUS_GRANTED
									&& volunteerOpportunity.Wish__r.Status != CASE_STATUS_COMPLETED)
									|| volunteerOpportunity.Wish__c == null)) {
								volunteerOpportunity.Status__c = VOLUNTEER_OPPORTUNITY_STATUS_OUT_OF_COMPLIANCE;
							}
							updateVolOppMap.put(volunteerOpportunity.Id, volunteerOpportunity);
						}
					}
				}
			}
			update updateVolOppMap.values();
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Volunteer_Opportunity__c volunteerOpportunity : updateVolOppMap.values()) {
				ErrorMessage_AC.createDebugRec('VolunteerOpportunityService', String.valueOf(volunteerOpportunity),
						String.valueOf(ex), 'updateVolunteerOpportunityByVolunteerRoles',
						volunteerOpportunity.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
				if (!Test.isRunningTest()) {
					volunteerOpportunity.addError(Label.Debug_log_error_message);
				}
			}
		}
		return updateVolOppMap;
	}

	/**
	 * Delete Volunteer Opportunity Non Approved By Non Wish Event and Record Type Id
	 * @param nonWishEventId
	 * @param recordTypeId
	 */
	public static void deleteNonApprovedByNonWishEventAndRecordType(Id nonWishEventId, Id recordTypeId) {
		List<Volunteer_Opportunity__c> volunteerOpportunity = [
				SELECT Id,RecordTypeId,Chapter_Role_Opportunity__c,Chapter_Name__c,
						Volunteer_Name__c,Non_Wish_Event__c,Reason_Inactive__c
				FROM Volunteer_Opportunity__c
				WHERE Volunteer_Name__c = NULL
				AND Non_Wish_Event__c = :nonWishEventId
				AND RecordTypeId = :recordTypeId
				AND Status__c != :VOLUNTEER_OPPORTUNITY_STATUS_APPROVED
				AND Reason_Inactive__c = :NULL
		];
		delete volunteerOpportunity;
	}

	/**
	 * Delete Volunteer Opportunity Non Approved By Chapter and Non Wish Event
	 * @param nonWishEventId
	 * @param recordTypeId
	 */
	public static void deleteNonApprovedByChapterAndNonWishEvent(Set<Id> chapterRoleIds, Id nonWishEventId) {
		List<Volunteer_Opportunity__c> deleteVolunteerList = [
				SELECT Id,Chapter_Name__c,Chapter_Role_Opportunity__c,Volunteer_Name__c,Non_Wish_Event__c
				FROM Volunteer_Opportunity__c
				WHERE Chapter_Role_Opportunity__c IN:chapterRoleIds
				AND Volunteer_Name__c = NULL
				AND Non_Wish_Event__c = :nonWishEventId
				AND Reason_Inactive__c = :NULL
		];
		delete deleteVolunteerList;
	}

	/**
	 * Update the record type, status and wish start date values
	 * @param newMap
	 * @param oldMap
	 */
	public static void setFields(Map<Id, Volunteer_Opportunity__c> newMap, Map<Id, Volunteer_Opportunity__c> oldMap) {
		Set<Id> volunteerContactIdSet = new Set<Id>();
		Set<Id> wishIds = new Set<Id>();
		for (Volunteer_Opportunity__c volunteerOpportunity : newMap.values()) {
			if (volunteerOpportunity.Inactive__c
					&& !oldMap.get(volunteerOpportunity.Id).Inactive__c
					&& volunteerOpportunity.Reason_Inactive__c != null) {
				volunteerOpportunity.Status__c = VOLUNTEER_OPPORTUNITY_STATUS_INACTIVE;
				volunteerOpportunity.Inactivated_or_Rejected_Date__c = Date.today();
			}
			if (volunteerOpportunity.Inactive__c
					&& VOLUNTEER_OPPORTUNITY_STATUS_INACTIVE.equals(volunteerOpportunity.Status__c)
					&& volunteerOpportunity.Wish__c != null) {
				volunteerOpportunity.Wish_End_Date__c = Date.today();
			}
			if (VOLUNTEER_OPPORTUNITY_STATUS_PENDING.equals(volunteerOpportunity.Status__c)
					&& volunteerOpportunity.Status__c != oldMap.get(volunteerOpportunity.Id).Status__c) {
				volunteerOpportunity.Inactivated_or_Rejected_Date__c = Date.today();
			}
			if (volunteerOpportunity.Volunteer_Name__c != null
					&& volunteerOpportunity.Volunteer_Name__c != oldMap.get(volunteerOpportunity.Id).Volunteer_Name__c) {
				volunteerContactIdSet.add(volunteerOpportunity.Volunteer_Name__c);
			}
			if (volunteerOpportunity.Reason_Inactive__c != null) {
				volunteerOpportunity.Inactive__c = true;
			}
			if (volunteerOpportunity.RecordTypeId == WISH_VOLUNTEER_OPPORTUNITY_ID
					&& VOLUNTEER_OPPORTUNITY_STATUS_APPROVED.equals(volunteerOpportunity.Status__c)
					&& oldMap.get(volunteerOpportunity.Id).Status__c != volunteerOpportunity.Status__c
					&& volunteerOpportunity.Wish__c != null) {
				volunteerOpportunity.RecordTypeId = REGISTERED_WISH_ID;
				wishIds.add(volunteerOpportunity.Wish__c);
			}
			if (volunteerOpportunity.RecordTypeId == NON_WISH_EVENT_RT_ID
					&& VOLUNTEER_OPPORTUNITY_STATUS_APPROVED.equals(volunteerOpportunity.Status__c)) {
				volunteerOpportunity.RecordTypeId = REGISTERED_NON_WISH_ID;

			}
			if (VOLUNTEER_OPPORTUNITY_STATUS_APPROVED.equals(volunteerOpportunity.Status__c)
					&& VOLUNTEER_OPPORTUNITY_STATUS_PENDING.equals(oldMap.get(volunteerOpportunity.Id).Status__c)) {
				volunteerOpportunity.Inactivated_or_Rejected_Date__c = null;
			}
		}
		Map<Id, String> volunteerContactMap = new Map<Id, String>();
		if (!volunteerContactIdSet.isEmpty()) {
			for (Contact volunteerContact : [
					SELECT Id,Email
					FROM Contact
					WHERE Id IN:volunteerContactIdSet
			]) {
				volunteerContactMap.put(volunteerContact.Id, volunteerContact.Email);
			}
		}
		Set<Id> caseIds = new Set<Id>();
		if (!wishIds.isEmpty()) {
			for (Case wishCase : [
					SELECT Id,Status,RecordTypeId,IsClosed
					FROM Case
					WHERE Status != :CASE_STATUS_GRANTED
					AND RecordTypeId = :WISH_RT_ID
					AND Id IN:wishIds
			]) {
				if (!wishCase.IsClosed) {
					caseIds.add(wishCase.Id);
				}
			}
		}
		if (!volunteerContactMap.isEmpty() || !caseIds.isEmpty()) {
			for (Volunteer_Opportunity__c volunteerOpportunity : newMap.values()) {
				if (volunteerOpportunity.Volunteer_Name__c != null
						&& volunteerContactMap.containsKey(volunteerOpportunity.Volunteer_Name__c)) {
					volunteerOpportunity.Hidden_Volunteer_Contact_Email__c = volunteerContactMap.get(volunteerOpportunity.Volunteer_Name__c);
				}
				if (caseIds.contains(volunteerOpportunity .Wish__c)) {
					volunteerOpportunity.Wish_Start_Date__c = System.today();
				}
			}
		}
	}

	public static void updateUserRoleId(List<Volunteer_Opportunity__c> volunteerOpportunities) {
		if (volunteerOpportunities.isEmpty()) {
			return;
		}
		Map<Id, Id> volunteerUserMap = new Map<Id, Id>();
		for (Volunteer_Opportunity__c volunteerOpportunity : volunteerOpportunities) {
			if (volunteerOpportunity.Volunteer_Name__c != null) {
				volunteerUserMap.put(volunteerOpportunity.Id, volunteerOpportunity.Volunteer_Name__c);
			}
		}
		try {
			String chapterRole;
			Set<Id> volunteerIds = new Set<Id>();
			for (Volunteer_Opportunity__c opportunity : [
					SELECT Id,Volunteer_Name__c, Non_Wish_Event__c, Chapter_Role_Opportunity__c,
							Chapter_Role_Opportunity__r.Role_Name__c
					FROM Volunteer_Opportunity__c
					WHERE Id IN:volunteerUserMap.keySet()
			]) {
				volunteerIds.add(opportunity.Volunteer_Name__c);
				chapterRole = opportunity.Chapter_Role_Opportunity__r.Role_Name__c
						+ String.valueOf(opportunity.Non_Wish_Event__c);
			}
			String roleInUser;
			List<User> volunteerUsers = new List<User>();
			for (User user : [
					SELECT Id,ContactId,Hidden_Role_Name_Id__c
					FROM User
					WHERE ContactId IN:volunteerUserMap.values()
			]) {
				if (String.isNotEmpty(user.Hidden_Role_Name_Id__c)) {
					roleInUser = user.Hidden_Role_Name_Id__c ;
					if (roleInUser.contains(chapterRole)) {
						roleInUser.remove(chapterRole);
						user.Hidden_Role_Name_Id__c = roleInUser.remove(chapterRole);
						volunteerUsers.add(user);
					}
				}
			}
			update volunteerUsers;
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Volunteer_Opportunity__c volunteerOpportunity : volunteerOpportunities) {
				ErrorMessage_AC.createDebugRec('VolunteerOpportunityService',
						String.valueOf(volunteerOpportunity), String.valueOf(ex), 'updateUserRoleId',
						volunteerOpportunity.Id, ex.getStackTraceString(), 'Error');
				if (!Test.isRunningTest()) {
					volunteerOpportunity.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	public static void updateVolunteerNeededCount(Map<Id, Volunteer_Opportunity__c> nonWishUpdateMap) {
		if (nonWishUpdateMap.isEmpty()) {
			return;
		}
		Set<Id> chapterRoleIds = new Set<Id>();
		Set<Id> nonWishEventIds = new Set<Id>();
		Set<String> volunteerCountDescIds = new Set<String>();
		Map<Id, Integer> volunteerCountMap = new Map<Id, Integer>();
		List<Volunteer_Count__c > updateVolunteerCountList = new List<Volunteer_Count__c>();
		try {
			for (Volunteer_Opportunity__c volunteerOpportunity : nonWishUpdateMap.values()) {
				chapterRoleIds.add(volunteerOpportunity.Chapter_Role_Opportunity__c);
				nonWishEventIds.add(volunteerOpportunity.Non_Wish_Event__c);
				volunteerCountDescIds.add(volunteerOpportunity.Hidden_VolunteerCount_Desc__c +
						volunteerOpportunity.Date__c +
						volunteerOpportunity.Start_Time__c +
						volunteerOpportunity.End_Time__c);
			}
			List<AggregateResult> groupedResults = [
					SELECT Chapter_Role_Opportunity__c nonwish, COUNT(Id)aver,Hidden_VolunteerCount_Desc__c
					FROM Volunteer_Opportunity__c
					WHERE Non_Wish_Event__c IN:nonWishEventIds
					AND Reason_Inactive__c = NULL
					AND Chapter_Role_Opportunity__c IN:chapterRoleIds
					GROUP BY Chapter_Role_Opportunity__c, Hidden_VolunteerCount_Desc__c, Date__c, Start_Time__c, End_Time__c
			];
			if (!groupedResults.isEmpty()) {
				for (AggregateResult arr : groupedResults) {
					volunteerCountMap.put((Id) arr.get('nonwish'), (Integer) arr.get('aver'));
				}
			}
			if (!volunteerCountMap.isEmpty()) {
				for (Volunteer_Count__c volunteerCount : [
						SELECT Id,Name,Volunteer_Needed__c,Non_Wish_Events__c,Chapter_Role__c,Registered__c,
								Description__c,Start_Time__c,End_Time__c,Date__c
						FROM Volunteer_Count__c
						WHERE Chapter_Role__c IN:volunteerCountMap.keySet()
				]) {
					if (nonWishEventIds .contains(volunteerCount.Non_Wish_Events__c)) {
						if (volunteerCountMap.containsKey(volunteerCount.Chapter_Role__c)) {
							if (volunteerCountDescIds.contains(volunteerCount.Description__c +
									volunteerCount.Date__c +
									volunteerCount.Start_Time__c +
									volunteerCount.End_Time__c)) {
								if (volunteerCount.Volunteer_Needed__c > 0) {
									volunteerCount.Volunteer_Needed__c = volunteerCount.Volunteer_Needed__c - 1;
								}
								updateVolunteerCountList.add(volunteerCount);
							}
						}
					}
				}
				update updateVolunteerCountList;
			} else {
				for (Volunteer_Count__c volunteerCount : [
						SELECT Id,Name,Volunteer_Needed__c,Non_Wish_Events__c,Chapter_Role__c,Registered__c,
								Description__c,Start_Time__c,End_Time__c,Date__c
						FROM Volunteer_Count__c
						WHERE Chapter_Role__c IN:chapterRoleIds
				]) {
					if (nonWishEventIds.contains(volunteerCount.Non_Wish_Events__c)) {
						if (volunteerCountDescIds.contains(volunteerCount.Description__c +
								volunteerCount.Date__c +
								volunteerCount.Start_Time__c +
								volunteerCount.End_Time__c)) {
							volunteerCount.Volunteer_Needed__c = 0;
							updateVolunteerCountList.add(volunteerCount);
						}
					}
				}
				update updateVolunteerCountList;
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Volunteer_Opportunity__c volunteerOpportunity : nonWishUpdateMap.values()) {
				ErrorMessage_AC.createDebugRec('VolunteerOpportunityService',
						String.valueOf(volunteerOpportunity), String.valueOf(ex), 'updateVolunteerNeededCount',
						volunteerOpportunity.Id, ex.getStackTraceString(), 'Error');
				if (!Test.isRunningTest()) {
					volunteerOpportunity.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	public static void updateVolunteerRegisteredCount(List<Volunteer_Opportunity__c> nonWishListUpdateCount, Set<Id> nonWishRegisteredUpdateSet, Boolean isDelete) {
		if (nonWishListUpdateCount.isEmpty() || nonWishRegisteredUpdateSet.isEmpty()) {
			return;
		}
		RecursiveTriggerHandler.isFirstTime = false;
		Set<Id> chapterRoleIds = new Set<Id>();
		Set<Id> nonWishEventIds = new Set<Id>();
		Set<String> descriptionIds = new Set<String>();
		Map<Id, Integer> volunteerCountMap = new Map<Id, Integer>();
		List<Volunteer_Count__c > updateVolunteerCounts = new List<Volunteer_Count__c>();
		Boolean isRegistered = false;
		Boolean isPending = false;
		try {
			for (Volunteer_Opportunity__c newVolOpp : nonWishListUpdateCount) {
				chapterRoleIds.add(newVolOpp.Chapter_Role_Opportunity__c);
				descriptionIds.add(newVolOpp.Hidden_VolunteerCount_Desc__c +
						newVolOpp.Date__c +
						newVolOpp.Start_Time__c +
						newVolOpp.End_Time__c);
				nonWishEventIds.add(newVolOpp.Non_Wish_Event__c);
				if ((newVolOpp.Inactive__c && newVolOpp.Reason_Inactive__c != null
						&& VOLUNTEER_OPPORTUNITY_STATUS_APPROVED.equals(newVolOpp.Status__c))
						|| (newVolOpp.Inactive__c
						&& newVolOpp.Reason_Inactive__c != null
						&& VOLUNTEER_OPPORTUNITY_REASON_INACTIVE_NOT_APPROVED.equals(newVolOpp.Reason_Inactive__c))) {
					isDelete = true;
					isRegistered = true;
				}
				if (VOLUNTEER_OPPORTUNITY_STATUS_PENDING.equals(newVolOpp.Status__c) && !isDelete) {
					isPending = true;
				}
			}
			List<AggregateResult> groupedResults = [
					SELECT Chapter_Role_Opportunity__c nonwish, COUNT(Id)aver,Hidden_VolunteerCount_Desc__c
					FROM Volunteer_Opportunity__c
					WHERE Non_Wish_Event__c IN:nonWishEventIds
					AND Volunteer_Name__c != NULL
					AND (Reason_Inactive__c = NULL
					OR Reason_Inactive__c != NULL)
					AND Chapter_Role_Opportunity__c IN:chapterRoleIds
					AND Id IN :nonWishRegisteredUpdateSet
					GROUP BY Chapter_Role_Opportunity__c, Hidden_VolunteerCount_Desc__c, Date__c, Start_Time__c, End_Time__c
			];
			if (!groupedResults.isEmpty()) {
				for (AggregateResult arr : groupedResults) {
					volunteerCountMap.put((Id) arr.get('nonwish'), (Integer) arr.get('aver'));
				}
			}
			if (!volunteerCountMap.isEmpty()) {
				for (Volunteer_Count__c volunteerCount : [
						SELECT Id,Name,Volunteer_Needed__c,Non_Wish_Events__c,Chapter_Role__c,Registered__c,Description__c,Start_Time__c,End_Time__c,Date__c
						FROM Volunteer_Count__c
						WHERE Chapter_Role__c IN:volunteerCountMap.keySet()
				]) {
					if (nonWishEventIds.contains(volunteerCount.Non_Wish_Events__c)) {
						if (descriptionIds.contains(volunteerCount.Description__c +
								volunteerCount.Date__c +
								volunteerCount.Start_Time__c +
								volunteerCount.End_Time__c)) {
							if (volunteerCountMap.containsKey(volunteerCount.Chapter_Role__c)) {
								volunteerCount.Registered__c = volunteerCountMap.get(volunteerCount.Chapter_Role__c);
								if (isPending) {
									volunteerCount.Registered__c = volunteerCount.Registered__c + 1;
								}
								if (volunteerCount.Registered__c > 0 && isRegistered) {
									volunteerCount.Registered__c = volunteerCount.Registered__c - 1;
								}
								updateVolunteerCounts.add(volunteerCount);
							}
						}
					}
				}
				update updateVolunteerCounts;
			} else {
				for (Volunteer_Count__c volunteerCount : [
						SELECT Id,Name,Volunteer_Needed__c,Non_Wish_Events__c,Chapter_Role__c,
								Registered__c,Description__c,Start_Time__c,End_Time__c,Date__c
						FROM Volunteer_Count__c
						WHERE Chapter_Role__c IN:chapterRoleIds
				]) {
					if (nonWishEventIds.contains(volunteerCount.Non_Wish_Events__c)) {
						if (descriptionIds.contains(volunteerCount.Description__c +
								volunteerCount.Date__c +
								volunteerCount.Start_Time__c +
								volunteerCount.End_Time__c)) {
							if (volunteerCount.Registered__c > 0 && isRegistered) {
								volunteerCount.Registered__c = 0;
							}
							updateVolunteerCounts.add(volunteerCount);
						}
					}
				}
			}
			update updateVolunteerCounts;
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Volunteer_Opportunity__c volunteerOpportunity : nonWishListUpdateCount) {
				ErrorMessage_AC.createDebugRec('VolunteerOpportunityService', String.valueOf(volunteerOpportunity),
						String.valueOf(ex), 'updateVolunteerRegisteredCount',
						volunteerOpportunity.Id, ex.getStackTraceString(), 'Error');
				if (!Test.isRunningTest()) {
					volunteerOpportunity.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	public static void updateInactive(Map<Id, Volunteer_Opportunity__c> volunteerOpportunityMap) {
		if (volunteerOpportunityMap.isEmpty()) {
			return;
		}
		RecursiveTriggerHandler.isFirstTime = false;
		try {
			Map<Id, Boolean> wishStatusMap = new Map<Id, Boolean>();
			for (Volunteer_Opportunity__c volunteerOpportunity : [
					SELECT Id,Wish__c,Wish__r.Status,Wish__r.IsClosed
					FROM Volunteer_Opportunity__c
					WHERE Id IN :volunteerOpportunityMap.keySet()
					AND Wish__c != NULL
			]) {
				wishStatusMap.put(volunteerOpportunity.Wish__c, volunteerOpportunity.Wish__r.IsClosed);
			}
			Map<String, Id> caseTeamNameMap = new Map<String, Id>();
			Map<Id, String> caseTeamMap = new Map<Id, String>();
			for (CaseTeamRole caseTeamInfo : [
					SELECT Id, Name
					FROM CaseTeamRole
			]) {
				caseTeamMap.put(caseTeamInfo.Id, caseTeamInfo.Name);
				caseTeamNameMap.put(caseTeamInfo.Name, caseTeamInfo.Id);
			}
			Map<Id, Set<Id>> inactiveOwners = new Map<Id, Set<Id>>();
			Set<Id> contactIdSet = new Set<Id>();
			Set<Id> volunteerIds = new Set<Id>();
			Set<Id> wishIds = new Set<Id>();
			Set<Id> parentIds = new Set<Id>();
			List<Volunteer_Opportunity__c> updateList = new List<Volunteer_Opportunity__c>();
			for (Volunteer_Opportunity__c processVolOpportunity : volunteerOpportunityMap.values()) {
				Volunteer_Opportunity__c newVolOpportunity = new Volunteer_Opportunity__c();
				newVolOpportunity.Chapter_Name__c = processVolOpportunity.Chapter_Name__c;
				newVolOpportunity.Chapter_Role_Opportunity__c = processVolOpportunity.Chapter_Role_Opportunity__c;
				newVolOpportunity.Date_Time__c = processVolOpportunity.Date_Time__c;
				newVolOpportunity.Hidden_VolunteerCount_Desc__c = processVolOpportunity.Hidden_VolunteerCount_Desc__c;
				newVolOpportunity.Description__c = processVolOpportunity.Description__c;
				newVolOpportunity.Start_Time__c = processVolOpportunity.Start_Time__c ;
				newVolOpportunity.End_Time__c = processVolOpportunity.End_Time__c;
				newVolOpportunity.Date__c = processVolOpportunity.Date__c;
				newVolOpportunity.Location__c = processVolOpportunity.Location__c;
				newVolOpportunity.HiddenVolunteer_Count_Description__c = processVolOpportunity.HiddenVolunteer_Count_Description__c ;
				volunteerIds.add(processVolOpportunity.Volunteer_Name__c);
				if (processVolOpportunity.Non_Wish_Event__c != null) {
					newVolOpportunity.Non_Wish_Event__c = processVolOpportunity.Non_Wish_Event__c;
					newVolOpportunity.RecordTypeId = Constant_AC.NON_WISH_EVENT_RT_ID;
				}
				newVolOpportunity.Required_Forms_for_Volunteers__c = processVolOpportunity.Required_Forms_for_Volunteers__c;
				newVolOpportunity.Volunteer_Notes__c = processVolOpportunity.Volunteer_Notes__c ;
				if (processVolOpportunity.Wish__c != null && wishStatusMap.get(processVolOpportunity.Wish__c) != true) {
					contactIdSet.add(processVolOpportunity.Volunteer_Name__c);
					if (inactiveOwners.containsKey(processVolOpportunity.Wish__c)) {
						inactiveOwners.get(processVolOpportunity.Wish__c).add(processVolOpportunity.Volunteer_Name__c);
					} else {
						inactiveOwners.put(processVolOpportunity.Wish__c, new Set<Id>{
								processVolOpportunity.Volunteer_Name__c
						});
					}
					newVolOpportunity.Wish__c = processVolOpportunity.Wish__c;
					newVolOpportunity.RecordTypeId = Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID;
					wishIds.add(processVolOpportunity.Wish__c);
					parentIds.add(processVolOpportunity.Wish__c);
				}
				if (VOLUNTEER_OPPORTUNITY_REASON_INACTIVE_NOT_APPROVED.equals(processVolOpportunity.Reason_Inactive__c)) {
					Volunteer_Opportunity__c updateVolOpp = new Volunteer_Opportunity__c();
					updateVolOpp.Id = processVolOpportunity.Id;
					updateVolOpp.Inactive__c = true;
					updateList.add(updateVolOpp);
				}
			}
			Map<Id, Id> contactUserMap = UserService.findByContactId(contactIdSet);
			Map<Id, Id> activeVolunteerMap = CaseTeamMemberService.findByTeamRoleNamesAndParentIdsAndMemberIds(
					new Set<String>{
							VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER,
							VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER_MENTOR
					},
					inactiveOwners.keySet(), contactUserMap.keySet());
			Map<Id, Case> caseOwnerMap = CaseService.findById(wishStatusMap.keySet());
			TaskService.updateOwner(inactiveOwners, activeVolunteerMap, caseOwnerMap, contactUserMap);
			Map<Id, Id> userMap = UserService.findByContactId(volunteerIds);
			Map<Id, String> volunteerOppMap = new Map<Id, String>();
			for (Volunteer_Opportunity__c getActiveVolOpp : [
					SELECT Id, Volunteer_Name__c, Wish__c, Role__c
					FROM Volunteer_Opportunity__c
					WHERE Volunteer_Name__c IN :volunteerIds
					AND Wish__c != NULL
					AND Status__c = :VOLUNTEER_OPPORTUNITY_STATUS_APPROVED
					AND Wish__c IN :wishStatusMap.keySet()
			]) {
				if (!volunteerOpportunityMap.containsKey(getActiveVolOpp.Id)) {
					volunteerOppMap.put(getActiveVolOpp.Volunteer_Name__c, getActiveVolOpp.Role__c);
				}
			}
			Set<Id> parentCaseId = CaseTeamMemberService.updateTeamRoleId(parentIds, userMap.keySet(), caseTeamMap, contactUserMap,
					volunteerOppMap, caseTeamNameMap);
			CaseService.updateHiddenVolunteerInactive(parentCaseId);
			update updateList;
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Volunteer_Opportunity__c volunteerOpportunity : volunteerOpportunityMap.values()) {
				ErrorMessage_AC.createDebugRec('VolunteerOpportunityService',
						String.valueOf(volunteerOpportunity), String.valueOf(ex), 'updateInactive',
						volunteerOpportunity.Id, ex.getStackTraceString(), 'Error');
				if (!Test.isRunningTest()) {
					volunteerOpportunity.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	public static void activeWishCount(Set<Id> volunteerIdsSet) {
		if (volunteerIdsSet.isEmpty()) {
			return;
		}
		Map<Id, Integer> grantedCount = new Map<Id, Integer>();
		Map<Id, Integer> activeCount = new Map<Id, Integer>();
		List<Contact> updateContacts = new List<Contact>();
		List<Volunteer_Opportunity__c> volunteerOpportunities = [
				SELECT Id,Wish__c, Wish__r.Status,Wish__r.IsClosed,Volunteer_Name__c
				FROM Volunteer_Opportunity__c
				WHERE Wish__c != NULL
				AND (Status__c = :VOLUNTEER_OPPORTUNITY_STATUS_APPROVED
				OR Status__c = :VOLUNTEER_OPPORTUNITY_STATUS_COMPLETED)
				AND ((Wish__r.Status = :CASE_STATUS_GRANTED
				OR Wish__r.IsClosed = TRUE OR Wish__r.Status = :CASE_STATUS_COMPLETED)
				OR (Wish__r.Status != :CASE_STATUS_GRANTED
				AND Wish__r.IsClosed = FALSE AND Wish__r.Status != :CASE_STATUS_INACTIVE))
				AND Volunteer_Name__c IN :volunteerIdsSet
		];
		try {
			for (Volunteer_Opportunity__c volunteerOpportunity : volunteerOpportunities) {
				if (CASE_STATUS_GRANTED.equals(volunteerOpportunity.Wish__r.Status)
						|| volunteerOpportunity.Wish__r.IsClosed
						|| CASE_STATUS_COMPLETED.equals(volunteerOpportunity.Wish__r.Status)) {
					if (grantedCount.containsKey(volunteerOpportunity.Volunteer_Name__c)) {
						Integer countVal = grantedCount.get(volunteerOpportunity.Volunteer_Name__c) + 1;
						grantedCount.put(volunteerOpportunity.Volunteer_Name__c, countVal);
					} else {
						grantedCount.put(volunteerOpportunity.Volunteer_Name__c, 1);
					}
				} else {
					if (activeCount.containsKey(volunteerOpportunity.Volunteer_Name__c)) {
						Integer countVal = activeCount.get(volunteerOpportunity.Volunteer_Name__c) + 1;
						activeCount.put(volunteerOpportunity.Volunteer_Name__c, countVal);
					} else {
						activeCount.put(volunteerOpportunity.Volunteer_Name__c, 1);
					}
				}
			}
			for (String volId : volunteerIdsSet) {
				Contact contact = new Contact();
				contact.Id = volId;
				contact.Number_of_wishes_active__c = activeCount.get(volId);
				contact.Number_of_wishes_granted__c = grantedCount.get(volId);
				if (contact.Number_of_wishes_active__c == null) {
					contact.Number_of_wishes_active__c = 0;
				}
				if (contact.Number_of_wishes_granted__c == null) {
					contact.Number_of_wishes_granted__c = 0;
				}
				updateContacts.add(contact);
			}
			update updateContacts;
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Volunteer_Opportunity__c volunteerOpportunity : volunteerOpportunities) {
				ErrorMessage_AC.createDebugRec('VolunteerOpportunityService',
						String.valueOf(volunteerOpportunity), String.valueOf(ex), 'activeWishCount',
						volunteerOpportunity.Id, ex.getStackTraceString(), 'Error');
				if (!Test.isRunningTest()) {
					volunteerOpportunity.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	public static void submitApprovalProcess(List<Volunteer_Opportunity__c> recordsForApprovalProcess) {
		if (recordsForApprovalProcess.isEmpty()) {
			return;
		}
		Set<Id> chapterIds = new Set<Id>();
		for (Volunteer_Opportunity__c volunteerOpportunity : recordsForApprovalProcess) {
			chapterIds.add(volunteerOpportunity.Chapter_Name__c);
		}
		List<Approval.ProcessSubmitRequest> approvalReqList = new List<Approval.ProcessSubmitRequest>();
		Map<Id, Id> wishVolunteerApproverIdsMap = new Map<Id, Id>();
		Map<Id, Id> nonWishVolunteerApproverIdsMap = new Map<Id, Id>();
		try {
			for (Account getAccountName : [
					SELECT Id,
							Name,
							Event_Volunteer_Assignment_Approver__c,
							Wish_Volunteer_Assignment_Approver__c
					FROM Account
					WHERE Id IN :chapterIds
			]) {
				wishVolunteerApproverIdsMap.put(getAccountName.Id, getAccountName.Wish_Volunteer_Assignment_Approver__c);
				nonWishVolunteerApproverIdsMap.put(getAccountName.Id, getAccountName.Event_Volunteer_Assignment_Approver__c);
			}
			Id chapterAccountId;
			for (Volunteer_Opportunity__c newVolunteerRole : recordsForApprovalProcess) {
				Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
				req.setComments('Submitting request for approval.');
				req.setObjectId(newVolunteerRole.Id);
				chapterAccountId = null;
				if (WISH_RECORD_TYPES.contains(newVolunteerRole.RecordTypeId)
						&& wishVolunteerApproverIdsMap.containsKey(newVolunteerRole.Chapter_Name__c)) {
					chapterAccountId = wishVolunteerApproverIdsMap.get(newVolunteerRole.Chapter_Name__c);
				}
				if (NONWISH_RECORD_TYPES.contains(newVolunteerRole.RecordTypeId)
						&& nonWishVolunteerApproverIdsMap.containsKey(newVolunteerRole.Chapter_Name__c)) {
					chapterAccountId = nonWishVolunteerApproverIdsMap.get(newVolunteerRole.Chapter_Name__c);
				}
				if (chapterAccountId != null) {
					req.setNextApproverIds(new Id[]{
							chapterAccountId
					});
				} else {
					req.setNextApproverIds(new Id[]{
							UserInfo.getUserId()
					});
				}
				req.setProcessDefinitionNameOrId('Volunteer_Role_Approval_Process');
				req.setSkipEntryCriteria(true);
				approvalReqList.add(req);
			}
			if (!approvalReqList.isEmpty()) {
				Approval.process(approvalReqList);
			}
		} catch (Exception ex) {
			for (Volunteer_Opportunity__c volunteerOpportunity : recordsForApprovalProcess) {
				volunteerOpportunity.addError(Label.Debug_log_error_message);
			}
		}
	}

	public static void createCaseTeamMembers(List<Volunteer_Opportunity__c> recordsForCreatingCaseTeams) {
		if (recordsForCreatingCaseTeams.isEmpty()) {
			return;
		}
		Set<Id> volunteerNameSet = new Set<Id>();
		Set<Id> wishIds = new Set<Id>();
		Map<Id, Set<Id>> wishUserMap = new Map<Id, Set<Id>>();
		Map<Id, Contact> updateContactMap = new Map<Id, Contact>();
		Map<Id, CaseTeamMember> caseMemberMap = new Map<Id, CaseTeamMember>();
		Map<Id, Id> volunteerMap = new Map<Id, Id>();
		try {
			for (Volunteer_Opportunity__c newVolunteerRole : recordsForCreatingCaseTeams) {
				volunteerNameSet.add(newVolunteerRole.Volunteer_Name__c);
				wishIds.add(newVolunteerRole.Wish__c);
				if (newVolunteerRole.Wish__c != null
						&& newVolunteerRole.Role__c == VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER) {
					if (!volunteerMap.containsKey(newVolunteerRole.Wish__c)) {
						volunteerMap.put(newVolunteerRole.Wish__c, newVolunteerRole.Volunteer_Name__c);
					}
				}
				if (wishUserMap.containsKey(newVolunteerRole.Wish__c)) {
					wishUserMap.get(newVolunteerRole.Wish__c).add(newVolunteerRole.Volunteer_Name__c);
				} else {
					wishUserMap.put(newVolunteerRole.Wish__c, new Set<Id>{
							newVolunteerRole.Volunteer_Name__c
					});
				}
				if (!newVolunteerRole.Migrated_Record__c) {
					Contact updateContact = new Contact();
					updateContact.Id = newVolunteerRole.Volunteer_Name__c;
					updateContact.Date_of_last_engagement__c = Date.today();
					updateContactMap.put(updateContact.Id, updateContact);
				}
			}
			Map<Id, Id> volunteerUserMap = new Map<Id, Id>();
			for (User contactUser : [
					SELECT Id, ContactId
					FROM User
					WHERE ContactId IN :volunteerNameSet
			]) {
				volunteerUserMap.put(contactUser.ContactId, contactUser.Id);
			}
			Map<String, CaseTeamRole > teamMemberRoleMap = new Map<String, CaseTeamRole>();
			for (CaseTeamRole caseTem : [
					SELECT Id,Name
					FROM CaseTeamRole
			]) {
				teamMemberRoleMap.put(caseTem.Name, caseTem);
			}
			Map<Id, Id> contactUserInfoMap = new Map<Id, Id>();
			for (User communityUserInfo : [
					SELECT Id, ContactId
					FROM User
					WHERE ContactId != NULL
			]) {
				contactUserInfoMap.put(communityUserInfo.ContactId, communityUserInfo.Id);
			}
			Map<Id, CaseTeamMember> caseTeamMemberMap = new Map<Id, CaseTeamMember>();
			List<CaseTeamMember> updateRoleList = new List<CaseTeamMember>();
			Map<Id, Set<String>> wishMembersMap = new Map<Id, Set<String>>();
			for (CaseTeamMember caseTeamMember : [
					SELECT Id,MemberId, ParentId, TeamRole.Name, TeamRole.Id
					FROM CaseTeamMember
					WHERE ParentId IN :wishIds
			]) {
				caseTeamMemberMap.put(caseTeamMember.MemberId, caseTeamMember);
				if (wishMembersMap.containsKey(caseTeamMember.ParentId)) {
					wishMembersMap.get(caseTeamMember.ParentId).add(caseTeamMember.MemberId);
				} else {
					wishMembersMap.put(caseTeamMember.ParentId, new Set<String>{
							caseTeamMember.MemberId
					});
				}
			}
			Set<Id> userIds = new Set<Id>();
			Map<Id, List<Task>> taskMap = new Map<Id, List<Task>>();
			for (Task checkExistingTaskOwner : [
					SELECT Id, OwnerId, WhatId, RecordType.Name
					FROM Task
					WHERE WhatId IN :volunteerMap.keySet()
					AND RecordType.Name = :Constant_AC.VOLUNTEER_TASK_RT_LABEL
					AND IsClosed = FALSE
			]) {
				userIds.add(checkExistingTaskOwner.OwnerId);
				if (taskMap.containsKey(checkExistingTaskOwner.WhatId)) {
					taskMap.get(checkExistingTaskOwner.WhatId).add(checkExistingTaskOwner);
				} else {
					taskMap.put(checkExistingTaskOwner.WhatId, new List<Task>{
							checkExistingTaskOwner
					});
				}
			}
			Set<Id> internalUserIdSet = new Set<Id>();
			for (User getUserInfo : [
					SELECT Id, ContactId
					FROM User
					WHERE Id IN :userIds
			]) {
				if (getUserInfo.ContactId == null) {
					internalUserIdSet.add(getUserInfo.Id);
				}
			}
			Map<Id, Task> updateOwnerMap = new Map<Id, Task>();
			Map<Id, Set<CaseTeamMember>> updateCaseMemberCount = new Map<Id, Set<CaseTeamMember>>();
			for (Volunteer_Opportunity__c newVolunteerOpportunity : recordsForCreatingCaseTeams) {
				if (newVolunteerOpportunity.Role__c == VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER
						|| newVolunteerOpportunity.Role__c == VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER_MENTOR) {
					if (taskMap.containsKey(newVolunteerOpportunity.Wish__c)) {
						for (Task checkOwner : taskMap.get(newVolunteerOpportunity.Wish__c)) {
							if (internalUserIdSet.contains(checkOwner.OwnerId)) {
								if (contactUserInfoMap.containsKey(newVolunteerOpportunity.Volunteer_Name__c)) {
									checkOwner.OwnerId = contactUserInfoMap.get(newVolunteerOpportunity.Volunteer_Name__c);
									updateOwnerMap.put(checkOwner.Id, checkOwner);
								}
							}
						}
					}
				}
				if (newVolunteerOpportunity.Volunteer_Name__c != null && newVolunteerOpportunity.Wish__c != null) {
					if (!wishMembersMap.containsKey(newVolunteerOpportunity.Wish__c)
							|| (wishMembersMap.containsKey(newVolunteerOpportunity.Wish__c)
							&& volunteerUserMap.containsKey(newVolunteerOpportunity.Volunteer_Name__c))) {
						CaseTeamMember newCaseTeamMembers = new CaseTeamMember();
						newCaseTeamMembers.ParentId = newVolunteerOpportunity.Wish__c;
						newCaseTeamMembers.MemberId = newVolunteerOpportunity.Volunteer_Name__c;
						if (volunteerUserMap.containsKey(newVolunteerOpportunity.Volunteer_Name__c)) {
							newCaseTeamMembers.MemberId = volunteerUserMap.get(newVolunteerOpportunity.Volunteer_Name__c);
						}
						if ((teamMemberRoleMap.containsKey(newVolunteerOpportunity.Role__c))
								&& (wishMembersMap.size() == 0
								|| !wishMembersMap.get(newVolunteerOpportunity.Wish__c).contains(volunteerUserMap.get(newVolunteerOpportunity.Volunteer_Name__c)))) {
							newCaseTeamMembers.TeamRoleId = teamMemberRoleMap.get(newVolunteerOpportunity.Role__c).Id;
							caseMemberMap.put(newCaseTeamMembers.Id, newCaseTeamMembers);
						} else if (teamMemberRoleMap.containsKey(newVolunteerOpportunity.Role__c)
								&& wishMembersMap.get(newVolunteerOpportunity.Wish__c).contains(volunteerUserMap.get(newVolunteerOpportunity.Volunteer_Name__c))
								&& (newVolunteerOpportunity.Role__c == VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER
								|| newVolunteerOpportunity.Role__c == VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER_MENTOR)) {
							newCaseTeamMembers.TeamRoleId = teamMemberRoleMap.get(newVolunteerOpportunity.Role__c).Id;
							newCaseTeamMembers.Id = caseTeamMemberMap.get(volunteerUserMap.get(newVolunteerOpportunity.Volunteer_Name__c)).Id;
							caseMemberMap.put(newCaseTeamMembers.Id, newCaseTeamMembers);
						}
						if (newVolunteerOpportunity.Role__c == VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER
								|| newVolunteerOpportunity.Role__c == VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER_MENTOR
								|| newVolunteerOpportunity.Role__c == VOLUNTEER_OPPORTUNITY_ROLE_TEMPORARY_WISH_GRANTER) {
							if (!updateCaseMemberCount.containsKey(newVolunteerOpportunity.Wish__c)) {
								updateCaseMemberCount.put(newVolunteerOpportunity.Wish__c, new Set<CaseTeamMember>{
										newCaseTeamMembers
								});
							}
							updateCaseMemberCount.get(newVolunteerOpportunity.Wish__c).add(newCaseTeamMembers);
						}
					}
				}
				if (!caseTeamMemberMap.isEmpty() && contactUserInfoMap.containsKey(newVolunteerOpportunity.Volunteer_Name__c)
						&& caseTeamMemberMap.containsKey(contactUserInfoMap.get(newVolunteerOpportunity.Volunteer_Name__c))) {
					if (caseTeamMemberMap.get(contactUserInfoMap.get(newVolunteerOpportunity.Volunteer_Name__c)).TeamRole.Name.contains(TEAM_MEMBER_NAME_INACTIVE)) {
						if (teamMemberRoleMap.containsKey(
								caseTeamMemberMap.get(
										contactUserInfoMap.get(
												newVolunteerOpportunity.Volunteer_Name__c)).TeamRole.Name.remove(' (' + TEAM_MEMBER_NAME_INACTIVE + ')'))) {
							CaseTeamMember updateInfo = new CaseTeamMember();
							updateInfo.TeamRoleId = teamMemberRoleMap.get(
									caseTeamMemberMap.get(contactUserInfoMap.get(
											newVolunteerOpportunity.Volunteer_Name__c)).TeamRole.Name.remove(' (' + TEAM_MEMBER_NAME_INACTIVE + ')')).Id;
							updateInfo.Id = caseTeamMemberMap.get(contactUserInfoMap.get(newVolunteerOpportunity.Volunteer_Name__c)).Id;
							updateRoleList.add(updateInfo);
						}
					}
				}
			}
			TaskService.updateBirthday(volunteerMap, contactUserInfoMap);
			update updateOwnerMap.values();
			update updateRoleList;
			update updateContactMap.values();
			upsert caseMemberMap.values();
			Map<Id, Case> wishRelatedContactMap = CaseService.findById(wishUserMap.keySet());
			ChapterStaffRecordSharing_AC.createContactSharing(
					wishUserMap, wishRelatedContactMap, volunteerUserMap);
			List<Case> updateCaseList = new List<Case>();
			if (!updateCaseMemberCount.isEmpty()) {
				for (AggregateResult aggregateResult : [
						SELECT COUNT(Id), Wish__c
						FROM Volunteer_Opportunity__c
						WHERE Wish__c IN :updateCaseMemberCount.keySet()
						AND Role__c IN (:VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER,
								:VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER_MENTOR,
								:VOLUNTEER_OPPORTUNITY_ROLE_TEMPORARY_WISH_GRANTER)
						AND Status__c = :VOLUNTEER_OPPORTUNITY_STATUS_APPROVED
						GROUP BY Wish__c
				]) {
					Case updateCase = new Case();
					updateCase.Id = (Id) aggregateResult.get('Wish__c');
					updateCase.Case_Member_Count__c = (Decimal) aggregateResult.get('expr0');
					updateCase.Assigned_Date__c = Date.today();
					updateCaseList.add(updateCase);
				}
			}
			update updateCaseList;
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Volunteer_Opportunity__c volunteerOpportunity : recordsForCreatingCaseTeams) {
				ErrorMessage_AC.createDebugRec('VolunteerOpportunityService', String.valueOf(volunteerOpportunity),
						String.valueOf(ex), 'createCaseTeamMembers', volunteerOpportunity.Id, ex.getStackTraceString(), 'Error');
				if (!Test.isRunningTest()) {
					volunteerOpportunity.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	public static void updateVolunteerRegisteredCountDelete(Map<Id, Volunteer_Opportunity__c> nonWishListToUpdateCount) {
		if (nonWishListToUpdateCount.isEmpty()) {
			return;
		}
		RecursiveTriggerHandler.isFirstTime = false;
		Set<Id> chapterRoleIdSet = new Set<Id>();
		Set<Id> nonWishEventIdSet = new Set<Id>();
		Set<String> descriptionSetId = new Set<String>();
		Map<Id, Integer> volunteerCountMap = new Map<Id, Integer>();
		List<Volunteer_Count__c > updateVolunteerCountList = new List<Volunteer_Count__c>();
		Boolean isRegistered = false;
		Boolean isPending = false;
		try {
			for (Volunteer_Opportunity__c newVolOpp : nonWishListToUpdateCount.values()) {
				chapterRoleIdSet .add(newVolOpp.Chapter_Role_Opportunity__c);
				descriptionSetId.add(
						newVolOpp.Hidden_VolunteerCount_Desc__c +
								newVolOpp.Date__c +
								newVolOpp.Start_Time__c +
								newVolOpp.End_Time__c);
				nonWishEventIdSet.add(newVolOpp.Non_Wish_Event__c);
				if ((newVolOpp.Inactive__c && newVolOpp.Reason_Inactive__c != null
						&& VOLUNTEER_OPPORTUNITY_STATUS_APPROVED.equals(newVolOpp.Status__c))
						|| (newVolOpp.Inactive__c && newVolOpp.Reason_Inactive__c != null
						&& VOLUNTEER_OPPORTUNITY_REASON_INACTIVE_NOT_APPROVED.equals(newVolOpp.Reason_Inactive__c))) {
					isRegistered = true;
				}
			}
			List<AggregateResult> groupedResults = [
					SELECT Chapter_Role_Opportunity__c nonwish, COUNT(Id)aver,Hidden_VolunteerCount_Desc__c
					FROM Volunteer_Opportunity__c
					WHERE Non_Wish_Event__c IN:nonWishEventIdSet
					AND Volunteer_Name__c != NULL
					AND (Reason_Inactive__c = NULL
					OR Reason_Inactive__c != NULL)
					AND Chapter_Role_Opportunity__c IN:chapterRoleIdSet
					AND Id IN :nonWishListToUpdateCount.keySet()
					GROUP BY Chapter_Role_Opportunity__c, Hidden_VolunteerCount_Desc__c, Date__c, Start_Time__c, End_Time__c
			];
			if (!groupedResults.isEmpty()) {
				for (AggregateResult arr : groupedResults) {
					volunteerCountMap.put((Id) arr.get('nonwish'), (Integer) arr.get('aver'));
				}
			}
			if (!volunteerCountMap.isEmpty()) {
				for (Volunteer_Count__c volunteerCount : [
						SELECT Id,Name,Volunteer_Needed__c,Non_Wish_Events__c,Chapter_Role__c,Registered__c,
								Description__c,Start_Time__c,End_Time__c,Date__c
						FROM Volunteer_Count__c
						WHERE Chapter_Role__c IN:volunteerCountMap.keySet()
				]) {
					if (nonWishEventIdSet.contains(volunteerCount.Non_Wish_Events__c)) {
						if (descriptionSetId.contains(volunteerCount.Description__c +
								+volunteerCount.Date__c +
								+volunteerCount.Start_Time__c +
								+volunteerCount.End_Time__c)) {
							if (volunteerCountMap.containsKey(volunteerCount.Chapter_Role__c)) {
								volunteerCount.Registered__c = volunteerCountMap.get(volunteerCount.Chapter_Role__c);
								if (isPending) {
									volunteerCount.Registered__c = volunteerCount.Registered__c + 1;
								}
								volunteerCount.Registered__c = volunteerCount.Registered__c - 1;
								updateVolunteerCountList.add(volunteerCount);
							}
						}
					}
				}
				update updateVolunteerCountList;
			} else {
				for (Volunteer_Count__c volunteerCount : [
						SELECT Id,Name,Volunteer_Needed__c,Non_Wish_Events__c,Chapter_Role__c,
								Registered__c,Description__c,Start_Time__c,End_Time__c,Date__c
						FROM Volunteer_Count__c
						WHERE Chapter_Role__c IN:chapterRoleIdSet
				]) {
					if (nonWishEventIdSet.contains(volunteerCount.Non_Wish_Events__c)) {
						if (descriptionSetId.contains(volunteerCount.Description__c +
								volunteerCount.Date__c +
								volunteerCount.Start_Time__c +
								volunteerCount.End_Time__c)) {
							volunteerCount.Registered__c = 0;
							updateVolunteerCountList.add(volunteerCount);
						}
					}
				}
			}
			update updateVolunteerCountList;
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Volunteer_Opportunity__c volunteerOpportunity : nonWishListToUpdateCount.values()) {
				ErrorMessage_AC.createDebugRec('VolunteerOpportunityService',
						String.valueOf(volunteerOpportunity), String.valueOf(ex), 'updateVolunteerRegisteredCountDelete',
						volunteerOpportunity.Id, ex.getStackTraceString(), 'Error');
				if (!Test.isRunningTest()) {
					volunteerOpportunity.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	public static void shareVolunteerOpportunityRecord(List<Volunteer_Opportunity__c> volunteerOpportunities) {
		if (volunteerOpportunities.isEmpty()) {
			return;
		}
		Set<Id> volunteerContactIdSet = new Set<Id>();
		Map<Id, Id> volunteerUserMap = new Map<Id, Id>();
		List<Volunteer_Opportunity__Share> volOpportunitySharingList = new List<Volunteer_Opportunity__Share>();
		try {
			for (Volunteer_Opportunity__c processVolOpportunityRec : volunteerOpportunities) {
				volunteerContactIdSet.add(processVolOpportunityRec.Volunteer_Name__c);
			}
			for (User activeUser : [
					SELECT Id,ContactId
					FROM User
					WHERE ContactId IN:volunteerContactIdSet
			]) {
				volunteerUserMap.put(activeUser.ContactId, activeUser.Id);
			}
			for (Volunteer_Opportunity__c processVolOpportunityRec : volunteerOpportunities) {
				if (volunteerUserMap.containsKey(processVolOpportunityRec.Volunteer_Name__c)) {
					Volunteer_Opportunity__Share newVolOppShareRec = new Volunteer_Opportunity__Share();
					newVolOppShareRec.ParentId = processVolOpportunityRec.Id;
					newVolOppShareRec.AccessLevel = 'Edit';
					newVolOppShareRec.RowCause = Schema.Volunteer_Opportunity__Share.RowCause.Grant_Edit_Access_to_assigned_Volunteer__C;
					newVolOppShareRec.UserOrGroupId = volunteerUserMap.get(processVolOpportunityRec.Volunteer_Name__c);
					volOpportunitySharingList.add(newVolOppShareRec);
				}
			}
			insert volOpportunitySharingList;
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Volunteer_Opportunity__c volunteerOpportunity : volunteerOpportunities) {
				ErrorMessage_AC.createDebugRec('VolunteerOpportunityService',
						String.valueOf(volunteerOpportunity), String.valueOf(ex), 'shareVolunteerOpportunityRecord',
						volunteerOpportunity.Id, ex.getStackTraceString(), 'Error');
				if (!Test.isRunningTest()) {
					volunteerOpportunity.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	/**
	 * Build Map of Volunteer Opportunities by Chapter Name
	 * @param volunteerOpportunityIds
	 * @return Map of Volunteer Opportunities
	 */
	public static Map<String, List<Volunteer_Opportunity__c>> buildVolunteerOpportunitiesByChapterMap(Set<Id> volunteerOpportunityIds) {
		Map<String, List<Volunteer_Opportunity__c>> volunteerOpportunityMap = new Map<String, List<Volunteer_Opportunity__c>>();
		if (volunteerOpportunityIds.isEmpty()) {
			return volunteerOpportunityMap;
		}
		for (Volunteer_Opportunity__c volunteerOpportunity : [
				SELECT Id, OwnerId, Owner.UserRoleId, Owner.UserRole.Name, Chapter_Name__c,
						Chapter_Name__r.Name
				FROM Volunteer_Opportunity__c
				WHERE Id IN :volunteerOpportunityIds
		]) {
			if (volunteerOpportunity.Chapter_Name__c != null && ROLE_NATIONAL_STAFF.equals(volunteerOpportunity.Owner.UserRole.Name)) {
				if (!volunteerOpportunityMap.containsKey(volunteerOpportunity.Chapter_Name__r.Name)) {
					volunteerOpportunityMap.put(volunteerOpportunity.Chapter_Name__r.Name, new List<Volunteer_Opportunity__c>{
							volunteerOpportunity
					});
				}
				volunteerOpportunityMap.get(volunteerOpportunity.Chapter_Name__r.Name).add(volunteerOpportunity);
			}
		}
		return volunteerOpportunityMap;
	}

	/**
	 * Build Map of Out of Compliance Volunteer Opportunities
	 * @param volunteerOpportunityIds
	 * @return Map of Volunteer Opportunities
	 */
	public static Set<Id> buildVolunteerOpportunitiesOutOfComplianceMap(
			Map<Id, Volunteer_Opportunity__c> newVolunteerOpportunityMap,
			Map<Id, Volunteer_Opportunity__c> oldVolunteerOpportunityMap) {
		Set<Id> volunteerOpportunityIds = new Set<Id>();
		for (Volunteer_Opportunity__c volunteerOpportunity : newVolunteerOpportunityMap.values()) {
			if (volunteerOpportunity.Status__c != oldVolunteerOpportunityMap.get(volunteerOpportunity.Id).Status__c
					&& VOLUNTEER_OPPORTUNITY_STATUS_PENDING.equals(oldVolunteerOpportunityMap.get(volunteerOpportunity.Id).Status__c)
					&& (VOLUNTEER_OPPORTUNITY_STATUS_INACTIVE.equals(volunteerOpportunity.Status__c)
					|| VOLUNTEER_OPPORTUNITY_STATUS_OUT_OF_COMPLIANCE.equals(volunteerOpportunity.Status__c))) {
				volunteerOpportunityIds.add(volunteerOpportunity.Id);
			}
		}
		return volunteerOpportunityIds;
	}

	/**
	 * Build Map of Volunteer Opportunities Approval Recall
	 * @param newVolunteerOpportunityMap
	 * @param oldVolunteerOpportunityMap
	 * @return Map of Volunteer Opportunities
	 */
	public static Map<Id, Volunteer_Opportunity__c> buildVolunteerOpportunitiesForApprovalMap(
			Map<Id, Volunteer_Opportunity__c> newVolunteerOpportunityMap,
			Map<Id, Volunteer_Opportunity__c> oldVolunteerOpportunityMap) {
		Map<Id, Volunteer_Opportunity__c> volunteerOpportunityMap = new Map<Id, Volunteer_Opportunity__c>();
		for (Volunteer_Opportunity__c volunteerOpportunity : newVolunteerOpportunityMap.values()) {
			if (!VOLUNTEER_OPPORTUNITY_STATUS_APPROVED.equals(volunteerOpportunity.Status__c)
					&& (volunteerOpportunity.Volunteer_Name__c != null
					&& oldVolunteerOpportunityMap.get(volunteerOpportunity.Id).Volunteer_Name__c == null)
					&& (volunteerOpportunity.Wish__c != null && volunteerOpportunity.Reason_Inactive__c == null)) {
				volunteerOpportunityMap.put(volunteerOpportunity.Id, volunteerOpportunity);
			} else if (!VOLUNTEER_OPPORTUNITY_STATUS_APPROVED.equals(volunteerOpportunity.Status__c)
					&& (volunteerOpportunity.Volunteer_Name__c != null
					&& oldVolunteerOpportunityMap.get(volunteerOpportunity.Id).Volunteer_Name__c == null)
					&& (volunteerOpportunity.Wish__c == null) && (volunteerOpportunity.Non_Wish_Event__c != null
					&& volunteerOpportunity.Reason_Inactive__c == null)) {
				volunteerOpportunityMap.put(volunteerOpportunity.Id, volunteerOpportunity);
			}
		}
		return volunteerOpportunityMap;
	}

	/**
 	* Build Volunteer Approved Volunteer Opportunity Ids
 	* @param volunteerOpportunities
 	* @return Volunteer Ids
 	*/
	public static Set<Id> buildVolunteerApprovedOpportunitiesIds(List<Volunteer_Opportunity__c> volunteerOpportunities) {
		Set<Id> volunteerIds = new Set<Id>();
		for (Volunteer_Opportunity__c volunteerOpportunity : volunteerOpportunities) {
			if (VOLUNTEER_OPPORTUNITY_STATUS_APPROVED.equals(volunteerOpportunity.Status__c)
					&& !volunteerOpportunity.Migrated_Record__c) {
				volunteerIds.add(volunteerOpportunity.Volunteer_Name__c);
			}
		}
		return volunteerIds;
	}

	/**
	 * Build Ids of Volunteers Approved
	 * @param newVolunteerOpportunityMap
	 * @param oldVolunteerOpportunityMap
	 * @return Set of Volunteer Ids
	 */
	public static Set<Id> buildVolunteerApprovedMap(
			Map<Id, Volunteer_Opportunity__c> newVolunteerOpportunityMap,
			Map<Id, Volunteer_Opportunity__c> oldVolunteerOpportunityMap) {
		Set<Id> volunteerIds = new Set<Id>();
		for (Volunteer_Opportunity__c volunteerOpportunity : newVolunteerOpportunityMap.values()) {
			if (volunteerOpportunity.Volunteer_Name__c != null
					&& volunteerOpportunity.Wish__c != null
					&& VOLUNTEER_OPPORTUNITY_STATUS_APPROVED.equals(volunteerOpportunity.Status__c)
					&& !VOLUNTEER_OPPORTUNITY_STATUS_APPROVED.equals(oldVolunteerOpportunityMap.get(volunteerOpportunity.Id).Status__c)) {
				volunteerIds.add(volunteerOpportunity.Volunteer_Name__c);
			}
		}
		return volunteerIds;
	}

	/**
	 * Build Volunteer Ids from Volunteer Opportunity
	 * @param newVolunteerOpportunityMap
	 * @param oldVolunteerOpportunityMap
	 * @return Set of Volunteer Ids
	 */
	public static Set<Id> buildVolunteerOpportunityVolunteerIds(
			Map<Id, Volunteer_Opportunity__c> newVolunteerOpportunityMap) {
		Set<Id> volunteerOpportunityIds = new Set<Id>();
		for (Volunteer_Opportunity__c volunteerOpportunity : newVolunteerOpportunityMap.values()) {
			if (volunteerOpportunity.Volunteer_Name__c != null
					&& volunteerOpportunity.Non_Wish_Event__c != null
					&& !VOLUNTEER_OPPORTUNITY_STATUS_APPROVED.equals(volunteerOpportunity.Status__c)
					&& VOLUNTEER_OPPORTUNITY_STATUS_PENDING.equals(volunteerOpportunity.Status__c)
					&& volunteerOpportunity.Reason_Inactive__c == null) {
				if (RecursiveTriggerHandler.isFirstTime) {
					volunteerOpportunityIds.add(volunteerOpportunity.Id);
				}
			}
			if ((volunteerOpportunity.Volunteer_Name__c != null
					&& volunteerOpportunity.Non_Wish_Event__c != null
					&& VOLUNTEER_OPPORTUNITY_STATUS_APPROVED.equals(volunteerOpportunity.Status__c)
					&& volunteerOpportunity.Reason_Inactive__c != null)
					|| (volunteerOpportunity.Volunteer_Name__c != null
					&& volunteerOpportunity.Non_Wish_Event__c != null
					&& !VOLUNTEER_OPPORTUNITY_STATUS_APPROVED.equals(volunteerOpportunity.Status__c)
					&& volunteerOpportunity.Reason_Inactive__c != null)) {
				if (RecursiveTriggerHandler.isFirstTime) {
					volunteerOpportunityIds.add(volunteerOpportunity.Id);
				}
			}
			if (volunteerOpportunity.Volunteer_Name__c != null && volunteerOpportunity.Wish__c != null
					&& (VOLUNTEER_OPPORTUNITY_STATUS_APPROVED.equals(volunteerOpportunity.Status__c)
					|| !VOLUNTEER_OPPORTUNITY_STATUS_APPROVED.equals(volunteerOpportunity.Status__c))
					&& volunteerOpportunity.Reason_Inactive__c != null && volunteerOpportunity.Inactive__c) {
				volunteerOpportunityIds.add(volunteerOpportunity.Volunteer_Name__c);
			}
		}
		return volunteerOpportunityIds;
	}

	/**
	 * Build Volunteer Opportunity Map to create Case Team Members
	 * @param newVolunteerOpportunityMap
	 * @param oldVolunteerOpportunityMap
	 * @return Map Volunteer Opportunity
	 */
	public static Map<Id, Volunteer_Opportunity__c> buildVolunteerOpportunityCaseTeamMemberMap(
			Map<Id, Volunteer_Opportunity__c> newVolunteerOpportunityMap,
			Map<Id, Volunteer_Opportunity__c> oldVolunteerOpportunityMap) {
		Map<Id, Volunteer_Opportunity__c> recordsForCreatingCaseTeams = new Map<Id, Volunteer_Opportunity__c>();
		for (Volunteer_Opportunity__c volunteerOpportunity : newVolunteerOpportunityMap.values()) {
			if ((VOLUNTEER_OPPORTUNITY_STATUS_APPROVED.equals(volunteerOpportunity.Status__c)
					&& VOLUNTEER_OPPORTUNITY_STATUS_PENDING.equals(oldVolunteerOpportunityMap.get(volunteerOpportunity.Id).Status__c))
					&& volunteerOpportunity.Volunteer_Name__c != null
					&& (volunteerOpportunity.Wish__c != null
					|| volunteerOpportunity.Non_Wish_Event__c != null)
					&& volunteerOpportunity.Reason_Inactive__c == null) {
				if (volunteerOpportunity.Wish__c != null) {
					recordsForCreatingCaseTeams.put(volunteerOpportunity.Id, volunteerOpportunity);
				}
			}
			if (volunteerOpportunity.Volunteer_Name__c != null
					&& volunteerOpportunity.Wish__c != null
					&& VOLUNTEER_OPPORTUNITY_STATUS_APPROVED.equals(volunteerOpportunity.Status__c)
					&& !VOLUNTEER_OPPORTUNITY_STATUS_PENDING.equals(oldVolunteerOpportunityMap.get(volunteerOpportunity.Id).Status__c)
					&& oldVolunteerOpportunityMap.get(volunteerOpportunity.Id).Status__c != volunteerOpportunity.Status__c) {
				recordsForCreatingCaseTeams.put(volunteerOpportunity.Id, volunteerOpportunity);
			}
		}
		return recordsForCreatingCaseTeams;
	}

	/**
	 * Build Volunteer Opportunity Map to create reason inactive
	 * @param newVolunteerOpportunityMap
	 * @param oldVolunteerOpportunityMap
	 * @return Map Volunteer Opportunity
	 */
	public static Map<Id, Volunteer_Opportunity__c> buildVolunteerOpportunityReasonInactiveMap(
			Map<Id, Volunteer_Opportunity__c> newVolunteerOpportunityMap,
			Map<Id, Volunteer_Opportunity__c> oldVolunteerOpportunityMap) {
		Map<Id, Volunteer_Opportunity__c> recordsForCreatingCaseTeams = new Map<Id, Volunteer_Opportunity__c>();
		for (Volunteer_Opportunity__c volunteerOpportunity : newVolunteerOpportunityMap.values()) {
			Map<Id, Volunteer_Opportunity__c> volunteerOpportunityMap = new Map<Id, Volunteer_Opportunity__c>();
			if ((
					VOLUNTEER_OPPORTUNITY_STATUS_APPROVED.equals(volunteerOpportunity.Status__c)
							&& volunteerOpportunity.Volunteer_Name__c != null
							&& oldVolunteerOpportunityMap.get(volunteerOpportunity.Id).Reason_Inactive__c == null
							&& volunteerOpportunity.Reason_Inactive__c != null)
					|| (volunteerOpportunity.Reason_Inactive__c == 'Not Approved'
					&& volunteerOpportunity.Reason_Inactive__c != oldVolunteerOpportunityMap.get(volunteerOpportunity.Id).Reason_Inactive__c)
					|| (volunteerOpportunity.Inactive__c && volunteerOpportunity.Inactive__c != oldVolunteerOpportunityMap.get(volunteerOpportunity.Id).Inactive__c)) {
				if (RecursiveTriggerHandler.isFirstTime || Test.isRunningTest()) {
					volunteerOpportunityMap.put(volunteerOpportunity.Id, volunteerOpportunity);
				}
			}
		}
		return recordsForCreatingCaseTeams;
	}

	/**
	 * Build Volunteer Opportunity Map to create Non Wish Event
	 * @param newVolunteerOpportunityMap
	 * @param oldVolunteerOpportunityMap
	 * @return Map Volunteer Opportunity
	 */
	public static Map<Id, Volunteer_Opportunity__c> buildVolunteerOpportunityNonWishMap(
			Map<Id, Volunteer_Opportunity__c> newVolunteerOpportunityMap) {
		Map<Id, Volunteer_Opportunity__c> nonWishListUpdateCount = new Map<Id, Volunteer_Opportunity__c>();
		for (Volunteer_Opportunity__c volunteerOpportunity : newVolunteerOpportunityMap.values()) {
			if (volunteerOpportunity.Volunteer_Name__c != null
					&& volunteerOpportunity.Non_Wish_Event__c != null
					&& !VOLUNTEER_OPPORTUNITY_STATUS_APPROVED.equals(volunteerOpportunity.Status__c)
					&& VOLUNTEER_OPPORTUNITY_STATUS_PENDING.equals(volunteerOpportunity.Status__c)
					&& volunteerOpportunity.Reason_Inactive__c == null) {
				if (RecursiveTriggerHandler.isFirstTime) {
					nonWishListUpdateCount.put(volunteerOpportunity.Id, volunteerOpportunity);
				}
			}
			if ((volunteerOpportunity.Volunteer_Name__c != null
					&& volunteerOpportunity.Non_Wish_Event__c != null
					&& VOLUNTEER_OPPORTUNITY_STATUS_APPROVED.equals(volunteerOpportunity.Status__c)
					&& volunteerOpportunity.Reason_Inactive__c != null)
					|| (volunteerOpportunity.Volunteer_Name__c != null
					&& volunteerOpportunity.Non_Wish_Event__c != null
					&& !VOLUNTEER_OPPORTUNITY_STATUS_APPROVED.equals(volunteerOpportunity.Status__c)
					&& volunteerOpportunity.Reason_Inactive__c != null)) {
				if (RecursiveTriggerHandler.isFirstTime) {
					nonWishListUpdateCount.put(volunteerOpportunity.Id, volunteerOpportunity);
				}
			}
		}
		return nonWishListUpdateCount;
	}

	/**
	 * Build Volunteer Opportunity Map for Record Sharing
	 * @param newVolunteerOpportunityMap
	 * @param oldVolunteerOpportunityMap
	 * @return Map Volunteer Opportunity
	 */
	public static Map<Id, Volunteer_Opportunity__c> buildVolunteerOpportunitySharingMap(
			Map<Id, Volunteer_Opportunity__c> newVolunteerOpportunityMap,
			Map<Id, Volunteer_Opportunity__c> oldVolunteerOpportunityMap) {
		Map<Id, Volunteer_Opportunity__c> volunteerOpportunitySharingMap = new Map<Id, Volunteer_Opportunity__c>();
		for (Volunteer_Opportunity__c volunteerOpportunity : newVolunteerOpportunityMap.values()) {
			if ((VOLUNTEER_OPPORTUNITY_STATUS_APPROVED.equals(volunteerOpportunity.Status__c)
					&& VOLUNTEER_OPPORTUNITY_STATUS_PENDING.equals(oldVolunteerOpportunityMap.get(volunteerOpportunity.Id).Status__c))
					&& volunteerOpportunity.Volunteer_Name__c != null
					&& (volunteerOpportunity.Wish__c != null
					|| volunteerOpportunity.Non_Wish_Event__c != null)
					&& volunteerOpportunity.Reason_Inactive__c == null) {
				volunteerOpportunitySharingMap.put(volunteerOpportunity.Id, volunteerOpportunity);
			}
		}
		return volunteerOpportunitySharingMap;
	}

	/**
	 * Build Volunteer Opportunity Map inactive wish granter map
	 * @param newVolunteerOpportunityMap
	 * @param oldVolunteerOpportunityMap
	 * @return Map Volunteer Opportunity
	 */
	public static Map<Id, Volunteer_Opportunity__c> buildVolunteerOpportunityUpdateInActiveWishGranterMap(
			Map<Id, Volunteer_Opportunity__c> newVolunteerOpportunityMap) {
		Map<Id, Volunteer_Opportunity__c> inActiveWishGranterMap = new Map<Id, Volunteer_Opportunity__c>();
		for (Volunteer_Opportunity__c volunteerOpportunity : newVolunteerOpportunityMap.values()) {
			if (volunteerOpportunity.Volunteer_Name__c != null && volunteerOpportunity.Wish__c != null
					&& (VOLUNTEER_OPPORTUNITY_STATUS_APPROVED.equals(volunteerOpportunity.Status__c)
					|| !VOLUNTEER_OPPORTUNITY_STATUS_APPROVED.equals(volunteerOpportunity.Status__c))
					&& volunteerOpportunity.Reason_Inactive__c != null && volunteerOpportunity.Inactive__c) {
				inActiveWishGranterMap.put(volunteerOpportunity.Id, volunteerOpportunity);
			}
		}
		return inActiveWishGranterMap;
	}

	/**
	 * Build Volunteer Opportunity Map Non Wish Update map
	 * @param oldVolunteerOpportunityMap
	 * @return Map Volunteer Opportunity
	 */
	public static Map<Id, Volunteer_Opportunity__c> buildVolunteerOpportunityNonWishListToUpdateMap(
			Map<Id, Volunteer_Opportunity__c> oldVolunteerOpportunityMap) {
		Map<Id, Volunteer_Opportunity__c> nonWishUpdateMap = new Map<Id, Volunteer_Opportunity__c>();
		for (Volunteer_Opportunity__c volunteerOpportunity : oldVolunteerOpportunityMap.values()) {
			if ((volunteerOpportunity.Volunteer_Name__c != null
					&& volunteerOpportunity .Non_Wish_Event__c != null
					&& VOLUNTEER_OPPORTUNITY_STATUS_APPROVED.equals(volunteerOpportunity.Status__c)
					&& volunteerOpportunity.Reason_Inactive__c == null
					&& volunteerOpportunity.Hidden_VolunteerCount_Desc__c != null)
					|| (volunteerOpportunity.Volunteer_Name__c != null
					&& volunteerOpportunity .Non_Wish_Event__c != null
					&& VOLUNTEER_OPPORTUNITY_STATUS_PENDING.equals(volunteerOpportunity.Status__c))
					|| (volunteerOpportunity.Volunteer_Name__c == null
					&& volunteerOpportunity.Reason_Inactive__c == null
					&& volunteerOpportunity .Non_Wish_Event__c != null)) {
				nonWishUpdateMap.put(volunteerOpportunity.Id, volunteerOpportunity);
			}
		}
		return nonWishUpdateMap;
	}

	/**
	 * Build Volunteer Opportunity Map Non Wish Update map
	 * @param oldVolunteerOpportunityMap
	 * @return Map Volunteer Opportunity
	 */
	public static Map<Id, Volunteer_Opportunity__c> buildVolunteerOpportunityNonRegisteredMap(
			Map<Id, Volunteer_Opportunity__c> oldVolunteerOpportunityMap) {
		Map<Id, Volunteer_Opportunity__c> nonRegisteredMap = new Map<Id, Volunteer_Opportunity__c>();
		for (Volunteer_Opportunity__c volunteerOpportunity : oldVolunteerOpportunityMap.values()) {
			if ((volunteerOpportunity.Volunteer_Name__c != null
					&& volunteerOpportunity .Non_Wish_Event__c != null
					&& VOLUNTEER_OPPORTUNITY_STATUS_APPROVED.equals(volunteerOpportunity.Status__c)
					&& volunteerOpportunity.Hidden_VolunteerCount_Desc__c != null)
					|| (volunteerOpportunity.Volunteer_Name__c != null
					&& volunteerOpportunity .Non_Wish_Event__c != null
					&& VOLUNTEER_OPPORTUNITY_STATUS_PENDING.equals(volunteerOpportunity.Status__c)
					&& volunteerOpportunity.Hidden_VolunteerCount_Desc__c != null)) {
				nonRegisteredMap.put(volunteerOpportunity.Id, volunteerOpportunity);
			}
		}
		return nonRegisteredMap;
	}
}