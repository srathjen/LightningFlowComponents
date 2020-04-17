/**
 * Author      : MST Solutions
 * Date        : 12/01/2016
 * Description : This class contains test method for CaseFile object
 * Modification Log:
 * 28/03/2018 - Kanagaraj
 **/
@IsTest
public class VolunteerWelcomePage_ACTest {

    @TestSetup
    private static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;
        insert new Bypass_Triggers__c(SetupOwnerId = UserInfo.getUserId());
    }

    // Initializing  constructor.
    @IsTest
    static void testVolunteerWelcomePage() {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        insert acc;

        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.Id);
        insert con;

        insert OrientationandTrainingUtil.createAffiliation(con.Id);

        User currUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.Id);
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
        Dynamic_Content__c createProspectiveDynamicContent = OrientationandTrainingUtil.createProspectiveDynamicContent(acc.Id);
        insert new List<Dynamic_Content__c>{
                createDynamicContent, createProspectiveDynamicContent
        };
        System.runAs(currUser) {

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
	@IsTest
    static void negativeDataforOrientation() {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        insert acc;

        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.Id);
        insert con;
        Contact updateContact = new Contact();
        updateContact.Id = con.Id;
        updateContact.is_Application__c = 'Submit';
        update updateContact;

        User currUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.Id);
            insert currUser;
        }
        // Need parent record fields
        currUser = [
                SELECT Id, ContactId, Contact.AccountId
                FROM User
                WHERE Id = :currUser.Id
        ];
        System.runAs(currUser) {
            Test.startTest();
            Account acc1 = OrientationandTrainingUtil.createVolunteerAccount();
            insert acc1;

            Contact con1 = OrientationandTrainingUtil.createVolunteerContact(acc1.Id);
            insert con1;

            Role__c currRole = OrientationandTrainingUtil.createRole();
            insert currRole;

            Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc1.Id, currRole.Id);
            currChapRole.Background_Check_Required__c = false;
            insert currChapRole;

            npe5__Affiliation__c currAffliation = OrientationandTrainingUtil.CreateAffiliation(con1.Id);
            currAffliation.npe5__Primary__c = true;
            currAffliation.Constituent_Code__c = Constant_AC.VOLUNTEER_TASK_RT_LABEL;
            insert currAffliation;

            Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(currUser.ContactId, currChapRole.Id);
            insert currVolRole;

            Orientation_Training__c currOrientationTraining = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
            insert currOrientationTraining;

            Chapter_Role_O_T__c currChapOrientation = OrientationandTrainingUtil.createChapterOandT(currChapRole.Id, currOrientationTraining.Id);
            Chapter_Role_O_T__c currChapOrientation1 = OrientationandTrainingUtil.createChapterOandT(currChapRole.Id, currOrientationTraining.Id);
            insert new List<Chapter_Role_O_T__c>{
                    currChapOrientation, currChapOrientation1
            };

            Class_Offering__c currOrientationOffering = OrientationandTrainingUtil.createClassOffering(currChapOrientation.Id);
            insert currOrientationOffering;

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
	@IsTest
    static void completeOrientation() {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        insert acc;

        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.Id);
        insert con;
        Contact updateContact = new Contact();
        updateContact.Id = con.Id;
        updateContact.is_Application__c = 'Submit';
        update updateContact;

        System.assertEquals(updateContact.is_Application__c, 'Submit', 'Contact application status does not match');
        System.assert(updateContact.is_Application__c == 'Submit', 'Contact application status does not match');

        insert OrientationandTrainingUtil.createAffiliation(con.Id);

        User currUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.Id);
            insert currUser;
        }
        // Need parent record fields
        currUser = [
                SELECT Id, ContactId, Contact.AccountId
                FROM User
                WHERE Id = :currUser.Id
        ];
        System.runAs(currUser) {

            Role__c currRole = OrientationandTrainingUtil.createRole();
            insert currRole;

            Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(currUser.Contact.AccountId, currRole.Id);
            insert currChapRole;

            Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(currUser.ContactId, currChapRole.Id);
            insert currVolRole;

            Orientation_Training__c currOrientationTraining = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
            insert currOrientationTraining;

            Chapter_Role_O_T__c currChapOrientation = OrientationandTrainingUtil.createChapterOandT(currChapRole.Id, currOrientationTraining.Id);
            insert currChapOrientation;

            Class_Offering__c currOrientationOffering = OrientationandTrainingUtil.createClassOffering(currChapOrientation.Id);
            insert currOrientationOffering;

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
	@IsTest
	static void completeApplication() {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        insert acc;

        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.Id);
        insert con;
        Contact updateContact = new Contact();
        updateContact.Id = con.Id;
        updateContact.is_Application__c = 'Approved';
        update updateContact;

        insert OrientationandTrainingUtil.createAffiliation(con.Id);
        User currUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.Id);
            insert currUser;
        }
        // Need parent record fields
        currUser = [
                SELECT Id, ContactId, Contact.AccountId
                FROM User
                WHERE Id = :currUser.Id
        ];
        System.runAs(currUser) {

            Role__c currRole = OrientationandTrainingUtil.createRole();
            insert currRole;

            Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(currUser.Contact.AccountId, currRole.Id);
            insert currChapRole;

            Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(currUser.ContactId, currChapRole.Id);
            insert currVolRole;

            Orientation_Training__c currOrientationTraining = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
            insert currOrientationTraining;

            Chapter_Role_O_T__c currChapOrientation = OrientationandTrainingUtil.createChapterOandT(currChapRole.Id, currOrientationTraining.Id);
            insert currChapOrientation;

            Class_Offering__c currOrientationOffering = OrientationandTrainingUtil.createClassOffering(currChapOrientation.Id);
            insert currOrientationOffering;

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
	@IsTest
	static void completeInterviewTask() {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        insert acc;

        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.Id);
        insert con;
        Contact updateContact = new Contact();
        updateContact.Id = con.Id;
        updateContact.is_Application__c = 'Approved';
        update updateContact;

        insert OrientationandTrainingUtil.createAffiliation(con.Id);
        User currUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.Id);
            insert currUser;
        }
        // Need parent record fields
        currUser = [
                SELECT Id, ContactId, Contact.AccountId
                FROM User
                WHERE Id = :currUser.Id
        ];
        System.runAs(currUser) {

            Role__c currRole = OrientationandTrainingUtil.createRole();
            insert currRole;

            Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(currUser.Contact.AccountId, currRole.Id);
            insert currChapRole;

            Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(currUser.ContactId, currChapRole.Id);
            insert currVolRole;

            Orientation_Training__c currOrientationTraining = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
            insert currOrientationTraining;

            Chapter_Role_O_T__c currChapOrientation = OrientationandTrainingUtil.createChapterOandT(currChapRole.Id, currOrientationTraining.Id);
            insert currChapOrientation;

            Class_Offering__c currOrientationOffering = OrientationandTrainingUtil.createClassOffering(currChapOrientation.Id);
            insert currOrientationOffering;

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
	@IsTest
	static void createBackGroundCheck() {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        insert acc;

        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.Id);
        insert con;
        Contact updateContact = new Contact();
        updateContact.Id = con.Id;
        updateContact.is_Application__c = 'Approved';
        update updateContact;

        insert OrientationandTrainingUtil.createAffiliation(con.Id);
        User currUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.Id);
            insert currUser;
        }
        // Need parent record fields
        currUser = [
                SELECT Id, ContactId, Contact.AccountId
                FROM User
                WHERE Id = :currUser.Id
        ];
        System.runAs(currUser) {

            Role__c currRole = OrientationandTrainingUtil.createRole();
            insert currRole;

            Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(currUser.Contact.AccountId, currRole.Id);
            insert currChapRole;

            Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(currUser.ContactId, currChapRole.Id);
            insert currVolRole;

            Orientation_Training__c currOrientationTraining = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
            insert currOrientationTraining;

            Chapter_Role_O_T__c currChapOrientation = OrientationandTrainingUtil.createChapterOandT(currChapRole.Id, currOrientationTraining.Id);
            insert currChapOrientation;

            Class_Offering__c currOrientationOffering = OrientationandTrainingUtil.createClassOffering(currChapOrientation.Id);
            insert currOrientationOffering;

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
            controller.bgRequired = false;
            controller.trainingRequired = true;
            controller.findVolunteerStatus();
            Test.stopTest();
            System.assertEquals(confirmationTask.Status, 'Approved', 'Task status does not match');
            System.assert(confirmationTask.Status == 'Approved', 'Task status does not match');
        }
    }

    // Completing Background check for updating background check status.
	@IsTest
	static void completeBackGroundCheck() {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        insert acc;

        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.Id);
        con.is_Application__c = 'Approved';
        insert con;

        insert OrientationandTrainingUtil.createAffiliation(con.Id);
        User currUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.Id);
            insert currUser;
        }
        // Need parent record fields
        currUser = [
                SELECT Id, ContactId, Contact.AccountId
                FROM User
                WHERE Id = :currUser.Id
        ];
        System.runAs(currUser) {

            Role__c currRole = OrientationandTrainingUtil.createRole();
            insert currRole;

            Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(currUser.Contact.AccountId, currRole.Id);
            insert currChapRole;

            Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(currUser.ContactId, currChapRole.Id);
            insert currVolRole;

            Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
            insert currOandT;

            Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.Id, currOandT.Id);
            insert currChapOandT;

            Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.Id);
            insert currOffering;

            Orientation_Training__c currOrientationTraining = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
            insert currOrientationTraining;

            Chapter_Role_O_T__c currChapOrientation = OrientationandTrainingUtil.createChapterOandT(currChapRole.Id, currOrientationTraining.Id);
            insert currChapOrientation;

            Class_Offering__c currOrientationOffering = OrientationandTrainingUtil.createClassOffering(currChapOrientation.Id);
            insert currOrientationOffering;

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
            //VolunteerLanding_AC_Test.BGCRecordSharing(currUser.Id,currBc.Id);
            currBC.Date_Completed__c = Date.Today();
            currBC.Date__c = Date.today().addDays(1);
            currBC.Status__c = 'Approved';
//            BGCRecordSharing(currUser.Id, currBC.Id);
            update currBC;
            VolunteerWelcomePage_AC controller = new VolunteerWelcomePage_AC();
            controller.BackgroundCheck(true);
            controller.getEvents();
            controller.becomeAVolunteer();
            controller.findVolunteerStatus();
            Test.stopTest();
            System.assertEquals(currBC.Status__c, 'Approved', 'Background check status does not match');
            System.assert(currBC.Status__c == 'Approved', 'Background check status does not match');
        }
    }
    // Completing training.
	@IsTest
	static void completeTraining() {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        insert acc;

        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.Id);
        insert con;
        con.is_Application__c = 'Approved';
        con.BackGroundCheckUpdated__c = true;
        update con;

        insert OrientationandTrainingUtil.createAffiliation(con.Id);
        User currUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.Id);
            insert currUser;
        }
        // Need parent record fields
        currUser = [
                SELECT Id, ContactId, Contact.AccountId
                FROM User
                WHERE Id = :currUser.Id
        ];
        System.runAs(currUser) {
            Role__c currRole = OrientationandTrainingUtil.createRole();
            insert currRole;

            Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(currUser.Contact.AccountId, currRole.Id);
            insert currChapRole;

            Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(currUser.ContactId, currChapRole.Id);
            insert currVolRole;

            Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
            insert currOandT;

            Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.Id, currOandT.Id);
            insert currChapOandT;

            Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.Id);
            insert currOffering;

            Orientation_Training__c currOrientationTraining = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
            insert currOrientationTraining;

            Chapter_Role_O_T__c currChapOrientation = OrientationandTrainingUtil.createChapterOandT(currChapRole.Id, currOrientationTraining.Id);
            insert currChapOrientation;

            Class_Offering__c currOrientationOffering = OrientationandTrainingUtil.createClassOffering(currChapOrientation.Id);
            insert currOrientationOffering;

            Test.startTest();

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
            currBC.Date_Completed__c = Date.Today();
            currBC.Status__c = 'Approved';
            currBC.Current__c = true;
//            BGCRecordSharing(currUser.Id, currBC.Id);
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
            System.assertEquals(currBC.Status__c, 'Approved', 'Background check status does not match');
            System.assert(currBC.Status__c == 'Approved', 'Background check status does not match');
        }
    }

	@IsTest
    static void verifyCompleteTraining() {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        insert acc;

        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.Id);
        insert con;
        Contact updateContact = new Contact();
        updateContact.Id = con.Id;
        updateContact.is_Application__c = 'Approved';
        updateContact.BackGroundCheckUpdated__c = true;
        updateContact.Residing_in_US__c = true;
        update updateContact;
        List<Contact> contactList = new List<Contact>();
        contactList.add(updateContact);
        insert OrientationandTrainingUtil.createAffiliation(con.Id);
        User currUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.Id);
            insert currUser;
        }
        // Need parent record fields
        currUser = [
                SELECT Id, ContactId, Contact.AccountId
                FROM User
                WHERE Id = :currUser.Id
        ];
        System.runAs(currUser) {
            Test.startTest();
            Role__c currRole = OrientationandTrainingUtil.createRole();
            insert currRole;

            Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(currUser.Contact.AccountId, currRole.Id);
            insert currChapRole;

            Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRoleWithSubStatus(currUser.ContactId, currChapRole.Id);
            insert currVolRole;

            Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
            insert currOandT;

            Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.Id, currOandT.Id);
            insert currChapOandT;

            Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.Id);
            insert currOffering;

            Orientation_Training__c currOrientationTraining = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
            insert currOrientationTraining;

            Chapter_Role_O_T__c currChapOrientation = OrientationandTrainingUtil.createChapterOandT(currChapRole.Id, currOrientationTraining.Id);
            insert currChapOrientation;

            Class_Offering__c currOrientationOffering = OrientationandTrainingUtil.createClassOffering(currChapOrientation.Id);
            insert currOrientationOffering;

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
            currBC.Date_Completed__c = Date.Today() + 2;
            currBC.Date__c = Date.today().addDays(1);
            currBC.Status__c = 'Approved';
            insert currBC;
//            BGCRecordSharing(currUser.Id, currBC.Id);

            Background_check__c currBC1 = OrientationandTrainingUtil.createBackgroundCheckFasleRec(currUser.ContactId);
            currBC1.Date_Completed__c = Date.Today() + 2;
            currBC1.Date__c = Date.today().addDays(1);
            currBC1.Status__c = 'Approved';
            insert currBC1;
//            BGCRecordSharing(currUser.Id, currBC1.Id);

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

            System.assertEquals(currBC.Status__c, 'Approved', 'Background check status does not match');
            System.assert(currBC.Status__c == 'Approved', 'Background check status does not match');
        }
    }

	@IsTest
    static void verifyCompleteTraining1() {
        User currUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
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
        System.runAs(currUser) {
            Account acc = OrientationandTrainingUtil.createVolunteerAccount();
            insert acc;

            Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.Id);
            con.is_Application__c = 'Approved';
            con.BackGroundCheckUpdated__c = true;
            con.Residing_in_US__c = true;
            insert con;

            insert OrientationandTrainingUtil.createAffiliation(con.Id);
            Role__c currRole = OrientationandTrainingUtil.createRole();
            insert currRole;

            Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(currUser.Contact.AccountId, currRole.Id);
            insert currChapRole;

            Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRoleWithSubStatus(currUser.ContactId, currChapRole.Id);
            insert currVolRole;

            Orientation_Training__c currOrientationTraining = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
            insert currOrientationTraining;

            Chapter_Role_O_T__c currChapOrientation = OrientationandTrainingUtil.createChapterOandT(currChapRole.Id, currOrientationTraining.Id);
            insert currChapOrientation;

            Class_Offering__c currOrientationOffering = OrientationandTrainingUtil.createClassOffering(currChapOrientation.Id);
            insert currOrientationOffering;

            Volunteer_Orientation_Training__c createVolOrientation = OrientationandTrainingUtil.createVolOrientation(currOrientationTraining.Id, currOrientationOffering.Id, currUser.ContactId, 'Completed');
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
            currBC.Date_Completed__c = Date.Today() + 2;
            currBC.Date__c = Date.today().addDays(1);
            currBC.Status__c = 'Approved';
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
            System.assertEquals(currBC.Status__c, 'Approved', 'Background check status does not match');
            System.assert(currBC.Status__c == 'Approved', 'Background check status does not match');
        }
    }

    private static Background_check__Share BGCRecordSharing(id userId, id recordId) {
        Background_check__Share currSharing = new Background_check__Share();
        User currUser = [
                SELECT Id
                FROM User
                WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE
                LIMIT 1
        ];
        System.runAs(currUser) {
            currSharing.ParentId = recordId;
            currSharing.UserOrGroupId = userId;
            currSharing.AccessLevel = Constant_AC.RECORD_SHARE_EDIT;
            currSharing.RowCause = Schema.Background_check__Share.RowCause.Manual;
            insert currSharing;
        }
        return currSharing;
    }
}