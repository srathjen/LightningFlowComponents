/*
 * Description: This Apex Class will cover the unit testing for the ApexDebugLog class . 
 * 
 * Created By: MST Solutions.
 * 
 * Created Date: Dec 15, 2017
 * 
*/
@isTest
public class ApexDebugLog_Test{
    testMethod
    static void createErrorLog(){
        try{
            Integer result = 1 / 0;
        }
        catch(Exception ex){
            new ApexDebugLog().createLog(
                new ApexDebugLog.Error('ApexDebugLog_Test','createErrorLog',NULL,ex,'Custom Message'));

            List<Apex_Debug_Log__c> lstLogsCreated = [
                SELECT  Id, Type__c, Apex_Class__c, Method__c
                FROM    Apex_Debug_Log__c
                WHERE   Method__c = 'createErrorLog' LIMIT 1
            ];

            System.assertEquals(1, lstLogsCreated.size(), 'There is an issue with record creation');
            System.assertEquals('Error', lstLogsCreated.get(0).Type__c, 'Error type doesnot Match');
           // System.assertEquals('ApexDebugLog_Test', lstLogsCreated.get(0).Apex_Class__c);
        }
    }

    testMethod
    static void createInformationLog(){
        new ApexDebugLog().createLog(
            new ApexDebugLog.Information('ApexDebugLog_Test','createInformationLog',NULL,'Logging Information from an Apex Class - ApexDebugLog_Test','Custom Message'));

        List<Apex_Debug_Log__c> lstLogsCreated = [
            SELECT  Id, Type__c, Apex_Class__c, Method__c, Message__c
            FROM    Apex_Debug_Log__c
            WHERE   Method__c = 'createInformationLog' LIMIT 1
        ];

        System.assertEquals(1, lstLogsCreated.size(), 'There is an issue with record creation');
        System.assertEquals('Information', lstLogsCreated.get(0).Type__c, 'Error type doesnot Match');
        System.assertEquals('ApexDebugLog_Test', lstLogsCreated.get(0).Apex_Class__c, 'Apex class name doesnot match');
        System.assertEquals('Logging Information from an Apex Class - ApexDebugLog_Test', lstLogsCreated.get(0).Message__c,'Apex Message doesnot match');
    }

    testMethod
    static void ws_createErrorLog(){
        try{
            Integer result = 1 / 0;
        }
        catch(Exception ex){
            ApexDebugLog.createLog(
                '{"Type" : "Error","ApexClass" : "ApexDebugLog_Test","Method" : "createErrorLog","RecordId" : "","Message" : "System.MathException: Divide by 0","StackTrace" : "Line: 1, Column: 1 System.MathException: Divide by 0","DeveloperMessage" : "Custom Message"}'
            );

            List<Apex_Debug_Log__c> lstLogsCreated = [
                SELECT  Id, Type__c, Apex_Class__c, Method__c
                FROM    Apex_Debug_Log__c
                WHERE   Method__c = 'createErrorLog' LIMIT 1
            ];

            System.assertEquals(1, lstLogsCreated.size(), 'There is an issue with record creation');
            System.assertEquals('Error', lstLogsCreated.get(0).Type__c, 'Error type doesnot Match');
            System.assertEquals('ApexDebugLog_Test', lstLogsCreated.get(0).Apex_Class__c, 'Apex class name doesnot match');
        }
    }

    testMethod
    static void ws_createInformationLog(){
        ApexDebugLog.createLog(
            '{"Type" : "Information","ApexClass" : "ApexDebugLog_Test","Method" : "createInformationLog","RecordId" : "","Message" : "Logging Information from an Apex Class - ApexDebugLog_Test","DeveloperMessage" : "Custom Message"}'
        );

        List<Apex_Debug_Log__c> lstLogsCreated = [
            SELECT  Id, Type__c, Apex_Class__c, Method__c, Message__c
            FROM    Apex_Debug_Log__c
            WHERE   Method__c = 'createInformationLog' LIMIT 1
        ];

        System.assertEquals(1, lstLogsCreated.size(), 'There is an issue with record creation');
        System.assertEquals('Information', lstLogsCreated.get(0).Type__c, 'Error type doesnot Match');
        System.assertEquals('ApexDebugLog_Test', lstLogsCreated.get(0).Apex_Class__c, 'Apex class name doesnot match');
        System.assertEquals('Logging Information from an Apex Class - ApexDebugLog_Test', lstLogsCreated.get(0).Message__c,'Apex Message doesnot match');
    }
}