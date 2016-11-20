/************************************************************************************
Author : Mst Solutions
Description : This class is used to increase the code coverage for CaseTrigger_AT and CaseTriggerHandler
*************************************************************************************/
@isTest
public class CaseTrigger_AT_Test {
    
    @testSetup static void setup(){  
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        parentCase.ChapterName__c = chapterAccount.Id;
        parentCase.Budget_Approval_Status__c = 'Approved';
        update parentCase;
        Case wishDetermination = OrientationandTrainingUtil.createWishDeterminationCase(wishChild.Id,parentCase.Id);
        Case wishAssistCase = OrientationandTrainingUtil.createWishAssistCase(wishChild.Id,parentCase.Id);
        Case wishGrantCase = OrientationandTrainingUtil.createWishGrantCase(wishChild.Id,parentCase.Id);
        List<WishDeterminationSubCaseTaskList__c> createDeterminationTaskList = OrientationandTrainingUtil.createDeterminationTask(8);
        
        Chapter_Action_Track__c chapterAction = OrientationandTrainingUtil.createChapterActionTrack();
        chapterAction.Chapter_Name__c = chapterAccount.Id;
        insert chapterAction;
        Chapter_Action_Track__c chapterActionwithNull = OrientationandTrainingUtil.createChapterActionTrack();
        chapterActionwithNull.Chapter_Name__c = chapterAccount.Id;
        chapterActionwithNull.Months__c = null;
        chapterActionwithNull.Weeks__c = null;
        insert chapterActionwithNull;
        Chapter_Action_Track__c otherAction = OrientationandTrainingUtil.otherActionTrack();
        otherAction.Chapter_Name__c = chapterAccount.Id;
        insert otherAction;
        
        Chapter_Action_Track__c otherActionNullDate = OrientationandTrainingUtil.otherActionTrack();
        otherActionNullDate.Chapter_Name__c = chapterAccount.Id;
        otherActionNullDate.Months__c = null;
        otherActionNullDate.Weeks__c = null;
        insert otherActionNullDate;
        Case wishPlanningCase = OrientationandTrainingUtil.createWishPlanningCase(wishChild.Id,parentCase.Id);
    
    }
    
    //Used to assign user to case team member
    @isTest static void caseTeamMemberProcess() {
        Constant_AC  constant = new Constant_Ac();    
        Id wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Case parentCase = [SELECT Id, RecordTypeId FROM Case WHERE RecordTypeId = : parentWishRecordTypeId LIMIT 1];
        Id wishChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
        Contact wishChild = [SELECT Id,ACcountId FROM Contact WHERE RecordTypeId  = :wishChildRecordTypeId LIMIT 1];
        
        Case newWishDeterminatonWish = new Case();
        newWishDeterminatonWish.RecordTypeId = wishDeterminationRecordTypeId;
        newWishDeterminatonWish.ParentId = parentCase.Id;
        newWishDeterminatonWish.ChapterName__c = TestClassUtil.createArizonaChapter();
        newWishDeterminatonWish.Subject = 'Wish Determination';
        newWishDeterminatonWish.Wish_Type__c = 'Standard';
        newWishDeterminatonWish.ContactId = wishChild.Id;
        newWishDeterminatonWish.accountId = wishChild.AccountId;
        
        Chapter_Action_Track__c currActionTrack = TestClassUtil.CreateChapterActionTrack();
        currActionTrack.Chapter_Name__c = TestClassUtil.createchapterAccount().id;
        insert currActionTrack;
        
        CaseTeamRole teamRole = new CaseTeamRole();
        System.RunAs(new User(Id = UserInfo.getUserId())) {
            teamRole.accesslevel = 'edit';
            teamRole.name = 'test';
            teamRole.PreferencesVisibleInCSP = true;
            insert(teamRole);
        }
        
        CaseTeamMember caseMember = OrientationandTrainingUtil.createCaseTeamMember(parentCase.Id,wishChild.Id,teamRole.id);
        insert newWishDeterminatonWish;
        
    }
    
    //Parent case update process
    @isTest static void parentCaseProcess() {
        Constant_AC  constant = new Constant_Ac();    
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Case parentCase = [SELECT Id, RecordTypeId FROM Case WHERE RecordTypeId = : parentWishRecordTypeId LIMIT 1];   
        parentCase.isApprove__c  = true;
        parentCase.Case_Member_Count__c  = 2;
        update parentCase;
        System.assertEquals(parentCase.ParentId, null);
    }
    
    //Parent case Anticipated date as Not null
    @isTest static void anticipatedNull() {
        Constant_AC  constant = new Constant_Ac();    
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Case parentCase = [SELECT Id, RecordTypeId FROM Case WHERE RecordTypeId = : parentWishRecordTypeId LIMIT 1];   
        parentCase.Anticipated_Start_Date__c = System.today().addDays(-60);
        update parentCase;
    }
    
    //Anticipated Date update in Parent wish
    @isTest static void anticipatedNotNull() {
        Constant_AC  constant = new Constant_Ac();    
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Case parentCase = [SELECT Id, RecordTypeId FROM Case WHERE RecordTypeId = : parentWishRecordTypeId LIMIT 1];   
        parentCase.Anticipated_Start_Date__c = System.today().addDays(-60);
        update parentCase;
        Case updateAnotherDate = new Case();
        updateAnotherDate.Id = parentCase.Id;
        updateAnotherDate.Anticipated_Start_Date__c = System.today().addDays(-63);
        update updateAnotherDate;
    }
    
    //Parent case Anticipated date as null
    @isTest static void anticipatedAsNull() {
        Constant_AC  constant = new Constant_Ac();    
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Case parentCase = [SELECT Id, RecordTypeId FROM Case WHERE RecordTypeId = : parentWishRecordTypeId LIMIT 1];   
        parentCase.Anticipated_Start_Date__c = null;
        update parentCase;
    }
    
    
    //This Method will Create "Enter New Interview" Task
    @isTest static void updateInterviewDateAsNull() {
        Constant_AC  constant = new Constant_Ac();    
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Case parentCase = [SELECT Id, RecordTypeId FROM Case WHERE RecordTypeId = : parentWishRecordTypeId LIMIT 1];   
        parentCase.Interview_date__c = null;
        update parentCase;
        System.assertEquals(parentCase.Interview_date__c, null);
    }
    
    //This Method will delete "Enter New Interview" Task
    @isTest static void updateInterviewDate() {
        Constant_AC  constant = new Constant_Ac();    
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Case parentCase = [SELECT Id, RecordTypeId FROM Case WHERE RecordTypeId = : parentWishRecordTypeId LIMIT 1];   
        parentCase.Interview_date__c = null;
        update parentCase;
        case newCase = new case();
        newCase.Interview_date__c = system.today();
        newCase.Id = parentCase.Id;
        update newCase;
    }
    
    //This Method is used to create wish determination activity date
    @isTest static void updateInterviewDateWithTaks() {
        Constant_AC  constant = new Constant_Ac();    
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Case parentCase = [SELECT Id, RecordTypeId FROM Case WHERE RecordTypeId = : parentWishRecordTypeId LIMIT 1];   
        parentCase.Interview_date__c = System.today().addDays(16);
        update parentCase;
        case newCase = new case();
        newCase.Interview_date__c = system.today().addDays(18);
        newCase.Id = parentCase.Id;
        update newCase;
        Task newTask = new Task();
        newTask.Subject = 'Procure Icebreaker Gift';
        newTask.WhatId = parentCase.Id;
        insert newTask;
    }
    
    
    //WishDetermination case update process
    @isTest static void wishDeterminationtCaseProcess() {
        Constant_AC  constant = new Constant_Ac();    
        Id wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        Case wishDeterminationCase = [SELECT Id,Parent.ContactId, RecordTypeId FROM Case WHERE RecordTypeId = : wishDeterminationRecordTypeId LIMIT 1];   
        wishDeterminationCase.isApprove__c  = true;
        update wishDeterminationCase;
        
        
        
        System.assertEquals(wishDeterminationCase.Wish_type__c, null);
    }
    
    //WishPlanning case update process
    @isTest static void wishPlanningCaseProcess() {
        Constant_AC  constant = new Constant_Ac();    
        Id wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();
        Case wishPlanningCase = [SELECT Id, RecordTypeId FROM Case WHERE RecordTypeId = : wishPlanningRecordTypeId LIMIT 1];   
        wishPlanningCase.isApprove__c  = true;
        update wishPlanningCase;
        
    }
    
    @isTest static void parentWishTypeAnimal() {
        Constant_AC  constant = new Constant_Ac();    
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Test.startTest();
        Case parentCase = [SELECT Id, RecordTypeId FROM Case WHERE RecordTypeId = : parentWishRecordTypeId LIMIT 1];
        parentCase.Wish_Type__c = 'Animal';
        update parentCase;
        Contact childWish = [SELECT Id FROM Contact LIMIT 1];
        Case wishPlanningCase = OrientationandTrainingUtil.createWishPlanningCase(childWish.Id,parentCase.Id);
        Test.stopTest();
    }
    
    
    //WishAssist case update process
    @isTest static void wishAssistCaseProcess() {
        Constant_AC  constant = new Constant_Ac();    
        Id wishAssistRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishAssistRT).getRecordTypeId();
        Case wishAssistCase = [SELECT Id, RecordTypeId FROM Case WHERE RecordTypeId = : wishAssistRecordTypeId LIMIT 1];   
        wishAssistCase.isApprove__c  = true;
        update wishAssistCase;
    }
    
    //WishGrant case update process
    @isTest static void wishGrantCaseProcess() {
        Constant_AC  constant = new Constant_Ac();    
        Id wishGrantRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
        Case wishGrantCase = [SELECT Id, RecordTypeId FROM Case WHERE RecordTypeId = : wishGrantRecordTypeId LIMIT 1];   
        wishGrantCase.isApprove__c  = true;
        update wishGrantCase;
    }
    //Update case status to 'Ready to Assign'.
    @isTest static void UpdateParentWishStatus(){
        user systemAdminUser = OrientationandTrainingUtil.createrSystemAdminUser();
        system.RunAs(systemAdminUser){
            Constant_AC  constant = new Constant_Ac();    
            Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
            Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();   
            Role__c  roleName = OrientationandTrainingUtil.createRole();
            roleName.Name = 'Wish Granter1';
            //update roleName;
            Chapter_Role__c  chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.Id,roleName.id);
            Case parentCase = [SELECT Id, RecordTypeId FROM Case WHERE RecordTypeId = : parentWishRecordTypeId LIMIT 1];
            Id wishChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
            Contact wishChild = [SELECT Id,ACcountId FROM Contact WHERE RecordTypeId  = :wishChildRecordTypeId LIMIT 1];
            Case updateparentCase = new Case();
            updateparentCase.Id = parentCase.Id;
            updateparentCase.ChapterName__c = TestClassUtil.createchapterAccount().id;
            updateparentCase.Status = 'Ready to Assign';
            updateparentCase.Volunteer_Manager_Name__c = 'testmawa Manager';
            updateparentCase.Volunteer_Manager_Email__c =  'testmawa@gmail.com';
            updateparentCase.Sub_Status__c = 'Assign in Portal';
            updateparentCase.OwnerId = userInfo.getUserId();
            Test.startTest();
            //update updateparentCase;
            Test.StopTest();
        }
    }
    
    
    @isTest static void ParentWishStatusAsGranted(){
        
        
        Constant_AC  constant = new Constant_Ac();    
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Id parentCaseId;
        
        Id wishChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
        
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();   
        Contact VolunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        Role__c  roleName = OrientationandTrainingUtil.createRole();
        roleName.Name = 'Wish Granter2';
        update roleName;
        Chapter_Role__c  chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.Id,roleName.id);
        Case parentCase = [SELECT Id, RecordTypeId FROM Case WHERE RecordTypeId = : parentWishRecordTypeId LIMIT 1];
        parentCaseId = parentCase.Id;
        system.debug('******** parentCaseId @@@@@@@@@@@@'+parentCaseId);
        List<Volunteer_Opportunity__c> wishVolunteerOpportunityList =OrientationandTrainingUtil.NewWishVolunteerOpportunityList(chapterAccount.id,chapterRole.id,parentCase.id,1);
        Volunteer_Opportunity__c updateVolOpportunity = new Volunteer_Opportunity__c();
        updateVolOpportunity.Id = wishVolunteerOpportunityList.get(0).Id;
        updateVolOpportunity.IsApproved__c = true;
        updateVolOpportunity.Volunteer_Name__c = VolunteerContact.Id;
        //update updateVolOpportunity;
        system.debug('########## parentCaseId@@@@@@@@@@@@'+parentCaseId);
        Case dbParentCase = [SELECT Id, RecordTypeId FROM Case WHERE RecordTypeId = : parentWishRecordTypeId AND Id =: parentCaseId Limit 1];
        system.debug('########## ParentCase @@@@@@@@@@@@'+dbParentCase);
        dbParentCase.status = 'Granted';
        update dbParentCase;
        
        CaseTeamRole teamRole = new CaseTeamRole();
        System.RunAs(new User(Id = UserInfo.getUserId())) {
            teamRole.accesslevel = 'edit';
            teamRole.name = 'test';
            teamRole.PreferencesVisibleInCSP = true;
            insert(teamRole);
        }
        Contact wishChild = [SELECT Id,ACcountId FROM Contact WHERE RecordTypeId  = :wishChildRecordTypeId LIMIT 1];
        CaseTeamMember caseMember = OrientationandTrainingUtil.createCaseTeamMember(dbParentCase.Id,wishChild.Id,teamRole.id);
        
        
    }
    
    
    @isTest static void CreatePartACase(){
        Constant_AC  constant = new Constant_Ac(); 
        Id wishChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
        Test.startTest();
        Contact wishChild = [SELECT Id,ACcountId FROM Contact WHERE RecordTypeId  = :wishChildRecordTypeId LIMIT 1];
        Contact dbMedicalCon = OrientationandTrainingUtil.CreateMedicalProfContact();
        Case PartACase = OrientationandTrainingUtil.CreatePartAWishRec();
        PartACase.Local_MCA_Team__c = dbMedicalCon.Id;
        insert PartACase;
        Test.stopTest();
    }
    
    @isTest static void UpdatePartACaseStatus(){
        Constant_AC  constant = new Constant_Ac(); 
        Id wishChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
        Contact wishChild = [SELECT Id,ACcountId FROM Contact WHERE RecordTypeId  = :wishChildRecordTypeId LIMIT 1];
        Account acc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Contact dbMedicalCon = OrientationandTrainingUtil.CreateMedicalProfContact();
        Case PartACase = OrientationandTrainingUtil.CreatePartAWishRec();
        PartACase.Local_MCA_Team__c = dbMedicalCon.Id;
        Test.startTest();
        insert PartACase;
        PartACase.status = 'Escalated';
        PartACase.isEmail__c = true;
        Update PartACase;
        Test.stopTest();
    }
    
    @isTest static void PartACasestatusAsInprogress(){
        
        Constant_AC  constant = new Constant_Ac(); 
        Id wishChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
        Test.startTest();
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Contact wishChild = [SELECT Id,ACcountId FROM Contact WHERE RecordTypeId  = :wishChildRecordTypeId LIMIT 1];
        Account acc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
        newLead.Child_Age__c = '4';
        insert newLead;
        Contact dbMedicalCon = OrientationandTrainingUtil.CreateMedicalProfContact();
        Case PartACase = OrientationandTrainingUtil.CreatePartAWishRec();
        PartACase.ContactId = wishChild.Id;
        PartACase.Local_MCA_Team__c = dbMedicalCon.Id;
        PartACase.Lead__c = newLead.Id;
        insert PartACase; 
        PartACase.Status = 'In progress';
        update PartACase;
        Test.stopTest();
        
    }
    
    @isTest static void PartACasestatusAsEscalated(){
        
        Constant_AC  constant = new Constant_Ac(); 
        Id wishChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
        Test.startTest();
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Contact wishChild = [SELECT Id,ACcountId FROM Contact WHERE RecordTypeId  = :wishChildRecordTypeId LIMIT 1];
        Account acc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
        newLead.Child_Age__c = '4';
        insert newLead;
        Contact dbMedicalCon = OrientationandTrainingUtil.CreateMedicalProfContact();
        Case PartACase = OrientationandTrainingUtil.CreatePartAWishRec();
        PartACase.ContactId = wishChild.Id;
        PartACase.Local_MCA_Team__c = dbMedicalCon.Id;
        PartACase.Lead__c = newLead.Id;
        insert PartACase; 
        PartACase.Status = 'Escalated';
        update PartACase;
        Test.stopTest();
        
    }
    
    /*@isTest static void PartACasestatusAsMedicalEligible(){
        
        Constant_AC  constant = new Constant_Ac(); 
        Id wishChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
        Test.StartTest();
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Contact wishChild = [SELECT Id,ACcountId FROM Contact WHERE RecordTypeId  = :wishChildRecordTypeId LIMIT 1];
        Account acc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
        newLead.Child_Age__c = '4';
        insert newLead;
        Contact dbMedicalCon = OrientationandTrainingUtil.CreateMedicalProfContact();
        Case PartACase = OrientationandTrainingUtil.CreatePartAWishRec();
        PartACase.ContactId = wishChild.Id;
        PartACase.Local_MCA_Team__c = dbMedicalCon.Id;
        PartACase.Lead__c = newLead.Id;
        insert PartACase; 
        PartACase.Status = 'Medical Eligible';
        
        update PartACase;
        Test.StopTest();
    }*/
    
    
    @isTest static void PartACasestatusAsDenied(){
        
        Constant_AC  constant = new Constant_Ac(); 
        Id wishChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
        Test.startTest();
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Contact wishChild = [SELECT Id,ACcountId FROM Contact WHERE RecordTypeId  = :wishChildRecordTypeId LIMIT 1];
        Account acc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
        newLead.Child_Age__c = '4';
        insert newLead;
        Contact dbMedicalCon = OrientationandTrainingUtil.CreateMedicalProfContact();
        Case PartACase = OrientationandTrainingUtil.CreatePartAWishRec();
        PartACase.ContactId = wishChild.Id;
        PartACase.Local_MCA_Team__c = dbMedicalCon.Id;
        PartACase.Lead__c = newLead.Id;
        insert PartACase; 
        PartACase.Status = 'Denied';
        update PartACase;
        Test.stopTest();
        
    }
    @isTest static void PartACasestatus(){
        
        Constant_AC  constant = new Constant_Ac(); 
        Id wishChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
        Test.startTest();
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Contact wishChild = [SELECT Id,ACcountId FROM Contact WHERE RecordTypeId  = :wishChildRecordTypeId LIMIT 1];
        Account acc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
        newLead.Child_Age__c = '4';
        insert newLead;
        Contact dbMedicalCon = OrientationandTrainingUtil.CreateMedicalProfContact();
        Case PartACase = OrientationandTrainingUtil.CreatePartAWishRec();
        PartACase.ContactId = wishChild.Id;
        PartACase.Local_MCA_Team__c = dbMedicalCon.Id;
        PartACase.Lead__c = newLead.Id;
        PartACase.Status = 'Closed';
        PartACase.Sub_Status__c = 'Abandoned';
        
        insert PartACase; 
        Test.stopTest();
        // update PartACase;
        
    }
    
    @isTest static void PartACasestatusAsClosed(){
        
        Constant_AC  constant = new Constant_Ac(); 
        Id wishChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
        Test.startTest();
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Contact wishChild = [SELECT Id,ACcountId FROM Contact WHERE RecordTypeId  = :wishChildRecordTypeId LIMIT 1];
        Account acc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
        newLead.Child_Age__c = '4';
        insert newLead;
        Contact dbMedicalCon = OrientationandTrainingUtil.CreateMedicalProfContact();
        Case PartACase = OrientationandTrainingUtil.CreatePartAWishRec();
        PartACase.ContactId = wishChild.Id;
        PartACase.Local_MCA_Team__c = dbMedicalCon.Id;
        PartACase.Lead__c = newLead.Id;
        insert PartACase; 
        PartACase.Status = 'Closed';
        PartACase.Sub_status__c = 'Abandoned';
        update PartACase;
        Test.stopTest();
        
    }
    
    @isTest static void UpdateWishRecordIdentifier(){
        Constant_AC  constant = new Constant_Ac();    
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId(); 
    }
}