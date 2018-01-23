/***************************************************************************
Author : MST Solutions
Created Date : 11/16/2017
Description : This class is used to schedule batch_COIExpReminder_AC class
****************************************************************************/
global class batch_COIExpReminderSchedule_AC implements Schedulable{
    global void execute(SchedulableContext SC){
        Database.executeBatch(new batch_COIExpReminder_AC(),200);
    }
}