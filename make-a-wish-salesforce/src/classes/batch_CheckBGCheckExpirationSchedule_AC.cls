/*****************************************************************************************
Created By  : MST
CreatedDate : 10/12/2017
Author : MST Solutions
Description : This schedule class used to run the batch_CheckBGCheckExpiration_AC class in particular time interval
*********************************************************************************************/
global class batch_CheckBGCheckExpirationSchedule_AC implements Schedulable{
    global void execute(SchedulableContext SC){
        Database.executeBatch(new batch_CheckBackGroundCheckExpiration_AC(),200);
    }
}