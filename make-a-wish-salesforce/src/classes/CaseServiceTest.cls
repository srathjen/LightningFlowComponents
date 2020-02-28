/**
 * @description Case Service Test Class
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 8/20/2019
 */
@IsTest
public with sharing class CaseServiceTest {

	@TestSetup
	public static void setUpData() {
		List<Account> accounts = TestDataFactory.createAccount(2);
		Account account1 = accounts.get(0);
		Account account2 = accounts.get(1);
		insert accounts;
		List<Contact> contacts = TestDataFactory.createContact(2);
		Contact contact1 = contacts.get(0);
		contact1.FirstName = 'Test1';
		contact1.LastName = 'User2';
		contact1.AccountId = account1.Id;
		Contact contact2 = contacts.get(1);
		contact2.FirstName = 'Test2';
		contact2.LastName = 'User3';
		contact2.AccountId = account2.Id;
		insert contacts;
		List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
		insert icdCodes;
		List<Lead> leads = TestDataFactory.createLead(1);
		Lead lead = leads.get(0);
		lead.ChapterName__c = account2.Id;
		lead.FirstName = 'Jack';
		lead.LastName = 'Smith';
		lead.Hidden_Chapter_Change_Confirmation__c = account2.Id;
		lead.is_Family_Aware_of_Referral__c = 'Yes';
		lead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
		lead.PD_ICD_Code__c = icdCodes.get(0).Id;
		lead.Company = 'MAW';
		insert lead;
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
		wish.ContactId = contact2.Id;
		wish.Status = 'New';
		wish.Start_Date__c = System.today();
		wish.Budget_Submitted_Date__c = System.today();
		wish.Budget_Approved_Date__c = System.today();
		wish.Update_Wish_Child_Form_Info__c = true;
		insert cases;
	}

	@IsTest
	static void shouldRestrictUserCasePermission() {
		Contact contact = [
				SELECT Id
				FROM Contact
				WHERE Name = 'Test1 User2'
		];
		User adminUser = [
				SELECT Id
				FROM User
				WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE
				LIMIT 1
		];
		System.runAs (adminUser) {
			UserRole userRole = [
					SELECT PortalType, PortalAccountId
					FROM UserRole
					WHERE PortalType = :'CustomerPortal'
					LIMIT 1
			];
			Profile profile = [
					SELECT Id,Name
					FROM Profile
					WHERE Name = 'Active Volunteer (Member)'
					LIMIT 1
			];
			User user = new User(
					UserRoleId = userRole.Id,
					ProfileId = profile.Id,
					Username = 'newUser@yahoo.com',
					Email = 'pb@ff.com',
					EmailEncodingKey = 'UTF-8',
					LocaleSidKey = 'en_US',
					LanguageLocaleKey = 'en_US',
					TimeZoneSidKey = 'America/Los_Angeles',
					Alias = 'nuser',
					LastName = 'lastname',
					ContactId = contact.Id
			);
			insert user;
			insert new Closed_Case_Editing_Security_Settings__c(SetupOwnerId = user.Id, Restrict_Access__c = true);
			System.runAs(user) {
				Boolean result = CaseService.userHasRestrictedPermissionOnCase();
				System.assertEquals(true, result);
			}
		}
	}

	@IsTest
	static void shouldNotRestrictUserCasePermission() {
		Contact contact = [
				SELECT Id
				FROM Contact
				WHERE Name = 'Test1 User2'
		];
		User adminUser = [
				SELECT Id
				FROM User
				WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE
				LIMIT 1
		];
		System.runAs (adminUser) {
			UserRole userRole = [
					SELECT PortalType, PortalAccountId
					FROM UserRole
					WHERE PortalType = :'CustomerPortal'
					LIMIT 1
			];
			Profile profile = [
					SELECT Id,Name
					FROM Profile
					WHERE Name = 'Active Volunteer (Member)'
					LIMIT 1
			];
			User user = new User(
					UserRoleId = userRole.Id,
					ProfileId = profile.Id,
					Username = 'newUser@yahoo.com',
					Email = 'pb@ff.com',
					EmailEncodingKey = 'UTF-8',
					LocaleSidKey = 'en_US',
					LanguageLocaleKey = 'en_US',
					TimeZoneSidKey = 'America/Los_Angeles',
					Alias = 'nuser',
					LastName = 'lastname',
					ContactId = contact.Id
			);
			insert user;
			System.runAs(user) {
				Boolean result = CaseService.userHasRestrictedPermissionOnCase();
				System.assertEquals(false, result);
			}
		}
	}

	@IsTest
	static void shouldDeleteCase() {
		Lead lead = [
				SELECT Id
				FROM Lead
				WHERE Name = 'Jack Smith'
		];

		Test.startTest();
		CaseService.deleteByLeadIdAndRecordTypeNames(lead.Id,
				new List<String>{Constant_AC.CASE_RECORD_TYPE_DIAGNOSIS_VERIFICATION_REVIEW});
		Test.stopTest();

		List<Case> cases = [
				SELECT Id
				FROM Case
				WHERE Lead__c = :lead.Id
		];
		System.assertEquals(0, cases.size());
	}
}