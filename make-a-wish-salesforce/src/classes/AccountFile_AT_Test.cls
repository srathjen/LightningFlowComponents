/*****************************************************************************************************************
Author      : MST Solutions
Date        : 10/26/2016
Description : This class contains test method for Account object
*******************************************************************************************************************/
@isTest
public class AccountFile_AT_Test {
    static testmethod void createAccountFile() {
        test.startTest();
        Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
        cg__AccountFile__c accountFile = OrientationandTrainingUtil.createAccountFileRecord(chapterAccount.Id);
        System.assertEquals(chapterAccount.id, accountFile.cg__Account__c, 'Id dose not match');
        System.assert(chapterAccount.id == accountFile.cg__Account__c, 'The value of chapterAccount.id is: ' +chapterAccount.id + ' and the value of accountFile.cg__Account__c is: ' + accountFile.cg__Account__c);
        test.stopTest();
    }
}