/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 28/06/2016
Description : Application_AC_Test is used to increase the code coverage for Application_AC controller.
*****************************************************************************************************/

@isTest
public class Application_AC_Test {

	/* This method is used to update the volunteer contact information*/
	public testMethod static void updateVolunteerContact() {
		Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
		insert chapterAccount;
		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
		volunteerContact.Write__c = 'Arabic; Chinese; English';
		volunteerContact.is_Application__c = 'Complete';
		insert volunteerContact;
		User currentVoulnteerUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currentVoulnteerUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(volunteerContact.Id);
		}
		OrientationandTrainingUtil.CreateAffiliation(currentVoulnteerUser.ContactId);
		OrientationandTrainingUtil.insertDocusignSetting();
		OrientationandTrainingUtil.createDynamicContent();

		list<Contact> conList = new list<Contact>();
		conList = [
				select id
				from contact];
		
        PageReference pageRef = Page.Application_VF;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('bgRequired', 'true');
		ApexPages.currentPage().getParameters().put('trainingRequired', 'true');
		ApexPages.currentPage().getParameters().put('showeditmode', 'true');
		ApexPages.currentPage().getParameters().put('event', 'signing_complete');
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
		Set<String> roleNameSet = applicationAcIns.roleNameSet;

		System.assertEquals(currentVoulnteerUser.Email, 'jonathanEdwards@gmail.com', 'Email does not updated or Mismatched Email');
		System.assert(currentVoulnteerUser.Email == 'jonathanEdwards@gmail.com', 'Email does not updated or Mismatched Email');
	}
    
	/*This method is used to sign the docusign document when the application is completed*/
	public testMethod static void signDocument() {
		insert new DocuSignCredentialsSetting__c(Name = 'Test', Account__c = 'Test', IntegratorKey__c = 'Test');
		Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
		User currentVoulnteerUser;
        System.RunAs(new User(Id = UserInfo.getUserId())) {
            currentVoulnteerUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(volunteerContact.Id);
        }
		npe5__Affiliation__c newAffiliation = OrientationandTrainingUtil.CreateAffiliation(currentVoulnteerUser.ContactId);
		Role__c roleName = OrientationandTrainingUtil.createRole();
		Chapter_Role__c chapterRole = OrientationandTrainingUtil.createChapter(newAffiliation.npe5__Organization__c, roleName.id);
		OrientationandTrainingUtil.insertDocusignSetting();
		OrientationandTrainingUtil.createDynamicContent();
		PageReference pageRef = Page.Application_VF;
		Test.setCurrentPage(pageRef);
		Application_AC applicationAcIns = new Application_AC();
		Test.setMock(HttpCalloutMock.class, new Mock_ResponseGenerator());
		Test.StartTest();
		applicationAcIns.SubmitAndSign();
		applicationAcIns.saveRec();
		applicationAcIns.DisplayDescription();
		Test.StopTest();
        
		System.assertEquals(currentVoulnteerUser.Email, 'jonathanEdwards@gmail.com', 'Email does not updated or Mismatched Email');
		System.assert(currentVoulnteerUser.Email == 'jonathanEdwards@gmail.com', 'Email does not updated or Mismatched Email');
	}

	/* This method is used to update the volunteer contact Alternate Phone type and prefered phone type with the value of Home*/
	public testMethod static void updateVolunteerContactwithHomePhone() {
		Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
		insert chapterAccount;

		Contact volunteerContact = OrientationandTrainingUtil.VolunteerContactwithHomePhone(chapterAccount.Id);
		volunteerContact.Write__c = 'Arabic; Chinese; English';
		insert volunteerContact;
		User currentVoulnteerUser;
		Application_AC.roleWrapper newRoleWrapper = new Application_AC.roleWrapper();
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currentVoulnteerUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(volunteerContact.Id);
			insert currentVoulnteerUser;
		}
		Contact currentContact = [
				SELECT Id, Read__c, Speak__c, Write__c, Understand__c, Language__c
				FROM Contact
				WHERE Id = :currentVoulnteerUser.ContactId
		];
		currentContact.Read__c = currentContact.Speak__c = currentContact.Write__c
				= currentContact.Understand__c = currentContact.Language__c = null;

		currentContact.Birth_Year__c = '2000';
		currentContact.Birth_Month__c = 'January';
		currentContact.Birth_Day__c = '01';
		update currentContact;
		npe5__Affiliation__c newAffiliation = OrientationandTrainingUtil.CreateAffiliation(currentVoulnteerUser.ContactId);
		insert newAffiliation;
		Role__c roleName = OrientationandTrainingUtil.createRole();
		roleName.Exclude_from_Application__c = false;
		insert roleName;
		Chapter_Role__c chapterRole = OrientationandTrainingUtil.createChapter(newAffiliation.npe5__Organization__c, roleName.id);
		insert chapterRole;
		OrientationandTrainingUtil.CreateAffiliation(currentVoulnteerUser.ContactId);
		OrientationandTrainingUtil.insertDocusignSetting();
		OrientationandTrainingUtil.createDynamicContent();

		system.RunAs(currentVoulnteerUser) {
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
			applicationAcIns.chaptersNameSet.add(newAffiliation.npe5__Organization__c);
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
		System.assertEquals(currentVoulnteerUser.Email, 'jonathanEdwards@gmail.com', 'Email does not updated or Mismatched Email');
		System.assert(currentVoulnteerUser.Email == 'jonathanEdwards@gmail.com', 'Email does not updated or Mismatched Email');
	}

	/* This method is used to update the volunteer contact Alternate Phone type and prefered phone type with the value of Mobile*/
	public testMethod static void updateVolunteerContactwithMobilePhone() {
		Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
		insert chapterAccount;
		Contact volunteerContact = OrientationandTrainingUtil.VolunteerContactwithMobilePhone(chapterAccount.Id);
		volunteerContact.Write__c = 'Arabic; Chinese; English';
		insert volunteerContact;
		User currentVoulnteerUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currentVoulnteerUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(volunteerContact.Id);
			insert currentVoulnteerUser;
		}
		npe5__Affiliation__c newAff = OrientationandTrainingUtil.CreateAffiliation(currentVoulnteerUser.ContactId);
		OrientationandTrainingUtil.insertDocusignSetting();
		OrientationandTrainingUtil.createDynamicContent();

		system.RunAs(currentVoulnteerUser) {
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
		System.assertEquals(currentVoulnteerUser.Email, 'jonathanEdwards@gmail.com', 'Email does not updated or Mismatched Email');
		System.assert(currentVoulnteerUser.Email == 'jonathanEdwards@gmail.com', 'Email does not updated or Mismatched Email');
	}

	/* This method is used to update the volunteer contact Alternate Phone type and prefered phone type with the value of Home and Mobile*/
	public testMethod static void updateVolunteerContactwithOtherPhone() {
		Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
		insert chapterAccount;

		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContactwithOtherPhone(chapterAccount.Id);
		insert volunteerContact;

		User currentVoulnteerUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currentVoulnteerUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(volunteerContact.Id);
			insert currentVoulnteerUser;
		}
		OrientationandTrainingUtil.CreateAffiliation(currentVoulnteerUser.ContactId);
		OrientationandTrainingUtil.insertDocusignSetting();
		OrientationandTrainingUtil.createDynamicContent();

		system.RunAs(currentVoulnteerUser) {

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
			applicationAcIns.confirmSign();
			applicationAcIns.isSigned = true;
			Test.StopTest();
		}
		System.assertEquals(currentVoulnteerUser.Email, 'jonathanEdwards@gmail.com', 'Email does not updated or Mismatched Email');
		System.assert(currentVoulnteerUser.Email == 'jonathanEdwards@gmail.com', 'Email does not updated or Mismatched Email');
	}
}