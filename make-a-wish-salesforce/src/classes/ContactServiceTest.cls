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

		Account htfAccount = TestDataFactory.createAccount(1)[0];
		htfAccount.RecordTypeId = Constant_AC.HOSPITAL_TREATMENT_ID;
		htfAccount.Name = 'Sun Valley General Hospital';
		htfAccount.BillingPostalCode = '85001';
		htfAccount.Chapter_Name__c = arizonaChapter.Id;
		insert htfAccount;

		List<Condition_Description__c> conditionsList = TestDataFactory.createConditionDescription(1);
		Condition_Description__c heartTransplant = conditionsList.get(0);
		heartTransplant.Name = 'Heart Transplant';
		insert conditionsList;

		List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(2);
		ICD_Codes__c heartTran = icdCodes.get(1);
		heartTran.Name = 'T86.2';
		heartTran.Condition_Description__c = heartTransplant.Id;
		insert icdCodes;

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
		wishChildContact1.SD1_ICD_Code__c = icdCodes[0].Id;
		wishChildContact1.SD2_ICD_Code__c = icdCodes[0].Id;
		wishChildContact1.SD3_ICD_Code__c = icdCodes[0].Id;
		wishChildContact1.SD4_ICD_Code__c = icdCodes[0].Id;
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
		wishChildContact2.isRecall_Contact_Info__c = true;

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
        wishChildContact2Mother.Hidden_Use_as_Household_Address__c = true;
        wishChildContact2Mother.AccountId = watkinsFamily.Id;
        wishChildContact2Mother.Hidden_Phone__c = '9912121313';
        wishChildContact2Mother.HiddenMobilePhone__c = '9912121313';
        wishChildContact2Mother.Hidden_Work_Phone__c = '9912121313';
        wishChildContact2Mother.HiddenOtherPhone__c = '9912121313';
        wishChildContact2Mother.Hidden_Email__c = Label.Dummy_Email;
        wishChildContact2Mother.Hidden_Preferred_Phone_Types__c = Label.Dummy_Email;
        wishChildContact2Mother.Hidden_Street__c = Label.Dummy_Email;
        wishChildContact2Mother.Hidden_city__c = Label.Dummy_Email;
        wishChildContact2Mother.Hidden_State__c = Label.Dummy_Email;
        wishChildContact2Mother.Hidden_Zip_Code__c = '11111';
        wishChildContact2Mother.Hidden_Same_Address__c = true;
		wishChildContact2Mother.Relationship__c = 'Mother';

		Contact wishChildContact2Father = contacts.get(5);
		wishChildContact2Father.RecordTypeId = WISH_FAMILY_RECORD_TYPE_ID;
		wishChildContact2Father.FirstName = 'Joel';
		wishChildContact2Father.LastName = 'Watkins';
		wishChildContact2Father.Relationship__c = 'Father';
		wishChildContact2Father.Phone = '5558956789';
		wishChildContact2Father.MobilePhone = '9876598555';
		wishChildContact2Father.HomePhone = '5558956789';
        wishChildContact2Father.npe01__WorkPhone__c = '5678905674';
		wishChildContact2Father.npe01__PreferredPhone__c = 'Work';
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
        wishChildContact2Father.Hidden_Phone__c = '5218209898';

		Contact medProfessional = contacts.get(6);
		medProfessional.RecordTypeId = MEDICAL_PROFESSIONAL_RECORD_TYPE_ID;
		medProfessional.Region_Chapter__c = arizonaChapter.Id;
		medProfessional.FirstName = 'Lewis';
		medProfessional.LastName = 'Hall';
		medProfessional.Email = 'l.hall@email.com';
		medProfessional.Phone = '12345678';
		medProfessional.MailingPostalCode = '12345-9876';
		medProfessional.MailingStreet = 'Highland Avenue';
		medProfessional.MailingCountry = 'United States';
		medProfessional.MailingState = 'Arizona';
		medProfessional.MailingCity = 'Phoenix';

		Contact medProfContact = contacts.get(7);
		medProfContact.RecordTypeId = MEDICAL_PROFESSIONAL_RECORD_TYPE_ID;
		medProfContact.FirstName = 'Jane';
		medProfContact.LastName = 'Flora';
		medProfContact.Email = 'j.flora@email.com';
		medProfContact.Phone = '12345678';
		medProfContact.npsp__Primary_Affiliation__c = htfAccount.Id;
		medProfContact.MailingPostalCode = '85016-1234';
		medProfContact.MailingStreet = '900 Highland Avenue';
		medProfContact.MailingCountry = 'United States';
		medProfContact.MailingState = 'Arizona';
		medProfContact.MailingCity = 'Phoenix';
		insert contacts;

		User volunteerUser = TestDataFactory.createVolunteerUser(1)[0];
		volunteerUser.FirstName = 'Abby';
		volunteerUser.LastName = 'Jones';
		System.runAs(TestDataFactory.adminUser) {
			insert volunteerUser;
		}
		Contact volunteerArizonaUpdate = new Contact();
		volunteerArizonaUpdate.Id = volunteerUser.ContactId;
		volunteerArizonaUpdate.FirstName = 'Abby';
		volunteerArizonaUpdate.Middle_Name__c = 'Rose';
		volunteerArizonaUpdate.LastName = 'Jones';
		volunteerArizonaUpdate.Email = 'a.jones@email.com';
		volunteerArizonaUpdate.Phone = '12345678';
		volunteerArizonaUpdate.MailingPostalCode = '12345-9876';
		volunteerArizonaUpdate.MailingStreet = 'Highland Avenue';
		volunteerArizonaUpdate.MailingCountry = 'United States';
		volunteerArizonaUpdate.MailingState = 'Arizona';
		volunteerArizonaUpdate.MailingCity = 'Phoenix';
		volunteerArizonaUpdate.is_Application__c = 'Submitted';
		volunteerArizonaUpdate.Migrated_Record__c = true;
		volunteerArizonaUpdate.Do_Not_Create_User__c = false;
		volunteerArizonaUpdate.Volunteer_Role__c = 'Wish Granter';
		update volunteerArizonaUpdate;

		List<npe4__Relationship__c> relationships = TestDataFactory.createRelationship(3);
		npe4__Relationship__c relationship1 = relationships.get(0);
		relationship1.npe4__Contact__c = wishChildContact2.Id;
		relationship1.npe4__RelatedContact__c = wishChildContact2Mother.Id;
		relationship1.Parent_Legal_Guardian__c = true;
		npe4__Relationship__c relationship2 = relationships.get(1);
		relationship2.npe4__Contact__c = wishChildContact2.Id;
		relationship2.npe4__RelatedContact__c = medProfessional.Id;
		relationship2.Qualifying_Medical_Professional__c = true;
		relationship2.npe4__Status__c = 'Active';
		npe4__Relationship__c relationship3 = relationships.get(2);
		relationship3.npe4__Contact__c = wishChildContact2.Id;
		relationship3.npe4__RelatedContact__c = wishChildContact2Father.Id;
		relationship3.Parent_Legal_Guardian__c = true;
		insert relationships;

		List<npe5__Affiliation__c> affiliations = TestDataFactory.createAffiliation(1);
		npe5__Affiliation__c affiliation1 = affiliations.get(0);
		affiliation1.npe5__Contact__c = volunteerArizonaUpdate.Id;
		affiliation1.npe5__Organization__c = arizonaChapter.Id;
		affiliation1.npe5__Status__c = 'Pending';
		affiliation1.npe5__Primary__c = true;
		insert affiliations;

		List<Role__c> roles = TestDataFactory.createRole(3, true);
		Role__c wishGranterRole = roles.get(0);
		wishGranterRole.Name = 'Wish Granter';
		Role__c wishGranterMentorRole = roles.get(1);
		wishGranterMentorRole.Name = 'Wish Granter Mentor';
		Role__c singleDayEvent = roles.get(2);
		singleDayEvent.Name = 'Single Day Event Volunteer';
		insert roles;

		List<Chapter_Role__c> chapterRoles = TestDataFactory.createChapterRole(4);
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
		wishGranterMentorChapterRole.Add_to_New_Volunteers_Automatically__c = true;
		Chapter_Role__c singleDayArizonaRole = chapterRoles.get(3);
		singleDayArizonaRole.Chapter_Name__c = arizonaChapter.Id;
		singleDayArizonaRole.Role_Name__c = singleDayEvent.Id;
		singleDayArizonaRole.Background_Check_Required__c = false;
		singleDayArizonaRole.COI_Required__c = false;
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

		List<Volunteer_Opportunity__c> volunteerOpportunities = TestDataFactory.createVolunteerOpportunity(2);
		Volunteer_Opportunity__c volunteerOpportunity = volunteerOpportunities.get(0);
		volunteerOpportunity.Volunteer_Name__c = volunteerArizona.Id;
		volunteerOpportunity.RecordTypeId = Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID;
		volunteerOpportunity.Chapter_Role_Opportunity__c = wishGranterArizonaRole.Id;
		volunteerOpportunity.Status__c = 'Approved';
		Volunteer_Opportunity__c volunteerOpportunitySingleDay = volunteerOpportunities.get(1);
		volunteerOpportunitySingleDay.Volunteer_Name__c = volunteerArizona.Id;
		volunteerOpportunitySingleDay.RecordTypeId = Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID;
		volunteerOpportunitySingleDay.Chapter_Role_Opportunity__c = singleDayArizonaRole.Id;
		volunteerOpportunitySingleDay.Status__c = 'Approved';
		insert volunteerOpportunities;

		Lead qualifiedLead = TestDataFactory.createQualifiedLead(arizonaChapter.Id, icdCodes[0].Id);
		qualifiedLead.Referring_MP__c = medProfessional.Id;
		qualifiedLead.Treating_MP__c = medProfessional.Id;
		insert qualifiedLead;
        
        Lead wishLead = TestDataFactory.createQualifiedLead(arizonaChapter.Id, icdCodes[0].Id);
        wishLead.FirstName = 'Rebecca';
        wishLead.LastName = 'Black';
        wishLead.Gender__c = 'Female';
        wishLead.Relationship_to_child__c = 'Family Member/Relative';
        insert wishLead;

		Office__c mawAzOffice = TestDataFactory.createOffice(1)[0];
		mawAzOffice.Name = 'Make-A-Wish-Arizona';
		mawAzOffice.Chapter__c = arizonaChapter.Id;
		insert mawAzOffice;

		Zip_Code__c zipAz = TestDataFactory.createZipCode(1)[0];
		zipAz.Name = '85069';
		zipAz.Office__c = mawAzOffice.Id;
		zipAz.External_Id__c = '85069';
		insert zipAz;

		Case wishChildCase = TestDataFactory.createCase(1)[0];
		wishChildCase.RecordTypeId = Constant_AC.WISH_RT_ID;
		wishChildCase.ChapterName__c = arizonaChapter.Id;
		wishChildCase.Subject = 'Parent Wish';
		wishChildCase.Interview_date__c = System.today();
		wishChildCase.Wish_Type__c = 'Disney World';
		wishChildCase.Start_Date__c = System.today();
		wishChildCase.End_Date__c = System.today();
		wishChildCase.ContactId = wishChildContact1.Id;
		wishChildCase.Status = 'New';
		wishChildCase.Start_Date__c = System.today();
		wishChildCase.Budget_Submitted_Date__c = System.today();
		wishChildCase.Budget_Approved_Date__c = System.today();
		insert wishChildCase;

		Wish_Signature_Forms__c wishForm = TestDataFactory.createWishSignatureForm(1)[0];
		insert wishForm;

		Wish_Required_Signature__c wishSignature = TestDataFactory.createWishRequiredSignature(1)[0];
		wishSignature.Wish_Case__c = wishChildCase.Id;
		wishSignature.Wish_Signature_Form__c = wishForm.Id;
		insert wishSignature;

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
		List<Lead> leads = [
				SELECT CreatedDate, DOB__c, Medical_Provider_Category__c, Self_describe_comment_box__c,
						What_is_the_family_s_primary_spoken_lang__c, ChapterName__c, LeadSource, Referrer_City__c,
						Referrer_Email__c, Referring_MP__c, Referring_MP__r.FirstName, Referring_MP__r.LastName,
						Referrer_FirstName__c, Referrer_Last_Name__c, Referrer_Phone__c,
						Referrer_Zip__c, Relationship_to_child__c, Other_Medical_Provider_Category__c,
						Other_Relationship_To_Child__c, is_Family_Aware_of_Referral__c, Migrated_Record__c,
						How_Did_you_hear_about_Make_A_Wish__c, Additional_Parent_City__c, City,
						Additional_Parent_Postal_Code__c, PostalCode, Additional_Parent_State__c, State,
						Additional_Parent_Street__c, Street, Gender__c, Salutation, ConvertedContactId,
						Treating_MP__c, Treating_MP__r.FirstName, Treating_MP__r.LastName
				FROM Lead
				WHERE Name = 'Mark Smith'
		];

		Test.startTest();
		Contact result = ContactService.buildWishChildFromLead(leads[0]);
		Test.stopTest();

		System.assertEquals('Lewis', result.Referrer_FirstName__c);
		System.assertEquals('Hall', result.Referrer_Last_Name__c);
	}
    
    @IsTest
    public static void shouldBuildWishChildNonMP() {
        List<Lead> leads = [
				SELECT CreatedDate, DOB__c, Medical_Provider_Category__c, Self_describe_comment_box__c,
						What_is_the_family_s_primary_spoken_lang__c, ChapterName__c, LeadSource, Referrer_City__c,
						Referrer_Email__c, Referring_MP__c, Referring_MP__r.FirstName, Referring_MP__r.LastName,
						Referrer_FirstName__c, Referrer_Last_Name__c, Referrer_Phone__c,
						Referrer_Zip__c, Relationship_to_child__c, Other_Medical_Provider_Category__c,
						Other_Relationship_To_Child__c, is_Family_Aware_of_Referral__c, Migrated_Record__c,
						How_Did_you_hear_about_Make_A_Wish__c, Additional_Parent_City__c, City,
						Additional_Parent_Postal_Code__c, PostalCode, Additional_Parent_State__c, State,
						Additional_Parent_Street__c, Street, Gender__c, Salutation, ConvertedContactId,
						Treating_MP__c, Treating_MP__r.FirstName, Treating_MP__r.LastName
				FROM Lead
				WHERE Name = 'Rebecca Black'
		];
        
        Test.startTest();
        Contact result = ContactService.buildWishChildFromLead(leads[0]);
        Test.stopTest();
        System.assertEquals(leads[0].Referrer_FirstName__c, result.Referrer_FirstName__c);
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

	@isTest
	private static void validateUpdateFamilyContactDetails() {
		Set<Id> wishChildIdSet = new Set<Id>();
		Map<Id, Id> childPreferredRelationMap = new Map<Id, Id>();
		List<Contact> contactList = new List<Contact>();
		for (npe4__Relationship__c relationship : [
				SELECT Id, npe4__Contact__c, npe4__RelatedContact__c
				FROM npe4__Relationship__c
		]) {
			wishChildIdSet.add(relationship.npe4__Contact__c);
			childPreferredRelationMap.put(relationship.npe4__Contact__c, relationship.Id);
		}
		for (Contact contact : [
				SELECT Id, RecordTypeId, Hidden_Preferred_Contact_Rel_Id__c,
						Hidden_Current_Pref_Con_Rel_Id__c, IsContactInfoUpdated__c
				FROM Contact
		]) {
			if (childPreferredRelationMap.containsKey(contact.Id)) {
				contact.Hidden_Preferred_Contact_Rel_Id__c = childPreferredRelationMap.get(contact.Id);
			}
			contactList.add(contact);
		}
		Test.startTest();
		ContactService.updateFamilyContactDetails(wishChildIdSet, contactList);
		List<npe4__Relationship__c> updatedRelationships = [
				SELECT Id, Hidden_Preferred_Contact__c
				FROM npe4__Relationship__c
				WHERE Id IN :childPreferredRelationMap.values()
		];
		Test.stopTest();
		System.assert(updatedRelationships[0].Hidden_Preferred_Contact__c == true);
	}

	@isTest
	private static void validateUpdateHiddenContactFields() {
		Set<Id> contactIdHiddenFieldSet = new Set<Id>();
		List<Contact> contactList = new List<Contact>();
		for (Contact contact : [
				SELECT Id, RecordTypeId, Hidden_Zip_Code__c, IsContactInfoUpdated__c,
						IsRejected_Contact_Info__c, isRecall_Contact_Info__c
				FROM Contact
		]) {
			if (contact.Hidden_Zip_Code__c != null && contact.RecordTypeId == WISH_FAMILY_RECORD_TYPE_ID) {
				contactIdHiddenFieldSet.add(contact.Id);
			}
			if (contact.RecordTypeId == WISH_CHILD_RECORD_TYPE_ID) {
				contact.IsContactInfoUpdated__c = true;
				contact.IsRecall_Contact_Info__c = true;
			}
			contactList.add(contact);
		}
		Test.startTest();
		ContactService.updateContactHiddenFields(contactList);
		List<Contact> updatedContacts = [
				SELECT Id, Hidden_Zip_Code__c
				FROM Contact
				WHERE Id IN :contactIdHiddenFieldSet
		];
		Test.stopTest();
		System.assert(updatedContacts[0].Hidden_Zip_Code__c == null);
	}

	@isTest
	private static void validateUpdateMedicalProfessional() {
		Map<Id, Contact> contactMap = new Map<Id, Contact>();
		List<Contact> updatedContactList = new List<Contact>();
		for (Contact contact : [
				SELECT Id, FirstName, LastName, Name, Email, RecordTypeId
				FROM Contact
		]) {
			contactMap.put(contact.Id, contact);
			Contact updatedContact = new Contact(Id = contact.Id, FirstName = contact.FirstName, LastName = contact.LastName,
					Email = contact.Email, RecordTypeId = contact.RecordTypeId);
			if (contact.Name == 'Lewis Hall') {
				updatedContact.Email = 'Lewis.Hall@email.com';
			}
			updatedContactList.add(updatedContact);
		}
		Test.startTest();
		ContactService.updateMedicalProfessional(updatedContactList, contactMap);
		Set<Id> contactIdSet = new Set<Id>();
		for (npe4__Relationship__c relationship : [
				SELECT Id, npe4__Contact__c
				FROM npe4__Relationship__c
				WHERE npe4__RelatedContact__c IN :contactMap.keySet()
		]) {
			contactIdSet.add(relationship.npe4__Contact__c);
		}
		List<Contact> contactsUpdatedList = [
				SELECT Id, Hidden_Medical_Physician__c, Hidden_Medical_Physician_Email__c
				FROM Contact
				WHERE Id IN :contactIdSet
		];
		Test.stopTest();
		System.assert(contactsUpdatedList[0].Hidden_Medical_Physician__c != null);
	}

	@isTest
	private static void validateUpdateEmailAddress() {
		List<Contact> contactList = new List<Contact>();
		Map<Id, Contact> contactMap = new Map<Id, Contact>();
		for (Contact contact : [
				SELECT Id, FirstName, LastName, Name, Email
				FROM Contact
				WHERE Email != null
		]) {
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
		Test.startTest();
		Set<Id> contactIdSet = new Set<Id>();
		Set<Id> accountIdSet = new Set<Id>();
		for (Contact contact : [
				SELECT Id, AccountId
				FROM Contact
				WHERE Same_as_Household_Address__c = true
		]) {
			contactIdSet.add(contact.Id);
			accountIdSet.add(contact.AccountId);
		}
		List<Account> householdAccountList = [
				SELECT Id, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode
				FROM Account
				WHERE Id IN :accountIdSet
		];
		ContactService.updateHouseHoldAddress(contactIdSet);
		Test.stopTest();
		List<Contact> updatedContacts = [
				SELECT Id, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode
				FROM Contact
				WHERE Id IN :contactIdSet
				AND AccountId IN :accountIdSet
		];
	}

	@isTest
	private static void validateUpdateRelationship() {
		Map<Id, Contact> contactMap = new Map<Id, Contact>();
		List<Contact> updatedContactList = new List<Contact>();
		Map<Id, Contact> relationshipContactMap = new Map<Id, Contact>();
		for (Contact contact : [
				SELECT Id, RecordTypeId, Relationship__c
				FROM Contact
		]) {
			contactMap.put(contact.Id, contact);
			Contact updatedContact = new Contact(Id = contact.Id, RecordTypeId = contact.RecordTypeId,
					Relationship__c = contact.Relationship__c);
			if (contact.Relationship__c != null) {
				updatedContact.Relationship__c = 'Family';
				relationshipContactMap.put(contact.Id, contact);
			}
			updatedContactList.add(updatedContact);
		}
		Test.startTest();
		ContactService.UpdateRelationship(updatedContactList, contactMap);
		List<npe4__Relationship__c> updatedRelationshipList = [
				SELECT Id, npe4__Type__c, npe4__Contact__c
				FROM npe4__Relationship__c
				WHERE npe4__Contact__c IN :relationshipContactMap.keySet()
		];
		Test.stopTest();
		//System.assert(updatedRelationshipList[0].npe4__Type__c == relationshipContactMap.get(updatedRelationshipList[0].npe4__Contact__c).Relationship__c);
	}

	@isTest
	private static void validateCreateVolunteerUser() {
		Test.startTest();
		Map<Id, Contact> contactMap = new Map<Id, Contact>([
				SELECT Id, FirstName, LastName, Middle_Name__c, Email
				FROM Contact
				WHERE Migrated_Record__c = TRUE
		]);
		ContactService.createVolunteerUser(contactMap.keySet());
		Test.stopTest();
		List<User> newUserList = [
				SELECT Id, ContactId
				FROM User
		];
		System.assert(!newUserList.isEmpty());
	}

	@isTest
	private static void validateUpdateWishChildContactInfo() {
		List<Contact> contactList = [
				SELECT Id, Name, RecordTypeId, IsContactInfoUpdated__c, Hidden_First_Name__c, Hidden_Last_Name__c,
						Hidden_Phone__c, HiddenMobilePhone__c, HiddenOtherPhone__c, Hidden_Email__c, Hidden_Street__c,
						Hidden_State__c, Hidden_Country__c, Hidden_Zip_Code__c, Hidden_city__c, Hidden_Preferred_Contact_Rel_Id__c
				FROM Contact
				WHERE RecordTypeId = :WISH_CHILD_RECORD_TYPE_ID
		];
		for (Contact contact : contactList) {
			contact.IsContactInfoUpdated__c = true;
		}
		Test.startTest();
		ContactService.updateWishChildContactInfo(contactList);
		Test.stopTest();
	}

	@isTest
	private static void validateMatchConditionDescription() {
		ICD_Codes__c heartTran = [
				SELECT Id, Condition_Description__c, Condition_Description__r.Name
				FROM ICD_Codes__c
				WHERE Name = 'T86.2'
		];
		Map<Id, Contact> wishChildMap = new Map<Id, Contact>([
				SELECT Id, Diagnosis__c, SD2_ICD_Code__c, SD3_ICD_Code__c, SD4_ICD_Code__c, ICD_10_Code__c, SD1_ICD_Code__c
				FROM Contact
				WHERE Name = 'Jack Smith'
		]);
		List<Contact> contactUpdatedList = new List<Contact>();
		for (Contact con : wishChildMap.values()) {
			Contact contact = new Contact(Id = con.Id);
			contact.SD1_ICD_Code__c = heartTran.Id;
			contact.SD2_ICD_Code__c = heartTran.Id;
			contact.SD3_ICD_Code__c = heartTran.Id;
			contact.SD4_ICD_Code__c = heartTran.Id;
			contact.ICD_10_Code__c = heartTran.Id;
			contactUpdatedList.add(contact);
		}
		Test.startTest();
		List<Contact> contactReturnedList = ContactService.matchConditionDescription(contactUpdatedList, wishChildMap);
		Test.stopTest();
		System.assert(contactReturnedList[0].SD1_Condition_Description__c == heartTran.Condition_Description__r.Name);
	}

	@isTest
	private static void validateCreateVolunteerRoles() {
		Map<Id, Contact> volunteerMap = new Map<Id, Contact>([
				SELECT Id, RecordTypeId, Volunteer_Role__c
				FROM Contact
				WHERE Volunteer_Role__c != null
		]);
		List<Contact> contactUpdatedList = new List<Contact>();
		for (Contact con : volunteerMap.values()) {
			Contact contact = new Contact(Id = con.Id);
			contact.Volunteer_Role__c = 'Wish Granter Mentor';
			contact.RecordTypeId = con.RecordTypeId;
			contactUpdatedList.add(contact);
		}
		Test.startTest();
		ContactService.createVolunteerRoles(contactUpdatedList, volunteerMap);
		Test.stopTest();
		List<Volunteer_Roles__c> newVolRole = [
				SELECT Id, Chapter_Role__c, Chapter_Role__r.Name
				FROM Volunteer_Roles__c
				WHERE Volunteer_Name__c = :contactUpdatedList[0].Id
		];
		System.assert(!newVolRole.isEmpty());
	}

	@isTest
	private static void validateCreateZipcodeUpdateTask() {
		Map<Id, Contact> contactMap = new Map<Id, Contact>([
				SELECT Id, RecordTypeId, MailingAddressVerified__c, MailingPostalCode
				FROM Contact
				WHERE FirstName = 'Abby'
		]);
		List<Contact> contactUpdatedList = new List<Contact>();
		for (Contact con : contactMap.values()) {
			Contact contact = new Contact(Id = con.Id);
			contact.RecordTypeId = con.RecordTypeId;
			contact.MailingAddressVerified__c = false;
			contact.MailingPostalCode = '85069-9876';
			contactUpdatedList.add(contact);
		}
		Test.startTest();
		ContactService.createZipcodeUpdateTask(contactUpdatedList, contactMap);
		Test.stopTest();
	}

	@isTest
	private static void validateClearHiddenFields() {
		List<Contact> contactList = [
				SELECT Id, RecordTypeId, IsContactInfoUpdated__c, IsRejected_Contact_Info__c, isRecall_Contact_Info__c,
						Hidden_First_Name__c, Hidden_Last_Name__c, Hidden_Phone__c, Hidden_Email__c, Hidden_Street__c, Hidden_State__c,
						HiddenOtherPhone__c, HiddenMobilePhone__c, Hidden_Country__c, Hidden_Zip_Code__c, Hidden_city__c,
						Hidden_Preferred_Contact_Rel_Id__c
				FROM Contact
		];
		Test.startTest();
		ContactService.clearHiddenFields(contactList);
		Test.stopTest();
	}

	@isTest
	private static void validateUpdateAssignedNumberOfOpportunities() {
		List<Volunteer_Opportunity__c> volOpps = [
				SELECT Id, Volunteer_Name__c
				FROM Volunteer_Opportunity__c
		];
		Set<Id> volunteerIds = new Set<Id>();
		for (Volunteer_Opportunity__c vOpps : volOpps) {
			volunteerIds.add(vOpps.Volunteer_Name__c);
		}
		Test.startTest();
		ContactService.updateAssignedNumberOfOpportunities(volunteerIds);
		Test.stopTest();
	}

	@isTest
	private static void validateUpdateUserDetails() {
		Map<Id, Contact> contactMap = new Map<Id, Contact>([
				SELECT Id, FirstName, LastName, MobilePhone, Email, MailingStreet, MailingCity,
						MailingState, MailingPostalCode, County__c, Fax, RecordTypeId
				FROM Contact
				WHERE FirstName = 'Abby'
		]);
		List<Contact> contactUpdatedList = new List<Contact>();
		for (Contact con : contactMap.values()) {
			Contact contact = new Contact(Id = con.Id);
			contact.FirstName = con.FirstName;
			contact.LastName = 'Hall';
			contact.MobilePhone = '820-353-8503';
			contact.Email = 'abby@hall.com';
			contact.MailingStreet = '100 Cactus Boulevard';
			contact.MailingCity = 'Scottsdale';
			contact.MailingState = con.MailingState;
			contact.MailingPostalCode = '85261';
			contact.County__c = 'Maricopa';
			contact.Fax = '820-353-8503';
			contact.RecordTypeId = con.RecordTypeId;
			contactUpdatedList.add(contact);
		}
		Test.startTest();
		ContactService.updateUserDetails(contactUpdatedList, contactMap);
		Test.stopTest();
		User userUpdate = [
				SELECT Id, Name, Email
				FROM User
				WHERE FirstName = 'Abby'
				AND ContactId IN :contactUpdatedList
		];
		System.assert(userUpdate.Email == 'abby@hall.com');
	}

	@isTest
	private static void validateUpdateRaceEthnicity() {
		Map<Id, Wish_Required_Signature__c> wishSignatureNewVals = new Map<Id, Wish_Required_Signature__c>();
		Map<Id, Wish_Required_Signature__c> wishSignatureOldVals = new Map<Id, Wish_Required_Signature__c>();
		Id contactId;
		for (Wish_Required_Signature__c signature : [
				SELECT Id, Wish_Case__c, Wish_Case__r.ContactId, Race_Ethnicity_Details__c
				FROM Wish_Required_Signature__c
				WHERE Wish_Case__r.Contact.Name = 'Jack Smith'
		]) {
			wishSignatureOldVals.put(signature.Id, signature);
			Wish_Required_Signature__c updated = signature.clone(true, true, true, true);
			updated.Race_Ethnicity_Details__c = 'White: A person having origins in any of the original peoples of Europe, the Middle East, or North Africa.';
			wishSignatureNewVals.put(updated.Id, updated);
			contactId = signature.Wish_Case__r.ContactId;
		}

		Test.startTest();
		ContactService.updateRaceEthnicity(wishSignatureNewVals, wishSignatureOldVals);
		Test.stopTest();
		Contact updatedContact = [
				SELECT Id, Race_Ethnicity__c
				FROM Contact
				WHERE Id = :contactId
		];
		System.assert(updatedContact.Race_Ethnicity__c == 'White');
	}

	@isTest
	private static void validateUpdateRegionChapterOnMedicalProfessional() {
		Contact mpContact = [
				SELECT Id, Region_Chapter__c
				FROM Contact
				WHERE Name = 'Jane Flora'
		];
		System.assert(mpContact.Region_Chapter__c == null);
		Map<Id, Account> accountMap = new Map<Id, Account>([
				SELECT Id, Name, Chapter_Name__c
				FROM Account
				WHERE RecordTypeId = :Constant_AC.HOSPITAL_TREATMENT_ID
		]);
		Test.startTest();
		ContactService.updateRegionChapterOnMedicalProfessional(accountMap);
		Test.stopTest();
		Contact mpContactUpdated = [
				SELECT Id, Region_Chapter__c
				FROM Contact
				WHERE Id = :mpContact.Id
		];
		System.assert(mpContactUpdated.Region_Chapter__c != null);
	}

	@isTest
	private static void getDuplicateRecords() {
		// As Duplicate Rules might constantly change by Admin, this test is only to obtain coverage and not OOTB Duplicate Check
		ContactService.ContactDuplicateInput input = new ContactService.ContactDuplicateInput();
		Contact duplicateContact = new Contact(FirstName = 'Jack', LastName = 'Med', Email = 'ms@email.com', RecordTypeId = MEDICAL_PROFESSIONAL_RECORD_TYPE_ID);
		input.contactInput = duplicateContact;
		Test.startTest();
		List<List<Contact>> result = ContactService.getDuplicateRecords(new List<ContactService.ContactDuplicateInput>{
				input
		});
		Test.stopTest();
		System.assert(result.get(0).size() == 0);
	}
}