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

		List<Contact> contacts = TestDataFactory.createContact(5);
		Contact childContact = contacts.get(0);
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

		Contact childContactDuplicate = contacts.get(1);
		childContactDuplicate.Region_Chapter__c = account1.Id;
		childContactDuplicate.FirstName = 'James';
		childContactDuplicate.LastName = 'B';
		childContactDuplicate.Email = 'bobj@email.com';
		childContactDuplicate.Phone = '1234567890';
		childContactDuplicate.MailingStreet = '456 Street';
		childContactDuplicate.MailingCity = 'Phoenix';
		childContactDuplicate.MailingState = 'Arizona';
		childContactDuplicate.MailingStateCode = 'AZ';
		childContactDuplicate.MailingPostalCode = '8042123';
		childContactDuplicate.MailingCountryCode = 'US';
		childContactDuplicate.MobilePhone = '9900220022';
		childContactDuplicate.Primary_Diagnosis_Condition_Description__c = 'Test';
		childContactDuplicate.Diagnosis__c = 'test';

		Contact familyContact = contacts.get(2);
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

		List<Lead> leads = TestDataFactory.createLead(3);
		Lead lead = leads.get(0);
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
		lead.Child_Age__c = '4';
		lead.RecordTypeId = Constant_AC.LEAD_RT_WISH_CHILD;

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
		leadDuplicated.Child_Age__c = '5';
		leadDuplicated.RecordTypeId = Constant_AC.LEAD_RT_WISH_CHILD;

		Lead leadNotDuplicated = leads.get(2);
		leadNotDuplicated.FirstName = 'Bob';
		leadNotDuplicated.LastName = 'Johnson';
		leadNotDuplicated.Phone = '1234567890';
		leadNotDuplicated.Email = 'bobj@email.com';
		leadNotDuplicated.Street = '456 Street';
		leadNotDuplicated.City = 'Phoenix';
		leadNotDuplicated.State = 'Arizona';
		leadNotDuplicated.StateCode = 'AZ';
		leadNotDuplicated.PostalCode = '8042123';
		leadNotDuplicated.CountryCode = 'US';
		leadNotDuplicated.DOB__c = System.today() - 1000;
		leadNotDuplicated.Company = 'MAW';
		leadNotDuplicated.Status = 'Inquiry';
		leadNotDuplicated.Gender__c = 'Male';
		leadNotDuplicated.ChapterName__c = account1.Id;
		leadNotDuplicated.Parent_First_Name__c = 'Paul';
		leadNotDuplicated.Parent_Last_Name__c = 'Smith';
		leadNotDuplicated.Referrer_FirstName__c = 'Matt';
		leadNotDuplicated.Referrer_Last_Name__c = 'Test';
		leadNotDuplicated.Referrer_Email__c = 'matt@email.com';
		leadNotDuplicated.Referrer_Phone__c = '3212323434';
		leadNotDuplicated.Referrer_City__c = 'Phoenix';
		leadNotDuplicated.Referrer_Zip__c = '4545';
		leadNotDuplicated.Sibling_Detail__c = '';
		leadNotDuplicated.PD_Condition_Description__c = 'Test Diagnosis';
		leadNotDuplicated.Medical_Professional_First_Name__c = 'Rick';
		leadNotDuplicated.Medical_Professional_Last_Name__c = 'A';
		leadNotDuplicated.Medical_Professional_Phone__c = '9600467559';
		leadNotDuplicated.Medical_Professional_Email__c = 'testmawa1s@gmail.com';
		leadNotDuplicated.Hospital_Treatment_Facility__c = 'Moss Hart AC';
		leadNotDuplicated.Treating_Medical_Professional_First_Name__c = 'Steve';
		leadNotDuplicated.Treating_Medical_Professional_Last_Name__c = 'Smith';
		leadNotDuplicated.Treating_Medical_Professional_Phone__c = '9600467578';
		leadNotDuplicated.Treating_Medical_Professional_Email__c = 'testmawa2d@gmail.com';
		leadNotDuplicated.Hospital_Treatment_Facility_Treating__c = 'Steve Smith 2';
		leadNotDuplicated.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis2';
		leadNotDuplicated.is_Family_Aware_of_Referral__c = 'Yes';
		leadNotDuplicated.Medical_Questions__c = 'Test Diagnosis2';
		leadNotDuplicated.PD_ICD_Code__c = icdCode.Id;
		leadNotDuplicated.Child_Age__c = '10';
		leadNotDuplicated.RecordTypeId = Constant_AC.LEAD_RT_WISH_CHILD;
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
	public static void shouldFndLeadDupe() {
		Lead lead = [
				SELECT Id, ChapterName__c
				FROM Lead
				WHERE LastName = 'Smith'
				LIMIT 1
		];

		Test.startTest();
		String result = LeadDuplicateService.FindLeadDupe(lead.Id);
		System.assertEquals(LeadDuplicateService.DUPE_MESSAGE, result);
		Test.stopTest();
	}

	@IsTest
	public static void shouldNotFndLeadDupe() {
		Lead lead = [
				SELECT Id, ChapterName__c
				FROM Lead
				WHERE LastName = 'Johnson'
				LIMIT 1
		];

		Test.startTest();
		String result = LeadDuplicateService.FindLeadDupe(lead.Id);
		System.assertEquals(null, result);
		Test.stopTest();
	}
}