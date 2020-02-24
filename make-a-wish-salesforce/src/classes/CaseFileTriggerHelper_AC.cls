public class CaseFileTriggerHelper_AC{

    public static void updateFilePath(set<Id> caseIdSet,map<string,string> casefileMap){
        List<Minor_Participant__c> minorParticipantList = new List<Minor_Participant__c>();
        for(Minor_Participant__c dbMinorParticipantRec : [SELECT Id,Case__c,File_Path__c,Form_Name__c,AttachmentId__c,
                                                          RecordTypeId FROM Minor_Participant__c WHERE Case__c IN: caseIdSet]){
                                                              if(caseIdSet.contains(dbMinorParticipantRec.Case__c)){
                                                                  if(caseFileMap.containsKey(dbMinorParticipantRec.AttachmentId__c)){

                                                                      dbMinorParticipantRec.File_Path__c = caseFileMap.get(dbMinorParticipantRec.AttachmentId__c);
                                                                      minorParticipantList.add(dbMinorParticipantRec);
                                                                  }
                                                              }    
                                                          }
        
        if(minorParticipantList.size() > 0){
            update minorParticipantList;
        }
    }
}