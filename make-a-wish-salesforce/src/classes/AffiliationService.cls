/**
 * @description Affiliation Service, centralizes Affiliation business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 10/03/2020
 */
public class AffiliationService {

	private static final String TREATING_MED_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL;
	private static final String BEST_CONTACT = Constant_AC.LEAD_DV_FORM_TYPE_BEST_CONTACT;
	private static final String ALT1_MED_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL;
	private static final String ALT2_MED_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL;
	private static final String CURRENT_TREATING_FACILITY = Constant_AC.ORG_AFFILIATION_TREATING_FACILITY_CURRENT;
	private final static Id HOSPITAL_TREATMENT_ID = Constant_AC.HOSPITAL_TREATMENT_ID;
	private final static String WISH_FAMILY_LABEL = Constant_AC.WISH_FAMILY_RT_LABEL;
	private final static String CONTACT_WISH_CHILD_LABEL = Constant_AC.CONTACT_WISH_CHILD_RT_LABEL;
	private final static String TREATING_FACILITY_CURRENT = Constant_AC.ORG_AFFILIATION_TREATING_FACILITY_CURRENT;

	/**
	 * Build Medical Affiliations
	 * @param convertedLead
	 * @param medicalAccountMap
	 * @return List of Affiliations
	 */
	public static List<npe5__Affiliation__c> buildHospitalMedicalAffiliations(Lead convertedLead,
			Map<String, Account> medicalAccountMap) {
		List<npe5__Affiliation__c> affiliationList = new List<npe5__Affiliation__c>();
		if (convertedLead.Hidden_DV_form_Medical_professional_Type__c != null) {
			npe5__Affiliation__c newAff = new npe5__Affiliation__c();
			newAff.npe5__Contact__c = convertedLead.ConvertedContactId;
			newAff.Treating_Facility__c = CURRENT_TREATING_FACILITY;
			if (convertedLead.Hidden_DV_form_Medical_professional_Type__c == ALT2_MED_PROFESSIONAL
					&& medicalAccountMap.containsKey(convertedLead.Alternate2HospitalTreatmentFacility__c)
					&& convertedLead.HiddenAlternate2MedProfessionalId__c == null) {
				if (medicalAccountMap.containsKey(convertedLead.Alternate2HospitalTreatmentFacility__c)) {
					newAff.npe5__Organization__c = medicalAccountMap.get(convertedLead.Alternate2HospitalTreatmentFacility__c).Id;
				}
				affiliationList.add(newAff);
			} else if (convertedLead.Hidden_DV_form_Medical_professional_Type__c == ALT1_MED_PROFESSIONAL
					&& medicalAccountMap.containsKey(convertedLead.Alternate1HospitalTreatmentFacility__c)
					&& convertedLead.HiddenAlternate1MedProfessionalId__c == null) {
				if (medicalAccountMap.containsKey(convertedLead.Alternate1HospitalTreatmentFacility__c)) {
					newAff.npe5__Organization__c = medicalAccountMap.get(convertedLead.Alternate1HospitalTreatmentFacility__c).Id;
				}
				affiliationList.add(newAff);
			} else if ((convertedLead.Hidden_DV_form_Medical_professional_Type__c == BEST_CONTACT
					|| convertedLead.Hidden_DV_form_Medical_professional_Type__c == TREATING_MED_PROFESSIONAL)
					&& medicalAccountMap.containsKey(convertedLead.Hospital_Treatment_Facility_Treating__c)
					&& convertedLead.Treating_Medical_Professional_Contact_Id__c == null) {
				if (medicalAccountMap.containsKey(convertedLead.Hospital_Treatment_Facility_Treating__c)) {
					newAff.npe5__Organization__c = medicalAccountMap.get(convertedLead.Hospital_Treatment_Facility_Treating__c).Id;
				}
				affiliationList.add(newAff);
			}
		}
		return affiliationList;
	}

	/**
	 * Build Affiliations from Lead
	 * @param existingMedicalProfIdMap
	 * @param wishChildContactMap
	 * @return List of Affiliations
	 */
	public static List<npe5__Affiliation__c> buildMedicalAndChildAffiliations(Map<Id, Lead> existingMedicalProfIdMap,
			Map<Id, Contact> wishChildContactMap){
		List<npe5__Affiliation__c> affiliationList = new List<npe5__Affiliation__c>();
		String wishFamilyRtLabel = WISH_FAMILY_LABEL;
		if (!existingMedicalProfIdMap.isEmpty() || !wishChildContactMap.isEmpty()) {
			for (npe5__Affiliation__c affiliation : [
					SELECT npe5__Organization__c, npe5__Organization__r.RecordTypeId, npe5__Contact__c, Constituent_Code__c
					FROM npe5__Affiliation__c
					WHERE (npe5__Organization__r.RecordTypeId = :HOSPITAL_TREATMENT_ID
					OR Constituent_Code__c = :wishFamilyRtLabel)
			]) {
				if (existingMedicalProfIdMap.containsKey(affiliation.npe5__Contact__c)
						&& affiliation.npe5__Organization__r.RecordTypeId == HOSPITAL_TREATMENT_ID) {
					npe5__Affiliation__c newAff = new npe5__Affiliation__c();
					newAff.npe5__Contact__c = existingMedicalProfIdMap.get(affiliation.npe5__Contact__c).ConvertedContactId;
					newAff.Treating_Facility__c = TREATING_FACILITY_CURRENT;
					newAff.npe5__Organization__c = affiliation.npe5__Organization__c;
					affiliationList.add(newAff);
				}
				if (wishChildContactMap.containsKey(affiliation.npe5__Contact__c) && affiliation.Constituent_Code__c == wishFamilyRtLabel) {
					affiliation.Constituent_Code__c = CONTACT_WISH_CHILD_LABEL;
					affiliationList.add(affiliation);
				}
			}
		}
		return affiliationList;
	}
}