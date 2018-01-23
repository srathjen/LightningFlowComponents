/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Chandrasekar
Date        : 4/10/2016
Description : This class is used to submit the Inkind and Reimbursement record for approval process when
              the user click the custom submit for approval button in Inkind and Reimbursement detail page.
****************************************************************************************************/
global class InKindReimbursementApproval_AC{
     /******************************************************************************************************
     This submitApproval webservice method is called when the user click the submit for approval button
     on kInkind and Reimbursement detail page. Once volunteer or chappter staff click this button the record
     goes to approval process and success message will displyed.
     *******************************************************************************************************/
     webservice static String submitApproval(Id inKindId,String recordType){
        list<ProcessInstanceWorkitem> approvalList = [SELECT Id,ProcessInstanceId,ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectID =: inKindID];
        list<In_Kind_Donation_Reimbursement__c> inkindList = [SELECT ID,Documentation__c, Wish__r.OwnerId FROM In_Kind_Donation_Reimbursement__c WHERE ID =: inKindId Limit 1];
        list<InkindDon_reimburseFile__c> attchmentList = [SELECT ID,Name,Parent__c,Parent__r.Documentation__c from InkindDon_reimburseFile__c WHERE Parent__c =: inKindId Limit 1];
        string message;
        if(approvalList.size()>0){
            message = 'This record has already been submitted for approval and cannot be submitted again.';
        }
        else if(( inkindList[0].Documentation__c == 'Will Attach' && attchmentList.size() >0 ) || (inkindList[0].Documentation__c == 'Not available' &&  attchmentList.size() >0) ||
           (inkindList[0].Documentation__c == 'Not available' &&  attchmentList.size() == 0) || ( inkindList[0].Documentation__c == 'Attached' && attchmentList.size() >0 ) )
        {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting request for approval');
            req.setObjectId(inKindId);
            if(recordType == 'In-Kind Donation')
                req.setProcessDefinitionNameOrId('In_Kind_Donation_Reimbursement_Approval');
            else if(recordType == 'Reimbursement')
                req.setProcessDefinitionNameOrId('Reimbursement_Approval_To_Wish_Owner');  
            req.setNextApproverIds(new Id[]{inkindList[0].Wish__r.OwnerId});
            req.setSkipEntryCriteria(true);
            Approval.ProcessResult result = Approval.process(req);
            message = 'Please click OK to return to the In-Kind Donation & Reimbursement Page.';
        }
        else if((inkindList[0].Documentation__c == 'Will Attach' || inkindList[0].Documentation__c == 'Attached' ) && attchmentList.size() == 0){
            message = 'Please attach all In-kind receipts or documentation below or select Documentation as Not Available.';
        }
        return message;
    }
    
    
}