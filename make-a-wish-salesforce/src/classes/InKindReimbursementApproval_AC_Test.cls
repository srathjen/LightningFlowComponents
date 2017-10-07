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
        In_Kind_Donation_Reimbursement__c inKind = OrientationandTrainingUtil.CreateInkindRecord();
        System.assertEquals(inkindgRecordTypeId, inKind.RecordTypeId);
        InKindReimbursementApproval.submitApproval(inKind.id);
    }
    
    static testMethod void callInkindApprovalWithoutAttachment(){
        Constant_AC newConstant =  new Constant_AC();
        Id inkindgRecordTypeId = Schema.SObjectType.In_Kind_Donation_Reimbursement__c.getRecordTypeInfosByName().get(newConstant.InKind).getRecordTypeId();
        In_Kind_Donation_Reimbursement__c inKind = OrientationandTrainingUtil.CreateInkindRecordWithOutAttachment();
        System.assertEquals(inkindgRecordTypeId, inKind.RecordTypeId);
        InKindReimbursementApproval.submitApproval(inKind.id);
    }
    
    //This method used to create a reimbursement type record for inkinddonorobject
    static testMethod void callReimbursementApprovalMethods(){
        Constant_AC newConstant =  new Constant_AC();
        Id reEmbRT = Schema.SObjectType.In_Kind_Donation_Reimbursement__c.getRecordTypeInfosByName().get(newConstant.Reimbursement).getRecordTypeId();
        In_Kind_Donation_Reimbursement__c reimbursement = OrientationandTrainingUtil.CreateReimbursRecord();
        System.assertEquals(reEmbRT, reimbursement.RecordTypeId);
        InKindReimbursementApproval.submitReimbursementApproval(reimbursement.id);
    }
    
    static testMethod void callReimbursementApprovalWithoutAttachment(){
        Constant_AC newConstant =  new Constant_AC();
        Id reEmbRT = Schema.SObjectType.In_Kind_Donation_Reimbursement__c.getRecordTypeInfosByName().get(newConstant.Reimbursement).getRecordTypeId();
        In_Kind_Donation_Reimbursement__c reimbursement = OrientationandTrainingUtil.CreateReimbursRecordWithOutAttachment();
        System.assertEquals(reEmbRT, reimbursement.RecordTypeId);
        InKindReimbursementApproval.submitReimbursementApproval(reimbursement.id);
    }
}