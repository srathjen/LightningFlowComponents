@IsTest
public class VolunteerWorkItems_AC_Test {

	@TestSetup
	static void setup() {
		trac_TriggerHandlerBase.blockTrigger = true;

		List<Account> accountList = TestDataFactory.createAccount(1);
		Account accountAzChapter = accountList.get(0);
		accountAzChapter.Name = 'Make-A-Wish Arizona';
		accountAzChapter.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
		insert accountList;

		User volunteerUser = TestDataFactory.createVolunteerUser(1, 'Active Volunteer (Login)', 'Manager').get(0);
		volunteerUser.LastName = 'Smith0';
		volunteerUser.Email = 'js@email.com';
		System.runAs(TestDataFactory.adminUser) {
			insert volunteerUser;
		}

		List<Contact> contactList = TestDataFactory.createContact(1);
		Contact wishChildMadison = contactList.get(0);
		wishChildMadison.FirstName = 'Madison';
		wishChildMadison.LastName = 'Jacobs';
		wishChildMadison.RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
		wishChildMadison.Birthdate = Date.today().addYears(-10);
		wishChildMadison.MailingPostalCode = '94105-5188';
		wishChildMadison.MailingStreet = '7540 E Gold Dust Ave';
		wishChildMadison.MailingCountry = 'United States';
		wishChildMadison.MailingState = 'Arizona';
		wishChildMadison.MailingCity = 'Scottsdale';
		wishChildMadison.MailingLatitude = -24.355798;
		wishChildMadison.MailingLongitude = 69.830469;
		insert contactList;

		List<npe5__Affiliation__c> affiliationList = TestDataFactory.createAffiliation(1);
		npe5__Affiliation__c volunteerAffiliation = affiliationList.get(0);
		volunteerAffiliation.npe5__Contact__c = volunteerUser.ContactId;
		volunteerAffiliation.npe5__Organization__c = accountAzChapter.Id;
		volunteerAffiliation.npe5__Primary__c = true;
		volunteerAffiliation.npe5__Status__c = 'Pending';
		insert affiliationList;

		List<Role__c> roleList = TestDataFactory.createRole(2, true);
		Role__c wishRole = roleList.get(0);
		wishRole.Name = 'Wish Granter';
		Role__c nonWishRole = roleList.get(1);
		nonWishRole.Name = 'Assistant';
		nonWishRole.isWishRole__c = false;
		insert roleList;

		List<Chapter_Role__c> chapterRoleList = TestDataFactory.createChapterRole(2);
		Chapter_Role__c wishGranterChapterRole = chapterRoleList.get(0);
		wishGranterChapterRole.Chapter_Name__c = accountAzChapter.Id;
		wishGranterChapterRole.Role_Name__c = wishRole.Id;
		wishGranterChapterRole.Background_Check_Required__c = true;

		Chapter_Role__c nonWishChapterRole = chapterRoleList.get(1);
		nonWishChapterRole.Chapter_Name__c = accountAzChapter.Id;
		nonWishChapterRole.Role_Name__c = nonWishRole.Id;
		nonWishChapterRole.Background_Check_Required__c = false;
		insert chapterRoleList;

		List<Volunteer_Roles__c> volunteerRolesList = TestDataFactory.createVolunteerRole(2);
		Volunteer_Roles__c volunteerWishRole = volunteerRolesList.get(0);
		volunteerWishRole.Volunteer_Name__c = volunteerUser.ContactId;
		volunteerWishRole.Chapter_Role__c = wishGranterChapterRole.Id;
		volunteerWishRole.Status__c = 'Pending';
		volunteerWishRole.Sub_status__c = 'Missing Requirement';

		Volunteer_Roles__c volunteerNonwishRole = volunteerRolesList.get(1);
		volunteerNonwishRole.Volunteer_Name__c = volunteerUser.ContactId;
		volunteerNonwishRole.Chapter_Role__c = nonWishChapterRole.Id;
		volunteerNonwishRole.Status__c = 'Pending';
		volunteerNonwishRole.Sub_status__c = 'Missing Requirement';
		insert volunteerRolesList;

		List<Case> caseList = TestDataFactory.createCase(1);
		Case wishCaseJacobs = caseList.get(0);
		wishCaseJacobs.RecordTypeId = Constant_AC.WISH_RT_ID;
		wishCaseJacobs.ChapterName__c = accountAzChapter.Id;
		wishCaseJacobs.Subject = 'Madison Jacobs Wish';
		wishCaseJacobs.Interview_date__c = System.today();
		wishCaseJacobs.Wish_Type__c = 'Disney World';
		wishCaseJacobs.Start_Date__c = System.today();
		wishCaseJacobs.Status = 'New';
		wishCaseJacobs.Sub_Status__c = 'Abandoned';
		wishCaseJacobs.ContactId = wishChildMadison.Id;
		insert caseList;

		List<Non_Wish_Events__c> nonWishEvents = TestDataFactory.createNonwishEvent(1);
		Non_Wish_Events__c nonWishTeamMeet = nonWishEvents.get(0);
		nonWishTeamMeet.Event_Name__c = 'Monthly Team Meeting';
		nonWishTeamMeet.Event_Text__c = 'Monthly touchpoint for the Arizona volunteer team.';
		nonWishTeamMeet.Chapter__c = accountAzChapter.Id;
		nonWishTeamMeet.Event_Date__c = Date.today().addDays(2);
		insert nonWishEvents;

		List<Volunteer_Opportunity__c> volOppsList = TestDataFactory.createVolunteerOpportunity(12);
		Volunteer_Opportunity__c volOppNonwish1 = volOppsList.get(0);
		volOppNonwish1.Volunteer_Name__c = volunteerUser.ContactId;
		volOppNonwish1.Non_Wish_Event__c = nonWishTeamMeet.Id;
		volOppNonwish1.Chapter_Role_Opportunity__c = wishGranterChapterRole.Id;
		volOppNonwish1.RecordTypeId = Constant_AC.REGISTERED_NON_WISH_ID;
		volOppNonwish1.Inactive__c = true;
		volOppNonwish1.Inactivated_or_Rejected_Date__c = System.now().date();
		volOppNonwish1.Reason_Inactive__c = 'Test';
		volOppNonwish1.Chapter_Name__c = accountAzChapter.Id;

		Volunteer_Opportunity__c volOppNonwish2 = volOppsList.get(1);
		volOppNonwish2.Volunteer_Name__c = volunteerUser.ContactId;
		volOppNonwish2.Non_Wish_Event__c = nonWishTeamMeet.Id;
		volOppNonwish2.RecordTypeId = Constant_AC.REGISTERED_NON_WISH_ID;
		volOppNonwish2.Chapter_Role_Opportunity__c = nonWishChapterRole.Id;
		volOppNonwish2.Chapter_Name__c = accountAzChapter.Id;
		volOppNonwish2.Status__c = 'Approved';

		Volunteer_Opportunity__c volOppNonwish3 = volOppsList.get(2);
		volOppNonwish3.Volunteer_Name__c = volunteerUser.ContactId;
		volOppNonwish3.Non_Wish_Event__c = nonWishTeamMeet.Id;
		volOppNonwish3.RecordTypeId = Constant_AC.REGISTERED_NON_WISH_ID;
		volOppNonwish3.Chapter_Role_Opportunity__c = nonWishChapterRole.Id;
		volOppNonwish3.Status__c = 'Pending';
		volOppNonwish3.Chapter_Name__c = accountAzChapter.Id;
		volOppNonwish3.Inactivated_or_Rejected_Date__c = System.now().date();

		Volunteer_Opportunity__c volOppNonwish4 = volOppsList.get(3);
		volOppNonwish4.Volunteer_Name__c = volunteerUser.ContactId;
		volOppNonwish4.Non_Wish_Event__c = nonWishTeamMeet.Id;
		volOppNonwish4.RecordTypeId = Constant_AC.NON_WISH_EVENT_RT_ID;
		volOppNonwish4.Chapter_Role_Opportunity__c = nonWishChapterRole.Id;
		volOppNonwish4.Status__c = 'Pending';
		volOppNonwish4.Reason_Inactive__c = 'Requested';
		volOppNonwish4.Chapter_Name__c = accountAzChapter.Id;

		Volunteer_Opportunity__c volOppNonwish5 = volOppsList.get(4);
		volOppNonwish5.Volunteer_Name__c = volunteerUser.ContactId;
		volOppNonwish5.Non_Wish_Event__c = nonWishTeamMeet.Id;
		volOppNonwish5.RecordTypeId = Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID;
		volOppNonwish5.Chapter_Role_Opportunity__c = nonWishChapterRole.Id;
		volOppNonwish5.Status__c = 'Pending';
		volOppNonwish5.Chapter_Name__c = accountAzChapter.Id;

		Volunteer_Opportunity__c volOppNonwish6 = volOppsList.get(5);
		volOppNonwish6.Non_Wish_Event__c = nonWishTeamMeet.Id;
		volOppNonwish6.RecordTypeId = Constant_AC.NON_WISH_EVENT_RT_ID;
		volOppNonwish6.Chapter_Role_Opportunity__c = nonWishChapterRole.Id;
		volOppNonwish6.Inactive__c = false;
		volOppNonwish6.Reason_Inactive__c = null;
		volOppNonwish6.Chapter_Name__c = accountAzChapter.Id;

		Volunteer_Opportunity__c volOppNonwish7 = volOppsList.get(6);
		volOppNonwish7.Volunteer_Name__c = volunteerUser.ContactId;
		volOppNonwish7.Chapter_Name__c = accountAzChapter.Id;
		volOppNonwish7.RecordTypeId = Constant_AC.REGISTERED_NON_WISH_ID;
		volOppNonwish7.Status__c = 'Completed';
		volOppNonwish7.Inactive__c = false;
		volOppNonwish7.Reason_Inactive__c = null;
		volOppNonwish7.Chapter_Role_Opportunity__c = nonWishChapterRole.Id;

		Volunteer_Opportunity__c volOppWish1 = volOppsList.get(7);
		volOppWish1.Volunteer_Name__c = volunteerUser.ContactId;
		volOppWish1.Chapter_Name__c = accountAzChapter.Id;
		volOppWish1.Wish__c = wishCaseJacobs.Id;
		volOppWish1.RecordTypeId = Constant_AC.REGISTERED_WISH_ID;
		volOppWish1.Chapter_Role_Opportunity__c = wishGranterChapterRole.Id;
		volOppWish1.Status__c = 'Pending';
		volOppWish1.Inactive__c = false;
		volOppWish1.Reason_Inactive__c = null;

		Volunteer_Opportunity__c volOppWish2 = volOppsList.get(8);
		volOppWish2.Volunteer_Name__c = volunteerUser.ContactId;
		volOppWish2.Chapter_Name__c = accountAzChapter.Id;
		volOppWish2.Wish__c = wishCaseJacobs.Id;
		volOppWish2.RecordTypeId = Constant_AC.REGISTERED_WISH_ID;
		volOppWish2.Status__c = 'Completed';
		volOppWish2.Inactive__c = false;
		volOppWish2.Reason_Inactive__c = null;
		volOppWish2.Chapter_Role_Opportunity__c = nonWishChapterRole.Id;

		Volunteer_Opportunity__c volOppWish3 = volOppsList.get(9);
		volOppWish3.Volunteer_Name__c = volunteerUser.ContactId;
		volOppWish3.Chapter_Name__c = accountAzChapter.Id;
		volOppWish3.Wish__c = wishCaseJacobs.Id;
		volOppWish3.RecordTypeId = Constant_AC.REGISTERED_WISH_ID;
		volOppWish3.Status__c = 'Approved';
		volOppWish3.Chapter_Role_Opportunity__c = wishGranterChapterRole.Id;

		Volunteer_Opportunity__c volOppWish4 = volOppsList.get(10);
		volOppWish4.Volunteer_Name__c = volunteerUser.ContactId;
		volOppWish4.Chapter_Name__c = accountAzChapter.Id;
		volOppWish4.Wish__c = wishCaseJacobs.Id;
		volOppWish4.Status__c = 'Pending';
		volOppWish4.Inactivated_or_Rejected_Date__c = System.now().date();

		Volunteer_Opportunity__c volOppWish5 = volOppsList.get(11);
		volOppWish5.RecordTypeId = Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID;
		volOppWish5.Chapter_Role_Opportunity__c = nonWishChapterRole.Id;
		volOppWish5.Inactive__c = false;
		volOppWish5.Reason_Inactive__c = null;
		volOppWish5.Wish__c = wishCaseJacobs.Id;
		volOppWish5.Chapter_Name__c = accountAzChapter.Id;
		insert volOppsList;

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void volunteerWishEvents() {
		User currUser = [
				SELECT Id, Username, ContactId
				FROM User
				WHERE Email = 'js@email.com'
				LIMIT 1
		];
		Volunteer_Opportunity__c volOpp = [
				SELECT Id, Wish__c, Non_Wish_Event__c, Hidden_VolunteerCount_Desc__c, Chapter_Role_Opportunity__c
				FROM Volunteer_Opportunity__c
				WHERE Wish__c != null
				LIMIT 1
		];
		List<Account> azChapter = [
				SELECT Id
				FROM Account
				WHERE Name = 'Make-A-Wish Arizona'
		];
		List<Volunteer_Opportunity__c> volOppList = [
				SELECT Id, Wish__c, Non_Wish_Event__c, Hidden_VolunteerCount_Desc__c, Role__c, Status__c,
						Chapter_Role_Opportunity__r.Role_Name__c, Chapter_Name__r.Name, Reason_Inactive__c
				FROM Volunteer_Opportunity__c
		];
		Chapter_Role__c chapRole = [
				SELECT Id
				FROM Chapter_Role__c
				WHERE Background_Check_Required__c = true
		];

		Test.startTest();
		System.runAs(currUser) {
			PageReference pageref = Page.MyAssignment_VF;
			Test.setCurrentPageReference(pageref);
			VolunteerWorkItems_AC volunteerWorkitems = new VolunteerWorkItems_AC();
			VolunteerWorkItems_AC volunteerWorkitem = new VolunteerWorkItems_AC(new ApexPages.StandardController(volOpp));
			volunteerWorkitems.volunteerOpportunityRecordId = volOpp.Id;
			volunteerWorkitems.volunteerChaptersSet = new Set<Id>();
			volunteerWorkitems.volunteerChaptersSet.add(azChapter[0].Id);
			volunteerWorkitems.CurrentWish();
			volunteerWorkitems.HistoricalWish();
			volunteerWorkitems.getVolunteerAssignedWishEvents();
			volunteerWorkitems.getVolunteerAssignedNonWishEvents();
			volunteerWorkitems.getNonWishEvents();
			volunteerWorkitems.getWishEvents();
			volunteerWorkitems.getClosedWish();
			volunteerWorkitems.getClosedNonWishEvents();
			volunteerWorkitems.RegisterWishEvents();
			volunteerWorkitems.registrationConfirmation();
			volunteerWorkitems.getChapterRoleOanTStatus(chapRole.Id);
			volunteerWorkitems.allowRegisteration(volOppList);
			volunteerWorkitems.RedirecttoVolOpportunity();
		}
		Test.stopTest();
	}

	@IsTest
	public static void volunteerClosedWish() {
        User currUser = [
                SELECT Id, Username, ContactId
                FROM User
                WHERE Email = 'js@email.com'
                LIMIT 1
        ];
		Case wishCase = [
				SELECT Id, Status, Wish_Type__c
				FROM Case
				WHERE Wish_Type__c = :'Disney World'
		];
		wishCase.Status = 'Closed';
        wishCase.Closed_Date__c = Date.today();
		update wishCase;

		Volunteer_Opportunity__c volOpp = [
				SELECT Id, Wish__c, Non_Wish_Event__c, Chapter_Role_Opportunity__c
				FROM Volunteer_Opportunity__c
				WHERE Wish__c = :wishCase.Id
				LIMIT 1
		];

		Test.startTest();
		VolunteerWorkItems_AC volunteerWorkitems;
		System.runAs(currUser) {
			PageReference pageref = Page.MyAssignment_VF;
			Test.setCurrentPageReference(pageref);
			volunteerWorkitems = new VolunteerWorkItems_AC();
			volunteerWorkitems = new VolunteerWorkItems_AC(new ApexPages.StandardController(volOpp));
			volunteerWorkitems.CurrentWish();
			volunteerWorkitems.HistoricalWish();
			volunteerWorkitems.getClosedWish();
			volunteerWorkitems.RegisterWishEvents();
		}
		Test.stopTest();
		System.assert(volunteerWorkitems.isWishClosed = true);
	}

	@IsTest
	public static void volunteerClosedNonWish() {
        User currUser = [
                SELECT Id, Username, ContactId
                FROM User
                WHERE Email = 'js@email.com'
                LIMIT 1
        ];
		Non_Wish_Events__c closedNonWish = [
				SELECT Id,Event_Text__c
				FROM Non_Wish_Events__c
				WHERE Event_Text__c = 'Monthly touchpoint for the Arizona volunteer team.'
		];
		closedNonWish.Event_Date__c = System.today() - 3;
		update closedNonWish;

		Volunteer_Opportunity__c volOpp = [
				SELECT Id, Wish__c, Non_Wish_Event__c, Chapter_Role_Opportunity__c, Status__c
				FROM Volunteer_Opportunity__c
				WHERE Non_Wish_Event__c = :closedNonWish.Id
				AND Status__c != 'Completed'
				LIMIT 1
		];
		List<Volunteer_Opportunity__c> volOppList = new List<Volunteer_Opportunity__c>();

		Test.startTest();
		VolunteerWorkItems_AC volunteerWorkitems;
		System.runAs(currUser) {
			PageReference pageref = Page.MyAssignment_VF;
			Test.setCurrentPageReference(pageref);
			volunteerWorkitems = new VolunteerWorkItems_AC();
			volunteerWorkitems = new VolunteerWorkItems_AC(new ApexPages.StandardController(volOpp));
			volunteerWorkitems.CurrentWish();
			volunteerWorkitems.getNonWishEvents();
			volOppList = volunteerWorkitems.getClosedNonWishEvents();
			volunteerWorkitems.RegisterWishEvents();
		}
		Test.stopTest();
	}
}