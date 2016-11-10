trigger CaseFile_AT on cg__CaseFile__c (before insert,after insert) {
    
    if(Trigger.isAfter && Trigger.isInsert) {
        List<Id> CaseIds = new List<Id>();
        for(cg__CaseFile__c acc: Trigger.new){
            CaseIds.add(acc.Id);
        }
        AWSFilePath_AC.updateCaseFilePath(CaseIds);
        AWSFilePath_AC.createAttachmentReviewTask(Trigger.newMap);
    }
    
    /*if(Trigger.isBefore && Trigger.isInsert) {
        
        Set<Id> parentCaseIdSet = new Set<Id>();
        List<cg__CaseFile__c> caseFileList = new List<cg__CaseFile__c>();
        for(cg__CaseFile__c newCaseFile : Trigger.New) {
            parentCaseIdSet.add(newCaseFile.cg__Case__c);
            caseFileList.add(newCaseFile);
        }
        
        if(parentCaseIdSet.size() > 0 && caseFileList.size() > 0) {
            AWSFilePath_AC.populateRelatedInfo(parentCaseIdSet,caseFileList);
        }
        
    }*/
}