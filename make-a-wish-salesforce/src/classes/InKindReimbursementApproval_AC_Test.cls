/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Chandrasekar
Date        : 4/10/2016
Description : This class is used to make sure the unit test and functionality for the InKindDonationReimbursement_AT
****************************************************************************************************/
@isTest
public class InKindReimbursementApproval_AC_Test {

	private final static Id wishRecordTypeId = Constant_AC.WISH_RT_ID;

	//This method used to create a inkind type record for inkinddonorobject
	static testMethod void callInkindApprovalMethods() {
		Id inkindgRecordTypeId = Constant_AC.IN_KIND_ID;
		Case parent = OrientationandTrainingUtil.createParentCase();
		insert parent;
		Contact cntid = OrientationandTrainingUtil.CreateWishChild();
		insert cntid;
		Case caseid = OrientationandTrainingUtil.createWishGrantCase(cntid.Id, parent.Id);
		insert caseid;
		Case cs = new Case();
		cs.Id = caseid.Id;
		cs.RecordTypeId = wishRecordTypeId;
		update cs;
		In_Kind_Donation_Reimbursement__c inKind2 = OrientationandTrainingUtil.CreateInkindRecord(caseid.Id);
		insert inKind2;
		System.assertEquals(inkindgRecordTypeId, inKind2.RecordTypeId, 'Check Inkind RecordType');
		InKindReimbursementApproval_AC.submitApproval(inKind2.Id, 'In-Kind Donation');
		inKind2.Documentation__c = 'Will Attach';
		InKindReimbursementApproval_AC.submitApproval(inKind2.Id, 'In-Kind Donation');
	}

	//This method used to create a Inkind donor type record for inkinddonorobject without attachment.
	static testMethod void callInkindApprovalWithoutAttachment() {
		Id inkindgRecordTypeId = Constant_AC.IN_KIND_ID;
		//   In_Kind_Donation_Reimbursement__c inKind = OrientationandTrainingUtil.CreateInkindRecordWithOutAttachment();
		Case parent = OrientationandTrainingUtil.createParentCase();
		insert parent;
		Contact cntid = OrientationandTrainingUtil.CreateWishChild();
		insert cntid;
		Case caseid = OrientationandTrainingUtil.createWishGrantCase(cntid.Id, parent.Id);
		insert caseid;
		Case cs = new Case();
		cs.Id = caseid.Id;
		cs.RecordTypeId = wishRecordTypeId;
		update cs;
		In_Kind_Donation_Reimbursement__c inKind2 = OrientationandTrainingUtil.CreateInkindRecord(caseid.Id);
		insert inKind2;
		System.assertEquals(inkindgRecordTypeId, inKind2.RecordTypeId, 'Check Inkind RecordType');
		InKindReimbursementApproval_AC.submitApproval(inKind2.Id, 'In-Kind Donation');
	}

	//This method used to create a reimbursement type record for inkinddonorobject
	static testMethod void callReimbursementApprovalMethods() {
		Case parent = OrientationandTrainingUtil.createParentCase();
		insert parent;
		Contact cntid = OrientationandTrainingUtil.CreateWishChild();
		insert cntid;
		Case caseid = OrientationandTrainingUtil.createWishGrantCase(cntid.Id, parent.Id);
		insert caseid;
		Case cs = new Case();
		cs.Id = caseid.Id;
		cs.RecordTypeId = wishRecordTypeId;
		update cs;
		Id reEmbRT = Constant_AC.REIMBURSEMENT_ID;
		In_Kind_Donation_Reimbursement__c reimbursement = OrientationandTrainingUtil.CreateReimbursRecordWithCase(caseid.Id);
		insert reimbursement;
		System.assertEquals(reEmbRT, reimbursement.RecordTypeId, 'Check Reimbursement RecordType');
		InKindReimbursementApproval_AC.submitApproval(reimbursement.Id, 'Reimbursement');
	}

	//This method used to create a reimbursement type record for inkinddonorobject without Attaachement.
	static testMethod void callReimbursementApprovalWithoutAttachment() {
		Id reEmbRT = Constant_AC.REIMBURSEMENT_ID;
		In_Kind_Donation_Reimbursement__c reimbursement = OrientationandTrainingUtil.CreateReimbursRecordWithOutAttachment();
		insert reimbursement;
		System.assertEquals(reEmbRT, reimbursement.RecordTypeId, 'Check Reimbursement RecordType');
		InKindReimbursementApproval_AC.submitApproval(reimbursement.Id, 'Reimbursement');
	}
}