/*****************************************************************************************************************
Author      : MST Solutions

Modification Log
1. WVC-2205 - Kanagaraj - 08/08/2018 // line 1580,1594 previously the affilliation status was "Prospective" Now
We have updated as "Pending"
2. 09/10/2019 - Manik - WLP-423
*******************************************************************************************************************/
@IsTest
public class OrientationandTrainingUtil {
	private final static Id chapterRecordTypeId = Constant_AC.CHAPTER_RT_ID;
	private final static Id householdRecordTypeId = Constant_AC.HOUSEHOLD_RT_ID;
	private final static Id inKindDonorsAccountRecordTypeId = Constant_AC.IN_KIND_ACCOUNT_ID;
	private final static Id hospitalTreatmentRecordTypeId = Constant_AC.HOSPITAL_TREATMENT_ID;
	private final static Id volunteerRecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
	private final static String medicalProfessionalRecordTypeLabel = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
	private final static Id medicalProfessionalRecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
	private final static Id wishFamilyRecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
	private final static Id diagnosisVerificationRecordTypeId = Constant_AC.DIAGNOSIS_RT_ID;
	private final static Id wishRecordTypeId = Constant_AC.WISH_RT_ID;
	private final static Id wishChildRecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
	private final static Id volunteerTrainingRecordTypeId = Constant_AC.TRAINING_RT_ID;
	private final static Id volunteerOrientationRecordTypeId = Constant_AC.ORIENTATION_RT_ID;
	private final static Id classOfferingRecordTypeId = Constant_AC.CLASS_OFFERING_RECORD_TYPE_ID;
	private final static Id activeRecordTypeId = Constant_AC.ACTIVE_VOL_RT_ID;
	private final static Id nationalRecordTypeId = Constant_AC.NATIONAL_RT_ID;
	private final static Id prospectiveVolunteerRecordTypeId = Constant_AC.PROSPECTIVE_VOLUNTEER_RT_ID;
	private final static Id wishVolunteerOpportunityRecordTypeId = Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID;
	private final static Id nonWishRecordTypeId = Constant_AC.NON_WISH_EVENT_RT_ID;
	private final static Id eventsRecordTypeId = Constant_AC.EVENTS_ID;
	private final static Id algorithmRecordTypeId = Constant_AC.TRAVEL_ALGM_RT_ID;
	private final static Id inKindRecordTypeId = Constant_AC.IN_KIND_ID;
	private final static Id reimbursementRecordTypeId = Constant_AC.REIMBURSEMENT_ID;
	private final static String boardMemberRecordTypeLabel = Constant_AC.BOARD_MEMBER_RT_LABEL;

	public static Account createchapterAccount() {
		Account newchapterAccount = new Account();
		newchapterAccount .Name = 'Make-A-Wish Alabama';
		newchapterAccount.RecordTypeId = chapterRecordTypeId;
		newchapterAccount.MAC_Email_del__c = 'Test@gmail.com';
		newchapterAccount.Wish_Co_ordinator__c = createUser().Id;
		return newchapterAccount;
	}

	public static Account HouseHoldAccount() {
		Account houseHoldAccount = new Account();
		houseHoldAccount.Name = 'TestHouseHoldAccount';
		houseHoldAccount.RecordTypeId = householdRecordTypeId;
		houseHoldAccount.Emergency_Contact_Phone__c = '9988998899';
		return houseHoldAccount;
	}

	public static Account CreateAlabamaAccount() {
		Account newchapterAccount = new Account();
		newchapterAccount.Name = 'Make-A-Wish Alabama';
		newchapterAccount.RecordTypeId = chapterRecordTypeId;
		newchapterAccount.Alert_for_Unassigned_Wishes__c = 1;
		return newchapterAccount;
	}

	public static account CreateAmericaAccount() {
		Account newchapterAccount = new Account();
		newchapterAccount.Name = 'Make-A-Wish America';
		newchapterAccount.RecordTypeId = chapterRecordTypeId;
		newchapterAccount.Wish_Co_ordinator__c = Userinfo.getUserId();
		return newchapterAccount;
	}

	public static Account inKindAccount() {
		Account newchapterAccount = new Account();
		newchapterAccount .Name = 'InKind Account';
		newchapterAccount.RecordTypeId = inKindDonorsAccountRecordTypeId;
		return newchapterAccount;
	}

	public static Account inKindAccountWithStatus() {
		Account newchapterAccount = new Account();
		newchapterAccount.Name = 'InKind Account';
		newchapterAccount.RecordTypeId = inKindDonorsAccountRecordTypeId;
		newchapterAccount.Chapter_Name__c = createchapterAccount().id;
		return newchapterAccount;
	}

	public static Account inKindAccountWithSChpater(Id chapterAccountId) {
		Account newchapterAccount = new Account();
		newchapterAccount.Name = 'InKind Account';
		newchapterAccount.RecordTypeId = inKindDonorsAccountRecordTypeId;
		newchapterAccount.Chapter_Name__c = chapterAccountId;
		return newchapterAccount;
	}

	public static Account createVolunteerAccount() {
		User currUser = Utils.currentUser;
		Account newAccount = new Account();
		newAccount.Name = 'Make-A-Wish Alabama';
		newAccount.RecordTypeId = chapterRecordTypeId;
		newAccount.Volunteer_Manager__c = currUser.Id;
		newAccount.Alert_for_Unassigned_Wishes__c = 1;
		return newAccount;
	}

	public static Account createVolunteerAccountwithVolunteerManager() {
		Account newAccount = new Account();
		newAccount.Name = 'Make-A-Wish Alabama';
		newAccount.RecordTypeId = chapterRecordTypeId;
		newAccount.Volunteer_Manager__c = createUser().Id;
		return newAccount;
	}

	public static Account createVolunteerAccountWithWishCoordinatior(Id wishCoordinator) {
		Account newAccount = new Account();
		newAccount.Name = 'Make-A-Wish Alabama';
		newAccount.RecordTypeId = chapterRecordTypeId;
		newAccount.Wish_Co_ordinator__c = wishCoordinator;
		newAccount.DevStaffEmail__c = 'chandrasekar@mstsolutions.com';
		return newAccount;

	}

	public static Account AlabamaAccount() {
		Account newchapterAccount = new Account();
		newchapterAccount .Name = 'Make-A-Wish Alabama';
		newchapterAccount.RecordTypeId = chapterRecordTypeId;
		return newchapterAccount;
	}

	public static Account MakeAWishAmericaAcc() {
		Account newchapterAccount = new Account();
		newchapterAccount .Name = 'Make-A-Wish America';
		newchapterAccount.RecordTypeId = chapterRecordTypeId;
		newchapterAccount.MAC_Email_del__c = 'testMAC@gmail.com';
		return newchapterAccount;
	}

	public static Account HospitalTreatment() {
		Account newchapterAccount = new Account();
		newchapterAccount .Name = 'Make-A-Wish America';
		newchapterAccount.RecordTypeId = hospitalTreatmentRecordTypeId;
		newchapterAccount.MAC_Email_del__c = 'testMAC@gmail.com';
		return newchapterAccount;
	}

	public static Contact createVolunteerContact(Id AccountId) {
		Contact newContact = new Contact();
		newContact.FirstName = 'moss';
		newContact.LastName = 'Smith';
		newContact.Birthdate = System.today() - 1;
		newContact.Parent_Guardian_Name__c = 'Steve Smith';
		newContact.RecordTypeId = volunteerRecordTypeId;
		newContact.Title = 'Mr';
		newContact.Birth_Month__c = 'January';
		newContact.Birth_Day__c = '12';
		newContact.Birth_Year__c = '1985';
		newContact.Alternate_Phone_Type__c = 'Home';
		newContact.npe01__PreferredPhone__c = 'Mobile';
		newContact.OtherPhone = '3332211144';
		newContact.HomePhone = '9003910426';
		newContact.MobilePhone = '9003910426';
		newContact.I_m_on_LinkedIn__c = 'Yes';
		newContact.How_did_you_hear_about_Make_A_Wish__c = 'Family';
		newContact.MailingPostalCode = '94105-5188';
		newContact.MailingStreet = 'One Market Street';
		newContact.MailingCountry = 'United States';
		newContact.MailingState = 'Texas';
		newContact.MailingCity = 'San Francisco';
		newContact.MailingLatitude = -24.355798;
		newContact.MailingLongitude = 69.830469;
		newContact.Emergency_Contact__c = 'Test';
		newContact.Emergency_Contact_Relationship__c = 'Father';
		newContact.Emergency_Contact_Phone__c = '9003910426';
		newContact.Read__c = 'English';
		newContact.language__c = 'English';
		newContact.speak__c = 'English';
		newContact.understand__c = 'English';
		newContact.Professional_Skills__c = 'Photography';
		newContact.Language_Notes__c = 'Test';
		newContact.Volunteer_Role__c = 'Special Events';
		newContact.is_Application__c = 'Partial Submit';
		newContact.AccountId = AccountId;
		newContact.Volunteer_Role__c = 'Water Handler';
		newContact.npe01__Preferred_Email__c = 'test@gmail.com';
		newContact.Email = 'test@gmail.com';
		return newContact;
	}

	public static Contact createVolunteerContactwithOtherPhone(Id AccountId) {
		Contact newContact = new Contact();
		newContact.FirstName = 'moss';
		newContact.LastName = 'Smith';
		newContact.Birthdate = System.today() - 1;
		newContact.Parent_Guardian_Name__c = 'Steve Smith';
		newContact.RecordTypeId = volunteerRecordTypeId;
		newContact.Title = 'Mr';
		newContact.Birth_Month__c = 'January';
		newContact.Birth_Day__c = '12';
		newContact.Birth_Year__c = '1985';
		newContact.Alternate_Phone_Type__c = 'Mobile';
		newContact.npe01__PreferredPhone__c = 'Home';
		newContact.OtherPhone = '3332211144';
		newContact.HomePhone = '9003910426';
		newContact.MobilePhone = '9003910426';
		newContact.I_m_on_LinkedIn__c = 'Yes';
		newContact.How_did_you_hear_about_Make_A_Wish__c = 'Family';
		newContact.MailingStreet = 'ThillaiNagar';
		newContact.MailingCity = 'Trichy';
		newContact.MailingCountrycode = 'US';
		newContact.MailingPostalCode = '621010';
		newContact.mailingstatecode = 'AZ';
		newContact.Emergency_Contact__c = 'Test';
		newContact.Emergency_Contact_Relationship__c = 'Father';
		newContact.Emergency_Contact_Phone__c = '9003910426';
		newContact.Read__c = 'English';
		newContact.language__c = 'English';
		newContact.speak__c = 'English';
		newContact.understand__c = 'English';
		newContact.Professional_Skills__c = 'Photography';
		newContact.Language_Notes__c = 'Test';
		newContact.Volunteer_Role__c = 'Special Events';
		newContact.is_Application__c = 'Partial Submit';
		newContact.AccountId = AccountId;
		newContact.Volunteer_Role__c = 'Water Handler';
		return newContact;
	}

	public static Contact VolunteerContactwithHomePhone(Id AccountId) {
		Contact newContact = new Contact();
		newContact.FirstName = 'moss';
		newContact.LastName = 'Smith';
		newContact.Birthdate = System.today() - 1;
		newContact.Parent_Guardian_Name__c = 'Steve Smith';
		newContact.RecordTypeId = volunteerRecordTypeId;
		newContact.Title = 'Mr';
		newContact.Birth_Month__c = 'January';
		newContact.Birth_Day__c = '12';
		newContact.Birth_Year__c = '1985';
		newContact.Alternate_Phone_Type__c = 'Home';
		newContact.npe01__PreferredPhone__c = 'Home';
		newContact.HomePhone = '9003910426';
		newContact.otherPhone = '9003910426';
		newContact.I_m_on_LinkedIn__c = 'Yes';
		newContact.How_did_you_hear_about_Make_A_Wish__c = 'Family';
		newContact.MailingStreet = 'ThillaiNagar';
		newContact.MailingCity = 'Trichy';
		newContact.MailingCountrycode = 'US';
		newContact.MailingPostalCode = '621010';
		newContact.mailingstatecode = 'AZ';
		newContact.Emergency_Contact__c = 'Test';
		newContact.Emergency_Contact_Relationship__c = 'Father';
		newContact.Emergency_Contact_Phone__c = '9003910426';
		newContact.Read__c = 'English';
		newContact.language__c = 'English';
		newContact.speak__c = 'English';
		newContact.understand__c = 'English';
		newContact.Professional_Skills__c = 'Photography';
		newContact.Language_Notes__c = 'Test';
		newContact.Volunteer_Role__c = 'Special Events';
		newContact.is_Application__c = 'Partial Submit';
		newContact.AccountId = AccountId;
		newContact.Volunteer_Role__c = 'Water Handler';
		return newContact;
	}

	public static Contact VolunteerContactwithMobilePhone(Id AccountId) {
		Contact newContact = new Contact();
		newContact.FirstName = 'moss';
		newContact.LastName = 'Smith';
		newContact.Birthdate = System.today() - 1;
		newContact.Parent_Guardian_Name__c = 'Steve Smith';
		newContact.RecordTypeId = volunteerRecordTypeId;
		newContact.Title = 'Mr';
		newContact.Birth_Month__c = 'January';
		newContact.Birth_Day__c = '12';
		newContact.Birth_Year__c = '1985';
		newContact.Alternate_Phone_Type__c = 'Mobile';
		newContact.npe01__PreferredPhone__c = 'Mobile';
		newContact.MobilePhone = '9003910426';
		newContact.otherPhone = '9003910426';
		newContact.I_m_on_LinkedIn__c = 'Yes';
		newContact.How_did_you_hear_about_Make_A_Wish__c = 'Family';
		newContact.MailingStreet = 'ThillaiNagar';
		newContact.MailingCity = 'Trichy';
		newContact.MailingCountrycode = 'US';
		newContact.MailingPostalCode = '621010';
		newContact.mailingstatecode = 'AZ';
		newContact.Emergency_Contact__c = 'Test';
		newContact.Emergency_Contact_Relationship__c = 'Father';
		newContact.Emergency_Contact_Phone__c = '9003910426';
		newContact.Read__c = 'English';
		newContact.language__c = 'English';
		newContact.speak__c = 'English';
		newContact.understand__c = 'English';
		newContact.Professional_Skills__c = 'Photography';
		newContact.Language_Notes__c = 'Test';
		newContact.Volunteer_Role__c = 'Special Events';
		newContact.is_Application__c = 'Partial Submit';
		newContact.AccountId = AccountId;
		newContact.Volunteer_Role__c = 'Water Handler';
		return newContact;
	}

	public static Contact CreateWishChild() {
		ICD_Codes__c obj = new ICD_Codes__c();
		obj.Name = 'Q917';
		insert obj;
		Contact newWishChild = new Contact();
		newWishChild.FirstName = 'Steven';
		newWishChild.LastName = 'Smith';
		newWishChild.Parent_Guardian_Name__c = 'Jonathan Edwards';
		newWishChild.RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
		newWishChild.ICD_10_Code__c = obj.Id;
		newWishChild.Birthdate = Date.today().addDays(+21);
		newWishChild.Birthdate = newWishChild.Birthdate.addYears(-3);
		newWishChild.MailingPostalCode = '94105-5188';
		newWishChild.MailingStreet = '7540 E Gold Dust Ave';
		newWishChild.MailingCountry = 'United States';
		newWishChild.MailingState = 'Arizona';
		newWishChild.MailingCity = 'Scottsdale';
		newWishChild.MailingLatitude = -24.355798;
		newWishChild.MailingLongitude = 69.830469;
		return newWishChild;
	}

	public static contact CreateTreatingMedicalProfContact() {
		Contact treatingProfContact = new Contact();
		treatingProfContact.FirstName = 'Steveone';
		treatingProfContact.LastName = 'Waughone';
		treatingProfContact.Email = 'testmawa2@gmail.com';
		treatingProfContact.Phone = '9600467554';
		treatingProfContact.MailingStreet = 'KuttaiKarai Street';
		treatingProfContact.MailingCity = 'Trichy';
		treatingProfContact.MailingStateCode = 'AZ';
		treatingProfContact.MailingPostalCode = '6201717';
		treatingProfContact.Provider_Type__c = 'Nurse Practitioner';
		treatingProfContact.MailingCountryCode = 'US';
		treatingProfContact.RecordTypeId = medicalProfessionalRecordTypeId;
		return treatingProfContact;
	}

	public static contact CreateMedicalProfContact() {
		Contact medicalProfContact = new Contact();
		medicalProfContact .FirstName = 'mosstest';
		medicalProfContact .LastName = 'harttest';
		medicalProfContact .Email = 'testmawa1@gmail.com';
		medicalProfContact .Phone = '9600467554';
		medicalProfContact .MailingStreet = 'KuttaiKarai Street';
		medicalProfContact .MailingCity = 'Trichy';
		medicalProfContact .MailingStateCode = 'AZ';
		medicalProfContact .MailingPostalCode = '6201717';
		medicalProfContact .MailingCountryCode = 'US';
		medicalProfContact .RecordTypeId = medicalProfessionalRecordTypeId;
		return medicalProfContact;
	}

	public static contact CreateWishFamily() {
		Contact wishFamilyCon = new Contact();
		wishFamilyCon.FirstName = 'MAWAFirstName';
		wishFamilyCon.LastName = 'MAWALastName';
		wishFamilyCon.Email = 'testmawa@gmail.com';
		wishFamilyCon.Phone = '9600467559';
		wishFamilyCon.MailingStreet = 'KuttaiKarai Street';
		wishFamilyCon.MailingCity = 'Trichy';
		wishFamilyCon.MailingStateCode = 'AZ';
		wishFamilyCon.MailingPostalCode = '6201717';
		wishFamilyCon.MailingCountryCode = 'US';
		wishFamilyCon.RecordTypeId = wishFamilyRecordTypeId ;
		wishFamilyCon.IsParentGuardian__c = 'ParentGuardian';
		wishFamilyCon.BirthDate = system.Today() + 11234;
		wishFamilyCon.Region_Chapter__c = createchapterAccount().id;
		return wishFamilyCon ;
	}

	public static contact CreateWishFamilyForRelationship() {
		Contact wishFamilyCon = new Contact();
		wishFamilyCon.FirstName = 'MAWAFirstName';
		wishFamilyCon.LastName = 'MAWALastName';
		wishFamilyCon.Email = 'testmawa@gmail.com';
		wishFamilyCon.Phone = '9600467559';
		wishFamilyCon.MailingStreet = 'KuttaiKarai Street';
		wishFamilyCon.MailingCity = 'Trichy';
		wishFamilyCon.MailingStateCode = 'AZ';
		wishFamilyCon.MailingPostalCode = '6201717';
		wishFamilyCon.MailingCountryCode = 'US';
		wishFamilyCon.RecordTypeId = wishFamilyRecordTypeId ;
		wishFamilyCon.Region_Chapter__c = createchapterAccount().id;
		return wishFamilyCon ;
	}

	public static contact CreateWishChildCon() {
		Contact wishChildCon = new Contact();
		wishChildCon.Region_Chapter__c = createchapterAccount().id;
		wishChildCon.FirstName = 'moss';
		wishChildCon.LastName = 'Smith Household';
		wishChildCon.Email = 'testmawa@gmail.com';
		wishChildCon.Phone = '9600467559';
		wishChildCon.OtherPhone = '8056913402';
		wishChildCon.MobilePhone = '9003910426';
		wishChildCon.MailingStreet = 'East Street';
		wishChildCon.MailingCity = 'Trichy';
		wishChildCon.MailingState = 'Arizona';
		wishChildCon.MailingStateCode = 'AZ';
		wishChildCon.MailingPostalCode = '85251';
		wishChildCon.MailingCountryCode = 'US';
		wishChildCon.RecordTypeId = wishChildRecordTypeId;
		wishChildCon.MobilePhone = '9900220022';
		wishChildCon.Primary_Diagnosis_Condition_Description__c = 'Test';
		wishChildCon.Diagnosis__c = 'test';
		return wishChildCon;
	}

	public static Contact CreateWishChildwithAcc(Id accId) {
		ICD_Codes__c obj = new ICD_Codes__c();
		obj.Name = 'Q917';
		insert obj;
		Contact newWishChild = new Contact();
		newWishChild.FirstName = 'Steven';
		newWishChild.LastName = 'Smith';
		newWishChild.Parent_Guardian_Name__c = 'Jonathan Edwards';
		newWishChild.RecordTypeId = wishChildRecordTypeId ;
		newWishChild.Diagnosis__c = 'Test';
		newWishChild.ICD_10_Code__c = obj.id;
		newWishChild.AccountId = accId;
		return newWishChild;
	}

	public static contact CreateWishFamilyparticipant() {
		Contact wishFamilyCon = new Contact();
		wishFamilyCon.FirstName = 'MAWAFirstNameOne';
		wishFamilyCon.LastName = 'MAWALastNameOne';
		wishFamilyCon.Email = 'kanagumca_jcet@hotmail.com';
		wishFamilyCon.Phone = '9600467559';
		wishFamilyCon.MailingStreet = 'KuttaiKarai Street';
		wishFamilyCon.MailingCity = 'Trichy';
		wishFamilyCon.MailingStateCode = 'AZ';
		wishFamilyCon.MailingPostalCode = '6201717';
		wishFamilyCon.MailingCountryCode = 'US';
		wishFamilyCon.BirthDate = system.Today() + 11234;
		wishFamilyCon.RecordTypeId = wishFamilyRecordTypeId ;
		wishFamilyCon.Region_Chapter__c = createchapterAccount().id;
		return wishFamilyCon ;
	}

	public static Lead createTestLeadRec(Id chapterAccountId) {
		Lead newLead = new Lead();
		newLead.FirstName = 'moss';
		newLead.LastName = 'Smith Household';
		newLead.Phone = '9600467559';
		newLead.Email = 'testmawa@gmail.com';
		newLead.Street = 'KuttaiKarai Street';
		newLead.StateCode = 'AZ';
		newLead.city = 'Trichy';
		newLead.Postalcode = '6201717';
		newLead.CountryCode = 'US';
		newLead.DOB__c = System.today() - 1435;
		newLead.company = 'MAWA';
		newLead.Status = 'Inquiry';
		newLead.Gender__c = 'Male';
		newLead.ChapterName__c = chapterAccountId;
		newLead.Referrer_FirstName__c = 'Sudhar';
		newLead.Referrer_Last_Name__c = 'test';
		newLead.Referrer_Email__c = 'sudhar1@gmail.com';
		newLead.Referrer_Phone__c = '0600467559';
		newLead.Referrer_City__c = 'Trichy';
		newLead.Referrer_Zip__c = '6210';
		newLead.Sibling_Detail__c = 'aa | aaab | 14 bbb | bbbc | 15';
		newLead.PD_Condition_Description__c = 'Test Diagnosis';
		newLead.Parent_First_Name__c = 'MAWAFirstJune';
		newLead.Parent_Last_Name__c = 'MAWALastJune';
		newLead.Medical_Professional_First_Name__c = 'mossJune';
		newLead.Medical_Professional_Last_Name__c = 'hartJune';
		newLead.Medical_Professional_Phone__c = '9600467559';
		newLead.Medical_Professional_Email__c = 'testmawa1s@gmail.com';
		newLead.Hospital_Treatment_Facility__c = 'Moss Hart AC';
		newLead.Treating_Medical_Professional_First_Name__c = 'SteveJune';
		newLead.Treating_Medical_Professional_Last_Name__c = 'Waughone';
		newLead.Treating_Medical_Professional_Phone__c = '9600467578';
		newLead.Treating_Medical_Professional_Email__c = 'testmawa2d@gmail.com';
		newLead.Hospital_Treatment_Facility_Treating__c = 'Steve Smith AC';
		newLead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
		newLead.is_Family_Aware_of_Referral__c = 'Yes';
		newLead.Medical_Questions__c = 'Test Diagnosis';
		ICD_Codes__c obj = new ICD_Codes__c();
		obj.Name = 'C120';
		insert obj;
		newLead.PD_ICD_Code__c = obj.id;
		newLead.Lung_Disease__c = 'Test1;Test2';
		newLead.Angina__c = 'Test1;Test2';
		newLead.Ventilator__c = 'Test1;Test2';
		newLead.Arrhythmia__c = 'Test1;Test2';
		newLead.Heart_Failure__c = 'Test1;Test2';
		newLead.Congenital_Heart_Disease__c = 'Test1;Test2';
		newLead.Chronic_Hepatitis__c = 'Test1;Test2';
		newLead.Convulsive_Disorders__c = 'Test1;Test2';
		newLead.Pulmonary_Hypertension__c = 'Test1;Test2';
		newLead.Strokes__c = 'Test1;Test2';
		newLead.Chronic_Heart_Failure__c = 'Test1;Test2';
		newLead.isSign__c = true;
		//newLead.Communication__c = 'Non-Verbal';
		newLead.Travel_algorithm__c = 'Test1;Test2;';
		return newLead;
	}

	public static Lead createSameMedicalLead(Id chapterAccountId) {
		Lead newLead = new Lead();
		newLead.FirstName = 'moss';
		newLead.LastName = 'Smith Household';
		newLead.Phone = '9600467559';
		newLead.Email = 'testmawa@gmail.com';
		newLead.Street = 'KuttaiKarai Street';
		newLead.StateCode = 'AZ';
		newLead.city = 'Trichy';
		newLead.Postalcode = '6201717';
		newLead.CountryCode = 'US';
		newLead.DOB__c = System.today() - 1435;
		newLead.company = 'MAWA';
		newLead.Status = 'Inquiry';
		// newLead.Sub_Status__c = 'Pending Diagnosis Verification';
		newLead.Gender__c = 'Male';
		newLead.ChapterName__c = chapterAccountId;
		newLead.Referrer_FirstName__c = 'SteveJuneone';
		newLead.Referrer_Last_Name__c = 'Waugh';
		newLead.Referrer_Email__c = 'testmawa21d@gmail.com';
		newLead.Referrer_Phone__c = '9600467579';
		newLead.Referrer_City__c = 'Trichy';
		newLead.Referrer_Zip__c = '6210';
		newLead.Sibling_Detail__c = 'aa | aaab | 14 bbb | bbbc | 15';
		newLead.PD_Condition_Description__c = 'Test Diagnosis';
		newLead.Parent_First_Name__c = 'MAWAFirstJune';
		newLead.Parent_Last_Name__c = 'MAWALastJune';
		newLead.Medical_Professional_First_Name__c = 'SteveJuneone';
		newLead.Medical_Professional_Last_Name__c = 'Waugh';
		newLead.Medical_Professional_Phone__c = '9600467579';
		newLead.Medical_Professional_Email__c = 'testmawa21d@gmail.com';
		newLead.Hospital_Treatment_Facility__c = 'Steve Smith AC';
		newLead.Treating_Medical_Professional_First_Name__c = 'SteveJune';
		newLead.Treating_Medical_Professional_Last_Name__c = 'Waughone';
		newLead.Treating_Medical_Professional_Phone__c = '9600467578';
		newLead.Treating_Medical_Professional_Email__c = 'testmawa2d@gmail.com';
		newLead.Hospital_Treatment_Facility_Treating__c = 'Steve Smith AC';
		newLead.Best_Contact_for_Physician_First_Name__c = 'SteveJune';
		newLead.Best_Contact_for_Physician_Last_Name__c = 'Waughone';
		newLead.Best_contact_for_Physician_Email__c = 'testmawa2d@gmail.com';
		newLead.is_Family_Aware_of_Referral__c = 'Yes';
		newLead.Medical_Questions__c = 'Test Diagnosis';

		newLead.Lung_Disease__c = 'Test1;Test2';
		newLead.Angina__c = 'Test1;Test2';
		newLead.Ventilator__c = 'Test1;Test2';
		newLead.Arrhythmia__c = 'Test1;Test2';
		newLead.Heart_Failure__c = 'Test1;Test2';
		newLead.Congenital_Heart_Disease__c = 'Test1;Test2';
		newLead.Chronic_Hepatitis__c = 'Test1;Test2';
		newLead.Convulsive_Disorders__c = 'Test1;Test2';
		newLead.Pulmonary_Hypertension__c = 'Test1;Test2';
		newLead.Strokes__c = 'Test1;Test2';
		newLead.Chronic_Heart_Failure__c = 'Test1;Test2';
		newLead.isSign__c = true;
		newLead.Travel_algorithm__c = 'Test1;Test2;';
		newLead.Additional_Parent_First_Name__c = 'MAWAFirstJune';
		newLead.Additional_Parent_Last_Name__c = 'MAWALastJune';
		newLead.Additional_Parent_Phone__c = '9600467559';
		newLead.Additional_Parent_Email__c = 'testmawa@gmail.com';
		newLead.Additional_Parent_City__c = 'Trichy';
		newLead.Additional_Parent_Postal_Code__c = '6201717';
		return newLead;
	}

	public static Case CreateDiagnosisNewCase() {
		Account chapterAccount = createchapterAccount();
		Lead newLead = createTestLeadRec(chapterAccount.Id);
		Contact newContact = CreateMedicalProfContact();
		Case newDiagnosis = new Case();
		newDiagnosis.Lead__c = newLead.id;
		newDiagnosis.Local_MCA_Team__c = newContact.id;
		newDiagnosis.MAC_Email__c = 'chandrasekar@mstsolutions.com';
		newDiagnosis.RecordTypeId = diagnosisVerificationRecordTypeId;
		return newDiagnosis;
	}

	public static case CreateParentCase(Id wishChildId) {
		Account alabamaAccount = CreateAlabamaAccount();
		insert alabamaAccount;
		Case newParentWish = new Case();
		newParentWish.RecordTypeId = wishRecordTypeId;
		newParentWish.ChapterName__c = alabamaAccount.Id;
		newParentWish.Subject = 'Parent Wish';
		newParentWish.Interview_date__c = System.today();
		newParentWish.Wish_Type__c = 'Disney World';
		newParentWish.Start_Date__c = System.today();
		newParentWish.End_Date__c = System.today();
		newParentWish.ContactId = wishChildId;
		// newParentWish.Update_Wish_Child_Form_Info__c  = false;
		newParentWish.Status = 'New';
		newParentWish.Start_Date__c = System.today();
		newParentWish.LiabilitySignerMapKeyPair__c = 'Vennila';
		newParentWish.Budget_Submitted_Date__c = system.today();
		newParentWish.Budget_Approved_Date__c = system.today();
		//newParentWish.Update_Wish_Child_Form_Info__c = true;
		//newParentWish.Birthdate__c = Date.today().addDays(+21);
		//newParentWish.Birthdate__c = newParentWish.Birthdate__c.addYears(-3);
		return newParentWish;
	}

	public static case CreateParentCaseWithStatus() {
		Account alabamaAccount = CreateAlabamaAccount();
		insert alabamaAccount;
		Case newParentWish = new Case();
		newParentWish.RecordTypeId = wishRecordTypeId;
		newParentWish.ChapterName__c = alabamaAccount.Id;
		newParentWish.Subject = 'Parent Wish';
		newParentWish.Interview_date__c = System.today();
		newParentWish.Status = 'Qualified';
		newParentWish.Wish_Type__c = 'Disney World';
		newParentWish.Start_Date__c = System.today();
		newParentWish.End_Date__c = System.today();
		newParentWish.Referral_Date__c = Date.today();
		newParentWish.Diagnosis_Verification_Receive_Date__c = System.today();
		newParentWish.Start_Date__c = System.today();
		return newParentWish;
	}

	public static case CreateParentCaseWithTravel(Id wishChildId) {
		Account alabamaAccount = CreateAlabamaAccount();
		insert alabamaAccount;
		Case newParentWish = new Case();
		newParentWish.RecordTypeId = wishRecordTypeId;
		newParentWish.ChapterName__c = alabamaAccount.Id;
		newParentWish.Subject = 'Parent Wish';
		newParentWish.Interview_date__c = System.today();
		newParentWish.Wish_Type__c = 'Disney World';
		newParentWish.ContactId = wishChildId;
		newParentWish.wish_involves_air_travel__c = 'Yes';
		newParentWish.Start_Date__c = System.today();
		//newParentWish.Comments__c = 'Test Comment';
		newParentWish.Comment_1__c = 'Test Comment One';
		//newParentWish.Comment_2__c = 'Test Comment Two';
		newParentWish.Appropriate_Comments__c = 'Appropriate Comment';
		newParentWish.Please_Explain__c = 'Please Explain';
		newParentWish.Rush__c = true;
		newParentWish.Rush_Explanation__c = 'Test Explanation';
		newParentWish.Rush_Timeframe__c = 'ASAP';
		newParentWish.status = 'Ready to Interview';
		return newParentWish;
	}

	public static case CreateParentCaseWithAnticipatedStartDate(Id wishChildId) {
		Account alabamaAccount = CreateAlabamaAccount();
		insert alabamaAccount;
		Case newParentWish = new Case();
		newParentWish.RecordTypeId = wishRecordTypeId;
		newParentWish.ChapterName__c = alabamaAccount.Id;
		newParentWish.Subject = 'Parent Wish';
		newParentWish.Interview_date__c = System.today();
		newParentWish.Start_Date__c = System.today() - 23;
		newParentWish.Wish_Type__c = 'Disney World';
		newParentWish.ContactId = wishChildId;
		return newParentWish;
	}
	//This method used to crate parentcase without value for interview date
	public static case CreateParentCaseWithoutInterviewDate(Id wishChildId) {
		Account alabamaAccount = CreateAlabamaAccount();
		insert alabamaAccount;
		Case newParentWish = new Case();
		newParentWish.RecordTypeId = wishRecordTypeId;
		newParentWish.ChapterName__c = alabamaAccount.Id;
		newParentWish.Subject = 'Parent Wish';
		newParentWish.Wish_Type__c = 'Disney World';
		newParentWish.ContactId = wishChildId;
		return newParentWish;
	}

	//This method used to crate wishdetermination case with the past created date value
	public static case createWishDeterminationCaseWithOldDate(Id wishChildId, Id parentCaseId) {
		Account alabamaAccount = CreateAlabamaAccount();
		insert alabamaAccount;
		Contact newCon = CreateWishChild();
		Case newDeterminationtWish = new Case();
		newDeterminationtWish.RecordTypeId = wishRecordTypeId;
		newDeterminationtWish.ChapterName__c = alabamaAccount.Id;
		newDeterminationtWish.Subject = 'Parent Wish';
		newDeterminationtWish.ContactId = wishChildId;
		newDeterminationtWish.ParentId = CreateParentCaseWithoutInterviewDate(newCon.Id).Id;
		insert newDeterminationtWish;
		Datetime oldDate = Datetime.now().addDays(-21);
		Test.setCreatedDate(newDeterminationtWish.id, oldDate);
		return newDeterminationtWish;
	}

	public static case createWishDeterminationCase(Id wishChildId, Id parentCaseId) {
		Account alabamaAccount = CreateAlabamaAccount();
		insert alabamaAccount;
		Contact newCon = CreateWishChild();
		Case newDeterminationtWish = new Case();
		newDeterminationtWish.RecordTypeId = wishRecordTypeId;
		newDeterminationtWish.ChapterName__c = alabamaAccount.Id;
		newDeterminationtWish.Subject = 'Parent Wish';
		newDeterminationtWish.ContactId = wishChildId;
		newDeterminationtWish.ParentId = CreateParentCaseWithoutInterviewDate(newCon.Id).Id;
		return newDeterminationtWish;
	}

	public static case createWishGrantCase(Id wishChildId, Id parentCaseId) {
		Account alabamaAccount = CreateAlabamaAccount();
		insert alabamaAccount;
		Case newGrantWish = new Case();
		newGrantWish.RecordTypeId = wishRecordTypeId;
		newGrantWish.ChapterName__c = alabamaAccount.Id;
		newGrantWish.Subject = 'Wish Grant';
		newGrantWish.ContactId = wishChildId;
		newGrantWish.ParentId = parentCaseId;
		return newGrantWish;
	}

	public static case ParentCasetoAddCaseMember(Id wishChildId) {
		Account alabamaAccount = CreateAlabamaAccount();
		insert alabamaAccount;
		Case newParentWish = new Case();
		newParentWish.RecordTypeId = wishRecordTypeId;
		newParentWish.ChapterName__c = alabamaAccount.Id;
		newParentWish.Subject = 'Parent Wish';
		newParentWish.ContactId = wishChildId;
		newParentWish.status = 'Qualified';
		return newParentWish;
	}

	public static case CreateParentCaseWithClosedStatus(Id wishChildId) {
		Account alabamaAccount = CreateAlabamaAccount();
		insert alabamaAccount;
		Case newParentWish = new Case();
		newParentWish.RecordTypeId = wishRecordTypeId;
		newParentWish.ChapterName__c = alabamaAccount.Id;
		newParentWish.Subject = 'Parent Wish';
		newParentWish.Interview_date__c = System.today();
		newParentWish.Wish_Type__c = 'Disney World';
		newParentWish.Start_Date__c = System.today();
		newParentWish.End_Date__c = System.today();
		newParentWish.ContactId = wishChildId;
		newParentWish.Status = 'Closed';
		newParentWish.Start_Date__c = System.today();
		newParentWish.LiabilitySignerMapKeyPair__c = 'Vennila';
		newParentWish.Budget_Submitted_Date__c = system.today();
		newParentWish.Budget_Approved_Date__c = system.today();
		newParentWish.Closed_Date__c = System.Today();
		return newParentWish;
	}

	public static case childWishWithConChapter(Id parentWishId) {
		Case newParentWish = new Case(RecordTypeId = wishRecordTypeId, Subject = 'Child Wish', ParentId = parentWishId);
		return newParentWish;
	}

	public static case CreatePartAWishRec() {
		case newPartAcase = new Case();
		newPartAcase.Origin = 'Email';
		newPartAcase.Status = 'Open';
		newPartACase.RecordTypeId = diagnosisVerificationRecordTypeId;
		return newPartAcase;
	}

	public static Role__c createRole() {
		Role__c newRole = new Role__c();
		newRole.Name = 'Wish Granter';
		newRole.isWishRole__c = true;
		return newRole;
	}

	public static Role__c createNonWishRole() {
		Role__c newRole = new Role__c();
		newRole.Name = 'Water Handler';
		newRole.isWishRole__c = false;
		return newRole;
	}

	public Static Chapter_Role__c createChapter(String chapterId, String RoleId) {
		Chapter_Role__c newChapRole = new Chapter_Role__c();
		newChapRole.Chapter_Name__c = chapterId;
		newChapRole.Role_Name__c = roleId;
		newChapRole.Background_Check_Required__c = true;
		return newChapRole;

	}

	public static Volunteer_Roles__c createVolRole(String contactId, String chapterRoleId) {
		Volunteer_Roles__c newVolRole = new Volunteer_Roles__c ();
		newVolRole.Chapter_Role__c = chapterRoleId;
		newVolRole.Volunteer_Name__c = contactId;
		newVolRole.Status__c = 'Chapter Review';
		return newVolRole;
	}

	public static Volunteer_Roles__c createVolRoleWithSubStatus(String contactId, String chapterRoleId) {
		Volunteer_Roles__c newVolRole = new Volunteer_Roles__c ();
		newVolRole.Chapter_Role__c = chapterRoleId;
		newVolRole.Volunteer_Name__c = contactId;
		newVolRole.Status__c = 'Pending';
		newVolRole.Sub_status__c = 'Missing Requirement';
		return newVolRole;
	}

	public static Orientation_Training__c CreateVolunteerTrainingRecord() {
		Orientation_Training__c newTraining = new Orientation_Training__c();
		newTraining.Name = 'Trainging1';
		newTraining.RecordTypeId = volunteerTrainingRecordTypeId;
		newTraining.Start_Time__c = '7:00 AM';
		newTraining.End_Time__c = '7:00 PM';
		return newTraining;
	}

	public static Orientation_Training__c CreateVolunteerOrientationRecord() {
		Orientation_Training__c newOrientation = new Orientation_Training__c();
		newOrientation.Name = 'Orienatation1';
		newOrientation.RecordTypeId = volunteerOrientationRecordTypeId;
		newOrientation.Start_Time__c = '7:00 AM';
		newOrientation.End_Time__c = '7:00 PM';
		return newOrientation;
	}

	public static Chapter_Role_O_T__c createChapterOandT(String chapterRole, String OrientationId) {
		Chapter_Role_O_T__c newChapterRoleOandT = new Chapter_Role_O_T__c();
		newChapterRoleOandT.Orientation_Training__c = OrientationId;
		newChapterRoleOandT.Chapter_Role__c = chapterRole;
		newChapterRoleOandT.Required__c = true;
		return newChapterRoleOandT;
	}

	public static Class_Offering__c createClassOffering(String chapRoleandId) {
		Class_Offering__c newOffering = new Class_Offering__c();
		newOffering.Chapter_Role_O_T__c = chapRoleandId;
		newOffering.Date__c = System.Today() + 10;
		newOffering.Start_Time__c = '10:00 AM';
		newOffering.End_Time__c = '11:00 AM';
		newOffering.max_capacity__c = 100;
		newOffering.Location__c = 'Test';
		newOffering.RecordTypeId = classOfferingRecordTypeId;
		return newOffering;
	}

	public static User createUser() {
		Profile sysAdminProfile = [
				SELECT Id
				FROM Profile
				WHERE Name = 'System Administrator'
		];
		String orgId = UserInfo.getOrganizationId();
		String dateString =
				String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
		Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
		String uniqueName = orgId + dateString + randomInt;
		User tuser = new User(firstname = 'Jon Test',
				lastName = 'Edwards',
				email = uniqueName + '@test' + orgId + '.org',
				Username = uniqueName + '@test' + orgId + '.org',
				EmailEncodingKey = 'ISO-8859-1',
				Alias = uniqueName.substring(18, 23),
				TimeZoneSidKey = 'America/Los_Angeles',
				LocaleSidKey = 'en_US',
				LanguageLocaleKey = 'en_US',
				ProfileId = sysAdminProfile.id);
		return tuser;
	}

	public static User createUserWithRole(Id roleId) {
		Profile volunteerSystemAdministrator = [
				SELECT Id
				FROM Profile
				WHERE Name = 'System Administrator'
		];
		User newPvolunteerSystemAdministratorUser = new User(firstname = 'JonJesu', lastName = 'EdwardsJo', email = 'jonemail@gma111il.com', Username = 'jonsamp0@gma11il.com',
				EmailEncodingKey = 'ISO-8859-1', Alias = 'jone', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
				LanguageLocaleKey = 'en_US', UserRoleId = roleId, ProfileId = volunteerSystemAdministrator.Id, isActive = true, Statecode = 'AZ');
		return newPvolunteerSystemAdministratorUser ;
	}

	public static User createProspectiveVolunteerUser(Id contactId) {
		String prospectiveProfileId = label.Prospective_Volunteer_Profile;
		UserRole portalRole = [
				Select Id
				From UserRole
				Where Name = 'Make-A-Wish Arizona Customer User'
				Limit 1
		];
		User adminUser = [
				SELECT Id
				FROM User
				WHERE IsActive = TRUE AND UserRoleId != NULL AND Profile.Name = 'System Administrator'
				LIMIT 1
		];
		User newProspectiveVolunteerUser;
		System.runAs(adminUser) {
			Account chapterAccount = createVolunteerAccount();
			insert chapterAccount;

			Contact volunteerContact = VolunteerContactwithHomePhone(chapterAccount.Id);
			volunteerContact.Write__c = 'Arabic; Chinese; English';
			insert volunteerContact;

			newProspectiveVolunteerUser = new User(firstname = 'Jonathanan', lastName = 'Edward', email = 'jonathanEdwards@gmail.com', Username = 'joathanedwards@gmail.com',
					EmailEncodingKey = 'ISO-8859-1', Alias = 'jone', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', /*UserRoleId = portalRole.Id,*/ PortalRole = 'Worker',
					LanguageLocaleKey = 'en_US', created_from_portal__c = true, ProfileId = prospectiveProfileId, ContactId = volunteerContact.Id, isActive = true, Statecode = 'AZ');
		}
		return newProspectiveVolunteerUser;
	}

	public static User CreateActiveVolunteerUser(Id contactId) {
		String activeProfileId = label.Active_Volunteer_Profile;
		User newUser = createProspectiveVolunteerUser(null);
		newUser.ProfileId = activeProfileId;
		return newUser;
	}

	public static User CreateActiveVolunteerUserWithPS(Id contactId) {
		String activeProfileId = label.Active_Volunteer_Profile;
		User newUser = createProspectiveVolunteerUser(null);
		newUser.ProfileId = activeProfileId;
		return newUser;
	}

	public static user createrSystemAdminUser() {
		UserRole newUserRole = new UserRole();
		newUserRole.Name = 'Make A Wish Alabama';
		Insert newUserRole;
		Profile pf = [
				SELECT Id
				FROM Profile
				WHERE Name = 'System Administrator'
		];
		String orgId = UserInfo.getOrganizationId();
		String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
		Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
		String uniqueName = orgId + dateString + randomInt;

		User tuser = new User(firstname = 'Test FirstName',
				lastName = 'Test LastName',
				email = 'testmawa@gmail.com',
				Username = uniqueName + '@test' + orgId + '.org',
				EmailEncodingKey = 'ISO-8859-1',
				Alias = uniqueName.substring(18, 23),
				TimeZoneSidKey = 'America/Los_Angeles',
				LocaleSidKey = 'en_US',
				LanguageLocaleKey = 'en_US',
				ProfileId = pf.Id,
				isActive = true,
				State = 'Arizona',
				UserRoleId = newUserRole.Id
		);
		return tuser;
	}

	public static user createrSystemAdminUserwithMgr() {
		UserRole newUserRole = new UserRole();
		newUserRole.Name = 'Make A Wish Alabama';
		Insert newUserRole;
		Profile pf = [
				SELECT Id
				FROM Profile
				WHERE Name = 'System Administrator'
		];
		User user1 = createrSystemAdminUser();

		String orgId = UserInfo.getOrganizationId();
		String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');

		Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
		String uniqueName = orgId + dateString + randomInt;

		User tuser = new User(firstname = 'Test FirstName',
				lastName = 'Test LastName',
				email = 'testmawa@gmail.com',
				Username = uniqueName + '@test' + orgId + '.org',
				EmailEncodingKey = 'ISO-8859-1',
				Alias = uniqueName.substring(18, 23),
				TimeZoneSidKey = 'America/Los_Angeles',
				LocaleSidKey = 'en_US',
				LanguageLocaleKey = 'en_US',
				ProfileId = pf.Id,
				isActive = true,
				State = 'Arizona',
				UserRoleId = newUserRole.Id,
				ManagerId = user1.id
		);
		return tuser;
	}

	public static user createChapterUser() {
		UserRole newUserRole = new UserRole();
		newUserRole.Name = 'Make A Wish Alabama';
		Insert newUserRole;
		Profile pf = [
				SELECT Id
				FROM Profile
				WHERE Name = 'Chapter Dev/Fin Staff'
		];
		String orgId = UserInfo.getOrganizationId();
		String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
		Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
		String uniqueName = orgId + dateString + randomInt;
		User tuser = new User(firstname = 'Test FirstName',
				lastName = 'Test LastName',
				email = 'test123@gmail.com',
				Username = uniqueName + '@test' + orgId + '.org',
				EmailEncodingKey = 'ISO-8859-1',
				Alias = uniqueName.substring(18, 23),
				TimeZoneSidKey = 'America/Los_Angeles',
				LocaleSidKey = 'en_US',
				LanguageLocaleKey = 'en_US',
				ProfileId = pf.Id,
				isActive = true,
				State = 'Alabama',
				UserRoleId = newUserRole.Id);
		return tuser;
	}

	public static User createVolunteerUser(Id contactId) {
		return createProspectiveVolunteerUser(null);
	}

	public static User createAdminUser() {
		Profile volunteerSystemAdministrator = [
				SELECT Id
				FROM Profile
				WHERE Name = 'System Administrator'
		];
		User newPvolunteerSystemAdministratorUser = new User(firstname = 'Yohan', lastName = 'Blake', email = 'blake@yohan.com', Username = 'yohanblake@100m.com',
				EmailEncodingKey = 'ISO-8859-1', Alias = 'jone', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
				LanguageLocaleKey = 'en_US', ProfileId = volunteerSystemAdministrator.Id, isActive = true, Statecode = 'AZ');
		return newPvolunteerSystemAdministratorUser ;
	}

	public static User createActVolunteerUser(Id contactId) {
		String activeProfileId = label.Active_Volunteer_Profile;
		User newUser = createProspectiveVolunteerUser(null);
		newUser.ProfileId = activeProfileId;
		return newUser;
	}

	public static Background_check__c createBackgroundCheck(Id ContactId) {
		Background_check__c backCheck = new Background_check__c();
		backCheck.Date__c = system.today();
		backCheck.Volunteer__c = ContactId;
		backCheck.Date_Completed__c = System.Today().AddYears(-3);
		backCheck.Status__c = 'Sent to First Advantage';
		return backCheck;
	}

	public static Background_check__c createBackgroundCheckFasleRec(Id contactId) {
		Background_check__c backCheck = new Background_check__c();
		backCheck.Date__c = system.today() + 3;
		backCheck.Volunteer__c = contactId;
		backCheck.Date_Completed__c = system.today() + 3;
		backCheck.Status__c = 'Manual';
		backCheck.current__c = false;
		return backCheck;
	}

	public static Background_check__c createBackgroundCheckRec(Id contactId) {
		Background_check__c backCheck = new Background_check__c();
		backCheck.Date__c = system.today() + 3;
		backCheck.Volunteer__c = contactId;
		backCheck.Status__c = 'Approved';
		backCheck.current__c = true;
		backCheck.Date_Completed__c = system.today() + 9;
		return backCheck;
	}

	public static Background_check__c createBackgroundCheckActiveRec(Id contactId) {
		Background_check__c backCheck = new Background_check__c();
		backCheck.Date__c = system.today() + 3;
		backCheck.Volunteer__c = contactId;
		backCheck.Status__c = 'NewApprovedWishVolunteerOpportunityList';
		backCheck.current__c = true;
		backCheck.Date_Completed__c = system.today() + 9;
		return backCheck;
	}

	public static Awards_Recognition__c CreateAwardRecognition(Id chapterAccountId, Id volContactId) {
		Awards_Recognition__c awdreg = new Awards_Recognition__c();
		awdreg.Chapter_Name__c = chapterAccountId;
		awdreg.Volunteer_Contact__c = volContactId;
		awdreg.Award_Type__c = 'Chapter Recognition';
		return awdreg;
	}

	public static Conflict_Of_Interest__c createCOI(Id conId) {
		Conflict_Of_Interest__c newCOI = new Conflict_Of_Interest__c();
		newCOI.Volunteer_Contact__c = conId;
		newCOI.Expiration_Date__c = system.today() + 3;
		return newCOI;
	}

	public static Conflict_Of_Interest__c createCOIwithCurrent(Id conId, boolean bool) {
		Conflict_Of_Interest__c newCOI = new Conflict_Of_Interest__c();
		newCOI.Volunteer_Contact__c = conId;
		newCOI.Expiration_Date__c = system.today() + 3;
		newCOI.Current__c = bool;
		return newCOI;
	}

	public static npe5__Affiliation__c CreateAffiliation(Id contactId) {
		npe5__Affiliation__c neworgAffiliation = new npe5__Affiliation__c ();
		neworgAffiliation.npe5__Contact__c = contactId;
		neworgAffiliation.npe5__Organization__c = TestClassUtil.createVolunteerAccount().Id;
		neworgAffiliation.npe5__Primary__c = true;
		neworgAffiliation.npe5__Status__c = 'Pending';
		neworgAffiliation.Constituent_Code__c = boardMemberRecordTypeLabel;
		return neworgAffiliation;
	}

	public static npe5__Affiliation__c CreateAffiliationwithAccount(Id contactId, Id AccountId) {
		npe5__Affiliation__c neworgAffiliation = new npe5__Affiliation__c ();
		neworgAffiliation.npe5__Contact__c = contactId;
		neworgAffiliation.npe5__Organization__c = AccountId;
		neworgAffiliation.npe5__Primary__c = true;
		neworgAffiliation.npe5__Status__c = 'Pending';
		return neworgAffiliation;
	}

	public static Volunteer_Orientation_Training__c createVolTraining(Id OrienationId, Id ClassOfferingId, Id volunteer, string status) {
		Volunteer_Orientation_Training__c createNewVol = new Volunteer_Orientation_Training__c();
		createNewVol.class_offering__c = ClassOfferingId;
		createNewVol.Hidden_O_T_Id__c = OrienationId;
		createNewVol.Registered_Date__c = Date.Today();
		createNewVol.Volunteer__c = volunteer;
		createNewVol.Volunteer_Attendance__c = status;
		createNewVol.Type__c = 'Training';
		createNewVol.RE_Completed_Date__c = String.ValueOf(system.today());
		return createNewVol;
	}

	public static Volunteer_Orientation_Training__c createVolOrientation(Id OrienationId, Id ClassOfferingId, Id volunteer, string status) {
		Volunteer_Orientation_Training__c createNewVol = new Volunteer_Orientation_Training__c();
		createNewVol.class_offering__c = ClassOfferingId;
		createNewVol.Hidden_O_T_Id__c = OrienationId;
		createNewVol.Registered_Date__c = Date.Today();
		createNewVol.Volunteer__c = volunteer;
		createNewVol.Volunteer_Attendance__c = status;
		createNewVol.Type__c = 'Orientation';
		return createNewVol;
	}

	public static Dynamic_Content__c ChapterDynamicContent(String chapterId) {
		Dynamic_Content__c newChapterContent = new Dynamic_Content__c();
		newChapterContent.Feature_Quote__c = 'Test Feature Quote';
		newChapterContent.Active__c = true;
		newChapterContent.Welcome_Message__c = 'Test Welcome Page';
		newChapterContent.Heading_Highlight_Text_1__c = 'Test Heightlisght Text';
		newChapterContent.Heading_Highlight_Text_2__c = 'Test Heightlisght Text';
		newChapterContent.Heading_Highlight_Text_3__c = 'Test Heightlisght Text';
		newChapterContent.Heading_Highlight_Title_1__c = 'Test Title';
		newChapterContent.Heading_Highlight_Title_2__c = 'Test Title';
		newChapterContent.Heading_Highlight_Title_3__c = 'Test Title';
		newChapterContent.RecordTypeId = activeRecordTypeId;
		newChapterContent.Chapter_Name__c = chapterId;
		return newChapterContent;
	}

	public static Dynamic_Content__c createDynamicContent() {
		Dynamic_Content__c newContent = new Dynamic_Content__c();
		newContent.Sign_Up_Page__c = 'Hai';
		newContent.RecordTypeId = nationalRecordTypeId;
		newContent.Application_Overview__c = 'An interview is a great way to better understand the role(s) and expectations of the volunteer opportunities that you are interested in';
		newContent .Active__c = true;
		newContent.Interview_Additional_Info__c = 'Test';
		newContent.Orientation_Add_l_Info__c = 'Test';
		newContent.Sign_Up_Page__c = 'Test';
		newContent.Training_Additional_Info__c = 'Test';
		newContent.Welcome_Message__c = 'Test';
		newContent.WelcomePage__c = 'Test';
		newContent.Welcome_Text__c = 'Test';
		newContent.Why_Need_Background_Check__c = 'Test';
		return newContent;
	}

	public static Dynamic_Content__c createProspectiveDynamicContent(Id chapterId) {
		Dynamic_Content__c newContent = new Dynamic_Content__c();
		newContent.RecordTypeId = prospectiveVolunteerRecordTypeId;
		newContent.How_do_I_Become_a_Volunteer__c = 'Test';
		newContent.Chapter_Name__c = chapterId;
		return newContent;
	}

	public Static DocuSignCredentialsSetting__c insertDocusignSetting() {
		DocuSignCredentialsSetting__c newSetting = new DocuSignCredentialsSetting__c();
		newSetting.account__c = '0afd45e1-ae2d-468c-a168-b8603dae66a3';
		newSetting.IntegratorKey__c = 'ea6d625f-6c08-4b12-aa2d-554909addb30';
		newSetting.Name = 'kanagaraj@mstsolutions.com';
		return newSetting;
	}

	public static ICD_Codes__c createICDCode(Id conditionDescId) {
		ICD_Codes__c newICD = new ICD_Codes__c ();
		newICD.Name = 'C43.30';
		newICD.Condition_Description__c = conditionDescId;
		newICD.Group1__c = true;
		newICD.Short_Description__c = 'Malignant melanoma of unspecified part of face';
		newICD.Long_Description__c = 'Malignant melanoma of unspecified part of face';
		return newICD;
	}

	public static Volunteer_Opportunity__c CreateNewWishVolunteerOpportunity(Id chapterId, Id roleId, Id wishId) {
		Volunteer_Opportunity__c newWishOpportunity = new Volunteer_Opportunity__c();
		newWishOpportunity.Chapter_Role_Opportunity__c = roleId;
		newWishOpportunity.Wish__c = wishId;
		newWishOpportunity.Chapter_Name__c = chapterId;
		newWishOpportunity.RecordTypeId = wishVolunteerOpportunityRecordTypeId;
		return newWishOpportunity;

	}

	public static Volunteer_Opportunity__c createDuplicateNewWishVolunteerOpportunity(Id chapterId, Id roleId, Id wishId) {
		Volunteer_Opportunity__c newWishOpportunity = new Volunteer_Opportunity__c();
		newWishOpportunity.Chapter_Role_Opportunity__c = roleId;
		//newWishOpportunity.Volunteer_Name__c = volunteerId;
		newWishOpportunity.Wish__c = wishId;
		newWishOpportunity.Chapter_Name__c = chapterId;
		newWishOpportunity.RecordTypeId = wishVolunteerOpportunityRecordTypeId;
		return newWishOpportunity;
	}

	public static Volunteer_Opportunity__c CreateNonWishVolunteerOpportunity(Id chapterId, Id roleId, Id eventId) {
		Volunteer_Count__c newVolCount = new Volunteer_Count__c ();
		Volunteer_Opportunity__c newNonWishOpportunity = new Volunteer_Opportunity__c();
		newNonWishOpportunity.Chapter_Role_Opportunity__c = roleId;
		newNonWishOpportunity.Non_Wish_Event__c = eventId;
		newNonWishOpportunity.Chapter_Name__c = chapterId;
		newNonWishOpportunity.RecordTypeId = nonWishRecordTypeId;
		newNonWishOpportunity.Status__c = 'Pending';
		newNonWishOpportunity.HiddenVolunteer_Count_Description__c = newVolCount.id;
		return newNonWishOpportunity;
	}

	public static Volunteer_Opportunity__c CreateNonWishDuplicateVolunteerOpportunity(Id chapterId, Id roleId, Id eventId) {
		Volunteer_Opportunity__c newNonWishOpportunity = new Volunteer_Opportunity__c();
		newNonWishOpportunity.Chapter_Role_Opportunity__c = roleId;
		newNonWishOpportunity.Non_Wish_Event__c = eventId;
		newNonWishOpportunity.Chapter_Name__c = chapterId;
		newNonWishOpportunity.RecordTypeId = nonWishRecordTypeId;
		return newNonWishOpportunity;
	}

	public static List<Volunteer_Opportunity__c> createVolunteerOpportunities(Integer num){
		List<Volunteer_Opportunity__c> retList = new List<Volunteer_Opportunity__c>();
		for(Integer i = 0; i < num; i++){
			retList.add(new Volunteer_Opportunity__c());
		}
		return retList;
	}

	public static List<Volunteer_Opportunity__c> NewWishVolunteerOpportunityList(Id chapterId, Id roleId, Id wishId, Integer count) {
		List<Volunteer_Opportunity__c> volunteerOpportunityList = new List<Volunteer_Opportunity__c>();
		for (Integer i = 0; i <= count; i++) {
			Volunteer_Opportunity__c newWishOpportunity = new Volunteer_Opportunity__c();
			newWishOpportunity.Chapter_Role_Opportunity__c = roleId;
			newWishOpportunity.Wish__c = wishId;
			newWishOpportunity.Chapter_Name__c = chapterId;
			newWishOpportunity.RecordTypeId = wishVolunteerOpportunityRecordTypeId;
			volunteerOpportunityList.add(newWishOpportunity);
		}
		return volunteerOpportunityList;
	}

	public static List<Volunteer_Opportunity__c> NewWishVolunteerOpportunityList(Id volunteerId, Id chapterId, Id roleId, Id wishId, Integer count) {
		List<Volunteer_Opportunity__c> volunteerOpportunityList = new List<Volunteer_Opportunity__c>();
		for (Integer i = 0; i <= count; i++) {
			Volunteer_Opportunity__c newWishOpportunity = new Volunteer_Opportunity__c();
			newWishOpportunity.Chapter_Role_Opportunity__c = roleId;
			newWishOpportunity.Volunteer_Name__c = volunteerId;
			newWishOpportunity.Wish__c = wishId;
			newWishOpportunity.Chapter_Name__c = chapterId;
			newWishOpportunity.RecordTypeId = wishVolunteerOpportunityRecordTypeId;
			volunteerOpportunityList.add(newWishOpportunity);
		}
		return volunteerOpportunityList;
	}

	public static List<Volunteer_Opportunity__c> NewnonWishVolunteerOpportunityList(Id chapterId, Id roleId, Id nonWishId, Integer count) {
		List<Volunteer_Opportunity__c> volunteerOpportunityList = new List<Volunteer_Opportunity__c>();
		for (Integer i = 1; i <= count; i++) {
			Volunteer_Opportunity__c newWishOpportunity = new Volunteer_Opportunity__c();
			newWishOpportunity.Chapter_Role_Opportunity__c = roleId;
			newWishOpportunity.Non_Wish_Event__c = nonWishId;
			newWishOpportunity.Chapter_Name__c = chapterId;

			newWishOpportunity.RecordTypeId = wishVolunteerOpportunityRecordTypeId;
			volunteerOpportunityList.add(newWishOpportunity);

		}
		return volunteerOpportunityList;
	}

	public static List<Volunteer_Opportunity__c> NewnonWishVolunteerOpportunityList(Id volunteerId, Id chapterId, Id roleId, Id nonWishId, Integer count) {
		List<Volunteer_Opportunity__c> volunteerOpportunityList = new List<Volunteer_Opportunity__c>();
		for (Integer i = 1; i <= count; i++) {
			Volunteer_Opportunity__c newWishOpportunity = new Volunteer_Opportunity__c();
			newWishOpportunity.Chapter_Role_Opportunity__c = roleId;
			newWishOpportunity.Non_Wish_Event__c = nonWishId;
			newWishOpportunity.Chapter_Name__c = chapterId;
			newWishOpportunity.Volunteer_Name__c = volunteerId;
			newWishOpportunity.RecordTypeId = nonWishRecordTypeId;
			volunteerOpportunityList.add(newWishOpportunity);
		}
		return volunteerOpportunityList;
	}

	public static Volunteer_Opportunity__c NewnonWishVolunteerOpportunity(Id chapterId, Id contactId) {
		Volunteer_Opportunity__c newWishOpportunity = new Volunteer_Opportunity__c();
		newWishOpportunity.Chapter_Name__c = chapterId;
		newWishOpportunity.RecordTypeId = wishVolunteerOpportunityRecordTypeId;
		newWishOpportunity.Volunteer_Name__c = contactId;
		return newWishOpportunity;
	}

	public static Non_Wish_Events__c CreateEvent(Id ChapterId) {
		Non_Wish_Events__c newEvent = new Non_Wish_Events__c();
		newEvent.Event_Name__c = 'Send Off';
		newEvent.Event_Date__c = System.Today() + 5;
		newEvent.Event_Text__c = 'Sending Wish Child';
		newEvent.RecordTypeId = eventsRecordTypeId;
		return newEvent;
	}

	public static Non_Wish_Events__c CreateEventinPastDate(Id ChapterId) {
		Non_Wish_Events__c newEvent = new Non_Wish_Events__c();
		newEvent.Event_Name__c = 'Send Off';
		newEvent.Event_Date__c = System.Today() - 5;
		newEvent.Event_Text__c = 'Sending Wish Child';
		newEvent.RecordTypeId = eventsRecordTypeId;
		return newEvent;
	}

	public static Non_Wish_Events__c CreateEventRec(Id chaterRoleId, Id chaterId) {
		Non_Wish_Events__c newEvent = new Non_Wish_Events__c();
		newEvent.Event_Name__c = 'Send Off';
		newEvent.Event_Date__c = System.Today() + 5;
		newEvent.Event_Text__c = 'Sending Wish Child';
		newEvent.RecordTypeId = eventsRecordTypeId;
		newEvent.Volunteer_Need__c = 3;
		newEvent.Chapter_Role__c = chaterRoleId;
		newEvent.Chapter__c = chaterId;
		return newEvent;
	}

	public static Volunteer_Count__c createVolunteerCount(Id nonWishId, Id chapterRoleId, Integer count) {
		Volunteer_Count__c newVolCount = new Volunteer_Count__c ();
		newVolCount.Volunteer_Needed__c = count;
		newVolCount.Chapter_Role__c = chapterRoleId;
		newVolCount .Non_Wish_Events__c = nonWishId;
		newVolCount.Description__c = 'Test Description';
		newVolCount.Date__c = system.today();
		newVolCount.Start_Time__c = '7.00 AM';
		newVolCount.End_Time__c = '9.00 AM';
		return newVolCount;
	}

	public Static List<Time_sheet__c> crateWishTimeSheet(List<Volunteer_Opportunity__c> WishOpportunityList) {
		List<Time_sheet__c> nonwishDeterminationList = new List<Time_sheet__c>();
		for (Integer i = 0; i < WishOpportunityList.Size(); i++) {
			Time_sheet__c newTimeSheet = new Time_sheet__c();
			newTimeSheet.Date__c = system.today();
			newTimeSheet.Hours_spent__c = 12.59;
			newTimeSheet.Volunteer_Opportunity__c = WishOpportunityList.get(i).Id;
			nonwishDeterminationList .add(newTimeSheet);
		}
		return nonwishDeterminationList;
	}

	public Static List<Time_sheet__c> crateNonWishTimeSheet(List<Volunteer_Opportunity__c> nonWishopportunityList, integer a) {
		List<Time_sheet__c> nonwishDeterminationList = new List<Time_sheet__c>();
		for (Integer i = 1; i <= a; i++) {
			Time_sheet__c newTimeSheet = new Time_sheet__c();
			newTimeSheet.Date__c = system.today();
			newTimeSheet.Hours_spent__c = 12.50;
			newTimeSheet.Volunteer_Opportunity__c = nonWishopportunityList.get(0).Id;
			nonwishDeterminationList .add(newTimeSheet);
		}
		return nonwishDeterminationList;
	}

	public Static void cretateGroup() {
		Group leadalabamaGroup = new Group(Type = 'Regular', Name = 'Arizona');
	}

	public static Chapter_Action_Track__c createChapterActionTrack() {
		Chapter_Action_Track__c newChapterAction = new Chapter_Action_Track__c();
		newChapterAction.Task_Name__c = 'Planning';
		newChapterAction.Sort_Order__c = 1;
		newChapterAction.Wish_type__c = 'Standard';
		newChapterAction.Wish_Type__c = 'Disney World';
		newChapterAction.Months__c = 2;
		newChapterAction.Weeks__c = 2;
		return newChapterAction;
	}

	public static Chapter_Action_Track__c otherActionTrack() {
		Chapter_Action_Track__c newChapterAction = new Chapter_Action_Track__c();
		newChapterAction.Task_Name__c = 'Planning';
		newChapterAction.Sort_Order__c = 1;
		newChapterAction.Wish_type__c = 'Standard';
		newChapterAction.Wish_Type__c = 'Other';
		newChapterAction.Months__c = 2;
		newChapterAction.Weeks__c = 2;
		return newChapterAction;
	}

	public static CaseTeamMember createCaseTeamMember(Id parentId, Id wishId, Id roleId) {
		CaseTeamMember caseMember = new CaseTeamMember();
		caseMember.ParentId = parentId;
		caseMember.memberId = wishId;
		caseMember.TeamRoleId = roleId;
		return caseMember;
	}

	public static CaseTeamMember createWishTeamMemberwithTeamRole(Id parentId, Id wishId, Id roleId) {
		CaseTeamMember caseMember = new CaseTeamMember();
		caseMember.ParentId = parentId;
		caseMember.memberId = wishId;
		caseMember.TeamRoleId = roleId;
		return caseMember;
	}

	public static CollaborationGroup createCollaborationGroup(string chapterName) {
		CollaborationGroup newGroup = new CollaborationGroup();
		newGroup.name = chapterName;
		newGroup.CollaborationType = 'Public';
		return newGroup;
	}

	public static Office__c createOffice(Id AccountId) {
		Office__c newOffice = new Office__c();
		newOffice.Chapter__c = AccountId;
		newOffice.Name = 'Make-A-Wish Alabama';
		newOffice.Office_Id__c = '014-000';
		newOffice.Office_Legal_Name__c = 'Make-A-Wish Alabama,NY, Inc.';
		newOffice.General_Email_Address__c = 'wishmail@suffolk.wish.org';
		newOffice.Website__c = 'http://suffolk.wish.org';
		newOffice.Address_1__c = '1 Comac Loop';
		newOffice.Address_2__c = 'Suite 1A1';
		newOffice.City__c = 'Ronkonkoma';
		newOffice.State__c = 'NY';
		newOffice.Zip_Code__c = '32193';
		newOffice.Country__c = 'US';
		newOffice.Phone_Number__c = '(631) 585-9474';
		return newOffice;
	}

	public static Zip_Code__c createZipcode(Id officeId) {
		Zip_Code__c newZip = new Zip_Code__c ();
		newZip.Name = '32193';
		newZip.Office__c = officeId;
		return newZip;
	}

	public Static List<Medical_Questions__c> CreateMedicalQuestion(Id ConditionDesc) {
		list<Medical_Questions__c> medicalQuestionList = new List<Medical_Questions__c>();
		Medical_Questions__c newQuestionsOne = new Medical_Questions__c();
		newQuestionsOne.Question__c = 'Is child currently or within one year of completing treatment for this condition?';
		newQuestionsOne.Picklist_values__c = 'Yes,No';
		newQuestionsOne.Data_Type__c = 'Picklist';
		newQuestionsOne.RecordTypeId = algorithmRecordTypeId;
		newQuestionsOne.Wrapper_Variable__c = 'TestWrapperone';
		newQuestionsOne.Current_Condition__c = 'Testone';
		newQuestionsOne.Recommendation_to_Chapter__c = 'None Apply';
		newQuestionsOne.Condition_Description__c = ConditionDesc;
		newQuestionsOne.Sort_Order__c = 1;
		medicalQuestionList.add(newQuestionsOne);
		Medical_Questions__c newQuestionsTwo = new Medical_Questions__c();
		newQuestionsTwo.Question__c = 'Is child currently or within one year of completing treatment for this condition?';
		newQuestionsTwo.Picklist_values__c = 'Yes,No';
		newQuestionsTwo.Epilepsy_picklist__c = 'Yes,No';
		newQuestionsTwo.Data_Type__c = 'Picklist';
		newQuestionsTwo.RecordTypeId = algorithmRecordTypeId;
		newQuestionsTwo.Wrapper_Variable__c = 'TestWrappertwo';
		newQuestionsTwo.Current_Condition__c = 'Testtwo';
		newQuestionsTwo.Recommendation_to_Chapter__c = 'None Apply';
		newQuestionsTwo.Condition_Description__c = ConditionDesc;
		newQuestionsOne.Sort_Order__c = 2;
		Medical_Questions__c newQuestionsThree = new Medical_Questions__c();
		newQuestionsThree.Question__c = 'Is child currently or within one year of completing treatment for this condition?';
		newQuestionsThree.Picklist_values__c = 'Yes,No';
		newQuestionsThree.Data_Type__c = 'Comment box';
		newQuestionsThree.RecordTypeId = algorithmRecordTypeId;
		newQuestionsThree.Wrapper_Variable__c = 'TestWrapperthree';
		newQuestionsThree.Current_Condition__c = 'Testthree';
		newQuestionsThree.Recommendation_to_Chapter__c = 'None Apply';
		newQuestionsThree.Condition_Description__c = ConditionDesc;
		newQuestionsOne.Sort_Order__c = 3;
		medicalQuestionList.add(newQuestionsTwo);
		return medicalQuestionList;
	}

	public static Condition_Description__c createConditionDesCription() {
		Condition_Description__c newDesc = new Condition_Description__c();
		newDesc.Name = 'Malignant Melanoma';
		newDesc.Treatment_Subspecialty__c = 'Oncology';
		newDesc.Code_To_Use__c = 'C43.30';
		newDesc.PR_Diagnosis__c = 'Malignant Melanoma';
		newDesc.Group1__c = true;
		return newDesc;
	}

	public static Diagnosis_Verification__c createDiagnosis(Id leadId) {
		ICD_Codes__c newICD = new ICD_Codes__c ();
		newICD.Name = 'C43.30';
		newICD.Group1__c = true;
		newICD.Short_Description__c = 'Malignant melanoma of unspecified part of face';
		newICD.Long_Description__c = 'Malignant melanoma of unspecified part of face';
		insert newICD;
		Diagnosis_Verification__c newDiagVf = new Diagnosis_Verification__c();
		newDiagVf.ICD_Code__c = newICD.Id;
		newDiagVf.Lead__c = leadId;
		newDiagVf.Order__c = 2;
		//newDiagVf.Primary_Diagnosis__c= 'test';
		return newDiagVf ;
	}

	public static Diagnosis_Verification__c createDiagnosisRec(Id leadId, Id conditionDescId) {
		ICD_Codes__c newICD = new ICD_Codes__c ();
		newICD.Name = 'C43.30';
		newICD.Group1__c = true;
		newICD.Short_Description__c = 'Malignant melanoma of unspecified part of face';
		newICD.Long_Description__c = 'Malignant melanoma of unspecified part of face';
		insert newICD;
		Diagnosis_Verification__c newDiagVf = new Diagnosis_Verification__c();
		newDiagVf.ICD_Code__c = newICD.Id;
		newDiagVf.Lead__c = leadId;
		newDiagVf.Order__c = 2;
		newDiagVf.Condition_Description__c = conditionDescId;
		//newDiagVf.Primary_Diagnosis__c= 'test';
		return newDiagVf ;
	}

	public static dsfs__DocuSign_Status__c createDocusignStatus(Id LeadId) {

		dsfs__DocuSign_Status__c dsfs = NEW dsfs__DocuSign_Status__c();
		dsfs.dsfs__DocuSign_Envelope_ID__c = '0F31B5A9-DB3A-4D31-8D69-9DE86F2010A8';
		dsfs.dsfs__Lead__c = LeadId;
		dsfs.isConflict__c = false;
		dsfs.dsfs__Envelope_Status__c = 'Sent';
		return dsfs;
	}

	public static dsfs__DocuSign_Status__c createDocusignStatuswithCase(Id caseId) {

		dsfs__DocuSign_Status__c dsfs = NEW dsfs__DocuSign_Status__c();
		dsfs.dsfs__DocuSign_Envelope_ID__c = '0204C9DD-B8B3-4D7D-B9C5-F88B921E1511';
		dsfs.dsfs__Case__c = caseId;
		dsfs.isConflict__c = false;
		dsfs.Recipient_names__c = 'Vennila';
		dsfs.dsfs__Envelope_Status__c = 'Sent';
		dsfs.dsfs__Completed_Date_Time__c = system.Now();
		dsfs.dsfs__Subject__c = 'Signature Required - Liability And Publicity Release Form';
		return dsfs;
	}

	public static dsfs__DocuSign_Status__c CreateDocusignRecord() {
		Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
		Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
		dsfs__DocuSign_Status__c newDocusign = new dsfs__DocuSign_Status__c();
		newDocusign.dsfs__Lead__c = newLead.Id;
		newDocusign.dsfs__Envelope_Status__c = 'Completed';
		newDocusign.dsfs__Subject__c = 'Signature Required - Absent Parent Form';
		return newDocusign;
	}

	public static dsfs__DocuSign_Status__c createDocusignStatuswithCon(Id contactId) {
		dsfs__DocuSign_Status__c dsfs = NEW dsfs__DocuSign_Status__c();
		dsfs.dsfs__DocuSign_Envelope_ID__c = '0F31B5A9-DB3A-4D31-8D69-9DE86F2010A8';
		dsfs.dsfs__Contact__c = contactId;
		dsfs.dsfs__Envelope_Status__c = 'Sent';
		return dsfs;
	}

	//This method is used to create reimbursement record with record type of reimbursement
	public static In_Kind_Donation_Reimbursement__c createReImbursementRecord() {
		In_Kind_Donation_Reimbursement__c newReimbursement = new In_Kind_Donation_Reimbursement__c();
		Contact newContact = CreateWishChild();
		Case newCase = ParentCasetoAddCaseMember(newContact.Id);
		newReimbursement.Wish__c = newCase.Id;
		newReimbursement.RecordTypeId = reimbursementRecordTypeId;
		return newReimbursement;
	}

	//This method is used to create test record with inkind record type
	public static In_Kind_Donation_Reimbursement__c CreateInkindRecord(Id ParentId) {
		In_Kind_Donation_Reimbursement__c newinkind = new In_Kind_Donation_Reimbursement__c();
		newinkind.Date_of_Gift__c = system.today() + 2;
		newinkind.Gift_Type__c = 'Goods';
		newinkind.Gift_Value__c = 123456;
		newinkind.Documentation__c = 'Not available';
		newinkind.RecordTypeId = inKindRecordTypeId;
		newinkind.Make_check_payable_to_me__c = true;
		newinkind.Wish__c = ParentId;
		return newinkind;
	}

	//This method is used to create inkind  record without any attachment
	public static In_Kind_Donation_Reimbursement__c CreateInkindRecord() {
		In_Kind_Donation_Reimbursement__c newinkindRecord = new In_Kind_Donation_Reimbursement__c();
		newinkindRecord.Date_of_Gift__c = system.today() + 2;
		newinkindRecord.Gift_Type__c = 'Goods';
		newinkindRecord.Gift_Value__c = 123456;
		newinkindRecord.Documentation__c = 'Not available';
		newinkindRecord.RecordTypeId = inKindRecordTypeId;
		newinkindRecord.Make_check_payable_to_me__c = true;
		return newinkindRecord;
	}

	//This method is used to create reimbursement record with make check payable field valu as true
	public static In_Kind_Donation_Reimbursement__c CreateReimbursRecord() {
		In_Kind_Donation_Reimbursement__c newReimbursement = new In_Kind_Donation_Reimbursement__c();
		newReimbursement.Documentation__c = 'Not available';
		newReimbursement.RecordTypeId = reimbursementRecordTypeId;
		newReimbursement.Make_check_payable_to_me__c = true;
		return newReimbursement;
	}

	public static In_Kind_Donation_Reimbursement__c CreateReimbursRecordWithCase(Id caseid) {
		In_Kind_Donation_Reimbursement__c newReimbursement = new In_Kind_Donation_Reimbursement__c();
		newReimbursement.Documentation__c = 'Not available';
		newReimbursement.RecordTypeId = reimbursementRecordTypeId;
		newReimbursement.Make_check_payable_to_me__c = true;
		newReimbursement.Wish__c = caseid;
		return newReimbursement;
	}

	//This method is used to create reimbursement record without any attachment
	public static In_Kind_Donation_Reimbursement__c CreateReimbursRecordWithOutAttachment() {
		In_Kind_Donation_Reimbursement__c newReimbursement = new In_Kind_Donation_Reimbursement__c();
		newReimbursement.Documentation__c = 'Will Attach';
		newReimbursement.RecordTypeId = reimbursementRecordTypeId;
		newReimbursement.Make_check_payable_to_me__c = true;
		return newReimbursement;
	}

	//This method is used to create reimbursement record with make check payable field valu as false
	public static In_Kind_Donation_Reimbursement__c CreateReimbursRecordwithFalse() {
		In_Kind_Donation_Reimbursement__c newReimbursement = new In_Kind_Donation_Reimbursement__c();
		newReimbursement.Documentation__c = 'Not available';
		newReimbursement.RecordTypeId = reimbursementRecordTypeId;
		newReimbursement.Make_check_payable_to_me__c = false;
		return newReimbursement;
	}

	//Used to create checkin task for wish child family.
	public static Task createFamilyCheckinTask(Id parentWishId) {
		Task checkinTask = new Task();
		checkinTask.ActivityDate = System.today() + 30;
		checkinTask.Subject = 'Check in with the family every 30 days';
		checkinTask.Status = 'Not Started';
		checkinTask.WhatId = parentWishId;
		return checkinTask;
	}

	//Used to create Flights booked task for wish child family.
	public static Task createFightBookingTask(Id parentWishId) {
		Task checkinTask = new Task();
		checkinTask.ActivityDate = System.today() + 30;
		checkinTask.Subject = 'Flights booked';
		checkinTask.Status = 'Not Started';
		checkinTask.WhatId = parentWishId;
		return checkinTask;
	}

	//Used to create sneak Peek booked task for wish child family.
	public static Task createSneakPeek(Id parentWishId) {
		Task checkinTask = new Task();
		checkinTask.ActivityDate = System.today() + 30;
		checkinTask.Subject = 'Sneak Peek Letter';
		checkinTask.Status = 'Not Started';
		checkinTask.WhatId = parentWishId;
		return checkinTask;
	}

	//Used to create Budget task for wish child family.
	public static Task createBudgetTask(Id parentWishId) {
		Task checkinTask = new Task();
		checkinTask.ActivityDate = System.today() + 30;
		checkinTask.Subject = 'Budget';
		checkinTask.Status = 'Not Started';
		checkinTask.WhatId = parentWishId;
		return checkinTask;
	}

	public static Task passportRequestTask(Id parentWishId) {
		Task checkinTask = new Task();
		checkinTask.ActivityDate = System.today() + 30;
		checkinTask.Subject = 'Request Passports from family';
		checkinTask.Status = 'Not Started';
		checkinTask.WhatId = parentWishId;
		return checkinTask;
	}

	//Wish presentation not set
	public static Task wishPresentationNotSet(Id parentWishId) {
		Task presentation = new Task();
		presentation.ActivityDate = System.today() + 30;
		presentation.Subject = 'Wish Presentation not set';
		presentation.Status = 'Not Started';
		presentation.WhatId = parentWishId;
		return presentation;
	}

	public static npe4__Relationship__c CreateRelationshipRec(Id wishChildId, Id wishFamilyId) {
		npe4__Relationship__c newRelationShip = new npe4__Relationship__c();
		newRelationShip.npe4__Contact__c = wishChildId;
		newRelationShip.npe4__RelatedContact__c = wishFamilyId;
		newRelationShip.npe4__Status__c = 'Active';
		newRelationShip.npe4__Type__c = 'Father';
		return newRelationShip;
	}

	public Static npe4__Relationship__c relationshipChild(Id FamilyContactId, id ChildContactid) {
		npe4__Relationship__c newRelationForm = new npe4__Relationship__c();
		newRelationForm.npe4__Contact__c = ChildContactid;
		newRelationForm.npe4__RelatedContact__c = FamilyContactId;
		newRelationForm.Parent_Legal_Guardian__c = true;
		return newRelationForm;
	}

	public Static npe4__Relationship__c relationshipChildWithFalse(Id FamilyContactId, id ChildContactid) {
		npe4__Relationship__c newRelationForm = new npe4__Relationship__c();
		newRelationForm.npe4__Contact__c = ChildContactid;
		newRelationForm.npe4__RelatedContact__c = FamilyContactId;
		newRelationForm.Parent_Legal_Guardian__c = false;
		newRelationForm.npe4__Type__c = medicalProfessionalRecordTypeLabel;
		newRelationForm.Qualifying_Medical_Professional__c = true;
		newRelationForm.npe4__Status__c = 'Active';
		newRelationForm.Parent_Legal_Guardian__c = true;
		return newRelationForm;
	}

	public static npe4__Relationship__c ParentLegualGuardianRelation(Id wishChildId, Id wishFamilyId) {
		npe4__Relationship__c newRelationShip = new npe4__Relationship__c();
		newRelationShip.npe4__Contact__c = wishChildId;
		newRelationShip.npe4__RelatedContact__c = wishFamilyId;
		newRelationShip.npe4__Status__c = 'Active';
		newRelationShip.npe4__Type__c = 'Father';
		newRelationShip.Parent_Legal_Guardian__c = true;
		return newRelationShip;
	}

	public static npe4__Relationship__c ParticipantRelationShip(Id wishChildId, Id wishFamilyId) {
		npe4__Relationship__c newRelationShip = new npe4__Relationship__c();
		newRelationShip.npe4__Contact__c = wishChildId;
		newRelationShip.npe4__RelatedContact__c = wishFamilyId;
		newRelationShip.npe4__Status__c = 'Active';
		newRelationShip.npe4__Type__c = 'Mother';
		newRelationShip.Parent_Legal_Guardian__c = false;
		newRelationShip.Wish_Participant__c = true;
		return newRelationShip;
	}

	public static CaseTeamRole CreateCaseTeamRole() {
		CaseTeamRole newRole = new CaseTeamRole();
		newRole.Name = 'Wish Granter';
		newRole.PreferencesVisibleInCSP = true;
		newRole.AccessLevel = 'Edit';
		return newRole;
	}

	public static cg__Lead_File__c createLeadFileRecord(Id LeadId) {
		cg__Lead_File__c newLeadFile = new cg__Lead_File__c();
		newLeadFile.cg__File_Name__c = 'MedicalSummary.txt';
		newLeadFile.cg__Lead__c = LeadId;
		newLeadFile.cg__Content_Type__c = 'text/plain';
		return newLeadFile;
	}

	public static cg__CaseFile__c createCaseFileRecord(Id caseId) {
		cg__CaseFile__c newCaseFile = new cg__CaseFile__c();
		newCaseFile.cg__File_Name__c = 'MedicalSummary.txt';
		newCaseFile.cg__Case__c = caseId;
		newCaseFile.cg__Content_Type__c = 'image';
		return newCaseFile;
	}

	public static cg__contactFile__c createContactFileRecord(Id contactId) {
		cg__ContactFile__c newContactFile = new cg__ContactFile__c();
		newContactFile.cg__File_Name__c = 'MedicalSummary.txt';
		newContactFile.cg__Contact__c = contactId;
		newContactFile.cg__Content_Type__c = 'text/plain';
		return newContactFile;
	}

	public Static Case createParentCase() {
		Case newCase = new Case();
		return newCase;
	}

	public Static dsfs__DocuSign_Recipient_Status__c CreatedsfsRec(Id dsfsStatusId) {
		dsfs__DocuSign_Recipient_Status__c newdsfs = new dsfs__DocuSign_Recipient_Status__c();
		newdsfs.dsfs__Parent_Status_Record__c = dsfsStatusId;
		newdsfs.dsfs__DocuSign_Recipient_Email__c = 'testmawa@gmail.com';
		newdsfs.Name = 'Vennila';
		newdsfs.dsfs__DocuSign_Recipient_Id__c = '98D97010-2A0B-4714-B9AE-494B74BD287F';
		newdsfs.dsfs__Envelope_Id__c = '0204C9DD-B8B3-4D7D-B9C5-F88B921E1511';
		newdsfs.dsfs__Recipient_Status__c = 'Completed';
		return newdsfs;
	}

	public Static dsfs__DocuSign_Recipient_Status__c CreatedsfsRecAsDeliver(Id dsfsStatusId) {
		dsfs__DocuSign_Recipient_Status__c newdsfs = new dsfs__DocuSign_Recipient_Status__c();
		newdsfs.dsfs__Parent_Status_Record__c = dsfsStatusId;
		newdsfs.dsfs__DocuSign_Recipient_Email__c = 'testmawa@gmail.com';
		newdsfs.Name = 'Vennila';
		newdsfs.dsfs__DocuSign_Recipient_Id__c = '98D97010-2A0B-4714-B9AE-494B74BD287F';
		newdsfs.dsfs__Envelope_Id__c = '0204C9DD-B8B3-4D7D-B9C5-F88B921E1511';
		newdsfs.dsfs__Recipient_Status__c = 'Delivered';
		return newdsfs;
	}

	public Static dsfs__DocuSign_Recipient_Status__c CreatedsfsRecAsDeliverRecord(Id dsfsStatusId) {
		dsfs__DocuSign_Recipient_Status__c newdsfs = new dsfs__DocuSign_Recipient_Status__c();
		newdsfs.dsfs__Parent_Status_Record__c = dsfsStatusId;
		newdsfs.dsfs__DocuSign_Recipient_Email__c = 'testmawa@gmail.com';
		newdsfs.Name = 'Sankar';
		newdsfs.dsfs__DocuSign_Recipient_Id__c = '98D97010-2A0B-4714-B9AE-494B74BD287F';
		newdsfs.dsfs__Envelope_Id__c = '0204C9DD-B8B3-4D7D-B9C5-F88B921E1511';
		newdsfs.dsfs__Recipient_Status__c = 'Delivered';
		return newdsfs;
	}

	// public static In_Kind_Donation_Reimbursement_File__c  createInkindDonaReimbFileRecord(Id ikdrId) {
	public static InkindDon_reimburseFile__c createInkindDonaReimbFileRecord(Id ikdrId) {
		//In_Kind_Donation_Reimbursement_File__c  newikdrFile = new In_Kind_Donation_Reimbursement_File__c  ();
		InkindDon_reimburseFile__c newikdrFile = new InkindDon_reimburseFile__c();
		newikdrFile.Parent__c = ikdrId;
		newikdrFile.File_Name__c = 'MedicalSummary.txt';
		newikdrFile.Content_Type__c = 'text/plain';
		return newikdrFile;
	}

	public static Wish_Expense_Type__c CreateWishExpenseTypeRecord() {
		Wish_Expense_Type__c currType = new Wish_Expense_Type__c();
		currType.Name = 'Airfare';
		return currType;
	}

	public static Wish_Expense_Transaction_Code__c CreateWishExpenseTransactionCodeRecord(ID wishtypeId) {
		Wish_Expense_Transaction_Code__c currtransactionCode = new Wish_Expense_Transaction_Code__c();
		currtransactionCode.Name = 'Airfare Other';
		currtransactionCode.Wish_Expense_Type__c = wishtypeId;
		currtransactionCode.Is_Active__c = true;
		return currtransactionCode;
	}

	public static Attachment CreateAttachmentRecordWishChild(Id ParentId) {
		Attachment newAttachment = new Attachment();
		newAttachment.ParentId = ParentId;
		newAttachment.Name = 'Attachment1';
		newAttachment.Body = blob.valueOf('Hi Welcome to body text');
		return newAttachment;
	}

	public static Regions__c createRegion(Id AccountId) {
		Regions__c newRegion = new Regions__c();
		newRegion.Name = 'Alabama';
		newRegion.Chapter_Name__c = AccountId;
		return newRegion;
	}

	public static Chapter_Vs_Role__c createAlabamaChapter() {
		Chapter_Vs_Role__c createRec = new Chapter_Vs_Role__c();
		createRec.Chapter_Name__c = 'Make-A-Wish Alabama';
		createRec.Role_Name__c = 'Alabama - Chapter';
		createRec.Name = 'Make-A-Wish Alabama';
		return createRec;
	}

	public static Chapter_Vs_Role__c createArizonaChapter() {
		Chapter_Vs_Role__c createRec = new Chapter_Vs_Role__c();
		createRec.Chapter_Name__c = 'Make-A-Wish Arizona';
		createRec.Role_Name__c = 'Arizona - Chapter';
		createRec.Name = 'Make-A-Wish Arizona';
		return createRec;
	}
}