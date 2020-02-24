/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : COI_OnBeforeInsertTriggerHandler is used to call the Helper class when the
              new COI record is created.
              
              Modification Log
              ------------------
              WVC-1888    Pavithra G  06/13/2018
              
*****************************************************************************************************/
public class COI_OnAfterUpdateTriggerHandler {
	/********************************************************************************************
	This method is used to create a task when the lead record is created. And share the lead
	record based on the chapter.
*********************************************************************************************/
	public static void OnAfterUpdate(List<Conflict_Of_Interest__c > newCOIList, Map<Id, Conflict_Of_Interest__c> oldCOIMap) {
		List<Contact> updateVolunteerContact = new List<Contact>();
		Set<Id> recordIds = new Set<Id>();
		Set<Id> volunteerIdsCoiCurrent = new Set<Id>();
		Set<Id> ownerIds = new Set<Id>();
		Set<Id> volunteerContactIdSet = new Set<Id>();
		List<Conflict_Of_Interest__c> coiList = new List<Conflict_Of_Interest__c>();
		for (Conflict_Of_Interest__c coi : newCOIList) {
			if (coi.Expiration_Date__c != oldCOIMap.get(coi.id).Expiration_Date__c
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
				recordIds.add(coi.Id);
				volunteerIdsCoiCurrent.add(coi.Volunteer_Contact__c);
			}
			if (coi.OwnerId != oldCOIMap.get(coi.Id).OwnerId){
				ownerIds.add(coi.OwnerId);
			}
		}
		if (updateVolunteerContact.size() > 0) {
			update updateVolunteerContact;
		}
		if (ownerIds.size() > 0) {
			COI_OnAfterInsertTriggerHelper.COIRecordSharing(ownerIds, newCOIList);
		}
		if (volunteerIdsCoiCurrent.size() > 0 && recordIds.size() > 0) {
			COI_OnAfterInsertTriggerHelper.UpdateExistingRecords(newCOIList, recordIds, volunteerIdsCoiCurrent);
		}
		if (volunteerContactIdSet.size() > 0) {
			BackGroundCheck_OnAfterUpdateHelper.UpdateVOppAndVRoleStatus(volunteerContactIdSet, 'COI', coiList);
		}
		/**
		 * WLP-619
		 * Process Volunteers to try to Activate its Volunteer Role, User and Organization Affiliation
		 */
		if (!volunteerIdsCoiCurrent.isEmpty()) {
			VolunteerJourneyService.processVolunteersChapterRequirements(volunteerIdsCoiCurrent);
		}
	}
}