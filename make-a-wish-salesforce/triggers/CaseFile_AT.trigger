trigger CaseFile_AT on cg__CaseFile__c (before insert,after insert) {
    
    if(Trigger.isAfter && Trigger.isInsert) {
        List<Id> CaseIds = new List<Id>();
        Set<Id> caseIdsSet = new Set<Id>();
        for(cg__CaseFile__c acc: Trigger.new){
            CaseIds.add(acc.Id);
            if(acc.cg__Content_Type__c != 'Folder') {
                caseIdsSet.add(acc.Id);
            }
        }
        AWSFilePath_AC.UpdateCaseFilePath(CaseIds);
        AWSFilePath_AC.createAttachmentReviewTask(caseIdsSet);
    }
}