/**
 * @description Lead Service, centralizes Lead business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 2/27/2020
 */
public class LeadService {

	/**
	 * Revert Chapter Name Change
	 * @param leadIds
	 * @return Lead Map
	 */
	public static Map<Id, Lead> revertChapterNameChange(List<Id> leadIds) {
		Map<Id, Lead> leadUpdateMap = new Map<Id, Lead>();
		for (Lead processLead : [
				SELECT Id, ChapterName__c, Hidden_Chapter_Change_Confirmation__c
				FROM Lead
				WHERE Id IN :leadIds
		]) {
			Lead updateLead = new Lead(Id = processLead.Id);
			updateLead.ChapterName__c = processLead.Hidden_Chapter_Change_Confirmation__c;
			updateLead.Hidden_Chapter_Change_Confirmation__c = processLead.Hidden_Chapter_Change_Confirmation__c;
			leadUpdateMap.put(updateLead.Id, updateLead);
		}
		update leadUpdateMap.values();
		return leadUpdateMap;
	}

	/**
	 * Backup Chapter Name Change
	 * @param leadIds
	 * @return Lead Map
	 */
	public static Map<Id, Lead> backupChapterNameChange(List<Id> leadIds) {
		Map<Id, Lead> leadUpdateMap = new Map<Id, Lead>();
		for (Lead processLead : [
				SELECT Id, ChapterName__c, Hidden_Chapter_Change_Confirmation__c
				FROM Lead
				WHERE Id IN :leadIds
		]) {
			Lead updateLead = new Lead(Id = processLead.Id);
			updateLead.Hidden_Chapter_Change_Confirmation__c = processLead.ChapterName__c;
			leadUpdateMap.put(updateLead.Id, updateLead);
		}
		update leadUpdateMap.values();
		return leadUpdateMap;
	}

	/**
	 * Reset Lead fields
	 * @param leadId
	 * @return Lead
	 */
	public static Lead resetLead(Id leadId) {
		Lead lead = [
				SELECT Id,Hidden_Potential_Rush__c,
						Part_A_Received__c,Part_A_Sent__c, Status, Part_A_Form_Password__c,
						Diagnosis_Given_By_Referrer__c, ICD_Given_By_Referrer__c,
						PD_Condition_Description__c, PD_ICD_Code__c
				FROM Lead
				WHERE Id = :leadId
		];
		lead.Admitting_diagnosis__c = '';
		lead.Angina__c = '';
		lead.Any_medical_reason_for_moving_quickly__c = lead.Hidden_Potential_Rush__c;
		lead.Arrhythmia__c = '';
		lead.Child_will_ultimately_die_prematurely__c = false;
		lead.Chronic_Heart_Failure__c = '';
		lead.Chronic_Hepatitis__c = '';
		lead.Congenital_Heart_Disease__c = '';
		lead.Convulsive_Disorders__c = '';
		lead.Current_Condition_Label__c = '';
		lead.Current_Condition_Label__c = '';
		lead.Current_Condition_Label__c = '';
		lead.Debilitation_may_extend_over_many_years__c = false;
		lead.DV_Present__c = false;
		lead.Heart_Failure__c = '';
		lead.I_am_Recognized_To_Practice_As_a__c = '';
		lead.I_m_Part_of_The_Treating_HealthCare_Team__c = '';
		lead.ICU_Admissions__c = '';
		lead.Increased_probability_of_premature_death__c = false;
		lead.Is_in_a_Comatose_Vegetative_State__c = '';
		lead.isSign__c = false;
		lead.Lung_Disease__c = '';
		lead.None_of_these_statements_describes_Child__c = false;
		lead.Number_hospital_admissions__c = null;
		lead.Part_A_Received__c = null;
		lead.Part_A_Sent__c = Date.today();
		lead.PD_Condition_Description__c = lead.Diagnosis_Given_By_Referrer__c;
		lead.PD_ICD_Code__c = lead.ICD_Given_By_Referrer__c;
		lead.Pending_Diagnosis_Date__c = Date.today();
		lead.Please_Explain__c = '';
		lead.Please_Explain_Deteriorate__c = '';
		lead.PR_Diagnosis__c = '';
		lead.Provided_additional_information__c = '';
		lead.Provider_Signature__c = '';
		lead.Pulmonary_Hypertension__c = '';
		lead.Responds_to_treatment_with_normal_health__c = false;
		lead.RFI_Form_Info_Hidden__c = lead.Status;
		lead.Risk_of_complications_premature_death__c = false;
		lead.Rush__c = false;
		lead.SD1_Condition_Description__c = '';
		lead.SD1_ICD_Code__c = null;
		lead.SD2_Condition_Description__c = '';
		lead.SD2_ICD_Code__c = null;
		lead.SD3_Condition_Description__c = '';
		lead.SD3_ICD_Code__c = null;
		lead.SD4_Condition_Description__c = '';
		lead.SD4_ICD_Code__c = null;
		lead.Status = Constant_AC.LEAD_STATUS_REFERRED;
		lead.Strokes__c = '';
		lead.Sub_Status__c = Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION;
		lead.This_Statement_Describes_My_Patient__c = '';
		lead.Travel_algorithm__c = '';
		lead.Travel_Restriction__c = '';
		lead.Treatment_may_be_feasible_but_can_fail__c = false;
		lead.Treatment_may_prolong_normal_activities__c = false;
		lead.Unplanned_hospital_admissions__c = '';
		lead.Ventilator__c = '';
		lead.Why_do_you_feel_would_be_eligible_Wish__c = '';
		lead.Will_Child_s_Condition_Deteriorate__c = '';
		update lead;
		return lead;
	}

	/**
	 * Reset Lead fields
	 * @param leadId
	 * @return Lead
	 */
	public static Lead resetLeadDvMedicalSummary(Id leadId) {
		Lead lead = [
				SELECT Id,Of_Times_Email_Sent__c,Qualifying_Diagnosis__c, Qualifying_ICD__c,
						Hidden_Potential_Rush__c, Diagnosis_Given_By_Referrer__c, ICD_Given_By_Referrer__c,
						PD_Condition_Description__c, PD_ICD_Code__c, Part_A_Sent__c, Part_A_Received__c,
						Part_A_Form_Password__c, Hidden_DV_form_Medical_professional_Type__c, PR_Diagnosis__c,
						Sub_Status__c,Treating_Medical_Professional_Email__c,HiddenMedicalProfessionalEmail__c, Status
				FROM Lead
				WHERE Id = :leadId
		];
		if (lead.Of_Times_Email_Sent__c == null) {
			lead.Of_Times_Email_Sent__c = 0;
		}
		lead.Admitting_diagnosis__c = '';
		lead.Angina__c = '';
		lead.Any_medical_reason_for_moving_quickly__c = lead.Hidden_Potential_Rush__c;
		lead.Arrhythmia__c = '';
		lead.Child_will_ultimately_die_prematurely__c = false;
		lead.Chronic_Heart_Failure__c = '';
		lead.Chronic_Hepatitis__c = '';
		lead.Congenital_Heart_Disease__c = '';
		lead.Convulsive_Disorders__c = '';
		lead.Current_Condition_Label__c = '';
		lead.Current_Condition_Label__c = '';
		lead.Current_Condition_Label__c = '';
		lead.Debilitation_may_extend_over_many_years__c = false;
		lead.DV_Present__c = false;
		lead.Heart_Failure__c = '';
		lead.I_am_Recognized_To_Practice_As_a__c = '';
		lead.I_m_Part_of_The_Treating_HealthCare_Team__c = '';
		lead.ICU_Admissions__c = '';
		lead.Increased_probability_of_premature_death__c = false;
		lead.Is_in_a_Comatose_Vegetative_State__c = '';
		lead.isSign__c = false;
		lead.Lung_Disease__c = '';
		lead.None_of_these_statements_describes_Child__c = false;
		lead.Number_hospital_admissions__c = null;
		lead.Part_A_Received__c = null;
		lead.Part_A_Sent__c = Date.today();
		lead.PD_Condition_Description__c = lead.Diagnosis_Given_By_Referrer__c;
		lead.PD_ICD_Code__c = lead.ICD_Given_By_Referrer__c;
		lead.Pending_Diagnosis_Date__c = Date.today();
		lead.Please_Explain__c = '';
		lead.Please_Explain_Deteriorate__c = '';
		lead.PR_Diagnosis__c = '';
		lead.Provided_additional_information__c = '';
		lead.Provider_Signature__c = '';
		lead.Pulmonary_Hypertension__c = '';
		lead.Responds_to_treatment_with_normal_health__c = false;
		lead.RFI_Form_Info_Hidden__c = lead.Status;
		lead.Risk_of_complications_premature_death__c = false;
		lead.Rush__c = false;
		lead.SD1_Condition_Description__c = '';
		lead.SD1_ICD_Code__c = null;
		lead.SD2_Condition_Description__c = '';
		lead.SD2_ICD_Code__c = null;
		lead.SD3_Condition_Description__c = '';
		lead.SD3_ICD_Code__c = null;
		lead.SD4_Condition_Description__c = '';
		lead.SD4_ICD_Code__c = null;
		lead.Status = Constant_AC.LEAD_STATUS_REFERRED;
		lead.Strokes__c = '';
		lead.Sub_Status__c = Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION;
		lead.This_Statement_Describes_My_Patient__c = '';
		lead.Travel_algorithm__c = '';
		lead.Travel_Restriction__c = '';
		lead.Treatment_may_be_feasible_but_can_fail__c = false;
		lead.Treatment_may_prolong_normal_activities__c = false;
		lead.Unplanned_hospital_admissions__c = '';
		lead.Ventilator__c = '';
		lead.Why_do_you_feel_would_be_eligible_Wish__c = '';
		lead.Will_Child_s_Condition_Deteriorate__c = '';
		lead.Hidden_DV_form_Medical_professional_Type__c = 'Treating Medical Professional';
		lead.HiddenMedicalProfessionalEmail__c = lead.Treating_Medical_Professional_Email__c;
		lead.Of_Times_Email_Sent__c = 0;
		lead.Of_Times_Email_Sent__c = lead.Of_Times_Email_Sent__c + 1;
		lead.Part_A_Form_Password__c = Utils.generateRandomNumber(6);
		update lead;
		return lead;
	}

	/**
	 * Merge a list Leads into one Lead
	 * @param leadTarget
	 * @param leadDuplicates
	 * @return
	 */
	public static Boolean mergeLeads(Lead leadTarget, List<Lead> leadDuplicates) {
		Boolean successfulMerge = false;
		Lead winnerMakePrivate = new Lead(Id = leadTarget.Id, Override_Dupe_Check__c = true);
		List<Lead> losersMakePrivate = new List<Lead>();
		for (Lead leadDuplicate : leadDuplicates) {
			Lead loserMakePrivate = new Lead(Id = leadDuplicate.Id, Override_Dupe_Check__c = true);
			losersMakePrivate.add(loserMakePrivate);
		}
		update winnerMakePrivate;
		if (losersMakePrivate.size() > 0) {
			update losersMakePrivate;
		}
		merge winnerMakePrivate leadDuplicates;
		successfulMerge = true;
		return successfulMerge;
	}

	/**
	 * Find Lead Duplicates
	 * @param firstName
	 * @param lastName
	 * @param phone
	 * @param email
	 * @param street
	 * @param city
	 * @param state
	 * @param postalCode
	 * @param dateOfBirth
	 * @param leadsFilterOut
	 * @return List of Leads
	 */
	public static List<Lead> findLeadDuplicates(String firstName, String lastName,
			String phone, String email, String street, String city, String state,
			String postalCode, Date dateOfBirth, List<Id> leadsFilterOut) {
		return [
				SELECT Id, FirstName, Name, LastName, Email,
						Phone, City, DOB__c, State, PostalCode,
						ChapterName__r.Name, ChapterName__c
				FROM Lead
				WHERE ((LastName = :lastName AND FirstName = :firstName)
				OR (LastName = :lastName AND ((State = :state AND City = :city AND Street = :street
				AND PostalCode = :postalCode) OR (Email != '' AND Email = :email)))
				OR (FirstName = :firstName AND ((State = :state AND City = :city AND Street = :street
				AND PostalCode = :postalCode) OR Phone = :phone OR (Email != '' AND Email = :email)))
				OR (DOB__c = :dateOfBirth AND ((State = :state AND City = :city
				AND Street = :street AND PostalCode = :postalCode) OR (Email != '' AND Email = :email)))
				OR (DOB__c = :dateOfBirth AND (LastName = :lastName OR FirstName = :firstName)))
				AND Id NOT IN :leadsFilterOut
				AND IsConverted = FALSE
		];
	}

	/**
	 * Find Lead Duplicates
	 * @param firstName
	 * @param lastName
	 * @param phone
	 * @param email
	 * @param street
	 * @param city
	 * @param state
	 * @param postalCode
	 * @param dateOfBirth
	 * @param leadsFilterOut
	 * @param chapterName
	 * @return List of Leads
	 */
	public static List<Lead> findLeadDuplicatesWithChapter(String firstName, String lastName,
			String phone, String email, String street, String city, String state,
			String postalCode, Date dateOfBirth, List<Id> leadsFilterOut, Id chapterName) {
		return [
				SELECT Id, FirstName,Name, LastName, Email, Phone, City, DOB__c,State, PostalCode,
						ChapterName__r.Name, ChapterName__c
				FROM Lead
				WHERE ((LastName = :lastName AND FirstName = :firstName)
				OR (LastName = :lastName AND ((State = :state AND City = :city AND Street = :street
				AND PostalCode = :postalCode) OR Email = :email))
				OR (FirstName = :firstName AND ((State = :state AND City = :city AND Street = :street
				AND PostalCode = :postalCode) OR Phone = :phone OR Email = :email))
				OR (DOB__c = :dateOfBirth AND ((State = :state AND City = :city
				AND Street = :street AND PostalCode = :postalCode)
				OR Email = :email)) OR (DOB__c = :dateOfBirth
				AND (LastName = :lastName OR FirstName = :firstName)))
				AND Id NOT IN :leadsFilterOut
				AND IsConverted = FALSE
				AND ChapterName__c = :chapterName
		];
	}

	/**
	 * Check if a Medical Professional contact equal
	 * @param sourceFirstName
	 * @param sourceLastName
	 * @param sourcePhone
	 * @param sourceEmail
	 * @param targetFirstName
	 * @param targetLastName
	 * @param targetPhone
	 * @param targetEmail
	 * @return
	 */
	public static Boolean isSameMedicalProfessional(
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