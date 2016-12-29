trigger InKindDonationReimbursementFile_AT on In_Kind_Donation_Reimbursement_File__c (After insert) {
    List<Id> drIds = new List<Id>();
    for(In_Kind_Donation_Reimbursement_File__c dr: Trigger.new){
        drIds.add(dr.Id);
    }
    AWSFilePath_AC.UpdateInKindDonReimburFilePath(drIds);
}