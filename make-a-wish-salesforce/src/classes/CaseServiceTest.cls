/**
 * @description Case Service Test Class
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 8/20/2019
 */
@IsTest
public with sharing class CaseServiceTest {

	@TestSetup
	public static void setUpData() {
		List<Account> accountsDataFactory = TestDataFactory.createAccount(1);
		Account account = accountsDataFactory.get(0);
		insert account;
		List<Contact> contactsDataFactory = TestDataFactory.createContact(1);
		Contact contact = contactsDataFactory.get(0);
		contact.FirstName = 'Test1';
		contact.LastName = 'User2';
		contact.AccountId = account.Id;
		insert contact;
	}

	static testMethod void shouldRestrictUserCasePermission() {
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
					//UserRoleId = userRole.Id,
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

	static testMethod void shouldNotRestrictUserCasePermission() {
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
					//UserRoleId = userRole.Id,
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
}