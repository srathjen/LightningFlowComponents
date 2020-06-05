/**
 * @description AccountFile Service Test
 * @author Michelle Cominotto, Make-A-Wish
 * @date 3/17/2020
 */
@IsTest
public class AccountFileServiceTest {

    private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;

    @TestSetup
    private static void setUp() {
        trac_TriggerHandlerBase.blockTrigger = true;

        List<Account> accountList = TestDataFactory.createAccount(1);
        Account account = accountList.get(0);
        account.Name = 'Make-A-Wish Arizona';
        account.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
        insert accountList;

        trac_TriggerHandlerBase.blockTrigger = false;
    }

    @IsTest
    private static void validateUpdateAccountFilePath() {
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
        Test.stopTest();

        accountFileList = [
                SELECT Id, cg__File_Name__c, File_Path__c, cg__Content_Type__c
                FROM cg__AccountFile__c
                WHERE cg__File_Name__c = 'MAW-Arizona.txt'
        ];
        System.assert(accountFileList[0].File_Path__c != null);
    }
}