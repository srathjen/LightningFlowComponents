/*****************************************************************************************
Created By  : MST
CreatedDate : 10/12/2017
Author : MST Solutions
Description : This schedule class used to run the batch_CheckCOIExpiration_AC class in particular time interval
*********************************************************************************************/
global class batch_CheckCOIExpirationSchedule_AC implements Schedulable{
    global void execute(SchedulableContext SC){
        Database.executeBatch(new batch_CheckCOIExpiration_AC(),200);
    }
}