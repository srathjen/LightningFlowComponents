/**
 * @description Test
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 3/18/2020
 */
@IsTest
public class ConflictOfInterestServiceTest {

	private final static Id VOLUNTEER_RECORD_TYPE_ID = Constant_AC.VOLUNTEER_RT_ID;

	@TestSetup
	public static void setUp() {
		trac_TriggerHandlerBase.blockTrigger = true;
		List<Account> accounts = TestDataFactory.createAccount(2);
		Account arizonaChapter = accounts.get(0);
		arizonaChapter.Name = 'Make-A-Wish Arizona';
		arizonaChapter.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
		arizonaChapter.Phone = '555555555';
		arizonaChapter.Email__c = 'maw@email.com';
		insert accounts;

		List<Contact> contacts = TestDataFactory.createContact(1);
		Contact volunteerArizona = contacts.get(0);
		volunteerArizona.RecordTypeId = VOLUNTEER_RECORD_TYPE_ID;
		volunteerArizona.AccountId = arizonaChapter.Id;
		volunteerArizona.FirstName = 'Mark';
		volunteerArizona.LastName = 'Smith';
		volunteerArizona.Birthdate = Date.today().addYears(-10);
		volunteerArizona.MailingPostalCode = '12345-9876';
		volunteerArizona.MailingStreet = 'Mark Street';
		volunteerArizona.MailingCountry = 'United States';
		volunteerArizona.MailingState = 'Arizona';
		volunteerArizona.MailingCity = 'Phoenix';
		volunteerArizona.Email = 'ms@email.com';
		insert contacts;

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
			nationalStaff = new User(FirstName = 'Mark', LastName = 'Smith', Email = 'jonemail@gma111il.com', Username = 'ms@email.test.com',
					EmailEncodingKey = 'ISO-8859-1', Alias = 'ms', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
					LanguageLocaleKey = 'en_US', UserRoleId = roleId, ProfileId = volunteerSystemAdministrator.Id, IsActive = true, StateCode = 'AZ');
			insert nationalStaff;
		}

		Chapter_Vs_Role__c createRec = new Chapter_Vs_Role__c();
		createRec.Chapter_Name__c = 'Make-A-Wish Arizona';
		createRec.Role_Name__c = 'Arizona - Chapter';
		createRec.Name = 'Make-A-Wish Arizona';
		insert createRec;

		List<Conflict_Of_Interest__c> conflictOfInterests = TestDataFactory.createConflictOfInterest(2);
		Conflict_Of_Interest__c newCoi = conflictOfInterests.get(0);
		newCoi.Volunteer_Contact__c = volunteerArizona.Id;
		newCoi.OwnerId = nationalStaff.Id;
		newCoi.Account_Name__c = arizonaChapter.Name;
		Conflict_Of_Interest__c oldCoi = conflictOfInterests.get(1);
		oldCoi.Current__c = true;
		oldCoi.Volunteer_Contact__c = volunteerArizona.Id;
		oldCoi.Signed_Date__c = Date.today().addMonths(-1);
		insert conflictOfInterests;

		List<Role__c> rolesDataFactory = TestDataFactory.createRole(2, true);
		List<Role__c> roles = new List<Role__c>();
		Role__c wishGranterRole = rolesDataFactory.get(0);
		wishGranterRole.Name = 'Wish Granter';
		roles.add(wishGranterRole);
		Role__c wishGranterMentorRole = rolesDataFactory.get(1);
		wishGranterMentorRole.Name = 'Wish Granter Mentor';
		roles.add(wishGranterMentorRole);
		insert roles;

		List<Chapter_Role__c> chapterRoles = TestDataFactory.createChapterRole(1);
		Chapter_Role__c wishGranterArizonaRole = chapterRoles.get(0);
		wishGranterArizonaRole.Chapter_Name__c = arizonaChapter.Id;
		wishGranterArizonaRole.Role_Name__c = wishGranterRole.Id;
		wishGranterArizonaRole.Background_Check_Required__c = false;
		wishGranterArizonaRole.COI_Required__c = true;
		insert chapterRoles;

		List<Volunteer_Roles__c> volunteerRoles = TestDataFactory.createVolunteerRole(1);
		Volunteer_Roles__c volunteerRoleArizonaPending = volunteerRoles.get(0);
		volunteerRoleArizonaPending.Chapter_Role__c = wishGranterArizonaRole.Id;
		volunteerRoleArizonaPending.Volunteer_Name__c = volunteerArizona.Id;
		volunteerRoleArizonaPending.Status__c = Constant_AC.VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE;
		insert volunteerRoles;

		List<Background_check__c> backgroundCheckDataFactory = TestDataFactory.createBackgroundCheck(1);
		List<Background_check__c> backgroundChecks = new List<Background_check__c>();
		Background_check__c backgroundCheck = backgroundCheckDataFactory.get(0);
		backgroundCheck.Current__c = true;
		backgroundCheck.Volunteer__c = volunteerArizona.Id;
		backgroundCheck.Status__c = 'Sent to First Advantage';
		backgroundCheck.Date__c = Date.today().addMonths(-1);
		backgroundChecks.add(backgroundCheck);
		insert backgroundChecks;
		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void shouldSetAccountDetails() {
		Account account = [
				SELECT Id, Phone
				FROM Account
				WHERE Name IN ('Make-A-Wish Arizona')
		];
		Contact volunteer = [
				SELECT Id
				FROM Contact
				WHERE Name = 'Mark Smith'
		];
		List<Conflict_Of_Interest__c> coi = [
				SELECT Id, Account_Name__c, Account_Phone__c, Hidden_Volunteer_Contact_Email__c, Volunteer_Contact__c,
						Current__c, Signed_Date__c, Expiration_Date__c
				FROM Conflict_Of_Interest__c
				WHERE Volunteer_Contact__c = :volunteer.Id
				AND Current__c = NULL
		];
		coi[0].Signed_Date__c = Date.today();

		List<Conflict_Of_Interest__c> results = ConflictOfInterestService.setAccount(
				new List<Conflict_Of_Interest__c>{
						coi[0]
				},
				new Map<Id, Conflict_Of_Interest__c>());

//		System.assertEquals(account.Phone, results[0].Account_Phone__c);
	}

	@IsTest
	public static void shouldUpdateNonCurrentConflictOfInterest() {
		Contact volunteer = [
				SELECT Id
				FROM Contact
				WHERE Name = 'Mark Smith'
		];
		List<Conflict_Of_Interest__c> newCOI = [
				SELECT Id, Account_Name__c, Account_Phone__c, Hidden_Volunteer_Contact_Email__c, Volunteer_Contact__c,
						Current__c, Signed_Date__c, Expiration_Date__c
				FROM Conflict_Of_Interest__c
				WHERE Volunteer_Contact__c = :volunteer.Id
				AND Current__c = NULL
		];

		List<Conflict_Of_Interest__c> results = ConflictOfInterestService.updateNonCurrentConflictOfInterest(
				new Map<Id, Conflict_Of_Interest__c>{
						volunteer.Id => newCOI[0]
				});

		System.assertNotEquals(newCOI[0].Id, results[0].Id);
		System.assertEquals(false, results[0].Current__c);
	}

	@IsTest
	public static void shouldCreateRecordSharing() {
		Contact volunteer = [
				SELECT Id
				FROM Contact
				WHERE Name = 'Mark Smith'
		];
		List<Conflict_Of_Interest__c> newCOI = [
				SELECT Id, Account_Name__c, OwnerId
				FROM Conflict_Of_Interest__c
				WHERE Volunteer_Contact__c = :volunteer.Id
				AND Current__c = NULL
		];

		List<Conflict_Of_Interest__Share> results = ConflictOfInterestService.createRecordSharing(
				new Map<Id, Conflict_Of_Interest__c>{
						newCOI[0].OwnerId => newCOI[0]
				});

		//System.assertEquals(newCOI[0].Id, results[0].ParentId);
	}
}