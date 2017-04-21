/*****************************************************************************
Author : MST Solutions
CreateDate : 03/25/2016
Description : WishChildSummary_AC_Test is used to increase the code coverage for WishChildSummary_AC.
******************************************************************************/

@isTest
public class WishChildSummary_AC_Test {
    
   public static testMethod void createParentCase(){
        Contact contactWishChild =   OrientationandTrainingUtil.CreateWishChild(); 
        Case caseId = OrientationandTrainingUtil.CreateParentCase(contactWishChild.Id);
        OrientationandTrainingUtil.insertDocusignSetting();
        ApexPAges.StandardController sc = new ApexPages.StandardController(caseId);
        PageReference pageRef = Page.WishChildSummary_VF;
        pageRef.getParameters().put('id',String.valueOf(caseId.Id));
        Test.setCurrentPage(pageRef);
        WishChildSummary_AC wishClear = new WishChildSummary_AC(sc);
        wishClear.SendtoDocuSign();
        wishClear.DisplayMessage();
        wishClear.cancel();
        
    }
    
    public static testMethod void createParentCaseWithRush(){
        Contact contactWishChild =   OrientationandTrainingUtil.CreateWishChild(); 
        Case caseId = OrientationandTrainingUtil.CreateParentCase(contactWishChild.Id);
        case updatecase = new case();
        updatecase.Rush__c = true;
        updatecase.Id = caseId.Id;
        updatecase.Rush_Explanation__c = 'test';
        updatecase.Rush_Timeframe__c = '0-31';
        update updatecase;
        OrientationandTrainingUtil.insertDocusignSetting();
        ApexPAges.StandardController sc = new ApexPages.StandardController(updatecase);
        PageReference pageRef = Page.WishChildSummary_VF;
        pageRef.getParameters().put('id',String.valueOf(updatecase.Id));
        Test.setCurrentPage(pageRef);
        WishChildSummary_AC wishClear = new WishChildSummary_AC(sc);
        wishClear.SendtoDocuSign();
        wishClear.DisplayMessage();
        wishClear.cancel();
        
    }
    
    public static testMethod void createParentCaseWithAirTravel(){
        Contact contactWishChild =   OrientationandTrainingUtil.CreateWishChild(); 
        Case caseId = OrientationandTrainingUtil.CreateParentCase(contactWishChild.Id);
        case updatecase = new case();
        updatecase.wish_involves_air_travel__c = 'Yes';
        updatecase.Id = caseId.Id;
        updatecase.Description = 'test';
        update updatecase;
        OrientationandTrainingUtil.insertDocusignSetting();
        ApexPAges.StandardController sc = new ApexPages.StandardController(updatecase);
        PageReference pageRef = Page.WishChildSummary_VF;
        pageRef.getParameters().put('id',String.valueOf(updatecase.Id));
        Test.setCurrentPage(pageRef);
        WishChildSummary_AC wishClear = new WishChildSummary_AC(sc);
        wishClear.SendtoDocuSign();
        wishClear.DisplayMessage();
        wishClear.cancel();
        
    }
       
    public static testMethod void createParentCaseWithTravel(){
        Contact contactWishChild =   OrientationandTrainingUtil.CreateWishChild(); 
        Case caseId = OrientationandTrainingUtil.CreateParentCaseWithTravel(contactWishChild.Id);
        OrientationandTrainingUtil.insertDocusignSetting();
        ApexPAges.StandardController sc = new ApexPages.StandardController(caseId);
        PageReference pageRef = Page.WishChildSummary_VF;
        pageRef.getParameters().put('id',String.valueOf(caseId.Id));
        Test.setCurrentPage(pageRef);
        WishChildSummary_AC wishClear = new WishChildSummary_AC(sc);
        wishClear.SendtoDocuSign();
        Test.StartTest();
        boolean isRush = false;
        Test.setMock(HttpCalloutMock.class, new Mock_ResponseGenerator()); 
        WishChildSummary_AC.CallouttoDocusign(caseId.id,isRush);
        Test.StopTest();
        
    }

}