/************************************************************************************
Author : Mst Solutions
Description : This class is used to increase the code coverage for CaseTrigger_AT and CaseTriggerHandler
*************************************************************************************/
@isTest
public class CaseTrigger_AT_Test {
    
    @testSetup static void setup(){  
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Case wishDetermination = OrientationandTrainingUtil.createWishDeterminationCase(wishChild.Id,parentCase.Id);
        Case wishPlanningCase = OrientationandTrainingUtil.createWishPlanningCase(wishChild.Id,parentCase.Id);
        Case wishAssistCase = OrientationandTrainingUtil.createWishAssistCase(wishChild.Id,parentCase.Id);
        Case wishGrantCase = OrientationandTrainingUtil.createWishGrantCase(wishChild.Id,parentCase.Id);
        
    }
    
    //Used to assign user to case team member
    @isTest static void caseTeamMemberProcess() {
        Constant_AC  constant = new Constant_Ac();    
        Id wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Case parentCase = [SELECT Id, RecordTypeId FROM Case WHERE RecordTypeId = : parentWishRecordTypeId];
        Id wishChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
        Contact wishChild = [SELECT Id,ACcountId FROM Contact WHERE RecordTypeId  = :wishChildRecordTypeId];
        
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
        Case parentCase = [SELECT Id, RecordTypeId FROM Case WHERE RecordTypeId = : parentWishRecordTypeId];   
        parentCase.isApprove__c  = true;
        parentCase.Case_Member_Count__c  = 2;
        update parentCase;
        
        System.assertEquals(parentCase.ParentId, null);
    }
    
    //WishDetermination case update process
    @isTest static void wishDeterminationtCaseProcess() {
        Constant_AC  constant = new Constant_Ac();    
        Id wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        Case wishDeterminationCase = [SELECT Id, RecordTypeId FROM Case WHERE RecordTypeId = : wishDeterminationRecordTypeId LIMIT 1];   
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
            roleName.Name = 'Wish Granter';
            update roleName;
            Chapter_Role__c  chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.Id,roleName.id);
            Case parentCase = [SELECT Id, RecordTypeId FROM Case WHERE RecordTypeId = : parentWishRecordTypeId];
            Id wishChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
            Contact wishChild = [SELECT Id,ACcountId FROM Contact WHERE RecordTypeId  = :wishChildRecordTypeId];
            Case updateparentCase = new Case();
            updateparentCase.Id = parentCase.Id;
            updateparentCase.ChapterName__c = TestClassUtil.createchapterAccount().id;
            updateparentCase.Status = 'Ready to Assign';
            updateparentCase.Volunteer_Manager_Name__c = 'testmawa Manager';
            updateparentCase.Volunteer_Manager_Email__c =  'testmawa@gmail.com';
            updateparentCase.Sub_Status__c = 'Assign in Portal';
            Test.startTest();
            update updateparentCase;
            Test.StopTest();
        }
    }
    
    
     @isTest static void ParentWishStatusAsGranted(){
       
           
            Constant_AC  constant = new Constant_Ac();    
            Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
            Id parentCaseId;
            Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();   
            Contact VolunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
            Role__c  roleName = OrientationandTrainingUtil.createRole();
            roleName.Name = 'Wish Granter';
            update roleName;
            Chapter_Role__c  chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.Id,roleName.id);
            Case parentCase = [SELECT Id, RecordTypeId FROM Case WHERE RecordTypeId = : parentWishRecordTypeId];
            parentCaseId = parentCase.Id;
           system.debug('******** parentCaseId @@@@@@@@@@@@'+parentCaseId);
            List<Volunteer_Opportunity__c> wishVolunteerOpportunityList =OrientationandTrainingUtil.NewWishVolunteerOpportunityList(chapterAccount.id,chapterRole.id,parentCase.id,1);
            Volunteer_Opportunity__c updateVolOpportunity = new Volunteer_Opportunity__c();
            updateVolOpportunity.Id = wishVolunteerOpportunityList.get(0).Id;
            updateVolOpportunity.IsApproved__c = true;
            updateVolOpportunity.Volunteer_Name__c = VolunteerContact.Id;
            update updateVolOpportunity;
            system.debug('########## parentCaseId@@@@@@@@@@@@'+parentCaseId);
            Case dbParentCase = [SELECT Id, RecordTypeId FROM Case WHERE RecordTypeId = : parentWishRecordTypeId AND Id =: parentCaseId Limit 1];
            system.debug('########## ParentCase @@@@@@@@@@@@'+dbParentCase);
            dbParentCase.status = 'Granted';
            update dbParentCase;
            
       
        
    }
    
    
    @isTest static void CreatePartACase(){
      Constant_AC  constant = new Constant_Ac(); 
      Id wishChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
      Contact wishChild = [SELECT Id,ACcountId FROM Contact WHERE RecordTypeId  = :wishChildRecordTypeId];
      Contact dbMedicalCon = OrientationandTrainingUtil.CreateMedicalProfContact();
      Case PartACase = OrientationandTrainingUtil.CreatePartAWishRec();
      PartACase.Local_MCA_Team__c = dbMedicalCon.Id;
      insert PartACase;
    }
    
     @isTest static void UpdatePartACaseStatus(){
      Constant_AC  constant = new Constant_Ac(); 
      Id wishChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
      Contact wishChild = [SELECT Id,ACcountId FROM Contact WHERE RecordTypeId  = :wishChildRecordTypeId];
      Account acc = OrientationandTrainingUtil.MakeAWishAmericaAcc();
      Contact dbMedicalCon = OrientationandTrainingUtil.CreateMedicalProfContact();
      Case PartACase = OrientationandTrainingUtil.CreatePartAWishRec();
      PartACase.Local_MCA_Team__c = dbMedicalCon.Id;
      insert PartACase;
      PartACase.status = 'Escalated';
      PartACase.isEmail__c = true;
      Update PartACase;
    }
    
    @isTest static void PartACasestatusAsInprogress(){
       
      Constant_AC  constant = new Constant_Ac(); 
      Id wishChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
      Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
      Contact wishChild = [SELECT Id,ACcountId FROM Contact WHERE RecordTypeId  = :wishChildRecordTypeId];
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
    
    }
    
    @isTest static void PartACasestatusAsEscalated(){
       
      Constant_AC  constant = new Constant_Ac(); 
      Id wishChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
      Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
      Contact wishChild = [SELECT Id,ACcountId FROM Contact WHERE RecordTypeId  = :wishChildRecordTypeId];
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
    
    }
    
     @isTest static void PartACasestatusAsMedicalEligible(){
       
      Constant_AC  constant = new Constant_Ac(); 
      Id wishChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
      Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
      Contact wishChild = [SELECT Id,ACcountId FROM Contact WHERE RecordTypeId  = :wishChildRecordTypeId];
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
      Test.StartTest();
      update PartACase;
      Test.StopTest();
    }
    
    
    @isTest static void PartACasestatusAsDenied(){
       
      Constant_AC  constant = new Constant_Ac(); 
      Id wishChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
      Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
      Contact wishChild = [SELECT Id,ACcountId FROM Contact WHERE RecordTypeId  = :wishChildRecordTypeId];
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
    
    }
    @isTest static void PartACasestatus(){
       
      Constant_AC  constant = new Constant_Ac(); 
      Id wishChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
      Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
      Contact wishChild = [SELECT Id,ACcountId FROM Contact WHERE RecordTypeId  = :wishChildRecordTypeId];
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
     
     // update PartACase;
    
    }
    
     @isTest static void PartACasestatusAsClosed(){
       
      Constant_AC  constant = new Constant_Ac(); 
      Id wishChildRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(constant.contactWishChildRT).getRecordTypeId();
      Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
      Contact wishChild = [SELECT Id,ACcountId FROM Contact WHERE RecordTypeId  = :wishChildRecordTypeId];
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
    
    }
    
    @isTest static void UpdateWishRecordIdentifier(){
       Constant_AC  constant = new Constant_Ac();    
       Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId(); 
    }
}