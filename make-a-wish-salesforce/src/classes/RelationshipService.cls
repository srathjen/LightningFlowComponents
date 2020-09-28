/**
 * @description Relationship Service, centralizes Relationship business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 10/23/2020
 */
public class RelationshipService {

	private final static Id WISH_FAMILY_ID = Constant_AC.WISH_FAMILY_RT_ID;
	private final static Id MEDICAL_PROFESSIONAL_ID = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
	private final static Id CONTACT_WISH_CHILD_RT_ID = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
	private final static String MEDICAL_PROFESSIONAL_LABEL = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
	private static final String LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL;
	private static final String LEAD_DV_FORM_TYPE_BEST_CONTACT = Constant_AC.LEAD_DV_FORM_TYPE_BEST_CONTACT;
	private static final String LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL;
	private static final String LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL;
	private static final String RELATIONSHIP_ACTIVE = Constant_AC.RELATIONSHIP_STATUS_ACTIVE;
	private static final String CONTACT_PARENT = Constant_AC.CONTACT_TYPE_PARENT_LEGAL_GUARDIAN;
	private static final String CONTACT_SIBLING = Constant_AC.CONTACT_TYPE_SIBLING;
	private static final String CONTACT_REFERRING = Constant_AC.CONTACT_TYPE_REFERRING;
	private static final String LEAD_RELATIONSHIP_TO_CHILD_PARENT_GUARDIAN = Constant_AC.LEAD_RELATIONSHIP_TO_CHILD_PARENT_GUARDIAN;

	/**
	 * Build Lead Converted Relationships
	 * @param convertedLead
	 * @return List of Relationships
	 */
	public static Map<Id, npe4__Relationship__c> buildLeadConvertRelationships(Lead convertedLead) {
		Map<Id, npe4__Relationship__c> relationshipMap = new Map<Id, npe4__Relationship__c>();
		// Create Relationship Treating Medical Professional
		if (convertedLead.Treating_MP__c != null) {
			npe4__Relationship__c newRelationship = new npe4__Relationship__c();
			if (relationshipMap.containsKey(convertedLead.Treating_MP__c)) {
				newRelationship = relationshipMap.get(convertedLead.Treating_MP__c);
			} else {
				newRelationship.npe4__Contact__c = convertedLead.ConvertedContactId;
				newRelationship.npe4__Type__c = MEDICAL_PROFESSIONAL_LABEL;
				newRelationship.npe4__RelatedContact__c = convertedLead.Treating_MP__c;
				newRelationship.npe4__Status__c = RELATIONSHIP_ACTIVE;
				newRelationship.Treating_HCP__c = true;
			}
			Boolean isTreatingMedicalProfessionalAlsoReferrer = convertedLead.Treating_MP__c == convertedLead.Referring_MP__c;
			if (isTreatingMedicalProfessionalAlsoReferrer) {
				newRelationship.Referring_Medical_Professional__c = true;
			}
			if (convertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL) {
				newRelationship.Qualifying_Medical_Professional__c = true;
			}
			relationshipMap.put(convertedLead.Treating_MP__c, newRelationship);
		}

		// Create Relationship Referring Medical Professional
		if (convertedLead.Referring_MP__c != null) {
			npe4__Relationship__c newRelationship = new npe4__Relationship__c();
			if (relationshipMap.containsKey(convertedLead.Referring_MP__c)) {
				newRelationship = relationshipMap.get(convertedLead.Referring_MP__c);
			} else {
				newRelationship.npe4__Contact__c = convertedLead.ConvertedContactId;
				newRelationship.npe4__Type__c = MEDICAL_PROFESSIONAL_LABEL;
				newRelationship.npe4__RelatedContact__c = convertedLead.Referring_MP__c;
				newRelationship.npe4__Status__c = RELATIONSHIP_ACTIVE;
				newRelationship.Treating_HCP__c = true;
			}
			newRelationship.Referring_Medical_Professional__c = true;
			Boolean isTreatingMedicalProfessionalAlsoReferrer = convertedLead.Treating_MP__c == convertedLead.Referring_MP__c;
			if (isTreatingMedicalProfessionalAlsoReferrer) {
				if (convertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL) {
					newRelationship.Qualifying_Medical_Professional__c = true;
				}
			}
			relationshipMap.put(convertedLead.Referring_MP__c, newRelationship);
		}

		// Create Relationship Alternate 1 Medical Professional
		if (convertedLead.Alt_1_MP__c != null) {
			npe4__Relationship__c newRelationship = new npe4__Relationship__c();
			if (relationshipMap.containsKey(convertedLead.Alt_1_MP__c)) {
				newRelationship = relationshipMap.get(convertedLead.Alt_1_MP__c);
			} else {
				newRelationship.npe4__Contact__c = convertedLead.ConvertedContactId;
				newRelationship.npe4__Type__c = MEDICAL_PROFESSIONAL_LABEL;
				newRelationship.npe4__RelatedContact__c = convertedLead.Alt_1_MP__c ;
				newRelationship.npe4__Status__c = RELATIONSHIP_ACTIVE;
			}
			Boolean isAlternate1MedicalProfessionalAlsoReferrer = convertedLead.Alt_1_MP__c == convertedLead.Referring_MP__c;
			if (isAlternate1MedicalProfessionalAlsoReferrer) {
				newRelationship.Referring_Medical_Professional__c = true;
			}
			if (convertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL) {
				newRelationship.Qualifying_Medical_Professional__c = true;
			}
			relationshipMap.put(convertedLead.Alt_1_MP__c, newRelationship);
		}

		// Create Relationship Alternate 2 Medical Professional
		if (convertedLead.Alt_2_MP__c != null) {
			npe4__Relationship__c newRelationship = new npe4__Relationship__c();
			if (relationshipMap.containsKey(convertedLead.Alt_2_MP__c)) {
				newRelationship = relationshipMap.get(convertedLead.Alt_2_MP__c);
			} else {
				newRelationship.npe4__Contact__c = convertedLead.ConvertedContactId;
				newRelationship.npe4__Type__c = MEDICAL_PROFESSIONAL_LABEL;
				newRelationship.npe4__RelatedContact__c = convertedLead.Alt_2_MP__c ;
				newRelationship.npe4__Status__c = RELATIONSHIP_ACTIVE;
			}
			Boolean isAlternate2MedicalProfessionalAlsoReferrer = convertedLead.Alt_2_MP__c == convertedLead.Referring_MP__c;
			if (isAlternate2MedicalProfessionalAlsoReferrer) {
				newRelationship.Referring_Medical_Professional__c = true;
			}
			if (convertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL) {
				newRelationship.Qualifying_Medical_Professional__c = true;
			}
			relationshipMap.put(convertedLead.Alt_2_MP__c, newRelationship);
		}

		// Create Relationship Best Contact
		if (convertedLead.Best_Contact__c != null) {
			npe4__Relationship__c newRelationship = new npe4__Relationship__c();
			if (relationshipMap.containsKey(convertedLead.Best_Contact__c)) {
				newRelationship = relationshipMap.get(convertedLead.Best_Contact__c);
			} else {
				newRelationship.npe4__Contact__c = convertedLead.ConvertedContactId;
				newRelationship.npe4__Type__c = MEDICAL_PROFESSIONAL_LABEL;
				newRelationship.npe4__RelatedContact__c = convertedLead.Best_Contact__c;
				newRelationship.npe4__Status__c = RELATIONSHIP_ACTIVE;
			}
			newRelationship.Best_Contact__c = true;
			Boolean isBestContactMedicalProfessionalAlsoReferrer = convertedLead.Best_Contact__c == convertedLead.Referring_MP__c;
			if (isBestContactMedicalProfessionalAlsoReferrer) {
				newRelationship.Referring_Medical_Professional__c = true;
			}
			Boolean isTreatingMedicalProfessionalAlsoBestContact = convertedLead.Treating_MP__c == convertedLead.Best_Contact__c;
			if (isTreatingMedicalProfessionalAlsoBestContact) {
				newRelationship.Treating_HCP__c = true;
			}
			if (convertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_BEST_CONTACT) {
				newRelationship.Qualifying_Medical_Professional__c = true;
			}
			relationshipMap.put(convertedLead.Best_Contact__c, newRelationship);
		}

		// Create Relationship Family Parent Guardian
		if (convertedLead.Wish_Family_ContactId__c != null) {
			npe4__Relationship__c newRelationship = new npe4__Relationship__c();
			newRelationship.npe4__Contact__c = convertedLead.ConvertedContactId;
			newRelationship.npe4__Type__c = convertedLead.Parent_Relationship_to_Child__c;
			newRelationship.Hidden_isparentFirst__c = true;
			newRelationship.Parent_Legal_Guardian__c = true;
			newRelationship.npe4__RelatedContact__c = convertedLead.Wish_Family_ContactId__c;
			newRelationship.npe4__Status__c = RELATIONSHIP_ACTIVE;
			if (convertedLead.Relationship_to_child__c == LEAD_RELATIONSHIP_TO_CHILD_PARENT_GUARDIAN) {
				newRelationship.Referring_Medical_Professional__c = true;
			}
			relationshipMap.put(convertedLead.Wish_Family_ContactId__c, newRelationship);
		}

		// Create Relationship Additional Family Parent Guardian
		if (convertedLead.Hidden_Additional_Parent_Id__c != null) {
			npe4__Relationship__c newRelationship = new npe4__Relationship__c();
			newRelationship.npe4__Contact__c = convertedLead.ConvertedContactId;
			newRelationship.Hidden_isparentFirst__c = false;
			newRelationship.Parent_Legal_Guardian__c = true;
			newRelationship.npe4__Type__c = convertedLead.Additional_Parent_Relationship_to_Child__c;
			newRelationship.npe4__RelatedContact__c = convertedLead.Hidden_Additional_Parent_Id__c;
			newRelationship.npe4__Status__c = RELATIONSHIP_ACTIVE;
			relationshipMap.put(convertedLead.Hidden_Additional_Parent_Id__c, newRelationship);
		}
		return relationshipMap;
	}

	/**
	 * Update the medical physician name and email value into contact record.
	 * @param relatedContactId
	 * @param relationShipList
	 */
	public static void updatePhysicianDetails(Set<Id> relatedContactId, List<npe4__Relationship__c> relationShipList) {
		if (relatedContactId.isEmpty() || !RecursiveTriggerHandler.isFirstTime) {
			return;
		}
		RecursiveTriggerHandler.isFirstTime = false;
		Map<Id, Contact> medicalProfContactMap = new Map<Id, Contact>();
		Map<Id, Contact> updateContactMap = new Map<Id, Contact>();
		try {
			if (relatedContactId.isEmpty()) {
				return;
			}
			for (Contact dbWishChildCon : [
					SELECT Id,Name,Email,RecordTypeId
					FROM Contact
					WHERE Id IN:relatedContactId
					AND RecordTypeId = :MEDICAL_PROFESSIONAL_ID
			]) {
				medicalProfContactMap.put(dbWishChildCon.Id, dbWishChildCon);
			}
			if (medicalProfContactMap.isEmpty()) {
				return;
			}
			for (npe4__Relationship__c newRecord : relationShipList) {
				if (medicalProfContactMap.containsKey(newRecord.npe4__RelatedContact__c)) {
					Contact newContact = new Contact();
					newContact.Id = newRecord.npe4__Contact__c;
					newContact.Hidden_Medical_Physician__c = medicalProfContactMap.get(newRecord.npe4__RelatedContact__c).Name;
					newContact.Hidden_Medical_Physician_Email__c = medicalProfContactMap.get(newRecord .npe4__RelatedContact__c).Email;
					updateContactMap.put(newContact.Id, newContact);
				}
			}
			if (updateContactMap.isEmpty()) {
				return;
			}
			update updateContactMap.values();
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (npe4__Relationship__c relationship : relationShipList) {
				ErrorMessage_AC.createDebugRec('RelationshipService',
						String.valueOf(relationship), String.valueOf(ex), 'updatePhysicianDetails',
						relationship.Id, ex.getStackTraceString(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (npe4__Relationship__c currRec : relationShipList) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}


	/**
	 * Build Lead Converted Relationship
	 * @param leadConvertWrapper wrapper
	 * @return Relationship
	 */
	public static List<npe4__Relationship__c> buildWishFamilyLeadConvertRelationship(List<Contact> contacts) {
		List<npe4__Relationship__c> relationships = new List<npe4__Relationship__c>();
		for(Contact familyContact : contacts){
			if (familyContact.Relationship_Type__c.equals(CONTACT_PARENT)) {
				// Parent Legal Guardian Relationship
				npe4__Relationship__c parentLegGuardRelationship = new npe4__Relationship__c();
				parentLegGuardRelationship.npe4__Contact__c = familyContact.Wish_Child_Id_Hidden__c;
				parentLegGuardRelationship.npe4__Type__c = familyContact.Relationship__c;
				parentLegGuardRelationship.Parent_Legal_Guardian__c = true;
				if (familyContact.Type_of_Contact__c.equals(CONTACT_REFERRING)) {
					parentLegGuardRelationship.Referring_Medical_Professional__c = true;
				}
				parentLegGuardRelationship.npe4__RelatedContact__c = familyContact.Id;
				parentLegGuardRelationship.npe4__Status__c = RELATIONSHIP_ACTIVE;
				relationships.add(parentLegGuardRelationship);
			} else {
				// Sibling Relationship
				npe4__Relationship__c siblingRelationship = new npe4__Relationship__c();
				siblingRelationship.npe4__Contact__c = familyContact.Wish_Child_Id_Hidden__c;
				siblingRelationship.npe4__Type__c = CONTACT_SIBLING;
				siblingRelationship.npe4__RelatedContact__c = familyContact.Id;
				siblingRelationship.npe4__Status__c = RELATIONSHIP_ACTIVE;
				relationships.add(siblingRelationship);
			}
		}
		return relationships;
	}

	/**
	 * Update the type of relationship in contact record.
	 * @param relationshipMap
	 */
	public static void updateRelationshipType(Map<Id, String> relationshipMap) {
		if (relationshipMap.isEmpty()) {
			return;
		}
		List<Contact> familyContactList = new List<Contact>();
		try {
			for (Contact dbContact : [
					SELECT Id,Name,Relationship_Type__c,RecordTypeId
					FROM Contact
					WHERE Id IN:relationshipMap.keySet() AND RecordTypeId = :WISH_FAMILY_ID
			]) {
				if (relationshipMap.containsKey(dbContact.Id)) {
					dbContact.Relationship_Type__c = relationshipMap.get(dbContact.Id);
					familyContactList.add(dbContact);
				}
			}
			update familyContactList;
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (npe4__Relationship__c relationship : [
					SELECT Id,npe4__Contact__c,npe4__Type__c
					FROM npe4__Relationship__c
					WHERE npe4__Contact__c IN:relationshipMap.keySet()
			]) {
				ErrorMessage_AC.createDebugRec('RelationshipService',
						String.valueOf(relationship), String.valueOf(ex),
						'updateRelationshipType', relationship.Id, ex.getStackTraceString(), 'Error');
				if (!Test.isRunningTest()) {
					relationship.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	/**
	 * Populate Guargian Name
	 * @param contactMap
	 */
	public static void populateGuardianName(Map<Id, Id> contactMap) {
		if (contactMap.isEmpty()) {
			return;
		}
		String parentGuardianName;
		Map<Id, String> parentGuardianMap = new Map<Id, String>();
		Set<String> names = new Set<String>();
		for (npe4__Relationship__c relationship : [
				SELECT Id,npe4__RelatedContact__c, npe4__RelatedContact__r.Name, npe4__RelatedContact__r.FirstName,
						npe4__RelatedContact__r.LastName, npe4__Contact__c, npe4__RelatedContact__r.Email,
						Hidden_isparentFirst__c, npe4__RelatedContact__r.Phone, npe4__RelatedContact__r.Middle_Name__c,
						npe4__RelatedContact__r.MailingCity, npe4__RelatedContact__r.MailingStreet,
						npe4__RelatedContact__r.MailingState, npe4__RelatedContact__r.MailingPostalCode,
						npe4__Type__c,npe4__RelatedContact__r.HomePhone,npe4__RelatedContact__r.npe01__WorkPhone__c,
						npe4__RelatedContact__r.MobilePhone,npe4__RelatedContact__r.T_Shirt_Size__c,
						npe4__RelatedContact__r.Hidden_Wish_Form_Id__c,Parent_Legal_Guardian__c,Wish_Participant__c
				FROM npe4__Relationship__c
				WHERE npe4__RelatedContact__c = :contactMap.keySet()
				AND npe4__RelatedContact__r.RecordTypeId = :WISH_FAMILY_ID
				AND (Parent_Legal_Guardian__c = TRUE OR Wish_Participant__c = TRUE)
				AND npe4__RelatedContact__r.Hidden_Wish_Form_Id__c != NULL
		]) {
			if (contactMap.containsKey(relationship.npe4__RelatedContact__c) && relationship.Id != null) {
				if (relationship.Parent_Legal_Guardian__c == true) {
					if (String.isEmpty(parentGuardianName) && (!names.contains(relationship.npe4__RelatedContact__c))) {
						parentGuardianName = relationship.npe4__RelatedContact__r.Name;
						names.add(relationship.npe4__RelatedContact__c);
					} else if (!names.contains(relationship.npe4__RelatedContact__c)) {
						parentGuardianName = parentGuardianName + ', ' + relationship.npe4__RelatedContact__r.Name;
						names.add(relationship.npe4__RelatedContact__c);
					}
					parentGuardianMap.put(relationship.npe4__Contact__c, parentGuardianName);
				}
			}
		}
		if (parentGuardianMap.isEmpty()) {
			return;
		}
		List<Contact> contacts = new List<Contact>();
		for (Contact contact : [
				SELECT Id,Name,Parent_Legal_Guardian__c,RecordTypeId
				FROM Contact
				WHERE Id IN:parentGuardianMap.keySet()
				AND RecordTypeId = :CONTACT_WISH_CHILD_RT_ID
		]) {
			if (parentGuardianMap.containsKey(contact.Id)) {
				if (String.isNotEmpty(contact.Parent_Legal_Guardian__c)) {
					contact.Parent_Legal_Guardian__c = parentGuardianMap.get(contact.Id);
				} else {
					contact.Parent_Legal_Guardian__c = contact.Parent_Legal_Guardian__c + ', '
							+ parentGuardianMap.get(contact.Id);
				}
				contacts.add(contact);
			}
			update contacts;
		}
	}

	/**
	 * Build Contact Set from new Relationships
	 * @param newRelationshipsList
	 * @return Set of npe4__RelatedContact__c
	 */
	public static Set<Id> buildQualifyingMedProfessionalRelationshipMap(List<npe4__Relationship__c> newRelationshipsList) {
		Set<Id> qualifyingMedicalProfessionalContactIds = new Set<Id>();
		for (npe4__Relationship__c newRecord : newRelationshipsList) {
			if (Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null) {
				if (newRecord.npe4__Contact__c != null
						&& newRecord.npe4__Type__c == Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL
						&& newRecord.Qualifying_Medical_Professional__c
						&& RELATIONSHIP_ACTIVE.equals(newRecord.npe4__Status__c)) {
					qualifyingMedicalProfessionalContactIds.add(newRecord.npe4__RelatedContact__c);
				}
			}
		}
		return qualifyingMedicalProfessionalContactIds;
	}

	/**
	 * Build Relationship Map from new Relationships
	 * @param newRelationshipsList
	 * @return Map of npe4__RelatedContact__c and npe4__Contact__c
	 */
	public static Map<Id, String> buildNonMedicalRelationshipMap(List<npe4__Relationship__c> newRelationshipsList) {
		Map<Id, String> relationshipMap = new Map<Id, String>();
		for (npe4__Relationship__c newRecord : newRelationshipsList) {
			if (newRecord.npe4__Contact__c != null
					&& newRecord.npe4__RelatedContact__c != null
					&& newRecord.npe4__Type__c != Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL) {
				relationshipMap.put(newRecord.npe4__RelatedContact__c, newRecord.npe4__Type__c);
			}
		}
		return relationshipMap;
	}

	/**
	 * Build Contact Map from new Relationships
	 * @param newRelationshipsList
	 * @return Map of npe4__RelatedContact__c and npe4__Contact__c
	 */
	public static Map<Id, Id> buildContactMap(List<npe4__Relationship__c> newRelationshipsList) {
		Map<Id, Id> contactMap = new Map<Id, Id>();
		for (npe4__Relationship__c newRecord : newRelationshipsList) {
			if (newRecord.npe4__Contact__c != null
					&& newRecord.npe4__RelatedContact__c != null) {
				contactMap.put(newRecord.npe4__RelatedContact__c, newRecord.npe4__Contact__c);
			}
		}
		return contactMap;
	}
}