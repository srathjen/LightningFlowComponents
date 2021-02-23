/**
* @description DV Diagnosis Controller Test
* @author Michelle Cominotto, Make-A-Wish
* @createdDate 02/22/2021
*/
@isTest
private class DvDiagnosisControllerTest {
    
    @TestSetup
    private static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;
        
        List<Account> accounts = TestDataFactory.createAccount(1);
        Account accountAz = accounts.get(0);
        accountAz.Name = 'Make-A-Wish Arizona';
        accountAz.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
        accountAz.Onboarded_on_SF__c = true;
        insert accounts;
        
        List<Condition_Description__c> conditionDescriptions = TestDataFactory.createConditionDescription(1);
        Condition_Description__c conditionDescription = conditionDescriptions.get(0);
        conditionDescription.Name = 'Malignant Melanoma';
        conditionDescription.Treatment_Subspecialty__c = 'Oncology';
        conditionDescription.Code_To_Use__c = 'C43.30';
        conditionDescription.PR_Diagnosis__c = 'Malignant Melanoma';
        conditionDescription.Group1__c = true;
        insert conditionDescriptions;
        
        List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
        ICD_Codes__c icdCode = icdCodes.get(0);
        icdCode.Name = 'icdCode1';
        icdCode.Group1__c = true;
        icdCode.Condition_Description__c = conditionDescription.Id;
        insert icdCodes;
        
        List<Lead> leads = TestDataFactory.createLead(1);
        Lead wishKid = leads.get(0);
        wishKid.RecordTypeId = Constant_AC.LEAD_RT_WISH_CHILD;
        wishKid.FirstName = 'Samantha';
        wishKid.LastName = 'Walker';
        wishKid.ChapterName__c = accountAz.Id;
        wishKid.Treating_Medical_Professional_First_Name__c = 'Daniel';
        wishKid.Treating_Medical_Professional_Last_Name__c = 'Thompson';
        wishKid.Hospital_Treatment_Facility_Treating__c = 'Phoenix General Hospital';
        wishKid.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL;
        wishKid.DV_Signer_Changed__c = false;
        wishKid.I_am_Recognized_To_Practice_As_a__c = 'Physician';
        wishKid.is_Family_Aware_of_Referral__c = 'Yes';
        wishKid.I_m_Part_of_The_Treating_HealthCare_Team__c = 'Yes';
        wishKid.Phone = '1233213333';
        wishKid.Email = 'wishChild@email.com';
        wishKid.Street = '123 Street';
        wishKid.State = 'Arizona';
        wishKid.StateCode = 'AZ';
        wishKid.City = 'Phoenix';
        wishKid.PostalCode = '85001';
        wishKid.DOB__c = System.today() - 1435;
        wishKid.Company = 'MAW';
        wishKid.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
        wishKid.PD_ICD_Code__c = icdCode.Id;
        wishKid.SD1_ICD_Code__c = icdCode.Id;
        wishKid.Is_in_a_Comatose_Vegetative_State__c = 'No';
        insert leads;
        
        trac_TriggerHandlerBase.blockTrigger = false;
    }
    
    @isTest
    private static void getLeadInformation() {
        Lead lead = [
            SELECT Id, Name, Is_in_a_Comatose_Vegetative_State__c 
            FROM Lead 
            WHERE Name = 'Samantha Walker'
        ];
        
        test.startTest();
        DvDiagnosisController.DvDiagnosisWrapper dvWrapper = 
            DvDiagnosisController.getLeadDvDiagnosis(lead.Id);
        test.stopTest();
        
        System.assert(lead.Name == dvWrapper.leadName);
        System.assert(lead.Is_in_a_Comatose_Vegetative_State__c == dvWrapper.comatoseVegetativeState);
    }
    
    @isTest
    private static void saveLeadInformation() {
        Lead lead = [
            SELECT Id, Is_in_a_Comatose_Vegetative_State__c 
            FROM Lead 
            WHERE Name = 'Samantha Walker'
        ];
        
        DvDiagnosisController.DvDiagnosisWrapper dvWrapper = 
            new DvDiagnosisController.DvDiagnosisWrapper();
        dvWrapper.leadId = lead.Id;
        dvWrapper.comatoseVegetativeState = 'Yes';
        
        test.startTest();
        DvDiagnosisController.saveLeadDvDiagnosis(dvWrapper);
        test.stopTest();
        
        Lead updatedLead = [
            SELECT Id, Is_in_a_Comatose_Vegetative_State__c 
            FROM Lead 
            WHERE Id = :lead.Id
        ];
        
        System.assert(dvWrapper.comatoseVegetativeState == updatedLead.Is_in_a_Comatose_Vegetative_State__c);
    }
}