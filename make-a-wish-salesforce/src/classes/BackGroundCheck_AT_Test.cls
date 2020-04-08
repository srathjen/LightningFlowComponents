/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 28/06/2016
Description : BackGroundCheck_AT_Test is used to increase the code coverage for Application_AC controller.
*****************************************************************************************************/
@IsTest
public class BackGroundCheck_AT_Test {

	/*This method is used to update the background check record to approved*/
	@IsTest
	public static void updateBackGroundChecktoApproved() {
		Account volunteerAccount = OrientationandTrainingUtil.createVolunteerAccount();
		insert volunteerAccount;

		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.Id);
		insert volunteerContact;

		Role__c role = OrientationandTrainingUtil.createRole();
		insert role;

		Chapter_Role__c chapterRole = OrientationandTrainingUtil.createChapter(volunteerAccount.Id, role.Id);
		insert chapterRole;

		Volunteer_Roles__c volunteerRole = OrientationandTrainingUtil.createVolRole(volunteerContact.Id, chapterRole.Id);
		Volunteer_Roles__c volunteerRoleRec = OrientationandTrainingUtil.createVolRole(volunteerContact.Id, chapterRole.Id);
		insert new List<Volunteer_Roles__c>{
				volunteerRole, volunteerRoleRec
		};

		Orientation_Training__c orientationId = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
		insert orientationId;

		Chapter_Role_O_T__c chapterRoleT = OrientationandTrainingUtil.createChapterOandT (chapterRole.Id, orientationId.Id);
		insert chapterRoleT;

		npe5__Affiliation__c orgAfflitation = OrientationandTrainingUtil.CreateAffiliationwithAccount(volunteerContact.Id, volunteerAccount.Id);
		insert orgAfflitation;

		insert OrientationandTrainingUtil.createCOI(volunteerContact.Id);
		Background_check__c backgroundcheck = OrientationandTrainingUtil.createBackgroundCheck(volunteerContact.Id);
		insert backgroundcheck;

		backgroundcheck.Status__c = 'Approved';
		backgroundcheck.Current__c = true;
		backgroundcheck.Date_Completed__c = System.today();
		update backgroundcheck;
	}

	/*This method is used to update the background check record to Rejected*/

	@IsTest
	public static void updateBackGroundChecktoRejected() {
		Account volunteerAccount = OrientationandTrainingUtil.createVolunteerAccount();
		insert volunteerAccount;

		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.Id);
		insert volunteerContact;

		Background_check__c backgroundcheck = OrientationandTrainingUtil.createBackgroundCheckFasleRec(volunteerContact.Id);
		insert backgroundcheck;

		backgroundcheck.Status__c = 'Rejected';
		backgroundcheck.Hidden_Background_Rejected__c = true;
		backgroundcheck.HiddenBackgroundExpire__c = true;
		update backgroundcheck;

		backgroundcheck.Hidden_Background_Rejected__c = false;
		update backgroundcheck;

		backgroundcheck.Status__c = 'Received FROM First Advantage';
		update backgroundcheck;
	}
	/*This method is used to create background check record*/

	@IsTest
	public static void CreateBackGroundCheckRecord() {
		Account volunteerAccount = OrientationandTrainingUtil.createVolunteerAccount();
		insert volunteerAccount;

		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.Id);
		insert volunteerContact;

		insert OrientationandTrainingUtil.createBackgroundCheckRec(volunteerContact.Id);
		Background_check__c backgroundcheck = OrientationandTrainingUtil.createBackgroundCheckActiveRec(volunteerContact.Id);
		insert backgroundcheck;

	}

	/*This method is used to create background check record to Active*/
	/*@IsTest
	public static void updateBackgroundChecktoActive() {
		Account volunteerAccount = OrientationandTrainingUtil.createVolunteerAccount();
		insert volunteerAccount;

		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.Id);
		insert volunteerContact;

		Background_check__c backgroundcheck = OrientationandTrainingUtil.createBackgroundCheckActiveRec(volunteerContact.Id);
		Background_check__c backgroundcheckfalse = OrientationandTrainingUtil.createBackgroundCheckFasleRec(volunteerContact.Id);
		insert new List<Background_check__c>{
				backgroundcheck, backgroundcheckfalse
		};
		backgroundcheckfalse.Current__c = true;
		backgroundcheckfalse.Date_Completed__c = System.today() + 9;
		Database.SaveResult result = Database.update(backgroundcheckfalse, false);
		System.assertEquals('Active Background Check Already Exist',result.getErrors()[0].getMessage());
	}*/

	/*This method is used to create background check exisiting background record is Active or not*/
	/*@IsTest
	public static void CheckExisitingRecordtoActive() {
		Account volunteerAccount = OrientationandTrainingUtil.createVolunteerAccount();
		insert volunteerAccount;

		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.Id);
		insert volunteerContact;

		Background_check__c backgroundcheck = OrientationandTrainingUtil.createBackgroundCheckActiveRec(volunteerContact.Id);
		Background_check__c backgroundcheckActive = OrientationandTrainingUtil.createBackgroundCheckActiveRec(volunteerContact.Id);
		Background_check__c backgroundcheckfalse = OrientationandTrainingUtil.createBackgroundCheckFasleRec(volunteerContact.Id);
		insert new List<Background_check__c>{
				backgroundcheck, backgroundcheckActive, backgroundcheckfalse
		};
		backgroundcheckfalse.Current__c = true;
		backgroundcheckfalse.Date_Completed__c = System.today() + 9;
		Database.SaveResult result = Database.update(backgroundcheckfalse, false);
		System.assertEquals('Active Background Check Already Exist',result.getErrors()[0].getMessage());
	}*/

	@IsTest
	private static void createBackgroundCheckNationalStaff() {
		User currUser = [
				SELECT Id
				FROM User
				WHERE Id = :UserInfo.getUserId()
				LIMIT 1
		];
		User nationalStaff;
		System.runAs(currUser) {
			nationalStaff = OrientationandTrainingUtil.createUserWithRole([
					SELECT Id
					FROM UserRole
					WHERE Name = 'National Staff'
			].Id);
		}
		System.runAs(nationalStaff) {
			Account volunteerAccount = OrientationandTrainingUtil.createVolunteerAccount();
			insert volunteerAccount;

			Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.Id);
			insert volunteerContact;
			volunteerContact.Region_Chapter__c = volunteerAccount.Id;
			update volunteerContact;

			Background_check__c backCheck = new Background_check__c();
			backCheck.Date__c = System.today() + 3;
			backCheck.Volunteer__c = volunteerContact.Id;
			backCheck.Status__c = 'Manual';
			backCheck.Current__c = true;
			backCheck.Date_Completed__c = System.today() + 9;
			backCheck.OwnerId = nationalStaff.Id;
			insert backCheck;
		}
		//System.assertEquals('Active Background Check Already Exist',result.getErrors()[0].getMessage());
	}

	@IsTest
	private static void createBackgroundCheckNonNationalStaff() {
		User currUser = [
				SELECT Id
				FROM User
				WHERE Id = :UserInfo.getUserId()
				LIMIT 1
		];
		Id staffProfileId = [
				SELECT Id
				FROM Profile
				WHERE Name = 'Program Staff'
		].Id;
		User nonNationalStaff;
		System.runAs(currUser) {
			nonNationalStaff = OrientationandTrainingUtil.createUserWithRole([
					SELECT Id
					FROM UserRole
					WHERE Name = 'National Staff'
			].Id);
			nonNationalStaff.UserRoleId = [
					SELECT Id
					FROM UserRole
					WHERE Name = 'Alabama - chapter'
			].Id;
			nonNationalStaff.ProfileId = staffProfileId;
			insert nonNationalStaff;
		}
		System.runAs(nonNationalStaff) {
			Account volunteerAccount = OrientationandTrainingUtil.createVolunteerAccount();
            insert volunteerAccount;

			Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.Id);
            insert volunteerContact;

			Background_check__c backCheck = new Background_check__c();
			backCheck.Date__c = System.today() + 3;
			backCheck.Volunteer__c = volunteerContact.Id;
			backCheck.Status__c = 'test';
			backCheck.Current__c = true;
			backCheck.Date_Completed__c = System.today() + 9;
			backCheck.OwnerId = nonNationalStaff.Id;
			insert backCheck;
		}
		//System.assertEquals('Active Background Check Already Exist',result.getErrors()[0].getMessage());
	}

	@IsTest
	private static void checkVolOpp() {
		Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
		insert chapterAccount;

		Contact volunteerCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
		volunteerCon.MailingLatitude = -24.355798;
		volunteerCon.MailingLongitude = 69.830469;
		volunteerCon.MailingStreet = '7540 E Gold Dust Ave';
		volunteerCon.MailingCountry = 'United States';
		volunteerCon.MailingState = 'Arizona';
		volunteerCon.MailingCity = 'Scottsdale';
		insert volunteerCon;

		Case wishCase = OrientationandTrainingUtil.CreateParentCaseWithStatus();
		wishCase.ChapterName__c = chapterAccount.Id;
		wishCase.ContactId = volunteerCon.Id;
		insert wishCase;

		Role__c roleName = OrientationandTrainingUtil.createRole();
		insert roleName;
		Chapter_Role__c chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.Id, roleName.Id);
		insert chapterRole;
		Volunteer_Opportunity__c wishVolOpp = OrientationandTrainingUtil.CreateNewWishVolunteerOpportunity(chapterAccount.Id, chapterRole.Id, wishCase.Id);
		wishVolOpp.Status__c = 'Approved';
		wishVolOpp.Volunteer_Name__c = volunteerCon.Id;
		insert wishVolOpp;

		Test.startTest();
		Volunteer_Roles__c volRole = OrientationandTrainingUtil.createVolRole(volunteerCon.Id, chapterRole.Id);
		insert volRole;

		Background_check__c backgroundcheck = OrientationandTrainingUtil.createBackgroundCheckFasleRec(volunteerCon.Id);
		backgroundcheck.Hidden_Background_Rejected__c = false;
		insert backgroundcheck;

		backgroundcheck.Hidden_Background_Rejected__c = true;
		update backgroundcheck;
		Test.stopTest();
	}
}
