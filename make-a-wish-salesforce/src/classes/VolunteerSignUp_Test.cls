/**
 * @description Class VolunteerSignUp_Test
 *
 * @author Chris Shinnimin, Traction on Demand
 *
 * @date 2019-09-05
 */
@IsTest
private class VolunteerSignUp_Test {

    private static final String userEmail = 'sysadmin@foo.com';

    @TestSetup
    static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;

        User thisUser = Utils.currentUser;
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

        Dynamic_Content__c dynamicContent = TestDataFactory.createDynamicContent(1)[0];
        dynamicContent.Active__c = true;
        dynamicContent.RecordTypeId = Constant_AC.NATIONAL_RT_ID;
        insert dynamicContent;

        trac_TriggerHandlerBase.blockTrigger = false;
    }

    @IsTest
    static void testValidFormInputCreatesUserAndContact() {
        VolunteerSignUp_AC controller = new VolunteerSignUp_AC();
        populateControllerDefaultCase(controller);

        Test.startTest();
        controller.registerUser();
        Test.stopTest();

        List<User> users = [
                SELECT Id, Username
                FROM User
                WHERE Email = 'jane@doe.com'
        ];
        System.assertEquals('jane@doe.com', users[0].Username, 'Failed to create user when expected with valid inputs.');
    }

    @IsTest
    static void testOver18FalseFails() {
        VolunteerSignUp_AC controller = new VolunteerSignUp_AC();
        populateControllerDefaultCase(controller);
        controller.over18 = false;

        Test.startTest();
        controller.registerUser();
        Test.stopTest();

        System.assert(controller.showErrorMsg, 'Setting the over18 flag to false should result in error.');
    }

    @IsTest
    static void testInvalidUsernameFormatFails() {
        VolunteerSignUp_AC controller = new VolunteerSignUp_AC();
        populateControllerDefaultCase(controller);
        controller.username = 'notemailformat';

        Test.startTest();
        controller.registerUser();
        Test.stopTest();

        System.assert(controller.showErrorMsg, 'Invalid Username should result in error.');
    }

    @IsTest
    static void testInvalidEmailFormatFails() {
        VolunteerSignUp_AC controller = new VolunteerSignUp_AC();
        populateControllerDefaultCase(controller);
        controller.email = 'notemailformat';

        Test.startTest();
        controller.registerUser();
        Test.stopTest();

        System.assert(controller.showErrorMsg, 'Invalid email should result in error.');
    }

    @IsTest
    static void testZipcodeNot5CharactersFails() {
        VolunteerSignUp_AC controller = new VolunteerSignUp_AC();
        populateControllerDefaultCase(controller);
        controller.zipCode = '1234';

        Test.startTest();
        controller.registerUser();
        Test.stopTest();

        System.assert(controller.showErrorMsg, 'Zipcode of not 5 characters should result in error.');
    }

    @IsTest
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

    @IsTest
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

    @IsTest
    static void testUsernameAlreadyExistsFails() {
        VolunteerSignUp_AC controller = new VolunteerSignUp_AC();
        populateControllerDefaultCase(controller);
        controller.username = userEmail;

        Test.startTest();
        controller.registerUser();
        Test.stopTest();

        System.assert(controller.showErrorMsg, 'Username already exists should result in error.');
    }

    @IsTest
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

    @IsTest
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

    @IsTest
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
                SELECT Id, Username
                FROM User
                WHERE Email = 'jane@doe.com'
        ];
        System.assertEquals('jane@doe.com', users[0].Username, 'Failed to create user when expected with valid inputs.');
    }

    @IsTest
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
                SELECT Id, Username
                FROM User
                WHERE Email = 'jane@doe.com'
        ];
        System.assertEquals('jane@doe.com', users[0].Username, 'Failed to create user when expected with valid inputs.');
    }

    @IsTest
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
        List<Contact> matchedContacts = controller.matchedContacts;
        List<SelectOption> matchedContactOptions = controller.matchedContactOptions;

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
                SELECT Id, Username
                FROM User
                WHERE Email = 'jane@doe.com'
        ];
        System.assertEquals('jane@doe.com', users[0].Username, 'Failed to create user when expected with valid inputs.');
    }

    @IsTest
    static void testGetMethods() {
        Test.startTest();
        System.assert(!VolunteerSignUp_AC.States.isEmpty(), 'getStates returns nothing.');
        System.assert(!VolunteerSignUp_AC.Titles.isEmpty(), 'getTitles returns nothing.');
        System.assert(!VolunteerSignUp_AC.PreferredPhoneTypes.isEmpty(), 'getPreferredPhoneTypes returns nothing.');
        System.assert(!VolunteerSignUp_AC.OnLinkedInOptions.isEmpty(), 'getOnLinkedInOptions returns nothing.');
        System.assert(!VolunteerSignUp_AC.HearAboutMAWOptions.isEmpty(), 'getHearAboutMAWOptions returns nothing.');
        System.assert(!VolunteerSignUp_AC.ContactAtWorkOptions.isEmpty(), 'getContactAtWorkOptions returns nothing.');
        System.assert(!VolunteerSignUp_AC.EmployerSharePowerOptions.isEmpty(), 'getEmployerSharePowerOptions returns nothing.');
        System.assert(!VolunteerSignUp_AC.Languages.isEmpty(), 'getLanguages returns nothing.');
        System.assert(!VolunteerSignUp_AC.ProfessionalSkills.isEmpty(), 'getProfessionalSkills returns nothing.');
        System.assert(!VolunteerSignUp_AC.EmergencyRelationships.isEmpty(), 'getEmergencyRelationships returns nothing.');
        System.assert(!VolunteerSignUp_AC.BirthMonths.isEmpty(), 'getBirthMonths returns nothing.');
        System.assert(!VolunteerSignUp_AC.BirthDays.isEmpty(), 'getBirthDays returns nothing.');
        Test.stopTest();
    }

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
}