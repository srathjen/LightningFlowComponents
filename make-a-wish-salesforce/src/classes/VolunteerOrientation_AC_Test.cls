/*************************************************************************************************************
Author : Mst Solutions
Description : This class is used to increase the code coverage for VolunteerOrientation_AC controller
Modification Log
1. WVC-2205 - Kanagaraj - 08/08/2018 // line - 237,55,99,142,189 Previously the affilliation status 
                                       was "Prospective". Now we have updated as "Pending".
**************************************************************************************************************/

@IsTest
public class VolunteerOrientation_AC_Test {
	@TestSetup
	private static void setup() {
		trac_TriggerHandlerBase.blockTrigger = true;
	}

	static testMethod void coverMisc() {
		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(null);
			insert currUser;
		}

		System.RunAs(currUser) {
			Account acc = OrientationandTrainingUtil.createVolunteerAccount();
			insert acc;
			Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
			insert con;
			OrientationandTrainingUtil.createAffiliation(con.id);
			Role__c currRole = OrientationandTrainingUtil.createRole();
			insert currRole;
			Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.id, currRole.id);
			insert currChapRole;
			Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id, currChapRole.id);
			insert currVolRole;
			Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
			insert currOandT;
			Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOandT.id);
			insert currChapOandT;
			Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
			insert currOffering;

			Volunteer_Orientation_Training__c createVolOrientation = VolunteerOrientation_AC_Test.createVolOrientation(currOandT.id, currOffering.Id, currUser.ContactId, 'Completed');
			createVolOrientation.Volunteer_Attendance__c = 'Registered';

			update createVolOrientation;

			npe5__Affiliation__c neworgAffiliation = new npe5__Affiliation__c ();
			neworgAffiliation.npe5__Contact__c = currUser.ContactId;
			neworgAffiliation.npe5__Organization__c = acc.Id;
			neworgAffiliation.npe5__Primary__c = true;
			neworgAffiliation.npe5__Status__c = 'Pending';
			neworgAffiliation.Constituent_code__c = Constant_AC.BOARD_MEMBER_RT_LABEL;
			insert neworgAffiliation;

			System.assertEquals(currOffering.id, createVolOrientation.class_offering__c);
			TestClassUtil.createDynamicContent();
			PageReference pageRef = Page.VolunteerTraining_VF;
			Test.setCurrentPage(pageRef);
			System.currentPageReference().getParameters().put('bgRequired', 'true');
			System.currentPageReference().getParameters().put('trainingRequired', 'true');
			VolunteerOrientation_AC controller = new VolunteerOrientation_AC();
			controller.TimingInfo();
			controller.getOrientationRecordList();
			controller.classOfferingMap.put(controller.trainingId, currOffering);
			controller.Register();
			controller.trainingId = currOffering.id;
			List<Orientation_Training__c> volunteerRelatedTrainingsList = controller.volunteerTrainingsList;
			Boolean bgTabPermission = controller.bgTabPermission;
			Boolean trainingTabVisible = controller.trainingTabVisible;
		}

		VolunteerOrientation_AC.classOfferingWrapper wrapper = new VolunteerOrientation_AC.classOfferingWrapper();
		wrapper.orientationName = 'x';
		wrapper.chapterName = 'x';
		wrapper.orientationDate = Date.today();
		wrapper.startTime = 'x';
		wrapper.endTime = 'x';
		wrapper.location = 'x';
		wrapper.maxCapacity = 1;
		wrapper.avilableSheets = 1;
		wrapper.recordType = 'x';
		wrapper.status = 'x';
		wrapper.volOppSize = 1;
		wrapper.recordId = 'x';
		wrapper.courseId = 'x';
		wrapper.recordTypeId = 'x';
		wrapper.displayRec = true;

		VolunteerOrientation_AC miscController = new VolunteerOrientation_AC();
		miscController.total_size = 4;
		miscController.list_size = 3;
		miscController.getTotalPages();
		miscController.total_size = 3;
		miscController.getTotalPages();
		miscController.End();
	}

	// Complete the Volunteer Orientation.
	static testMethod void CreatingCompletedOrientation() {
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		OrientationandTrainingUtil.createAffiliation(con.id);
		Role__c currRole = OrientationandTrainingUtil.createRole();
		insert currRole;
		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.id, currRole.id);
		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id, currChapRole.id);
		Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
		insert currOandT;
		Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOandT.id);
		insert currChapOandT;
		Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
		insert currOffering;

		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
		}
		Volunteer_Orientation_Training__c createVolOrientation = VolunteerOrientation_AC_Test.createVolOrientation(currOandT.id, currOffering.Id, currUser.ContactId, 'Completed');

		Volunteer_Orientation_Training__c createVolOrientation2 = VolunteerOrientation_AC_Test.createVolOrientation(currOandT.id, currOffering.Id, currUser.ContactId, 'Completed');
		createVolOrientation2.Type__c = 'Orientation';
		createVolOrientation2.Volunteer_Attendance__c = 'No Show';
		update createVolOrientation2;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			System.assertEquals(currOffering.id, createVolOrientation.class_offering__c);
			TestClassUtil.createDynamicContent();
			PageReference pageRef = Page.VolunteerTraining_VF;
			Test.setCurrentPage(pageRef);
			System.currentPageReference().getParameters().put('bgRequired', 'true');
			System.currentPageReference().getParameters().put('trainingRequired', 'true');
			VolunteerOrientation_AC controller = new VolunteerOrientation_AC();
			controller.TimingInfo();
			controller.getOrientationRecordList();
			controller.trainingId = currOffering.id;
			List<Orientation_Training__c> volunteerRelatedTrainingsList = controller.volunteerTrainingsList;
			Boolean bgTabPermission = controller.bgTabPermission;
			Boolean trainingTabVisible = controller.trainingTabVisible;
		}
	}
	// Display Class OFfering on Portal.
	static testMethod void VolunteerTrainingDisplay() {
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		//OrientationandTrainingUtil.createAffiliation(con.id);

		npe5__Affiliation__c neworgAffiliation = new npe5__Affiliation__c ();
		neworgAffiliation.npe5__Contact__c = con.Id;
		neworgAffiliation.npe5__Organization__c = acc.Id;
		neworgAffiliation.npe5__Primary__c = true;
		neworgAffiliation.npe5__Status__c = 'Pending';
		neworgAffiliation.Constituent_code__c = Constant_AC.BOARD_MEMBER_RT_LABEL;
		insert neworgAffiliation;

		User currUser;
		Role__c currRole = OrientationandTrainingUtil.createRole();
		insert currRole;
		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.id, currRole.id);
		insert currChapRole;
		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id, currChapRole.id);
		insert currVolRole;
		Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
		insert currOandT;
		Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOandT.id);
		insert currChapOandT;
		Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
		insert currOffering;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
			insert currUser;
		}
		Volunteer_Orientation_Training__c createVolOrientation = VolunteerOrientation_AC_Test.createVolOrientation(currOandT.id, currOffering.id, currUser.ContactId, 'Registered');
//		insert createVolOrientation;
		//System.RunAs(new User(Id = UserInfo.getUserId())) {
		System.RunAs(currUser) {

			System.assertEquals(currOffering.id, createVolOrientation.class_offering__c);

			TestClassUtil.createDynamicContent();
			PageReference pageRef = Page.VolunteerOrientation_VF;
			Test.setCurrentPage(pageRef);

			VolunteerOrientation_AC controller = new VolunteerOrientation_AC();
			controller.TimingInfo();
			controller.getOrientationRecordList();
			controller.trainingId = currOffering.id;
			controller.Register();
		}
	}

	// Register for new Orientation.
	static testMethod void CreateNewTraining() {
		LMS_Credentials__c currLMSCredential = testClassUtil.createLMSCredentials();
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		//OrientationandTrainingUtil.createAffiliation(con.id);
		npe5__Affiliation__c neworgAffiliation = new npe5__Affiliation__c ();
		neworgAffiliation.npe5__Contact__c = con.Id;
		neworgAffiliation.npe5__Organization__c = acc.Id;
		neworgAffiliation.npe5__Primary__c = true;
		neworgAffiliation.npe5__Status__c = 'Pending';
		neworgAffiliation.Constituent_code__c = Constant_AC.BOARD_MEMBER_RT_LABEL;
		insert neworgAffiliation;

		Role__c currRole = OrientationandTrainingUtil.createRole();
		insert currRole;
		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.id, currRole.id);
		insert currChapRole;
		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id, currChapRole.id);
		insert currVolRole;
		Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
		insert currOandT;
		Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOandT.id);
		insert currChapOandT;
		Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
		insert currOffering;
		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
		}
		System.RunAs(new User(Id = UserInfo.getUserId())) {

			TestClassUtil.createDynamicContent();
			PageReference pageRef = Page.VolunteerOrientation_VF;
			Test.setCurrentPage(pageRef);
			VolunteerOrientation_AC controller = new VolunteerOrientation_AC();
			controller.TimingInfo();
			controller.getOrientationRecordList();
			controller.trainingId = currOffering.id;
			controller.Register();
			VolunteerOrientation_AC.updateUser('volunteer@gmail.com', '3409379', 'volunteer@gmail.com', currUser.id);
		}
	}

	// Creating Orientation with Cancelled status.
	static testMethod void CreatingCancelledTraining() {
		LMS_Credentials__c currLMSCredential = testClassUtil.createLMSCredentials();
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		//OrientationandTrainingUtil.createAffiliation(con.id);
		npe5__Affiliation__c neworgAffiliation = new npe5__Affiliation__c ();
		neworgAffiliation.npe5__Contact__c = con.Id;
		neworgAffiliation.npe5__Organization__c = acc.Id;
		neworgAffiliation.npe5__Primary__c = true;
		neworgAffiliation.npe5__Status__c = 'Pending';
		neworgAffiliation.Constituent_code__c = Constant_AC.BOARD_MEMBER_RT_LABEL;
		insert neworgAffiliation;

		User currUser;
		Role__c currRole = OrientationandTrainingUtil.createRole();
		insert currRole;
		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.id, currRole.id);
		insert currChapRole;
		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id, currChapRole.id);
		insert currVolRole;
		Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
		insert currOandT;
		Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOandT.id);
		insert currChapOandT;
		Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
		insert currOffering;
		Volunteer_Orientation_Training__c createVolOrientation = VolunteerOrientation_AC_Test.createVolOrientation(currOandT.id, currOffering.id, con.id, 'Volunteer Cancelled');
//        insert createVolOrientation;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
		}

		VolunteerOrientation_AC controller = new VolunteerOrientation_AC();
		System.RunAs(new User(Id = UserInfo.getUserId())) {

			TestClassUtil.createDynamicContent();
			PageReference pageRef = Page.VolunteerOrientation_VF;
			Test.setCurrentPage(pageRef);

			controller.TimingInfo();
			controller.getOrientationRecordList();
			controller.trainingId = currOffering.id;
			VolunteerOrientation_AC.updateUser('volunteer@gmail.com', '3409379', 'volunteer@gmail.com', UserInfo.getUserId());
		}

		//
		// controller.Register();
	}
	// Cancel Registered Orientation.
	static testMethod void CancelTraining() {
		LMS_Credentials__c currLMSCredential = testClassUtil.createLMSCredentials();
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		//OrientationandTrainingUtil.createAffiliation(con.id);
		npe5__Affiliation__c neworgAffiliation = new npe5__Affiliation__c ();
		neworgAffiliation.npe5__Contact__c = con.Id;
		neworgAffiliation.npe5__Organization__c = acc.Id;
		neworgAffiliation.npe5__Primary__c = true;
		neworgAffiliation.npe5__Status__c = 'Pending';
		neworgAffiliation.Constituent_code__c = Constant_AC.BOARD_MEMBER_RT_LABEL;
		insert neworgAffiliation;

		User currUser;
		Role__c currRole = OrientationandTrainingUtil.createRole();
		insert currRole;
		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.id, currRole.id);
		insert currChapRole;
		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id, currChapRole.id);
		insert currVolRole;
		Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
		insert currOandT;
		Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOandT.id);
		insert currChapOandT;
		Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
		insert currOffering;
		Volunteer_Orientation_Training__c createVolOrientation = VolunteerOrientation_AC_Test.createVolOrientation(currOandT.id, currOffering.id, con.id, 'Registered');

		createVolOrientation.Volunteer_Attendance__c = 'Volunteer Cancelled';
		update createVolOrientation;
		Volunteer_Orientation_Training__c createVolOrientation2 = VolunteerOrientation_AC_Test.createVolOrientation(currOandT.id, currOffering.id, con.id, 'Registered');
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
		}
		System.RunAs(new User(Id = UserInfo.getUserId())) {

			TestClassUtil.createDynamicContent();
			PageReference pageRef = Page.VolunteerOrientation_VF;
			Test.setCurrentPage(pageRef);

			VolunteerOrientation_AC controller = new VolunteerOrientation_AC();
			controller.TimingInfo();

			controller.getOrientationRecordList();
			controller.trainingId = currOffering.id;
			controller.Cancel();
			system.assertEquals('Volunteer Cancelled', createVolOrientation.Volunteer_Attendance__c);
			controller.Register();
		}

	}

	// Duplicate Orientation time prevention.
	static testMethod void BookingTrainingwithSameTime() {
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		//OrientationandTrainingUtil.createAffiliation(con.id);
		npe5__Affiliation__c neworgAffiliation = new npe5__Affiliation__c ();
		neworgAffiliation.npe5__Contact__c = con.Id;
		neworgAffiliation.npe5__Organization__c = acc.Id;
		neworgAffiliation.npe5__Primary__c = true;
		neworgAffiliation.npe5__Status__c = 'Pending';
		neworgAffiliation.Constituent_code__c = Constant_AC.BOARD_MEMBER_RT_LABEL;
		insert neworgAffiliation;

		Role__c currRole = OrientationandTrainingUtil.createRole();
		insert currRole;
		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.id, currRole.id);
		insert currChapRole;
		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id, currChapRole.id);
		insert currVolRole;

		Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
		insert currOandT;
		Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOandT.id);
		insert currChapOandT;
		Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
		insert currOffering;
		Volunteer_Orientation_Training__c createVolOrientation = VolunteerOrientation_AC_Test.createVolOrientation(currOandT.id, currOffering.id, con.id, 'Registered');

		Orientation_Training__c currOandT1 = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
		insert currOandT1;
		Chapter_Role_O_T__c currChapOandT1 = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOandT1.id);
		insert currChapOandT1;
		Class_Offering__c currOffering1 = OrientationandTrainingUtil.createClassOffering(currChapOandT1.id);
		insert currOffering1;
		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
		}
		System.RunAs(new User(Id = UserInfo.getUserId())) {

			TestClassUtil.createDynamicContent();
			PageReference pageRef = Page.VolunteerOrientation_VF;
			Test.setCurrentPage(pageRef);

			VolunteerOrientation_AC controller = new VolunteerOrientation_AC();
			controller.TimingInfo();
			controller.userRelatedContactId = con.Id;
			controller.getOrientationRecordList();
			controller.trainingId = currOffering1.id;
			controller.Register();
			controller.Next();
			controller.Beginning();
			controller.getPageNumber();
//                controller.getTotalPages();
//                controller.End();
			controller.getDisableNext();

		}
	}

	// Creating Volunteer Orientation for volunteer based on the input parameter.
	static Volunteer_Orientation_Training__c createVolOrientation(Id OrienationId, Id ClassOfferingId, Id volunteer, string status) {
		Volunteer_Orientation_Training__c createNewVol = new Volunteer_Orientation_Training__c();
		createNewVol.class_offering__c = ClassOfferingId;
		createNewVol.Hidden_O_T_Id__c = OrienationId;
		createNewVol.Registered_Date__c = Date.Today();
		createNewVol.Volunteer__c = volunteer;
		createNewVol.Volunteer_Attendance__c = status;
		createNewVol.Type__c = 'Orientation';
		insert createNewVol;
		return createNewVol;
	}

	static testMethod void CheckViewLMS() {
		Account acc;
		Contact con;
		LMS_Credentials__c currLMSCredential;
		User currUser;
		acc = OrientationandTrainingUtil.createVolunteerAccount();
		con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		currLMSCredential = testClassUtil.createLMSCredentials();
		OrientationandTrainingUtil.createAffiliation(con.id);
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			testClassUtil.createUser();
			//testClassUtil.createUser();
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
			PageReference pageRef = Page.VolunteerOrientation_VF;
			Test.setCurrentPage(pageRef);
			VolunteerOrientation_AC controller = new VolunteerOrientation_AC();
			controller.lMSCourseId = 'Test';
			controller.viewLMS();
			// updateUser();
			controller.Previous();
			controller.getDisablePrevious();
		}
		Test.stopTest();
	}

	static testMethod void CreateNewTrainingWithExistingCancelledRecords() {
		LMS_Credentials__c currLMSCredential = testClassUtil.createLMSCredentials();
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		//OrientationandTrainingUtil.createAffiliation(con.id);
		npe5__Affiliation__c neworgAffiliation = new npe5__Affiliation__c ();
		neworgAffiliation.npe5__Contact__c = con.Id;
		neworgAffiliation.npe5__Organization__c = acc.Id;
		neworgAffiliation.npe5__Primary__c = true;
		neworgAffiliation.npe5__Status__c = 'Pending';
		neworgAffiliation.Constituent_code__c = Constant_AC.BOARD_MEMBER_RT_LABEL;
		insert neworgAffiliation;

		Role__c currRole = OrientationandTrainingUtil.createRole();
		insert currRole;
		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.id, currRole.id);
		insert currChapRole;
		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id, currChapRole.id);
		insert currVolRole;
		Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
		insert currOandT;
		Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOandT.id);
		insert currChapOandT;
		Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
		insert currOffering;

		Volunteer_Orientation_Training__c volunteerOrientationTraining = OrientationandTrainingUtil.createVolTraining(currOandT.Id, currOffering.Id, con.Id, 'Completed');
		insert volunteerOrientationTraining;

		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
		}
		System.RunAs(new User(Id = UserInfo.getUserId())) {

			TestClassUtil.createDynamicContent();
			PageReference pageRef = Page.VolunteerOrientation_VF;
			Test.setCurrentPage(pageRef);
			VolunteerOrientation_AC controller = new VolunteerOrientation_AC();
			controller.TimingInfo();
			controller.getOrientationRecordList();
			controller.trainingId = currOffering.id;
			controller.userRelatedContactId = con.Id;
			controller.classOfferingMap = new Map<Id, Class_Offering__c>();
			controller.classOfferingMap.put(currOffering.id, currOffering);
			controller.Register();
		}
	}

	static testMethod void CreateNewTrainingWithVolunteerCancelledRecords() {
		LMS_Credentials__c currLMSCredential = testClassUtil.createLMSCredentials();
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		npe5__Affiliation__c neworgAffiliation = new npe5__Affiliation__c ();
		neworgAffiliation.npe5__Contact__c = con.Id;
		neworgAffiliation.npe5__Organization__c = acc.Id;
		neworgAffiliation.npe5__Primary__c = true;
		neworgAffiliation.npe5__Status__c = 'Pending';
		neworgAffiliation.Constituent_code__c = Constant_AC.BOARD_MEMBER_RT_LABEL;
		insert neworgAffiliation;

		Role__c currRole = OrientationandTrainingUtil.createRole();
		insert currRole;
		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.id, currRole.id);
		insert currChapRole;
		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id, currChapRole.id);
		insert currVolRole;
		Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
		insert currOandT;
		Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOandT.id);
		currChapOandT.Orientation_Training__r = currOandT;
		insert currChapOandT;
		Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
		insert currOffering;

		Volunteer_Orientation_Training__c volunteerOrientationTraining = OrientationandTrainingUtil.createVolTraining(currOandT.Id, currOffering.Id, con.Id, 'Volunteer Cancelled');
		insert volunteerOrientationTraining;

		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
		}
		System.RunAs(new User(Id = UserInfo.getUserId())) {

			TestClassUtil.createDynamicContent();
			PageReference pageRef = Page.VolunteerOrientation_VF;
			Test.setCurrentPage(pageRef);
			VolunteerOrientation_AC controller = new VolunteerOrientation_AC();
			controller.TimingInfo();
			controller.getOrientationRecordList();
			controller.trainingId = currOffering.id;
			controller.userRelatedContactId = con.Id;
			controller.classOfferingMap = new Map<Id, Class_Offering__c>();
			controller.classOfferingMap.put(currOffering.id, [
					SELECT Id, Chapter_Role_O_T__r.Orientation_Training__c
					FROM Class_Offering__c
					WHERE Id = :currOffering.Id
			]);
			controller.Register();
		}
	}

	/*
	static testMethod void CreateNewTrainingWithCheckForExistingBeforeRecords()
	{
		LMS_Credentials__c currLMSCredential = testClassUtil.createLMSCredentials();
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		npe5__Affiliation__c neworgAffiliation = new npe5__Affiliation__c ();
		neworgAffiliation.npe5__Contact__c  = con.Id;
		neworgAffiliation.npe5__Organization__c = acc.Id;
		neworgAffiliation.npe5__Primary__c = true;
		neworgAffiliation.npe5__Status__c = 'Pending';
		neworgAffiliation.Constituent_code__c = Constant_AC.BOARD_MEMBER_RT_LABEL;
		insert neworgAffiliation;

		Role__c currRole = OrientationandTrainingUtil.createRole();
		insert currRole;
		Chapter_Role__c  currChapRole = OrientationandTrainingUtil.createChapter(acc.id,currRole.id);
		insert currChapRole;
		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id,currChapRole.id);
		insert currVolRole;
		Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
		insert currOandT;
		Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id,currOandT.id);
		currChapOandT.Orientation_Training__r = currOandT;
		insert currChapOandT;
		Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
		insert currOffering;

		Volunteer_Orientation_Training__c volunteerOrientationTraining = OrientationandTrainingUtil.createVolTraining(currOandT.Id, currOffering.Id, con.Id, 'Volunteer Cancelled');
		insert volunteerOrientationTraining;

		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId()))
		{
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
		}
		System.RunAs(new User(Id = UserInfo.getUserId()))
		{

			TestClassUtil.createDynamicContent();
			PageReference pageRef = Page.VolunteerOrientation_VF;
			Test.setCurrentPage(pageRef);
			VolunteerOrientation_AC controller = new VolunteerOrientation_AC();
			controller.TimingInfo();
			controller.getOrientationRecordList();
			controller.trainingId = currOffering.id;
			controller.userRelatedContactId = con.Id;
			controller.classOfferingMap = new Map<Id,Class_Offering__c>();
			controller.classOfferingMap.put(currOffering.id, [SELECT Id, Chapter_Role_O_T__r.Orientation_Training__c FROM Class_Offering__c WHERE Id = :currOffering.Id]);
			controller.Register();
		}
	}
	*/

	@IsTest
	static void testCancelWithOrientationDetails() {
		Account chapterAcc = OrientationandTrainingUtil.createChapterAccount();
		insert chapterAcc;
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		Role__c currRole = OrientationandTrainingUtil.createRole();
		insert currRole;
		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.id, currRole.id);
		insert currChapRole;
		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id, currChapRole.id);
		insert currVolRole;
		Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
		insert currOandT;
		Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOandT.id);
		currChapOandT.Orientation_Training__r = currOandT;
		insert currChapOandT;
		Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
		insert currOffering;

		Volunteer_Orientation_Training__c volunteerOrientationTraining = OrientationandTrainingUtil.createVolTraining(currOandT.Id, currOffering.Id, con.Id, 'Volunteer Cancelled');
		volunteerOrientationTraining.Type__c = 'Orientation';
		insert volunteerOrientationTraining;

		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
		}
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			VolunteerOrientation_AC controller = new VolunteerOrientation_AC();
			controller.trainingId = currOffering.id;
			controller.userRelatedContactId = con.Id;
			controller.lMSCredential = testClassUtil.createLMSCredentials();
			controller.Cancel();
		}
	}

	@IsTest
	static void testCancelWithOrientationDetailsWithoutCredential() {
		Account chapterAcc = OrientationandTrainingUtil.createChapterAccount();
		insert chapterAcc;
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		Role__c currRole = OrientationandTrainingUtil.createRole();
		insert currRole;
		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.id, currRole.id);
		insert currChapRole;
		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id, currChapRole.id);
		insert currVolRole;
		Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
		insert currOandT;
		Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOandT.id);
		currChapOandT.Orientation_Training__r = currOandT;
		insert currChapOandT;
		Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
		insert currOffering;

		Volunteer_Orientation_Training__c volunteerOrientationTraining = OrientationandTrainingUtil.createVolTraining(currOandT.Id, currOffering.Id, con.Id, 'Volunteer Cancelled');
		volunteerOrientationTraining.Type__c = 'Orientation';
		insert volunteerOrientationTraining;

		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
		}
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			VolunteerOrientation_AC controller = new VolunteerOrientation_AC();
			controller.trainingId = currOffering.id;
			controller.userRelatedContactId = con.Id;
			controller.Cancel();
		}
	}
}