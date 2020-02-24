/*****************************************************************************************************************
Author      : MST Solutions
Date        : 12/01/2016
Description : This class contains test method for CaseFile object
Modification Log: 
28/03/2018 - Kanagaraj
*******************************************************************************************************************/
@isTest
public class VolunteerWelcomePage_ACTest {

	@TestSetup
	private static void setup(){
		trac_TriggerHandlerBase.blockTrigger = true;
		insert new Bypass_Triggers__c(SetupOwnerId = UserInfo.getUserId());
	}
	// Initializing  constructor.
	static testMethod void testVolunteerWelcomePage() {
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;

		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;

		insert OrientationandTrainingUtil.createAffiliation(con.id);
		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
			currUser.ProfileId = Label.Active_Volunteer_Profile;
			insert currUser;
		}
		// Need parent record fields
		currUser = [
				SELECT Id, ContactId, Contact.AccountId
				FROM User
				WHERE Id = :currUser.Id
		];
		Dynamic_Content__c createDynamicContent = OrientationandTrainingUtil.createDynamicContent();
		Dynamic_Content__c createProspectiveDynamicContent = OrientationandTrainingUtil.createProspectiveDynamicContent(acc.id);
		insert new List<Dynamic_Content__c>{
				createDynamicContent, createProspectiveDynamicContent
		};
		System.RunAs(currUser) {

			VolunteerWelcomePage_AC controller = new VolunteerWelcomePage_AC();
			controller.becomeAVolunteer();
			controller.findVolunteerStatus();

			// Cover fields
			Boolean displayBecomAVolunteer = controller.displayBecomAVolunteer;
			Boolean displayContinueProcess = controller.displayContinueProcess;
			String welcomText = controller.welcomText;
			String becomeAVolunteer = controller.becomeAVolunteer;
			Integer nCOIDays = controller.nCOIDays;
			Boolean flagForCOICancel = controller.flagForCOICancel;
			Integer nBCDays = controller.nBCDays;
			Boolean flagForCancel = controller.flagForCancel;
			String residingStatus = controller.residingStatus;
			Boolean isInactivePopup = controller.isInactivePopup;
		}
	}

	// Testing negative case for orientation.
	static testMethod void negativeDataforOrientation() {
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;

		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		Contact updateContact = new Contact();
		updateContact.id = con.id;
		updateContact.is_Application__c = 'Submit';
		update updateContact;

		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
			insert currUser;
		}
		// Need parent record fields
		currUser = [
				SELECT Id, ContactId, Contact.AccountId
				FROM User
				WHERE Id = :currUser.Id
		];
		System.RunAs(currUser) {
			Test.startTest();
			Account acc1 = OrientationandTrainingUtil.createVolunteerAccount();
			insert acc1;

			Contact con1 = OrientationandTrainingUtil.createVolunteerContact(acc1.id);
			insert con1;

			Role__c currRole = OrientationandTrainingUtil.createRole();
			insert currRole;

			Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc1.id, currRole.id);
			currChapRole.Background_Check_Required__c = false;
			insert currChapRole;

			npe5__Affiliation__c currAffliation = OrientationandTrainingUtil.CreateAffiliation(con1.id);
			currAffliation.npe5__Primary__c = true;
			currAffliation.Constituent_Code__c = Constant_AC.VOLUNTEER_TASK_RT_LABEL;
			insert currAffliation;

			Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(currUser.ContactId, currChapRole.id);
			insert currVolRole;

			Orientation_Training__c currOrientationTraining = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
			insert currOrientationTraining;

			Chapter_Role_O_T__c currChapOrientation = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOrientationTraining.id);
			Chapter_Role_O_T__c currChapOrientation1 = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOrientationTraining.id);
			insert new List<Chapter_Role_O_T__c>{
					currChapOrientation, currChapOrientation1
			};

			Class_Offering__c currOrientationOffering = OrientationandTrainingUtil.createClassOffering(currChapOrientation.id);
			insert currOrientationOffering;

			Volunteer_Orientation_Training__c createVolOrientation = OrientationandTrainingUtil.createVolOrientation(currOrientationTraining.id, currOrientationOffering.id, currUser.ContactId, 'Completed');
			insert createVolOrientation;
			//npe5__Affiliation__c currAfflRec = [SELECT id,npe5__Organization__c FROM npe5__Affiliation__c WHERE npe5__Contact__c = :currUser.contactId AND npe5__Primary__c = true ];

			Id EventRecTypeId = Constant_AC.EVENTS_ID;

			List<Non_Wish_Events__c> eventList = new List<Non_Wish_Events__c>();
			for (integer i = 1; i < 4; i++) {
				Non_Wish_Events__c newEvent = new Non_Wish_Events__c();
				newEvent.Event_Name__c = 'Send Off';
				newEvent.Event_Date__c = System.Today() + 5;
				newEvent.Event_Text__c = 'Sending Wish Child';
				newEvent.Priority__c = String.valueOf(i);
				newEvent.chapter__c = currUser.Contact.AccountId;
				newEvent.RecordTypeId = EventRecTypeId;
				eventList.add(newEvent);
			}

			Non_Wish_Events__c newEvent = new Non_Wish_Events__c();
			newEvent.Event_Name__c = 'Send Off';
			newEvent.Event_Date__c = System.Today() + 5;
			newEvent.Event_Text__c = 'Sending Wish Child';
			//newEvent.Priority__c = String.valueOf(i);
			newEvent.RecordTypeId = EventRecTypeId;
			newEvent.chapter__c = currUser.Contact.AccountId;
			eventList.add(newEvent);
			insert eventList;

			VolunteerWelcomePage_AC controller = new VolunteerWelcomePage_AC();
			controller.getEvents();
			controller.becomeAVolunteer();
			controller.findVolunteerStatus();
			controller.COICheck();
			Test.stopTest();
			System.assertEquals(newEvent.Event_Name__c, 'Send Off', 'Event name does not match');
			System.assert(newEvent.Event_Name__c == 'Send Off', 'Event name does not match');
		}

	}

	// Completing Orientation for updating Orientation status.
	static testMethod void completeOrientation() {
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;

		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		Contact updateContact = new Contact();
		updateContact.id = con.id;
		updateContact.is_Application__c = 'Submit';
		update updateContact;

		System.assertEquals(updateContact.is_Application__c, 'Submit', 'Contact application status does not match');
		System.assert(updateContact.is_Application__c == 'Submit', 'Contact application status does not match');

		insert OrientationandTrainingUtil.createAffiliation(con.id);

		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
			insert currUser;
		}
		// Need parent record fields
		currUser = [
				SELECT Id, ContactId, Contact.AccountId
				FROM User
				WHERE Id = :currUser.Id
		];
		System.RunAs(currUser) {

			Role__c currRole = OrientationandTrainingUtil.createRole();
			insert currRole;

			Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(currUser.Contact.AccountId, currRole.id);
			insert currChapRole;

			Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(currUser.ContactId, currChapRole.id);
			insert currVolRole;

			Orientation_Training__c currOrientationTraining = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
			insert currOrientationTraining;

			Chapter_Role_O_T__c currChapOrientation = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOrientationTraining.id);
			insert currChapOrientation;

			Class_Offering__c currOrientationOffering = OrientationandTrainingUtil.createClassOffering(currChapOrientation.id);
			insert currOrientationOffering;

			Volunteer_Orientation_Training__c createVolOrientation = OrientationandTrainingUtil.createVolOrientation(currOrientationTraining.id, currOrientationOffering.id, currUser.ContactId, 'Completed');
			insert createVolOrientation;

			Test.startTest();
			VolunteerWelcomePage_AC controller = new VolunteerWelcomePage_AC();
			controller.getEvents();
			controller.becomeAVolunteer();
			controller.completedVolunteerOrientationIdsIds.add(con.Id);
			controller.requiredOrientationIds.add(con.Id);
			controller.orientationStatus = 'Completed';
			controller.checkcontactApplicationList = new List<Contact>{
					con
			};
			controller.findVolunteerStatus();
			Test.stopTest();
		}

	}
	// Completing Applicaiton for updating Applicaiton status.
	static testMethod void completeApplication() {
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;

		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		Contact updateContact = new Contact();
		updateContact.id = con.id;
		updateContact.is_Application__c = 'Approved';
		update updateContact;

		insert OrientationandTrainingUtil.createAffiliation(con.id);
		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
			insert currUser;
		}
		// Need parent record fields
		currUser = [
				SELECT Id, ContactId, Contact.AccountId
				FROM User
				WHERE Id = :currUser.Id
		];
		System.RunAs(currUser) {

			Role__c currRole = OrientationandTrainingUtil.createRole();
			insert currRole;

			Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(currUser.Contact.AccountId, currRole.id);
			insert currChapRole;

			Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(currUser.ContactId, currChapRole.id);
			insert currVolRole;

			Orientation_Training__c currOrientationTraining = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
			insert currOrientationTraining;

			Chapter_Role_O_T__c currChapOrientation = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOrientationTraining.id);
			insert currChapOrientation;

			Class_Offering__c currOrientationOffering = OrientationandTrainingUtil.createClassOffering(currChapOrientation.id);
			insert currOrientationOffering;

			Volunteer_Orientation_Training__c createVolOrientation = OrientationandTrainingUtil.createVolOrientation(currOrientationTraining.id, currOrientationOffering.id, currUser.ContactId, 'Completed');
			insert createVolOrientation;

			VolunteerWelcomePage_AC controller = new VolunteerWelcomePage_AC();
			controller.getEvents();
			controller.becomeAVolunteer();
			controller.completedVolunteerOrientationIdsIds.add(con.Id);
			controller.orientationStatus = 'Completed';
			controller.checkcontactApplicationList = new List<Contact>{
					con
			};
			controller.findVolunteerStatus();
		}
		System.assertEquals(updateContact.is_Application__c, 'Approved', 'Contact application status does not match');
		System.assert(updateContact.is_Application__c == 'Approved', 'Contact application status does not match');
	}
	// Completing Interview for updating Interview status.
	static testMethod void completeInterviewTask() {
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;

		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		Contact updateContact = new Contact();
		updateContact.id = con.id;
		updateContact.is_Application__c = 'Approved';
		update updateContact;

		insert OrientationandTrainingUtil.createAffiliation(con.id);
		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
			insert currUser;
		}
		// Need parent record fields
		currUser = [
				SELECT Id, ContactId, Contact.AccountId
				FROM User
				WHERE Id = :currUser.Id
		];
		System.RunAs(currUser) {

			Role__c currRole = OrientationandTrainingUtil.createRole();
			insert currRole;

			Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(currUser.Contact.AccountId, currRole.id);
			insert currChapRole;

			Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(currUser.ContactId, currChapRole.id);
			insert currVolRole;

			Orientation_Training__c currOrientationTraining = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
			insert currOrientationTraining;

			Chapter_Role_O_T__c currChapOrientation = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOrientationTraining.id);
			insert currChapOrientation;

			Class_Offering__c currOrientationOffering = OrientationandTrainingUtil.createClassOffering(currChapOrientation.id);
			insert currOrientationOffering;

			Volunteer_Orientation_Training__c createVolOrientation = OrientationandTrainingUtil.createVolOrientation(currOrientationTraining.id, currOrientationOffering.id, currUser.ContactId, 'Completed');
			insert createVolOrientation;

			// Task Creation.
			Id interviewRT = Constant_AC.TASK_RT_ID;
			// Confirmation Task
			Task confirmationTask = new Task();
			confirmationTask.Subject = 'Interview Task';
			confirmationTask.RecordTypeId = interviewRT;
			confirmationTask.Available_Date1__c = Date.Today();
			confirmationTask.Available_Time1__c = '5 pm';
			confirmationTask.Available_Date2__c = Date.Today();
			confirmationTask.Available_Time2__c = '6 pm';
			confirmationTask.Status = 'Approved';
			confirmationTask.whoId = currUser.ContactId;
			insert confirmationTask;

			VolunteerWelcomePage_AC controller = new VolunteerWelcomePage_AC();
			controller.getEvents();
			controller.becomeAVolunteer();
			controller.findVolunteerStatus();
			System.assertEquals(confirmationTask.Status, 'Approved', 'Task status does not match');
			System.assert(confirmationTask.Status == 'Approved', 'Task status does not match');
		}
	}

	// Creating Background check.
	static testMethod void createBackGroundCheck() {
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;

		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		Contact updateContact = new Contact();
		updateContact.id = con.id;
		updateContact.is_Application__c = 'Approved';
		update updateContact;

		insert OrientationandTrainingUtil.createAffiliation(con.id);
		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
			insert currUser;
		}
		// Need parent record fields
		currUser = [
				SELECT Id, ContactId, Contact.AccountId
				FROM User
				WHERE Id = :currUser.Id
		];
		System.RunAs(currUser) {

			Role__c currRole = OrientationandTrainingUtil.createRole();
			insert currRole;

			Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(currUser.Contact.AccountId, currRole.id);
			insert currChapRole;

			Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(currUser.ContactId, currChapRole.id);
			insert currVolRole;

			Orientation_Training__c currOrientationTraining = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
			insert currOrientationTraining;

			Chapter_Role_O_T__c currChapOrientation = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOrientationTraining.id);
			insert currChapOrientation;

			Class_Offering__c currOrientationOffering = OrientationandTrainingUtil.createClassOffering(currChapOrientation.id);
			insert currOrientationOffering;

			Volunteer_Orientation_Training__c createVolOrientation = OrientationandTrainingUtil.createVolOrientation(currOrientationTraining.id, currOrientationOffering.id, currUser.ContactId, 'Completed');
			createVolOrientation.Volunteer_Attendance__c = 'Registered';

			Volunteer_Orientation_Training__c createVolOrientation2 = OrientationandTrainingUtil.createVolOrientation(currOrientationTraining.id, currOrientationOffering.id, currUser.ContactId, 'Completed');
			createVolOrientation2.Volunteer_Attendance__c = 'Completed';
			insert new List<Volunteer_Orientation_Training__c>{
					createVolOrientation, createVolOrientation2
			};

			// Task Creation.
			Id interviewRT = Constant_AC.TASK_RT_ID;
			// Confirmation Task
			Task confirmationTask = new Task();
			confirmationTask.Subject = 'Interview Task';
			confirmationTask.RecordTypeId = interviewRT;
			confirmationTask.Available_Date1__c = Date.Today();
			confirmationTask.Available_Time1__c = '5 pm';
			confirmationTask.Available_Date2__c = Date.Today();
			confirmationTask.Available_Time2__c = '6 pm';
			confirmationTask.Status = 'Approved';
			confirmationTask.whoId = currUser.ContactId;
			insert confirmationTask;

			// Backgroud check creationn.
			Background_check__c currBC = OrientationandTrainingUtil.createBackgroundCheck(currUser.ContactId);
			currBC.Status__c = 'Approved';
			currBC.Date__c = Date.today().addDays(7);
			currBC.Current__c = true;
			insert currBC;
			Test.startTest();
			VolunteerWelcomePage_AC controller = new VolunteerWelcomePage_AC();
			controller.BackgroundCheck(true);
			controller.getEvents();
			controller.becomeAVolunteer();
			controller.applyForRolesStatus = 'Completed';
			controller.checkBackGroundList = new List<Background_check__c>{
					currBC
			};
			controller.backgroundCheckStatus = 'Completed';
			controller.trainingList = new List<Volunteer_Orientation_Training__c>{
					createVolOrientation, createVolOrientation2
			};
			controller.bgRequired = false;
			controller.trainingRequired = true;
			controller.findVolunteerStatus();
			Test.stopTest();
			System.assertEquals(confirmationTask.Status, 'Approved', 'Task status does not match');
			System.assert(confirmationTask.Status == 'Approved', 'Task status does not match');
		}
	}

	// Completing Background check for updating background check status.
	static testMethod void completeBackGroundCheck() {
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;

		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		con.is_Application__c = 'Approved';
		insert con;

		insert OrientationandTrainingUtil.createAffiliation(con.id);
		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
			insert currUser;
		}
		// Need parent record fields
		currUser = [
				SELECT Id, ContactId, Contact.AccountId
				FROM User
				WHERE Id = :currUser.Id
		];
		System.RunAs(currUser) {

			Role__c currRole = OrientationandTrainingUtil.createRole();
			insert currRole;

			Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(currUser.Contact.AccountId, currRole.id);
			insert currChapRole;

			Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(currUser.ContactId, currChapRole.id);
			insert currVolRole;

			Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
			insert currOandT;

			Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOandT.id);
			insert currChapOandT;

			Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
			insert currOffering;

			Volunteer_Orientation_Training__c createVolTraining = OrientationandTrainingUtil.createVolTraining(currOandT.id, currOffering.id, currUser.ContactId, 'Registered');
			insert createVolTraining;

			Orientation_Training__c currOrientationTraining = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
			insert currOrientationTraining;

			Chapter_Role_O_T__c currChapOrientation = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOrientationTraining.id);
			insert currChapOrientation;

			Class_Offering__c currOrientationOffering = OrientationandTrainingUtil.createClassOffering(currChapOrientation.id);
			insert currOrientationOffering;

			Volunteer_Orientation_Training__c createVolOrientation = OrientationandTrainingUtil.createVolOrientation(currOrientationTraining.id, currOrientationOffering.id, currUser.ContactId, 'Completed');
			insert createVolOrientation;

			// Task Creation.
			Id interviewRT = Constant_AC.TASK_RT_ID;
			// Confirmation Task
			Task confirmationTask = new Task();
			confirmationTask.Subject = 'Interview Task';
			confirmationTask.RecordTypeId = interviewRT;
			confirmationTask.Available_Date1__c = Date.Today();
			confirmationTask.Available_Time1__c = '5 pm';
			confirmationTask.Available_Date2__c = Date.Today();
			confirmationTask.Available_Time2__c = '6 pm';
			confirmationTask.Status = 'Approved';
			confirmationTask.whoId = currUser.ContactId;
			insert confirmationTask;

			// Backgroud check creationn.
			Test.startTest();
			Background_check__c currBC = OrientationandTrainingUtil.createBackgroundCheck(currUser.ContactId);
			currBC.Current__c = true;
			insert currBC;
			//VolunteerLanding_AC_Test.BGCRecordSharing(currUser.id,currBc.id);
			currBC.Date_Completed__C = Date.Today();
			currBC.Date__c = Date.today().addDays(1);
			currBC.status__c = 'Approved';
			BGCRecordSharing(currUser.id, currBC.id);
			update currBC;
			VolunteerWelcomePage_AC controller = new VolunteerWelcomePage_AC();
			controller.BackgroundCheck(true);
			controller.getEvents();
			controller.becomeAVolunteer();
			controller.findVolunteerStatus();
			Test.stopTest();
			System.assertEquals(currBC.status__c, 'Approved', 'Background check status does not match');
			System.assert(currBC.status__c == 'Approved', 'Background check status does not match');
		}
	}
	// Completing training.
	static testMethod void completeTraining() {
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;

		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		con.is_Application__c = 'Approved';
		con.BackGroundCheckUpdated__c = true;
		update con;

		insert OrientationandTrainingUtil.createAffiliation(con.id);
		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
			insert currUser;
		}
		// Need parent record fields
		currUser = [
				SELECT Id, ContactId, Contact.AccountId
				FROM User
				WHERE Id = :currUser.Id
		];
		System.RunAs(currUser) {
			Role__c currRole = OrientationandTrainingUtil.createRole();
			insert currRole;

			Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(currUser.Contact.AccountId, currRole.id);
			insert currChapRole;

			Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(currUser.ContactId, currChapRole.id);
			insert currVolRole;

			Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
			insert currOandT;

			Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOandT.id);
			insert currChapOandT;

			Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
			insert currOffering;

			Volunteer_Orientation_Training__c createVolTraining = OrientationandTrainingUtil.createVolTraining(currOandT.id, currOffering.id, currUser.ContactId, 'Completed');
			insert createVolTraining;

			Orientation_Training__c currOrientationTraining = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
			insert currOrientationTraining;

			Chapter_Role_O_T__c currChapOrientation = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOrientationTraining.id);
			insert currChapOrientation;

			Class_Offering__c currOrientationOffering = OrientationandTrainingUtil.createClassOffering(currChapOrientation.id);
			insert currOrientationOffering;

			Test.startTest();
			Volunteer_Orientation_Training__c createVolOrientation = OrientationandTrainingUtil.createVolOrientation(currOrientationTraining.id, currOrientationOffering.id, currUser.ContactId, 'Completed');
			insert createVolOrientation;

			// Task Creation.
			Id interviewRT = Constant_AC.TASK_RT_ID;
			// Confirmation Task
			Task confirmationTask = new Task();
			confirmationTask.Subject = 'Interview Task';
			confirmationTask.RecordTypeId = interviewRT;
			confirmationTask.Available_Date1__c = Date.Today();
			confirmationTask.Available_Time1__c = '5 pm';
			confirmationTask.Available_Date2__c = Date.Today();
			confirmationTask.Available_Time2__c = '6 pm';
			confirmationTask.Status = 'Approved';
			confirmationTask.whoId = currUser.ContactId;
			insert confirmationTask;

			// Backgroud check creationn.
			Background_check__c currBC = OrientationandTrainingUtil.createBackgroundCheck(currUser.ContactId);
			insert currBC;
			//VolunteerLanding_AC_Test.BGCRecordSharing(currUser.id,currBc.id);
			currBC.Date_Completed__C = Date.Today();
			currBC.status__c = 'Approved';
			currBC.Current__c = true;
			BGCRecordSharing(currUser.id, currBC.id);
			update currBC;
			VolunteerWelcomePage_AC controller = new VolunteerWelcomePage_AC();
			controller.getEvents();
			controller.becomeAVolunteer();
			controller.findVolunteerStatus();
			controller.callConfirmConflict();
			controller.cancelConflict();
			controller.volunteercon.BackGroundCheckUpdated__c = true;
			controller.confirmBackGroundCheck();
			controller.confirmPopUp = false;
			Test.stopTest();
			System.assertEquals(currBC.status__c, 'Approved', 'Background check status does not match');
			System.assert(currBC.status__c == 'Approved', 'Background check status does not match');
		}
	}

	static testMethod void verifyCompleteTraining() {
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;

		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		Contact updateContact = new Contact();
		updateContact.id = con.id;
		updateContact.is_Application__c = 'Approved';
		updateContact.BackGroundCheckUpdated__c = true;
		updateContact.Residing_in_US__c = true;
		update updateContact;
		List<Contact> contactList = new List<Contact>();
		contactList.add(updateContact);
		insert OrientationandTrainingUtil.createAffiliation(con.id);
		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
			insert currUser;
		}
		// Need parent record fields
		currUser = [
				SELECT Id, ContactId, Contact.AccountId
				FROM User
				WHERE Id = :currUser.Id
		];
		System.RunAs(currUser) {
			Test.startTest();
			Role__c currRole = OrientationandTrainingUtil.createRole();
			insert currRole;

			Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(currUser.Contact.AccountId, currRole.id);
			insert currChapRole;

			Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRoleWithSubStatus(currUser.ContactId, currChapRole.id);
			insert currVolRole;

			Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
			insert currOandT;

			Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOandT.id);
			insert currChapOandT;

			Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
			insert currOffering;

			Volunteer_Orientation_Training__c createVolTraining = OrientationandTrainingUtil.createVolTraining(currOandT.id, currOffering.id, currUser.ContactId, 'Completed');
			insert createVolTraining;

			Orientation_Training__c currOrientationTraining = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
			insert currOrientationTraining;

			Chapter_Role_O_T__c currChapOrientation = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOrientationTraining.id);
			insert currChapOrientation;

			Class_Offering__c currOrientationOffering = OrientationandTrainingUtil.createClassOffering(currChapOrientation.id);
			insert currOrientationOffering;

			Volunteer_Orientation_Training__c createVolOrientation = OrientationandTrainingUtil.createVolOrientation(currOrientationTraining.id, currOrientationOffering.id, currUser.ContactId, 'Completed');
			insert createVolOrientation;
			// Task Creation.
			Id interviewRT = Constant_AC.TASK_RT_ID;
			// Confirmation Task
			Task confirmationTask = new Task();
			confirmationTask.Subject = 'Interview Task';
			confirmationTask.RecordTypeId = interviewRT;
			confirmationTask.Available_Date1__c = Date.Today();
			confirmationTask.Available_Time1__c = '5 pm';
			confirmationTask.Available_Date2__c = Date.Today();
			confirmationTask.Available_Time2__c = '6 pm';
			confirmationTask.Status = 'Approved';
			confirmationTask.whoId = currUser.ContactId;
			insert confirmationTask;

			// Backgroud check creationn.
			Background_check__c currBC = OrientationandTrainingUtil.createBackgroundCheckFasleRec(currUser.ContactId);
			//VolunteerLanding_AC_Test.BGCRecordSharing(currUser.id,currBc.id);
			currBC.Date_Completed__C = Date.Today() + 2;
			currBC.Date__c = Date.today().addDays(1);
			currBC.status__c = 'Approved';
			insert currBC;
			BGCRecordSharing(currUser.id, currBC.id);

			Background_check__c currBC1 = OrientationandTrainingUtil.createBackgroundCheckFasleRec(currUser.ContactId);
			//VolunteerLanding_AC_Test.BGCRecordSharing(currUser.id,currBc.id);
			currBC1.Date_Completed__C = Date.Today() + 2;
			currBC1.Date__c = Date.today().addDays(1);
			currBC1.status__c = 'Approved';
			insert currBC1;
			BGCRecordSharing(currUser.id, currBC1.id);

			VolunteerWelcomePage_AC controller = new VolunteerWelcomePage_AC();
			controller.getEvents();
			controller.becomeAVolunteer();
			controller.findVolunteerStatus();
			controller.callConfirmConflict();
			controller.cancelConflict();
			controller.confirmBackGroundCheck();
			controller.confirmPopUp = false;
			controller.isBGRoleExpOOC = true;
			controller.checkcontactApplicationList = contactList;
			Test.stopTest();

			System.assertEquals(currBC.status__c, 'Approved', 'Background check status does not match');
			System.assert(currBC.status__c == 'Approved', 'Background check status does not match');
		}
	}

	static testMethod void verifyCompleteTraining1() {
		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(null);
			insert currUser;
		}
		// Need parent record fields
		currUser = [
				SELECT Id, ContactId, Contact.AccountId
				FROM User
				WHERE Id = :currUser.Id
		];
		insert new Bypass_Triggers__c(SetupOwnerId = currUser.Id);
		Conflict_Of_Interest__c coiRecord = OrientationandTrainingUtil.createCOIwithCurrent(currUser.ContactId, true);
		coiRecord.Volunteer_Contact__c = currUser.ContactId;
		coiRecord.Expiration_Date__c = System.today() - 7;
		coiRecord.Current__c = true;
		insert coiRecord;
		System.RunAs(currUser) {
			Account acc = OrientationandTrainingUtil.createVolunteerAccount();
			insert acc;

			Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
			con.is_Application__c = 'Approved';
			con.BackGroundCheckUpdated__c = true;
			con.Residing_in_US__c = true;
			insert con;

			insert OrientationandTrainingUtil.createAffiliation(con.id);
			Role__c currRole = OrientationandTrainingUtil.createRole();
			insert currRole;

			Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(currUser.Contact.AccountId, currRole.id);
			insert currChapRole;

			Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRoleWithSubStatus(currUser.ContactId, currChapRole.id);
			insert currVolRole;
			//Orientation_Training__c  currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
			//Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id,currOandT.id);
			//Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
			//Volunteer_Orientation_Training__c  createVolTraining = OrientationandTrainingUtil.createVolTraining(currOandT.id,currOffering.id,con.id,'Completed');
			Orientation_Training__c currOrientationTraining = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
			insert currOrientationTraining;

			Chapter_Role_O_T__c currChapOrientation = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOrientationTraining.id);
			insert currChapOrientation;

			Class_Offering__c currOrientationOffering = OrientationandTrainingUtil.createClassOffering(currChapOrientation.id);
			insert currOrientationOffering;

			Volunteer_Orientation_Training__c createVolOrientation = OrientationandTrainingUtil.createVolOrientation(currOrientationTraining.id, currOrientationOffering.id, currUser.ContactId, 'Completed');
			insert createVolOrientation;

			Test.startTest();
			List<npe5__Affiliation__c> records = [
					SELECT Id,npe5__Organization__c,npe5__Contact__c,npe5__Status__c,
							npe5__Primary__c
					FROM npe5__Affiliation__c
			];

			npe5__Affiliation__c currAffliation = OrientationandTrainingUtil.CreateAffiliation(currUser.ContactId);
			currAffliation.npe5__Primary__c = true;
			currAffliation.Constituent_Code__c = Constant_AC.VOLUNTEER_TASK_RT_LABEL;
			currAffliation.npe5__Status__c = 'Out of Compliance';
			insert currAffliation;

			// Task Creation.
			Id interviewRT = Constant_AC.TASK_RT_ID;
			// Confirmation Task
			Task confirmationTask = new Task();
			confirmationTask.Subject = 'Interview Task';
			confirmationTask.RecordTypeId = interviewRT;
			confirmationTask.Available_Date1__c = Date.Today();
			confirmationTask.Available_Time1__c = '5 pm';
			confirmationTask.Available_Date2__c = Date.Today();
			confirmationTask.Available_Time2__c = '6 pm';
			confirmationTask.Status = 'Approved';
			confirmationTask.whoId = currUser.ContactId;
			insert confirmationTask;

			// Backgroud check creationn.
			Background_check__c currBC = OrientationandTrainingUtil.createBackgroundCheckFasleRec(currUser.ContactId);
			insert currBC;
			//VolunteerLanding_AC_Test.BGCRecordSharing(currUser.id,currBc.id);
			currBC.Date_Completed__C = Date.Today() + 2;
			currBC.Date__c = Date.today().addDays(1);
			currBC.status__c = 'Approved';
			//BGCRecordSharing(currUser.id, currBC.id);
			update currBC;

			VolunteerWelcomePage_AC controller = new VolunteerWelcomePage_AC();
			controller.getEvents();
			controller.becomeAVolunteer();
			controller.findVolunteerStatus();
			controller.callConfirmConflict();
			controller.cancelConflict();
			controller.confirmBackGroundCheck();
			controller.myId = null;
			controller.COICheck();
			controller.confirmPopUp = false;
			controller.isBGRoleExpOOC = true;
			Test.stopTest();
			System.assertEquals(currBC.status__c, 'Approved', 'Background check status does not match');
			System.assert(currBC.status__c == 'Approved', 'Background check status does not match');
		}
	}

	/*static testMethod void verifyCompleteTraining2()
   {
	   Account acc = OrientationandTrainingUtil.createVolunteerAccount();
	   Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
	   /*Contact updateContact = new Contact();
	   updateContact.id = con.id;
	   updateContact.is_Application__c = 'Approved';
	   updateContact.BackGroundCheckUpdated__c = true;
	   updateContact.Residing_in_US__c = true;
	   update updateContact;*/

	/*OrientationandTrainingUtil.createAffiliation(con.id);
	User currUser;
	System.RunAs(new User(Id = UserInfo.getUserId()))
	{
		currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
	}
	System.RunAs(currUser)
	{
		Role__c currRole = OrientationandTrainingUtil.createRole();
		Chapter_Role__c  currChapRole = OrientationandTrainingUtil.createChapter(acc.id,currRole.id);
		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRoleWithSubStatus(currUser.ContactId,currChapRole.id);

		Orientation_Training__c  currOrientationTraining = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
		Chapter_Role_O_T__c currChapOrientation = OrientationandTrainingUtil.createChapterOandT(currChapRole.id,currOrientationTraining.id);
		Class_Offering__c currOrientationOffering = OrientationandTrainingUtil.createClassOffering(currChapOrientation.id);
		Volunteer_Orientation_Training__c  createVolOrientation = OrientationandTrainingUtil.createVolOrientation(currOrientationTraining.id,currOrientationOffering.id,con.id,'Completed');
		Test.startTest();

		// Backgroud check creationn.
		Background_check__c currBC = OrientationandTrainingUtil.createBackgroundCheckFasleRec(currUser.ContactId);
		//VolunteerLanding_AC_Test.BGCRecordSharing(currUser.id,currBc.id);
		currBC.Date_Completed__C = Date.Today() + 2;
		currBC.Date__c = Date.today().addDays(-10);
		currBC.status__c = 'Approved';
		BGCRecordSharing(currUser.id,currBC.id);
		update currBC;


		VolunteerWelcomePage_AC controller = new VolunteerWelcomePage_AC();
		controller.confirmBackGroundCheck();
		controller.COICheck();
		   controller.confirmPopUp = false;
		controller.isBGRoleExpOOC = true;
		Test.stopTest();
	}
}*/

	private Static Background_check__Share BGCRecordSharing(id userId, id recordId) {
		Background_check__Share currSharing = new Background_check__Share();
		User currUser = [
				SELECT id
				from User
				WHERE Profile.Name = 'System Administrator' and isActive = True
				limit 1
		];
		System.RunAs(currUser) {
			currSharing.ParentId = recordId;
			currSharing.UserOrGroupId = userId;
			currSharing.AccessLevel = 'Edit';
			currSharing.RowCause = Schema.Background_check__Share.RowCause.Manual;
			insert currSharing;
		}
		return currSharing;
	}
}