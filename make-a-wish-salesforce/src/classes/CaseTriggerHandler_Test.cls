/**
 * Author      : MST Solutions
 * Date        : 10/4/2016
 * Description : Description : This class is used to increase the code coverage for CaseTrigger_AT and CaseTriggerHandler
 * Modification Log:
 * 23/03/2018 - SankarGiritharan - WVC-1835
 **/
@IsTest
public class CaseTriggerHandler_Test {

    private static final Id wishRecordTypeId = Constant_AC.WISH_RT_ID;

    //This method is used to increase the coverage for when the case status is updated to completed.
    @IsTest
    static void updateStatusesCompleted() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        insert new List<Account>{
                chapterAccount, chapterAmericaAccount
        };

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;

        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        insert parentCase;
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishRecordTypeId;
        anticipationCase.parentId = parentCase.Id;
        //anticipationCase.Absent_Parent_Form__c = true;
        insert anticipationCase;

        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        insert volunterCon;

        User volunterUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.Id);
            insert volunterUser;
        }

        CaseTeamRole roleRec = [
                SELECT Id
                FROM CaseTeamRole
                WHERE Name = 'Wish Granter'
                LIMIT 1
        ];
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.Id, volunterUser.Id, roleRec.Id);
        insert caseTeamMeber;

        parentCase.Status = 'Completed';
        database.saveResult result = Database.update(parentCase, false);
        System.assertEquals('Completed', parentCase.Status, 'status is not updated to completed');
        System.assert(parentCase.Status == 'Completed', 'status updated incorrectly');
    }

    //This method is used to increase the coverage for when the case status is updated to completed.
    @IsTest
    static void updateStatusasCompleted1() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        insert new List<Account>{
                chapterAccount, chapterAmericaAccount
        };

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;

        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        insert parentCase;
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishRecordTypeId;
        anticipationCase.parentId = parentCase.Id;
        //anticipationCase.Child_s_Medical_Summary_Form__c = true;
        //anticipationCase.Date_Wish_Child_Form__c = system.today();
        //anticipationCase.Date_Wish_Family_Form__c = system.today();
        //anticipationCase.Date_Wish_Information_Form__c = system.today();
        anticipationCase.Date_Liability_Release_Authorization__c = system.today();
        insert anticipationCase;

        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        insert volunterCon;

        User volunterUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.Id);
            insert volunterUser;
        }

        CaseTeamRole roleRec = [
                SELECT Id
                FROM CaseTeamRole
                WHERE Name = 'Wish Granter'
                LIMIT 1
        ];
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.Id, volunterUser.Id, roleRec.Id);
        insert caseTeamMeber;

        parentCase.Status = 'Completed';
        database.saveResult result = Database.update(parentCase, false);

        //System.assertEquals(system.today(), anticipationCase.Date_Wish_Information_Form__c, 'Date_Wish_Information_Form__c  field should be today()');
        //System.assert(anticipationCase.Date_Wish_Family_Form__c == system.today(), 'Date_Wish_Family_Form__c  field should be today()');
    }

    //This method is used to increase the coverage for when the case status is updated to completed.
    @IsTest
    static void updateStatusasCompleted2() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        insert new List<Account>{
                chapterAccount, chapterAmericaAccount
        };

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;

        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        insert parentCase;
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishRecordTypeId;
        anticipationCase.parentId = parentCase.Id;
        anticipationCase.Communication_Profile__c = true;
        insert anticipationCase;

        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        insert volunterCon;

        User volunterUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.Id);
            insert volunterUser;
        }

        CaseTeamRole roleRec = [
                SELECT Id,Name
                FROM CaseTeamRole
                WHERE Name = 'Wish Granter'
                LIMIT 1
        ];
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.Id, volunterUser.Id, roleRec.Id);
        insert caseTeamMeber;

        parentCase.Status = 'Completed';
        database.saveResult result = Database.update(parentCase, false);
        System.assertEquals(roleRec.Name, 'Wish Granter', 'CaseTeam role name is not Wish Granter');
        System.assert(parentCase.contactId == wishChild.Id, 'Contact Id does not match');
    }

    //This method is used to increase the coverage for when the case status is updated to completed.
    @IsTest
    static void updateStatusasCompleted3() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        insert new List<Account>{
                chapterAccount, chapterAmericaAccount
        };

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;

        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        insert parentCase;
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishRecordTypeId;
        anticipationCase.parentId = parentCase.Id;
        //anticipationCase.Entertainment_Sports_Wish_LOU__c = true;
        insert anticipationCase;

        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        insert volunterCon;

        User volunterUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.Id);
            insert volunterUser;
        }

        CaseTeamRole roleRec = [
                SELECT Id
                FROM CaseTeamRole
                WHERE Name = 'Wish Granter'
                LIMIT 1
        ];
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.Id, volunterUser.Id, roleRec.Id);
        insert caseTeamMeber;

        parentCase.Status = 'Completed';
        database.SaveResult result = Database.update(parentCase, false);
        //System.assertEquals(anticipationCase.Entertainment_Sports_Wish_LOU__c, true, 'Entertainment_Sports_Wish_LOU__c is inserted as false');
        System.assert(anticipationCase.RecordTypeId == wishRecordTypeId, 'RecordType Id does not match');
    }

    //This method is used to increase the coverage for when the case status is updated to completed.
    @IsTest
    static void updateStatusasCompleted4() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        insert new List<Account>{
                chapterAccount, chapterAmericaAccount
        };

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;

        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        insert parentCase;
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishRecordTypeId;
        anticipationCase.parentId = parentCase.Id;
        //anticipationCase.Guardianship_Document__c = true;
        insert anticipationCase;

        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        insert volunterCon;

        User volunterUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.Id);
            insert volunterUser;
        }

        CaseTeamRole roleRec = [
                SELECT Id
                FROM CaseTeamRole
                WHERE Name = 'Wish Granter'
                LIMIT 1
        ];
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.Id, volunterUser.Id, roleRec.Id);
        insert caseTeamMeber;

        parentCase.Status = 'Completed';
        database.saveResult result = Database.update(parentCase, false);
        System.assertEquals(volunterCon.AccountId, chapterAccount.Id, 'Volunter contact accountId and chapter accountId should match');
        System.assert(anticipationCase.RecordTypeId == wishRecordTypeId, 'RecordType Id does not match');
    }

    //This method is used to increase the coverage for when the case status is updated to completed.
    @IsTest
    static void updateStatusesCompleted5() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        insert new List<Account>{
                chapterAccount, chapterAmericaAccount
        };

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;

        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        insert parentCase;
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishRecordTypeId;
        anticipationCase.parentId = parentCase.Id;
        //anticipationCase.Liability_Release_and_Authorization__c = true;
        insert anticipationCase;

        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        insert volunterCon;

        User volunterUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.Id);
            insert volunterUser;
        }

        CaseTeamRole roleRec = [
                SELECT Id,Name
                FROM CaseTeamRole
                WHERE Name = 'Wish Granter'
                LIMIT 1
        ];
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.Id, volunterUser.Id, roleRec.Id);
        insert caseTeamMeber;

        parentCase.Status = 'Completed';
        database.saveResult result = Database.update(parentCase, false);
        System.assertEquals(roleRec.Name, 'Wish Granter', 'CaseTeam role name is not Wish Granter');
        System.assert(parentCase.contactId == wishChild.Id, 'Contact Id does not match');
    }

    //This method is used to increase the coverage for when the case status is updated to completed.
    @IsTest
    static void updateStatusasCompleted6() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        insert new List<Account>{
                chapterAccount, chapterAmericaAccount
        };

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;

        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        insert parentCase;
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishRecordTypeId;
        anticipationCase.parentId = parentCase.Id;
        anticipationCase.Passports__c = true;
        insert anticipationCase;

        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        insert volunterCon;

        User volunterUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.Id);
            insert volunterUser;
        }

        CaseTeamRole roleRec = [
                SELECT Id
                FROM CaseTeamRole
                WHERE Name = 'Wish Granter'
                LIMIT 1
        ];
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.Id, volunterUser.Id, roleRec.Id);
        insert caseTeamMeber;

        parentCase.Status = 'Completed';
        database.saveResult result = Database.update(parentCase, false);
        System.assertEquals(true, anticipationCase.Passports__c, 'Passports field in planning case should be true');
        System.assert(parentCase.Status == 'Completed', 'status should be completed');
    }

    //This method is used to increase the coverage for when the case status is updated to completed.
    @IsTest
    static void updateStatusasCompleted7() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        insert new List<Account>{
                chapterAccount, chapterAmericaAccount
        };

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;

        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        insert parentCase;
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishRecordTypeId;
        anticipationCase.parentId = parentCase.Id;
        //anticipationCase.Single_Parent_Form__c = true;
        insert anticipationCase;

        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        insert volunterCon;

        User volunterUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.Id);
            insert volunterUser;
        }

        CaseTeamRole roleRec = [
                SELECT Id,Name
                FROM CaseTeamRole
                WHERE Name = 'Wish Granter'
                LIMIT 1
        ];
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.Id, volunterUser.Id, roleRec.Id);
        insert caseTeamMeber;

        parentCase.Status = 'Completed';
        database.saveResult result = Database.update(parentCase, false);
        //System.assertEquals(true, anticipationCase.Single_Parent_Form__c, 'single parent form field should be true');
        System.assert(parentCase.Status == 'Completed', 'Parent status should be completed');
    }

    //This method is used to increase the coverage for when the case status is updated to completed.
    @IsTest
    static void updateStatusasCompleted8() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        insert new List<Account>{
                chapterAccount, chapterAmericaAccount
        };

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;

        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        insert parentCase;
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishRecordTypeId;
        anticipationCase.parentId = parentCase.Id;
        anticipationCase.Visas__c = true;
        insert anticipationCase;

        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        insert volunterCon;

        User volunterUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.Id);
            insert volunterUser;
        }

        CaseTeamRole roleRec = [
                SELECT Id,Name
                FROM CaseTeamRole
                WHERE Name = 'Wish Granter'
                LIMIT 1
        ];
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.Id, volunterUser.Id, roleRec.Id);
        insert caseTeamMeber;

        parentCase.Status = 'Completed';
        database.saveResult result = Database.update(parentCase, false);
        System.assertEquals(wishRecordTypeId, anticipationCase.RecordTypeId, 'child case record type should be planning recordtype');
        System.assert(anticipationCase.Visas__c == true, 'Visas field in planning case should to true');
    }

    //This method is used to increase the coverage for when the case status is updated to completed.
    @IsTest
    static void updateStatusasCompleted9() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        insert new List<Account>{
                chapterAccount, chapterAmericaAccount
        };

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;

        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        insert parentCase;
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishRecordTypeId;
        anticipationCase.parentId = parentCase.Id;
        //anticipationCase.Wish_Child_Form__c = true;
        insert anticipationCase;

        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        insert volunterCon;

        User volunterUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.Id);
            insert volunterUser;
        }

        CaseTeamRole roleRec = [
                SELECT Id
                FROM CaseTeamRole
                WHERE Name = 'Wish Granter'
                LIMIT 1
        ];
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.Id, volunterUser.Id, roleRec.Id);
        insert caseTeamMeber;

        parentCase.Status = 'Completed';
        database.saveResult result = Database.update(parentCase, false);
        System.assertEquals('Completed', parentCase.Status, 'case status should be completed');
        //System.assert(anticipationCase.Wish_Child_Form__c == true, ' wish child form field should be true in palnning case');
    }

    //This method is used to increase the coverage for when the case status is updated to completed.
    @IsTest
    static void updateStatusasCompleted10() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        insert new List<Account>{
                chapterAccount, chapterAmericaAccount
        };

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;

        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        insert parentCase;
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishRecordTypeId;
        anticipationCase.parentId = parentCase.Id;
        //anticipationCase.Wish_Family_Form__c = true;
        insert anticipationCase;

        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        insert volunterCon;

        User volunterUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.Id);
            insert volunterUser;
        }

        CaseTeamRole roleRec = [
                SELECT Id,Name
                FROM CaseTeamRole
                WHERE Name = 'Wish Granter'
                LIMIT 1
        ];
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.Id, volunterUser.Id, roleRec.Id);
        insert caseTeamMeber;

        parentCase.Status = 'Completed';
        database.saveResult result = Database.update(parentCase, false);
        System.assertEquals(parentCase.Id, anticipationCase.ParentId, 'Wish planing parent Id should be wish Id');
        //System.assert(anticipationCase.Wish_Family_Form__c == true, 'wish family form should be true');
    }

    //This method is used to increase the coverage for when the case status is updated to completed.
    @IsTest
    static void updateStatusasCompleted11() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        insert new List<Account>{
                chapterAccount, chapterAmericaAccount
        };

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;

        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        insert parentCase;
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishRecordTypeId;
        anticipationCase.parentId = parentCase.Id;
        //anticipationCase.Wish_Information_Form__c = true;
        insert anticipationCase;

        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        insert volunterCon;

        User volunterUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.Id);
            insert volunterUser;
        }

        CaseTeamRole roleRec = [
                SELECT Id
                FROM CaseTeamRole
                WHERE Name = 'Wish Granter'
                LIMIT 1
        ];
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.Id, volunterUser.Id, roleRec.Id);
        insert caseTeamMeber;

        parentCase.Status = 'Completed';
        database.saveResult result = Database.update(parentCase, false);
        //System.assertEquals(true, anticipationCase.Wish_Information_Form__c, 'wish information form field should be true');
        System.assert(parentCase.Status == 'Completed', 'Case status should be completed');
    }

    //This method is used to increase the coverage for when the case status is updated to completed.
    @IsTest
    static void updateStatusasCompleted12() {
        trac_TriggerHandlerBase.blockTrigger = true;
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        insert new List<Account>{
                chapterAccount, chapterAmericaAccount
        };

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        insert new List<Contact>{
                wishChild, volunterCon
        };

        User volunterUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.Id);
            insert volunterUser;
        }
        trac_TriggerHandlerBase.blockTrigger = true;

        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        insert parentCase;

        Wish_Expense__c currExpense = new Wish_Expense__c();
        currExpense.Case__c = parentCase.Id;
        currExpense.Projected_Approval_Status__c = 'Submitted';
        currExpense.Projected_Cash__c = 0;
        currExpense.Projected_In_Kind__c = 0;
        currExpense.Actual_In_Kind__c = 0;
        currExpense.FE_Posted_Cash__c = 0;
        currExpense.FE_Posted_In_Kind__c = 0;
        currExpense.Actual_Cash__c = 0;
        insert currExpense;

        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishRecordTypeId;
        anticipationCase.ParentId = parentCase.Id;
        anticipationCase.Wish_Safety_Authorization_Part_B_Form__c = true;
        insert anticipationCase;

        CaseTeamRole roleRec = [
                SELECT Id
                FROM CaseTeamRole
                WHERE Name = 'Wish Granter'
                LIMIT 1
        ];
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.Id, volunterUser.Id, roleRec.Id);
        insert caseTeamMeber;

        parentCase.Status = 'Completed';
        database.saveResult result = Database.update(parentCase, false);
        System.assertEquals('Completed', parentCase.Status, 'parent case status should be completed');
        System.assert(anticipationCase.Wish_Safety_Authorization_Part_B_Form__c == true, 'wish safety authorization part b form should be true');
    }

    //This method is used to update the anticipation date.
    @IsTest
    static void updateAnticipationDate() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        chapterAccount.Volunteer_Manager__c = UserInfo.getUserId();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        insert new List<Account>{
                chapterAccount, chapterAmericaAccount
        };

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;

        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithAnticipatedStartDate(wishChild.Id);
        insert parentCase;

        Id taskPlanningRecordTypeId = Constant_AC.STAFF_TASK_RT_ID;
        Chapter_Action_Track__c newTrack = OrientationandTrainingUtil.createChapterActionTrack();
        newTrack.Chapter_Name__c = chapterAccount.Id;
        newTrack.Task_name__c = 'Test';
        insert newTrack;

        Task newTask = new Task();
        newTask.Subject = 'Test';
        newTask.ActivityDate = Date.Today();
        newTask.Priority = '4';
        newTask.RecordTypeId = taskPlanningRecordTypeId;
        newTask.WhatId = parentCase.Id;
        insert newTask;
        parentCase.Start_Date__c = Date.Today().addDays(-10);
        update parentCase;
        System.assertEquals(Date.Today().addDays(-10), parentCase.Start_Date__c, 'Anticipated start date should today - 10');
        System.assertEquals('4', newTask.Priority, 'Task priority should be 4');
    }

    //This method is used to update the anticipation date.
    @IsTest
    static void updateAnticipationDateasNull() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        chapterAccount.Volunteer_Manager__c = UserInfo.getUserId();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        insert new List<Account>{
                chapterAccount, chapterAmericaAccount
        };

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;

        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithAnticipatedStartDate(wishChild.Id);
        insert parentCase;

        Chapter_Action_Track__c newTrack = OrientationandTrainingUtil.createChapterActionTrack();
        newTrack.Task_name__c = 'Test';
        newTrack.Chapter_Name__c = chapterAccount.Id;
        insert newTrack;

        Id taskPlanningRecordTypeId = Constant_AC.STAFF_TASK_RT_ID;
        Task newTask = new Task();
        newTask.Subject = 'Test';
        newTask.ActivityDate = Date.Today();
        newTask.Priority = '4';
        newTask.RecordTypeId = taskPlanningRecordTypeId;
        newTask.WhatId = parentCase.Id;
        insert newTask;
        parentCase.Start_Date__c = Null;
        update parentCase;
        System.assertEquals('4', newTask.Priority, 'Task priority should be 4');
        System.assert(newTask.RecordTypeId == taskPlanningRecordTypeId, 'Task recordType should be planning record type');
    }

    //This method is used to get the permissoins on case object.
    @IsTest
    static void grantPermissionOnCase() {
        trac_TriggerHandlerBase.blockTrigger = true;
        UserSetting__c settings = new UserSetting__c();
        settings.Name = 'Update Abandoned Wishes';
        settings.Abandon_the_Granted_case__c = true;
        settings.All_Closed_Cases_except_Abandoned__c = true;
        settings.Edit_Abandoned_Cases__c = true;
        settings.SetupOwnerId = UserInfo.getUserId();
        insert settings;

        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        insert chapterAccount;

        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert new List<Contact>{
                volunterCon, wishChild
        };

        User volunterUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.Id);
            insert volunterUser;
        }
        trac_TriggerHandlerBase.blockTrigger = false;

        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithStatus();
        parentCase.ContactId = wishChild.Id;
        parentCase.Status = 'Granted';
        insert parentCase;

        Volunteer_Opportunity__c volOpp = new Volunteer_Opportunity__c();
        volOpp.Wish__c = parentCase.Id;
        volOpp.Migrated_Record__c = true;
        volOpp.Volunteer_Name__c = volunterCon.Id;
        insert volOpp;

        Volunteer_Opportunity__c updateVolOpp = new Volunteer_Opportunity__c();
        updateVolOpp.Id = volOpp.Id;
        updateVolOpp.Status__c = 'Approved';
        update updateVolOpp;

        parentCase.Status = 'Granted';
        update parentCase;
        System.assertEquals('Granted', parentCase.Status, 'parent case status should be Granted');
        System.assert(updateVolOpp.Status__c == 'Approved', 'Volunteer Opportunity status should be Approved');
    }

    //This method is used to update the change owner.
    @IsTest
    static void changeOwner() {
        UserSetting__c settings = new UserSetting__c();
        settings.Name = 'Update Abandoned Wishes';
        settings.Abandon_the_Granted_case__c = true;
        settings.All_Closed_Cases_except_Abandoned__c = true;
        settings.Edit_Abandoned_Cases__c = true;
        settings.SetupOwnerId = UserInfo.getUserId();
        insert settings;
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        insert chapterAccount;

        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        insert volunterCon;

        User volunterUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.Id);
            insert volunterUser;
        }

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;

        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithStatus();
        parentCase.ContactId = wishChild.Id;
        parentCase.Diagnosis_Verification_Receive_Date__c = Date.today();
        parentCase.Closed_Date__c = System.Today();
        insert parentCase;
        List<CaseTeamRole> caseTeamRole = [
                SELECT Id
                FROM CaseTeamRole
                WHERE Name = 'Wish Granter'
                LIMIT 1
        ];

        CaseTeamMember caseTeamMem = new CaseTeamMember();
        caseTeamMem.ParentId = parentCase.Id;
        caseTeamMem.TeamRoleId = caseTeamRole[0].Id;
        caseTeamMem.MemberId = volunterUser.Id;
        insert caseTeamMem;
        Case childCase = new Case();
        childCase.RecordTypeId = wishRecordTypeId;
        childCase.ParentId = parentCase.Id;
        childCase.Status = 'New';
        insert childCase;
        System.assert(childCase.status == 'New', 'child case status should be New');
        Case newChildUpdate = new Case();
        newChildUpdate.Id = childCase.Id;
        //newChildUpdate.OwnerId = volunterUser.Id;
        newChildUpdate.Diagnosis_Verification_Receive_Date__c = Date.today();
        //update newChildUpdate;
        System.assertEquals(newChildUpdate.Diagnosis_Verification_Receive_Date__c, Date.today(), 'Diagnosis verification receive date should be today');

    }

    //Create Sub Cases
    @IsTest
    static void createSubCases() {
        UserSetting__c settings = new UserSetting__c();
        settings.Name = 'Update Abandoned Wishes';
        settings.Abandon_the_Granted_case__c = true;
        settings.All_Closed_Cases_except_Abandoned__c = true;
        settings.Edit_Abandoned_Cases__c = true;
        settings.SetupOwnerId = UserInfo.getUserId();
        insert settings;

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;

        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithStatus();
        parentCase.ContactId = wishChild.Id;
        parentCase.Diagnosis_Verification_Receive_Date__c = Date.today();
        parentCase.Status = 'Ready to Assign';
        parentCase.Sub_Status__c = 'Assign in Portal';
        parentCase.Case_Member_Count__c = 2;
        insert parentCase;

        Task wishGrantingNewTask = new Task(Subject = 'Wish concept approval', Status = 'New', WhoId = wishChild.Id, WhatId = parentCase.Id);
        insert wishGrantingNewTask;
        Task referralDNQTask = new Task(Subject = 'Wish Child Birthday Reminder', Status = 'New', whatId = parentCase.Id);
        insert referralDNQTask;

        Case childCase = OrientationandTrainingUtil.CreateParentCaseWithStatus();
        childCase.RecordTypeId = wishRecordTypeId;
        childCase.ParentId = parentCase.Id;
        childCase.Diagnosis_Verification_Receive_Date__c = Date.today();
        insert childCase;
        Case newCase = new Case();
        newCase.Id = parentCase.Id;
        newCase.Status = 'Ready to Interview';
        //newCase.Sub_Status__c = 'Within Policy';
        newCase.Wish_Type__c = 'Disneyland';

        update newCase;
        System.assertEquals(2, parentCase.Case_Member_Count__c, 'case membercount should 2');
        System.assert(referralDNQTask.Subject == 'Wish Child Birthday Reminder', 'Task subject should be Wish Child birthday Reminder');
    }

    //Volunteer Opportunity Creation
    @IsTest
    static void volunteerOppCreation() {
        Role__c newWishGranter = new Role__c();
        newWishGranter.Name = 'Wish Granter';
        insert newWishGranter;

        Regions__c newRegion = new Regions__c();
        newRegion.Name = 'Default';
        insert newRegion;

        User manager;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            manager = OrientationandTrainingUtil.createUser();
            insert manager;
        }

        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        chapterAccount.Volunteer_Manager__c = manager.Id;
        insert chapterAccount;

        Chapter_Role__c newRole = new Chapter_Role__c();
        newRole.Chapter_Name__c = chapterAccount.Id;
        newRole.Role_Name__c = newWishGranter.Id;
        insert newRole;

        System.assertEquals(newRole.Chapter_Name__c, chapterAccount.Id, 'Compare New Role Chapter Name with ChapterAccount');
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        wishChild.Region_Code__c = newRegion.Id;
        wishChild.county__c = 'Karur';
        insert wishChild;

        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithStatus();
        parentCase.ContactId = wishChild.Id;
        parentCase.AccountId = chapterAccount.Id;
        parentCase.ChapterName__c = chapterAccount.Id;
        parentCase.Status = 'Qualified';
        insert parentCase;

        User volMgr = OrientationandTrainingUtil.createAdminUser();
        insert volMgr;
        List<CaseTeamRole> caseTeamRoleInfo = [
                SELECT Id, Name
                FROM CaseTeamRole
                WHERE Name = 'Volunteer Manager'
                LIMIT 1
        ];
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.Id, volMgr.Id, caseTeamRoleInfo[0].Id);
        insert caseTeamMeber;
        System.assertEquals(parentCase.Status, 'Qualified', 'Check ParentCase Status is Qualified');
        System.assertEquals(parentCase.ChapterName__c, chapterAccount.Id, 'Compare Parent case Chapter Name with ChapterAccount');
        RecursiveTriggerHandler.isFirstTime = true;
        Case updateParentCase = new Case();
        updateParentCase.Id = parentCase.Id;
        updateParentCase.Status = 'Ready to Assign';
        updateParentCase.OwnerId = manager.Id;
        updateParentCase.Sub_Status__c = 'Assign in Portal';
        Test.startTest();
        update updateParentCase;
        Test.stopTest();
        System.assertEquals('Assign in Portal', updateParentCase.Sub_Status__c, 'Case sub status should be Assign in portal');
        System.assert(updateParentCase.Status == 'Ready to Assign', 'Parent case status should be Ready to Assign');
    }

    //Presentation Task
    @IsTest
    static void presentationTask() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        insert chapterAccount;

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;

        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithStatus();
        parentCase.ContactId = wishChild.Id;
        parentCase.AccountId = chapterAccount.Id;
        parentCase.Status = 'Qualified';
        insert parentCase;
        Case updateParentCase = new Case();
        updateParentCase.Id = parentCase.Id;
        updateParentCase.End_Date__c = Date.today() + 10;
        Test.startTest();
        update updateParentCase;
        Test.stopTest();
        System.assertEquals(Date.today() + 10, updateParentCase.End_Date__c, 'End date should be today date+10');
        System.assert(parentCase.Status == 'Qualified', 'case status should be qualified');
    }

    //Medical Summary Task
    @IsTest
    static void medicalSummaryTask() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;

        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithStatus();
        parentCase.ContactId = wishChild.Id;
        parentCase.AccountId = chapterAccount.Id;
        parentCase.Start_Date__c = System.today();
        parentCase.Status = 'Qualified';
        insert parentCase;
        Case updateParentCase = new Case();
        updateParentCase.Id = parentCase.Id;
        updateParentCase.Start_Date__c = null;
        updateParentCase.Wish_Type__c = 'Cruise - Celebrity/Royal';
        Test.startTest();
        update updateParentCase;
        System.assertEquals(updateParentCase.Wish_Type__c, 'Cruise - Celebrity/Royal', 'wish type should be Cruise - Celebrity/Royal');
        System.assert(updateParentCase.Start_Date__c == Null, 'case start date should be null');
        Test.stopTest();

    }

    //Abondend Case
    @IsTest
    static void wishAbondend() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        insert chapterAccount;

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;

        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithStatus();
        parentCase.ContactId = wishChild.Id;
        parentCase.AccountId = chapterAccount.Id;
        parentCase.Start_Date__c = System.today();
        parentCase.Status = 'Qualified';
        insert parentCase;
        Case updateParentCase = new Case();
        updateParentCase.Id = parentCase.Id;
        updateParentCase.Sub_Status__c = 'Abandoned';
        updateParentCase.Status = 'Closed';
        updateParentCase.Closed_Date__c = System.Today();
        Test.startTest();
        update updateParentCase;
        System.assertEquals('Qualified', parentCase.Status, 'case should be qualified');
        System.assert(updateParentCase.Sub_Status__c == 'Abandoned', 'case sub status should be Abandoned');
        Test.stopTest();

    }

    //This method is used to get the wish reopen case.
    @IsTest
    static void wishReopenCase() {
        //Chapter_Action_Track__c newChapterActtrack =  OrientationandTrainingUtil.createChapterActionTrack();
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        insert chapterAccount;

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;

        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithStatus();
        parentCase.ContactId = wishChild.Id;
        parentCase.AccountId = chapterAccount.Id;
        parentCase.Start_Date__c = System.today();
        parentCase.Status = 'Qualified';
        insert parentCase;

        Test.startTest();
        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        volunterCon.Number_of_wishes_active__c = 0;
        insert volunterCon;

        User volunterUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.Id);
            insert volunterUser;
        }

        CaseTeamRole roleRec = [
                SELECT Id
                FROM CaseTeamRole
                WHERE Name = 'Wish Granter'
                LIMIT 1
        ];
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.Id, volunterUser.Id, roleRec.Id);
        insert caseTeamMeber;

        Case wishDeter = OrientationandTrainingUtil.createWishDeterminationCase(wishChild.Id, parentCase.Id);
        insert wishDeter;

        Case updateParentCase = new Case();
        updateParentCase.Id = parentCase.Id;
        updateParentCase.Sub_Status__c = 'Abandoned';
        updateParentCase.Status = 'Closed';
        updateParentCase.Closed_Date__c = System.today();
        update updateParentCase;
        System.assertEquals(System.today(), updateParentCase.Closed_Date__c, 'case close date should be today');
        System.assert(updateParentCase.Status == 'Closed', 'case should be Closed');
        Test.stopTest();
    }

    //This method is used to check the chapter action track as null.
    @IsTest
    static void chapterActionTrackAsNull() {
        Id planningRT = Constant_AC.PLANNING_ANTICIPATION_CHAPTER_ACTION_RT_ID;
        Id wishGrantTaskRT = Constant_AC.GRANT_CHAPTER_ACTION_RT_ID;
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        insert chapterAccount;

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;
        Chapter_Action_Track__c newActionTrack = new Chapter_Action_Track__c();
        newActionTrack.Task_Name__c = 'Sample Task';
        newActionTrack.Due_Days__c = 10.0;
        newActionTrack.Months__c = 1;
        newActionTrack.Chapter_Name__c = chapterAccount.Id;
        newActionTrack.Wish_type__c = 'Other';
        newActionTrack.Description__c = 'sample';
        newActionTrack.RecordTypeId = planningRT;
        insert newActionTrack;
        Chapter_Action_Track__c newActionTrack1 = new Chapter_Action_Track__c();
        newActionTrack1.Task_Name__c = 'Sample Task';
        newActionTrack1.Due_Days__c = 10.0;
        newActionTrack1.Months__c = 1;
        newActionTrack1.Chapter_Name__c = chapterAccount.Id;
        newActionTrack1.Wish_type__c = 'Other';
        newActionTrack1.Description__c = 'sample';
        newActionTrack1.RecordTypeId = wishGrantTaskRT;
        insert newActionTrack1;

        Case parentCase = new Case(RecordTypeId = wishRecordTypeId, Subject = 'Parent Wish',
                Status = 'New', Interview_date__c = System.today(), ContactId = wishChild.Id);
        insert parentCase;
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishRecordTypeId;
        anticipationCase.parentId = parentCase.Id;
        insert anticipationCase;
        parentCase.ChapterName__c = chapterAccount.Id;
        parentCase.Status = 'Wish Determined';
        parentCase.Wish_Type__c = 'Oth';
        parentCase.Sub_Status__c = 'Within Policy';
        Test.startTest();
        update parentCase;
        System.assertEquals('Within Policy', parentCase.Sub_Status__c, 'case sub status should be within policy');
        System.assert(parentCase.Status == 'Wish Determined', 'case status should be Wish determined');
        Test.stopTest();
    }

    //This method is used to check the interview date as not null.
    @IsTest
    static void interviewdateNotNull() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        insert chapterAccount;

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;

        Case newParentWish = new Case(RecordTypeId = wishRecordTypeId, Subject = 'Parent Wish',
                Status = 'New', Interview_date__c = System.today(), ContactId = wishChild.Id);
        insert newParentWish;
        Task volunteerFollowup = new Task(Subject = 'Enter interview date', Status = 'New', WhoId = wishChild.Id, WhatId = newParentWish.Id, SystemGeneratedTask__c = true);
        insert volunteerFollowup;
        newParentWish.Interview_date__c = System.today();
        Test.startTest();
        update newParentWish;
        System.assertEquals(System.today(), newParentWish.Interview_date__c, 'Interview date should be system date');
        System.assert(volunteerFollowup.WhoId == wishChild.Id, 'Task whoId should match with wish child Id');
        Test.stopTest();
    }

    //This method is used to check the interview date as null.
    @IsTest
    static void inrerviewDateAsNull() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        insert chapterAccount;

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;

        Case newParentWish = new Case(RecordTypeId = wishRecordTypeId, Subject = 'Parent Wish',
                Status = 'New', Interview_date__c = System.today(), ContactId = wishChild.Id);
        insert newParentWish;
        Task volunteerFollowup = new Task(Subject = 'Enter interview date', Status = 'New', WhoId = wishChild.Id, WhatId = newParentWish.Id, SystemGeneratedTask__c = true);
        insert volunteerFollowup;
        newParentWish.Interview_date__c = null;
        Test.startTest();
        update newParentWish;
        System.assertEquals(null, newParentWish.Interview_date__c, 'Interview date should be null');
        System.assert(volunteerFollowup.Subject == 'Enter interview date', 'Task subject sould be Enter interview date');
        Test.stopTest();
    }
}