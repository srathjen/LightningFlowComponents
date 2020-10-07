@IsTest
public class LeadConvertServiceTest {

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
		qualifiedLead.Any_medical_reason_for_moving_quickly__c = 'No';
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
		insert leads;

		qualifiedLead.Sub_Status__c = Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION;
		update qualifiedLead;

        List<Case> cases = TestDataFactory.createCase(1);
        Case wish = cases.get(0);
        wish.RecordTypeId = Constant_AC.DIAGNOSIS_RT_ID;
        wish.ChapterName__c = account1.Id;
        wish.Lead__c = qualifiedLead.Id;
        wish.Subject = 'Parent Wish';
        wish.Interview_date__c = System.today();
        wish.Wish_Type__c = 'Disney World';
        wish.Start_Date__c = System.today();
        wish.End_Date__c = System.today();
        wish.Status = 'New';
        wish.Start_Date__c = System.today();
        wish.Budget_Submitted_Date__c = System.today();
        wish.Budget_Approved_Date__c = System.today();
        wish.Comment_1__c = '';
        wish.Appropriate_Comments__c = '';
        wish.Please_Explain__c = '';
        insert cases;

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void shouldConvertLead_existingContactId() {
		Lead lead = [
				SELECT Id, Name
				FROM Lead
				WHERE Status = :Constant_AC.LEAD_STATUS_REFERRED
				LIMIT 1
		];

		Map<Id, Lead> leadMap = new Map<Id, Lead>();
		leadMap.put(lead.Id, lead);

		Test.startTest();
		Map<Id, Id> convertLeadResult = LeadConvertService.convertLead(leadMap);

		Contact leadGeneratedContact = [
				SELECT Id
				FROM Contact
				WHERE Name = :lead.Name
				LIMIT 1
		];
		System.assertEquals(leadGeneratedContact.Id, convertLeadResult.get(lead.Id));

		LeadConvertService.processConvertedLead(convertLeadResult);
		Test.stopTest();
	}

    @IsTest
    public static void shouldConvertLead() {
        Lead lead = [
                SELECT Id, Name
                FROM Lead
                WHERE Status = :Constant_AC.LEAD_STATUS_REFERRED
                LIMIT 1
        ];

        lead.Sibling_Detail__c = 'aa | aaab | 14 | bbb | bbbc | 15';
        lead.Wish_Family_ContactId__c = null;
        lead.Hidden_Additional_Parent_Id__c = null;
        lead.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL;
        update lead;

        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        leadMap.put(lead.Id, lead);

        Test.startTest();
        Map<Id, Id> convertLeadResult = LeadConvertService.convertLead(leadMap);

        Contact leadGeneratedContact = [
                SELECT Id
                FROM Contact
                WHERE Name = :lead.Name
                LIMIT 1
        ];
        System.assertEquals(leadGeneratedContact.Id, convertLeadResult.get(lead.Id));

        LeadConvertService.processConvertedLead(convertLeadResult);
        Test.stopTest();
    }
}