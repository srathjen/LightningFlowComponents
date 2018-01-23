/***************************************************************************
Author : MST Solutions
Created Date : 11/13/2017
Description : This class is used to schedule batch_BGCExpReminder_AC class
****************************************************************************/
global class batch_BGCExpReminderSchedule_AC implements Schedulable{
    global void execute(SchedulableContext SC){
        Database.executeBatch(new batch_BGCExpReminder_AC(),200);
    }
}