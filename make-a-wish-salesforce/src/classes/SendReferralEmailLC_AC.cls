public without sharing class SendReferralEmailLC_AC {
    
    @AuraEnabled
    public static Lead getLeadInformation(String leadId){
        Lead processLead = [SELECT 
                            Id,
                            ChapterName__c,
                            Is_Chapter_Active__c
                            FROM Lead 
                            WHERE Id =:leadId
                            LIMIT 1];
        return processLead;
    }
    
    @AuraEnabled    
    public static List<Office__c> getOfficeViaChapter(String ChapterId){
        List<Office__c> officeList = [SELECT 
                                      Id,
                                      Name, 
                                      Referral_Email_Address__c, 
                                      Chapter__r.Onboarded_on_SF__c,
                                      Chapter__c 
                                      FROM Office__c 
                                      WHERE Chapter__c =:ChapterId 
                                      LIMIT 50000];
        return officeList;
    }
    
    @AuraEnabled
    public static List<Office__c> getOfficeViaLead(String leadId){
        Lead processLead = SendReferralEmailLC_AC.getLeadInformation(leadId);
        
        return SendReferralEmailLC_AC.getOfficeViaChapter(processLead.ChapterName__c);
    }
    
    @AuraEnabled
    public static String triggerEmail(String leadId, String emailId){
        Lead processLead = [SELECT 
                            Id,
                            Office_Referral_Email__c,
                            Hidden_Trigger_Referral_Email__c
                            FROM Lead 
                            WHERE Id =:leadId
                            LIMIT 1];
        Lead updateLead = new Lead(Id = processLead.Id);
        updateLead.Office_Referral_Email__c = emailId;
        updateLead.Hidden_Trigger_Referral_Email__c  = !processLead.Hidden_Trigger_Referral_Email__c;
        update updateLead;
        return 'success';
    }
}