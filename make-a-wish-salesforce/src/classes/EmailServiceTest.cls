/**
 * @description Service class for Email Delivery
 * @author  Gustavo Mayer, Traction on Demand
 * @createdDate 08/Sep/2020
 */
@IsTest
public class EmailServiceTest {

	@TestSetup
	static void setup() {
		trac_TriggerHandlerBase.blockTrigger = true;

		List<Account> accounts = TestDataFactory.createAccount(1);
		Account account1 = accounts.get(0);
		account1.Name = 'Make-A-Wish Arizona';
		account1.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
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
	static void shouldBuildEmail() {
		Lead lead = [
				SELECT Id
				FROM Lead
				WHERE Name = 'Jack Smith'
		];
		EmailService.EmailMessageWrapper email = new EmailService.EmailMessageWrapper(
				lead.Id,
				Label.DV_Form_Email_Template_API,
				new List<String>{
						'test@test.com.invalid'
				}
		);

		Test.startTest();
		List<Messaging.SingleEmailMessage> result = EmailService.buildEmail(new List<EmailService.EmailMessageWrapper>{
				email
		});
		System.assertEquals('test@test.com.invalid', result[0].getToAddresses()[0]);
		EmailService.sendEmail(result);
		Test.stopTest();
	}
}