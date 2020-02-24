/*Contains unit test for Batch_UpdateChildCaseOwner_AC class */

@IsTest
public class Batch_UpdateChildCaseOwner_AC_Test {
	static testMethod void createCase() {
		Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithStatus();
		parentCase.Start_Date__c = System.today();
		parentCase.Status = 'Qualified'; 
		insert parentCase;
		Case childCase = OrientationandTrainingUtil.CreateParentCaseWithStatus();
		childCase.RecordTypeId = Constant_AC.WISH_RT_ID;
		childCase.ParentId = parentCase.Id;
		insert childCase;
		System.assertEquals(parentCase.Status, 'Qualified', 'The value does not match');
		System.assert(parentCase.Status == 'Qualified', 'The value does not match');
		Test.startTest();
		Batch_UpdateChildCaseOwner_AC executeCls = new Batch_UpdateChildCaseOwner_AC();
		Database.executeBatch(executeCls);
		Test.stopTest();
	}
}