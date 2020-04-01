/**
* @description Contact Service Test
* @author Gustavo Mayer, Traction on Demand
* @createdDate 2/27/2020
*/
@IsTest
public class ContactServiceTest {
    
    private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;
    private final static Id HOUSEHOLD_RT_ID = Constant_AC.HOUSEHOLD_RT_ID;
    private final static Id VOLUNTEER_RECORD_TYPE_ID = Constant_AC.VOLUNTEER_RT_ID;
    private final static Id VOLUNTEER_ORIENTATION_RECORD_TYPE_ID = Constant_AC.ORIENTATION_RT_ID;
    private final static Id VOLUNTEER_TRAINING_RECORD_TYPE_ID = Constant_AC.TRAINING_RT_ID;
    private final static Id WISH_CHILD_RECORD_TYPE_ID = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
    private final static Id WISH_FAMILY_RECORD_TYPE_ID = Constant_AC.WISH_FAMILY_RT_ID;
    private final static String BACKGROUND_CHECK_STATUS_APPROVED = 'Approved';
    private static final String VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED = 'Completed';
    private final static Id CLASS_OFFERING_RECORD_TYPE_ID = Constant_AC.CLASS_OFFERING_RECORD_TYPE_ID;
    private final static Id MEDICAL_PROFESSIONAL_RECORD_TYPE_ID = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
    
    @TestSetup
    public static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;
        List<Account> accounts = TestDataFactory.createAccount(2);
        Account arizonaChapter = accounts.get(0);
        arizonaChapter.Name = 'Make-A-Wish Arizona';
        arizonaChapter.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
        Account watkinsFamily = accounts.get(1);
        watkinsFamily.Name = 'Rebecca Watkins & Family Household';
        watkinsFamily.RecordTypeId = HOUSEHOLD_RT_ID;
        watkinsFamily.BillingStreet = '100 Cactus Road';
        watkinsFamily.BillingCity = 'Phoenix';
        watkinsFamily.BillingState = 'Arizona';
        watkinsFamily.BillingCountry = 'United States';
        watkinsFamily.BillingPostalCode = '85260';
        insert accounts;
        
        List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
        insert icdCodes;
        
        List<Wish_Child_Form__c> wishForms = TestDataFactory.createWishForm(1);
        Wish_Child_Form__c wishForm1 = wishForms.get(0);
        wishForm1.Migrated__c = false;
        insert wishForms;
        
        List<Contact> contacts = TestDataFactory.createContact(8);
        Contact volunteerArizona = contacts.get(0);
        volunteerArizona.RecordTypeId = VOLUNTEER_RECORD_TYPE_ID;
        volunteerArizona.AccountId = arizonaChapter.Id;
        volunteerArizona.FirstName = 'Jack';
        volunteerArizona.LastName = 'Smith';
        volunteerArizona.Email = 'ms@email.com';
        volunteerArizona.Phone = '12345678';
        volunteerArizona.Birthdate = Date.today().addYears(-10);
        volunteerArizona.MailingPostalCode = '12345-9876';
        volunteerArizona.MailingStreet = 'Jack Street';
        volunteerArizona.MailingCountry = 'United States';
        volunteerArizona.MailingState = 'Arizona';
        volunteerArizona.MailingCity = 'Phoenix';
        Contact volunteerNewYork = contacts.get(1);
        volunteerNewYork.RecordTypeId = VOLUNTEER_RECORD_TYPE_ID;
        volunteerNewYork.AccountId = arizonaChapter.Id;
        volunteerNewYork.FirstName = 'Jack';
        volunteerNewYork.LastName = 'Smith';
        volunteerNewYork.Email = 'ms@email.com';
        volunteerNewYork.Phone = '12345678';
        volunteerNewYork.Birthdate = Date.today().addYears(-10);
        volunteerNewYork.MailingPostalCode = '12345-9876';
        volunteerNewYork.MailingStreet = 'Jack Street';
        volunteerNewYork.MailingCountry = 'United States';
        volunteerNewYork.MailingState = 'New York';
        volunteerNewYork.MailingCity = 'New York';
        Contact wishChildContact1 = contacts.get(2);
        wishChildContact1.AccountId = arizonaChapter.Id;
        wishChildContact1.FirstName = 'Jack';
        wishChildContact1.LastName = 'Smith';
        wishChildContact1.ICD_10_Code__c = icdCodes[0].Id;
        wishChildContact1.Birthdate = Date.today().addYears(-10);
        wishChildContact1.MailingPostalCode = '12345-9876';
        wishChildContact1.MailingStreet = 'Jack Street';
        wishChildContact1.MailingCountry = 'United States';
        wishChildContact1.MailingState = 'Arizona';
        wishChildContact1.MailingCity = 'Phoenix';
        Contact wishChildContact2 = contacts.get(3);
        wishChildContact2.RecordTypeId = WISH_CHILD_RECORD_TYPE_ID;
        wishChildContact2.AccountId = watkinsFamily.Id;
        wishChildContact2.FirstName = 'Rebecca';
        wishChildContact2.LastName = 'Watkins';
        wishChildContact2.Birthdate = Date.today().addYears(-10);
        wishChildContact2.MailingPostalCode = '12345-9876';
        wishChildContact2.MailingStreet = 'Cactus Road';
        wishChildContact2.MailingCountry = 'United States';
        wishChildContact2.MailingState = 'Arizona';
        wishChildContact2.MailingCity = 'Phoenix';
        wishChildContact2.Email = 'e.watkins@mail.com';
        wishChildContact2.Recipient_Email__c = 'e.watkins@mail.com';
        wishChildContact2.First_Recipient_Name__c = 'Emily Watkins';
        wishChildContact2.Second_Recipient_Email__c = 'j.watkins@mail.com';
        wishChildContact2.Second_Recipient_Name__c = 'Joel Watkins';
        wishChildContact2.Hidden_Wish_Form_Id__c = wishForm1.Id;
        wishChildContact2.Same_as_Household_Address__c = true;
        wishChildContact2.Hidden_First_Name__c = 'Rebecca';
        wishChildContact2.Hidden_Last_Name__c = 'Watkins';
        wishChildContact2.HiddenMobilePhone__c = '9876598555';
        wishChildContact2.Hidden_Work_Phone__c = '5208209898';
        wishChildContact2.HiddenOtherPhone__c = '5208209898';
        wishChildContact2.MailingPostalCode = '12345-9876';
        wishChildContact2.MailingStreet = 'Cactus Road';
        wishChildContact2.MailingCountry = 'United States';
        wishChildContact2.MailingState = 'Arizona';
        wishChildContact2.MailingCity = 'Phoenix';
        wishChildContact2.Hidden_Zip_Code__c = '85260';
        wishChildContact2.Hidden_Email__c = 'e.watkins@mail.com';
        wishChildContact2.Hidden_Preferred_Phone_Types__c = 'Mobile';
        wishChildContact2.Hidden_Street__c = '100 Cactus Road';
        wishChildContact2.Hidden_city__c = 'Phoenix';
        wishChildContact2.Hidden_State__c = 'Arizona';
        wishChildContact2.Hidden_Country__c = 'United States';
        wishChildContact2.Hidden_Zip_Code__c = '85260';
        wishChildContact2.IsContactInfoUpdated__c = true;
        Contact wishChildContact2Mother = contacts.get(4);
        wishChildContact2Mother.RecordTypeId = WISH_FAMILY_RECORD_TYPE_ID;
        wishChildContact2Mother.FirstName = 'Emily';
        wishChildContact2Mother.LastName = 'Watkins';
        wishChildContact2Mother.Email = 'e.watkins@mail.com';
        wishChildContact2Mother.MailingPostalCode = '12345-9876';
        wishChildContact2Mother.MailingStreet = 'Cactus Road';
        wishChildContact2Mother.MailingCountry = 'United States';
        wishChildContact2Mother.MailingState = 'Arizona';
        wishChildContact2Mother.MailingCity = 'Phoenix';
        wishChildContact2Mother.Hidden_Zip_Code__c = '85260';
        wishChildContact2Mother.Relationship__c = 'Mother';
        Contact wishChildContact2Father = contacts.get(5);
        wishChildContact2Father.RecordTypeId = WISH_FAMILY_RECORD_TYPE_ID;
        wishChildContact2Father.FirstName = 'Joel';
        wishChildContact2Father.LastName = 'Watkins';
        wishChildContact2Father.Relationship__c = 'Father';
        wishChildContact2Father.Phone = '5558956789';
        wishChildContact2Father.MobilePhone = '9876598555';
        wishChildContact2Father.HomePhone = '5558956789';
        wishChildContact2Father.npe01__PreferredPhone__c = '9876598555';
        wishChildContact2Father.OtherPhone = '5208209898';
        wishChildContact2Father.npe01__WorkPhone__c = '5208209898';
        wishChildContact2Father.Hidden_First_Name__c = 'Joel';
        wishChildContact2Father.Hidden_Last_Name__c = 'Watkins';
        wishChildContact2Father.HiddenMobilePhone__c = '9876598555';
        wishChildContact2Father.Hidden_Work_Phone__c = '5208209898';
        wishChildContact2Father.HiddenOtherPhone__c = '5208209898';
        wishChildContact2Father.MailingPostalCode = '12345-9876';
        wishChildContact2Father.MailingStreet = 'Cactus Road';
        wishChildContact2Father.MailingCountry = 'United States';
        wishChildContact2Father.MailingState = 'Arizona';
        wishChildContact2Father.MailingCity = 'Phoenix';
        wishChildContact2Father.Hidden_Zip_Code__c = '85260';
        wishChildContact2Father.Hidden_Email__c = 'j.watkins@mail.com';
        wishChildContact2Father.Hidden_Preferred_Phone_Types__c = 'Mobile';
        wishChildContact2Father.Hidden_Street__c = '100 Cactus Road';
        wishChildContact2Father.Hidden_city__c = 'Phoenix';
        wishChildContact2Father.Hidden_State__c = 'Arizona';
        wishChildContact2Father.Hidden_Country__c = 'United States';
        wishChildContact2Father.Hidden_Zip_Code__c = '85260';
        Contact volunteerArizona2 = contacts.get(6);
        volunteerArizona2.RecordTypeId = VOLUNTEER_RECORD_TYPE_ID;
        volunteerArizona2.AccountId = arizonaChapter.Id;
        volunteerArizona2.FirstName = 'Abby';
        volunteerArizona2.Middle_Name__c = 'Rose';
        volunteerArizona2.LastName = 'Jones';
        volunteerArizona2.Email = 'a.jones@email.com';
        volunteerArizona2.Phone = '12345678';
        volunteerArizona2.MailingPostalCode = '12345-9876';
        volunteerArizona2.MailingStreet = 'Highland Avenue';
        volunteerArizona2.MailingCountry = 'United States';
        volunteerArizona2.MailingState = 'Arizona';
        volunteerArizona2.MailingCity = 'Phoenix';
        volunteerArizona2.is_Application__c = 'Submitted';
        volunteerArizona2.Migrated_Record__c = true;
        volunteerArizona2.Do_Not_Create_User__c = false;
        Contact medProfessional = contacts.get(7);
        medProfessional.RecordTypeId = MEDICAL_PROFESSIONAL_RECORD_TYPE_ID;
        medProfessional.FirstName = 'Lewis';
        medProfessional.LastName = 'Hall';
        medProfessional.Email = 'l.hall@email.com';
        medProfessional.Phone = '12345678';
        medProfessional.MailingPostalCode = '12345-9876';
        medProfessional.MailingStreet = 'Highland Avenue';
        medProfessional.MailingCountry = 'United States';
        medProfessional.MailingState = 'Arizona';
        medProfessional.MailingCity = 'Phoenix';
        insert contacts;
        
        List<npe4__Relationship__c> relationships = TestDataFactory.createRelationship(3);
        npe4__Relationship__c relationship1 = relationships.get(0);
        relationship1.npe4__Contact__c = wishChildContact2.Id;
        relationship1.npe4__RelatedContact__c = wishChildContact2Mother.Id;
        npe4__Relationship__c relationship2 = relationships.get(1);
        relationship2.npe4__Contact__c = wishChildContact2.Id;
        relationship2.npe4__RelatedContact__c = medProfessional.Id;
        relationship2.Qualifying_Medical_Professional__c = true;
        relationship2.npe4__Status__c = 'Active';
        npe4__Relationship__c relationship3 = relationships.get(2);
        relationship3.npe4__Contact__c = wishChildContact2.Id;
        relationship3.npe4__RelatedContact__c = wishChildContact2Father.Id;
        insert relationships;
        
        List<npe5__Affiliation__c> affiliations = TestDataFactory.createAffiliation(1);
        npe5__Affiliation__c affiliation1 = affiliations.get(0);
        affiliation1.npe5__Contact__c = volunteerArizona2.Id;
        affiliation1.npe5__Organization__c = arizonaChapter.Id;
        affiliation1.npe5__Status__c = 'Pending';
        insert affiliations;
        
        List<Role__c> roles = TestDataFactory.createRole(2, true);
        Role__c wishGranterRole = roles.get(0);
        wishGranterRole.Name = 'Wish Granter';
        Role__c wishGranterMentorRole = roles.get(1);
        wishGranterMentorRole.Name = 'Wish Granter Mentor';
        insert roles;
        
        List<Chapter_Role__c> chapterRoles = TestDataFactory.createChapterRole(3);
        Chapter_Role__c wishGranterArizonaRole = chapterRoles.get(0);
        wishGranterArizonaRole.Chapter_Name__c = arizonaChapter.Id;
        wishGranterArizonaRole.Role_Name__c = wishGranterRole.Id;
        wishGranterArizonaRole.Background_Check_Required__c = true;
        wishGranterArizonaRole.COI_Required__c = true;
        Chapter_Role__c wishGranterNewYorkRole = chapterRoles.get(1);
        wishGranterNewYorkRole.Chapter_Name__c = arizonaChapter.Id;
        wishGranterNewYorkRole.Role_Name__c = wishGranterRole.Id;
        wishGranterNewYorkRole.Background_Check_Required__c = true;
        wishGranterNewYorkRole.COI_Required__c = true;
        Chapter_Role__c wishGranterMentorChapterRole = chapterRoles.get(2);
        wishGranterMentorChapterRole.Chapter_Name__c = arizonaChapter.Id;
        wishGranterMentorChapterRole.Role_Name__c = wishGranterRole.Id;
        wishGranterMentorChapterRole.Background_Check_Required__c = false;
        wishGranterMentorChapterRole.COI_Required__c = false;
        insert chapterRoles;
        
        List<Volunteer_Roles__c> volunteerRoles = TestDataFactory.createVolunteerRole(2);
        Volunteer_Roles__c volunteerRoleArizonaPending = volunteerRoles.get(0);
        volunteerRoleArizonaPending.Chapter_Role__c = wishGranterArizonaRole.Id;
        volunteerRoleArizonaPending.Volunteer_Name__c = volunteerArizona.Id;
        volunteerRoleArizonaPending.Status__c = 'Active';
        Volunteer_Roles__c volunteerRoleActive = volunteerRoles.get(1);
        volunteerRoleActive.Chapter_Role__c = wishGranterMentorChapterRole.Id;
        volunteerRoleActive.Volunteer_Name__c = volunteerArizona.Id;
        volunteerRoleActive.Status__c = 'Active';
        insert volunteerRoles;
        
        List<Orientation_Training__c> orientationTrainings = TestDataFactory.createOrientationTraining(2);
        Orientation_Training__c orientation = orientationTrainings.get(0);
        orientation.RecordTypeId = VOLUNTEER_ORIENTATION_RECORD_TYPE_ID;
        Orientation_Training__c training = orientationTrainings.get(1);
        training.RecordTypeId = VOLUNTEER_TRAINING_RECORD_TYPE_ID;
        insert orientationTrainings;
        
        List<Chapter_Role_O_T__c> chapterRoleOTs = TestDataFactory.createChapterRoleOrientationAndTraining(2);
        Chapter_Role_O_T__c chapterRoleOTOrientation = chapterRoleOTs.get(0);
        chapterRoleOTOrientation.Orientation_Training__c = orientation.Id;
        chapterRoleOTOrientation.Chapter_Role__c = wishGranterArizonaRole.Id;
        chapterRoleOTOrientation.Required__c = true;
        Chapter_Role_O_T__c chapterRoleOTTraining = chapterRoleOTs.get(1);
        chapterRoleOTTraining.Orientation_Training__c = training.Id;
        chapterRoleOTTraining.Chapter_Role__c = wishGranterMentorChapterRole.Id;
        chapterRoleOTTraining.Required__c = true;
        insert chapterRoleOTs;
        
        List<Conflict_Of_Interest__c> conflictOfInterests = TestDataFactory.createConflictOfInterest(1);
        Conflict_Of_Interest__c conflictOfInterest = conflictOfInterests.get(0);
        conflictOfInterest.Current__c = true;
        conflictOfInterest.Account_Name__c = arizonaChapter.Name;
        conflictOfInterest.Volunteer_Contact__c = volunteerArizona.Id;
        insert conflictOfInterests;
        
        List<Background_check__c> backgroundChecks = TestDataFactory.createBackgroundCheck(1);
        Background_check__c backgroundCheck = backgroundChecks.get(0);
        backgroundCheck.Current__c = true;
        backgroundCheck.Volunteer__c = volunteerArizona.Id;
        backgroundCheck.Status__c = BACKGROUND_CHECK_STATUS_APPROVED;
        backgroundCheck.Date_Completed__c = Date.today();
        insert backgroundChecks;
        
        List<Class_Offering__c> classOfferings = TestDataFactory.createClassOffering(2);
        Class_Offering__c classOfferingOrientation = classOfferings.get(0);
        classOfferingOrientation.Chapter_Role_O_T__c = chapterRoleOTOrientation.Id;
        classOfferingOrientation.Date__c = System.today() + 10;
        classOfferingOrientation.RecordTypeId = CLASS_OFFERING_RECORD_TYPE_ID;
        Class_Offering__c classOfferingTraining = classOfferings.get(1);
        classOfferingTraining.Chapter_Role_O_T__c = chapterRoleOTTraining.Id;
        classOfferingTraining.Date__c = System.today() + 10;
        classOfferingTraining.RecordTypeId = CLASS_OFFERING_RECORD_TYPE_ID;
        insert classOfferings;
        
        List<Volunteer_Orientation_Training__c> volunteerOrientationTrainings = TestDataFactory.createVolunteerOrientationAndTraining(2);
        Volunteer_Orientation_Training__c volunteerOrientation = volunteerOrientationTrainings.get(0);
        volunteerOrientation.Volunteer_Attendance__c = VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED;
        volunteerOrientation.Volunteer__c = volunteerArizona.Id;
        volunteerOrientation.Class_Offering__c = classOfferingOrientation.Id;
        Volunteer_Orientation_Training__c volunteerTraining = volunteerOrientationTrainings.get(1);
        volunteerTraining.Volunteer_Attendance__c = VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED;
        volunteerTraining.Volunteer__c = volunteerArizona.Id;
        volunteerTraining.Class_Offering__c = classOfferingTraining.Id;
        insert volunteerOrientationTrainings;
        
        List<Volunteer_Opportunity__c> volunteerOpportunities = TestDataFactory.createVolunteerOpportunity(1);
        Volunteer_Opportunity__c volunteerOpportunity = volunteerOpportunities.get(0);
        volunteerOpportunity.Volunteer_Name__c = volunteerArizona.Id;
        volunteerOpportunity.RecordTypeId = Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID;
        volunteerOpportunity.Chapter_Role_Opportunity__c = wishGranterArizonaRole.Id;
        volunteerOpportunity.Status__c = 'Approved';
        insert volunteerOpportunities;
        
        insert TestDataFactory.createQualifiedLead(arizonaChapter.Id, icdCodes[0].Id);
        trac_TriggerHandlerBase.blockTrigger = false;
    }

	@IsTest
	public static void shouldChangeVolunteerContactActive() {
		List<Contact> contacts = [
				SELECT Id, B_C_Expiration_Date__c, COI_Expiration_Date__c,
						Active_Board_Member__c, Active_Wish_Granter__c,
						Active_Non_Wish_Granter__c, Active_Single_Day_Event_Volunteer__c
				FROM Contact
				WHERE Name = 'Jack Smith'
		];

		Map<Id, Contact> contactMap = new Map<Id, Contact>(contacts);
		Test.startTest();
		Map<Id, Contact> result = ContactService.setVolunteerContactActive(contactMap);
		Test.stopTest();
		System.assertEquals(1, result.size());
	}

	@IsTest
	public static void shouldFindDuplicatedContacts() {
		String firstName = 'Jack';
		String lastName = 'Smith';
		String email = 'ms@email.com';

		Test.startTest();
		List<Contact> result = ContactService.findDuplicatedContacts(
				firstName, lastName, null, email, new List<Id>{
						VOLUNTEER_RECORD_TYPE_ID
				}
		);
		Test.stopTest();
		System.assertEquals(2, result.size());
	}

	@IsTest
	public static void shouldFindChildDuplicatedContacts() {
		String firstName = 'Jack';
		String lastName = 'Smith';
		String email = 'ms@email.com';
		Date dateOfBirth = Date.today().addYears(-10);
		String street = 'Jack Street';
		String state = 'Arizona';
		String city = 'Phoenix';
		String postalCode = '12345-9876';

		Test.startTest();
		List<Contact> result = ContactService.findChildDuplicatedContacts(
				firstName, lastName, null, email, street,
				city, state, postalCode, dateOfBirth, new List<Id>{
						VOLUNTEER_RECORD_TYPE_ID
				}
		);
		Test.stopTest();
		System.assertEquals(2, result.size());
	}

	@IsTest
	public static void shouldFindFamilyDuplicatedContacts() {
		String firstName = 'Jack';
		String lastName = 'Smith';
		String email = 'ms@email.com';
		String phone = '12345678';
		String street = 'Jack Street';
		String state = 'Arizona';
		String city = 'Phoenix';
		String postalCode = '12345-9876';

		Test.startTest();
		List<Contact> result = ContactService.findFamilyDuplicatedContacts(
				firstName, lastName, phone, email, street,
				city, state, postalCode, new List<Id>{
						VOLUNTEER_RECORD_TYPE_ID
				}
		);
		Test.stopTest();
		System.assertEquals(2, result.size());
	}

	@IsTest
	public static void shouldBuildWishChild() {
		List<Contact> childContacts = [
				SELECT FirstName, LastName, Id, AccountId, Department, Provider_Type__c, Language__c,
						Self_describe_comment_box__c, Migrated_Record__c, Lead_Created_Date__c,
						Relationship_to_Wish_Child__c, Referrer_FirstName__c, Referrer_Last_Name__c, Referrer_Phone__c,
						Referrer_Email__c, Referrer_City__c, Referrer_Zip__c, Relationship__c,
						Inquiry_Referral_Method__c, Is_Family_Aware_of_Referral__c, Parent_Guardian_Name__c,
						RecordTypeId, MailingCity, OwnerId, MailingState, MailingPostalCode,
						Wish_How_Did_you_hear_about_Make_A_Wish__c, Other_Medical_Provider_Category__c
				FROM Contact
				WHERE Name = 'Jack Smith'
		];
		List<Lead> leads = [
				SELECT CreatedDate, DOB__c, Medical_Provider_Category__c, Self_describe_comment_box__c,
						What_is_the_family_s_primary_spoken_lang__c, ChapterName__c, LeadSource, Referrer_City__c,
						Referrer_Email__c, Referrer_FirstName__c, Referrer_Last_Name__c, Referrer_Phone__c,
						Referrer_Zip__c, Relationship_to_child__c, Other_Medical_Provider_Category__c,
						Other_Relationship_To_Child__c, is_Family_Aware_of_Referral__c, Migrated_Record__c,
						How_Did_you_hear_about_Make_A_Wish__c, Additional_Parent_City__c, City,
						Additional_Parent_Postal_Code__c, PostalCode, Additional_Parent_State__c, State,
						Additional_Parent_Street__c, Street, Treating_Medical_Professional_First_Name__c,
						Treating_Medical_Professional_Last_Name__c, Gender__c, Salutation
				FROM Lead
				WHERE Name = 'Mark Smith'
		];

		Test.startTest();
		Contact result = ContactService.buildWishChildFromLead(childContacts[0], leads[0]);
		Test.stopTest();

		System.assertEquals('Referrer', result.Referrer_FirstName__c);
	}

	@IsTest
	public static void shouldBuildSibling() {
		List<Contact> childContacts = [
				SELECT FirstName, LastName, Id, AccountId
				FROM Contact
				WHERE Name = 'Jack Smith'
		];
		List<Account> accounts = [
				SELECT Id
				FROM Account
				WHERE Name = 'Make-A-Wish Arizona'
		];

		Test.startTest();
		Contact result = ContactService.buildSibling('Sibling1', 'Smith', '2', childContacts[0].Id,
				childContacts[0].AccountId, accounts[0].Id, 'English');
		Test.stopTest();

		System.assertEquals('Smith', result.LastName);
	}

	@IsTest
	public static void shouldBuildParentLegalGuardianFromLead() {
		List<Lead> leads = [
				SELECT Parent_First_Name__c, Parent_Last_Name__c, Email, Phone, CountryCode, Street, StateCode,
						City, PostalCode, ConvertedContactId, ConvertedAccountId, ChapterName__c,
						What_is_the_family_s_primary_spoken_lang__c, Parent_Relationship_to_Child__c, Migrated_Record__c,
						Relationship_to_child__c
				FROM Lead
				WHERE Name = 'Mark Smith'
		];

		Test.startTest();
		Contact result = ContactService.buildParentLegalGuardianFromLead(leads[0]);
		Test.stopTest();

		System.assertEquals('Father', result.FirstName);
	}

	@IsTest
	public static void shouldBuildAdditionalParentLegalGuardianFromLead() {
		List<Lead> leads = [
				SELECT Additional_Parent_First_Name__c, Additional_Parent_Last_Name__c, Additional_Parent_Email__c,
						Additional_Parent_Phone__c, CountryCode, Additional_Parent_Street__c,
						Additional_Parent_State__c, Additional_Parent_City__c, Additional_Parent_Postal_Code__c,
						ConvertedContactId, ConvertedAccountId, Additional_Parent_Relationship_to_Child__c,
						Migrated_Record__c, ChapterName__c, City, PostalCode, State, Street
				FROM Lead
				WHERE Name = 'Mark Smith'
		];

		Test.startTest();
		Contact result = ContactService.buildAdditionalParentLegalGuardianFromLead(leads[0]);
		Test.stopTest();

		System.assertEquals('Mother', result.FirstName);
	}

	@IsTest
	public static void shouldBuildBestTreatingReferrerMedicalProfessionalFromLead_WhenReferrerSameAsTreating() {
		List<Lead> leads = [
				SELECT Referrer_FirstName__c, Referrer_Last_Name__c, I_am_Recognized_To_Practice_As_a__c,
						Medical_Provider_Category__c, Referrer_Phone__c, Referrer_Email__c, ChapterName__c,
						Migrated_Record__c, Hospital_Treatment_Facility_Treating__c, Best_Contact_for_Physician_First_Name__c,
						Best_Contact_for_Physician_Last_Name__c, Best_contact_for_Physician_Email__c,
						Hidden_DV_form_Medical_professional_Type__c
				FROM Lead
				WHERE Name = 'Mark Smith'
		];
		Map<String, Account> medicalAccountMap = new Map<String, Account>();

		Test.startTest();
		Contact result = ContactService.buildBestTreatingReferrerMedicalProfessionalFromLead(leads[0], medicalAccountMap);
		Test.stopTest();

		System.assertEquals('Referrer', result.FirstName);
		System.assertEquals('Referrer&Treating', result.Type_of_Contact__c);
	}

	@IsTest
	public static void shouldBuildBestTreatingReferrerMedicalProfessionalFromLead_WhenReferrerSameAsBest() {
		List<Lead> leads = [
				SELECT Referrer_FirstName__c, Referrer_Last_Name__c, I_am_Recognized_To_Practice_As_a__c,
						Medical_Provider_Category__c, Referrer_Phone__c, Referrer_Email__c, ChapterName__c,
						Migrated_Record__c, Hospital_Treatment_Facility_Treating__c, Best_Contact_for_Physician_First_Name__c,
						Best_Contact_for_Physician_Last_Name__c, Best_contact_for_Physician_Email__c,
						Hidden_DV_form_Medical_professional_Type__c
				FROM Lead
				WHERE Name = 'Mark Smith'
		];
		Map<String, Account> medicalAccountMap = new Map<String, Account>();
		leads[0].Best_Contact_for_Physician_First_Name__c = leads[0].Referrer_FirstName__c;
		leads[0].Best_Contact_for_Physician_Last_Name__c = leads[0].Referrer_Last_Name__c;
		leads[0].Best_contact_for_Physician_Email__c = leads[0].Referrer_Email__c;

		Test.startTest();
		Contact result = ContactService.buildBestTreatingReferrerMedicalProfessionalFromLead(leads[0], medicalAccountMap);
		Test.stopTest();

		System.assertEquals('Referrer', result.FirstName);
		System.assertEquals('Referrer&Best', result.Type_of_Contact__c);
	}

	@IsTest
	public static void shouldBuildReferrerMedicalProfessionalFromLead() {
		List<Lead> leads = [
				SELECT Referrer_FirstName__c, Referrer_Last_Name__c, ChapterName__c,
						Medical_Provider_Category__c, Referrer_Phone__c, Referrer_Email__c,
						Migrated_Record__c, Department__c
				FROM Lead
				WHERE Name = 'Mark Smith'
		];

		Test.startTest();
		Contact result = ContactService.buildReferrerMedicalProfessionalFromLead(leads[0]);
		Test.stopTest();

		System.assertEquals('Referrer', result.FirstName);
	}

	@IsTest
	public static void shouldBuildTreatingMedicalProfessionalFromLead() {
		List<Lead> leads = [
				SELECT Treating_Medical_Professional_First_Name__c, Treating_Medical_Professional_Last_Name__c,
						ChapterName__c, Treating_Medical_Professional_Phone__c,
						Treating_Medical_Professional_Email__c, Migrated_Record__c,
						Hospital_Treatment_Facility_Treating__c, Department__c,
						Hidden_DV_form_Medical_professional_Type__c, I_am_Recognized_To_Practice_As_a__c
				FROM Lead
				WHERE Name = 'Mark Smith'
		];
		Map<String, Account> medicalAccountMap = new Map<String, Account>();

		Test.startTest();
		Contact result = ContactService.buildTreatingMedicalProfessionalFromLead(leads[0], medicalAccountMap);
		Test.stopTest();

		System.assertEquals('TreatingMedicalProfessional', result.FirstName);
	}

	@IsTest
	public static void shouldBuildBestMedicalProfessionalFromLead() {
		List<Lead> leads = [
				SELECT Best_Contact_for_Physician_First_Name__c, Best_Contact_for_Physician_Last_Name__c, ChapterName__c,
						Best_contact_for_Physician_Email__c, Migrated_Record__c, Department__c,
						Hospital_Treatment_Facility_Treating__c
				FROM Lead
				WHERE Name = 'Mark Smith'
		];
		Map<String, Account> medicalAccountMap = new Map<String, Account>();

		Test.startTest();
		Contact result = ContactService.buildBestMedicalProfessionalFromLead(leads[0], medicalAccountMap);
		Test.stopTest();

		System.assertEquals('Best', result.FirstName);
	}

	@IsTest
	public static void shouldBuildAlternate1MedicalProfessionalFromLead() {
		List<Lead> leads = [
				SELECT Alternate1MedProfessionalFirstName__c, Alternate1MedProfessionalLastName__c, ChapterName__c,
						Alternate1MedProfessionalPhone__c, Alternate_1_Medical_Professional_Type__c, Migrated_Record__c,
						Alternate1HospitalTreatmentFacility__c, Alternate1MedicalProfessionalEmail__c, Department__c,
						Hidden_DV_form_Medical_professional_Type__c, I_am_Recognized_To_Practice_As_a__c
				FROM Lead
				WHERE Name = 'Mark Smith'
		];
		Map<String, Account> medicalAccountMap = new Map<String, Account>();

		Test.startTest();
		Contact result = ContactService.buildAlternate1MedicalProfessionalFromLead(leads[0], medicalAccountMap);
		Test.stopTest();

		System.assertEquals('Alt1MedicalProfessional', result.FirstName);
	}

	@IsTest
	public static void shouldBuildAlternate2MedicalProfessionalFromLead() {
		List<Lead> leads = [
				SELECT Alternate2MedProfessionalFirstName__c, Alternate2MedProfessionalLastName__c, ChapterName__c,
						Alternate2MedProfessionalPhone__c, Alternate_2_Medical_Professional_Type__c, Migrated_Record__c,
						Alternate2HospitalTreatmentFacility__c, Alternate2MedProfessionalEmail__c, Department__c,
						Hidden_DV_form_Medical_professional_Type__c, I_am_Recognized_To_Practice_As_a__c
				FROM Lead
				WHERE Name = 'Mark Smith'
		];
		Map<String, Account> medicalAccountMap = new Map<String, Account>();

		Test.startTest();
		Contact result = ContactService.buildAlternate2MedicalProfessionalFromLead(leads[0], medicalAccountMap);
		Test.stopTest();

		System.assertEquals('Alt2MedicalProfessional', result.FirstName);
	}
    
    @isTest
    private static void validateCreateAffiliations() {
        Test.startTest();
        Map<Id, Contact> contactMap = new Map<Id, Contact>([
            SELECT Id, RecordTypeId, Name, AccountId, Hidden_Hospital_Account__c, Region_Chapter__c 
            FROM Contact
        ]);
        ContactService.createAffiliation(contactMap.values());
        List<npe5__Affiliation__c> affiliationList = [
            SELECT Id 
            FROM npe5__Affiliation__c 
            WHERE npe5__Contact__c IN :contactMap.keySet()];
        Test.stopTest();
        System.assert(!affiliationList.isEmpty());
    }
    
    @isTest
    private static void validateUpdateWishFormContact() {
        Test.startTest();
        Map<Id, Contact> contactMap = new Map<Id, Contact>([
            SELECT Id, RecordTypeId, Hidden_Wish_Form_Id__c
            FROM Contact
            WHERE Hidden_Wish_Form_Id__c != null
        ]);
        Set<Id> wishFormIds = new Set<Id>();
        for(Contact contact : contactMap.values()) {
            wishFormIds.add(contact.Hidden_Wish_Form_Id__c);
        }
        ContactService.updateWishFormContact(contactMap.values());
        List<Wish_Child_Form__c> wishFormListUpdated = [
            SELECT Id, Contact__c 
            FROM Wish_Child_Form__c 
            WHERE Id IN :wishFormIds];
        Test.stopTest();
        System.assert(wishFormListUpdated[0].Contact__c != null);
    }
    
    @isTest
    private static void validateUpdateFamilyContactDetails() {
        Set<Id> wishChildIdSet = new Set<Id>();
        Map<Id, Id> childPreferredRelationMap = new Map<Id, Id>();
        for(npe4__Relationship__c relationship : [SELECT Id, npe4__Contact__c, npe4__RelatedContact__c FROM npe4__Relationship__c]) {
            wishChildIdSet.add(relationship.npe4__Contact__c);
            childPreferredRelationMap.put(relationship.npe4__Contact__c, relationship.Id);
        }
        Map<Id, Contact> wishChildContactMap = new Map<Id, Contact>();
        for(Contact contact: [SELECT Id, Hidden_Current_Pref_Con_Rel_Id__c FROM Contact WHERE Id IN :wishChildIdSet]) {
            if(childPreferredRelationMap.containsKey(contact.Id)) {
                contact.Hidden_Preferred_Contact_Rel_Id__c = childPreferredRelationMap.get(contact.Id);
                wishChildContactMap.put(contact.Hidden_Preferred_Contact_Rel_Id__c, contact);
            }
        }
        ContactService.updateFamilyContactDetails(wishChildIdSet, wishChildContactMap, wishChildIdSet);
        List<npe4__Relationship__c> updatedRelationships = [
            SELECT Id, Hidden_Preferred_Contact__c 
            FROM npe4__Relationship__c 
            WHERE Id IN :childPreferredRelationMap.values()];
        System.assert(updatedRelationships[0].Hidden_Preferred_Contact__c == true);
    }
    
    @isTest
    private static void validateUpdateHiddenContactFields() {
        Test.startTest();
        Set<Id> contactIdHiddenFieldSet = new Set<Id>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>([
            SELECT Id, RecordTypeId, Hidden_Zip_Code__c
            FROM Contact
        ]);
        for(Contact contact: contactMap.values()) {
            if(contact.Hidden_Zip_Code__c != null && contact.RecordTypeId == WISH_FAMILY_RECORD_TYPE_ID) {
                contactIdHiddenFieldSet.add(contact.Id);
            }
        }
        ContactService.updateContactHiddenFields(contactMap.keySet());
        List<Contact> updatedContacts = [
            SELECT Id, Hidden_Zip_Code__c 
            FROM Contact 
            WHERE Id IN :contactIdHiddenFieldSet
        ];
        Test.stopTest();
        System.assert(updatedContacts[0].Hidden_Zip_Code__c == null);
    }
    
    @isTest
    private static void validateUpdateOrgAffiliationStatus() {
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        for(Contact contact: [SELECT Id, is_Application__c
                              FROM Contact 
                              WHERE is_Application__c != null]) {
                contact.is_Application__c = 'Rejected';
                contactMap.put(contact.Id, contact);
        }
        Test.startTest();
        ContactService.updateOrgAffiliationStatus(contactMap);
        List<npe5__Affiliation__c> affiliationList = [SELECT Id, npe5__Status__c 
                                                      FROM npe5__Affiliation__c
                                                      WHERE npe5__Contact__c IN :contactMap.keySet()];
        Test.stopTest();
        System.assert(affiliationList[0].npe5__Status__c == 'Not Approved');
    }
    
    @isTest
    private static void validateUpdateMedicalProfessional() {
        Test.startTest();
        Map<Id, Contact> contactMap = new Map<Id, Contact>([
            SELECT Id 
            FROM Contact 
            WHERE RecordTypeId = :MEDICAL_PROFESSIONAL_RECORD_TYPE_ID]);
        ContactService.updateMedicalProfessional(contactMap.keySet());
        Set<Id> contactIdSet = new Set<Id>();
        for(npe4__Relationship__c relationship : [SELECT Id, npe4__Contact__c 
                                                  FROM npe4__Relationship__c 
                                                  WHERE npe4__RelatedContact__c IN :contactMap.keySet()]) {
            contactIdSet.add(relationship.npe4__Contact__c);
        }
        List<Contact> contactsUpdatedList = [
            SELECT Id, Hidden_Medical_Physician__c, Hidden_Medical_Physician_Email__c 
            FROM Contact 
            WHERE Id IN :contactIdSet];
        Test.stopTest();
        System.assert(contactsUpdatedList[0].Hidden_Medical_Physician__c != null);
    }
    
    @isTest
    private static void validateUpdateEmailAddress() {
        //SCC-79 need to set relationship.Parent_Legal_Guardian__c = true but causes test failure due to RelationshipOnAfterInsertTriggerHandler
        List<Contact> contactList = new List<Contact>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        for(Contact contact : [SELECT Id, FirstName, LastName, Name, Email FROM Contact WHERE Email != null]) {
            contactMap.put(contact.Id, contact);
            Contact updateContact = new Contact();
            updateContact.Id = contact.Id;
            updateContact.Email = 'updateAddress@mail.com';
            updateContact.FirstName = contact.FirstName;
            updateContact.LastName = contact.LastName;
            contactList.add(updateContact);
        }
        Test.startTest();
        ContactService.updateEmailAddress(contactList, contactMap);
        Test.stopTest();
    }
    
    @isTest
    private static void validateUpdateHouseHoldAddress() {
        test.startTest();
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        for(Contact contact : [SELECT Id, AccountId FROM Contact WHERE Same_as_Household_Address__c = true]) {
            contactIdSet.add(contact.Id);
            accountIdSet.add(contact.AccountId);
        }
        List<Account> householdAccountList = [SELECT Id, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode 
                                              FROM Account WHERE Id IN :accountIdSet];
        ContactService.updateHouseHoldAddress(contactIdSet);
        test.stopTest();
        List<Contact> updatedContacts = [SELECT Id, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode
                                         FROM Contact 
                                         WHERE Id IN :contactIdSet 
                                         AND AccountId IN :accountIdSet];
    }
    
    @isTest
    private static void validateUpdateRelationship() {
        Test.startTest();
        Map<Id, Contact> contactMap = new Map<Id, Contact>([
            SELECT Id, Relationship__c 
            FROM Contact 
            WHERE Relationship__c != null]);
        ContactService.UpdateRelationship(contactMap);
        List<Contact> contactList = new List<Contact>();
        contactList.addAll(contactMap.values());
        Map<Id, npe4__Relationship__c> relationshipMap = new Map<Id, npe4__Relationship__c>();
        for(npe4__Relationship__c relationship : [SELECT Id, npe4__RelatedContact__c, npe4__Type__c FROM npe4__Relationship__c]) {
            relationshipMap.put(relationship.npe4__RelatedContact__c, relationship);
        }
        Test.stopTest();
        System.assert(contactList[0].Relationship__c == relationshipMap.get(contactList[0].Id).npe4__Type__c);
    }
    
    @isTest
    private static void validateClearHiddenFields() {
        Test.startTest();
        List<Contact> contactListUpdated = new List<Contact>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>([
            SELECT Id, Hidden_First_Name__c, Hidden_Last_Name__c
            FROM Contact 
            WHERE Hidden_First_Name__c != null
            OR Hidden_Last_Name__c != null]);
        contactListUpdated = ContactService.clearHiddenFields(contactMap.values());
        Test.stopTest();
        System.assert(contactListUpdated[0].Hidden_First_Name__c == null);
    }
    
    @isTest
    private static void validateCreateVolunteerUser() {
        Test.startTest();
        Map<Id, Contact> contactMap = new Map<Id, Contact>([
            SELECT Id, FirstName, LastName, Middle_Name__c, Email 
            FROM Contact 
            WHERE Migrated_Record__c = true
        ]);
        ContactService.createVolunteerUser(contactMap.keySet());
        List<User> newUserList = [SELECT Id, ContactId FROM User WHERE ContactId IN :contactMap.keySet()];
        Test.stopTest();
        System.assert(!newUserList.isEmpty());
    }
    
    @isTest
    private static void validateUpdateWishChildContactInfo() {
        List<Contact> contactList = [SELECT Id, Name, RecordTypeId, IsContactInfoUpdated__c, Hidden_First_Name__c, Hidden_Last_Name__c,
                                     Hidden_Phone__c, HiddenMobilePhone__c, HiddenOtherPhone__c, Hidden_Email__c, Hidden_Street__c, 
                                     Hidden_State__c, Hidden_Country__c, Hidden_Zip_Code__c, Hidden_city__c, Hidden_Preferred_Contact_Rel_Id__c 
                                     FROM Contact 
                                     WHERE RecordTypeId = :WISH_CHILD_RECORD_TYPE_ID];
        for(Contact contact: contactList) {
            contact.IsContactInfoUpdated__c = true;
        }
        Test.startTest();
        ContactService.updateWishChildContactInfo(contactList);
        Test.stopTest();
    }
}