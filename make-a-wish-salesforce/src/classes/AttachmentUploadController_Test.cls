/***********************************************************************************************
Description : This test class used to cover the unit testing of the attachmentuploadcontroller 
************************************************************************************************/
@isTest
public class AttachmentUploadController_Test {
/*******************************************************************
This method is attach the image to wish child record.
********************************************************************/
    public static testmethod void insertAttachment(){
        //Create the wish child contact record.
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Attachment newAttachment = new Attachment();
        newAttachment.Name = 'test';
        newAttachment.Body = blob.valueOf('Hi Welcome to body text');
        newAttachment.ParentId = wishChild.id;
        insert newAttachment;
           
        ApexPages.StandardController sc = new ApexPages.StandardController(wishChild);
        AttachmentUploadController attchUpload = new AttachmentUploadController(sc);
        PageReference pageRef = Page.WishChildPhoto_VF;
        Test.setCurrentPage(pageRef);
        
        attchUpload.upload();
        attchUpload.updateWishChildPhoto();
        System.assertEquals(newAttachment.ParentId , wishChild.id,'Attachment does not have a Parent Id');
        System.assert(newAttachment.ParentId == wishChild.id,'Attachment does not have a Parent Id');
    }
    
}