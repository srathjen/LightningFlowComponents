@IsTest
public class VolunteerLanding_AC_Test {
    private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;

    @TestSetup
    private static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;

        User currUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            currUser = OrientationandTrainingUtil.createActiveVolunteerUser(null);
            insert currUser;
        }
        insert OrientationandTrainingUtil.createAffiliation(currUser.ContactId);
    }

    // Capturing Dynamic content and Events.
    @IsTest
    static void createDynamicContent() {
        User currUser = getVolunteerUser();
        System.runAs(currUser) {
            Dynamic_Content__c createProspectiveDynamicContent = OrientationandTrainingUtil.ChapterDynamicContent(currUser.Contact.AccountId);
            insert createProspectiveDynamicContent;

            HoldCurrentChapter__c currVal = new HoldCurrentChapter__c();
            currVal.Name = currUser.Id;
            currVal.CurrentChapter__c = currUser.Contact.Account.Name;
            insert currVal;

            Id EventRecTypeId = Constant_AC.EVENTS_ID;

            List<Non_Wish_Events__c> eventList = new List<Non_Wish_Events__c>();
            for (integer i = 1; i < 4; i++) {
                Non_Wish_Events__c newEvent = new Non_Wish_Events__c();
                newEvent.Event_Name__c = 'Send Off';
                newEvent.Event_Date__c = System.today() + 5;
                newEvent.Event_Text__c = 'Sending Wish Child';
                newEvent.Priority__c = String.valueOf(i);
                newEvent.chapter__c = currUser.Contact.AccountId;
                newEvent.RecordTypeId = EventRecTypeId;
                eventList.add(newEvent);
            }

            Non_Wish_Events__c newEvent = new Non_Wish_Events__c();
            newEvent.Event_Name__c = 'Send Off';
            newEvent.Event_Date__c = System.today() + 5;
            newEvent.Event_Text__c = 'Sending Wish Child';
            //newEvent.Priority__c = String.valueOf(i);
            newEvent.RecordTypeId = EventRecTypeId;
            newEvent.chapter__c = currUser.Contact.AccountId;
            eventList.add(newEvent);
            insert eventList;

            VolunteerLanding_AC controller = new VolunteerLanding_AC();
            controller.getChapterList();
            controller.getEvents();
            controller.EnterchapterPage();
        }
    }

    // Create custom setting value.
    @IsTest
    static void CreateHoldChapterValue() {
        User currUser = getVolunteerUser();
        // Need parent fields
        currUser = [
                SELECT Id, ContactId, Contact.AccountId
                FROM User
                WHERE Id = :currUser.Id
        ];
        System.runAs(currUser) {
            Dynamic_Content__c createDynamicContent = OrientationandTrainingUtil.createDynamicContent();

            VolunteerLanding_AC controller = new VolunteerLanding_AC();
            controller.EnterchapterPage();
        }
    }

    // Display Promop upon login Training.
    @IsTest
    static void checkBGandCOI() {
        User currUser = getVolunteerUser();

        npe5__Affiliation__c neworgAffiliation = new npe5__Affiliation__c ();
        neworgAffiliation.npe5__Contact__c = currUser.ContactId;
        neworgAffiliation.npe5__Organization__c = currUser.Contact.AccountId;
        neworgAffiliation.npe5__Primary__c = true;
        neworgAffiliation.npe5__Status__c = 'Active';
        neworgAffiliation.Constituent_Code__c = Constant_AC.BOARD_MEMBER_RT_LABEL;
        insert neworgAffiliation;

        VolunteerLanding_AC controller;
        insert OrientationandTrainingUtil.insertDocusignSetting();

        Contact con1 = new Contact();
        con1.Id = currUser.ContactId;
        con1.Broadcast_Number__c = '1234';
        con1.BackGroundCheckUpdated__c = true;
        update con1;

        Dynamic_Content__c createProspectiveDynamicContent = OrientationandTrainingUtil.ChapterDynamicContent(currUser.Contact.AccountId);
        insert createProspectiveDynamicContent;

        HoldCurrentChapter__c currVal = new HoldCurrentChapter__c();
        currVal.Name = currUser.Id;
        currVal.CurrentChapter__c = currUser.Contact.Account.Name;
        insert currVal;

        Conflict_Of_Interest__c currCOI = OrientationandTrainingUtil.createCOI(currUser.ContactId);
        currCOI.Volunteer_Contact__c = currUser.ContactId;
        currCOI.Expiration_Date__c = System.today() + 5;
        currCOI.Current__c = true;
        insert currCOI;
        COIRecordSharing(currUser.Id, currCOI.Id);

        Broadcast__c currBroad = new Broadcast__c();
        currBroad.Broadcast_Message__c = 'Test';
        currBroad.Date__c = Date.today() + 5;
        currBroad.Chapter_Name__c = currUser.Contact.AccountId;
        currBroad.Active__c = true;
        insert currBroad;

        Role__c currRole = OrientationandTrainingUtil.createRole();
        insert currRole;

        Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(currUser.Contact.AccountId, currRole.Id);
        insert currChapRole;

        Test.startTest();
        Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(currUser.ContactId, currChapRole.Id);
        currVolRole.Status__c = VOLUNTEER_ROLE_STATUS_ACTIVE;
        insert currVolRole;

        System.runAs(currUser) {
            Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
            currOandT.Prompt_upon_Login__c = true;
            insert currOandT;

            Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.Id, currOandT.Id);
            insert currChapOandT;

            Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.Id);
            insert currOffering;

            controller = new VolunteerLanding_AC();
            controller.getChapterList();
            controller.EnterchapterPage();
            controller.COICheck();
        }

        currCOI.Expiration_Date__c = Date.today() - 5;
        update currCOI;

        System.runAs(currUser){
            controller.COICheck();
            controller.BackgroundCheck(false);
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

            controller.confirmBackGroundCheck();
            controller.cancel();
            controller.cancelConflict();
            controller.displayEmail();
            controller.hidePopup();

            controller.TrainingAckCancel();
            Test.setMock(HttpCalloutMock.class, new Mock_ResponseGenerator());
            controller.confirmBackGroundCheck();
            controller.confirmConflict('VolunteerLanding_VF');

            Boolean flagForCOICancel = controller.flagForCOICancel;
            String residingStatus = controller.residingStatus;
            Integer nCOIDays = controller.nCOIDays;
            List<Orientation_Training__c> orientationList = controller.orientationList;
            Boolean isInactivePopup = controller.isInactivePopup;
            Boolean displayTrainingnewDetails = controller.displayTrainingnewDetails;
            controller.broadCastCancel();
        }
        Test.stopTest();
    }

    // Background verfication and New BroadCast policy created.
    @IsTest
    static void checkBackgroundCheck() {
        User currUser = getVolunteerUser();

        npe5__Affiliation__c neworgAffiliation = new npe5__Affiliation__c ();
        neworgAffiliation.npe5__Contact__c = currUser.ContactId;
        neworgAffiliation.npe5__Organization__c = currUser.Contact.AccountId;
        neworgAffiliation.npe5__Primary__c = true;
        neworgAffiliation.npe5__Status__c = 'Active';
        neworgAffiliation.Constituent_Code__c = Constant_AC.BOARD_MEMBER_RT_LABEL;
        insert neworgAffiliation;

        Test.startTest();
        VolunteerLanding_AC controller;
        System.runAs(currUser) {
            Dynamic_Content__c createProspectiveDynamicContent = OrientationandTrainingUtil.ChapterDynamicContent(currUser.Contact.AccountId);
            insert createProspectiveDynamicContent;

            HoldCurrentChapter__c currVal = new HoldCurrentChapter__c();
            currVal.Name = currUser.Id;
            currVal.CurrentChapter__c = currUser.Contact.Account.Name;
            insert currVal;
        }

        Background_check__c currBG = OrientationandTrainingUtil.createBackgroundCheck(currUser.ContactId);
        currBG.Date__c = Date.today() + 5;
        currBG.Date_Completed__c = Date.today() + 5;
        currBG.Current__c = true;
        insert currBG;
        BGCRecordSharing(currUser.Id, currBG.Id);

        Broadcast__c currBroad = new Broadcast__c();
        currBroad.Broadcast_Message__c = 'Test';
        currBroad.Date__c = Date.today() + 5;
        currBroad.Active__c = true;
        currBroad.Chapter_Name__c = currUser.Contact.AccountId;
        insert currBroad;

        Role__c currRole = OrientationandTrainingUtil.createRole();
        insert currRole;

        Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(currUser.Contact.AccountId, currRole.Id);
        insert currChapRole;

        Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(currUser.ContactId, currChapRole.Id);
        currVolRole.Status__c = 'Pending';
        insert currVolRole;

        Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
        currOandT.Prompt_upon_Login__c = True;
        insert currOandT;

        Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.Id, currOandT.Id);
        insert currChapOandT;

        Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.Id);
        insert currOffering;

        System.runAs(currUser){
            controller = new VolunteerLanding_AC();
            controller.confirmPopup = true;
            controller.hidePopup();
            controller.getChapterList();
            controller.EnterchapterPage();
            controller.myId = currUser.Id;
            controller.COICheck();
            controller.broadCastCancel();
            controller.callConfirmConflict();
        }
        Test.stopTest();
    }

    // Background check and COI is interms of going to expired in 30 days.
    @IsTest
    static void checkCOI() {
        User currUser = getVolunteerUser();

        VolunteerLanding_AC controller;

        Conflict_Of_Interest__c currCOI = OrientationandTrainingUtil.createCOI(currUser.ContactId);
        currCOI.Expiration_Date__c = System.today() + 5;
        currCOI.Current__c = true;
        insert currCOI;
        COIRecordSharing(currUser.Id, currCOI.Id);

        Broadcast__c currBroad = new Broadcast__c();
        currBroad.Broadcast_Message__c = 'Test';
        currBroad.Date__c = Date.today() + 5;
        currBroad.Chapter_Name__c = currUser.Contact.AccountId;
        currBroad.Active__c = true;
        insert currBroad;

        Role__c currRole = OrientationandTrainingUtil.createRole();
        insert currRole;

        Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(currUser.Contact.AccountId, currRole.Id);
        insert currChapRole;

        Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(currUser.ContactId, currChapRole.Id);
        insert currVolRole;

        Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
        currOandT.Prompt_upon_Login__c = true;
        insert currOandT;

        Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.Id, currOandT.Id);
        insert currChapOandT;

        Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.Id);
        insert currOffering;

        Volunteer_Orientation_Training__c createVolOrientation = VolunteerLanding_AC_Test.createVolOrientation(currOandT.Id, currOffering.Id, currUser.ContactId, 'Registered');
        insert createVolOrientation;

        Test.startTest();
        System.runAs(currUser) {
            Dynamic_Content__c createProspectiveDynamicContent = OrientationandTrainingUtil.ChapterDynamicContent(currUser.Contact.AccountId);
            insert createProspectiveDynamicContent;

            HoldCurrentChapter__c currVal = new HoldCurrentChapter__c();
            currVal.Name = currUser.Id;
            currVal.CurrentChapter__c = currUser.Contact.Account.Name;
            insert currVal;

            controller = new VolunteerLanding_AC();
            controller.getChapterList();
            controller.EnterchapterPage();
            controller.COICheck();
            controller.broadCastCancel();
        }
        Test.stopTest();
    }

    //Confict Of Interest Expired.
    @IsTest
    static void checkCOIisExpired() {
        User currUser = getVolunteerUser();

        VolunteerLanding_AC controller;
        System.runAs(currUser) {
            Dynamic_Content__c createProspectiveDynamicContent = OrientationandTrainingUtil.ChapterDynamicContent(currUser.Contact.AccountId);
            HoldCurrentChapter__c currVal = new HoldCurrentChapter__c();
            currVal.Name = currUser.Id;
            currVal.CurrentChapter__c = currUser.Contact.Account.Name;
            insert currVal;
        }

        Conflict_Of_Interest__c currCOI = OrientationandTrainingUtil.createCOI(currUser.ContactId);
        currCOI.Expiration_Date__c = System.today() - 5;
        currCOI.Current__c = true;
        insert currCOI;
        COIRecordSharing(currUser.Id, currCOI.Id);
        update currCOI;

        System.runAs(currUser){
            controller = new VolunteerLanding_AC();
            controller.getChapterList();
            controller.EnterchapterPage();
            controller.COICheck();
        }
    }

    // Backgroundcheck expired.
    @IsTest
    static void checkBGisExpired() {
        User currUser = getVolunteerUser();

        npe5__Affiliation__c neworgAffiliation = new npe5__Affiliation__c ();
        neworgAffiliation.npe5__Contact__c = currUser.ContactId;
        neworgAffiliation.npe5__Organization__c = currUser.Contact.AccountId;
        neworgAffiliation.npe5__Primary__c = true;
        neworgAffiliation.npe5__Status__c = 'Active';
        neworgAffiliation.Constituent_Code__c = Constant_AC.BOARD_MEMBER_RT_LABEL;
        insert neworgAffiliation;

        VolunteerLanding_AC controller;
        System.runAs(currUser) {
            Dynamic_Content__c createProspectiveDynamicContent = OrientationandTrainingUtil.ChapterDynamicContent(currUser.Contact.AccountId);
            HoldCurrentChapter__c currVal = new HoldCurrentChapter__c();
            currVal.Name = currUser.Id;
            currVal.CurrentChapter__c = currUser.Contact.Account.Name;
            insert currVal;
        }

        Background_check__c currBG = OrientationandTrainingUtil.createBackgroundCheck(currUser.ContactId);
        currBG.Date__c = Date.today() - 5;
        insert currBG;
        BGCRecordSharing(currUser.Id, currBG.Id);
        update currBG;

        System.runAs(currUser){

            controller = new VolunteerLanding_AC();
            controller.isBGRoleExpOOC = true;
            controller.getChapterList();
            controller.EnterchapterPage();
            controller.COICheck();
        }
    }

    // Registered the Background Verfication.But Verifiation pending status.
    @IsTest
    private static void checkBGStatus() {
        User currUser = getVolunteerUser();

        npe5__Affiliation__c neworgAffiliation = new npe5__Affiliation__c ();
        neworgAffiliation.npe5__Contact__c = currUser.ContactId;
        neworgAffiliation.npe5__Organization__c = currUser.Contact.AccountId;
        neworgAffiliation.npe5__Primary__c = true;
        neworgAffiliation.npe5__Status__c = 'Active';
        neworgAffiliation.Constituent_Code__c = Constant_AC.BOARD_MEMBER_RT_LABEL;
        insert neworgAffiliation;

        VolunteerLanding_AC controller;
        System.runAs(currUser) {
            Dynamic_Content__c createProspectiveDynamicContent = OrientationandTrainingUtil.ChapterDynamicContent(currUser.Contact.AccountId);
            insert createProspectiveDynamicContent;

            HoldCurrentChapter__c currVal = new HoldCurrentChapter__c();
            currVal.Name = currUser.Id;
            currVal.CurrentChapter__c = currUser.Contact.Account.Name;
            insert currVal;
        }

        trac_TriggerHandlerBase.blockTrigger = true;
        Background_check__c currBG = OrientationandTrainingUtil.createBackgroundCheck(currUser.ContactId);
        currBG.Date__c = Date.today().addYears(3);
        insert currBG;

        BGCRecordSharing(currUser.Id, currBG.Id);
        trac_TriggerHandlerBase.blockTrigger = false;

        System.runAs(currUser){
            controller = new VolunteerLanding_AC();
            controller.getChapterList();
            controller.EnterchapterPage();
            controller.COICheck();
        }
    }

    // Creating Volunteer Traing based on the input parameter.
    private static Volunteer_Orientation_Training__c createVolOrientation(Id OrienationId, Id ClassOfferingId, Id volunteer, string status) {
        Volunteer_Orientation_Training__c createNewVol = new Volunteer_Orientation_Training__c();
        createNewVol.class_offering__c = ClassOfferingId;
        createNewVol.Hidden_O_T_Id__c = OrienationId;
        createNewVol.Registered_Date__c = Date.today();
        createNewVol.Volunteer__c = volunteer;
        createNewVol.Volunteer_Attendance__c = status;
        createNewVol.Type__c = 'Training';
        return createNewVol;
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

    // Need to requery uesr for test methods as test setup doesn't allow static variables for easy access
    private static User getVolunteerUser() {
        return [
                SELECT Id, ContactId, Contact.AccountId, Contact.Account.Name
                FROM User
                WHERE Username = 'joathanedwards@gmail.com'
        ];
    }
}