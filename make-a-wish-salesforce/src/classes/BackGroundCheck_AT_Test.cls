/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 28/06/2016
Description : BackGroundCheck_AT_Test is used to increase the code coverage for Application_AC controller.
*****************************************************************************************************/
@IsTest
public class BackGroundCheck_AT_Test {

	@TestSetup
	public static void setup(){
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
			User nationalUser = users.get(0);
			nationalUser.ProfileId = profile.Id;
			nationalUser.PortalRole = portalRole;
			nationalUser.UserRoleId = userRoleId;
			nationalUser.LastName = 'Doe1';
			nationalUser.Alias = 'Nat';
			nationalUser.Email = 'nationaluser1@testorg.com';
			nationalUser.Username = 'nationaluser1@testorg.com';
			nationalUser.EmailEncodingKey = 'UTF-8';
			nationalUser.LastName = 'Test';
			nationalUser.LanguageLocaleKey = 'en_US';
			nationalUser.LocaleSidKey = 'en_US';
			nationalUser.TimeZoneSidKey = 'America/Los_Angeles';
			insert nationalUser;
		}

		User volunteerUser = TestDataFactory.createVolunteerUser(1, 'Active Volunteer (Login)', 'Manager').get(0);
		volunteerUser.LastName = 'Doe2';
		volunteerUser.Alias = 'Vol';
		volunteerUser.Email = 'voluser1@testorg.com';
		volunteerUser.Username = 'voluser1@testorg.com';
		volunteerUser.EmailEncodingKey = 'UTF-8';
		volunteerUser.LastName = 'Test';
		volunteerUser.LanguageLocaleKey = 'en_US';
		volunteerUser.LocaleSidKey = 'en_US';
		volunteerUser.TimeZoneSidKey = 'America/Los_Angeles';
		System.runAs(TestDataFactory.adminUser) {
			insert volunteerUser;
		}

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void createBackgroundCheck(){
		User volunteerUser = [
				SELECT Id, ContactId
				FROM User
				WHERE Email = 'voluser1@testorg.com'
				LIMIT 1
		];
		User nationalStaffUser = [
				SELECT Id
				FROM User
				WHERE Email = 'nationaluser1@testorg.com'
				LIMIT 1
		];

		List<Background_check__c> backgroundChecks = TestDataFactory.createBackgroundCheck(1);
		Background_check__c backgroundCheck = backgroundChecks.get(0);
		backgroundCheck.Date__c = Date.today();
		backgroundCheck.Volunteer__c = volunteerUser.ContactId;
		backgroundCheck.Date_Completed__c = System.today().addYears(-3);
		backgroundCheck.Status__c = 'Sent to First Advantage';
		backgroundCheck.OwnerId = nationalStaffUser.Id;
		insert backgroundChecks;
	}

	@IsTest
	public static void updateBackgroundCheck(){
		User volunteerUser = [
				SELECT Id, ContactId
				FROM User
				WHERE Email = 'voluser1@testorg.com'
				LIMIT 1
		];
		User nationalStaffUser = [
				SELECT Id
				FROM User
				WHERE Email = 'nationaluser1@testorg.com'
				LIMIT 1
		];

		List<Background_check__c> backgroundChecks = TestDataFactory.createBackgroundCheck(1);
		Background_check__c backgroundCheck = backgroundChecks.get(0);
		backgroundCheck.Date__c = Date.today().addDays(-1);
		backgroundCheck.Volunteer__c = volunteerUser.ContactId;
		backgroundCheck.Date_Completed__c = System.today().addYears(-3);
		backgroundCheck.Status__c = Constant_AC.BACKGROUND_CHECK_STATUS_FIRST_ADVANTAGE;
		backgroundCheck.OwnerId = nationalStaffUser.Id;
		backgroundCheck.Current__c = false;
		backgroundCheck.HiddenBackgroundExpire__c = false;
		backgroundCheck.Hidden_Background_Rejected__c = false;
		insert backgroundChecks;

		System.assertEquals(false, backgroundCheck.Current__c);

		backgroundCheck.Status__c = Constant_AC.BACKGROUND_CHECK_STATUS_APPROVED_WITH_CONDITIONS;
		backgroundCheck.Date__c = Date.today();
		backgroundCheck.Current__c = true;
		backgroundCheck.HiddenBackgroundExpire__c = true;
		backgroundCheck.Hidden_Background_Rejected__c = true;
		update backgroundCheck;
	}
}