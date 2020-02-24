Public class CaseFileAfterDeleteTriggerHandler_AC{

    public static void onAfterDelete(List<cg__CaseFile__c> oldCaseFileList){
    Map<Id,String> filePathMap = new Map<Id,String>();
    for(cg__CaseFile__c oldCaseFile : oldCaseFileList){
        
        if(oldCaseFile.File_Path__c != Null){
            filePathMap.put(oldCaseFile.cg__Case__c,oldCaseFile.File_Path__c);
         }
     }
     if(filePathMap.size() > 0)
     {
         CaseFileAfterDeleteTriggerHelper_AC.updateFilePath(filePathMap);
     }
   }
}