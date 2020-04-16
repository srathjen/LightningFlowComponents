/**
 * Class ApplyForRoles_AC_Test
 * Test class for ApplyForRoles_AC Visualforce Controller
 * @author Chris Shinnimin, Traction on Demand
 * @date 2019-09-09
 */
@IsTest
private class ApplyForRoles_AC_Test {

	@TestSetup
	static void setup() {
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
					Email = 'sysadmin@foo.com.test',
					Username = 'sysadmin@foo.com.test',
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

		Contact volContact = new Contact();
		volContact.AccountId = account.Id;
		volContact.RecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
		volContact.Email = 'volunteer@foo.com.test';
		volContact.FirstName = 'Volun';
		volContact.LastName = 'Teer';
		volContact.Street__c = '123 Anywhere St.';
		volContact.Birth_Day__c = '1';
		volContact.Birth_Month__c = 'January';
		volContact.County__c = 'Maricopa';
		volContact.Phone = '2222222222';
		volContact.Emergency_Contact__c = 'Somebody';
		volContact.Emergency_Contact_Relationship__c = 'Family';
		volContact.Emergency_Contact_Phone__c = '2222222222';
		volContact.Language__c = 'English';
		volContact.Read__c = 'English';
		volContact.Write__c = 'English';
		volContact.Speak__c = 'English';
		volContact.Understand__c = 'English';
		insert volContact;

		User volUser = new User();
		volUser.ContactId = volContact.Id;
		volUser.Username = 'volunteer@foo.com.test';
		volUser.Email = 'volunteer@foo.com.test';
		volUser.FirstName = 'Volun';
		volUser.LastName = 'Teer';
		volUser.CommunityNickname = 'volunteer@foo.com.test';
		volUser.Phone = '2222222222';
		volUser.State = 'Arizona';
		volUser.City = 'Phoenix';
		volUser.PostalCode = '85001';
		volUser.ProfileId = Label.Prospective_Volunteer_Profile;
		volUser.I_am_over_18_years_old__c = true;
		volUser.Created_from_Portal__c = true;
		volUser.LocaleSidKey = 'en_US';
		volUser.EmailEncodingKey = 'ISO-8859-1';
		volUser.LanguageLocaleKey = 'en_US';
		volUser.TimeZoneSidKey = 'America/Los_Angeles';
		volUser.Alias = 'vteer';
		insert volUser;

		System.setPassword(volUser.Id, 'a12345678');
	}

	@IsTest
	static void testSaveRoles() {
		User testUser = [
				SELECT Id, ContactId
				FROM User
				WHERE Email = 'volunteer@foo.com.test'
		];
		Contact testContact = [
				SELECT Id, Volunteer_Role__c
				FROM Contact
				WHERE Email = 'volunteer@foo.com.test'
		];

		System.assertEquals(null, testContact.Volunteer_Role__c);

		System.runAs(testUser) {
			ApplyForRoles_AC controller = new ApplyForRoles_AC();
			controller.currentVolunteer = testContact;
			controller.volRoles = new List<String>{
					'Role1', 'Role2'
			};

			Test.startTest();
			controller.saveRec();
			Test.stopTest();
		}

		System.assertEquals('Role1;Role2', testContact.Volunteer_Role__c, 'Roles not successfully saved.');
	}

	@IsTest
	static void testConfirmSign() {
		User testUser = [
				SELECT Id, ContactId
				FROM User
				WHERE Email = 'volunteer@foo.com.test'
		];
		Contact testContact = [
				SELECT Id
				FROM Contact
				WHERE Email = 'volunteer@foo.com.test'
		];

		System.runAs(testUser) {
			ApplyForRoles_AC controller = new ApplyForRoles_AC();
			controller.currentVolunteer = testContact;

			Test.startTest();
			controller.confirmSign();
			Test.stopTest();

			System.assert(controller.displaySignNowPopup, 'confirmSign not successful.');
		}
	}

	@IsTest
	static void testSubmitAndSignNotSuccessful() {
		User testUser = [
				SELECT Id, ContactId
				FROM User
				WHERE Email = 'volunteer@foo.com.test'
		];
		Contact testContact = [
				SELECT Id, Email, FirstName, LastName, isApplication__c, Onboarding_Status__c
				FROM Contact
				WHERE Email = 'volunteer@foo.com.test'
		];

		System.runAs(testUser) {
			ApplyForRoles_AC controller = new ApplyForRoles_AC();
			controller.currentVolunteer = testContact;

			Test.setMock(HttpCalloutMock.class, new DocusignMock(404, '', 0, ''));

			Test.startTest();
			controller.SubmitAndSign();
			Test.stopTest();

			System.assert(!controller.displaySignNowPopup, 'HTTP Status code of 404 should generate failure condition.');
		}
	}

	@IsTest
	static void testSubmitAndSignSuccessful() {
		User testUser = [
				SELECT Id, ContactId
				FROM User
				WHERE Email = 'volunteer@foo.com.test'
		];
		Contact testContact = [
				SELECT Id, Email, FirstName, LastName, isApplication__c, Onboarding_Status__c
				FROM Contact
				WHERE Email = 'volunteer@foo.com.test'
		];
		testContact.Volunteer_Role__c = 'Role1';
		update testContact;

		System.runAs(testUser) {
			ApplyForRoles_AC controller = new ApplyForRoles_AC();
			controller.currentVolunteer = testContact;

			Test.setMock(HttpCalloutMock.class, new DocusignMock(200, '{"envelopeId": "123"}', 200, '{"url": "/Some_URL"}'));

			Test.startTest();
			PageReference redirectPage = controller.SubmitAndSign();
			Test.stopTest();

			System.assertEquals('/Some_URL', redirectPage.getUrl(), 'HTTP Status code of 200 should generate success condition.');
		}
	}

	@IsTest
	static void testSubmitAndSignFirstCalloutSuccessSecondCalloutFail() {
		User testUser = [
				SELECT Id, ContactId
				FROM User
				WHERE Email = 'volunteer@foo.com.test'
		];
		Contact testContact = [
				SELECT Id, Email, FirstName, LastName, isApplication__c, Onboarding_Status__c
				FROM Contact
				WHERE Email = 'volunteer@foo.com.test'
		];
		testContact.Volunteer_Role__c = 'Role1';
		update testContact;

		System.runAs(testUser) {
			ApplyForRoles_AC controller = new ApplyForRoles_AC();
			controller.currentVolunteer = testContact;

			Test.setMock(HttpCalloutMock.class, new DocusignMock(200,
                    '{"envelopeId": "123"}', 404, ''));

			Test.startTest();
			PageReference redirectPage = controller.SubmitAndSign();
			Test.stopTest();

			System.assert(!controller.displaySignNowPopup, 'HTTP Status code of 404 on second callout should generate failure condition.');
		}
	}

	@IsTest
	static void testSubmitAndSignBadJSONCausesException() {
		User testUser = [
				SELECT Id, ContactId
				FROM User
				WHERE Email = 'volunteer@foo.com.test'
		];
		Contact testContact = [
				SELECT Id, Email, FirstName, LastName, isApplication__c, Onboarding_Status__c
				FROM Contact
				WHERE Email = 'volunteer@foo.com.test'
		];
		testContact.Volunteer_Role__c = 'Role1';
		update testContact;

		System.runAs(testUser) {
			ApplyForRoles_AC controller = new ApplyForRoles_AC();
			controller.currentVolunteer = testContact;

			Test.setMock(HttpCalloutMock.class, new DocusignMock(200,
                    'invalid JSON', 0, ''));

			Test.startTest();
			PageReference redirectPage = controller.SubmitAndSign();
			Test.stopTest();

			// nothing to assert
		}
	}

	private class DocusignMock implements HttpCalloutMock {
		public Integer firstResponseCode;
		public String firstResponseBody;
		public Integer secondResponseCode;
		public String secondResponseBody;

        DocusignMock(Integer firstResponseCode, String firstResponseBody, Integer secondResponseCode, String secondResponseBody) {
			this.firstResponseCode = firstResponseCode;
			this.firstResponseBody = firstResponseBody;
			this.secondResponseCode = secondResponseCode;
			this.secondResponseBody = secondResponseBody;
		}

		public HttpResponse respond(HttpRequest req) {
			HttpResponse res = new HttpResponse();
			if (req.getEndpoint().contains('views/recipient')) {
				res.setBody(this.secondResponseBody);
				res.setStatusCode(this.secondResponseCode);
			} else {
				res.setBody(this.firstResponseBody);
				res.setStatusCode(this.firstResponseCode);
			}
			return res;
		}
	}

	@IsTest
	static void testGetMethods() {
		Role__c testRole = new Role__c(
				isWishRole__c = true,
				Name = 'Test Role',
				Description__c = 'Test Role'
		);
		insert testRole;

		Account testAccount = [
				SELECT Id
				FROM Account
				WHERE AccountNumber = 'abc12345678'
		];
		Chapter_Role__c chapterRole = new Chapter_Role__c(
				Chapter_Name__c = testAccount.Id,
				Role_Name__c = testRole.Id
		);
		insert chapterRole;

		User testUser = [
				SELECT Id, ContactId
				FROM User
				WHERE Email = 'volunteer@foo.com.test'
		];
		Contact testContact = [
				SELECT Id, Email, FirstName, LastName, isApplication__c, Onboarding_Status__c
				FROM Contact
				WHERE Email = 'volunteer@foo.com.test'
		];

		System.runAs(testUser) {
			ApplyForRoles_AC controller = new ApplyForRoles_AC();
			controller.currentVolunteer = testContact;

			List<SelectOption> states;
			List<SelectOption> roles;

			Test.startTest();
			states = controller.getStates();
			roles = controller.getRoles();
			Test.stopTest();

			System.assert(states.size() > 0, 'getStates returns nothing.');
			System.assert(roles.size() > 0, 'getRoles returns nothing.');
		}
	}

	@IsTest
	static void testEditRec() {
		User testUser = [
				SELECT Id, ContactId
				FROM User
				WHERE Email = 'volunteer@foo.com.test'
		];
		Contact testContact = [
				SELECT Id, Email, FirstName, LastName, isApplication__c, Onboarding_Status__c
				FROM Contact
				WHERE Email = 'volunteer@foo.com.test'
		];

		System.runAs(testUser) {
			ApplyForRoles_AC controller = new ApplyForRoles_AC();
			controller.currentVolunteer = testContact;

			Test.startTest();
			PageReference redirectPage = controller.EditRec();
			Test.stopTest();

			System.assert(redirectPage.getUrl().contains('showeditMode=True'), 'EditRec() should return a PageReference with showEditMode=true parameter.');
		}
	}

	@IsTest
	static void testDisplayDescription() {
		Role__c testRole = new Role__c(
				isWishRole__c = true,
				Name = 'Test Role',
				Description__c = 'Test Role'
		);
		insert testRole;

		Account testAccount = [
				SELECT Id
				FROM Account
				WHERE AccountNumber = 'abc12345678'
		];
		Chapter_Role__c chapterRole = new Chapter_Role__c(
				Chapter_Name__c = testAccount.Id,
				Role_Name__c = testRole.Id
		);
		insert chapterRole;

		User testUser = [
				SELECT Id, ContactId
				FROM User
				WHERE Email = 'volunteer@foo.com.test'
		];
		Contact testContact = [
				SELECT Id, Email, FirstName, LastName, isApplication__c, Onboarding_Status__c
				FROM Contact
				WHERE Email = 'volunteer@foo.com.test'
		];

		System.runAs(testUser) {
			ApplyForRoles_AC controller = new ApplyForRoles_AC();
			controller.currentVolunteer = testContact;

			Test.startTest();
			controller.DisplayDescription();
			Test.stopTest();

			System.assertEquals('Test Role', controller.roleDescriptionList[0].roleDescription, 'DisplayDescription() does not return RoleWrapper with expected description.');
		}
	}

	@IsTest
	static void testCloseAndHidePopup() {
		User testUser = [
				SELECT Id, ContactId
				FROM User
				WHERE Email = 'volunteer@foo.com.test'
		];
		Contact testContact = [
				SELECT Id, Email, FirstName, LastName, isApplication__c, Onboarding_Status__c
				FROM Contact
				WHERE Email = 'volunteer@foo.com.test'
		];

		System.runAs(testUser) {
			ApplyForRoles_AC controller = new ApplyForRoles_AC();
			controller.currentVolunteer = testContact;

			Test.startTest();
			controller.ClosePopUp();
			controller.hidePopup();
			System.assert(!controller.displayPopup, 'ClosePopup() failed.');
			System.assert(!controller.displaySignNowPopup, 'HidePopup() failed.');
			Test.stopTest();
		}
	}

	@IsTest
	static void testURLParameters() {
		User testUser = [
				SELECT Id, ContactId
				FROM User
				WHERE Email = 'volunteer@foo.com.test'
		];
		Contact testContact = [
				SELECT Id, Email, FirstName, LastName, isApplication__c, Onboarding_Status__c
				FROM Contact
				WHERE Email = 'volunteer@foo.com.test'
		];

		Dynamic_Content__c content = new Dynamic_Content__c(
				RecordTypeId = Constant_AC.NATIONAL_RT_ID
		);
		insert content;

		Test.setCurrentPageReference(new PageReference('Page.ApplyForRoles_AC'));
		System.currentPageReference().getParameters().put('showeditMode', 'true');
		System.currentPageReference().getParameters().put('event', 'true');
		System.currentPageReference().getParameters().put('bgRequired', 'true');
		System.currentPageReference().getParameters().put('trainingRequired', 'true');

		System.runAs(testUser) {
			ApplyForRoles_AC controller = new ApplyForRoles_AC();
			controller.currentVolunteer = testContact;

			Test.startTest();
			controller.saveRec();
			Test.stopTest();

			System.assert(controller.bgTabPermission, 'bgTabPermission not true.');
			System.assert(controller.trainingTabVisible, 'trainingTabVisible not true.');
		}
	}

	@IsTest
	static void testSigningComplete() {
		User testUser = [
				SELECT Id, ContactId
				FROM User
				WHERE Email = 'volunteer@foo.com.test'
		];
		Contact testContact = [
				SELECT Id, Email, FirstName, LastName, isApplication__c, Onboarding_Status__c
				FROM Contact
				WHERE Email = 'volunteer@foo.com.test'
		];
		testContact.is_Application__c = 'Submit';
		update testContact;

		Test.setCurrentPageReference(new PageReference('Page.ApplyForRoles_AC'));
		System.currentPageReference().getParameters().put('event', 'signing_complete');

		System.runAs(testUser) {
			ApplyForRoles_AC controller = new ApplyForRoles_AC();
			controller.currentVolunteer = testContact;

			Test.startTest();
			controller.saveRec();
			Test.stopTest();

			System.assert(controller.isSigned, 'isSigned not true.');
			System.assert(controller.editMode, 'editMode not true.');
			System.assert((controller.saveMode == null), 'saveMode not null.');
		}
	}

	@IsTest
	static void testSubmit() {
		User testUser = [
				SELECT Id, ContactId
				FROM User
				WHERE Email = 'volunteer@foo.com.test'
		];
		Contact testContact = [
				SELECT Id, Email, FirstName, LastName, isApplication__c, Onboarding_Status__c
				FROM Contact
				WHERE Email = 'volunteer@foo.com.test'
		];
		testContact.is_Application__c = 'Submit';
		update testContact;

		System.runAs(testUser) {
			ApplyForRoles_AC controller = new ApplyForRoles_AC();
			controller.currentVolunteer = testContact;

			Test.startTest();
			controller.saveRec();
			Test.stopTest();

			System.assert(!controller.isSigned, 'isSigned not false.');
			System.assert(!controller.editMode, 'editMode not false.');
			System.assert(controller.saveMode, 'saveMode not true.');
		}
	}

	@IsTest
	static void testRedirectToHome() {
		User testUser = [
				SELECT Id, ContactId
				FROM User
				WHERE Email = 'volunteer@foo.com.test'
		];
		Contact testContact = [
				SELECT Id, Email, FirstName, LastName, isApplication__c, Onboarding_Status__c
				FROM Contact
				WHERE Email = 'volunteer@foo.com.test'
		];

		System.runAs(testUser) {
			ApplyForRoles_AC controller = new ApplyForRoles_AC();
			controller.currentVolunteer = testContact;

			Test.startTest();
			PageReference pageRef = controller.redirectToHome();
			Test.stopTest();

			System.assertEquals('/VolunteerWelcomePage_VF', pageRef.getUrl());
		}
	}
}