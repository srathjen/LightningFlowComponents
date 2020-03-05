@IsTest
public class LeadDuplicate_ACTest {

	private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;

	@TestSetup
	public static void setup() {
		trac_TriggerHandlerBase.blockTrigger = true;
		List<Account> accounts = TestDataFactory.createAccount(2);
		Account account1 = accounts.get(0);
		account1.Name = 'MAW Arizona';
		account1.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
		account1.MAC_Email_del__c = 'test1@email.com';
		Account account2 = accounts.get(1); 
		account2.Name = 'MAW York';
		account2.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
		account2.MAC_Email_del__c = 'test2@email.com';
		insert accounts;

		List<ICD_Codes__c> icdCodesDataFactory = TestDataFactory.createIcdCode(1);
		ICD_Codes__c icdCode = icdCodesDataFactory.get(0);
		insert icdCode;

		List<Contact> contacts = TestDataFactory.createContact(1);
		Contact wishChildContact = contacts.get(0);
		wishChildContact.FirstName = 'Jack';
		wishChildContact.LastName = 'Smith';
		wishChildContact.Email = 'testmawa@gmail.com';
		wishChildContact.Phone = '9600467559';
		wishChildContact.OtherPhone = '8056913402';
		wishChildContact.MobilePhone = '9003910426';
		wishChildContact.MailingStreet = 'East Street';
		wishChildContact.MailingCity = 'Trichy';
		wishChildContact.MailingState = 'Arizona';
		wishChildContact.MailingStateCode = 'AZ';
		wishChildContact.MailingPostalCode = '85251';
		wishChildContact.MailingCountryCode = 'US';
		wishChildContact.MobilePhone = '9900220022';
		wishChildContact.Primary_Diagnosis_Condition_Description__c = 'Test';
		wishChildContact.Diagnosis__c = 'test';
		insert contacts;

		List<Lead> leads = TestDataFactory.createLead(2);
		Lead lead = leads.get(0);
		lead.ChapterName__c = account1.Id;
		lead.FirstName = 'Jack';
		lead.LastName = 'Smith';
		lead.Child_Age__c = '4';
		lead.unique_wish_identifier__c = '1234567';
		lead.Hidden_Chapter_Change_Confirmation__c = account1.Id;
		lead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
		lead.PD_ICD_Code__c = icdCode.Id;
		lead.Phone = '9600467559';
		lead.Email = 'testmawa@gmail.com';
		lead.Street = 'KuttaiKarai Street';
		lead.StateCode = 'AZ';
		lead.City = 'Trichy';
		lead.PostalCode = '6201717';
		lead.CountryCode = 'US';
		lead.DOB__c = System.today() - 1435;
		lead.Company = 'MAW';
		lead.Status = 'Inquiry';
		lead.Gender__c = 'Male';
		lead.Referrer_FirstName__c = 'SteveJune';
		lead.Referrer_Last_Name__c = 'Waughone';
		lead.Referrer_Email__c = 'testmawa2d@gmail.com';
		lead.Referrer_Phone__c = '9600467578';
		lead.Referrer_City__c = 'Trichy';
		lead.Referrer_Zip__c = '6210';
		lead.Sibling_Detail__c = 'aa | aaab | 14 bbb | bbbc | 15';
		lead.PD_Condition_Description__c = 'Test Diagnosis';
		lead.Parent_First_Name__c = 'MAWAFirstJune';
		lead.Parent_Last_Name__c = 'MAWALastJune';
		lead.Additional_Parent_Relationship_to_Child__c = '';
		lead.Additional_Parent_First_Name__c = 'Parent2';
		lead.Additional_Parent_Last_Name__c = 'Lead';
		lead.Additional_Parent_Phone__c = '9876543210';
		lead.Additional_Parent_Email__c = 'parent2@mail.com';
		lead.Additional_Parent_Postal_Code__c = '35004';
		lead.Additional_Parent_City__c = 'Test st';
		lead.Additional_Parent_State__c = 'Alabama';
		lead.Medical_Professional_First_Name__c = 'SteveJune';
		lead.Medical_Professional_Last_Name__c = 'Waughone';
		lead.Medical_Professional_Phone__c = '9600467578';
		lead.Medical_Professional_Email__c = 'testmawa2d@gmail.com';
		lead.Hospital_Treatment_Facility__c = 'Steve Smith AC';
		lead.Treating_Medical_Professional_First_Name__c = 'SteveJune';
		lead.Treating_Medical_Professional_Last_Name__c = 'Waughone';
		lead.Treating_Medical_Professional_Phone__c = '9600467578';
		lead.Treating_Medical_Professional_Email__c = 'testmawa2d@gmail.com';
		lead.Hospital_Treatment_Facility_Treating__c = 'Steve Smith AC';
		lead.Best_Contact_for_Physician_First_Name__c = 'SteveJune';
		lead.Best_Contact_for_Physician_Last_Name__c = 'Waughone';
		lead.Best_contact_for_Physician_Email__c = 'testmawa2d@gmail.com';
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

		Lead lead2 = leads.get(1);
		lead2.ChapterName__c = accounts[0].Id;
		lead2.FirstName = 'Jack';
		lead2.LastName = 'Smith';
		lead2.is_Family_Aware_of_Referral__c = 'Yes';
		lead2.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
		lead2.PD_ICD_Code__c = icdCode.Id;
		lead2.Company = 'MAW';
		lead2.Override_Dupe_Check__c = true;
		lead2.Child_Age__c = '4';
		lead2.unique_wish_identifier__c = '654321';
		insert leads;
		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	static void createDuplicateFamily() {
		List<Lead> leads = [
				SELECT Id
				FROM Lead
				WHERE Name = 'Jack Smith'
		];
		ApexPages.currentPage().getParameters().put('wishFamily', 'True');
		ApexPages.currentPage().getParameters().put('Id', leads[0].Id);
		List<Lead> currLead = new List<Lead>();
		currLead.add(leads[0]);
		currLead.add(leads[1]);
		ApexPages.StandardSetController std = new ApexPages.StandardSetController(currLead);
		LeadDuplicate_AC controller = new LeadDuplicate_AC(std);
		controller.getdupLeadList();
		controller.getdupContactList();
		controller.getAdditionalParentContactList();
		controller.getdupMedicalContactList();
		controller.getdupTreatingContactList();
		controller.getdupParentContactList();
		controller.nextStep();
	}

	@IsTest
	static void selectNoDuplicate() {
		List<Lead> leads = [
				SELECT Id
				FROM Lead
				WHERE Name = 'Jack Smith'
		];
		List<Contact> contacts = [
				SELECT Id
				FROM Contact
				WHERE Name = 'Jack Smith'
		];
		ApexPages.currentPage().getParameters().put('wishFamily', 'True');
		ApexPages.currentPage().getParameters().put('Id', leads[0].Id);
		List<Lead> currLead = new List<Lead>();
		currLead.add(leads[0]);
		currLead.add(leads[1]);
		ApexPages.StandardSetController std = new ApexPages.StandardSetController(currLead);
		LeadDuplicate_AC controller = new LeadDuplicate_AC(std);
		controller.noDuplicate = true;
		controller.nextStep();
		controller.ContinuePartAForm();
		controller.hideTreatingSection = false;
		controller.treatingContactId = contacts[0].Id;
		controller.ContinuePartAForm();
		controller.hideTreatingSection = true;
		controller.ContinuePartAForm();
		controller.CompleteDupeCheck();
	}

	@IsTest
	static void duplicateMedicalProfessional() {
		List<Lead> leads = [
				SELECT Id
				FROM Lead
				WHERE Name = 'Jack Smith'
		];
		ApexPages.currentPage().getParameters().put('wishFamily', 'True');
		ApexPages.currentPage().getParameters().put('Id', leads[0].Id);
		List<Lead> currLead = new List<Lead>();
		currLead.add(leads[0]);
		currLead.add(leads[1]);
		ApexPages.StandardSetController std = new ApexPages.StandardSetController(currLead);
		LeadDuplicate_AC controller = new LeadDuplicate_AC(std);
		controller.getdupAlternate1MedicalContactList();
		controller.getdupAlternate2MedicalContactList();
		controller.getbestPhysicianContactList();
		for (Lead currDup : currLead) {
			LeadDuplicate_AC.leadWrapper newWrapper = new LeadDuplicate_AC.leadWrapper(currDup);
			newWrapper.selected = true;
			controller.wrapperList.add(newWrapper);
		}
		controller.nextStep();
		ApexPages.currentPage().getParameters().put('recordId', currLead[0].Id);
		controller.selectDefaultRecord();
		controller.mergeContacts();
		controller.GoToLeadViewPage();
	}

	@IsTest
	static void stopLeadMerge() {
		List<Account> accounts = [
				SELECT Id
				FROM Account
				WHERE Name LIKE 'MAW%'
		];
		ApexPages.StandardSetController std = new ApexPages.StandardSetController(new List<Lead>());
		LeadDuplicate_AC controller = new LeadDuplicate_AC(std);
		controller.loadMergeCandidates(new Map<Id, Account>(accounts).keySet());
		controller.loadMergeCandidates(new Set<Id>{
				accounts[0].Id, accounts[1].Id
		});
		controller.isNo();
	}

	@IsTest
	static void continueLeadMerge() {
		List<Account> accounts = [
				SELECT Id
				FROM Account
				WHERE Name LIKE 'MAW%'
		];
		ApexPages.StandardSetController std = new ApexPages.StandardSetController(new List<Lead>());
		LeadDuplicate_AC controller = new LeadDuplicate_AC(std);
		controller.loadMergeCandidates(new Map<Id, Account>(accounts).keySet());
		controller.loadMergeCandidates(new Set<Id>{
				accounts[0].Id, accounts[1].Id
		});
		controller.isYes();
	}

	@IsTest
	static void blankLead() {
		List<Account> accounts = [
				SELECT Id
				FROM Account
				WHERE Name LIKE 'MAW%'
		];
		ApexPages.StandardSetController std = new ApexPages.StandardSetController(new List<Lead>());
		LeadDuplicate_AC controller = new LeadDuplicate_AC(std);
		controller.loadMergeCandidates(new Map<Id, Account>(accounts).keySet());
		controller.loadMergeCandidates(new Set<Id>{
				accounts[0].Id, accounts[1].Id
		});
	}
}