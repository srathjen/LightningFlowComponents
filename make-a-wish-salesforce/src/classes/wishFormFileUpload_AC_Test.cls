/**
 * @description Wish Form File Upload Test Class
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 8/22/2019
 */
@IsTest
public with sharing class wishFormFileUpload_AC_Test {

	private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;
	private final static Id WISH_RECORD_TYPE_ID = Constant_AC.WISH_RT_ID;

	@TestSetup
	public static void setUpData() {
		List<ICD_Codes__c> icdCodesDataFactory = TestDataFactory.createIcdCode(1);
		ICD_Codes__c icdCode = icdCodesDataFactory.get(0);
		insert icdCode;
		List<Contact> contactsDataFactory = TestDataFactory.createContact(4);
		List<Contact> contacts = new List<Contact>();
		Contact wishChildContact = contactsDataFactory.get(0);
		wishChildContact.FirstName = 'Mark';
		wishChildContact.LastName = 'Smith';
		wishChildContact.ICD_10_Code__c = icdCode.Id;
		wishChildContact.Birthdate = Date.today().addYears(-10);
		wishChildContact.MailingPostalCode = '12345-9876';
		wishChildContact.MailingStreet = 'Mark Street';
		wishChildContact.MailingCountry = 'United States';
		wishChildContact.MailingState = 'Arizona';
		wishChildContact.MailingCity = 'Phoenix';
		contacts.add(wishChildContact);
		insert contacts;
		List<Account> accountsDataFactory = TestDataFactory.createAccount(1);
		List<Account> accounts = new List<Account>();
		Account account = accountsDataFactory.get(0);
		account.Name = 'Make-A-Wish Arizona';
		account.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
		accounts.add(account);
		insert accounts;
		List<Case> casesDataFactory = TestDataFactory.createCase(1);
		List<Case> cases = new List<Case>();
		Case wishCase = casesDataFactory.get(0);
		wishCase.RecordTypeId = WISH_RECORD_TYPE_ID;
		wishCase.ChapterName__c = accounts.get(0).Id;
		wishCase.Subject = 'Wish';
		wishCase.Interview_date__c = System.today();
		wishCase.Wish_Type__c = 'Disney World';
		wishCase.Start_Date__c = System.today();
		wishCase.End_Date__c = System.today();
		wishCase.ContactId = wishChildContact.Id;
		wishCase.Status = 'New';
		wishCase.Start_Date__c = System.today();
		wishCase.Budget_Submitted_Date__c = System.today();
		wishCase.Budget_Approved_Date__c = System.today();
		wishCase.Update_Wish_Child_Form_Info__c = true;
		cases.add(wishCase);
		insert cases;
		List<Attachment> attachmentsDataFactory = TestDataFactory.createAttachments(1, wishCase.Id);
		List<Attachment> attachments = new List<Attachment>();
		Attachment wishCaseAttachment = attachmentsDataFactory.get(0);
		wishCaseAttachment.Name = 'Attachment1.txt';
		attachments.add(wishCaseAttachment);
		insert attachments;
	}

	static testMethod void shouldSaveChunkOfNewFile() {
		// ARRANGE
		Case wishCase = [
				SELECT Id
				FROM Case
				WHERE Wish_Type__c = 'Disney World'
		];
		Id parentId = wishCase.Id;
		String fileName = 'file.txt';
		Blob b = Blob.valueOf('This is the file content');
		String base64Data = EncodingUtil.base64Encode(b);
		String contentType = 'text/plain';
		String fileId = '';
		String description = '';

		// ACT
		Test.startTest();
		Id result = wishFormFileUpload_AC.saveChunk(parentId, fileName, base64Data, contentType, fileId, description);
		Test.stopTest();

		// ASSERT
		System.assertNotEquals(null, result);
	}

	static testMethod void shouldSaveChunkOfExistingFile() {
		// ARRANGE
		Case wishCase = [
				SELECT Id
				FROM Case
				WHERE Wish_Type__c = 'Disney World'
		];
		Attachment caseAttachment = [
				SELECT Id
				FROM Attachment
				WHERE Name = 'Attachment1.txt'
		];

		Id parentId = wishCase.Id;
		String fileName = 'file.txt';
		Blob b = Blob.valueOf('This is the file content');
		String base64Data = EncodingUtil.base64Encode(b);
		String contentType = 'text/plain';
		String fileId = caseAttachment.Id;
		String description = '';

		// ACT
		Test.startTest();
		Id result = wishFormFileUpload_AC.saveChunk(parentId, fileName, base64Data, contentType, fileId, description);
		Test.stopTest();

		// ASSERT
		System.assertNotEquals(null, result);
	}
}