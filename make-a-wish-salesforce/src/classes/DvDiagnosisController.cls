/**
* @description DV Diagnosis Controller
* @author Michelle Cominotto, Make-A-Wish
* @createdDate 02/18/2021
*/
public without sharing class DvDiagnosisController {

    @AuraEnabled(cacheable=true)
    public static DvDiagnosisWrapper getLeadDvDiagnosis(Id recordId) {
        DvDiagnosisWrapper diagnosisWrapper = new DvDiagnosisWrapper();

        Lead lead = [
            SELECT Id, FirstName, LastName, Is_in_a_Comatose_Vegetative_State__c 
            FROM Lead
            WHERE Id = :recordId
        ];

        if(lead != null) {
            diagnosisWrapper.leadId = lead.Id;
            diagnosisWrapper.leadName = lead.FirstName + ' ' + lead.LastName;
            diagnosisWrapper.comatoseVegetativeState = lead.Is_in_a_Comatose_Vegetative_State__c;
        }

        return diagnosisWrapper;
    }

    @AuraEnabled
    public static void saveLeadDvDiagnosis(DvDiagnosisWrapper diagnosisWrapper) {
        Lead updateLead = new Lead();
        updateLead.Id = diagnosisWrapper.leadId;
        updateLead.Is_in_a_Comatose_Vegetative_State__c = diagnosisWrapper.comatoseVegetativeState;
        if(updateLead.Is_in_a_Comatose_Vegetative_State__c == Constant_AC.LEAD_COMATOSE_VEGETATIVE_STATE_YES) {
            updateLead.Part_A_Received__c = diagnosisWrapper.receivedDate;
        }

        try {
            update updateLead;
        } catch(Exception e) {
            ErrorMessage_AC.createDebugRec('DvDiagnosisController', String.valueOf(updateLead), String.valueOf(e),
                                           'saveLeadDvDiagnosis', updateLead.Id, e.getStackTraceString() 
                                           + ' ' + e.getMessage(), 'Error');
        }
    }

    public class DvDiagnosisWrapper {
        @AuraEnabled
        public Id leadId {get; set;}
        @AuraEnabled
        public String leadName {get; set;}
        @AuraEnabled
        public String comatoseVegetativeState {get; set;}
        @AuraEnabled
        public Date receivedDate {get; set;}
    }
}