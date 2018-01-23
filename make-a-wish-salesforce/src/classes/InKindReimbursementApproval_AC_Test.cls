/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Chandrasekar
Date        : 4/10/2016
Description : This class is used to make sure the unit test and functionality for the InKindDonationReimbursement_AT
****************************************************************************************************/
@isTest
public class InKindReimbursementApproval_AC_Test {
    
    //This method used to create a inkind type record for inkinddonorobject
    static testMethod void callInkindApprovalMethods(){
        Constant_AC newConstant =  new Constant_AC();
        Id inkindgRecordTypeId = Schema.SObjectType.In_Kind_Donation_Reimbursement__c.getRecordTypeInfosByName().get(newConstant.InKind).getRecordTypeId();
        Case parent=OrientationandTrainingUtil.createParentCase();
        Contact cntid=OrientationandTrainingUtil.CreateWishChild();
        Id WishRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Wish').getRecordTypeId();
        Case caseid=OrientationandTrainingUtil.createWishGrantCase(cntid.Id,parent.Id);
        Case cs=new Case();
        cs.Id=caseid.Id;
        cs.RecordTypeId=WishRecordTypeId;
        update cs;
        In_Kind_Donation_Reimbursement__c inKind2 = OrientationandTrainingUtil.CreateInkindRecord(caseid.Id);
        System.assertEquals(inkindgRecordTypeId, inKind2.RecordTypeId,'Check Inkind RecordType');
        InKindReimbursementApproval_AC.submitApproval(inKind2.id,'In-Kind Donation');
        inkind2.Documentation__c='Will Attach';
        InKindReimbursementApproval_AC.submitApproval(inKind2.id,'In-Kind Donation');
    }
    //This method used to create a Inkind donor type record for inkinddonorobject without attachment.
    static testMethod void callInkindApprovalWithoutAttachment(){
        Constant_AC newConstant =  new Constant_AC();
        Id inkindgRecordTypeId = Schema.SObjectType.In_Kind_Donation_Reimbursement__c.getRecordTypeInfosByName().get(newConstant.InKind).getRecordTypeId();
        //   In_Kind_Donation_Reimbursement__c inKind = OrientationandTrainingUtil.CreateInkindRecordWithOutAttachment();
        Case parent=OrientationandTrainingUtil.createParentCase();
        Contact cntid=OrientationandTrainingUtil.CreateWishChild();
        Id WishRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Wish').getRecordTypeId();
        Case caseid=OrientationandTrainingUtil.createWishGrantCase(cntid.Id,parent.Id);
        Case cs=new Case();
        cs.Id=caseid.Id;
        cs.RecordTypeId=WishRecordTypeId;
        update cs;
        In_Kind_Donation_Reimbursement__c inKind2 = OrientationandTrainingUtil.CreateInkindRecord(caseid.Id);
        System.assertEquals(inkindgRecordTypeId, inKind2.RecordTypeId,'Check Inkind RecordType');
        InKindReimbursementApproval_AC.submitApproval(inKind2.id,'In-Kind Donation');
    }
    
    //This method used to create a reimbursement type record for inkinddonorobject
    static testMethod void callReimbursementApprovalMethods(){
        Constant_AC newConstant =  new Constant_AC();
        Case parent=OrientationandTrainingUtil.createParentCase();
        Contact cntid=OrientationandTrainingUtil.CreateWishChild();
        Id WishRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Wish').getRecordTypeId();
        Case caseid=OrientationandTrainingUtil.createWishGrantCase(cntid.Id,parent.Id);
        Case cs=new Case();
        cs.Id=caseid.Id;
        cs.RecordTypeId=WishRecordTypeId;
        update cs;
        Id reEmbRT = Schema.SObjectType.In_Kind_Donation_Reimbursement__c.getRecordTypeInfosByName().get(newConstant.Reimbursement).getRecordTypeId();
        In_Kind_Donation_Reimbursement__c reimbursement = OrientationandTrainingUtil.CreateReimbursRecordWithCase(caseid.Id);
        System.assertEquals(reEmbRT, reimbursement.RecordTypeId,'Check Reimbursement RecordType');
        InKindReimbursementApproval_AC.submitApproval(reimbursement.id,'Reimbursement');
    }
    //This method used to create a reimbursement type record for inkinddonorobject without Attaachement.
    static testMethod void callReimbursementApprovalWithoutAttachment(){
        Constant_AC newConstant =  new Constant_AC();
        Id reEmbRT = Schema.SObjectType.In_Kind_Donation_Reimbursement__c.getRecordTypeInfosByName().get(newConstant.Reimbursement).getRecordTypeId();
        In_Kind_Donation_Reimbursement__c reimbursement = OrientationandTrainingUtil.CreateReimbursRecordWithOutAttachment();
        System.assertEquals(reEmbRT,reimbursement.RecordTypeId,'Check Reimbursement RecordType');
        InKindReimbursementApproval_AC.submitApproval(reimbursement.id,'Reimbursement');
    }
}