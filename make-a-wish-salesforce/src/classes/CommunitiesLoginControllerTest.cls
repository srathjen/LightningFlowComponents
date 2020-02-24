/**
 * An apex page controller that exposes the site login functionality
 */
@IsTest
global class CommunitiesLoginControllerTest {

	// Login As Prospective User Profile
	static testmethod void loginAsProspectiveUser() {
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(con.id);
		insert affiliation;
		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
			insert currUser;
		}
		System.RunAs(currUser) {
			CommunitiesLoginController controller = new CommunitiesLoginController();
			controller.userName = 'joathanedwards@gmail.com';
			controller.login();
		}
		System.assert(con.Id != Null, 'Id should not blank');
		System.assertEquals(currUser.ProfileId, label.Prospective_Volunteer_Profile, 'Id does not match');
	}

	// Login As Active User Profile
	static testmethod void loginAsActiveUser() {
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(con.id);
		insert affiliation;
		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createActiveVolunteerUser(con.id);
			insert currUser;
		}
		System.RunAs(currUser) {
			CommunitiesLoginController controller = new CommunitiesLoginController();
			controller.userName = 'joathanedwards@gmail.com';
			controller.login();
		}
		System.assert(con.Id != Null, 'Id should not blank');
		System.assertEquals(currUser.ProfileId, label.Active_Volunteer_Profile, 'Id does not match');
	}

	// Creating custom setting values.
	static testmethod void createCustomSettingValueforActive() {
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		npe5__Affiliation__c neworgAffiliation = new npe5__Affiliation__c ();
		neworgAffiliation.npe5__Contact__c = con.Id;
		neworgAffiliation.npe5__Organization__c = acc.Id;
		neworgAffiliation.npe5__Primary__c = true;
		neworgAffiliation.npe5__Status__c = 'Prospective';
		neworgAffiliation.Constituent_code__c = Constant_AC.BOARD_MEMBER_RT_LABEL;
		insert neworgAffiliation;
		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createActiveVolunteerUser(con.id);
			insert currUser;
		}
		System.RunAs(currUser) {
			HoldCurrentChapter__c currVal = new HoldCurrentChapter__c();
			currVal.Name = currUser.id;
			currVal.CurrentChapter__c = acc.name;
			insert currVal;
			CommunitiesLoginController controller = new CommunitiesLoginController();
			controller.userName = 'joathanedwards@gmail.com';
			controller.login();
		}
		System.assert(con.Id != Null, 'Id should not blank');
		System.assertEquals(currUser.ProfileId, label.Active_Volunteer_Profile, 'Id does not macth');
	}

	static testmethod void withoutCustomSettingValueforActive() {
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		npe5__Affiliation__c neworgAffiliation = new npe5__Affiliation__c ();
		neworgAffiliation.npe5__Contact__c = con.Id;
		neworgAffiliation.npe5__Organization__c = acc.Id;
		neworgAffiliation.npe5__Primary__c = true;
		neworgAffiliation.npe5__Status__c = 'Prospective';
		neworgAffiliation.Constituent_code__c = Constant_AC.BOARD_MEMBER_RT_LABEL;
		insert neworgAffiliation;
		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createActiveVolunteerUser(con.id);
			insert currUser;
		}
		System.RunAs(currUser) {
			CommunitiesLoginController controller = new CommunitiesLoginController();
			controller.userName = 'joathanedwards@gmail.com';
			controller.login();
		}
		System.assert(con.Id != Null, 'Id should not blank');
		System.assertEquals(currUser.ProfileId, label.Active_Volunteer_Profile, 'Id does not match');
	}

	// Login as wrong user.
	static testmethod void loginAsWrongUser() {
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(con.id);
		insert affiliation;
		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createActiveVolunteerUser(con.id);
			insert currUser;
		}
		System.RunAs(currUser) {
			CommunitiesLoginController controller = new CommunitiesLoginController();
			controller.userName = 'vennila@gmail.com';
			controller.login();
		}
		System.assert(con.Id != Null, 'Id should not blank');
		// System.assertEquals(currUser.ProfileId,  label.Active_Volunteer_Profile);
	}
}