/**
* @description Test class for Timesheet Service
* @author Michelle Cominotto, Make-A-Wish
* @createdDate 4/14/2020
*/
@IsTest
private class TimesheetServiceTest {
	private final static Id CHAPTER_RT_ID = Constant_AC.CHAPTER_RT_ID;
	private final static Id VOLUNTEER_RT_ID = Constant_AC.VOLUNTEER_RT_ID;
	private final static String CHAPTER_ROLE_WISH_GRANTER = Constant_AC.CHAPTER_ROLE_WISH_GRANTER;
	private final static Id NON_WISH_EVENT_RT_ID = Constant_AC.NON_WISH_EVENT_RT_ID;

	@TestSetup
	private static void setup() {
		trac_TriggerHandlerBase.blockTrigger = true;

		List<Account> accounts = TestDataFactory.createAccount(1);
		Account accountAzChapter = accounts.get(0);
		accountAzChapter.Name = 'Make-A-Wish Arizona';
		accountAzChapter.RecordTypeId = CHAPTER_RT_ID;
		insert accounts;

		List<Contact> contactList = TestDataFactory.createContact(1);
		Contact volunteerJane = contactList.get(0);
		volunteerJane.FirstName = 'Jane';
		volunteerJane.LastName = 'Eyre';
		volunteerJane.Email = 'jane.eyre@testmail.com';
		volunteerJane.RecordTypeId = VOLUNTEER_RT_ID;
		volunteerJane.AccountId = accountAzChapter.Id;
		volunteerJane.Active_Wish_Granter__c = false;
		insert contactList;

		List<Case> caseList = TestDataFactory.createCase(1);
        Case wishCase = caseList.get(0);
        wishCase.Total_Hour_Spent_Hidden__c = 1.60;
		insert caseList;

		List<Role__c> wishRolesList = TestDataFactory.createRole(1, true);
		Role__c wishGranter = wishRolesList.get(0);
		wishGranter.Name = CHAPTER_ROLE_WISH_GRANTER;
		insert wishRolesList;

		List<Chapter_Role__c> chapterRoleList = TestDataFactory.createChapterRole(1);
		Chapter_Role__c chapterRoleWishGranter = chapterRoleList.get(0);
		chapterRoleWishGranter.Chapter_Name__c = accountAzChapter.Id;
		chapterRoleWishGranter.Role_Name__c = wishGranter.Id;
		insert chapterRoleList;

		List<Non_Wish_Events__c> nonWishEvents = TestDataFactory.createNonWishEvent(1);
		Non_Wish_Events__c nonWishEventMeetup = nonWishEvents.get(0);
		nonWishEventMeetup.Event_Name__c = 'Arizona Chapter Case Review';
		nonWishEventMeetup.Chapter__c = accountAzChapter.Id;
		nonWishEventMeetup.Event_Date__c = Date.today().addDays(-7);
		nonWishEventMeetup.Total_Hour_Spent_Hidden__c = 1.60;
		insert nonWishEvents;

		List<Volunteer_Opportunity__c> volOppsList = TestDataFactory.createVolunteerOpportunity(2);
		Volunteer_Opportunity__c volOpp1 = volOppsList.get(0);
		volOpp1.Volunteer_Name__c = volunteerJane.Id;
		volOpp1.Non_Wish_Event__c = nonWishEventMeetup.Id;
		volOpp1.RecordTypeId = NON_WISH_EVENT_RT_ID;
		Volunteer_Opportunity__c volOpp2 = volOppsList.get(1);
		volOpp2.Volunteer_Name__c = volunteerJane.Id;
		volOpp2.Chapter_Name__c = accountAzChapter.Id;
		volOpp2.Wish__c = wishCase.Id;
		insert volOppsList;

		List<Time_sheet__c> timesheetsList = TestDataFactory.createTimesheet(2);
		Time_sheet__c nonWishTimesheet = timesheetsList.get(0);
		nonWishTimesheet.Volunteer_Opportunity__c = volOpp1.Id;
		nonWishTimesheet.Date__c = Date.today().addDays(-7);
		nonWishTimesheet.Description__c = 'Case Reviews';
		nonWishTimesheet.Hours_spent__c = 2.5;
		nonWishTimesheet.Hours_Hidden__c = 170;
		Time_sheet__c wishTimesheet = timesheetsList.get(1);
		wishTimesheet.Volunteer_Opportunity__c = volOpp2.Id;
		wishTimesheet.Date__c = Date.today().addDays(-3);
		wishTimesheet.Hours_spent__c = 1.5;
		wishTimesheet.Hours_Hidden__c = 110;
		wishTimesheet.Description__c = 'Wish Evaluation';
		insert timesheetsList;

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	private static void splitHoursMinutes() {
		List<Time_sheet__c> timesheetMap = [
				SELECT Id, Hours_spent__c
				FROM Time_sheet__c
		];

		Test.startTest();
		TimesheetService.splitHoursMinutes(timesheetMap);
		Test.stopTest();
	}

	@IsTest
	private static void splitHoursMinutesMap() {
		List<Time_sheet__c> timeSheets = [
				SELECT Id, Hours_spent__c
				FROM Time_sheet__c
                LIMIT 1
		];
        Time_sheet__c timeSheet = new Time_sheet__c();
        timeSheet.Id = timeSheets.get(0).Id;
        timeSheet.Hours_spent__c = 3.5;
        Map<Id, Time_sheet__c> oldTimesheetMap = new Map<Id, Time_sheet__c>{
                timeSheet.Id => timeSheet
        };

		Test.startTest();
		TimesheetService.splitHoursMinutes(timeSheets, oldTimesheetMap);
		Test.stopTest();
	}

	@IsTest
	private static void shareVolunteerOpportunity() {
		List<Time_sheet__c> timesheetMap = [
				SELECT Id, Volunteer_Opportunity__c
				FROM Time_sheet__c
		];

		Test.startTest();
		TimesheetService.shareVolunteerOpportunity(timesheetMap);
		Test.stopTest();
	}

	@IsTest
	private static void validateCalculateHoursOfWish() {
		Map<Id, Time_sheet__c> caseTimesheetMap = new Map<Id, Time_sheet__c>();
		for (Time_sheet__c sheet : [
				SELECT Id, Hours_spent__c, Volunteer_Opportunity__c, Volunteer_Opportunity__r.Wish__c
				FROM Time_sheet__c
				WHERE Volunteer_Opportunity__r.Wish__c != NULL
		]) {
			caseTimesheetMap.put(sheet.Volunteer_Opportunity__r.Wish__c, sheet);
		}
		Test.startTest();
		TimesheetService.calculateHoursOfWish(caseTimesheetMap.values());
		Test.stopTest();
		List<Case> caseList = [
				SELECT Id, Total_Hour_Spent_Hidden__c
				FROM Case
				WHERE Id IN :caseTimesheetMap.keySet()
		];
		System.assert(caseList[0].Total_Hour_Spent_Hidden__c == caseTimesheetMap.get(caseList[0].Id).Hours_spent__c);
	}

	@IsTest
	private static void validateCalculateHoursOfNonwish() {
		Map<Id, Time_sheet__c> nonWishTimesheetMap = new Map<Id, Time_sheet__c>();
		for (Time_sheet__c sheet : [
				SELECT Id, Hours_spent__c, Volunteer_Opportunity__c, Volunteer_Opportunity__r.Non_Wish_Event__c
				FROM Time_sheet__c
				WHERE Volunteer_Opportunity__r.Non_Wish_Event__c != NULL
		]) {
			nonWishTimesheetMap.put(sheet.Volunteer_Opportunity__r.Non_Wish_Event__c, sheet);
		}
		Test.startTest();
		TimesheetService.calculateHoursOfNonwish(nonWishTimesheetMap.values());
		Test.stopTest();
		List<Non_Wish_Events__c> nonWishEventsList = [
				SELECT Id, Total_Hour_Spent__c, Total_Hour_Spent_Hidden__c
				FROM Non_Wish_Events__c
				WHERE Id IN :nonWishTimesheetMap.keySet()
		];
		System.assert(nonWishEventsList[0].Total_Hour_Spent_Hidden__c == nonWishTimesheetMap.get(nonWishEventsList[0].Id).Hours_spent__c);
	}

	@IsTest
	private static void calculateHoursOfWishMap() {
        List<Time_sheet__c> timeSheets = [
                SELECT Id, Hours_Hidden__c, Volunteer_Opportunity__c
                FROM Time_sheet__c
                LIMIT 1
        ];

        Time_sheet__c timeSheet = new Time_sheet__c();
        timeSheet.Id = timeSheets.get(0).Id;
        timeSheet.Hours_Hidden__c = 250;
        Map<Id, Time_sheet__c> oldTimesheetMap = new Map<Id, Time_sheet__c>{
                timeSheet.Id => timeSheet
        };

        Test.startTest();
        TimesheetService.calculateHoursOfWish(timeSheets, oldTimesheetMap);
        Test.stopTest();
	}

	@IsTest
	private static void validateFindRecentTimesheetDate() {
		Map<Id, Time_sheet__c> volunteerTimesheetMap = new Map<Id, Time_sheet__c>();
		for (Time_sheet__c sheet : [
				SELECT Id, Date__c, Volunteer_Opportunity__c, Volunteer_Opportunity__r.Volunteer_Name__c
				FROM Time_sheet__c
				WHERE Volunteer_Opportunity__r.Volunteer_Name__c != NULL
		]) {
			volunteerTimesheetMap.put(sheet.Volunteer_Opportunity__r.Volunteer_Name__c, sheet);
		}
		Test.startTest();
		TimesheetService.findRecentTimesheetDate(volunteerTimesheetMap.values());
		Test.stopTest();
		List<Contact> volunteerList = [
				SELECT Id, Date_of_last_engagement__c
				FROM Contact
				WHERE Id IN :volunteerTimesheetMap.keySet()
		];
		System.assert(volunteerList[0].Date_of_last_engagement__c == volunteerTimesheetMap.get(volunteerList[0].Id).Date__c);
	}

	@IsTest
	private static void findRecentTimesheetDate() {
		List<Time_sheet__c> timeSheets = [
				SELECT Id, Date__c, Volunteer_Opportunity__c, Volunteer_Opportunity__r.Volunteer_Name__c
				FROM Time_sheet__c
				LIMIT 1
		];
		Time_sheet__c timeSheet = new Time_sheet__c();
		timeSheet.Id = timeSheets.get(0).Id;
		timeSheet.Date__c = Date.today();
		Map<Id, Time_sheet__c> oldTimesheetMap = new Map<Id, Time_sheet__c>{
				timeSheet.Id => timeSheet
		};
		Test.startTest();
		TimesheetService.findRecentTimesheetDate(timeSheets, oldTimesheetMap);
		Test.stopTest();
	}
}