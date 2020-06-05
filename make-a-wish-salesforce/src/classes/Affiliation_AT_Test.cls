@IsTest
public class Affiliation_AT_Test {

	@TestSetup
	public static void setUp() {
		trac_TriggerHandlerBase.blockTrigger = true;

		List<Account> accounts = TestDataFactory.createAccount(1);
		Account account = accounts.get(0);
		account.Name = 'Make-A-Wish Arizona';
		account.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
		insert accounts;

		ICD_Codes__c icdCode = new ICD_Codes__c();
		icdCode.Name = 'Q917';
		insert icdCode;

		List<Contact> contacts = TestDataFactory.createContact(2);
		Contact contact1 = contacts.get(0);
		contact1.FirstName = 'Test1';
		contact1.LastName = 'User2';
		contact1.AccountId = account.Id;
		contact1.ICD_10_Code__c = icdCode.Id;

		Contact contact2 = contacts.get(0);
		contact2.FirstName = 'Test2';
		contact2.LastName = 'User3';
		contact2.AccountId = account.Id;
		contact2.ICD_10_Code__c = icdCode.Id;
		insert contacts;

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	static void createUpdateAffiliation() {
		Account account = [
				SELECT Id
				FROM Account
				LIMIT 1
		];
		List<Contact> contacts = [
				SELECT Id
				FROM Contact
		];

		List<npe5__Affiliation__c> affiliations = TestDataFactory.createAffiliation(1);
		npe5__Affiliation__c affiliation = affiliations.get(0);
		affiliation.npe5__Contact__c = contacts.get(0).Id;
		affiliation.npe5__Organization__c = account.Id;
		affiliation.npe5__Primary__c = true;
		affiliation.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_PENDING;

		Test.startTest();
		insert affiliations;

		affiliation.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
		update affiliations;

		delete affiliations;
		Test.stopTest();
	}
}