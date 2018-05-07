/*****************************************************************************
Author : MST Solutions
CreateDate : 07/28/2017
Description : ComboCMSWC_AC_Test is used to make sure the unit testing and code coverage for ComboCMSWC_AC.
******************************************************************************/

@isTest
public class ComboCMSWC_AC_Test {
    
    public static testMethod void createParentCase(){
        Contact contactWishChild =   OrientationandTrainingUtil.CreateWishChild(); 
        Contact contactMedicalProfessChild = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        npe4__Relationship__c createRelationShipRec = OrientationandTrainingUtil.CreateMedicalProfessionalRelationshipRec(contactWishChild.Id,contactMedicalProfessChild.Id);
        Case caseId = OrientationandTrainingUtil.CreateParentCase(contactWishChild.Id);
        caseId.wish_involves_air_travel__c='';
        caseId.Rush__c=false;
        update caseId;
        OrientationandTrainingUtil.insertDocusignSetting();
        ApexPAges.StandardController sc = new ApexPages.StandardController(caseId);
        PageReference pageRef = Page.ComboCMSWC;
        pageRef.getParameters().put('id',String.valueOf(caseId.Id));
        Test.setCurrentPage(pageRef);
        ComboCMSWC_AC wishClear = new ComboCMSWC_AC(sc);
        wishClear.getMedicalProContact();
        wishClear.medicalProfContactName = contactMedicalProfessChild.FirstName+' '+contactMedicalProfessChild.LastName;
        wishClear.SendtoDocuSign();
        wishClear.DisplayMessage();
        wishClear.cancel();
        wishClear.displayEmail();
        
    }
    
    public static testMethod void createParentCaseWithRush(){
        Contact contactWishChild =   OrientationandTrainingUtil.CreateWishChild();
        Contact contactMedicalProfessChild = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        npe4__Relationship__c createRelationShipRec = OrientationandTrainingUtil.CreateMedicalProfessionalRelationshipRec(contactWishChild.Id,contactMedicalProfessChild.Id); 
        Case caseId = OrientationandTrainingUtil.CreateParentCase(contactWishChild.Id);
        case updatecase = new case();
        updatecase.Rush__c = true;
        updatecase.Id = caseId.Id;
        updatecase.Rush_Explanation__c = 'test';
        updatecase.IsRushWishClearence_ChildSummary__c = true;
        updatecase.Rush_Timeframe__c = '0-31';
        updatecase.wish_involves_air_travel__c = 'Yes';
        updatecase.Description = 'Test Description'    ;
        update updatecase;
        OrientationandTrainingUtil.insertDocusignSetting();
        ApexPAges.StandardController sc = new ApexPages.StandardController(updatecase);
        PageReference pageRef = Page.ComboCMSWC;
        pageRef.getParameters().put('id',String.valueOf(updatecase.Id));
        Test.setCurrentPage(pageRef);
        ComboCMSWC_AC wishClear = new ComboCMSWC_AC(sc);
        wishClear.getMedicalProContact();
        wishClear.medicalProfContactName = contactMedicalProfessChild.FirstName+' '+contactMedicalProfessChild.LastName;
        wishClear.SendtoDocuSign();
        wishClear.DisplayMessage();
        wishClear.cancel();
        wishClear.displayEmail();
        wishClear.ReturnToWish();
        wishClear.ReturnToComboCMSWCForm();
        
    }
    
    public static testMethod void createParentCaseWithAirTravel(){
        Contact contactWishChild =   OrientationandTrainingUtil.CreateWishChild(); 
        Contact contactMedicalProfessChild = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        npe4__Relationship__c createRelationShipRec = OrientationandTrainingUtil.CreateMedicalProfessionalRelationshipRec(contactWishChild.Id,contactMedicalProfessChild.Id);
        Case caseId = OrientationandTrainingUtil.CreateParentCase(contactWishChild.Id);
        case updatecase = new case();
        updatecase.wish_involves_air_travel__c = 'Yes';
        updatecase.Id = caseId.Id;
        updatecase.Description = 'test';
        updatecase.Rush__c =true;
        updatecase.Rush_Explanation__c ='test';
        updatecase.Rush_Timeframe__c ='ASAP';
        update updatecase;
        
        case newCase = new case();
        newCase.IsRushWishClearence_ChildSummary__c = true;
        newCase.Id = caseId.id;
        update newCase;
        OrientationandTrainingUtil.insertDocusignSetting();
        ApexPAges.StandardController sc = new ApexPages.StandardController(updatecase);
        PageReference pageRef = Page.WishClearanceSendNow_VF;
        pageRef.getParameters().put('id',String.valueOf(updatecase.Id));
        Test.setCurrentPage(pageRef);
        ComboCMSWC_AC wishClear = new ComboCMSWC_AC(sc);
        wishClear.getMedicalProContact();
        wishClear.medicalProfContactName = contactMedicalProfessChild.FirstName+' '+contactMedicalProfessChild.LastName;
        wishClear.SendtoDocuSign();
        wishClear.DisplayMessage();
        wishClear.cancel();
        wishClear.displayEmail();
        wishClear.ReturnToWish();
        wishClear.ReturnToComboCMSWCForm();
        
    }
    
    public static testMethod void createParentCaseWithTravel(){
        Contact contactWishChild =   OrientationandTrainingUtil.CreateWishChild(); 
        Contact contactMedicalProfessChild = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
        npe4__Relationship__c createRelationShipRec = OrientationandTrainingUtil.CreateMedicalProfessionalRelationshipRec(contactWishChild.Id,contactMedicalProfessChild.Id);
        Case caseId = OrientationandTrainingUtil.CreateParentCaseWithTravel(contactWishChild.Id);
        createRelationShipRec.Send_Wish_Forms__c = True;
        Update createRelationShipRec;
        
        case updatecase = new case();
        updatecase.wish_involves_air_travel__c = 'Yes' ;
        updatecase.Id = caseId.Id;
        updatecase.Description = 'test';
        updatecase.Emergency_Number__c = Null;
        updatecase.Appropriate_Comments__c = Null;
        updatecase.Please_Explain__c = Null;
        updatecase.Date_of_last_visit_treatment__c = Null;
        updatecase.IsRushWishClearence_ChildSummary__c = true;
        updatecase.Comments__c = Null;
        updatecase.Comment_1__c = Null;
        updatecase.Comment_2__c = Null;
        updatecase.Rush__c =true;
        updatecase.Rush_Explanation__c ='test';
        updatecase.Rush_Timeframe__c ='ASAP';
        updatecase.Wish_Clearance_Sent_Date__c = system.today();
        updatecase.Wish_Clearance_Sent_Date__c = system.today();
        update updatecase;
        
        
        OrientationandTrainingUtil.insertDocusignSetting();
        ApexPAges.StandardController sc = new ApexPages.StandardController(caseId);
        PageReference pageRef = Page.WishClearanceSendNow_VF;
        pageRef.getParameters().put('id',String.valueOf(caseId.Id));
        Test.setCurrentPage(pageRef);
        ComboCMSWC_AC wishClear = new ComboCMSWC_AC(sc);
        wishClear.getMedicalProContact();
        wishClear.medicalProfContactName = contactMedicalProfessChild.FirstName+' '+contactMedicalProfessChild.LastName;
        wishClear.email = contactMedicalProfessChild.Email;
        wishClear.displayEmail();
        wishClear.SendtoDocuSign();
        wishClear.ReturnToWish();
        wishClear.ReturnToComboCMSWCForm();
        Test.StartTest();
        boolean isRush = false;
        Test.setMock(HttpCalloutMock.class, new Mock_ResponseGenerator()); 
        ComboCMSWC_AC.CallouttoDocusign(caseId.id,contactWishChild.Name,contactWishChild.Email);
        Test.StopTest();
        
    }
    public testmethod static void testmethodFunctionCall()
    {
        Contact contactWishChild =   OrientationandTrainingUtil.CreateWishChild();
        contactWishChild.Email='TestofTest@gmail.com';
        update contactWishChild;
        Test.startTest();
        Case caseId = OrientationandTrainingUtil.CreateParentCaseWithTravel(contactWishChild.Id);
        Contact contactMedicalProfessChild = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
          npe4__Relationship__c createRelationShipRec = OrientationandTrainingUtil.CreateMedicalProfessionalRelationshipRec(contactWishChild.Id,contactMedicalProfessChild.Id);
       case updatecase = new case();
        updatecase.wish_involves_air_travel__c = 'NO' ;
        updatecase.Id = caseId.Id;
        updatecase.Description = 'test';
        updatecase.Emergency_Number__c = Null;
        updatecase.Appropriate_Comments__c = Null;
        updatecase.Please_Explain__c = Null;
        updatecase.Date_of_last_visit_treatment__c = Null;
        updatecase.IsRushWishClearence_ChildSummary__c = true;
        updatecase.Comments__c = Null;
        updatecase.Comment_1__c = Null;
        updatecase.Comment_2__c = Null;
        updatecase.Rush__c =true;
        updatecase.Rush_Explanation__c ='test';
        updatecase.Rush_Timeframe__c ='ASAP';
        updatecase.Wish_Clearance_Sent_Date__c = system.today();
        updatecase.Wish_Clearance_Sent_Date__c = system.today();
        update updatecase;
         OrientationandTrainingUtil.insertDocusignSetting();
        ApexPAges.StandardController sc = new ApexPages.StandardController(caseId);
        PageReference pageRef = Page.WishClearanceSendNow_VF;
        pageRef.getParameters().put('id',String.valueOf(caseId.Id));
        Test.setCurrentPage(pageRef);
        ComboCMSWC_AC wishClear = new ComboCMSWC_AC(sc);
     //    wishClear.medicalProfContactName = contactMedicalProfessChild.Name;
       // wishClear.email = contactMedicalProfessChild.Email;
       wishClear.getMedicalProContact();
       wishClear.medicalProfContactName = contactMedicalProfessChild.FirstName+' '+contactMedicalProfessChild.LastName;
       wishClear.email = contactMedicalProfessChild.Email;
        wishClear.displayEmail();
        wishClear.SendtoDocuSign();
        Test.stopTest();
    }
}