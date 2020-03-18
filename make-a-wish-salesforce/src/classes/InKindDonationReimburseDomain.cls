/**
 * @description     Domain class for In_Kind_Donation_Reimbursement__c object
 *
 * @author          Chris Shinnimin, Traction on Demand
 * @date            2020-03-17
 */
public with sharing class InKindDonationReimburseDomain extends trac_TriggerHandlerBase {
    List<In_Kind_Donation_Reimbursement__c> newInKindDonationReimbursements = (List<In_Kind_Donation_Reimbursement__c>) newRecordsList;
    List<In_Kind_Donation_Reimbursement__c> oldInKindDonationReimbursements = (List<In_Kind_Donation_Reimbursement__c>) oldRecordsList;
    Map<Id, In_Kind_Donation_Reimbursement__c> newInKindDonationReimbursementsMap = (Map<Id, In_Kind_Donation_Reimbursement__c>) newRecordsMap;
    Map<Id, In_Kind_Donation_Reimbursement__c> oldInKindDonationReimbursementsMap = (Map<Id, In_Kind_Donation_Reimbursement__c>) oldRecordsMap;

    public override void handleBeforeUpdate() {
        InKindDonationReimburseService.validateChapterRole(newInKindDonationReimbursements, newInKindDonationReimbursementsMap);
    }
}