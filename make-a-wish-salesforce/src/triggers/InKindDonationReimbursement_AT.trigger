/***************************************************************************************************
Author      : MST Solutions
Date        : 4/10/2016
Description : This trigger us used to fetch the associated case owner,case owner's manager 
****************************************************************************************************/
trigger InKindDonationReimbursement_AT on In_Kind_Donation_Reimbursement__c (before update) {
	trac_TriggerHandlerBase.triggerHandler(new InKindDonationReimburseDomain());
}