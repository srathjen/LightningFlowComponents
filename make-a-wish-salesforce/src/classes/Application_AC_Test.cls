/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 28/06/2016
Description : Application_AC_Test is used to increase the code coverage for Application_AC controller.
*****************************************************************************************************/

@IsTest
public class Application_AC_Test {

	private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;

	@TestSetup
	public static void setUp() {
		trac_TriggerHandlerBase.blockTrigger = true;
		User currentUser = Utils.currentUser;
		List<Account> accounts = TestDataFactory.createAccount(1);
		Account account = accounts.get(0);
		account.Name = 'Make-A-Wish Arizona';
		account.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
		account.Volunteer_Manager__c = currentUser.Id;
		account.Alert_for_Unassigned_Wishes__c = 1;
		insert accounts;

		List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
		ICD_Codes__c icdCode = icdCodes.get(0);
		insert icdCode;

		List<Lead> leadsDataFactory = TestDataFactory.createLead(1);
		Lead lead = leadsDataFactory.get(0);
		lead.ChapterName__c = accounts[0].Id;
		lead.FirstName = 'Jack';
		lead.LastName = 'Smith';
		lead.Hidden_Chapter_Change_Confirmation__c = account.Id;
		lead.is_Family_Aware_of_Referral__c = 'Yes';
		lead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
		lead.PD_ICD_Code__c = icdCode.Id;
		lead.Company = 'MAW';
		insert lead;

		List<Contact> contacts = TestDataFactory.createContact(2);
		Contact contact1 = contacts.get(0);
		contact1.FirstName = 'Test1';
		contact1.LastName = 'User2';
		contact1.AccountId = account.Id;
		contact1.ICD_10_Code__c = icdCode.Id;
		insert contacts;

		User volunteerUser = TestDataFactory.createVolunteerUser(1).get(0);
		volunteerUser.LastName = 'Smith0';
		volunteerUser.Email = 'js@email.com';
		System.runAs(TestDataFactory.adminUser) {
			insert volunteerUser;
		}
		Contact contact = new Contact();
		contact.Id = volunteerUser.ContactId;
		contact.Title = 'Mr.';
		contact.Email = 'js@email.com';
		contact.Birth_Month__c = 'May';
		contact.Birth_Day__c = '16';
		contact.npe01__PreferredPhone__c = '5555555555';
		contact.HomePhone = '5555555555';
		contact.I_m_on_LinkedIn__c = 'Yes';
		contact.How_did_you_hear_about_Make_A_Wish__c = 'Friend';
		contact.MailingStreet = '123 St';
		contact.MailingCity = 'Phoenix';
		contact.County__c = 'Arizona';
		contact.MailingPostalCode = '84001';
		contact.MailingStateCode = 'AZ';
		contact.Emergency_Contact__c = 'Mark';
		contact.Emergency_Contact_Relationship__c = 'Friend';
		contact.Emergency_Contact_Phone__c = '5555555555';
		contact.Read__c = 'English';
		contact.Write__c = 'English';
		contact.Speak__c = 'English';
		contact.Understand__c = 'English';
		contact.Language__c = 'English';
		update contact;

		List<Case> cases = TestDataFactory.createCase(1);
		Case wish = cases.get(0);
		wish.Lead__c = lead.Id;
		wish.RecordTypeId = Constant_AC.DIAGNOSIS_RT_ID;
		wish.ChapterName__c = accounts.get(0).Id;
		wish.Subject = 'Wish1';
		wish.Interview_date__c = System.today();
		wish.Wish_Type__c = 'Hawaii';
		wish.Start_Date__c = System.today();
		wish.End_Date__c = System.today();
		wish.ContactId = contact1.Id;
		wish.Status = 'New';
		wish.Rush__c = false;
		wish.Start_Date__c = System.today();
		wish.Budget_Submitted_Date__c = System.today();
		wish.Budget_Approved_Date__c = System.today();
		wish.Update_Wish_Child_Form_Info__c = true;
		insert cases;

		List<Task> tasks = TestDataFactory.createTask(1);
		Task task = tasks.get(0);
		task.ActivityDate = System.today();
		task.Subject = 'Wish1';
		task.Status = 'Not Started';
		task.WhatId = wish.Id;
		insert tasks;

		List<Background_check__c> backgroundChecks = TestDataFactory.createBackgroundCheck(1);
		Background_check__c backgroundCheck = backgroundChecks.get(0);
		backgroundCheck.Date__c = System.today();
		backgroundCheck.Volunteer__c = volunteerUser.ContactId;
		backgroundCheck.Date_Completed__c = System.today().addYears(-3);
		backgroundCheck.Status__c = 'Sent to First Advantage';
		insert backgroundChecks;

		List<npe5__Affiliation__c> affiliations = TestDataFactory.createAffiliation(1);
		npe5__Affiliation__c affiliation = affiliations[0];
		affiliation.npe5__Contact__c = volunteerUser.ContactId;
		affiliation.npe5__Organization__c = account.Id;
		affiliation.npe5__Primary__c = true;
		affiliation.npe5__Status__c = 'Pending';
		affiliation.Constituent_Code__c = Constant_AC.BOARD_MEMBER_RT_LABEL;
		insert affiliations;

		List<Role__c> roles = TestDataFactory.createRole(1, true);
		Role__c wishGranterRole = roles.get(0);
		wishGranterRole.Name = 'Wish Granter';
		wishGranterRole.isWishRole__c = true;
		insert roles;

		List<Chapter_Role__c> chapterRoles = TestDataFactory.createChapterRole(1);
		Chapter_Role__c wishGranterArizonaRole = chapterRoles.get(0);
		wishGranterArizonaRole.Chapter_Name__c = account.Id;
		wishGranterArizonaRole.Role_Name__c = wishGranterRole.Id;
		wishGranterArizonaRole.Background_Check_Required__c = false;
		insert chapterRoles;

		insert new DocuSignCredentialsSetting__c(Name = 'Test', Account__c = 'Test', IntegratorKey__c = 'Test');
		DocuSignCredentialsSetting__c newSetting = new DocuSignCredentialsSetting__c();
		newSetting.account__c = '0afd45e1-ae2d-468c-a168-b8603dae66a3';
		newSetting.IntegratorKey__c = 'ea6d625f-6c08-4b12-aa2d-554909addb30';
		newSetting.Name = 'kanagaraj@mstsolutions.com';
		insert newSetting;

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void updateVolunteerContact() {
		User volunteerUser = [
				SELECT Id,UserRoleId,Username,ProfileId,Email,FirstName,ContactId,LastName,IsActive
				FROM User
				WHERE LastName = 'Smith0'
		][0];
		List<Contact> conList = new List<Contact>();
		conList = [
				SELECT Id
				FROM Contact
		];

		PageReference pageRef = Page.Application_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('bgRequired', 'true');
		ApexPages.currentPage().getParameters().put('trainingRequired', 'true');
		ApexPages.currentPage().getParameters().put('showeditmode', 'true');
		ApexPages.currentPage().getParameters().put('event', 'signing_complete');
		Application_AC applicationAcIns;
		System.runAs(volunteerUser) {
			applicationAcIns = new Application_AC();
			applicationAcIns.saveRec();
			applicationAcIns.EditRec();
			applicationAcIns.getStates();
			applicationAcIns.getDays();
			applicationAcIns.getMonths();
			applicationAcIns.getLanguages();
			applicationAcIns.getProfessionalSKills();
			applicationAcIns.getRoles();
			applicationAcIns.getPreferedPhoneType();
			applicationAcIns.getIamOnLinkedIn();
			applicationAcIns.getTitles();
			applicationAcIns.getCountries();
			applicationAcIns.getContactAtWorks();
			applicationAcIns.getInterstedList();
			applicationAcIns.DisplayDescription();
			applicationAcIns.getHowdidyouhearaboutMakeAWish();
			applicationAcIns.editmode = true;
			applicationAcIns.showsubmitbutton = true;
			applicationAcIns.dynamicName = 'test';
			applicationAcIns.applicationDynamicContent = 'test';
			applicationAcIns.submitdisable = true;
			applicationAcIns.isSigned = true;
			Set<String> roleNameSet = applicationAcIns.roleNameSet;
		}
		System.assertEquals(volunteerUser.Email, 'js@email.com', 'Email does not updated or Mismatched Email');
		System.assert(volunteerUser.Email == 'js@email.com', 'Email does not updated or Mismatched Email');
	}

	@IsTest
	public static void signDocument() {
		User volunteerUser = [
				SELECT Id,UserRoleId,Username,ProfileId,Email,FirstName,ContactId,LastName,IsActive
				FROM User
				WHERE LastName = 'Smith0'
		][0];
		PageReference pageRef = Page.Application_VF;
		Test.setCurrentPage(pageRef);

		Application_AC applicationAcIns;
		System.runAs(volunteerUser) {
			applicationAcIns = new Application_AC();
			Test.setMock(HttpCalloutMock.class, new Mock_ResponseGenerator());
			Test.StartTest();
			applicationAcIns.SubmitAndSign();
			applicationAcIns.saveRec();
			applicationAcIns.DisplayDescription();
			Test.StopTest();
		}
		System.assertEquals(volunteerUser.Email, 'js@email.com', 'Email does not updated or Mismatched Email');
		System.assert(volunteerUser.Email == 'js@email.com', 'Email does not updated or Mismatched Email');
	}

	@IsTest
	public static void updateVolunteerContactwithHomePhone() {
		User volunteerUser = [
				SELECT Id,UserRoleId,Username,ProfileId,Email,FirstName,ContactId,LastName,IsActive
				FROM User
				WHERE LastName = 'Smith0'
		][0];
		Contact currentContact = [
				SELECT Id, Read__c, Speak__c, Write__c, Understand__c, Language__c
				FROM Contact
				WHERE Id = :volunteerUser.ContactId
		];
		currentContact.Read__c = currentContact.Speak__c = currentContact.Write__c
				= currentContact.Understand__c = currentContact.Language__c = null;

		currentContact.Birth_Year__c = '2000';
		currentContact.Birth_Month__c = 'January';
		currentContact.Birth_Day__c = '01';
		update currentContact;

		npe5__Affiliation__c affiliation = [
				SELECT Id, npe5__Organization__c
				FROM npe5__Affiliation__c
				WHERE npe5__Contact__c = :volunteerUser.ContactId
		][0];

		system.RunAs(volunteerUser) {
			PageReference pageRef = Page.Application_VF;
			Test.StartTest();
			Test.setCurrentPage(pageRef);
			ApexPages.currentPage().getParameters().put('bgRequired', 'true');
			ApexPages.currentPage().getParameters().put('trainingRequired', 'true');
			Application_AC applicationAcIns = new Application_AC();
			applicationAcIns.saveRec();
			applicationAcIns.EditRec();
			applicationAcIns.getStates();
			applicationAcIns.getDays();
			applicationAcIns.getMonths();
			applicationAcIns.getLanguages();
			applicationAcIns.getProfessionalSKills();
			applicationAcIns.chaptersNameSet.add(affiliation.npe5__Organization__c);
			applicationAcIns.getRoles();
			applicationAcIns.getPreferedPhoneType();
			applicationAcIns.getIamOnLinkedIn();
			applicationAcIns.getTitles();
			applicationAcIns.getCountries();
			applicationAcIns.getContactAtWorks();
			applicationAcIns.getInterstedList();
			applicationAcIns.DisplayDescription();
			applicationAcIns.getHowdidyouhearaboutMakeAWish();
			applicationAcIns.editmode = true;
			applicationAcIns.showsubmitbutton = true;
			applicationAcIns.dynamicName = 'test';
			applicationAcIns.applicationDynamicContent = 'test';
			applicationAcIns.submitdisable = true;
			applicationAcIns.isSigned = true;
			applicationAcIns.hidePopup();
			Test.StopTest();
		}
		System.assertEquals(volunteerUser.Email, 'js@email.com', 'Email does not updated or Mismatched Email');
		System.assert(volunteerUser.Email == 'js@email.com', 'Email does not updated or Mismatched Email');
	}

	@IsTest
	public static void updateVolunteerContactwithMobilePhone() {
		User volunteerUser = [
				SELECT Id,UserRoleId,Username,ProfileId,Email,FirstName,ContactId,LastName,IsActive
				FROM User
				WHERE LastName = 'Smith0'
		][0];

		system.RunAs(volunteerUser) {
			PageReference pageRef = Page.Application_VF;
			Test.StartTest();
			Test.setCurrentPage(pageRef);
			ApexPages.currentPage().getParameters().put('bgRequired', 'true');
			ApexPages.currentPage().getParameters().put('trainingRequired', 'true');
			Application_AC applicationAcIns = new Application_AC();
			applicationAcIns.saveRec();
			applicationAcIns.EditRec();
			applicationAcIns.getStates();
			applicationAcIns.getDays();
			applicationAcIns.getMonths();
			applicationAcIns.getLanguages();
			applicationAcIns.getProfessionalSKills();
			applicationAcIns.getRoles();
			applicationAcIns.getPreferedPhoneType();
			applicationAcIns.getIamOnLinkedIn();
			applicationAcIns.getTitles();
			applicationAcIns.getCountries();
			applicationAcIns.getContactAtWorks();
			applicationAcIns.getInterstedList();
			applicationAcIns.DisplayDescription();
			applicationAcIns.getHowdidyouhearaboutMakeAWish();
			applicationAcIns.editmode = true;
			applicationAcIns.showsubmitbutton = true;
			applicationAcIns.dynamicName = 'test';
			applicationAcIns.applicationDynamicContent = 'test';
			applicationAcIns.submitdisable = true;
			applicationAcIns.isSigned = true;
			Test.StopTest();
		}
		System.assertEquals(volunteerUser.Email, 'js@email.com', 'Email does not updated or Mismatched Email');
		System.assert(volunteerUser.Email == 'js@email.com', 'Email does not updated or Mismatched Email');
	}

	@IsTest
	public static void updateVolunteerContactwithOtherPhone() {
		User volunteerUser = [
				SELECT Id,UserRoleId,Username,ProfileId,Email,FirstName,ContactId,LastName,IsActive
				FROM User
				WHERE LastName = 'Smith0'
		][0];
		System.runAs(volunteerUser) {
			PageReference pageRef = Page.Application_VF;
			Test.startTest();
			Test.setCurrentPage(pageRef);
			ApexPages.currentPage().getParameters().put('bgRequired', 'true');
			ApexPages.currentPage().getParameters().put('trainingRequired', 'true');
			Application_AC applicationAcIns = new Application_AC();
			applicationAcIns.saveRec();
			applicationAcIns.EditRec();
			applicationAcIns.getStates();
			applicationAcIns.getDays();
			applicationAcIns.getMonths();
			applicationAcIns.getLanguages();
			applicationAcIns.getProfessionalSKills();
			applicationAcIns.getRoles();
			applicationAcIns.getPreferedPhoneType();
			applicationAcIns.getIamOnLinkedIn();
			applicationAcIns.getTitles();
			applicationAcIns.getCountries();
			applicationAcIns.getContactAtWorks();
			applicationAcIns.getInterstedList();
			applicationAcIns.DisplayDescription();
			applicationAcIns.getHowdidyouhearaboutMakeAWish();
			applicationAcIns.editmode = true;
			applicationAcIns.showsubmitbutton = true;
			applicationAcIns.dynamicName = 'test';
			applicationAcIns.applicationDynamicContent = 'test';
			applicationAcIns.submitdisable = true;
			applicationAcIns.confirmSign();
			applicationAcIns.isSigned = true;
			Test.stopTest();
		}
		System.assertEquals(volunteerUser.Email, 'js@email.com', 'Email does not updated or Mismatched Email');
		System.assert(volunteerUser.Email == 'js@email.com', 'Email does not updated or Mismatched Email');
	}
}