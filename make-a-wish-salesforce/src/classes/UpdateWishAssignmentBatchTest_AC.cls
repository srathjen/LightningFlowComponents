/*****************************************************************************
Author : MST Solutions
CreateDate : 05/5/2017
Description : This test class used for unit test and code coverage
Modification Log: 
28/03/2018 - Kanagaraj
******************************************************************************/

/**
 * WLP-322
 * Class being tested is commented out, commenting the test class as well as its useless
 */
@IsTest
public class UpdateWishAssignmentBatchTest_AC {
	// This test class used to create volunteer opportunity
//	static testMethod void createVolunteerOpportunity() {
//		String CRON_EXP = '0 0 1 * * ? *';
//		Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
//		insert chapterAccount;
//		chapterAccount.Alert_for_Unassigned_Wishes__c = 0;
//		update chapterAccount;
//		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
//		insert wishChild;
//		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
//		insert volunteerContact;
//		Case parentCase = OrientationandTrainingUtil.ParentCasetoAddCaseMember(wishChild.Id);
//		insert parentCase;
//		parentCase.ChapterName__c = chapterAccount.Id;
//		update parentCase;
//		Role__c roleName = OrientationandTrainingUtil.createRole();
//		insert roleName;
//		Role__c newRole = new Role__c();
//		newRole.Name = 'Wish Granter';
//		newRole.isWishRole__c = true;
//		insert newRole;
//		Chapter_Role__c chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.Id, newRole.Id);
//		insert chapterRole;
//		Non_Wish_Events__c nonWishEvent = OrientationandTrainingUtil.CreateEventRec(chapterRole.Id, chapterAccount.Id);
//		insert nonWishEvent;
//		nonWishEvent.Event_Date__c = Date.today().addDays(-5);
//		update nonWishEvent;
//		Id wishVolunteerOpportunityRecordTypeId = Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID;
//		Volunteer_Opportunity__c newOpp = new Volunteer_Opportunity__c();
//		newOpp.Volunteer_Name__c = volunteerContact.Id;
//		newOpp.Non_Wish_Event__c = nonWishEvent.Id;
//		newOpp.Chapter_Role_Opportunity__c = chapterRole.Id;
//		newOpp.Wish__c = parentCase.Id;
//		newOpp.RecordTypeId = wishVolunteerOpportunityRecordTypeId;
//		insert newOpp;
//
//		Test.startTest();
//		String jobId = System.schedule('lastWishAssignment', CRON_EXP, new UpdateWishAssignmentBatchSchedule_AC());
//		CronTrigger ct = [
//				SELECT Id, CronExpression, TimesTriggered, NextFireTime
//				FROM CronTrigger
//				WHERE Id = :jobId
//				LIMIT 50000
//		];
//		System.assertEquals(CRON_EXP,
//				ct.CronExpression, 'Compare Cron Expression');
//		System.assertEquals(0, ct.TimesTriggered, 'Compare Time Trigger');
//		Test.stopTest();
//	}
}