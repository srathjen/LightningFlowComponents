/*****************************************************************************************************************
Author      : MST Solutions
Date        : 10/26/2016
Description : This class contains test method for CaseFile object
*******************************************************************************************************************/
@IsTest
public class CaseFile_AT_Test {

	@TestSetup static void methodName() {
		trac_TriggerHandlerBase.blockTrigger = true;

		List<Account> accounts = TestDataFactory.createAccount(1);
		Account account1 = accounts.get(0);
		account1.Name = 'Make-A-Wish Arizona';
		account1.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
		insert accounts;

		List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
		ICD_Codes__c icdCode = icdCodes.get(0);
		insert icdCode;

		List<Contact> contacts = TestDataFactory.createContact(3);
		Contact wishChild = contacts.get(0);
		wishChild.FirstName = 'Steven';
		wishChild.LastName = 'Smith';
		wishChild.Parent_Guardian_Name__c = 'Jonathan Edwards';
		wishChild.RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
		wishChild.ICD_10_Code__c = icdCode.Id;
		wishChild.Birthdate = Date.today().addDays(18);
		wishChild.MailingPostalCode = '94105-5188';
		wishChild.MailingStreet = '7540 E Gold Dust Ave';
		wishChild.MailingCountry = 'United States';
		wishChild.MailingState = 'Arizona';
		wishChild.MailingCity = 'Scottsdale';
		wishChild.MailingLatitude = -24.355798;
		wishChild.MailingLongitude = 69.830469;
		insert contacts;

		List<Case> cases = TestDataFactory.createCase(1);
		Case wish = cases.get(0);
		wish.RecordTypeId = Constant_AC.WISH_RT_ID;
		wish.ChapterName__c = account1.Id;
		wish.Subject = 'Parent Wish';
		wish.Interview_date__c = System.today();
		wish.Wish_Type__c = 'Disney World';
		wish.Start_Date__c = System.today();
		wish.End_Date__c = System.today();
		wish.ContactId = wishChild.Id;
		wish.Status = 'New';
		wish.Start_Date__c = System.today();
		wish.LiabilitySignerMapKeyPair__c = 'Vennila';
		wish.Budget_Submitted_Date__c = System.today();
		wish.Budget_Approved_Date__c = System.today();
		insert cases;

		cg__CaseFile__c caseFile = new cg__CaseFile__c();
		caseFile.cg__File_Name__c = 'MedicalSummary.txt';
		caseFile.cg__Case__c = wish.Id;
		caseFile.cg__Content_Type__c = 'image';
		caseFile.File_Path__c = 'Test';
		insert caseFile;
		cg__CaseFile__c newCaseFile = new cg__CaseFile__c();
		newCaseFile.cg__Case__c = wish.Id;
		newCaseFile.cg__Content_Type__c = 'Folder';
		newCaseFile.cg__File_Name__c = 'Documents';
        newCaseFile.File_Path__c = 'Test';
		insert newCaseFile;
		cg__CaseFile__c newCaseFile1 = new cg__CaseFile__c();
		newCaseFile1.cg__Case__c = wish.Id;
		newCaseFile1.cg__Content_Type__c = 'Folder';
		newCaseFile1.cg__File_Name__c = 'Documents';
		newCaseFile1.cg__Parent_Folder_Id__c = newCaseFile.Id;
        newCaseFile1.File_Path__c = 'Test';
		insert newCaseFile1;
		cg__CaseFile__c folderCon = new cg__CaseFile__c();
		folderCon.cg__Case__c = wish.Id;
		folderCon.cg__Content_Type__c = 'Folder1';
		folderCon.cg__File_Name__c = 'Documents';
		folderCon.cg__Parent_Folder_Id__c = newCaseFile.Id;
        folderCon.File_Path__c = 'Test';
		insert folderCon;

		Minor_Participant__c minorParticipant = new Minor_Participant__c();
		minorParticipant.Associated_Childeren__c = 'Test';
		minorParticipant.AttachmentId__c = 'Test';
		minorParticipant.RecordTypeId = Constant_AC.WISH_CLEARANCE_ATTACHMENT_ID;
		minorParticipant.Case__c = wish.Id;
		insert minorParticipant;

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void createCaseFile() {
		Case wish = [
				SELECT Id
				FROM Case
				LIMIT 1
		];
		cg__CaseFile__c caseFile = new cg__CaseFile__c();
		caseFile.cg__File_Name__c = 'MedicalSummary2.txt';
		caseFile.cg__Case__c = wish.Id;
		caseFile.cg__Content_Type__c = 'image';
		insert caseFile;
	}

	@IsTest
	public static void updateCaseFile() {
		cg__CaseFile__c newCaseFile = [
				SELECT Id, cg__File_Name__c
				FROM cg__CaseFile__c
				WHERE cg__File_Name__c = 'Documents'
				LIMIT 1
		];
        newCaseFile.File_Path__c = 'Test2';
        update newCaseFile;
	}

	@IsTest
	public static void deleteCaseFile() {
		Test.startTest();
		Case wish = [
				SELECT Id
				FROM Case
				LIMIT 1
		];
		cg__CaseFile__c deleteCaseFile = [
				SELECT Id, cg__File_Name__c, File_Path__c
				FROM cg__CaseFile__c
				LIMIT 1
		];
		Minor_Participant__c newMinorPart = new Minor_Participant__c();
		newMinorPart.Case__c = wish.Id;
		newMinorPart.File_Path__c = 'Path';
		insert newMinorPart;

		delete deleteCaseFile;
		Test.stopTest();
	}
}