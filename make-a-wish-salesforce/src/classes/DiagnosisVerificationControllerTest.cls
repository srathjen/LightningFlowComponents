/**
 * @description Diagnosis Verification Controller Test
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 08/Feb/2021
 */
@IsTest
public with sharing class DiagnosisVerificationControllerTest {

	@TestSetup
	public static void setup() {
		trac_TriggerHandlerBase.blockTrigger = true;
		List<Account> accounts = TestDataFactory.createAccount(1);
		Account account1 = accounts.get(0);
		account1.Name = 'Make-A-Wish Arizona';
		account1.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
		insert accounts;

		List<ICD_Codes__c> icdCodesDataFactory = TestDataFactory.createIcdCode(1);
		ICD_Codes__c icdCode = icdCodesDataFactory.get(0);
		insert icdCode;

		List<Contact> contacts = TestDataFactory.createContact(2);
		Contact contact1 = contacts.get(0);
		contact1.FirstName = 'MAWAFirstName';
		contact1.LastName = 'MAWALastName';
		contact1.Email = 'testmawa@maw.com.test';
		contact1.Phone = '9600467559';
		contact1.MailingStreet = '123 Street';
		contact1.MailingCity = 'Phoenix';
		contact1.MailingStateCode = 'AZ';
		contact1.MailingPostalCode = '840001';
		contact1.MailingCountryCode = 'US';
		contact1.RecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
		contact1.IsParentGuardian__c = 'ParentGuardian';
		contact1.Birthdate = System.today() + 11234;
		contact1.Region_Chapter__c = account1.Id;

		Contact contact2 = contacts.get(0);
		contact2.FirstName = 'MAWAFirstName2';
		contact2.LastName = 'MAWALastName2';
		contact2.Email = 'testmawa@maw.com.test';
		contact2.Phone = '9600467559';
		contact2.MailingStreet = '123 Street';
		contact2.MailingCity = 'Phoenix';
		contact2.MailingStateCode = 'AZ';
		contact2.MailingPostalCode = '840001';
		contact2.MailingCountryCode = 'US';
		contact2.RecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
		contact2.IsParentGuardian__c = 'ParentGuardian';
		contact2.Birthdate = System.today() + 11234;
		contact2.Region_Chapter__c = account1.Id;
		insert contacts;

		List<npe5__Affiliation__c> affiliations = TestDataFactory.createAffiliation(1);
		npe5__Affiliation__c affiliation = affiliations.get(0);
		affiliation.npe5__Contact__c = contact1.Id;
		affiliation.npe5__Organization__c = account1.Id;
		affiliation.npe5__Primary__c = true;
		affiliation.Constituent_Code__c = Constant_AC.VOLUNTEER_TASK_RT_LABEL;
		affiliation.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
		insert affiliations;

		List<Lead> leads = TestDataFactory.createLead(1);
		Lead qualifiedLead = leads.get(0);
		qualifiedLead.RecordTypeId = Constant_AC.LEAD_RT_WISH_CHILD;
		qualifiedLead.ChapterName__c = account1.Id;
		qualifiedLead.FirstName = 'Jack';
		qualifiedLead.LastName = 'Smith';
		qualifiedLead.Hidden_Chapter_Change_Confirmation__c = account1.Id;
		qualifiedLead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
		qualifiedLead.PD_ICD_Code__c = icdCode.Id;
		qualifiedLead.Phone = '9600467559';
		qualifiedLead.Email = 'testmawa@email.com';
		qualifiedLead.Street = 'KuttaiKarai Street';
		qualifiedLead.StateCode = 'AZ';
		qualifiedLead.City = 'Phoenix';
		qualifiedLead.PostalCode = '840001';
		qualifiedLead.CountryCode = 'US';
		qualifiedLead.DOB__c = System.today() - 1435;
		qualifiedLead.Company = 'MAW';
		qualifiedLead.Status = Constant_AC.LEAD_STATUS_REFERRED;
		qualifiedLead.Gender__c = 'Male';
		qualifiedLead.I_am_Recognized_To_Practice_As_a__c = 'Physician';
		qualifiedLead.Referrer_FirstName__c = 'SteveJune';
		qualifiedLead.Referrer_Last_Name__c = 'Waughone';
		qualifiedLead.Referrer_Email__c = 'testmawa2d@email.com';
		qualifiedLead.Referrer_Phone__c = '9600467578';
		qualifiedLead.Referrer_City__c = 'Trichy';
		qualifiedLead.Referrer_Zip__c = '6210';
		qualifiedLead.PD_Condition_Description__c = 'Test Diagnosis';
		qualifiedLead.Parent_First_Name__c = 'MAWAFirstName';
		qualifiedLead.Parent_Last_Name__c = 'MAWALastName';
		qualifiedLead.Wish_Family_ContactId__c = contact1.Id;
		qualifiedLead.Additional_Parent_Last_Name__c = '';
		qualifiedLead.Hidden_Additional_Parent_Id__c = contact2.Id;
		qualifiedLead.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL;
		qualifiedLead.is_Family_Aware_of_Referral__c = 'Yes';
		qualifiedLead.Medical_Questions__c = 'Test Diagnosis';
		qualifiedLead.Lung_Disease__c = 'Test1;Test2';
		qualifiedLead.Angina__c = 'Test1;Test2';
		qualifiedLead.Ventilator__c = 'Test1;Test2';
		qualifiedLead.Arrhythmia__c = 'Test1;Test2';
		qualifiedLead.Heart_Failure__c = 'Test1;Test2';
		qualifiedLead.Congenital_Heart_Disease__c = 'Test1;Test2';
		qualifiedLead.Chronic_Hepatitis__c = 'Test1;Test2';
		qualifiedLead.Convulsive_Disorders__c = 'Test1;Test2';
		qualifiedLead.Pulmonary_Hypertension__c = 'Test1;Test2';
		qualifiedLead.Strokes__c = 'Test1;Test2';
		qualifiedLead.Chronic_Heart_Failure__c = 'Test1;Test2';
		qualifiedLead.isSign__c = true;
		qualifiedLead.Travel_algorithm__c = 'Test1;Test2;';
		qualifiedLead.Sibling_Detail__c = 'aa | aaab | 14 <br> bbb | bbbc | 15 <br>';
		qualifiedLead.Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
		qualifiedLead.Treating_Medical_Professional_First_Name__c = 'Dr. Jack';
		qualifiedLead.Treating_Medical_Professional_Last_Name__c = 'Doe';
		qualifiedLead.Treating_Medical_Professional_Phone__c = '8220708921';
		qualifiedLead.Treating_Medical_Professional_Email__c = 'jdoe@email.com';
		qualifiedLead.Hospital_Treatment_Facility_Treating__c = 'Treating Facility';
		insert leads;
		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void shouldGetDiagnosisVerificationByLeadId() {
		Lead lead = [
				SELECT Id
				FROM Lead
				WHERE Name = 'Jack Smith'
		][0];

		Test.startTest();
		DiagnosisVerificationController.DiagnosisVerificationWrapper dvw = DiagnosisVerificationController.getDiagnosisVerificationByLeadId(lead.Id);
		Test.stopTest();

		System.assertEquals(1, dvw.process.currentStepId);
	}
    
    @IsTest
    public static void shouldUpdateLastDvSaveDate() {
        Lead lead = [
            SELECT Id
            FROM Lead
            WHERE Name = 'Jack Smith'
        ];
        Test.startTest();
        DiagnosisVerificationController.updateLastDvSaveDate(lead.Id);
        Test.stopTest();
        
        Lead updatedLead = [
            SELECT Id, Last_DV_Save_Date__c 
            FROM Lead
            WHERE Id = :lead.Id
        ];
        System.assert(updatedLead.Last_DV_Save_Date__c == date.today());
    }
}