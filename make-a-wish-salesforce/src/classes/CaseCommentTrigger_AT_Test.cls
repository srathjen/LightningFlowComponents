@IsTest
public class CaseCommentTrigger_AT_Test {

    @IsTest
	public static void createCaseComment() {
		Test.startTest();
        Case wish = new Case();
        wish.Status = Constant_AC.CASE_STATUS_NEW;
        wish.Origin = 'Email';
        wish.MAC_Email__c = 'Test@gmail.com';
        wish.RecordTypeId = Constant_AC.WISH_RT_ID;
        insert wish;

		CaseComment caseComment = new CaseComment();
		caseComment.ParentId = wish.Id;
		caseComment.CommentBody = 'Test comment';
		insert caseComment;
		Test.stopTest();
	}
}