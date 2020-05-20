/*--*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Chandrasekar Nallusamy
Date        : 7/12/2016
Description : This test class used for unit test and code coverage
*******************************************************************************************************************/

@IsTest
public class BackgroundCheck_AC_Test {
	private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;
	private final static Id NATIONAL_RT_ID = Constant_AC.NATIONAL_RT_ID;

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

		User volunteerUser = TestDataFactory.createVolunteerUser(1, 'Active Volunteer (Login)', 'Manager').get(0);
		volunteerUser.LastName = 'Smith0';
		System.runAs(TestDataFactory.adminUser) {
			insert volunteerUser;
		}

		List<Contact> contacts = TestDataFactory.createContact(1);
		Contact contact1 = contacts.get(0);
		contact1.FirstName = 'Test1';
		contact1.LastName = 'User2';
		contact1.AccountId = account.Id;
		contact1.ICD_10_Code__c = icdCode.Id;
		insert contacts;

		Contact contactUpdate = new Contact();
		contactUpdate.Id = volunteerUser.ContactId;
		contactUpdate.Professional_Skills__c = 'Test';
		contactUpdate.How_did_you_hear_about_Make_A_Wish__c = 'Friend';
		contactUpdate.Language__c = 'English';
		contactUpdate.Understand__c = 'Test';
		contactUpdate.Write__c = 'English';
		contactUpdate.Speak__c = 'English';
		contactUpdate.Read__c = 'English';
		contactUpdate.Volunteer_Role__c = 'Special Events';
		update contactUpdate;

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

		List<Background_check__c> backgroundChecks = TestDataFactory.createBackgroundCheck(1);
		Background_check__c backgroundCheck = backgroundChecks.get(0);
		backgroundCheck.Date__c = System.today();
		backgroundCheck.Volunteer__c = volunteerUser.ContactId;
		backgroundCheck.Date_Completed__c = System.today().addYears(-3);
		backgroundCheck.Status__c = 'Sent to First Advantage';
		insert backgroundChecks;

		List<Dynamic_Content__c> dynamicContents = TestDataFactory.createDynamicContent(1);
		Dynamic_Content__c dynamicContent = dynamicContents.get(0);
		dynamicContent.Sign_Up_Page__c = 'Hai';
		dynamicContent.RecordTypeId = NATIONAL_RT_ID;
		dynamicContent.Application_Overview__c = 'An interview is a great way to better understand the role(s) and expectations of the volunteer opportunities that you are interested in';
		dynamicContent .Active__c = true;
		dynamicContent.Interview_Additional_Info__c = 'Test';
		dynamicContent.Orientation_Add_l_Info__c = 'Test';
		dynamicContent.Sign_Up_Page__c = 'Test';
		dynamicContent.Training_Additional_Info__c = 'Test';
		dynamicContent.Welcome_Message__c = 'Test';
		dynamicContent.WelcomePage__c = 'Test';
		dynamicContent.Welcome_Text__c = 'Test';
		dynamicContent.Why_Need_Background_Check__c = 'Test';
		insert dynamicContents;

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void createVolunteerCommunityUserBackCheck() {
		User volunteerUser = [
				SELECT Id,UserRoleId,Username,ProfileId,Email,FirstName,ContactId,LastName,IsActive
				FROM User
				WHERE LastName = 'Smith0'
		][0];
		Background_check__c backgroundCheck = [
				SELECT Id
				FROM Background_check__c
				WHERE Status__c = 'Sent to First Advantage'
		][0];

		Test.startTest();
		backgroundCheck.Resided_in_US_for_past_7_years__c = 'Yes';
		update backgroundCheck;
		ApexPages.currentPage().getParameters().put('trainingRequired', 'true');
		ApexPages.currentPage().getParameters().put('bgRequired', 'true');
		BGCRecordSharing(volunteerUser.Id, backgroundCheck.Id);
		update backgroundCheck;
		BackgroundCheck_AC backCheck;
		System.runAs(volunteerUser) {
			backCheck = new BackgroundCheck_AC();
			backCheck.backGroundCheck = backgroundCheck;
			backgroundCheck.Date_Completed__c = Date.today();
			backgroundCheck.Status__c = 'Approved';
			backCheck.statusValue = true;
			backCheck.whyNeedBGCheck = 'To Verify';
			backCheck.isBGFinished = true;
			backCheck.residingInPast7Years = 'Yes';
			backCheck.areYouinUS7Yrs = 'Yes';
			backCheck.saveRec();
			backCheck.getResidedValues();
		}
		Test.stopTest();
	}

	@IsTest
	public static void backGroundCheckNo() {
		User volunteerUser = [
				SELECT Id,UserRoleId,Username,ProfileId,Email,FirstName,ContactId,LastName,IsActive
				FROM User
				WHERE LastName = 'Smith0'
		][0];
		Background_check__c backgroundCheck = [
				SELECT Id
				FROM Background_check__c
				WHERE Status__c = 'Sent to First Advantage'
		][0];
		Test.startTest();
		backgroundCheck.Resided_in_US_for_past_7_years__c = null;
		update backgroundCheck;
		ApexPages.currentPage().getParameters().put('trainingRequired', 'true');
		ApexPages.currentPage().getParameters().put('bgRequired', 'true');
		BGCRecordSharing(volunteerUser.Id, backgroundCheck.Id);
		update backgroundCheck;

		BackgroundCheck_AC backCheck;
		System.runAs(volunteerUser) {
			backCheck = new BackgroundCheck_AC();
			backCheck.backGroundCheck = backgroundCheck;
		}

		backCheck.saveRec();
		backCheck.getResidedValues();
		Test.stopTest();
	}

	private static Background_check__Share BGCRecordSharing(Id userId, Id recordId) {
		Background_check__Share currSharing = new Background_check__Share();
		User currUser = [
				SELECT Id
				FROM User
				WHERE Profile.Name = 'System Administrator'
				AND IsActive = TRUE
				LIMIT 1
		];
		System.runAs(currUser) {
			currSharing.ParentId = recordId;
			currSharing.UserOrGroupId = userId;
			currSharing.AccessLevel = 'Edit';
			currSharing.RowCause = Schema.Background_check__Share.RowCause.Manual;
			insert currSharing;
		}
		return currSharing;
	}
}
