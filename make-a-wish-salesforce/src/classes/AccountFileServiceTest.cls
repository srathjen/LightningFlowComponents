/**
 * @description AccountFile Service Test
 * @author Michelle Cominotto, Make-A-Wish
 * @createdDate 3/17/2020
 */
@isTest
public class AccountFileServiceTest {
    
    private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;
    
    @TestSetup
    public static void setUp() {
        trac_TriggerHandlerBase.blockTrigger = true;
        List<Account> accountList =  TestDataFactory.createAccount(1);
        Account account = accountList.get(0);
        account.Name = 'Make-A-Wish Arizona';
        account.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
        insert accountList;
        
        List<cg__accountFile__c> accountFileList = TestDataFactory.createAccountFile(1);
        cg__accountFile__c accountFile = accountFileList.get(0);
        accountFile.cg__Account__c = accountList.get(0).Id;
        accountFile.cg__File_Name__c = 'MAW-Arizona.txt';
        insert accountFileList;
        trac_TriggerHandlerBase.blockTrigger = false;
    }
    
    @isTest
    private static void validateUpdateAccountFilePath() {
        List<cg__accountFile__c> accountFileList = [SELECT Id, cg__File_Name__c, File_Path__c 
                                                    FROM cg__accountFile__c];
        System.assert(accountFileList[0].File_Path__c == null);
        Test.startTest();
        AccountFileService.updateAccountFilePath(accountFileList);
        System.assert(accountFileList[0].File_Path__c != null);
        Test.stopTest();
    }
}