/**
 * @author Steve Doucette, Traction on Demand 
 * @date 10/23/2019
 *
 * NOTE: Only purpose of class is to cover MST code that isn't covered by other classes
 * No assertions will be made
 */
@IsTest
private class Lead_Trigger_Test {
	@TestSetup
	static void setup() {
		trac_TriggerHandlerBase.blockTrigger = true;
		Chapter_Name_Setting__mdt chapter = [
				SELECT Id, Chapter_Name__c
				FROM Chapter_Name_Setting__mdt
				LIMIT 1
		];

		Account hospital = OrientationandTrainingUtil.HospitalTreatment();
		hospital.Qualified_Wish_Owner__c = UserInfo.getUserId();
		insert hospital;

		Contact treatingMedicalProfessional = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
		insert treatingMedicalProfessional;

		Condition_Description__c conditionDescription = OrientationandTrainingUtil.createConditionDesCription();
		insert conditionDescription;

		ICD_Codes__c icdCode = OrientationandTrainingUtil.createICDCode(conditionDescription.Id);
		insert icdCode;

		Lead convertedLead = new Lead();
		convertedLead.FirstName = 'TestFirst';
		convertedLead.LastName = 'TestLast';
		convertedLead.ChapterName__c = hospital.Id;
		convertedLead.Treating_Medical_Professional_Contact_Id__c = convertedLead.HiddenAlternate1MedProfessionalId__c = convertedLead.HiddenAlternate2MedProfessionalId__c
				= treatingMedicalProfessional.Id;
		convertedLead.Hospital_Treatment_Facility_Treating__c = convertedLead.Alternate1HospitalTreatmentFacility__c = convertedLead.Alternate2HospitalTreatmentFacility__c
				= hospital.Id;
		convertedLead.is_Family_Aware_of_Referral__c = 'Yes';
		convertedLead.Company = 'MAW';
		convertedLead.PD_ICD_Code__c = convertedLead.ICD_Given_By_Referrer__c = icdCode.Id;
		convertedLead.DOB__c = Date.today();
		convertedLead.I_am_Recognized_To_Practice_As_a__c = 'Physician';
		convertedLead.Rush__c = true;
		convertedLead.Any_medical_reason_for_moving_quickly__c = 'No';
		convertedLead.Sub_Status__c = 'Pending Part A';
		convertedLead.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL;

		Lead convertedLead2 = convertedLead.clone();
		convertedLead2.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL;

		Lead convertedLead3 = convertedLead.clone();
		convertedLead3.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL;

		insert new List<Lead>{
				convertedLead, convertedLead2, convertedLead3
		};
		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	static void testLeadConvert() {
		List<Lead> convertedLeads = [
				SELECT Id, Status, Hidden_DV_form_Medical_professional_Type__c
				FROM Lead
		];

		for (Lead convertedLead : convertedLeads) {
			convertedLead.Status = Constant_AC.LEAD_STATUS_QUALIFIED;
		}
		update convertedLeads;
	}

	@IsTest
	static void testLeadConvertMedicalProfessionals() {
		List<Lead> convertedLeads = [
				SELECT Id, Status, Hidden_DV_form_Medical_professional_Type__c,
						Referrer_FirstName__c, Referrer_Last_Name__c,
						Best_Contact_for_Physician_First_Name__c, Best_Contact_for_Physician_Last_Name__c
				FROM Lead
		];

		for (Lead convertedLead : convertedLeads) {
			convertedLead.Status = Constant_AC.LEAD_STATUS_QUALIFIED;
			convertedLead.Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
			convertedLead.Treating_Medical_Professional_Contact_Id__c = convertedLead.Hidden_Best_Contact_Person_Id__c = null;
		}

		update convertedLeads;

		Lead_OnAfterUpdateTriggerHandlerHelper.dupeCheckonAccount(new Set<Id>(new Map<Id, Lead>(convertedLeads).keySet()));
	}

	@IsTest
	static void coverPrivateMethods() {
		trac_TriggerHandlerBase.blockTrigger = true;
		Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
		insert chapterAccount;

		Lead wishChild = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
		wishChild.Hidden_Potential_Rush__c = 'yes';
		wishChild.I_am_Recognized_To_Practice_As_a__c = 'Doctor';
		wishChild.Any_medical_reason_for_moving_quickly__c = 'yes';
		insert wishChild;
		wishChild.Sub_Status__c = 'Pending Diagnosis Verification';
		update wishChild;

		dsfs__DocuSign_Status__c status = OrientationandTrainingUtil.createDocusignStatus(wishChild.Id);
		status.dsfs__Subject__c = 'Diagnosis Verification Form';
		insert status;
		trac_TriggerHandlerBase.blockTrigger = false;

		Lead_OnAfterUpdateTriggerHandlerHelper.leadConvertion(new Map<Id, Lead>{
				wishChild.Id => wishChild
		});

		Set<Id> chapterAccountIds = new Set<Id>{
				chapterAccount.Id
		};

		Lead_OnAfterUpdateTriggerHandlerHelper.updateLeadConvertedAccounts(chapterAccountIds, chapterAccountIds, wishChild.Id, new Map<Id, Account>(), new Map<Id, Lead>{
				chapterAccount.Id => wishChild
		}, new List<Account>());
		wishChild.FirstName = null;
		Lead_OnAfterUpdateTriggerHandlerHelper.updateLeadConvertedAccounts(chapterAccountIds, chapterAccountIds, wishChild.Id, new Map<Id, Account>(), new Map<Id, Lead>{
				chapterAccount.Id => wishChild
		}, new List<Account>());
	}
}