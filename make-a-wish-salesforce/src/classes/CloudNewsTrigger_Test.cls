/**
 * @description     Test class for CloudNewsTrigger trigger.
 * @author          MST Solutions
 * @createdDate     2018-09-11
 */
@isTest
private class CloudNewsTrigger_Test {

	@testSetup
	static void setup() {
		List<Account> accounts = TestDataFactory.createAccount(2);
		accounts[0].Name = Constant_AC.ACCOUNT_NAME_MAW_ALABAMA;
		accounts[0].RecordTypeId = Constant_AC.CHAPTER_RT_ID;
		accounts[0].Alert_for_Unassigned_Wishes__c = 1;
		accounts[1].Name = Constant_AC.ACCOUNT_NAME_MAW_AMERICA;
		accounts[1].RecordTypeId = Constant_AC.CHAPTER_RT_ID;
		accounts[1].MAC_Email_del__c = 'testMAC@maw.com.test';
		insert accounts;

		List<Condition_Description__c> conditionDescriptions = TestDataFactory.createConditionDescription(1);
		conditionDescriptions[0].Name = 'Malignant Melanoma';
		conditionDescriptions[0].Treatment_Subspecialty__c = 'Oncology';
		conditionDescriptions[0].Code_To_Use__c = 'C43.30';
		conditionDescriptions[0].PR_Diagnosis__c = 'Malignant Melanoma';
		conditionDescriptions[0].Group1__c = true;
		insert conditionDescriptions;

		List<Contact> contacts = TestDataFactory.createContact(2);

		contacts[0].FirstName = 'Steveone';
		contacts[0].LastName = 'Waughone';
		contacts[0].Email = 'testmawa2@gmail.com';
		contacts[0].Phone = '9600467554';
		contacts[0].MailingStreet = 'KuttaiKarai Street';
		contacts[0].MailingCity = 'Trichy';
		contacts[0].MailingStateCode = 'AZ';
		contacts[0].MailingPostalCode = '6201717';
		contacts[0].Provider_Type__c = 'Nurse Practitioner';
		contacts[0].MailingCountryCode = 'US';
		contacts[0].RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;

		contacts[1].FirstName = 'MAWAFirstName';
		contacts[1].LastName = 'MAWALastName';
		contacts[1].Email = 'testmawa@maw.com.test';
		contacts[1].Phone = '9600467559';
		contacts[1].MailingStreet = 'KuttaiKarai Street';
		contacts[1].MailingCity = 'Trichy';
		contacts[1].MailingStateCode = 'AZ';
		contacts[1].MailingPostalCode = '6201717';
		contacts[1].MailingCountryCode = 'US';
		contacts[1].RecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
		contacts[1].IsParentGuardian__c = 'ParentGuardian';
		contacts[1].Birthdate = System.today() + 11234;
		contacts[1].Region_Chapter__c = accounts[0].Id;

		insert contacts;

		List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
		icdCodes[0].Name = 'C43.30';
		icdCodes[0].Condition_Description__c = conditionDescriptions[0].Id;
		icdCodes[0].Group1__c = true;
		icdCodes[0].Short_Description__c = 'Malignant melanoma of unspecified part of face';
		icdCodes[0].Long_Description__c = 'Malignant melanoma of unspecified part of face';
		insert icdCodes;

		List<Lead> leads = TestDataFactory.createLead(1);
		leads[0].FirstName = 'moss';
		leads[0].LastName = 'Smith Household';
		leads[0].Phone = '9600467559';
		leads[0].Email = 'testmawa@gmail.com';
		leads[0].Street = 'KuttaiKarai Street';
		leads[0].StateCode = 'AZ';
		leads[0].City = 'Trichy';
		leads[0].PostalCode = '6201717';
		leads[0].CountryCode = 'US';
		leads[0].DOB__c = System.today() - 1435;
		leads[0].Company = 'MAWA';
		leads[0].Status = 'Inquiry';
		leads[0].Gender__c = 'Male';
		leads[0].ChapterName__c = accounts[0].Id;
		leads[0].Referrer_FirstName__c = 'SteveJuneone';
		leads[0].Referrer_Last_Name__c = 'Waugh';
		leads[0].Referrer_Email__c = 'testmawa21d@gmail.com';
		leads[0].Referrer_Phone__c = '9600467579';
		leads[0].Referrer_City__c = 'Trichy';
		leads[0].Referrer_Zip__c = '6210';
		leads[0].Sibling_Detail__c = 'aa | aaab | 14 bbb | bbbc | 15';
		leads[0].PD_Condition_Description__c = 'Test Diagnosis';
		leads[0].Parent_First_Name__c = 'MAWAFirstJune';
		leads[0].Parent_Last_Name__c = 'MAWALastJune';
		leads[0].Medical_Professional_First_Name__c = 'SteveJuneone';
		leads[0].Medical_Professional_Last_Name__c = 'Waugh';
		leads[0].Medical_Professional_Phone__c = '9600467579';
		leads[0].Medical_Professional_Email__c = 'testmawa21d@gmail.com';
		leads[0].Hospital_Treatment_Facility__c = 'Steve Smith AC';
		leads[0].Hospital_Treatment_Facility_Treating__c = 'Steve Smith AC';
		leads[0].is_Family_Aware_of_Referral__c = 'Yes';
		leads[0].Medical_Questions__c = 'Test Diagnosis';
		leads[0].Lung_Disease__c = 'Test1;Test2';
		leads[0].Angina__c = 'Test1;Test2';
		leads[0].Ventilator__c = 'Test1;Test2';
		leads[0].Arrhythmia__c = 'Test1;Test2';
		leads[0].Heart_Failure__c = 'Test1;Test2';
		leads[0].Congenital_Heart_Disease__c = 'Test1;Test2';
		leads[0].Chronic_Hepatitis__c = 'Test1;Test2';
		leads[0].Convulsive_Disorders__c = 'Test1;Test2';
		leads[0].Pulmonary_Hypertension__c = 'Test1;Test2';
		leads[0].Strokes__c = 'Test1;Test2';
		leads[0].Chronic_Heart_Failure__c = 'Test1;Test2';
		leads[0].isSign__c = true;
		leads[0].Travel_algorithm__c = 'Test1;Test2;';
		leads[0].Additional_Parent_First_Name__c = 'MAWAFirstJune';
		leads[0].Additional_Parent_Last_Name__c = 'MAWALastJune';
		leads[0].Additional_Parent_Phone__c = '9600467559';
		leads[0].Additional_Parent_Email__c = 'testmawa@gmail.com';
		leads[0].Additional_Parent_City__c = 'Trichy';
		leads[0].Additional_Parent_Postal_Code__c = '6201717';
		leads[0].Sibling_Detail__c = 'aa | - | 12';
		leads[0].Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
		leads[0].PD_ICD_Code__c = icdCodes[0].Id;
		leads[0].Diagnosis_Given_By_Referrer__c = 'Test';
		leads[0].Will_Child_s_Condition_Deteriorate__c = 'No';
		leads[0].I_m_Part_of_The_Treating_HealthCare_Team__c = 'No';
		leads[0].Is_in_a_Comatose_Vegetative_State__c = 'No';
		insert leads;

		leads[0].SD1_ICD_Code__c = icdCodes[0].Id;
		leads[0].SD2_ICD_Code__c = leads[0].SD1_ICD_Code__c = icdCodes[0].Id;
		leads[0].SD3_ICD_Code__c = leads[0].SD1_ICD_Code__c = icdCodes[0].Id;
		leads[0].SD4_ICD_Code__c = leads[0].SD1_ICD_Code__c = icdCodes[0].Id;
		leads[0].Status = 'Referred';
		leads[0].ChapterName__c = accounts[1].Id;
		leads[0].Sub_Status__c = 'Pending Diagnosis Verification';
		leads[0].Wish_Family_ContactId__c = contacts[1].Id;
		leads[0].Medical_Professional_ContactId__c = contacts[0].Id;
		leads[0].Hidden_Additional_Parent_Id__c = contacts[1].Id;
		leads[0].Hidden_Best_Contact_Person_Id__c = contacts[0].Id;
		update leads;
	}

	@isTest
	static void updateLeadAsQualified() {
		Lead lead = [
				SELECT
						SD1_ICD_Code__c,
						SD2_ICD_Code__c,
						SD3_ICD_Code__c,
						SD4_ICD_Code__c,
						Status,
						Chapter_Name__c,
						Sub_Status__c,
						Wish_Family_ContactId__c,
						Medical_Professional_ContactId__c,
						Hidden_Additional_Parent_Id__c,
						Hidden_Best_Contact_Person_Id__c,
						Any_medical_reason_for_moving_quickly__c,
						Please_Explain__c,
						I_am_Recognized_To_Practice_As_a__c
				FROM Lead
		];

		RecursiveTriggerHandler.isFirstTime = true;

		lead.Any_medical_reason_for_moving_quickly__c = 'Yes';
		lead.Please_Explain__c = 'Yes';
		lead.I_am_Recognized_To_Practice_As_a__c = 'Nurse';
		lead.Status = 'Qualified';

		Test.startTest();
		update lead;
		Test.stopTest();

		List<Apex_Debug_Log__c> debugLogs = [
				SELECT Id, Developer_Message__c
				FROM Apex_Debug_Log__c
		];
		System.assert(!debugLogs.isEmpty());
	}
}