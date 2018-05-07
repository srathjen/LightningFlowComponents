@istest
public class DeleteApexDebugLogRecordScheduleTest_AC {    
   static testmethod void schedulerTest(){
        String CRON_EXP = '0 0 0 15 3 ? *';  
        Test.startTest();
        String jobId = System.schedule('DeleteApexDebugLogRecordSchedule_AC',  CRON_EXP, new DeleteApexDebugLogRecordSchedule_AC());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();       
    }
}