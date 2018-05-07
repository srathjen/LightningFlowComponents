/*****************************************************************************************************************
Created By : MST Solutions
Created Date : 3/27/2017
Description : This test class used to perform unit testing for the DV Medical Summary Attachment
*******************************************************************************************************************/
@isTest
public class wifAttachment_AC_Test{
    /************************************************************
    Globally create a chapter account and Wish child.
    **************************************************************/
    @testSetup
    public static void setUpData(){
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        cg__CaseFile__c caseFile = OrientationandTrainingUtil.createCaseFileRecord(parentCase.Id);
        
    }
    
    /***************************************
    Attachment for wish case from the controller.
    ***************************************/
    public static testMethod void getAttachment() {
        case newcase = [SELECT ID FROM case LIMIT 1];        
        List<cg__CaseFile__c > caseFile = [SELECT Id,cg__Case__c FROM cg__CaseFile__c LIMIT 5000];
        List<Case> caseList = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        PageReference pageRef = Page.wifAttachment_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',newcase.Id);
        ApexPages.currentPage().getParameters().put('saved','true');
        wifAttachment_AC wishFile = new wifAttachment_AC();
        wishFile.getAttachments();
        Attachment attach = new Attachment();     
        attach.Name ='Wish Family Form';
        Blob bodyBlob = Blob.valueOf('Wish Family Form');
        attach.body = bodyBlob;
        wishFile.newAttachment = attach;
        wishFile.save();
        wishFile.Refresh();
        wishFile.attachmentId = caseFile [0].Id;
        wishFile.RemoveAttachment();
        Test.stopTest();
       System.assertEquals(attach.Name,'Wish Family Form','Attachment does not have a matched file name');
       System.assert(caseFile [0].cg__Case__c == caseList[0].Id,'A wish doest not have Attachment');
    }
}