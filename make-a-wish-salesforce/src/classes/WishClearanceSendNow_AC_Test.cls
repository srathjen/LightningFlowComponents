@isTest
public class WishClearanceSendNow_AC_Test {
    
    public static testMethod void createParentCase(){
        Contact contactWishChild =   OrientationandTrainingUtil.CreateWishChild(); 
        Case caseId = OrientationandTrainingUtil.CreateParentCase(contactWishChild.Id);
        OrientationandTrainingUtil.insertDocusignSetting();
        ApexPAges.StandardController sc = new ApexPages.StandardController(caseId);
        PageReference pageRef = Page.WishClearanceSendNow_VF;
        pageRef.getParameters().put('id',String.valueOf(caseId.Id));
        Test.setCurrentPage(pageRef);
        WishClearanceSendNow_AC wishClear = new WishClearanceSendNow_AC(sc);
        wishClear.SendtoDocuSign();
        wishClear.DisplayMessage();
        //WishClearanceSendNow_AC.CallouttoDocusign(caseId.id);
        wishClear.cancel();
        
        
        
        
    }
    
    public static testMethod void createParentCaseWithTravel(){
        Contact contactWishChild =   OrientationandTrainingUtil.CreateWishChild(); 
        Case caseId = OrientationandTrainingUtil.CreateParentCaseWithTravel(contactWishChild.Id);
        OrientationandTrainingUtil.insertDocusignSetting();
        ApexPAges.StandardController sc = new ApexPages.StandardController(caseId);
        PageReference pageRef = Page.WishClearanceSendNow_VF;
        pageRef.getParameters().put('id',String.valueOf(caseId.Id));
        Test.setCurrentPage(pageRef);
        WishClearanceSendNow_AC wishClear = new WishClearanceSendNow_AC(sc);
        wishClear.SendtoDocuSign();
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new Mock_ResponseGenerator()); 
        WishClearanceSendNow_AC.CallouttoDocusign(caseId.id);
        Test.StopTest();
        
    }
    
}