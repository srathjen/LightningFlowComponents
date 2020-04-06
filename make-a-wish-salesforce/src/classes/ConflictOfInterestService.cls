/**
 * @description Conflict of Interest Service, centralizes Conflict of Interest business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 3/18/2020
 */
public class ConflictOfInterestService {

	private static String EMPTY = '';

	/**
	 * Set Account details on Conflict Of Interest
	 * @param newCOIList
	 * @param volContactIdSet
	 */
	public static List<Conflict_Of_Interest__c> setAccount(List<Conflict_Of_Interest__c> newCOIList,
			Map<Id, Conflict_Of_Interest__c> oldCOIMap) {
		Set<Id> volunteerContactIds = new Set<Id>();
		for (Conflict_Of_Interest__c newCOI : newCOIList) {
			if (newCOI.Account_Name__c == null
					|| newCOI.Account_Phone__c == null
					|| newCOI.Hidden_Volunteer_Contact_Email__c == null) {
				volunteerContactIds.add(newCOI.Volunteer_Contact__c);
			}
			if (oldCOIMap != null && oldCOIMap.containsKey(newCOI.Id)) {
				if (newCOI.Signed_Date__c != oldCOIMap.get(newCOI.Id).Signed_Date__c
						&& newCOI.Signed_Date__c != null) {
					newCOI.Expiration_Date__c = newCOI.Signed_Date__c.addYears(1);
					if (!newCOI.Current__c) {
						newCOI.Current__c = true;
					}
				}
			} else {
				if (newCOI.Signed_Date__c != null) {
					newCOI.Expiration_Date__c = newCOI.Signed_Date__c.addYears(1);
					if (!newCOI.Current__c) {
						newCOI.Current__c = true;
					}
				}
			}
		}
		if (volunteerContactIds.isEmpty()) {
			return newCOIList;
		}
		Map<Id, Contact> conMap = new Map<Id, Contact>();
		for (Contact volunteerContact : [
				SELECT Id, Email, AccountId, OwnerId, Region_Chapter__r.Name, Region_Chapter__r.Phone,
						Region_Chapter__r.Email__c, Region_Chapter__c
				FROM Contact
				WHERE Id IN :volunteerContactIds
		]) {
			conMap.put(volunteerContact.Id, volunteerContact);
		}
		for (Conflict_Of_Interest__c coi : newCOIList) {
			if (conMap.containsKey(coi.Volunteer_Contact__c)) {
				coi.Account_Name__c = conMap.get(coi.Volunteer_Contact__c).Region_Chapter__r.Name;
				coi.Account_Phone__c = conMap.get(coi.Volunteer_Contact__c).Region_Chapter__r.Phone;
				coi.Hidden_Volunteer_Contact_Email__c = conMap.get(coi.Volunteer_Contact__c).Email;
				coi.Account_Email__c = conMap.get(coi.Volunteer_Contact__c).Region_Chapter__r.Email__c;
				coi.OwnerId = conMap.get(coi.Volunteer_Contact__c).OwnerId;
			}
		}
		return newCOIList;
	}

	/**
	 * Update the Current field to false of the no longer current Conflict of Interests
	 * @param newCOIList
	 * @param volunteerIdCoiMap
	 */
	public static List<Conflict_Of_Interest__c> updateNonCurrentConflictOfInterest(Map<Id, Conflict_Of_Interest__c> volunteerIdCoiMap) {
		List<Conflict_Of_Interest__c> conflictOfInterests = new List<Conflict_Of_Interest__c>();
		try {
			for (Conflict_Of_Interest__c currentCoi : [
					SELECT Id
					FROM Conflict_Of_Interest__c
					WHERE Volunteer_Contact__c IN :volunteerIdCoiMap.keySet()
					AND Id NOT IN :volunteerIdCoiMap.values()
					AND Current__c = TRUE
			]) {
				Conflict_Of_Interest__c coi = new Conflict_Of_Interest__c();
				coi.Id = currentCoi.Id;
				coi.Current__c = false;
				conflictOfInterests.add(coi);
			}
			if (!conflictOfInterests.isEmpty()) {
				update conflictOfInterests;
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Conflict_Of_Interest__c coi : volunteerIdCoiMap.values()) {
				ErrorMessage_AC.createDebugRec('ConflictOfInterestService',
						String.valueOf(coi), String.valueOf(ex), 'updateNonCurrentConflictOfInterest',
						coi.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}

			if (!Test.isRunningTest()) {
				for (Conflict_Of_Interest__c coi : volunteerIdCoiMap.values()) {
					coi.addError(Label.Debug_log_error_message);
				}
			}
		}
		return conflictOfInterests;
	}

	/**
	 * Create record sharing
	 * @param ownerIds
	 * @param coiList
	 */
	public static List<Conflict_Of_Interest__Share> createRecordSharing(Map<Id, Conflict_Of_Interest__c> ownerIdCoiMap) {
		List<Conflict_Of_Interest__Share> conflictOfInterestShares = new List<Conflict_Of_Interest__Share>();
		try {
			Map<Id, String> userRoleMap = UserRoleUtility.getUserRole(ownerIdCoiMap.keySet());
			Map<String, List<Conflict_Of_Interest__c>> coiMap = new Map<String, List<Conflict_Of_Interest__c>>();
			for (Conflict_Of_Interest__c coi : ownerIdCoiMap.values()) {
				if (coi.Account_Name__c != null && userRoleMap.get(coi.OwnerId) == Constant_AC.ROLE_NATIONAL_STAFF) {
					if (coiMap.containsKey(coi.Account_Name__c)) {
						coiMap.get(coi.Account_Name__c).add(coi);
					} else {
						coiMap.put(coi.Account_Name__c, new List<Conflict_Of_Interest__c>{
								coi
						});
					}
				}
			}
			if (coiMap.size() > 0) {
				conflictOfInterestShares = ChapterStaffRecordSharing_AC.COIRecordSharing(coiMap);
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Conflict_Of_Interest__c coi : ownerIdCoiMap.values()) {
				ErrorMessage_AC.createDebugRec('ConflictOfInterestService', String.valueOf(coi),
						String.valueOf(ex), 'createRecordSharing', coi.Id,
						ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (Conflict_Of_Interest__c coi : ownerIdCoiMap.values()) {
					coi.addError(Label.Debug_log_error_message);
				}
			}
		}
		return conflictOfInterestShares;
	}

	/*
     * @description     Toggle the ConflictOfInterest.Volunteer_is_Inactive__c flag.
     *
     * @param           Set<Id> inactiveVolunteerIdSet
     * @param           Boolean isInactiveVolunteer
     *
     * @author          MST Solutions
     * @createdDate     unknown
     */
	@future
	public static void toggleConflictOfInterestInactiveFlag(Set<Id> inactiveVolunteerIdSet, Boolean isInactiveVolunteer) {
		try {
			List<Conflict_Of_Interest__c> updateCOIList = New List<Conflict_Of_Interest__c>();

			for (Conflict_Of_Interest__c currCOI : [
				SELECT Id, Volunteer_is_Inactive__c
				FROM Conflict_Of_Interest__c
				WHERE Volunteer_Contact__c IN :inactiveVolunteerIdSet AND Volunteer_is_Inactive__c != :isInactiveVolunteer
			]) {
				currCOI.Volunteer_is_Inactive__c = isInactiveVolunteer;
				updateCOIList.add(currCOI);
			}

			if (updateCOIList.size() > 0) {
				update updateCOIList;
			}

			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			if (!Test.isRunningTest()) {
				for (User currRec : [
					SELECT
						Id, FirstName, LastName, Email, MobilePhone, ContactId,
						Street, City, State, PostalCode, Country, Fax
					FROM User
					WHERE ContactId IN :inactiveVolunteerIdSet
				]) {
					ErrorMessage_AC.createdebugRec('ConflictOfInterestService', String.valueOf(currRec), String.valueOf(ex), 'toggleConflictOfInterestInactiveFlag', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
				}
			}
		}
	}
}