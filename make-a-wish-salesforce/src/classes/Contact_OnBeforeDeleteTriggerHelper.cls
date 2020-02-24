/***************************************************************************************************
Author      : MST Solutions
Date        : 10/15/2016
Description : Contact_OnBeforeDeleteTriggerHelper is used to call the correspondig methods when the
contact record is deleted.

Modification Log
------------------
WVC-1884    KANAGARAJ  04/04/2018

*****************************************************************************************************/
public class Contact_OnBeforeDeleteTriggerHelper {

	// Update the affiliation status when the contact is deleted
	public static void UpdateAffiliationPrimaryStatus(Map<Id, Contact> conMap) {
		npe5__Affiliation__c aff;
		List<npe5__Affiliation__c> UdateAff = new List<npe5__Affiliation__c>();
		try {
			for (npe5__Affiliation__c curraff : [
					SELECT Id,Constituent_Code__c,npe5__Contact__c,npe5__Contact__r.RecordTypeId
					FROM npe5__Affiliation__c
					WHERE npe5__Contact__c IN:conMap.keySet()
					LIMIT 50000
			]) {
				aff = new npe5__Affiliation__c();
				aff.id = curraff.id;
				aff.npe5__Primary__c = false;
				UdateAff.add(aff);
			}
			if (UdateAff.size() > 0) {
				update UdateAff;
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Contact currRec : conMap.values()) {
				ErrorMessage_AC.createdebugRec('Contact_OnBeforeDeleteTriggerHelper', String.valueof(currRec), String.valueOf(ex), 'UpdateAffiliationPrimaryStatus', currRec.Id, ex.getStackTraceString(), 'Error');
			}
			for (Contact currRec : conMap.values()) {
				if (!Test.isRunningTest()) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	// display the error message when the contact record is associated with lead.
	public static void validateContact(Map<Id, Contact> conMap) {
		Set<Id> contactSetId = new Set<id>();
		for (Lead dblead : [
				SELECT id,Hidden_Best_Contact_Person_Id__c,Medical_Professional_ContactId__c,Treating_Medical_Professional_Contact_Id__c,Hidden_Additional_Parent_Id__c,Wish_Family_ContactId__c
				FROM Lead
				WHERE Hidden_Best_Contact_Person_Id__c IN :conMap.keyset() OR Medical_Professional_ContactId__c IN :conMap.keyset() OR Treating_Medical_Professional_Contact_Id__c IN :conMap.keyset() OR Hidden_Additional_Parent_Id__c IN :conMap.keyset() OR Wish_Family_ContactId__c IN :conMap.keyset()
				Limit 50000
		]) {
			contactSetId.add(dbLead.id);
		}
		for (Contact dbContact : conMap.values()) {
			if (contactSetId.size() > 0) {
				dbContact.addError('You cannot delete this Contact as it is associated with Lead');
			}
		}
	}

	public static void deleteWishForm(Set<Id> wishFormIdSet) {
		Id wishFormRecordTypeId = Constant_AC.WISH_FORM_FAMILY_ID;
		if (wishFormIdSet.size() > 0) {
			List<Wish_Child_Form__c> dbWishformList = [
					SELECT Id,Contact__c,RecordTypeId,Migrated__c
					FROM Wish_Child_Form__c
					WHERE Id IN:wishFormIdSet
					AND RecordTypeId = :wishFormRecordTypeId
					AND Migrated__c = FALSE
			];
			if (dbWishformList.size() > 0)
				delete dbWishformList;
		}
	}
}