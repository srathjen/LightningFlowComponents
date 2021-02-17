/**
* @description DV Medical Professional Information Controller Test
* @author Michelle Cominotto, Make-A-Wish
* @createdDate 02/12/2021
*/
@isTest
private class DvMedicalProfessionalInfoControllerTest {
    
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
        
        List<Contact> contacts = TestDataFactory.createContact(3);
        Contact mpContact = contacts.get(0);
        mpContact.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        mpContact.FirstName = 'Willow';
        mpContact.LastName = 'Summers';
        mpContact.Region_Chapter__c = accountAz.Id;
        Contact altMpContact = contacts.get(1);
        altMpContact.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        altMpContact.FirstName = 'Eric';
        altMpContact.LastName = 'Childers';
        altMpContact.Region_Chapter__c = accountAz.Id;
        Contact altTwoMpContact = contacts.get(2);
        altTwoMpContact.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        altTwoMpContact.FirstName = 'Karen';
        altTwoMpContact.LastName = 'Smith';
        altTwoMpContact.Region_Chapter__c = accountAz.Id;
        insert contacts;
        
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
        wishKid.Referring_MP__c = mpContact.Id;
        wishKid.Treating_MP__c = mpContact.Id;
        wishKid.Best_Contact__c = mpContact.Id;
        wishKid.ALT_1_MP__c = altMpContact.Id;
        wishKid.ALT_2_MP__c = altTwoMpContact.Id;
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
        insert leads;
        
        trac_TriggerHandlerBase.blockTrigger = false;
    }
    
    @isTest
    private static void getLeadInformationTreatingMpRecipient() {
        Lead lead = [
            SELECT Id, Hospital_Treatment_Facility_Treating__c, DV_Signer_Changed__c, 
            I_am_Recognized_To_Practice_As_a__c, I_m_Part_of_The_Treating_HealthCare_Team__c, 
            Treating_MP__c, Treating_MP__r.FirstName, Treating_MP__r.LastName
            FROM Lead 
            WHERE Name = 'Samantha Walker'
        ];
        
        test.startTest();
        DvMedicalProfessionalInfoController.MedicalProfessionalInformationWrapper medicalInfoWrapper = 
            DvMedicalProfessionalInfoController.getLeadMedicalProfessionalInformation(lead.Id);
        test.stopTest();
        
        System.assert((lead.Treating_MP__r.FirstName + ' ' + lead.Treating_MP__r.LastName) == medicalInfoWrapper.dvRecipient);
        System.assert(lead.Hospital_Treatment_Facility_Treating__c == medicalInfoWrapper.treatingHtfName);
        System.assert(lead.DV_Signer_Changed__c == medicalInfoWrapper.changedDvSigner);
        System.assert(lead.I_am_Recognized_To_Practice_As_a__c == medicalInfoWrapper.practicingMpType);
        System.assert(lead.I_m_Part_of_The_Treating_HealthCare_Team__c == medicalInfoWrapper.partOfHealthcareTeam);
    }
    
    @isTest
    private static void getLeadInformationReferringMpRecipient() {
        Lead lead = [
            SELECT Id, Hospital_Treatment_Facility_Treating__c, Referring_MP__c, 
            Referring_MP__r.FirstName, Referring_MP__r.LastName
            FROM Lead 
            WHERE Name = 'Samantha Walker'
        ];
        lead.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_REFERRING_MEDICAL_PROFESSIONAL;
        update lead;
        
        test.startTest();
        DvMedicalProfessionalInfoController.MedicalProfessionalInformationWrapper medicalInfoWrapper = 
            DvMedicalProfessionalInfoController.getLeadMedicalProfessionalInformation(lead.Id);
        test.stopTest();
        
        System.assert((lead.Referring_MP__r.FirstName + ' ' + lead.Referring_MP__r.LastName) == medicalInfoWrapper.dvRecipient);
        System.assert(lead.Hospital_Treatment_Facility_Treating__c == medicalInfoWrapper.treatingHtfName);
    }
    
    @isTest
    private static void getLeadInformationBestContactRecipient() {
        Lead lead = [
            SELECT Id, Hospital_Treatment_Facility_Treating__c, Best_Contact__c, 
            Best_Contact__r.FirstName, Best_Contact__r.LastName
            FROM Lead 
            WHERE Name = 'Samantha Walker'
        ];
        lead.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_BEST_CONTACT;
        update lead;
        
        test.startTest();
        DvMedicalProfessionalInfoController.MedicalProfessionalInformationWrapper medicalInfoWrapper = 
            DvMedicalProfessionalInfoController.getLeadMedicalProfessionalInformation(lead.Id);
        test.stopTest();
        
        System.assert((lead.Best_Contact__r.FirstName + ' ' + lead.Best_Contact__r.LastName) == medicalInfoWrapper.dvRecipient);
        System.assert(lead.Hospital_Treatment_Facility_Treating__c == medicalInfoWrapper.treatingHtfName);
    }
    
    @isTest
    private static void getLeadInformationAltMpOneRecipient() {
        Lead lead = [
            SELECT Id, Hospital_Treatment_Facility_Treating__c, ALT_1_MP__c, 
            ALT_1_MP__r.FirstName, ALT_1_MP__r.LastName
            FROM Lead 
            WHERE Name = 'Samantha Walker'
        ];
        lead.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL;
        update lead;
        
        test.startTest();
        DvMedicalProfessionalInfoController.MedicalProfessionalInformationWrapper medicalInfoWrapper = 
            DvMedicalProfessionalInfoController.getLeadMedicalProfessionalInformation(lead.Id);
        test.stopTest();
        
        System.assert((lead.ALT_1_MP__r.FirstName + ' ' + lead.ALT_1_MP__r.LastName) == medicalInfoWrapper.dvRecipient);
        System.assert(lead.Hospital_Treatment_Facility_Treating__c == medicalInfoWrapper.treatingHtfName);
    }
    
    @isTest
    private static void getLeadInformationAltMpTwoRecipient() {
        Lead lead = [
            SELECT Id, Hospital_Treatment_Facility_Treating__c, ALT_2_MP__c, 
            ALT_2_MP__r.FirstName, ALT_2_MP__r.LastName
            FROM Lead 
            WHERE Name = 'Samantha Walker'
        ];
        lead.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL;
        update lead;
        
        test.startTest();
        DvMedicalProfessionalInfoController.MedicalProfessionalInformationWrapper medicalInfoWrapper = 
            DvMedicalProfessionalInfoController.getLeadMedicalProfessionalInformation(lead.Id);
        test.stopTest();
        
        System.assert((lead.ALT_2_MP__r.FirstName + ' ' + lead.ALT_2_MP__r.LastName) == medicalInfoWrapper.dvRecipient);
        System.assert(lead.Hospital_Treatment_Facility_Treating__c == medicalInfoWrapper.treatingHtfName);
    }
    
    @isTest
    private static void saveLeadMedicalProfessionalInformation() {
        Lead lead = [
            SELECT Id, RecordTypeId
            FROM Lead 
            WHERE Name = 'Samantha Walker'
        ];
        
        DvMedicalProfessionalInfoController.MedicalProfessionalInformationWrapper medicalInfoWrapper = 
            new DvMedicalProfessionalInfoController.MedicalProfessionalInformationWrapper();
        
        medicalInfoWrapper.leadId = lead.Id;
        medicalInfoWrapper.leadRecordTypeId = lead.RecordTypeId;
        medicalInfoWrapper.treatingMpName = 'Willow Summers';
        medicalInfoWrapper.treatingHtfName = 'Phoenix General Hospital';
        medicalInfoWrapper.dvRecipient = '';
        medicalInfoWrapper.dvSignerFirstName = 'Willow';
        medicalInfoWrapper.dvSignerLastName = 'Summers';
        medicalInfoWrapper.dvSignerPhone = '(820) 520-1234';
        medicalInfoWrapper.dvSignerEmail = 'willow@summers.com';
        medicalInfoWrapper.practicingMpType = 'Physician';
        medicalInfoWrapper.partOfHealthcareTeam = 'Yes';
        medicalInfoWrapper.changedDvSigner = true;
        
        test.startTest();
        DvMedicalProfessionalInfoController.saveLeadMedicalProfessionalInformation(medicalInfoWrapper);
        test.stopTest();
        
        Lead updatedLead = [
            SELECT Id, DV_Signer_First_Name__c, DV_Signer_Last_Name__c, DV_Signer_Email__c 
            FROM Lead 
            WHERE Id = :lead.Id
        ];
        
        System.assert(updatedLead.DV_Signer_First_Name__c == medicalInfoWrapper.dvSignerFirstName);
        System.assert(updatedLead.DV_Signer_Last_Name__c == medicalInfoWrapper.dvSignerLastName);
        System.assert(updatedLead.DV_Signer_Email__c == medicalInfoWrapper.dvSignerEmail);
    }
    
    @isTest
    private static void shouldNotSaveLeadMedicalProfessionalInformation() {
        DvMedicalProfessionalInfoController.MedicalProfessionalInformationWrapper medicalInfoWrapper = 
            new DvMedicalProfessionalInfoController.MedicalProfessionalInformationWrapper();
        
        medicalInfoWrapper.treatingMpName = 'Willow Summers';
        medicalInfoWrapper.treatingHtfName = 'Phoenix General Hospital';
        medicalInfoWrapper.dvRecipient = '';
        medicalInfoWrapper.dvSignerFirstName = 'Willow';
        medicalInfoWrapper.dvSignerLastName = 'Summers';
        medicalInfoWrapper.dvSignerPhone = '(820) 520-1234';
        medicalInfoWrapper.dvSignerEmail = 'willow@summers.com';
        medicalInfoWrapper.practicingMpType = 'Physician';
        medicalInfoWrapper.partOfHealthcareTeam = 'Yes';
        medicalInfoWrapper.changedDvSigner = true;
        
        Boolean leadSaved;
        test.startTest();
        try {
            DvMedicalProfessionalInfoController.saveLeadMedicalProfessionalInformation(medicalInfoWrapper);
            leadSaved = true;
        } catch(Exception e) {
            leadSaved = false;
        }
        test.stopTest();
        
        System.assert(leadSaved == false);
    }
}