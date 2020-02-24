/*****************************************************************************************************************
Author      : MST Solutions
Date        : 10/26/2016
Description : This class contains test method for InKindDonationReimbursementFile object
*******************************************************************************************************************/
@isTest
public class InKindDonationReimbursementFile_AT_Test {

	static testmethod void createCaseFile() {
		Account voluntterAccount = OrientationandTrainingUtil.createVolunteerAccount();
		insert voluntterAccount;
		Contact volunterrContct = OrientationandTrainingUtil.createVolunteerContact(voluntterAccount.id);
		insert volunterrContct;
		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		insert wishChild;
		Case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		insert wish;
		In_Kind_Donation_Reimbursement__c InkindRec = OrientationandTrainingUtil.CreateInkindRecord(wish.Id);
		insert InkindRec;
		InkindDon_reimburseFile__c newFileRecord = OrientationandTrainingUtil.createInkindDonaReimbFileRecord(InkindRec.Id);
		insert newFileRecord;
	}

	static testmethod void deleteInkind() {
		Account voluntterAccount = OrientationandTrainingUtil.createVolunteerAccount();
		insert voluntterAccount;
		Contact volunterrContct = OrientationandTrainingUtil.createVolunteerContact(voluntterAccount.id);
		insert volunterrContct;
		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		insert wishChild;
		Case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		insert wish;
		In_Kind_Donation_Reimbursement__c InkindRec = OrientationandTrainingUtil.CreateInkindRecord(wish.Id);
		insert InkindRec;
		InkindDon_reimburseFile__c newFileRecord = OrientationandTrainingUtil.createInkindDonaReimbFileRecord(InkindRec.Id);
		insert newFileRecord;
		Delete newFileRecord;
	}
}