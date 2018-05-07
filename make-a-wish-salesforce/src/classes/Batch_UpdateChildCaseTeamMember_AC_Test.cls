/*Contains unit test for Batch_UpdateChildCaseOwner_AC class */
@isTest
public class Batch_UpdateChildCaseTeamMember_AC_Test {
    Static testmethod void createCase() {
        Constant_AC  constant = new Constant_Ac();    
        Id wishDeterminationRT = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
        Case parentCase = OrientationandTrainingUtil.CreateParentCaseWithStatus();
        parentCase.Start_Date__c = System.today();
        parentCase.Status = 'Qualified';
        insert parentCase;
        Case childCase = OrientationandTrainingUtil.CreateParentCaseWithStatus();
        childCase.RecordTypeId = wishDeterminationRT;
        childCase.ParentId = parentCase.Id;
        insert childCase;
        System.assertEquals(childCase.RecordTypeId,  wishDeterminationRT, 'The record type does not match');
        System.assert(childCase.RecordTypeId ==  wishDeterminationRT, 'The record type does not match');
        Test.startTest();
        Batch_UpdateChildWishCaseTeamMember_AC executeCls = new Batch_UpdateChildWishCaseTeamMember_AC();
        Database.executeBatch(executeCls);
        Test.stopTest();
    }
}