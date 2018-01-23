/*****************************************************************************************
Created By  : MST
CreatedDate : 11/17/2017
Author : MST Solutions
Description : This schedule class used to run the batch_CreateBirthdayTask_AC class in particular time interval
*********************************************************************************************/
global class batch_CreateBirthdayTaskSchedule_AC implements Schedulable{
    global void execute(SchedulableContext SC){
        Database.executeBatch(new batch_CreateBirthdayTask_AC(),200);
    }
}