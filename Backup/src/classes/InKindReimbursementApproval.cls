/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Chandrasekar
Date        : 4/10/2016
Description : This class is used to submit the record for approval
****************************************************************************************************/
global class InKindReimbursementApproval{
    
    webservice static String submitApproval(Id inKindId){
        list<ProcessInstanceWorkitem> approvalList = [SELECT Id,ProcessInstanceId,ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectID =: inKindID];
        list<In_Kind_Donation_Reimbursement__c> inkindList = [SELECT ID,Documentation__c FROM In_Kind_Donation_Reimbursement__c WHERE ID =: inKindId Limit 1];
        list<In_Kind_Donation_Reimbursement_File__c> attchmentList = [SELECT ID,Name,Parent__c,Parent__r.Documentation__c from In_Kind_Donation_Reimbursement_File__c WHERE Parent__c =: inKindId Limit 1];
        string message;
        if(approvalList.size()>0){
            message = 'This record already in approval process,you can not submit once again';
        }
        else if(( inkindList[0].Documentation__c == 'Will Attach' && attchmentList.size() >0 ) || (inkindList[0].Documentation__c == 'Not available' &&  attchmentList.size() >0) ||
           (inkindList[0].Documentation__c == 'Not available' &&  attchmentList.size() == 0) )
        {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting request for approval');
            req.setObjectId(inKindId);
            req.setProcessDefinitionNameOrId('In_Kind_Donation_Reimbursement_Approval');
            req.setNextApproverIds(Null);
            req.setSkipEntryCriteria(true);
            if(!Test.IsRunningTest())
            Approval.ProcessResult result = Approval.process(req);
            message = 'Record was successfully submited for approval';
        }
        else if(inkindList[0].Documentation__c == 'Will Attach' && attchmentList.size() == 0){
            message = 'Please Attach all in-kind related receipts or documentation below or select Documentation Not available.';
        }
        return message;
    }
    
    
    webservice static String submitReimbursementApproval(Id inKindId){
        list<ProcessInstanceWorkitem> approvalList = [SELECT Id,ProcessInstanceId,ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectID =: inKindID];
        list<In_Kind_Donation_Reimbursement__c> inkindList = [SELECT ID,Documentation__c FROM In_Kind_Donation_Reimbursement__c WHERE ID =: inKindId Limit 1];
        list<In_Kind_Donation_Reimbursement_File__c> attchmentList = [SELECT ID,Name,Parent__c,Parent__r.Documentation__c from In_Kind_Donation_Reimbursement_File__c WHERE Parent__c =: inKindId Limit 1];
        string message;
        if(approvalList.size()>0){
            message = 'This record already in approval process,you can not submit once again';
        }
        else if(( inkindList[0].Documentation__c == 'Will Attach' && attchmentList.size() >0 ) || (inkindList[0].Documentation__c == 'Not available' &&  attchmentList.size() >0) ||
           (inkindList[0].Documentation__c == 'Not available' &&  attchmentList.size() == 0) )
        {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting request for approval');
            req.setObjectId(inKindId);
            req.setProcessDefinitionNameOrId('Reimbursement_Approval');
            req.setNextApproverIds(Null);
            req.setSkipEntryCriteria(true);
            if(!Test.IsRunningTest())
            Approval.ProcessResult result = Approval.process(req); 
            message = 'Record was successfully submited for approval';
        }
        else if(inkindList[0].Documentation__c == 'Will Attach' && attchmentList.size() == 0){
            message = 'Please Attach all in-kind related receipts or documentation below or select Documentation Not available.';
        }
        return message;
        
    }
    
}