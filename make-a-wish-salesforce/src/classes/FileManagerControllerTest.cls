/**
* @description File Manager Controller Test
* @author Gustavo Mayer, Traction on Demand
* @createdDate 17/Feb/2021
*/
@IsTest
public with sharing class FileManagerControllerTest {

	@TestSetup
	public static void setup() {
		trac_TriggerHandlerBase.blockTrigger = true;

		List<Account> accounts = TestDataFactory.createAccount(2);
		Account arizonaChapter = accounts.get(0);
		arizonaChapter.Name = 'Make-A-Wish Arizona';
		arizonaChapter.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
		Account arizonaHospital = accounts.get(1);
		arizonaHospital.Name = 'Phoenix General Hospital';
		arizonaHospital.RecordTypeId = Constant_AC.HOSPITAL_TREATMENT_ID;
		insert accounts;

		List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
		ICD_Codes__c icdCode = icdCodes.get(0);
		insert icdCodes;

		List<Contact> contactList = TestDataFactory.createContact(8);
		Contact mpContactLee = contactList.get(0);
		mpContactLee.FirstName = 'Ken';
		mpContactLee.LastName = 'Lee';
		mpContactLee.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
		mpContactLee.Region_Chapter__c = arizonaChapter.Id;
		Contact mpContactMiller = contactList.get(1);
		mpContactMiller.FirstName = 'Jennifer';
		mpContactMiller.LastName = 'Miller';
		mpContactMiller.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
		mpContactMiller.Region_Chapter__c = arizonaChapter.Id;
		Contact mpContactJohnson = contactList.get(2);
		mpContactJohnson.FirstName = 'Raymond';
		mpContactJohnson.LastName = 'Johnson';
		mpContactJohnson.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
		mpContactJohnson.Region_Chapter__c = arizonaChapter.Id;
		Contact mpContactPatel = contactList.get(3);
		mpContactPatel.FirstName = 'Daniel';
		mpContactPatel.LastName = 'Patel';
		mpContactPatel.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
		mpContactPatel.Region_Chapter__c = arizonaChapter.Id;
		Contact mpContactBrown = contactList.get(4);
		mpContactBrown.FirstName = 'Rachel';
		mpContactBrown.LastName = 'Brown';
		mpContactBrown.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
		mpContactBrown.Region_Chapter__c = arizonaChapter.Id;
		Contact wishFamilyWalker = contactList.get(5);
		wishFamilyWalker.FirstName = 'Lucy';
		wishFamilyWalker.LastName = 'Walker';
		wishFamilyWalker.RecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
		wishFamilyWalker.Region_Chapter__c = arizonaChapter.Id;
		Contact boardMember = contactList.get(6);
		boardMember.FirstName = 'Samuel';
		boardMember.LastName = 'Crane';
		boardMember.RecordTypeId = Constant_AC.BOARD_MEMBER_RT_ID;
		boardMember.Region_Chapter__c = arizonaChapter.Id;
		Contact volunteer = contactList.get(7);
		volunteer.FirstName = 'Katherine';
		volunteer.LastName = 'Buckland';
		volunteer.RecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
		volunteer.AccountId = arizonaChapter.Id;
		volunteer.Region_Chapter__c = arizonaChapter.Id;
		insert contactList;

		List<npe5__Affiliation__c> affiliationList = TestDataFactory.createAffiliation(6);
		npe5__Affiliation__c mpLeeAffiliation = affiliationList.get(0);
		mpLeeAffiliation.npe5__Contact__c = mpContactLee.Id;
		mpLeeAffiliation.npe5__Organization__c = arizonaHospital.Id;
		mpLeeAffiliation.npe5__Primary__c = true;
		mpLeeAffiliation.npe5__Status__c = 'Active';
		npe5__Affiliation__c mpMillerAffiliation = affiliationList.get(1);
		mpMillerAffiliation.npe5__Contact__c = mpContactMiller.Id;
		mpMillerAffiliation.npe5__Organization__c = arizonaHospital.Id;
		mpMillerAffiliation.npe5__Primary__c = true;
		npe5__Affiliation__c mpJohnsonAffiliation = affiliationList.get(2);
		mpJohnsonAffiliation.npe5__Contact__c = mpContactJohnson.Id;
		mpJohnsonAffiliation.npe5__Organization__c = arizonaHospital.Id;
		mpJohnsonAffiliation.npe5__Primary__c = true;
		npe5__Affiliation__c mpPatelAffiliation = affiliationList.get(3);
		mpPatelAffiliation.npe5__Contact__c = mpContactPatel.Id;
		mpPatelAffiliation.npe5__Organization__c = arizonaHospital.Id;
		mpPatelAffiliation.npe5__Primary__c = true;
		npe5__Affiliation__c mpBrownAffiliation = affiliationList.get(4);
		mpBrownAffiliation.npe5__Contact__c = mpContactBrown.Id;
		mpBrownAffiliation.npe5__Organization__c = arizonaHospital.Id;
		mpBrownAffiliation.npe5__Primary__c = true;
		npe5__Affiliation__c volunteerAffiliation = affiliationList.get(5);
		volunteerAffiliation.npe5__Contact__c = volunteer.Id;
		volunteerAffiliation.npe5__Organization__c = arizonaChapter.Id;
		volunteerAffiliation.npe5__Primary__c = true;
		volunteerAffiliation.npe5__Status__c = 'Pending';
		insert affiliationList;

		List<Lead> leadList = TestDataFactory.createLead(1);
		Lead wishLead = leadList.get(0);
		wishLead.FirstName = 'Jack';
		wishLead.LastName = 'Smith';
		wishLead.RecordTypeId = Constant_AC.LEAD_RT_WISH_CHILD;
		wishLead.is_Family_Aware_of_Referral__c = 'Yes';
		wishLead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
		wishLead.PD_ICD_Code__c = icdCode.Id;
		wishLead.Company = 'MAW';
		wishLead.Referring_MP__c = mpContactLee.Id;
		wishLead.Referring_MP_HTF__c = arizonaHospital.Id;
		wishLead.Treating_MP__c = mpContactMiller.Id;
		wishLead.Treating_MP_HTF__c = arizonaHospital.Id;
		wishLead.Best_Contact__c = mpContactJohnson.Id;
		wishLead.Best_Contact_HTF__c = arizonaHospital.Id;
		wishLead.Alt_1_MP__c = mpContactPatel.Id;
		wishLead.Alt_1_MP_HTF__c = arizonaHospital.Id;
		wishLead.Alt_2_MP__c = mpContactBrown.Id;
		wishLead.Alt_2_MP_HTF__c = arizonaHospital.Id;
		wishLead.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL;
		insert leadList;

		List<cg__Lead_File__c> leadFilesDataFactory = TestDataFactory.createLeadFile(1);
		cg__Lead_File__c leadFile = leadFilesDataFactory.get(0);
		leadFile.cg__File_Name__c = 'Test File';
		leadFile.cg__Description__c = wishLead.Treating_MP__c;
		leadFile.cg__Lead__c = wishLead.Id;
		insert leadFilesDataFactory;

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void shouldFindLeadFiles_WhenTreatingMp(){
		Lead lead = [
				SELECT Id
				FROM Lead
				WHERE Name = 'Jack Smith'
		][0];

		List<cg__Lead_File__c> leadFiles = [
			SELECT Id, cg__File_Name__c, cg__Description__c
			FROM cg__Lead_File__c
			WHERE cg__File_Name__c = 'Test File'
		];
		System.assert(!leadFiles.isEmpty());

		Test.startTest();
		List<FileManagerController.FileWrapper> fw = FileManagerController.findFiles(lead.Id);
		Test.stopTest();

		System.assertEquals('Test File', fw[0].fileName);
	}

	@IsTest
	public static void shouldFindLeadFiles_WhenReferringMp(){
		Lead lead = [
				SELECT Id, Referring_MP__c, Hidden_DV_form_Medical_professional_Type__c
				FROM Lead
				WHERE Name = 'Jack Smith'
		][0];
		lead.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_REFERRING_MEDICAL_PROFESSIONAL;
		update lead;

		cg__Lead_File__c leadFile = [
				SELECT Id, cg__File_Name__c, cg__Description__c
				FROM cg__Lead_File__c
				WHERE cg__File_Name__c = 'Test File'
		][0];
		leadFile.cg__Description__c = lead.Referring_MP__c;
		update leadFile;

		Test.startTest();
		List<FileManagerController.FileWrapper> fw = FileManagerController.findFiles(lead.Id);
		Test.stopTest();

		System.assertEquals('Test File', fw[0].fileName);
	}

	@IsTest
	public static void shouldFindLeadFiles_WhenBestMp(){
		Lead lead = [
				SELECT Id, Best_Contact__c, Hidden_DV_form_Medical_professional_Type__c
				FROM Lead
				WHERE Name = 'Jack Smith'
		][0];
		lead.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_BEST_CONTACT;
		update lead;

		cg__Lead_File__c leadFile = [
				SELECT Id, cg__File_Name__c, cg__Description__c
				FROM cg__Lead_File__c
				WHERE cg__File_Name__c = 'Test File'
		][0];
		leadFile.cg__Description__c = lead.Best_Contact__c;
		update leadFile;

		Test.startTest();
		List<FileManagerController.FileWrapper> fw = FileManagerController.findFiles(lead.Id);
		Test.stopTest();

		System.assertEquals('Test File', fw[0].fileName);
	}

	@IsTest
	public static void shouldFindLeadFiles_WhenAlt1Mp(){
		Lead lead = [
				SELECT Id, Alt_1_MP__c, Hidden_DV_form_Medical_professional_Type__c
				FROM Lead
				WHERE Name = 'Jack Smith'
		][0];
		lead.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL;
		update lead;

		cg__Lead_File__c leadFile = [
				SELECT Id, cg__File_Name__c, cg__Description__c
				FROM cg__Lead_File__c
				WHERE cg__File_Name__c = 'Test File'
		][0];
		leadFile.cg__Description__c = lead.Alt_1_MP__c;
		update leadFile;

		Test.startTest();
		List<FileManagerController.FileWrapper> fw = FileManagerController.findFiles(lead.Id);
		Test.stopTest();

		System.assertEquals('Test File', fw[0].fileName);
	}

	@IsTest
	public static void shouldFindLeadFiles_WhenAlt2Mp(){
		Lead lead = [
				SELECT Id, Alt_2_MP__c, Hidden_DV_form_Medical_professional_Type__c
				FROM Lead
				WHERE Name = 'Jack Smith'
		][0];
		lead.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL;
		update lead;

		cg__Lead_File__c leadFile = [
				SELECT Id, cg__File_Name__c, cg__Description__c
				FROM cg__Lead_File__c
				WHERE cg__File_Name__c = 'Test File'
		][0];
		leadFile.cg__Description__c = lead.Alt_2_MP__c;
		update leadFile;

		Test.startTest();
		List<FileManagerController.FileWrapper> fw = FileManagerController.findFiles(lead.Id);
		Test.stopTest();

		System.assertEquals('Test File', fw[0].fileName);
	}

	@IsTest
	public static void shouldUploadLeadFiles(){
		Lead lead = [
				SELECT Id
				FROM Lead
				WHERE Name = 'Jack Smith'
		][0];

		FileManagerController.FileWrapper file = new FileManagerController.FileWrapper();
		file.parentId = lead.Id;
		file.fileName = 'Test File';
		file.contentType = 'text/plain';
		file.base64Data = EncodingUtil.base64Encode(Blob.valueOf('File content of the a plain text file'));

		Test.startTest();
		Boolean isFileUploaded = FileManagerController.uploadFile(file);
		Test.stopTest();

		System.assertEquals(true, isFileUploaded);
	}

	@IsTest
	public static void shouldDeleteFile(){
		List<cg__Lead_File__c> leadFiles = [
				SELECT Id
				FROM cg__Lead_File__c
				WHERE cg__File_Name__c = 'Test File'
		];

		Test.startTest();
		Boolean isFileUploaded = FileManagerController.deleteFile(leadFiles[0].Id);
		Test.stopTest();

		System.assertEquals(true, isFileUploaded);
	}
}