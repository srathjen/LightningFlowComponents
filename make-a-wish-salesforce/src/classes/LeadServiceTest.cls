/**
 * Lead Service Test
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 2/27/2020
 */
@IsTest
public class LeadServiceTest {

	private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;

	@TestSetup
	public static void setup() {
		trac_TriggerHandlerBase.blockTrigger = true;
		List<Account> accounts = TestDataFactory.createAccount(2);
		Account account1 = accounts.get(0);
		account1.Name = 'Make-A-Wish Arizona';
		account1.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
		account1.Onboarded_on_SF__c = true;
		Account account2 = accounts.get(1);
		account2.Name = 'Make-A-Wish New York';
		account2.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
		account2.Onboarded_on_SF__c = true;
		insert accounts;

		List<Condition_Description__c> conditionDescriptions = TestDataFactory.createConditionDescription(1);
		Condition_Description__c conditionDescription = conditionDescriptions.get(0);
		conditionDescription.Name = 'Malignant Melanoma';
		conditionDescription.Treatment_Subspecialty__c = 'Oncology';
		conditionDescription.Code_To_Use__c = 'C43.30';
		conditionDescription.PR_Diagnosis__c = 'Malignant Melanoma';
		conditionDescription.Group1__c = true;
		insert conditionDescriptions;

		List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
		ICD_Codes__c icdCode = icdCodes.get(0);
		icdCode.Name = 'icdCode1';
		icdCode.Group1__c = true;
		icdCode.Condition_Description__c = conditionDescription.Id;
		insert icdCodes;

		List<Lead> leads = TestDataFactory.createLead(2);
		Lead lead = leads.get(0);
		lead.RecordTypeId = Constant_AC.LEAD_RT_WISH_CHILD;
		lead.ChapterName__c = account1.Id;
		lead.FirstName = 'Jack';
		lead.LastName = 'Smith';
		lead.Hidden_Chapter_Change_Confirmation__c = account2.Id;
		lead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
		lead.PD_ICD_Code__c = icdCode.Id;
		lead.SD1_ICD_Code__c = icdCode.Id;
		lead.Phone = '1233213333';
		lead.Email = 'wishChild@email.com';
		lead.Street = '123 Street';
		lead.State = 'Arizona';
		lead.StateCode = 'AZ';
		lead.City = 'Phoenix';
		lead.PostalCode = '6201717';
		lead.CountryCode = 'US';
		lead.DOB__c = System.today() - 1435;
		lead.Company = 'MAW';
		lead.Status = 'Inquiry';
		lead.Gender__c = 'Male';
		lead.Referrer_FirstName__c = 'Bob';
		lead.Referrer_Last_Name__c = 'Referrer';
		lead.Referrer_Email__c = 'referrer@email.com';
		lead.Referrer_Phone__c = '9600467578';
		lead.Referrer_City__c = 'Trichy';
		lead.Referrer_Zip__c = '6210';
		lead.Sibling_Detail__c = 'aa | aaab | 14 bbb | bbbc | 15';
		lead.PD_Condition_Description__c = 'Test Diagnosis';
		lead.Parent_First_Name__c = 'MAWAFirstJune';
		lead.Parent_Last_Name__c = 'MAWALastJune';
		lead.Medical_Professional_First_Name__c = 'Bob';
		lead.Medical_Professional_Last_Name__c = 'Medical Professional';
		lead.Medical_Professional_Phone__c = '9600467578';
		lead.Medical_Professional_Email__c = 'treatingMedicalProfessional@email.com';
		lead.Hospital_Treatment_Facility__c = 'Steve Smith AC';
		lead.Hospital_Treatment_Facility_Treating__c = 'Steve Smith AC';
		lead.is_Family_Aware_of_Referral__c = 'Yes';
		lead.Medical_Questions__c = 'Test Diagnosis';
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
		lead.Qualifying_Diagnosis__c = 'Malignant Melanoma';
		lead.Qualifying_ICD__c = icdCode.Id;

		Lead lead2 = leads.get(1);
		lead2.RecordTypeId = Constant_AC.LEAD_RT_WISH_CHILD;
		lead2.ChapterName__c = accounts[0].Id;
		lead2.FirstName = 'Mark';
		lead2.LastName = 'Smith';
		lead2.is_Family_Aware_of_Referral__c = 'Yes';
		lead2.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
		lead2.PD_ICD_Code__c = icdCode.Id;
		lead2.Company = 'MAW';
		insert leads;

		List<Regions__c> regions = TestDataFactory.createRegions(2);
		Regions__c region = regions.get(0);
		region.Chapter_Name__c = account1.Id;
		insert regions;

		List<Office__c> offices = TestDataFactory.createOffice(1);
		Office__c office = offices.get(0);
		office.Chapter__c = account1.Id;
		office.Name = 'Make-A-Wish Alabama';
		office.Office_Id__c = '014-000';
		office.Office_Legal_Name__c = 'Make-A-Wish Alabama,NY, Inc.';
		office.Referral_Email_Address__c = 'referrer@email.com';
		office.General_Email_Address__c = 'wishmail@suffolk.wish.org';
		office.Website__c = 'http://suffolk.wish.org';
		office.Address_1__c = '1 Comac Loop';
		office.Address_2__c = 'Suite 1A1';
		office.City__c = 'Ronkonkoma';
		office.State__c = 'NY';
		office.Zip_Code__c = '32193';
		office.Country__c = 'US';
		office.Phone_Number__c = '(631) 585-9474';
		insert offices;

		List<Zip_Code__c> zipCodes = TestDataFactory.createZipCode(1);
		zipCodes[0].Office__c = offices[0].Id;
		zipCodes[0].Name = '62017';
		zipCodes[0].External_Id__c = '1234567890';
		insert zipCodes;

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void shouldRevertChapterName() {
		Account oldChapter = [
				SELECT Id
				FROM Account
				WHERE Name IN ('Make-A-Wish New York')
		];
		Lead lead = getTestLead();
		List<Id> leadIds = new List<Id>();
		leadIds.add(lead.Id);

		Test.startTest();
		Map<Id, Lead> leadMap = LeadService.revertChapterNameChange(leadIds);
		Test.stopTest();

		System.assertEquals(oldChapter.Id, leadMap.get(lead.Id).ChapterName__c);
		System.assertEquals(oldChapter.Id, leadMap.get(lead.Id).Hidden_Chapter_Change_Confirmation__c);
	}

	@IsTest
	public static void shouldBackupChapterName() {
		Account newChapter = [
				SELECT Id
				FROM Account
				WHERE Name IN ('Make-A-Wish Arizona')
		];
		Lead lead = getTestLead();
		List<Id> leadIds = new List<Id>();
		leadIds.add(lead.Id);

		Test.startTest();
		Map<Id, Lead> leadMap = LeadService.backupChapterNameChange(leadIds);
		Test.stopTest();

		System.assertEquals(newChapter.Id, leadMap.get(lead.Id).Hidden_Chapter_Change_Confirmation__c);
	}

	@IsTest
	public static void shouldResetLeadFields() {
		Lead lead = getTestLead();

		Test.startTest();
		Lead updatedLead = LeadService.resetLead(lead);
		Test.stopTest();

		System.assertEquals(Constant_AC.LEAD_STATUS_REFERRED, updatedLead.Status);
	}

	@IsTest
	public static void shouldMergeLeads() {
		List<Lead> leads = [
				SELECT Id, ChapterName__c
				FROM Lead
				WHERE LastName = 'Smith'
		];

		Test.startTest();
		Boolean result = LeadService.mergeLeads(leads[0], new List<Lead>{
				leads[1]
		});
		Test.stopTest();

		System.assertEquals(true, result);
	}

	@IsTest
	public static void shouldLeadDuplicates() {
		String firstName = 'Jack';
		String lastName = 'Smith';
		String email = 'wishChild@email.com';
		String phone = '1233213333';
		Date dateOfBirth = Date.today().addYears(-10);
		String street = '123 Street';
		String state = 'Arizona';
		String city = 'Phoenix';
		String postalCode = '6201717';

		Test.startTest();
		List<Lead> result = LeadService.findLeadDuplicates(
				firstName, lastName, phone, email, street,
				city, state, postalCode, dateOfBirth,
				new List<Id>{
				}
		);
		Test.stopTest();
		System.assertEquals(1, result.size());
	}

	@IsTest
	public static void shouldLeadDuplicatesWithChapter() {
		Account newChapter = [
				SELECT Id
				FROM Account
				WHERE Name IN ('Make-A-Wish Arizona')
		];
		String firstName = 'Jack';
		String lastName = 'Smith';
		String email = 'wishChild@email.com';
		String phone = '1233213333';
		Date dateOfBirth = Date.today().addYears(-10);
		String street = '123 Street';
		String state = 'Arizona';
		String city = 'Phoenix';
		String postalCode = '6201717';

		Test.startTest();
		List<Lead> result = LeadService.findLeadDuplicatesWithChapter(
				firstName, lastName, phone, email, street,
				city, state, postalCode, dateOfBirth,
				new List<Id>{
				}, newChapter.Id
		);
		Test.stopTest();
		System.assertEquals(1, result.size());
	}

	@IsTest
	public static void shouldSetRegionCode() {
		Account account = [
				SELECT Id
				FROM Account
				WHERE Name = 'Make-A-Wish Arizona'
				LIMIT 1
		];
		Lead lead = [
				SELECT Id, ChapterName__c
				FROM Lead
				WHERE Name = 'Jack Smith'
				LIMIT 1
		];

		Test.startTest();
		LeadService.setRegionCode(new Map<Id, Lead>{
				account.Id => lead
		});
		Test.stopTest();
	}

	@IsTest
	public static void shouldUpdateChapterFields() {
		Lead lead = [
				SELECT Id, PostalCode, Referrer_Zip__c
				FROM Lead
				WHERE Name = 'Jack Smith'
				LIMIT 1
		];

		Test.startTest();
		LeadService.updateChapterFields(new Map<String, Lead>{
				'32193' => lead
		});
		Test.stopTest();
	}

	@IsTest
	public static void shouldSetHiddenChapterName() {
		Account account = [
				SELECT Id, Name
				FROM Account
				WHERE Name = 'Make-A-Wish Arizona'
				LIMIT 1
		];
		Lead lead = [
				SELECT Id, ChapterName__c
				FROM Lead
				WHERE Name = 'Jack Smith'
				LIMIT 1
		];

		Test.startTest();
		LeadService.setHiddenChapterName(new Map<Id, Lead>{
				account.Id => lead
		});
		Test.stopTest();
	}

	@IsTest
	public static void shouldMatchConditionDescription() {
		ICD_Codes__c icdCode = [
				SELECT Name
				FROM ICD_Codes__c
				LIMIT 1
		];
		Lead lead = [
				SELECT Id, ChapterName__c, SD1_ICD_Code__c
				FROM Lead
				WHERE Name = 'Jack Smith'
				LIMIT 1
		];

		Test.startTest();
		Map<Id, Set<Integer>> icdMap = new Map<Id, Set<Integer>>();
		icdMap.put(lead.Id, new Set<Integer>{
				1
		});
		Map<Id, Lead> leadIcdMap = new Map<Id, Lead>();
		leadIcdMap.put(icdCode.Id, lead);
		LeadService.matchConditionDescription(icdMap, leadIcdMap);
		Test.stopTest();
	}

	@IsTest
	public static void shouldUpdateLeadOwner() {
		Account account = [
				SELECT Id, Name
				FROM Account
				WHERE Name = 'Make-A-Wish Arizona'
				LIMIT 1
		];
		Lead lead = [
				SELECT Id, ChapterName__c
				FROM Lead
				WHERE Name = 'Jack Smith'
				LIMIT 1
		];

		Test.startTest();
		LeadService.updateLeadOwner(new Map<Id, Lead>{
				account.Id => lead
		});
		Test.stopTest();
	}

	@IsTest
	public static void shouldSetMedicalInfo() {
		ICD_Codes__c icdCode = [
				SELECT Name, Condition_Description__c
				FROM ICD_Codes__c
				WHERE Name = 'icdCode1'
				LIMIT 1
		];
		Lead lead = [
				SELECT Id, ChapterName__c, Qualifying_ICD__c, PR_Diagnosis__c
				FROM Lead
				WHERE Name = 'Jack Smith'
				LIMIT 1
		];

		Test.startTest();
		LeadService.setMedicalInfo(new Set<String>{
				'Malignant Melanoma'
		}, new Set<String>{
				String.valueOf(icdCode.Id)
		}, new List<Lead>{
				lead
		});
		Test.stopTest();
	}

	@IsTest
	public static void shouldFindDuplicateLeads() {
		List<Lead> leads = [
				SELECT Id, FirstName, LastName, DOB__c, PostalCode, City, State, Phone, Email, ChapterName__c, Street
				FROM Lead
		];
		ICD_Codes__c icdCode = [
				SELECT Name
				FROM ICD_Codes__c
				LIMIT 1
		];
		Account account = [
				SELECT Id, Name
				FROM Account
				WHERE Name = 'Make-A-Wish Arizona'
				LIMIT 1
		];

		trac_TriggerHandlerBase.blockTrigger = true;
        List<Lead> leadDuplicates = TestDataFactory.createLead(2);
        Lead lead1 = leadDuplicates.get(0);
		lead1.FirstName = 'John';
		lead1.LastName = 'Doe';
		lead1.Street = '123 Street';
		lead1.State = 'Arizona';
		lead1.StateCode = 'AZ';
		lead1.City = 'Phoenix';
		lead1.PostalCode = '6201717';
		lead1.CountryCode = 'US';
		lead1.Phone = '1233213333';
		lead1.Email = 'wishChild@email.com';
		lead1.DOB__c = System.today() - 1435;
		lead1.RecordTypeId = Constant_AC.LEAD_RT_WISH_CHILD;
		lead1.is_Family_Aware_of_Referral__c = 'Yes';
		lead1.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
		lead1.PD_ICD_Code__c = icdCode.Id;
		lead1.ChapterName__c = account.Id;
		lead1.Company = 'MAW';
		lead1.Status = 'Inquiry';
		lead1.Gender__c = 'Male';

        Lead lead2 = leadDuplicates.get(1);
        lead2.FirstName = 'Jack';
        lead2.LastName = 'Smith';
        lead2.Street = '123 Street';
        lead2.State = 'Arizona';
        lead2.StateCode = 'AZ';
        lead2.City = 'Phoenix';
        lead2.PostalCode = '6201717';
        lead2.CountryCode = 'US';
        lead2.Phone = '1233213333';
        lead2.Email = 'wishChild@email.com';
        lead2.DOB__c = System.today() - 1435;
        lead2.RecordTypeId = Constant_AC.LEAD_RT_WISH_CHILD;
        lead2.is_Family_Aware_of_Referral__c = 'Yes';
        lead2.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
        lead2.PD_ICD_Code__c = icdCode.Id;
        lead2.ChapterName__c = account.Id;
        lead2.Company = 'MAW';
        lead2.Status = 'Inquiry';
        lead2.Gender__c = 'Male';
		insert leadDuplicates;

		List<Contact> contacts = TestDataFactory.createContact(2);
		Contact contact1 = contacts.get(0);
		contact1.Region_Chapter__c = account.Id;
		contact1.FirstName = 'Jack';
		contact1.LastName = 'Smith';
		contact1.Email = 'wishChild@email.com';
		contact1.Phone = '1233213333';
		contact1.MailingStreet = '123 Street';
		contact1.MailingCity = 'Phoenix';
		contact1.MailingState = 'Arizona';
		contact1.MailingStateCode = 'AZ';
		contact1.MailingPostalCode = '6201717';
		contact1.MailingCountryCode = 'US';
		contact1.RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;

		Contact contact2 = contacts.get(1);
		contact2.Region_Chapter__c = account.Id;
		contact2.FirstName = 'Will';
		contact2.LastName = 'Doe';
		contact2.Email = 'wishChild@email.com';
		contact2.Phone = '1233213333';
		contact2.MailingStreet = '123 Street';
		contact2.MailingCity = 'Phoenix';
		contact2.MailingState = 'Arizona';
		contact2.MailingStateCode = 'AZ';
		contact2.MailingPostalCode = '6201717';
		contact2.MailingCountryCode = 'US';
		contact2.RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
		insert contacts;
		trac_TriggerHandlerBase.blockTrigger = false;

		Test.startTest();
		LeadService.findDuplicateLeads(leads);
		Test.stopTest();
	}

	@IsTest
	public static void shouldFindDuplicateContacts() {
		List<Lead> leads = [
				SELECT Id, FirstName, LastName, DOB__c, PostalCode, City, State, Phone, Email, ChapterName__c, Street,
						Medical_Professional_First_Name__c, Medical_Professional_Last_Name__c, Medical_Professional_Phone__c,
						Medical_Professional_Email__c, Parent_First_Name__c, Parent_Last_Name__c
				FROM Lead
		];
		Account account = [
				SELECT Id, Name
				FROM Account
				WHERE Name = 'Make-A-Wish Arizona'
				LIMIT 1
		];

		trac_TriggerHandlerBase.blockTrigger = true;
		List<Contact> contacts = TestDataFactory.createContact(4);
		Contact contact1 = contacts.get(0);
		contact1.Region_Chapter__c = account.Id;
		contact1.FirstName = 'Jack';
		contact1.LastName = 'Doe';
		contact1.Email = 'jacksmith@email.com';
		contact1.Phone = '1233213333';
		contact1.MailingStreet = '123 Street';
		contact1.MailingCity = 'Phoenix';
		contact1.MailingState = 'Arizona';
		contact1.MailingStateCode = 'AZ';
		contact1.MailingPostalCode = '6201717';
		contact1.MailingCountryCode = 'US';
		contact1.RecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;

		Contact contact2 = contacts.get(1);
		contact2.Region_Chapter__c = account.Id;
		contact2.FirstName = 'Bob';
		contact2.LastName = 'Medical Professional';
		contact2.Email = 'treatingMedicalProfessional@email.com';
		contact2.Phone = '9600467578';
		contact2.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;

		Contact contact3 = contacts.get(2);
		contact3.Region_Chapter__c = account.Id;
		contact3.FirstName = 'Bob';
		contact3.LastName = 'Treating Medical Professional';
		contact3.Email = 'treatingMedicalProfessional@email.com';
		contact3.Phone = '9600467578';
		contact3.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;

		Contact contact4 = contacts.get(3);
		contact4.Region_Chapter__c = account.Id;
		contact4.FirstName = 'Bob';
		contact4.LastName = 'Best Contact';
		contact4.Email = 'bestContact@email.com';
		contact4.Phone = '9600467578';
		contact4.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;

		insert contacts;
		trac_TriggerHandlerBase.blockTrigger = false;

		Test.startTest();
		LeadService.findDuplicateContacts(leads);
		Test.stopTest();
	}

	@IsTest
	public static void shouldValidateQualifiedRequiredFields() {
		List<Lead> leads = [
				SELECT Id, FirstName, DOB__c, Any_medical_reason_for_moving_quickly__c, I_am_Recognized_To_Practice_As_a__c
				FROM Lead
				WHERE Name = 'Jack Smith'
		];
		leads[0].FirstName = null;
		leads[0].DOB__c = null;
		leads[0].Any_medical_reason_for_moving_quickly__c = null;
		leads[0].I_am_Recognized_To_Practice_As_a__c = null;

		Test.startTest();
		LeadService.validateQualifiedRequiredFields(leads);
		Test.stopTest();
	}

	@IsTest
	public static void shouldSetQualifyingDiagnosis() {
		ICD_Codes__c icdCode = [
				SELECT Name
				FROM ICD_Codes__c
				LIMIT 1
		];
		List<Lead> leads = [
				SELECT Id
				FROM Lead
		];

		Test.startTest();
		LeadService.setQualifyingDiagnosis(icdCode.Name, leads);
		Test.stopTest();
	}

	@IsTest
	public static void shouldSetChapterViaZipCode() {
		List<Lead> leads = [
				SELECT Id, PostalCode, ChapterName__c
				FROM Lead
				WHERE Name = 'Jack Smith'
		];

		Test.startTest();
		LeadService.setChapterViaZipCode(leads);
		Test.stopTest();
	}

	private static Lead getTestLead() {
		return [
				SELECT Id, ChapterName__c, Diagnosis_Given_By_Referrer__c, ICD_Given_By_Referrer__c, Status
				FROM Lead
				WHERE Name = 'Jack Smith'
		];
	}
}