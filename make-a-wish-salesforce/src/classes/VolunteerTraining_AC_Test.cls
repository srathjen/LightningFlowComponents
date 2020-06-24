//Unit Test for Volunteer Training.
@IsTest
public class VolunteerTraining_AC_Test {

    private static final String VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED;
    private static final String VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED;
    private static final String VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING;

    @TestSetup
    private static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;

        insert new Bypass_Triggers__c(SetupOwnerId = UserInfo.getUserId());
        LMS_Credentials__c currLMSCredential = TestDataFactory.createLMSCredentials();
        insert currLMSCredential;

        Account acc = TestDataFactory.createChapterAccount(1)[0];
        insert acc;

        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.Id;
        insert con;

        User volunteerUser = TestDataFactory.createVolunteerUser(1)[0];
        insert volunteerUser;

        npe5__Affiliation__c affiliation = TestDataFactory.createAffiliation(1)[0];
        affiliation.npe5__Contact__c = con.Id;
        affiliation.npe5__Organization__c = acc.Id;
        insert affiliation;

        Role__c currRole = TestDataFactory.createRole(1, true)[0];
        insert currRole;

        Chapter_Role__c currChapRole = TestDataFactory.createChapterRole(1)[0];
        currChapRole.Chapter_Name__c = acc.Id;
        currChapRole.Role_Name__c = currRole.Id;
        currChapRole.Background_Check_Required__c = true;
        insert currChapRole;

        Volunteer_Roles__c currVolRole = TestDataFactory.createVolunteerRole(1)[0];
        currVolRole.Chapter_Role__c = currChapRole.Id;
        currVolRole.Volunteer_Name__c = con.Id;
        currVolRole.Status__c = Constant_AC.VOLUNTEER_ROLE_STATUS_CHAPTER_REVIEW;
        currVolRole.Volunteer_Name__c = volunteerUser.ContactId;
        insert currVolRole;

        Orientation_Training__c currOandT = TestDataFactory.createOrientationTraining(1)[0];
        currOandT.Name = 'Trainging1';
        currOandT.RecordTypeId = Constant_AC.TRAINING_RT_ID;
        currOandT.Start_Time__c = '7:00 AM';
        currOandT.End_Time__c = '7:00 PM';
        insert currOandT;

        Chapter_Role_O_T__c currChapOandT = TestDataFactory.createChapterRoleOrientationAndTraining(1)[0];
        currChapOandT.Orientation_Training__c = currOandT.Id;
        currChapOandT.Chapter_Role__c = currChapRole.Id;
        currChapOandT.Required__c = true;
        insert currChapOandT;

        Class_Offering__c currOffering = TestDataFactory.createClassOffering(1)[0];
        currOffering.Chapter_Role_O_T__c = currChapOandT.Id;
        currOffering.Date__c = System.today() + 10;
        currOffering.Start_Time__c = '10:00 AM';
        currOffering.End_Time__c = '11:00 AM';
        currOffering.max_capacity__c = 100;
        currOffering.Location__c = 'Test';
        currOffering.RecordTypeId = Constant_AC.CLASS_OFFERING_RECORD_TYPE_ID;
        insert currOffering;

        Volunteer_Orientation_Training__c createVolOrientation = TestDataFactory.createVolunteerOrientationAndTraining(1)[0];
        createVolOrientation.Class_Offering__c = currOffering.Id;
        createVolOrientation.Hidden_O_T_Id__c = currOandT.Id;
        createVolOrientation.Registered_Date__c = Date.today();
        createVolOrientation.Volunteer__c = con.Id;
        createVolOrientation.Volunteer_Attendance__c = VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED;
        createVolOrientation.Type__c = VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING;
        createVolOrientation.Volunteer__c = volunteerUser.ContactId;
        insert createVolOrientation;

        Dynamic_Content__c dc = TestDataFactory.createDynamicContent(1)[0];
        dc.RecordTypeId = Constant_AC.NATIONAL_RT_ID;
        dc.Active__c = true;
        insert dc;

        trac_TriggerHandlerBase.blockTrigger = false;
    }

    // Complete the Volunteer Training.
    @IsTest
    static void CreatingCompletedTraining() {
        Class_Offering__c currOffering = getClassOffering();
        User volunteerUser = getVolunteerUser();
        System.runAs(volunteerUser) {
            Test.startTest();
            PageReference pageRef = Page.VolunteerTraining_VF;
            Test.setCurrentPage(pageRef);

            VolunteerTraining_AC controller = new VolunteerTraining_AC();
            controller.TimingInfo();
            controller.getTrainingRecordList();
            controller.trainingId = currOffering.Id;
            controller.Register();
            Test.stopTest();
        }
    }

    // Creating Training with Cancelled status.
    @IsTest
    static void CreatingCancelledTraining() {
        Class_Offering__c currOffering = getClassOffering();
        Volunteer_Orientation_Training__c createVolOrientation = [
                SELECT Class_Offering__c, Hidden_O_T_Id__c
                FROM Volunteer_Orientation_Training__c
        ];
        System.assertEquals(currOffering.Id, createVolOrientation.Class_Offering__c);

        Test.startTest();
        createVolOrientation.Volunteer_Attendance__c = VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED;
        update createVolOrientation;

        User volunteerUser = getVolunteerUser();
        System.runAs(volunteerUser) {
            PageReference pageRef = Page.VolunteerTraining_VF;
            Test.setCurrentPage(pageRef);

            VolunteerTraining_AC controller = new VolunteerTraining_AC();
            controller.TimingInfo();
            controller.getTrainingRecordList();
            controller.classOfferingMap = new Map<Id, Class_Offering__c>();
            controller.classOfferingMap.put(currOffering.Id, currOffering);
            controller.trainingId = currOffering.Id;
            controller.Register();
            Test.stopTest();
        }
    }

    // Cancel Registered Training.
    @IsTest
    static void CancelTraining() {
        Class_Offering__c currOffering = getClassOffering();
        User volunteerUser = getVolunteerUser();
        System.runAs(volunteerUser) {
            Test.startTest();
            PageReference pageRef = Page.VolunteerTraining_VF;
            Test.setCurrentPage(pageRef);

            VolunteerTraining_AC controller = new VolunteerTraining_AC();
            controller.TimingInfo();
            controller.getTrainingRecordList();
            controller.trainingId = currOffering.Id;
            controller.Cancel();
            Test.stopTest();
        }

    }

    // Duplicate Training time prevention.
    @IsTest
    static void BookingTrainingwithSameTime() {
        Chapter_Role__c currChapRole = [
                SELECT Id
                FROM Chapter_Role__c
        ];

        Orientation_Training__c currOandT1 = TestDataFactory.createOrientationTraining(1)[0];
        currOandT1.Name = 'Trainging1';
        currOandT1.RecordTypeId = Constant_AC.TRAINING_RT_ID;
        currOandT1.Start_Time__c = '7:00 AM';
        currOandT1.End_Time__c = '7:00 PM';
        insert currOandT1;

        Chapter_Role_O_T__c currChapOandT1 = TestDataFactory.createChapterRoleOrientationAndTraining(1)[0];
        currChapOandT1.Orientation_Training__c = currOandT1.Id;
        currChapOandT1.Chapter_Role__c = currChapRole.Id;
        currChapOandT1.Required__c = true;
        insert currChapOandT1;

        Class_Offering__c currOffering1 = TestDataFactory.createClassOffering(1)[0];
        currOffering1.Chapter_Role_O_T__c = currChapOandT1.Id;
        currOffering1.Date__c = System.today() + 10;
        currOffering1.Start_Time__c = '10:00 AM';
        currOffering1.End_Time__c = '11:00 AM';
        currOffering1.max_capacity__c = 100;
        currOffering1.Location__c = 'Test';
        currOffering1.RecordTypeId = Constant_AC.CLASS_OFFERING_RECORD_TYPE_ID;
        insert currOffering1;

        User volunteerUser = getVolunteerUser();
        System.runAs(volunteerUser) {
            PageReference pageRef = Page.VolunteerTraining_VF;
            Test.setCurrentPage(pageRef);
            System.currentPageReference().getParameters().put('bgRequired', 'true');
            System.currentPageReference().getParameters().put('trainingRequired', 'false');
            Test.startTest();
            VolunteerTraining_AC controller = new VolunteerTraining_AC();
            controller.TimingInfo();
            controller.getTrainingRecordList();
            controller.trainingId = currOffering1.Id;
            controller.Register();
            controller.Next();
            controller.Beginning();
            controller.getPageNumber();
            controller.total_size = 1;
            controller.getTotalPages();
            controller.total_size = controller.list_size = 1;
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

    @IsTest
    static void CheckViewLMS() {
        Account acc = TestDataFactory.createChapterAccount(1)[0];
        insert acc;
        Contact con = TestDataFactory.createContact(1)[0];
        insert con;
        LMS_Credentials__c currLMSCredential = TestDataFactory.createLMSCredentials();
        insert currLMSCredential;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Id PROFILE_SYSTEM_ADMIN_ID = [
                    SELECT Id
                    FROM Profile
                    WHERE Name = :Constant_AC.PROFILE_SYSTEM_ADMINISTRATOR
            ].Id;
            List<User> newUsers = TestDataFactory.createUser(2);
            for (User u : newUsers) {
                u.ProfileId = PROFILE_SYSTEM_ADMIN_ID;
            }
            newUsers[0].Username = 'test1234@testorg.com';
            newUsers[1].Username = 'test12345@testorg.com';
            insert newUsers;
        }
        List<User> currUserLst = [
                SELECT Id
                FROM User
                WHERE Id != :UserInfo.getUserId() AND IsActive = TRUE AND Username LIKE '%testorg.com'
        ];
        System.runAs(currUserLst[0]) {
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
        System.runAs(currUserLst[1]) {
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

    private static User getVolunteerUser() {
        String usernameSuffixWildcard = '%' + TestDataFactory.USERNAME_SUFFIX;
        return [
                SELECT Id, ContactId
                FROM User
                WHERE Username LIKE :usernameSuffixWildcard
        ];
    }

    private static Class_Offering__c getClassOffering() {
        return [
                SELECT Id,Name,Chapter__c,Date__c,End_Time__c,Course_ID__c,RecordTypeId,RecordType.Name,
                        Chapter_Role_O_T__c,Chapter_Role_O_T__r.Orientation_Training__r.Name,
                        Location__c,max_capacity__c,Start_Time__c,Type__c,Orientation_and_Training__c,
                        Registered_Seats__c, AvailableSeats__c, Chapter_Role_O_T__r.Orientation_Training__c
                FROM Class_Offering__c
        ];
    }
}