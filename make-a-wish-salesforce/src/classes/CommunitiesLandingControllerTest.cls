/**
* An apex page controller that takes the user to the right start page based on credentials or lack thereof
*/
@IsTest public with sharing class CommunitiesLandingControllerTest {

	@IsTest
	public static void ActiveVolunteer() {
		Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
		insert chapterAccount;
		Contact volContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
		insert volContact;
		User newActiveVolunteerUser;
		System.runAs (new User(Id = UserInfo.getUserId())) {
			newActiveVolunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volContact.Id);
			insert newActiveVolunteerUser;
		}
		System.runAs(newActiveVolunteerUser) {
			CommunitiesLandingController controller = new CommunitiesLandingController();
			controller.forwardToStartPage();
		}
	}

	@IsTest
	public static void ProspectiveVolunteer() {
		// Instantiate a new controller with all parameters in the page
		Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
		insert chapterAccount;
		Contact volContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
		insert volContact;
		User newProspectiveUser;
		System.runAs (new User(Id = UserInfo.getUserId())) {
			newProspectiveUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(volContact.Id);
			insert newProspectiveUser;
		}
		System.runAs(newProspectiveUser) {
			CommunitiesLandingController controller = new CommunitiesLandingController();
			controller.forwardToStartPage();
		}
	}

	@IsTest
	public static void UserLoginWithReturnURL() {
		// Instantiate a new controller with all parameters in the page
		Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
		insert chapterAccount;
		Contact volContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
		insert volContact;
		User newActiveVolunteerUser;
		System.runAs (new User(Id = UserInfo.getUserId())) {
			newActiveVolunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volContact.Id);
			insert newActiveVolunteerUser;
		}
		System.runAs(newActiveVolunteerUser) {
			String startUrl = 'https://mawa.com';
			apexpages.currentpage().getparameters().put('startUrl', startUrl);
			CommunitiesLandingController controller = new CommunitiesLandingController();
			controller.forwardToStartPage();
		}
	}
}