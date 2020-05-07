@IsTest
public class ChapterRoleOT_Test {

    private static final Id USER_ROLE_NATIONAL_STAFF_ID = [
            SELECT Id
            FROM UserRole
            WHERE Name = :Constant_AC.ROLE_NATIONAL_STAFF
    ].Id;
    private static final Id PROFILE_SYSTEM_ADMIN_ID = [
            SELECT Id
            FROM Profile
            WHERE Name = :Constant_AC.PROFILE_SYSTEM_ADMINISTRATOR
    ].Id;

    @TestSetup
    private static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;
        Chapter_Vs_Role__c arizonaChap = TestDataFactory.createChapterVsRole(1, 'Arizona')[0];
        Chapter_Vs_Role__c alabamaChap = TestDataFactory.createChapterVsRole(1, 'Alabama')[0];
        insert new List<Chapter_Vs_Role__c>{
                arizonaChap, alabamaChap
        };

        User currUser = Utils.currentUser;
        User nationalStaff;
        System.runAs(currUser) {
            nationalStaff = TestDataFactory.createUser(1)[0];
            nationalStaff.UserRoleId = USER_ROLE_NATIONAL_STAFF_ID;
            nationalStaff.ProfileId = PROFILE_SYSTEM_ADMIN_ID;
            insert nationalStaff;
        }
        trac_TriggerHandlerBase.blockTrigger = false;
    }

    //Create a chapterroleO&T record owner as National staff
    @IsTest
    private static void createChapterRoleOT() {
        System.runAs(getNationalStaffUser()) {
            Chapter_Role__c newChapterRole = OrientationandTrainingUtil.createChapter(TestDataFactory.createChapterAccount(1)[0].Id, TestDataFactory.createRole(1, false)[0].Id);
            insert newChapterRole;

            OrientationandTrainingUtil.createChapterOandT(newChapterRole.Id, OrientationandTrainingUtil.CreateVolunteerOrientationRecord().Id);
        }
    }

    //Update Owner
    @IsTest
    private static void ownerUpdate() {
        System.runAs(getNationalStaffUser()) {
            Chapter_Role__c newChapterRole = OrientationandTrainingUtil.createChapter(OrientationandTrainingUtil.createchapterAccount().Id, OrientationandTrainingUtil.createRole().Id);
            insert newChapterRole;

            OrientationandTrainingUtil.createChapterOandT(newChapterRole.Id, OrientationandTrainingUtil.CreateVolunteerOrientationRecord().Id);
            List<Chapter_Role_O_T__c> chapterRoleOt = [
                    SELECT Id, OwnerId
                    FROM Chapter_Role_O_T__c
                    LIMIT 1
            ];
            if (!chapterRoleOt.isEmpty()) {
                Chapter_Role_O_T__c cOT = new Chapter_Role_O_T__c();
                cOT.Id = chapterRoleOt[0].Id;
                cOT.OwnerId = Utils.currentUser.Id;
                update cOT;
            }
        }
    }

    private static User getNationalStaffUser() {
        return [
                SELECT Id
                FROM User
                WHERE UserRole.Name = :Constant_AC.ROLE_NATIONAL_STAFF
                LIMIT 1
        ];
    }
}