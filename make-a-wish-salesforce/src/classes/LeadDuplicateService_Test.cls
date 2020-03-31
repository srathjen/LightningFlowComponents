@IsTest
public class LeadDuplicateService_Test {

	private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;

	@TestSetup
	private static void setup() {
		trac_TriggerHandlerBase.blockTrigger = true;
		insert new Bypass_Triggers__c(SetupOwnerId = UserInfo.getUserId());
		List<Account> accounts = TestDataFactory.createAccount(2);
		Account account1 = accounts.get(0);
		account1.Name = 'Make-A-Wish Arizona';
		account1.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
		Account account2 = accounts.get(1);
		account2.Name = 'Make-A-Wish New York';
		account2.RecordTypeId = CHAPTER_RECORD_TYPE_ID;

		List<Contact> contacts = TestDataFactory.createContact(2);
		Contact childContact = contacts[0];
		childContact.Region_Chapter__c = account1.Id;
		childContact.FirstName = 'moss';
		childContact.LastName = 'Smith Household';
		childContact.Email = 'testmawa@gmail.com';
		childContact.Phone = '9600467559';
		childContact.OtherPhone = '8056913402';
		childContact.MobilePhone = '9003910426';
		childContact.MailingStreet = 'East Street';
		childContact.MailingCity = 'Trichy';
		childContact.MailingState = 'Arizona';
		childContact.MailingStateCode = 'AZ';
		childContact.MailingPostalCode = '85252';
		childContact.MailingCountryCode = 'US';
		childContact.MobilePhone = '9900220022';
		childContact.Primary_Diagnosis_Condition_Description__c = 'Test';
		childContact.Diagnosis__c = 'test';
		Contact familyContact = contacts[1];
		familyContact.Region_Chapter__c = account1.Id;
		familyContact.FirstName = 'Bob';
		familyContact.LastName = 'Smith';
		familyContact.Email = 'test@email.com';
		familyContact.Phone = '123456789';
		familyContact.MailingStreet = '123 Street';
		familyContact.MailingCity = 'Phoenix';
		familyContact.MailingState = 'Arizona';
		familyContact.MailingStateCode = 'AZ';
		familyContact.MailingPostalCode = '8042000';
		familyContact.MailingCountryCode = 'US';
		familyContact.RecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
		insert contacts;

		List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
		ICD_Codes__c icdCode = icdCodes.get(0);
		insert icdCodes;

		List<Lead> leads = TestDataFactory.createLead(2);
		Lead lead = leads.get(0);
		lead.RecordTypeId = Constant_AC.LEAD_RT_WISH_CHILD;
		lead.FirstName = 'Jack';
		lead.LastName = 'Smith';
		lead.Phone = '123456789';
		lead.Email = 'test@email.com';
		lead.Street = '123 Street';
		lead.City = 'Phoenix';
		lead.State = 'Arizona';
		lead.StateCode = 'AZ';
		lead.PostalCode = '8042000';
		lead.CountryCode = 'US';
		lead.DOB__c = System.today() - 1435;
		lead.Company = 'MAW';
		lead.Status = 'Inquiry';
		lead.Gender__c = 'Male';
		lead.ChapterName__c = account1.Id;
		lead.Parent_First_Name__c = 'Bob';
		lead.Parent_Last_Name__c = 'Smith';
		lead.Referrer_FirstName__c = 'Sudhar';
		lead.Referrer_Last_Name__c = 'test';
		lead.Referrer_Email__c = 'sudhar1@gmail.com';
		lead.Referrer_Phone__c = '0600467559';
		lead.Referrer_City__c = 'Trichy';
		lead.Referrer_Zip__c = '6210';
		lead.Sibling_Detail__c = 'aa | aaab | 14 bbb | bbbc | 15';
		lead.PD_Condition_Description__c = 'Test Diagnosis';
		lead.Medical_Professional_First_Name__c = 'mossJune';
		lead.Medical_Professional_Last_Name__c = 'hartJune';
		lead.Medical_Professional_Phone__c = '9600467559';
		lead.Medical_Professional_Email__c = 'testmawa1s@gmail.com';
		lead.Hospital_Treatment_Facility__c = 'Moss Hart AC';
		lead.Treating_Medical_Professional_First_Name__c = 'SteveJune';
		lead.Treating_Medical_Professional_Last_Name__c = 'Waughone';
		lead.Treating_Medical_Professional_Phone__c = '9600467578';
		lead.Treating_Medical_Professional_Email__c = 'testmawa2d@gmail.com';
		lead.Hospital_Treatment_Facility_Treating__c = 'Steve Smith AC';
		lead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
		lead.is_Family_Aware_of_Referral__c = 'Yes';
		lead.Medical_Questions__c = 'Test Diagnosis';
		lead.PD_ICD_Code__c = icdCode.Id;
		lead.Lung_Disease__c = 'Test1;Test2';
		lead.Angina__c = 'Test1;Test2';
		lead.Ventilator__c = 'Test1;Test2';
		lead.Arrhythmia__c = 'Test1;Test2';
		lead.Heart_Failure__c = 'Test1;Test2';
		lead.Congenital_Heart_Disease__c = 'Test1;Test2';
		lead.Chronic_Hepatitis__c = 'Test1;Test2';
		lead.Convulsive_Disorders__c = 'Test1;Test2';
		lead.Pulmonary_Hypertension__c = 'Test1;Test2';
		lead.Strokes__c = 'Test1;Test2';
		lead.Chronic_Heart_Failure__c = 'Test1;Test2';
		lead.isSign__c = true;
		lead.Travel_algorithm__c = 'Test1;Test2;';
		lead.Child_Age__c = '4';
		Lead leadDuplicated = leads.get(1);
		leadDuplicated.FirstName = 'Jack';
		leadDuplicated.LastName = 'S';
		leadDuplicated.Phone = '987654321';
		leadDuplicated.Email = 'test@email.com';
		leadDuplicated.Street = '123 Street';
		leadDuplicated.City = 'Phoenix';
		leadDuplicated.State = 'Arizona';
		leadDuplicated.StateCode = 'AZ';
		leadDuplicated.PostalCode = '8042000';
		leadDuplicated.CountryCode = 'US';
		leadDuplicated.DOB__c = System.today() - 1000;
		leadDuplicated.Company = 'MAW';
		leadDuplicated.Status = 'Inquiry';
		leadDuplicated.Gender__c = 'Male';
		leadDuplicated.ChapterName__c = account2.Id;
		leadDuplicated.Parent_First_Name__c = 'Bob';
		leadDuplicated.Parent_Last_Name__c = 'Smith';
		leadDuplicated.Referrer_FirstName__c = 'Will';
		leadDuplicated.Referrer_Last_Name__c = 'Test';
		leadDuplicated.Referrer_Email__c = 'will@email.com';
		leadDuplicated.Referrer_Phone__c = '0600467559';
		leadDuplicated.Referrer_City__c = 'Trichy';
		leadDuplicated.Referrer_Zip__c = '6210';
		leadDuplicated.Sibling_Detail__c = 'aa | aaab | 14 bbb | bbbc | 15';
		leadDuplicated.PD_Condition_Description__c = 'Test Diagnosis';
		leadDuplicated.Medical_Professional_First_Name__c = 'mossJune';
		leadDuplicated.Medical_Professional_Last_Name__c = 'hartJune';
		leadDuplicated.Medical_Professional_Phone__c = '9600467559';
		leadDuplicated.Medical_Professional_Email__c = 'testmawa1s@gmail.com';
		leadDuplicated.Hospital_Treatment_Facility__c = 'Moss Hart AC';
		leadDuplicated.Treating_Medical_Professional_First_Name__c = 'Steve';
		leadDuplicated.Treating_Medical_Professional_Last_Name__c = 'Smith';
		leadDuplicated.Treating_Medical_Professional_Phone__c = '9600467578';
		leadDuplicated.Treating_Medical_Professional_Email__c = 'testmawa2d@gmail.com';
		leadDuplicated.Hospital_Treatment_Facility_Treating__c = 'Steve Smith 2';
		leadDuplicated.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis2';
		leadDuplicated.is_Family_Aware_of_Referral__c = 'Yes';
		leadDuplicated.Medical_Questions__c = 'Test Diagnosis2';
		leadDuplicated.PD_ICD_Code__c = icdCode.Id;
		leadDuplicated.Lung_Disease__c = 'Test3;Test4';
		leadDuplicated.Angina__c = 'Test3;Test4';
		leadDuplicated.Ventilator__c = 'Test3;Test4';
		leadDuplicated.Arrhythmia__c = 'Test3;Test4';
		leadDuplicated.Heart_Failure__c = 'Test3;Test4';
		leadDuplicated.Congenital_Heart_Disease__c = 'Test3;Test4';
		leadDuplicated.Chronic_Hepatitis__c = 'Test3;Test4';
		leadDuplicated.Convulsive_Disorders__c = 'Test3;Test4';
		leadDuplicated.Pulmonary_Hypertension__c = 'Test3;Test4';
		leadDuplicated.Strokes__c = 'Test3;Test4';
		leadDuplicated.Chronic_Heart_Failure__c = 'Test3;Test4';
		leadDuplicated.isSign__c = true;
		leadDuplicated.Travel_algorithm__c = 'Test1;Test2;';
		leadDuplicated.Child_Age__c = '5';
		insert leads;
		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	static void shouldFindFamilyDuplicatedContacts() {
		List<Lead> leads = [
				SELECT Id, ChapterName__c
				FROM Lead
				WHERE LastName = 'Smith'
		];

		Test.startTest();
		String result = LeadDuplicateService.FindFamilyContactDupe(leads[0].Id);
		Test.stopTest();

		System.assertNotEquals(null, result);
	}

	@IsTest
	public static void shouldFindDuplicatedLeads() {
		List<Lead> leads = [
				SELECT Id, ChapterName__c
				FROM Lead
				WHERE LastName = 'Smith'
		];

		Test.startTest();
		String result = LeadDuplicateService.FindLeadDupe(leads[0].Id);
		Test.stopTest();

		System.assertNotEquals(null, result);
	}

	@IsTest
	public static void findLeadDupe() {
		Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
		insert chapterAccount;

		Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
		newLead.Child_Age__c = '4';
		newLead.State = 'Arizona';
		newLead.PostalCode = '35004';
		newLead.Street = 'test';
		newLead.Phone = '8220708920';
		insert newLead;
		Lead dupeLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
		dupeLead.LastName = 'John';
		dupeLead.City = 'Karur';
		dupeLead.State = 'Arizona';
		dupeLead.PostalCode = '35004';
		dupeLead.Street = 'test';
		dupeLead.Phone = '8220708920';
		dupeLead.Override_Dupe_Check__c = true;
		insert dupeLead;

		String result = LeadDuplicateService.FindLeadDupe(dupeLead.id);
		LeadDuplicateService.resetDVMedicalSummary(dupeLead.id);

		System.assertEquals(LeadDuplicateService.DUPE_MESSAGE, result);

		// Covering other blocks of the FindLeadDupe method
		Test.startTest();
		dupeLead.FirstName = dupeLead.LastName = 'Test FN';
		dupeLead.DOB__c = newLead.DOB__c;
		dupeLead.Street = 'Test St.';
		update dupeLead;
		result = LeadDuplicateService.FindLeadDupe(dupeLead.id);

		dupeLead.FirstName = newLead.FirstName;
		dupeLead.State = 'Colorado';
		dupeLead.City = 'Denver';
		dupeLead.PostalCode = '12345';
		dupeLead.Phone = '1234567890';
		dupeLead.Email = 'Test@test.com';
		update dupeLead;
		result = LeadDuplicateService.FindLeadDupe(dupeLead.id);
		delete newLead;

		Contact wishChildContact = OrientationandTrainingUtil.CreateWishChildCon();
		wishChildContact.FirstName = newLead.FirstName;
		wishChildContact.LastName = newLead.LastName;
		wishChildContact.Region_Chapter__c = newLead.ChapterName__c;
		insert wishChildContact;
		result = LeadDuplicateService.FindLeadDupe(dupeLead.id);

		wishChildContact.Birthdate = newLead.DOB__c;
		wishChildContact.Phone = newLead.Phone;
		wishChildContact.Email = newLead.Email;
		update wishChildContact;
		result = LeadDuplicateService.FindLeadDupe(dupeLead.id);
		Test.stopTest();
	}
}