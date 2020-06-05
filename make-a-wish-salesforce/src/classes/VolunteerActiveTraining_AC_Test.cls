// Unit Test for VolunteerActiveTraining.
@IsTest
public class VolunteerActiveTraining_AC_Test {

	private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;

	@TestSetup
	public static void setUp() {
		trac_TriggerHandlerBase.blockTrigger = true;

		insert new Bypass_Triggers__c(SetupOwnerId = UserInfo.getUserId());

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
		chapterRole.Background_Check_Required__c = false;
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

		List<Class_Offering__c> classOfferings = TestDataFactory.createClassOffering(2);
		Class_Offering__c classOffering1 = classOfferings.get(0);
		classOffering1.Chapter_Role_O_T__c = chapterRoleOT.Id;
		classOffering1.Date__c = Date.today().addDays(10);
		classOffering1.Start_Time__c = '10:00 AM';
		classOffering1.End_Time__c = '10:00 AM';
		classOffering1.max_capacity__c = 100;
		classOffering1.Location__c = 'Test';
		classOffering1.RecordTypeId = Constant_AC.CLASS_OFFERING_RECORD_TYPE_ID;
		Class_Offering__c classOffering2 = classOfferings.get(1);
		classOffering2.Chapter_Role_O_T__c = chapterRoleOT.Id;
		classOffering2.Date__c = Date.today().addDays(12);
		classOffering2.Start_Time__c = '1:00 PM';
		classOffering2.End_Time__c = '2:00 PM';
		classOffering2.max_capacity__c = 100;
		classOffering2.Location__c = 'Test';
		classOffering2.RecordTypeId = Constant_AC.CLASS_OFFERING_RECORD_TYPE_ID;
		insert classOfferings;

		List<Volunteer_Orientation_Training__c> volunteerOrientationTrainings = TestDataFactory.createVolunteerOrientationAndTraining(5);
		Volunteer_Orientation_Training__c volunteerOrientationTraining1 = volunteerOrientationTrainings.get(0);
		volunteerOrientationTraining1.Class_Offering__c = classOffering1.Id;
		volunteerOrientationTraining1.Hidden_O_T_Id__c = orientationTraining.Id;
		volunteerOrientationTraining1.Registered_Date__c = Date.today();
		volunteerOrientationTraining1.Volunteer__c = volunteerUser.ContactId;
		volunteerOrientationTraining1.Volunteer_Attendance__c = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED;
		volunteerOrientationTraining1.Type__c = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_TYPE_ORIENTATION;
		Volunteer_Orientation_Training__c volunteerOrientationTraining2 = volunteerOrientationTrainings.get(1);
		volunteerOrientationTraining2.Class_Offering__c = classOffering1.Id;
		volunteerOrientationTraining2.Hidden_O_T_Id__c = orientationTraining.Id;
		volunteerOrientationTraining2.Registered_Date__c = Date.today();
		volunteerOrientationTraining2.Volunteer__c = volunteerUser.ContactId;
		volunteerOrientationTraining2.Volunteer_Attendance__c = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED;
		volunteerOrientationTraining2.Type__c = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_TYPE_ORIENTATION;
		Volunteer_Orientation_Training__c volunteerOrientationTraining3 = volunteerOrientationTrainings.get(2);
		volunteerOrientationTraining3.Class_Offering__c = classOffering1.Id;
		volunteerOrientationTraining3.Hidden_O_T_Id__c = orientationTraining.Id;
		volunteerOrientationTraining3.Registered_Date__c = Date.today();
		volunteerOrientationTraining3.Volunteer__c = volunteerUser.ContactId;
		volunteerOrientationTraining3.Volunteer_Attendance__c = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED;
		volunteerOrientationTraining3.Type__c = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING;
		Volunteer_Orientation_Training__c volunteerOrientationTraining4 = volunteerOrientationTrainings.get(3);
		volunteerOrientationTraining4.Class_Offering__c = classOffering1.Id;
		volunteerOrientationTraining4.Hidden_O_T_Id__c = orientationTraining.Id;
		volunteerOrientationTraining4.Registered_Date__c = Date.today();
		volunteerOrientationTraining4.Volunteer__c = volunteerUser.ContactId;
		volunteerOrientationTraining4.Volunteer_Attendance__c = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED;
		volunteerOrientationTraining4.Type__c = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING;
		Volunteer_Orientation_Training__c volunteerOrientationTraining5 = volunteerOrientationTrainings.get(4);
		volunteerOrientationTraining5.Class_Offering__c = classOffering1.Id;
		volunteerOrientationTraining5.Hidden_O_T_Id__c = orientationTraining.Id;
		volunteerOrientationTraining5.Registered_Date__c = Date.today();
		volunteerOrientationTraining5.Volunteer__c = volunteerUser.ContactId;
		volunteerOrientationTraining5.Volunteer_Attendance__c = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED;
		volunteerOrientationTraining5.Type__c = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING;
		insert volunteerOrientationTrainings;

		List<Conflict_Of_Interest__c> conflictOfInterests = TestDataFactory.createConflictOfInterest(1);
		Conflict_Of_Interest__c conflictOfInterest = conflictOfInterests.get(0);
		conflictOfInterest.Volunteer_Contact__c = volunteerUser.ContactId;
		conflictOfInterest.Expiration_Date__c = System.today() + 5;
		conflictOfInterest.Current__c = true;
		insert conflictOfInterests;

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
		backgroundCheck2.Status__c = Constant_AC.BACKGROUND_CHECK_STATUS_APPROVED;
		backgroundCheck2.Date__c = Date.today() + 5;
		backgroundCheck2.Date_Completed__c = Date.today() + 5;
		backgroundCheck2.Current__c = true;
		insert backgroundChecks;

		System.debug('Debugz1 User ' + volunteerUser.Id);
		System.debug('Debugz1 Contact' + volunteerUser.ContactId);
		System.debug('Debugz1 backgroundChecks' + backgroundChecks);

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	static void CreatingCompletedTraining() {
		User volunteerUser = [
				SELECT Id, ContactId, ProfileId
				FROM User
				WHERE Email = 'js@email.com'
		][0];
		Class_Offering__c classOffering = [
				SELECT Id
				FROM Class_Offering__c
				WHERE Location__c = 'Test'
		][0];
		System.runAs(volunteerUser) {
			Dynamic_Content__c dc = TestDataFactory.createDynamicContent(1)[0];
			insert dc;
			PageReference pageRef = Page.VolunteerActiveTraining_VF;
			Test.setCurrentPage(pageRef);
			VolunteerActiveTraining_AC controller = new VolunteerActiveTraining_AC();
			controller.TimingInfo();
			controller.getTrainingRecordList();
			controller.trainingId = classOffering.Id;
			controller.No();
			controller.Previous();
			controller.getDisablePrevious();
			controller.total_size = 10;
			controller.End();
			Boolean bgTabPermission = controller.bgTabPermission;
			Boolean trainingTabVisible = controller.trainingTabVisible;
			VolunteerActiveTraining_AC.updateUser('volunteer@gmail.com', '3409379', 'volunteer@gmail.com', volunteerUser.Id);
		}
	}

	@IsTest
	static void VolunteerTrainingDisplay() {
		User volunteerUser = [
				SELECT Id, ContactId, ProfileId
				FROM User
				WHERE Email = 'js@email.com'
		][0];
		Class_Offering__c classOffering = [
				SELECT Id
				FROM Class_Offering__c
				WHERE Location__c = 'Test'
		][0];
		System.runAs(volunteerUser) {
			Dynamic_Content__c dc = TestDataFactory.createDynamicContent(1)[0];
			insert dc;
			PageReference pageRef = Page.VolunteerActiveTraining_VF;
			Test.setCurrentPage(pageRef);
			VolunteerActiveTraining_AC controller = new VolunteerActiveTraining_AC();
			controller.TimingInfo();
			controller.getTrainingRecordList();
			controller.trainingId = classOffering.Id;
			controller.Register();
			VolunteerActiveTraining_AC.updateUser('volunteer@gmail.com', '3409379', 'volunteer@gmail.com', '0055B0000011r12');
		}
	}

	@IsTest
	static void CreateNewTraining() {
		User volunteerUser = [
				SELECT Id, ContactId, ProfileId
				FROM User
				WHERE Email = 'js@email.com'
		][0];
		Class_Offering__c classOffering = [
				SELECT Id
				FROM Class_Offering__c
				WHERE Location__c = 'Test'
		][0];
		System.runAs(volunteerUser) {
			Dynamic_Content__c dc = TestDataFactory.createDynamicContent(1)[0];
			insert dc;
			PageReference pageRef = Page.VolunteerTraining_VF;
			Test.setCurrentPage(pageRef);
			VolunteerActiveTraining_AC controller = new VolunteerActiveTraining_AC();
			controller.TimingInfo();
			controller.getTrainingRecordList();
			controller.trainingId = classOffering.Id;
			controller.Register();
		}
	}

	@IsTest
	static void CreatingCancelledTraining() {
		Class_Offering__c classOffering = [
				SELECT Id
				FROM Class_Offering__c
				WHERE Location__c = 'Test'
		][0];
		VolunteerActiveTraining_AC controller = new VolunteerActiveTraining_AC();
		Dynamic_Content__c dc = TestDataFactory.createDynamicContent(1)[0];
		insert dc;
		PageReference pageRef = Page.VolunteerActiveTraining_VF;
		Test.setCurrentPage(pageRef);
		controller.TimingInfo();
		controller.getTrainingRecordList();
		controller.trainingId = classOffering.Id;
	}

	@IsTest
	static void CancelTraining() {
		Class_Offering__c classOffering = [
				SELECT Id
				FROM Class_Offering__c
				WHERE Location__c = 'Test'
		][0];
		System.runAs(Utils.currentUser) {
			Dynamic_Content__c dc = TestDataFactory.createDynamicContent(1)[0];
			insert dc;
			PageReference pageRef = Page.VolunteerActiveTraining_VF;
			Test.setCurrentPage(pageRef);
			VolunteerActiveTraining_AC controller = new VolunteerActiveTraining_AC();
			controller.TimingInfo();
			controller.getTrainingRecordList();
			controller.trainingId = classOffering.Id;
			controller.Cancel();
		}
	}

	@IsTest
	static void CancelTraining2() {
		Class_Offering__c classOffering = [
				SELECT Id
				FROM Class_Offering__c
				WHERE Location__c = 'Test'
		][0];
		User volunteerUser = [
				SELECT Id, ContactId, ProfileId
				FROM User
				WHERE Email = 'js@email.com'
		][0];
		System.runAs(volunteerUser) {
			Dynamic_Content__c dc = TestDataFactory.createDynamicContent(1)[0];
			insert dc;
			PageReference pageRef = Page.VolunteerActiveTraining_VF;
			Test.setCurrentPage(pageRef);
			VolunteerActiveTraining_AC controller = new VolunteerActiveTraining_AC();
			controller.TimingInfo();
			controller.getTrainingRecordList();
			controller.trainingId = classOffering.Id;
			controller.getUserRelatedContact.add(volunteerUser);
			controller.Cancel();
		}
	}

	@IsTest
	static void BookingTrainingwithSameTime() {
		User volunteerUser = [
				SELECT Id, ContactId, ProfileId
				FROM User
				WHERE Email = 'js@email.com'
		][0];
		Class_Offering__c classOffering = [
				SELECT Id
				FROM Class_Offering__c
				WHERE Location__c = 'Test'
		][0];
		System.runAs(volunteerUser) {
			Dynamic_Content__c dc = TestDataFactory.createDynamicContent(1)[0];
			insert dc;
			PageReference pageRef = Page.VolunteerActiveTraining_VF;
			Test.setCurrentPage(pageRef);
			VolunteerActiveTraining_AC controller = new VolunteerActiveTraining_AC();
			controller.TimingInfo();
			controller.getTrainingRecordList();
			controller.trainingId = classOffering.Id;
			controller.Register();
			controller.Next();
			controller.Beginning();
			controller.getPageNumber();
			controller.getTotalPages();
			controller.getDisableNext();
		}
	}

	@IsTest
	static void CheckViewLMS() {
		User volunteerUser = [
				SELECT Id, ContactId, ProfileId
				FROM User
				WHERE Email = 'js@email.com'
		][0];
		System.runAs(volunteerUser) {
			LMSCourseSyncMockImpl currLMSCourseSyncMockImpl = new LMSCourseSyncMockImpl();
			HttpResponse response = new HttpResponse();
			response.setStatus('OK');
			response.setStatusCode(200);
			LMSUserResponse currLMSUserResponse = new LMSUserResponse();
			currLMSUserResponse.id = 1234;
			currLMSUserResponse.login = 'test@test.com';
			currLMSUserResponse.code = 'test@test.com';
			currLMSUserResponse.first_name = 'test';
			currLMSUserResponse.last_name = 'test';
			currLMSUserResponse.last_name = 'test@test.com';
			currLMSUserResponse.is_active = true;
			currLMSUserResponse.last_login_at = '2016-08-04T19:20:05.407-04:00';
			String payload = JSON.serialize(currLMSUserResponse);
			response.setBody(payload);
			currLMSCourseSyncMockImpl.addResponse(response);
			Test.setMock(HttpCalloutMock.class, currLMSCourseSyncMockImpl);
		}
		Test.startTest();
		System.runAs(volunteerUser) {
			PageReference pageRef = Page.VolunteerActiveTraining_VF;
			Test.setCurrentPage(pageRef);
			VolunteerActiveTraining_AC controller = new VolunteerActiveTraining_AC();
			controller.lMSCourseId = 'Test';
			controller.viewLMS();
		}
		Test.stopTest();
	}

	@IsTest
	static void register_test() {
		User volunteerUser = [
				SELECT Id, ContactId, ProfileId
				FROM User
				WHERE Email = 'js@email.com'
		][0];
		Class_Offering__c classOffering = [
				SELECT Id
				FROM Class_Offering__c
				WHERE Location__c = 'Test'
		][0];
		Test.startTest();
		System.runAs(volunteerUser) {
			Dynamic_Content__c dc = TestDataFactory.createDynamicContent(1)[0];
			insert dc;
			PageReference pageRef = Page.VolunteerActiveTraining_VF;
			Test.setCurrentPage(pageRef);
			VolunteerActiveTraining_AC controller = new VolunteerActiveTraining_AC();
			controller.TimingInfo();
			controller.getTrainingRecordList();
			controller.trainingId = classOffering.Id;
			controller.Register();
			controller.trainingId = classOffering.Id;
			controller.Register();
			controller.Next();
			controller.Beginning();
			controller.getPageNumber();
			controller.getTotalPages();
			controller.getDisableNext();
		}
		Test.stopTest();
	}

	@IsTest
	static void register_test2() {
		User volunteerUser = [
				SELECT Id, ContactId, ProfileId
				FROM User
				WHERE Email = 'js@email.com'
		][0];
		Class_Offering__c classOffering = [
				SELECT Id
				FROM Class_Offering__c
				WHERE Location__c = 'Test'
		][0];
		System.runAs(volunteerUser) {
			Dynamic_Content__c dc = TestDataFactory.createDynamicContent(1)[0];
			insert dc;
			PageReference pageRef = Page.VolunteerActiveTraining_VF;
			Test.setCurrentPage(pageRef);
			VolunteerActiveTraining_AC controller = new VolunteerActiveTraining_AC();
			controller.TimingInfo();
			controller.getTrainingRecordList();
			controller.trainingId = classOffering.Id;
			controller.Register();
			controller.Next();
			controller.Beginning();
			controller.getPageNumber();
			controller.getTotalPages();
			controller.getDisableNext();
		}
	}

	@IsTest
	static void register_test3() {
		User volunteerUser = [
				SELECT Id, ContactId, ProfileId
				FROM User
				WHERE Email = 'js@email.com'
		][0];
		Class_Offering__c classOffering = [
				SELECT Id
				FROM Class_Offering__c
				WHERE Location__c = 'Test'
		][0];
		System.runAs(volunteerUser) {
			Dynamic_Content__c dc = TestDataFactory.createDynamicContent(1)[0];
			insert dc;
			PageReference pageRef = Page.VolunteerActiveTraining_VF;
			Test.setCurrentPage(pageRef);
			VolunteerActiveTraining_AC controller = new VolunteerActiveTraining_AC();
			controller.TimingInfo();
			controller.getTrainingRecordList();
			controller.trainingId = classOffering.Id;
			controller.isCompleted = true;
			controller.Register();
			controller.Next();
			controller.Beginning();
			controller.getPageNumber();
			controller.getTotalPages();
			controller.getDisableNext();
		}
	}

	@IsTest
	static void register_test4() {
		User volunteerUser = [
				SELECT Id, ContactId, ProfileId
				FROM User
				WHERE Email = 'js@email.com'
		][0];
		Class_Offering__c classOffering = [
				SELECT Id
				FROM Class_Offering__c
				WHERE Location__c = 'Test'
		][0];
		List<Volunteer_Orientation_Training__c> volunteerOrientationTrainingsUpdate = new List<Volunteer_Orientation_Training__c>();
		for(Volunteer_Orientation_Training__c volunteerOrientationTraining : [
				SELECT Id, Volunteer_Attendance__c
				FROM Volunteer_Orientation_Training__c
				WHERE Volunteer_Attendance__c = :Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED
		]){
			volunteerOrientationTraining.Volunteer_Attendance__c = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED;
			volunteerOrientationTrainingsUpdate.add(volunteerOrientationTraining);
		}
		update volunteerOrientationTrainingsUpdate;
		System.runAs(volunteerUser) {
			Dynamic_Content__c dc = TestDataFactory.createDynamicContent(1)[0];
			insert dc;
			PageReference pageRef = Page.VolunteerActiveTraining_VF;
			Test.setCurrentPage(pageRef);
			VolunteerActiveTraining_AC controller = new VolunteerActiveTraining_AC();
			controller.TimingInfo();
			controller.getTrainingRecordList();
			controller.trainingId = classOffering.Id;
			controller.isCompleted = true;
			controller.Register();
			controller.Next();
			controller.Beginning();
			controller.getPageNumber();
			controller.getTotalPages();
			controller.getDisableNext();
		}
	}
}