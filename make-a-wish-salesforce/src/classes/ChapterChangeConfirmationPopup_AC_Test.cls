/**
 * @description Chapter Change Confirmation Popup Test
 *
 * @author Gustavo Mayer, Traction on Demand
 *
 * @date 2/27/2020
 */
@IsTest
public class ChapterChangeConfirmationPopup_AC_Test {

    private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;

    @TestSetup
    public static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;

        List<Account> accounts = TestDataFactory.createAccount(2);
        Account account1 = accounts.get(0);
        account1.Name = 'Make-A-Wish Arizona';
        account1.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
        Account account2 = accounts.get(1);
        account2.Name = 'Make-A-Wish New York';
        account2.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
        insert accounts;

        List<ICD_Codes__c> icdCodesDataFactory = TestDataFactory.createIcdCode(1);
        ICD_Codes__c icdCode = icdCodesDataFactory.get(0);
        insert icdCode;

        List<Lead> leadsDataFactory = TestDataFactory.createLead(1);
        Lead lead = leadsDataFactory.get(0);
        lead.ChapterName__c = accounts[0].Id;
        lead.FirstName = 'Jack';
        lead.LastName = 'Smith';
        lead.Hidden_Chapter_Change_Confirmation__c = account2.Id;
        lead.is_Family_Aware_of_Referral__c = 'Yes';
        lead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
        lead.PD_ICD_Code__c = icdCode.Id;
        lead.Company = 'MAWA';
        insert lead;

        trac_TriggerHandlerBase.blockTrigger = false;
    }

    @IsTest
    public static void shouldRevertChapterName() {
        Account oldChapter = [
                SELECT Id
                FROM Account
                WHERE Name IN ('Make-A-Wish New York')
        ];
        Account newChapter = [
                SELECT Id
                FROM Account
                WHERE Name IN ('Make-A-Wish Arizona')
        ];
        Lead lead = [
                SELECT Id, ChapterName__c
                FROM Lead
                WHERE Name = 'Jack Smith'
        ];
        System.assertEquals(newChapter.Id, lead.ChapterName__c);

        Test.startTest();
        String hiddenChapterName = ChapterChangeConfirmationPopup_AC.updateLeadChapter('revert', lead.Id);
        Test.stopTest();

        System.assertEquals(oldChapter.Id, hiddenChapterName);
    }

    @IsTest
    public static void shouldBackupChapterName() {
        Account newChapter = [
                SELECT Id
                FROM Account
                WHERE Name IN ('Make-A-Wish Arizona')
        ];
        Lead lead = [
                SELECT Id, ChapterName__c
                FROM Lead
                WHERE Name = 'Jack Smith'
        ];
        System.assertEquals(newChapter.Id, lead.ChapterName__c);

        Test.startTest();
        String hiddenChapterName = ChapterChangeConfirmationPopup_AC.updateLeadChapter('accept', lead.Id);
        Test.stopTest();

        System.assertEquals(newChapter.Id, hiddenChapterName);
    }

    @IsTest
    public static void shouldCallClassConstructor() {
        Lead lead = [
                SELECT Id, ChapterName__c
                FROM Lead
                WHERE Name = 'Jack Smith'
        ];
        ApexPages.StandardController sc = new ApexPages.StandardController(lead);
        new ChapterChangeConfirmationPopup_AC(sc);
    }
}