/**
 * @description		Test class for WishReferralForm_AC
 * @author			unknown
 * @createdDate		unknown
 */
@isTest
private class WishReferralForm_AC_Test {

	@testSetup
	static void setup() {
		List<Account> chapterAccounts = TestDataFactory.createChapterAccount(1);
		chapterAccounts[0].Name = Constant_AC.ACCOUNT_NAME_MAW_AMERICA;
		chapterAccounts[0].Wish_Co_ordinator__c = UserInfo.getUserId();
		insert chapterAccounts;

		List<Office__c> offices = TestDataFactory.createOffice(1);
		offices[0].Chapter__c = chapterAccounts[0].Id;
		offices[0].Name = 'Make-A-Wish Alabama';
		offices[0].Office_Id__c = '014-000';
		offices[0].Office_Legal_Name__c = 'Make-A-Wish Alabama,NY, Inc.';
		offices[0].General_Email_Address__c = 'wishmail@suffolk.wish.org';
		offices[0].Website__c = 'http://suffolk.wish.org';
		offices[0].Address_1__c = '1 Comac Loop';
		offices[0].Address_2__c = 'Suite 1A1';
		offices[0].City__c = 'Ronkonkoma';
		offices[0].State__c = 'NY';
		offices[0].Zip_Code__c = '32193';
		offices[0].Country__c = 'US';
		offices[0].Phone_Number__c = '(631) 585-9474';
		insert offices;

		List<Zip_Code__c> zipCodes = TestDataFactory.createZipCode(1);
		zipCodes[0].Office__c = offices[0].Id;
		zipCodes[0].Name = '90210';
		zipCodes[0].External_Id__c = '1234567890';
		insert zipCodes;

		List<Contact> contacts = TestDataFactory.createContact(1);
		contacts[0].FirstName = 'Testing1';
		contacts[0].LastName = 'Testing2';
		contacts[0].Birthdate = Date.valueOf('2000-09-11');
		contacts[0].Phone = '8220708920';
		contacts[0].Email = 'mcavennila@gmail.com';
		contacts[0].Diagnosis__c = 'Test';
		insert contacts;

		List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
		icdCodes[0].Name = 'c00';
		insert icdCodes;

		Account treatingHospital = TestDataFactory.createAccount(1)[0];
		treatingHospital.recordTypeId = Constant_AC.HOSPITAL_TREATMENT_ID;
		treatingHospital.Name = 'Phoenix General Hospital';
		insert treatingHospital;

		Referral_Form_Alerts__c wishReferralFormSettings = new Referral_Form_Alerts__c();
		wishReferralFormSettings.Display_Warning__c = false;
		wishReferralFormSettings.Warning_Message__c = 'Warning';
		wishReferralFormSettings.Deactivate_Referral_Form__c = false;
		wishReferralFormSettings.Deactivated_Message__c = 'Message';
		wishReferralFormSettings.Deactivate_MP_HTF_Search__c = false;
		insert wishReferralFormSettings;
	}

	@isTest
	static void relationshipNone() {
		PageReference pageRef = Page.WishReferralForm_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('isSuccess', 'Test');

		WishReferralForm_AC controller = new WishReferralForm_AC();
		controller.currLead.Has_this_child_ever_received_prior_wish__c = 'Yes';
		controller.currLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
		controller.warningMsg = 'test';
		controller.displayWarningPopup = true;
		controller.CreateLead();
		controller.currLead.Child_Age__c = 'Under 2.5';

		WishReferralForm_AC.siblingWrapper sw = new WishReferralForm_AC.siblingWrapper();
		String fname = sw.fName;
		String lname = sw.lName;
		String age = sw.age;

		Test.startTest();
		controller.getlanguage();
		controller.getdiaYear();
		controller.getNoOfSiblings();
		controller.getSelfRequiredFields();
		controller.getNonMedicalReqFields();
		controller.getMedicalRequiredFields();
		Test.stopTest();

		Boolean relationToChildErrorFound = false;
		Boolean completeMandatoryErrorFound = false;

		for (ApexPages.Message msg : ApexPages.getMessages()) {
			if (msg.getSummary() == WishReferralForm_AC.ERROR_STRING_RELATIONSHIP_TO_CHILD) {
				relationToChildErrorFound = true;
			}
			if (msg.getSummary().contains(WishReferralForm_AC.ERROR_STRING_SELECT_MANDATORY_FIELDS)) {
				completeMandatoryErrorFound = true;
			}
		}

		System.assert(relationToChildErrorFound);
		System.assert(completeMandatoryErrorFound);
	}

    @isTest
    static void relationshipSelf() {
        Account chapterAccount = [
            SELECT Intake_Manager__c
            FROM Account
            WHERE Name = :Constant_AC.ACCOUNT_NAME_MAW_AMERICA
        ];
        
        PageReference pageRef = Page.WishReferralForm_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
        WishReferralForm_AC controller = new WishReferralForm_AC();
        controller.currLead.Has_this_child_ever_received_prior_wish__c = 'Yes';
        controller.currLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        controller.currLead.Relationship_To_Child__c = 'Self';
        controller.currLead.Referrer_Zip__c = '35004';
        controller.currLead.Child_Age__c = '5';
        
        Test.startTest();
        controller.CreateLead();
        controller.copyReferralInfo();
        Test.stopTest();
        
        System.assertEquals(Constant_AC.LEAD_STATUS_REFERRED, controller.currLead.Status);
    }

	@isTest
	static void relationshipSelf1() {
		PageReference pageRef = Page.WishReferralForm_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('isSuccess', 'Test');

		WishReferralForm_AC controller = new WishReferralForm_AC();
		controller.currLead.Has_this_child_ever_received_prior_wish__c = 'Yes';
		controller.currLead.Has_this_child_ever_received_prior_wish__c = 'Yes';
		controller.currLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
		controller.currLead.Relationship_to_child__c = 'Self';
		controller.currLead.Referrer_FirstName__c = 'Testing';
		controller.currLead.Referrer_Last_Name__c = 'Testing';
		controller.currLead.Referrer_Phone__c = '8220708920';
		controller.currLead.Referrer_Email__c = 'mcavennila@gmail.com';
		controller.currLead.Referrer_City__c = 'karur';
		controller.currLead.Referrer_Zip__c = '35004';
		controller.currLead.Medical_Provider_Category__c = 'Physician';
		controller.currLead.is_Family_Aware_of_Referral__c = 'yes';
		controller.currLead.FirstName = 'Testing1';
		controller.currLead.Child_Middle_Initial__c = 'Testing2';
		controller.lastName = 'Testing2';
		controller.currLead.Gender__c = 'Male';
		controller.currLead.Child_Age__c = '16';
		controller.currLead.DOB__c = Date.valueOf('2000-09-11');
		controller.currLead.Parent_First_Name__c = 'Testing3';
		controller.currLead.Parent_Last_Name__c = 'Testing3';
		controller.currLead.Street = 'Karur';
		controller.currLead.City = 'Karur';
		controller.currLead.State = 'Arizona';
		controller.currLead.PostalCode = '90210';
		controller.currLead.Email = 'mcavennila@gmail.com';
		controller.currLead.Phone = '8220708920';
		controller.currLead.What_is_the_family_s_primary_spoken_lang__c = 'English';
		controller.diagnosisFilter = 'c00';
		controller.selectedDiagnosis = 'Malignant Neoplasm';
		controller.currLead.Hospital_Treatment_Facility_Treating__c = 'Malignant Neoplasm';
		controller.currLead.Treating_Medical_Professional_First_Name__c = 'Treaing 1';
		controller.currLead.Treating_Medical_Professional_Last_Name__c = 'Treaing 1';
		controller.currLead.Treating_Medical_Professional_Phone__c = '8220708921';
		controller.currLead.Treating_Medical_Professional_Email__c = 'mcavennila@gmail.com';
		controller.currLead.Any_medical_reason_for_moving_quickly__c = 'yes';
		controller.currList = new List<WishReferralForm_AC.SiblingWrapper>{
				new WishReferralForm_AC.SiblingWrapper()
		};
		controller.currList[0].fName = 'Test';
		controller.currList[0].lName = 'Test';
		controller.currList[0].age = '10';

		Test.startTest();
		controller.CreateLead();
		controller.copyReferralInfo();
		Test.stopTest();

		System.assertEquals(Constant_AC.LEAD_STATUS_REFERRED, controller.currLead.Status);
	}

	@isTest
	static void relationshipSelf2() {
		PageReference pageRef = Page.WishReferralForm_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('isSuccess', 'Test');

		WishReferralForm_AC controller = new WishReferralForm_AC();
		controller.currLead.Has_this_child_ever_received_prior_wish__c = 'Yes';
		controller.currLead.Has_this_child_ever_received_prior_wish__c = 'Yes';
		controller.currLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
		controller.currLead.Medical_Provider_Category__c = 'Physician';
		controller.currLead.Relationship_to_child__c = 'Self';
		controller.currLead.Referrer_FirstName__c = 'Testing';
		controller.currLead.Referrer_Last_Name__c = 'Testing';
		controller.currLead.Referrer_Phone__c = '8220708920';
		controller.currLead.Referrer_Email__c = 'mcavennila@gmail.com';
		controller.currLead.Referrer_City__c = 'karur';
		controller.currLead.Referrer_Zip__c = '35004';
		controller.currLead.is_Family_Aware_of_Referral__c = 'yes';
		controller.currLead.FirstName = 'Testing1';
		controller.currLead.Child_Middle_Initial__c = 'Testing2';
		controller.lastName = 'Testing2';
		controller.currLead.Gender__c = 'Male';
		controller.currLead.Child_Age__c = '16';
		controller.currLead.DOB__c = Date.valueOf('2000-09-11');
		controller.currLead.Parent_First_Name__c = 'Testing3';
		controller.currLead.Parent_Last_Name__c = 'Testing3';
		controller.currLead.Street = 'Karur';
		controller.currLead.City = 'Karur';
		controller.currLead.State = 'Arizona';
		controller.currLead.PostalCode = '35004';
		controller.currLead.Email = 'mcavennila@gmail.com';
		controller.currLead.Phone = '8220708920';
		controller.currLead.What_is_the_family_s_primary_spoken_lang__c = 'English';
		controller.diagnosisFilter = 'c00';
		controller.selectedDiagnosis = 'Malignant Neoplasm';
		controller.currLead.Hospital_Treatment_Facility_Treating__c = 'Malignant Neoplasm';
		controller.currLead.Treating_Medical_Professional_First_Name__c = 'Treaing 1';
		controller.currLead.Treating_Medical_Professional_Last_Name__c = 'Treaing 1';
		controller.currLead.Treating_Medical_Professional_Phone__c = '8220708921';
		controller.currLead.Treating_Medical_Professional_Email__c = 'mcavennila@gmail.com';
		controller.currLead.Any_medical_reason_for_moving_quickly__c = 'yes';
		controller.diagnosisYear = '2000';
		controller.diagnosisMonth = '01';

		Test.startTest();
		controller.CreateLead();
		controller.copyReferralInfo();
		Test.stopTest();

		System.assertEquals(Constant_AC.LEAD_STATUS_REFERRED, controller.currLead.Status);
	}

	@isTest
	static void relationshipSelf3() {
		ICD_Codes__c icdCode = [
				SELECT Id, Name
				FROM ICD_Codes__c
				WHERE Name = 'c00'
		];

		PageReference pageRef = Page.WishReferralForm_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('isSuccess', 'Test');

		Lead dupeLead = new Lead();
		dupeLead.is_Family_Aware_of_Referral__c = 'Yes';
		dupeLead.PD_ICD_Code__c = icdCode.Id;
		dupeLead.Status = 'Referred';
		dupeLead.Diagnosis_Given_By_Referrer__c = 'Referrer';
		dupeLead.Hospital_Treatment_Facility__c = 'Treating Facility';
		dupeLead.Hospital_Treatment_Facility_Treating__c = 'Treating Facility';
		dupeLead.Treating_Medical_Professional_First_Name__c = 'Dr. Jack';
		dupeLead.Treating_Medical_Professional_Last_Name__c = 'Treating Professional';
		dupeLead.Treating_Medical_Professional_Phone__c = '8220708921';
		dupeLead.Treating_Medical_Professional_Email__c = 'jdoe@email.com';
		dupeLead.Gender__c = 'Male';
		dupeLead.Company = 'Test Company';

		WishReferralForm_AC controller = new WishReferralForm_AC();
		controller.currLead.Has_this_child_ever_received_prior_wish__c = 'Yes';
		controller.currLead.Has_this_child_ever_received_prior_wish__c = 'Yes';
		controller.currLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
		controller.currLead.Medical_Provider_Category__c = 'Physician';
		controller.currLead.Referrer_FirstName__c = 'Testing';
		controller.currLead.Referrer_Last_Name__c = 'Testing';
		controller.currLead.Referrer_Phone__c = '8220708920';
		controller.currLead.Referrer_Email__c = 'mcavennila@gmail.com';
		controller.currLead.Referrer_City__c = 'karur';
		controller.currLead.Referrer_Zip__c = '35004';
		controller.currLead.Relationship_to_child__c = 'Parent/Guardian';
		controller.currLead.is_Family_Aware_of_Referral__c = 'yes';
		controller.currLead.FirstName = dupeLead.FirstName = 'Testing1';
		controller.currLead.LastName = dupeLead.LastName = 'Testing2';
		controller.currLead.Child_Middle_Initial__c = 'Testing2';
		controller.currLead.Gender__c = 'Male';
		controller.currLead.Child_Age__c = '16';
		controller.currLead.DOB__c = dupeLead.DOB__c = Date.valueOf('2000-09-11');
		controller.currLead.Parent_First_Name__c = 'Testing3';
		controller.currLead.Parent_Last_Name__c = 'Testing3';
		controller.currLead.Street = dupeLead.Street = 'Karur';
		controller.currLead.City = dupeLead.City = 'Karur';
		controller.currLead.State = dupeLead.State = 'Arizona';
		controller.currLead.PostalCode = dupeLead.PostalCode = '35004';
		controller.currLead.Email = dupeLead.Email = 'mcavennila@gmail.com';
		controller.currLead.Phone = dupeLead.Phone = '8220708920';
		controller.currLead.What_is_the_family_s_primary_spoken_lang__c = 'English';
		controller.diagnosisFilter = icdCode.Name;
		controller.selectedDiagnosis = 'Malignant Neoplasm';
		controller.currLead.Hospital_Treatment_Facility_Treating__c = 'Malignant Neoplasm';
		controller.currLead.Treating_Medical_Professional_First_Name__c = 'Treaing 1';
		controller.currLead.Treating_Medical_Professional_Last_Name__c = 'Treaing 1';
		controller.currLead.Treating_Medical_Professional_Phone__c = '8220708921';
		controller.currLead.Treating_Medical_Professional_Email__c = 'mcavennila@gmail.com';
		controller.currLead.Any_medical_reason_for_moving_quickly__c = 'yes';

		Lead dupeLead2 = dupeLead.clone();
		dupeLead2.Status = 'Inquiry';
		Lead dupeLead3 = dupeLead.clone();
		dupeLead3.Status = 'Other';
		insert new List<Lead>{
				dupeLead, dupeLead2, dupeLead3
		};

		Test.startTest();
		controller.CreateLead();
		controller.copyReferralInfo();
		Test.stopTest();

		System.assertEquals(Constant_AC.LEAD_STATUS_REFERRED, controller.currLead.Status);
	}

    @isTest
    static void relationshipOther() {
        PageReference pageRef = Page.WishReferralForm_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
        
        WishReferralForm_AC controller = new WishReferralForm_AC();
        controller.currLead.Has_this_child_ever_received_prior_wish__c = 'Yes';
        controller.currLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        controller.currLead.Relationship_to_child__c = 'Other';
        controller.currLead.Referrer_Zip__c = '35004';
        
        Test.startTest();
        controller.CreateLead();
        Test.stopTest();
        
        System.assertEquals(Constant_AC.LEAD_STATUS_INQUIRY, controller.currLead.Status);
    }

	@isTest
	static void relationshipMedicalProfessional() {
		PageReference pageRef = Page.WishReferralForm_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('isSuccess', 'Test');

		WishReferralForm_AC controller = new WishReferralForm_AC();
		controller.getMedicalSpecialty();
		controller.getFilterStateOptions();
		controller.currLead.Has_this_child_ever_received_prior_wish__c = 'Yes';
		controller.currLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
		controller.currLead.Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
		controller.currLead.Medical_Provider_Category__c = 'Nurse Practitioner';
		controller.currLead.Referring_MP_First_Name__c = 'Jamie';
		controller.currLead.Referring_MP_Last_Name__c = 'Pepper';
		controller.currLead.Referrer_Email__c = 'jamie@pepper.com';
		controller.currLead.Referring_MP_City__c = 'Phoenix';

		Test.startTest();
		controller.CreateLead();
		Test.stopTest();

		System.assert(controller.currLead.Referrer_FirstName__c == controller.currLead.Referring_MP_First_Name__c);
		System.assert(controller.currLead.Referrer_Last_Name__c == controller.currLead.Referring_MP_Last_Name__c);
		System.assert(controller.currLead.Referrer_Email__c == controller.currLead.Referring_MP_Email__c);
	}

	@isTest
	static void medicalFirstNameblank() {
		PageReference pageRef = Page.WishReferralForm_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('isSuccess', 'Test');

		WishReferralForm_AC controller = new WishReferralForm_AC();
		controller.currLead.Has_this_child_ever_received_prior_wish__c = 'Yes';
		controller.currLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
		controller.currLead.Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
		controller.currLead.LastName = 'Pepper';
		controller.currLead.Medical_Professional_Last_Name__c = 'Pepper';
		controller.diagnosisYear = '2000';
		controller.diagnosisMonth = '01';

		Test.startTest();
		controller.CreateLead();
		Test.stopTest();

		System.assert(String.isEmpty(controller.currLead.Medical_Professional_First_Name__c));
		System.assert(String.isNotEmpty(controller.currLead.Medical_Professional_Last_Name__c));
	}

    @isTest
    static void relationshipFamily() {
        PageReference pageRef = Page.WishReferralForm_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
        
        WishReferralForm_AC controller = new WishReferralForm_AC();
        controller.currLead.Has_this_child_ever_received_prior_wish__c = 'Yes';
        controller.currLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
        controller.currLead.Relationship_to_child__c = 'Parent/Guardian';
        controller.currLead.LastName = 'Test';
        controller.currLead.DOB__c = Date.today() - 1050;
        controller.currLead.Child_Age__c = '16';
        controller.currLead.Referrer_Zip__c = '35004';
        
        Test.startTest();
        controller.CreateLead();
        Test.stopTest();
        
        System.assertEquals(Constant_AC.LEAD_STATUS_REFERRED, controller.currLead.Status);
    }

	@isTest
	static void relationshipSibling() {
		PageReference pageRef = Page.WishReferralForm_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('isSuccess', 'Test');

		WishReferralForm_AC controller = new WishReferralForm_AC();
		controller.currLead.Has_this_child_ever_received_prior_wish__c = 'Yes';
		controller.currLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
		controller.currLead.Relationship_to_child__c = 'Parent/Guardian';
		controller.currLead.LastName = 'Test';
		controller.currLead.DOB__c = Date.today() - 1050;
		controller.currLead.of_Siblings__c = '2';
		controller.getSiblingList();
		controller.CreateLead();
		controller.getStates();
		controller.copyReferrerInfo = true;
		controller.copyReferralInfo();
		controller.getRelationships();
		controller.getNoOfSiblings();
		WishReferralForm_AC.searchDiagnosis('c00');
		WishReferralForm_AC.searchCondition('Mali');
		WishReferralForm_AC.searchDiagnosis(null);
		WishReferralForm_AC.searchCondition(null);
		controller.currLead.is_Family_Aware_of_Referral__c = 'Yes';
		controller.displayChildForm();

		System.assert(controller.currLead.Sibling_Detail__c != null);
	}

	@isTest
	static void relationshipSibling2() {
		PageReference pageRef = Page.WishReferralForm_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('isSuccess', 'Test');

		WishReferralForm_AC controller = new WishReferralForm_AC();
		controller.currLead.Has_this_child_ever_received_prior_wish__c = 'Yes';
		controller.currLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
		controller.currLead.Relationship_to_child__c = 'Self';
		controller.currLead.LastName = 'Test';
		controller.currLead.DOB__c = Date.today() - 1050;
		controller.currLead.of_Siblings__c = '2';
		controller.getSiblingList();
		controller.CreateLead();
		controller.getStates();
		controller.copyReferrerInfo = true;
		controller.copyReferralInfo();
		controller.getRelationships();
		controller.getNoOfSiblings();
		WishReferralForm_AC.searchDiagnosis('c00');
		WishReferralForm_AC.searchCondition('Mali');
		WishReferralForm_AC.searchDiagnosis(null);
		WishReferralForm_AC.searchCondition(null);
		controller.currLead.is_Family_Aware_of_Referral__c = 'Yes';
		controller.displayChildForm();

		System.assert(controller.currLead.Sibling_Detail__c != null);
	}

	@isTest
	static void callMethods() {
		WishReferralForm_AC obj = new WishReferralForm_AC();
		obj.getNonMedicalReqFields();
		obj.getMedicalRequiredFields();
		obj.getSelfRequiredFields();
		obj.getRelationshipsToChild();
		obj.getHereAboutMAW();
		obj.getdiaYear();
		obj.getCommunication();
	}

	@isTest
	static void validateCopyLookupToTreatingMP() {
		Contact referrer = [
				SELECT Id
				FROM Contact
				WHERE FirstName = 'Testing1'
		];
		Account hospital = [
				SELECT Id
				FROM Account
				WHERE Name = 'Phoenix General Hospital'
		];

		PageReference pageRef = Page.WishReferralForm_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
		WishReferralForm_AC controller = new WishReferralForm_AC();
		controller.currLead.Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
		controller.copyReferrerInfo = true;
		controller.currLead.Referring_MP__c = referrer.Id;
		controller.currLead.Referring_MP_HTF__c = hospital.Id;
		Test.startTest();
		controller.CreateLead();
		Test.stopTest();

		System.assert(controller.currLead.Treating_MP__c == controller.currLead.Referring_MP__c);
		System.assert(controller.currLead.Treating_MP_HTF__c == controller.currLead.Referring_MP_HTF__c);
	}

	@isTest
	static void validateCopyLookupToBestMP() {
		Contact referrer = [
				SELECT Id
				FROM Contact
				WHERE FirstName = 'Testing1'
		];
		Account hospital = [
				SELECT Id
				FROM Account
				WHERE Name = 'Phoenix General Hospital'
		];

		PageReference pageRef = Page.WishReferralForm_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
		WishReferralForm_AC controller = new WishReferralForm_AC();
		controller.currLead.Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
		controller.copyReferrerInfoBest = true;
		controller.currLead.Referring_MP__c = referrer.Id;
		controller.currLead.Referring_MP_HTF__c = hospital.Id;
		Test.startTest();
		controller.CreateLead();
		Test.stopTest();

		System.assert(controller.currLead.Best_Contact__c == controller.currLead.Referring_MP__c);
		System.assert(controller.currLead.Best_Contact_HTF__c == controller.currLead.Referring_MP_HTF__c);
	}

	@isTest
	static void validateSearchAccountContactAffiliation() {
		Contact referrer = [
				SELECT Id
				FROM Contact
				WHERE FirstName = 'Testing1'
		];
		Account hospital = [
				SELECT Id
				FROM Account
				WHERE Name = 'Phoenix General Hospital'
		];
		Boolean affiliationNotExist;

		Test.startTest();
		PageReference pageRef = Page.WishReferralForm_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
		WishReferralForm_AC controller = new WishReferralForm_AC();
		controller.currLead.Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
		affiliationNotExist = WishReferralForm_AC.searchAccountContactAffiliation(referrer.Id, hospital.Id);
		Test.stopTest();

		System.assert(affiliationNotExist == true);
	}

	@isTest
	static void validateCheckEmptyContactFields() {
		Contact referrer = [
				SELECT Id
				FROM Contact
				WHERE FirstName = 'Testing1'
		];
		Boolean contactAllEmptyFields;

		Test.startTest();
		PageReference pageRef = Page.WishReferralForm_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
		WishReferralForm_AC controller = new WishReferralForm_AC();
		controller.currLead.Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
		contactAllEmptyFields = WishReferralForm_AC.checkEmptyContactFields(referrer.Id);
		Test.stopTest();

		System.assert(contactAllEmptyFields == true);
	}
    
    @isTest
    static void validateReferrerZipLength() {
        PageReference pageRef = Page.WishReferralForm_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
        
        WishReferralForm_AC controller = new WishReferralForm_AC();
        controller.currLead.Has_this_child_ever_received_prior_wish__c = 'No';
        controller.currLead.Any_medical_reason_for_moving_quickly__c = 'No';
        controller.currLead.Relationship_to_child__c = 'Parent/Guardian';
        controller.currLead.FirstName = 'Danielle';
        controller.currLead.LastName = 'Watkins';
        controller.currLead.DOB__c = Date.today() - 1050;
        controller.currLead.Child_Age__c = '16';
        controller.currLead.Referrer_Zip__c = '35004-1234';
        
        Test.startTest();
        controller.CreateLead();
        Test.stopTest();
        System.assert(controller.currLead.Referrer_Zip__c.length() == 5);
    }
    
    @isTest
    static void validateCopyReferrerToBestHTF() {
        Contact referrer = [
            SELECT Id
            FROM Contact
            WHERE FirstName = 'Testing1'
        ];
        
        PageReference pageRef = Page.WishReferralForm_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
        WishReferralForm_AC controller = new WishReferralForm_AC();
        controller.copyReferrerInfoBest = true;
        controller.currLead.Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
        controller.currLead.PostalCode = '35004';
        controller.currLead.Referring_MP__c = referrer.Id;
        controller.currLead.Referring_MP_HTF_Name__c = 'General Hospital';
        controller.currLead.Referring_MP_HTF_Street_Address__c = '500 Main Street';
        controller.currLead.Referring_MP_HTF_City__c = 'Phoenix';
        controller.currLead.Referring_MP_HTF_State__c = 'Arizona';
        controller.currLead.Referring_MP_HTF_Zip_Code__c = '85001';
        controller.currLead.Referring_MP_HTF_Phone__c = '(978) 979-8787';
        controller.currLead.Referring_MP_HTF_Department__c = 'General Pediatrics';
        
        Test.startTest();
        controller.createLead();
        Test.stopTest();
        System.assert(controller.currLead.Best_Contact_HTF_Name__c == controller.currLead.Referring_MP_HTF_Name__c);
    }
    
    @isTest
    static void validateCopyTreatingToBestHTF() {
        Contact bestMedicalContact = [
            SELECT Id
            FROM Contact
            WHERE FirstName = 'Testing1'
        ];
        
        PageReference pageRef = Page.WishReferralForm_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
        WishReferralForm_AC controller = new WishReferralForm_AC();
        controller.copyReferrerInfoBest = false;
        controller.currLead.Relationship_to_child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
        controller.currLead.PostalCode = '35004';
        controller.currLead.Best_Contact__c = bestMedicalContact.Id;
        controller.currLead.Hospital_Treatment_Facility_Treating__c = 'General Hospital';
        controller.currLead.Treating_MP_HTF_Street_Address__c = '500 Main Street';
        controller.currLead.Treating_MP_HTF_City__c = 'Phoenix';
        controller.currLead.Treating_MP_HTF_State__c = 'Arizona';
        controller.currLead.Treating_MP_HTF_Zip_Code__c = '85001';
        controller.currLead.Treating_MP_HTF_Phone__c = '(978) 979-8787';
        controller.currLead.Treating_MP_HTF_Department__c = 'General Pediatrics';
        
        Test.startTest();
        controller.createLead();
        Test.stopTest();
        System.assert(controller.currLead.Best_Contact_HTF_Name__c == controller.currLead.Hospital_Treatment_Facility_Treating__c);
    }
}