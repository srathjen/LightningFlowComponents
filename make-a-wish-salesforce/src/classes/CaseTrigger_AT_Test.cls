/************************************************************************************
Author : Mst Solutions
Description : This class is used to increase the code coverage for CaseTrigger_AT and CaseTriggerHandler
*************************************************************************************/
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
    static testmethod void createNewCase()
    {
        User currUser = OrientationandTrainingUtil.createrSystemAdminUserwithMgr();
        System.RunAs(currUser)
        {
            Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
            Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
            Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
            Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
            createTask('Procure Icebreaker Gift',parentCase.id);
            parentCase.interview_Date__c = Date.Today().addDays(5);
            Test.startTest();
            update parentCase;
            Test.stopTest();
            System.assertEquals(Date.Today().addDays(5),parentCase.interview_Date__c);
        }
    }
    
    /* ************************************************************************
    This method is used to increase the code coverage for when the parent case is created.
    Create a  Complete/upload wish family packet task for parent case.    
    ************************************************************************** */
    
    static testmethod void createInterviewDate()
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
        System.assertEquals(Date.Today().addDays(5),parentCase.interview_Date__c);
    }
    
    /* ************************************************************************
    This method is used to increase the code coverage for when the Two volunteer opportunity is assigned to parent case.
    Update the case team member count is two iin parent case.    
    ************************************************************************** */
    
    static testmethod void updateCaseTeamMember()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        parentCase.Case_Member_Count__c = 2;
        Test.startTest();
        update parentCase;
        Test.stopTest();
        System.assertEquals(2,parentCase.Case_Member_Count__c);
    }
   /* ************************************************************************
    This method is usedd to increase the code coverage when the case is updated the interview date with null value.
    ************************************************************************** */
    
    static testmethod void updateInterviewDate()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        parentCase.interview_date__c = null;
        Test.startTest();
        update parentCase;        
        Test.stopTest();
        System.assertEquals(null,parentCase.interview_date__c);
        Task newTask = new Task();
        newTask.Subject = 'Test';
        newTask.Status = 'Completed';
        newTask.ActivityDate = Date.Today();
        newTask.Priority = '4';
        newTask.WhatId = parentCase.id;
        insert newTask;
        System.assertEquals(parentCase.id,newTask.WhatId);
    }
    
    /* ************************************************************************
    This method is usedd to increase the code coverage when the volunteer opportunity is assigned to case.
    Create a case team member for that case.
    Update the case status as granted.
    ************************************************************************** */
    static testmethod void updateStatusGranted()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        volunterCon.Number_of_wishes_active__c = 0;
        update volunterCon;
        User volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.id);
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        
        
        CaseTeamRole roleRec = [SELECT Id FROM CaseTeamRole WHERE Name = 'Wish Granter'];       
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.id,volunterUser.id,roleRec.id);
        System.assertEquals(parentCase.id,caseTeamMeber.ParentId);
        
        Volunteer_Opportunity__c  newVolOpp = new Volunteer_Opportunity__c();
        newVolOpp.Wish__c = parentCase.id;
        newVolOpp.Volunteer_Name__c = volunterCon.id;
        insert newVolOpp;
        
        parentCase.Status = 'Granted';
        Test.startTest();
        update parentCase;
        Test.stopTest();
        System.assertEquals('Granted',parentCase.Status);
    }
    
    /* ************************************************************************
    The case is updated with prsentation date
    Create the granted case and updaetd with the prsentation date.
    ************************************************************************** */
    
    static testmethod void updatePresentationDate()
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
        System.assertEquals(parentCase.id,wishGrantedCase.ParentId);
    }
    
     /* ************************************************************************
    The case is updated with prsentation date
    Create the granted case and updaetd with the Prsentation Date ,Location, and Time.
    ************************************************************************** */
    
    static testmethod void updatePresentationDate1()
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
        System.assertEquals(Null,setNullPresentation.Presentation_Date__c);
    }
    
    /* ************************************************************************
    The case is updated with prsentation date
    Create the granted case and updaetd with the prsentation date with Null value.
    ************************************************************************** */
    static testmethod void updatePresentationDateNull()
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
        System.assertEquals('Schedule Wish Presentation (add date, time, location name and address)',newRec.Task_Subject__c);
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
        System.assertEquals(Null,newParentWish.Presentation_Date__c);
    }
    
     /* ************************************************************************
    The case status is updated to Ready to Assign.
    ************************************************************************** */
    Static testmethod void updateStatusasRTA()
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
        System.assertEquals('Ready To Assign',parentCase.Status);
    }
    
     /* ************************************************************************
   This method is increase the code coverage for case when the anticipated case is create under theparent case.
    ************************************************************************** */
    
    Static testmethod void createAnticipationCase()
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
        updateCase.Start_Date__c = null;
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
        System.assertEquals(parentCase.id,anticipationCase.parentId);
    }
    
     /* ************************************************************************
   This method is increase the code coverage  when the anticipated case is create under the parent case.
    ************************************************************************** */
    
    Static testmethod void createAnticipationCaseOther()
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
        System.assertEquals(parentCase.id,anticipationCase.parentId);
    }
    
    /* ************************************************************************
       This method is increase the code coverage  when the Determination case is create under the parent case.
    ************************************************************************** */
    Static testmethod void createDeterminationCase()
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
        CaseTeamRole roleRec = [SELECT Id FROM CaseTeamRole WHERE Name = 'Wish Granter'];       
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
        System.assertEquals(parentCase.id,anticipationCase.parentId);
    }
    
    /* ************************************************************************
       This method is increase the code coverage  when the wish type is changed in parent case.
    ************************************************************************** */
    Static testmethod void updateWishType()
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
        System.assertEquals('Test',parentCase.Wish_Type__c);
    }
    
    /* ************************************************************************
       This method is increase the code coverage  when the case status is changed to Wish Determination.
    ************************************************************************** */
    Static testmethod void updateStatusasWD()
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
        System.assertEquals('Wish Determined',parentCase.Status);
    }
     /* ************************************************************************
       This method is increase the code coverage  when the case status is changed to DNQ.
    ************************************************************************** */
    Static testmethod void updateStatusasDNQ()
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
        System.assertEquals('DNQ - Chapter Staff',eligiblityCase.Status);
    }
    
    /* ************************************************************************
       This method is increase the code coverage  when the case status is changed to Abandoned.
    ************************************************************************** */
    Static testmethod void updateStatusasAbandoned()
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
        Test.stopTest();
        System.assertEquals('Abandoned',parentCase.Sub_Status__c);
    }
    
    /* ************************************************************************
       This method is increase the code coverage  when the case status is changed to on Hold.
    ************************************************************************** */
    Static testmethod void updateStatusasHold()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        parentCase.Status = 'on Hold';
        Test.startTest();
        update parentCase;
        Test.stopTest();
        System.assertEquals('on Hold',parentCase.Status);
    }
    
    /* ************************************************************************
       This method is increase the code coverage  when the case status is changed to inActive.
    ************************************************************************** */
    Static testmethod void updateStatusasinActive()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        parentCase.Status = 'inActive';
        Test.startTest();
        update parentCase;
        Test.stopTest();
        System.assertEquals('inActive',parentCase.Status);
    }
    
     /* ************************************************************************
       This method is increase the code coverage  when the flag is added to the wish child form.
    ************************************************************************** */
    Static testmethod void updateWishChildFormFlag()
    {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        parentCase.Update_Wish_Child_Form_Info__c = True;
        Test.startTest();
        update parentCase;
        Test.stopTest();
        System.assertEquals(True,parentCase.Update_Wish_Child_Form_Info__c );
    }
    
    
     /* ************************************************************************
       This method is increase the code coverage  when the parent case status is changed to Escalated.
    ************************************************************************** */
    @isTest static void partACasestatusAsEscalated(){        
        Constant_AC  constant = new Constant_Ac(); 
        Id wishChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
        Test.startTest();
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Account acc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
        newLead.Child_Age__c = '4';
        newLead.unique_wish_identifier__c = '059-17-12367';
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
        System.assertEquals('Escalated',PartACase.Status );
    }
    
    /* ************************************************************************
       This method is increase the code coverage  when the Part A case status is changed to DNQ.
    ************************************************************************** */
    @isTest static void partACasestatusAsDNQ(){
        
        Constant_AC  constant = new Constant_Ac(); 
        Id wishChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
        Test.startTest();
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        Account acc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
        Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id); 
        newLead.Child_Age__c = '4';
        newLead.unique_wish_identifier__c = '059-17-12367';
        insert newLead;
        Contact dbMedicalCon = OrientationandTrainingUtil.CreateMedicalProfContact();
        Case PartACase = OrientationandTrainingUtil.CreatePartAWishRec();
        PartACase.Local_MCA_Team__c = dbMedicalCon.Id;
        PartACase.Lead__c = newLead.Id;
        insert PartACase; 
        PartACase.Status = 'DNQ - Chapter Staff';
        update PartACase;
        Test.stopTest();
        System.assertEquals('DNQ - Chapter Staff',PartACase.Status);
    }
    
    /* ************************************************************************
       This method is increase the code coverage  when the wish Granted case is created.
    ************************************************************************** */
    Static testmethod void createWishGrantedCase()
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
        CaseTeamRole roleRec = [SELECT Id FROM CaseTeamRole WHERE Name = 'Wish Granter'];       
        CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.id,volunterUser.id,roleRec.id);
        Test.startTest();
        Case wishGrantedCase = OrientationandTrainingUtil.createWishGrantCase(wishChild.id,parentCase.id);
        Test.stopTest();
        System.assertEquals(parentCase.id,wishGrantedCase.ParentId);
    }
    
    /* ************************************************************************
       This method is increase the code coverage  when the Wish Expense case is created.
    ************************************************************************** */
    Static testmethod void createWishExpense()
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
        System.assertEquals('Approved',anticipationCase.Budget_Approval_Status__c);
    }
    
    /* ************************************************************************
       This method is increase the code coverage  when the Diagnosis VerificationReview case is created.
    ************************************************************************** */
    Static testmethod void createDiagnosisVerificationReview()
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
        System.assertEquals('Test Eligibility Review',caseDiagnosis.subject);
    }
     /* ************************************************************************
       This method is increase the code coverage  when the case Owner is changed.
    ************************************************************************** */
    static testmethod void changeCaseOwner() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Constant_Ac constant = new Constant_Ac();
        String wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        List<User> currUser = [SELECT Id FROM User WHERE email = 'testmawa@gmail.com'];
        Case anticipationCase = parentCase.clone();
        anticipationCase.RecordTypeId = wishDeterminationRecordTypeId;
        anticipationCase.parentId = parentCase.id;
        insert anticipationCase;
        parentCase.OwnerId = currUser[0].Id;
        Test.startTest();
        update parentCase;
        Test.stopTest();
        System.assertEquals(currUser[0].Id,parentCase.OwnerId);
    }
    /* ************************************************************************
       This method is increase the code coverage  when the case Team Member is added.
    ************************************************************************** */
    static testMethod void caseTeamMemberFunc() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        CaseTeamRole volunteerManager = [SELECT Id FROM CaseTeamRole WHERE Name = 'Volunteer Manager'];   
        List<User> currUser = [SELECT Id FROM User WHERE email = 'testmawa@gmail.com'];
        
        Case updateCaseStat = new Case();
        updateCaseStat.OwnerId = currUser[0].Id;
        updateCaseStat.Id = parentCase.Id;
        Test.startTest();
        update updateCaseStat;
        Test.stopTest();
        System.assertEquals(currUser[0].Id,updateCaseStat.OwnerId);
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
        System.assertEquals('Assign in Portal',updateStatus.Sub_Status__c);
    }
    
    /* ************************************************************************
       This method is increase the code coverage  when the Aniticipation is created under the case.
    ************************************************************************** */
    Static testmethod void anticipationAsNull()
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
    }
    
    /* ************************************************************************
       This method is increase the code coverage  when the sub status is changed to the parent case.
    ************************************************************************** */
    static testmethod void updateSubCaseStatus() {
        Constant_AC constant = new Constant_AC();
        Id wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        Id volunteerTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.volunteerTaskRT).getRecordTypeId();
        Id wishEffectRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishEffectRT).getRecordTypeId();
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        User volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.id);
        CaseTeamRole roleRec = [SELECT Id FROM CaseTeamRole WHERE Name = 'Wish Granter'];       
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
        System.assertEquals(parentCase.Status,'Closed');
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
    static testmethod void closeAllOpenTask() {
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
        System.assertEquals(parentCase.Status,'Closed');
    }
    
    
}