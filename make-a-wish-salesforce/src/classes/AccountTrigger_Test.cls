/*****************************************************************************************************************
Author      : MST Solutions
Date        : 6/1/2016
Description : 
*******************************************************************************************************************/
@IsTest
public class AccountTrigger_Test {

    @TestSetup static void createRecords() {
        insert OrientationandTrainingUtil.createrSystemAdminUser();
    }

    @IsTest
    static void inKindDonor() {
        User sysAdmin = [
                SELECT Id, Username, Email
                FROM User
                WHERE Email = :'testmawa@gmail.com'
                LIMIT 1
        ];
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccountWithWishCoordinatior(sysAdmin.Id);
        insert chapterAccount;

        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        insert volunteerContact;

        System.runAs (new User(Id = UserInfo.getUserId())) {
            User volunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
            insert volunteerUser;
        }
        Id inKindDonorsAccountRTId = Constant_AC.IN_KIND_ACCOUNT_ID;
        Account inkindAccount = new Account();
        inkindAccount.Name = 'InKind Account';
        inkindAccount.RecordTypeId = inKindDonorsAccountRTId;
        inkindAccount.Chapter_Name__c = chapterAccount.Id;
        insert inkindAccount;
        inkindAccount.Wish_Co_ordinator__c = sysAdmin.Id;
        update inkindAccount;
    }

    @IsTest
    static void inKindDonorUpdateChapterName() {
        User sysAdmin = [
                SELECT Id, Username,Email
                FROM User
                WHERE Email = :'testmawa@gmail.com'
                LIMIT 1
        ];
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccountWithWishCoordinatior(sysAdmin.Id);
        insert chapterAccount;

        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        insert volunteerContact;

        System.runAs (new User(Id = UserInfo.getUserId())) {
            User volunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
            insert volunteerUser;
        }

        Account inkindAccount = OrientationandTrainingUtil.inKindAccountWithStatus();
        inkindAccount.Chapter_Name__c = chapterAccount.Id;
        inkindAccount.In_Kind_Approval_Status__c = 'Rejected';
        insert inkindAccount;
    }

    @IsTest
    static void inKindDonorUpdateNullChapterName() {
        User sysAdmin = [
                SELECT Id, Username,Email
                FROM User
                WHERE Email = :'testmawa@gmail.com'
                LIMIT 1
        ];
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccountWithWishCoordinatior(sysAdmin.Id);
        insert chapterAccount;

        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        insert volunteerContact;

        System.runAs (new User(Id = UserInfo.getUserId())) {
            User volunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
            insert volunteerUser;
        }

        Account inkindAccount = OrientationandTrainingUtil.inKindAccountWithSChpater(chapterAccount.Id);
        inkindAccount.In_Kind_Approval_Status__c = 'Approved';
        insert inkindAccount;
    }

    @IsTest
    static void wishCoordinatorNotNull() {
        User sysAdmin = [
                SELECT Id, Username,Email
                FROM User
                WHERE Email = :'testmawa@gmail.com'
                LIMIT 1
        ];
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccountWithWishCoordinatior(sysAdmin.Id);
        insert chapterAccount;

        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        insert volunteerContact;

        User volunteerUser = new User();
        System.runAs (new User(Id = UserInfo.getUserId())) {
            volunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
            insert volunteerUser;
        }

        System.runAs(volunteerUser) {
            Account inkindAccount = OrientationandTrainingUtil.inKindAccount();

            try {
                insert inkindAccount;
            } catch (Exception e) {
                Boolean expectedExceptionThrown = (e.getMessage().contains('There is no approver for this account.')) ? true : false;
                System.assertEquals(expectedExceptionThrown, false);
            }

        }
    }

    @IsTest
    static void accountWishCoordinatorAsNull() {
        User sysAdmin = [
                SELECT Id,Username,Email
                FROM User
                WHERE Email = :'testmawa@gmail.com'
                LIMIT 1
        ];
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccountWithWishCoordinatior(sysAdmin.Id);
        insert chapterAccount;
        chapterAccount.Wish_Co_ordinator__c = null;
        update chapterAccount;
        chapterAccount.Wish_Co_ordinator__c = UserInfo.getUserId();
        update chapterAccount;
        chapterAccount.Wish_Co_ordinator__c = sysAdmin.Id;
        update chapterAccount;

        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        insert volunteerContact;

        User volunteerUser = new User();
        System.runAs (new User(Id = UserInfo.getUserId())) {
            volunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
            insert volunteerUser;
        }
        System.runAs(volunteerUser) {
            Account inkindAccount = OrientationandTrainingUtil.inKindAccount();
            Database.SaveResult result = Database.insert(inkindAccount, false);
            System.assertEquals('There is no wish coordinator to approve this record', result.getErrors()[0].getMessage());
        }
    }

    @IsTest
    static void chapterName() {
        User sysAdmin = [
                SELECT Id, Username,Email
                FROM User
                WHERE Email = :'testmawa@gmail.com'
                LIMIT 1
        ];
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccountWithWishCoordinatior(sysAdmin.Id);
        insert chapterAccount;

        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        insert volunteerContact;

        User volunteerUser = new User();
        System.runAs (new User(Id = UserInfo.getUserId())) {
            volunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
            insert volunteerUser;
        }
        System.runAs(volunteerUser) {
            Account inkindAccount = OrientationandTrainingUtil.inKindAccount();
            try {
                insert inkindAccount;
            } catch (Exception e) {
            }
        }
    }

    @IsTest
    static void AddFlagonHouseHoldAccount() {
        Bypass_Triggers__c turnOnHouseHold = new Bypass_Triggers__c();
        turnOnHouseHold.SetupOwnerId = UserInfo.getUserId();
        insert turnOnHouseHold;
        Account chapterAccount = OrientationandTrainingUtil.HouseHoldAccount();
        insert chapterAccount;
    }

    @IsTest
    static void updateChapterAccountDevEmail() {
        User sysAdmin = [
                SELECT Id, Username,Email
                FROM User
                WHERE Email = :'testmawa@gmail.com'
                LIMIT 1
        ];
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccountWithWishCoordinatior(sysAdmin.Id);
        insert chapterAccount;

        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithStatus();
        parentCase.ChapterName__c = chapterAccount.Id;
        parentCase.Closed_Date__c = System.today();
        insert parentCase;

        Contact wishChildCon = OrientationandTrainingUtil.CreateWishChildCon();
        insert wishChildCon;

        Case wishGranting = OrientationandTrainingUtil.createWishGrantCase(wishChildCon.Id, parentCase.Id);
        insert wishGranting;

        chapterAccount.DevStaffEmail__c = 'chandru.406@gmail.com';
        update chapterAccount;
    }

    @IsTest
    static void updateHouseHoldAccount() {
        Account houseHoldAccouont = OrientationandTrainingUtil.HouseHoldAccount();
        insert houseHoldAccouont;

        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithStatus();
        insert parentCase;

        houseHoldAccouont.Emergency_Contact_Phone__c = '9877665544';
        update houseHoldAccouont;
    }

    @IsTest
    static void createInkindSysAdmin() {
        User sysAdmin = [
                SELECT Id, Username, Email
                FROM User
                WHERE Email = :'testmawa@gmail.com'
                LIMIT 1
        ];
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccountWithWishCoordinatior(sysAdmin.Id);
        insert chapterAccount;

        Id inKindDonorsAccountRTId = Constant_AC.IN_KIND_ACCOUNT_ID;
        System.runAs(sysAdmin) {
            Account inkindAccount = new Account();
            inkindAccount.Name = 'InKind Account';
            inkindAccount.RecordTypeId = inKindDonorsAccountRTId;
            inkindAccount.Chapter_Name__c = chapterAccount.Id;
            insert inkindAccount;
        }
    }
}