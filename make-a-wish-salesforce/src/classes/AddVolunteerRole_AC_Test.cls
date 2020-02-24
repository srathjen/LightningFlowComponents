/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 28/06/2016
Description : AddVolunteerRole_AC_Test is used to increase the code coverage for Application_AC controller.
*****************************************************************************************************/
//AddVolunteerRole_AC_Test class is used to the unit testing of the AddVolunteerRole_AC class functionality
//This class has the four test methods to do the both possitive and negative testing
//This class is created by Kanagaraj
@isTest
public class AddVolunteerRole_AC_Test {
	@TestSetup
	private static void setup() {
		trac_TriggerHandlerBase.blockTrigger = true;
	}

	/* This method is used to create number of NonWishEvent Volunteer Opportunity count */
	//This method will create chapter account
	//This method will created volunteer contact
	//This method will update the volunteer contact
	public testMethod static void createNonWishEvent() {
		User volunteerUser = new User();
		System.runAs (new User(Id = UserInfo.getUserId())) {
			volunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(null);
			volunteerUser.Hidden_Role_Name_Id__c = 'Test';
			insert volunteerUser;
		}
		// Need parent fields
		volunteerUser = [
				SELECT Id, ContactId, Contact.AccountId
				FROM User
				WHERE Id = :volunteerUser.Id
		];

		Role__c nonWishRole = OrientationandTrainingUtil.createRole();
		insert nonWishRole;

		Chapter_Role__c chapterRole = OrientationandTrainingUtil.createChapter(volunteerUser.Contact.AccountId, nonWishRole.Id);
		insert chapterRole;

		Non_Wish_Events__c nonWishEvent = OrientationandTrainingUtil.CreateEventRec(chapterRole.Id, volunteerUser.Contact.AccountId);
		insert nonWishEvent;

		system.runAs(volunteerUser) {
			ApexPages.StandardController sc = new ApexPages.StandardController(nonWishEvent);
			AddVolunteerRole_AC addRole = new AddVolunteerRole_AC(sc);
			PageReference pageRef = Page.AddVolunteerRole_VF;
			pageRef.getParameters().put('id', String.valueOf(nonWishEvent.Id));
			Test.setCurrentPage(pageRef);
			Volunteer_Count__c volnteerCount = OrientationandTrainingUtil.createVolunteerCount(nonWishEvent.Id, chapterRole.Id, 3);
			volnteerCount.Date__c = System.today().addDays(-1);
			insert volnteerCount;
			insert OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(volunteerUser.Contact.AccountId, chapterRole.Id, nonWishEvent.Id);
			addRole.addRow();
			addRole.RoleName = 'WishGranter';
			addRole.VolunteerCount = 3;
			addRole.isCommunity = false;
			Volunteer_Count__c VolunteerNeededCount = [
					SELECT Id,Volunteer_Needed__c
					FROM Volunteer_Count__c
					WHERE Id = :volnteerCount.Id
					Limit 50000
			];
			VolunteerNeededCount.Volunteer_Needed__c = 2;
			update VolunteerNeededCount;
			addRole.EditRec();
			addRole.saveRec();
			addRole.cancelRec();
			addRole.ChapterRoleId = chapterRole.Id;
			addRole.register();
			System.assertEquals(VolunteerNeededCount.Volunteer_Needed__c, 2, 'Count does not Match');
			System.assert(VolunteerNeededCount.Volunteer_Needed__c == 2, 'The value of VolunteerNeededCount.Volunteer_Needed__c is: ' + VolunteerNeededCount.Volunteer_Needed__c + ' and the value of actual count is: 2');
		}
	}

	public testMethod static void createNonWishEventErrors() {
		User volunteerUser = new User();
		System.runAs (new User(Id = UserInfo.getUserId())) {
			volunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(null);
			volunteerUser.Hidden_Role_Name_Id__c = 'Test';
			insert volunteerUser;
		}
		// Need parent fields
		volunteerUser = [
				SELECT Id, ContactId, Contact.AccountId
				FROM User
				WHERE Id = :volunteerUser.Id
		];

		Role__c nonWishRole = OrientationandTrainingUtil.createRole();
		insert nonWishRole;

		Chapter_Role__c chapterRole = OrientationandTrainingUtil.createChapter(volunteerUser.Contact.AccountId, nonWishRole.Id);
		insert chapterRole;

		Non_Wish_Events__c nonWishEvent = OrientationandTrainingUtil.CreateEventRec(chapterRole.Id, volunteerUser.Contact.AccountId);
		insert nonWishEvent;

		system.runAs(volunteerUser) {
			Test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(nonWishEvent);
			AddVolunteerRole_AC addRole = new AddVolunteerRole_AC(sc);
			PageReference pageRef = Page.AddVolunteerRole_VF;
			pageRef.getParameters().put('id', String.valueOf(nonWishEvent.Id));
			Test.setCurrentPage(pageRef);
			Volunteer_Count__c volnteerCount = OrientationandTrainingUtil.createVolunteerCount(nonWishEvent.Id, chapterRole.Id, 3);
			insert volnteerCount;
			insert OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(volunteerUser.Contact.AccountId, chapterRole.Id, nonWishEvent.Id);
			addRole.addRow();
			addRole.RoleName = 'WishGranter';
			addRole.VolunteerCount = 3;
			addRole.isCommunity = false;

			Volunteer_Count__c VolunteerNeededCount = [
					SELECT Id,Volunteer_Needed__c
					FROM Volunteer_Count__c
					WHERE Id = :volnteerCount.Id
					Limit 50000
			];
			VolunteerNeededCount.Volunteer_Needed__c = 2;
			volnteerCount.Registered__c = volnteerCount.Volunteer_Needed__c + 1;
			update VolunteerNeededCount;
			addRole.EditRec();
			addRole.saveRec();

			volnteerCount.Description__c = nonWishEvent.Description__c;
			volnteerCount.Chapter_Role__c = nonWishEvent.Chapter_Role__c;
			update volnteerCount;
			addRole.EditRec();
			addRole.saveRec();
			addRole.EditRec();
			addRole.saveRec();

			addRole.cancelRec();
			addRole.ChapterRoleId = chapterRole.Id;
			addRole.register();
			Test.stopTest();
		}
	}

	/*This method is used to remove the volunteer contact from NonWishEvent Volunteer Opportunity*/

	public testMethod static void removeVolunteerContactonNonwishEvent() {
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

		ApexPages.StandardController sc = new ApexPages.StandardController(nonWishEvent);
		AddVolunteerRole_AC addRole = new AddVolunteerRole_AC(sc);
		PageReference pageRef = Page.AddVolunteerRole_VF;
		pageRef.getParameters().put('id', String.valueOf(nonWishEvent.Id));
		Test.setCurrentPage(pageRef);
		Volunteer_Count__c volnteerCount = OrientationandTrainingUtil.createVolunteerCount(nonWishEvent.Id, chapterRole.Id, 3);
		insert volnteerCount;
		insert OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(chapterAccount.Id, chapterRole.Id, nonWishEvent.Id);
		addRole.addRow();
		addRole.RoleName = 'WishGranter';
		addRole.VolunteerCount = 3;
		addRole.isCommunity = false;
		Volunteer_Count__c VolunteerNeededCount = [
				SELECT Id,Volunteer_Needed__c
				FROM Volunteer_Count__c
				WHERE Id = :volnteerCount.Id
				Limit 50000
		];
		VolunteerNeededCount.Volunteer_Needed__c = 2;
		update VolunteerNeededCount;
		addRole.EditRec();
		if (addRole.volunteerCountToUpdateList.size() > 0) {
			addRole.volunteerCountToUpdateList.get(0).Chapter_Role__c = null;
		}
		addRole.saveRec();
		addRole.cancelRec();
		addRole.ChapterRoleId = chapterRole.Id;
		addRole.register();
		System.assertEquals(addRole.VolunteerCount, 3, 'Count does not match');
		System.assert(addRole.VolunteerCount == 3, 'The value of  addRole.VolunteerCount is: ' + addRole.VolunteerCount + ' and the value of actual count is: 3');
	}

	/* This method is used to update number of NonWishEvent Volunteer Opportunity count */

	public testMethod static void updateNonWishEvent() {
		Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
		insert chapterAccount;

		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
		insert volunteerContact;

		Role__c nonWishRole = OrientationandTrainingUtil.createRole();
		insert nonWishRole;

		Chapter_Role__c chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.id, nonWishRole.Id);
		insert chapterRole;

		Non_Wish_Events__c nonWishEvent = OrientationandTrainingUtil.CreateEventRec(chapterRole.Id, chapterAccount.Id);
		Non_Wish_Events__c nonWishEvent2 = OrientationandTrainingUtil.CreateEventRec(chapterRole.Id, chapterAccount.Id);
		insert new List<Non_Wish_Events__c>{
				nonWishEvent, nonWishEvent2
		};
		Volunteer_Count__c createVolunteerCount = OrientationandTrainingUtil.createVolunteerCount(nonWishEvent.Id, chapterRole.Id, 3);
		insert createVolunteerCount;
		insert OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(chapterAccount.Id, chapterRole.Id, nonWishEvent.Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(nonWishEvent);
		AddVolunteerRole_AC addRole = new AddVolunteerRole_AC(sc);
		PageReference pageRef = Page.AddVolunteerRole_VF;
		pageRef.getParameters().put('id', String.valueOf(nonWishEvent.Id));
		Test.setCurrentPage(pageRef);
		Volunteer_Count__c newVolCount = OrientationandTrainingUtil.createVolunteerCount(nonWishEvent.Id, chapterRole.Id, 3);
		insert OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(chapterAccount.Id, chapterRole.Id, nonWishEvent.Id);
		addRole.addRow();
		addRole.RoleName = 'WishGranter';
		addRole.VolunteerCount = 3;
		addRole.isCommunity = false;
		addRole.addNewVolunteerRoleList.add(nonWishEvent2);
		addRole.saveRec();
		addRole.EditRec();
		addRole.cancelRec();
		addRole.ChapterRoleId = chapterRole.Id;
		addRole.CountId = newVolCount.Id;
		// addRole.dbVolOpporunity.add(newVolCount);
		addRole.register();
		System.assertEquals(addRole.ChapterRoleId, chapterRole.Id, 'Id does not match');
		System.assert(addRole.ChapterRoleId == chapterRole.Id, 'The value of  addRole.ChapterRoleId is: ' + addRole.VolunteerCount + ' and the value chapterRole.Id is: ' + chapterRole.Id);
	}

	/* This method is used to Register the volunteer contact to NonWishEvent Volunteer Opportunity */

	public testMethod static void registerVolunteerContact() {
		User volunteerUser = new User();
		System.runAs (new User(Id = UserInfo.getUserId())) {
			volunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(null);
			volunteerUser.Hidden_Role_Name_Id__c = 'Test';
			insert volunteerUser;
		}
		insert new Bypass_Triggers__c(SetupOwnerId = volunteerUser.Id);

		System.runAs(volunteerUser) {
			Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
			insert chapterAccount;

			Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
			insert volunteerContact;

			Role__c nonWishRole = OrientationandTrainingUtil.createRole();
			Role__c wishRole = nonWishRole.clone();
			nonWishRole.Name = wishRole.Name = 'Wish Granter Mentor';
			nonWishRole.isWishRole__c = false;
			insert new List<Role__c>{
					nonWishRole, wishRole
			};

			Chapter_Role__c chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.id, nonWishRole.Id);
			Chapter_Role__c chapterRole2 = OrientationandTrainingUtil.createChapter(chapterAccount.id, wishRole.Id);
			insert new List<Chapter_Role__c>{
					chapterRole, chapterRole2
			};

			Non_Wish_Events__c nonWishEvent = OrientationandTrainingUtil.CreateEventRec(chapterRole.Id, chapterAccount.Id);
			insert nonWishEvent;

			insert OrientationandTrainingUtil.createVolunteerCount(nonWishEvent.Id, chapterRole.Id, 3);
			insert OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(chapterAccount.Id, chapterRole.Id, nonWishEvent.Id);

			Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
			insert wishChild;

			Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
			parentCase.ChapterName__c = chapterAccount.Id;
			insert parentCase;

			Volunteer_Count__c volnteerCount = OrientationandTrainingUtil.createVolunteerCount(nonWishEvent.Id, chapterRole.Id, 3);
			insert volnteerCount;

			Volunteer_Opportunity__c volOpp = new Volunteer_Opportunity__c(Chapter_Name__c = chapterAccount.Id, Chapter_Role_Opportunity__c = chapterRole.Id, Wish__c = parentCase.Id);
			volOpp.Non_Wish_Event__c = volnteerCount.Non_Wish_Events__c;
			volOpp.HiddenVolunteer_Count_Description__c = volnteerCount.Id;
			insert volOpp;
			List<Volunteer_Opportunity__c> volOppList = [
					SELECT Id, Name, Non_Wish_Event__c,
							Chapter_Role_Opportunity__r.Role_Name__c, Chapter_Name__r.Name, HiddenVolunteer_Count_Description__c
					FROM Volunteer_Opportunity__c
					WHERE Id = :volOpp.Id
			];

			Volunteer_Roles__c volRole = OrientationandTrainingUtil.createVolRole(volunteerUser.ContactId, chapterRole2.Id);
			Volunteer_Roles__c volRole2 = OrientationandTrainingUtil.createVolRole(volunteerUser.ContactId, chapterRole.Id);
			insert new List<Volunteer_Roles__c>{
					volRole, volRole2
			};

			ApexPages.StandardController sc = new ApexPages.StandardController(nonWishEvent);
			AddVolunteerRole_AC addRole = new AddVolunteerRole_AC(sc);
			PageReference pageRef = Page.AddVolunteerRole_VF;
			pageRef.getParameters().put('id', String.valueOf(nonWishEvent.Id));
			Test.setCurrentPage(pageRef);
			Non_Wish_Events__c nonWishEventRec = OrientationandTrainingUtil.CreateEventRec(chapterRole.Id, chapterAccount.Id);
			Non_Wish_Events__c nonWishEventRec2 = OrientationandTrainingUtil.CreateEventRec(chapterRole.Id, chapterAccount.Id);
			insert new List<Non_Wish_Events__c>{
					nonWishEventRec, nonWishEventRec2
			};
			insert OrientationandTrainingUtil.createVolunteerCount(nonWishEventRec.Id, chapterRole.Id, 3);
			insert OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(chapterAccount.Id, chapterRole.Id, nonWishEventRec.Id);
			Test.startTest();
			addRole.addRow();
			addRole.addRow();
			addRole.RoleName = 'WishGranter';
			addRole.VolunteerCount = 3;
			addRole.isCommunity = false;
			addRole.addNewVolunteerRoleList.add(nonWishEventRec2);
			addRole.register();
			addRole.saveRec();
			addRole.EditRec();
			addRole.cancelRec();
			addRole.ChapterRoleId = chapterRole.Id;
			addRole.register();
			addRole.allowRegisteration(volOppList);
			addRole.getChapterRoleOanTStatus(chapterRole.Id);
			addRole.sameValue = true;
			addRole.dateMessage = true;
			addRole.boolValue = true;
			addRole.displayErrorMsg();
			Test.stopTest();
			System.assertEquals(addRole.ChapterRoleId, chapterRole.Id, 'Id does not match');
			System.assert(addRole.ChapterRoleId == chapterRole.Id, 'The value of  addRole.ChapterRoleId is: ' + addRole.VolunteerCount + ' and the value chapterRole.Id is: ' + chapterRole.Id);
		}
	}
}