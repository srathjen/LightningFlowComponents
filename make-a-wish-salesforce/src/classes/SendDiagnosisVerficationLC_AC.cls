/**
 * Author      : MST Solutions
 * CreatedBy   : Vignesh SM
 * Date        : 13/03/2018
 * Description : Class contains AURA enbaled utility methods used by the SendDiagnosisVerficationLC component
 * Modification Log:
 * 1. 03/28/2018 - Yuvraj - IME-59 - Line No: 22Hospital_Treatment_Facility_Treating__c
 * 2. 04/12/2018 - Yuvraj - IME-77 - Line:No: 32
 * 3. 06/03/3030- Brittany - SIW-543
 **/
public without sharing class SendDiagnosisVerficationLC_AC {

    /*
     * @description     Get the necessary lead information for further process of sending diagnosis verification
     * @param           Id leadId`
     * @return          String
     * @date            unknown
     * @author          MST Solutions
    */
    @AuraEnabled
    public static Lead getLeadInformation(Id leadId) {
        Lead data = [
                SELECT Id, Has_this_child_ever_received_prior_wish__c, Contact_Dup_Check__c,
                        Using_Paper_Process_For_DV__c, Status,Dup_Check__c, Sub_Status__c, Part_A_Sent__c,
                        HiddenMedicalProfessionalEmail__c, Pending_Diagnosis_Date__c, PD_ICD_Code__c,
                        PD_Condition_Description__c, Of_Times_Email_Sent__c, Part_A_Received__c,
                        isSign__c, Child_Age__c, Relationship_to_child__c, Referring_MP__c, Referring_MP_HTF__c,
                        Referrer_FirstName__c, Referrer_Last_Name__c, Referring_MP_HTF_Name__c,
                        Treating_MP__c, Treating_MP_HTF__c, Hospital_Treatment_Facility_Treating__c,
                        Treating_Medical_Professional_First_Name__c, Treating_Medical_Professional_Last_Name__c,
                        Treating_Medical_Professional_Email__c, Best_Contact__c, Best_Contact_HTF__c,
                        Best_Contact_HTF_Name__c, Best_Contact_for_Physician_First_Name__c,
                        Best_Contact_for_Physician_Last_Name__c, Best_contact_for_Physician_Email__c,
                        Alternate1MedicalProfessionalEmail__c, Alternate2MedProfessionalEmail__c
                FROM Lead
                WHERE Id = :leadId
                AND RecordTypeId = :Constant_AC.LEAD_RT_WISH_CHILD
        ];
        return data;
    }

    /*
     * @description     Wrapper method to call reset DV medical summary
     * @param           Id leadId
     * @return          String
     * @date            unknown
     * @author          MST Solutions
    */
    @AuraEnabled
    public static String resetDVMedicalSummary(Id leadId) {
        String result = LeadDuplicateService.resetDVMedicalSummary(leadId);
        return result;
    }

    /*
     * @description     Wrapper method to call Find Lead Dupe
     * @param           Id leadId
     * @return          String
     * @date            unknown
     * @author          MST Solutions
    */
    @AuraEnabled
    public static String findLeadDupe(Id leadId) {
        String result = LeadDuplicateService.FindLeadDupe(leadId);
        return result;
    }

    /*
     * @description     Wrapper method to call Find Family Contact Dupe
     * @param           Id leadId
     * @return          String
     * @date            unknown
     * @author          MST Solutions
    */
    @AuraEnabled
    public static String findFamilyContactDupe(Id leadId) {
        String result = LeadDuplicateService.FindFamilyContactDupe(leadId);
        return result;
    }

    /*
     * @description     Update the lead appropriate information when the diagnosis verification has been sent
     * @param           Id leadId
     * @return          String
     * @date            unknown
     * @author          MST Solutions
    */
    @AuraEnabled
    public static String updateLead(Id leadId, String HiddenDVformMedicalprofessionalType, Integer OfTimesEmailSent, String HiddenMedicalProfessionalEmail, String SubStatus) {
        Lead currLead = new Lead();
        currLead.Id = leadId;
        currLead.HiddenMedicalProfessionalEmail__c = HiddenMedicalProfessionalEmail;
        currLead.Hidden_DV_form_Medical_professional_Type__c = HiddenDVformMedicalprofessionalType;
        currLead.Of_Times_Email_Sent__c = Integer.valueOf(OfTimesEmailSent);
        currLead.Sub_Status__c = SubStatus;
        currLead.Pending_Diagnosis_Date__c = Date.today();//IME-77
        update currLead;
        return 'UPDATED';
    }
}