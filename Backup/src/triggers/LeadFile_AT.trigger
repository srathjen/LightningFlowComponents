/*****************************************************************************************************************
Author      : MST Solutions
Date        : 10/25/2016
Description : This trigger is used to generate file path for the attachment that inserted under lead record to SDrive
*******************************************************************************************************************/
trigger LeadFile_AT on Lead_File__c (after insert,after update) {
    set<Id> leadFileIdsSet = new set<id>();
    //Used to generate file path for new Lead File record
    if(Trigger.isAfter && Trigger.isInsert) {
        AWSFilePath_AC.generateLeadFilePath(trigger.newMap.keySet());
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        for(Lead_File__c currentLeadFile : trigger.new){
            if(currentLeadFile.File_Path__c != Null && trigger.oldMap.get(currentLeadFile.id).File_Path__c != currentLeadFile.File_Path__c){
                leadFileIdsSet.add(currentLeadFile.id);
             }            
        }
        
        if(leadFileIdsSet.Size() > 0) {
            LeadTriggerHandler newLead = new LeadTriggerHandler();
            newLead.updatecaseMedicalSummaryAttachments(leadFileIdsSet);
        }
    }
}