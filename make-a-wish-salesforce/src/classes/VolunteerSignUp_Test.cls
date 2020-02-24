/**
 * Class VolunteerSignUp_Test
 *
 * @author Chris Shinnimin, Traction on Demand
 * @date 2019-09-05
 */
@isTest
private class VolunteerSignUp_Test {

	private static final String userEmail = 'sysadmin@foo.com';

	// Use populateControllerDefaultCase to specify values for the Visualforce controller for
	// which successful user creation is expected:
	static void populateControllerDefaultCase(VolunteerSignUp_AC controller) {
		controller.firstName = 'Jane';
		controller.lastName = 'Doe';
		controller.phone = '6022222222';
		controller.preferredPhoneType = 'Mobile';
		controller.email = 'jane@doe.com';
		controller.street = '123 Somewhere St.';
		controller.city = 'Phoenix';
		controller.state = 'Arizona';
		controller.county = 'Maricopa';
		controller.zipCode = '85001';
		controller.birthMonth = 'July';
		controller.birthDay = '4';
		controller.onLinkedIn = 'Yes';
		controller.howHearAboutMAW = new List<String>{
				'Family'
		};
		controller.emergencyName = 'Janet Doe';
		controller.emergencyRelationship = 'Parent';
		controller.emergencyPhone = '6022222221';
		controller.language = new List<String>{
				'English'
		};
		controller.languagesRead = new List<String>{
				'English'
		};
		controller.languagesWritten = new List<String>{
				'English'
		};
		controller.languagesSpoken = new List<String>{
				'English'
		};
		controller.languagesUnderstood = new List<String>{
				'English'
		};
		controller.username = 'jane@doe.com';
		controller.password = 'a12345678';
		controller.confirmPassword = 'a12345678';
		controller.over18 = true;
	}

	@testSetup
	static void setup() {
		trac_TriggerHandlerBase.blockTrigger = true;
		User thisUser = [
				SELECT Id
				FROM User
				WHERE Id = :UserInfo.getUserId()
		];
		System.runAs(thisUser) {
			UserRole role = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
			insert role;

			User user = new User(
					ProfileId = [
							SELECT Id
							FROM Profile
							WHERE Name = 'System Administrator'
							LIMIT 1
					].Id,
					LastName = 'Some LastName',
					Email = userEmail,
					Username = userEmail,
					CompanyName = 'Make-a-Wish Arizona',
					Title = 'Some Title',
					Alias = 'alias',
					TimeZoneSidKey = 'America/Los_Angeles',
					EmailEncodingKey = 'UTF-8',
					LanguageLocaleKey = 'en_US',
					LocaleSidKey = 'en_US',
					UserRoleId = role.Id
			);
			insert user;

			Account account = new Account();
			account.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
			account.Name = 'Make-a-Wish Arizona';
			account.AccountNumber = 'abc12345678';
			account.OwnerId = user.Id;
			insert account;
		}

		Account account = [
				SELECT Id
				FROM Account
				LIMIT 1
		];
		Office__c office = new Office__c(
				Chapter__c = account.Id,
				Zip_Code__c = '85001',
				External_Id__c = 'cba12345678'
		);
		insert office;

		Zip_Code__c zipCode = new Zip_Code__c(
				Name = '85001',
				Office__c = office.Id,
				External_Id__c = 'abc85001'
		);
		insert zipCode;
		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@isTest
	static void testValidFormInputCreatesUserAndContact() {
		VolunteerSignUp_AC controller = new VolunteerSignUp_AC();
		populateControllerDefaultCase(controller);

		Test.startTest();
		controller.registerUser();
		Test.stopTest();

		List<User> users = [
				SELECT Id, username
				FROM User
				WHERE Email = 'jane@doe.com'
		];
		System.assertEquals('jane@doe.com', users[0].username, 'Failed to create user when expected with valid inputs.');
	}

	@isTest
	static void testOver18FalseFails() {
		VolunteerSignUp_AC controller = new VolunteerSignUp_AC();
		populateControllerDefaultCase(controller);
		controller.over18 = false;

		Test.startTest();
		controller.registerUser();
		Test.stopTest();

		System.assert(controller.showErrorMsg, 'Setting the over18 flag to false should result in error.');
	}

	@isTest
	static void testInvalidUsernameFormatFails() {
		VolunteerSignUp_AC controller = new VolunteerSignUp_AC();
		populateControllerDefaultCase(controller);
		controller.username = 'notemailformat';

		Test.startTest();
		controller.registerUser();
		Test.stopTest();

		System.assert(controller.showErrorMsg, 'Invalid username should result in error.');
	}

	@isTest
	static void testInvalidEmailFormatFails() {
		VolunteerSignUp_AC controller = new VolunteerSignUp_AC();
		populateControllerDefaultCase(controller);
		controller.email = 'notemailformat';

		Test.startTest();
		controller.registerUser();
		Test.stopTest();

		System.assert(controller.showErrorMsg, 'Invalid email should result in error.');
	}

	@isTest
	static void testZipcodeNot5CharactersFails() {
		VolunteerSignUp_AC controller = new VolunteerSignUp_AC();
		populateControllerDefaultCase(controller);
		controller.zipCode = '1234';

		Test.startTest();
		controller.registerUser();
		Test.stopTest();

		System.assert(controller.showErrorMsg, 'Zipcode of not 5 characters should result in error.');
	}

	@isTest
	static void testPasswordsDoNotMatchFails() {
		VolunteerSignUp_AC controller = new VolunteerSignUp_AC();
		populateControllerDefaultCase(controller);
		controller.password = 'a12345678';
		controller.confirmPassword = 'b12345678';

		Test.startTest();
		controller.registerUser();
		Test.stopTest();

		System.assert(controller.showErrorMsg, 'Non matching passwords should result in error.');
	}

	@isTest
	static void testMissingInformationFails() {
		VolunteerSignUp_AC controller = new VolunteerSignUp_AC();
		populateControllerDefaultCase(controller);
		controller.firstName = null;
		controller.lastName = null;

		Test.startTest();
		controller.registerUser();
		Test.stopTest();

		System.assert(controller.showErrorMsg, 'Missing information should result in error.');
	}

	@isTest
	static void testUsernameAlreadyExistsFails() {
		VolunteerSignUp_AC controller = new VolunteerSignUp_AC();
		populateControllerDefaultCase(controller);
		controller.username = userEmail;

		Test.startTest();
		controller.registerUser();
		Test.stopTest();

		System.assert(controller.showErrorMsg, 'Username already exists should result in error.');
	}

	@isTest
	static void testMatchedContactSucceedsAndAssociatesContact() {
		Test.startTest();
		Contact c;
		System.runAs([
				SELECT Id, UserRoleId
				FROM User
				WHERE Email = :userEmail
        ][0]) {
			c = new Contact(
					RecordTypeId = Constant_AC.WISH_FAMILY_RT_ID,
					FirstName = 'Contact',
					LastName = 'ToMatch',
					Email = 'contact@tomatch.com'
			);
			insert c;

			VolunteerSignUp_AC controller = new VolunteerSignUp_AC();
			populateControllerDefaultCase(controller);
			controller.email = 'contact@tomatch.com';
			controller.confirmedContactId = c.Id;
			controller.registerUser();
		}
		Test.stopTest();

		User u = [
				SELECT ContactId
				FROM User
				WHERE Email = 'contact@tomatch.com'
				LIMIT 1
		];
		System.assertEquals(c.Id, u.ContactId, 'Specifying confirmedContactId should result in new User associated to old Contact.');
	}

	@isTest
	static void testMatchedContactDoesNotAssociateContact() {
		Contact c = new Contact(
				RecordTypeId = Constant_AC.WISH_FAMILY_RT_ID,
				FirstName = 'Contact',
				LastName = 'ToMatch',
				Email = 'contact@tomatch.com'
		);
		insert c;

		VolunteerSignUp_AC controller = new VolunteerSignUp_AC();
		populateControllerDefaultCase(controller);
		controller.email = 'contact@tomatch.com';

		Test.startTest();
		controller.registerUser();
		Test.stopTest();

		User u = [
				SELECT ContactId
				FROM User
				WHERE Email = 'contact@tomatch.com'
				LIMIT 1
		];
		System.assertNotEquals(c.Id, u.ContactId, 'Not specifying confirmedContactId should result in newly created Contact.');
	}

	@isTest
	static void testCreatesUserWithoutPreExistingAccount() {
		Account a = [
				SELECT Id
				FROM Account
				WHERE AccountNumber = 'abc12345678'
				LIMIT 1
		];
		delete a;

		VolunteerSignUp_AC controller = new VolunteerSignUp_AC();
		populateControllerDefaultCase(controller);

		Test.startTest();
		System.runAs([
				SELECT Id
				FROM User
				WHERE Email = :userEmail
		][0]) {
			controller.registerUser();
		}
		Test.stopTest();

		List<User> users = [
				SELECT Id, username
				FROM User
				WHERE Email = 'jane@doe.com'
		];
		System.assertEquals('jane@doe.com', users[0].username, 'Failed to create user when expected with valid inputs.');
	}

	@isTest
	static void testCreatesUserWithoutPreExistingOffice() {
		Office__c o = [
				SELECT Id
				FROM Office__c
				WHERE External_Id__c = 'cba12345678'
				LIMIT 1
		];
		delete o;

		VolunteerSignUp_AC controller = new VolunteerSignUp_AC();
		populateControllerDefaultCase(controller);

		Test.startTest();
		System.runAs([
				SELECT Id
				FROM User
				WHERE Email = :userEmail
		][0]) {
			controller.registerUser();
		}
		Test.stopTest();

		List<User> users = [
				SELECT Id, username
				FROM User
				WHERE Email = 'jane@doe.com'
		];
		System.assertEquals('jane@doe.com', users[0].username, 'Failed to create user when expected with valid inputs.');
	}

	@isTest
	static void testCreatesUserWithoutPreExistingZipCode() {
		Zip_Code__c z = [
				SELECT Id
				FROM Zip_Code__c
				WHERE External_Id__c = 'abc85001'
				LIMIT 1
		];
		delete z;

		VolunteerSignUp_AC controller = new VolunteerSignUp_AC();
		populateControllerDefaultCase(controller);

		Test.startTest();
		System.runAs([
				SELECT Id
				FROM User
				WHERE Email = :userEmail
		][0]) {
			controller.registerUser();
		}
		Test.stopTest();

		List<User> users = [
				SELECT Id, username
				FROM User
				WHERE Email = 'jane@doe.com'
		];
		System.assertEquals('jane@doe.com', users[0].username, 'Failed to create user when expected with valid inputs.');
	}

	@isTest
	static void testGetMethods() {
		List<SelectOption> states;
		List<SelectOption> titles;
		List<SelectOption> preferredPhoneTypes;
		List<SelectOption> onLinkedInOptions;
		List<SelectOption> hearAboutMAWOptions;
		List<SelectOption> contactAtWorkOptions;
		List<SelectOption> employerSharePowerOptions;
		List<SelectOption> languages;
		List<SelectOption> professionalSkills;
		List<SelectOption> emergencyRelationships;
		List<SelectOption> birthMonths;
		List<SelectOption> birthDays;

		VolunteerSignUp_AC controller = new VolunteerSignUp_AC();

		Test.startTest();
		states = controller.getStates();
		titles = controller.getTitles();
		preferredPhoneTypes = controller.getPreferredPhoneTypes();
		onLinkedInOptions = controller.getOnLinkedInOptions();
		hearAboutMAWOptions = controller.getHearAboutMAWOptions();
		contactAtWorkOptions = controller.getContactAtWorkOptions();
		employerSharePowerOptions = controller.getEmployerSharePowerOptions();
		languages = controller.getLanguages();
		professionalSkills = controller.getProfessionalSkills();
		emergencyRelationships = controller.getEmergencyRelationships();
		birthMonths = controller.getBirthMonths();
		birthDays = controller.getBirthDays();
		Test.stopTest();

		System.assert(states.size() > 0, 'getStates returns nothing.');
		System.assert(titles.size() > 0, 'getTitles returns nothing.');
		System.assert(preferredPhoneTypes.size() > 0, 'getPreferredPhoneTypes returns nothing.');
		System.assert(onLinkedInOptions.size() > 0, 'getOnLinkedInOptions returns nothing.');
		System.assert(hearAboutMAWOptions.size() > 0, 'getHearAboutMAWOptions returns nothing.');
		System.assert(contactAtWorkOptions.size() > 0, 'getContactAtWorkOptions returns nothing.');
		System.assert(employerSharePowerOptions.size() > 0, 'getEmployerSharePowerOptions returns nothing.');
		System.assert(languages.size() > 0, 'getLanguages returns nothing.');
		System.assert(professionalSkills.size() > 0, 'getProfessionalSkills returns nothing.');
		System.assert(emergencyRelationships.size() > 0, 'getEmergencyRelationships returns nothing.');
		System.assert(birthMonths.size() > 0, 'getBirthMonths returns nothing.');
		System.assert(birthDays.size() > 0, 'getBirthDays returns nothing.');
	}
}