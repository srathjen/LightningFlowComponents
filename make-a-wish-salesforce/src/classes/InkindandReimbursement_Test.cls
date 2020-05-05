@IsTest
public class InkindandReimbursement_Test {

	private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;

	@TestSetup
	public static void setup() {
		trac_TriggerHandlerBase.blockTrigger = true;
		List<Account> accounts = TestDataFactory.createAccount(1);
		Account account = accounts.get(0);
		account.Name = 'Make-A-Wish Arizona';
		account.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
		insert accounts;

		List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
		ICD_Codes__c icdCode = icdCodes.get(0);
		insert icdCode;

		List<Lead> leadsDataFactory = TestDataFactory.createLead(1);
		Lead lead = leadsDataFactory.get(0);
		lead.ChapterName__c = accounts[0].Id;
		lead.FirstName = 'Jack';
		lead.LastName = 'Smith';
		lead.Hidden_Chapter_Change_Confirmation__c = account.Id;
		lead.is_Family_Aware_of_Referral__c = 'Yes';
		lead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
		lead.PD_ICD_Code__c = icdCode.Id;
		lead.Company = 'MAW';
		insert lead;

		List<Contact> contacts = TestDataFactory.createContact(1);
		Contact contact1 = contacts.get(0);
		contact1.FirstName = 'Test1';
		contact1.LastName = 'User2';
		contact1.AccountId = account.Id;
		contact1.ICD_10_Code__c = icdCode.Id;
		insert contacts;

		List<Case> cases = TestDataFactory.createCase(1);
		Case wish = cases.get(0);
		wish.Lead__c = lead.Id;
		wish.RecordTypeId = Constant_AC.DIAGNOSIS_RT_ID;
		wish.ChapterName__c = accounts.get(0).Id;
		wish.Subject = 'Wish1';
		wish.Interview_date__c = System.today();
		wish.Wish_Type__c = 'Hawaii';
		wish.Start_Date__c = System.today();
		wish.End_Date__c = System.today();
		wish.ContactId = contact1.Id;
		wish.Status = 'New';
		wish.Rush__c = false;
		wish.Start_Date__c = System.today();
		wish.Budget_Submitted_Date__c = System.today();
		wish.Budget_Approved_Date__c = System.today();
		wish.Update_Wish_Child_Form_Info__c = true;
		insert cases;

		List<Document> documents = TestDataFactory.createDocument(1);
		Document document = documents.get(0);
		document.Body = Blob.valueOf('Some Text');
		document.ContentType = 'application/pdf';
		document.IsPublic = true;
		document.FolderId = [
				SELECT Id
				FROM Folder
				WHERE Name = 'Drawloop Files'
		].Id;
		insert documents;



		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void createRecords() {
		List<Case> cases = [
				SELECT Id
				FROM Case
				WHERE Lead__r.Name = 'Jack Smith'
		];

		PageReference pageRef = Page.InkindandReimbursement_VF;
		pageRef.getParameters().put('recId', String.valueOf(cases.get(0).Id));
		ApexPages.StandardController sc = new ApexPages.StandardController(cases.get(0));
		Test.setCurrentPage(pageRef);
		InkindandReimbursement_AC controller = new InkindandReimbursement_AC (sc);
		controller.ReturnToWish();
	}
}