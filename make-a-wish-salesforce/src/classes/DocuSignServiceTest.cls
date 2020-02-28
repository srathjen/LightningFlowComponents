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
		insert docuSignStatuses;
		List<Attachment> attachments = TestDataFactory.createAttachments(1, docuSignStatus.Id);
		Attachment attachment = attachments.get(0);
		attachment.ContentType = 'Text';
		insert attachments;
	}

	@IsTest
	public static void shouldDeleteLeadsDocusignStatusesAndAttachments() {
		Lead lead = [
				SELECT Id
				FROM Lead
				WHERE Name = 'Jack Smith'
		];
		List<Id> leadIds = new List<Id>();
		leadIds.add(lead.Id);

		Test.startTest();
		DocuSignService.deleteByLeadIdAndDeleteRelatedAttachments(lead.Id);
		Test.stopTest();

		List<dsfs__DocuSign_Status__c> docuSignStatuses = [
				SELECT Id
				FROM dsfs__DocuSign_Status__c
				WHERE dsfs__Lead__c = :lead.Id
		];
		List<Attachment> attachments = [
				SELECT Id
				FROM Attachment
				WHERE ContentType = 'Text'
		];
		System.assertEquals(0, docuSignStatuses.size());
		System.assertEquals(0, attachments.size());
	}
}