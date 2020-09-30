/**
 * @description It called the when the chapter is changed in lead record.
 *
 * @author MST Solutions
 **/
global class ChapterChangeConfirmationPopup_AC {

    public ChapterChangeConfirmationPopup_AC(ApexPages.StandardController controller) {
    }

    /**
     * @description Updates Lead's ChapterName
     *
     * @param opt
     * @param leadId
     *
     * @return
     */
    @RemoteAction
    global static String updateLeadChapter(String opt, String leadId) {
        List<Id> leadIds = new List<Id>();
        leadIds.add(leadId);
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        if (opt == 'revert') {
            leadMap = LeadService.revertChapterNameChange(leadIds);
        } else {
            leadMap = LeadService.backupChapterNameChange(leadIds);
        }
        return leadMap.get(leadId).Hidden_Chapter_Change_Confirmation__c;
    }
    
    @RemoteAction
    global static void updateContactChapter(String action, String contactId) {
        Contact mpContact = [SELECT Id, Hidden_Chapter__c, Region_Chapter__c FROM Contact WHERE Id = :contactId];        
        if(action == 'revert') {
            mpContact.Region_Chapter__c = mpContact.Hidden_Chapter__c;
        } else {
            mpContact.Hidden_Chapter__c = mpContact.Region_Chapter__c;
        }
        try {
            update mpContact;
        } catch(Exception ex) {
            ErrorMessage_AC.createDebugRec('ChapterChangeConfirmationPopup_AC', String.valueOf(mpContact), String.valueOf(ex),
                                           'updateContactChapter', mpContact.Id, ex.getStackTraceString() + ' ' + ex.getMessage(), 'Error');
            mpContact.addError(Label.Debug_log_error_message);
        }
    }
    
    @RemoteAction
    global static void updateAccountChapter(String action, String accountId) {
        Account htfAccount = [SELECT Id, Hidden_Chapter__c, Chapter_Name__c FROM Account WHERE Id = :accountId];        
        if(action == 'revert') {
            htfAccount.Chapter_Name__c = htfAccount.Hidden_Chapter__c;
        } else {
            htfAccount.Hidden_Chapter__c = htfAccount.Chapter_Name__c;
        }
        try {
            update htfAccount;
        } catch(Exception ex) {
            ErrorMessage_AC.createDebugRec('ChapterChangeConfirmationPopup_AC', String.valueOf(htfAccount), String.valueOf(ex),
                                           'updateAccountChapter', htfAccount.Id, ex.getStackTraceString() + ' ' + ex.getMessage(), 'Error');
            htfAccount.addError(Label.Debug_log_error_message);
        }
    }
}