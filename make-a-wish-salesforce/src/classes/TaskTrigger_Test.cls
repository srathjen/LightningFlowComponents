/************************************************************************************
Created Date : 07/25/2016
Author : Mst Solutions
Description : Unit Test for TaskTrigger_AT and TaskTriggerHandler
*************************************************************************************/

@IsTest
public class TaskTrigger_Test {

	private final static Id VOLUNTEER_TASK_RT_ID = Constant_AC.VOLUNTEER_TASK_RT_ID;
	private final static Id CONTACT_WISH_CHILD_RT_ID = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
	private final static Id LEAD_RT_WISH_CHILD = Constant_AC.LEAD_RT_WISH_CHILD;

	@TestSetup static void setup() {
		trac_TriggerHandlerBase.blockTrigger = true;

		List<Account> accounts = TestDataFactory.createAccount(1);
		Account account = accounts.get(0);
		account.Name = 'Make-A-Wish Arizona';
		account.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
		insert accounts;

		List<Contact> contacts = TestDataFactory.createContact(1);
		Contact contact = contacts.get(0);
		contact.Region_Chapter__c = account.Id;
		contact.FirstName = 'Jack';
		contact.LastName = 'Smith';
		contact.Email = 'jacksmith@email.com';
		contact.Phone = '1233213333';
		contact.MailingStreet = '123 Street';
		contact.MailingCity = 'Phoenix';
		contact.MailingState = 'Arizona';
		contact.MailingStateCode = 'AZ';
		contact.MailingPostalCode = '85001';
		contact.MailingCountryCode = 'US';
		contact.RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
		contact.Primary_Diagnosis_Condition_Description__c = 'Test';
		contact.Diagnosis__c = 'test';
		insert contacts;

		List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
		ICD_Codes__c icdCode = icdCodes.get(0);
		insert icdCode;

		List<Lead> leadsDataFactory = TestDataFactory.createLead(1);
		Lead lead = leadsDataFactory.get(0);
		lead.ChapterName__c = accounts[0].Id;
		lead.FirstName = 'Bob';
		lead.LastName = 'Stuart';
		lead.Hidden_Chapter_Change_Confirmation__c = account.Id;
		lead.is_Family_Aware_of_Referral__c = 'Yes';
		lead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
		lead.PD_ICD_Code__c = icdCode.Id;
		lead.Company = 'MAW';
		lead.RecordTypeId = LEAD_RT_WISH_CHILD;
		insert lead;

		List<Case> cases = TestDataFactory.createCase(1);
		Case wish = cases.get(0);
		wish.Lead__c = lead.Id;
		wish.RecordTypeId = Constant_AC.WISH_RT_ID;
		wish.ChapterName__c = accounts.get(0).Id;
		wish.Subject = 'Wish1';
		wish.Interview_date__c = System.today();
		wish.Wish_Type__c = 'Hawaii';
		wish.Start_Date__c = System.today();
		wish.End_Date__c = System.today();
		wish.ContactId = contact.Id;
		wish.Status = 'New';
		wish.Rush__c = false;
		wish.Start_Date__c = System.today();
		wish.Budget_Submitted_Date__c = System.today();
		wish.Budget_Approved_Date__c = System.today();
		wish.Update_Wish_Child_Form_Info__c = true;
		insert cases;

		User volunteerUser = TestDataFactory.createVolunteerUser(1, 'Active Volunteer (Login)', 'Manager').get(0);
		volunteerUser.LastName = 'Smith0';
		volunteerUser.Email = 'js@email.com';
		System.runAs(TestDataFactory.adminUser) {
			insert volunteerUser;
		}

		CaseTeamRole caseTeamRole = [
				SELECT Id,Name
				FROM CaseTeamRole
				WHERE Name = :'Wish Granter'
				LIMIT 1
		];
		List<CaseTeamMember> caseTeamMembers = TestDataFactory.createCaseTeamMember(1);
		CaseTeamMember caseMember = caseTeamMembers.get(0);
		caseMember.ParentId = wish.Id;
		caseMember.MemberId = volunteerUser.Id;
		caseMember.TeamRoleId = caseTeamRole.Id;
		insert caseTeamMembers;

		List<npe5__Affiliation__c> affiliations = TestDataFactory.createAffiliation(1);
		npe5__Affiliation__c affiliation = affiliations.get(0);
		affiliation.npe5__Contact__c = volunteerUser.ContactId;
		affiliation.npe5__Organization__c = account.Id;
		affiliation.npe5__Primary__c = true;
		affiliation.npe5__Status__c = 'Pending';
		affiliation.Constituent_Code__c = Constant_AC.BOARD_MEMBER_RT_LABEL;
		insert affiliations;

		List<Background_check__c> backgroundChecks = TestDataFactory.createBackgroundCheck(1);
		Background_check__c backgroundCheck = backgroundChecks.get(0);
		backgroundCheck.Current__c = true;
		backgroundCheck.Date__c = Date.today().addDays(3);
		backgroundCheck.Date_Completed__c = Date.today().addDays(3);
		backgroundCheck.Status__c = Constant_AC.BACKGROUND_CHECK_STATUS_APPROVED;
		insert backgroundChecks;

		List<Conflict_Of_Interest__c> conflictOfInterests = TestDataFactory.createConflictOfInterest(1);
		Conflict_Of_Interest__c conflictOfIntetest = conflictOfInterests.get(0);
		conflictOfIntetest.Current__c = true;
		conflictOfIntetest.Expiration_Date__c = Date.today().addDays(3);
		insert conflictOfInterests;

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void checkWishGrantTask() {
		Case wish = [
				SELECT Id
				FROM Case
				LIMIT 1
		];
		Contact wishChild = [
				SELECT Id
				FROM Contact
				WHERE RecordTypeId = :CONTACT_WISH_CHILD_RT_ID
				LIMIT 1
		];

		List<Task> tasks = TestDataFactory.createTask(1);
		Task updateToCloseStatus = tasks.get(0);
		updateToCloseStatus.Subject = 'Granting Task';
		updateToCloseStatus.Status = 'New';
		updateToCloseStatus.Task_Type__c = 'Wish Granting';
		updateToCloseStatus.RecordTypeId = VOLUNTEER_TASK_RT_ID;
		updateToCloseStatus.WhoId = wishChild.Id;
		updateToCloseStatus.WhatId = wish.Id;
		insert tasks;
		System.assertEquals(wish.Id, updateToCloseStatus.WhatId, 'Compare Parentcaseinfo with wishgranting task what Id');
		updateToCloseStatus.Status = Constant_AC.TASK_STATUS_COMPLETED;
		update updateToCloseStatus;
		System.assertEquals(Constant_AC.TASK_STATUS_COMPLETED, updateToCloseStatus.Status, 'Confirm Close task status is Completed');
	}

	@IsTest
	public static void checkWishGrantTaskWithOpenTask() {
		Case wish = [
				SELECT Id
				FROM Case
				LIMIT 1
		];
		Contact wishChild = [
				SELECT Id
				FROM Contact
				WHERE RecordTypeId = :CONTACT_WISH_CHILD_RT_ID
				LIMIT 1
		];

		List<Task> tasks = TestDataFactory.createTask(2);
		Task wishGrantingNewTask = tasks.get(0);
		wishGrantingNewTask.Subject = 'Granting Open Task';
		wishGrantingNewTask.Status = 'New';
		wishGrantingNewTask.Task_Type__c = 'Wish Granting';
		wishGrantingNewTask.RecordTypeId = VOLUNTEER_TASK_RT_ID;
		wishGrantingNewTask.WhoId = wishChild.Id;
		wishGrantingNewTask.WhatId = wish.Id;

		Task wishGrantingTask = tasks.get(1);
		wishGrantingTask.Subject = 'Granting Close Task';
		wishGrantingTask.Status = 'New';
		wishGrantingTask.Task_Type__c = 'Wish Granting';
		wishGrantingTask.RecordTypeId = VOLUNTEER_TASK_RT_ID;
		wishGrantingTask.WhoId = wishChild.Id;
		wishGrantingTask.WhatId = wish.Id;
		insert tasks;

		System.assertEquals('Granting Open Task', wishGrantingNewTask.Subject, 'Confirm WishGrantingTask subject is Granting Open Task');
		System.assertEquals(wish.Id, wishGrantingTask.WhatId, 'Compare Parentcaseinfo with wishgranting task what Id');

		wishGrantingNewTask.Status = Constant_AC.TASK_STATUS_COMPLETED;
		update wishGrantingNewTask;
		System.assertEquals(Constant_AC.TASK_STATUS_COMPLETED, wishGrantingNewTask.Status, 'Confirm Close task status is Completed');
	}

	@IsTest
	public static void updateLeadCloseDate() {
		Case wish = [
				SELECT Id, Lead__c
				FROM Case
				LIMIT 1
		];
		Task referralDNQTask = new Task(Subject = 'Referral DNQ', Status = 'New', RecordTypeId = VOLUNTEER_TASK_RT_ID, WhoId = wish.Lead__c);
		insert referralDNQTask;
		Task updateToCloseStatus = new Task(Id = referralDNQTask.Id, Status = Constant_AC.TASK_STATUS_COMPLETED);
		update updateToCloseStatus;
	}

	@IsTest
	public static void updateCheckinDate() {
		Case wish = [
				SELECT Id
				FROM Case
				LIMIT 1
		];
		Contact wishChild = [
				SELECT Id
				FROM Contact
				WHERE RecordTypeId = :CONTACT_WISH_CHILD_RT_ID
				LIMIT 1
		];
		Task checkInTask = new Task(Subject = 'Check in with the family every 30 days', Status = 'New', RecordTypeId = VOLUNTEER_TASK_RT_ID, WhoId = wishChild.Id, WhatId = wish.Id);
		insert checkInTask;
		System.assertEquals(wish.Id, checkInTask.WhatId, 'Compare Parentcaseinfo with CheckInTask task what Id');
		Task updateToCloseStatus = new Task(Id = checkInTask.Id, Status = Constant_AC.TASK_STATUS_COMPLETED);
		update updateToCloseStatus;
	}

	@IsTest
	public static void createUploadTaskForWishOwner() {
		Case wish = [
				SELECT Id
				FROM Case
				LIMIT 1
		];
		Contact wishChild = [
				SELECT Id
				FROM Contact
				WHERE RecordTypeId = :CONTACT_WISH_CHILD_RT_ID
				LIMIT 1
		];

		List<Task> tasks = TestDataFactory.createTask(1);
		Task checkInTask = tasks.get(0);
		checkInTask.Subject = 'Review photos/vIdeos';
		checkInTask.Status = 'New';
		checkInTask.RecordTypeId = VOLUNTEER_TASK_RT_ID;
		checkInTask.WhoId = wishChild.Id;
		checkInTask.WhatId = wish.Id;
		insert tasks;
		System.assertEquals(wish.Id, checkInTask.WhatId, 'Compare Parentcaseinfo with CheckInTask task what Id');
		checkInTask.Status = Constant_AC.TASK_STATUS_COMPLETED;
		update checkInTask;
	}

	@IsTest
	public static void sneakPeekTask() {
		Case wish = [
				SELECT Id
				FROM Case
				LIMIT 1
		];

		List<Task> tasks = TestDataFactory.createTask(4);
		Task sneakPeek = tasks.get(0);
		sneakPeek.ActivityDate = System.today() + 30;
		sneakPeek.Subject = 'Sneak Peek Letter';
		sneakPeek.Status = 'Not Started';
		sneakPeek.WhatId = wish.Id;

		Task flightBookingTask = tasks.get(1);
		flightBookingTask.ActivityDate = System.today() + 30;
		flightBookingTask.Subject = 'Flights booked';
		flightBookingTask.Status = 'Not Started';
		flightBookingTask.WhatId = wish.Id;

		Task passportTask = tasks.get(2);
		passportTask.ActivityDate = System.today() + 30;
		passportTask.Subject = 'Request Passports from family';
		passportTask.Status = 'Not Started';
		passportTask.WhatId = wish.Id;

		Task budgetTask = tasks.get(3);
		budgetTask.ActivityDate = System.today() + 30;
		budgetTask.Subject = 'Budget';
		budgetTask.Status = 'Not Started';
		budgetTask.WhatId = wish.Id;
		insert tasks;

		flightBookingTask.Status = Constant_AC.TASK_STATUS_COMPLETED;
		update flightBookingTask;
		budgetTask.Status = Constant_AC.TASK_STATUS_COMPLETED;
		update budgetTask;
	}

	@IsTest
	public static void sneakPeekTaskActivityDateAsNull() {
		Case wish = [
				SELECT Id
				FROM Case
				LIMIT 1
		];

		List<Task> tasks = TestDataFactory.createTask(4);
		Task sneakPeek = tasks.get(0);
		sneakPeek.ActivityDate = null;
		sneakPeek.Subject = 'Sneak Peek Letter';
		sneakPeek.Status = 'Not Started';
		sneakPeek.WhatId = wish.Id;

		Task flightBookingTask = tasks.get(1);
		flightBookingTask.ActivityDate = System.today() + 30;
		flightBookingTask.Subject = 'Flights booked';
		flightBookingTask.Status = 'Not Started';
		flightBookingTask.WhatId = wish.Id;

		Task passportTask = tasks.get(2);
		passportTask.ActivityDate = System.today() + 30;
		passportTask.Subject = 'Request Passports from family';
		passportTask.Status = 'Not Started';
		passportTask.WhatId = wish.Id;

		Task budgetTask = tasks.get(3);
		budgetTask.ActivityDate = System.today() + 30;
		budgetTask.Subject = 'Budget';
		budgetTask.Status = 'Not Started';
		budgetTask.WhatId = wish.Id;
		insert tasks;

		flightBookingTask.Status = Constant_AC.TASK_STATUS_COMPLETED;
		update flightBookingTask;
		budgetTask.Status = Constant_AC.TASK_STATUS_COMPLETED;
		update budgetTask;
	}

	@IsTest
	public static void passPortRequest() {
		Case wish = [
				SELECT Id
				FROM Case
				LIMIT 1
		];

		List<Task> tasks = TestDataFactory.createTask(2);
		Task cruiseTask = tasks.get(0);
		cruiseTask.ActivityDate = System.today();
		cruiseTask.Subject = 'Cruise request form';
		cruiseTask.WhatId = wish.Id;

		Task passportTask = tasks.get(1);
		passportTask.ActivityDate = System.today() + 30;
		passportTask.Subject = 'Request Passports from family';
		passportTask.Status = 'Not Started';
		passportTask.WhatId = wish.Id;
		insert tasks;

		passportTask.Status = Constant_AC.TASK_STATUS_COMPLETED;
		update passportTask;
	}

	@IsTest
	public static void completedTask() {
		Case wish = [
				SELECT Id
				FROM Case
				LIMIT 1
		];

		List<Task> tasks = TestDataFactory.createTask(1);
		Task task = tasks.get(0);
		task.ActivityDate = null;
		task.Subject = 'Test';
		task.Status = Constant_AC.TASK_STATUS_IN_PROGRESS;
		task.WhatId = wish.Id;
		task.Available_Time1__c = 'Test';
		task.Available_Time2__c = 'Test';
		task.Available_Time3__c = 'Test';
		task.SystemGeneratedTask__c = false;
		insert tasks;

		task.Subject = 'Test ET : ';
		task.Availability_Time_Other1__c = 'Test';
		task.Availability_Time_Other2__c = 'Test';
		task.Availability_Time_Other3__c = 'Test';
		task.Status = Constant_AC.TASK_STATUS_COMPLETED;
		update task;
	}
}