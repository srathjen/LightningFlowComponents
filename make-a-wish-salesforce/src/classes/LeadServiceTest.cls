/**
 * @description Lead Service Test
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 2/27/2020
 */
@IsTest
public class LeadServiceTest {

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

		List<Lead> leads = TestDataFactory.createLead(2);
		Lead lead = leads.get(0);
		lead.ChapterName__c = account1.Id;
		lead.FirstName = 'Jack';
		lead.LastName = 'Smith';
		lead.Hidden_Chapter_Change_Confirmation__c = account2.Id;
		lead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
		lead.PD_ICD_Code__c = icdCode.Id;
		lead.Phone = '9600467559';
		lead.Email = 'testmawa@gmail.com';
		lead.Street = 'KuttaiKarai Street';
		lead.StateCode = 'AZ';
		lead.City = 'Trichy';
		lead.PostalCode = '6201717';
		lead.CountryCode = 'US';
		lead.DOB__c = System.today() - 1435;
		lead.Company = 'MAW';
		lead.Status = 'Inquiry';
		lead.Gender__c = 'Male';
		lead.Referrer_FirstName__c = 'SteveJune';
		lead.Referrer_Last_Name__c = 'Waughone';
		lead.Referrer_Email__c = 'testmawa2d@gmail.com';
		lead.Referrer_Phone__c = '9600467578';
		lead.Referrer_City__c = 'Trichy';
		lead.Referrer_Zip__c = '6210';
		lead.Sibling_Detail__c = 'aa | aaab | 14 bbb | bbbc | 15';
		lead.PD_Condition_Description__c = 'Test Diagnosis';
		lead.Parent_First_Name__c = 'MAWAFirstJune';
		lead.Parent_Last_Name__c = 'MAWALastJune';
		lead.Medical_Professional_First_Name__c = 'SteveJune';
		lead.Medical_Professional_Last_Name__c = 'Waughone';
		lead.Medical_Professional_Phone__c = '9600467578';
		lead.Medical_Professional_Email__c = 'testmawa2d@gmail.com';
		lead.Hospital_Treatment_Facility__c = 'Steve Smith AC';
		lead.Treating_Medical_Professional_First_Name__c = 'SteveJune';
		lead.Treating_Medical_Professional_Last_Name__c = 'Waughone';
		lead.Treating_Medical_Professional_Phone__c = '9600467578';
		lead.Treating_Medical_Professional_Email__c = 'testmawa2d@gmail.com';
		lead.Hospital_Treatment_Facility_Treating__c = 'Steve Smith AC';
		lead.Best_Contact_for_Physician_First_Name__c = 'SteveJune';
		lead.Best_Contact_for_Physician_Last_Name__c = 'Waughone';
		lead.Best_contact_for_Physician_Email__c = 'testmawa2d@gmail.com';
		lead.is_Family_Aware_of_Referral__c = 'Yes';
		lead.Medical_Questions__c = 'Test Diagnosis';
		lead.Lung_Disease__c = 'Test1;Test2';
		lead.Angina__c = 'Test1;Test2';
		lead.Ventilator__c = 'Test1;Test2';
		lead.Arrhythmia__c = 'Test1;Test2';
		lead.Heart_Failure__c = 'Test1;Test2';
		lead.Congenital_Heart_Disease__c = 'Test1;Test2';
		lead.Chronic_Hepatitis__c = 'Test1;Test2';
		lead.Convulsive_Disorders__c = 'Test1;Test2';
		lead.Pulmonary_Hypertension__c = 'Test1;Test2';
		lead.Strokes__c = 'Test1;Test2';
		lead.Chronic_Heart_Failure__c = 'Test1;Test2';
		lead.isSign__c = true;
		lead.Travel_algorithm__c = 'Test1;Test2;';
		Lead lead2 = leads.get(1);
		lead2.ChapterName__c = accounts[0].Id;
		lead2.FirstName = 'Mark';
		lead2.LastName = 'Smith';
		lead2.is_Family_Aware_of_Referral__c = 'Yes';
		lead2.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
		lead2.PD_ICD_Code__c = icdCode.Id;
		lead2.Company = 'MAW';
		insert leads;
	}

	@IsTest
	public static void shouldRevertChapterName() {
		Account oldChapter = [
				SELECT Id
				FROM Account
				WHERE Name IN ('Make-A-Wish New York')
		];
		Lead lead = [
				SELECT Id, ChapterName__c
				FROM Lead
				WHERE Name = 'Jack Smith'
		];
		List<Id> leadIds = new List<Id>();
		leadIds.add(lead.Id);

		Test.startTest();
		Map<Id, Lead> leadMap = LeadService.revertChapterNameChange(leadIds);
		Test.stopTest();

		System.assertEquals(oldChapter.Id, leadMap.get(lead.Id).ChapterName__c);
		System.assertEquals(oldChapter.Id, leadMap.get(lead.Id).Hidden_Chapter_Change_Confirmation__c);
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
		List<Id> leadIds = new List<Id>();
		leadIds.add(lead.Id);

		Test.startTest();
		Map<Id, Lead> leadMap = LeadService.backupChapterNameChange(leadIds);
		Test.stopTest();

		System.assertEquals(newChapter.Id, leadMap.get(lead.Id).Hidden_Chapter_Change_Confirmation__c);
	}

	@IsTest
	public static void shouldResetLeadFields() {
		Lead lead = [
				SELECT Id, ChapterName__c
				FROM Lead
				WHERE Name = 'Jack Smith'
		];

		Test.startTest();
		Lead updatedLead = LeadService.resetLead(lead.Id);
		Test.stopTest();

		System.assertEquals(Constant_AC.LEAD_STATUS_REFERRED, updatedLead.Status);
	}
}