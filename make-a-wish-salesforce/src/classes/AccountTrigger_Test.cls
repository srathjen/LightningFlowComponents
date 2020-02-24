/*****************************************************************************************************************
Author      : MST Solutions
Date        : 6/1/2016
Description : 
*******************************************************************************************************************/
@IsTest
public class AccountTrigger_Test {

	@TestSetup static void createRecords() {
		insert OrientationandTrainingUtil.createrSystemAdminUser();
	}

	static testMethod void inKindDonor() {
		User sysAdmin = [
				SELECT Id, Username, Email
				FROM User
				WHERE Email = :'testmawa@gmail.com'
				LIMIT 1
		];
		Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccountWithWishCoordinatior(sysAdmin.Id);
		insert chapterAccount;

		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
		insert volunteerContact;

		System.runAs (new User(Id = UserInfo.getUserId())) {
			User volunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
			insert volunteerUser;
		}
		//System.RunAs(volunteerUser) {
		Id inKindDonorsAccountRTId = Constant_AC.IN_KIND_ACCOUNT_ID;
		Account inkindAccount = new Account();
		inkindAccount.Name = 'InKind Account';
		inkindAccount.RecordTypeId = inKindDonorsAccountRTId;
		inkindAccount.Chapter_Name__c = chapterAccount.Id;
		insert inkindAccount;
		inkindAccount.Wish_Co_ordinator__c = sysAdmin.Id;
		update inkindAccount;
		//}
	}

	static testmethod void inKindDonorUpdateChapterName() {
		User sysAdmin = [
				SELECT Id,userName,Email
				FROM User
				WHERE Email = :'testmawa@gmail.com'
				limit 1
		];
		Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccountWithWishCoordinatior(sysAdmin.Id);
		insert chapterAccount;

		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
		insert volunteerContact;

		System.runAs (new User(Id = UserInfo.getUserId())) {
			User volunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
			insert volunteerUser;
		}

		Account inkindAccount = OrientationandTrainingUtil.inKindAccountWithStatus();
		inkindAccount.Chapter_Name__c = chapterAccount.Id;
		inkindAccount.In_Kind_Approval_Status__c = 'Rejected';
		insert inkindAccount;
	}

	static testmethod void inKindDonorUpdateNullChapterName() {
		User sysAdmin = [
				SELECT Id,userName,Email
				FROM User
				WHERE Email = :'testmawa@gmail.com'
				limit 1
		];
		Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccountWithWishCoordinatior(sysAdmin.Id);
		insert chapterAccount;

		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
		insert volunteerContact;

		System.runAs (new User(Id = UserInfo.getUserId())) {
			User volunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
			insert volunteerUser;
		}

		Account inkindAccount = OrientationandTrainingUtil.inKindAccountWithSChpater(chapterAccount.id);
		//inkindAccount.Chapter_Name__c = null;
		inkindAccount.In_Kind_Approval_Status__c = 'Approved';
		insert inkindAccount;
	}

	//Account with wishCoordinator Not Null
	static testmethod void wishCoordinatorNotNull() {
		User sysAdmin = [
				SELECT Id,userName,Email
				FROM User
				WHERE Email = :'testmawa@gmail.com'
				limit 1
		];
		Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccountWithWishCoordinatior(sysAdmin.Id);
		insert chapterAccount;

		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
		insert volunteerContact;

		User volunteerUser = new User();
		System.runAs (new User(Id = UserInfo.getUserId())) {
			volunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
			insert volunteerUser;
		}

		System.RunAs(volunteerUser) {
			Account inkindAccount = OrientationandTrainingUtil.inKindAccount();

			try {
				insert inkindAccount;
			} catch (Exception e) {
				Boolean expectedExceptionThrown = (e.getMessage().contains('There is no approver for this account.')) ? true : false;
				System.AssertEquals(expectedExceptionThrown, false);
			}

		}
	}

	//Account and wishCoordinator as null
	static testmethod void accountWishCoordinatorAsNull() {
		User sysAdmin = [
				SELECT Id,userName,Email
				FROM User
				WHERE Email = :'testmawa@gmail.com'
				limit 1
		];
		Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccountWithWishCoordinatior(sysAdmin.Id);
		insert chapterAccount;
		chapterAccount.Wish_Co_ordinator__c = null;
		update chapterAccount;
		chapterAccount.Wish_Co_ordinator__c = userinfo.getUserId();
		update chapterAccount;
		chapterAccount.Wish_Co_ordinator__c = sysAdmin.id;
		update chapterAccount;

		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
		insert volunteerContact;

		User volunteerUser = new User();
		System.runAs (new User(Id = UserInfo.getUserId())) {
			volunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
			insert volunteerUser;
		}
		System.RunAs(volunteerUser) {
			Account inkindAccount = OrientationandTrainingUtil.inKindAccount();
			Database.SaveResult result = Database.insert(inkindAccount, false);
			// System.assertEquals('There is no approver for this account.',result.getErrors()[0].getMessage());

		}
	}

	//Account and wishCoordinator as null
	static testmethod void chapterName() {
		User sysAdmin = [
				SELECT Id,userName,Email
				FROM User
				WHERE Email = :'testmawa@gmail.com'
				limit 1
		];
		Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccountWithWishCoordinatior(sysAdmin.Id);
		insert chapterAccount;

		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
		insert volunteerContact;

		User volunteerUser = new User();
		System.runAs (new User(Id = UserInfo.getUserId())) {
			volunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
			insert volunteerUser;
		}
		System.RunAs(volunteerUser) {
			Account inkindAccount = OrientationandTrainingUtil.inKindAccount();
			try {
				insert inkindAccount;
			} catch (Exception e) {
				// Do nothing
			}
		}
	}

	static testmethod void AddFlagonHouseHoldAccount() {
		Bypass_Triggers__c turnOnHouseHold = new Bypass_Triggers__c();
		turnOnHouseHold.setupownerId = userinfo.getUserId();
		insert turnOnHousehold;
		Account chapterAccount = OrientationandTrainingUtil.HouseHoldAccount();
		insert chapterAccount;
	}

	static testmethod void updateChapterAccountDevEmail() {
		User sysAdmin = [
				SELECT Id,userName,Email
				FROM User
				WHERE Email = :'testmawa@gmail.com'
				limit 1
		];
		Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccountWithWishCoordinatior(sysAdmin.Id);
		insert chapterAccount;

		Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithStatus();
		parentCase.ChapterName__c = chapterAccount.id;
		parentCase.Closed_Date__c = system.today();
		insert parentCase;

		Contact wishChildCon = OrientationandTrainingUtil.CreateWishChildCon();
		insert wishChildCon;

		Case wishGranting = OrientationandTrainingUtil.createWishGrantCase(wishChildCon.id, parentCase.id);
		insert wishGranting;

		chapterAccount.DevStaffEmail__c = 'chandru.406@gmail.com';
		update chapterAccount;
	}

	static testmethod void upadteHouseHoldAccount() {
		Id emergencyContactRecordTypeId = Constant_AC.WISH_FORM_CHILD_EMERGENCY_ID;
		Account houseHoldAccouont = OrientationandTrainingUtil.HouseHoldAccount();
		insert houseHoldAccouont;

		Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithStatus();
		insert parentCase;

		Wish_Child_Form__c emergencyContact = new Wish_Child_Form__c();
		emergencyContact.Emergency_Relationship__c = 'Employee';
		emergencyContact.Emergency_First_Name__c = 'TestEmployee';
		emergencyContact.Emergency_Last_Name__c = 'TestLastEmployee';
		emergencyContact.Emergency_Mobilephone__c = '9600467559';
		emergencyContact.Race_Ethnicity__c = 'American Indian or Alaska Native';
		emergencyContact.Case_Team_Member1__c = 'Test Chandru';
		emergencyContact.Case_Team_Member2__c = 'Test Kesav';
		emergencyContact.Driver_Information__c = '{"type":"","state":"Alabama","licenseNum":"Test","expirationDate":"2019-10-02","driverName":"Father - Chandr Sek"}]';
		emergencyContact.Case__c = parentCase.id;
		emergencyContact.RecordTypeId = emergencyContactRecordTypeId;
		insert emergencyContact;
		houseHoldAccouont.Emergency_Contact_Phone__c = '9877665544';
		houseHoldAccouont.Hidden_Wish_Form_Id__c = emergencyContact.id;
		update houseHoldAccouont;
	}

	static testMethod void createInkindSysAdmin() {
		User sysAdmin = [
				SELECT Id, Username, Email
				FROM User
				WHERE Email = :'testmawa@gmail.com'
				LIMIT 1
		];
		Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccountWithWishCoordinatior(sysAdmin.Id);
		insert chapterAccount;

		Id inKindDonorsAccountRTId = Constant_AC.IN_KIND_ACCOUNT_ID;
		System.runAs(sysAdmin) {
			Account inkindAccount = new Account();
			inkindAccount.Name = 'InKind Account';
			inkindAccount.RecordTypeId = inKindDonorsAccountRTId;
			inkindAccount.Chapter_Name__c = chapterAccount.Id;
			insert inkindAccount;
		}
	}
}