/**
 * @description Volunteer Journey Test Class
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 10/23/2019
 */
@IsTest
public class VolunteerJourneyServiceTest {

	private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;
	private final static Id VOLUNTEER_RECORD_TYPE_ID = Constant_AC.VOLUNTEER_RT_ID;
	private final static Id VOLUNTEER_ORIENTATION_RECORD_TYPE_ID = Constant_AC.ORIENTATION_RT_ID;
	private final static Id VOLUNTEER_TRAINING_RECORD_TYPE_ID = Constant_AC.TRAINING_RT_ID;
	private final static String BACKGROUND_CHECK_STATUS_APPROVED = 'Approved';
	private static final String VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED = 'Completed';
	private final static Id CLASS_OFFERING_RECORD_TYPE_ID = Constant_AC.CLASS_OFFERING_RECORD_TYPE_ID;

	@TestSetup
	public static void setUp() {
		List<Account> accountsDataFactory = TestDataFactory.createAccount(2);
		List<Account> accounts = new List<Account>();
		Account arizonaChapter = accountsDataFactory.get(0);
		arizonaChapter.Name = 'Make-A-Wish Arizona';
		arizonaChapter.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
		accounts.add(arizonaChapter);
		Account newYorkChapter = accountsDataFactory.get(1);
		newYorkChapter.Name = 'Make-A-Wish Arizona';
		newYorkChapter.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
		accounts.add(newYorkChapter);
		insert accounts;
		List<Contact> contactsDataFactory = TestDataFactory.createContact(2);
		List<Contact> contacts = new List<Contact>();
		Contact volunteerArizona = contactsDataFactory.get(0);
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
		contacts.add(volunteerArizona);
		Contact volunteerNewYork = contactsDataFactory.get(1);
		volunteerNewYork.RecordTypeId = VOLUNTEER_RECORD_TYPE_ID;
		volunteerNewYork.AccountId = newYorkChapter.Id;
		volunteerNewYork.FirstName = 'Mark';
		volunteerNewYork.LastName = 'Smith';
		volunteerNewYork.Birthdate = Date.today().addYears(-10);
		volunteerNewYork.MailingPostalCode = '12345-9876';
		volunteerNewYork.MailingStreet = 'Mark Street';
		volunteerNewYork.MailingCountry = 'United States';
		volunteerNewYork.MailingState = 'New York';
		volunteerNewYork.MailingCity = 'New York';
		contacts.add(volunteerNewYork);
		insert contacts;
		List<Role__c> rolesDataFactory = TestDataFactory.createRole(2, true);
		List<Role__c> roles = new List<Role__c>();
		Role__c wishGranterRole = rolesDataFactory.get(0);
		wishGranterRole.Name = 'Wish Granter';
		roles.add(wishGranterRole);
		Role__c wishGranterMentorRole = rolesDataFactory.get(1);
		wishGranterMentorRole.Name = 'Wish Granter Mentor';
		roles.add(wishGranterMentorRole);
		insert roles;
		List<Chapter_Role__c> chapterRolesDataFactory = TestDataFactory.createChapterRole(3);
		List<Chapter_Role__c> chapterRoles = new List<Chapter_Role__c>();
		Chapter_Role__c wishGranterArizonaRole = chapterRolesDataFactory.get(0);
		wishGranterArizonaRole.Chapter_Name__c = arizonaChapter.Id;
		wishGranterArizonaRole.Role_Name__c = wishGranterRole.Id;
		wishGranterArizonaRole.Background_Check_Required__c = true;
		wishGranterArizonaRole.COI_Required__c = true;
		chapterRoles.add(wishGranterArizonaRole);
		Chapter_Role__c wishGranterNewYorkRole = chapterRolesDataFactory.get(1);
		wishGranterNewYorkRole.Chapter_Name__c = arizonaChapter.Id;
		wishGranterNewYorkRole.Role_Name__c = wishGranterRole.Id;
		wishGranterNewYorkRole.Background_Check_Required__c = true;
		wishGranterNewYorkRole.COI_Required__c = true;
		chapterRoles.add(wishGranterNewYorkRole);
		Chapter_Role__c wishGranterMentorChapterRole = chapterRolesDataFactory.get(2);
		wishGranterMentorChapterRole.Chapter_Name__c = newYorkChapter.Id;
		wishGranterMentorChapterRole.Role_Name__c = wishGranterRole.Id;
		wishGranterMentorChapterRole.Background_Check_Required__c = false;
		wishGranterMentorChapterRole.COI_Required__c = false;
		chapterRoles.add(wishGranterMentorChapterRole);
		insert chapterRoles;
		List<Volunteer_Roles__c> volunteerRolesDataFactory = TestDataFactory.createVolunteerRole(3);
		List<Volunteer_Roles__c> volunteerRoles = new List<Volunteer_Roles__c>();
		Volunteer_Roles__c volunteerRoleArizonaPending = volunteerRolesDataFactory.get(0);
		volunteerRoleArizonaPending.Chapter_Role__c = wishGranterArizonaRole.Id;
		volunteerRoleArizonaPending.Volunteer_Name__c = volunteerArizona.Id;
		volunteerRoleArizonaPending.Status__c = 'Pending';
		volunteerRoles.add(volunteerRoleArizonaPending);
		Volunteer_Roles__c volunteerRoleNewYorkPending = volunteerRolesDataFactory.get(1);
		volunteerRoleNewYorkPending.Chapter_Role__c = wishGranterNewYorkRole.Id;
		volunteerRoleNewYorkPending.Volunteer_Name__c = volunteerNewYork.Id;
		volunteerRoleNewYorkPending.Status__c = 'Pending';
		volunteerRoles.add(volunteerRoleNewYorkPending);
		Volunteer_Roles__c volunteerRoleActive = volunteerRolesDataFactory.get(2);
		volunteerRoleActive.Chapter_Role__c = wishGranterMentorChapterRole.Id;
		volunteerRoleActive.Volunteer_Name__c = volunteerArizona.Id;
		volunteerRoleActive.Status__c = 'Active';
		volunteerRoles.add(volunteerRoleActive);
		insert volunteerRoles;
		List<Orientation_Training__c> orientationTrainingDataFactory = TestDataFactory.createOrientationTraining(2);
		List<Orientation_Training__c> orientationTrainings = new List<Orientation_Training__c>();
		Orientation_Training__c orientation = orientationTrainingDataFactory.get(0);
		orientation.RecordTypeId = VOLUNTEER_ORIENTATION_RECORD_TYPE_ID;
		orientationTrainings.add(orientation);
		Orientation_Training__c training = orientationTrainingDataFactory.get(1);
		training.RecordTypeId = VOLUNTEER_TRAINING_RECORD_TYPE_ID;
		orientationTrainings.add(training);
		insert orientationTrainings;
		List<Chapter_Role_O_T__c> chapterRoleOTDataFactory = TestDataFactory.createChapterRoleOrientationAndTraining(2);
		List<Chapter_Role_O_T__c> chapterRoleOTs = new List<Chapter_Role_O_T__c>();
		Chapter_Role_O_T__c chapterRoleOTOrientation = chapterRoleOTDataFactory.get(0);
		chapterRoleOTOrientation.Orientation_Training__c = orientation.Id;
		chapterRoleOTOrientation.Chapter_Role__c = wishGranterArizonaRole.Id;
		chapterRoleOTOrientation.Required__c = true;
		chapterRoleOTs.add(chapterRoleOTOrientation);
		Chapter_Role_O_T__c chapterRoleOTTraining = chapterRoleOTDataFactory.get(1);
		chapterRoleOTTraining.Orientation_Training__c = training.Id;
		chapterRoleOTTraining.Chapter_Role__c = wishGranterMentorChapterRole.Id;
		chapterRoleOTTraining.Required__c = true;
		chapterRoleOTs.add(chapterRoleOTTraining);
		insert chapterRoleOTs;
		List<Conflict_Of_Interest__c> conflictOfInterestDataFactory = TestDataFactory.createConflictOfInterest(1);
		List<Conflict_Of_Interest__c> conflictOfInterests = new List<Conflict_Of_Interest__c>();
		Conflict_Of_Interest__c conflictOfInterest = conflictOfInterestDataFactory.get(0);
		conflictOfInterest.Current__c = true;
		conflictOfInterest.Account_Name__c = arizonaChapter.Name;
		conflictOfInterest.Volunteer_Contact__c = volunteerArizona.Id;
		conflictOfInterests.add(conflictOfInterest);
		insert conflictOfInterests;
		List<Background_check__c> backgroundCheckDataFactory = TestDataFactory.createBackgroundCheck(1);
		List<Background_check__c> backgroundChecks = new List<Background_check__c>();
		Background_check__c backgroundCheck = backgroundCheckDataFactory.get(0);
		backgroundCheck.Current__c = true;
		backgroundCheck.Volunteer__c = volunteerArizona.Id;
		backgroundCheck.Status__c = BACKGROUND_CHECK_STATUS_APPROVED;
		backgroundCheck.Date_Completed__c = Date.today();
		backgroundChecks.add(backgroundCheck);
		insert backgroundChecks;
		List<Class_Offering__c> classOfferingDataFactory = TestDataFactory.createClassOffering(2);
		List<Class_Offering__c> classOfferings = new List<Class_Offering__c>();
		Class_Offering__c classOfferingOrientation = classOfferingDataFactory.get(0);
		classOfferingOrientation.Chapter_Role_O_T__c = chapterRoleOTOrientation.Id;
		classOfferingOrientation.Date__c = System.today() + 10;
		classOfferingOrientation.Start_Time__c = '10:00 AM';
		classOfferingOrientation.End_Time__c = '1:00 PM';
		classOfferingOrientation.RecordTypeId = CLASS_OFFERING_RECORD_TYPE_ID;
		classOfferings.add(classOfferingOrientation);
		Class_Offering__c classOfferingTraining = classOfferingDataFactory.get(1);
		classOfferingTraining.Chapter_Role_O_T__c = chapterRoleOTTraining.Id;
		classOfferingTraining.Date__c = System.today() + 10;
		classOfferingTraining.Start_Time__c = '10:00 AM';
		classOfferingTraining.End_Time__c = '1:00 PM';
		classOfferingTraining.RecordTypeId = CLASS_OFFERING_RECORD_TYPE_ID;
		classOfferings.add(classOfferingTraining);
		insert classOfferings;
		List<Volunteer_Orientation_Training__c> volunteerOrientationTrainingDataFactory = TestDataFactory.createVolunteerOrientationAndTraining(2);
		List<Volunteer_Orientation_Training__c> volunteerOrientationTrainings = new List<Volunteer_Orientation_Training__c>();
		Volunteer_Orientation_Training__c volunteerOrientation = volunteerOrientationTrainingDataFactory.get(0);
		volunteerOrientation.Volunteer_Attendance__c = VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED;
		volunteerOrientation.Volunteer__c = volunteerArizona.Id;
		volunteerOrientation.Class_Offering__c = classOfferingOrientation.Id;
		volunteerOrientationTrainings.add(volunteerOrientation);
		Volunteer_Orientation_Training__c volunteerTraining = volunteerOrientationTrainingDataFactory.get(1);
		volunteerTraining.Volunteer_Attendance__c = VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED;
		volunteerTraining.Volunteer__c = volunteerArizona.Id;
		volunteerTraining.Class_Offering__c = classOfferingTraining.Id;
		volunteerOrientationTrainings.add(volunteerTraining);
		insert volunteerOrientationTrainings;
		System.runAs(new User(Id = UserInfo.getUserId())) {
			User volunteerUser = TestDataFactory.createCommunityUser(1)[0];
			insert volunteerUser;
		}
	}

	@IsTest
	static void processVolunteersActive() {
		// ARRANGE
		Contact markVolunteerArizona = [
				SELECT Id, MailingState
				FROM Contact
				WHERE Name = 'Mark Smith'
				AND MailingState = 'Arizona'
		];
		Contact markVolunteerNewYork = [
				SELECT Id
				FROM Contact
				WHERE Name = 'Mark Smith'
				AND MailingState = 'New York'
		];
		Set<Id> volunteerContactIds = new Set<Id>();
		volunteerContactIds.add(markVolunteerArizona.Id);
		volunteerContactIds.add(markVolunteerNewYork.Id);

		// ACT
		Test.startTest();
		Map<Id, Boolean> result = VolunteerJourneyService.processVolunteersChapterRequirements(volunteerContactIds);
		Test.stopTest();

		// ASSERT
		Boolean markVolunteerArizonaActive = result.get(markVolunteerArizona.Id);
		Boolean markVolunteerNewYorkActive = result.get(markVolunteerNewYork.Id);
		System.assertEquals(true, markVolunteerArizonaActive);
		System.assertEquals(null, markVolunteerNewYorkActive);
	}

	@IsTest
	static void processVolunteersWhenVolunteerRoleSetToActiveManually() {
		// ARRANGE
		Volunteer_Roles__c manualActivatedVolunteerRole = [
				SELECT Id, Chapter_Name__c, Volunteer_Name__c
				FROM Volunteer_Roles__c
				WHERE Status__c = 'Active'
				AND Volunteer_Name__r.Name = :'Mark Smith'
		];
		Map<Id, Set<String>> volunteerContactIdByChapterIdWithActiveRoleMap = new Map<Id, Set<String>>();
		Set<String> volunteerRolesActiveIds = new Set<String>();
		volunteerRolesActiveIds.add(manualActivatedVolunteerRole.Chapter_Name__c);
		volunteerContactIdByChapterIdWithActiveRoleMap.put(manualActivatedVolunteerRole.Volunteer_Name__c, volunteerRolesActiveIds);

		// ACT
		Test.startTest();
		Map<Id, Boolean> result = VolunteerJourneyService.processVolunteersRoleActiveBypass(volunteerContactIdByChapterIdWithActiveRoleMap);
		Test.stopTest();

		// ASSERT
		Boolean markVolunteerActive = result.get(manualActivatedVolunteerRole.Volunteer_Name__c);
		System.assert(markVolunteerActive);
	}
}