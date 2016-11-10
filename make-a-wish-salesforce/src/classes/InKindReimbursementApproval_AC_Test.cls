@isTest
public class InKindReimbursementApproval_AC_Test {
    //This method used to create a inkind type record for inkinddonorobject
    static testMethod void callInkindApprovalMethods(){
        In_Kind_Donation_Reimbursement__c inKind = OrientationandTrainingUtil.CreateInkindRecord();
        OrientationandTrainingUtil.CreateInkindFileRecord();
        InKindReimbursementApproval.submitApproval(inKind.id);
        
    }
    //This method used to create a reimbursement type record for inkinddonorobject
    static testMethod void callReimbursementApprovalMethods(){
        In_Kind_Donation_Reimbursement__c reimbursement = OrientationandTrainingUtil.createReImbursementRecord();
        OrientationandTrainingUtil.CreateReimburseFileRecord();
        InKindReimbursementApproval.submitReimbursementApproval(reimbursement.id);
      
    }
}