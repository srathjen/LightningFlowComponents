/*****************************************************************************************************************
Author      : MST Solutions
Date        : 6/1/2016
Description : When new Task is inserted then this Task_OnAfterInsertHandler is called by before event in task trigger
then it will call the updateVolunteerInterviewDate method in Task_OnAfterInsertHelper based on Task subject.
*******************************************************************************************************************/
Public class Task_OnAfterInsertHandler{
    
    Static Constant_AC  constant = new Constant_Ac();
    Static String interviewTaskRTId = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.interviewRT).getRecordTypeId();
    public static void OnAfterInsert(List<Task> newTaskList){
        Set<Id> volunteerIdsSet = new Set<Id>();
        for(Task newTask : newTaskList){
            if(newTask.Subject == 'Interview Task' && newTask.WhoId != Null && newTask.RecordTypeId == interviewTaskRTId ){
                volunteerIdsSet.add(newTask.WhoId);
            }
        }
        if(volunteerIdsSet.size() > 0){
            Task_OnAfterInsertHelper.updateVolunteerInterviewDate(volunteerIdsSet,'insert');
        }
    }     
 }