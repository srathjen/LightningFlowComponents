/**
 * Author      : MST Solutions
 * CreatedBy   : Vignesh SM
 * Date        : 13/03/2018
 * Description : Class contains test method for SendDiagnosisVerficationLC_AC.apxc component
 **/
@IsTest
public class SendDiagnosisVerficationLC_ACTest {

    private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;

    @TestSetup
    public static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;

        List<Account> accounts = TestDataFactory.createAccount(1);
        Account account1 = accounts.get(0);
        account1.Name = 'Make-A-Wish Arizona';
        account1.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
        insert accounts;

        List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
        ICD_Codes__c icdCode = icdCodes.get(0);
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
        lead.Company = 'MAW';
        lead.RecordTypeId = Constant_AC.LEAD_RT_WISH_CHILD;
        lead.Treating_Medical_Professional_Email__c = 'TestMed@test.org';
        insert lead;

        trac_TriggerHandlerBase.blockTrigger = false;
    }

    @IsTest
    static void getLeadInformation_test() {
        Lead lead = [
                SELECT Id
                FROM Lead
                WHERE Name = 'Jack Smith'
        ];
        Lead retrieveLead = SendDiagnosisVerficationLC_AC.getLeadInformation(lead.Id);
        System.assertEquals(lead.Id, retrieveLead.Id);
    }

    @IsTest
    static void utilityMethods_test() {
        Lead lead = [
                SELECT Id
                FROM Lead
                WHERE Name = 'Jack Smith'
        ];
        SendDiagnosisVerficationLC_AC.findLeadDupe(lead.Id);
        SendDiagnosisVerficationLC_AC.findFamilyContactDupe(lead.Id);
    }

    @IsTest
    static void updateLead_test() {
        Lead lead = [
                SELECT Id
                FROM Lead
                WHERE Name = 'Jack Smith'
        ];
        lead.Sub_Status__c = 'Pending Diagnosis Verification';
        update lead;
        String result = SendDiagnosisVerficationLC_AC.updateLead(lead.Id,
                'Treating Medical Professional', 0,
                lead.Treating_Medical_Professional_Email__c, lead.Sub_Status__c);
        System.assertEquals('UPDATED', result);
    }
}