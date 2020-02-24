/*Contains unit test for Batch_UpdateChildCaseOwner_AC class */

@IsTest
public class Batch_UpdateChildCaseTeamMember_AC_Test {
    static testMethod void createCase() {
        Id wishRecordTypeId = Constant_AC.WISH_RT_ID;
        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithStatus();
        parentCase.Start_Date__c = System.today();
        parentCase.Status = 'Qualified';
        insert parentCase;
        Case childCase = OrientationandTrainingUtil.CreateParentCaseWithStatus();
        childCase.RecordTypeId = wishRecordTypeId;
        childCase.ParentId = parentCase.Id;
        insert childCase;
        System.assertEquals(childCase.RecordTypeId, wishRecordTypeId, 'The record type does not match');
        System.assert(childCase.RecordTypeId == wishRecordTypeId, 'The record type does not match');
        Test.startTest();
        Batch_UpdateChildWishCaseTeamMember_AC executeCls = new Batch_UpdateChildWishCaseTeamMember_AC();
        Database.executeBatch(executeCls);
        Test.stopTest();
    }
}