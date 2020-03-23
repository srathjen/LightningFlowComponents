/**
 * @description Domain class for the Conflict Of Interest trigger
 * @author	Gustavo Mayer, Traction on Demand
 * @createdDate	3-18-2020
 */
public with sharing class ConflictOfInterestDomain extends trac_TriggerHandlerBase {

	List<Conflict_Of_Interest__c> newCOIList = (List<Conflict_Of_Interest__c>) newRecordsList;
	List<Conflict_Of_Interest__c> oldCOIList = (List<Conflict_Of_Interest__c>) oldRecordsList;
	Map<Id, Conflict_Of_Interest__c> newCOIMap = (Map<Id, Conflict_Of_Interest__c>) newRecordsMap;
	Map<Id, Conflict_Of_Interest__c> oldCOIMap = (Map<Id, Conflict_Of_Interest__c>) oldRecordsMap;

	/**
	 * Before insert of Conflict Of Interest
	 */
	public override void handleBeforeInsert() {
		ConflictOfInterestService.setAccount(newCOIList, oldCOIMap);
	}

	/**
	 * Before update of Conflict Of Interest
	 */
	public override void handleBeforeUpdate() {
		ConflictOfInterestService.setAccount(newCOIList, oldCOIMap);
	}

	/**
	 * After insert of Conflict Of Interest
	 */
	public override void handleAfterInsert() {
		Map<Id, Conflict_Of_Interest__c> volunteerIdCoiMap = new Map<Id, Conflict_Of_Interest__c>();
		Map<Id, Conflict_Of_Interest__c> ownerIdCoiMap = new Map<Id, Conflict_Of_Interest__c>();
		Map<Id, Conflict_Of_Interest__c> volunteerIdCoiExpirationMap = new Map<Id, Conflict_Of_Interest__c>();
		List<Contact> updateVolunteerContact = new List<Contact>();
		Contact updateCon;
		for (Conflict_Of_Interest__c coi : newCOIList) {
			ownerIdCoiMap.put(coi.OwnerId, coi);
			if (coi.Current__c == true) {
				volunteerIdCoiMap.put(coi.Volunteer_Contact__c, coi);
			}
			if (coi.Expiration_Date__c != null && coi.Volunteer_Contact__c != null) {
				updateCon = new Contact();
				updateCon.Id = coi.Volunteer_Contact__c;
				updateCon.COI_Expiration_Date__c = coi.Expiration_Date__c;
				updateVolunteerContact.add(updateCon);
			}
			if (coi.Expiration_Date__c != null && coi.Volunteer_Contact__c != null && coi.Current__c == true) {
				volunteerIdCoiExpirationMap.put(coi.Volunteer_Contact__c, coi);
			}
		}
		if (!volunteerIdCoiMap.isEmpty()) {
			ConflictOfInterestService.updateNonCurrentConflictOfInterest(volunteerIdCoiMap);
		}
		if (!updateVolunteerContact.isEmpty()) {
			update updateVolunteerContact;
		}
		if (!ownerIdCoiMap.isEmpty()) {
			ConflictOfInterestService.createRecordSharing(ownerIdCoiMap);
		}
		if (!volunteerIdCoiExpirationMap.isEmpty()) {
			VolunteerRoleService.updateNonCompliantByConflictOfInterest(volunteerIdCoiExpirationMap);
		}
		if (!volunteerIdCoiMap.isEmpty()) {
			VolunteerJourneyService.processVolunteersChapterRequirements(volunteerIdCoiMap.keySet());
		}
	}

	/**
	 * After update of Conflict Of Interest
	 */
	public override void handleAfterUpdate() {
		Map<Id, Conflict_Of_Interest__c> ownerIdCoiMap = new Map<Id, Conflict_Of_Interest__c>();
		Map<Id, Conflict_Of_Interest__c> volunteerIdCoiMap = new Map<Id, Conflict_Of_Interest__c>();
		Set<Id> volunteerContactIdSet = new Set<Id>();
		List<Contact> updateVolunteerContact = new List<Contact>();
		List<Conflict_Of_Interest__c> coiList = new List<Conflict_Of_Interest__c>();
		for (Conflict_Of_Interest__c coi : newCOIList) {
			if (coi.Expiration_Date__c != oldCOIMap.get(coi.Id).Expiration_Date__c
					&& coi.Expiration_Date__c != null) {
				if (coi.Volunteer_Contact__c != null) {
					Contact updateVolunteer = new Contact();
					updateVolunteer.Id = coi.Volunteer_Contact__c;
					updateVolunteer.COI_Expiration_Date__c = coi.Expiration_Date__c;
					updateVolunteerContact.add(updateVolunteer);
				}
			}
			coiList.add(coi);
			if (coi.HiddenConflictExpire__c == true && oldCOIMap.get(coi.Id).HiddenConflictExpire__c == false) {
				volunteerContactIdSet.add(coi.Volunteer_Contact__c);
			}
			if (coi.Current__c == true && oldCOIMap.get(coi.Id).Current__c == false) {
				volunteerIdCoiMap.put(coi.Volunteer_Contact__c, coi);
			}
			if (coi.OwnerId != oldCOIMap.get(coi.Id).OwnerId) {
				ownerIdCoiMap.put(coi.OwnerId, coi);
			}
		}
		if (!updateVolunteerContact.isEmpty()) {
			update updateVolunteerContact;
		}
		if (!ownerIdCoiMap.isEmpty()) {
			ConflictOfInterestService.createRecordSharing(ownerIdCoiMap);
		}
		if (!volunteerIdCoiMap.isEmpty()) {
			ConflictOfInterestService.updateNonCurrentConflictOfInterest(volunteerIdCoiMap);
		}
		if (!volunteerContactIdSet.isEmpty()) {
			BackgroundCheckService.updateVolunteerRoleHiddenStatus(volunteerContactIdSet, 'COI', coiList);
		}
		if (!volunteerIdCoiMap.isEmpty()) {
			VolunteerJourneyService.processVolunteersChapterRequirements(volunteerIdCoiMap.keySet());
		}
	}
}