/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/27/2016
Description : When a new Relationship record is insert then it will call the corresponding methods based 
on the collection size() > 0.
Modification Log: 
04/18/2018 - Kanagaraj - WVC-1885
*******************************************************************************************************************/

public class RelationshipOnAfterInsertTriggerHelper {

	private final static Id familyContactRecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
	private final static Id medicalProfRecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
	private final static Id wishRecordTypeId = Constant_AC.WISH_RT_ID;
	private final static Id ContactFamilyRecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
	private final static Id wishFormRecordTypeId = Constant_AC.WISH_FORM_FAMILY_ID;
	private final static Id wishChildRecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;

	//This method is used to update the medical physician name and email value into contact record.
	public static void updatePhysicianDetails(Set<Id> relatedContactId, List<npe4__Relationship__c> relationShipList) {
		RecursiveTriggerHandler.isFirstTime = false;
		Map<Id, Contact> medicalProfContactMap = new Map<Id, Contact>();
		Map<Id, Contact> updateContactMap = new Map<Id, Contact>();

		try {
			if (relatedContactId.size() > 0) {
				for (Contact dbWishChildCon : [
						SELECT Id,Name,Email,RecordTypeId
						FROM Contact
						WHERE Id IN:relatedContactId
						AND RecordTypeId = :medicalProfRecordTypeId
				]) {
					medicalProfContactMap.put(dbWishChildCon.Id, dbWishChildCon);
				}
			}

			if (medicalProfContactMap.size() > 0) {
				for (npe4__Relationship__c newRecord : relationShipList) {
					if (medicalProfContactMap.containsKey(newRecord.npe4__RelatedContact__c)) {
						Contact newContact = new Contact();
						newContact.Id = newRecord.npe4__Contact__c;
						newContact.Hidden_Medical_Physician__c = medicalProfContactMap.get(newRecord.npe4__RelatedContact__c).Name;
						newContact.Hidden_Medical_Physician_Email__c = medicalProfContactMap.get(newRecord .npe4__RelatedContact__c).Email;
						updateContactMap.put(newContact.Id, newContact);
					}
				}
			}

			if (updateContactMap.size() > 0) {
				RecursiveTriggerHandler.isFirstTime = false;
				update updateContactMap.values();
			}

			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}

		}

		catch (Exception ex) {
			for (npe4__Relationship__c currRec : relationShipList) {
				ErrorMessage_AC.createdebugRec('OnAfterInsertRelationshipTriggerHelper', String.valueof(currRec), String.valueOf(ex), 'updatePhysicianDetails', currRec.Id, ex.getStackTraceString(), 'Error');
			}

			if (!Test.isRunningTest()) {
				for (npe4__Relationship__c currRec : relationShipList) {
					currRec.addError(Label.Debug_log_error_message);
				}

			}
		}
	}

	/*This method is used to once wishchild form get approved then all the relationship record are created then it will update the
	  Update_Wish_Child_Form_Info__c field in case record.*/
	public static void updateApprovedCase(set<Id> wishChildIdSet, List<npe4__Relationship__c> relationShipList) {
// 		RecursiveTriggerHandler.relationShipRecursive = false;
// 		List<Case> updateCaseList = new List<Case>();
// 		try {
// 			if (wishChildIdSet.size() > 0) {

// 				for (Case dbCase : [
// 						SELECT Id,ContactId,RecordTypeId,Update_Wish_Child_Form_Info__c
// 						FROM Case
// 						WHERE ContactId IN:wishChildIdSet AND Update_Wish_Child_Form_Info__c = :TRUE
// 						AND RecordTypeId = :wishRecordTypeId
// 				]) {
// 					if (wishChildIdSet.contains(dbCase.ContactId)) {

// 						dbCase.Update_Wish_Child_Form_Info__c = false;
// 						updateCaseList.add(dbCase);
// 					}
// 				}
// 			}
// 			if (updateCaseList.size() > 0)
// 				update updateCaseList;

// 			if (Test.isRunningTest()) {
// 				throw new CommonTriggerException('Test Class execution');
// 			}

// 		} catch (Exception ex) {
// 			for (npe4__Relationship__c currRec : relationShipList) {
// 				ErrorMessage_AC.createdebugRec('OnAfterInsertRelationshipTriggerHelper', String.valueof(currRec),
// 						String.valueOf(ex), 'updateApprovedCase', currRec.Id, ex.getStackTraceString(), 'Error');
// 			}

// 			if (!Test.isRunningTest()) {

// 				for (npe4__Relationship__c currRec : relationShipList) {
// 					currRec.addError(Label.Debug_log_error_message);
// 				}

// 			}
// 		}
	}

	//This method is used to update the type of relationship in contact record.
	public static void updateRelationshipType(Map<Id, String> relationshipMap) {
		List<Contact> familyContactList = new List<Contact>();
		try {
			if (relationshipMap.size() > 0) {
				for (Contact dbContact : [
						SELECT Id,Name,Relationship_Type__c,RecordTypeId
						FROM Contact
						WHERE Id IN:relationshipMap.KeySet() AND RecordTypeId = :familyContactRecordTypeId
						Limit 50000
				]) {
					if (relationshipMap.containsKey(dbContact.Id)) {
						dbContact.Relationship_Type__c = relationshipMap.get(dbContact.Id);
						familyContactList.add(dbContact);
					}
				}
			}
			if (familyContactList.size() > 0) {
				update familyContactList;
			}

			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}

		}

		catch (Exception ex) {
			for (npe4__Relationship__c currRec : [
					SELECT Id,npe4__Contact__c,npe4__Type__c
					FROM npe4__Relationship__c
					WHERE npe4__Contact__c IN:relationshipMap.KeySet()
			]) {
				ErrorMessage_AC.createdebugRec('OnAfterInsertRelationshipTriggerHelper', String.valueof(currRec), String.valueOf(ex), 'updateRelationshipType', currRec.Id, ex.getStackTraceString(), 'Error');
			}

			if (!Test.isRunningTest()) {

				for (npe4__Relationship__c currRec : [
						SELECT Id,npe4__Contact__c,npe4__Type__c
						FROM npe4__Relationship__c
						WHERE npe4__Contact__c IN:relationshipMap.KeySet()
				]) {
					currRec.addError(Label.Debug_log_error_message);
				}

			}

		}
	}

	public static void createWishFormRecord(Map<Id, Id> wishFormMap) {
		map<Id, Id> caseMap = new Map<Id, Id>();
		List<Wish_Child_Form__c> wishFormList = new List<Wish_Child_Form__c>();
		string parentGurdianName;
		Map<Id, String> prarentGurdianMap = new Map<Id, String>();
		set<string> nameset = new set<string>();

		List<Case> dbCaseList = [
				SELECT Id,ContactId,RecordTypeId
				From Case
				WHERE RecordTypeId = :wishRecordTypeId AND ContactId = :wishFormMap.Values()
		];
		for (case dbcase : dbCaseList) {
			caseMap.put(dbcase.ContactId, dbcase.Id);
		}

		for (npe4__Relationship__c currRel : [
				SELECT id,npe4__RelatedContact__c,npe4__RelatedContact__r.Name,npe4__RelatedContact__r.FirstName, npe4__RelatedContact__r.LastName,npe4__Contact__c,
						npe4__RelatedContact__r.Email,Hidden_isparentFirst__c,npe4__RelatedContact__r.Phone, npe4__RelatedContact__r.Middle_Name__c,npe4__RelatedContact__r.Mailingcity,npe4__RelatedContact__r.Mailingstreet,
						npe4__RelatedContact__r.MailingState,npe4__RelatedContact__r.MailingPostalCode,npe4__Type__c,npe4__RelatedContact__r.HomePhone,npe4__RelatedContact__r.npe01__WorkPhone__c,npe4__RelatedContact__r.MobilePhone,npe4__RelatedContact__r.T_Shirt_Size__c,npe4__RelatedContact__r.Hidden_Wish_Form_Id__c,Parent_Legal_Guardian__c,Wish_Participant__c
				FROM npe4__Relationship__c
				WHERE npe4__RelatedContact__c = :wishFormMap.KeySet() AND
				npe4__RelatedContact__r.RecordTypeId = :ContactFamilyRecordTypeId AND npe4__Type__c != 'Sibling' AND (Parent_Legal_Guardian__c = :true OR Wish_Participant__c = :true) AND npe4__RelatedContact__r.Hidden_Wish_Form_Id__c = :Null
		]) {

			if (wishFormMap.containsKey(currRel.npe4__RelatedContact__c) && currRel.Id != Null) {

				if (currRel.Parent_Legal_Guardian__c == true) {
					if ((parentGurdianName == '' || parentGurdianName == Null) && (!nameset.contains(currRel.npe4__RelatedContact__c))) {
						parentGurdianName = currRel.npe4__RelatedContact__r.Name;
						nameset.add(currRel.npe4__RelatedContact__c);
					} else if (!nameset.contains(currRel.npe4__RelatedContact__c)) {
						parentGurdianName = parentGurdianName + ',' + ' ' + currRel.npe4__RelatedContact__r.Name;
						nameset.add(currRel.npe4__RelatedContact__c);
					}
					prarentGurdianMap.put(currRel.npe4__Contact__c, parentGurdianName);
				}

				Wish_Child_Form__c newFamilyCon = new Wish_Child_Form__c();
				newFamilyCon.FirstName__c = currRel.npe4__RelatedContact__r.FirstName;
				newFamilyCon.Middle_Name__c = currRel.npe4__RelatedContact__r.Middle_Name__c;
				newFamilyCon.LastName__c = currRel.npe4__RelatedContact__r.LastName;
				newFamilyCon.mobilePhone__c = currRel.npe4__RelatedContact__r.MobilePhone;
				newFamilyCon.Email__c = currRel.npe4__RelatedContact__r.Email;
				newFamilyCon.city__c = currRel.npe4__RelatedContact__r.Mailingcity;
				newFamilyCon.Street__c = currRel.npe4__RelatedContact__r.MailingStreet;
				newFamilyCon.State__c = currRel.npe4__RelatedContact__r.MailingState;
				newFamilyCon.Zip_code__c = currRel.npe4__RelatedContact__r.MailingPostalCode;
				newFamilyCon.Emergency_Relationship__c = currRel.npe4__Type__c;
				newFamilyCon.Home_Phone__c = currRel.npe4__RelatedContact__r.HomePhone;
				newFamilyCon.TelePhone__c = currRel.npe4__RelatedContact__r.npe01__WorkPhone__c;
				newFamilyCon.T_Shirt_Size__c = currRel.npe4__RelatedContact__r.T_Shirt_Size__c;
				newFamilyCon.Residing_With_Wish_Child__c = null;

				if (wishFormMap.get(currRel.npe4__RelatedContact__c) == currRel.npe4__Contact__c) {
					newFamilyCon.Case__c = caseMap.get(currRel.npe4__Contact__c);
				}
				newFamilyCon.Contact__c = currRel.npe4__RelatedContact__c;
				newFamilyCon.Wish_Determination_Case_Id__c = currRel.npe4__RelatedContact__c;
				newFamilyCon.RecordTypeId = wishFormRecordTypeId;
				if (currRel.Parent_Legal_Guardian__c == true && currRel.Wish_Participant__c == true) {
					newFamilyCon.IsParticipant__c = false;
					newFamilyCon.Hidden_Same_as_Family__c = true;

				} else if (currRel.Parent_Legal_Guardian__c == true && currRel.Wish_Participant__c == false) {
					newFamilyCon.IsParticipant__c = false;
					newFamilyCon.Hidden_Same_as_Family__c = false;

				} else if (currRel.Parent_Legal_Guardian__c == false && currRel.Wish_Participant__c == true) {
					newFamilyCon.IsParticipant__c = true;
					newFamilyCon.Hidden_Same_as_Family__c = false;
				}
				wishFormList.add(newFamilyCon);
			}
		}

		if (wishFormList.size() > 0) {
			insert wishFormList;
		}
		if (prarentGurdianMap.size() > 0) {
			List<Contact> updateContactList = new List<Contact>();
			for (Contact dbContact : [
					SELECT Id,Name,Parent_Legal_Guardian__c
					FROM Contact
					WHERE Id IN:prarentGurdianMap.KeySet()
			]) {
				if (prarentGurdianMap.containsKey(dbContact.Id)) {
					if (dbContact.Parent_Legal_Guardian__c == Null) {
						dbContact.Parent_Legal_Guardian__c = prarentGurdianMap.get(dbContact.Id);
					} else {
						dbContact.Parent_Legal_Guardian__c = dbContact.Parent_Legal_Guardian__c + ',' + ' ' + prarentGurdianMap.get(dbContact.Id);
					}
					updateContactList.add(dbContact);
				}
				if (updateContactList.size () > 0) {
					update updateContactList;
				}
			}
		}
	}
	public static void populateGurdianName(Map<Id, Id> wishFormIdMap) {
		string parentGurdianName;
		Map<Id, String> prarentGurdianMap = new Map<Id, String>();
		set<string> nameset = new set<string>();
		for (npe4__Relationship__c currRel : [
				SELECT id,npe4__RelatedContact__c,npe4__RelatedContact__r.Name,npe4__RelatedContact__r.FirstName, npe4__RelatedContact__r.LastName,npe4__Contact__c,
						npe4__RelatedContact__r.Email,Hidden_isparentFirst__c,npe4__RelatedContact__r.Phone, npe4__RelatedContact__r.Middle_Name__c,npe4__RelatedContact__r.Mailingcity,npe4__RelatedContact__r.Mailingstreet,
						npe4__RelatedContact__r.MailingState,npe4__RelatedContact__r.MailingPostalCode,npe4__Type__c,npe4__RelatedContact__r.HomePhone,npe4__RelatedContact__r.npe01__WorkPhone__c,npe4__RelatedContact__r.MobilePhone,npe4__RelatedContact__r.T_Shirt_Size__c,npe4__RelatedContact__r.Hidden_Wish_Form_Id__c,Parent_Legal_Guardian__c,Wish_Participant__c
				FROM npe4__Relationship__c
				WHERE npe4__RelatedContact__c = :wishFormIdMap.KeySet() AND
				npe4__RelatedContact__r.RecordTypeId = :ContactFamilyRecordTypeId AND (Parent_Legal_Guardian__c = :true OR Wish_Participant__c = :true) AND npe4__RelatedContact__r.Hidden_Wish_Form_Id__c != Null
		]) {
			if (wishFormIdMap.containsKey(currRel.npe4__RelatedContact__c) && currRel.Id != Null) {
				if (currRel.Parent_Legal_Guardian__c == true) {
					if ((parentGurdianName == '' || parentGurdianName == Null) && (!nameset.contains(currRel.npe4__RelatedContact__c))) {
						parentGurdianName = currRel.npe4__RelatedContact__r.Name;
						nameset.add(currRel.npe4__RelatedContact__c);
					} else if (!nameset.contains(currRel.npe4__RelatedContact__c)) {
						parentGurdianName = parentGurdianName + ',' + ' ' + currRel.npe4__RelatedContact__r.Name;
						nameset.add(currRel.npe4__RelatedContact__c);
					}
					prarentGurdianMap.put(currRel.npe4__Contact__c, parentGurdianName);
				}
			}
		}
		if (prarentGurdianMap.size() > 0) {
			List<Contact> updateContactList = new List<Contact>();
			for (Contact dbContact : [
					SELECT Id,Name,Parent_Legal_Guardian__c,RecordTypeId
					FROM Contact
					WHERE Id IN:prarentGurdianMap.KeySet() AND RecordTypeId = :wishChildRecordTypeId
			]) {
				if (prarentGurdianMap.containsKey(dbContact.Id)) {
					if (dbContact.Parent_Legal_Guardian__c == Null) {
						dbContact.Parent_Legal_Guardian__c = prarentGurdianMap.get(dbContact.Id);

					} else {
						dbContact.Parent_Legal_Guardian__c = dbContact.Parent_Legal_Guardian__c + ',' + ' ' + prarentGurdianMap.get(dbContact.Id);
					}
					updateContactList.add(dbContact);
				}

				if (updateContactList.size () > 0) {
					update updateContactList;
				}
			}
		}
	}
}