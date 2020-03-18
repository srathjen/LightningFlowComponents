/*****************************************************************************************************************
Author      : MST Solutions
Date        : 10/26/2016
Description : This class contains test method for Account object
*******************************************************************************************************************/
@IsTest
public class AccountFile_AT_Test {
	@IsTest
	static void createAccountFile() {
		Test.startTest();
		Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
		insert chapterAccount;

		cg__AccountFile__c accountFile = OrientationandTrainingUtil.createAccountFileRecord(chapterAccount.Id);
		insert accountFile;

		System.assertEquals(chapterAccount.Id, accountFile.cg__Account__c, 'Id dose not match');
		System.assert(chapterAccount.Id == accountFile.cg__Account__c, 'The value of chapterAccount.Id is: ' + chapterAccount.Id + ' and the value of accountFile.cg__Account__c is: ' + accountFile.cg__Account__c);
		Test.stopTest();
	}
}