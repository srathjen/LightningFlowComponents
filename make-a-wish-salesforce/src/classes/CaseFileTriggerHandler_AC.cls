Public class CaseFileTriggerHandler_AC{

    Public static void onAfterUpdate(map<Id,cg__CaseFile__c> newCaseFileMap,map<Id,cg__CaseFile__c> oldcaseFileMap){
        Set<Id> caseIdSet = new Set<Id>();
        Map<String,String> caseFileMap = new Map<String,String>();
        List<Minor_Participant__c> minorParticipantList = new List<Minor_Participant__c>();
        
        for(cg__CaseFile__c newCaseFile : newCaseFileMap.Values()){
             if(newCaseFile.File_Path__c != Null){
                     caseIdSet.add(newCaseFile.cg__Case__c);
                     caseFileMap.put(newCaseFile.cg__File_Name__c,newCaseFile.File_Path__c);
               }
        }
        
        if(caseFileMap.size() > 0){
        CaseFileTriggerHelper_AC.updateFilePath(caseIdSet,caseFileMap);
        }
     }
}