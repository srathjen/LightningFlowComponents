@IsTest
public class ChapterRoleOT_Test {

    @TestSetup
    public static void setUp() {
        trac_TriggerHandlerBase.blockTrigger = true;

        List<Account> accounts = TestDataFactory.createAccount(1);
        Account account1 = accounts.get(0);
        account1.Name = 'Make-A-Wish Arizona';
        account1.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
        insert accounts;

        String profileName = 'Full Access National Staff';
        String portalRole = 'Manager';
        Id userRoleId = [
                SELECT Id
                FROM UserRole
                WHERE Name = 'National Staff'
        ].Id;

        List<User> users = TestDataFactory.createUser(1);
        System.runAs(Utils.currentUser) {
            Profile profile = [
                    SELECT Id,Name
                    FROM Profile
                    WHERE Name = :profileName
                    LIMIT 1
            ];
            User u = users.get(0);
            u.ProfileId = profile.Id;
            u.PortalRole = portalRole;
            u.UserRoleId = userRoleId;
            insert users;
        }

        trac_TriggerHandlerBase.blockTrigger = false;
    }

    @IsTest
    public static void createChapterRole() {
        User nationalStaff = [
                SELECT Id, UserRole.Name, AccountId
                FROM User
                WHERE Email = 'testuser0@testorg.com'
                LIMIT 1
        ];
        Account account = [
                SELECT Id
                FROM Account
                LIMIT 1
        ];

        Orientation_Training__c volunteerOrientationTraining = TestDataFactory.createOrientationTraining(1)[0];
        volunteerOrientationTraining.Name = 'Volunteer Orientation';
        volunteerOrientationTraining.Chapter_Name__c = account.Id;
        volunteerOrientationTraining.RecordTypeId = Constant_AC.ORIENTATION_RT_ID;
        volunteerOrientationTraining.Start_Time__c = '7:00 AM';
        volunteerOrientationTraining.End_Time__c = '7:00 PM';
        insert volunteerOrientationTraining;

        List<Chapter_Role_O_T__c> chapterRoleOts = TestDataFactory.createChapterRoleOrientationAndTraining(1);
        Chapter_Role_O_T__c chapterRoleOt = chapterRoleOts.get(0);
        chapterRoleOt.OwnerId = nationalStaff.Id;
        chapterRoleOt.Orientation_Training__c = volunteerOrientationTraining.Id;
        insert chapterRoleOts;
    }

    @IsTest
    public static void updateChapterRole() {
        User nationalStaff = [
                SELECT Id, UserRole.Name, AccountId
                FROM User
                WHERE Email = 'testuser0@testorg.com'
                LIMIT 1
        ];
        Account account = [
                SELECT Id
                FROM Account
                LIMIT 1
        ];

        Orientation_Training__c volunteerOrientationTraining = TestDataFactory.createOrientationTraining(1)[0];
        volunteerOrientationTraining.Name = 'Volunteer Orientation';
        volunteerOrientationTraining.Chapter_Name__c = account.Id;
        volunteerOrientationTraining.RecordTypeId = Constant_AC.ORIENTATION_RT_ID;
        volunteerOrientationTraining.Start_Time__c = '7:00 AM';
        volunteerOrientationTraining.End_Time__c = '7:00 PM';
        insert volunteerOrientationTraining;

        List<Chapter_Role_O_T__c> chapterRoleOts = TestDataFactory.createChapterRoleOrientationAndTraining(1);
        Chapter_Role_O_T__c chapterRoleOt = chapterRoleOts.get(0);
        chapterRoleOt.OwnerId = Utils.currentUser.Id;
        chapterRoleOt.Orientation_Training__c = volunteerOrientationTraining.Id;
        insert chapterRoleOts;

        chapterRoleOt.OwnerId = nationalStaff.Id;
        update chapterRoleOts;
    }
}