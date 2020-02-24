/*****************************************************************************************************************
Author      : MST Solutions
Date        : 
Description : It called the when the chapter is changed in lead reocord.
*******************************************************************************************************************/global class ChapterChangeConfirmationPopup_AC {
    public ChapterChangeConfirmationPopup_AC(ApexPages.StandardController controller){
        
    }    
    @RemoteAction
    global static String updateLeadChapter(String opt, String LeadId){  
        Lead processLead = [SELECT Id, ChapterName__c, Hidden_Chapter_Change_Confirmation__c FROM Lead WHERE Id=:LeadId LIMIT 1];
        Lead updateLead = new Lead(Id = processLead.Id);  
        
        if(opt == 'revert'){
            updateLead.ChapterName__c = processLead.Hidden_Chapter_Change_Confirmation__c;       
            updateLead.Hidden_Chapter_Change_Confirmation__c = processLead.Hidden_Chapter_Change_Confirmation__c;
        }else{
            updateLead.Hidden_Chapter_Change_Confirmation__c = processLead.ChapterName__c;        
        }
        update updateLead;
        return updateLead.Hidden_Chapter_Change_Confirmation__c;
    }
}