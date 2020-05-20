/**
 * Author      : MST Solutions
 * CreatedBy   : Chandrasekar
 * Date        : 4/10/2016
 * Description : This class is used to submit the Inkind and Reimbursement record for approval process when
 * the user click the custom submit for approval button in Inkind and Reimbursement detail page.
 **/
global class InKindReimbursementApproval_AC {

    @TestVisible private static final String DOCUMENTATION_NOT_AVAILABLE = 'Not available';
    @TestVisible private static final String DOCUMENTATION_WILL_ATTACH = 'Will Attach';
    @TestVisible private static final String DOCUMENTATION_ATTACHED = 'Attached';

    /*
     * @description     This webservice method is called when the user clicks the submit for approval button
     *                  on the Inkind and Reimbursement detail page. Once volunteer or chapter staff click this button
     *                  the record goes to approval process and success message will be displayed.
     *
     * @param           Id inKindId
     * @param           String recordType
     *
     * @return          String
     *
     * @author          MST Solutions
     * @date            2016-04-10
    */
    webService static String submitApproval(Id inKindId, String recordType) {
        List<ProcessInstanceWorkitem> approvalList = [
                SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId
                FROM ProcessInstanceWorkitem
                WHERE ProcessInstance.TargetObjectId = :inKindId
        ];
        List<In_Kind_Donation_Reimbursement__c> inKindList = [
                SELECT Id, Documentation__c, Wish__r.OwnerId
                FROM In_Kind_Donation_Reimbursement__c
                WHERE Id = :inKindId
                LIMIT 1
        ];
        List<InkindDon_reimburseFile__c> attchmentList = [
                SELECT Id, Name, Parent__c, Parent__r.Documentation__c
                FROM InkindDon_reimburseFile__c
                WHERE Parent__c = :inKindId
                LIMIT 1
        ];

        String message;
        if (approvalList.size() > 0) {
            message = Label.InKind_Already_Submitted;
        } else if ((inKindList[0].Documentation__c == DOCUMENTATION_NOT_AVAILABLE)
                || (inKindList[0].Documentation__c == DOCUMENTATION_WILL_ATTACH && attchmentList.size() > 0)
                || (inKindList[0].Documentation__c == DOCUMENTATION_ATTACHED && attchmentList.size() > 0)) {

            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting request for approval');
            req.setObjectId(inKindId);

            if (recordType == Constant_AC.IN_KIND_DONATION_RT_LABEL) {
                req.setProcessDefinitionNameOrId('In_Kind_Donation_Reimbursement_Approval');
            } else if (recordType == Constant_AC.IN_KIND_REIMBURSEMENT_RT_LABEL) {
                req.setProcessDefinitionNameOrId('Reimbursement_Approval_To_Wish_Owner');
            }

            req.setNextApproverIds(new Id[]{
                    inKindList[0].Wish__r.OwnerId
            });

            req.setSkipEntryCriteria(true);

            Approval.process(req);

            message = Label.InKind_Return_Message;
        } else if ((inKindList[0].Documentation__c == DOCUMENTATION_WILL_ATTACH || inKindList[0].Documentation__c == DOCUMENTATION_ATTACHED)
                && attchmentList.size() == 0) {
            message = Label.InKind_Attach_Receipts;
        }
        return message;
    }
}