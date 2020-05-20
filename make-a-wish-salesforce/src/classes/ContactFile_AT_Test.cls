@IsTest
public class ContactFile_AT_Test {

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

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void createContactFile() {
		Contact contact = [
				SELECT Id
				FROM Contact
				WHERE Name = 'Jack Smith'
		];

		cg__ContactFile__c contactFolder = new cg__ContactFile__c();
		contactFolder.cg__File_Name__c = 'Documents';
		contactFolder.cg__Contact__c = contact.Id;
		contactFolder.cg__Content_Type__c = Constant_AC.FILE_CONTENT_TYPE_FOLDER;
		insert contactFolder;
		cg__ContactFile__c contactFile = new cg__ContactFile__c();
		contactFile.cg__File_Name__c = 'MedicalSummary2.txt';
		contactFile.cg__Contact__c = contact.Id;
		contactFile.cg__Content_Type__c = Constant_AC.FILE_NAME_DOCUMENTS;
		insert contactFile;
	}
}