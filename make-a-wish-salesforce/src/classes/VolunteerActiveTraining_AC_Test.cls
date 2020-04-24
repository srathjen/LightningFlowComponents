// Unit Test for VolunteerActiveTraining.
@IsTest
public class VolunteerActiveTraining_AC_Test {

	@TestSetup
	private static void setup(){
		insert new Bypass_Triggers__c(SetupOwnerId = UserInfo.getUserId());
	}

	// Complete the Volunteer Training.
	@IsTest
	static void CreatingCompletedTraining() {
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.Id);
		insert con;
		npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(con.Id);
		insert affiliation;
		Role__c currRole = OrientationandTrainingUtil.createRole();
		insert currRole;
		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.Id, currRole.Id);
		insert currChapRole;
		Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
		insert currOandT;
		Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.Id, currOandT.Id);
		insert currChapOandT;
		Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.Id);
		insert currOffering;
		Volunteer_Orientation_Training__c createVolOrientation = OrientationandTrainingUtil.createVolOrientation(currOandT.Id, currOffering.Id, con.Id, 'Completed');
		upsert createVolOrientation;

		User currUser;
		System.runAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.Id);
			insert currUser;
		}
		System.runAs(currUser) {
			System.assertEquals(currOffering.Id, createVolOrientation.Class_Offering__c);
			TestClassUtil.createDynamicContent();
			PageReference pageRef = Page.VolunteerActiveTraining_VF;
			Test.setCurrentPage(pageRef);
			VolunteerActiveTraining_AC controller = new VolunteerActiveTraining_AC();
			controller.TimingInfo();
			controller.getTrainingRecordList();
			controller.trainingId = currOffering.Id;
			controller.No();
			controller.Previous();
			controller.getDisablePrevious();
			controller.total_size = 10;
			controller.End();
			Boolean bgTabPermission = controller.bgTabPermission;
			Boolean trainingTabVisible = controller.trainingTabVisible;
			VolunteerActiveTraining_AC.updateUser('volunteer@gmail.com', '3409379', 'volunteer@gmail.com', currUser.Id);
		}

	}
	// Display Class OFfering on Portal.
	@IsTest
	static void VolunteerTrainingDisplay() {
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.Id);
		insert con;
		npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(con.Id);
		insert affiliation;
		Role__c currRole = OrientationandTrainingUtil.createRole();
		currRole.Name = 'All Roles';
		insert currRole;
		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.Id, currRole.Id);
		insert currChapRole;
		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.Id, currChapRole.Id);
		insert currVolRole;
		Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
		insert currOandT;
		Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.Id, currOandT.Id);
		insert currChapOandT;
		Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.Id);
		insert currOffering;
		Volunteer_Orientation_Training__c createVolOrientation = OrientationandTrainingUtil.createVolOrientation(currOandT.Id, currOffering.Id, con.Id, 'Registered');
		createVolOrientation.Type__c = 'Training';
		insert createVolOrientation;

		User currUser;
		System.runAs(new User(Id = UserInfo.getUserId(), ContactId = con.Id)) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.Id);
			insert currUser;
		}
		System.runAs(currUser) {
			System.assertEquals(currOffering.Id, createVolOrientation.Class_Offering__c);

			TestClassUtil.createDynamicContent();
			PageReference pageRef = Page.VolunteerActiveTraining_VF;
			Test.setCurrentPage(pageRef);

			VolunteerActiveTraining_AC controller = new VolunteerActiveTraining_AC();
			controller.TimingInfo();
			controller.getTrainingRecordList();
			controller.trainingId = currOffering.Id;
			controller.Register();
			VolunteerActiveTraining_AC.updateUser('volunteer@gmail.com', '3409379', 'volunteer@gmail.com', '0055B0000011r12');
		}
	}
	// Register for new Training.
	@IsTest
	static void CreateNewTraining() {
		LMS_Credentials__c currLMSCredential = TestClassUtil.createLMSCredentials();
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.Id);
		insert con;
		npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(con.Id);
		insert affiliation;
		Role__c currRole = OrientationandTrainingUtil.createRole();
		insert currRole;
		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.Id, currRole.Id);
		insert currChapRole;
		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.Id, currChapRole.Id);
		Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
		insert currOandT;
		Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.Id, currOandT.Id);
		insert currChapOandT;
		Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.Id);
		insert currOffering;

		User currUser;
		System.runAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.Id);
			insert currUser;
		}
		System.runAs(currUser) {

			TestClassUtil.createDynamicContent();
			PageReference pageRef = Page.VolunteerTraining_VF;
			Test.setCurrentPage(pageRef);

			VolunteerActiveTraining_AC controller = new VolunteerActiveTraining_AC();
			controller.TimingInfo();
			controller.getTrainingRecordList();
			controller.trainingId = currOffering.Id;
			controller.Register();
		}
	}
	// Creating Training with Cancelled status.
	@IsTest
	static void CreatingCancelledTraining() {
		LMS_Credentials__c currLMSCredential = TestClassUtil.createLMSCredentials();
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.Id);
		insert con;
		npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(con.Id);
		insert affiliation;
		User currUser;
		Role__c currRole = OrientationandTrainingUtil.createRole();
		insert currRole;
		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.Id, currRole.Id);
		insert currChapRole;
		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.Id, currChapRole.Id);
		Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
		insert currOandT;
		Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.Id, currOandT.Id);
		insert currChapOandT;
		Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.Id);
		insert currOffering;

		System.runAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.Id);
			insert currUser;
		}
		VolunteerActiveTraining_AC controller = new VolunteerActiveTraining_AC();

		TestClassUtil.createDynamicContent();
		PageReference pageRef = Page.VolunteerActiveTraining_VF;
		Test.setCurrentPage(pageRef);
		controller.TimingInfo();
		controller.getTrainingRecordList();
		controller.trainingId = currOffering.Id;
		//  controller.Register();
	}
	// Cancel Registered Training.
	@IsTest
	static void CancelTraining() {
		LMS_Credentials__c currLMSCredential = TestClassUtil.createLMSCredentials();
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.Id);
		insert con;
		npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(con.Id);
		insert affiliation;
		User currUser;
		Role__c currRole = OrientationandTrainingUtil.createRole();
		insert currRole;
		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.Id, currRole.Id);
		insert currChapRole;
		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.Id, currChapRole.Id);
		insert currVolRole;
		Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
		insert currOandT;
		Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.Id, currOandT.Id);
		insert currChapOandT;
		Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.Id);
		insert currOffering;

		List<Volunteer_Orientation_Training__c> abc = [
				SELECT Id,LMS_Enrollment_Id__c,Class_Offering__c, Volunteer__c, Class_Offering__r.Chapter__c, Type__c
				from Volunteer_Orientation_Training__c
		];
		System.runAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createAdminUser();
			insert currUser;
		}
		Volunteer_Orientation_Training__c VolOrientation = createVolOrientation(currUser.ContactId, currOffering.Id, con.Id, 'Registered');

		insert VolOrientation;
		System.runAs(currUser) {

			TestClassUtil.createDynamicContent();
			PageReference pageRef = Page.VolunteerActiveTraining_VF;
			Test.setCurrentPage(pageRef);

			VolunteerActiveTraining_AC controller = new VolunteerActiveTraining_AC();
			controller.TimingInfo();
			controller.getTrainingRecordList();
			controller.trainingId = currOffering.Id;
			controller.Cancel();
		}
	}

	// Duplicate Training time prevention.
	@IsTest
	static void BookingTrainingwithSameTime() {
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.Id);
		insert con;
		npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(con.Id);
		insert affiliation;
		User currUser;
		Role__c currRole = OrientationandTrainingUtil.createRole();
		insert currRole;
		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.Id, currRole.Id);
		insert currChapRole;
		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.Id, currChapRole.Id);

		Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
		insert currOandT;
		Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.Id, currOandT.Id);
		insert currChapOandT;
		Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.Id);
		insert currOffering;

		Orientation_Training__c currOandT1 = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
		insert currOandT1;
		Chapter_Role_O_T__c currChapOandT1 = OrientationandTrainingUtil.createChapterOandT(currChapRole.Id, currOandT1.Id);
		insert currChapOandT1;
		Class_Offering__c currOffering1 = OrientationandTrainingUtil.createClassOffering(currChapOandT1.Id);
		insert currOffering1;

		System.runAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.Id);
			insert currUser;
		}
		System.runAs(currUser) {
			TestClassUtil.createDynamicContent();
			PageReference pageRef = Page.VolunteerActiveTraining_VF;
			Test.setCurrentPage(pageRef);

			VolunteerActiveTraining_AC controller = new VolunteerActiveTraining_AC();
			controller.TimingInfo();
			controller.getTrainingRecordList();
			controller.trainingId = currOffering1.Id;
			controller.Register();
			controller.Next();
			controller.Beginning();
			controller.getPageNumber();
			controller.getTotalPages();
			controller.getDisableNext();
		}
	}
	// Creating Volunteer Training for volunteer based on the input parameter.
	public static Volunteer_Orientation_Training__c createVolOrientation(Id OrienationId, Id ClassOfferingId, Id volunteer, string status) {
		Volunteer_Orientation_Training__c createNewVol = new Volunteer_Orientation_Training__c();
		createNewVol.Class_Offering__c = ClassOfferingId;
		createNewVol.Hidden_O_T_Id__c = OrienationId;
		createNewVol.Registered_Date__c = Date.today();
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

		acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		con = OrientationandTrainingUtil.createVolunteerContact(acc.Id);
		insert con;
		currLMSCredential = TestClassUtil.createLMSCredentials();
		npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(con.Id);
		insert affiliation;

		System.runAs(new User(Id = UserInfo.getUserId())) {
			TestClassUtil.createUser();
			TestClassUtil.createUser();
		}
		List<User> currUserLst = [
				SELECT ID
				FROM USER
				WHERE ID != :Userinfo.getUserId() AND isActive = True
		];
		System.runAs(currUserLst[0]) {

			LMSCourseSyncMockImpl currLMSCourseSyncMockImpl = new LMSCourseSyncMockImpl();
			HttpResponse response = new HttpResponse();
			response.setStatus('OK');
			response.setStatusCode(200);
			LMSUserResponse currLMSUserResponse = new LMSUserResponse();
			currLMSUserResponse.Id = 1234;
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
		System.runAs(currUserLst[1]) {
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
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.Id);
		insert con;

		User currUser;
		System.runAs(new User(Id = UserInfo.getUserId(), ContactId = con.Id)) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.Id);
			insert currUser;
		}

		npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(con.Id);
		insert affiliation;
		Role__c currRole = OrientationandTrainingUtil.createRole();
		currRole.Name = 'All Roles';
		insert currRole;
		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.Id, currRole.Id);
		insert currChapRole;
		currChapRole.Background_Check_Required__c = false;
		update currChapRole;
		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(currUser.ContactId, currChapRole.Id);
		insert currVolRole;

		Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
		Orientation_Training__c currOandT1 = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
		currOandT.RecordTypeId = currOandT1.RecordTypeId = Constant_AC.TRAINING_RT_ID;
		insert new List<Orientation_Training__c>{
				currOandT, currOandT1
		};
		Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.Id, currOandT.Id);
		Chapter_Role_O_T__c currChapOandT1 = OrientationandTrainingUtil.createChapterOandT(currChapRole.Id, currOandT1.Id);
		insert new List<Chapter_Role_O_T__c>{
				currChapOandT, currChapOandT1
		};
		Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.Id);
		Class_Offering__c currOffering1 = OrientationandTrainingUtil.createClassOffering(currChapOandT1.Id);
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

		System.runAs(currUser) {
			Background_check__c bkgCheck = OrientationandTrainingUtil.createBackgroundCheck(currUser.ContactId);
			bkgCheck.Status__c = 'Approved';
			bkgCheck.Date__c = System.today().addDays(3);
			bkgCheck.Current__c = true;
			bkgCheck.Volunteer__c = currUser.ContactId;
			insert bkgCheck;
			TestClassUtil.createDynamicContent();
			PageReference pageRef = Page.VolunteerActiveTraining_VF;
			Test.setCurrentPage(pageRef);

			VolunteerActiveTraining_AC controller = new VolunteerActiveTraining_AC();
			controller.TimingInfo();
			controller.getTrainingRecordList();
			controller.trainingId = currOffering.Id;
			controller.Register();
			controller.trainingId = currOffering1.Id;
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
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.Id);
		insert con;
		npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(con.Id);
		insert affiliation;
		User currUser;
		Role__c currRole = OrientationandTrainingUtil.createRole();
		insert currRole;
		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.Id, currRole.Id);
		insert currChapRole;
		currChapRole.Background_Check_Required__c = false;
		update currChapRole;
		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.Id, currChapRole.Id);

		Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
		insert currOandT;
		Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.Id, currOandT.Id);
		insert currChapOandT;
		Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.Id);
		insert currOffering;

		Orientation_Training__c currOandT1 = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
		insert currOandT1;
		Chapter_Role_O_T__c currChapOandT1 = OrientationandTrainingUtil.createChapterOandT(currChapRole.Id, currOandT1.Id);
		insert currChapOandT1;
		Class_Offering__c currOffering1 = OrientationandTrainingUtil.createClassOffering(currChapOandT1.Id);
		insert currOffering1;

		System.runAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.Id);
			insert currUser;
		}
		System.runAs(currUser) {

			TestClassUtil.createDynamicContent();
			PageReference pageRef = Page.VolunteerActiveTraining_VF;
			Test.setCurrentPage(pageRef);

			VolunteerActiveTraining_AC controller = new VolunteerActiveTraining_AC();
			controller.TimingInfo();
			controller.getTrainingRecordList();
			controller.trainingId = currOffering1.Id;
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