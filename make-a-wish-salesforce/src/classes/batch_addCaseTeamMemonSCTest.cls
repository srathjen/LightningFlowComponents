/*********************************************************
Test class for batch_CaseTeamMemberUpdate
********************************************************/

@IsTest
public class batch_addCaseTeamMemonSCTest {

	static testMethod void CreateRecords() {
		Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithStatus();
		parentCase.ContactId = wishChild.Id;
		parentCase.AccountId = chapterAccount.Id;
		parentCase.Start_Date__c = System.today();
		parentCase.Status = 'Qualified';
		parentCase.Migrated_Record__c = true;
		insert parentCase;

		Id wishRecordTypeId = Constant_AC.WISH_RT_ID;
		Case newPlanningtWish = new Case();
		newPlanningtWish.RecordTypeId = wishRecordTypeId;
		newPlanningtWish.ChapterName__c = chapterAccount.Id;
		newPlanningtWish.Subject = 'Wish Planning & Anticipation';
		newPlanningtWish.ParentId = parentCase.Id;
		newPlanningtWish.ContactId = wishChild.Id;
		newPlanningtWish.Migrated_Record__c = true;
		insert newPlanningtWish;

		System.assertEquals(parentCase.Id, newPlanningtWish.ParentId);
		CaseTeamRole wishGranter = [
				SELECT Id
				FROM CaseTeamRole
				WHERE Name = 'Wish Granter'
				LIMIT 1
		];
		User currUser = [
				SELECT Id
				FROM User
				WHERE IsActive = TRUE
				LIMIT 1
		];
		CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.Id, currUser.Id, wishGranter.Id);

		Test.startTest();
		Database.executeBatch(new batch_addCaseTeamMemonSC());
		Test.stopTest();
	}
}