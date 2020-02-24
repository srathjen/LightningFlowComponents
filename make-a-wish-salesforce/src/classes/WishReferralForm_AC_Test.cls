@isTest
public class WishReferralForm_AC_Test {

	public static testMethod void relationshipNone() {
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

		controller.getlanguage();
		controller.getdiaYear();
		controller.getNoOfSiblings();
		controller.getSelfRequiredFields();
		controller.getNonMedicalReqFields();
		controller.getMedicalRequiredFields();

		WishReferralForm_AC.siblingWrapper sw = new WishReferralForm_AC.siblingWrapper();
		String fname = sw.fname;
		String lname = sw.lname;
		String age = sw.age;
	}

	public static testMethod void relationshipSelf() {
		Account chapterAccount = OrientationandTrainingUtil.CreateAmericaAccount();
		chapterAccount.Intake_Manager__c = UserInfo.getUserId();
		insert chapterAccount;

		PageReference pageRef = Page.WishReferralForm_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
		WishReferralForm_AC controller = new WishReferralForm_AC();
		controller.currLead.Has_this_child_ever_received_prior_wish__c = 'Yes';
		controller.currLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
		controller.currLead.Relationship_To_Child__c = 'Self';
		controller.CreateLead();
		controller.CopyReferralInfo();
		controller.currLead.Child_Age__c = '5';

	}

	public static testMethod void relationshipSelf1() {
		PageReference pageRef = Page.WishReferralForm_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('isSuccess', 'Test');

		Account chapterAccount = OrientationandTrainingUtil.CreateAmericaAccount();
		chapterAccount.Intake_Manager__c = UserInfo.getUserId();
		insert chapterAccount;

		Office__c office = OrientationandTrainingUtil.createOffice(chapterAccount.Id);
		insert office;

		Zip_Code__c zipCode = new Zip_Code__c();
		zipCode.Name = '90210';
		zipCode.External_Id__c = '1234567890';
		zipCode.Office__c = office.Id;
		insert zipCode;

		WishReferralForm_AC controller = new WishReferralForm_AC();
		controller.currLead.Has_this_child_ever_received_prior_wish__c = 'Yes';
		controller.currLead.Has_this_child_ever_received_prior_wish__c = 'Yes';
		controller.currLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
		controller.currLead.Relationship_To_Child__c = 'Self';
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
		controller.currLead.state = 'Arizona';
		controller.currLead.PostalCode = zipCode.Name;
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
		controller.CreateLead();
		controller.CopyReferralInfo();

	}

	public static testMethod void relationshipSelf2() {
		PageReference pageRef = Page.WishReferralForm_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
		Contact con = WishReferralForm_AC_Test.createContact();
		WishReferralForm_AC controller = new WishReferralForm_AC();
		controller.currLead.Has_this_child_ever_received_prior_wish__c = 'Yes';
		controller.currLead.Has_this_child_ever_received_prior_wish__c = 'Yes';
		controller.currLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
		controller.currLead.Medical_Provider_Category__c = 'Physician';
		controller.currLead.Relationship_To_Child__c = 'Self';
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
		controller.currLead.state = 'Arizona';
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
		controller.CreateLead();
		controller.CopyReferralInfo();
	}

	public static testMethod void relationshipSelf3() {
		PageReference pageRef = Page.WishReferralForm_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
		Contact con = WishReferralForm_AC_Test.createContact();

		ICD_Codes__c icdCode = new ICD_Codes__c();
		icdCode.Name = 'c00';
		insert icdCode;

		Lead dupeLead = new Lead();
		dupeLead.is_Family_Aware_of_Referral__c = 'Yes';
		dupeLead.PD_ICD_Code__c = icdCode.Id;
		dupeLead.Status = 'Referred';
		dupeLead.Diagnosis_Given_By_Referrer__c = 'Referrer';
		dupeLead.Hospital_Treatment_Facility__c = 'Treating Facility';
		dupeLead.Hospital_Treatment_Facility_Treating__c = 'Treating Facility';
		dupeLead.Treating_Medical_Professional_Last_Name__c = 'Treating Professional';
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
		controller.currLead.Relationship_To_Child__c = 'Parent/Guardian';
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
		controller.currLead.state = dupeLead.State = 'Arizona';
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
		controller.CreateLead();
		controller.CopyReferralInfo();
	}

	public static testMethod void relationshipOther() {
		PageReference pageRef = Page.WishReferralForm_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
		WishReferralForm_AC controller = new WishReferralForm_AC();
		controller.currLead.Has_this_child_ever_received_prior_wish__c = 'Yes';
		controller.currLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
		controller.currLead.Relationship_To_Child__c = 'Other';
		controller.CreateLead();

	}

	public static testMethod void relationshipMedicalProfessional() {
		PageReference pageRef = Page.WishReferralForm_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
		WishReferralForm_AC controller = new WishReferralForm_AC();
		controller.currLead.Has_this_child_ever_received_prior_wish__c = 'Yes';
		controller.currLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
		controller.currLead.Relationship_To_Child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
		controller.currLead.Medical_Provider_Category__c = 'Nurse Practitioner';
		controller.CreateLead();
	}

	public static testMethod void medicalFirstNameblank() {
		PageReference pageRef = Page.WishReferralForm_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
		WishReferralForm_AC controller = new WishReferralForm_AC();
		controller.currLead.Has_this_child_ever_received_prior_wish__c = 'Yes';
		controller.currLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
		controller.currLead.Relationship_To_Child__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
		controller.currLead.LastName = 'Test';
		controller.diagnosisYear = '2000';
		controller.diagnosisMonth = '01';
		controller.CreateLead();
	}

	public static testMethod void relationshipFamily() {
		PageReference pageRef = Page.WishReferralForm_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
		WishReferralForm_AC controller = new WishReferralForm_AC();
		controller.currLead.Has_this_child_ever_received_prior_wish__c = 'Yes';
		controller.currLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
		controller.currLead.Relationship_To_Child__c = 'Parent/Guardian';
		controller.currLead.LastName = 'Test';
		controller.currLead.DOB__c = Date.Today() - 1050;
		controller.currlead.Child_Age__c = '16';
		controller.CreateLead();
	}

	public static testMethod void relationshipSibling() {
		PageReference pageRef = Page.WishReferralForm_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
		WishReferralForm_AC controller = new WishReferralForm_AC();
		controller.currLead.Has_this_child_ever_received_prior_wish__c = 'Yes';
		controller.currLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
		controller.currLead.Relationship_To_Child__c = 'Parent/Guardian';
		controller.currLead.LastName = 'Test';
		controller.currLead.DOB__c = Date.Today() - 1050;
		controller.currlead.Of_Siblings__c = '2';
		controller.getSiblingList();
		controller.CreateLead();
		controller.getStates();
		controller.copyReferrerInfo = True;
		controller.CopyReferralInfo();
		controller.getRelationships();
		controller.getNoOfSiblings();
		WishReferralForm_AC.searchDiagnosis('c00');
		WishReferralForm_AC.searchCondition('Mali');
		WishReferralForm_AC.searchDiagnosis(NULL);
		WishReferralForm_AC.searchCondition(NULL);
		controller.currLead.is_Family_Aware_of_Referral__c = 'Yes';
		controller.disPlayChildForm();
	}

	public static testMethod void relationshipSibling2() {
		PageReference pageRef = Page.WishReferralForm_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('isSuccess', 'Test');
		WishReferralForm_AC controller = new WishReferralForm_AC();
		controller.currLead.Has_this_child_ever_received_prior_wish__c = 'Yes';
		controller.currLead.Any_medical_reason_for_moving_quickly__c = 'Yes';
		controller.currLead.Relationship_To_Child__c = 'Self';
		controller.currLead.LastName = 'Test';
		controller.currLead.DOB__c = Date.Today() - 1050;
		controller.currlead.Of_Siblings__c = '2';
		controller.getSiblingList();
		controller.CreateLead();
		controller.getStates();
		controller.copyReferrerInfo = True;
		controller.CopyReferralInfo();
		controller.getRelationships();
		controller.getNoOfSiblings();
		WishReferralForm_AC.searchDiagnosis('c00');
		WishReferralForm_AC.searchCondition('Mali');
		WishReferralForm_AC.searchDiagnosis(NULL);
		WishReferralForm_AC.searchCondition(NULL);
		controller.currLead.is_Family_Aware_of_Referral__c = 'Yes';
		controller.disPlayChildForm();
	}

	public static testmethod void callmethods() {
		WishReferralForm_AC obj = new WishReferralForm_AC();
		obj.getNonMedicalReqFields();
		obj.getMedicalRequiredFields();
		obj.getSelfRequiredFields();
		obj.getRelationshipsToChild();
		obj.getHereAboutMAW();
		obj.getdiaYear();
		obj.getCommunication();
	}

	static contact createContact() {
		Contact currCon = new Contact();
		currcon.FirstName = 'Testing1';
		currcon.lastName = 'Testing2';
		currCon.Birthdate = Date.valueOf('2000-09-11');
		currCon.Phone = '8220708920';
		currCon.Email = 'mcavennila@gmail.com';
		currCon.Diagnosis__c = 'Test';
		insert currCon;
		return currCon;
	}
}