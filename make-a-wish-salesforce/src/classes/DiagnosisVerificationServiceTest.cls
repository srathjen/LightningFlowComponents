/**
 * @description DocuSign Service Test
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 2/27/2020
 */
@IsTest
public class DiagnosisVerificationServiceTest {
    
    private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;
    
    @TestSetup
    public static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;
        
        List<Account> accounts = TestDataFactory.createAccount(1);
        Account account1 = accounts.get(0);
        account1.Name = 'Make-A-Wish Arizona';
        account1.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
        insert accounts;

        List<Contact> contacts = TestDataFactory.createContact(1);
        Contact contact = contacts.get(0);
        contact.LastName = 'Liu';
        contact.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        contact.Region_Chapter__c = account1.Id;
        insert contacts;

        List<ICD_Codes__c> icdCodesDataFactory = TestDataFactory.createIcdCode(1);
        ICD_Codes__c icdCode = icdCodesDataFactory.get(0);
        icdCode.Name = 'Q917';
        insert icdCode;
        
        List<Lead> leadsDataFactory = TestDataFactory.createLead(1);
        Lead lead = leadsDataFactory.get(0);
        lead.ChapterName__c = accounts[0].Id;
        lead.FirstName = 'Jack';
        lead.LastName = 'Smith';
        lead.Hidden_Chapter_Change_Confirmation__c = account1.Id;
        lead.is_Family_Aware_of_Referral__c = 'Yes';
        lead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
        lead.PD_ICD_Code__c = icdCode.Id;
        lead.HiddenMedicalProfessionalEmail__c = 'mpTest@test.com.invalid';
        lead.Hidden_DV_form_Medical_professional_Type__c = 'Treating Medical Professional';
        lead.Treating_MP__c = contact.Id;
        lead.Company = 'MAW';
        insert lead;
        
        List<Diagnosis_Verification__c> diagnosisVerifications = TestDataFactory.createDiagnosisVerification(1);
        Diagnosis_Verification__c diagnosisVerification = diagnosisVerifications.get(0);
        diagnosisVerification.Lead__c = lead.Id;
        diagnosisVerification.isEligible__c = true;
        diagnosisVerification.ICD_Code__c = icdCode.Name;
        insert diagnosisVerifications;
        
        trac_TriggerHandlerBase.blockTrigger = false;
    }
    
    @IsTest
    public static void shouldDeleteLeadsDiagnosisVerifications() {
        Lead lead = [
            SELECT Id
            FROM Lead
            WHERE Name = 'Jack Smith'
        ];
        
        Test.startTest();
        DiagnosisVerificationService.deleteByLeadId(lead.Id);
        Test.stopTest();
        
        List<Diagnosis_Verification__c> diagnosisVerifications = [
            SELECT Id
            FROM Diagnosis_Verification__c
            WHERE Lead__c = :lead.Id
        ];
        System.assertEquals(0, diagnosisVerifications.size());
    }
    
    @IsTest
    public static void findByLeadId() {
        Lead lead = [
            SELECT Id
            FROM Lead
            WHERE Name = 'Jack Smith'
        ];
        Test.startTest();
        List<Diagnosis_Verification__c> listDiagnosisVerification = DiagnosisVerificationService.findByLeadId(lead.Id);
        Test.stopTest();
        System.assert(listDiagnosisVerification[0].ICD_Code__c == 'Q917');
    }
    
    @IsTest
    public static void updateContact() {
        Map<Id, Lead> leadMap = new Map<Id, Lead>([
            SELECT Id, ConvertedContactId 
            FROM Lead
        ]);
        Test.startTest();
        DiagnosisVerificationService.updateContact(leadMap);
        Test.stopTest();
    }

    @IsTest
    public static void shouldProcessSendDiagnosisVerification() {
        Lead lead = [
            SELECT Id, Hidden_DV_Form_Name__c, Treating_MP__c
            FROM Lead
        ];
        Test.startTest();
        DiagnosisVerificationService.processSendDiagnosisVerification(lead, 'test@test.com.invalid');
        Test.stopTest();
    }
}