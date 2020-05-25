/*****************************************************************************************************************
Author      : MST Solutions
Date        : 12/01/2016
Description : This class contains test method for CaseFile object
Modification Log: 
28/03/2018 - Kanagaraj
*******************************************************************************************************************/
@IsTest
public class VolunteerTaskTransfer_AC_Test {

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

		User communityUser = TestDataFactory.createCommunityUser(1).get(0);
		communityUser.LastName = 'Smith0';
		System.runAs(TestDataFactory.adminUser) {
			insert communityUser;
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
		task.Subject = 'Conduct Interview';
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
		caseMember.MemberId = communityUser.Id;
		caseMember.TeamRoleId = roleRec.Id;
		insert caseMember;

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void transferTask() {
		User volunteer = [
				SELECT Id
				FROM User
				WHERE LastName = 'Smith0'
		][0];
		List<Task> tasks = [
				SELECT Id, Subject, Status, WhatId
				FROM Task
				WHERE Subject = 'Conduct Interview'
		];
		ApexPages.StandardController sc = new ApexPages.StandardController(tasks[0]);
		VolunteerTaskTransfer_AC volunteerTask = new VolunteerTaskTransfer_AC(sc);
		volunteerTask.getAssigners();
		volunteerTask.assignerId = volunteer.Id;
		volunteerTask.transferTask();
		System.assertEquals(tasks[0].Subject, 'Conduct Interview', 'Task subject does not match');
		System.assert(tasks[0].Subject == 'Conduct Interview', 'Task subject does not match');
	}
}