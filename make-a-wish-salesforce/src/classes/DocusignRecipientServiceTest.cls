/**
 * @description Case Service Test Class
 * @author Gustavo Mayer, Traction on Demand
 * @date 8/20/2019
 */
@IsTest
public with sharing class DocusignRecipientServiceTest {

	@TestSetup
	public static void setUpData() {
		trac_TriggerHandlerBase.blockTrigger = true;

		List<Account> accounts = TestDataFactory.createAccount(2);
		Account account1 = accounts.get(0);
		insert accounts;

		List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
		insert icdCodes;

		List<Lead> leads = TestDataFactory.createLead(1);
		Lead lead = leads.get(0);
		lead.ChapterName__c = account1.Id;
		lead.FirstName = 'Jack';
		lead.LastName = 'Smith';
		lead.Hidden_Chapter_Change_Confirmation__c = account1.Id;
		lead.is_Family_Aware_of_Referral__c = 'Yes';
		lead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
		lead.PD_ICD_Code__c = icdCodes.get(0).Id;
		lead.Company = 'MAW';
		lead.DOB__c = Date.today().addDays(-1400);
		lead.I_am_Recognized_To_Practice_As_a__c = 'Physician';
		insert lead;

		List<dsfs__DocuSign_Status__c> docuSignStatuses = TestDataFactory.createDocusignStatus(1);
		dsfs__DocuSign_Status__c docuSignStatus = docuSignStatuses.get(0);
		docuSignStatus.dsfs__Lead__c = lead.Id;
		docuSignStatus.dsfs__Completed_Date_Time__c = Date.today();
		docuSignStatus.dsfs__Envelope_Status__c = Constant_AC.DOCUSIGN_ENVELOPE_STATUS_COMPLETED;
		docuSignStatus.dsfs__Subject__c = 'Test Subject';
		insert docuSignStatuses;

		Attachment attachment = TestDataFactory.createAttachments(1, docuSignStatus.Id)[0];
		insert attachment;

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	static void shouldUpdateStatusRecord() {
		List<Lead> leads = [
				SELECT Id
				FROM Lead
		];
		dsfs__DocuSign_Status__c docuSignStatus = [
				SELECT Id, dsfs__Lead__c
				FROM dsfs__DocuSign_Status__c
				WHERE dsfs__Lead__c = :leads.get(0).Id
				LIMIT 1
		];

		DocusignRecipientService.updateStatusRecord(new Map<Id, String>{
				docuSignStatus.Id => 'Test'
		}, new List<dsfs__DocuSign_Recipient_Status__c>());
	}

	@IsTest
	static void shouldUpdateAttachmentId() {
		List<Lead> leads = [
				SELECT Id
				FROM Lead
		];
		dsfs__DocuSign_Status__c docuSignStatus = [
				SELECT Id, dsfs__Lead__c
				FROM dsfs__DocuSign_Status__c
				WHERE dsfs__Lead__c = :leads.get(0).Id
				LIMIT 1
		];
		Attachment attachment = [
				SELECT Id
				FROM Attachment
				WHERE ParentId = :docuSignStatus.Id
				LIMIT 1
		];

		DocusignRecipientService.updateAttachmentId(new Set<Id>{attachment.Id}, new List<dsfs__DocuSign_Recipient_Status__c>());
	}
}