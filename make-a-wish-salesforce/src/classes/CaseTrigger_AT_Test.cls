/**
 * Author      : MST Solutions
 * Date        : 10/4/2016
 * Description : This class is used to increase the code coverage for CaseTrigger_AT and CaseTriggerHandler
 * Modification Log:
 * 23/03/2018 - Sankar - WVC-1835
 **/
@IsTest
public class CaseTrigger_AT_Test {

	@TestSetup
	public static void setUp() {
		trac_TriggerHandlerBase.blockTrigger = true;

		List<Account> accounts = TestDataFactory.createAccount(1);
		Account account1 = accounts.get(0);
		account1.Name = 'Make-A-Wish Arizona';
		account1.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
		insert accounts;

		String profileName = 'Full Access National Staff';
		String portalRole = 'Manager';
		Id userRoleId = [
				SELECT Id
				FROM UserRole
				WHERE Name = 'National Staff'
		].Id;

		List<User> users = TestDataFactory.createUser(1);
		System.runAs(Utils.currentUser) {
			Profile profile = [
					SELECT Id,Name
					FROM Profile
					WHERE Name = :profileName
					LIMIT 1
			];
			User u = users.get(0);
			u.ProfileId = profile.Id;
			u.PortalRole = portalRole;
			u.UserRoleId = userRoleId;
			u.ManagerId = Utils.currentUser.Id;
			insert users;
		}

		List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
		ICD_Codes__c icdCode = icdCodes.get(0);
		insert icdCode;

		Regions__c region = new Regions__c();
		region.Name = 'Default';
		insert region;

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
		wishChild.Region_Code__c = region.Id;
		wishChild.County__c = 'Arizona';
		insert contacts;

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void createCase() {
		Account account = [
				SELECT Id
				FROM Account
				LIMIT 1
		];
		Contact wishChild = [
				SELECT Id
				FROM Contact
				WHERE Name = 'Steven Smith'
				LIMIT 1
		];
		User user = [
				SELECT Id, ManagerId
				FROM User
				WHERE ManagerId = :Utils.currentUser.Id
				LIMIT 1
		];

		List<Case> cases = TestDataFactory.createCase(1);
		Case wish = cases.get(0);
		wish.ChapterName__c = account.Id;
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
		wish.OwnerId = user.Id;
		wish.RecordTypeId = Constant_AC.WISH_RT_ID;
		insert cases;
	}

	@IsTest
	public static void updateCase_ReadyToAssign() {
		Account account = [
				SELECT Id
				FROM Account
				LIMIT 1
		];
		Contact wishChild = [
				SELECT Id
				FROM Contact
				WHERE Name = 'Steven Smith'
				LIMIT 1
		];
		User user = [
				SELECT Id, ManagerId
				FROM User
				WHERE ManagerId = :Utils.currentUser.Id
				LIMIT 1
		];

		List<Case> cases = TestDataFactory.createCase(1);
		Case wish = cases.get(0);
		wish.ChapterName__c = account.Id;
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
		wish.OwnerId = user.Id;
		wish.Comment_1__c = '';
		wish.RecordTypeId = Constant_AC.WISH_RT_ID;
		wish.Appropriate_Comments__c = '';
		wish.Please_Explain__c = '';
		wish.Sub_Status__c = Constant_AC.CASE_SUB_STATUS_PENDING;
		insert cases;

		wish.Status = Constant_AC.CASE_STATUS_READY_TO_ASSIGN;
		wish.Comment_1__c = 'test';
		wish.Appropriate_Comments__c = 'Test';
		wish.Please_Explain__c = 'Test';
		wish.Wish_Clearance_Needed__c = 'Yes';
		wish.OwnerId = Utils.currentUser.Id;
		update wish;
	}

	@IsTest
	public static void updateCase_ReadyToInterview() {
		Account account = [
				SELECT Id
				FROM Account
				LIMIT 1
		];
		Contact wishChild = [
				SELECT Id
				FROM Contact
				WHERE Name = 'Steven Smith'
				LIMIT 1
		];
		User user = [
				SELECT Id, ManagerId
				FROM User
				WHERE ManagerId = :Utils.currentUser.Id
				LIMIT 1
		];

		List<Case> cases = TestDataFactory.createCase(1);
		Case wish = cases.get(0);
		wish.ChapterName__c = account.Id;
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
		wish.OwnerId = user.Id;
		wish.Comment_1__c = '';
		wish.RecordTypeId = Constant_AC.WISH_RT_ID;
		wish.Status = Constant_AC.CASE_STATUS_READY_TO_ASSIGN;
		wish.Sub_Status__c = Constant_AC.CASE_SUB_STATUS_PENDING;
		insert cases;

		wish.Status = Constant_AC.CASE_STATUS_READY_TO_INTERVIEW;
		wish.Comment_1__c = 'test';
		wish.Wish_Clearance_Needed__c = 'No';
		update wish;
	}

	@IsTest
	public static void updateCase_Escalated() {
		Account account = [
				SELECT Id
				FROM Account
				LIMIT 1
		];
		Contact wishChild = [
				SELECT Id
				FROM Contact
				WHERE Name = 'Steven Smith'
				LIMIT 1
		];
		User user = [
				SELECT Id, ManagerId
				FROM User
				WHERE ManagerId = :Utils.currentUser.Id
				LIMIT 1
		];

		List<Case> cases = TestDataFactory.createCase(1);
		Case wish = cases.get(0);
		wish.ChapterName__c = account.Id;
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
		wish.OwnerId = user.Id;
		wish.Case_Comment__c = '';
		wish.RecordTypeId = Constant_AC.DIAGNOSIS_RT_ID;
		wish.Status = Constant_AC.CASE_STATUS_ESCALATED;
		insert cases;

		wish.Case_Comment__c = 'test';
		wish.Status = Constant_AC.CASE_STATUS_ESCALATED;
		update wish;
	}

	@IsTest
	public static void updateCase_Determined() {
		Account account = [
				SELECT Id
				FROM Account
				LIMIT 1
		];
		Contact wishChild = [
				SELECT Id
				FROM Contact
				WHERE Name = 'Steven Smith'
				LIMIT 1
		];
		User user = [
				SELECT Id, ManagerId
				FROM User
				WHERE ManagerId = :Utils.currentUser.Id
				LIMIT 1
		];

		List<Case> cases = TestDataFactory.createCase(1);
		Case wish = cases.get(0);
		wish.ChapterName__c = account.Id;
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
		wish.OwnerId = user.Id;
		wish.Case_Comment__c = '';
		wish.RecordTypeId = Constant_AC.WISH_RT_ID;
		wish.Status = Constant_AC.CASE_STATUS_NEW;
		insert cases;

		wish.Case_Comment__c = 'test';
		wish.Status = Constant_AC.CASE_STATUS_WISH_DETERMINED;
		update wish;
	}
}