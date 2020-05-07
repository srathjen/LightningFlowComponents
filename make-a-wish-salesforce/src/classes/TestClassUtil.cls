@IsTest
public class TestClassUtil {

	public static List<Account> chapterAccountList = new List<Account>();
	public static User newProspectiveVolunteerUser;
	private final static Id wishRecordTypeId = Constant_AC.WISH_RT_ID;
	private final static Id chapterRecordTypeId = Constant_AC.CHAPTER_RT_ID;
	private final static Id organizationRecordTypeId = Constant_AC.ORGANIZATION_RT_ID;
	private final static Id volunteerRecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
	private final static Id prospectiveVolunteerRecordTypeId = Constant_AC.PROSPECTIVE_VOLUNTEER_RT_ID;
	private final static Id wishChildRecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
	private final static Id medicalProfessionalRecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
	private final static Id nationalRecordTypeId = Constant_AC.NATIONAL_RT_ID;
	private final static Id volunteerOrientationRecordTypeId = Constant_AC.ORIENTATION_RT_ID;
	private final static Id volunteerTrainingRecordTypeId = Constant_AC.TRAINING_RT_ID;
	private final static Id nonWishEventRTId = Constant_AC.NON_WISH_RT_ID;

	public static void createUser() {
		UserRole newUserRole = new UserRole();
		newUserRole.Name = 'Arizona - Chapter';
		insert newUserRole;
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
				email = uniqueName + '@test' + orgId + '.org',
				Username = uniqueName + '@test' + orgId + '.org',
				EmailEncodingKey = 'ISO-8859-1',
				Alias = uniqueName.substring(18, 23),
				TimeZoneSidKey = 'America/Los_Angeles',
				LocaleSidKey = 'en_US',
				LanguageLocaleKey = 'en_US',
				ProfileId = pf.Id,
				isActive = true,
				UserRoleId = newUserRole.Id);
		insert tuser;

	}

	public static void createchapterAccount(Integer count) {
		for (Integer i = 0; i <= count; i++) {
			Account newchapterAccount = new Account();
			newchapterAccount .Name = 'Arizona - Chapter';
			newchapterAccount.RecordTypeId = chapterRecordTypeId;
			chapterAccountList .add(newchapterAccount);
		}
		insert chapterAccountList ;
	}

	public static Id createArizonaChapter() {
		Account newchapterAccount = new Account();
		newchapterAccount .Name = 'Arizona - Chapter';
		newchapterAccount.RecordTypeId = chapterRecordTypeId;

		insert newchapterAccount;
		return newchapterAccount.id;
	}

	public static void createVolunteerContact(Integer count) {
		List<Contact> volunteercontactList = new List<Contact>();
		for (Integer i = 0; i <= count; i++) {
			Contact newContact = new Contact();
			newContact.FirstName = 'moss';
			newContact.LastName = 'Smith';
			newContact.Birthdate = System.today() - 1;
			newContact.Parent_Guardian_Name__c = 'Steve Smith';
			newContact.RecordTypeId = volunteerRecordTypeId;
			volunteercontactList .add(newContact);
		}
		insert volunteercontactList;
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

		insert newContent;
		return newContent;
	}
	public static Dynamic_Content__c createProspectiveDynamicContent() {
		Dynamic_Content__c newContent = new Dynamic_Content__c();
		newContent.Sign_Up_Page__c = 'Hai';
		newContent.RecordTypeId = prospectiveVolunteerRecordTypeId;
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
		newContent.Chapter_Name__c = createArizonaChapter();
		insert newContent;
		return newContent;
	}

	public static Account createChapter() {
		Account newAccount = new Account();
		newAccount.Name = 'Make-A-Wish America';
		newAccount.RecordTypeId = chapterRecordTypeId;
		insert newAccount;
		return newAccount;
	}

	public static Office__c createOffice() {
		Office__c newOffice = new Office__c();
		newOffice.Name = 'Make-A-Wish Alabama,NY, Inc.';
		newOffice.Office_Id__c = '014-000';
		newOffice.Office_Legal_Name__c = 'Make-A-Wish Alabama,NY, Inc.';
		newOffice.General_Email_Address__c = 'wishmail@suffolk.wish.org';
		newOffice.Website__c = 'http://suffolk.wish.org';
		newOffice.Address_1__c = '1 Comac Loop';
		newOffice.Address_2__c = 'Suite 1A1';
		newOffice.City__c = 'Ronkonkoma';
		newOffice.State__c = 'NY';
		newOffice.Zip_Code__c = '11779';
		newOffice.Country__c = 'US';
		newOffice.Phone_Number__c = '(631) 585-9474';
		return newOffice;
	}

	public static Zip_Code__c createZipCode() {
		Zip_Code__c newZipCode = new Zip_Code__c();
		//newZipCode.Name = '35004';
		return newZipCode;
	}

	public static Account createVolunteerAccount() {
		Account newAccount = new Account();
		newAccount.Name = 'Make-A-Wish Alabama';
		newAccount.RecordTypeId = chapterRecordTypeId;
		insert newAccount;
		return newAccount;
	}

	public static Contact createVolunteerContact() {
		Contact newContact = new Contact();
		newContact.FirstName = 'moss';
		newContact.LastName = 'Smith';

		newContact.Birth_Month__c = 'January';
		newContact.Birth_Day__c = '30';
		newContact.Birth_Year__c = '1989';
		newContact.Parent_Guardian_Name__c = 'Steve Smith';
		newContact.RecordTypeId = volunteerRecordTypeId;
		newContact.Title = 'Mr';

		newContact.Alternate_Phone_Type__c = 'Home';
		newContact.npe01__PreferredPhone__c = 'Mobile';
		newContact.Phone = '9003910426';
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
		newContact.AccountId = TestClassUtil.createVolunteerAccount().Id;
		newContact.isApplication__c = false;

		insert newContact;
		return newContact;
	}

	public static Contact createVolunteerContacttwo() {
		Contact newContact = new Contact();
		newContact.FirstName = 'moss';
		newContact.LastName = 'Smith';

		newContact.Birth_Month__c = '';
		newContact.Birth_Day__c = '';
		newContact.Birth_Year__c = '';
		newContact.Parent_Guardian_Name__c = '';
		newContact.RecordTypeId = volunteerRecordTypeId;
		newContact.Title = '';

		newContact.Alternate_Phone_Type__c = '';
		newContact.npe01__PreferredPhone__c = '';
		newContact.Phone = '';
		newContact.I_m_on_LinkedIn__c = '';
		newContact.How_did_you_hear_about_Make_A_Wish__c = '';
		newContact.MailingStreet = 'ThillaiNagar';
		newContact.MailingCity = 'Trichy';
		newContact.MailingCountrycode = 'US';
		newContact.MailingPostalCode = '621010';
		newContact.mailingstatecode = 'AZ';
		newContact.Emergency_Contact__c = '';
		newContact.Emergency_Contact_Relationship__c = '';
		newContact.Emergency_Contact_Phone__c = '';
		newContact.Read__c = '';
		newContact.language__c = '';
		newContact.speak__c = '';
		newContact.understand__c = '';
		newContact.Professional_Skills__c = '';
		newContact.Language_Notes__c = '';
		newContact.Volunteer_Role__c = '';
		newContact.AccountId = TestClassUtil.createVolunteerAccount().Id;

		insert newContact;
		return newContact;
	}

	public static void createProspectiveVolunteerUser() {

		// Profile volunteerProspectiveProfile = [SELECT Id FROM Profile WHERE Name = 'Prospective Volunteer'];
		String profileId = label.Prospective_Volunteer_Profile;

		newProspectiveVolunteerUser = new User(firstname = 'Jonathan', created_from_portal__c = true, lastName = 'Edwards', email = 'jonathan@gmail.com', Username = 'joathanedwards@gmail.com',
				EmailEncodingKey = 'ISO-8859-1', Alias = 'jone', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
				LanguageLocaleKey = 'en_US', ProfileId = profileId, ContactId = TestClassUtil.createVolunteerContact().id, isActive = true, Statecode = 'AZ');
		insert newProspectiveVolunteerUser;

	}

	public static Background_check__c createBackgroundCheck(Id conId) {

		Background_check__c backCheck = new Background_check__c();
		backCheck.Date__c = system.today() + 3;
		backCheck.Volunteer__c = conId;
		backCheck.Status__c = 'Approved w/ Conditions';
		insert backCheck;
		return backCheck;
	}

	public static void createCOI(Id conId) {
		Conflict_Of_Interest__c newCOI = new Conflict_Of_Interest__c();
		newCOI.Volunteer_Contact__c = conId;
		newCOI.Expiration_Date__c = system.today() + 3;
		insert newCOI;
	}

	public static Role__c createRole() {
		Role__c newRole = new Role__c();
		newRole.Name = 'WishGranter';
		insert newRole;
		return newRole;
	}

	public static Chapter_Role__c createchapterRole() {
		Chapter_Role__c newchapterRole = new Chapter_Role__c();
		newchapterRole.Chapter_Name__c = TestClassUtil.createVolunteerAccount().Id;
		newchapterRole.Role_Name__c = TestClassUtil.createRole().Id;
		insert newchapterRole;
		return newchapterRole;
	}

	public static Orientation_Training__c createOrientationForProfile() {
		Orientation_Training__c newOrientation = new Orientation_Training__c();
		newOrientation.Name = 'Test Orienatation';
		newOrientation.RecordTypeId = volunteerOrientationRecordTypeId;

		insert newOrientation;
		return newOrientation;
	}

	public static Orientation_Training__c createTrainingForProfile() {
		Orientation_Training__c newOrientation = new Orientation_Training__c();
		newOrientation.Name = 'Training';
		newOrientation.RecordTypeId = volunteerTrainingRecordTypeId;
		insert newOrientation;
		return newOrientation;
	}

	public static Account createchapterAccount() {
		Account newchapterAccount = new Account();
		newchapterAccount .Name = 'Arizona - Chapter';
		newchapterAccount.RecordTypeId = chapterRecordTypeId;
		insert newchapterAccount ;
		return newchapterAccount;
	}

	/* Date Added : 08/16/2016
   Added by : Sailappa Vignesh PG
   This method will create a LMSCredentials details (Custom setting )*/
	public static LMS_Credentials__c createLMSCredentials() {
		LMS_Credentials__c currLMSCredential = new LMS_Credentials__c();
		currLMSCredential.CourseEndpoint__c = '/course';

		currLMSCredential.EnrollmentEndPoint__c = '/Enrollment';

		currLMSCredential.SSOEndPoint__c = '/SSO';
		currLMSCredential.UserCreaationEndpoint__c = '/Usercreation';

		currLMSCredential.Name = 'LMS Integration';
		try {
			Insert currLMSCredential;
		} catch (exception ex) {
			System.debug('Exception ex' + ex.getMessage());
		}
		return currLMSCredential;
	}

	/* Date Added : 08/16/2016
	Added by : Sailappa Vignesh PG
	This method will create a Class_Offering__c record */
	public static Class_Offering__c createClassOffering() {
		Class_Offering__c currClassOffering = new Class_Offering__c();
		currClassOffering.Course_ID__c = 'Test Test';
		try {
			insert currClassOffering;
		} catch (Exception ex) {
			System.debug('exception ' + ex.getMessage());
		}
		return currClassOffering;
	}

	public static List<Case> createCases(Integer num) {
		List<Case> cases = new List<Case>();
		for (Integer i = 0; i < num; i++) {
			Case c = new Case();
			c.RecordTypeId = wishRecordTypeId;
			c.ChapterName__c = null;
			c.Subject = 'Parent Wish';
			cases.add(c);
		}
		return cases;
	}

	public static List<Wish_Signature_Forms__c> createWishSignatureForms(Integer num) {
		List<Wish_Signature_Forms__c> forms = new List<Wish_Signature_Forms__c>();
		for(Integer i = 0; i < num; i++){
			Wish_Signature_Forms__c newForm = new Wish_Signature_Forms__c();
			forms.add(newForm);
		}
		return forms;
	}

	public static List<Wish_Required_Signature__c> createWishRequiredSignatures(Integer num) {
		Case c = createCases(1)[0];
		insert c;
		Wish_Signature_Forms__c form = createWishSignatureForms(1)[0];
		insert form;
		List<Wish_Required_Signature__c> sigs = new List<Wish_Required_Signature__c>();
		for (Integer i = 0; i < num; i++) {
			Wish_Required_Signature__c sig = new Wish_Required_Signature__c();
			sig.Wish_Case__c = c.Id;
			sig.Wish_Signature_Form__c = form.Id;
			sigs.add(sig);
		}
		return sigs;
	}
}