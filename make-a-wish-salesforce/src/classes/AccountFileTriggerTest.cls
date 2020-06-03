/**
 * @description AccountFile Service Test
 * @author Michelle Cominotto, Make-A-Wish
 * @date 3/17/2020
 */
@IsTest
public class AccountFileTriggerTest {

    @TestSetup
    private static void setUp() {
        trac_TriggerHandlerBase.blockTrigger = true;

        List<Account> accountList = TestDataFactory.createAccount(1);
        Account account = accountList.get(0);
        account.Name = 'Make-A-Wish Arizona';
        account.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
        insert accountList;

        trac_TriggerHandlerBase.blockTrigger = false;
    }

    @IsTest
    private static void testUpdate() {
        Account chapterAccount = [
                SELECT Id
                FROM Account
        ];

        Test.startTest();
        List<cg__AccountFile__c> accountFileList = TestDataFactory.createAccountFile(1);
        cg__AccountFile__c accountFile = accountFileList.get(0);
        accountFile.cg__Account__c = chapterAccount.Id;
        accountFile.cg__File_Name__c = 'MAW-Arizona.txt';
        accountFile.File_Path__c = '';
        insert accountFileList;

        accountFile.cg__File_Name__c = 'MAW-Arizona.pdf';
        update accountFileList;
        Test.stopTest();
    }
}