/**
 * @description Test
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 3/18/2020
 */
@IsTest
public class VolunteerRoleServiceTest {

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

		Chapter_Vs_Role__c createRec = new Chapter_Vs_Role__c();
		createRec.Chapter_Name__c = 'Make-A-Wish Arizona';
		createRec.Role_Name__c = 'Arizona - Chapter';
		createRec.Name = 'Make-A-Wish Arizona';
		insert createRec;

		List<Conflict_Of_Interest__c> conflictOfInterests = TestDataFactory.createConflictOfInterest(2);
		Conflict_Of_Interest__c newCoi = conflictOfInterests.get(0);
		newCoi.Volunteer_Contact__c = volunteerArizona.Id;
		newCoi.Account_Name__c = arizonaChapter.Name;
		Conflict_Of_Interest__c oldCoi = conflictOfInterests.get(1);
		oldCoi.Current__c = true;
		oldCoi.Volunteer_Contact__c = volunteerArizona.Id;
		oldCoi.Signed_Date__c = Date.today().addMonths(-1);
		insert conflictOfInterests;

		List<Role__c> roles = TestDataFactory.createRole(2, true);
		Role__c wishGranterRole = roles.get(0);
		wishGranterRole.Name = 'Wish Granter';
		Role__c wishGranterMentorRole = roles.get(1);
		wishGranterMentorRole.Name = 'Wish Granter Mentor';
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
		volunteerRoleArizonaPending.Hidden_Previous_Status__c = 'Status';
		volunteerRoleArizonaPending.Hidden_Previous_Sub_Status__c = 'Sub Status';
		insert volunteerRoles;

		List<Background_check__c> backgroundChecks = TestDataFactory.createBackgroundCheck(1);
		Background_check__c backgroundCheck = backgroundChecks.get(0);
		backgroundCheck.Current__c = true;
		backgroundCheck.Volunteer__c = volunteerArizona.Id;
		backgroundCheck.Status__c = 'Sent to First Advantage';
		backgroundCheck.Date__c = Date.today().addMonths(-1);
		insert backgroundChecks;
		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void shouldUpdateNonCompliantByConflictOfInterest() {
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

		List<Volunteer_Roles__c> results = VolunteerRoleService.updateNonCompliantByConflictOfInterest(
				new Map<Id, Conflict_Of_Interest__c>{
						volunteer.Id => newCOI[0]
				});

		System.assertEquals('', results[0].Hidden_Previous_Status__c);
		System.assertEquals('', results[0].Hidden_Previous_Sub_Status__c);
	}
}