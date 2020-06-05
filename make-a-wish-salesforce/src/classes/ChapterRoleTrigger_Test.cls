@IsTest
public class ChapterRoleTrigger_Test{

    @TestSetup
    private static void setUp() {
        trac_TriggerHandlerBase.blockTrigger = true;

        List<Account> accountList = TestDataFactory.createAccount(1);
        Account accountAzChapter = accountList.get(0);
        accountAzChapter.Name = 'Make-A-Wish Arizona';
        accountAzChapter.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
        insert accountList;

        List<Role__c> roleList = TestDataFactory.createRole(3, false);
        Role__c wishRole = roleList.get(0);
        wishRole.Name = 'Wish Granter';
        wishRole.isWishRole__c = true;
        Role__c nonWishRole = roleList.get(1);
        nonWishRole.Name  = 'Office Assistant';
        Role__c nonWishRoleTemporary = roleList.get(2);
        nonWishRoleTemporary.Name  = 'Single Day Event Volunteer';
        insert roleList;

        List<Chapter_Role__c> chapterRoleList = TestDataFactory.createChapterRole(2);
        Chapter_Role__c wishGranterChapterRole = chapterRoleList.get(0);
        wishGranterChapterRole.Chapter_Name__c = accountAzChapter.Id;
        wishGranterChapterRole.Role_Name__c = wishRole.Id;
        wishGranterChapterRole.Background_Check_Required__c = true;
        Chapter_Role__c nonWishChapterRole = chapterRoleList.get(1);
        nonWishChapterRole.Chapter_Name__c = accountAzChapter.Id;
        nonWishChapterRole.Role_Name__c = nonWishRole.Id;
        nonWishChapterRole.Background_Check_Required__c = false;
        insert chapterRoleList;

        Profile nationalStaffFullAccessProfile = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Full Access National Staff'
        ];

        List<User> userList = TestDataFactory.createUser(1);
        User nationalStaffUser = userList.get(0);
        nationalStaffUser.ProfileId = nationalStaffFullAccessProfile.Id;
        nationalStaffUser.Username = 'national.staff@mawtesting.com';
        insert userList;

        trac_TriggerHandlerBase.blockTrigger = false;
    }

    @IsTest
    private static void validateRoleUpdate() {
        Role__c singleDayRole = [
            SELECT Id
            FROM Role__c
            WHERE Name = 'Single Day Event Volunteer'
        ];
        Chapter_Role__c nonWishRole = [
            SELECT Id, Role_Name__c, Role__c
            FROM Chapter_Role__c
            WHERE Role_Name__r.Name = 'Office Assistant'
        ];
        nonWishRole.Role_Name__c = singleDayRole.Id;

        Test.startTest();
        update nonWishRole;
        Test.stopTest();

        Chapter_Role__c nonWishRoleUpdate = [
            SELECT Id, Role_Name__c, Role__c
            FROM Chapter_Role__c
            WHERE Id = :nonWishRole.Id
        ];
        System.assert(nonWishRoleUpdate.Role__c == 'Single Day Event Volunteer');
    }

    @IsTest
    private static void validateRecordSharingMap() {
        User userNatStaff = getNationalStaffUser();
        Account accountAzChapter = [
            SELECT Id
            FROM Account
            WHERE Name = 'Make-A-Wish Arizona'
        ];
        Role__c wishRole = [
            SELECT Id
            FROM Role__c
            WHERE Name = 'Wish Granter'
        ];

        List<Chapter_Role__c> chapterRoleList = TestDataFactory.createChapterRole(1);
        System.runAs(Utils.currentUser){
            Chapter_Role__c wishGranterChapterRole = chapterRoleList.get(0);
            wishGranterChapterRole.Chapter_Name__c = accountAzChapter.Id;
            wishGranterChapterRole.Role_Name__c = wishRole.Id;
            wishGranterChapterRole.OwnerId = userNatStaff.Id;
            insert chapterRoleList;
        }

        Map<String, List<Chapter_Role__c>> chapterRoleMap = new Map<String, List<Chapter_Role__c>>();
        Test.startTest();
        System.runAs(userNatStaff) {
            chapterRoleMap = ChapterRoleService.buildChapterRoleRecordSharingUpdateMap(new Map<Id, Chapter_Role__c>(chapterRoleList));
        }
        Test.stopTest();
        System.assert(chapterRoleMap.containsKey('Make-A-Wish Arizona'));
    }

    @IsTest
    private static void validateOwnerChange() {
        User userNatStaff = getNationalStaffUser();
        Map<Id, Chapter_Role__c> oldChapterRoleMap = new Map<Id, Chapter_Role__c>([
            SELECT Id, OwnerId
            FROM Chapter_Role__c
            WHERE Chapter_Name__r.Name = 'Make-A-Wish Arizona'
        ]);
        Map<Id, Chapter_Role__c> newChapterRoleMap = new Map<Id, Chapter_Role__c>();
        for(Chapter_Role__c chapterRole : oldChapterRoleMap.values()) {
            Chapter_Role__c updatedChapterRole = new Chapter_Role__c(Id = chapterRole.Id);
            updatedChapterRole.OwnerId = userNatStaff.Id;
            newChapterRoleMap.put(updatedChapterRole.Id, updatedChapterRole);
        }
        Map<String, List<Chapter_Role__c>> chapterRoleMap = new Map<String, List<Chapter_Role__c>>();
        Test.startTest();
        System.runAs(userNatStaff) {
            update newChapterRoleMap.values();
            chapterRoleMap = ChapterRoleService.buildChapterRoleRecordSharingUpdateMap(newChapterRoleMap, oldChapterRoleMap);
        }
        Test.stopTest();
        System.assert(chapterRoleMap.containsKey('Make-A-Wish Arizona'));
    }

    private static User getNationalStaffUser() {
        UserRole nationalStaffRole = [
            SELECT Id
            FROM UserRole
            WHERE Name = 'National Staff'
        ];
        User userNatStaff = [
            SELECT Id, UserRoleId
            FROM User
            WHERE Username = 'national.staff@mawtesting.com'
        ];
        userNatStaff.UserRoleId = nationalStaffRole.Id;
        update userNatStaff;
        return userNatStaff;
    }
}