/*--*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Chandrasekar Nallusamy
Date        : 7/12/2016
Description : This test class used for unit test and code coverage
*******************************************************************************************************************/

@isTest
public class BackgroundCheck_AC_Test {
	//This method is used to create test data for Account & volunteer contact.
	@testSetup static void setup() {
		Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
		insert chapterAccount;

		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
		insert volunteerContact;

		User currentVoulnteerUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currentVoulnteerUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(volunteerContact.Id);
			insert currentVoulnteerUser;
		}
		insert OrientationandTrainingUtil.createBackgroundCheck(currentVoulnteerUser.ContactId);

		insert OrientationandTrainingUtil.createDynamicContent();
	}

	public static testMethod void createVolunteerCommunityUserBackCheck() {
		User dbUser = [
				SELECT Id,UserRoleId,UserName,ProfileId,Email,FirstName,ContactId,LastName,isActive
				From User
				WHERE Email = :'jonathanEdwards@gmail.com'
				Limit 1
		];
		// system.RunAs(dbUser){
		Test.StartTest();
		// OrientationandTrainingUtil.createBackgroundCheck(dbUser.ContactId);
		Background_check__c backgroundCheck = OrientationandTrainingUtil.createBackgroundCheck(dbUser.ContactId);
		backgroundCheck.Resided_in_US_for_past_7_years__c = 'Yes';
        insert backgroundCheck;
		ApexPages.currentPage().getParameters().put('trainingRequired', 'true');
		ApexPages.currentPage().getParameters().put('bgRequired', 'true');
		insert OrientationandTrainingUtil.createDynamicContent();
		BGCRecordSharing(dbUser.id, backgroundCheck.id);
		update backgroundCheck;

		BackgroundCheck_AC backCheck = new BackgroundCheck_AC();
		backCheck.backGroundCheck = backgroundCheck;

		backCheck.statusValue = true;
		backCheck.whyNeedBGCheck = 'To Verify';
		backCheck.isBGFinished = true;
		backCheck.residingInPast7Years = 'Yes';
		backCheck.areYouinUS7Yrs = 'Yes';
		backgroundCheck.Date_Completed__c = Date.Today();
		backgroundCheck.Status__c = 'Approved';
		backCheck.saveRec();
		backCheck.getResidedValues();
		Test.StopTest();
		// }
	}

	private Static Background_check__Share BGCRecordSharing(id userId, id recordId) {
		Background_check__Share currSharing = new Background_check__Share();
		User currUser = [
				SELECT id
				from User
				WHERE Profile.Name = 'System Administrator' and isActive = True
				limit 1
		];
		System.RunAs(currUser) {
			currSharing.ParentId = recordId;
			currSharing.UserOrGroupId = userId;
			currSharing.AccessLevel = 'Edit';
			currSharing.RowCause = Schema.Background_check__Share.RowCause.Manual;
			insert currSharing;
		}
		return currSharing;
	}

	public static testMethod void backGroundCheckNo() {
		User dbUser = [
				SELECT Id,UserRoleId,UserName,ProfileId,Email,FirstName,ContactId,LastName,isActive
				From User
				WHERE Email = :'jonathanEdwards@gmail.com'
				Limit 1
		];
		// system.RunAs(dbUser){
		Test.StartTest();
		// OrientationandTrainingUtil.createBackgroundCheck(dbUser.ContactId);
		Background_check__c backgroundCheck = OrientationandTrainingUtil.createBackgroundCheck(dbUser.ContactId);
		backgroundCheck.Resided_in_US_for_past_7_years__c = null;
        insert backgroundCheck;
		ApexPages.currentPage().getParameters().put('trainingRequired', 'true');
		ApexPages.currentPage().getParameters().put('bgRequired', 'true');
		insert OrientationandTrainingUtil.createDynamicContent();
		BGCRecordSharing(dbUser.id, backgroundCheck.id);
		update backgroundCheck;

		BackgroundCheck_AC backCheck = new BackgroundCheck_AC();
		backCheck.backGroundCheck = backgroundCheck;

		backCheck.saveRec();
		backCheck.getResidedValues();
		Test.StopTest();
		// }
	}

	public static testMethod void createPrspectiveUserBackCheck() {
		/*test.startTest();
		Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        insert chapterAccount;

		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        insert volunteerContact;

		User prospectUser = new User();
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			prospectUser = OrientationandTrainingUtil.createVolunteerUser(volunteerContact.id);
            insert prospectUser;
		}
		system.runAs(prospectUser) {
			BackgroundCheck_AC backCheck = new BackgroundCheck_AC();
			Background_check__c newBackCheck = new Background_check__c();

			insert newBackCheck;
			backCheck.areYouinUS7Yrs = 'No';
			backCheck.saveRec();
			Test.stopTest();
		}*/
	}
}