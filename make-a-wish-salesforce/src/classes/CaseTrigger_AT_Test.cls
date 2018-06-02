/*****************************************************************************************************************
Author      : MST Solutions
Date        : 10/4/2016
Description : This class is used to increase the code coverage for CaseTrigger_AT and CaseTriggerHandler
Modification Log: 
23/03/2018 - Sankar - WVC-1835
*******************************************************************************************************************/
@isTest
public class CaseTrigger_AT_Test {
    
    @testSetup static void methodName() {
        User sysAdminUser = OrientationandTrainingUtil.createrSystemAdminUserwithMgr();
    }
    
    //This method is used to create a task with default record type. 
    static void createTask(String subject, String parentCaseId)
    {
        Task newTask = new Task();
        newTask.Subject = subject;
        newTask.ActivityDate = Date.Today();
        newTask.Priority = '4';
        newTask.WhatId = parentCaseId;
        insert newTask;
    }
    //This method is used to create a task with specified record type. 
    static void createTask(String subject, String parentCaseId, String recordTypeId)
    {
        Task newTask = new Task();
        newTask.Subject = subject;
        newTask.ActivityDate = Date.Today();
        newTask.Priority = '4';
        newTask.WhatId = parentCaseId;
        newTask.RecordTypeId = recordTypeId;
        insert newTask;
    }
    
    /* ************************************************************************
This method is used to increase the code coverage for when the parent case is created.
Increase the coverage when the case is updated with interview date.     
************************************************************************** */
    static testMethod void createNewCase()
    {
        User currUser = OrientationandTrainingUtil.createrSystemAdminUserwithMgr();
        System.RunAs(currUser)
        {
            Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
            Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
            Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
            Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
            Volunteer_Opportunity__c  newVolOpp = new Volunteer_Opportunity__c();
            newVolOpp.Wish__c = parentCase.id;
            //newVolOpp.Volunteer_Name__c = volunterCon.id;
            insert newVolOpp;
            Map<Id, Id> caseContactMap = new Map<Id, Id>(); 
            List<Case> newCaseList = new List<Case>();
            Map<Id,String> wishReceiptMap = new Map<Id,String>();
            Set<Id> caseId = new Set<Id>();
            caseContactMap.put(parentCase.id,parentCase.ContactId);
            caseId.add(parentCase.id);
            newCaseList.add(parentCase);
            wishReceiptMap.put(parentCase.id, 'Test item');
            Case_OnAfterUpdateTriggerHandlerHelper.UpdateSubCaseStatus(caseId,newCaseList);
            Case_OnAfterUpdateTriggerHandlerHelper.chageAccessPermission(caseContactMap,newCaseList);
            Case_OnAfterUpdateTriggerHandlerHelper.UpdateWishRecipetItems(wishReceiptMap,newCaseList);
            Case_OnAfterUpdateTriggerHandlerHelper.updateVolunteerOpportunityStatus(caseId,newCaseList);
            createTask('Procure Icebreaker Gift',parentCase.id);
            parentCase.interview_Date__c = Date.Today().addDays(5);
            Test.startTest();
            update parentCase;
            Test.stopTest();
            System.assertEquals(Date.Today().addDays(5),parentCase.interview_Date__c,'parent case interview date should be today() + 5');
            System.assert(parentCase.id == newVolOpp.Wish__c,'Parent case id and voulnteer Opportunity wish Id should be same');
        }
    }
    
    /* ************************************************************************
This method is used to increase the code coverage for when the parent case is created.
Create a  Complete/upload wish family packet task for parent case.    
************************************************************************** */
    
    static testMethod void createInterviewDate()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        createTask('Complete/upload wish family packet',parentCase.id);
        parentCase.interview_Date__c = Date.Today().addDays(5);
        Test.startTest();
        update parentCase;
        Test.stopTest();
        System.assertEquals(Date.Today().addDays(5),parentCase.interview_Date__c,'parent case interview date should be today() + 5');
        System.assert(parentCase.interview_Date__c == Date.Today().addDays(5),'parent case interview date should be today() + 5');
    }
    
    /* ************************************************************************
This method is used to increase the code coverage for when the Two volunteer opportunity is assigned to parent case.
Update the case team member count is two iin parent case.    
************************************************************************** */
    
    static testMethod void updateCaseTeamMember()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        parentCase.Case_Member_Count__c = 2;
        Test.startTest();
        update parentCase;
        Test.stopTest();
        System.assertEquals(2,parentCase.Case_Member_Count__c,'Parent case Case_Member_Count__c field should be 2');
        System.assert(parentCase.contactId == wishChild.Id,'wish child contact Id and parent case contact Id should be same');
    }
    /* ************************************************************************
This method is usedd to increase the code coverage when the case is updated the interview date with null value.
************************************************************************** */
    
    static testMethod void updateInterviewDate()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        parentCase.interview_date__c = null;
        Test.startTest();
        update parentCase;        
        Test.stopTest();
        System.assertEquals(null,parentCase.interview_date__c,'Interview date should be null');
        Task newTask = new Task();
        newTask.Subject = 'Test';
        newTask.Status = 'Completed';
        newTask.ActivityDate = Date.Today();
        newTask.Priority = '4';
        newTask.WhatId = parentCase.id;
        insert newTask;
        System.assertEquals(parentCase.id,newTask.WhatId,'Task whatId and parent case Id should be same');
        System.assert(newTask.Status == 'Completed', 'Task status should be completed');
    }
    
    /* ************************************************************************
This method is usedd to increase the code coverage when the volunteer opportunity is assigned to case.
Create a case team member for that case.
Update the case status as granted.
************************************************************************** */
    static testMethod void updateStatusGranted()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        volunterCon.Number_of_wishes_active__c = 0;
        update volunterCon;
        User volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.id);
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        
        
        CaseTeamRole roleRec = [SELECT Id FROM CaseTeamRole WHERE Name = 'Wish Granter' Limit 1];       
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.id,volunterUser.id,roleRec.id);
        
        System.assertEquals(parentCase.id,caseTeamMeber.ParentId,'CaseTember parentId and wish Id should be same');
        
        Volunteer_Opportunity__c  newVolOpp = new Volunteer_Opportunity__c();
        newVolOpp.Wish__c = parentCase.id;
        newVolOpp.Volunteer_Name__c = volunterCon.id;
        insert newVolOpp;
        
        parentCase.Status = 'Granted';
        Test.startTest();
        update parentCase;
        Test.stopTest();
        System.assertEquals('Granted',parentCase.Status,'Parent case status should be Granted');
        System.assert(volunterCon.Number_of_wishes_active__c == 0,'Number_of_wishes_active__c field in volunteer contact should be zero');
    }
    
    /* ************************************************************************
The case is updated with prsentation date
Create the granted case and updaetd with the prsentation date.
************************************************************************** */
    
    static testMethod void updatePresentationDate()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        WishGrantedSubCaseTaskList__c newRec = new WishGrantedSubCaseTaskList__c();
        newRec.Task_Subject__c = 'Schedule Wish Presentation (add date, time, location name and address)';
        newRec.Name = 'Schedule Wish Presentation';
        newRec.Due_Date__c = 5;
        newRec.Description__c = 'Test';
        insert newRec;
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Constant_AC constant = new Constant_AC();
        Id wishGrantTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.VolunteerTaskRT).getRecordTypeId();
        createTask('Schedule Wish Presentation (add date, time, location name and address)',parentCase.id,wishGrantTaskRT);
        
        Case wishGrantedCase = OrientationandTrainingUtil.createWishGrantCase(wishChild.id,parentCase.id);
        wishGrantedCase.Presentation_Date__c = Date.Today().addDays(5);
        wishGrantedCase.Time__c = '1:30';
        wishGrantedCase.Location_Address__c = 'Sample';
        wishGrantedCase.Name_of_Location__c = 'Sample';
        wishGrantedCase.Wish_Presentation_Set__c  = True;
        Test.startTest();
        update wishGrantedCase;
        Test.stopTest();
        System.assertEquals(newRec.Due_Date__c ,5,'Task due date should be 5');
        System.assert(parentCase.id == wishGrantedCase.ParentId,'Parent case Id and granting case parentId should be same');
    }
    
    /* ************************************************************************
The case is updated with prsentation date
Create the granted case and updaetd with the Prsentation Date ,Location, and Time.
************************************************************************** */
    
    static testMethod void updatePresentationDate1()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        WishGrantedSubCaseTaskList__c newRec = new WishGrantedSubCaseTaskList__c();
        newRec.Task_Subject__c = 'Test';
        newRec.Name = 'Schedule Wish Presentation';
        newRec.Due_Date__c = 5;
        newRec.Description__c = 'Test';
        insert newRec;
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Constant_AC constant = new Constant_AC();
        Id wishGrantTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.VolunteerTaskRT).getRecordTypeId();
        createTask('Test',parentCase.id,wishGrantTaskRT);
        
        Case wishGrantedCase = OrientationandTrainingUtil.createWishGrantCase(wishChild.id,parentCase.id);
        wishGrantedCase.Presentation_Date__c = Date.Today().addDays(5);
        wishGrantedCase.Wish_Presentation_Set__c  = True;
        wishGrantedCase.Time__c = '1:30';
        wishGrantedCase.Location_Address__c = 'Sample';
        wishGrantedCase.Name_of_Location__c = 'Sample';
        update wishGrantedCase;
        case setNullPresentation = new Case();
        setNullPresentation.Presentation_Date__c = null;
        setNullPresentation.Wish_Presentation_Set__c  = false;
        setNullPresentation.Id = wishGrantedCase.Id;
        Test.startTest();
        update setNullPresentation;
        Test.stopTest();
        System.assertEquals(Null,setNullPresentation.Presentation_Date__c,'Presentation_Date__c field should be null');
        System.assert(setNullPresentation.Presentation_Date__c == Null,'Presentation_Date__c field should be null');
    }
    
    /* ************************************************************************
The case is updated with prsentation date
Create the granted case and updaetd with the prsentation date with Null value.
************************************************************************** */
    static testMethod void updatePresentationDateNull()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        WishGrantedSubCaseTaskList__c newRec = new WishGrantedSubCaseTaskList__c();
        newRec.Task_Subject__c = 'Schedule Wish Presentation (add date, time, location name and address)';
        newRec.Name = 'Schedule Wish Presentation';
        newRec.Due_Date__c = 5;
        newRec.Description__c = 'Test';
        insert newRec;
       
        Constant_AC  constant = new Constant_Ac();    
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Case newParentWish = new Case();
        newParentWish.RecordTypeId = parentWishRecordTypeId;
        newParentWish.ChapterName__c = chapterAccount.id;
        newParentWish.Subject = 'Parent Wish';
        newParentWish.Presentation_Date__c = System.today();
        newParentWish.Wish_Type__c = 'Disney World';
        newParentWish.ContactId = wishChild.Id;
        insert newParentWish;
        
        Id wishGrantTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.VolunteerTaskRT).getRecordTypeId();
        createTask('Schedule Wish Presentation (add date, time, location name and address)',newParentWish.id,wishGrantTaskRT);
        newParentWish.Presentation_Date__c = null;
        Test.StartTest();
        update newParentWish;
        Test.stopTest();
        System.assertEquals(newRec.Task_Subject__c,'Schedule Wish Presentation (add date, time, location name and address)','Task subject should be add schedule wish presentation');
        System.assert(newParentWish.Wish_Type__c == 'Disney World','wish type should be Disney World');
    }
    
    /* ************************************************************************
The case status is updated to Ready to Assign.
************************************************************************** */
    Static testMethod void updateStatusasRTA()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        chapterAccount.Volunteer_Manager__c = userinfo.getUserId();
        update ChapterAccount;
        Regions__c regionRec = OrientationandTrainingUtil.createRegion(chapterAccount.Id);
        insert regionRec;
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        wishChild.Region_Chapter__c = ChapterAccount.Id;
        wishChild.Region_Code__c =regionRec.Id;
        wishChild.County__c = 'Karur';
        update wishChild; 
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        parentCase.Status = 'Ready To Assign';
        parentCase.ChapterName__c = ChapterAccount.id;
        parentCase.Sub_Status__c = 'Testing'; 
        Test.StartTest();       
        update parentCase;
        Test.stopTest();
        System.assertEquals('Ready To Assign',parentCase.Status,'Parent case status should be Ready to Assign');
        System.assert(wishChild.County__c == 'Karur', 'wish child County__c  should be karur');
    }
    
    /* ************************************************************************
This method is increase the code coverage for case when the anticipated case is create under theparent case.
************************************************************************** */
    
    Static testMethod void createAnticipationCase()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Constant_AC constant = new Constant_AC();
        chapterAccount.Volunteer_Manager__c = userinfo.getUserId();
        update ChapterAccount;         
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Case updateCase = new Case();
        updateCase.Id = parentCase .Id;
        updateCase.Wish_Type__c = 'Cruise-Celebrity/Royal';
        updateCase.Start_Date__c = null;
        updateCase.Child_s_Medical_Summary_received_date__c = NULL;
        Test.startTest();
        update updateCase;
        Chapter_Action_Track__c newTrack = OrientationandTrainingUtil.createChapterActionTrack(); insert newTrack;
        newTrack.Chapter_Name__c = parentCase.ChapterName__c;
        update newTrack;
        Test.stopTest();
        Id wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();        
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishPlanningRecordTypeId;
        anticipationCase.parentId = parentCase.id;
        insert anticipationCase;
        System.assertEquals(parentCase.id,anticipationCase.parentId,'wish planning case Parent Id should be wish Id');
        System.assert(updateCase.Wish_Type__c == 'Cruise-Celebrity/Royal','wish type should be Cruise-Celebrity/Royal');
    }
    
    /* ************************************************************************
This method is increase the code coverage  when the anticipated case is create under the parent case.
************************************************************************** */
    
    Static testMethod void createAnticipationCaseOther()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Constant_AC constant = new Constant_AC();
        chapterAccount.Volunteer_Manager__c = userinfo.getUserId();
        update ChapterAccount;
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Chapter_Action_Track__c newTrack = OrientationandTrainingUtil.otherActionTrack(); insert newTrack;
        newTrack.Chapter_Name__c = parentCase.ChapterName__c;
        update newTrack;
        Id wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();        
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishPlanningRecordTypeId;
        anticipationCase.parentId = parentCase.id;
        Test.startTest();
        insert anticipationCase;
        Test.stopTest();
        System.assertEquals(parentCase.ChapterName__c,newTrack.Chapter_Name__c,'Case and Task chapter name should be same');
        System.assert(parentCase.id == anticipationCase.parentId,'wish planning case Parent Id should be wish Id');
    }
    
    /* ************************************************************************
This method is increase the code coverage  when the Determination case is create under the parent case.
************************************************************************** */
    Static testMethod void createDeterminationCase()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Constant_AC constant = new Constant_AC();
        chapterAccount.Volunteer_Manager__c = userinfo.getUserId();
        update ChapterAccount;
        
        WishDeterminationSubCaseTaskList__c newTask = new WishDeterminationSubCaseTaskList__c();
        newTask.Name = 'Test';
        newTask.Due_Date__c = 5;
        newTask.Task_Subject__c = 'Test';
        insert newTask;
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id); 
        User volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.id);
        CaseTeamRole roleRec = [SELECT Id FROM CaseTeamRole WHERE Name = 'Wish Granter' Limit 1];       
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.id,volunterUser.id,roleRec.id);
        Chapter_Action_Track__c newTrack = OrientationandTrainingUtil.createChapterActionTrack(); insert newTrack;
        newTrack.Chapter_Name__c = parentCase.ChapterName__c;
        update newTrack;
        String wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishDeterminationRecordTypeId;
        anticipationCase.parentId = parentCase.id;
        Test.startTest();
        insert anticipationCase;
        Test.stopTest();
        System.assertEquals(newTask.Task_Subject__c,'Test','Task subject should be Test');
        System.assert(parentCase.id == anticipationCase.parentId,'wish planning case Parent Id should be wish Id');
    }
    
    /* ************************************************************************
This method is increase the code coverage  when the wish type is changed in parent case.
************************************************************************** */
    Static testMethod void updateWishType()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Constant_AC constant = new Constant_AC();
        chapterAccount.Volunteer_Manager__c = userinfo.getUserId();
        update ChapterAccount;
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Id wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();        
        Id taskPlanningRecordTypeId = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.VolunteerTaskRT).getRecordTypeId();
        Task newTask = new Task();
        newTask.Subject = 'Test';
        newTask.ActivityDate = Date.Today();
        newTask.Priority = '4';
        newTask.RecordTypeid = taskPlanningRecordTypeId;
        newTask.WhatId = parentCase.id;
        insert newTask;
        parentCase.Wish_Type__c = 'Test';
        Test.startTest();
        update parentCase;
        Test.stopTest();
        System.assertEquals('Test',parentCase.Wish_Type__c,'wish type should be Test');
        System.assert(newTask.Priority  == '4','Task priority should 4');
    }
    
    /* ************************************************************************
This method is increase the code coverage  when the case status is changed to Wish Determination.
************************************************************************** */
    Static testMethod void updateStatusasWD()
    {
        Constant_Ac constant = new Constant_Ac();
        Id planningRT = Schema.Sobjecttype.Chapter_Action_Track__c.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();
        String wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Chapter_Action_Track__c newActionTrack = new Chapter_Action_Track__c();
        newActionTrack.Task_Name__c ='Sample Task';
        newActionTrack.Due_Days__c =10.0;
        newActionTrack.Chapter_Name__c = chapterAccount.Id;
        newActionTrack.Wish_type__c = 'Disney World';
        newActionTrack.Description__c='sample';
        newActionTrack.Months__c = 1;
        newActionTrack.RecordTypeId = planningRT;
        insert newActionTrack;
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishDeterminationRecordTypeId;
        anticipationCase.parentId = parentCase.id;
        insert anticipationCase;
        parentCase.ChapterName__c = chapterAccount.Id; 
        parentCase.Status = 'Wish Determined';
        parentCase.Wish_Type__c = 'Disney World';
        parentCase.Sub_Status__c = 'Within Policy';
        Test.startTest();
        update parentCase;
        Test.stopTest();
        System.assertEquals('Wish Determined',parentCase.Status,'Wish status should be wish determination');
        System.assert(parentCase.Sub_Status__c  == 'Within Policy','Wish sub status should be within Policy');
    }
    /* ************************************************************************
This method is increase the code coverage  when the case status is changed to DNQ.
************************************************************************** */
    Static testMethod void updateStatusasDNQ()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case eligiblityCase= OrientationandTrainingUtil.CreatePartAWishRec();
        insert eligiblityCase;
        eligiblityCase.Status = 'DNQ - Chapter Staff';
        Test.startTest();
        update eligiblityCase;
        Test.stopTest();
        System.assertEquals('DNQ - Chapter Staff',eligiblityCase.Status,'Case status should be DNQ - Chapter Staff');
        System.assert(eligiblityCase.Status == 'DNQ - Chapter Staff','Case status should be DNQ - Chapter Staff');
    }
    
    /* ************************************************************************
This method is increase the code coverage  when the case status is changed to Abandoned.
************************************************************************** */
    Static testMethod void updateStatusasAbandoned()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Volunteer_Opportunity__c volOpp = new Volunteer_Opportunity__c(Wish__c = parentCase.Id, Volunteer_Name__c = null, Inactive__c= false, Migrated_Record__c = false);
        insert volOpp;
        createTask('Test',parentCase.id);
        parentCase.Status = 'Closed';
        parentCase.Sub_Status__c = 'Abandoned';
        parentCase.Closed_Date__c = System.Today();
        Test.startTest();
        update parentCase;
        System.assertEquals(parentCase.Sub_Status__c,'Abandoned','sub status should be Abandoned');
        System.assert(parentCase.Status == 'Closed','Parent case status should be closed');
        Test.stopTest();
        
    }
    
    /* ************************************************************************
This method is increase the code coverage  when the case status is changed to Closed .
************************************************************************** */
    Static testMethod void recallApproval()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Volunteer_Opportunity__c volOpp = new Volunteer_Opportunity__c(Wish__c = parentCase.Id, Volunteer_Name__c = null, Inactive__c= false, Migrated_Record__c = false);
        insert volOpp;
        Role__c  roleName = OrientationandTrainingUtil.createRole();
        Chapter_Role__c  chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.Id,roleName.id);
        List<Volunteer_Opportunity__c> wishVolunteerOpportunityList =OrientationandTrainingUtil.NewWishVolunteerOpportunityList(chapterAccount.id,chapterRole.id,parentCase.id,3);
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
        app.setObjectId(wishVolunteerOpportunityList[0].id);
        app.setProcessDefinitionNameOrId('Volunteer_Role_Approval_Process');
        app.setSkipEntryCriteria(true);
        app.setNextApproverIds(new Id[] {userInfo.getUserId()});
        Approval.ProcessResult result = Approval.process(app);
        
        createTask('Test',parentCase.id);
        parentCase.Status = 'Closed';
        parentCase.Sub_Status__c = 'Abandoned';
        parentCase.Closed_Date__c = System.Today();
        Test.startTest();
        update parentCase;
        System.assertEquals('Abandoned',parentCase.Sub_Status__c,'Parent case sub status should be Abandoned');
        System.assert(volOpp.Volunteer_Name__c == Null,'Volunteer name field in volunteer Opportunity should be null');
        Test.stopTest();
        
    }
    
    /* ************************************************************************
This method is increase the code coverage  when the case status is changed to on Hold.
************************************************************************** */
    Static testMethod void updateStatusasHold()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        parentCase.Status = 'on Hold';
        Test.startTest();
        update parentCase;
        Test.stopTest();
        System.assertEquals('on Hold',parentCase.Status,'Parent case status should be hold');
        System.assert(parentCase.contactId == wishChild.Id,'parent case contactId and wish child Id should be same');
    }
    
    /* ************************************************************************
This method is increase the code coverage  when the case status is changed to inActive.
************************************************************************** */
    Static testMethod void updateStatusasinActive()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        parentCase.Status = 'inActive';
        Test.startTest();
        update parentCase;
        Test.stopTest();
        System.assertEquals('inActive',parentCase.Status,'Parent case status should be InActive');
        System.assert(parentCase.contactId == wishChild.Id,'Contact Id and wish contact Id sholud be same');
    }
    
    /* ************************************************************************
This method is increase the code coverage  when the flag is added to the wish child form.
************************************************************************** */
    Static testMethod void updateWishChildFormFlag()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        parentCase.Update_Wish_Child_Form_Info__c = True;
        Test.startTest();
        update parentCase;
        Test.stopTest();
        System.assertEquals(True,parentCase.Update_Wish_Child_Form_Info__c,'Update_Wish_Child_Form_Info__c field in parent case should true');
        System.assert(parentCase.Update_Wish_Child_Form_Info__c == True,'Update_Wish_Child_Form_Info__c field in parent case should true');
    }
    
    
    /* ************************************************************************
This method is increase the code coverage  when the parent case status is changed to Escalated.
************************************************************************** */
        static testMethod  void partACasestatusAsEscalated(){        
        Constant_AC  constant = new Constant_Ac(); 
        Id wishChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
        Test.startTest();
        Condition_Description__c newConDes = new Condition_Description__c();
        newConDes.Name = 'Malignant Neoplasm';
        newConDes.Code_To_Use__c = 'C00';
        newConDes.PR_Diagnosis__c = 'Malignant Neoplasm';
        newConDes.Group1__c = true;
        insert newConDes;
        ICD_Codes__c newIcd = new ICD_Codes__c();
        newIcd.Condition_Description__c = newConDes.id;
        newIcd.Name = 'C00';
        insert newIcd;
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Account acc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
        newLead.Child_Age__c = '4';
        newLead.unique_wish_identifier__c = '059-17-12367';
        newLead.PD_ICD_Code__c = newIcd.Id;
        newLead.PD_Condition_Description__c = 'Malignant Neoplasm';
        newLead.Diagnosis_Given_By_Referrer__c = 'Malignant Neoplasm';
        insert newLead;
        Contact dbMedicalCon = OrientationandTrainingUtil.CreateMedicalProfContact();
        Case PartACase = OrientationandTrainingUtil.CreatePartAWishRec();
        PartACase.Local_MCA_Team__c = dbMedicalCon.Id;
        PartACase.Lead__c = newLead.Id;
        insert PartACase; 
        dsfs__DocuSign_Status__c docuSignRec = OrientationandTrainingUtil.createDocusignStatus(newLead.Id);
        docuSignRec.dsfs__Envelope_Status__c = 'Completed';
        update docuSignRec;
        Blob b = Blob.valueOf('Test Data'); 
        Attachment attachment = new Attachment();  
        attachment.ParentId = docuSignRec.id;  
        attachment.Name = 'Test Attachment for Parent';  
        attachment.Body = b; 
        insert attachment;
        PartACase.Status = 'Escalated';
        update PartACase;
        Test.stopTest();
        System.assertEquals('Escalated',PartACase.Status,'partAcase status should be Escalated' );
        System.assert(attachment.Name == 'Test Attachment for Parent','Attachment name should be Test Attachment for Parent');
    }
    
    /* ************************************************************************
This method is increase the code coverage  when the Part A case status is changed to DNQ.
************************************************************************** */
       static testMethod void partACasestatusAsDNQ(){
        
        Constant_AC  constant = new Constant_Ac(); 
        Id wishChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
        Test.startTest();
        Condition_Description__c newConDes = new Condition_Description__c();
        newConDes.Name = 'Malignant Neoplasm';
        newConDes.Code_To_Use__c = 'C00';
        //newConDes.PR_Diagnosis__c = 'Malignant Neoplasm';
        newConDes.Group1__c = true;
        insert newConDes;
        ICD_Codes__c newIcd = new ICD_Codes__c();
        newIcd.Condition_Description__c = newConDes.id;
        newIcd.Name = 'C00';
        insert newIcd;
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Account acc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
        newLead.Child_Age__c = '4';
        newLead.unique_wish_identifier__c = '059-17-12367';
        newLead.PD_ICD_Code__c = newIcd.id;
        newLead.PD_Condition_Description__c = 'Malignant Neoplasm';
        newLead.Diagnosis_Given_By_Referrer__c = 'Malignant Neoplasm';
        insert newLead;
        Contact dbMedicalCon = OrientationandTrainingUtil.CreateMedicalProfContact();
        Case PartACase = OrientationandTrainingUtil.CreatePartAWishRec();
        PartACase.Local_MCA_Team__c = dbMedicalCon.Id;
        PartACase.Lead__c = newLead.Id;
        insert PartACase; 
        PartACase.Status = 'DNQ - Chapter Staff';
        update PartACase;
        Test.stopTest();
        System.assertEquals('Malignant Neoplasm',newLead.Diagnosis_Given_By_Referrer__c,'Diagnosis Given By Referrer should be Malignant Neoplasm');
        System.assert(PartACase.Status == 'DNQ - Chapter Staff','PartACase status should be DNQ-Chapter Staff');
    }
    
    /* ************************************************************************
This method is increase the code coverage  when the wish Granted case is created.
************************************************************************** */
    Static testMethod void createWishGrantedCase()
    {
        Constant_AC constant = new Constant_AC();
        Id wishGrantTaskRT = Schema.Sobjecttype.Chapter_Action_Track__c.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        
        Chapter_Action_Track__c newActionTrack = new Chapter_Action_Track__c();
        newActionTrack.Task_Name__c ='Sample Task';
        newActionTrack.Due_Days__c =10.0;
        newActionTrack.Description__c='sample';
        newActionTrack.RecordTypeId = wishGrantTaskRT;
        insert newActionTrack;
        
        WishGrantedSubCaseTaskList__c wishGrantedTask = new WishGrantedSubCaseTaskList__c();
        wishGrantedTask.Description__c = 'Test';
        wishGrantedTask.Due_Date__c = 10;
        wishGrantedTask.Task_Subject__c = 'Test';
        wishGrantedTask.Name = 'Task1';
        insert wishGrantedTask;
        
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id); 
        User volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.id);
        CaseTeamRole roleRec = [SELECT Id FROM CaseTeamRole WHERE Name = 'Wish Granter' Limit 1];       
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.id,volunterUser.id,roleRec.id);
        Test.startTest();
        Case wishGrantedCase = OrientationandTrainingUtil.createWishGrantCase(wishChild.id,parentCase.id);
        Test.stopTest();
        System.assertEquals(parentCase.id,wishGrantedCase.ParentId,'Granting case parentId should be wish Id');
        System.assert(wishGrantedTask.Task_Subject__c  == 'Test','Task subject should be Test');
    }
    
    /* ************************************************************************
This method is increase the code coverage  when the Wish Expense case is created.
************************************************************************** */
    Static testMethod void createWishExpense()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Constant_AC constant = new Constant_AC();
        chapterAccount.Volunteer_Manager__c = userinfo.getUserId();
        update ChapterAccount;
        Id wishEffectRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishEffectRT).getRecordTypeId();        
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Chapter_Action_Track__c newTrack = OrientationandTrainingUtil.createChapterActionTrack(); insert newTrack;
        newTrack.Chapter_Name__c = parentCase.ChapterName__c;
        update newTrack;
        Id wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();        
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishPlanningRecordTypeId;
        anticipationCase.parentId = parentCase.id;
        insert anticipationCase;
        Case wishImpactCase = parentCase.clone();
        wishImpactCase.ParentId = parentCase.Id;
        wishImpactCase.RecordTypeId = wishEffectRecordTypeId;
        wishImpactCase.Survey_Email__c = 'chadrutest@gmc.com';
        insert wishImpactCase;
        
        Wish_Expense__c currExpense = new Wish_Expense__c();
        currExpense.Case__c = parentCase.id;
        currExpense.Budget_Approval_Status__c = 'Submitted';
        currExpense.Projected_Approval_Status__c = 'Submitted';
        currExpense.Projected_Cash__c = 0;
        currExpense.Projected_In_Kind__c = 0;
        insert currExpense;
        Test.startTest();
        anticipationCase.Budget_Approval_Status__c = 'Approved';
        update anticipationCase;
        Test.stopTest();
        System.assertEquals('Approved',anticipationCase.Budget_Approval_Status__c,'Budget_Approval_Status__c field should be Approved');
        System.assert(currExpense.Projected_In_Kind__c == 0,'Projected_In_Kind__c field in planning case should be 0');
    }
    
    /* ************************************************************************
This method is increase the code coverage  when the Diagnosis VerificationReview case is created.
************************************************************************** */
    Static testMethod void createDiagnosisVerificationReview()
    {
        Constant_AC constant=new Constant_AC();
        Case caseDiagnosis = new Case();
        caseDiagnosis.subject = 'Test Eligibility Review';
        caseDiagnosis.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(constant.diagnosisRT).getRecordTypeId();
        caseDiagnosis.Status = 'New';
        caseDiagnosis.Origin = 'Email';
        Test.startTest();
        insert caseDiagnosis;
        Test.stopTest();
        System.assertEquals('Test Eligibility Review',caseDiagnosis.subject,'case subject should be Test Eligibility Review');
        System.assert(caseDiagnosis.status == 'New','case status should be New');
    }
    /* ************************************************************************
This method is increase the code coverage  when the case Owner is changed.
************************************************************************** */
    static testMethod void changeCaseOwner() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Constant_Ac constant = new Constant_Ac();
        String wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        List<User> currUser = [SELECT Id,Email FROM User WHERE email = 'testmawa@gmail.com' Limit 1];
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishDeterminationRecordTypeId;
        anticipationCase.parentId = parentCase.id;
        insert anticipationCase;
        parentCase.OwnerId = currUser[0].Id;
        Test.startTest();
        update parentCase;
        Test.stopTest();
        System.assertEquals(currUser[0].Id,parentCase.OwnerId,'User Id and parent case owner Id should be same');
        System.assert('testmawa@gmail.com' == currUser[0].Email, 'current user email Id should be testmawa@gmail.com');
    }
    /* ************************************************************************
This method is increase the code coverage  when the case Team Member is added.
************************************************************************** */
    static testMethod void caseTeamMemberFunc() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        CaseTeamRole volunteerManager = [SELECT Id FROM CaseTeamRole WHERE Name = 'Volunteer Manager' Limit 1];   
        List<User> currUser = [SELECT Id,Email FROM User WHERE email = 'testmawa@gmail.com' Limit 1];
        
        Case updateCaseStat = new Case();
        updateCaseStat.OwnerId = currUser[0].Id;
        updateCaseStat.Id = parentCase.Id;
        Test.startTest();
        update updateCaseStat;
        Test.stopTest();
        System.assertEquals(currUser[0].Id,updateCaseStat.OwnerId,'User Id and parent case owner Id should be same');
        System.assert(currUser[0].Email == 'testmawa@gmail.com','current user email Id should be testmawa@gmail.com');
    }
    
    /* ************************************************************************
This method is increase the code coverage  when the Volunteer Opportunity is created under the case.
************************************************************************** */
    static testMethod void createVolOpp() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        wishChild.County__c = 'Karur';
        update wishChild;
        
        Role__c newRole = new Role__c();
        newRole.Name = 'Wish Granter';
        insert newRole;
        Chapter_Role__c newCR = new Chapter_Role__c();
        newCR.Role_Name__c = newRole.Id;
        newCR.Chapter_Name__c = chapterAccount.Id;
        insert newCR;
        Regions__c regionRec = OrientationandTrainingUtil.createRegion(chapterAccount.Id);
        insert regionRec;
        Contact newCon = new Contact();
        newCon.Id = wishChild.Id;
        newCon.Region_Chapter__c = ChapterAccount.Id;
        newCon.Region_Code__c =regionRec.Id;
        update newCon; 
        RecursiveTriggerHandler.isFirstTime = true;
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        
        Case updateStatus = new Case();
        updateStatus.Id = parentCase.Id;
        updateStatus.ChapterName__c = chapterAccount.Id;
        updateStatus.Status = 'Ready to Assign';
        updateStatus.Sub_Status__c = 'Assign in Portal';
        Test.startTest();
        update updateStatus;
        Test.stopTest();
        System.assertEquals('Assign in Portal',updateStatus.Sub_Status__c,'Wish Sub status should be Assign in Portal');
        System.assert(updateStatus.status == 'Ready to Assign','case status should be Ready to Assign');
    }
    
    /* ************************************************************************
This method is increase the code coverage  when the Aniticipation is created under the case.
************************************************************************** */
    Static testMethod void anticipationAsNull()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Constant_AC constant = new Constant_AC();
        chapterAccount.Volunteer_Manager__c = userinfo.getUserId();
        update ChapterAccount;
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Case newParentWish = new Case();
        newParentWish.RecordTypeId = parentWishRecordTypeId;
        newParentWish.Subject = 'Parent Wish';
        newParentWish.Interview_date__c = System.today();
        newParentWish.Wish_Type__c = 'Disney World';
        newParentWish.Start_Date__c = null;
        newParentWish.End_Date__c = System.today();
        newParentWish.ContactId = wishChild.Id;
        newParentWish.Status = 'New';        
        newParentWish.LiabilitySignerMapKeyPair__c = 'Vennila';
        insert newParentWish;
        Task newTask = new Task();
        newTask.Subject = 'Test';
        newTask.ActivityDate = Date.Today();
        newTask.Priority = '4';
        newTask.WhatId = newParentWish.id;
        newTask.Task_Type__c = 'Wish Planning';
        insert newTask;
        Case updateCase = new Case();
        updateCase.Id = newParentWish.Id;
        updateCase.Wish_Assist__c = True;
        updateCase.Anticipated_Start_Date__c = System.today();
        updateCase.Start_Date__c = System.today();
        Test.startTest();
        update updateCase;
        Test.stopTest();
        System.assertEquals(System.today(),updateCase.Anticipated_Start_Date__c);
        System.assert(updateCase.Anticipated_Start_Date__c == System.today(),updateCase);
    }
    
    /* ************************************************************************
This method is increase the code coverage  when the sub status is changed to the parent case.
************************************************************************** */
    static testMethod void updateSubCaseStatus() {
        Constant_AC constant = new Constant_AC();
        Id wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        Id volunteerTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.volunteerTaskRT).getRecordTypeId();
        Id wishEffectRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishEffectRT).getRecordTypeId();
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        User volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.id);
        CaseTeamRole roleRec = [SELECT Id FROM CaseTeamRole WHERE Name = 'Wish Granter' Limit 1];       
        Id determinationChapterActionRT = Schema.Sobjecttype.Chapter_Action_Track__c.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        Chapter_Action_Track__c newActionTrack = new Chapter_Action_Track__c();
        newActionTrack.Task_Name__c ='Sample Task';
        newActionTrack.Due_Days__c =10.0;
        newActionTrack.Description__c='sample';
        newActionTrack.RecordTypeId = determinationChapterActionRT;
        Insert newActionTrack;
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithClosedStatus(wishChild.Id);
        Task wishChildBirthdayTask = new Task(Subject = 'Wish Child Birthday Reminder', Status = 'New', Task_Type__c = 'Wish Granting', RecordTypeId = volunteerTaskRT, WhoId = wishChild.Id, WhatId = parentCase.Id);
        insert wishChildBirthdayTask;
        Case wishImpactCase = parentCase.clone();
        wishImpactCase.RecordTypeId = wishEffectRecordTypeId;
        wishImpactCase.ParentId = parentCase.Id;
        insert wishImpactCase;
        wishImpactCase.Survey_Email__c = 'chadrutest@gmc.com';
        update wishImpactCase;
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.id,volunterUser.id,roleRec.id);
        System.assertEquals(parentCase.Status,'Closed','case status should be closed');
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishDeterminationRecordTypeId;
        anticipationCase.parentId = parentCase.id;
        insert anticipationCase;
        System.assert(anticipationCase.ParentId.equals(parentCase.Id),'Compare Anticipationcase ParentId with ParentCase Id');
                
        Test.startTest();
        update parentCase;
        Test.stopTest();
    }
    
    /* ************************************************************************
This method is increase the code coverage  when the status is updated to closed.
************************************************************************** */
    static testMethod void closeAllOpenTask() {
        Constant_AC constant = new Constant_AC();
        Id wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        System.assertEquals(parentCase.Status,'New');
        Task volunteerFollowup = new Task(Subject = 'Volunteer wish follow-up activities not complete', Status = 'New', Task_Type__c = 'Wish Granting', WhoId = wishChild.Id, WhatId = parentCase.Id, SystemGeneratedTask__c = true);
        insert volunteerFollowup;
        parentCase.Status = 'Closed';
        parentCase.Closed_Date__c = System.Today();
        Test.startTest();
        update parentCase;
        Test.stopTest();
        System.assertEquals(volunteerFollowup.Subject,'Volunteer wish follow-up activities not complete','Task subject should be Volunteer wish follow-up activities not complete');
        System.assert(parentCase.Status == 'Closed','Parent case status should be closed');
    }
    
    /* ************************************************************************
This method is increase the code coverage  when the form tracking field is filled in Planning Case
************************************************************************** */
    Static testMethod void updateFormTracking()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Constant_AC constant = new Constant_AC();
        chapterAccount.Volunteer_Manager__c = userinfo.getUserId();
        update ChapterAccount;         
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Test.startTest();
        Chapter_Action_Track__c newTrack = OrientationandTrainingUtil.createChapterActionTrack(); insert newTrack;
        newTrack.Chapter_Name__c = parentCase.ChapterName__c;
        update newTrack;
        Test.stopTest();
        Id wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();        
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishPlanningRecordTypeId;
        anticipationCase.parentId = parentCase.id;
        insert anticipationCase;
        anticipationCase.Form_Tracking_Notes__c = 'Test';
        update anticipationCase;
        System.assertEquals(parentCase.id,anticipationCase.parentId,'Planning case parent Id and wish Id should be same');
        System.assert('Test' == anticipationCase.Form_Tracking_Notes__c,'Form_Tracking_Notes__c field should be Test' );
    }
    
    
      Static testMethod List<Volunteer_Opportunity__c>  RejectedWish(){   
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();   
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild(); 
        Contact VolunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        
        Role__c  roleName = OrientationandTrainingUtil.createRole();
        Chapter_Role__c  chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.Id,roleName.id);
        List<Volunteer_Opportunity__c> wishVolunteerOpportunityList =OrientationandTrainingUtil.NewWishVolunteerOpportunityList(chapterAccount.id,chapterRole.id,parentCase.id,3);
        List<Volunteer_Opportunity__c> volunteerOpportunityList = new List<Volunteer_Opportunity__c>();
        
        
        for(Volunteer_Opportunity__c processVolOpportunities : wishVolunteerOpportunityList){
            processVolOpportunities.Volunteer_Name__c = VolunteerContact.Id;
            volunteerOpportunityList.add(processVolOpportunities);
            
        }
        
        test.startTest();
        update volunteerOpportunityList;
        parentCase.Closed_Date__c = Date.today();
        parentCase.Status = 'Closed';
        update parentCase;
        test.stopTest();
        System.assertEquals(parentCase.Closed_Date__c,Date.Today(),'close date should be today()');
        return volunteerOpportunityList;  
        
        
    }
    
     static testMethod void airTravelComment(){
        
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();   
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild(); 
        Contact VolunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithTravel(wishChild.Id);
        parentCase.Comments__c  = 'Updated Test Comment';
        parentCase.Please_Explain__c = 'Test Please Explain';
        parentCase.Appropriate_Comments__c = 'Test Appropriate';
        parentCase.Rush__c = false;
        parentCase.Est_Hold_End_Date__c = system.today();
        parentCase.status = 'Hold';
        update parentCase;
        System.assertEquals(parentCase.Appropriate_Comments__c ,'Test Appropriate','Appropriate_Comments__c field should be Updated Test Appropriate');
        System.assert(parentCase.status == 'Hold','Wish status should be Hold');
    }
    
    static testMethod void airTravelCommentOne(){
        
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();   
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild(); 
        Contact VolunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithTravel(wishChild.Id);
        parentCase.Comment_1__c  = 'Updated Test Comment';
        parentCase.status = 'Inactive';
        update parentCase;
        System.assertEquals(parentCase.Comment_1__c ,'Updated Test Comment','Comment_1__c field should be Updated Test Comment');
        System.assert(parentCase.status == 'Inactive','Wish status should be Inactive');
        
    }
    
    static testMethod void airTravelCommentTwo(){
        Constant_AC constant = new Constant_AC(); 
        Id wishGrantingRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();        
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();   
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild(); 
        Contact VolunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithTravel(wishChild.Id);
        parentCase.Comment_2__c = 'Updated Test Comment';
        parentCase.status = 'DNQ';
        parentCase.Closed_Date__c = system.today();
        update parentCase;
        parentCase.status = 'Ready to Interview';
        update parentCase;
        System.assertEquals(parentCase.Comment_2__c ,'Updated Test Comment','Case_Member_Count__c  field should be 2');
        System.assert(parentCase.status == 'Ready to Interview','Wish status should be Ready to Interview');
        
      } 
      
       /* ************************************************************************
This method is increase the code coverage  when the wish Granted case is created.
************************************************************************** */
    Static testMethod void wishdeterminationSubTaskCreation()
    {
        Constant_AC constant = new Constant_AC();
        Id wishGrantTaskRT = Schema.Sobjecttype.Chapter_Action_Track__c.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
        Id determinationChapterActionRT = Schema.Sobjecttype.Chapter_Action_Track__c.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        
        Regions__c newRegion = new Regions__c();
        newRegion.Name = 'Alabama';        
        insert newRegion;
        wishChild.Region_Code__c =newRegion.Id;
        wishChild.County__c = 'Karur';
        update wishChild; 
        
        Chapter_Action_Track__c newActionTrack = new Chapter_Action_Track__c();
        newActionTrack.Task_Name__c ='Sample Task';
        newActionTrack.Due_Days__c =10.0;
        newActionTrack.Description__c='sample';
        newActionTrack.RecordTypeId = determinationChapterActionRT;
        insert newActionTrack;
        
        WishGrantedSubCaseTaskList__c wishGrantedTask = new WishGrantedSubCaseTaskList__c();
        wishGrantedTask.Description__c = 'Test';
        wishGrantedTask.Due_Date__c = 10;
        wishGrantedTask.Task_Subject__c = 'Test';
        wishGrantedTask.Name = 'Task1';
        insert wishGrantedTask;
        
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        
        Task checkinTask = new Task();
        checkinTask.ActivityDate = System.today() + 30;
        checkinTask.Subject = 'Wish Child Birthday Reminder';
        checkinTask.Status = 'Not Started';
        checkinTask.WhatId = parentCase.Id;
        insert checkinTask;
       
        
        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id); 
        User volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.id);
        CaseTeamRole roleRec = [SELECT Id FROM CaseTeamRole WHERE Name = 'Wish Granter' Limit 1];       
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.id,volunterUser.id,roleRec.id);
        
        case updateParentcase = new case();
        updateParentcase.Id = parentCase.Id; 
        updateParentcase .status = 'Ready to Assign';
        updateParentcase.Sub_Status__c = 'Assign in Portal';
        update updateParentcase;
        
        RecursiveTriggerHandler.blockCaseLockRecursive = true;
        case updateRedaytoInterview = new case();
        updateRedaytoInterview .Id = parentCase.Id; 
        updateRedaytoInterview .Case_Member_Count__c = 2;
        update updateRedaytoInterview ;
        System.assertEquals(updateRedaytoInterview.Case_Member_Count__c ,2,'Case_Member_Count__c  field should be 2');
        System.assert(updateParentcase.Sub_Status__c == 'Assign in Portal','Sub status should be Assign in portal');
    }
    
    static testMethod void medicalReview(){
        Constant_AC constant = new Constant_AC(); 
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
        newLead.Child_Age__c = '4';
        newLead.unique_wish_identifier__c = '059-17-12367';
        newLead.PD_Condition_Description__c = 'Malignant Neoplasm';
        newLead.Diagnosis_Given_By_Referrer__c = 'Malignant Neoplasm';
        insert newLead;
        
        Id dvRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(constant.diagnosisRT).getRecordTypeId();       
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild(); 
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        parentCase.RecordTypeId = dvRecordTypeId;
        parentCase.Lead__c = newLead.Id;
        parentCase.status = 'DNQ - National Medical Review';
        update parentCase;        
      } 
      
}