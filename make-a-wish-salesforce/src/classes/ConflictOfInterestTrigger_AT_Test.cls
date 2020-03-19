@IsTest
public class ConflictOfInterestTrigger_AT_Test {

	@TestSetup
	public static void setUp(){
		trac_TriggerHandlerBase.blockTrigger = true;
		List<Account> accounts = TestDataFactory.createAccount(1);
		Account chapterAccount = accounts.get(0);
		chapterAccount.Name = 'Make-A-Wish Arizona';
		chapterAccount.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
		insert accounts;

		List<Contact> contacts = TestDataFactory.createContact(1);
		Contact volunteerArizona = contacts.get(0);
		volunteerArizona.RecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
		volunteerArizona.AccountId = chapterAccount.Id;
		volunteerArizona.FirstName = 'Mark';
		volunteerArizona.LastName = 'Smith';
		volunteerArizona.Birthdate = Date.today().addYears(-10);
		volunteerArizona.MailingPostalCode = '12345-9876';
		volunteerArizona.MailingStreet = 'Mark Street';
		volunteerArizona.MailingCountry = 'United States';
		volunteerArizona.MailingState = 'Arizona';
		volunteerArizona.MailingCity = 'Phoenix';
		volunteerArizona.Region_Chapter__c = chapterAccount.Id;
		insert contacts;
		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void createConflictOfInterest() {
		Contact volunteerContact = [
				SELECT Id
				FROM Contact
				WHERE Name = 'Mark Smith'
				AND MailingState = 'Arizona'
		];

		Conflict_Of_Interest__c coi = new Conflict_Of_Interest__c();
		coi.Volunteer_Contact__c = volunteerContact.Id;
		coi.Expiration_Date__c = Date.today() + 3;
		insert coi;
	}

	@IsTest
	public static void updateConflictOfInterest() {
		Contact volunteerContact = [
				SELECT Id
				FROM Contact
				WHERE Name = 'Mark Smith'
				AND MailingState = 'Arizona'
		];

		Conflict_Of_Interest__c coi = new Conflict_Of_Interest__c();
		coi.Volunteer_Contact__c = volunteerContact.Id;
		coi.Expiration_Date__c = Date.today() + 3;
		insert coi;
		coi.Expiration_Date__c = Date.today().addYears(1);
		update coi;
	}

	@IsTest
	public static void nationalStaffConflictOfInterest() {
		Contact volunteerContact = [
				SELECT Id, Account.Id, Account.Name
				FROM Contact
				WHERE Name = 'Mark Smith'
				AND MailingState = 'Arizona'
		];
		Role__c newR = new Role__c(Name = 'Wish Granter');
		insert newR;

		Chapter_Role__c newCR = new Chapter_Role__c(Role_Name__c = newR.Id,
				Chapter_Name__c = volunteerContact.Account.Id);
		insert newCR;

		Volunteer_Roles__c newVR = new Volunteer_Roles__c(Volunteer_Name__c =
				volunteerContact.Id, Status__c = 'Out of Compliance', Chapter_Role__c = newCR.Id);
		insert newVR;

		Background_check__c newBg = new Background_check__c(Volunteer__c = volunteerContact.Id,
				Current__c = true, Date__c = Date.today().addDays(-10),
				Date_Completed__c = Date.today().addDays(-50), Status__c = 'Completed');
		newBg.Date__c = Date.today().addDays(-11);
		insert newBg;
		User nationalStaff;
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Profile volunteerSystemAdministrator = [
					SELECT Id
					FROM Profile
					WHERE Name = 'System Administrator'
			];
			Id roleId = [
					SELECT Id
					FROM UserRole
					WHERE Name = 'National Staff'
			].Id;
			nationalStaff = new User(firstname = 'JonJesu', lastName = 'EdwardsJo', email = 'jonemail@gma111il.com', Username = 'jonsamp0@gma11il.com',
					EmailEncodingKey = 'ISO-8859-1', Alias = 'jone', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
					LanguageLocaleKey = 'en_US', UserRoleId = roleId, ProfileId = volunteerSystemAdministrator.Id, isActive = true, Statecode = 'AZ');
			insert nationalStaff;
		}
		Test.startTest();
		System.runAs(nationalStaff) {
			Conflict_Of_Interest__c newCOI1 = new Conflict_Of_Interest__c();
			newCOI1.Volunteer_Contact__c = volunteerContact.Id;
			newCOI1.Expiration_Date__c = System.today() + 3;
			newCOI1.Current__c = true;
			newCOI1.Account_Name__c = volunteerContact.Account.Name;
			newCOI1.OwnerId = nationalStaff.Id;
			insert newCOI1;
		}
		Test.stopTest();
	}

	@IsTest
	public static void UpdateOwnerConflictOfInterest() {
		Contact volunteerContact = [
				SELECT Id
				FROM Contact
				WHERE Name = 'Mark Smith'
				AND MailingState = 'Arizona'
		];

		Conflict_Of_Interest__c newCOI = new Conflict_Of_Interest__c();
		newCOI.Volunteer_Contact__c = volunteerContact.Id;
		newCOI.Expiration_Date__c = System.today() + 3;
		newCOI.Signed_Date__c = System.today() - 2;
		newCOI.Current__c = false;
		insert newCOI;

		User nationalStaff;
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Profile volunteerSystemAdministrator = [
					SELECT Id
					FROM Profile
					WHERE Name = 'System Administrator'
			];
			Id roleId = [
					SELECT Id
					FROM UserRole
					WHERE Name = 'National Staff'
			].Id;
			nationalStaff = new User(Firstname = 'JonJesu', LastName = 'EdwardsJo', Email = 'jonemail@gma111il.com', Username = 'jonsamp0@gma11il.com',
					EmailEncodingKey = 'ISO-8859-1', Alias = 'jone', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
					LanguageLocaleKey = 'en_US', UserRoleId = roleId, ProfileId = volunteerSystemAdministrator.Id, isActive = true, Statecode = 'AZ');
			insert nationalStaff;
		}
		System.runAs(nationalStaff) {
			newCOI.OwnerId = nationalStaff.Id;
			newCOI.Signed_Date__c = System.today();
			newCOI.HiddenConflictExpire__c = true;
			newCOI.Current__c = true;
			update newCOI;
		}
	}
}