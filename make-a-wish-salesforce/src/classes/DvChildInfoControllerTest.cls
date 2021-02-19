/**
* @description DV Child Information Controller Test
* @author Brittany Maclaughlin, Make-A-Wish
* @createdDate 02/12/2021
*/
@isTest
private class DvChildInfoControllerTest {
    
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
        Lead DvLead = leads.get(0);
        DvLead.RecordTypeId = Constant_AC.LEAD_RT_WISH_CHILD;
        DvLead.FirstName = 'Samantha';
        DvLead.LastName = 'Walker';
        DvLead.Gender__c = 'Female';
        DvLead.ChapterName__c = accountAz.Id;
        DvLead.Treating_Medical_Professional_First_Name__c = 'Daniel';
        DvLead.Treating_Medical_Professional_Last_Name__c = 'Thompson';
        DvLead.Hospital_Treatment_Facility_Treating__c = 'Phoenix General Hospital';
        DvLead.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL;
        DvLead.DV_Signer_Changed__c = false;
        DvLead.I_am_Recognized_To_Practice_As_a__c = 'Physician';
        DvLead.is_Family_Aware_of_Referral__c = 'Yes';
        DvLead.I_m_Part_of_The_Treating_HealthCare_Team__c = 'Yes';
        DvLead.Phone = '1233213333';
        DvLead.Email = 'wishChild@email.com';
        DvLead.Street = '123 Street';
        DvLead.State = 'Arizona';
        DvLead.StateCode = 'AZ';
        DvLead.City = 'Phoenix';
        DvLead.PostalCode = '85001';
        DvLead.DOB__c = System.today() - 1435;
        DvLead.Company = 'MAW';
        DvLead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
        DvLead.PD_ICD_Code__c = icdCode.Id;
        DvLead.SD1_ICD_Code__c = icdCode.Id;
        insert leads;
        
        trac_TriggerHandlerBase.blockTrigger = false;
    }
    
    @isTest
    private static void getLeadInformation() {
        Lead lead = [SELECT Id, Name, Gender__c, DOB_Text__c FROM Lead WHERE Name = 'Samantha Walker'];

        test.startTest();
        DvChildInfoController.ChildInformationWrapper childInformationWrapper = 
        DvChildInfoController.getLeadChildInformation(lead.Id);
        test.stopTest();

        System.assert(lead.Name == ChildInformationWrapper.Name);
        System.assert(lead.Gender__c == ChildInformationWrapper.Gender);
        System.assert(lead.DOB_Text__c == ChildInformationWrapper.DOB);
        
    
    
        System.debug('Retrieving Lead');
        System.debug(DvChildInfoController.getLeadChildInformation(lead.Id));
    }
}
