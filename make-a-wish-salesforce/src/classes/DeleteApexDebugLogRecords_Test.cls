/*
* Description: This class will cover the unit testinf for the DeleteApexDebugLogRecords_AC. 
* 
* Created By: MST Solutions.
* 
* Created Date: Dec 28, 2017
* 
*/
@isTest
public class DeleteApexDebugLogRecords_Test{
    public static testMethod void executeBatchMethodOne(){
        ApexDebugLogSetting__c apexDebugCusSetting=TestDataUtility_AC.createApexDebugCussettingWithoutNull();
        insert apexDebugCusSetting;
        Apex_Debug_Log__c apexDebugLog1= TestDataUtility_AC.createApexDebug();
        insert apexDebugLog1;
        Test.setCreatedDate(apexDebugLog1.Id, DateTime.newInstance(2017,12,26));
        Apex_Debug_Log__c apexDebugLog2= TestDataUtility_AC.createApexDebug();
        insert apexDebugLog2;
        Test.setCreatedDate(apexDebugLog2.Id, DateTime.newInstance(2017,12,26));
        test.startTest();
        DeleteApexDebugLogRecords_AC obj=new DeleteApexDebugLogRecords_AC();
        Database.executeBatch(obj, 200);
        test.stopTest();
    }
    public static testMethod void executeBatchMethodTwo(){
        ApexDebugLogSetting__c apexDebugCusSetting=TestDataUtility_AC.createApexDebugCussettingWithNull();
        insert apexDebugCusSetting;
        Apex_Debug_Log__c apexDebugLog1= TestDataUtility_AC.createApexDebug();
        insert apexDebugLog1;
        Test.setCreatedDate(apexDebugLog1.Id, DateTime.newInstance(2017,12,26));
        Apex_Debug_Log__c apexDebugLog2= TestDataUtility_AC.createApexDebug();
        insert apexDebugLog2;
        Test.setCreatedDate(apexDebugLog2.Id, DateTime.newInstance(2017,12,26));
        test.startTest();
        DeleteApexDebugLogRecords_AC obj=new DeleteApexDebugLogRecords_AC();
        Database.executeBatch(obj, 200);
        test.stopTest();
    }
}