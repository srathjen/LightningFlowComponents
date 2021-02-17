/**
 * @description Diagnosis Verification Additional Medical Questions Controller Test
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 08/Feb/2021
 */
@IsTest
public with sharing class DvAdditionalMedicalQuestionsCtrlTest {

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
	public static void shouldLoadAdditionalMedicalQuestions(){
		Lead lead = [
				SELECT Id
				FROM Lead
				WHERE Name = 'Jack Smith'
		][0];

		// Additional Medical Questions:
		lead.Unplanned_hospital_admissions__c = 'Yes';
		lead.Number_hospital_admissions__c = 0;
		lead.Admitting_diagnosis__c = 'Neoplasm';
		lead.ICU_Admissions__c = 'Yes';
		lead.Why_do_you_feel_would_be_eligible_Wish__c = 'Additional clinical details notes';
		lead.Child_will_ultimately_die_prematurely__c = true;
		lead.Treatment_may_be_feasible_but_can_fail__c = false;
		lead.Treatment_may_prolong_normal_activities__c = false;
		lead.Debilitation_may_extend_over_many_years__c = false;
		lead.Increased_probability_of_premature_death__c = false;
		lead.None_of_these_statements_describes_Child__c = false;
		lead.Will_Child_s_Condition_Deteriorate__c = 'Yes';
		lead.Please_Explain_Deteriorate__c = 'Deteriorate 3-6 notes';
		lead.Any_medical_reason_for_moving_quickly__c = '<font color="Red">Yes</font>';
		lead.Please_Explain__c = 'Reason for expediting notes';
		lead.Expedite_timeframe__c = 'Other';
		lead.Other_expedite_timeframe_comments__c = 'Ideal time frame notes';
		lead.Provided_additional_information__c = 'Additional Information notes';
		lead.Does_Child_Have_Cognitive_Delays__c = 'Mild: Functions close to peers';
		lead.Does_Child_Have_Speech_or_Language_Delay__c = 'Yes';
		lead.Non_Verbal__c = 'Yes';
		lead.Non_Verbal_Communication_Method__c = 'Crying without the capacity to indicate needs or wants to a caregiver well known to the child';
		lead.Non_Verbal_Additional_Information__c = 'Additional information about child\'s ability to communicate notes';
		update lead;

		Test.startTest();
		DvAdditionalMedicalQuestionsController.AdditionalMedicalQuestionsWrapper amq = DvAdditionalMedicalQuestionsController.getAdditionalMedicalQuestionsByLeadId(lead.Id);
		Test.stopTest();

		System.assertEquals('Yes', amq.unplannedHospitalAdmissions);
		System.assertEquals('0', amq.timesChildAdmitted);
		System.assertEquals('Neoplasm', amq.admittedDiagnosis);
		System.assertEquals('Yes', amq.hospitalizationAdmissionIcu);
		System.assertEquals('Additional clinical details notes', amq.additionalClinicalDetails);
		System.assertEquals('TREATMENT_MAY_BE_FEASIBLE_BUT_CAN_FAIL', amq.statementDescribePatient);
		System.assertEquals('Yes', amq.expectConditionDeteriorate);
		System.assertEquals('Deteriorate 3-6 notes', amq.expectConditionDeteriorateExplain);
		System.assertEquals('Yes', amq.medicalExpediteProcess);
		System.assertEquals('Reason for expediting notes', amq.medicalExpediteProcessReason);
		System.assertEquals('Other', amq.provideTimeFrameWish);
		System.assertEquals('Ideal time frame notes', amq.provideTimeFrameWishInformation);
		System.assertEquals(null, amq.medicalSummaryAttachment);
		System.assertEquals('Additional Information notes', amq.additionalInfoProvide);
		System.assertEquals('Yes', amq.cognitiveDelay);
		System.assertEquals('Mild: Functions close to peers', amq.levelOfDelay);
		System.assertEquals('Yes', amq.speechLanguageDelay);
		System.assertEquals('No, child is non-verbal', amq.expressNeedsDesires);
		System.assertEquals(new List<String>{'Crying without the capacity to indicate needs or wants to a caregiver well known to the child'}, amq.describeCommunicationNeeds);
		System.assertEquals('Additional information about child\'s ability to communicate notes', amq.describeCommunicationNeedsInformation);
	}

	@IsTest
	public static void shouldSaveAdditionalMedicalQuestions(){
		Lead lead = [
				SELECT Id
				FROM Lead
				WHERE Name = 'Jack Smith'
		][0];

		DvAdditionalMedicalQuestionsController.AdditionalMedicalQuestionsWrapper amq = new DvAdditionalMedicalQuestionsController.AdditionalMedicalQuestionsWrapper();
		amq.leadId = lead.Id;
		amq.unplannedHospitalAdmissions = 'Yes';
		amq.timesChildAdmitted = '0';
		amq.admittedDiagnosis = 'Neoplasm';
		amq.hospitalizationAdmissionIcu = 'Yes';
		amq.additionalClinicalDetails = 'Additional clinical details notes';
		amq.statementDescribePatient = 'TREATMENT_MAY_BE_FEASIBLE_BUT_CAN_FAIL';
		amq.expectConditionDeteriorate = 'Yes';
		amq.expectConditionDeteriorateExplain = 'Deteriorate 3-6 notes';
		amq.medicalExpediteProcess = 'Yes';
		amq.medicalExpediteProcessReason = 'Reason for expediting notes';
		amq.provideTimeFrameWish = 'Other';
		amq.provideTimeFrameWishInformation = 'Ideal time frame notes';
		amq.medicalSummaryAttachment = '';
		amq.additionalInfoProvide = 'Additional Information notes';
		amq.cognitiveDelay = 'Yes';
		amq.levelOfDelay = 'Mild: Functions close to peers';
		amq.speechLanguageDelay = 'Yes';
		amq.expressNeedsDesires = 'No, child is non-verbal';
		amq.describeCommunicationNeeds = new List<String>{'Crying without the capacity to indicate needs or wants to a caregiver well known to the child'};
		amq.describeCommunicationNeedsInformation = 'Additional information about child\'s ability to communicate notes';

		Test.startTest();
		DvAdditionalMedicalQuestionsController.SaveAdditionalMedicalQuestionsResultWrapper result = DvAdditionalMedicalQuestionsController.saveAdditionalMedicalQuestions(amq);
		Test.stopTest();

		Lead savedLead = result.lead;
		System.assertEquals(true, result.saved);
		System.assertEquals('Yes', savedLead.Unplanned_hospital_admissions__c);
		System.assertEquals(0, savedLead.Number_hospital_admissions__c = 0);
		System.assertEquals('Neoplasm', savedLead.Admitting_diagnosis__c);
		System.assertEquals('Yes', savedLead.ICU_Admissions__c);
		System.assertEquals('Additional clinical details notes', savedLead.Why_do_you_feel_would_be_eligible_Wish__c);
		System.assertEquals(true, savedLead.Child_will_ultimately_die_prematurely__c = true);
		System.assertEquals(false, savedLead.Treatment_may_be_feasible_but_can_fail__c = false);
		System.assertEquals(false, savedLead.Treatment_may_prolong_normal_activities__c = false);
		System.assertEquals(false, savedLead.Debilitation_may_extend_over_many_years__c = false);
		System.assertEquals(false, savedLead.Increased_probability_of_premature_death__c = false);
		System.assertEquals(false, savedLead.None_of_these_statements_describes_Child__c = false);
		System.assertEquals('Yes', savedLead.Will_Child_s_Condition_Deteriorate__c);
		System.assertEquals('Deteriorate 3-6 notes', savedLead.Please_Explain_Deteriorate__c);
		System.assertEquals('<font color="Red">Yes</font>', savedLead.Any_medical_reason_for_moving_quickly__c);
		System.assertEquals('Reason for expediting notes', savedLead.Please_Explain__c);
		System.assertEquals('Other', savedLead.Expedite_timeframe__c);
		System.assertEquals('Ideal time frame notes', savedLead.Other_expedite_timeframe_comments__c);
		System.assertEquals('Additional Information notes', savedLead.Provided_additional_information__c);
		System.assertEquals('Mild: Functions close to peers', savedLead.Does_Child_Have_Cognitive_Delays__c);
		System.assertEquals('Yes', savedLead.Does_Child_Have_Speech_or_Language_Delay__c);
		System.assertEquals('Yes', savedLead.Non_Verbal__c);
		System.assertEquals('Crying without the capacity to indicate needs or wants to a caregiver well known to the child', savedLead.Non_Verbal_Communication_Method__c);
		System.assertEquals('Additional information about child\'s ability to communicate notes', savedLead.Non_Verbal_Additional_Information__c);
	}
}