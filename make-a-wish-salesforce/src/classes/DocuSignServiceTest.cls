/**
 * @description DocuSign Service Test
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 2/27/2020
 */
@IsTest
public class DocuSignServiceTest {

	private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;

	@TestSetup
	public static void setup() {
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

		List<dsfs__DocuSign_Status__c> docuSignStatuses = TestDataFactory.createDocusignStatus(1);
		dsfs__DocuSign_Status__c docuSignStatus = docuSignStatuses.get(0);
		docuSignStatus.dsfs__Lead__c = lead.Id;
        docuSignStatus.dsfs__Envelope_Status__c = 'Completed';
		insert docuSignStatuses;

		List<Attachment> attachments = TestDataFactory.createAttachments(1, docuSignStatus.Id);
		Attachment attachment = attachments.get(0);
		attachment.ContentType = 'Text';
		insert attachments;
	}
    
    @isTest
    public static void shouldFindByLeadAndEnvelopeStatus() {
        Set<Id> leadIds = new Set<Id>();
        Id leadId = [SELECT Id FROM Lead WHERE Name = 'Jack Smith'].Id;
        leadIds.add(leadId);
        
        test.startTest();
        List<dsfs__DocuSign_Status__c> docusignStatusList = DocuSignService.findByLeadAndEnvelopeStatus(leadIds, 'Completed');
        test.stopTest();
        
        System.assert(!docusignStatusList.isEmpty());
    }
}