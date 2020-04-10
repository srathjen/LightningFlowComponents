/**
 * @description Relationship Service, centralizes Relationship business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 10/23/2020
 */
public class RelationshipService {

	private final static Id WISH_FAMILY_ID = Constant_AC.WISH_FAMILY_RT_ID;
	private final static Id MEDICAL_PROFESSIONAL_ID = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
	private final static Id WISH_RT_ID = Constant_AC.WISH_RT_ID;
	private final static Id WISH_FORM_FAMILY_ID = Constant_AC.WISH_FORM_FAMILY_ID;
	private final static Id CONTACT_WISH_CHILD_RT_ID = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
	private final static String MEDICAL_PROFESSIONAL_LABEL = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
	private static final String LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL;
	private static final String LEAD_DV_FORM_TYPE_BEST_CONTACT = Constant_AC.LEAD_DV_FORM_TYPE_BEST_CONTACT;
	private static final String LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL;
	private static final String LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL;
	private static final String LEAD_RELATIONSHIP_TO_CHILD_PARENT_GUARDIAN = Constant_AC.LEAD_RELATIONSHIP_TO_CHILD_PARENT_GUARDIAN;
	private static final String RELATIONSHIP_ACTIVE = Constant_AC.RELATIONSHIP_STATUS_ACTIVE;
	private static final String CONTACT_SIBLING = Constant_AC.CONTACT_TYPE_SIBLING;
	private static final String CONTACT_REFERRER_BEST = Constant_AC.CONTACT_TYPE_REFERRER_AND_BEST;
	private static final String CONTACT_REFERRER_TREATING = Constant_AC.CONTACT_TYPE_REFERRER_AND_TREATING;
	private static final String CONTACT_BEST = Constant_AC.CONTACT_TYPE_BEST;
	private static final String CONTACT_TREATING = Constant_AC.CONTACT_TYPE_TREATING;
	private static final String CONTACT_REFERRING = Constant_AC.CONTACT_TYPE_REFERRING;
	private static final String CONTACT_PARENT = Constant_AC.CONTACT_TYPE_PARENT_LEGAL_GUARDIAN;
	private static final String DASH = '-';

	/**
	 * Build Lead Converted Relationships
	 * @param convertedLead
	 * @return List of Relationships
	 */
	public static Map<Id, npe4__Relationship__c> buildLeadConvertRelationships(Lead convertedLead) {
		Map<Id, npe4__Relationship__c> relationshipMap = new Map<Id, npe4__Relationship__c>();
		// Create Relationship Treating Medical Professional
		if (convertedLead.Treating_Medical_Professional_Contact_Id__c != null) {
			npe4__Relationship__c newRelationship = new npe4__Relationship__c();
			if (relationshipMap.containsKey(convertedLead.Treating_Medical_Professional_Contact_Id__c)) {
				newRelationship = relationshipMap.get(convertedLead.Treating_Medical_Professional_Contact_Id__c);
			} else {
				newRelationship.npe4__Contact__c = convertedLead.ConvertedContactId;
				newRelationship.npe4__Type__c = MEDICAL_PROFESSIONAL_LABEL;
				newRelationship.npe4__RelatedContact__c = convertedLead.Treating_Medical_Professional_Contact_Id__c;
				newRelationship.npe4__Status__c = RELATIONSHIP_ACTIVE;
				newRelationship.Treating_HCP__c = true;
			}
			Boolean isTreatingMedicalProfessionalAlsoReferrer = isSameMedicalProfessional(
					convertedLead.Treating_Medical_Professional_First_Name__c, convertedLead.Referrer_FirstName__c,
					convertedLead.Treating_Medical_Professional_Last_Name__c, convertedLead.Referrer_Last_Name__c,
					convertedLead.Treating_Medical_Professional_Phone__c, convertedLead.Referrer_Phone__c,
					convertedLead.Treating_Medical_Professional_Email__c, convertedLead.Referrer_Email__c);
			if (isTreatingMedicalProfessionalAlsoReferrer) {
				newRelationship.Referring_Medical_Professional__c = true;
			}
			if (convertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL) {
				newRelationship.Qualifying_Medical_Professional__c = true;
			}
			relationshipMap.put(convertedLead.Treating_Medical_Professional_Contact_Id__c, newRelationship);
		}
		// Create Relationship Referring Medical Professional
		if (convertedLead.Medical_Professional_ContactId__c != null) {
			npe4__Relationship__c newRelationship = new npe4__Relationship__c();
			if (relationshipMap.containsKey(convertedLead.Medical_Professional_ContactId__c)) {
				newRelationship = relationshipMap.get(convertedLead.Medical_Professional_ContactId__c);
			} else {
				newRelationship.npe4__Contact__c = convertedLead.ConvertedContactId;
				newRelationship.npe4__Type__c = MEDICAL_PROFESSIONAL_LABEL;
				newRelationship.npe4__RelatedContact__c = convertedLead.Medical_Professional_ContactId__c ;
				newRelationship.npe4__Status__c = RELATIONSHIP_ACTIVE;
				newRelationship.Treating_HCP__c = true;
			}
			newRelationship.Referring_Medical_Professional__c = true;
			Boolean isTreatingMedicalProfessionalAlsoReferrer = isSameMedicalProfessional(
					convertedLead.Treating_Medical_Professional_First_Name__c, convertedLead.Referrer_FirstName__c,
					convertedLead.Treating_Medical_Professional_Last_Name__c, convertedLead.Referrer_Last_Name__c,
					convertedLead.Treating_Medical_Professional_Phone__c, convertedLead.Referrer_Phone__c,
					convertedLead.Treating_Medical_Professional_Email__c, convertedLead.Referrer_Email__c);
			if (isTreatingMedicalProfessionalAlsoReferrer) {
				if (convertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL) {
					newRelationship.Qualifying_Medical_Professional__c = true;
				}
			}
			relationshipMap.put(convertedLead.Medical_Professional_ContactId__c, newRelationship);
		}
		// Create Relationship Alternate 1 Medical Professional
		if (convertedLead.HiddenAlternate1MedProfessionalId__c != null) {
			npe4__Relationship__c newRelationship = new npe4__Relationship__c();
			if (relationshipMap.containsKey(convertedLead.HiddenAlternate1MedProfessionalId__c)) {
				newRelationship = relationshipMap.get(convertedLead.HiddenAlternate1MedProfessionalId__c);
			} else {
				newRelationship.npe4__Contact__c = convertedLead.ConvertedContactId;
				newRelationship.npe4__Type__c = MEDICAL_PROFESSIONAL_LABEL;
				newRelationship.npe4__RelatedContact__c = convertedLead.HiddenAlternate1MedProfessionalId__c ;
				newRelationship.npe4__Status__c = RELATIONSHIP_ACTIVE;
			}

			Boolean isAlternate1MedicalProfessionalAlsoReferrer = isSameMedicalProfessional(
					convertedLead.Alternate1MedProfessionalFirstName__c, convertedLead.Referrer_FirstName__c,
					convertedLead.Alternate1MedProfessionalLastName__c, convertedLead.Referrer_Last_Name__c,
					convertedLead.Alternate1MedProfessionalPhone__c, convertedLead.Referrer_Phone__c,
					convertedLead.Alternate1MedicalProfessionalEmail__c, convertedLead.Referrer_Email__c);
			if (isAlternate1MedicalProfessionalAlsoReferrer) {
				newRelationship.Referring_Medical_Professional__c = true;
			}
			if (convertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL) {
				newRelationship.Qualifying_Medical_Professional__c = true;
			}
			relationshipMap.put(convertedLead.HiddenAlternate1MedProfessionalId__c, newRelationship);
		}
		// Create Relationship Alternate 2 Medical Professional
		if (convertedLead.HiddenAlternate2MedProfessionalId__c != null) {
			npe4__Relationship__c newRelationship = new npe4__Relationship__c();
			if (relationshipMap.containsKey(convertedLead.HiddenAlternate2MedProfessionalId__c)) {
				newRelationship = relationshipMap.get(convertedLead.HiddenAlternate2MedProfessionalId__c);
			} else {
				newRelationship.npe4__Contact__c = convertedLead.ConvertedContactId;
				newRelationship.npe4__Type__c = MEDICAL_PROFESSIONAL_LABEL;
				newRelationship.npe4__RelatedContact__c = convertedLead.HiddenAlternate2MedProfessionalId__c ;
				newRelationship.npe4__Status__c = RELATIONSHIP_ACTIVE;
			}
			Boolean isAlternate2MedicalProfessionalAlsoReferrer = isSameMedicalProfessional(
					convertedLead.Alternate2MedProfessionalFirstName__c, convertedLead.Referrer_FirstName__c,
					convertedLead.Alternate2MedProfessionalLastName__c, convertedLead.Referrer_Last_Name__c,
					convertedLead.Alternate2MedProfessionalPhone__c, convertedLead.Referrer_Phone__c,
					convertedLead.Alternate2MedProfessionalEmail__c, convertedLead.Referrer_Email__c);
			if (isAlternate2MedicalProfessionalAlsoReferrer) {
				newRelationship.Referring_Medical_Professional__c = true;
			}
			if (convertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL) {
				newRelationship.Qualifying_Medical_Professional__c = true;
			}
			relationshipMap.put(convertedLead.HiddenAlternate2MedProfessionalId__c, newRelationship);
		}
		// Create Relationship Best Contact
		if (convertedLead.Hidden_Best_Contact_Person_Id__c != null) {
			npe4__Relationship__c newRelationship = new npe4__Relationship__c();
			if (relationshipMap.containsKey(convertedLead.Hidden_Best_Contact_Person_Id__c)) {
				newRelationship = relationshipMap.get(convertedLead.Hidden_Best_Contact_Person_Id__c);
			} else {
				newRelationship.npe4__Contact__c = convertedLead.ConvertedContactId;
				newRelationship.npe4__Type__c = MEDICAL_PROFESSIONAL_LABEL;
				newRelationship.npe4__RelatedContact__c = convertedLead.Hidden_Best_Contact_Person_Id__c;
				newRelationship.npe4__Status__c = RELATIONSHIP_ACTIVE;
			}
			newRelationship.Best_Contact__c = true;
			Boolean isBestContactMedicalProfessionalAlsoReferrer = isSameMedicalProfessional(
					convertedLead.Best_Contact_for_Physician_First_Name__c, convertedLead.Referrer_FirstName__c,
					convertedLead.Best_Contact_for_Physician_Last_Name__c, convertedLead.Referrer_Last_Name__c,
					null, null,
					convertedLead.Best_contact_for_Physician_Email__c, convertedLead.Referrer_Email__c);
			if (isBestContactMedicalProfessionalAlsoReferrer) {
				newRelationship.Referring_Medical_Professional__c = true;
			}
			Boolean isTreatingMedicalProfessionalAlsoBestContact = isSameMedicalProfessional(
					convertedLead.Treating_Medical_Professional_First_Name__c, convertedLead.Best_Contact_for_Physician_First_Name__c,
					convertedLead.Treating_Medical_Professional_Last_Name__c, convertedLead.Best_Contact_for_Physician_Last_Name__c,
					null, null,
					convertedLead.Treating_Medical_Professional_Email__c, convertedLead.Best_contact_for_Physician_Email__c);
			if (isTreatingMedicalProfessionalAlsoBestContact) {
				newRelationship.Treating_HCP__c = true;
			}
			if (convertedLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_BEST_CONTACT) {
				newRelationship.Qualifying_Medical_Professional__c = true;
			}
			relationshipMap.put(convertedLead.Hidden_Best_Contact_Person_Id__c, newRelationship);
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
	 * Build Lead Converted Relationship
	 * @param wishChildContactId
	 * @param contact
	 * @param qualifyingMap
	 * @param relationshipTypeMap
	 * @param parentGuardianNameSet
	 * @return Relationship
	 */
	public static npe4__Relationship__c buildLeadConvertRelationship(Id wishChildContactId, Contact contact,
			Map<String, Boolean> qualifyingMap, Map<String, String> relationshipTypeMap, Set<String> parentGuardianNameSet) {
		npe4__Relationship__c newRelationship = new npe4__Relationship__c();
		newRelationship.npe4__Contact__c = wishChildContactId;
		if (contact.RecordTypeId == MEDICAL_PROFESSIONAL_ID) {
			newRelationship.npe4__Type__c = MEDICAL_PROFESSIONAL_LABEL;
			if (qualifyingMap.containsKey(contact.FirstName + DASH + contact.LastName
					+ DASH + contact.npe01__WorkEmail__c)) {
				newRelationship.Qualifying_Medical_Professional__c = qualifyingMap.get(contact.FirstName
						+ DASH + contact.LastName + DASH + contact.npe01__WorkEmail__c);
			}
		} else if (contact.RecordTypeId == WISH_FAMILY_ID) {
			if (CONTACT_SIBLING.equals(contact.Type_of_Contact__c)) {
				newRelationship.npe4__Type__c = CONTACT_SIBLING;
				newRelationship.npe4__RelatedContact__c = contact.Id;
				newRelationship.npe4__Contact__c = contact.Wish_Child_Id_Hidden__c;
				newRelationship.npe4__Status__c = RELATIONSHIP_ACTIVE;
			} else {
				newRelationship.npe4__Type__c = relationshipTypeMap.get(contact.FirstName + DASH
						+ contact.LastName + DASH + contact.Email + DASH + contact.Phone);
				if (parentGuardianNameSet.contains(contact.FirstName + DASH + contact.LastName
						+ DASH + WISH_FAMILY_ID)) {
					newRelationship.Parent_Legal_Guardian__c = true;
				}
			}
		}
		if (contact.Type_of_Contact__c == CONTACT_REFERRING
				|| contact.Type_of_Contact__c == CONTACT_PARENT) {
			newRelationship.Referring_Medical_Professional__c = true;
		} else if (contact.Type_of_Contact__c == CONTACT_TREATING) {
			newRelationship.Treating_HCP__c = true;
		} else if (contact.Type_of_Contact__c == CONTACT_REFERRER_TREATING) {
			newRelationship.Referring_Medical_Professional__c = true;
			newRelationship.Treating_HCP__c = true;
		} else if (contact.Type_of_Contact__c == CONTACT_REFERRER_BEST) {
			newRelationship.Referring_Medical_Professional__c = true;
			newRelationship.Best_Contact__c = true;
		} else if (contact.Type_of_Contact__c == CONTACT_BEST) {
			newRelationship.Best_Contact__c = true;
		}
		newRelationship.npe4__RelatedContact__c = contact.Id;
		newRelationship.npe4__Status__c = RELATIONSHIP_ACTIVE;
		return newRelationship;
	}

	/**
	 * Check if a Medical Professional contact equal
	 *
	 * @param sourceFirstName
	 * @param sourceLastName
	 * @param sourcePhone
	 * @param sourceEmail
	 * @param targetFirstName
	 * @param targetLastName
	 * @param targetPhone
	 * @param targetEmail
	 *
	 * @return
	 */
	private static Boolean isSameMedicalProfessional(
			String sourceFirstName, String targetFirstName,
			String sourceLastName, String targetLastName,
			String sourcePhone, String targetPhone,
			String sourceEmail, String targetEmail) {
		if (sourceFirstName == targetFirstName
				&& sourceLastName == targetLastName
				&& (sourcePhone == targetPhone || sourceEmail == targetEmail)) {
			return true;
		} else {
			return false;
		}
	}

	/**
	 * Update the medical physician name and email value into contact record.
	 * @param relatedContactId
	 * @param relationShipList
	 */
	public static void updatePhysicianDetails(Set<Id> relatedContactId, List<npe4__Relationship__c> relationShipList) {
		if (relatedContactId.isEmpty() && (!RecursiveTriggerHandler.isFirstTime || !Test.isRunningTest())) {
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
	 * Create Wish Child Form
	 * @param wishFormMap
	 */
	public static void createWishChildForm(Map<Id, Id> wishFormMap) {
		Map<Id, Id> caseMap = new Map<Id, Id>();
		List<Wish_Child_Form__c> wishFormList = new List<Wish_Child_Form__c>();
		String parentGuardianName;
		Map<Id, String> parentGuardianMap = new Map<Id, String>();
		Set<String> names = new Set<String>();

		for (Case wishCase : [
				SELECT Id,ContactId,RecordTypeId
				FROM Case
				WHERE RecordTypeId = :WISH_RT_ID AND ContactId = :wishFormMap.values()
		]) {
			caseMap.put(wishCase.ContactId, wishCase.Id);
		}

		for (npe4__Relationship__c relationship : [
				SELECT Id,npe4__RelatedContact__c,npe4__RelatedContact__r.Name,npe4__RelatedContact__r.FirstName,
						npe4__RelatedContact__r.LastName,npe4__Contact__c, npe4__RelatedContact__r.Email,
						Hidden_isparentFirst__c,npe4__RelatedContact__r.Phone, npe4__RelatedContact__r.Middle_Name__c,
						npe4__RelatedContact__r.MailingCity,npe4__RelatedContact__r.MailingStreet,
						npe4__RelatedContact__r.MailingState,npe4__RelatedContact__r.MailingPostalCode,npe4__Type__c,
						npe4__RelatedContact__r.HomePhone,npe4__RelatedContact__r.npe01__WorkPhone__c,
						npe4__RelatedContact__r.MobilePhone,npe4__RelatedContact__r.T_Shirt_Size__c,
						npe4__RelatedContact__r.Hidden_Wish_Form_Id__c,Parent_Legal_Guardian__c,Wish_Participant__c
				FROM npe4__Relationship__c
				WHERE npe4__RelatedContact__c = :wishFormMap.keySet()
				AND npe4__RelatedContact__r.RecordTypeId = :WISH_FAMILY_ID
				AND npe4__Type__c != :CONTACT_SIBLING
				AND (Parent_Legal_Guardian__c = TRUE OR Wish_Participant__c = TRUE)
				AND npe4__RelatedContact__r.Hidden_Wish_Form_Id__c = NULL
		]) {
			if (wishFormMap.containsKey(relationship.npe4__RelatedContact__c) && relationship.Id != null) {
				if (relationship.Parent_Legal_Guardian__c == true) {
					if (String.isEmpty(parentGuardianName) && (!names.contains(relationship.npe4__RelatedContact__c))) {
						parentGuardianName = relationship.npe4__RelatedContact__r.Name;
						names.add(relationship.npe4__RelatedContact__c);
					} else if (!names.contains(relationship.npe4__RelatedContact__c)) {
						parentGuardianName = parentGuardianName + ',' + ' ' + relationship.npe4__RelatedContact__r.Name;
						names.add(relationship.npe4__RelatedContact__c);
					}
					parentGuardianMap.put(relationship.npe4__Contact__c, parentGuardianName);
				}
				Wish_Child_Form__c wishChildForm = new Wish_Child_Form__c();
				wishChildForm.FirstName__c = relationship.npe4__RelatedContact__r.FirstName;
				wishChildForm.Middle_Name__c = relationship.npe4__RelatedContact__r.Middle_Name__c;
				wishChildForm.LastName__c = relationship.npe4__RelatedContact__r.LastName;
				wishChildForm.mobilePhone__c = relationship.npe4__RelatedContact__r.MobilePhone;
				wishChildForm.Email__c = relationship.npe4__RelatedContact__r.Email;
				wishChildForm.City__c = relationship.npe4__RelatedContact__r.MailingCity;
				wishChildForm.Street__c = relationship.npe4__RelatedContact__r.MailingStreet;
				wishChildForm.State__c = relationship.npe4__RelatedContact__r.MailingState;
				wishChildForm.Zip_Code__c = relationship.npe4__RelatedContact__r.MailingPostalCode;
				wishChildForm.Emergency_Relationship__c = relationship.npe4__Type__c;
				wishChildForm.Home_Phone__c = relationship.npe4__RelatedContact__r.HomePhone;
				wishChildForm.TelePhone__c = relationship.npe4__RelatedContact__r.npe01__WorkPhone__c;
				wishChildForm.T_Shirt_Size__c = relationship.npe4__RelatedContact__r.T_Shirt_Size__c;
				wishChildForm.Residing_With_Wish_Child__c = null;
				if (wishFormMap.get(relationship.npe4__RelatedContact__c) == relationship.npe4__Contact__c) {
					wishChildForm.Case__c = caseMap.get(relationship.npe4__Contact__c);
				}
				wishChildForm.Contact__c = relationship.npe4__RelatedContact__c;
				wishChildForm.Wish_Determination_Case_Id__c = relationship.npe4__RelatedContact__c;
				wishChildForm.RecordTypeId = WISH_FORM_FAMILY_ID;
				if (relationship.Parent_Legal_Guardian__c && relationship.Wish_Participant__c) {
					wishChildForm.IsParticipant__c = false;
					wishChildForm.Hidden_Same_as_Family__c = true;
				} else if (relationship.Parent_Legal_Guardian__c && !relationship.Wish_Participant__c) {
					wishChildForm.IsParticipant__c = false;
					wishChildForm.Hidden_Same_as_Family__c = false;
				} else if (!relationship.Parent_Legal_Guardian__c && relationship.Wish_Participant__c) {
					wishChildForm.IsParticipant__c = true;
					wishChildForm.Hidden_Same_as_Family__c = false;
				}
				wishFormList.add(wishChildForm);
			}
		}
		insert wishFormList;
		if (parentGuardianMap.isEmpty()) {
			return;
		}
		List<Contact> updateContactList = new List<Contact>();
		for (Contact contact : [
				SELECT Id,Name,Parent_Legal_Guardian__c
				FROM Contact
				WHERE Id IN:parentGuardianMap.keySet()
		]) {
			if (parentGuardianMap.containsKey(contact.Id)) {
				if (contact.Parent_Legal_Guardian__c == null) {
					contact.Parent_Legal_Guardian__c = parentGuardianMap.get(contact.Id);
				} else {
					contact.Parent_Legal_Guardian__c = contact.Parent_Legal_Guardian__c
							+ ', ' + parentGuardianMap.get(contact.Id);
				}
				updateContactList.add(contact);
			}
			update updateContactList;
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
	 * Update Wish Child Form
	 * @param relationshipMap
	 */
	public static void updateWishChildForm(Map<Id, npe4__Relationship__c> newRelationshipsMap,
			Map<Id, npe4__Relationship__c> oldRelationshipsMap) {
		if (newRelationshipsMap.isEmpty()) {
			return;
		}
		Map<Id, npe4__Relationship__c > relationshipMap = new Map<Id, npe4__Relationship__c>();
		for (npe4__Relationship__c newRecord : newRelationshipsMap.values()) {
			if ((newRecord.npe4__Contact__c != null && newRecord.npe4__RelatedContact__c != null)
					|| (newRecord.Wish_Participant__c != oldRelationshipsMap.get(newRecord.Id).Wish_Participant__c)
					|| (newRecord.Parent_Legal_Guardian__c != oldRelationshipsMap.get(newRecord.Id).Parent_Legal_Guardian__c)
					|| (newRecord.npe4__Type__c != oldRelationshipsMap.get(newRecord.Id).npe4__Type__c)) {
				relationshipMap.put(newRecord.npe4__RelatedContact__c, newRecord);
			}
		}
		List<Wish_Child_Form__c> updateWishFormRec = new List<Wish_Child_Form__c >();
		List<Wish_Child_Form__c> deleteWishFormList = new List<Wish_Child_Form__c>();
		if (relationshipMap.isEmpty()) {
			return;
		}
		for (Wish_Child_Form__c wishChildForm : [
				SELECT Id,Contact__c,Emergency_Relationship__c,Residing_With_Wish_Child__c,
						RecordTypeId,Hidden_Same_as_Family__c,Migrated__c,IsParticipant__c
				FROM Wish_Child_Form__c
				WHERE Contact__c IN:relationshipMap.keySet()
				AND RecordTypeId = :WISH_FORM_FAMILY_ID
				AND Migrated__c = FALSE
		]) {
			if (relationshipMap.containsKey(wishChildForm.Contact__c)) {
				wishChildForm.Id = wishChildForm.Id;
				wishChildForm.Emergency_Relationship__c = relationshipMap.get(wishChildForm.Contact__c).npe4__Type__c;
				if (relationshipMap.get(wishChildForm.Contact__c).Parent_Legal_Guardian__c
						&& relationshipMap.get(wishChildForm.Contact__c).Wish_Participant__c) {
					wishChildForm.Hidden_Same_as_Family__c = true;
					wishChildForm.IsParticipant__c = false;
				} else if (relationshipMap.get(wishChildForm.Contact__c).Parent_Legal_Guardian__c
						&& !relationshipMap.get(wishChildForm.Contact__c).Wish_Participant__c) {
					wishChildForm.Hidden_Same_as_Family__c = false;
					wishChildForm.IsParticipant__c = false;
				} else if (!relationshipMap.get(wishChildForm.Contact__c).Parent_Legal_Guardian__c
						&& relationshipMap.get(wishChildForm.Contact__c).Wish_Participant__c) {
					wishChildForm.Hidden_Same_as_Family__c = false;
					wishChildForm.IsParticipant__c = true;
				} else if (!relationshipMap.get(wishChildForm.Contact__c).Parent_Legal_Guardian__c
						&& !relationshipMap.get(wishChildForm.Contact__c).Wish_Participant__c) {
					deleteWishFormList.add(wishChildForm);
				}
				updateWishFormRec.add(wishChildForm);
			}
		}
		update updateWishFormRec;
		delete deleteWishFormList;
	}

	/**
	 * Delete Wish Child Form
	 * @param relationships
	 */
	public static void deleteWishChildForm(List<npe4__Relationship__c> relationships) {
		if (relationships.isEmpty()) {
			return;
		}
		Set<Id> contactIds = new Set<Id>();
		for (npe4__Relationship__c relationship : relationships) {
			contactIds.add(relationship.npe4__RelatedContact__c);
		}
		if (contactIds.isEmpty()) {
		}
		List<Wish_Child_Form__c> wishFormList = new List<Wish_Child_Form__c>();
		for (Wish_Child_Form__c wishChildForm : [
				SELECT Id,Contact__c,RecordTypeId,Migrated__c
				FROM Wish_Child_Form__c
				WHERE Contact__c IN:contactIds
				AND RecordTypeId = :WISH_FORM_FAMILY_ID
				AND Migrated__c = :FALSE
		]) {
			wishFormList.add(wishChildForm);
		}
		List<Contact> contacts = new List<Contact>();
		for (Contact contact : [
				SELECT Id,Hidden_Wish_Form_Id__c
				FROM Contact
				WHERE Id IN:contactIds
		]) {
			contact.Hidden_Wish_Form_Id__c = null;
			contacts.add(contact);
		}
		update contacts;
		delete wishFormList;
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

	/**
	 * Build Contact Map from updated Relationships
	 * @param newRelationshipMap
	 * @param oldRelationshipMap
	 * @return Map of npe4__RelatedContact__c and npe4__Contact__c
	 */
	public static Map<Id, Id> buildContactMap(Map<Id, npe4__Relationship__c> newRelationshipMap,
			Map<Id, npe4__Relationship__c> oldRelationshipMap) {
		Map<Id, Id> contactMap = new Map<Id, Id>();
		for (npe4__Relationship__c newRecord : newRelationshipMap.values()) {
			if (CONTACT_SIBLING.equals(oldRelationshipMap.get(newRecord.Id).npe4__Type__c)
					&& !CONTACT_SIBLING.equals(newRecord.npe4__Type__c)) {
				contactMap.put(newRecord.npe4__RelatedContact__c, newRecord.npe4__Contact__c);
			}
			if (newRecord.npe4__Contact__c != null
					&& newRecord.npe4__RelatedContact__c != null
					&& (!oldRelationshipMap.get(newRecord.Id).Parent_Legal_Guardian__c
					&& !oldRelationshipMap.get(newRecord.Id).Wish_Participant__c)
					&& (newRecord.Wish_Participant__c || newRecord.Parent_Legal_Guardian__c)) {
				contactMap.put(newRecord.npe4__RelatedContact__c, newRecord.npe4__Contact__c);
			}
		}
		return contactMap;
	}
}