/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 28/06/2016
Description : UserTrigger_AT_Test is used to increase the code coverage for Application_AC controller.
*****************************************************************************************************/
@isTest
public class UserTrigger_AT_Test {

	/*This method is used to create a system Addmin user records*/
	@testSetup static void setup() {
		User user = OrientationandTrainingUtil.createrSystemAdminUser();
		insert user;
	}
	/*This method is used to create a prospectiv user records*/

	public testmethod static void createProspectiveUser() {
		User dbUser = [
				SELECT Id,UserRoleId,UserName,ProfileId,Email,FirstName,LastName,isActive
				From User
				WHERE FirstName =:'Test FirstName'
				Limit 1
		];
		system.RunAs(dbUser) {
			Test.StartTest();
			Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
			insert chapterAccount;
			Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
			insert volunteerContact;
			User prospectiveUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(volunteerContact.id);
			insert prospectiveUser;
			prospectiveUser.Email = 'TestEmail1234@mail.com';
			Update prospectiveUser;
			Test.StopTest();
		}
	}

	/*This method is used to create a public Group records*/
	public testmethod static void createPublicGroup() {
		User dbUser = [
				SELECT Id,UserRoleId,UserName,ProfileId,Email,FirstName,LastName,isActive
				From User
				WHERE FirstName = :'Test FirstName'
				Limit 1
		];
		system.RunAs(dbUser) {
			Test.StartTest();
			OrientationandTrainingUtil.cretateGroup();
			Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
			insert chapterAccount;
			Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
			insert volunteerContact;
			User user = OrientationandTrainingUtil.createProspectiveVolunteerUser(volunteerContact.id);
			insert user;
			Test.StopTest();
		}
	}

	public testmethod static void updateUser() {
		system.RunAs(new user(ID = UserInfo.getUserID())) {
			Account chapterAcc = OrientationandTrainingUtil.createVolunteerAccount();
			Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
			insert new List<Account>{
					chapterAcc, chapterAccount
			};

			Contact chapterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAcc.Id);
			Contact chaptercontact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
			Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon();
			insert new List<Contact>{
					chapterCon, chaptercontact, wishChild
			};

			Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
			insert parentCase;

			Account chapterAccountWithVolunteerManager = OrientationandTrainingUtil.createVolunteerAccountwithVolunteerManager();
			insert chapterAccountWithVolunteerManager;

			Case updatecase = new Case();
			updatecase.isEmailWishGranter__c = true;
			updatecase.InActiveWishGranter__c = 'test';
			updatecase.Id = parentCase.Id;
			Test.startTest();
			update updateCase;

			//CaseTeamRole caseRole = OrientationandTrainingUtil.CreateCaseTeamRole();
			CaseTeamRole role = [
					SELECT Id,Name
					FROM CaseTeamRole
					WHERE Name = :'Wish Granter'
			];

			User arizonaVolunterrUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(chapterCon.Id);
			User alabamaVolunterrUser = OrientationandTrainingUtil.createVolunteerUser(chaptercontact .Id);
			alabamaVolunterrUser.Username += '1';
			insert new List<User>{
					arizonaVolunterrUser, alabamaVolunterrUser
			};

			CaseTeamMember arizonacasTemMember = OrientationandTrainingUtil.createCaseTeamMember(parentCase.id,
					arizonaVolunterrUser.Id, role.Id);
			CaseTeamMember alabamacasTemMember = OrientationandTrainingUtil.createCaseTeamMember(parentCase.id,
					alabamaVolunterrUser.Id, role.Id);
			insert new List<CaseTeamMember>{
					arizonacasTemMember, alabamacasTemMember
			};

			User queryAlabamaUser = [
					SELECT Id,IsActive
					from User
					WHERE Id = :alabamaVolunterrUser.Id
			];
			Volunteer_Opportunity__c volunteerOpportunityRec = OrientationandTrainingUtil.NewnonWishVolunteerOpportunity(chapterAccountWithVolunteerManager.Id, chaptercontact.Id);
			insert volunteerOpportunityRec;
			user updateUser = new User();
			updateUser.Id = queryAlabamaUser.Id;
			updateUser.IsActive = false;
			update updateUser;
			updateUser.IsActive = True;
			Update updateUser;
			Test.stopTest();
		}
	}

	public testmethod static void Test_AddInternalUserToChatterGroup() {
		system.RunAs(new user(ID = UserInfo.getUserID())) {
			CollaborationGroup newGroup = OrientationandTrainingUtil.createCollaborationGroup('America');
			insert newGroup;
			UserRole newUserRole = new UserRole();
			newUserRole.Name = 'America - Chapter';
			test.startTest();
			Insert newUserRole;
			User newUser = OrientationandTrainingUtil.createUserWithRole(newUserRole.Id);
			insert newUser;
			test.stopTest();
		}
	}

	public testmethod static void Test_RemoveInternalUserToChatterGroup() {
		system.RunAs(new user(ID = UserInfo.getUserID())) {
			UserRole newUserRole = new UserRole();
			newUserRole.Name = 'Alabama - Chapter';
			Insert newUserRole;
			UserRole newUserRole1 = new UserRole();
			newUserRole1.Name = 'Arizona - Chapter';
			test.startTest();
			Insert newUserRole1;
			User newUser = OrientationandTrainingUtil.createUserWithRole(newUserRole.Id);
			insert newUser;
			newUser.UserRoleId = newUserRole1.Id;
			update newUser;
			test.stopTest();
		}
	}
}