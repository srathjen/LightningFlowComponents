@IsTest
public class AddVolunteerRole_AC_Test {

    private static final String NAME_TEST = 'AddVolunteerRoleTest';

    @TestSetup
    private static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;
        User volunteerUser = new User();
        System.runAs (new User(Id = UserInfo.getUserId())) {
            volunteerUser = TestDataFactory.createVolunteerUser(1, 'Active Volunteer (Member)', 'Manager')[0];
            volunteerUser.Hidden_Role_Name_Id__c = NAME_TEST;
            volunteerUser.LastName = NAME_TEST;
            insert volunteerUser;
        }
        volunteerUser = getVolunteerUser();
        Account chapterAccount = [
                SELECT RecordTypeId
                FROM Account
                WHERE Id = :volunteerUser.Contact.AccountId
        ];
        chapterAccount.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
        update chapterAccount;

        Role__c nonWishRole = TestDataFactory.createRole(1, false)[0];
        nonWishRole.Name = NAME_TEST;
        insert nonWishRole;

        Chapter_Role__c chapterRole = TestDataFactory.createChapterRole(1)[0];
        chapterRole.Chapter_Name__c = volunteerUser.Contact.AccountId;
        chapterRole.Role_Name__c = nonWishRole.Id;
        chapterRole.Background_Check_Required__c = true;
        insert chapterRole;

        Non_Wish_Events__c nonWishEvent = TestDataFactory.createNonWishEvent(1)[0];
        nonWishEvent.Event_Name__c = 'Send Off';
        nonWishEvent.Event_Date__c = System.today() + 5;
        nonWishEvent.Event_Text__c = 'Sending Wish Child';
        nonWishEvent.RecordTypeId = Constant_AC.EVENTS_ID;
        nonWishEvent.Volunteer_Need__c = 3;
        nonWishEvent.Chapter_Role__c = chapterRole.Id;
        nonWishEvent.Chapter__c = volunteerUser.Contact.AccountId;
        insert nonWishEvent;

        System.runAs(volunteerUser) {
            Volunteer_Count__c volunteerCount = TestDataFactory.createVolunteerCount(1)[0];
            volunteerCount.Non_Wish_Events__c = nonWishEvent.Id;
            volunteerCount.Description__c = 'Test Description';
            volunteerCount.Date__c = System.today() + 1;
            volunteerCount.Start_Time__c = '7.00 AM';
            volunteerCount.End_Time__c = '9.00 AM';
            volunteerCount.Volunteer_Needed__c = 2;
            volunteerCount.Description__c = nonWishEvent.Description__c;
            volunteerCount.Chapter_Role__c = nonWishEvent.Chapter_Role__c;
            insert volunteerCount;

            Volunteer_Opportunity__c volunteerOpportunity = TestDataFactory.createVolunteerOpportunity(1)[0];
            volunteerOpportunity.Chapter_Role_Opportunity__c = chapterRole.Id;
            volunteerOpportunity.Non_Wish_Event__c = nonWishEvent.Id;
            volunteerOpportunity.Chapter_Name__c = volunteerUser.Contact.AccountId;
            volunteerOpportunity.RecordTypeId = Constant_AC.NON_WISH_EVENT_RT_ID;
            volunteerOpportunity.Status__c = 'Pending';
            insert volunteerOpportunity;
        }
        trac_TriggerHandlerBase.blockTrigger = false;
    }

    @IsTest
    public static void createNonWishEvent() {
        SetupPackage sp = new SetupPackage();
        Test.startTest();
        System.runAs(sp.volunteerUser) {
            ApexPages.StandardController sc = new ApexPages.StandardController(sp.nonWishEvent);
            AddVolunteerRole_AC addRole = new AddVolunteerRole_AC(sc);
            PageReference pageRef = Page.AddVolunteerRole_VF;
            pageRef.getParameters().put('id', String.valueOf(sp.nonWishEvent.Id));
            Test.setCurrentPage(pageRef);
            addRole.addRow();
            addRole.addRow();
            addRole.RoleName = 'WishGranter';
            addRole.VolunteerCount = 3;
            addRole.isCommunity = false;
            addRole.EditRec();
            addRole.saveRec();
            addRole.cancelRec();
            addRole.ChapterRoleId = sp.chapterRole.Id;
            addRole.register();
            System.assertEquals([
                    SELECT Volunteer_Needed__c
                    FROM Volunteer_Count__c
            ].Volunteer_Needed__c, 2, 'Count does not Match');
        }
        Test.stopTest();
    }

    @IsTest
    public static void createNonWishEventErrors() {
        SetupPackage sp = new SetupPackage();
        Test.startTest();
        System.runAs(sp.volunteerUser) {
            ApexPages.StandardController sc = new ApexPages.StandardController(sp.nonWishEvent);
            AddVolunteerRole_AC addRole = new AddVolunteerRole_AC(sc);
            PageReference pageRef = Page.AddVolunteerRole_VF;
            pageRef.getParameters().put('id', String.valueOf(sp.nonWishEvent.Id));
            Test.setCurrentPage(pageRef);
            addRole.addRow();
            addRole.RoleName = 'WishGranter';
            addRole.VolunteerCount = 3;
            addRole.isCommunity = false;
            addRole.EditRec();
            addRole.saveRec();
            addRole.EditRec();
            addRole.saveRec();
            addRole.EditRec();
            addRole.saveRec();
            addRole.cancelRec();
            addRole.ChapterRoleId = sp.chapterRole.Id;
            addRole.register();
        }
        Test.stopTest();
    }

    @IsTest
    public static void removeVolunteerContactonNonwishEvent() {
        SetupPackage sp = new SetupPackage();
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(sp.nonWishEvent);
        AddVolunteerRole_AC addRole = new AddVolunteerRole_AC(sc);
        PageReference pageRef = Page.AddVolunteerRole_VF;
        pageRef.getParameters().put('id', String.valueOf(sp.nonWishEvent.Id));
        Test.setCurrentPage(pageRef);
        addRole.addRow();
        addRole.RoleName = 'WishGranter';
        addRole.VolunteerCount = 3;
        addRole.isCommunity = false;
        addRole.EditRec();
        addRole.saveRec();
        addRole.cancelRec();
        addRole.ChapterRoleId = sp.chapterRole.Id;
        addRole.register();
        System.assertEquals(addRole.VolunteerCount, 3, 'Count does not match');
        System.assert(addRole.VolunteerCount == 3, 'The value of  addRole.VolunteerCount is: '
                + addRole.VolunteerCount + ' and the value of actual count is: 3');
    }

    @IsTest
    public static void testEmptyVolunteerCountOnInit() {
        delete [
                SELECT Id
                FROM Volunteer_Count__c
        ];
        SetupPackage sp = new SetupPackage();
        Test.startTest();
        System.runAs(sp.volunteerUser) {
            ApexPages.StandardController sc = new ApexPages.StandardController(sp.nonWishEvent);
            AddVolunteerRole_AC addRole = new AddVolunteerRole_AC(sc);
            PageReference pageRef = Page.AddVolunteerRole_VF;
            pageRef.getParameters().put('id', String.valueOf(sp.nonWishEvent.Id));
            Test.setCurrentPage(pageRef);
            addRole.addRow();
            addRole.RoleName = 'WishGranter';
            addRole.VolunteerCount = 3;
            addRole.isCommunity = false;
            addRole.EditRec();
            addRole.saveRec();
            addRole.cancelRec();
            addRole.ChapterRoleId = sp.chapterRole.Id;
            addRole.register();
        }
        Test.stopTest();
    }

    @IsTest
    public static void testTooManyRegisteredError() {
        SetupPackage sp = new SetupPackage();
        Volunteer_Count__c vc = [
                SELECT Registered__c, Volunteer_Needed__c
                FROM Volunteer_Count__c
                WHERE Non_Wish_Events__c = :sp.nonWishEvent.Id
        ];
        // Setup Volunteer Count to enter too many registered block
        vc.Registered__c = 2;
        vc.Volunteer_Needed__c = 1;
        update vc;

        Test.startTest();
        System.runAs(sp.volunteerUser) {
            ApexPages.StandardController sc = new ApexPages.StandardController(sp.nonWishEvent);
            AddVolunteerRole_AC addRole = new AddVolunteerRole_AC(sc);
            PageReference pageRef = Page.AddVolunteerRole_VF;
            pageRef.getParameters().put('id', String.valueOf(sp.nonWishEvent.Id));
            Test.setCurrentPage(pageRef);
            addRole.addRow();
            addRole.RoleName = 'WishGranter';
            addRole.VolunteerCount = 3;
            addRole.isCommunity = false;
            addRole.EditRec();
            System.assertEquals(null, addRole.saveRec());
        }
        Test.stopTest();
    }
    @IsTest
    public static void testErrors() {
        SetupPackage sp = new SetupPackage();
        Test.startTest();
        System.runAs(sp.volunteerUser) {
            ApexPages.StandardController sc = new ApexPages.StandardController(sp.nonWishEvent);
            AddVolunteerRole_AC addRole = new AddVolunteerRole_AC(sc);
            PageReference pageRef = Page.AddVolunteerRole_VF;
            pageRef.getParameters().put('id', String.valueOf(sp.nonWishEvent.Id));
            Test.setCurrentPage(pageRef);
            addRole.addRow();
            addRole.addRow();
            addRole.RoleName = 'WishGranter';
            addRole.VolunteerCount = 3;
            addRole.isCommunity = false;
            addRole.EditRec();
            for(Volunteer_Count__c vc : addRole.volunteerCountToUpdateList){
                vc.Date__c = System.today().addDays(-1);
            }
            addRole.sameValue = addRole.dateMessage = true;
            addRole.saveRec();
            addRole.cancelRec();
            addRole.ChapterRoleId = sp.chapterRole.Id;
            addRole.register();
        }
        Test.stopTest();
    }

    @IsTest
    public static void coverMisc() {
        SetupPackage sp = new SetupPackage();
        Test.startTest();
        System.runAs(sp.volunteerUser) {
            ApexPages.StandardController sc = new ApexPages.StandardController(sp.nonWishEvent);
            AddVolunteerRole_AC addRole = new AddVolunteerRole_AC(sc);
            PageReference pageRef = Page.AddVolunteerRole_VF;
            pageRef.getParameters().put('id', String.valueOf(sp.nonWishEvent.Id));
            Test.setCurrentPage(pageRef);
            addRole.addRow();
            addRole.addRow();
            addRole.RoleName = 'WishGranter';
            addRole.VolunteerCount = 3;
            addRole.isCommunity = false;
            addRole.EditRec();
            addRole.volunteerCountToUpdateList.clear();
            addRole.addNewVolunteerRoleList.add(sp.nonWishEvent);
            addRole.saveRec();
            addRole.cancelRec();
            addRole.ChapterRoleId = sp.chapterRole.Id;
            addRole.register();
        }
        Test.stopTest();
    }

    private static User getVolunteerUser() {
        return [
                SELECT Id, ContactId, Contact.AccountId
                FROM User
                WHERE LastName = :NAME_TEST
        ];
    }

    private class SetupPackage {
        public User volunteerUser { get; set; }
        public Role__c nonWishRole { get; set; }
        public Chapter_Role__c chapterRole { get; set; }
        public Non_Wish_Events__c nonWishEvent { get; set; }

        public SetupPackage() {
            volunteerUser = getVolunteerUser();
            nonWishRole = [
                    SELECT Id
                    FROM Role__c
                    WHERE Name = :NAME_TEST
            ];
            chapterRole = [
                    SELECT Id
                    FROM Chapter_Role__c
                    WHERE Role_Name__c = :nonWishRole.Id
            ];
            nonWishEvent = [
                    SELECT Id, Chapter_Role__c, Volunteer_Need__c, Description__c, Start_Time__c, End_Time__c,
                            Hidden_Location__c, Hidden_Date__c
                    FROM Non_Wish_Events__c
                    WHERE Chapter__c = :volunteerUser.Contact.AccountId
            ];
        }
    }
}