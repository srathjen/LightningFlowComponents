/**
 * @description     Test class for VolunteerWelcomePage_AC
 * @author          MST Solutions
 * @createdDate     2016-12-01
 */
@IsTest
public class VolunteerWelcomePage_ACTest {
    @TestSetup
    private static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;
        insert new Bypass_Triggers__c(SetupOwnerId = UserInfo.getUserId());

        List<Account> accounts = TestDataFactory.createChapterAccount(1);
        insert accounts;

        List<Contact> contacts = TestDataFactory.createContact(1);
        contacts[0].RecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
        contacts[0].AccountId = accounts[0].Id;
        contacts[0].FirstName = 'Testy';
        contacts[0].LastName = 'McTest';
        insert contacts;

        List<User> users = TestDataFactory.createVolunteerUser(1, 'Active Volunteer (Login)', 'Manager');
        users[0].Username = 'active@volunteer.wish.org.test';
        List<User> users2 = TestDataFactory.createVolunteerUser(1, 'Prospective Volunteer (Login)', 'Manager');
        users2[0].Username = 'prospective@volunteer.wish.org.test';
        users.addAll(users2);
        insert users;

        List<npe5__Affiliation__c> affiliations = TestDataFactory.createAffiliation(3);

        affiliations[0].npe5__Contact__c = contacts[0].Id;
        affiliations[0].npe5__Organization__c = accounts[0].Id;
        affiliations[0].npe5__Primary__c = true;
        affiliations[0].npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_PENDING;
        affiliations[0].Constituent_Code__c = Constant_AC.BOARD_MEMBER_RT_LABEL;

        affiliations[1].npe5__Contact__c = contacts[0].Id;
        affiliations[1].npe5__Organization__c = accounts[0].Id;
        affiliations[1].npe5__Primary__c = true;
        affiliations[1].npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_PENDING;
        affiliations[1].Constituent_Code__c = Constant_AC.VOLUNTEER_TASK_RT_LABEL;

        affiliations[2].npe5__Contact__c = users2[0].ContactId;
        affiliations[2].npe5__Organization__c = accounts[0].Id;
        affiliations[2].npe5__Primary__c = true;
        affiliations[2].npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
        affiliations[2].Constituent_Code__c = Constant_AC.VOLUNTEER_TASK_RT_LABEL;

        insert affiliations;

        List<npe5__Affiliation__c> foo = [SELECT npe5__Primary__c FROM npe5__Affiliation__c];
        System.debug(foo);

        List<Role__c> roles = TestDataFactory.createRole(1, true);
        roles[0].Name = Constant_AC.ROLE_WISH_GRANTER;
        insert roles;

        List<Chapter_Role__c> chapterRoles = TestDataFactory.createChapterRole(1);
        chapterRoles[0].Chapter_Name__c = accounts[0].Id;
        chapterRoles[0].Role_Name__c = roles[0].Id;
        chapterRoles[0].Background_Check_Required__c = true;
        insert chapterRoles;

        List<Volunteer_Roles__c> volunteerRoles = TestDataFactory.createVolunteerRole(1);
        volunteerRoles[0].Chapter_Role__c = chapterRoles[0].Id;
        volunteerRoles[0].Volunteer_Name__c = contacts[0].Id;
        volunteerRoles[0].Status__c = Constant_AC.VOLUNTEER_ROLE_STATUS_CHAPTER_REVIEW;
        //volunteerRoles[0].Sub_status__c = Constant_AC.VOLUNTEER_ROLE_SUB_STATUS_UNDER_CHAPTER_REVIEW;
        insert volunteerRoles;

        List<Orientation_Training__c> orientationTrainings = TestDataFactory.createOrientationTraining(2);

        orientationTrainings[0].Name = 'Orientation1';
        orientationTrainings[0].RecordTypeId = Constant_AC.ORIENTATION_RT_ID;
        orientationTrainings[0].Start_Time__c = '7:00 AM';
        orientationTrainings[0].End_Time__c = '7:00 PM';

        orientationTrainings[1].Name = 'Training1';
        orientationTrainings[1].RecordTypeId = Constant_AC.TRAINING_RT_ID;
        orientationTrainings[1].Start_Time__c = '7:00 AM';
        orientationTrainings[1].End_Time__c = '7:00 PM';

        insert orientationTrainings;


        List<Chapter_Role_O_T__c> chapterRoleOrientationAndTrainings =
            TestDataFactory.createChapterRoleOrientationAndTraining(2);

        chapterRoleOrientationAndTrainings[0].Orientation_Training__c = orientationTrainings[0].Id;
        chapterRoleOrientationAndTrainings[0].Chapter_Role__c = chapterRoles[0].Id;
        chapterRoleOrientationAndTrainings[0].Required__c = true;

        chapterRoleOrientationAndTrainings[1].Orientation_Training__c = orientationTrainings[1].Id;
        chapterRoleOrientationAndTrainings[1].Chapter_Role__c = chapterRoles[0].Id;
        chapterRoleOrientationAndTrainings[1].Required__c = true;

        insert chapterRoleOrientationAndTrainings;

        List<Class_Offering__c> classOfferings = TestDataFactory.createClassOffering(2);

        classOfferings[0].Chapter_Role_O_T__c = chapterRoleOrientationAndTrainings[0].Id;
        classOfferings[0].Date__c = System.today() + 10;
        classOfferings[0].Start_Time__c = '10:00 AM';
        classOfferings[0].End_Time__c = '11:00 AM';
        classOfferings[0].max_capacity__c = 100;
        classOfferings[0].Location__c = 'Test';
        classOfferings[0].RecordTypeId = Constant_AC.CLASS_OFFERING_RECORD_TYPE_ID;

        classOfferings[1].Chapter_Role_O_T__c = chapterRoleOrientationAndTrainings[1].Id;
        classOfferings[1].Date__c = System.today() + 10;
        classOfferings[1].Start_Time__c = '10:00 AM';
        classOfferings[1].End_Time__c = '11:00 AM';
        classOfferings[1].max_capacity__c = 100;
        classOfferings[1].Location__c = 'Test';
        classOfferings[1].RecordTypeId = Constant_AC.CLASS_OFFERING_RECORD_TYPE_ID;

        insert classOfferings;

        List<Task> tasks = TestDataFactory.createTask(1);
        tasks[0].Subject = Constant_AC.TASK_SUBJECT_INTERVIEW_TASK;
        tasks[0].RecordTypeId = Constant_AC.TASK_RT_ID;
        tasks[0].Available_Date1__c = Date.today();
        tasks[0].Available_Time1__c = '5 pm';
        tasks[0].Available_Date2__c = Date.today();
        tasks[0].Available_Time2__c = '6 pm';
        tasks[0].Status = Constant_AC.TASK_STATUS_APPROVED;
        tasks[0].WhoId = users[0].ContactId;
        insert tasks;
    }

    @IsTest
    static void testVolunteerWelcomePage() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Chapter0' LIMIT 1];
        User currUser = [SELECT Id, ContactId, CreatedDate, ProfileId FROM User WHERE Username = 'active@volunteer.wish.org.test'];

        List<Dynamic_Content__c> dynamicContents = TestDataFactory.createDynamicContent(2);

        dynamicContents[0].RecordTypeId = Constant_AC.NATIONAL_RT_ID;
        dynamicContents[0].Sign_Up_Page__c = 'Hai';
        dynamicContents[0].Application_Overview__c = 'Test';
        dynamicContents[0] .Active__c = true;
        dynamicContents[0].Interview_Additional_Info__c = 'Test';
        dynamicContents[0].Orientation_Add_l_Info__c = 'Test';
        dynamicContents[0].Sign_Up_Page__c = 'Test';
        dynamicContents[0].Training_Additional_Info__c = 'Test';
        dynamicContents[0].Welcome_Message__c = 'Test';
        dynamicContents[0].WelcomePage__c = 'Test';
        dynamicContents[0].Welcome_Text__c = 'Test';
        dynamicContents[0].Why_Need_Background_Check__c = 'Test';

        dynamicContents[1].RecordTypeId = Constant_AC.PROSPECTIVE_VOLUNTEER_RT_ID;
        dynamicContents[1].Chapter_Name__c = acc.Id;
        dynamicContents[1].How_do_I_Become_a_Volunteer__c = 'Test';

        insert dynamicContents;

        VolunteerWelcomePage_AC controller;

        Test.startTest();
        System.runAs(currUser) {
            Utils.currentUser = null;
            controller = new VolunteerWelcomePage_AC();
            controller.becomeAVolunteer();
            controller.findVolunteerStatus();
        }
        Test.stopTest();

        System.assert(controller.isBecomVolunteer, 'Controller attribute `isBecomVolunteer` should be true.');
        System.assert(controller.continueProcess, 'Controller attribute `continueProcess` should be true.');
    }

    @IsTest
    static void testCompletedVolunteerOrientation() {
        User currUser = [SELECT Id, ContactId, CreatedDate, ProfileId, Contact.AccountId FROM User WHERE Username = 'prospective@volunteer.wish.org.test'];
        Contact contact = [SELECT Id, is_Application__c FROM Contact WHERE Name = 'Testy McTest'];
        Class_Offering__c classOffering = [SELECT Id FROM Class_Offering__c WHERE Chapter_Role_O_T__r.Orientation_Training__r.Name = 'Orientation1'];

        List<Volunteer_Orientation_Training__c> volunteerOrientationTrainings = TestDataFactory.createVolunteerOrientationAndTraining(1);
        volunteerOrientationTrainings[0].Class_Offering__c = classOffering.Id;
        volunteerOrientationTrainings[0].Volunteer__c = currUser.ContactId;
        volunteerOrientationTrainings[0].Volunteer_Attendance__c = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED;
        volunteerOrientationTrainings[0].Completion_Status__c = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_APPROVED;
        insert volunteerOrientationTrainings;

        VolunteerWelcomePage_AC controller;

        Test.startTest();
        System.runAs(currUser) {
            controller = new VolunteerWelcomePage_AC();
            controller.findVolunteerStatus();
        }
        Test.stopTest();

        System.assertEquals('In Progress', controller.orientationStatus, 'Controller attribute `orientationStatus` has unexpected value.');
    }

    @IsTest
    static void negativeDataforOrientation() {
        Account account = [SELECT Id FROM Account WHERE Name = 'Chapter0' LIMIT 1];
        User currUser = [SELECT Id, ContactId, CreatedDate, ProfileId, Contact.AccountId FROM User WHERE Username = 'active@volunteer.wish.org.test'];

        Contact contact = [SELECT Id, is_Application__c FROM Contact WHERE Name = 'Testy McTest'];
        contact.is_Application__c = Constant_AC.CONTACT_IS_APPLICATION_SUBMIT;
        update contact;

        Non_Wish_Events__c newEvent;
        List<Non_Wish_Events__c> eventList = new List<Non_Wish_Events__c>();
        for (Integer i = 1; i < 4; i++) {
            newEvent = new Non_Wish_Events__c();
            newEvent.Event_Name__c = 'Send Off';
            newEvent.Event_Date__c = System.today() + 5;
            newEvent.Event_Text__c = 'Sending Wish Child';
            newEvent.Priority__c = String.valueOf(i);
            newEvent.Chapter__c = currUser.Contact.AccountId;
            newEvent.RecordTypeId = Constant_AC.EVENTS_ID;
            eventList.add(newEvent);
        }
        newEvent = new Non_Wish_Events__c();
        newEvent.Event_Name__c = 'Send Off';
        newEvent.Event_Date__c = System.today() + 5;
        newEvent.Event_Text__c = 'Sending Wish Child';
        newEvent.RecordTypeId = Constant_AC.EVENTS_ID;
        newEvent.Chapter__c = currUser.Contact.AccountId;
        eventList.add(newEvent);

        Test.startTest();
        System.runAs(currUser) {
            insert eventList;

            VolunteerWelcomePage_AC controller = new VolunteerWelcomePage_AC();
            controller.getEvents();
            controller.becomeAVolunteer();
            controller.findVolunteerStatus();
            controller.COICheck();
        }
        Test.stopTest();

        System.assertEquals(newEvent.Event_Name__c, 'Send Off', 'Event name does not match');
        System.assert(newEvent.Event_Name__c == 'Send Off', 'Event name does not match');
    }

    @IsTest
    static void completeOrientation() {
        User currUser = [SELECT Id, ContactId, CreatedDate, ProfileId, Contact.AccountId FROM User WHERE Username = 'active@volunteer.wish.org.test'];
        Contact contact = [SELECT Id, is_Application__c FROM Contact WHERE Name = 'Testy McTest'];

        VolunteerWelcomePage_AC controller;

        Test.startTest();
        System.runAs(currUser) {
            controller = new VolunteerWelcomePage_AC();

            controller.getEvents();
            controller.becomeAVolunteer();
            controller.completedVolunteerOrientationIdsIds.add(contact.Id);
            controller.requiredOrientationIds.add(contact.Id);
            controller.orientationStatus = VolunteerWelcomePage_AC.PAGE_STATUS_COMPLETED;
            controller.checkcontactApplicationList = new List<Contact>{
                contact
            };
            controller.findVolunteerStatus();
        }
        Test.stopTest();

        System.assertEquals(VolunteerWelcomePage_AC.PAGE_STATUS_COMPLETED, controller.orientationStatus);
    }

    @IsTest
    static void completeApplication() {
        User currUser = [SELECT Id, ContactId, CreatedDate, ProfileId, Contact.AccountId FROM User WHERE Username = 'active@volunteer.wish.org.test'];

        Contact contact = [SELECT Id, is_Application__c FROM Contact WHERE Name = 'Testy McTest'];
        contact.is_Application__c = Constant_AC.CONTACT_IS_APPLICATION_APPROVED;
        update contact;

        Test.startTest();
        System.runAs(currUser) {
            VolunteerWelcomePage_AC controller = new VolunteerWelcomePage_AC();
            controller.getEvents();
            controller.becomeAVolunteer();
            controller.completedVolunteerOrientationIdsIds.add(contact.Id);
            controller.orientationStatus = VolunteerWelcomePage_AC.PAGE_STATUS_COMPLETED;
            controller.checkcontactApplicationList = new List<Contact>{
                contact
            };
            controller.findVolunteerStatus();
        }
        Test.stopTest();

        System.assertEquals(contact.is_Application__c, Constant_AC.CONTACT_IS_APPLICATION_APPROVED, 'Contact application status does not match');
    }

    @IsTest
    static void completeInterviewTask() {
        User currUser = [SELECT Id, ContactId, CreatedDate, ProfileId, Contact.AccountId FROM User WHERE Username = 'active@volunteer.wish.org.test'];
        Task confirmationTask = [SELECT Id, Status FROM Task WHERE WhoId = :currUser.ContactId];

        Contact contact = [SELECT Id, is_Application__c FROM Contact WHERE Name = 'Testy McTest'];
        contact.is_Application__c = Constant_AC.CONTACT_IS_APPLICATION_APPROVED;
        update contact;

        Test.startTest();
        System.runAs(currUser) {
            VolunteerWelcomePage_AC controller = new VolunteerWelcomePage_AC();
            controller.getEvents();
            controller.becomeAVolunteer();
            controller.findVolunteerStatus();
        }
        Test.stopTest();

        System.assertEquals(confirmationTask.Status, Constant_AC.CONTACT_IS_APPLICATION_APPROVED, 'Task status does not match');
        System.assert(confirmationTask.Status == Constant_AC.CONTACT_IS_APPLICATION_APPROVED, 'Task status does not match');
    }

    @IsTest
    static void createBackGroundCheck() {
        User currUser = [SELECT Id, ContactId, CreatedDate, ProfileId, Contact.AccountId FROM User WHERE Username = 'active@volunteer.wish.org.test'];
        Task confirmationTask = [SELECT Id, Status FROM Task WHERE WhoId = :currUser.ContactId];

        Contact contact = [SELECT Id, is_Application__c FROM Contact WHERE Name = 'Testy McTest'];
        contact.is_Application__c = Constant_AC.CONTACT_IS_APPLICATION_APPROVED;
        update contact;

        List<Background_check__c> backgroundChecks = TestDataFactory.createBackgroundCheck(1);
        backgroundChecks[0].Status__c = Constant_AC.BACKGROUND_CHECK_STATUS_APPROVED;
        backgroundChecks[0].Date__c = Date.today().addDays(7);
        backgroundChecks[0].Current__c = true;
        backgroundChecks[0].OwnerId = currUser.Id;
        backgroundChecks[0].Volunteer__c = currUser.ContactId;
        backgroundChecks[0].Date_Completed__c = Date.today().addDays(7);
        insert backgroundChecks;

        Test.startTest();
        System.runAs(currUser) {
            VolunteerWelcomePage_AC controller = new VolunteerWelcomePage_AC();
            controller.isBGRoleExpOOC = true;
            controller.backgroundCheck();
            controller.getEvents();
            controller.becomeAVolunteer();
            controller.applyForRolesStatus = VolunteerWelcomePage_AC.PAGE_STATUS_COMPLETED;
            controller.checkBackGroundList = backgroundChecks;
            controller.backgroundCheckStatus = VolunteerWelcomePage_AC.PAGE_STATUS_COMPLETED;
            controller.bgRequired = false;
            controller.trainingRequired = true;
            controller.findVolunteerStatus();
        }
        Test.stopTest();

        System.assertEquals(confirmationTask.Status, Constant_AC.CONTACT_IS_APPLICATION_APPROVED, 'Task status does not match');
        System.assert(confirmationTask.Status == Constant_AC.CONTACT_IS_APPLICATION_APPROVED, 'Task status does not match');
    }

    @IsTest
    static void completeBackGroundCheck() {
        User currUser = [SELECT Id, ContactId, CreatedDate, ProfileId, Contact.AccountId FROM User WHERE Username = 'active@volunteer.wish.org.test'];

        List<Background_check__c> backgroundChecks = TestDataFactory.createBackgroundCheck(1);
        backgroundChecks[0].Current__c = true;

        Test.startTest();
        System.runAs(currUser) {
            insert backgroundChecks;

            backgroundChecks[0].Date_Completed__c = Date.today();
            backgroundChecks[0].Date__c = Date.today().addDays(1);
            backgroundChecks[0].Status__c = Constant_AC.BACKGROUND_CHECK_STATUS_APPROVED;

            update backgroundChecks;

            VolunteerWelcomePage_AC controller = new VolunteerWelcomePage_AC();
            controller.backgroundCheck();
            controller.getEvents();
            controller.becomeAVolunteer();
            controller.findVolunteerStatus();
        }
        Test.stopTest();

        System.assertEquals(backgroundChecks[0].Status__c, Constant_AC.BACKGROUND_CHECK_STATUS_APPROVED, 'Background check status does not match');
    }

    @IsTest
    static void completeTraining() {
        User currUser = [SELECT Id, ContactId, CreatedDate, ProfileId, Contact.AccountId FROM User WHERE Username = 'active@volunteer.wish.org.test'];
        List<Background_check__c> backgroundChecks = TestDataFactory.createBackgroundCheck(1);

        Test.startTest();
        System.runAs(currUser) {
            insert backgroundChecks;

            backgroundChecks[0].Date_Completed__c = Date.today();
            backgroundChecks[0].Status__c = Constant_AC.BACKGROUND_CHECK_STATUS_APPROVED;
            backgroundChecks[0].Current__c = true;

            update backgroundChecks;

            Utils.currentUser = null;
            VolunteerWelcomePage_AC controller = new VolunteerWelcomePage_AC();
            controller.getEvents();
            controller.becomeAVolunteer();
            controller.findVolunteerStatus();
            controller.callConfirmConflict();
            controller.cancelConflict();
            controller.volunteercon.BackGroundCheckUpdated__c = true;
            controller.confirmBackGroundCheck();
            controller.confirmPopup = false;
        }
        Test.stopTest();

        System.assertEquals(backgroundChecks[0].Status__c, Constant_AC.BACKGROUND_CHECK_STATUS_APPROVED, 'Background check status does not match');
    }

    @IsTest
    static void verifyCompleteTraining() {
        User currUser = [SELECT Id, ContactId, CreatedDate, ProfileId, Contact.AccountId FROM User WHERE Username = 'active@volunteer.wish.org.test'];

        Contact contact = [SELECT Id, is_Application__c FROM Contact WHERE Name = 'Testy McTest'];
        contact.is_Application__c = Constant_AC.CONTACT_IS_APPLICATION_APPROVED;
        contact.BackGroundCheckUpdated__c = true;
        contact.Residing_in_US__c = true;
        update contact;

        List<Background_check__c> backgroundChecks = TestDataFactory.createBackgroundCheck(2);

        backgroundChecks[0].Date__c = System.today() + 3;
        backgroundChecks[0].Volunteer__c = currUser.ContactId;
        backgroundChecks[0].Date_Completed__c = System.today() + 3;
        backgroundChecks[0].Status__c = Constant_AC.BACKGROUND_CHECK_STATUS_MANUAL;
        backgroundChecks[0].Current__c = false;

        backgroundChecks[1].Date__c = System.today() + 3;
        backgroundChecks[1].Volunteer__c = currUser.ContactId;
        backgroundChecks[1].Date_Completed__c = System.today() + 3;
        backgroundChecks[1].Status__c = Constant_AC.BACKGROUND_CHECK_STATUS_MANUAL;
        backgroundChecks[1].Current__c = false;

        Test.startTest();
        System.runAs(currUser) {
            insert backgroundChecks[0];
            insert backgroundChecks[1];

            Utils.currentUser = null;
            VolunteerWelcomePage_AC controller = new VolunteerWelcomePage_AC();
            controller.getEvents();
            controller.becomeAVolunteer();
            controller.findVolunteerStatus();
            controller.callConfirmConflict();
            controller.cancelConflict();
            controller.confirmBackGroundCheck();
            controller.confirmPopup = false;
            controller.isBGRoleExpOOC = true;
            controller.checkcontactApplicationList = new List<Contact>{contact};
        }
        Test.stopTest();
    }

    @IsTest
    static void testVolunteerOandTRecordExists() {
        User currUser = [SELECT Id, ContactId, CreatedDate, ProfileId, Contact.AccountId FROM User WHERE Username = 'active@volunteer.wish.org.test'];
        Contact contact = [SELECT Id, is_Application__c FROM Contact WHERE Name = 'Testy McTest'];
        Class_Offering__c classOffering = [SELECT Id FROM Class_Offering__c WHERE Chapter_Role_O_T__r.Orientation_Training__r.Name = 'Training1'];

        List<Volunteer_Orientation_Training__c> volunteerOrientationTrainings = TestDataFactory.createVolunteerOrientationAndTraining(1);
        volunteerOrientationTrainings[0].Class_Offering__c = classOffering.Id;
        volunteerOrientationTrainings[0].Volunteer__c = currUser.ContactId;
        volunteerOrientationTrainings[0].Volunteer_Attendance__c = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED;
        insert volunteerOrientationTrainings;

        VolunteerWelcomePage_AC controller;

        Test.startTest();
        System.runAs(currUser) {
            controller = new VolunteerWelcomePage_AC();
        }
        Test.stopTest();

        System.assert(!controller.trainingList.isEmpty(), 'Controller attribute `trainingList` should be set.');
    }

    @IsTest
    static void testFindVolunteerStatusGotoPage() {
        User currUser = [SELECT Id, ContactId, CreatedDate, ProfileId, Contact.AccountId FROM User WHERE Username = 'prospective@volunteer.wish.org.test'];
        Id otcId = [SELECT Id FROM Orientation_Training__c LIMIT 1].Id;
        Class_Offering__c classOffering = [SELECT Id FROM Class_Offering__c WHERE Chapter_Role_O_T__r.Orientation_Training__r.Name = 'Orientation1'];

        List<Volunteer_Orientation_Training__c> volunteerOrientationTrainings = TestDataFactory.createVolunteerOrientationAndTraining(1);
        volunteerOrientationTrainings[0].Class_Offering__c = classOffering.Id;
        volunteerOrientationTrainings[0].Volunteer__c = currUser.ContactId;
        volunteerOrientationTrainings[0].Volunteer_Attendance__c = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED;
        volunteerOrientationTrainings[0].Completion_Status__c = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_APPROVED;
        insert volunteerOrientationTrainings;

        List<Background_check__c> backgroundChecks = TestDataFactory.createBackgroundCheck(1);
        backgroundChecks[0].Status__c = '';
        insert backgroundChecks;

        VolunteerWelcomePage_AC controller;
        List<String> gotoPages = new String[6];

        Test.startTest();
        System.runAs(currUser) {
            controller = new VolunteerWelcomePage_AC();

            controller.requiredOrientationIds = new Set<Id>{otcId};
            controller.completedVolunteerOrientationIdsIds = new Set<Id>{otcId};
            controller.findVolunteerStatus();
            gotoPages.add(0, controller.gotoPage);

            controller.completedVolunteerOrientationIdsIds = new Set<Id>();
            controller.findVolunteerStatus();
            gotoPages.add(1, controller.gotoPage);

            controller.checkBackGroundList = backgroundChecks;
            controller.findVolunteerStatus();
            gotoPages.add(2, controller.gotoPage);

            controller.checkBackGroundList[0].Status__c = Constant_AC.BACKGROUND_CHECK_STATUS_APPROVED;
            controller.trainingList = volunteerOrientationTrainings;
            controller.findVolunteerStatus();
            gotoPages.add(3, controller.gotoPage);
        }
        Test.stopTest();

        System.assertEquals(VolunteerWelcomePage_AC.GO_TO_PAGE_VOLUNTEER_TRAINING, gotoPages[0]);
        System.assertEquals(VolunteerWelcomePage_AC.GO_TO_PAGE_VOLUNTEER_ORIENTATION, gotoPages[1]);
        System.assertEquals(VolunteerWelcomePage_AC.GO_TO_PAGE_VOLUNTEER_ORIENTATION, gotoPages[2]);
        System.assertEquals(VolunteerWelcomePage_AC.GO_TO_PAGE_VOLUNTEER_ORIENTATION, gotoPages[3]);
    }

    @IsTest
    static void testCOICheckExpired() {
        User currUser = [SELECT Id, ContactId, CreatedDate, ProfileId, Contact.AccountId FROM User WHERE Username = 'prospective@volunteer.wish.org.test'];
        Contact contact = [SELECT OwnerId FROM Contact WHERE Name = 'Testy McTest'];
        Account account = [SELECT OwnerId FROM Account WHERE Name = 'Chapter0' LIMIT 1];

        contact.OwnerId = currUser.Id;
        account.OwnerId = currUser.Id;
        update contact;
        update account;

        List<Conflict_Of_Interest__c> coi = TestDataFactory.createConflictOfInterest(1);
        coi[0].Volunteer_Contact__c = currUser.ContactId;
        coi[0].Expiration_Date__c = Date.today().addDays(-3);
        coi[0].Current__c = true;
        coi[0].OwnerId = currUser.Id;
        insert coi;

        VolunteerWelcomePage_AC controller;

        Test.startTest();
        System.runAs(currUser) {
            controller = new VolunteerWelcomePage_AC();
            controller.COICheck();
        }
        Test.stopTest();

        System.assert(!controller.flagForCOICancel, 'Controller attribute `flagForCOICancel` should be false.');
    }

    @IsTest
    static void testCOICheckNotExpired() {
        User currUser = [SELECT Id, ContactId, CreatedDate, ProfileId, Contact.AccountId FROM User WHERE Username = 'prospective@volunteer.wish.org.test'];
        Contact contact = [SELECT OwnerId FROM Contact WHERE Name = 'Testy McTest'];
        Account account = [SELECT OwnerId FROM Account WHERE Name = 'Chapter0' LIMIT 1];

        contact.OwnerId = currUser.Id;
        account.OwnerId = currUser.Id;
        update contact;
        update account;

        List<Conflict_Of_Interest__c> coi = TestDataFactory.createConflictOfInterest(1);
        coi[0].Volunteer_Contact__c = currUser.ContactId;
        coi[0].Expiration_Date__c = Date.today().addDays(3);
        coi[0].Current__c = true;
        coi[0].OwnerId = currUser.Id;
        insert coi;

        VolunteerWelcomePage_AC controller;

        Test.startTest();
        System.runAs(currUser) {
            controller = new VolunteerWelcomePage_AC();
            controller.COICheck();
        }
        Test.stopTest();

        System.assert(controller.flagForCOICancel, 'Controller attribute `flagForCOICancel` should be true.');
    }

    @IsTest
    static void testBackgroundCheckDateInFuture() {
        User currUser = [SELECT Id, ContactId, CreatedDate, ProfileId, Contact.AccountId FROM User WHERE Username = 'active@volunteer.wish.org.test'];

        List<Chapter_Role__c> chapterRoles = [SELECT OwnerId FROM Chapter_Role__c];
        for (Chapter_Role__c chapterRole : chapterRoles) {
            chapterRole.OwnerId = currUser.Id;
        }
        update chapterRoles;

        List<Volunteer_Roles__c> volunteerRoles = [SELECT OwnerId, Volunteer_Name__c FROM Volunteer_Roles__c];
        for (Volunteer_Roles__c volunteerRole : volunteerRoles) {
            volunteerRole.OwnerId = currUser.Id;
            volunteerRole.Volunteer_Name__c = currUser.ContactId;
        }
        update volunteerRoles;

        Contact contact = [SELECT Id, is_Application__c FROM Contact WHERE Name = 'Testy McTest'];
        contact.is_Application__c = Constant_AC.CONTACT_IS_APPLICATION_APPROVED;
        update contact;

        List<Background_check__c> backgroundChecks = TestDataFactory.createBackgroundCheck(1);
        backgroundChecks[0].Status__c = Constant_AC.BACKGROUND_CHECK_STATUS_APPROVED;
        backgroundChecks[0].Date__c = Date.today().addDays(7);
        backgroundChecks[0].Current__c = true;
        backgroundChecks[0].OwnerId = currUser.Id;
        backgroundChecks[0].Volunteer__c = currUser.ContactId;
        backgroundChecks[0].Date_Completed__c = Date.today().addDays(7);
        insert backgroundChecks;

        VolunteerWelcomePage_AC controller;

        Test.startTest();
        System.runAs(currUser) {
            controller = new VolunteerWelcomePage_AC();
            controller.isBGRoleExpOOC = true;
            controller.backgroundCheck();
        }
        Test.stopTest();

        System.assert(controller.displayPopup, 'Controller attribute `displayPopup` should be true.');
        System.assert(controller.flagForCancel, 'Controller attribute `flagForCancel` should be true.');
    }

    @IsTest
    static void testBackgroundCheckDateInPast() {
        User currUser = [SELECT Id, ContactId, CreatedDate, ProfileId, Contact.AccountId FROM User WHERE Username = 'active@volunteer.wish.org.test'];

        List<Chapter_Role__c> chapterRoles = [SELECT OwnerId FROM Chapter_Role__c];
        for (Chapter_Role__c chapterRole : chapterRoles) {
            chapterRole.OwnerId = currUser.Id;
        }
        update chapterRoles;

        List<Volunteer_Roles__c> volunteerRoles = [SELECT OwnerId, Volunteer_Name__c FROM Volunteer_Roles__c];
        for (Volunteer_Roles__c volunteerRole : volunteerRoles) {
            volunteerRole.OwnerId = currUser.Id;
            volunteerRole.Volunteer_Name__c = currUser.ContactId;
        }
        update volunteerRoles;

        Contact contact = [SELECT Id, is_Application__c FROM Contact WHERE Name = 'Testy McTest'];
        contact.is_Application__c = Constant_AC.CONTACT_IS_APPLICATION_APPROVED;
        update contact;

        List<Background_check__c> backgroundChecks = TestDataFactory.createBackgroundCheck(1);
        backgroundChecks[0].Status__c = Constant_AC.BACKGROUND_CHECK_STATUS_APPROVED;
        backgroundChecks[0].Date__c = Date.today().addDays(-3);
        backgroundChecks[0].Current__c = true;
        backgroundChecks[0].OwnerId = currUser.Id;
        backgroundChecks[0].Volunteer__c = currUser.ContactId;
        backgroundChecks[0].Date_Completed__c = Date.today().addDays(7);
        insert backgroundChecks;

        VolunteerWelcomePage_AC controller;

        Test.startTest();
        System.runAs(currUser) {
            controller = new VolunteerWelcomePage_AC();
            controller.isBGRoleExpOOC = true;
            controller.backgroundCheck();
        }
        Test.stopTest();

        System.assert(controller.displayPopup, 'Controller attribute `displayPopup` should be true.');
        System.assert(!controller.flagForCancel, 'Controller attribute `flagForCancel` should be false.');
    }

    @IsTest
    static void testTwoBackgroundCheckDateInFuture() {
        User currUser = [SELECT Id, ContactId, CreatedDate, ProfileId, Contact.AccountId FROM User WHERE Username = 'active@volunteer.wish.org.test'];

        List<Chapter_Role__c> chapterRoles = [SELECT OwnerId FROM Chapter_Role__c];
        for (Chapter_Role__c chapterRole : chapterRoles) {
            chapterRole.OwnerId = currUser.Id;
        }
        update chapterRoles;

        List<Volunteer_Roles__c> volunteerRoles = [SELECT OwnerId, Volunteer_Name__c FROM Volunteer_Roles__c];
        for (Volunteer_Roles__c volunteerRole : volunteerRoles) {
            volunteerRole.OwnerId = currUser.Id;
            volunteerRole.Volunteer_Name__c = currUser.ContactId;
        }
        update volunteerRoles;

        Contact contact = [SELECT Id, is_Application__c FROM Contact WHERE Name = 'Testy McTest'];
        contact.is_Application__c = Constant_AC.CONTACT_IS_APPLICATION_APPROVED;
        update contact;

        List<Background_check__c> backgroundChecks = TestDataFactory.createBackgroundCheck(2);
        backgroundChecks[0].Status__c = Constant_AC.BACKGROUND_CHECK_STATUS_APPROVED;
        backgroundChecks[0].Date__c = Date.today().addDays(7);
        backgroundChecks[0].Current__c = true;
        backgroundChecks[0].OwnerId = currUser.Id;
        backgroundChecks[0].Volunteer__c = currUser.ContactId;
        backgroundChecks[0].Date_Completed__c = Date.today().addDays(7);
        backgroundChecks[1].Status__c = Constant_AC.BACKGROUND_CHECK_STATUS_APPROVED;
        backgroundChecks[1].Date__c = Date.today().addDays(7);
        backgroundChecks[1].Current__c = true;
        backgroundChecks[1].OwnerId = currUser.Id;
        backgroundChecks[1].Volunteer__c = currUser.ContactId;
        backgroundChecks[1].Date_Completed__c = Date.today().addDays(7);
        insert backgroundChecks;

        VolunteerWelcomePage_AC controller;

        Test.startTest();
        System.runAs(currUser) {
            controller = new VolunteerWelcomePage_AC();
            controller.isBGRoleExpOOC = true;
            controller.backgroundCheck();
        }
        Test.stopTest();

        System.assert(controller.displayPopup, 'Controller attribute `displayPopup` should be true.');
        System.assert(controller.flagForCancel, 'Controller attribute `flagForCancel` should be true.');
    }

    @IsTest
    static void testTwoBackgroundCheckDateInPast() {
        User currUser = [SELECT Id, ContactId, CreatedDate, ProfileId, Contact.AccountId FROM User WHERE Username = 'active@volunteer.wish.org.test'];

        List<Chapter_Role__c> chapterRoles = [SELECT OwnerId FROM Chapter_Role__c];
        for (Chapter_Role__c chapterRole : chapterRoles) {
            chapterRole.OwnerId = currUser.Id;
        }
        update chapterRoles;

        List<Volunteer_Roles__c> volunteerRoles = [SELECT OwnerId, Volunteer_Name__c FROM Volunteer_Roles__c];
        for (Volunteer_Roles__c volunteerRole : volunteerRoles) {
            volunteerRole.OwnerId = currUser.Id;
            volunteerRole.Volunteer_Name__c = currUser.ContactId;
        }
        update volunteerRoles;

        Contact contact = [SELECT Id, is_Application__c FROM Contact WHERE Name = 'Testy McTest'];
        contact.is_Application__c = Constant_AC.CONTACT_IS_APPLICATION_APPROVED;
        update contact;

        List<Background_check__c> backgroundChecks = TestDataFactory.createBackgroundCheck(2);
        backgroundChecks[0].Status__c = Constant_AC.BACKGROUND_CHECK_STATUS_APPROVED;
        backgroundChecks[0].Date__c = Date.today().addDays(-3);
        backgroundChecks[0].Current__c = true;
        backgroundChecks[0].OwnerId = currUser.Id;
        backgroundChecks[0].Volunteer__c = currUser.ContactId;
        backgroundChecks[0].Date_Completed__c = Date.today().addDays(7);
        backgroundChecks[1].Status__c = Constant_AC.BACKGROUND_CHECK_STATUS_APPROVED;
        backgroundChecks[1].Date__c = Date.today().addDays(-3);
        backgroundChecks[1].Current__c = true;
        backgroundChecks[1].OwnerId = currUser.Id;
        backgroundChecks[1].Volunteer__c = currUser.ContactId;
        backgroundChecks[1].Date_Completed__c = Date.today().addDays(7);
        insert backgroundChecks;

        VolunteerWelcomePage_AC controller;

        Test.startTest();
        System.runAs(currUser) {
            controller = new VolunteerWelcomePage_AC();
            controller.isBGRoleExpOOC = true;
            controller.backgroundCheck();
        }
        Test.stopTest();

        System.assert(controller.displayPopup, 'Controller attribute `displayPopup` should be true.');
        System.assert(!controller.flagForCancel, 'Controller attribute `flagForCancel` should be false.');
    }

    @IsTest
    static void testConfirmBackgroundCheck() {
        User currUser = [SELECT Id, ContactId, CreatedDate, ProfileId, Contact.AccountId FROM User WHERE Username = 'active@volunteer.wish.org.test'];
        Contact contact = [SELECT OwnerId FROM Contact WHERE Name = 'Testy McTest'];

        contact.OwnerId = currUser.Id;
        update contact;

        List<Background_check__c> backgroundChecks = TestDataFactory.createBackgroundCheck(1);
        backgroundChecks[0].Date_Completed__c = Date.today();
        backgroundChecks[0].Status__c = Constant_AC.BACKGROUND_CHECK_STATUS_APPROVED;
        backgroundChecks[0].Current__c = true;
        backgroundChecks[0].Volunteer__c = contact.Id;
        backgroundChecks[0].OwnerId = currUser.Id;
        insert backgroundChecks;

        VolunteerWelcomePage_AC controller;

        Test.startTest();
        System.runAs(currUser) {
            controller = new VolunteerWelcomePage_AC();
            controller.volunteercon = contact;
            controller.volunteercon.BackGroundCheckUpdated__c = false;
            controller.confirmBackGroundCheck();
            controller.confirmPopup = false;
        }
        Test.stopTest();

        System.assert(!controller.displayPopup, 'Controller attribute `displayPopup` should be false.');
        System.assert(controller.blockNewBG, 'Controller attribute `blockNewBG` should be true.');
    }
}