/************************************************************************************
Created Date : 07/25/2016
Author : Mst Solutions
Description : Unit Test for TaskTrigger_AT and TaskTriggerHandler
*************************************************************************************/

@IsTest
public class TaskTrigger_Test {

	private final static Id volunteerTaskRT = Constant_AC.VOLUNTEER_TASK_RT_ID;
	private final static Id wishChildRecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
	private final static Id taskInterviewRecordType = Constant_AC.INTERVIEW_RT_ID;
	private final static Id volunteerRecordTypeId = Constant_AC.VOLUNTEER_RT_ID;

	//Used to create wishchild and parent case record
	@TestSetup static void setup() {
		Contact wishChild = OrientationandTrainingUtil.CreateWishChildCon();
		insert wishChild;
		Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		insert parentCase;
		Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
		insert chapterAccount;
		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
		insert volunteerContact;
	}

	//Wish Granting open task
	static testMethod void checkWishGrantTask() {
		Case parentCaseInfo = [
				SELECT Id
				FROM Case
				LIMIT 1
		];
		Contact wishChildInfo = [
				SELECT Id
				FROM Contact
				WHERE RecordTypeId = :wishChildRecordTypeId
				LIMIT 1
		];
		Task wishGrantingTask = new Task(Subject = 'Granting Task', Status = 'New', Task_Type__c = 'Wish Granting', RecordTypeId = volunteerTaskRT, WhoId = wishChildInfo.Id, WhatId = parentCaseInfo.Id);
		insert wishGrantingTask;
		System.assertEquals(parentCaseInfo.Id, wishGrantingTask.WhatId, 'Compare Parentcaseinfo with wishgranting task what id');
		Task updateToCloseStatus = new Task();
		updateToCloseStatus.Id = wishGrantingTask.Id;
		updateToCloseStatus.Status = 'Completed';
		update updateToCloseStatus;
		System.assertEquals('Completed', updateToCloseStatus.Status, 'Confirm Close task status is Completed');

	}

	//Wish Granting open task
	static testMethod void checkWishGrantTaskWithOpenTask() {
		Case parentCaseInfo = [
				SELECT Id
				FROM Case
				LIMIT 1
		];
		Contact wishChildInfo = [
				SELECT Id
				FROM Contact
				WHERE RecordTypeId = :wishChildRecordTypeId
				LIMIT 1
		];
		Task wishGrantingNewTask = new Task(Subject = 'Granting Open Task', Status = 'New', Task_Type__c = 'Wish Granting', RecordTypeId = volunteerTaskRT, WhoId = wishChildInfo.Id, WhatId = parentCaseInfo.Id);
		insert wishGrantingNewTask;
		System.assertEquals('Granting Open Task', wishGrantingNewTask.Subject, 'Confirm WishGrantingTask subject is Granting Open Task');
		Task wishGrantingTask = new Task(Subject = 'Granting Close Task', Status = 'New', Task_Type__c = 'Wish Granting', RecordTypeId = volunteerTaskRT, WhoId = wishChildInfo.Id, WhatId = parentCaseInfo.Id);
		insert wishGrantingTask;
		System.assertEquals(parentCaseInfo.Id, wishGrantingTask.WhatId, 'Compare Parentcaseinfo with wishgranting task what id');
		Task updateToCloseStatus = new Task(Id = wishGrantingTask.Id, Status = 'Completed');
		update updateToCloseStatus;
		System.assertEquals('Completed', updateToCloseStatus.Status, 'Confirm Close task status is Completed');
	}

	//Volunteer Followup Task
	static testMethod void checkFollowUpTask() {
		Case parentCaseInfo = [
				SELECT Id
				FROM Case
				LIMIT 1
		];
		Contact wishChildInfo = [
				SELECT Id
				FROM Contact
				WHERE RecordTypeId = :wishChildRecordTypeId
				LIMIT 1
		];
		Contact volunteerContact = [
				SELECT Id
				FROM Contact
				WHERE RecordTypeId = :volunteerRecordTypeId
				LIMIT 1
		];
		User currentVoulnteerUser;
		CaseTeamRole caseTeamRoleInfo = [
				SELECT Id, Name
				FROM CaseTeamRole
				WHERE Name = 'Wish Granter'
		];
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currentVoulnteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
			insert currentVoulnteerUser;
		}
		CaseTeamMember newCaseTeamMember = new CaseTeamMember (ParentId = parentCaseInfo.Id, TeamRoleId = caseTeamRoleInfo.Id, MemberId = currentVoulnteerUser.Id);
		insert newCaseTeamMember;
		Task volunteerFollowup = new Task(Subject = 'Volunteer wish follow-up activities not complete', Status = 'New', Task_Type__c = 'Wish Granting', RecordTypeId = volunteerTaskRT, WhoId = wishChildInfo.Id, WhatId = parentCaseInfo.Id, OwnerId = currentVoulnteerUser.Id);
		insert volunteerFollowup;
		Task updateToCloseStatus = new Task(Id = volunteerFollowup.Id, Status = 'Completed');
		update updateToCloseStatus;
	}

	//Volunteer Followup open task and BirthDayTask
	static testMethod void checkFollowUpOpenTaskANDBirthdayTask() {
		Case parentCaseInfo = [
				SELECT Id
				FROM Case
				LIMIT 1
		];
		Contact wishChildInfo = [
				SELECT Id
				FROM Contact
				WHERE RecordTypeId = :wishChildRecordTypeId
				LIMIT 1
		];
		Contact volunteerContact = [
				SELECT Id
				FROM Contact
				WHERE RecordTypeId = :volunteerRecordTypeId
				LIMIT 1
		];
		User currentVoulnteerUser;
		CaseTeamRole caseTeamRoleInfo = [
				SELECT Id, Name
				FROM CaseTeamRole
				WHERE Name = 'Wish Granter'
		];
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currentVoulnteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
			insert currentVoulnteerUser;
		}
		CaseTeamMember newCaseTeamMember = new CaseTeamMember (ParentId = parentCaseInfo.Id, TeamRoleId = caseTeamRoleInfo.Id, MemberId = currentVoulnteerUser.Id);
		insert newCaseTeamMember;
		Task wishChildBirthdayTask = new Task(Subject = 'Wish Child Birthday Reminder', Status = 'New', Task_Type__c = 'Wish Granting', RecordTypeId = volunteerTaskRT, WhoId = wishChildInfo.Id, WhatId = parentCaseInfo.Id, OwnerId = currentVoulnteerUser.Id);
		insert wishChildBirthdayTask;

		Task volunteerFollowup = new Task(Subject = 'Volunteer wish follow-up activities not complete', Status = 'New', Task_Type__c = 'Wish Granting', RecordTypeId = volunteerTaskRT, WhoId = wishChildInfo.Id, WhatId = parentCaseInfo.Id, OwnerId = currentVoulnteerUser.Id);
		insert volunteerFollowup;
		Task updateToCloseStatus = new Task(Id = volunteerFollowup.Id, Status = 'Completed');
		try {
			update updateToCloseStatus;
		} catch (Exception e) {
			System.debug('ERROR:' + e);
		}
	}

	//Referral DNQ Lead Task
	static testmethod void updateLeadCloseDate() {
		Account chapterAccount = [
				SELECT Id
				FROM Account
				LIMIT 1
		];
		Account americaChapter = OrientationandTrainingUtil.MakeAWishAmericaAcc();
		insert americaChapter;
		Lead newLead = OrientationandTrainingUtil.createTestLeadRec(chapterAccount.Id);
		insert newLead;
		Task referralDNQTask = new Task(Subject = 'Referral DNQ', Status = 'New', RecordTypeId = volunteerTaskRT, WhoId = newLead.Id);
		insert referralDNQTask;
		Task updateToCloseStatus = new Task(Id = referralDNQTask.Id, Status = 'Completed');
		update updateToCloseStatus;
	}

	//Affiliation Status Change
	static testmethod void updateAffiliationStatusAsDeclined() {
		Contact volunteerContact = [
				SELECT Id
				FROM Contact
				WHERE RecordTypeId = :volunteerRecordTypeId
				LIMIT 1
		];
		npe5__Affiliation__c neworgAffiliation = OrientationandTrainingUtil.CreateAffiliation(volunteerContact.Id);
		insert neworgAffiliation;
//		Task referralDNQTask = new Task(Subject = 'Background Check', Status = 'New', RecordTypeId = taskInterviewRecordType, WhoId = volunteerContact.Id);
//		insert referralDNQTask;
//		Task updateToCloseStatus = new Task(Id = referralDNQTask.Id, Status = 'Declined');
//		update updateToCloseStatus;
	}

	//Udate familcheckin date
	static testmethod void updateCheckinDate() {
		Case parentCaseInfo = [
				SELECT Id
				FROM Case
				LIMIT 1
		];
		Contact wishChildInfo = [
				SELECT Id
				FROM Contact
				WHERE RecordTypeId = :wishChildRecordTypeId
				LIMIT 1
		];
		Task checkInTask = new Task(Subject = 'Check in with the family every 30 days', Status = 'New', RecordTypeId = volunteerTaskRT, WhoId = wishChildInfo.Id, WhatId = parentCaseInfo.Id);
		insert checkInTask;
		System.assertEquals(parentCaseInfo.Id, checkInTask.WhatId, 'Compare Parentcaseinfo with CheckInTask task what id');
		Task updateToCloseStatus = new Task(Id = checkInTask.Id, Status = 'Completed');
		update updateToCloseStatus;
	}

	//Staff Review Task
	static testmethod void createUploadTaskForWishOwner() {
		Case parentCaseInfo = [
				SELECT Id
				FROM Case
				LIMIT 1
		];
		Contact wishChildInfo = [
				SELECT Id
				FROM Contact
				WHERE RecordTypeId = :wishChildRecordTypeId
				LIMIT 1
		];
		Task checkInTask = new Task(Subject = 'Review photos/videos', Status = 'New', RecordTypeId = volunteerTaskRT, WhoId = wishChildInfo.Id, WhatId = parentCaseInfo.Id);
		insert checkInTask;
		System.assertEquals(parentCaseInfo.Id, checkInTask.WhatId, 'Compare Parentcaseinfo with CheckInTask task what id');
		Task updateToCloseStatus = new Task(Id = checkInTask.Id, Status = 'Completed');
		update updateToCloseStatus;
	}
	//Used to create SneakPeek Task
	static testMethod void sneakPeekTask() {
		Case parentCaseInfo = [
				SELECT Id
				FROM Case
				LIMIT 1
		];
		Task sneakPeek = OrientationandTrainingUtil.createSneakPeek(parentCaseInfo.Id);
		insert sneakPeek;
		Task flightBookingTask = OrientationandTrainingUtil.createFightBookingTask(parentCaseInfo.Id);
		insert flightBookingTask;
		flightBookingTask.Status = 'Completed';
		update flightBookingTask;
		Task passportTask = OrientationandTrainingUtil.passportRequestTask(parentCaseInfo.Id);
		insert passportTask;
		Task budgetTask = OrientationandTrainingUtil.createBudgetTask(parentCaseInfo.Id);
		insert budgetTask;
		budgetTask.Status = 'Completed';
		update budgetTask;
	}

	//Used to create SneakPeek Activity Date null
	static testMethod void sneakPeekTaskActivityDateAsNull() {
		Case parentCaseInfo = [
				SELECT Id
				FROM Case
				LIMIT 1
		];
		Task sneakPeek = OrientationandTrainingUtil.createSneakPeek(parentCaseInfo.Id);
		insert sneakPeek;
		sneakPeek.ActivityDate = null;
		update sneakPeek;
		Task flightBookingTask = OrientationandTrainingUtil.createFightBookingTask(parentCaseInfo.Id);
		insert flightBookingTask;
		flightBookingTask.Status = 'Completed';
		update flightBookingTask;
		Task passportTask = OrientationandTrainingUtil.passportRequestTask(parentCaseInfo.Id);
		insert passportTask;
		passportTask.ActivityDate = null;
		update passportTask;
		Task budgetTask = OrientationandTrainingUtil.createBudgetTask(parentCaseInfo.Id);
		insert budgetTask;
		budgetTask.Status = 'Completed';
		update budgetTask;
	}

	//Passport Request Task
	static testMethod void passPortRequest() {
		Case parentCaseInfo = [
				SELECT Id
				FROM Case
				LIMIT 1
		];
		Task cruiseTask = new Task(Subject = 'Cruise request form', WhatId = parentCaseInfo.Id, ActivityDate = System.today());
		insert cruiseTask;
		Task passportTask = OrientationandTrainingUtil.passportRequestTask(parentCaseInfo.Id);
		insert passportTask;
		passportTask.Status = 'Completed';
		update passportTask;
	}

	//Cruise request form Task
	static testMethod void cruiseTaskActivityAsNull() {
		Case parentCaseInfo = [
				SELECT Id
				FROM Case
				LIMIT 1
		];
		Task cruiseTask = new Task(Subject = 'Cruise request form', WhatId = parentCaseInfo.Id);
		insert cruiseTask;
		Task passportTask = OrientationandTrainingUtil.passportRequestTask(parentCaseInfo.Id);
		insert passportTask;
		passportTask.Status = 'Completed';
		update passportTask;
	}

	//Affiliation Status as Approved
	static testmethod void updateAffiliationStatusAsApproved() {
		Account chapterAccount = [
				SELECT Id
				FROM Account
				LIMIT 1
		];
		Contact volunteerContact = [
				SELECT Id
				FROM Contact
				WHERE RecordTypeId = :volunteerRecordTypeId
				LIMIT 1
		];
		Role__c newRole = OrientationandTrainingUtil.createRole();
		insert newRole;
		Chapter_Role__c chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.Id, newRole.Id);
		insert chapterRole;
		chapterRole.Background_Check_Required__c = true;
		update chapterRole;
		Volunteer_Roles__c volunteerRole = OrientationandTrainingUtil.createVolRole(volunteerContact.Id, chapterRole.Id);
		insert volunteerRole;
		volunteerRole.Status__c = 'Prospective';
		update volunteerRole;
		npe5__Affiliation__c neworgAffiliation = OrientationandTrainingUtil.CreateAffiliation(volunteerContact.Id);
	}

	//Wish Presentation Date Entered
	static testmethod void wishPresentationDateEntered() {
		Case parentCaseInfo = [
				SELECT Id
				FROM Case
				LIMIT 1
		];
		Contact wishChildInfo = [
				SELECT Id
				FROM Contact
				WHERE RecordTypeId = :wishChildRecordTypeId
				LIMIT 1
		];
		Case WishGrantCase = OrientationandTrainingUtil.createWishGrantCase(wishChildInfo.Id, parentCaseInfo.Id);
		Task presentationDate = new Task(Subject = 'wish presentation date entered', Status = 'New', WhatId = WishGrantCase.Id);
		insert presentationDate;
		Task updateToCloseStatus = new Task(Id = presentationDate.Id, Status = 'Completed');
		try {
			update updateToCloseStatus;
		} catch (Exception e) {
			System.debug('ERROR:' + e);
		}
	}

	//Availability Time Check
	static testmethod void availabilityTimeCheck() {
		Case parentCaseInfo = [
				SELECT Id
				FROM Case
				LIMIT 1
		];
		Task availabilityTask = new Task(Confirmed_Date__c = null, Subject = 'Sample', Availability_Time_Other1__c = 'Test', Available_Time1__c = 'Other1', WhatId = parentCaseInfo.Id, Availability_Time_Other2__c = 'Test', Available_Time2__c = 'Other1', Availability_Time_Other3__c = 'Test', Available_Time3__c = 'Other1');
		insert availabilityTask;
		Task updateTask = new Task(Id = availabilityTask.Id, Confirmed_Date__c = Date.today());
		try {
			update updateTask;
		} catch (Exception e) {
			System.debug('ERROR:' + e);
		}
	}

	//Availability Time Check
	static testmethod void confirmedDateAsNull() {
		Case parentCaseInfo = [
				SELECT Id
				FROM Case
				LIMIT 1
		];
		Task availabilityTask = new Task(Confirmed_Date__c = Date.today(), Availability_Time_Other1__c = 'Test', Subject = 'Sample', Available_Time1__c = 'Other', WhatId = parentCaseInfo.Id, Availability_Time_Other2__c = 'Test', Available_Time2__c = 'Other', Availability_Time_Other3__c = 'Test', Available_Time3__c = 'Other');
		insert availabilityTask;
		Task updateTask = new Task(Id = availabilityTask.Id, Confirmed_Date__c = null, Confirmed_Time__c = '3:30');
		try {
			update updateTask;
		} catch (Exception e) {
			System.debug('ERROR:' + e);

		}
	}

	//Availability Time Check
	static testmethod void confirmedDateLesseThanToday() {
		Case parentCaseInfo = [
				SELECT Id
				FROM Case
				LIMIT 1
		];
		Task availabilityTask = new Task(Confirmed_Date__c = Date.today(), Availability_Time_Other1__c = 'Test', Subject = 'Sample', Available_Time1__c = 'Other', WhatId = parentCaseInfo.Id, Availability_Time_Other2__c = 'Test', Available_Time2__c = 'Other', Availability_Time_Other3__c = 'Test', Available_Time3__c = 'Other');
		insert availabilityTask;
		Task updateTask = new Task(Id = availabilityTask.Id, Confirmed_Date__c = Date.today().addDays(-3), Confirmed_Time__c = '3:30');
		try {
			update updateTask;
		} catch (Exception e) {
			System.debug('ERROR:' + e);

		}
	}

	//Wish Concept Approval
	static testMethod void wishConceptApproval() {
		Case parentCase = new Case(Subject = 'ParentCase', Origin = 'Web', Presentation_Date__c = Date.today());
		Task conceptTask = new Task(Subject = 'Wish concept approval', WhatId = parentCase.Id);
		insert conceptTask;
		Task closeTask = new Task(Id = conceptTask.Id);
		closeTask.Status = 'Completed';
		update closeTask;
	}

	//Wish presentation not set
	static testMethod void wishPresentationNotSet() {
		Case parentCase = new Case(Subject = 'ParentCase', Origin = 'Web', Presentation_Date__c = Date.today());
		Task conceptTask = new Task(Subject = 'Wish Presentation not set', WhatId = parentCase.Id);
		insert conceptTask;
		Task closeTask = new Task(Id = conceptTask.Id);
		closeTask.Status = 'Completed';
		update closeTask;
	}

	//Wish Concept Approval
	static testMethod void wishNotClosed() {
		Case parentCase = new Case(Subject = 'ParentCase', Origin = 'Web', Presentation_Date__c = Date.today());
		Task conceptTask = new Task(Subject = 'Wish not closed', WhatId = parentCase.Id);
		insert conceptTask;
		Task closeTask = new Task(Id = conceptTask.Id);
		closeTask.Status = 'Completed';
		update closeTask;
	}

	//Affiliation Status Change
	static testmethod void updateAffiliationStatus() {
		Contact volunteerContact = [
				SELECT Id
				FROM Contact
				WHERE RecordTypeId = :volunteerRecordTypeId
				LIMIT 1
		];
		npe5__Affiliation__c neworgAffiliation = OrientationandTrainingUtil.CreateAffiliation(volunteerContact.Id);
		insert neworgAffiliation;
	}

	/**
	* JIRA: WLP-286
	* Author: Gustavo Mayer
	* Update: This test classes references Child Cases which will no longer be used as the Cases 'Wish Determination, 'Wish Planning,
	* 'Wish Granting and 'Wish Impact are now converted to a single case Wish
	*/
	//Reparent Task
//    static testMethod void reparentTask() {
//        Id parentWishRecordTypeId = Constant_AC.PARENT_WISH_RT_ID;
//        Id wishGrantRecordTypeId = Constant_AC.PARENT_WISH_RT_ID;
//        Case parentCase = new Case(Subject = 'ParentCase', Origin = 'Web', Presentation_Date__c = Date.today(), RecordTypeId = parentWishRecordTypeId);
//        Case grantCase = new Case(Subject = 'ChildCase', Origin = 'Web', Presentation_Date__c = Date.today(), RecordTypeId = wishGrantRecordTypeId, parentId = parentCase.Id);
//        Task conceptTask = new Task(Subject = 'Case ET : Wish Presentation Details', WhatId = grantCase.Id, Status = 'Completed');
//        insert conceptTask;
//        Task birthDayTask = new Task(Subject = 'Case ET : Wish Presentation Date Reminder', WhatId = grantCase.Id, Status = 'Completed');
//        insert birthDayTask;
//    }

	//BG and COI Completed Task
	static testMethod void updateTaskSubject() {
		Account volunteerAccount = OrientationandTrainingUtil.createVolunteerAccount();
		insert volunteerAccount;
		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.id);
		insert volunteerContact;
		Background_check__c createBackCheck = OrientationandTrainingUtil.createBackgroundCheckFasleRec(volunteerContact.id);
		insert createBackCheck;
		createBackCheck.Current__c = true;
		createBackCheck.Date__c = Date.today().addDays(2);
		update createBackCheck;
		Conflict_Of_Interest__c createCOI = OrientationandTrainingUtil.createCOI(volunteerContact.id);
		insert createCOI;
		createCOI.Current__c = true;
		createCOI.Expiration_Date__c = Date.today().addDays(2);
		update createCOI;
		Task bgTask = new Task(Subject = 'BC ET : Background Check Expiring', WhatId = createBackCheck.Id);
		insert bgTask;
		Task coiTask = new Task(Subject = 'COI ET : COI Expiring', WhatId = createCOI.Id);
		insert coiTask;
	}

	/**
	 * WLP-434
	 * Deprecate Interview Fields on Contact
	 */
//	static testMethod void callUpdateInterviewTaskStatus() {
//		Set<Id> volunteerRoleBaseIdsSet = new Set<Id>();
//		Account volunteerAccount = OrientationandTrainingUtil.createVolunteerAccount();
//		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.id);
//		Role__c newRole = OrientationandTrainingUtil.createRole();
//		Chapter_Role__c chapterRole = OrientationandTrainingUtil.createChapter(volunteerAccount.Id, newRole.Id);
//		chapterRole.Background_Check_Required__c = true;
//		update chapterRole;
//		Volunteer_Roles__c volunteerRole = OrientationandTrainingUtil.createVolRole(volunteerContact.Id, chapterRole.Id);
//		Task interviewTask = new Task(Subject = 'Interview Task', WhoId = volunteerContact.Id, RecordTypeId = taskInterviewRecordType);
//		insert interviewTask;
//		interviewTask.Status = 'Approved';
//		update interviewTask;
//		volunteerRoleBaseIdsSet.add(volunteerContact.id);
//		Task_OnAfterInsertHelper.updateVolunteerInterviewDate(volunteerRoleBaseIdsSet, 'update');
//	}

	/**
	 * WLP-434
	 * Deprecate Interview Fields on Contact
	 */
//	static testMethod void callInsertInterviewTaskStatus() {
//		Set<Id> volunteerRoleBaseIdsSet = new Set<Id>();
//		Account volunteerAccount = OrientationandTrainingUtil.createVolunteerAccount();
//		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.id);
//		Task interviewTask = new Task(Subject = 'Interview Task', WhoId = volunteerContact.Id, RecordTypeId = taskInterviewRecordType);
//		insert interviewTask;
//		volunteerRoleBaseIdsSet.add(volunteerContact.id);
//		Task_OnAfterInsertHelper.updateVolunteerInterviewDate(volunteerRoleBaseIdsSet, 'insert');
//	}

//	static testMethod void changeTaskRelatedRecord() {
//		Set<Id> volunteerRoleBaseIdsSet = new Set<Id>();
//		Account volunteerAccount = OrientationandTrainingUtil.createVolunteerAccount();
//		insert volunteerAccount;
//		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.id);
//		insert volunteerContact;
//		Contact volCon = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.id);
//		insert volCon;
//		Task interviewTask = new Task(Subject = 'Interview Task', WhoId = volunteerContact.Id, RecordTypeId = taskInterviewRecordType);
//		insert interviewTask;
//		Task updateVolCon = new Task();
//		updateVolCon.Id = interviewTask.Id;
//		updateVolCon.WhoId = volCon.Id;
//		update updateVolCon;
//	}
}