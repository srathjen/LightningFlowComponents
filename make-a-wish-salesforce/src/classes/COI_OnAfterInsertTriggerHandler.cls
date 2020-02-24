/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : COI_OnBeforeInsertTriggerHandler is used to call the Helper class when the
              new COI record is created.
              
              Modification Log
              ------------------
              WVC-1888    Pavithra G  06/13/2018
              WVC-2199    Pavithra G  08/10/2018
              
*****************************************************************************************************/
public class COI_OnAfterInsertTriggerHandler {
	/********************************************************************************************
	This method is used to create a task when the lead record is created. And share the lead
	record based on the chapter.
*********************************************************************************************/
	public static void OnAfterInsert(List<Conflict_Of_Interest__c > newCOIList) {
		Set<Id> recordIds = new Set<Id>();
		Set<Id> volunteerIdsCoiCurrent = new Set<Id>();
		Set<Id> updateVolunteerIdSet = new Set<Id>();
		Set<Id> ownerIds = new Set<Id>();
		List<Conflict_Of_Interest__c> updateVolRoleCOIList = new List<Conflict_Of_Interest__c>();
		List<Contact> updateVolunteerContact = new List<Contact>();
		Contact updateCon;
		for (Conflict_Of_Interest__c coi : newCOIList) {
			if (coi.Current__c == true) {
				recordIds.add(coi.Id);
				volunteerIdsCoiCurrent.add(coi.Volunteer_Contact__c);
			}
			ownerIds.add(coi.OwnerId);
			if (coi.Expiration_Date__c != null && coi.Volunteer_Contact__c != null) {
				//updateVolunteerContact.add(curr);
				updateCon = new Contact();
				updateCon.Id = coi.Volunteer_Contact__c;
				updateCon.COI_Expiration_Date__c = coi.Expiration_Date__c;
				updateVolunteerContact.add(updateCon);
			}
			/***** WVC-2199 *******/
			if (coi.Expiration_Date__c != null && coi.Volunteer_Contact__c != null && coi.Current__c == true) {
				updateVolunteerIdSet.add(coi.Volunteer_Contact__c);
				updateVolRoleCOIList.add(coi);
			}
			/***** WVC-2199 ****/
		}
		if (volunteerIdsCoiCurrent.size() > 0 && recordIds.size() > 0) {
			COI_OnAfterInsertTriggerHelper.UpdateExistingRecords(newCOIList, recordIds, volunteerIdsCoiCurrent);
		}
		if (updateVolunteerContact.size() > 0) {
			update updateVolunteerContact;
		}
		if (ownerIds.size() > 0) {
			COI_OnAfterInsertTriggerHelper.COIRecordSharing(ownerIds, newCOIList);
		}
		if (updateVolunteerIdSet.size() > 0) {
			COI_OnAfterInsertTriggerHelper.updateVolunteerRole(updateVolunteerIdSet, updateVolRoleCOIList);
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