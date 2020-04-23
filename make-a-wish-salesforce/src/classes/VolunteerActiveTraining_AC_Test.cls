// Unit Test for VolunteerActiveTraining.

@isTest
Public class VolunteerActiveTraining_AC_Test {

	// Complete the Volunteer Training.
	@IsTest
	static void CreatingCompletedTraining() {
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(con.id);
		insert affiliation;
		Role__c currRole = OrientationandTrainingUtil.createRole();
		insert currRole;
		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.id, currRole.id);
		insert currChapRole;
		Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
		insert currOandT;
		Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOandT.id);
		insert currChapOandT;
		Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
		insert currOffering;
		Volunteer_Orientation_Training__c createVolOrientation = OrientationandTrainingUtil.createVolOrientation(currOandT.id, currOffering.id, con.id, 'Completed');
		upsert createVolOrientation;

		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
			insert currUser;
		}
		System.RunAs(currUser) {
			System.assertEquals(currOffering.id, createVolOrientation.class_offering__c);
			TestClassUtil.createDynamicContent();
			PageReference pageRef = Page.VolunteerActiveTraining_VF;
			Test.setCurrentPage(pageRef);
			VolunteerActiveTraining_AC controller = new VolunteerActiveTraining_AC();
			controller.TimingInfo();
			controller.getTrainingRecordList();
			controller.trainingId = currOffering.id;
			controller.No();
			controller.Previous();
			controller.getDisablePrevious();
			controller.total_size = 10;
			controller.End();
			boolean bgTabPermission = controller.bgTabPermission;
			boolean trainingTabVisible = controller.trainingTabVisible;
			VolunteerActiveTraining_AC.updateUser('volunteer@gmail.com', '3409379', 'volunteer@gmail.com', currUser.id);
		}

	}
	// Display Class OFfering on Portal.
	@IsTest
	static void VolunteerTrainingDisplay() {
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(con.id);
		insert affiliation;
		Role__c currRole = OrientationandTrainingUtil.createRole();
		currRole.Name = 'All Roles';
		insert currRole;
		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.id, currRole.id);
		insert currChapRole;
		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id, currChapRole.id);
		insert currVolRole;
		Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
		insert currOandT;
		Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOandT.id);
		insert currChapOandT;
		Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
		insert currOffering;
		Volunteer_Orientation_Training__c createVolOrientation = OrientationandTrainingUtil.createVolOrientation(currOandT.id, currOffering.id, con.id, 'Registered');
		createVolOrientation.Type__c = 'Training';
		insert createVolOrientation;

		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId(), ContactId = con.id)) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
			insert currUser;
		}
		System.RunAs(currUser) {
			System.assertEquals(currOffering.id, createVolOrientation.class_offering__c);

			TestClassUtil.createDynamicContent();
			PageReference pageRef = Page.VolunteerActiveTraining_VF;
			Test.setCurrentPage(pageRef);

			VolunteerActiveTraining_AC controller = new VolunteerActiveTraining_AC();
			controller.TimingInfo();
			controller.getTrainingRecordList();
			controller.trainingId = currOffering.id;
			controller.Register();
			VolunteerActiveTraining_AC.updateUser('volunteer@gmail.com', '3409379', 'volunteer@gmail.com', '0055B0000011r12');
		}
	}
	// Register for new Training.
	@IsTest
	static void CreateNewTraining() {
		LMS_Credentials__c currLMSCredential = testClassUtil.createLMSCredentials();
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(con.id);
		insert affiliation;
		Role__c currRole = OrientationandTrainingUtil.createRole();
		insert currRole;
		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.id, currRole.id);
		insert currChapRole;
		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id, currChapRole.id);
		Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
		insert currOandT;
		Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOandT.id);
		insert currChapOandT;
		Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
		insert currOffering;

		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
			insert currUser;
		}
		System.RunAs(currUser) {

			TestClassUtil.createDynamicContent();
			PageReference pageRef = Page.VolunteerTraining_VF;
			Test.setCurrentPage(pageRef);

			VolunteerActiveTraining_AC controller = new VolunteerActiveTraining_AC();
			controller.TimingInfo();
			controller.getTrainingRecordList();
			controller.trainingId = currOffering.id;
			controller.Register();
		}
	}
	// Creating Training with Cancelled status.
	@IsTest
	static void CreatingCancelledTraining() {
		LMS_Credentials__c currLMSCredential = testClassUtil.createLMSCredentials();
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(con.id);
		insert affiliation;
		User currUser;
		Role__c currRole = OrientationandTrainingUtil.createRole();
		insert currRole;
		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.id, currRole.id);
		insert currChapRole;
		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id, currChapRole.id);
		Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
		insert currOandT;
		Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOandT.id);
		insert currChapOandT;
		Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
		insert currOffering;

		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
			insert currUser;
		}
		VolunteerActiveTraining_AC controller = new VolunteerActiveTraining_AC();

		TestClassUtil.createDynamicContent();
		PageReference pageRef = Page.VolunteerActiveTraining_VF;
		Test.setCurrentPage(pageRef);
		controller.TimingInfo();
		controller.getTrainingRecordList();
		controller.trainingId = currOffering.id;
		//  controller.Register();
	}
	// Cancel Registered Training.
	@IsTest
	static void CancelTraining() {
		LMS_Credentials__c currLMSCredential = testClassUtil.createLMSCredentials();
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(con.id);
		insert affiliation;
		User currUser;
		Role__c currRole = OrientationandTrainingUtil.createRole();
		insert currRole;
		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.id, currRole.id);
		insert currChapRole;
		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id, currChapRole.id);
		insert currVolRole;
		Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
		insert currOandT;
		Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOandT.id);
		insert currChapOandT;
		Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
		insert currOffering;

		List<Volunteer_Orientation_Training__c> abc = [
				SELECT Id,LMS_Enrollment_Id__c,Class_Offering__c, Volunteer__c, Class_Offering__r.Chapter__c, Type__c
				from Volunteer_Orientation_Training__c
		];
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createAdminUser();
//			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
			insert currUser;
		}
		Volunteer_Orientation_Training__c VolOrientation = createVolOrientation(currUser.ContactId, currOffering.Id, con.Id, 'Registered');

		insert VolOrientation;
		System.RunAs(currUser) {

			TestClassUtil.createDynamicContent();
			PageReference pageRef = Page.VolunteerActiveTraining_VF;
			Test.setCurrentPage(pageRef);

			VolunteerActiveTraining_AC controller = new VolunteerActiveTraining_AC();
			controller.TimingInfo();
			controller.getTrainingRecordList();
			controller.trainingId = currOffering.id;
			controller.Cancel();
		}
	}

	// Duplicate Training time prevention.
	@IsTest
	static void BookingTrainingwithSameTime() {
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(con.id);
		insert affiliation;
		User currUser;
		Role__c currRole = OrientationandTrainingUtil.createRole();
		insert currRole;
		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.id, currRole.id);
		insert currChapRole;
		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id, currChapRole.id);

		Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
		insert currOandT;
		Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOandT.id);
		insert currChapOandT;
		Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
		insert currOffering;

		Orientation_Training__c currOandT1 = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
		insert currOandT1;
		Chapter_Role_O_T__c currChapOandT1 = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOandT1.id);
		insert currChapOandT1;
		Class_Offering__c currOffering1 = OrientationandTrainingUtil.createClassOffering(currChapOandT1.id);
		insert currOffering1;

		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
			insert currUser;
		}
		System.RunAs(currUser) {

			TestClassUtil.createDynamicContent();
			PageReference pageRef = Page.VolunteerActiveTraining_VF;
			Test.setCurrentPage(pageRef);

			VolunteerActiveTraining_AC controller = new VolunteerActiveTraining_AC();
			controller.TimingInfo();
			controller.getTrainingRecordList();
			controller.trainingId = currOffering1.id;
			controller.Register();
			controller.Next();
			controller.Beginning();
			controller.getPageNumber();
			controller.getTotalPages();
//			controller.End();
			controller.getDisableNext();

		}
	}
	// Creating Volunteer Training for volunteer based on the input parameter.
	public static Volunteer_Orientation_Training__c createVolOrientation(Id OrienationId, Id ClassOfferingId, Id volunteer, string status) {
		Volunteer_Orientation_Training__c createNewVol = new Volunteer_Orientation_Training__c();
		createNewVol.class_offering__c = ClassOfferingId;
		createNewVol.Hidden_O_T_Id__c = OrienationId;
		createNewVol.Registered_Date__c = Date.Today();
		createNewVol.Volunteer__c = volunteer;
		createNewVol.Volunteer_Attendance__c = status;
		createNewVol.Type__c = 'Training';
		return createNewVol;
	}

	@IsTest
	static void CheckViewLMS() {
		Account acc;
		Contact con;
		LMS_Credentials__c currLMSCredential;
		User currUser;

		acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		currLMSCredential = testClassUtil.createLMSCredentials();
		npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(con.id);
		insert affiliation;

		System.RunAs(new User(Id = UserInfo.getUserId())) {
			testClassUtil.createUser();
			testClassUtil.createUser();
		}
		List<User> currUserLst = [
				SELECT ID
				FROM USER
				WHERE ID != :Userinfo.getUserId() AND isActive = True
		];
		System.RunAs(currUserLst[0]) {

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
		System.RunAs(currUserLst[1]) {
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
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;

		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId(), ContactId = con.id)) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
			insert currUser;
		}

		npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(con.id);
		insert affiliation;
		Role__c currRole = OrientationandTrainingUtil.createRole();
		currRole.Name = 'All Roles';
		insert currRole;
		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.id, currRole.id);
		insert currChapRole;
		currChapRole.Background_Check_Required__c = false;
		update currChapRole;
		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(currUser.ContactId, currChapRole.id);
		insert currVolRole;

		Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
		Orientation_Training__c currOandT1 = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
		currOandT.RecordTypeId = currOandT1.RecordTypeId = Constant_AC.TRAINING_RT_ID;
		insert new List<Orientation_Training__c>{
				currOandT, currOandT1
		};
		Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOandT.id);
		Chapter_Role_O_T__c currChapOandT1 = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOandT1.id);
		insert new List<Chapter_Role_O_T__c>{
				currChapOandT, currChapOandT1
		};
		Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
		Class_Offering__c currOffering1 = OrientationandTrainingUtil.createClassOffering(currChapOandT1.id);
		insert new List<Class_Offering__c>{
				currOffering, currOffering1
		};

		Test.startTest();
		Volunteer_Orientation_Training__c VolOrientation = createVolOrientation(currUser.ContactId, currOffering.Id, currUser.ContactId, 'Registered');
		VolOrientation.Volunteer_Attendance__c = 'Completed';
		VolOrientation.Hidden_O_T_Id__c = currOandT.Id;

		Volunteer_Orientation_Training__c VolOrientation2 = createVolOrientation(currUser.ContactId, currOffering1.Id, currUser.ContactId, 'Registered');
		VolOrientation.Volunteer_Attendance__c = 'Volunteer Cancelled';
		VolOrientation.Hidden_O_T_Id__c = currOandT.Id;
		insert new List<Volunteer_Orientation_Training__c>{
				VolOrientation, VolOrientation2
		};

		System.RunAs(currUser) {
			Background_check__c bkgCheck = OrientationandTrainingUtil.createBackgroundCheck(currUser.ContactId);
			bkgCheck.Status__c = 'Approved';
			bkgCheck.Date__c = System.Today().addDays(3);
			bkgCheck.Current__c = true;
			bkgCheck.Volunteer__c = currUser.ContactId;
			insert bkgCheck;
			TestClassUtil.createDynamicContent();
			PageReference pageRef = Page.VolunteerActiveTraining_VF;
			Test.setCurrentPage(pageRef);

			VolunteerActiveTraining_AC controller = new VolunteerActiveTraining_AC();
			controller.TimingInfo();
			controller.getTrainingRecordList();
			controller.trainingId = currOffering.id;
			controller.Register();
			controller.trainingId = currOffering1.id;
			controller.Register();
			controller.Next();
			controller.Beginning();
			controller.getPageNumber();
			controller.getTotalPages();
//			controller.End();
			controller.getDisableNext();
		}
		Test.stopTest();
	}

	@IsTest
	static void register_test2() {
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(con.id);
		insert affiliation;
		User currUser;
		Role__c currRole = OrientationandTrainingUtil.createRole();
		insert currRole;
		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.id, currRole.id);
		insert currChapRole;
		currChapRole.Background_Check_Required__c = false;
		update currChapRole;
		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id, currChapRole.id);

		Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
		insert currOandT;
		Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOandT.id);
		insert currChapOandT;
		Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
		insert currOffering;

		Orientation_Training__c currOandT1 = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
		insert currOandT1;
		Chapter_Role_O_T__c currChapOandT1 = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOandT1.id);
		insert currChapOandT1;
		Class_Offering__c currOffering1 = OrientationandTrainingUtil.createClassOffering(currChapOandT1.id);
		insert currOffering1;

		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
			insert currUser;
		}
		System.RunAs(currUser) {

			TestClassUtil.createDynamicContent();
			PageReference pageRef = Page.VolunteerActiveTraining_VF;
			Test.setCurrentPage(pageRef);

			VolunteerActiveTraining_AC controller = new VolunteerActiveTraining_AC();
			controller.TimingInfo();
			controller.getTrainingRecordList();
			controller.trainingId = currOffering1.id;
			controller.Register();
			controller.Next();
			controller.Beginning();
			controller.getPageNumber();
			controller.getTotalPages();
//			controller.End();
			controller.getDisableNext();

		}
	}
}