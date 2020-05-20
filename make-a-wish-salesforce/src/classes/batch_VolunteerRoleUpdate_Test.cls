/**
 * Test
 */
@IsTest
public class batch_VolunteerRoleUpdate_Test {

	private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;

	@TestSetup
	public static void setUp() {
		trac_TriggerHandlerBase.blockTrigger = true;
		User currentUser = Utils.currentUser;
		List<Account> accounts = TestDataFactory.createAccount(1);
		Account account = accounts.get(0);
		account.Name = 'Make-A-Wish Arizona';
		account.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
		account.Volunteer_Manager__c = currentUser.Id;
		account.Alert_for_Unassigned_Wishes__c = 1;
		insert accounts;

		List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
		ICD_Codes__c icdCode = icdCodes.get(0);
		insert icdCode;

		List<Lead> leadsDataFactory = TestDataFactory.createLead(1);
		Lead lead = leadsDataFactory.get(0);
		lead.ChapterName__c = accounts[0].Id;
		lead.FirstName = 'Jack';
		lead.LastName = 'Smith';
		lead.Hidden_Chapter_Change_Confirmation__c = account.Id;
		lead.is_Family_Aware_of_Referral__c = 'Yes';
		lead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
		lead.PD_ICD_Code__c = icdCode.Id;
		lead.Company = 'MAW';
		insert lead;

		List<Contact> contacts = TestDataFactory.createContact(2);
		Contact contact1 = contacts.get(0);
		contact1.FirstName = 'Test1';
		contact1.LastName = 'User2';
		contact1.AccountId = account.Id;
		contact1.ICD_10_Code__c = icdCode.Id;
		insert contacts;

		User volunteerUser = TestDataFactory.createVolunteerUser(1, 'Active Volunteer (Login)', 'Manager').get(0);
		volunteerUser.LastName = 'Smith0';
		volunteerUser.Email = 'js@email.com';
		System.runAs(TestDataFactory.adminUser) {
			insert volunteerUser;
		}

		Contact volunteerUserContact = [
				SELECT AccountId, Account.Name
				FROM Contact
				WHERE Id = :volunteerUser.ContactId
		];

		List<Case> cases = TestDataFactory.createCase(1);
		Case wish = cases.get(0);
		wish.Lead__c = lead.Id;
		wish.RecordTypeId = Constant_AC.DIAGNOSIS_RT_ID;
		wish.ChapterName__c = accounts.get(0).Id;
		wish.Subject = 'Wish1';
		wish.Interview_date__c = System.today();
		wish.Wish_Type__c = 'Hawaii';
		wish.Start_Date__c = System.today();
		wish.End_Date__c = System.today();
		wish.ContactId = contact1.Id;
		wish.Status = 'New';
		wish.Rush__c = false;
		wish.Start_Date__c = System.today();
		wish.Budget_Submitted_Date__c = System.today();
		wish.Budget_Approved_Date__c = System.today();
		wish.Update_Wish_Child_Form_Info__c = true;
		insert cases;

		List<npe5__Affiliation__c> affiliations = TestDataFactory.createAffiliation(1);
		npe5__Affiliation__c affiliation = affiliations.get(0);
		affiliation.npe5__Contact__c = volunteerUser.ContactId;
		affiliation.npe5__Organization__c = volunteerUserContact.AccountId;
		affiliation.npe5__Primary__c = true;
		affiliation.npe5__Status__c = 'Active';
		affiliation.Constituent_Code__c = Constant_AC.BOARD_MEMBER_RT_LABEL;
		insert affiliations;

		List<Dynamic_Content__c> dynamicContents = TestDataFactory.createDynamicContent(1);
		Dynamic_Content__c dynamicContent = dynamicContents.get(0);
		dynamicContent.Feature_Quote__c = 'Test Feature Quote';
		dynamicContent.Active__c = true;
		dynamicContent.Welcome_Message__c = 'Test Welcome Page';
		dynamicContent.Heading_Highlight_Text_1__c = 'Test Heightlisght Text';
		dynamicContent.Heading_Highlight_Text_2__c = 'Test Heightlisght Text';
		dynamicContent.Heading_Highlight_Text_3__c = 'Test Heightlisght Text';
		dynamicContent.Heading_Highlight_Title_1__c = 'Test Title';
		dynamicContent.Heading_Highlight_Title_2__c = 'Test Title';
		dynamicContent.Heading_Highlight_Title_3__c = 'Test Title';
		dynamicContent.RecordTypeId = Constant_AC.ACTIVE_VOL_RT_ID;
		dynamicContent.Chapter_Name__c = volunteerUser.AccountId;
		insert dynamicContents;

		List<HoldCurrentChapter__c> holdCurrentChapters = TestDataFactory.createHoldCurrentChapter(1);
		HoldCurrentChapter__c holdCurrentChapter = holdCurrentChapters.get(0);
		holdCurrentChapter.Name = volunteerUser.Id;
		holdCurrentChapter.CurrentChapter__c = volunteerUserContact.Account.Name;
		insert holdCurrentChapters;

		List<Non_Wish_Events__c> nonWishEvents = TestDataFactory.createNonWishEvent(2);
		Non_Wish_Events__c nonWishEvent = nonWishEvents.get(0);
		nonWishEvent.Event_Name__c = 'Send Off';
		nonWishEvent.Event_Date__c = System.today() + 5;
		nonWishEvent.Event_Text__c = 'Sending Wish Child';
		nonWishEvent.Priority__c = '1';
		nonWishEvent.Chapter__c = volunteerUserContact.AccountId;
		nonWishEvent.RecordTypeId = Constant_AC.EVENTS_ID;
		Non_Wish_Events__c nonWishEvent2 = nonWishEvents.get(1);
		nonWishEvent2.Event_Name__c = 'Send Off';
		nonWishEvent2.Event_Date__c = System.today() + 5;
		nonWishEvent2.Event_Text__c = 'Sending Wish Child';
		nonWishEvent2.Priority__c = '2';
		nonWishEvent2.Chapter__c = volunteerUserContact.AccountId;
		nonWishEvent2.RecordTypeId = Constant_AC.EVENTS_ID;
		insert nonWishEvents;

		List<Role__c> roles = TestDataFactory.createRole(2, true);
		Role__c wishGranterRole = roles.get(0);
		wishGranterRole.Name = 'Wish Granter';
		wishGranterRole.isWishRole__c = true;
		Role__c wishGranterRoleMentor = roles.get(1);
		wishGranterRoleMentor.Name = 'Wish Granter Mentor';
		wishGranterRoleMentor.isWishRole__c = true;
		insert roles;

		List<Chapter_Role__c> chapterRoles = TestDataFactory.createChapterRole(2);
		Chapter_Role__c chapterRole1 = chapterRoles.get(0);
		chapterRole1.Chapter_Name__c = account.Id;
		chapterRole1.Role_Name__c = wishGranterRole.Id;
		chapterRole1.Background_Check_Required__c = true;
		Chapter_Role__c chapterRole2 = chapterRoles.get(0);
		chapterRole2.Chapter_Name__c = account.Id;
		chapterRole2.Role_Name__c = wishGranterRoleMentor.Id;
		chapterRole2.Background_Check_Required__c = true;
		insert chapterRoles;

		List<Volunteer_Roles__c> volunteerRoles = TestDataFactory.createVolunteerRole(2);
		Volunteer_Roles__c volunteerWishRole1 = volunteerRoles.get(0);
		volunteerWishRole1.Volunteer_Name__c = volunteerUser.ContactId;
		volunteerWishRole1.Chapter_Role__c = chapterRole1.Id;
		volunteerWishRole1.Status__c = Constant_AC.VOLUNTEER_ROLE_STATUS_PENDING;
		volunteerWishRole1.Migrated_Record__c = true;
		Volunteer_Roles__c volunteerWishRole2 = volunteerRoles.get(1);
		volunteerWishRole2.Volunteer_Name__c = volunteerUser.ContactId;
		volunteerWishRole2.Chapter_Role__c = chapterRole1.Id;
		volunteerWishRole2.Status__c = Constant_AC.VOLUNTEER_ROLE_STATUS_PENDING;
		volunteerWishRole2.Migrated_Record__c = true;
		insert volunteerRoles;

		List<Orientation_Training__c> orientationTrainings = TestDataFactory.createOrientationTraining(2);
		Orientation_Training__c orientationTraining = orientationTrainings.get(0);
		orientationTraining.Name = 'Trainging1';
		orientationTraining.RecordTypeId = Constant_AC.TRAINING_RT_ID;
		orientationTraining.Start_Time__c = '7:00 AM';
		orientationTraining.End_Time__c = '7:00 PM';
		orientationTraining.Prompt_upon_Login__c = true;
		insert orientationTrainings;

		List<Chapter_Role_O_T__c> chapterRoleOTs = TestDataFactory.createChapterRoleOrientationAndTraining(1);
		Chapter_Role_O_T__c chapterRoleOT = chapterRoleOTs.get(0);
		chapterRoleOT.Orientation_Training__c = orientationTraining.Id;
		chapterRoleOT.Chapter_Role__c = chapterRole1.Id;
		chapterRoleOT.Required__c = true;
		insert chapterRoleOTs;

		List<DocuSignCredentialsSetting__c> docuSignCredentialsSettings = TestDataFactory.createDocuSignCredentialsSetting(1);
		DocuSignCredentialsSetting__c docuSignCredentialsSetting = docuSignCredentialsSettings.get(0);
		docuSignCredentialsSetting.account__c = '0afd45e1-ae2d-468c-a168-b8603dae66a3';
		docuSignCredentialsSetting.IntegratorKey__c = 'ea6d625f-6c08-4b12-aa2d-554909addb30';
		docuSignCredentialsSetting.Name = 'kanagaraj@mstsolutions.com';
		insert docuSignCredentialsSettings;

		List<Class_Offering__c> classOfferings = TestDataFactory.createClassOffering(1);
		Class_Offering__c classOffering = classOfferings.get(0);
		classOffering.Chapter_Role_O_T__c = chapterRoleOT.Id;
		classOffering.Date__c = Date.today().addDays(10);
		classOffering.Start_Time__c = '10:00 AM';
		classOffering.End_Time__c = '11:00 AM';
		classOffering.max_capacity__c = 100;
		classOffering.Location__c = 'Test';
		classOffering.RecordTypeId = Constant_AC.CLASS_OFFERING_RECORD_TYPE_ID;
		classOffering.Chapter_Role_O_T__c = chapterRoleOT.Id;
		insert classOfferings;

		List<Volunteer_Orientation_Training__c> volunteerOrientationTrainings = TestDataFactory.createVolunteerOrientationAndTraining(1);
		Volunteer_Orientation_Training__c volunteerOrientationTraining1 = volunteerOrientationTrainings.get(0);
		volunteerOrientationTraining1.Class_Offering__c = classOffering.Id;
		volunteerOrientationTraining1.Hidden_O_T_Id__c = orientationTraining.Id;
		volunteerOrientationTraining1.Registered_Date__c = Date.today();
		volunteerOrientationTraining1.Volunteer__c = volunteerUser.ContactId;
		volunteerOrientationTraining1.Volunteer_Attendance__c = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED;
		volunteerOrientationTraining1.Type__c = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_TYPE_ORIENTATION;
		insert volunteerOrientationTrainings;

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	static void testVolunteerRoleUpdate() {
		Test.startTest();
		Database.executeBatch(new batch_VolunteerRoleUpdate(), 25);
		Test.stopTest();
	}
}