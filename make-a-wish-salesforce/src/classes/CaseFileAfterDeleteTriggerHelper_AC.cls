Public class CaseFileAfterDeleteTriggerHelper_AC{
    
    public static void updateFilePath(Map<Id,String> filePathMap){
        List<Minor_Participant__c> deleteMinorParticipantList = new List<Minor_Participant__c>();
        List<Minor_Participant__c> UpdateMinorParticipantList = new List<Minor_Participant__c>();
        case updatecase = new case();   
        integer i = 1;
        Map<Id,Case> updateCaseMap = new Map<Id,Case>();
        Set<Id> caseIdSet = new Set<Id>();
        for(Minor_Participant__c dbMinorParticipant : [SELECT Id,AttachmentId__c,File_Path__c,Case__c  
                                                       FROM Minor_Participant__c WHERE Case__c IN: filePathMap.KeySet()]){
            
            if(filePathMap.containsKey(dbMinorParticipant.Case__c)){
                if(filePathMap.get(dbMinorParticipant.Case__c)  == dbMinorParticipant.File_Path__c){
                    deleteMinorParticipantList.add(dbMinorParticipant);
                    caseIdSet.add(dbMinorParticipant.Case__c);
                }
                else{
                    UpdateMinorParticipantList.add(dbMinorParticipant);
                }
            }
        }
       
        if(UpdateMinorParticipantList.size() > 0){
        for(Minor_Participant__c processminorRec : UpdateMinorParticipantList){
            
                if(filePathMap.containsKey(processminorRec.Case__c)){
                     updatecase.Id = processminorRec.Case__c;
                     if(updatecase.File_Path__c == Null){
                         updatecase.File_Path__c = i +'-'+' '+processminorRec.File_Path__c+'<br><br>';
                     }
                     else
                     {
                         updatecase.File_Path__c = updatecase.File_Path__c + i +'-'+' '+processminorRec.File_Path__c+'<br><br>';
                     }
                       i++;
                    updateCaseMap.put(updatecase.Id,updatecase);
                }
        }
       }
       else{
           for(case dbcase : [SELECT Id,File_Path__c FROM Case WHERE Id IN: caseIdSet]){
               dbcase.File_Path__c = null;
               updateCaseMap.put(dbcase.Id,dbcase);
           }
       }
        if(updateCaseMap.size() > 0){
            update updateCaseMap.values();
        }
        
        if(deleteMinorParticipantList.size() > 0)
        delete deleteMinorParticipantList ;
        
    }
}