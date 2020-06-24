/**
 * An apex page controller that exposes the site login functionality
 */
@IsTest
global class CommunitiesLoginControllerTest {

	private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;

	@TestSetup
	public static void setUp() {
		trac_TriggerHandlerBase.blockTrigger = true;
		User currentUser = Utils.currentUser;
		List<Account> accounts = TestDataFactory.createAccount(1);
		Account account = accounts.get(0);
		account.Name = 'Make-A-Wish Arizona';
		account.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
		account.Volunteer_Manager__c = currentUser.Id;
		account.Alert_for_Unassigned_Wishes__c = 1;
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

		List<Contact> contacts = TestDataFactory.createContact(2);
		Contact contact1 = contacts.get(0);
		contact1.FirstName = 'Test1';
		contact1.LastName = 'User2';
		contact1.AccountId = account.Id;
		contact1.ICD_10_Code__c = icdCode.Id;
		insert contacts;

		User volunteerUser = TestDataFactory.createVolunteerUser(1, 'Active Volunteer (Login)', 'Manager').get(0);
		volunteerUser.LastName = 'Smith0';
		volunteerUser.Email = 'js@email.com';
		System.runAs(TestDataFactory.adminUser) {
			insert volunteerUser;
		}

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

		List<npe5__Affiliation__c> affiliations = TestDataFactory.createAffiliation(1);
		npe5__Affiliation__c affiliation = affiliations.get(0);
		affiliation.npe5__Contact__c = volunteerUser.ContactId;
		affiliation.npe5__Organization__c = accounts[0].Id;
		affiliation.npe5__Primary__c = true;
		affiliation.npe5__Status__c = 'Pending';

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void loginAsProspectiveUser() {
		User volunteerUser = [
				SELECT Id, ContactId, ProfileId
				FROM User
				WHERE Email = 'js@email.com'
		][0];
		System.runAs(volunteerUser) {
			CommunitiesLoginController controller = new CommunitiesLoginController();
			controller.username = 'testuser0@testorg.com';
			Test.setCurrentPageReference(new PageReference('Page.CommunitiesLoginController'));
			System.currentPageReference().getParameters().put('startURL', '/');
			controller.login();
		}
		System.assert(volunteerUser.ContactId != null, 'Id should not blank');
	}

	@IsTest
	public static void loginAsActiveUser() {
		User volunteerUser = [
				SELECT Id, ContactId, ProfileId
				FROM User
				WHERE Email = 'js@email.com'
		][0];
		System.runAs(volunteerUser) {
			CommunitiesLoginController controller = new CommunitiesLoginController();
			controller.username = 'testuser0@testorg.com';
			Test.setCurrentPageReference(new PageReference('Page.CommunitiesLoginController'));
			System.currentPageReference().getParameters().put('startURL', '/');
			controller.login();
		}
		System.assert(volunteerUser.ContactId != null, 'Id should not blank');
	}

	@IsTest
	public static void createCustomSettingValueforActive() {
		User volunteerUser = [
				SELECT Id, ContactId, ProfileId, Contact.AccountId, Contact.Account.Name
				FROM User
				WHERE Email = 'js@email.com'
		][0];
		npe5__Affiliation__c affiliation = new npe5__Affiliation__c ();
		affiliation.npe5__Contact__c = volunteerUser.ContactId;
		affiliation.npe5__Organization__c = volunteerUser.Contact.AccountId;
		affiliation.npe5__Primary__c = true;
		affiliation.npe5__Status__c = 'Prospective';
		affiliation.Constituent_Code__c = Constant_AC.BOARD_MEMBER_RT_LABEL;
		insert affiliation;

		System.runAs(volunteerUser) {
			HoldCurrentChapter__c holdCurrentChapter = new HoldCurrentChapter__c();
			holdCurrentChapter.Name = volunteerUser.Id;
			holdCurrentChapter.CurrentChapter__c = volunteerUser.Contact.Account.Name;
			insert holdCurrentChapter;
			CommunitiesLoginController controller = new CommunitiesLoginController();
			Test.setCurrentPageReference(new PageReference('Page.CommunitiesLoginController'));
			System.currentPageReference().getParameters().put('startURL', '/');
			controller.username = 'testuser0@testorg.com';
			controller.login();
		}
		System.assert(volunteerUser.ContactId != null, 'Id should not blank');
	}

	@IsTest
	public static void withoutCustomSettingValueforActive() {
		User volunteerUser = [
				SELECT Id, ContactId, ProfileId, Contact.AccountId, Contact.Account.Name
				FROM User
				WHERE Email = 'js@email.com'
		][0];
		npe5__Affiliation__c affiliation = new npe5__Affiliation__c ();
		affiliation.npe5__Contact__c = volunteerUser.ContactId;
		affiliation.npe5__Organization__c = volunteerUser.Contact.AccountId;
		affiliation.npe5__Primary__c = true;
		affiliation.npe5__Primary__c = true;
		affiliation.npe5__Status__c = 'Prospective';
		affiliation.Constituent_Code__c = Constant_AC.BOARD_MEMBER_RT_LABEL;
		insert affiliation;
		System.runAs(volunteerUser) {
			CommunitiesLoginController controller = new CommunitiesLoginController();
			controller.username = 'testuser0@testorg.com';
			Test.setCurrentPageReference(new PageReference('Page.CommunitiesLoginController'));
			System.currentPageReference().getParameters().put('startURL', '/');
			controller.login();
		}
		System.assert(volunteerUser.ContactId != null, 'Id should not blank');
	}

	@IsTest
	public static void loginAsWrongUser() {
		User volunteerUser = [
				SELECT Id, ContactId, ProfileId, Contact.AccountId, Contact.Account.Name
				FROM User
				WHERE Email = 'js@email.com'
		][0];
		System.runAs(volunteerUser) {
			CommunitiesLoginController controller = new CommunitiesLoginController();
			controller.username = 'testuser_doesnotexist@testorg.com';
			Test.setCurrentPageReference(new PageReference('Page.CommunitiesLoginController'));
			System.currentPageReference().getParameters().put('startURL', '/');
			controller.login();
		}
		System.assert(volunteerUser.ContactId != null, 'Id should not blank');
	}
}