/**
* @description DV Medical Professional Information Controller
* @author Michelle Cominotto, Make-A-Wish
* @createdDate 02/08/2021
*/
public class DvMedicalProfessionalInfoController {
    
    @AuraEnabled(cacheable=true)
    public static MedicalProfessionalInformationWrapper getLeadMedicalProfessionalInformation(Id recordId) {
        MedicalProfessionalInformationWrapper dvMedicalInfoWrapper = new MedicalProfessionalInformationWrapper();
        
        Lead dvLead = [
            SELECT Id, Treating_Medical_Professional_First_Name__c, Treating_Medical_Professional_Last_Name__c,
            Hospital_Treatment_Facility_Treating__c, Hidden_DV_form_Medical_professional_Type__c,
            DV_Signer_First_Name__c, DV_Signer_Last_Name__c, DV_Signer_Phone__c, DV_Signer_Email__c,
            Treating_MP__r.FirstName, Treating_MP__r.LastName, Referring_MP__r.FirstName, Referring_MP__r.LastName,
            Best_Contact__r.FirstName, Best_Contact__r.LastName, ALT_1_MP__r.FirstName, ALT_1_MP__r.LastName, 
            ALT_2_MP__r.FirstName, ALT_2_MP__r.LastName, RecordTypeId, DV_Signer_Changed__c, Last_DV_Save_Date__c,
            I_am_Recognized_To_Practice_As_a__c, I_m_Part_of_The_Treating_HealthCare_Team__c
            FROM Lead 
            WHERE Id = :recordId
        ];
        
        if(dvLead != null) {
            dvMedicalInfoWrapper.leadId = dvLead.Id;
            dvMedicalInfoWrapper.leadRecordTypeId = dvLead.RecordTypeId;
            dvMedicalInfoWrapper.treatingMpName = dvLead.Treating_Medical_Professional_First_Name__c + ' ' + 
                dvLead.Treating_Medical_Professional_Last_Name__c;
            dvMedicalInfoWrapper.treatingHtfName = dvLead.Hospital_Treatment_Facility_Treating__c;
            dvMedicalInfoWrapper.practicingMpType = dvLead.I_am_Recognized_To_Practice_As_a__c;
            dvMedicalInfoWrapper.partOfHealthcareTeam = dvLead.I_m_Part_of_The_Treating_HealthCare_Team__c;
            dvMedicalInfoWrapper.changedDvSigner = dvLead.DV_Signer_Changed__c;
            if(dvLead.Last_DV_Save_Date__c == null) {
                dvMedicalInfoWrapper.isPreviouslySaved = false;
            } else {
                dvMedicalInfoWrapper.isPreviouslySaved = true;
            }
            if(dvLead.Hidden_DV_form_Medical_professional_Type__c == 
               Constant_AC.LEAD_DV_FORM_TYPE_REFERRING_MEDICAL_PROFESSIONAL) {
                dvMedicalInfoWrapper.dvRecipient = dvLead.Referring_MP__r.FirstName + ' '+ 
                    dvLead.Referring_MP__r.LastName;
            } else if(dvLead.Hidden_DV_form_Medical_professional_Type__c == 
                      Constant_AC.LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL) {
                dvMedicalInfoWrapper.dvRecipient = dvLead.Treating_MP__r.FirstName + ' ' + 
                    dvLead.Treating_MP__r.LastName;
            } else if(dvLead.Hidden_DV_form_Medical_professional_Type__c == 
                      Constant_AC.LEAD_DV_FORM_TYPE_BEST_CONTACT) {
                dvMedicalInfoWrapper.dvRecipient = dvLead.Best_Contact__r.FirstName + ' ' + 
                    dvLead.Best_Contact__r.LastName;
            } else if (dvLead.Hidden_DV_form_Medical_professional_Type__c == 
                       Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL) {
                dvMedicalInfoWrapper.dvRecipient = dvLead.ALT_1_MP__r.FirstName + ' ' + 
                    dvLead.ALT_1_MP__r.LastName;
            } else if (dvLead.Hidden_DV_form_Medical_professional_Type__c == 
                       Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL) {
                dvMedicalInfoWrapper.dvRecipient = dvLead.ALT_2_MP__r.FirstName + ' ' + 
                    dvLead.ALT_2_MP__r.LastName;
            } else {
                dvMedicalInfoWrapper.dvRecipient = '';
            }
            dvMedicalInfoWrapper.dvSignerFirstName = dvLead.DV_Signer_First_Name__c;
            dvMedicalInfoWrapper.dvSignerLastName = dvLead.DV_Signer_Last_Name__c;
            dvMedicalInfoWrapper.dvSignerPhone = dvLead.DV_Signer_Phone__c;
            dvMedicalInfoWrapper.dvSignerEmail = dvLead.DV_Signer_Email__c;
        }
        return dvMedicalInfoWrapper;
    }
    
    @AuraEnabled
    public static void saveLeadMedicalProfessionalInformation(MedicalProfessionalInformationWrapper dvMedicalInfoWrapper) {
        Lead updatedLead = new Lead();
        updatedLead.Id = dvMedicalInfoWrapper.leadId;
        updatedLead.I_am_Recognized_To_Practice_As_a__c = dvMedicalInfoWrapper.practicingMpType;
        updatedLead.I_m_Part_of_The_Treating_HealthCare_Team__c = dvMedicalInfoWrapper.partOfHealthcareTeam;
        updatedLead.DV_Signer_Changed__c = dvMedicalInfoWrapper.changedDvSigner;
        if(updatedLead.DV_Signer_Changed__c == true) {
            updatedLead.DV_Signer_First_Name__c = dvMedicalInfoWrapper.dvSignerFirstName;
            updatedLead.DV_Signer_Last_Name__c = dvMedicalInfoWrapper.dvSignerLastName;
            updatedLead.DV_Signer_Phone__c = dvMedicalInfoWrapper.dvSignerPhone;
            updatedLead.DV_Signer_Email__c = dvMedicalInfoWrapper.dvSignerEmail;
        }
        
        try{
            update updatedLead;
        } catch(Exception e) {
            ErrorMessage_AC.createDebugRec('DvMedicalProfessionalInfoController', String.valueOf(updatedLead), String.valueOf(e),
                                           'saveLeadMedicalProfessionalInformation', updatedLead.Id, e.getStackTraceString() 
                                           + ' ' + e.getMessage(), 'Error');
            throw new AuraHandledException(e.getMessage());
            
        }
    }
    
    public class MedicalProfessionalInformationWrapper {
        @AuraEnabled
        public Id leadId {get; set;}
        @AuraEnabled
        public Id leadRecordTypeId {get; set;}
        @AuraEnabled
        public String treatingMpName {get; set;}
        @AuraEnabled
        public String treatingHtfName {get; set;}
        @AuraEnabled
        public String dvRecipient {get; set;}
        @AuraEnabled
        public String dvSignerFirstName {get; set;}
        @AuraEnabled
        public String dvSignerLastName {get; set;}
        @AuraEnabled
        public String dvSignerPhone {get; set;}
        @AuraEnabled
        public String dvSignerEmail {get; set;}
        @AuraEnabled
        public String practicingMpType {get; set;}
        @AuraEnabled
        public String partOfHealthcareTeam {get; set;}
        @AuraEnabled
        public Boolean changedDvSigner {get; set;}
        @AuraEnabled
        public Boolean isPreviouslySaved {get; set;}
    }
}