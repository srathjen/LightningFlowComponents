/***************************************************************************
Author : MST Solutions
Created Date : 3/15/2018
Description : This class is used to schedule batch_sendAgeNotificationToCaseOwner_AC class
****************************************************************************/
global class batch_sendAgeNotificationSchedule_AC implements Schedulable{
    global void execute(SchedulableContext SC){
        Database.executeBatch(new batch_sendAgeNotificationToCaseOwner_AC(),200);
    }
}