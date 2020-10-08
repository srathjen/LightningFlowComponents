@IsTest
public class ContactFileServiceTest {

	@TestSetup
	public static void setUp() {
		trac_TriggerHandlerBase.blockTrigger = true;

		List<Account> accounts = TestDataFactory.createAccount(1);
		Account account = accounts.get(0);
		account.Name = 'Make-A-Wish Arizona';
		account.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
		insert accounts;

		List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
		ICD_Codes__c icdCode = icdCodes.get(0);
		insert icdCode;

		List<Contact> contacts = TestDataFactory.createContact(1);
		Contact contact1 = contacts.get(0);
		contact1.FirstName = 'Jack';
		contact1.LastName = 'Smith';
		contact1.AccountId = account.Id;
		contact1.ICD_10_Code__c = icdCode.Id;
		insert contacts;

		List<Lead> leads = TestDataFactory.createLead(1);
		Lead qualifiedLead = leads.get(0);
		qualifiedLead.RecordTypeId = Constant_AC.LEAD_RT_WISH_CHILD;
		qualifiedLead.ChapterName__c = account.Id;
		qualifiedLead.FirstName = 'Jack';
		qualifiedLead.LastName = 'Smith';
		qualifiedLead.Hidden_Chapter_Change_Confirmation__c = account.Id;
		qualifiedLead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
		qualifiedLead.PD_ICD_Code__c = icdCode.Id;
		qualifiedLead.Phone = '9600467559';
		qualifiedLead.Email = 'testmawa@email.com';
		qualifiedLead.Street = 'KuttaiKarai Street';
		qualifiedLead.StateCode = 'AZ';
		qualifiedLead.City = 'Phoenix';
		qualifiedLead.PostalCode = '840001';
		qualifiedLead.CountryCode = 'US';
		qualifiedLead.DOB__c = System.today() - 1435;
		qualifiedLead.Company = 'MAW';
		qualifiedLead.Status = Constant_AC.LEAD_STATUS_REFERRED;
		qualifiedLead.Gender__c = 'Male';
		qualifiedLead.I_am_Recognized_To_Practice_As_a__c = 'Physician';
		qualifiedLead.Any_medical_reason_for_moving_quickly__c = 'No';
		qualifiedLead.Referrer_FirstName__c = 'SteveJune';
		qualifiedLead.Referrer_Last_Name__c = 'Waughone';
		qualifiedLead.Referrer_Email__c = 'testmawa2d@email.com';
		qualifiedLead.Referrer_Phone__c = '9600467578';
		qualifiedLead.Referrer_City__c = 'Trichy';
		qualifiedLead.Referrer_Zip__c = '6210';
		qualifiedLead.PD_Condition_Description__c = 'Test Diagnosis';
		qualifiedLead.Wish_Family_ContactId__c = contact1.Id;
		qualifiedLead.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL;
		qualifiedLead.is_Family_Aware_of_Referral__c = 'Yes';
		qualifiedLead.Medical_Questions__c = 'Test Diagnosis';
		qualifiedLead.Lung_Disease__c = 'Test1;Test2';
		qualifiedLead.Angina__c = 'Test1;Test2';
		qualifiedLead.Ventilator__c = 'Test1;Test2';
		qualifiedLead.Arrhythmia__c = 'Test1;Test2';
		qualifiedLead.Heart_Failure__c = 'Test1;Test2';
		qualifiedLead.Congenital_Heart_Disease__c = 'Test1;Test2';
		qualifiedLead.Chronic_Hepatitis__c = 'Test1;Test2';
		qualifiedLead.Convulsive_Disorders__c = 'Test1;Test2';
		qualifiedLead.Pulmonary_Hypertension__c = 'Test1;Test2';
		qualifiedLead.Strokes__c = 'Test1;Test2';
		qualifiedLead.Chronic_Heart_Failure__c = 'Test1;Test2';
		qualifiedLead.isSign__c = true;
		qualifiedLead.Travel_algorithm__c = 'Test1;Test2;';
		qualifiedLead.Sibling_Detail__c = 'aa | aaab | 14 <br> bbb | bbbc | 15 <br>';
		qualifiedLead.Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
		insert leads;

		qualifiedLead.Sub_Status__c = Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION;
		update qualifiedLead;

		List<cg__Lead_File__c> leadFileList = TestDataFactory.createLeadFile(1);
		cg__Lead_File__c leadFileFrieda = leadFileList.get(0);
		leadFileFrieda.cg__Lead__c = qualifiedLead.Id;
		leadFileFrieda.cg__Description__c = 'Medical Information for Frieda Crowley';
		leadFileFrieda.File_Path__c = 'TestPath';
		insert leadFileList;

		cg__ContactFile__c contactFolder = new cg__ContactFile__c();
		contactFolder.cg__File_Name__c = 'Documents';
		contactFolder.cg__Contact__c = contact1.Id;
		contactFolder.cg__Content_Type__c = Constant_AC.FILE_CONTENT_TYPE_FOLDER;
		insert contactFolder;
		cg__ContactFile__c contactFile = new cg__ContactFile__c();
		contactFile.cg__File_Name__c = 'MedicalSummary2.txt';
		contactFile.cg__Contact__c = contact1.Id;
		contactFile.cg__Content_Type__c = Constant_AC.FILE_NAME_DOCUMENTS;
		insert contactFile;

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void shouldBuildFileFoldersLeadConvert() {
		Contact contact = [
				SELECT Id
				FROM Contact
				WHERE Name = 'Jack Smith'
		];

		ContactFileService.buildFileFoldersLeadConvert(contact.Id);
	}

	@IsTest
	public static void shouldBuildFilesLeadConvert() {
		Lead leadToConvert = [
				SELECT Id
				FROM Lead
				LIMIT 1
		];
		LeadStatus convertStatus = [
				SELECT MasterLabel
				FROM LeadStatus
				WHERE IsConverted = TRUE
				LIMIT 1
		];
		Database.LeadConvert lc = new Database.LeadConvert();
		lc.setLeadId(leadToConvert.Id);
		lc.setDoNotCreateOpportunity(true);
		lc.setConvertedStatus(convertStatus.MasterLabel);
		Database.convertLead(new List<Database.LeadConvert>{lc});
		Lead convertedLead = [
				SELECT Id, ConvertedContactId
				FROM Lead
				LIMIT 1
		];

		ContactFileService.buildFilesLeadConvert(new Map<Id, Lead>{
				convertedLead.Id => convertedLead
		});
	}

	@IsTest
	public static void shouldUpdateContactFilePath() {
		List<cg__ContactFile__c> contactFiles = [
				SELECT Id
				FROM cg__ContactFile__c
		];

		ContactFileService.updateContactFilePath(contactFiles);
	}

	@IsTest
	public static void shouldUpdateContactFileFolderId() {
		List<cg__ContactFile__c> contactFiles = [
				SELECT Id, cg__Contact__c, cg__Content_Type__c, cg__Parent_Folder_Id__c
				FROM cg__ContactFile__c
		];

		ContactFileService.updateContactFileFolderId(contactFiles);
	}
}