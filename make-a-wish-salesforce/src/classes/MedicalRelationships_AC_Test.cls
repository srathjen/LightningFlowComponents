@IsTest
public class MedicalRelationships_AC_Test {

	private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;
	private final static Id MEDICAL_PROFESSIONAL_RT = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;


	@TestSetup
	public static void setup() {
		List<Account> accounts = TestDataFactory.createAccount(1);
		Account account1 = accounts.get(0);
		account1.Name = 'Make-A-Wish Arizona';
		account1.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
		insert accounts;

		List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
		ICD_Codes__c icdCode = icdCodes.get(0);
		insert icdCode;

		List<Lead> leadsDataFactory = TestDataFactory.createLead(1);
		Lead lead = leadsDataFactory.get(0);
		lead.ChapterName__c = accounts[0].Id;
		lead.FirstName = 'Jack';
		lead.LastName = 'Smith';
		lead.Hidden_Chapter_Change_Confirmation__c = account1.Id;
		lead.is_Family_Aware_of_Referral__c = 'Yes';
		lead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
		lead.PD_ICD_Code__c = icdCode.Id;
		lead.Company = 'MAW';
		insert lead;

		List<Contact> contacts = TestDataFactory.createContact(2);
		Contact wishChild = contacts.get(0);
		wishChild.FirstName = 'Test1';
		wishChild.LastName = 'User1';
		wishChild.AccountId = account1.Id;
		wishChild.ICD_10_Code__c = icdCode.Id;
		wishChild.Birthdate = Date.today().addYears(-3);
		wishChild.RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
		Contact medicalProfessional = contacts.get(1);
		medicalProfessional.FirstName = 'Test1';
		medicalProfessional.LastName = 'User2';
		medicalProfessional .RecordTypeId = MEDICAL_PROFESSIONAL_RT;
		insert contacts;

		List<npe4__Relationship__c> relationships = TestDataFactory.createRelationship(1);
		npe4__Relationship__c newRelationShip = relationships.get(0);
		newRelationShip.npe4__Contact__c = wishChild.Id;
		newRelationShip.npe4__RelatedContact__c = medicalProfessional.Id;
		newRelationShip.npe4__Status__c = 'Active';
		newRelationShip.npe4__Type__c = 'Medical Professional';

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
		wish.ContactId = wishChild.Id;
		wish.Status = 'New';
		wish.Rush__c = false;
		wish.Start_Date__c = System.today();
		wish.Budget_Submitted_Date__c = System.today();
		wish.Budget_Approved_Date__c = System.today();
		wish.Update_Wish_Child_Form_Info__c = true;
		insert cases;
	}

	@IsTest
	static void createRelationship() {
		Case wishCase = [
				SELECT Id
				FROM Case
				WHERE Subject = 'Wish1'
		];
		PageReference pageRef = Page.MedicalRelationships_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.StandardController stdController = new ApexPages.StandardController(wishCase);
		MedicalRelationships_AC medicalRelationshipsAC = new MedicalRelationships_AC(stdController);
		medicalRelationshipsAC.getmedicalRelationshipsConList();
	}
}