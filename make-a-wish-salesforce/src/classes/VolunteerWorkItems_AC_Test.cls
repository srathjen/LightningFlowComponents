@IsTest
public class VolunteerWorkItems_AC_Test {

	@TestSetup
	static void setup() {
		trac_TriggerHandlerBase.blockTrigger = true;
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		acc.Name = 'Primary Account';
		insert acc;

		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.Id);
		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		insert new List<Contact>{
				con, wishChild
		};

		insert OrientationandTrainingUtil.createAffiliation(con.Id);

		User currUser;
		System.runAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createActiveVolunteerUser(con.Id);
			insert currUser;
		}

		Role__c currRole = OrientationandTrainingUtil.createRole();
		Role__c currNonWishRole = OrientationandTrainingUtil.createNonWishRole();
		insert new List<Role__c>{
				currRole, currNonWishRole
		};

		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.Id, currRole.Id);
		Chapter_Role__c currNonWishChapRole = OrientationandTrainingUtil.createChapter(acc.Id, currNonWishRole.Id);
		insert new List<Chapter_Role__c>{
				currChapRole, currNonWishChapRole
		};

		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(currUser.ContactId, currChapRole.Id);
		insert currVolRole;

		Case newParentWish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		newParentWish.Sub_Status__c = 'Abandoned';
		insert newParentWish;

		Non_Wish_Events__c nonWishEvent = OrientationandTrainingUtil.CreateEvent(acc.Id);
		insert nonWishEvent;

		Volunteer_Opportunity__c wishVolunteerOpportunity = OrientationandTrainingUtil.CreateNewWishVolunteerOpportunity(acc.Id, currChapRole.Id, newParentWish.Id);
		Volunteer_Opportunity__c wishVolunteerOpportunity1 = OrientationandTrainingUtil.CreateNewWishVolunteerOpportunity(acc.Id, currChapRole.Id, newParentWish.Id);
		Volunteer_Opportunity__c duplicateWishVolunteerOpportunity = OrientationandTrainingUtil.createDuplicateNewWishVolunteerOpportunity(acc.Id, currChapRole.Id, newParentWish.Id);
		Volunteer_Opportunity__c nonWishVolunteerOpportunity = OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(acc.Id, currChapRole.Id, nonWishEvent.Id);
		Volunteer_Opportunity__c nonWishVolunteerOpportunity1 = OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(acc.Id, currChapRole.Id, nonWishEvent.Id);
		Volunteer_Opportunity__c duplicateNonWishVolunteerOpportunity = OrientationandTrainingUtil.CreateNonWishDuplicateVolunteerOpportunity(acc.Id, currChapRole.Id, nonWishEvent.Id);
		Volunteer_Opportunity__c nonWishEventVolunteerOpportunity = OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(acc.Id, currChapRole.Id, nonWishEvent.Id);
		Volunteer_Opportunity__c nonWishEventVolunteerOpportunity1 = OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(acc.Id, currChapRole.Id, nonWishEvent.Id);
		Volunteer_Opportunity__c wishEventVolunteerOpportunity = OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(acc.Id, currChapRole.Id, nonWishEvent.Id);
		Volunteer_Opportunity__c wishEventVolunteerOpportunity1 = OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(acc.Id, currChapRole.Id, nonWishEvent.Id);
		wishVolunteerOpportunity.RecordTypeId = duplicateWishVolunteerOpportunity.RecordTypeId = wishVolunteerOpportunity1.RecordTypeId = Constant_AC.REGISTERED_WISH_ID;
		wishVolunteerOpportunity.Volunteer_Name__c = duplicateWishVolunteerOpportunity.Volunteer_Name__c = wishVolunteerOpportunity1.Volunteer_Name__c = currUser.ContactId;

		wishVolunteerOpportunity.Inactive__c = true;
		wishVolunteerOpportunity.Inactivated_or_Rejected_Date__c = System.now().date();
		wishVolunteerOpportunity.Reason_Inactive__c = 'Test';

		duplicateWishVolunteerOpportunity.Status__c = 'Pending';
		duplicateWishVolunteerOpportunity.Inactivated_or_Rejected_Date__c = System.now().date();

		wishVolunteerOpportunity1.Status__c = 'Approved';

		nonWishVolunteerOpportunity.RecordTypeId = duplicateNonWishVolunteerOpportunity.RecordTypeId = nonWishVolunteerOpportunity1.RecordTypeId = Constant_AC.REGISTERED_NON_WISH_ID;
		nonWishVolunteerOpportunity.Volunteer_Name__c = duplicateNonWishVolunteerOpportunity.Volunteer_Name__c = nonWishVolunteerOpportunity1.Volunteer_Name__c = currUser.ContactId;

		nonWishVolunteerOpportunity.Inactive__c = true;
		nonWishVolunteerOpportunity.Inactivated_or_Rejected_Date__c = System.now().date();
		nonWishVolunteerOpportunity.Reason_Inactive__c = 'Test';

		duplicateNonWishVolunteerOpportunity.Status__c = 'Pending';
		duplicateNonWishVolunteerOpportunity.Inactivated_or_Rejected_Date__c = System.now().date();

		nonWishVolunteerOpportunity1.Status__c = 'Approved';

		nonWishEventVolunteerOpportunity.RecordTypeId = nonWishEventVolunteerOpportunity1.RecordTypeId = Constant_AC.NON_WISH_EVENT_RT_ID;
		nonWishEventVolunteerOpportunity.Wish__c = nonWishEventVolunteerOpportunity1.Wish__c = newParentWish.Id;

		wishEventVolunteerOpportunity.RecordTypeId = wishEventVolunteerOpportunity1.RecordTypeId = Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID;
		wishEventVolunteerOpportunity.Wish__c = wishEventVolunteerOpportunity1.Wish__c = newParentWish.Id;
		insert new List<Volunteer_Opportunity__c>{
				wishVolunteerOpportunity, duplicateWishVolunteerOpportunity, nonWishVolunteerOpportunity,
				wishVolunteerOpportunity1, duplicateNonWishVolunteerOpportunity, nonWishVolunteerOpportunity1,
				nonWishEventVolunteerOpportunity, nonWishEventVolunteerOpportunity1,
				wishEventVolunteerOpportunity, wishEventVolunteerOpportunity1
		};
		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void volunteerWishEvents() {
		Test.startTest();
		Account chapterAcc = [
				SELECT Id
				FROM Account
				WHERE Name = 'Primary Account'
		];
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;

		Role__c currRole = OrientationandTrainingUtil.createRole();
		Role__c currNonWishRole = OrientationandTrainingUtil.createNonWishRole();
		currRole.isWishRole__c = currNonWishRole.isWishRole__c = false;
		insert new List<Role__c>{
				currRole, currNonWishRole
		};

		Chapter_Role__c currNonWishChapRole = OrientationandTrainingUtil.createChapter(acc.Id, currNonWishRole.Id);
		insert currNonWishChapRole;

		User currUser = [
				SELECT Id,Username, ContactId
				FROM User
				WHERE Username = :'joathanedwards@gmail.com'
		];
		Case dbCase = [
				SELECT Id,Status,Wish_Type__c
				FROM Case
				WHERE Wish_Type__c = :'Disney World'
		];

		Volunteer_Opportunity__c dbOpp = [
				SELECT Id,Wish__c,Non_Wish_Event__c,Hidden_VolunteerCount_Desc__c,Chapter_Role_Opportunity__c
				FROM Volunteer_Opportunity__c
				WHERE Wish__c = :dbCase.Id
				LIMIT 1
		];
		List<Volunteer_Opportunity__c> voloppList = new List<Volunteer_Opportunity__c>([
				SELECT Id,Wish__c,Non_Wish_Event__c,Hidden_VolunteerCount_Desc__c,Role__c,
						Chapter_Role_Opportunity__r.Role_Name__c,Chapter_Name__r.Name, Reason_Inactive__c,
						Status__c
				FROM Volunteer_Opportunity__c
				WHERE Role__c = 'Wish Granter'
		]);
		voloppList[0].Status__c = 'Pending';
		voloppList[0].Inactive__c = false;
		voloppList[0].Reason_Inactive__c = null;
		update voloppList;
		Volunteer_Roles__c volRole = [
				SELECT Id, Status__c, Volunteer_Name__c
				FROM Volunteer_Roles__c
				LIMIT 1
		];
		volRole.Status__c = 'Pending';
		volRole.Sub_status__c = 'Missing Requirement';
		volRole.Volunteer_Name__c = currUser.ContactId;
		update volRole;
		System.runAs(currUser) {

			PageReference pageref = Page.MyAssignment_VF;
			Test.setCurrentPageReference(pageref);
			VolunteerWorkItems_AC volunteerWorkitem = new VolunteerWorkItems_AC(new ApexPages.StandardController(dbOpp));
			VolunteerWorkItems_AC volunteerWorkitems = new VolunteerWorkItems_AC();
			volunteerWorkitems.volunteerOpportunityRecordId = dbOpp.Id;
			volunteerWorkitems.volunteerChaptersSet = new Set<Id>();
			volunteerWorkitems.volunteerChaptersSet.add(chapterAcc.Id);
			volunteerWorkitems.CurrentWish();
			volunteerWorkitems.HistoricalWish();
			volunteerWorkitems.getVolunteerAssignedWishEvents();
			volunteerWorkitems.getVolunteerAssignedNonWishEvents();
			volunteerWorkitems.getWishEvents();
			volunteerWorkitems.getNonWishEvents();
			volunteerWorkitems.volunteerOpportunityRecordId = voloppList[0].Id;
			volunteerWorkitems.RegisterWishEvents();
			volunteerWorkitems.registrationConfirmation();
			volunteerWorkitems.getChapterRoleOanTStatus(currNonWishChapRole.Id);
			volunteerWorkitems.allowRegisteration(voloppList);
			volunteerWorkitems.RedirecttoVolOpportunity();
			Test.stopTest();
		}
	}

	@IsTest
	public static void volunteerClosedWish() {
		Test.startTest();
		User currUser = [
				SELECT Id,Username
				FROM User
				WHERE Username = :'joathanedwards@gmail.com'
		];

		Case dbCase = [
				SELECT Id,Status,Wish_Type__c
				FROM Case
				WHERE Wish_Type__c = :'Disney World'
		];
		dbCase.Status = 'Closed';

		System.runAs(currUser) {
			PageReference pageref = Page.MyAssignment_VF;
			Test.setCurrentPageReference(pageref);
			VolunteerWorkItems_AC volunteerWorkitems = new VolunteerWorkItems_AC();
			volunteerWorkitems.CurrentWish();
			volunteerWorkitems.HistoricalWish();
			volunteerWorkitems.getClosedWish();
			volunteerWorkitems.RegisterWishEvents();
		}
		Test.stopTest();
	}

	@IsTest
	public static void volunteerClosedNonWish() {
		Test.startTest();
		User currUser = [
				SELECT Id,Username
				FROM User
				WHERE Username = :'joathanedwards@gmail.com'
		];
		Non_Wish_Events__c closedNonWish = [
				SELECT Id,Event_Text__c
				FROM Non_Wish_Events__c
				WHERE Event_Text__c = 'Sending Wish Child'
		];
		closedNonWish.Event_Date__c = System.today() - 3;
		update closedNonWish;
		System.runAs(currUser) {
			PageReference pageref = Page.MyAssignment_VF;
			Test.setCurrentPageReference(pageref);
			VolunteerWorkItems_AC volunteerWorkitems = new VolunteerWorkItems_AC();
			volunteerWorkitems.CurrentWish();
			volunteerWorkitems.HistoricalWish();
			volunteerWorkitems.getClosedNonWishEvents();
			volunteerWorkitems.RegisterWishEvents();
		}
		Test.stopTest();
	}

	@IsTest
	public static void volunteerRegisteredNonWish() {
		Test.startTest();
		User currUser = [
				SELECT Id,Username
				FROM User
				WHERE Username = :'joathanedwards@gmail.com'
		];
		Non_Wish_Events__c dbNonWish = [
				SELECT Id,Event_Text__c
				FROM Non_Wish_Events__c
				WHERE Event_Text__c = 'Sending Wish Child'
		];
		Volunteer_Opportunity__c dbOpp = [
				SELECT Id,Chapter_Name__r.Name,Non_Wish_Event__c,Chapter_Role_Opportunity__r.Role_Name__c
				FROM Volunteer_Opportunity__c
				WHERE Non_Wish_Event__c = :dbNonWish.Id
				LIMIT 1
		];
		System.runAs(currUser) {
			PageReference pageref = Page.MyAssignment_VF;
			Test.setCurrentPageReference(pageref);
			VolunteerWorkItems_AC volunteerWorkitems = new VolunteerWorkItems_AC();
			volunteerWorkitems.volunteerOpportunityRecordId = dbOpp.Id;
			volunteerWorkitems.RegisterWishEvents();
		}
		Test.stopTest();
	}
}