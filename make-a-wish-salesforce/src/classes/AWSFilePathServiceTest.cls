@IsTest
public class AWSFilePathServiceTest {

	@TestSetup
	public static void setUp() {
		trac_TriggerHandlerBase.blockTrigger = true;

		User volunteerUser = TestDataFactory.createVolunteerUser(1, 'Active Volunteer (Login)', 'Manager').get(0);
		volunteerUser.LastName = 'Smith0';
		volunteerUser.Email = 'js@email.com';
		System.runAs(TestDataFactory.adminUser) {
			insert volunteerUser;
		}

		List<Account> accounts = TestDataFactory.createAccount(1);
		Account account = accounts.get(0);
		account.Name = 'Make-A-Wish Arizona';
		account.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
		insert accounts;

		List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
		ICD_Codes__c icdCode = icdCodes.get(0);
		insert icdCode;

		List<Contact> contactList = TestDataFactory.createContact(2);
		Contact wishChildAnthony = contactList.get(1);
		wishChildAnthony.FirstName = 'Anthony';
		wishChildAnthony.LastName = 'Edwards';
		wishChildAnthony.Parent_Guardian_Name__c = 'Jonathan Edwards';
		wishChildAnthony.RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
		wishChildAnthony.Birthdate = Date.today().addDays(+21);
		wishChildAnthony.Birthdate = wishChildAnthony.Birthdate.addYears(-5);
		wishChildAnthony.MailingPostalCode = '94105-5188';
		wishChildAnthony.MailingStreet = '7540 E Gold Dust Ave';
		wishChildAnthony.MailingCountry = 'United States';
		wishChildAnthony.MailingState = 'Arizona';
		wishChildAnthony.MailingCity = 'Scottsdale';
		wishChildAnthony.MailingLatitude = -24.355798;
		wishChildAnthony.MailingLongitude = 69.830469;
		insert contactList;

		Case wishChildCase = TestDataFactory.createCase(1)[0];
		wishChildCase.RecordTypeId = Constant_AC.WISH_RT_ID;
		wishChildCase.ChapterName__c = account.Id;
		wishChildCase.Subject = 'Parent Wish';
		wishChildCase.Interview_date__c = System.today();
		wishChildCase.Wish_Type__c = 'Disney World';
		wishChildCase.Start_Date__c = System.today();
		wishChildCase.End_Date__c = System.today();
		wishChildCase.ContactId = wishChildAnthony.Id;
		wishChildCase.Status = 'New';
		wishChildCase.Start_Date__c = System.today();
		wishChildCase.LiabilitySignerMapKeyPair__c = 'Vennila';
		wishChildCase.Budget_Submitted_Date__c = System.today();
		wishChildCase.Budget_Approved_Date__c = System.today();
		insert wishChildCase;

		cg__ContactFile__c contactFolder = new cg__ContactFile__c();
		contactFolder.cg__File_Name__c = 'Documents';
		contactFolder.cg__Contact__c = wishChildAnthony.Id;
		contactFolder.cg__Content_Type__c = Constant_AC.FILE_CONTENT_TYPE_FOLDER;
		insert contactFolder;
		cg__ContactFile__c contactFile = new cg__ContactFile__c();
		contactFile.cg__File_Name__c = 'MedicalSummary2.txt';
		contactFile.cg__Contact__c = wishChildAnthony.Id;
		contactFile.cg__Content_Type__c = Constant_AC.FILE_NAME_DOCUMENTS;
		insert contactFile;

		List<Wish_Signature_Forms__c> wishSignFormsDataFactory = TestDataFactory.createWishSignatureForm(1);
		wishSignFormsDataFactory[0].Form_Type__c = 'Medical';
		insert wishSignFormsDataFactory;

		List<Wish_Signature_Chapter_Form__c> wishSignChapFormsDataFactory = TestDataFactory.createWishSignatureChapterForm(1);
		wishSignChapFormsDataFactory[0].Chapter_Account__c = account.Id;
		wishSignChapFormsDataFactory[0].Wish_Signature_Form__c = wishSignFormsDataFactory[0].Id;
		insert wishSignChapFormsDataFactory;

		List<Wish_Affiliation__c> wishAffiliationsDataFactory = TestDataFactory.createWishAffiliation(1);
		wishAffiliationsDataFactory[0].Contact__c = wishChildAnthony.Id;
		wishAffiliationsDataFactory[0].Wish_Affiliation_Type__c = 'Approved Participant' ;
		wishAffiliationsDataFactory[0].Wish__c = wishChildCase.Id;
		insert wishAffiliationsDataFactory;

		List<Wish_Required_Signature__c> wishReqSignsDataFactory = TestDataFactory.createWishRequiredSignature(1);
		wishReqSignsDataFactory[0].Wish_Case__c = wishChildCase.Id;
		wishReqSignsDataFactory[0].Wish_Signature_Form__c = wishSignFormsDataFactory[0].Id;
		wishReqSignsDataFactory[0].Status__c = 'Not Sent';
		wishReqSignsDataFactory[0].Type__c = 'Medical';
		wishReqSignsDataFactory[0].Wish_Affiliation__c = wishAffiliationsDataFactory[0].Id;
		insert wishReqSignsDataFactory;

		Wish_Required_Signature_File__c wrsFile = TestDataFactory.createWRSFileRecord(wishReqSignsDataFactory[0].Id);
		insert wrsFile;

		List<cg__AccountFile__c> accountFileList = TestDataFactory.createAccountFile(1);
		cg__AccountFile__c accountFile = accountFileList.get(0);
		accountFile.cg__Account__c = account.Id;
		accountFile.cg__File_Name__c = 'MAW-Arizona.txt';
		accountFile.File_Path__c = '';
		insert accountFileList;

		cg__CaseFile__c caseFile = new cg__CaseFile__c();
		caseFile.cg__File_Name__c = 'MedicalSummary.txt';
		caseFile.cg__Case__c = wishChildCase.Id;
		caseFile.cg__Content_Type__c = 'image';
		caseFile.File_Path__c = 'Test';
		insert caseFile;

		List<Background_check__c> backgroundChecks = TestDataFactory.createBackgroundCheck(1);
		Background_check__c backgroundCheck = backgroundChecks.get(0);
		backgroundCheck.Date__c = Date.today();
		backgroundCheck.Volunteer__c = volunteerUser.ContactId;
		backgroundCheck.Current__c = true;
		backgroundCheck.Status__c = 'Approved';
		backgroundCheck.Date_Completed__c = Date.today();
		insert backgroundChecks;

		Background_Check_File__c backgroundCheckFile = new Background_Check_File__c();
		backgroundCheckFile.File_Name__c = 'Test File';
		backgroundCheckFile.WIP__c = false;
		backgroundCheckFile.Parent__c = backgroundCheck.Id;
		insert backgroundCheckFile;

		List<In_Kind_Donation_Reimbursement__c> reimbursements = TestDataFactory.createInKindDonationReimbursement(1);
		In_Kind_Donation_Reimbursement__c reimbursement = reimbursements.get(0);
		reimbursement.Date_of_Gift__c = System.today() + 2;
		reimbursement.Gift_Type__c = 'Goods';
		reimbursement.Gift_Value__c = 123456;
		reimbursement.Documentation__c = 'Not available';
		reimbursement.RecordTypeId = Constant_AC.IN_KIND_ID;
		reimbursement.Make_check_payable_to_me__c = true;
		reimbursement.Wish__c = wishChildCase.Id;
		insert reimbursements;

		InkindDon_reimburseFile__c reimbursementServicesFile = TestDataFactory.createInKindDonationReimbursementFile(reimbursement.Id);
		reimbursementServicesFile.File_Name__c = 'ReimbursementSummary.txt';
		insert reimbursementServicesFile;

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void shouldUpdateWishRequiredSignatureFilePath() {
		List<Wish_Required_Signature_File__c> wishRequiredSignatureFiles = [
				SELECT Id
				FROM Wish_Required_Signature_File__c
		];

		Test.startTest();
		AWSFilePathService.updateWishRequiredSignatureFilePath(new List<Id>{
				wishRequiredSignatureFiles.get(0).Id
		}, new Map<Id, String>());
		Test.stopTest();
	}

	@IsTest
	public static void shouldUpdateAccountFilePath() {
		List<cg__AccountFile__c> accountFiles = [
				SELECT Id
				FROM cg__AccountFile__c
		];

		Test.startTest();
		AWSFilePathService.updateAccountFilePath(new List<Id>{
				accountFiles.get(0).Id
		}, new Map<Id, String>());
		Test.stopTest();
	}

	@IsTest
	public static void shouldUpdateContactFilePath() {
		List<cg__ContactFile__c> contactFiles = [
				SELECT Id
				FROM cg__ContactFile__c
		];

		Test.startTest();
		AWSFilePathService.updateContactFilePath(new List<Id>{
				contactFiles.get(0).Id
		}, new Map<Id, String>());
		Test.stopTest();
	}

	@IsTest
	public static void shouldUpdateCaseFilePath() {
		List<cg__CaseFile__c> caseFiles = [
				SELECT Id
				FROM cg__CaseFile__c
		];

		Test.startTest();
		AWSFilePathService.updateCaseFilePath(new List<Id>{
				caseFiles.get(0).Id
		}, new Map<Id, String>());
		Test.stopTest();
	}

	@IsTest
	public static void shouldUpdateBackgroundCheckFilePath() {
		List<Background_Check_File__c> backgroundCheckFiles = [
				SELECT Id
				FROM Background_Check_File__c
		];

		Test.startTest();
		AWSFilePathService.updateBackgroundCheckFilePath(new List<Id>{
				backgroundCheckFiles.get(0).Id
		}, new Map<Id, String>());
		Test.stopTest();
	}

	@IsTest
	public static void shouldUpdateInKindDonReimburseFilePath() {
		List<InkindDon_reimburseFile__c> inkindDonReimburseFiles = [
				SELECT Id
				FROM InkindDon_reimburseFile__c
		];

		Test.startTest();
		AWSFilePathService.updateInKindDonReimburseFilePath(new List<Id>{
				inkindDonReimburseFiles.get(0).Id
		}, new Map<Id, String>());
		Test.stopTest();
	}
}