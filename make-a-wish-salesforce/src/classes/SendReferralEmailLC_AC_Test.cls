@IsTest
public class SendReferralEmailLC_AC_Test {

    private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;

    @TestSetup
    public static void setup() {
        List<Account> accounts = TestDataFactory.createAccount(1);
        Account account1 = accounts.get(0);
        account1.Name = 'Make-A-Wish Arizona';
        account1.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
        insert accounts;

        List<ICD_Codes__c> icdCodesDataFactory = TestDataFactory.createIcdCode(1);
        ICD_Codes__c icdCode = icdCodesDataFactory.get(0);
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
        insert lead;
    }

    @IsTest
    static void SendReferralEmail_test(){
        Lead lead = [
                SELECT Id
                FROM Lead
                WHERE Name = 'Jack Smith'
        ];

        SendReferralEmailLC_AC.getOfficeViaLead(lead.Id);
        SendReferralEmailLC_AC.triggerEmail(lead.Id, 'Test@test.com');
        ChapterChangeConfirmationPopup_AC.updateLeadChapter('revert', lead.Id);
        ChapterChangeConfirmationPopup_AC.updateLeadChapter('accept', lead.Id);
    }
}