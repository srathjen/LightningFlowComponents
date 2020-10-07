@IsTest
public class LeadTrigger_AT_Test {

	@TestSetup
	static void setup() {
		trac_TriggerHandlerBase.blockTrigger = true;
		User integrationUser = TestDataFactory.createIntegrationUser(1, 'Integration', 'Manager').get(0);
		integrationUser.LastName = 'Integration';
		System.runAs(TestDataFactory.adminUser) {
			insert integrationUser;
		}

		List<Account> accounts = TestDataFactory.createAccount(2);
		Account account1 = accounts.get(0);
		account1.Name = 'Make-A-Wish Arizona';
		account1.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
		Account account2 = accounts.get(1);
		account2.Name = 'Make-A-Wish New York';
		account2.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
		insert accounts;

		List<ICD_Codes__c> icdCodesDataFactory = TestDataFactory.createIcdCode(1);
		ICD_Codes__c icdCode = icdCodesDataFactory.get(0);
		insert icdCode;

		List<Lead> leads = TestDataFactory.createLead(200);
		System.runAs(integrationUser) {
			for (Integer i = 0; i < leads.size(); i++) {
				Lead lead = leads[i];
				lead.ChapterName__c = account1.Id;
				lead.Hidden_Chapter_Change_Confirmation__c = account1.Id;
				lead.FirstName = 'Jack';
				lead.LastName = 'Smith' + i;
				lead.is_Family_Aware_of_Referral__c = 'Yes';
				lead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
				lead.PD_ICD_Code__c = icdCode.Id;
				lead.Sub_Status__c = Constant_AC.LEAD_SUB_STATUS_PENDING_PAPER_DV;
				lead.Company = 'MAW';
				lead.Street = '123 Street';
				lead.State = 'Arizona';
				lead.StateCode = 'AZ';
				lead.City = 'Phoenix';
				lead.PostalCode = '85001';
				lead.Initial_Address_Verification__c = false;
				lead.Is_Chapter_Active__c = false;
				lead.Any_medical_reason_for_moving_quickly__c = 'No';
				lead.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL;
				lead.RecordTypeId = Constant_AC.LEAD_RT_WISH_CHILD;
			}
			insert leads;
		}
		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	static void shouldCreateLead() {
		Account account = [
				SELECT Id
				FROM Account
				LIMIT 1
		];
		ICD_Codes__c icdCode = [
				SELECT Id
				FROM ICD_Codes__c
				LIMIT 1
		];

		List<Lead> leads = TestDataFactory.createLead(1);
		Lead lead = leads[0];
		lead.ChapterName__c = account.Id;
		lead.FirstName = 'Mark';
		lead.LastName = 'Smith';
		lead.Hidden_Chapter_Change_Confirmation__c = account.Id;
		lead.is_Family_Aware_of_Referral__c = 'Yes';
		lead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
		lead.PD_ICD_Code__c = icdCode.Id;
		lead.Company = 'MAW';
		lead.Street = '123 Street';
		lead.State = 'Arizona';
		lead.StateCode = 'AZ';
		lead.City = 'Phoenix';
		lead.PostalCode = '85001';
		lead.Initial_Address_Verification__c = false;
		lead.Is_Chapter_Active__c = false;
		insert leads;
	}

	@IsTest
	static void shouldCreateLead_Referred() {
		Account account = [
				SELECT Id
				FROM Account
				LIMIT 1
		];
		ICD_Codes__c icdCode = [
				SELECT Id
				FROM ICD_Codes__c
				LIMIT 1
		];

		List<Lead> leads = TestDataFactory.createLead(1);
		Lead lead = leads[0];
		lead.ChapterName__c = account.Id;
		lead.FirstName = 'Mark';
		lead.LastName = 'Smith';
		lead.Hidden_Chapter_Change_Confirmation__c = account.Id;
		lead.is_Family_Aware_of_Referral__c = 'Yes';
		lead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
		lead.PD_ICD_Code__c = icdCode.Id;
		lead.Company = 'MAW';
		lead.Street = '123 Street';
		lead.State = 'Arizona';
		lead.StateCode = 'AZ';
		lead.City = 'Phoenix';
		lead.PostalCode = '85001';
		lead.Initial_Address_Verification__c = false;
		lead.Is_Chapter_Active__c = false;
		lead.Status = 'Referred';
		lead.Sub_Status__c = 'Pending Part A';
		lead.DOB__c = Date.today().addYears(-2);
		lead.Hospital_Treatment_Facility_Treating__c = 'Malignant Neoplasm';
		lead.Gender__c = 'Male';
		lead.Street = '123 St';
		lead.City = 'Phoenix';
		lead.State = 'Arizona';
		lead.PostalCode = '35004';
		lead.Email = 'mcavennila@gmail.com';
		lead.Phone = '8220708920';
		insert leads;
	}

	@IsTest
	static void shouldUpdateLead() {
		Account account = [
				SELECT Id
				FROM Account
				WHERE Name = 'Make-A-Wish New York'
				LIMIT 1
		];
		Lead lead = [
				SELECT Id
				FROM Lead
				LIMIT 1
		];

		lead.Status = Constant_AC.LEAD_STATUS_QUALIFIED;
		lead.DOB__c = Date.today().addYears(-2);
		lead.Hospital_Treatment_Facility_Treating__c = 'Malignant Neoplasm';
		lead.Gender__c = 'Male';
		lead.Street = '123 St';
		lead.City = 'Phoenix';
		lead.State = 'Arizona';
		lead.PostalCode = '35004';
		lead.Email = 'testupdate@email.com';
		lead.Phone = '8220708920';
		lead.I_am_Recognized_To_Practice_As_a__c = 'Physician';
		lead.Any_medical_reason_for_moving_quickly__c = 'No';
		lead.Sub_Status__c = 'Pending Diagnosis Verification';
		lead.Hidden_Chapter_Change_Confirmation__c = account.Id;
		lead.ChapterName__c = account.Id;
		lead.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL;
		lead.Dup_Check__c = '';
		update lead;
	}

	@IsTest
	static void shouldUpdateLead_InEligibilityReview() {
		Account account = [
				SELECT Id
				FROM Account
				WHERE Name = 'Make-A-Wish New York'
				LIMIT 1
		];
		Lead lead = [
				SELECT Id
				FROM Lead
				LIMIT 1
		];

		lead.Status = Constant_AC.LEAD_STATUS_ELIGIBILITY_REVIEW;
		lead.DOB__c = Date.today().addYears(-2);
		lead.Hospital_Treatment_Facility_Treating__c = 'Malignant Neoplasm';
		lead.Gender__c = 'Male';
		lead.Street = '123 St';
		lead.City = 'Phoenix';
		lead.State = 'Arizona';
		lead.PostalCode = '35004';
		lead.Email = 'testupdate@email.com';
		lead.Phone = '8220708920';
		lead.I_am_Recognized_To_Practice_As_a__c = 'Physician';
		lead.Any_medical_reason_for_moving_quickly__c = 'No';
		lead.Sub_Status__c = 'Pending Diagnosis Verification';
		lead.Hidden_Chapter_Change_Confirmation__c = account.Id;
		lead.ChapterName__c = account.Id;
		lead.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL;
		lead.Dup_Check__c = '';
		update lead;
	}

	@IsTest
	static void shouldUpdateAddress_WhenIntegrationUser() {
		User integrationUser = [
				SELECT Id
				FROM User
				WHERE Profile.Name = 'Integration'
				LIMIT 1
		];
		List<Lead> leads = [
				SELECT Id
				FROM Lead
		];
		System.assert(leads.size() == 200);

		for (Integer i = 0; i < leads.size(); i++) {
			Lead lead = leads[i];
			lead.PostalCode = '98101';
		}
		System.runAs(integrationUser) {
			update leads;
		}
	}
}