/**
 * @description Contact Service Test
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 2/27/2020
 */
@IsTest
public class ContactServiceTest {

	private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;
	private final static Id VOLUNTEER_RECORD_TYPE_ID = Constant_AC.VOLUNTEER_RT_ID;
	private final static Id VOLUNTEER_ORIENTATION_RECORD_TYPE_ID = Constant_AC.ORIENTATION_RT_ID;
	private final static Id VOLUNTEER_TRAINING_RECORD_TYPE_ID = Constant_AC.TRAINING_RT_ID;
	private final static String BACKGROUND_CHECK_STATUS_APPROVED = 'Approved';
	private static final String VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED = 'Completed';
	private final static Id CLASS_OFFERING_RECORD_TYPE_ID = Constant_AC.CLASS_OFFERING_RECORD_TYPE_ID;

	@TestSetup
	public static void setup() {
		trac_TriggerHandlerBase.blockTrigger = true;
		List<Account> accounts = TestDataFactory.createAccount(1);
		Account arizonaChapter = accounts.get(0);
		arizonaChapter.Name = 'Make-A-Wish Arizona';
		arizonaChapter.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
		insert accounts;

		List<Contact> contacts = TestDataFactory.createContact(2);
		Contact volunteerArizona = contacts.get(0);
		volunteerArizona.RecordTypeId = VOLUNTEER_RECORD_TYPE_ID;
		volunteerArizona.AccountId = arizonaChapter.Id;
		volunteerArizona.FirstName = 'Mark';
		volunteerArizona.LastName = 'Smith';
		volunteerArizona.Email = 'ms@email.com';
		volunteerArizona.Phone = '12345678';
		volunteerArizona.Birthdate = Date.today().addYears(-10);
		volunteerArizona.MailingPostalCode = '12345-9876';
		volunteerArizona.MailingStreet = 'Mark Street';
		volunteerArizona.MailingCountry = 'United States';
		volunteerArizona.MailingState = 'Arizona';
		volunteerArizona.MailingCity = 'Phoenix';
		Contact volunteerNewYork = contacts.get(1);
		volunteerNewYork.RecordTypeId = VOLUNTEER_RECORD_TYPE_ID;
		volunteerNewYork.AccountId = arizonaChapter.Id;
		volunteerNewYork.FirstName = 'Mark';
		volunteerNewYork.LastName = 'Smith';
		volunteerNewYork.Email = 'ms@email.com';
		volunteerNewYork.Phone = '12345678';
		volunteerNewYork.Birthdate = Date.today().addYears(-10);
		volunteerNewYork.MailingPostalCode = '12345-9876';
		volunteerNewYork.MailingStreet = 'Mark Street';
		volunteerNewYork.MailingCountry = 'United States';
		volunteerNewYork.MailingState = 'New York';
		volunteerNewYork.MailingCity = 'New York';
		insert contacts;

		List<Role__c> roles = TestDataFactory.createRole(2, true);
		Role__c wishGranterRole = roles.get(0);
		wishGranterRole.Name = 'Wish Granter';
		Role__c wishGranterMentorRole = roles.get(1);
		wishGranterMentorRole.Name = 'Wish Granter Mentor';
		insert roles;

		List<Chapter_Role__c> chapterRoles = TestDataFactory.createChapterRole(3);
		Chapter_Role__c wishGranterArizonaRole = chapterRoles.get(0);
		wishGranterArizonaRole.Chapter_Name__c = arizonaChapter.Id;
		wishGranterArizonaRole.Role_Name__c = wishGranterRole.Id;
		wishGranterArizonaRole.Background_Check_Required__c = true;
		wishGranterArizonaRole.COI_Required__c = true;
		Chapter_Role__c wishGranterNewYorkRole = chapterRoles.get(1);
		wishGranterNewYorkRole.Chapter_Name__c = arizonaChapter.Id;
		wishGranterNewYorkRole.Role_Name__c = wishGranterRole.Id;
		wishGranterNewYorkRole.Background_Check_Required__c = true;
		wishGranterNewYorkRole.COI_Required__c = true;
		Chapter_Role__c wishGranterMentorChapterRole = chapterRoles.get(2);
		wishGranterMentorChapterRole.Chapter_Name__c = arizonaChapter.Id;
		wishGranterMentorChapterRole.Role_Name__c = wishGranterRole.Id;
		wishGranterMentorChapterRole.Background_Check_Required__c = false;
		wishGranterMentorChapterRole.COI_Required__c = false;
		insert chapterRoles;

		List<Volunteer_Roles__c> volunteerRoles = TestDataFactory.createVolunteerRole(2);
		Volunteer_Roles__c volunteerRoleArizonaPending = volunteerRoles.get(0);
		volunteerRoleArizonaPending.Chapter_Role__c = wishGranterArizonaRole.Id;
		volunteerRoleArizonaPending.Volunteer_Name__c = volunteerArizona.Id;
		volunteerRoleArizonaPending.Status__c = 'Active';
		Volunteer_Roles__c volunteerRoleActive = volunteerRoles.get(1);
		volunteerRoleActive.Chapter_Role__c = wishGranterMentorChapterRole.Id;
		volunteerRoleActive.Volunteer_Name__c = volunteerArizona.Id;
		volunteerRoleActive.Status__c = 'Active';
		insert volunteerRoles;

		List<Orientation_Training__c> orientationTrainings = TestDataFactory.createOrientationTraining(2);
		Orientation_Training__c orientation = orientationTrainings.get(0);
		orientation.RecordTypeId = VOLUNTEER_ORIENTATION_RECORD_TYPE_ID;
		Orientation_Training__c training = orientationTrainings.get(1);
		training.RecordTypeId = VOLUNTEER_TRAINING_RECORD_TYPE_ID;
		insert orientationTrainings;

		List<Chapter_Role_O_T__c> chapterRoleOTs = TestDataFactory.createChapterRoleOrientationAndTraining(2);
		Chapter_Role_O_T__c chapterRoleOTOrientation = chapterRoleOTs.get(0);
		chapterRoleOTOrientation.Orientation_Training__c = orientation.Id;
		chapterRoleOTOrientation.Chapter_Role__c = wishGranterArizonaRole.Id;
		chapterRoleOTOrientation.Required__c = true;
		Chapter_Role_O_T__c chapterRoleOTTraining = chapterRoleOTs.get(1);
		chapterRoleOTTraining.Orientation_Training__c = training.Id;
		chapterRoleOTTraining.Chapter_Role__c = wishGranterMentorChapterRole.Id;
		chapterRoleOTTraining.Required__c = true;
		insert chapterRoleOTs;

		List<Conflict_Of_Interest__c> conflictOfInterests = TestDataFactory.createConflictOfInterest(1);
		Conflict_Of_Interest__c conflictOfInterest = conflictOfInterests.get(0);
		conflictOfInterest.Current__c = true;
		conflictOfInterest.Account_Name__c = arizonaChapter.Name;
		conflictOfInterest.Volunteer_Contact__c = volunteerArizona.Id;
		insert conflictOfInterests;

		List<Background_check__c> backgroundChecks = TestDataFactory.createBackgroundCheck(1);
		Background_check__c backgroundCheck = backgroundChecks.get(0);
		backgroundCheck.Current__c = true;
		backgroundCheck.Volunteer__c = volunteerArizona.Id;
		backgroundCheck.Status__c = BACKGROUND_CHECK_STATUS_APPROVED;
		backgroundCheck.Date_Completed__c = Date.today();
		insert backgroundChecks;

		List<Class_Offering__c> classOfferings = TestDataFactory.createClassOffering(2);
		Class_Offering__c classOfferingOrientation = classOfferings.get(0);
		classOfferingOrientation.Chapter_Role_O_T__c = chapterRoleOTOrientation.Id;
		classOfferingOrientation.Date__c = System.today() + 10;
		classOfferingOrientation.RecordTypeId = CLASS_OFFERING_RECORD_TYPE_ID;
		Class_Offering__c classOfferingTraining = classOfferings.get(1);
		classOfferingTraining.Chapter_Role_O_T__c = chapterRoleOTTraining.Id;
		classOfferingTraining.Date__c = System.today() + 10;
		classOfferingTraining.RecordTypeId = CLASS_OFFERING_RECORD_TYPE_ID;
		insert classOfferings;

		List<Volunteer_Orientation_Training__c> volunteerOrientationTrainings = TestDataFactory.createVolunteerOrientationAndTraining(2);
		Volunteer_Orientation_Training__c volunteerOrientation = volunteerOrientationTrainings.get(0);
		volunteerOrientation.Volunteer_Attendance__c = VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED;
		volunteerOrientation.Volunteer__c = volunteerArizona.Id;
		volunteerOrientation.Class_Offering__c = classOfferingOrientation.Id;
		Volunteer_Orientation_Training__c volunteerTraining = volunteerOrientationTrainings.get(1);
		volunteerTraining.Volunteer_Attendance__c = VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED;
		volunteerTraining.Volunteer__c = volunteerArizona.Id;
		volunteerTraining.Class_Offering__c = classOfferingTraining.Id;
		insert volunteerOrientationTrainings;

		List<Volunteer_Opportunity__c> volunteerOpportunities = TestDataFactory.createVolunteerOpportunity(1);
		Volunteer_Opportunity__c volunteerOpportunity = volunteerOpportunities.get(0);
		volunteerOpportunity.Volunteer_Name__c = volunteerArizona.Id;
		volunteerOpportunity.RecordTypeId = Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID;
		volunteerOpportunity.Chapter_Role_Opportunity__c = wishGranterArizonaRole.Id;
		volunteerOpportunity.Status__c = 'Approved';
		insert volunteerOpportunities;
		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void shouldChangeVolunteerContactActive() {
		List<Contact> contacts = [
				SELECT Id, B_C_Expiration_Date__c, COI_Expiration_Date__c,
						Active_Board_Member__c, Active_Wish_Granter__c,
						Active_Non_Wish_Granter__c, Active_Single_Day_Event_Volunteer__c
				FROM Contact
				WHERE Name = 'Mark Smith'
		];

		Map<Id, Contact> contactMap = new Map<Id, Contact>(contacts);
		Test.startTest();
		Map<Id, Contact> result = ContactService.setVolunteerContactActive(contactMap);
		Test.stopTest();
		System.assertEquals(1, result.size());
	}

	@IsTest
	public static void shouldFindDuplicatedContacts() {
		String firstName = 'Mark';
		String lastName = 'Smith';
		String email = 'ms@email.com';

		Test.startTest();
		List<Contact> result = ContactService.findDuplicatedContacts(
				firstName, lastName, null, email, new List<Id>{
						VOLUNTEER_RECORD_TYPE_ID
				}
		);
		Test.stopTest();
		System.assertEquals(2, result.size());
	}

	@IsTest
	public static void shouldFindChildDuplicatedContacts() {
		String firstName = 'Mark';
		String lastName = 'Smith';
		String email = 'ms@email.com';
		Date dateOfBirth = Date.today().addYears(-10);
		String street = 'Mark Street';
		String state = 'Arizona';
		String city = 'Phoenix';
		String postalCode = '12345-9876';

		Test.startTest();
		List<Contact> result = ContactService.findChildDuplicatedContacts(
				firstName, lastName, null, email, street,
				city, state, postalCode, dateOfBirth, new List<Id>{
						VOLUNTEER_RECORD_TYPE_ID
				}
		);
		Test.stopTest();
		System.assertEquals(2, result.size());
	}

	@IsTest
	public static void shouldFindFamilyDuplicatedContacts() {
		String firstName = 'Mark';
		String lastName = 'Smith';
		String email = 'ms@email.com';
		String phone = '12345678';
		String street = 'Mark Street';
		String state = 'Arizona';
		String city = 'Phoenix';
		String postalCode = '12345-9876';

		Test.startTest();
		List<Contact> result = ContactService.findFamilyDuplicatedContacts(
				firstName, lastName, phone, email, street,
				city, state, postalCode, new List<Id>{
						VOLUNTEER_RECORD_TYPE_ID
				}
		);
		Test.stopTest();
		System.assertEquals(2, result.size());
	}
}