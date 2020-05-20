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

		List<Account> accounts = TestDataFactory.createAccount(1);
		Account account = accounts.get(0);
		account.Name = 'Make-A-Wish Arizona';
		account.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
		insert accounts;

		List<ICD_Codes__c> icdCodesDataFactory = TestDataFactory.createIcdCode(1);
		ICD_Codes__c icdCode = icdCodesDataFactory.get(0);
		insert icdCode;

		System.runAs(integrationUser) {
			List<Lead> leads = TestDataFactory.createLead(200);
			for (Integer i = 0; i < leads.size(); i++) {
				Lead lead = leads[i];
				lead.ChapterName__c = account.Id;
				lead.FirstName = 'Jack';
				lead.LastName = 'Smith' + i;
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
			}
			insert leads;
		}

		trac_TriggerHandlerBase.blockTrigger = false;
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
				WHERE FirstName = 'Jack'
		];
		for (Integer i = 0; i < leads.size(); i++) {
			Lead lead = leads[i];
			lead.PostalCode = '98101';
		}
		System.runAs(integrationUser) {
			update leads;
		}
	}
}