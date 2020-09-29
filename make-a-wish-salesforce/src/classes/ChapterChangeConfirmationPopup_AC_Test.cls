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
        
        List<Contact> contacts = TestDataFactory.createContact(1);
        Contact contactKnowles = contacts.get(0);
        contactKnowles.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        contactKnowles.Region_Chapter__c = account1.Id;
        contactKnowles.FirstName = 'Allison';
        contactKnowles.LastName = 'Knowles';
        insert contacts;
        
        Account account3 = TestDataFactory.createAccount(1)[0];
        account3.Name = 'Phoenix General Hospital';
        account3.RecordTypeId = Constant_AC.HOSPITAL_TREATMENT_ID;
        account3.Chapter_Name__c = account2.Id;
        account3.Hidden_Chapter__c = account1.Id;
        insert account3;
        
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
    
    @IsTest
    public static void validateChapterChangeContact() {
        Contact mpContact = [
            SELECT Id, Region_Chapter__c 
            FROM Contact 
            WHERE Name = 'Allison Knowles'
        ];
        Test.startTest();
        ChapterChangeConfirmationPopup_AC.updateContactChapter('accept', mpContact.Id);
        Test.stopTest();
        
        Contact mpContactUpdated = [
            SELECT Id, Hidden_Chapter__c 
            FROM Contact 
            WHERE Id = :mpContact.Id
        ];
        System.assert(mpContact.Region_Chapter__c == mpContactUpdated.Hidden_Chapter__c);
    }
    
    
    @IsTest
    public static void validateChapterRevertAccount() {
        Account htfAccount = [
            SELECT Id, Hidden_Chapter__c
            FROM Account 
            WHERE Name = 'Phoenix General Hospital'
        ];
        Test.startTest();
        ChapterChangeConfirmationPopup_AC.updateAccountChapter('revert', htfAccount.Id);
        Test.stopTest();
        
        Account htfAccountUpdated = [
            SELECT Id, Hidden_Chapter__c, Chapter_Name__c
            FROM Account 
            WHERE Name = 'Phoenix General Hospital'
        ];
        System.assert(htfAccount.Hidden_Chapter__c == htfAccountUpdated.Chapter_Name__c);
    }
}