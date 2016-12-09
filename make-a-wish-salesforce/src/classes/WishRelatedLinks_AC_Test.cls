@isTest

public class WishRelatedLinks_AC_Test {
    
    
    public static testMethod void wishRelatedLink(){
        
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(parentCase);
        WishRelatedLinks_AC testAccPlan = new WishRelatedLinks_AC(sc);
        
        PageReference pageRef = Page.WishRelatedLinks_VF;
        //pageRef.getParameters().put('Id', String.valueOf(pay.Id));
        Test.setCurrentPage(pageRef);
    }
    
    public static testMethod void wisGrantedCase(){
        
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        Case wishGrantCase = OrientationandTrainingUtil.createWishGrantCase(wishChild.Id,parentCase.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(wishGrantCase);
        WishRelatedLinks_AC testAccPlan = new WishRelatedLinks_AC(sc);
        
        PageReference pageRef = Page.WishRelatedLinks_VF;
        //pageRef.getParameters().put('Id', String.valueOf(pay.Id));
        Test.setCurrentPage(pageRef);
    }

}