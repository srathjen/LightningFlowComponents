//Unit Test for Volunteer Training.
@IsTest
public class VolunteerTraining_AC_Test {

	@TestSetup
	private static void setup() {
		trac_TriggerHandlerBase.blockTrigger = true;
		insert new Bypass_Triggers__c(SetupOwnerId = UserInfo.getUserId());
		
		LMS_Credentials__c currLMSCredential = TestClassUtil.createLMSCredentials();

		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;

		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;

		User volunteerUser;
		System.runAs(new User(Id = UserInfo.getUserId())) {
			volunteerUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(null);
			insert volunteerUser;
		}

		insert OrientationandTrainingUtil.createAffiliation(con.id);

		Role__c currRole = OrientationandTrainingUtil.createRole();
		insert currRole;

		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.id, currRole.id);
		insert currChapRole;

		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id, currChapRole.id);
		currVolRole.Volunteer_Name__c = volunteerUser.ContactId;
		insert currVolRole;

		Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
		insert currOandT;

		Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOandT.id);
		insert currChapOandT;

		Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
		insert currOffering;

		Volunteer_Orientation_Training__c createVolOrientation = VolunteerTraining_AC_Test.createVolOrientation(currOandT.id, currOffering.id, con.id, 'Completed');
		createVolOrientation.Volunteer__c = volunteerUser.ContactId;
		insert createVolOrientation;
		trac_TriggerHandlerBase.blockTrigger = false;
	}

	// Complete the Volunteer Training.
	static testMethod void CreatingCompletedTraining() {
		Class_Offering__c currOffering = [
				SELECT Id
				FROM Class_Offering__c
		];
		Volunteer_Orientation_Training__c createVolOrientation = [
				SELECT Class_Offering__c
				FROM Volunteer_Orientation_Training__c
		];
		System.assertEquals(currOffering.id, createVolOrientation.class_offering__c);

		User volunteerUser = [
				SELECT Id, ContactId
				FROM User
				WHERE Username = 'joathanedwards@gmail.com'
		];
		System.runAs(volunteerUser) {
			Test.startTest();
			TestClassUtil.createDynamicContent();
			PageReference pageRef = Page.VolunteerTraining_VF;
			Test.setCurrentPage(pageRef);
			VolunteerTraining_AC controller = new VolunteerTraining_AC();
			controller.TimingInfo();
			controller.getTrainingRecordList();
			controller.trainingId = currOffering.id;
			Test.stopTest();
		}
	}

	// Display Class OFfering on Portal.
	static testMethod void VolunteerTrainingDisplay() {
		Class_Offering__c currOffering = [
				SELECT Id
				FROM Class_Offering__c
		];
		Volunteer_Orientation_Training__c createVolOrientation = [
				SELECT Class_Offering__c
				FROM Volunteer_Orientation_Training__c
		];
		System.assertEquals(currOffering.id, createVolOrientation.class_offering__c);

		User volunteerUser = [
				SELECT Id, ContactId
				FROM User
				WHERE Username = 'joathanedwards@gmail.com'
		];
		System.runAs(volunteerUser) {
			Test.startTest();
			TestClassUtil.createDynamicContent();
			PageReference pageRef = Page.VolunteerTraining_VF;
			Test.setCurrentPage(pageRef);

			VolunteerTraining_AC controller = new VolunteerTraining_AC();
			controller.TimingInfo();
			controller.getTrainingRecordList();
			controller.trainingId = currOffering.id;
			controller.Register();
			Test.stopTest();
		}
	}

	// Register for new Training.
	static testMethod void CreateNewTraining() {
		Class_Offering__c currOffering = [
				SELECT Id
				FROM Class_Offering__c
		];
		Volunteer_Orientation_Training__c createVolOrientation = [
				SELECT Class_Offering__c
				FROM Volunteer_Orientation_Training__c
		];
		System.assertEquals(currOffering.id, createVolOrientation.class_offering__c);

		User volunteerUser = [
				SELECT Id, ContactId
				FROM User
				WHERE Username = 'joathanedwards@gmail.com'
		];
		System.runAs(volunteerUser) {
			Test.startTest();
			TestClassUtil.createDynamicContent();
			PageReference pageRef = Page.VolunteerTraining_VF;
			Test.setCurrentPage(pageRef);

			VolunteerTraining_AC controller = new VolunteerTraining_AC();
			controller.TimingInfo();
			controller.getTrainingRecordList();
			controller.trainingId = currOffering.id;
			controller.Register();
			Test.stopTest();
		}
	}

	// Creating Training with Cancelled status.
	static testMethod void CreatingCancelledTraining() {
		Class_Offering__c currOffering = [
				SELECT id,Name,Chapter__c,Date__c,End_Time__c,Course_ID__c,recordtypeid,recordtype.name,
						Chapter_Role_O_T__c,Chapter_Role_O_T__r.Orientation_Training__r.Name,
						Location__c,max_capacity__c,Start_Time__c,Type__c,Orientation_and_Training__c,
						Registered_Seats__c, AvailableSeats__c, Chapter_Role_O_T__r.Orientation_Training__c
				FROM Class_Offering__c
		];
		Volunteer_Orientation_Training__c createVolOrientation = [
				SELECT Class_Offering__c, Hidden_O_T_Id__c
				FROM Volunteer_Orientation_Training__c
		];
		System.assertEquals(currOffering.id, createVolOrientation.class_offering__c);

		Test.startTest();
		createVolOrientation.Volunteer_Attendance__c = 'Volunteer Cancelled';
		update createVolOrientation;

		User volunteerUser = [
				SELECT Id, ContactId
				FROM User
				WHERE Username = 'joathanedwards@gmail.com'
		];
		System.runAs(volunteerUser) {
			TestClassUtil.createDynamicContent();
			PageReference pageRef = Page.VolunteerTraining_VF;
			Test.setCurrentPage(pageRef);

			VolunteerTraining_AC controller = new VolunteerTraining_AC();
			controller.TimingInfo();
			controller.getTrainingRecordList();
			controller.classOfferingMap = new Map<Id, Class_Offering__c>();
			controller.classOfferingMap.put(currOffering.Id, currOffering);
			controller.trainingId = currOffering.id;
			controller.Register();
			Test.stopTest();
		}
	}

	// Cancel Registered Training.
	static testMethod void CancelTraining() {
		Class_Offering__c currOffering = [
				SELECT Id
				FROM Class_Offering__c
		];
		Volunteer_Orientation_Training__c createVolOrientation = [
				SELECT Class_Offering__c
				FROM Volunteer_Orientation_Training__c
		];
		System.assertEquals(currOffering.id, createVolOrientation.class_offering__c);

		User volunteerUser = [
				SELECT Id, ContactId
				FROM User
				WHERE Username = 'joathanedwards@gmail.com'
		];
		System.runAs(volunteerUser) {
			Test.startTest();
			TestClassUtil.createDynamicContent();
			PageReference pageRef = Page.VolunteerTraining_VF;
			Test.setCurrentPage(pageRef);

			VolunteerTraining_AC controller = new VolunteerTraining_AC();
			controller.TimingInfo();
			controller.getTrainingRecordList();
			controller.trainingId = currOffering.id;
			controller.Cancel();
			Test.stopTest();
		}

	}

	// Duplicate Training time prevention.
	static testMethod void BookingTrainingwithSameTime() {
		Class_Offering__c currOffering = [
				SELECT Id
				FROM Class_Offering__c
		];
		Volunteer_Orientation_Training__c createVolOrientation = [
				SELECT Class_Offering__c
				FROM Volunteer_Orientation_Training__c
		];
		Chapter_Role__c currChapRole = [
				SELECT Id
				FROM Chapter_Role__c
		];
		User currUser;

		Orientation_Training__c currOandT1 = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
		insert currOandT1;

		Chapter_Role_O_T__c currChapOandT1 = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOandT1.id);
		insert currChapOandT1;

		Class_Offering__c currOffering1 = OrientationandTrainingUtil.createClassOffering(currChapOandT1.id);
		insert currOffering1;

		User volunteerUser = [
				SELECT Id, ContactId
				FROM User
				WHERE Username = 'joathanedwards@gmail.com'
		];
		System.runAs(volunteerUser) {
			PageReference pageRef = Page.VolunteerTraining_VF;
			Test.setCurrentPage(pageRef);
			System.currentPageReference().getParameters().put('bgRequired', 'true');
			System.currentPageReference().getParameters().put('trainingRequired', 'false');
			Test.startTest();
			TestClassUtil.createDynamicContent();
			VolunteerTraining_AC controller = new VolunteerTraining_AC();
			controller.TimingInfo();
			controller.getTrainingRecordList();
			controller.trainingId = currOffering1.id;
			controller.Register();
			controller.Next();
			controller.Beginning();
			controller.getPageNumber();
			controller.total_size = 1;
			controller.getTotalPages();
			controller.End();
			controller.getDisableNext();
			controller.Beginning();
			controller.Previous();
			controller.getDisablePrevious();
			VolunteerTraining_AC.updateUser('3497181', 'test.prod@mail.com', 'test.prod@mail.com', UserInfo.getUserId());
			Test.stopTest();
		}
	}

	// Creating Volunteer Training for volunteer based on the input parameter.
	static Volunteer_Orientation_Training__c createVolOrientation(Id OrienationId, Id ClassOfferingId, Id volunteer, string status) {
		Volunteer_Orientation_Training__c createNewVol = new Volunteer_Orientation_Training__c();
		createNewVol.class_offering__c = ClassOfferingId;
		createNewVol.Hidden_O_T_Id__c = OrienationId;
		createNewVol.Registered_Date__c = Date.Today();
		createNewVol.Volunteer__c = volunteer;
		createNewVol.Volunteer_Attendance__c = status;
		createNewVol.Type__c = 'Training';
		return createNewVol;
	}

	static testMethod void CheckViewLMS() {
		Account acc;
		Contact con;
		LMS_Credentials__c currLMSCredential;
		User currUser;

		acc = OrientationandTrainingUtil.createVolunteerAccount();
		con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		currLMSCredential = TestClassUtil.createLMSCredentials();
		OrientationandTrainingUtil.createAffiliation(con.id);

		System.RunAs(new User(Id = UserInfo.getUserId())) {
			TestClassUtil.createUser();
			TestClassUtil.createUser();
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
			PageReference pageRef = Page.VolunteerTraining_VF;
			Test.setCurrentPage(pageRef);
			VolunteerTraining_AC controller = new VolunteerTraining_AC();
			controller.lMSCourseId = 'Test';
			controller.viewLMS();
			controller.getLMSSSODetails('1234');
			VolunteerTraining_AC.updateUser('3497181', 'test.prod@mail.com', 'test.prod@mail.com', currUserLst[1].Id);
		}
		Test.stopTest();
	}
}
