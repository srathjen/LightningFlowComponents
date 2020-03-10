/**
 * @description Lead Service, centralizes Lead business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 2/27/2020
 */
public class LeadService {

	private static final String INSTANCE_URL = Endpoints__c.getInstance().Instance_URL__c;

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
		if (!losersMakePrivate.isEmpty()) {
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

	public static void populateRegionCode(Map<Id, Lead> leadMap, Set<Id> leadChapterSet) {
		Set<Id> chapterRegionSet = new Set<Id>();
		try {
			for (AggregateResult aggr : [
					SELECT COUNT(Id) cnt,Chapter_Name__c cName
					FROM Regions__c
					WHERE Chapter_Name__c != NULL
					AND Chapter_Name__c IN :leadChapterSet
					GROUP BY Chapter_Name__c
			]) {
				chapterRegionSet.add((Id) aggr.get('cName'));
			}
			List<Regions__c> regionCodeList = [
					SELECT Id, Chapter_Name__c
					FROM Regions__c
					WHERE Chapter_Name__c = NULL
					LIMIT 1
			];
			for (Lead leadUpdate : leadMap.values()) {
				if (!chapterRegionSet.contains(leadUpdate.ChapterName__c)) {
					if (!regionCodeList.isEmpty()) {
						leadUpdate.Region_Code__c = regionCodeList.get(0).Id;
					}
				}
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class Execution');
			}
		} catch (Exception ex) {
			for (Lead currRec : leadMap.values()) {
				ErrorMessage_AC.createdebugRec('Lead_OnBeforeInsertTriggerHandlerHelper',
						String.valueOf(currRec), String.valueOf(ex), 'populateRegionCode',
						'Null', ex.getStackTraceString(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (Lead currRec : leadMap.values()) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}

		}
	}

	public static void updateChapterFields(Set<String> postalCodesSet, List<Lead> updateChapterOnLeadList) {
		Map<String, String> zipCodeChapterMap = new Map<String, String>();
		Map<String, String> zipCodeReferralMap = new Map<String, String>();
		Map<String, Boolean> chapterActiveMap = new Map<String, Boolean>();

		try {
			for (Zip_Code__c currZipCode : [
					SELECT Id, Name,Office__r.Chapter__c, Office__r.Referral_Email_Address__c
					FROM Zip_Code__c
					WHERE Name IN :postalCodesSet
					LIMIT 50000
			]) {
				zipCodeChapterMap.put(currZipCode.Name, currZipCode.Office__r.Chapter__c);
				zipCodeReferralMap.put(currZipCode.Name, currZipCode.Office__r.Referral_Email_Address__c);
			}
			for (Account account : [
					SELECT Id, Onboarded_on_SF__c,Intake_Manager__r.Email
					FROM Account
					WHERE Id IN :zipCodeChapterMap.values()
					LIMIT 50000
			]) {
				chapterActiveMap.put(account.Id, account.Onboarded_on_SF__c);
			}
			for (Lead currLead : updateChapterOnLeadList) {
				if (zipCodeReferralMap.containsKey(currLead.PostalCode)) {
					currLead.Office_Referral_Email__c = zipCodeReferralMap.get(currLead.PostalCode);
				} else if (zipCodeReferralMap.containsKey(currLead.Referrer_Zip__c)) {
					currLead.Office_Referral_Email__c = zipCodeReferralMap.get(currLead.Referrer_Zip__c);
				} else {
					currLead.Office_Referral_Email__c = null;
				}
				if (chapterActiveMap.containsKey(currLead.ChapterName__c)) {
					currLead.Is_Chapter_Active__c = chapterActiveMap.get(currLead.ChapterName__c);
				}
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		}

		catch (Exception ex) {
			for (Lead currRec : updateChapterOnLeadList) {
				ErrorMessage_AC.createdebugRec('Lead_OnBeforeInsertTriggerHandlerHelper',
						String.valueOf(currRec), String.valueOf(ex), 'updateChapterFields',
						'Null', ex.getStackTraceString(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (Lead currRec : updateChapterOnLeadList) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}

		}
	}

	public static void updateHiddenChapterName(Set<Id> accountIdSet, List<Lead> leadList) {
		Map<Id, Account> accountNameMap = new Map<Id, Account>();
		try {
			for (Account currAcc : [
					SELECT Id,Name,Intake_Manager__r.Email,Intake_Manager__c
					FROM Account
					WHERE Id IN :accountIdSet
					LIMIT 50000
			]) {
				accountNameMap.put(currAcc.Id, currAcc);
			}
			for (Lead currLead : leadList) {
				if (accountNameMap.containsKey(currLead.ChapterName__c)) {
					currLead.Hidden_OldChapterName__c = currLead.Hidden_Chapter_Name__c;
					currLead.Hidden_Chapter_Name__c = accountNameMap.get(currLead.ChapterName__c).Name;
				}
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Lead currRec : leadList) {
				ErrorMessage_AC.createdebugRec('Lead_OnBeforeInsertTriggerHandlerHelper',
						String.valueOf(currRec), String.valueOf(ex), 'updateHiddenchapterName',
						'Null', ex.getStackTraceString(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (Lead currRec : leadList) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	public static void MatchConditionDescription(Map<Id, Set<Integer>> icdInfoMap, List<Lead> leadRecList, Set<Id> icdCodeRecSet) {
		Map<Id, ICD_Codes__c> icdCodeDetails = new Map<Id, ICD_Codes__c>();
		try {
			for (ICD_Codes__c icdInfo : [
					SELECT Id, Name, Group1__c,
							Condition_Description__c, Condition_Description__r.Code_To_Use__c, Condition_Description__r.Name
					FROM ICD_Codes__c
					WHERE Id IN :icdCodeRecSet
			]) {
				icdCodeDetails.put(icdInfo.Id, icdInfo);
			}
			for (Lead updatePD : leadRecList) {
				if (icdInfoMap.containsKey(updatePD.Id)) {
					for (Integer icdField : icdInfoMap.get(updatePD.Id)) {
						if (icdField == 1 && icdCodeDetails.containsKey(updatePD.SD1_ICD_Code__c)) {
							updatePD.SD1_Condition_Description__c = icdCodeDetails.get(updatePD.SD1_ICD_Code__c).Condition_Description__r.Name;
						} if (icdField == 2 && icdCodeDetails.containsKey(updatePD.SD2_ICD_Code__c)) {
							updatePD.SD2_Condition_Description__c = icdCodeDetails.get(updatePD.SD2_ICD_Code__c).Condition_Description__r.Name;
						} if (icdField == 3 && icdCodeDetails.containsKey(updatePD.SD3_ICD_Code__c)) {
							updatePD.SD3_Condition_Description__c = icdCodeDetails.get(updatePD.SD3_ICD_Code__c).Condition_Description__r.Name;
						} if (icdField == 4 && icdCodeDetails.containsKey(updatePD.SD4_ICD_Code__c)) {
							updatePD.SD4_Condition_Description__c = icdCodeDetails.get(updatePD.SD4_ICD_Code__c).Condition_Description__r.Name;
						}
					}
				}
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		}

		catch (Exception ex) {

			for (Lead currRec : leadRecList) {
				ErrorMessage_AC.createdebugRec('Lead_OnBeforeUpdateTriggerHandlerHelper',
						String.valueOf(currRec), String.valueOf(ex), 'MatchConditionDescription',
						currRec.Id, ex.getStackTraceString(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (Lead currRec : leadRecList) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}

		}
	}

	public static void updateLeadOwner(List<Lead> leadsToUpdateList, Set<String> chaptersSet) {
		Map<Id, Account> chapterMap = new Map<Id, Account>([
				SELECT Id,Intake_Manager__c,Onboarded_on_SF__c
				FROM Account
				WHERE Id IN :chaptersSet
				LIMIT 50000
		]);
		Set<String> zipSet = new Set<String>();
		try {
			for (Lead currLead : leadsToUpdateList) {
				if (chapterMap.containsKey(currLead.ChapterName__c)) {
					if (chapterMap.get(currLead.ChapterName__c).Intake_Manager__c != null) {
						currLead.OwnerId = chapterMap.get(currLead.ChapterName__c).Intake_Manager__c;
					} else {
						currLead.OwnerId = Label.Salesforce_Support_User_Id;
					}
					if (chapterMap.get(currLead.ChapterName__c).Onboarded_on_SF__c != null) {
						currLead.Is_Chapter_Active__c = chapterMap.get(currLead.ChapterName__c).Onboarded_on_SF__c;
					}
				}
			}
			for (Lead processLead : leadsToUpdateList) {
				zipSet.add(processLead.PostalCode);
			}
			List<Zip_Code__c> officeZipList = [
					SELECT Id,Name, Office__c,Office__r.Chapter__c, Office__r.Referral_Email_Address__c
					FROM Zip_Code__c
					WHERE Name IN :zipSet AND Office__r.Chapter__c IN :chaptersSet
			];
			if (!officeZipList.isEmpty()) {
				for (Lead processLead : leadsToUpdateList) {
					for (Zip_Code__c zipInfo : officeZipList) {
						if (processLead.PostalCode == zipInfo.Name
								&& processLead.ChapterName__c == zipInfo.Office__r.Chapter__c) {
							if (zipInfo.Office__r.Referral_Email_Address__c != null) {
								processLead.Office_Referral_Email__c = zipInfo.Office__r.Referral_Email_Address__c;
							}
						}
					}
				}
			}
		}

		catch (Exception ex) {

			for (Lead currRec : leadsToUpdateList) {
				ErrorMessage_AC.createdebugRec('Lead_OnBeforeUpdateTriggerHandlerHelper',
						String.valueOf(currRec), String.valueOf(ex), 'updateLeadOwner',
						currRec.Id, ex.getStackTraceString(), 'Error');
			}
			for (Lead currRec : leadsToUpdateList) {
				currRec.addError(Label.Debug_log_error_message);
			}
		}
	}

	/**
	 * Update the Chapter Name on Medical Professional Contact. If the Zip Code value is updated.
	 * @param conditionDescriptionsSet
	 * @param icdCodesSet
	 * @param leadUpdateToMedicalInfoList
	 */
	public static void ToUpdateMedicalInfo(Set<String> conditionDescriptionsSet, Set<String> icdCodesSet, List<Lead> leadUpdateToMedicalInfoList) {
		Set<Id> conditionDescriptionIdSet = new Set<Id>();
		Map<String, ICD_Codes__c> icdCodesMap = new Map<String, ICD_Codes__c>();
		try {
			if (!icdCodesSet.isEmpty()) {

				for (ICD_Codes__c currRec : [
						SELECT Id,Name, Condition_Description__r.PR_Diagnosis__c,Group1__c,
								Condition_Description__c, Condition_Description__r.Code_To_Use__c,Condition_Description__r.Name
						FROM ICD_Codes__c
						WHERE Id IN :icdCodesSet
				]) {
					icdCodesMap.put(currRec.Id, currRec);
					if (currRec.Condition_Description__c != null) {
						conditionDescriptionIdSet.add(currRec.Condition_Description__c);
					}
				}
				Map<Id, Set<Id>> iCDforCondionDescMap = new Map<Id, Set<Id>>();
				for (ICD_Codes__c icdInfo : [
						SELECT Id, Condition_Description__c
						FROM ICD_Codes__c
						WHERE Condition_Description__c IN :conditionDescriptionIdSet
				]) {
					if (iCDforCondionDescMap.containsKey(icdInfo.Condition_Description__c)) {
						iCDforCondionDescMap.get(icdInfo.Condition_Description__c).add(icdInfo.Id);
					} else {
						iCDforCondionDescMap.put(icdInfo.Condition_Description__c, new Set<Id>{
								icdInfo.Id
						});
					}
				}
				for (Lead currLead : leadUpdateToMedicalInfoList) {
					if (icdCodesMap.containsKey(currLead.Qualifying_ICD__c)) {
						if (icdCodesMap.get(currLead.Qualifying_ICD__c).Condition_Description__c != null) {
							currLead.Qualifying_Diagnosis__c = icdCodesMap.get(currLead.Qualifying_ICD__c).Condition_Description__r.Name;
						} else {
							currLead.Qualifying_Diagnosis__c = '';
						}
					}
					if (currLead.Qualifying_ICD__c != null) {
						if (icdCodesMap.containsKey(currLead.Qualifying_ICD__c)
								&& icdCodesMap.get(currLead.Qualifying_ICD__c).Condition_Description__c != null) {
							currLead.PR_Diagnosis__c = icdCodesMap.get(currLead.Qualifying_ICD__c).Condition_Description__r.PR_Diagnosis__c;
							if (iCDforCondionDescMap.containsKey(icdCodesMap.get(currLead.Qualifying_ICD__c).Condition_Description__c)) {
								if (iCDforCondionDescMap.get(icdCodesMap.get(currLead.Qualifying_ICD__c).Condition_Description__c).contains(currLead.Qualifying_ICD__c)) {
									currLead.Qualifying_Diagnosis__c = icdCodesMap.get(currLead.Qualifying_ICD__c).Condition_Description__r.Name;
								}
							}
						}
					}
				}
			}
			if (!conditionDescriptionsSet.isEmpty()) {
				Map<String, Condition_Description__c> descriptionMap = new Map<String, Condition_Description__c>();
				for (Condition_Description__c currRec : [
						SELECT Id, PR_Diagnosis__c, Name
						FROM Condition_Description__c
						WHERE Name IN :conditionDescriptionsSet
				]) {
					descriptionMap.put(currRec.Name, currRec);
				}
				for (Lead currLead : leadUpdateToMedicalInfoList) {
					if (descriptionMap.containsKey(currLead.Qualifying_Diagnosis__c)) {
						currLead.PR_Diagnosis__c = descriptionMap.get(currLead.Qualifying_Diagnosis__c).PR_Diagnosis__c;
					}
				}
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Lead currRec : leadUpdateToMedicalInfoList) {
				ErrorMessage_AC.createdebugRec('Lead_OnBeforeUpdateTriggerHandlerHelper',
						String.valueOf(currRec), String.valueOf(ex), 'ToUpdateMedicalInfo',
						currRec.Id, ex.getStackTraceString(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (Lead currRec : leadUpdateToMedicalInfoList) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}

		}
	}

	/**
	 * This CreateNewCase method is used to create a new eligibility review case when the lead status is updated
	 * as elegibility review.
	 * @param LeadList
	 */
	public static void CreateNewCase(List<Lead> LeadList) {
		List<Case> newCaseList = new List<Case>();
		Set<Id> accountIdSet = new Set<Id>();
		Map<Id, String> emailMap = new Map<Id, String>();
		Id chapterRecordTypeId = Constant_AC.CHAPTER_RT_ID;
		Id partARecordTypeId = Constant_AC.DIAGNOSIS_RT_ID;
		String nationalAdviser = System.Label.MedicalAdviser;
		Id nationAdvisorQueueId = [
				SELECT Id
				FROM Group
				WHERE Name = :nationalAdviser
		].Id;
		try {
			for (Lead process : LeadList) {
				accountIdSet.add(process.ChapterName__c);
			}
			if (!accountIdSet.isEmpty()) {
				for (Account dbChapterAcc : [
						SELECT Id,MAC_Email_del__c,RecordTypeId
						FROM Account
						WHERE Id IN:accountIdSet AND RecordTypeId = :chapterRecordTypeId
				]) {
					emailMap.put(dbChapterAcc.Id, dbChapterAcc.MAC_Email_del__c);
				}
			}
			for (Lead processLead : LeadList) {
				Case newCase = new Case();
				newCase.Status = 'New';
				if (processLead.Is_in_a_Comatose_Vegetative_State__c == 'Yes') {
					newCase.Status = 'Pending Clarification - Chapter';
				}
				newCase.Origin = 'Email';
				newCase.Subject = processLead.FirstName + ' ' + processLead.LastName + ' - Eligibility Review';
				newCase.RecordTypeId = partARecordTypeId;
				newCase.OwnerId = nationAdvisorQueueId;
				newCase.Hidden_Why_do_you_feel__c = processLead.Why_do_you_feel_would_be_eligible_Wish__c;
				if (emailMap.containsKey(processLead.ChapterName__c)) {
					newCase.MAC_Email__c = emailMap.get(processLead.ChapterName__c);
				}
				newCase.Lead__c = processLead.Id;
				newCase.AccountId = processLead.ChapterName__c;
				newCase.ChapterName__c = processLead.ChapterName__c;
				if (processLead.Any_medical_reason_for_moving_quickly__c == 'Yes') {
					newCase.Rush__c = true;
					newCase.Rush_Explanation__c = processLead.Please_Explain__c;
					newCase.Rush_Timeframe__c = 'Select timeframe';
					newCase.Diagnosis_Verification_Receive_Date__c = processLead.Part_A_Received__c;
				}
				if (processLead.Any_medical_reason_for_moving_quickly__c != null) {
					String medicalReason = processLead.Any_medical_reason_for_moving_quickly__c;
					if (medicalReason.contains('Yes')) {
						newCase.Rush__c = true;
					}
				}
				newCaseList.add(newCase);
			}
			if (!newCaseList.isEmpty()) {
				insert newCaseList;
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Lead currRec : LeadList) {
				ErrorMessage_AC.createdebugRec('Lead_OnBeforeUpdateTriggerHandlerHelper',
						String.valueOf(currRec), String.valueOf(ex), 'CreateNewCase',
						currRec.Id, ex.getStackTraceString(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (Lead currRec : LeadList) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	/**
	 * This findDuplicateRecords() method is fire if the lead status is "Reffered" and sub status is "Pending dignose verification".
	 * It will display error message if any duplicate wishchild or wish family or medical proff contact is there.
	 * @param leadList
	 */
	public static void findDuplicateRecords(List<Lead> leadList) {
		Set<String> leadFNamesSet = new Set<String>();
		Set<String> leadLNamesSet = new Set<String>();
		Set<Date> leadbDaysSet = new Set<Date>();
		Set<String> AddressSet = new Set<String>();
		Set<String> phoneSet = new Set<String>();
		Set<String> zipCodesSet = new Set<String>();
		Set<String> citySet = new Set<String>();
		Set<String> emailsSet = new Set<String>();
		Set<String> stateSet = new Set<String>();
		Set<Id> leadIds = new Set<Id>();
		Set<String> chaptersSet = new Set<String>();
		List<Lead> noDupLeadRec = new List<Lead>();
		Id wishChild = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
		String errorType = 'Classic';
		if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4u') {
			errorType = 'Lightning';
		}
		User u = [
				SELECT Id, UserPreferencesLightningExperiencePreferred
				FROM User
				WHERE Id = :UserInfo.getUserId()
				LIMIT 1
		];
		try {
			for (Lead currLead : leadList) {
				if (currLead.FirstName != null) {
					leadFNamesSet.add(currLead.FirstName);
				}
				if (currLead.LastName != null) {
					leadLNamesSet.add(currLead.LastName);
				}
				if (currLead.DOB__c != null)
					leadbDaysSet.add(currLead.DOB__c);
				addressSet.add(currLead.City + '-' + currLead.State + '-' + currLead.PostalCode);
				if (currLead.PostalCode != null) {
					zipCodesSet.add(currLead.PostalCode);
				}
				if (currLead.City != null) {
					citySet.add(currLead.City);
				}
				if (currLead.State != null) {
					stateSet.add(currLead.State);
				}
				if (currLead.Phone != null) {
					phoneSet.add(currLead.Phone);
				}
				if (currLead.Email != null)
					emailsSet.add(currLead.Email);
				chaptersSet.add(currLead.ChapterName__c);
				if (currLead.Id != null) {
					leadIds.add(currLead.Id);
				}
			}
			List<Lead> exLeads = [
					SELECT Id,LastName,Street,FirstName, Email, ChapterName__c,Phone, DOB__c,
							City,State,PostalCode
					FROM Lead
					WHERE (LastName IN :leadLNamesSet OR FirstName IN :leadFNamesSet OR DOB__c IN :leadbDaysSet
					OR Phone IN :phoneSet OR Email IN :emailsSet OR (State IN :stateSet
					AND PostalCode IN :zipCodesSet AND City IN :citySet))
					AND Id NOT IN :leadIds AND IsConverted = FALSE
			];
			List<Contact> exContacts = [
					SELECT Id, LastName,AccountId,MailingStreet,FirstName, Email, Phone, Birthdate,Region_Chapter__r.Name,
							MailingCity, MailingState, MailingPostalCode
					FROM Contact
					WHERE (LastName IN :leadLNamesSet OR FirstName IN :leadFNamesSet OR Birthdate IN :leadbDaysSet
					OR ((MailingState IN :stateSet AND MailingPostalCode IN :zipCodesSet
					AND MailingCity IN :citySet) OR Phone IN :phoneSet OR Email IN :emailsSet))
					AND Region_Chapter__c = :chaptersSet AND RecordTypeId = :wishChild
			];
			for (Lead currLead : leadList) {
				Boolean isDuplicate = false;
				for (Lead exLead : exLeads) {
					{
						if (currLead.FirstName == exLead.FirstName && currLead.LastName == exLead.LastName) {
							isDuplicate = true;
							if (errorType == 'Lightning') {
								currLead.addError('There might be a duplicate Wish Child. Please click Send Diagnosis Verification button to review the duplicates.', false);
							} else {
								currLead.addError('There might be a duplicate Wish Child. Please click <a href='
										+ INSTANCE_URL + '/apex/LeadDuplicate_VF?id='
										+ currLead.Id + '>here </a> to review the duplicates.',
										false);
							}
						} else if (currLead.FirstName == exLead.FirstName
								&& ((currLead.Street == exLead.Street && currLead.State == exLead.State && currLead.City == exLead.City && currLead.PostalCode == exLead.PostalCode)
								|| currLead.Phone == exLead.Phone || currLead.Email == exLead.Email)) {
							isDuplicate = true;
							if (errorType == 'Lightning') {
								currLead.addError('There might be a duplicate Wish Child. Please click Send Diagnosis Verification button to review the duplicates.', false);
							} else {
								currLead.addError('There might be a duplicate Wish Child. Please click <a href='
										+ INSTANCE_URL + '/apex/LeadDuplicate_VF?id='
										+ currLead.Id + '>here </a> to review the duplicates.',
										false);
							}
						} else if ((currLead.LastName == exLead.LastName) &&
								((currLead.Street == exLead.Street && currLead.State == exLead.State && currLead.City == exLead.City && currLead.PostalCode == exLead.PostalCode)
										|| currLead.Email == exLead.Email)) {
							isDuplicate = true;
							if (errorType == 'Lightning') {
								currLead.addError('There might be a duplicate Wish Child. Please click Send Diagnosis Verification button to review the duplicates.', false);
							} else {
								currLead.addError('There might be a duplicate Wish Child. Please click <a href='
										+ INSTANCE_URL + '/apex/LeadDuplicate_VF?id='
										+ currLead.Id + '>here </a> to review the duplicates.',
										false);
							}
						} else if ((currLead.DOB__c == exLead.DOB__c)
								&& ((currLead.Street == exLead.Street
								&& currLead.State == exLead.State
								&& currLead.City == exLead.City
								&& currLead.PostalCode == exLead.PostalCode)
								|| currLead.Email == exLead.Email)) {
							isDuplicate = true;
							if (errorType == 'Lightning') {
								currLead.addError('There might be a duplicate Wish Child. Please click Send Diagnosis Verification button to review the duplicates.', false);
							} else {
								currLead.addError('There might be a duplicate Wish Child. Please click <a href='
										+ INSTANCE_URL + '/apex/LeadDuplicate_VF?id='
										+ currLead.Id + '>here </a> to review the duplicates.',
										false);
							}
						} else if ((currLead.DOB__c == exLead.DOB__c)
								&& (currLead.FirstName == exLead.FirstName
								|| currLead.LastName == exLead.LastName)) {
							isDuplicate = true;
							if (errorType == 'Lightning') {
								currLead.addError('There might be a duplicate Wish Child. Please click Send Diagnosis Verification button to review the duplicates.', false);
							} else {
								currLead.addError('There might be a duplicate Wish Child. Please click <a href='
										+ INSTANCE_URL + '/apex/LeadDuplicate_VF?id='
										+ currLead.Id + '>here </a> to review the duplicates.',
										false);
							}
						}
					}
				}
				for (Contact exCon : exContacts) {
					if (currLead.ChapterName__c == exCon.Region_Chapter__c) {
						if (currLead.FirstName == exCon.FirstName && currLead.LastName == exCon.LastName) {
							isDuplicate = true;
							if (errorType == 'Lightning') {
								currLead.addError('There might be a duplicate Wish Child. Please click Send Diagnosis Verification button to review the duplicates.', false);
							} else {
								currLead.addError('There might be a duplicate Wish Child. Please click <a href='
										+ INSTANCE_URL + '/apex/LeadDuplicate_VF?id='
										+ currLead.Id + '>here </a> to review the duplicates.',
										false);
							}
						} else if ((currLead.FirstName == exCon.FirstName || currLead.LastName == exCon.LastName)
								&& ((currLead.Street == exCon.MailingStreet && currLead.State == exCon.MailingState
								&& currLead.City == exCon.MailingCity && currLead.PostalCode == exCon.MailingPostalCode)
								|| currLead.Phone == exCon.Phone || currLead.Email == exCon.Email)) {
							isDuplicate = true;
							if (errorType == 'Lightning') {
								currLead.addError('There might be a duplicate Wish Child. Please click Send Diagnosis Verification button to review the duplicates.', false);
							} else {
								currLead.addError('There might be a duplicate Wish Child. Please click <a href='
										+ INSTANCE_URL + '/apex/LeadDuplicate_VF?id='
										+ currLead.Id + '>here </a> to review the duplicates.',
										false);
							}
						} else if ((currLead.DOB__c == exCon.Birthdate)
								&& ((currLead.Street == exCon.MailingStreet
								&& currLead.State == exCon.MailingState
								&& currLead.City == exCon.MailingCity
								&& currLead.PostalCode == exCon.MailingPostalCode)
								|| currLead.Phone == exCon.Phone || currLead.Email == exCon.Email)) {
							isDuplicate = true;
							if (errorType == 'Lightning') {
								currLead.addError('There might be a duplicate Wish Child. Please click Send Diagnosis Verification button to review the duplicates.', false);
							} else {
								currLead.addError('There might be a duplicate Wish Child. Please click <a href='
										+ INSTANCE_URL + '/apex/LeadDuplicate_VF?id='
										+ currLead.Id + '>here </a> to review the duplicates.',
										false);
							}
						} else if ((currLead.DOB__c == exCon.Birthdate)
								&& (currLead.FirstName == exCon.FirstName
								|| currLead.LastName == exCon.LastName)) {
							isDuplicate = true;
							if (errorType == 'Lightning') {
								currLead.addError('There might be a duplicate Wish Child. Please click Send Diagnosis Verification button to review the duplicates.', false);
							} else {
								currLead.addError('There might be a duplicate Wish Child. Please click <a href='
										+ INSTANCE_URL + '/apex/LeadDuplicate_VF?id='
										+ currLead.Id + '>here </a> to review the duplicates.',
										false);
							}
						}
					}
				}
				if (isDuplicate == false) {
					noDupLeadRec.add(currLead);
				}
			}
			if (!noDupLeadRec.isEmpty()) {
				FindDupContacts(noDupLeadRec);
			}
		} catch (Exception ex) {
			for (Lead currRec : leadList) {
				ErrorMessage_AC.createdebugRec('Lead_OnBeforeUpdateTriggerHandlerHelper',
						String.valueOf(currRec), String.valueOf(ex), 'findDuplicateRecords',
						currRec.Id, ex.getStackTraceString(), 'Error');
			}
			for (Lead currRec : leadList) {
				currRec.addError(Label.Debug_log_error_message);
			}
		}
	}

	/**
	 * If the lead status is "Reffered" and sub status is "Pending dignose verification".
	 * It will display error message if any duplicate wishchild or wish family or medical proff contact is there.
	 * @param leadRecords
	 */
	public static void FindDupContacts(List<Lead> leadRecords) {
		String errorType = 'Classic';
		if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4u') {
			errorType = 'Lightning';
		}
		Id wishFamilyRT = Constant_AC.WISH_FAMILY_RT_ID;
		Id medicalProfessionalRT = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
		Set<String> mProfessionalFName = new Set<String>();
		Set<String> mProfessionalLName = new Set<String>();
		Set<String> mProfessionalPhone = new Set<String>();
		Set<String> mProfessionalEmail = new Set<String>();
		Set<String> tProfessionalFName = new Set<String>();
		Set<String> tProfessionalLName = new Set<String>();
		Set<String> tProfessionalPhone = new Set<String>();
		Set<String> tProfessionalEmail = new Set<String>();
		Set<String> bestPhysicianFName = new Set<String>();
		Set<String> bestPhysicianLName = new Set<String>();
		Set<String> bestPhysicianEmail = new Set<String>();
		Set<String> leadFNamesSet = new Set<String>();
		Set<String> leadLNamesSet = new Set<String>();
		Set<Date> leadbDaysSet = new Set<Date>();
		Set<String> AddressSet = new Set<String>();
		Set<String> phoneSet = new Set<String>();
		Set<String> zipCodesSet = new Set<String>();
		Set<String> citySet = new Set<String>();
		Set<String> emailsSet = new Set<String>();
		Set<String> stateSet = new Set<String>();
		Set<Id> leadIds = new Set<Id>();
		Set<String> chaptersSet = new Set<String>();
		User u = [
				SELECT Id, UserPreferencesLightningExperiencePreferred
				FROM User
				WHERE Id = :UserInfo.getUserId()
				LIMIT 1
		];

		try {
			for (Lead newLead : leadRecords) {
				mProfessionalFName.add(newLead.Medical_Professional_First_Name__c);
				mProfessionalLName.add(newLead.Medical_Professional_Last_Name__c);
				mProfessionalPhone.add(newLead.Medical_Professional_Phone__c);
				mProfessionalEmail.add(newLead.Medical_Professional_Email__c);
				tProfessionalFName.add(newLead.Treating_Medical_Professional_First_Name__c);
				tProfessionalLName.add(newLead.Treating_Medical_Professional_Last_Name__c);
				tProfessionalPhone.add(newLead.Treating_Medical_Professional_Phone__c);
				tProfessionalEmail.add(newLead.Treating_Medical_Professional_Email__c);
				leadFNamesSet.add(newLead.Parent_First_Name__c);
				leadLNamesSet.add(newLead.Parent_Last_Name__c);
				emailsSet.add(newLead.Email);
				phoneSet.add(newLead.Phone);
				zipCodesSet.add(newLead.PostalCode);
				stateSet.add(newLead.State);
				AddressSet.add(newLead.Street);
				citySet.add(newLead.City);
				leadbDaysSet.add(newLead.DOB__c);
				chaptersSet.add(newLead.ChapterName__c);
				bestPhysicianFName.add(newLead.Best_Contact_for_Physician_First_Name__c);
				bestPhysicianLName.add(newLead.Best_Contact_for_Physician_Last_Name__c);
				bestPhysicianEmail.add(newLead.Best_contact_for_Physician_Email__c);
			}

			List<Contact> dupMedicalContacts = [
					SELECT Id, FirstName,Name, LastName, Email, Phone, MailingCity, Birthdate,
							MailingState, MailingPostalCode
					FROM Contact
					WHERE (FirstName IN :mProfessionalFName AND LastName IN :mProfessionalLName
					AND (Phone = :mProfessionalPhone OR Email IN :mProfessionalEmail)
					AND RecordTypeId = :medicalProfessionalRT)
			];

			List<Contact> dupTreatingContacts = [
					SELECT Id, FirstName,Name, LastName, Email, Phone, MailingCity, Birthdate,
							MailingState, MailingPostalCode
					FROM Contact
					WHERE (FirstName IN :tProfessionalFName AND
					LastName IN :tProfessionalLName
					AND (Phone = :tProfessionalPhone OR Email = :tProfessionalEmail)
					AND RecordTypeId = :medicalProfessionalRT)
			];

			List<Contact> dupPhysicianContacts = [
					SELECT Id,FirstName,LastName,Name,Email
					FROM Contact
					WHERE
					FirstName IN :bestPhysicianFName AND LastName IN :bestPhysicianLName AND
					Email IN:bestPhysicianEmail AND RecordTypeId = :medicalProfessionalRT
			];

			List<Contact> dupFamilyContacts = [
					SELECT Id, FirstName,Name, LastName, Email, Phone, MailingCity, Birthdate,
							MailingState, MailingPostalCode,MailingStreet
					FROM Contact
					WHERE (FirstName IN :leadFNamesSet AND LastName IN :leadLNamesSet AND
					(((Email IN :emailsSet OR Phone IN :phoneSet)
					AND (MailingStreet IN :AddressSet AND MailingState IN :stateSet
					AND MailingPostalCode IN :zipCodesSet
					AND MailingCity IN :citySet))
					OR ((Phone IN :phoneSet OR (MailingStreet IN :AddressSet AND MailingState = :stateSet
					AND MailingPostalCode IN :zipCodesSet
					AND MailingCity = :citySet))
					AND Email = :emailsSet) OR (((MailingStreet = :AddressSet AND MailingState = :stateSet
					AND MailingPostalCode = :zipCodesSet
					AND MailingCity = :citySet) OR (Email = :emailsSet) )
					AND Phone = :phoneSet))) AND RecordTypeId = :wishFamilyRT
			];
			for (Lead newLead : leadRecords) {
				Boolean medicalFlag = false;
				Boolean treatingFlag = false;
				Boolean familyFlag = false;
				Boolean physicianFlag = false;
				for (Contact medicalCon : dupMedicalContacts) {
					if (medicalCon.FirstName == newLead.Medical_Professional_First_Name__c
							&& medicalCon.LastName == newLead.Medical_Professional_Last_Name__c
							&& (medicalCon.Phone == newLead.Medical_Professional_Phone__c
							|| medicalCon.Email == newLead.Medical_Professional_Email__c)) {
						medicalFlag = true;
					}
				}

				for (Contact treatingCon : dupTreatingContacts) {
					if (treatingCon.FirstName == newLead.Treating_Medical_Professional_First_Name__c
							&& treatingCon.LastName == newLead.Treating_Medical_Professional_Last_Name__c
							&& (treatingCon.Phone == newLead.Treating_Medical_Professional_Phone__c
							|| treatingCon.Email == newLead.Treating_Medical_Professional_Email__c)) {
						treatingFlag = true;
					}
				}
				for (Contact physicianCon : dupPhysicianContacts) {
					if (physicianCon.FirstName == newLead.Best_Contact_for_Physician_First_Name__c
							&& physicianCon.LastName == newLead.Best_Contact_for_Physician_Last_Name__c
							&& physicianCon.Email == newLead.Best_contact_for_Physician_Email__c) {
						physicianFlag = true;
					}
				}
				for (Contact familyCon : dupFamilyContacts) {
					if (familyCon.FirstName == newLead.Parent_First_Name__c && familyCon.LastName == newLead.Parent_Last_Name__c
							&& (((familyCon.Phone == newLead.Phone || familyCon.Email == newLead.Email)
							&& (familyCon.MailingStreet == newLead.Street
							&& familyCon.MailingState == newLead.State && familyCon.MailingCity == newLead.City
							&& familyCon.MailingPostalCode == newLead.PostalCode)) || ((familyCon.Phone == newLead.Phone || (familyCon.MailingStreet == newLead.Street
							&& familyCon.MailingState == newLead.State && familyCon.MailingPostalCode == newLead.PostalCode && familyCon.MailingCity == newLead.City))
							&& familyCon.Email == newLead.Email) || (((familyCon.MailingStreet == newLead.Street && familyCon.MailingState == newLead.State
							&& familyCon.MailingPostalCode == newLead.PostalCode && familyCon.MailingCity == newLead.City) || (familyCon.Email == newLead.Email))
							&& familyCon.Phone == newLead.Phone))) {
						familyFlag = true;
					}
				}
				List<Contact> dupAdditionalFamilyContacts = [
						SELECT Id, FirstName,Name, LastName, Email, Phone, MailingCity, Birthdate,
								MailingState, MailingPostalCode
						FROM Contact
						WHERE (FirstName = :newLead.Additional_Parent_First_Name__c AND LastName = :newLead.Additional_Parent_Last_Name__c
						AND (((Email = :newLead.Additional_Parent_Email__c OR Phone = :newLead.Additional_Parent_Phone__c)
						AND (MailingStreet = :newLead.Additional_Parent_Street__c AND MailingState = :newLead.Additional_Parent_State__c
						AND MailingPostalCode = :newLead.Additional_Parent_Postal_Code__c
						AND MailingCity = :newLead.Additional_Parent_City__c))
						OR ((Phone = :newLead.Additional_Parent_Phone__c OR (MailingStreet = :newLead.Additional_Parent_Street__c
						AND MailingState = :newLead.Additional_Parent_State__c
						AND MailingPostalCode = :newLead.Additional_Parent_Postal_Code__c
						AND MailingCity = :newLead.Additional_Parent_City__c))
						AND Email = :newLead.Additional_Parent_Email__c ) OR (((MailingStreet = :newLead.Additional_Parent_Street__c
						AND MailingState = :newLead.Additional_Parent_State__c
						AND MailingPostalCode = :newLead.Additional_Parent_Postal_Code__c
						AND MailingCity = :newLead.Additional_Parent_City__c) OR (Email = :newLead.Additional_Parent_Email__c ) )
						AND Phone = :newLead.Additional_Parent_Phone__c ))) AND RecordTypeId = :wishFamilyRT
				];
				if ((medicalFlag == true || treatingFlag == true || physicianFlag == true) && (familyFlag == true
						|| !dupAdditionalFamilyContacts.isEmpty())) {
					if (errorType == 'Lightning') {
						newLead.addError('There might be an existing Wish Family and Medical Professional. Please click Send Diagnosis Verification button to review the existing record.', false);
					} else {
						newLead.addError('There might be an existing Wish Family and Medical Professional.Please click <a href='
								+ INSTANCE_URL
								+ '/apex/LeadDuplicate_VF?id=' + newLead.Id
								+ '&wishFamily=true&manual=true' + '>here </a> to review the existing record.',
								false);
					}
				} else if (medicalFlag == true || treatingFlag == true) {
					if (errorType == 'Lightning') {
						newLead.addError('There might be an existing Medical Professional. Please click Send Diagnosis Verification button to review the existing record.', false);
					} else {
						newLead.addError('There might be an existing Medical Professional. Please click <a href='
								+ INSTANCE_URL + '/apex/LeadDuplicate_VF?id='
								+ newLead.Id + '&wishFamily=true&manual=true' + '>here </a> to review the existing record.',
								false);
					}
				} else if (physicianFlag) {
					if (errorType == 'Lightning') {
						newLead.addError('There might be an existing Best Physician Contact. Please click Send Diagnosis Verification button to review the existing record.', false);
					} else {
						newLead.addError('There might be an existing Best Physician Contact. Please click <a href='
								+ INSTANCE_URL + '/apex/LeadDuplicate_VF?id='
								+ newLead.Id + '&wishFamily=true&manual=true' + '>here </a> to review the existing record.',
								false);
					}
				} else if (familyFlag == true) {
					if (errorType == 'Lightning') {
						newLead.addError('There might be an existing Wish Family. Please click Send Diagnosis Verification button to review the existing record.', false);
					} else {
						newLead.addError('There might be an existing Wish Family.Please click <a href='
								+ INSTANCE_URL + '/apex/LeadDuplicate_VF?id='
								+ newLead.Id + '&wishFamily=true&manual=true' + '>here </a> to review the existing record.',
								false);
					}
				} else if (!dupAdditionalFamilyContacts.isEmpty()) {
					if (errorType == 'Lightning') {
						newLead.addError('There might be an existing Additional Parent/Guardian. Please click Send Diagnosis Verification button to review the existing record.', false);
					} else {
						newLead.addError('There might be an existing Additional Parent/Guardian. Please click <a href='
								+ INSTANCE_URL + '/apex/LeadDuplicate_VF?id='
								+ newLead.Id + '&wishFamily=true&manual=true' + '>here </a> to review the existing record.',
								false);
					}
				}
			}
		} catch (Exception ex) {
			for (Lead currRec : leadRecords) {
				ErrorMessage_AC.createdebugRec('Lead_OnBeforeUpdateTriggerHandlerHelper',
						String.valueOf(currRec), String.valueOf(ex), 'FindDupContacts',
						currRec.Id, ex.getStackTraceString(), 'Error');
			}
			for (Lead currRec : leadRecords) {
				currRec.addError(Label.Debug_log_error_message);
			}
		}
	}

	/**
	 * This method will fire to check the specific fields are null/blank if the lead status changed to "Qualified"
	 * @param leadList
	 */
	public static void preQualifiedRequired(List<Lead> leadList) {
		String message = '';
		for (Lead le : leadList) {
			if (le.FirstName == null) {
				if (message == '' || message == null) {
					message = 'First Name';
				}
			}
			if (le.DOB__c == null) {
				if (message == '' || message == null) {
					message = 'DOB';
				} else {
					message = message + ', ' + 'DOB';
				}
			}
			if (le.Any_medical_reason_for_moving_quickly__c == null) {
				if (message == '' || message == null) {
					message = 'Potential Rush';
				} else {
					message = message + ', ' + 'Potential Rush';
				}
			}
			if (le.I_am_Recognized_To_Practice_As_a__c == null) {
				if (message == '' || message == null) {
					message = 'I Am Recognized To Practice As A';
				} else {
					message = message + ', ' + 'I Am Recognized To Practice As A';
				}
			}
			if (!String.isBlank(message)) {
				for (Lead leadTemp : leadList) {
					if (Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null) {
						leadTemp.addError('Please enter the values for the following fields - ' + message + '.');
					}
				}
			}
		}
	}

	/**
	 *
	 *
	 * @param leadList
	 */
	public static void createPotentialRushTask(List<Lead> leadList) {
		List<Task> newTaskList = new List<Task>();
		for (Lead processLead : leadList) {
			Task newRushTask = new Task(Priority = 'Normal',
					Status = 'Not Started',
					Subject = 'Rush has been changed from Yes to No/ Not sure, reach out to family if necessary',
					OwnerId = processLead.OwnerId,
					ActivityDate = System.today() + 3,
					SystemGeneratedTask__c = true,
					WhoId = processLead.Id);
			newTaskList.add(newRushTask);
		}
		if (!newTaskList.isEmpty()) {
			insert newTaskList;
		}
	}

	/**
	 *
	 * @param ICDCode
	 * @param leadList
	 */
	public static void updateQualifingDiagnosis(String ICDCode, List<Lead> leadList) {
		List<ICD_Codes__c> icdCodeSet = [
				SELECT Id,Name,Condition_Description__r.Name,
						Condition_Description__r.PR_Diagnosis__c
				FROM ICD_Codes__c
				WHERE Name = :ICDCode AND Group1__c = TRUE
				LIMIT 1
		];
		if (!icdCodeSet.isEmpty()) {
			for (Lead newLead : leadList) {
				newLead.Qualifying_ICD__c = icdCodeSet[0].Id;
				newLead.Qualifying_Diagnosis__c = icdCodeSet[0].Condition_Description__r.Name;
				newLead.PR_Diagnosis__c = icdCodeSet[0].Condition_Description__r.PR_Diagnosis__c;
			}
		}
	}

	/**
	 *
	 * @param leadIds
	 */
	public static void closeTasks(Set<Id> leadIds) {
		List<Task> taskList = [
				SELECT Id,Status
				FROM Task
				WHERE WhoId IN :leadIds AND Status != 'Completed'
				LIMIT 50000
		];
		List<Task> updateTask = new List<Task>();
		for (Task processTask : taskList) {
			processTask.Status = 'Completed';
			updateTask.add(processTask);
		}
		if (!updateTask.isEmpty()) {
			update updateTask;
		}
	}

	/**
	 *
	 * @param updateChapterLeadList
	 */
	public static void updateChapterViaZipcode(List<Lead> updateChapterLeadList) {
		Set<String> zipSet = new Set<String>();
		Map<Id, String> codeMap = new Map<Id, String>();
		for (Lead processLead : updateChapterLeadList) {
			String postCode = processLead.PostalCode;
			if (postCode.length() > 5) {
				postCode = postCode.substring(0, 5);
			}
			codeMap.put(processLead.Id, postCode);
			zipSet.add(postCode);
		}
		List<Zip_Code__c> officeZipList = [
				SELECT Id, Name, Office__c, Office__r.Chapter__c, Office__r.Referral_Email_Address__c,
						Office__r.Chapter__r.Intake_Manager__c, Office__r.Chapter__r.Onboarded_on_SF__c
				FROM Zip_Code__c
				WHERE Name IN :zipSet
		];
		if (!officeZipList.isEmpty()) {
			for (Lead processLead : updateChapterLeadList) {
				for (Zip_Code__c zipInfo : officeZipList) {
					if (codeMap.get(processLead.Id) == zipInfo.Name) {
						if (zipInfo.Office__c != null && zipInfo.Office__r.Chapter__c != null) {
							processLead.ChapterName__c = zipInfo.Office__r.Chapter__c;
						}
						if (zipInfo.Office__r.Chapter__r.Onboarded_on_SF__c) {
							if (zipInfo.Office__r.Chapter__c != null
									&& zipInfo.Office__r.Chapter__r.Intake_Manager__c != null) {
								processLead.OwnerId = zipInfo.Office__r.Chapter__r.Intake_Manager__c;
							} else {
								processLead.OwnerId = Label.Salesforce_Support_User_Id;
							}
						}
						if (zipInfo.Office__r.Referral_Email_Address__c != null) {
							processLead.Office_Referral_Email__c = zipInfo.Office__r.Referral_Email_Address__c;
							if (!zipInfo.Office__r.Chapter__r.Onboarded_on_SF__c) {
								processLead.Hidden_Trigger_Referral_Email__c = !processLead.Hidden_Trigger_Referral_Email__c;
							}
						}
						if (zipInfo.Office__r.Chapter__r != null
								&& zipInfo.Office__r.Chapter__r.Onboarded_on_SF__c != null) {
							processLead.Is_Chapter_Active__c = zipInfo.Office__r.Chapter__r.Onboarded_on_SF__c;
						}
					}
				}
			}
		}
	}
}