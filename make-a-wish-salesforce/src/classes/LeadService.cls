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

	public static Lead resetLead(Id leadId) {
		Lead lead = [
				SELECT Id,Hidden_Potential_Rush__c,
						Part_A_Received__c,Part_A_Sent__c, Status, Part_A_Form_Password__c,
						Diagnosis_Given_By_Referrer__c, ICD_Given_By_Referrer__c,
						PD_Condition_Description__c, PD_ICD_Code__c
				FROM Lead
				WHERE Id = :leadId
		];
		lead.PR_Diagnosis__c = '';
		lead.PD_ICD_Code__c = lead.ICD_Given_By_Referrer__c;
		lead.PD_Condition_Description__c = lead.Diagnosis_Given_By_Referrer__c;
		lead.I_am_Recognized_To_Practice_As_a__c = '';
		lead.I_m_Part_of_The_Treating_HealthCare_Team__c = '';
		lead.Is_in_a_Comatose_Vegetative_State__c = '';
		lead.Part_A_Received__c = null;
		lead.Part_A_Sent__c = Date.today();
		lead.Why_do_you_feel_would_be_eligible_Wish__c = '';
		lead.Any_medical_reason_for_moving_quickly__c = lead.Hidden_Potential_Rush__c;
		lead.Rush__c = false;
		lead.Please_Explain__c = '';
		lead.Will_Child_s_Condition_Deteriorate__c = '';
		lead.Please_Explain_Deteriorate__c = '';
		lead.Provider_Signature__c = '';
		lead.Current_Condition_Label__c = '';
		lead.Provided_additional_information__c = '';
		lead.This_Statement_Describes_My_Patient__c = '';
		lead.Child_will_ultimately_die_prematurely__c = false;
		lead.Treatment_may_be_feasible_but_can_fail__c = false;
		lead.Treatment_may_prolong_normal_activities__c = false;
		lead.Debilitation_may_extend_over_many_years__c = false;
		lead.Increased_probability_of_premature_death__c = false;
		lead.Risk_of_complications_premature_death__c = false;
		lead.Responds_to_treatment_with_normal_health__c = false;
		lead.None_of_these_statements_describes_Child__c = false;
		lead.SD1_ICD_Code__c = null;
		lead.SD1_Condition_Description__c = '';
		lead.SD2_ICD_Code__c = null;
		lead.SD2_Condition_Description__c = '';
		lead.SD3_ICD_Code__c = null;
		lead.SD3_Condition_Description__c = '';
		lead.SD4_ICD_Code__c = null;
		lead.SD4_Condition_Description__c = '';
		lead.Current_Condition_Label__c = '';
		lead.Chronic_Hepatitis__c = '';
		lead.Pulmonary_Hypertension__c = '';
		lead.Strokes__c = '';
		lead.Convulsive_Disorders__c = '';
		lead.Congenital_Heart_Disease__c = '';
		lead.Chronic_Heart_Failure__c = '';
		lead.Heart_Failure__c = '';
		lead.Arrhythmia__c = '';
		lead.Angina__c = '';
		lead.Ventilator__c = '';
		lead.Lung_Disease__c = '';
		lead.Travel_Restriction__c = '';
		lead.Travel_algorithm__c = '';
		lead.Current_Condition_Label__c = '';
		lead.isSign__c = false;
		lead.DV_Present__c = false;
		lead.Unplanned_hospital_admissions__c = '';
		lead.Number_hospital_admissions__c = null;
		lead.Admitting_diagnosis__c = '';
		lead.ICU_Admissions__c = '';
		lead.Sub_Status__c = Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION;
		lead.Pending_Diagnosis_Date__c = Date.today();
		lead.Status = Constant_AC.LEAD_STATUS_REFERRED;
		lead.RFI_Form_Info_Hidden__c = lead.Status;
		update lead;
		return lead;
	}
}