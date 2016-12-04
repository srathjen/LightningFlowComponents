@isTest
public class WishChildSummary_AC_Test {
    
    /*public static testMethod void createParentCase(){
        Constituent_Code__c consTituent = OrientationandTrainingUtil.createWishParentGuardiansContituentCode();
        Constituent_Code__c  cinstChild = OrientationandTrainingUtil.createWishChildContituentCode();
        Contact contactWishChild =   OrientationandTrainingUtil.CreateWishChild(); 
        Case caseId = OrientationandTrainingUtil.CreateParentCase(contactWishChild.Id);
        OrientationandTrainingUtil.insertDocusignSetting();
        ApexPAges.StandardController sc = new ApexPages.StandardController(caseId);
        PageReference pageRef = Page.WishClearanceSendNow_VF;
        pageRef.getParameters().put('id',String.valueOf(caseId.Id));
        Test.setCurrentPage(pageRef);
        WishChildSummary_AC wishClear = new WishChildSummary_AC(sc);
        wishClear.SendtoDocuSign();
        wishClear.DisplayMessage();
        
        //WishChildSummary_AC.CallouttoDocusign(caseId.id);
        wishClear.cancel();
        
        
        
        
    }*/
    
    public static testMethod void createParentCaseWithTravel(){
        Constituent_Code__c consTituent = OrientationandTrainingUtil.createWishParentGuardiansContituentCode();
        Constituent_Code__c  cinstChild = OrientationandTrainingUtil.createWishChildContituentCode();
        Contact contactWishChild =   OrientationandTrainingUtil.CreateWishChild(); 
        Case caseId = OrientationandTrainingUtil.CreateParentCaseWithTravel(contactWishChild.Id);
        OrientationandTrainingUtil.insertDocusignSetting();
        ApexPAges.StandardController sc = new ApexPages.StandardController(caseId);
        PageReference pageRef = Page.WishClearanceSendNow_VF;
        pageRef.getParameters().put('id',String.valueOf(caseId.Id));
        Test.setCurrentPage(pageRef);
        WishChildSummary_AC wishClear = new WishChildSummary_AC(sc);
        wishClear.SendtoDocuSign();
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new Mock_ResponseGenerator()); 
        WishChildSummary_AC.CallouttoDocusign(caseId.id);
        Test.StopTest();
        
    }


}