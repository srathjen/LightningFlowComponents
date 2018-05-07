/*****************************************************************************************************************
Author      : MST Solutions
Date        : 10/4/2016
Description : Description : This class is used to increase the code coverage for CaseTrigger_AT and CaseTriggerHandler
Modification Log: 
23/03/2018 - SankarGiritharan - WVC-1835
*******************************************************************************************************************/
@isTest
public class CaseTriggerHandler_Test {
    
    //This method is used to increase the coverage for when the case status is updated to completed. 
    Static testMethod void updateStatusasCompleted()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Constant_AC constant = new Constant_AC();
        Id wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();        
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishPlanningRecordTypeId;
        anticipationCase.parentId = parentCase.id;
        anticipationCase.Absent_Parent_Form__c = true;
        insert anticipationCase;
        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        User volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.id);
        CaseTeamRole roleRec = [SELECT Id FROM CaseTeamRole WHERE Name = 'Wish Granter' Limit 1];       
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.id,volunterUser.id,roleRec.id);
        parentCase.Status = 'Completed';
        database.saveResult result = Database.update(parentCase,false);
        System.assertEquals('Completed',parentCase.Status,'status is not updated to completed');
        System.assert(parentCase.Status == 'Completed','status updated incorrectly');
    }
    //This method is used to increase the coverage for when the case status is updated to completed. 
    Static testMethod void updateStatusasCompleted1()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Constant_AC constant = new Constant_AC();
        Id wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();        
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishPlanningRecordTypeId;
        anticipationCase.parentId = parentCase.id;
        anticipationCase.Child_s_Medical_Summary_Form__c = true;
        anticipationCase.Date_Wish_Child_Form__c = system.today();
        anticipationCase.Date_Wish_Family_Form__c = system.today();
        anticipationCase.Date_Wish_Information_Form__c = system.today();
        anticipationCase.Date_Liability_Release_Authorization__c = system.today();
        insert anticipationCase;
        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        User volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.id);
        CaseTeamRole roleRec = [SELECT Id FROM CaseTeamRole WHERE Name = 'Wish Granter' Limit 1];       
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.id,volunterUser.id,roleRec.id);
        parentCase.Status = 'Completed';
        database.saveResult result = Database.update(parentCase,false);
       
        System.assertEquals(system.today(),anticipationCase.Date_Wish_Information_Form__c ,'Date_Wish_Information_Form__c  field should be today()');
        System.assert(anticipationCase.Date_Wish_Family_Form__c == system.today(),'Date_Wish_Family_Form__c  field should be today()');
    }
    //This method is used to increase the coverage for when the case status is updated to completed. 
    Static testMethod void updateStatusasCompleted2()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Constant_AC constant = new Constant_AC();
        Id wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();        
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishPlanningRecordTypeId;
        anticipationCase.parentId = parentCase.id;
        anticipationCase.Communication_Profile__c = true;
        insert anticipationCase;
        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        User volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.id);
        CaseTeamRole roleRec = [SELECT Id,Name FROM CaseTeamRole WHERE Name = 'Wish Granter' Limit 1];       
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.id,volunterUser.id,roleRec.id);
        parentCase.Status = 'Completed';
        database.saveResult result = Database.update(parentCase,false);
        System.assertEquals(roleRec.Name,'Wish Granter','CaseTeam role name is not Wish Granter');
        System.assert(parentCase.contactId == wishChild.Id,'Contact Id does not match');
    }
    //This method is used to increase the coverage for when the case status is updated to completed. 
    Static testMethod void updateStatusasCompleted3()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Constant_AC constant = new Constant_AC();
        Id wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();        
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishPlanningRecordTypeId;
        anticipationCase.parentId = parentCase.id;
        anticipationCase.Entertainment_Sports_Wish_LOU__c = true;
        insert anticipationCase;
        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        User volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.id);
        CaseTeamRole roleRec = [SELECT Id FROM CaseTeamRole WHERE Name = 'Wish Granter' Limit 1];       
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.id,volunterUser.id,roleRec.id);
        parentCase.Status = 'Completed';
        database.saveResult result = Database.update(parentCase,false);
        System.assertEquals(anticipationCase.Entertainment_Sports_Wish_LOU__c, true,'Entertainment_Sports_Wish_LOU__c is inserted as false');
        System.assert(anticipationCase.RecordTypeId == wishPlanningRecordTypeId,'RecordType Id does not match');
    }
    //This method is used to increase the coverage for when the case status is updated to completed. 
    Static testMethod void updateStatusasCompleted4()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Constant_AC constant = new Constant_AC();
        Id wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();        
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishPlanningRecordTypeId;
        anticipationCase.parentId = parentCase.id;
        anticipationCase.Guardianship_Document__c = true;
        insert anticipationCase;
        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        User volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.id);
        CaseTeamRole roleRec = [SELECT Id FROM CaseTeamRole WHERE Name = 'Wish Granter' Limit 1];       
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.id,volunterUser.id,roleRec.id);
        parentCase.Status = 'Completed';
        database.saveResult result = Database.update(parentCase,false);
        System.assertEquals(volunterCon.AccountId,chapterAccount.Id,'Volunter contact accountId and chapter accountId should match');
        System.assert(anticipationCase.RecordTypeId == wishPlanningRecordTypeId,'RecordType Id does not match');
    }
    //This method is used to increase the coverage for when the case status is updated to completed. 
    Static testMethod void updateStatusasCompleted5()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Constant_AC constant = new Constant_AC();
        Id wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();        
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishPlanningRecordTypeId;
        anticipationCase.parentId = parentCase.id;
        anticipationCase.Liability_Release_and_Authorization__c = true;
        insert anticipationCase;
        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        User volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.id);
        CaseTeamRole roleRec = [SELECT Id,Name FROM CaseTeamRole WHERE Name = 'Wish Granter' Limit 1];       
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.id,volunterUser.id,roleRec.id);
        parentCase.Status = 'Completed';
        database.saveResult result = Database.update(parentCase,false);
        System.assertEquals(roleRec.Name,'Wish Granter','CaseTeam role name is not Wish Granter');
        System.assert(parentCase.contactId == wishChild.Id,'Contact Id does not match');
    }
    //This method is used to increase the coverage for when the case status is updated to completed. 
    Static testMethod void updateStatusasCompleted6()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Constant_AC constant = new Constant_AC();
        Id wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();        
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishPlanningRecordTypeId;
        anticipationCase.parentId = parentCase.id;
        anticipationCase.Passports__c = true;
        insert anticipationCase;
        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        User volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.id);
        CaseTeamRole roleRec = [SELECT Id FROM CaseTeamRole WHERE Name = 'Wish Granter' Limit 1];       
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.id,volunterUser.id,roleRec.id);
        parentCase.Status = 'Completed';
        database.saveResult result = Database.update(parentCase,false);
        System.assertEquals(true,anticipationCase.Passports__c,'Passports field in planning case should be true' );
        System.assert(parentCase.Status == 'Completed','status should be completed');
    }
    //This method is used to increase the coverage for when the case status is updated to completed. 
    Static testMethod void updateStatusasCompleted7()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Constant_AC constant = new Constant_AC();
        Id wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();        
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishPlanningRecordTypeId;
        anticipationCase.parentId = parentCase.id;
        anticipationCase.Single_Parent_Form__c = true;
        insert anticipationCase;
        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        User volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.id);
        CaseTeamRole roleRec = [SELECT Id,Name FROM CaseTeamRole WHERE Name = 'Wish Granter' Limit 1];       
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.id,volunterUser.id,roleRec.id);
        parentCase.Status = 'Completed';
        database.saveResult result = Database.update(parentCase,false);
        System.assertEquals(true,anticipationCase.Single_Parent_Form__c,'single parent form field should be true');
        System.assert(parentCase.Status == 'Completed','Parent status should be completed');
    }
    //This method is used to increase the coverage for when the case status is updated to completed. 
    Static testMethod void updateStatusasCompleted8()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Constant_AC constant = new Constant_AC();
        Id wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();        
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishPlanningRecordTypeId;
        anticipationCase.parentId = parentCase.id;
        anticipationCase.Visas__c = true;
        insert anticipationCase;
        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        User volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.id);
        CaseTeamRole roleRec = [SELECT Id,Name FROM CaseTeamRole WHERE Name = 'Wish Granter' Limit 1];       
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.id,volunterUser.id,roleRec.id);
        parentCase.Status = 'Completed';
        database.saveResult result = Database.update(parentCase,false);
        System.assertEquals(wishPlanningRecordTypeId,anticipationCase.RecordTypeId,'child case record type should be planning recordtype');
        System.assert(anticipationCase.Visas__c == true,'Visas field in planning case should to true');
    }
    //This method is used to increase the coverage for when the case status is updated to completed. 
    Static testMethod void updateStatusasCompleted9()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Constant_AC constant = new Constant_AC();
        Id wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();        
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishPlanningRecordTypeId;
        anticipationCase.parentId = parentCase.id;
        anticipationCase.Wish_Child_Form__c = true;
        insert anticipationCase;
        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        User volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.id);
        CaseTeamRole roleRec = [SELECT Id FROM CaseTeamRole WHERE Name = 'Wish Granter' Limit 1];       
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.id,volunterUser.id,roleRec.id);
        parentCase.Status = 'Completed';
        database.saveResult result = Database.update(parentCase,false);
        System.assertEquals('Completed',parentCase.Status,'case status should be completed');
        System.assert(anticipationCase.Wish_Child_Form__c == true,' wish child form field should be true in palnning case');
    }
    //This method is used to increase the coverage for when the case status is updated to completed. 
    Static testMethod void updateStatusasCompleted10()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Constant_AC constant = new Constant_AC();
        Id wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();        
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishPlanningRecordTypeId;
        anticipationCase.parentId = parentCase.id;
        anticipationCase.Wish_Family_Form__c = true;
        insert anticipationCase;
        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        User volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.id);
        CaseTeamRole roleRec = [SELECT Id,Name FROM CaseTeamRole WHERE Name = 'Wish Granter' Limit 1];       
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.id,volunterUser.id,roleRec.id);
        parentCase.Status = 'Completed';
        database.saveResult result = Database.update(parentCase,false);
        System.assertEquals(parentCase.Id,anticipationCase.ParentId,'Wish planing parent Id should be wish Id');
        System.assert(anticipationCase.Wish_Family_Form__c == true,'wish family form should be true');
    }
    //This method is used to increase the coverage for when the case status is updated to completed. 
    Static testMethod void updateStatusasCompleted11()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Constant_AC constant = new Constant_AC();
        Id wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();        
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishPlanningRecordTypeId;
        anticipationCase.parentId = parentCase.id;
        anticipationCase.Wish_Information_Form__c = true;
        insert anticipationCase;
        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        User volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.id);
        CaseTeamRole roleRec = [SELECT Id FROM CaseTeamRole WHERE Name = 'Wish Granter' Limit 1];       
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.id,volunterUser.id,roleRec.id);
        parentCase.Status = 'Completed';
        database.saveResult result = Database.update(parentCase,false);
        System.assertEquals(true,anticipationCase.Wish_Information_Form__c,'wish information form field should be true');
        System.assert(parentCase.Status == 'Completed','Case status should be completed');
    }
    //This method is used to increase the coverage for when the case status is updated to completed. 
    Static testMethod void updateStatusasCompleted12()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        
        Wish_Expense__c currExpense = new Wish_Expense__c();
        currExpense.Case__c = parentCase.id;
        currExpense.Budget_Approval_Status__c = 'Submitted';
        currExpense.Projected_Approval_Status__c = 'Submitted';
        currExpense.Projected_Cash__c = 0;
        currExpense.Projected_In_Kind__c = 0;
        currExpense.Actual_In_Kind__c =0;
        currExpense.FE_Posted_Cash__c =0;
        currExpense.FE_Posted_In_Kind__c =0;
        currExpense.Actual_Cash__c =0;
        
        insert currExpense;
        
        
        Constant_AC constant = new Constant_AC();
        Id wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();        
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishPlanningRecordTypeId;
        anticipationCase.parentId = parentCase.id;
        anticipationCase.Wish_Safety_Authorization_Part_B_Form__c = true;
        insert anticipationCase;
        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        User volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.id);
        CaseTeamRole roleRec = [SELECT Id FROM CaseTeamRole WHERE Name = 'Wish Granter' Limit 1];       
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.id,volunterUser.id,roleRec.id);
        parentCase.Status = 'Completed';
        database.saveResult result = Database.update(parentCase,false);
        System.assertEquals('Completed',parentCase.Status,'parent case status should be completed');
        System.assert(anticipationCase.Wish_Safety_Authorization_Part_B_Form__c == true,'wish safety authorization part b form should be true');
    }
    //This method is used to update the anticipation date.
    Static testMethod void updateAnticipationDate()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Constant_AC constant = new Constant_AC();
        chapterAccount.Volunteer_Manager__c = userinfo.getUserId();
        update ChapterAccount;
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithAnticipatedStartDate(wishChild.Id);
        Id wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();        
        Id taskPlanningRecordTypeId = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.staffTaskRT).getRecordTypeId();
        Chapter_Action_Track__c newTrack = OrientationandTrainingUtil.createChapterActionTrack(); 
        newTrack.Chapter_Name__c = chapterAccount.Id;
        newTrack.Task_name__c= 'Test';
        insert newTrack;
        Task newTask = new Task();
        newTask.Subject = 'Test';
        newTask.ActivityDate = Date.Today();
        newTask.Priority = '4';
        newTask.RecordTypeid = taskPlanningRecordTypeId;
        newTask.WhatId = parentCase.id;
        insert newTask;
        parentCase.Anticipated_Start_Date__c = Date.Today().addDays(-10);
        update parentCase;
        System.assertEquals(Date.Today().addDays(-10),parentCase.Anticipated_Start_Date__c,'Anticipated start date should today - 10');
        System.assertEquals('4',newTask.Priority,'Task priority should be 4');
    }
    //This method is used to update the anticipation date.
    Static testMethod void updateAnticipationDateasNull()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Constant_AC constant = new Constant_AC();
        chapterAccount.Volunteer_Manager__c = userinfo.getUserId();
        update ChapterAccount;
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithAnticipatedStartDate(wishChild.Id);
        Chapter_Action_Track__c newTrack = OrientationandTrainingUtil.createChapterActionTrack(); 
        newTrack.Task_name__c = 'Test';
        newTrack.Chapter_Name__c = chapterAccount.Id;
        insert newTrack;
        Id wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();        
        Id taskPlanningRecordTypeId = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.staffTaskRT).getRecordTypeId();
        Task newTask = new Task();
        newTask.Subject = 'Test';
        newTask.ActivityDate = Date.Today();
        newTask.Priority = '4';
        newTask.RecordTypeid = taskPlanningRecordTypeId;
        newTask.WhatId = parentCase.id;
        insert newTask;
        parentCase.Anticipated_Start_Date__c = Null;
        update parentCase;
        System.assertEquals('4',newTask.Priority,'Task priority should be 4');
        System.assert(newTask.RecordTypeid == taskPlanningRecordTypeId,'Task recordType should be planning record type');
    }
    //This method is used to get the permissoins on case object.
    Static testMethod void grantPermissionOnCase() {
        UserSetting__c settings = new UserSetting__c();
        settings.Name = 'Update Abandoned Wishes';
        settings.Abandon_the_Granted_case__c = true;
        settings.All_Closed_Cases_except_Abandoned__c = true;
        settings.Edit_Abandoned_Cases__c = true;
        settings.SetupOwnerId = userinfo.getUserid();
        insert settings;
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithStatus();
        parentCase.ContactId = wishChild.id;
        ParentCase.Status = 'Granted';
        insert parentCase;
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        User volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.id);
        
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
        System.assertEquals('Granted',parentCase.Status,'parent case status should be Granted');
        System.assert(updateVolOpp.Status__c == 'Approved','Volunteer Opportunity status should be Approved');
    }
    //This method is used to update the change owner.
    Static testMethod void changeOwner() {
        UserSetting__c settings = new UserSetting__c();
        settings.Name = 'Update Abandoned Wishes';
        settings.Abandon_the_Granted_case__c = true;
        settings.All_Closed_Cases_except_Abandoned__c = true;
        settings.Edit_Abandoned_Cases__c = true;
        settings.SetupOwnerId = userinfo.getUserid();
        insert settings;
        Constant_AC  constant = new Constant_Ac();    
        Id wishDeterminationRT = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        User volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.id);
        
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithStatus();
        parentCase.ContactId = wishChild.Id;
        parentCase.Diagnosis_Verification_Receive_Date__c = Date.today();
        parentCase.Closed_Date__c = System.Today();
        insert parentCase;
        List<CaseTeamRole> caseTeamRole = [SELECT Id FROM CaseTeamRole WHERE Name = 'Wish Granter' LIMIT 1];
        
        CaseTeamMember caseTeamMem = new CaseTeamMember();
        caseTeamMem.ParentId = parentCase.Id;
        caseTeamMem.TeamRoleId = caseTeamRole[0].Id;
        caseTeamMem.MemberId = volunterUser.Id;
        insert caseTeamMem;
        Case childCase = new Case();
        childCase.RecordTypeId = wishDeterminationRT;
        childCase.ParentId = parentCase.Id;
        childCase.Status = 'New';
        insert childCase;
        System.assert(childCase.status == 'New','child case status should be New');
        Case newChildUpdate = new Case();
        newChildUpdate.Id = childCase.Id;
        //newChildUpdate.OwnerId = volunterUser.Id;
        newChildUpdate.Diagnosis_Verification_Receive_Date__c = Date.today();
        update newChildUpdate;
        System.assertEquals(newChildUpdate.Diagnosis_Verification_Receive_Date__c,Date.today(),'Diagnosis verification receive date should be today');
        
    }
    
    //Eligibility Review Case Creation
    /*Static testMethod void eligibilityReviewCase() {
        Case parentCase = OrientationandTrainingUtil.createEligibilityReviewCase();
    }*/
    
    //Create Sub Cases
    Static testMethod void createSubCases() {
        
        UserSetting__c settings = new UserSetting__c();
        settings.Name = 'Update Abandoned Wishes';
        settings.Abandon_the_Granted_case__c = true;
        settings.All_Closed_Cases_except_Abandoned__c = true;
        settings.Edit_Abandoned_Cases__c = true;
        settings.SetupOwnerId = userinfo.getUserid();
        insert settings;
        
        Constant_AC  constant = new Constant_Ac();    
        Id wishDeterminationRT = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
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
        childCase.RecordTypeId = wishDeterminationRT;
        childCase.ParentId = parentCase.Id;
        childCase.Diagnosis_Verification_Receive_Date__c = Date.today();
        insert childCase;
        Case newCase = new Case();
        newCase.id = parentCase.Id;
        newCase.Status = 'Ready to Interview';
        //newCase.Sub_Status__c = 'Within Policy';
        newCase.Wish_Type__c = 'Disneyland';
        
        update newCase;
        System.assertEquals(2,parentCase.Case_Member_Count__c,'case membercount should 2');
        System.assert(referralDNQTask.Subject == 'Wish Child Birthday Reminder','Task subject should be Wish Child birthday Reminder');     
    }
    
    //Volunteer Opportunity Creation
    Static testMethod void volunteerOppCreation() { 
        
        Role__c newWishGranter = new Role__c();
        newWishGranter.Name = 'Wish Granter';
        insert newWishGranter;
        Regions__c newRegion = new Regions__c();
        newRegion.Name = 'Default';
        insert newRegion;
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        User managerId = OrientationandTrainingUtil.createUser();
        chapterAccount.Volunteer_Manager__c = managerId.Id;
        Chapter_Role__c newRole = new Chapter_Role__c();
        newRole.Chapter_Name__c = chapterAccount.Id;
        newRole.Role_Name__c = newWishGranter.Id;
        insert newRole;
        System.assertEquals(newRole.Chapter_Name__c, chapterAccount.Id, 'Compare New Role Chapter Name with ChapterAccount');
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        wishChild.Region_Code__c = newRegion.Id;
        wishChild.county__c = 'Karur';
        update wishChild;
        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithStatus();
        parentCase.ContactId = wishChild.Id;
        parentCase.AccountId = chapterAccount.Id;
        parentCase.ChapterName__c = chapterAccount.Id;
        parentCase.Status = 'Qualified';
        insert parentCase;
        User volMgr = OrientationandTrainingUtil.createAdminUser();
        List<CaseTeamRole> caseTeamRoleInfo = [SELECT Id, Name FROM CaseTeamRole WHERE Name = 'Volunteer Manager' Limit 1];
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.id,volMgr.id,caseTeamRoleInfo[0].id);
        System.assertEquals(parentCase.Status,'Qualified', 'Check ParentCase Status is Qualified');
        System.assertEquals(parentCase.ChapterName__c, chapterAccount.Id, 'Compare Parent case Chapter Name with ChapterAccount');
        RecursiveTriggerHandler.isFirstTime = true;
        Case updateParentCase = new Case();
        updateParentCase.Id = parentCase.Id;
        updateParentCase.Status = 'Ready to Assign';
        updateParentCase.OwnerId  = managerId.Id;
        updateParentCase.Sub_Status__c = 'Assign in Portal';
        Test.startTest();
        update updateParentCase;
        Test.stopTest();
        System.assertEquals('Assign in Portal',updateParentCase.Sub_Status__c,'Case sub status should be Assign in portal' );
        System.assert(updateParentCase.Status == 'Ready to Assign','Parent case status should be Ready to Assign');
    }
    
    //Presentation Task
    Static testMethod void presentationTask() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithStatus();
        parentCase.ContactId = wishChild.Id;
        parentCase.AccountId = chapterAccount.Id;
        parentCase.Status = 'Qualified';
        insert parentCase;
        Case updateParentCase = new Case();
        updateParentCase.Id = parentCase.Id;
        updateParentCase.End_Date__c = Date.today()+10;
        Test.startTest();
        update updateParentCase;
        Test.stopTest();
        System.assertEquals(Date.today()+10,updateParentCase.End_Date__c,'End date should be today date+10');
        System.assert(parentCase.Status ==  'Qualified','case status should be qualified');
    }
    
    //Medical Summary Task
    Static testMethod void medicalSummaryTask() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
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
        System.assertEquals(updateParentCase.Wish_Type__c,'Cruise - Celebrity/Royal','wish type should be Cruise - Celebrity/Royal');
        System.assert(updateParentCase.Start_Date__c  == Null,'case start date should be null');
        Test.stopTest();
        
        
    }
    
    //Abondend Case
    Static testMethod void wishAbondend()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
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
        System.assertEquals('Qualified',parentCase.Status,'case should be qualified' );
        System.assert(updateParentCase.Sub_Status__c == 'Abandoned','case sub status should be Abandoned');
        Test.stopTest();
        
    }
    //This method is used to get the wish reopen case.
    Static testMethod void wishReopenCase()
    {
        
        Constant_AC  constant = new Constant_Ac();   
        //Chapter_Action_Track__c newChapterActtrack =  OrientationandTrainingUtil.createChapterActionTrack();
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        
        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithStatus();
        parentCase.ContactId = wishChild.Id;
        parentCase.AccountId = chapterAccount.Id;
        parentCase.Start_Date__c = System.today();
        parentCase.Status = 'Qualified';
        insert parentCase;
        Test.startTest();
        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        volunterCon.Number_of_wishes_active__c = 0;
        update volunterCon;
        User volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.id);
        CaseTeamRole roleRec = [SELECT Id FROM CaseTeamRole WHERE Name = 'Wish Granter' Limit 1];       
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.id,volunterUser.id,roleRec.id);
        
        Case wishDeter = OrientationandTrainingUtil.createWishDeterminationCase(wishChild.Id,parentCase.Id);
        
        Case updateParentCase = new Case();
        updateParentCase.Id = parentCase.Id;
        updateParentCase.Sub_Status__c = 'Abandoned';
        updateParentCase.Status = 'Closed';
        updateParentCase.Closed_Date__c = System.Today();
        update updateParentCase;
        System.assertEquals(System.Today(),updateParentCase.Closed_Date__c,'case close date should be today');
        System.assert(updateParentCase.Status == 'Closed', 'case should be Closed');
        Test.StopTest();
        
    }
    //This method is used to check the chapter action track as null.
    Static testMethod void chapterActionTrackAsNull()
    {
        Constant_Ac constant = new Constant_Ac();
        Id planningRT = Schema.Sobjecttype.Chapter_Action_Track__c.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();
        Id wishGrantTaskRT = Schema.Sobjecttype.Chapter_Action_Track__c.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
        String wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Chapter_Action_Track__c newActionTrack = new Chapter_Action_Track__c();
        newActionTrack.Task_Name__c ='Sample Task';
        newActionTrack.Due_Days__c =10.0;
        newActionTrack.Months__c = 1;
        newActionTrack.Chapter_Name__c = chapterAccount.Id;
        newActionTrack.Wish_type__c = 'Other';
        newActionTrack.Description__c='sample';
        newActionTrack.RecordTypeId = planningRT;
        insert newActionTrack;
        Chapter_Action_Track__c newActionTrack1 = new Chapter_Action_Track__c();
        newActionTrack1.Task_Name__c ='Sample Task';
        newActionTrack1.Due_Days__c =10.0;
        newActionTrack1.Months__c = 1;
        newActionTrack1.Chapter_Name__c = chapterAccount.Id;
        newActionTrack1.Wish_type__c = 'Other';
        newActionTrack1.Description__c='sample';
        newActionTrack1.RecordTypeId = wishGrantTaskRT;
        insert newActionTrack1;
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishDeterminationRecordTypeId;
        anticipationCase.parentId = parentCase.id;
        insert anticipationCase;
        parentCase.ChapterName__c = chapterAccount.Id; 
        parentCase.Status = 'Wish Determined';
        parentCase.Wish_Type__c = 'Oth';
        parentCase.Sub_Status__c = 'Within Policy';
        Test.startTest();
        update parentCase;
        System.assertEquals('Within Policy',parentCase.Sub_Status__c,'case sub status should be within policy');
        System.assert(parentCase.Status  == 'Wish Determined','case status should be Wish determined');
        Test.stopTest();
        
    }
    //This method is used to check the interview date as not null.
    static testMethod void interviewdateNotNull() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Constant_AC constant = new Constant_AC();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Case newParentWish = new Case(RecordTypeId = parentWishRecordTypeId,Subject = 'Parent Wish',Status = 'New',Interview_date__c = null);
        insert newParentWish;
        Task volunteerFollowup = new Task(Subject = 'Enter interview date', Status = 'New', WhoId = wishChild.Id, WhatId = newParentWish.Id, SystemGeneratedTask__c = true);
        insert volunteerFollowup;
        newParentWish.Interview_date__c = System.today();
        Test.startTest();
        update newParentWish;
        System.assertEquals(System.today(),newParentWish.Interview_date__c,'Interview date should be system date');
        System.assert(volunteerFollowup.WhoId == wishChild.Id,'Task whoId should match with wish child Id');
        Test.stopTest();
        
    }
    //This method is used to check the interview date as null.
    static testMethod void inrerviewDateAsNull() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Constant_AC constant = new Constant_AC();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Case newParentWish = new Case(RecordTypeId = parentWishRecordTypeId,Subject = 'Parent Wish',Status = 'New',Interview_date__c = System.today());
        insert newParentWish;
        Task volunteerFollowup = new Task(Subject = 'Enter interview date', Status = 'New', WhoId = wishChild.Id, WhatId = newParentWish.Id, SystemGeneratedTask__c = true);
        insert volunteerFollowup;
        newParentWish.Interview_date__c = null;
        Test.startTest();
        update newParentWish;
        System.assertEquals(null,newParentWish.Interview_date__c,'Interview date should be null');
        System.assert(volunteerFollowup.Subject == 'Enter interview date','Task subject sould be Enter interview date');
        Test.stopTest();
        
    }   
}