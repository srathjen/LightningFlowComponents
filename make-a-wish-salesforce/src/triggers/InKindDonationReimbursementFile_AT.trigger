/***************************************************************************************************
Author      : MST Solutions
Date        : 4/10/2016
Description : This trigger is used to update the Documentation picklist value of the related inkind donation and reimbursement record
****************************************************************************************************/
trigger InKindDonationReimbursementFile_AT on InkindDon_reimburseFile__c (after insert, after delete) {
	trac_TriggerHandlerBase.triggerHandler(new InKindDonReimburseFileDomain());
}