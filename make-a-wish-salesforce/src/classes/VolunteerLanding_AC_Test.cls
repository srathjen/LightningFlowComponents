@IsTest
public class VolunteerLanding_AC_Test {

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

		List<Role__c> roles = TestDataFactory.createRole(1, true);
		Role__c wishGranterRole = roles.get(0);
		wishGranterRole.Name = 'Wish Granter';
		wishGranterRole.isWishRole__c = true;
		insert roles;

		List<Chapter_Role__c> chapterRoles = TestDataFactory.createChapterRole(1);
		Chapter_Role__c chapterRole = chapterRoles.get(0);
		chapterRole.Chapter_Name__c = account.Id;
		chapterRole.Role_Name__c = wishGranterRole.Id;
		chapterRole.Background_Check_Required__c = true;
		insert chapterRoles;

		List<Volunteer_Roles__c> volunteerRoles = TestDataFactory.createVolunteerRole(2);
		Volunteer_Roles__c volunteerWishRole = volunteerRoles.get(0);
		volunteerWishRole.Volunteer_Name__c = volunteerUser.ContactId;
		volunteerWishRole.Chapter_Role__c = chapterRole.Id;
		volunteerWishRole.Status__c = Constant_AC.VOLUNTEER_ROLE_STATUS_PENDING;
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
		chapterRoleOT.Chapter_Role__c = chapterRole.Id;
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

		List<Conflict_Of_Interest__c> conflictOfInterests = TestDataFactory.createConflictOfInterest(1);
		Conflict_Of_Interest__c conflictOfInterest = conflictOfInterests.get(0);
		conflictOfInterest.Volunteer_Contact__c = volunteerUser.ContactId;
		conflictOfInterest.Expiration_Date__c = System.today() + 5;
		conflictOfInterest.Current__c = true;
		insert conflictOfInterests;

		COIRecordSharing(volunteerUser.Id, conflictOfInterest.Id);

		List<Broadcast__c> broadcasts = TestDataFactory.createBroadcast(1);
		Broadcast__c broadcast = broadcasts.get(0);
		broadcast.Broadcast_Message__c = 'Test';
		broadcast.Date__c = Date.today() + 5;
		broadcast.Chapter_Name__c = volunteerUserContact.AccountId;
		broadcast.Active__c = true;
		insert broadcasts;

		List<Background_check__c> backgroundChecks = TestDataFactory.createBackgroundCheck(2);
		Background_check__c backgroundCheck = backgroundChecks.get(0);
		backgroundCheck.Volunteer__c = volunteerUser.ContactId;
		backgroundCheck.Status__c = Constant_AC.BACKGROUND_CHECK_STATUS_REJECTED;
		backgroundCheck.Date__c = Date.today() + 5;
		backgroundCheck.Date_Completed__c = Date.today() + 5;
		backgroundCheck.Current__c = true;
		Background_check__c backgroundCheck2 = backgroundChecks.get(1);
		backgroundCheck2.Volunteer__c = volunteerUser.ContactId;
		backgroundCheck2.Status__c = Constant_AC.BACKGROUND_CHECK_STATUS_REJECTED;
		backgroundCheck2.Date__c = Date.today() + 5;
		backgroundCheck2.Date_Completed__c = Date.today() + 5;
		backgroundCheck2.Current__c = true;
		insert backgroundChecks;

		BGCRecordSharing(volunteerUser.Id, backgroundCheck.Id);

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	static void createDynamicContent() {
		User volunteerUser = [
				SELECT Id, ContactId, ProfileId
				FROM User
				WHERE Email = 'js@email.com'
		][0];
		System.runAs(volunteerUser) {
			Utils.currentUser = null;
			VolunteerLanding_AC controller = new VolunteerLanding_AC();
			controller.getChapterList();
			controller.getEvents();
			controller.EnterchapterPage();
		}
	}

	@IsTest
	static void CreateHoldChapterValue() {
		User volunteerUser = [
				SELECT Id, ContactId, ProfileId
				FROM User
				WHERE Email = 'js@email.com'
		][0];
		System.runAs(volunteerUser) {
			Utils.currentUser = null;
			VolunteerLanding_AC controller = new VolunteerLanding_AC();
			controller.EnterchapterPage();
		}
	}

	@IsTest
	static void checkBGandCOI() {
		User volunteerUser = [
				SELECT Id, ContactId, ProfileId
				FROM User
				WHERE Email = 'js@email.com'
		][0];
		System.runAs(volunteerUser) {
			Utils.currentUser = null;
			VolunteerLanding_AC controller = new VolunteerLanding_AC();
			controller.currUser = volunteerUser;
			controller.getChapterList();
			controller.EnterchapterPage();
			controller.COICheck();
			controller.COICheck();
			controller.backgroundCheck();
			controller.volunteercon.BackGroundCheckUpdated__c = true;
			controller.register();
			controller.featuredImage = 'testImage';
			controller.featuredQuote = 'testQuote';
			controller.welcomeMsg = 'testWelcome';
			controller.headingTitle1 = 'testTitle1';
			controller.headingText1 = 'testText';
			controller.text1 = 'testText1';
			controller.text2 = 'testText2';
			controller.text3 = 'testText3';
			controller.title1 = 'testTitile1';
			controller.title2 = 'testTitle2';
			controller.title3 = 'testTitle3';
			controller.image1 = 'testImage1';
			controller.image2 = 'testImage2';
			controller.image3 = 'testImage3';
			controller.confirmPopup = true;
			User currUser = TestDataFactory.adminUser;
			System.runAs(currUser) {
				controller.confirmBackGroundCheck();
			}
			controller.cancel();
			controller.cancelConflict();
			controller.displayEmail();
			controller.hidePopup();
			controller.TrainingAckCancel();
			Test.setMock(HttpCalloutMock.class, new Mock_ResponseGenerator());
			System.runAs(currUser) {
				controller.confirmBackGroundCheck();
			}
			controller.confirmConflict('VolunteerLanding_VF');
			Boolean flag = controller.flagForCOICancel;
			String status = controller.residingStatus;
			Integer coi = controller.nCOIDays;
			List<Orientation_Training__c> orientations = controller.orientationList;
			Boolean inactive = controller.isInactivePopup;
			Boolean display = controller.displayTrainingnewDetails;
			controller.broadCastCancel();
		}
	}

	@IsTest
	static void checkBackgroundCheck() {
		User volunteerUser = [
				SELECT Id, ContactId, ProfileId
				FROM User
				WHERE Email = 'js@email.com'
		][0];
		System.runAs(volunteerUser) {
			Utils.currentUser = null;
			VolunteerLanding_AC controller = new VolunteerLanding_AC();
			controller.confirmPopup = true;
			controller.hidePopup();
			controller.getChapterList();
			controller.EnterchapterPage();
			controller.myId = volunteerUser.Id;
			controller.COICheck();
			controller.broadCastCancel();
			controller.callConfirmConflict();
		}
	}

	@IsTest
	static void checkCOI() {
		User volunteerUser = [
				SELECT Id, ContactId, ProfileId
				FROM User
				WHERE Email = 'js@email.com'
		][0];
		System.runAs(volunteerUser) {
			Utils.currentUser = null;
			VolunteerLanding_AC controller = new VolunteerLanding_AC();
			controller.getChapterList();
			controller.EnterchapterPage();
			controller.COICheck();
			controller.broadCastCancel();
		}
	}

	@IsTest
	static void checkCOIisExpired() {
		User volunteerUser = [
				SELECT Id, ContactId, ProfileId
				FROM User
				WHERE Email = 'js@email.com'
		][0];
		System.runAs(volunteerUser) {
			Utils.currentUser = null;
			VolunteerLanding_AC controller = new VolunteerLanding_AC();
			controller.getChapterList();
			controller.EnterchapterPage();
			controller.COICheck();
		}
	}

	@IsTest
	static void checkBGisExpired() {
		User volunteerUser = [
				SELECT Id, ContactId, ProfileId
				FROM User
				WHERE Email = 'js@email.com'
		][0];
		System.runAs(volunteerUser) {
			Utils.currentUser = null;
			VolunteerLanding_AC controller = new VolunteerLanding_AC();
			controller.isBGRoleExpOOC = true;
			controller.getChapterList();
			controller.EnterchapterPage();
			controller.COICheck();
		}
	}

	@IsTest
	private static void checkBGStatus() {
		User volunteerUser = [
				SELECT Id, ContactId, ProfileId
				FROM User
				WHERE Email = 'js@email.com'
		][0];

		System.runAs(volunteerUser) {
			Utils.currentUser = null;
			VolunteerLanding_AC controller = new VolunteerLanding_AC();
			controller.getChapterList();
			controller.EnterchapterPage();
			controller.COICheck();
		}
	}

	private static Background_check__Share BGCRecordSharing(Id userId, Id recordId) {
		Background_check__Share currSharing = new Background_check__Share();
		User currUser = TestDataFactory.adminUser;
		System.runAs(currUser) {
			currSharing.ParentId = recordId;
			currSharing.UserOrGroupId = userId;
			currSharing.AccessLevel = Constant_AC.RECORD_SHARE_EDIT;
			currSharing.RowCause = Schema.Background_check__Share.RowCause.Manual;
			insert currSharing;
		}
		return currSharing;
	}

	private static Conflict_Of_Interest__Share COIRecordSharing(Id userId, Id recordId) {
		Conflict_Of_Interest__Share currSharing = new Conflict_Of_Interest__Share();
		User currUser = TestDataFactory.adminUser;
		System.runAs(currUser) {
			currSharing.ParentId = recordId;
			currSharing.UserOrGroupId = userId;
			currSharing.AccessLevel = Constant_AC.RECORD_SHARE_EDIT;
			currSharing.RowCause = Schema.Conflict_Of_Interest__Share.RowCause.Manual;
			insert currSharing;
		}
		return currSharing;
	}
}