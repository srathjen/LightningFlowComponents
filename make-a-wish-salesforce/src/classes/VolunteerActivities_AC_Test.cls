/************************************************************************************
Author : Mst Solutions
Created date: 11/21/2016
Description : This class is used to increase the code coverage for VolunteerActivities_AC
*************************************************************************************/
@IsTest
public class VolunteerActivities_AC_Test {

	private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;
	private final static Id VOLUNTEER_RT_ID = Constant_AC.VOLUNTEER_RT_ID;
	private final static Date sixtyDays = Date.today().addDays(60);

	@TestSetup
	public static void setUp() {
		trac_TriggerHandlerBase.blockTrigger = true;
		User currentUser = Utils.currentUser;
		List<Account> accounts = TestDataFactory.createAccount(1);
		Account account = accounts.get(0);
		account.Name = 'Make-A-Wish Arizona';
		account.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
		account.Volunteer_Manager__c = currentUser.Id;
		account.Alert_for_Unassigned_Wishes__c = 1;
		insert accounts;

		List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
		ICD_Codes__c icdCode = icdCodes.get(0);
		insert icdCode;

		List<Lead> leadsDataFactory = TestDataFactory.createLead(1);
		Lead lead = leadsDataFactory.get(0);
		lead.ChapterName__c = accounts[0].Id;
		lead.FirstName = 'Jack';
		lead.LastName = 'Smith';
		lead.Hidden_Chapter_Change_Confirmation__c = account.Id;
		lead.is_Family_Aware_of_Referral__c = 'Yes';
		lead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
		lead.PD_ICD_Code__c = icdCode.Id;
		lead.Company = 'MAW';
		insert lead;

		List<Contact> contacts = TestDataFactory.createContact(2);
		Contact contact1 = contacts.get(0);
		contact1.FirstName = 'Test1';
		contact1.LastName = 'User2';
		contact1.AccountId = account.Id;
		contact1.ICD_10_Code__c = icdCode.Id;
		Contact volunteerJoe = contacts.get(1);
		volunteerJoe.FirstName = 'Joe';
		volunteerJoe.LastName = 'Smith';
		volunteerJoe.Email = 'joe.smith@testmail.com';
		volunteerJoe.RecordTypeId = VOLUNTEER_RT_ID;
		volunteerJoe.AccountId = account.Id;
		volunteerJoe.B_C_Expiration_Date__c = sixtyDays;
		volunteerJoe.COI_Expiration_Date__c = sixtyDays;
		volunteerJoe.Active_Wish_Granter__c = false;
		insert contacts;

		User volunteerUser = TestDataFactory.createVolunteerUser(1).get(0);
		volunteerUser.LastName = 'Smith0';
		System.runAs(TestDataFactory.adminUser) {
			insert volunteerUser;
		}

		List<Case> cases = TestDataFactory.createCase(1);
		Case wish = cases.get(0);
		wish.Lead__c = lead.Id;
		wish.RecordTypeId = Constant_AC.DIAGNOSIS_RT_ID;
		wish.ChapterName__c = accounts.get(0).Id;
		wish.Subject = 'Wish1';
		wish.Interview_date__c = System.today();
		wish.Wish_Type__c = 'Hawaii';
		wish.Start_Date__c = System.today();
		wish.End_Date__c = System.today();
		wish.ContactId = contact1.Id;
		wish.Status = 'New';
		wish.Rush__c = false;
		wish.Start_Date__c = System.today();
		wish.Budget_Submitted_Date__c = System.today();
		wish.Budget_Approved_Date__c = System.today();
		wish.Update_Wish_Child_Form_Info__c = true;
		insert cases;

		List<Task> tasks = TestDataFactory.createTask(1);
		Task task = tasks.get(0);
		task.ActivityDate = System.today();
		task.Subject = 'Wish1';
		task.Status = 'Not Started';
		task.WhatId = wish.Id;
		insert tasks;

		CaseTeamRole roleRec = [
				SELECT Id
				FROM CaseTeamRole
				WHERE Name = 'Wish Granter'
				LIMIT 1
		];
		CaseTeamMember caseMember = new CaseTeamMember();
		caseMember.ParentId = wish.Id;
		caseMember.MemberId = volunteerUser.Id;
		caseMember.TeamRoleId = roleRec.Id;
		insert caseMember;

		List<Volunteer_Opportunity__c> volunteerOpportunities = TestDataFactory.createVolunteerOpportunity(1);
		Volunteer_Opportunity__c volunteerOpportunity = volunteerOpportunities.get(0);
		volunteerOpportunity.RecordTypeId = Constant_AC.NON_WISH_EVENT_RT_ID;
		volunteerOpportunity.Wish__c = wish.Id;
		volunteerOpportunity.Volunteer_Name__c = Utils.currentUser.ContactId;
		volunteerOpportunity.Status__c = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_APPROVED;
		insert volunteerOpportunities;

		List<Non_Wish_Events__c> nonWishEvents = TestDataFactory.createNonWishEvent(1);
		Non_Wish_Events__c event1 = nonWishEvents.get(0);
		event1.Event_Name__c = 'Event 1';
		event1.Event_Text__c = 'Event 1';
		event1.Priority__c = '2';
		event1.Chapter__c = account.Id;
		event1.Event_Date__c = Date.today().addDays(2);
		insert nonWishEvents;

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void openWishActivities() {
		User volunteer = [
				SELECT Id
				FROM User
				WHERE LastName = 'Smith0'
		][0];
		List<Task> tasks = [
				SELECT Id, Subject, Status, WhatId
				FROM Task
				WHERE Subject = 'Wish1'
		];
		System.assertEquals('Not Started', tasks[0].Status);

		System.runAs(volunteer) {
			PageReference pageref = Page.VolunteerActivities_VF;
			Test.setCurrentPageReference(pageref);
			VolunteerActivities_AC volunteerWorkitems = new VolunteerActivities_AC();
			volunteerWorkitems.getOpenActivities();
		}
	}

	@IsTest
	public static void openNonActivities() {
		Case wishCase = [
				SELECT Id
				FROM Case
				WHERE Subject = 'Wish1'
				LIMIT 1
		];
		List<Volunteer_Opportunity__c> volunteerOpportunities = [
				SELECT Id
				FROM Volunteer_Opportunity__c
				WHERE Wish__c = :wishCase.Id
		];
		List<Task> tasks = [
				SELECT Id, Subject, Status, WhatId
				FROM Task
				WHERE Subject = 'Wish1'
		];
		tasks[0].WhatId = volunteerOpportunities[0].Id;
		update tasks;
		User volunteer = [
				SELECT Id
				FROM User
				WHERE LastName = 'Smith0'
		][0];
		tasks[0].WhatId = volunteerOpportunities[0].Id;
		update tasks;
		System.assertEquals(tasks[0].WhatId, volunteerOpportunities[0].Id);
		System.runAs(volunteer) {
			PageReference pageref = Page.VolunteerActivities_VF;
			Test.setCurrentPageReference(pageref);
			VolunteerActivities_AC volunteerWorkitems = new VolunteerActivities_AC();
			volunteerWorkitems.getOpenActivities();
		}
	}

	@IsTest
	public static void openNonWishActivities() {
		Case wishCase = [
				SELECT Id
				FROM Case
				WHERE Subject = 'Wish1'
				LIMIT 1
		];
		List<Non_Wish_Events__c> nonWishEvents = [
				SELECT Id
				FROM Non_Wish_Events__c
				WHERE Event_Name__c = 'Event 1'
		];
		List<Volunteer_Opportunity__c> volunteerOpportunities = [
				SELECT Id
				FROM Volunteer_Opportunity__c
				WHERE Wish__c = :wishCase.Id
		];
		volunteerOpportunities[0].Non_Wish_Event__c = nonWishEvents[0].Id;
		update volunteerOpportunities;
		User volunteer = [
				SELECT Id
				FROM User
				WHERE LastName = 'Smith0'
		][0];
		List<Task> tasks = [
				SELECT Id, Subject, Status, WhatId, OwnerId
				FROM Task
				WHERE Subject = 'Wish1'
		];
		tasks[0].OwnerId = volunteer.Id;
		update tasks;

		System.assertEquals(tasks[0].OwnerId, volunteer.Id);

		System.runAs(volunteer) {
			PageReference pageref = Page.VolunteerActivities_VF;
			Test.setCurrentPageReference(pageref);
			VolunteerActivities_AC volunteerWorkitems = new VolunteerActivities_AC();
			volunteerWorkitems.getOpenActivities();
		}
	}

	@IsTest
	public static void openNonWishEventActivities() {
		Case wishCase = [
				SELECT Id
				FROM Case
				WHERE Subject = 'Wish1'
				LIMIT 1
		];
		List<Non_Wish_Events__c> nonWishEvents = [
				SELECT Id
				FROM Non_Wish_Events__c
				WHERE Event_Name__c = 'Event 1'
		];
		List<Volunteer_Opportunity__c> volunteerOpportunities = [
				SELECT Id
				FROM Volunteer_Opportunity__c
				WHERE Wish__c = :wishCase.Id
		];
		volunteerOpportunities[0].Non_Wish_Event__c = nonWishEvents[0].Id;
		update volunteerOpportunities;
		User volunteer = [
				SELECT Id
				FROM User
				WHERE LastName = 'Smith0'
		][0];
		List<Task> tasks = [
				SELECT Id, Subject, Status, WhatId, OwnerId
				FROM Task
				WHERE Subject = 'Wish1'
		];
		tasks[0].OwnerId = volunteer.Id;
		update tasks;

		System.assertEquals(tasks[0].OwnerId, volunteer.Id);

		System.runAs(volunteer) {
			PageReference pageref = Page.VolunteerActivities_VF;
			Test.setCurrentPageReference(pageref);
			VolunteerActivities_AC volunteerWorkitems = new VolunteerActivities_AC();
			volunteerWorkitems.getOpenActivities();
			volunteerWorkitems.taskId = tasks[0].Id;
			volunteerWorkitems.closeTask();
		}
	}

	@IsTest
	public static void closedWishActivities() {
		Case wishCase = [
				SELECT Id
				FROM Case
				WHERE Subject = 'Wish1'
				LIMIT 1
		];
		List<Non_Wish_Events__c> nonWishEvents = [
				SELECT Id
				FROM Non_Wish_Events__c
				WHERE Event_Name__c = 'Event 1'
		];
		List<Volunteer_Opportunity__c> volunteerOpportunities = [
				SELECT Id
				FROM Volunteer_Opportunity__c
				WHERE Wish__c = :wishCase.Id
		];
		volunteerOpportunities[0].Non_Wish_Event__c = nonWishEvents[0].Id;
		update volunteerOpportunities;
		User volunteer = [
				SELECT Id
				FROM User
				WHERE LastName = 'Smith0'
		][0];
		List<Task> tasks = [
				SELECT Id, Subject, Status, WhatId
				FROM Task
				WHERE Subject = 'Wish1'
		];
		tasks[0].Status = 'Completed';

		Case newCase = new Case();
		newCase.Id = wishCase.Id;
		newCase.Presentation_Date__c = System.today();
		newCase.Time__c = '10.50pm';
		newCase.Name_of_Location__c = 'testLocation';
		newCase.Location_Address__c = 'test';
		newCase.Wish_Presentation_Set__c = True;
		update newCase;

		System.assertEquals(tasks[0].Status, 'Completed');

		System.runAs(volunteer) {
			PageReference pageref = Page.VolunteerActivities_VF;
			Test.setCurrentPageReference(pageref);
			VolunteerActivities_AC volunteerWorkitems = new VolunteerActivities_AC();
			volunteerWorkitems.getCloseActivities();
		}
	}

	@IsTest
	public static void closedNonActivities() {
		Case wishCase = [
				SELECT Id
				FROM Case
				WHERE Subject = 'Wish1'
				LIMIT 1
		];
		List<Non_Wish_Events__c> nonWishEvents = [
				SELECT Id
				FROM Non_Wish_Events__c
				WHERE Event_Name__c = 'Event 1'
		];
		List<Volunteer_Opportunity__c> volunteerOpportunities = [
				SELECT Id
				FROM Volunteer_Opportunity__c
				WHERE Wish__c = :wishCase.Id
		];
		volunteerOpportunities[0].Non_Wish_Event__c = nonWishEvents[0].Id;
		update volunteerOpportunities;
		User volunteer = [
				SELECT Id
				FROM User
				WHERE LastName = 'Smith0'
		][0];
		List<Task> tasks = [
				SELECT Id, Subject, Status, WhatId
				FROM Task
				WHERE Subject = 'Wish1'
		];
		tasks[0].Status = 'Completed';

		System.assertEquals(tasks[0].Status, 'Completed');

		System.runAs(volunteer) {
			PageReference pageref = Page.VolunteerActivities_VF;
			Test.setCurrentPageReference(pageref);
			VolunteerActivities_AC volunteerWorkitems = new VolunteerActivities_AC();
			volunteerWorkitems.getCloseActivities();
		}
	}

	@IsTest
	public static void closedNonWishActivities() {
		Case wishCase = [
				SELECT Id
				FROM Case
				WHERE Subject = 'Wish1'
				LIMIT 1
		];
		List<Non_Wish_Events__c> nonWishEvents = [
				SELECT Id
				FROM Non_Wish_Events__c
				WHERE Event_Name__c = 'Event 1'
		];
		List<Volunteer_Opportunity__c> volunteerOpportunities = [
				SELECT Id
				FROM Volunteer_Opportunity__c
				WHERE Wish__c = :wishCase.Id
		];
		volunteerOpportunities[0].Non_Wish_Event__c = nonWishEvents[0].Id;
		update volunteerOpportunities;
		User volunteer = [
				SELECT Id
				FROM User
				WHERE LastName = 'Smith0'
		][0];
		List<Task> tasks = [
				SELECT Id, Subject, Status, WhatId
				FROM Task
				WHERE Subject = 'Wish1'
		];
		tasks[0].Status = 'Completed';

		System.assertEquals(tasks[0].Status, 'Completed');

		System.RunAs(volunteer) {
			PageReference pageref = Page.VolunteerActivities_VF;
			Test.setCurrentPageReference(pageref);
			VolunteerActivities_AC volunteerWorkitems = new VolunteerActivities_AC();
			volunteerWorkitems.getCloseActivities();
		}
	}

	@IsTest
	public static void closedNonWishEventActivities() {
		Case wishCase = [
				SELECT Id
				FROM Case
				WHERE Subject = 'Wish1'
				LIMIT 1
		];
		List<Non_Wish_Events__c> nonWishEvents = [
				SELECT Id
				FROM Non_Wish_Events__c
				WHERE Event_Name__c = 'Event 1'
		];
		List<Volunteer_Opportunity__c> volunteerOpportunities = [
				SELECT Id
				FROM Volunteer_Opportunity__c
				WHERE Wish__c = :wishCase.Id
		];
		volunteerOpportunities[0].Non_Wish_Event__c = nonWishEvents[0].Id;
		update volunteerOpportunities;
		User volunteer = [
				SELECT Id
				FROM User
				WHERE LastName = 'Smith0'
		][0];
		List<Task> tasks = [
				SELECT Id, Subject, Status, WhatId
				FROM Task
				WHERE Subject = 'Wish1'
		];
		tasks[0].Status = 'Completed';

		System.assertEquals(tasks[0].Status, 'Completed');

		System.runAs(volunteer) {
			PageReference pageref = Page.VolunteerActivities_VF;
			Test.setCurrentPageReference(pageref);
			VolunteerActivities_AC volunteerWorkitems = new VolunteerActivities_AC();
			volunteerWorkitems.getCloseActivities();
		}
	}
}