/************************************************************************************
Author : Mst Solutions
Description : This class is used to recall the approval process using salesforce support user
*************************************************************************************/
@RestResource (urlMapping='/recalApproval/*')
global class RecallApprovalRest_AC {
    
    @HttpPost
    global static String getBackApproval() {
        String[] uriKeys = RestContext.request.requestURI.split('/');
        String volOppString = uriKeys.get(uriKeys.size()-1);
        Set<Id> pendingVollOppIdSet = new Set<Id>();
        if(volOppString.contains(',')) {
            for(Id volOpp : volOppString.split(',')) {
                pendingVollOppIdSet.add(volOpp);
            }
        } else {
            pendingVollOppIdSet.add(volOppString);
        }
        
        try {
            List<Approval.ProcessWorkitemRequest> processInsList = new List<Approval.ProcessWorkitemRequest>();
            for(ProcessInstanceWorkitem approvalRecallRec : [SELECT Id, ProcessInstanceId,ProcessInstance.Status,ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN : pendingVollOppIdSet AND  ProcessInstance.Status = 'Pending']) {
                Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
                pwr.setWorkitemId(approvalRecallRec.Id);
                pwr.setAction('Removed');
                processInsList.add(pwr);
            }
            if(processInsList.size() > 0) {
                Approval.ProcessResult[] recallActions =  Approval.process(processInsList);
            }
            return null;
        } catch (Exception ex) {
            System.debug(ex.getMessage());
            return null;
        }
    }
}