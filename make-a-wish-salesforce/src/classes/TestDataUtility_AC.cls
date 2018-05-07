/*
* Description: Helper class for the test classes. 
* 
* Created By: MST Solutions.
* 
* Created Date: Dec 28, 2017
* 
*/
public class TestDataUtility_AC{
    public static Apex_Debug_Log__c createApexDebug(){
        Apex_Debug_Log__c apexDebugLog=new Apex_Debug_Log__c();
        apexDebugLog.Apex_Class__c='Developer Console';
        apexDebugLog.Message__c='Test Message';
        apexDebugLog.Stack_Trace__c='Anonymous Block';
        apexDebugLog.Type__c='Error';
        return apexDebugLog;
    }
    public static ApexDebugLogSetting__c createApexDebugCussettingWithoutNull(){
        ApexDebugLogSetting__c cusSet=new ApexDebugLogSetting__c();
        cusSet.Name='TestRecord';
        cusSet.Number_of_records_needs_to_preserve__c=1;
        cusSet.Interval_to_clear_the_debug_log__c=1;
        return cusSet;
    }
    public static ApexDebugLogSetting__c createApexDebugCussettingWithNull(){
        ApexDebugLogSetting__c cusSet=new ApexDebugLogSetting__c();
        cusSet.Name='TestRecord';
        cusSet.Number_of_records_needs_to_preserve__c=NULL;
        cusSet.Interval_to_clear_the_debug_log__c=1;
        return cusSet;
    }
}