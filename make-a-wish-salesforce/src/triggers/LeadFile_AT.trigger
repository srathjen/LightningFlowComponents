/*****************************************************************************************************************
Author      : MST Solutions
Date        : 10/25/2016
Description : This trigger is used to generate file path for the attachment that inserted under lead record to SDrive
*******************************************************************************************************************/
trigger LeadFile_AT on Lead_File__c (after insert,after update) {
    set<Id> leadFileIdsSet = new set<id>();
    Map<Id,String> leadFileMap = new Map<Id,String>();
    //Used to generate file path for new Lead File record
    if(Trigger.isAfter && Trigger.isInsert) {
        for(Lead_File__c lf : Trigger.new){
            leadFileIdsSet.add(lf.Id);
            leadFileMap.put(lf.Id,String.valueOf(lf));
        }
        AWSFilePath_AC.generateLeadFilePath(leadFileIdsSet,leadFileMap);
    }
    
    
}