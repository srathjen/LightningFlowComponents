/**
 * @description		Test class for UserTrigger_AT.
 * @author			MST Solutions
 * @createdDate		2016-06-28
 */
@isTest
private class UserTrigger_AT_Test {
	@testSetup
	static void setup() {
		List<Account> accounts = TestDataFactory.createAccount(2);
		accounts[0].Name = Constant_AC.ACCOUNT_NAME_MAW_ALABAMA;
		accounts[0].RecordTypeId = Constant_AC.CHAPTER_RT_ID;
		accounts[0].Volunteer_Manager__c = Utils.currentUser.Id;
		accounts[0].Alert_for_Unassigned_Wishes__c = 1;
		accounts[0].OwnerId = TestDataFactory.adminUser.Id;
		insert accounts;

		List<Contact> contacts = TestDataFactory.createContact(1);
		contacts[0].FirstName = 'Moss';
		contacts[0].LastName = 'Smith';
		contacts[0].RecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
		contacts[0].Email = 'test@maw.org.test';
		contacts[0].AccountId = accounts[0].Id;
		contacts[0].OwnerId = TestDataFactory.adminUser.Id;
		insert contacts;

		List<User> volunteerUsers;
		System.runAs(TestDataFactory.adminUser) {
			volunteerUsers = TestDataFactory.createVolunteerUser(1, 'Active Volunteer (Login)', 'Manager');
			volunteerUsers[0].LastName = 'DynamicVolunteerUser';
			volunteerUsers[0].ProfileId = Label.Prospective_Volunteer_Profile;
			volunteerUsers[0].Migrated_User__c = false;
			volunteerUsers[0].Created_from_Portal__c = true;
			insert volunteerUsers;
		}

		List<npe5__Affiliation__c> affiliations = TestDataFactory.createAffiliation(1);
		affiliations[0].npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_CURRENT;
		affiliations[0].npe5__Contact__c = contacts[0].Id;
		affiliations[0].npe5__Organization__c = accounts[0].Id;
		insert affiliations;
	}

	@isTest
	static void testUpdateEmailStampsContactFields() {
		User volunteerUser = [
			SELECT
				Id, ContactId, Email, FirstName, LastName, Street, City, State, Country,
				PostalCode, MobilePhone, Fax
			FROM User
			WHERE LastName = 'DynamicVolunteerUser'
		];

		volunteerUser.Email = 'changed_email@maw.org.test';
		volunteerUser.FirstName = 'Danielle';
		volunteerUser.LastName = 'NameChanged';
		volunteerUser.Street = '123 Test St.';
		volunteerUser.City = 'Phoenix';
		volunteerUser.State = 'Arizona';
		volunteerUser.MobilePhone = '6041234567';
		volunteerUser.Country = 'United States';
		volunteerUser.PostalCode = '85001';
		volunteerUser.Fax = '6047654321';

		Test.startTest();
		System.runAs(TestDataFactory.adminUser) {
			update volunteerUser;
		}
		Test.stopTest();

		Contact volunteerUserContact = [
			SELECT
				Id, Email, FirstName, LastName, MailingStreet, MailingCity, MailingState,
				MailingCountry, MailingPostalCode, MobilePhone, Fax
			FROM Contact
			WHERE Id = :volunteerUser.ContactId
		];

		System.assertEquals(volunteerUser.Email.toLowerCase(), volunteerUserContact.Email.toLowerCase());
		System.assertEquals(volunteerUser.FirstName, volunteerUserContact.FirstName);
		System.assertEquals(volunteerUser.LastName, volunteerUserContact.LastName);
		System.assertEquals(volunteerUser.Street, volunteerUserContact.MailingStreet);
		System.assertEquals(volunteerUser.City, volunteerUserContact.MailingCity);
		System.assertEquals(volunteerUser.State, volunteerUserContact.MailingState);
		System.assertEquals(volunteerUser.Country, volunteerUserContact.MailingCountry);
		System.assertEquals(volunteerUser.PostalCode, volunteerUserContact.MailingPostalCode);
		System.assertEquals(volunteerUser.MobilePhone, volunteerUserContact.MobilePhone);
		System.assertEquals(volunteerUser.Fax, volunteerUserContact.Fax);
	}

	@isTest
	static void testDeactivateAndReactivate() {
		User volunteerUser = [SELECT Id, Inactive_Date__c FROM User WHERE LastName = 'DynamicVolunteerUser'];

		System.runAs(TestDataFactory.adminUser) {
			volunteerUser.IsActive = false;
			update volunteerUser;
			volunteerUser.IsActive = true;
			update volunteerUser;
		}
	}

	@isTest
	static void testAddInternalUserToChatterGroup() {
		System.runAs(TestDataFactory.adminUser) {
			List<CollaborationGroup> collaborationGroups = TestDataFactory.createCollaborationGroup(1);
			collaborationGroups[0].Name = 'America';
			collaborationGroups[0].CollaborationType = 'Public';
			insert collaborationGroups;
		}

		List<UserRole> userRoles = TestDataFactory.createUserRole(1);
		userRoles[0].Name = 'America - Chapter';
		insert userRoles;

		List<User> users = TestDataFactory.createUser(1);
		users[0].Username += 'UNIQUE';
		users[0].ProfileId = TestDataFactory.adminUser.ProfileId;
		users[0].UserRoleId = userRoles[0].Id;

		Test.startTest();
		System.runAs(TestDataFactory.adminUser) {
			insert users;
		}
		Test.stopTest();

		List<CollaborationGroupMember> chatterGroupMembersList = [SELECT Id FROM CollaborationGroupMember];
		System.assert(!chatterGroupMembersList.isEmpty());
	}

	@isTest
	static void testRemoveInternalUserFromChatterGroup() {
		List<UserRole> userRoles = TestDataFactory.createUserRole(2);
		userRoles[0].Name = 'Alabama - Chapter';
		userRoles[1].Name = 'Arizona - Chapter';
		insert userRoles;

		List<User> users = TestDataFactory.createUser(1);
		users[0].Username += 'UNIQUE';
		users[0].ProfileId = TestDataFactory.adminUser.ProfileId;
		users[0].UserRoleId = userRoles[0].Id;
		insert users;

		users[0].UserRoleId = userRoles[1].Id;

		Test.startTest();
		System.runAs(TestDataFactory.adminUser) {
			update users;
		}
		Test.stopTest();

		List<CollaborationGroupMember> chatterGroupMembersList = [SELECT Id FROM CollaborationGroupMember];
		System.assert(chatterGroupMembersList.isEmpty());
	}

	@isTest
	static void testUserServiceFindByContactId() {
		Set<Id> contactIds = new Set<Id>();
		List<Contact> contacts = [SELECT Id FROM Contact];

		for (Contact contact : contacts) {
			contactIds.add(contact.Id);
		}

		Map<Id,Id> contactIdByUserIdMap;

		Test.startTest();
		contactIdByUserIdMap = UserService.findByContactId(contactIds);
		Test.stopTest();

		System.assert(!contactIdByUserIdMap.isEmpty());
	}
}