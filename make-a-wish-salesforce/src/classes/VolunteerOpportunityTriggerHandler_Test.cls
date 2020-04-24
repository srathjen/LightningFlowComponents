@IsTest
public class VolunteerOpportunityTriggerHandler_Test {

	@TestSetup
	static void setup() {
		User thisUser = [
				SELECT Id
				FROM User
				WHERE Id = :UserInfo.getUserId()
		];
		System.runAs(thisUser) {
			List<User> users = new List<User>();

			users.add(new User(
					ProfileId = [
							SELECT Id
							FROM Profile
							WHERE Name = 'System Administrator'
							LIMIT 1
					].Id,
					LastName = 'Wish Approver',
					Email = 'wishapprover@foo.com.test',
					Username = 'wishapprover@foo.com.test',
					CompanyName = 'Make-a-Wish Arizona',
					Title = 'Wish Approver',
					Alias = 'wish',
					TimeZoneSidKey = 'America/Los_Angeles',
					EmailEncodingKey = 'UTF-8',
					LanguageLocaleKey = 'en_US',
					LocaleSidKey = 'en_US'
			));
			users.add(new User(
					ProfileId = [
							SELECT Id
							FROM Profile
							WHERE Name = 'System Administrator'
							LIMIT 1
					].Id,
					LastName = 'Nonwish Approver',
					Email = 'nonwishapprover@foo.com.test',
					Username = 'nonwishapprover@foo.com.test',
					CompanyName = 'Make-a-Wish Arizona',
					Title = 'Nonwish Approver',
					Alias = 'nonwish',
					TimeZoneSidKey = 'America/Los_Angeles',
					EmailEncodingKey = 'UTF-8',
					LanguageLocaleKey = 'en_US',
					LocaleSidKey = 'en_US'
			));
			insert users;
			Account account = new Account();
			account.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
			account.Name = 'Make-a-Wish TEST TEST TEST';
			account.AccountNumber = 'abc12345678';
			account.OwnerId = users[0].Id;
			account.Wish_Volunteer_Assignment_Approver__c = users[0].Id;
			account.Event_Volunteer_Assignment_Approver__c = users[1].Id;
			insert account;
		}
	}

	@IsTest
	public static void updateNeededOpportunityCount() {
		Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
		insert chapterAccount;
		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
		insert volunteerContact;
		Role__c nonWishRole = OrientationandTrainingUtil.createRole();
		insert nonWishRole;
		Chapter_Role__c chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.Id, nonWishRole.Id);
		insert chapterRole;
		Non_Wish_Events__c nonWishEvent = OrientationandTrainingUtil.CreateEventRec(chapterRole.Id, chapterAccount.Id);
		insert nonWishEvent;
		Volunteer_Count__c volunteerCount2 = OrientationandTrainingUtil.createVolunteerCount(nonWishEvent.Id, chapterRole.Id, 3);
		insert volunteerCount2;
		Volunteer_Opportunity__c volOpportunity = OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(
				chapterAccount.Id, chapterRole.Id, nonWishEvent.Id);
		insert volOpportunity;
		Volunteer_Opportunity__c nonWishvolOpportunity = OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(
				chapterAccount.Id, chapterRole.Id, nonWishEvent.Id);
		insert nonWishvolOpportunity;
		User volunteerUser;
		Set<Id> userIdSet = new Set<Id>();
		Set<Id> volIdSet = new Set<Id>();
		Volunteer_Count__c volunteerCount = OrientationandTrainingUtil.createVolunteerCount(nonWishEvent.Id, chapterRole.Id, 2);
		insert volunteerCount;
		Volunteer_Opportunity__c volOpp = [
				SELECT Id,Volunteer_Name__c,Non_Wish_Event__c,Chapter_Role_Opportunity__c,
						Chapter_Role_Opportunity__r.Role_Name__c
				FROM Volunteer_Opportunity__c
				WHERE Id = :volOpportunity.Id
				LIMIT 1
		];
		System.runAs(new User(Id = UserInfo.getUserId())) {
			volunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
			insert volunteerUser;
			volunteerUser.Hidden_Role_Name_Id__c = volOpp.Chapter_Role_Opportunity__r.Role_Name__c
					+ String.valueOf(volOpp.Non_Wish_Event__c);
			update volunteerUser;
		}
		volOpportunity.Volunteer_Name__c = volunteerContact.Id;
		volOpportunity.Status__c = 'Approved';
		Test.startTest();
		update volOpportunity;
		Volunteer_Opportunity__c deleteOpportunity = new Volunteer_Opportunity__c ();
		deleteOpportunity.Id = volOpportunity.Id;
		// deleteOpportunity.Volunteer_Name__c  = Null;
		deleteOpportunity.Status__c = 'Approved';
		deleteOpportunity.Hidden_VolunteerCount_Desc__c = 'test';
		// deleteOpportunity.Volunteer_Needed__c = 2;
		update deleteOpportunity;

		System.runAs(new User(Id = UserInfo.getUserId())) {
			volunteerUser.Hidden_Role_Name_Id__c = volOpp.Chapter_Role_Opportunity__r.Role_Name__c + String.valueOf(volOpp.Non_Wish_Event__c);
		}
		delete deleteOpportunity;
		userIdSet.add(deleteOpportunity.Id);
		volIdSet.add(volunteerContact.Id);
		Test.stopTest();
	}

	@IsTest
	public static void testApprovalProcessWishRT() {
		Account chapter = [
				SELECT Id
				FROM Account
				WHERE Name = 'Make-a-Wish TEST TEST TEST'
		];
		Set<Id> chapterIds = new Set<Id>{
				chapter.Id
		};
		Volunteer_Opportunity__c vopp = new Volunteer_Opportunity__c(
				RecordTypeId = Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID,
				Chapter_Name__c = chapter.Id
		);
		insert vopp;

		Test.startTest();
		VolOpportunity_OnAfter_Update_Helper.submitforApprovalProcess(new List<Volunteer_Opportunity__c>{
				vopp
		}, chapterIds);
		Test.stopTest();

		ProcessInstanceWorkitem workitem = [
				SELECT Id, ActorId
				FROM ProcessInstanceWorkitem
		];
		User user = [
				SELECT Id
				FROM User
				WHERE Username = 'wishapprover@foo.com.test'
		];
		System.assertEquals(user.Id, workitem.ActorId, 'System assigned user from the wrong lookup.');
	}

	@IsTest
	static void testApprovalProcessVolunteerRegisteredWishRT() {
		Account chapter = [
				SELECT Id
				FROM Account
				WHERE Name = 'Make-a-Wish TEST TEST TEST'
		];
		Set<Id> chapterIds = new Set<Id>{
				chapter.Id
		};
		Volunteer_Opportunity__c vopp = new Volunteer_Opportunity__c(
				RecordTypeId = Constant_AC.REGISTERED_WISH_ID,
				Chapter_Name__c = chapter.Id
		);
		insert vopp;

		Test.startTest();
		VolOpportunity_OnAfter_Update_Helper.submitforApprovalProcess(new List<Volunteer_Opportunity__c>{
				vopp
		}, chapterIds);
		Test.stopTest();

		ProcessInstanceWorkitem workitem = [
				SELECT Id, ActorId
				FROM ProcessInstanceWorkitem
		];
		User user = [
				SELECT Id
				FROM User
				WHERE Username = 'wishapprover@foo.com.test'
		];
		System.assertEquals(user.Id, workitem.ActorId, 'System assigned user from the wrong lookup.');
	}

	@IsTest
	public static void testApprovalProcessNonWishEventRT() {
		Account chapter = [
				SELECT Id
				FROM Account
				WHERE Name = 'Make-a-Wish TEST TEST TEST'
		];
		Set<Id> chapterIds = new Set<Id>{
				chapter.Id
		};
		Volunteer_Opportunity__c vopp = new Volunteer_Opportunity__c(
				RecordTypeId = Constant_AC.NON_WISH_EVENT_RT_ID,
				Chapter_Name__c = chapter.Id
		);
		insert vopp;

		Test.startTest();
		VolOpportunity_OnAfter_Update_Helper.submitforApprovalProcess(new List<Volunteer_Opportunity__c>{
				vopp
		}, chapterIds);
		Test.stopTest();

		ProcessInstanceWorkitem workitem = [
				SELECT Id, ActorId
				FROM ProcessInstanceWorkitem
		];
		User user = [
				SELECT Id
				FROM User
				WHERE Username = 'nonwishapprover@foo.com.test'
		];
		System.assertEquals(user.Id, workitem.ActorId, 'System assigned user from the wrong lookup.');
	}

	@IsTest
	public static void testApprovalProcessVolunteerRegisteredNonWishRT() {
		Account chapter = [
				SELECT Id
				FROM Account
				WHERE Name = 'Make-a-Wish TEST TEST TEST'
		];
		Set<Id> chapterIds = new Set<Id>{
				chapter.Id
		};
		Volunteer_Opportunity__c vopp = new Volunteer_Opportunity__c(
				RecordTypeId = Constant_AC.REGISTERED_NON_WISH_ID,
				Chapter_Name__c = chapter.Id
		);
		insert vopp;

		Test.startTest();
		VolOpportunity_OnAfter_Update_Helper.submitforApprovalProcess(new List<Volunteer_Opportunity__c>{
				vopp
		}, chapterIds);
		Test.stopTest();

		ProcessInstanceWorkitem workitem = [
				SELECT Id, ActorId
				FROM ProcessInstanceWorkitem
		];
		User user = [
				SELECT Id
				FROM User
				WHERE Username = 'nonwishapprover@foo.com.test'
		];
		System.assertEquals(user.Id, workitem.ActorId, 'System assigned user from the wrong lookup.');
	}

	@IsTest
	public static void deleteOpportunityCount() {
		Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
		insert chapterAccount;
		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
		insert volunteerContact;
		Role__c nonWishRole = OrientationandTrainingUtil.createRole();
		insert nonWishRole;
		Chapter_Role__c chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.id, nonWishRole.Id);
		insert chapterRole;
		Non_Wish_Events__c nonWishEvent = OrientationandTrainingUtil.CreateEventRec(chapterRole.Id, chapterAccount.Id);
		insert nonWishEvent;
		Volunteer_Count__c volunteerCount2 = OrientationandTrainingUtil.createVolunteerCount(nonWishEvent.Id, chapterRole.Id, 3);
		insert volunteerCount2;
		Volunteer_Opportunity__c volOpportunity = OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(
				chapterAccount.Id, chapterRole.Id, nonWishEvent.Id);
		volOpportunity.Volunteer_Name__c = volunteerContact.Id;
		insert volOpportunity;
		Volunteer_Opportunity__c nonWishvolOpportunity = OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(
				chapterAccount.Id, chapterRole.Id, nonWishEvent.Id);
		nonWishvolOpportunity.Volunteer_Name__c = volunteerContact.Id;
		insert nonWishvolOpportunity;
		User volunteerUser;
		Set<Id> userIdSet = new Set<Id>();
		Set<Id> volIdSet = new Set<Id>();
		Volunteer_Count__c volunteerCount = OrientationandTrainingUtil.createVolunteerCount(nonWishEvent.Id, chapterRole.Id, 2);
		insert volunteerCount;

		Volunteer_Opportunity__c volOpp = [
				SELECT Id,Volunteer_Name__c,Non_Wish_Event__c,Chapter_Role_Opportunity__c,
						Chapter_Role_Opportunity__r.Role_Name__c
				FROM Volunteer_Opportunity__c
				WHERE Id = :volOpportunity.Id
				LIMIT 1
		];
		System.runAs(new User(Id = UserInfo.getUserId())) {
			volunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
			insert volunteerUser;
			volunteerUser.Hidden_Role_Name_Id__c = volOpp.Chapter_Role_Opportunity__r.Role_Name__c
					+ String.valueOf(volOpp.Non_Wish_Event__c);
			update volunteerUser;
		}
		volOpportunity.Status__c = 'Approved';
		Test.startTest();
		update volOpportunity;
		Volunteer_Opportunity__c deleteOpportunity = new Volunteer_Opportunity__c ();
		deleteOpportunity.Id = volOpportunity.Id;
		deleteOpportunity.Status__c = 'Approved';
		deleteOpportunity.Hidden_VolunteerCount_Desc__c = 'test';
		update deleteOpportunity;

		System.runAs(new User(Id = UserInfo.getUserId())) {
			volunteerUser.Hidden_Role_Name_Id__c = volOpp.Chapter_Role_Opportunity__r.Role_Name__c + String.valueOf(volOpp.Non_Wish_Event__c);
		}
		delete deleteOpportunity;
		userIdSet.add(deleteOpportunity.Id);
		volIdSet.add(volunteerContact.Id);
		Test.stopTest();
	}
}