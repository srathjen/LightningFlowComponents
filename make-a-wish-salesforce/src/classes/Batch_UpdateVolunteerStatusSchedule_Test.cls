/*************************************************************************************************************************************************
Created by: Pavithra
Author : MST Solutions
CreateDate : 10/05/2016
Description :Batch_UpdateVolunteerStatusSchedule_Test is used to increase the code coverage for Batch_UpdateVolunteerStatusSchedule_AC class
*************************************************************************************************************************************************

/*Batch_UpdateVolunteerStatusSchedule_Test is used to increase the code coverage for
Batch_UpdateVolunteerStatusSchedule_AC class.*/
@istest
public class Batch_UpdateVolunteerStatusSchedule_Test{
    static testmethod void scheduleStatusUpdate() {
        Test.startTest();
        
        String CRON_EXP = '0 0 0/12 1/1 * ? *';
        String jobId = System.schedule('Volunteer Status', CRON_EXP, new Batch_UpdateVolunteerStatusSchedule_AC() );   
        Test.stopTest();
        
        CronTrigger contr = [SELECT Id,CronJobDetail.Name,CronJobDetail.Id,State FROM CronTrigger where CronJobDetail.Name =: 'Volunteer Status'];
        system.assertEquals(contr.CronJobDetail.Name,'Volunteer Status','Job name does not match');
        system.assert(contr.Id==jobId,'Job id does not match');
    }

}