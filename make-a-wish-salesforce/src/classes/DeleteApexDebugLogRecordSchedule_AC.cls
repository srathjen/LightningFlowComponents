/*
* Description: This schedule class used to execute the Batch class on time. 
* 
* Created By: MST Solutions.
* 
* Created Date: Dec 28, 2017
* 
*/
global class DeleteApexDebugLogRecordSchedule_AC implements Schedulable{  
    global void execute(SchedulableContext ctx) {
        DeleteApexDebugLogRecords_AC batchJob = new DeleteApexDebugLogRecords_AC(); 
        database.executebatch(batchJob);
    }
}