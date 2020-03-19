/*****************************************************************************************************************
Created By : MST Solutions
Created Date : 3/27/2017
Description : This test class used to perform unit testing for the DV Medical Summary Attachment
*******************************************************************************************************************/
@IsTest
public class wifAttachment_AC_Test {

    private static final String ATTACHMENT_NAME_WISH_FAMILY_FORM = 'Wish Family Form';

    /************************************************************
    Globally create a chapter account and Wish child.
    **************************************************************/
    @TestSetup
    public static void setUpData() {
        trac_TriggerHandlerBase.blockTrigger = true;
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
        insert new List<Account>{
                chapterAccount, chapterAmericaAccount
        };

        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;

        Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        insert parentCase;

        cg__CaseFile__c caseFile = OrientationandTrainingUtil.createCaseFileRecord(parentCase.Id);
        insert caseFile;
        trac_TriggerHandlerBase.blockTrigger = false;
    }

    /***************************************
    Attachment for wish case from the controller.
    ***************************************/
    @IsTest
    public static void getAttachment() {
        Case newCase = [
                SELECT Id
                FROM Case
                LIMIT 1
        ];
        List<cg__CaseFile__c > caseFile = [
                SELECT Id,cg__Case__c
                FROM cg__CaseFile__c
                LIMIT 5000
        ];

        Test.startTest();
        PageReference pageRef = Page.wifAttachment_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put(wifAttachment_AC.URL_PARAMETER_ID, newCase.Id);
        ApexPages.currentPage().getParameters().put(wifAttachment_AC.URL_PARAMETER_SAVED, wifAttachment_AC.URL_VALUE_TRUE);
        wifAttachment_AC wishFile = new wifAttachment_AC();
        wishFile.getAttachments();
        Attachment attach = new Attachment();
        attach.Name = ATTACHMENT_NAME_WISH_FAMILY_FORM;
        Blob bodyBlob = Blob.valueOf(ATTACHMENT_NAME_WISH_FAMILY_FORM);
        attach.Body = bodyBlob;
        wishFile.newAttachment = attach;
        wishFile.save();
        wishFile.attachmentId = caseFile[0].Id;
        wishFile.RemoveAttachment();
        Test.stopTest();
        System.assertEquals(attach.Name, ATTACHMENT_NAME_WISH_FAMILY_FORM, 'Attachment does not have a matched file name');
        System.assert(caseFile[0].cg__Case__c == newCase.Id, 'A wish doest not have Attachment');
        System.assertEquals(0, [
                SELECT Id
                FROM cg__CaseFile__c
                WHERE Id = :caseFile[0].Id
        ].size(), 'Case Attachment should have been deleted');
    }
}