/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Vignesh SM
Date        : 13/03/2018
Description : Class contains AURA enbaled utility methods used by the SendDiagnosisVerficationLC component

Modification Log:

1. 03/28/2018 - Yuvraj - IME-59 - Line No: 22
2. 04/12/2018 - Yuvraj - IME-77 - Line:No: 32
*****************************************************************************************************/

public without sharing class SendDiagnosisVerficationLC_AC {
    
    /********************************************************************************************
    Get the neccessary lead information for further process of sending diagnosis verfication    
    ***********************************************************************************************/
    @AuraEnabled
    public static Lead getLeadInformation(Id leadId){
        Lead data = [SELECT Id, 
                     Has_this_child_ever_received_prior_wish__c,
                     Contact_Dup_Check__c,
                     Using_Paper_Process_For_DV__c,
                     Status,Dup_Check__c, 
                     Sub_Status__c, 
                     Treating_Medical_Professional_Email__c, 
                     Best_contact_for_Physician_Email__c,
                     Alternate1MedicalProfessionalEmail__c,
                     Alternate2MedProfessionalEmail__c,
                     Part_A_Sent__c,
                     HiddenMedicalProfessionalEmail__c,
                     Pending_Diagnosis_Date__c,
                     PD_ICD_Code__c, 
                     PD_Condition_Description__c,
                     Of_Times_Email_Sent__c,
                     Part_A_Received__c,
					 isSign__c                     
                     FROM Lead WHERE Id = :leadId LIMIT 1];
        
        return data;
    }
    
     /********************************************************************************************
    Wrapper method to call reset DV medical summary   
    ***********************************************************************************************/
    @AuraEnabled
    public static String resetDVMedicalSummary(Id leadId){
        String result = LeadWishFamilyDupe.resetDVMedicalSummary(leadId);
        return result;
    }
    
    /********************************************************************************************
    Wrapper method to call Find Lead Dupe  
    ***********************************************************************************************/
    @AuraEnabled
    public static String findLeadDupe(Id leadId){
        String result = LeadWishFamilyDupe.FindLeadDupe(leadId);
        return result;
    }
    
    /********************************************************************************************
    Wrapper method to call Find Family Contact Dupe   
    ***********************************************************************************************/
    @AuraEnabled
    public static String findFamilyContactDupe(Id leadId){
        String result = LeadWishFamilyDupe.FindFamilyContactDupe(leadId);
        return result;
    }
    
    /********************************************************************************************
    Update the lead appropriate information when the diagnosis verfication has been sent   
    ***********************************************************************************************/
    @AuraEnabled
    public static String updateLead(Id leadId, String HiddenDVformMedicalprofessionalType, Integer OfTimesEmailSent, String HiddenMedicalProfessionalEmail, String SubStatus){
        String result;
        
        Lead currLead = new Lead();            
        currLead.Id  = leadId;
        currLead.HiddenMedicalProfessionalEmail__c = HiddenMedicalProfessionalEmail;
        currLead.Hidden_DV_form_Medical_professional_Type__c = HiddenDVformMedicalprofessionalType;
        currLead.Of_Times_Email_Sent__c = Integer.valueOf(OfTimesEmailSent);       
        currLead.Sub_Status__c = SubStatus;
        currLead.Pending_Diagnosis_Date__c = Date.today();//IME-77
        
        update currLead;
        result = 'UPDATED';
        
        return result;
    }
}