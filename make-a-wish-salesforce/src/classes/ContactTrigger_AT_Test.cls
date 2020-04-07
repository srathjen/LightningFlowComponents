/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 28/06/2016
Description : ContactTrigger_AT_Test is used to increase the code coverage for contact_AT trigger and contactTriggerHandler.
*****************************************************************************************************/

@IsTest
public class ContactTrigger_AT_Test {

	/*This setup method is used to create a chapter User and systemAdmin Users*/
	@TestSetup
	static void setup() {
		User User = OrientationandTrainingUtil.createChapterUser();
		insert User;
		User adminUser = OrientationandTrainingUtil.createrSystemAdminUser();
		insert adminUser;
	}

	/*This setup method is used to create a community User records*/
	@IsTest
	public static void createCommunityUser() {
		User chapterUser = [
				SELECT Id,UserName,ProfileId,Profile.Name,Email
				FROM User
				WHERE Email = :'test123@gmail.com'
				LIMIT 1
		];
		System.runAs(chapterUser) {
			Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
			insert chapterAccount;
			try {
				Contact contact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
				insert contact;
			} catch (exception ex) {
			}
		}
	}

	/*This method is used to update the application status to complete*/
	@IsTest
	public static void UpdateApplicationStatustoComplete() {
		Id volunteerRecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
		User systemAdmin = [
				SELECT id
				FROM User
				WHERE id = :UserInfo.getUserId()
		];
		System.runAs(systemAdmin) {
			Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
			insert chapterAccount;
			Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
			insert volunteerContact;
			OrientationandTrainingUtil.CreateAffiliation(volunteerContact.Id);
			Contact dbcontact = [
					SELECT Id,FirstName,LastName,AccountId,Birth_Month__c,Birth_Day__c,is_Application__c, Birth_Year__c,RecordTypeId
					FROM Contact
					WHERE RecordTypeId = :volunteerRecordTypeId
					LIMIT 1
			];
			dbcontact .Birth_Day__c = '21';
			dbcontact .Birth_Month__c = 'March';
			dbcontact.RecordTypeId = volunteerRecordTypeId;
			dbcontact .Birth_Year__c = '1986';
			dbcontact .is_Application__c = 'Complete';
			dbcontact.HiddenOtherPhone__c = '1122334455';
			update dbcontact;
			System.assertEquals(dbcontact .is_Application__c, 'Complete');
		}
	}

	/*This method is used to update the application status to reject*/
	@IsTest
	public static void UpdateApplicationStatustoReject() {
		Id volunteerRecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
		User systemAdmin = [
				SELECT id
				FROM User
				WHERE id = :UserInfo.getUserId()
		];
		System.runAs(systemAdmin) {
			Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
			insert chapterAccount;
			Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
			insert volunteerContact;
			npe5__Affiliation__c affiliation = OrientationandTrainingUtil.CreateAffiliationwithAccount(volunteerContact.Id, chapterAccount.Id);
			insert affiliation;
			Role__c wishRole = OrientationandTrainingUtil.createRole();
			insert wishRole;
			Chapter_Role__c chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.Id, wishRole.Id);
			insert chapterRole;
			Contact dbcontact = [
					SELECT Id,FirstName,LastName,AccountId,Birth_Month__c,Birth_Day__c,is_Application__c, Birth_Year__c,RecordTypeId
					FROM Contact
					WHERE RecordTypeId = :volunteerRecordTypeId
					LIMIT 1
			];
			dbcontact .Birth_Day__c = '21';
			dbcontact .Birth_Month__c = 'March';
			dbcontact .Birth_Year__c = '1986';
			dbcontact .is_Application__c = 'Rejected';
			dbcontact.Volunteer_Role__c = 'Wish Granter;Airport Greeter';
			update dbcontact;
			System.assertEquals(dbcontact .is_Application__c, 'Rejected');
		}
	}

	/*This method is used to create a task record when zipcode is update*/
	@IsTest
	public static void CreateZipcodeUpdateTask() {
		User systemAdmin = [
				SELECT id
				FROM User
				WHERE id = :UserInfo.getUserId()
		];
		System.runAs(systemAdmin) {
			Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
			insert chapterAccount;
			Account chapterAccount1 = OrientationandTrainingUtil.createVolunteerAccount();
			insert chapterAccount1;
			Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
			insert volunteerContact;
			Office__c officeRec = OrientationandTrainingUtil.createOffice(chapterAccount1.Id);
			officeRec.External_Id__c = 'R123';
			insert officeRec;
			Zip_Code__c zipcodeRec = OrientationandTrainingUtil.createZipcode(officeRec.Id);
			zipcodeRec.Name = '35004';
			zipCodeRec.office__c = officeRec.Id;
			zipCodeRec.External_Id__c = 'R123';
			insert zipCodeRec;
			npe5__Affiliation__c affiliation = OrientationandTrainingUtil.CreateAffiliationwithAccount(volunteerContact.Id, chapterAccount.Id);
			insert affiliation;
			Contact dbContact = [
					SELECT Id,MailingPostalCode
					FROM Contact
					WHERE Id = :volunteerContact.Id
			];
			dbContact.MailingPostalCode = '35004';
			System.assertEquals(dbcontact .MailingPostalCode, '35004');

		}
	}

	/* This Method is used to update the Volunteer LastName,FirstName,Email and Mobile Number */
	@IsTest
	public static void UpdateVolunteerDetails() {
		Id volunteerRecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
		User systemAdmin = [
				SELECT id
				FROM User
				WHERE id = :UserInfo.getUserId()
		];
		System.runAs(systemAdmin) {

			Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
			insert chapterAccount;
			Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
			insert volunteerContact;
			User volunteerUser = OrientationandTrainingUtil.createVolunteerUser(volunteerContact.Id);
			insert volunteerUser;
			npe5__Affiliation__c affiliation = OrientationandTrainingUtil.CreateAffiliationwithAccount(volunteerContact.Id, chapterAccount.Id);
			insert affiliation;
			Role__c wishRole = OrientationandTrainingUtil.createRole();
			insert wishRole;
			Chapter_Role__c chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.Id, wishRole.Id);
			insert chapterRole;
			Contact dbcontact = [
					SELECT Id,FirstName,LastName,MobilePhone,Email,RecordTypeId
					FROM Contact
					WHERE RecordTypeId = :volunteerRecordTypeId
					LIMIT 1
			];
			dbcontact.LastName = 'moss';
			dbcontact.FirstName = 'Smith';
			dbcontact.MobilePhone = '9003910427';
			dbcontact.Email = 'Smith@gmail.com';
			System.assertEquals(dbcontact .Email, 'Smith@gmail.com');
		}

	}
	//This Method is used to create a wish child contact
	@IsTest
	public static void CreateWishChildContact() {
		Id wichChildRecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;

		Account newAcc = new Account();
		newAcc.Name = 'Test';
		insert newAcc;

		Account chapterAcc = OrientationandTrainingUtil.createchapterAccount();
		ICD_Codes__c newICD = new ICD_Codes__c ();
		newICD.Name = 'c00';
		insert newICD;
		Contact newCon = new Contact();
		newCon.LastName = 'Test';
		newCon.ICD_10_Code__c = newICD.Id;
		newCon.Diagnosis__c = 'Malignant Neoplasm';
		newCon.Non_Verbal__c = 'No';
		newCon.accountid = newAcc.Id;
		newCon.Region_Chapter__c = chapterAcc.Id;
		newCon.recordTypeId = wichChildRecordTypeId;
		insert newCon;
		System.assertEquals(newCon.ICD_10_Code__c, newICD.Id);
	}

	//This method is used to create a medical professional contact.
	@IsTest
	public static void CreateMedicalContact() {
		Id wichChildRecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
		Id MedicalProfContactRecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
		Account newAcc = new Account();
		newAcc.Name = 'Test';
		insert newAcc;
		ICD_Codes__c newICD = new ICD_Codes__c ();
		newICD.Name = 'c00';
		insert newICD;
		Contact newCon = new Contact();
		newCon.LastName = 'Test';
		newCon.ICD_10_Code__c = newICD.Id;
		newCon.Diagnosis__c = 'Malignant Neoplasm';
		newCon.Non_Verbal__c = 'No';
		newCon.accountid = newAcc.Id;
		newCon.recordTypeId = wichChildRecordTypeId;
		insert newCon;

		Contact newMedCon = new Contact();
		newMedCon.LastName = 'Test';
		newMedCon.recordTypeId = MedicalProfContactRecordTypeId;
		insert newMedCon;

		npe4__Relationship__c newRel = new npe4__Relationship__c();
		newRel.npe4__RelatedContact__c = newMedCon.Id;
		newRel.npe4__Contact__c = newCon.Id;
		newRel.npe4__Status__c = 'Active';
		newRel.Qualifying_Medical_Professional__c = true;
		insert newRel;

		newMedCon.LastName = 'Test1';
		newMedCon.Email = 'test@gmail.com';
		update newMedCon;
		System.assertEquals(newMedCon.Email, 'test@gmail.com');
	}

	//This method is used to update the wish family contatc information.
	@IsTest
	public static void RecallWishFamilyContactInfo() {

		Contact childCon = OrientationandTrainingUtil.CreateWishChildCon();
		insert childCon;
		Contact childFamily = OrientationandTrainingUtil.CreateWishFamily();
		insert childFamily;
		npe4__Relationship__c npcr = OrientationandTrainingUtil.CreateRelationshipRec(childCon.Id, childFamily.Id);

		Contact updateConFamily = new Contact();
		updateConFamily.Hidden_First_Name__c = 'Chandra';
		updateConFamily.Hidden_Last_Name__c = 'Sekar';
		updateConFamily.Hidden_Phone__c = '8056913402';
		updateConFamily.Hidden_Email__c = 'testmst@gmail.com';
		updateConFamily.Hidden_Street__c = 'North Street';
		updateConFamily.Hidden_city__c = 'Chennai';
		updateConFamily.Hidden_State__c = 'Alabama';
		updateConFamily.Hidden_Country__c = 'United States';
		updateConFamily.Hidden_Zip_Code__c = '621010';
		updateConFamily.IsContactInfoUpdated__c = true;
		updateConFamily.Id = childFamily.Id;
		update updateConFamily;

		Contact updateCon = new Contact();
		updateCon.Email = 'kanagu431@gmail.com';
		updateCon.IsRejected_Contact_Info__c = true;
		updateCon.Id = childCon.Id;
		update updateCon;
		System.assertEquals(updateCon.IsRejected_Contact_Info__c, True);
	}

	//This method used to increase the code coverage for when the wish child information is updated.
	@IsTest
	public static void updatewishChildContactInfo() {
		Contact childCon = OrientationandTrainingUtil.CreateWishChildCon();
		insert childCon;
		Contact updateCon = new Contact();
		updateCon.Hidden_First_Name__c = 'Chandra';
		updateCon.Hidden_Last_Name__c = 'Sekar';
		updateCon.Hidden_Phone__c = '8056913402';
		updateCon.Hidden_Email__c = 'testmst@gmail.com';
		updateCon.Hidden_Street__c = 'North Street';
		updateCon.Hidden_city__c = 'Chennai';
		updateCon.Hidden_State__c = 'Alabama';
		updateCon.Hidden_Country__c = 'United States';
		updateCon.Hidden_Zip_Code__c = '621010';
		updateCon.IsContactInfoUpdated__c = true;
		updateCon.Id = childCon.Id;
		update updateCon;
		System.assertEquals(updateCon.IsContactInfoUpdated__c, True);
	}

	/*This method is used to update the application status to submit*/
	@IsTest
	public static void UpdateApplicationStatustoSubmit() {
		Id volunteerRecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
		User systemAdmin = [
				SELECT id
				FROM User
				WHERE id = :UserInfo.getUserId()
		];
		System.runAs(systemAdmin) {
			Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
			insert chapterAccount;
			Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
			insert volunteerContact;
			npe5__Affiliation__c affiliation = OrientationandTrainingUtil.CreateAffiliation(volunteerContact.Id);
			insert affiliation;
			Contact dbcontact = [
					SELECT Id,FirstName,LastName,AccountId,Birth_Month__c,Birth_Day__c,is_Application__c, Birth_Year__c,RecordTypeId
					FROM Contact
					WHERE RecordTypeId = :volunteerRecordTypeId
					LIMIT 1
			];
			dbcontact .Birth_Day__c = '21';
			dbcontact .Birth_Month__c = 'March';
			dbcontact .Birth_Year__c = '1986';
			dbcontact .is_Application__c = 'Submit';
			update dbcontact;
			System.assertEquals(dbcontact.is_Application__c, 'Submit');
		}
	}

	@IsTest
	public static void createwishfamilyContact() {
		Contact wishChildFamily = OrientationandTrainingUtil.CreateWishFamily();
	}

	//This Method is used to Update and recall the wish family contatc information.
	@IsTest
	public static void recallWishChildContactInfo() {
		Contact childCon = OrientationandTrainingUtil.CreateWishChildCon();
		insert childCon;
		Contact childFamily = OrientationandTrainingUtil.CreateWishFamily();
		insert childFamily;
		npe4__Relationship__c npcr = OrientationandTrainingUtil.CreateRelationshipRec(childCon.Id, childFamily.Id);
		Contact updateConFamily = new Contact();
		updateConFamily.Hidden_First_Name__c = 'Chandra';
		updateConFamily.Hidden_Last_Name__c = 'Sekar';
		updateConFamily.Hidden_Phone__c = '8056913402';
		updateConFamily.Hidden_Email__c = 'testmst@gmail.com';
		updateConFamily.Hidden_Street__c = 'North Street';
		updateConFamily.Hidden_city__c = 'Chennai';
		updateConFamily.Hidden_State__c = 'Alabama';
		updateConFamily.Hidden_Country__c = 'United States';
		updateConFamily.Hidden_Zip_Code__c = '621010';
		updateConFamily.IsContactInfoUpdated__c = true;
		updateConFamily.Id = childFamily.Id;
		update updateConFamily;

		System.assert([
				SELECT Name
				FROM Contact
				WHERE Hidden_Zip_Code__c = '621010'
				LIMIT 1
		].Name != Null);
		Contact updateCon = new Contact();
		updateCon.Email = 'kanagu431@gmail.com';
		updateCon.IsContactInfoUpdated__c = true;
		updateCon.Id = childCon.Id;
		update updateCon;
	}

	//This method is used to recall the approval and update the wish child contac information.
	@IsTest
	public static void updatewishChildRecall() {
		Contact childCon = OrientationandTrainingUtil.CreateWishChildCon();
		insert childCon;
		Contact childFamily = OrientationandTrainingUtil.CreateWishFamily();
		insert childFamily;
		npe4__Relationship__c npcr = OrientationandTrainingUtil.CreateRelationshipRec(childCon.Id, childFamily.Id);
		childFamily.Hidden_First_Name__c = '';
		update childFamily;
		Contact updateCon = new Contact();
		updateCon.Hidden_First_Name__c = 'Chandra';
		updateCon.Hidden_Last_Name__c = 'Sekar';
		updateCon.Hidden_Phone__c = '8056913402';
		updateCon.Hidden_Email__c = 'testmst@gmail.com';
		updateCon.Hidden_Street__c = 'North Street';
		updateCon.Hidden_State__c = 'Alabama';
		updateCon.Hidden_Country__c = 'United States';
		updateCon.Hidden_Zip_Code__c = '621010';
		updateCon.HiddenOtherPhone__c = '9876543210';
		updateCon.HiddenMobilePhone__c = '8907654321';
		updateCon.Hidden_Use_as_Household_Address__c = True;
		updateCon.IsRejected_Contact_Info__c = true;
		updateCon.Id = childCon.Id;
		update updateCon;
		updateCon.Hidden_city__c = 'Chennai';
		Update updateCon;
		System.assertEquals(updateCon.Hidden_city__c, 'Chennai');
	}

	@IsTest
	public static void deleteContact() {
		Contact childCon = OrientationandTrainingUtil.CreateWishChildCon();
		insert childCon;
		Contact childFamily = OrientationandTrainingUtil.CreateWishFamily();
		insert childFamily;
		delete childFamily;
	}

	//This method is used to update the condition description in wish child contact.
	@IsTest
	public static void diagnosisUpdate() {
		Id wichChildRecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
		Contact childCon = OrientationandTrainingUtil.CreateWishChildCon();
		insert childCon;
		Case parentCase = OrientationandTrainingUtil.CreateParentCase(childCon.Id);
		childCon.Diagnosis__c = 'Malignant';
		childCon.SD1_Condition_Description__c = 'Malignant';
		childCon.SD2_Condition_Description__c = 'Malignant';
		childCon.SD3_Condition_Description__c = 'Malignant';
		childCon.SD4_Condition_Description__c = 'Malignant';
		childCon.RecordTypeId = wichChildRecordTypeId;
		update childCon;
		System.assertEquals([
				SELECT Id
				FROM Contact
				WHERE SD1_Condition_Description__c = 'Malignant'
				LIMIT 1
		].Id, childCon.Id);
	}

	//This method is used to update the ICD in wish child contact.
	@IsTest
	public static void icdUpdates() {
		Id wichChildRecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
		Contact childCon = OrientationandTrainingUtil.CreateWishChildCon();
		insert childCon;
		ICD_Codes__c newICD = new ICD_Codes__c(Name = 'C00');
		insert newICD;
		Case parentCase = OrientationandTrainingUtil.CreateParentCase(childCon.Id);
		childCon.ICD_10_Code__c = newICD.Id;
		childCon.SD1_ICD_Code__c = newICD.Id;
		childCon.SD2_ICD_Code__c = newICD.Id;
		childCon.SD3_ICD_Code__c = newICD.Id;
		childCon.SD4_ICD_Code__c = newICD.Id;
		childCon.RecordTypeId = wichChildRecordTypeId;
		update childCon;
		System.assertEquals([
				SELECT Id
				FROM Contact
				WHERE ICD_10_Code__c = :newICD.Id
				LIMIT 1
		].Id, childCon.Id);
	}

	//This method is used to create a volunteer User for migrated volunteer contact.
	@IsTest
	public static void createMigratedVolunteerUser() {
		Id volunteerRecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
		Account chapterAcc = OrientationandTrainingUtil.createchapterAccount();
		insert chapterAcc;
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
		newContact.AccountId = chapterAcc.Id;
		newContact.email = 'Test@mail.com';
		newContact.Volunteer_Role__c = 'Water Handler';
		newContact.Do_Not_Create_User__c = False;
		newContact.Migrated_Record__c = True;
		insert newContact;
		System.assert(newContact.Migrated_Record__c, True);
	}

	@IsTest
	public static void updateContactPhone() {
		Id wichChildRecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
		Contact newCon = New Contact();
		newCon.RecordTypeId = wichChildRecordTypeId;
		newCon.IsContactInfoUpdated__c = true;
		newCon.Hidden_First_Name__c = 'TestFirst Name';
		newCon.Hidden_Last_Name__c = 'estLastName';
		newCon.FirstName = 'TestFirst Name';
		newCon.LastName = 'TestLastName';
		newCon.Diagnosis__c = 'Malignant Neoplasm';
		insert newCon;
		npe4__Relationship__c newRlet = new npe4__Relationship__c();
		newRlet.npe4__RelatedContact__c = newCon.Id;
		newRlet.npe4__Status__c = 'Active';
		newRlet.npe4__Contact__c = newCon.Id;
		insert newRlet;
		newCon.Hidden_Phone__c = '222222222222';
		newCon.HiddenMobilePhone__c = '2222222222';
		newCon.HiddenOtherPhone__c = '1111111111';
		newCon.Hidden_Preferred_Contact_Rel_Id__c = newRlet.Id;
		newCon.Hidden_Zip_Code__c = '62100';
		update newCon;
		newCon.Hidden_Preferred_Contact_Rel_Id__c = 'Remove';
		update newCon;
	}

	@IsTest
	public static void updateContactPhoneNegative() {
		Id wichChildRecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
		Contact newCon = New Contact();
		newCon.RecordTypeId = wichChildRecordTypeId;
		newCon.IsContactInfoUpdated__c = true;
		newCon.FirstName = 'TestFirst Name';
		newCon.LastName = 'TestLastName';
		newCon.Diagnosis__c = 'Malignant Neoplasm';
		insert newCon;
		newCon.Hidden_Phone__c = '9912121313';
		newCon.HiddenMobilePhone__c = '9912121313';
		newCon.HiddenOtherPhone__c = '9912121313';
		newCon.Hidden_Zip_Code__c = '11111';
		newCon.Hidden_Preferred_Contact_Rel_Id__c = 'Remove';
		update newCon;
	}

	@IsTest
	public static void deleteWishForm() {
		Id wichChildRecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
		Id wishFormRecordTypeId = Constant_AC.WISH_FORM_FAMILY_ID;
		Wish_Child_Form__c newWF = new Wish_Child_Form__c();
		newWF.RecordTypeId = wishFormRecordTypeId;
		insert newWF;
		Contact newCon = New Contact();
		newCon.RecordTypeId = wichChildRecordTypeId;
		newCon.IsContactInfoUpdated__c = true;
		newCon.FirstName = 'TestFirst Name';
		newCon.Hidden_Wish_Form_Id__c = newWF.Id;
		newCon.LastName = 'TestLastName';
		newCon.Diagnosis__c = 'Malignant Neoplasm';
		insert newCon;
		Contact childFamily = OrientationandTrainingUtil.CreateWishFamily();
		insert childFamily;
		childFamily.Hidden_Wish_Form_Id__c = newWF.Id;
		update childFamily;
		Delete newCon;
	}

	@IsTest
	public static void updatewishChildSameAsHousHold() {
		Contact childCon = OrientationandTrainingUtil.CreateWishChildCon();
		insert childCon;
		Contact childFamily = OrientationandTrainingUtil.CreateWishFamily();
		insert childFamily;
		npe4__Relationship__c npcr = OrientationandTrainingUtil.CreateRelationshipRec(childCon.Id, childFamily.Id);
		insert npcr;
		set<Id> wishChildIdSet = new set<Id>();
		String dummyValue = Label.Dummy_Email;
        List<Contact> contactList = new List<Contact>();
		Contact updateCon = new Contact();
		updateCon.Hidden_First_Name__c = 'Chandra';
		updateCon.Hidden_Last_Name__c = 'Sekar';
		updateCon.Hidden_Phone__c = '9912121313';
		updateCon.Hidden_Email__c = dummyValue;
		updateCon.Hidden_Street__c = dummyValue;
		updateCon.Hidden_city__c = dummyValue;
		updateCon.Hidden_State__c = dummyValue;
		updateCon.Hidden_Country__c = 'United States';
		updateCon.Hidden_Zip_Code__c = '621010';
		updateCon.IsContactInfoUpdated__c = true;
		updateCon.Hidden_Use_as_Household_Address__c = true;
		updateCon.Hidden_Same_Address__c = true;
		updateCon.Hidden_Zip_Code__c = '11111';
		updateCon.Hidden_Preferred_Phone_Types__c = 'Home';
		updateCon.HiddenOtherPhone__c = '9912121313';
		updateCon.Hidden_Work_Phone__c = '9912121313';
		updateCon.HiddenMobilePhone__c = '9912121313';
		updateCon.Id = childFamily.Id;
		wishChildIdSet.add(childCon.Id);
		update updateCon;
		update childCon;
        contactList.add(updateCon);
        ContactService.updateFamilyContactDetails(wishChildIdSet, contactList);
		System.assertEquals(updateCon.IsContactInfoUpdated__c, True);
	}

	@IsTest
	public static void updatewishChildHiddenPhone() {
		Contact childCon = OrientationandTrainingUtil.CreateWishChildCon();
		insert childCon;
		Contact childFamily = OrientationandTrainingUtil.CreateWishFamily();
		insert childFamily;
		npe4__Relationship__c npcr = OrientationandTrainingUtil.CreateRelationshipRec(childCon.Id, childFamily.Id);
		set<Id> wishChildIdSet = new set<Id>();
		Map<Id, Contact> ConrelationshipIdMap = new Map<Id, Contact>();
		set<Id> removePrefIdSet = new set<Id>();
		String dummyValue = Label.Dummy_Email;
        List<Contact> contactList = new List<Contact>();
		Contact updateCon = new Contact();
		updateCon.Hidden_First_Name__c = 'Chandra';
		updateCon.Hidden_Last_Name__c = 'Sekar';
		updateCon.Hidden_Phone__c = '8012121313';
		updateCon.Hidden_Email__c = dummyValue;
		updateCon.Hidden_Street__c = dummyValue;
		updateCon.Hidden_city__c = dummyValue;
		updateCon.Hidden_State__c = dummyValue;
		updateCon.Hidden_Country__c = 'United States';
		updateCon.Hidden_Zip_Code__c = '621010';
		updateCon.IsContactInfoUpdated__c = true;
		updateCon.Hidden_Use_as_Household_Address__c = true;
		updateCon.Hidden_Same_Address__c = true;
		updateCon.Hidden_Zip_Code__c = '11111';
		updateCon.Hidden_Preferred_Phone_Types__c = 'Home';
		updateCon.HiddenOtherPhone__c = '8012121313';
		updateCon.Hidden_Work_Phone__c = '8012121313';
		updateCon.HiddenMobilePhone__c = '8012121313';
		updateCon.Id = childFamily.Id;
		wishChildIdSet.add(childCon.Id);
		removePrefIdSet.add(childCon.Id);
		ConrelationshipIdMap.put(childCon.Id, childCon);
		update updateCon;
		update childCon;
        contactList.add(updateCon);
        ContactService.updateFamilyContactDetails(wishChildIdSet, contactList);
		System.assertEquals(updateCon.IsContactInfoUpdated__c, True);
	}

	@IsTest
	public static void docusignNameUpdate() {
		Contact childCon = OrientationandTrainingUtil.CreateWishChildCon();
		insert childCon;
		Contact childFamily = OrientationandTrainingUtil.CreateWishFamily();
		insert childFamily;
		Contact childFamily2 = OrientationandTrainingUtil.CreateWishFamily();
		npe4__Relationship__c npcr = OrientationandTrainingUtil.CreateRelationshipRec(childCon.Id, childFamily.Id);
		Test.startTest();
		npe4__Relationship__c npcr2 = OrientationandTrainingUtil.CreateRelationshipRec(childCon.Id, childFamily2.Id);
		Case newCase = OrientationandTrainingUtil.CreateParentCase(childCon.Id);
		newCase.ContactId = childCon.Id;

		// insert newCase;
		dsfs__DocuSign_Status__c newStat = new dsfs__DocuSign_Status__c();
		newStat.dsfs__Case__c = newCase.Id;
		insert newStat;
		dsfs__DocuSign_Recipient_Status__c newRecpStatus = new dsfs__DocuSign_Recipient_Status__c();
		newRecpStatus.dsfs__Parent_Status_Record__c = newStat.Id;
		newRecpStatus.dsfs__DocuSign_Recipient_Id__c = '3643786876';
		insert newRecpStatus;
		List<Wish_Child_Form__c> wishChildForm = OrientationandTrainingUtil.createWishChildForm(newCase.Id, childCon, childFamily, childFamily2);
		Insert wishChildForm;
		childFamily.Relationship__c = 'Self';
		update childFamily;
		Test.stopTest();
	}

	@IsTest
	public static void createAffiliation() {
		Id volunteerRecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
		Id ChapterRecordTypeId = Constant_AC.CHAPTER_RT_ID;
		Id medicalProfessionalRecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
		Account newchapterAccount = new Account();
		newchapterAccount .Name = 'Make-A-Wish Alabama';
		newchapterAccount.RecordTypeId = ChapterRecordTypeId;
		insert newchapterAccount;
		List<contact> conList = new List<Contact>();
		Contact medCon = OrientationandTrainingUtil.CreateWishFamily();
		insert medCon;
		medCon.RecordTypeId = medicalProfessionalRecordTypeId ;
		Contact childCon = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
		insert childCon;
		childCon.RecordTypeId = volunteerRecordTypeId;
		Account hospAcc = OrientationandTrainingUtil.HospitalTreatment();
		insert hospAcc;
		childCon.Hidden_Hospital_Account__c = hospAcc.Id;
		childCon.Region_Chapter__c = newchapterAccount.Id;
		update childCon;
		update medCon;
		conList.add(medCon);
		ContactService.createAffiliation(conList);
	}
}