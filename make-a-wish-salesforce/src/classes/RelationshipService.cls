/**
 * @description Relationship Service, centralizes Relationship business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 10/23/2020
 */
public class RelationshipService {

	private final static Id WISH_FAMILY_ID = Constant_AC.WISH_FAMILY_RT_ID;
	private final static Id MEDICAL_PROFESSIONAL_ID = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
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
			Map<String, Boolean> qualifyingMap, Map<String, String> relationshipTypeMap, Set<String> parentGuardianNameSet){
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
}