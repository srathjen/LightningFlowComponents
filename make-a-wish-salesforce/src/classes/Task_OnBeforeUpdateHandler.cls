/*****************************************************************************************************************
Author      : MST Solutions
Date        : 6/1/2016
Description : When new Task is updated  then Task_OnBeforeUpdateHandler is called by before update event in Task trigger
then it will assign the values to the corresponding fields and it will call the Task_OnBeforeUpdateHandleHelper class
based on the collection size().
*******************************************************************************************************************/
Public class Task_OnBeforeUpdateHandler{
    
    Static  Constant_AC  constant = new Constant_Ac();
    Static String wishGrantTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
    Static String backrgroundcheckTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.backgroundRT).getRecordTypeId();
    Static String contactUpdateTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.updateContactRT).getRecordTypeId();
    Static String  planningTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();
    Static String determinationTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
    Static String volunteerTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.volunteerTaskRT).getRecordTypeId();
    Static String chapterRT = Schema.SObjectType.Task.getRecordTypeInfosByName().get(constant.staffTaskRT).getRecordTypeId();
    Static String DefaultTask= Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.taskRT).getRecordTypeId();
    Static String interviewTask = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.interviewRT).getRecordTypeId();
    Static String wishEffectRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishEffectRT).getRecordTypeId();
    Static String diagnosisVerificationRT = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.diagnosisRT).getRecordTypeId();
    Static String wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();     
    Static String wishPlanningRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishPlanningAnticipationRT).getRecordTypeId();    
    Static String wishAssistRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishAssistRT).getRecordTypeId();
    Static String wishGrantRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
    Static String parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
    
    /**********************************************************************************************************************
    This method will assign the values to the corresponding fields and it will call the Task_OnBeforeUpdateHandleHelper class
based on the collection size().
*****************************************************************************************************************************/
    public static void OnBeforeUpdate(Map<Id,Task> newTaskMap,Map<Id,Task> oldTaskMap){
        List<Task> validateTaskList = new List<Task>();
        set<ID> contactIdset = new set<ID>();
        List<Task> updateTaskList = new List<Task>();
        Map<Id,id> caseInfoMap=new Map<Id,id>();
        for(Task newTask : newTaskMap.values()){
            string id = newTask.WhoId;
            if(newTask.RecordTypeId == wishGrantTaskRT || newTask.RecordTypeId == planningTaskRT || newTask.RecordTypeId == determinationTaskRT || newTask.RecordTypeId == volunteerTaskRT || newTask.RecordTypeId == chapterRT || newTask.RecordTypeId == backrgroundcheckTaskRT 
               || newTask.RecordTypeId == contactUpdateTaskRT || newTask.RecordTypeId == DefaultTask || newTask.RecordTypeId == interviewTask){ 
                   if(newTask.Confirmed_Date__c != Null && oldTaskMap.get(newTask.id).Confirmed_Date__c  == Null)
                       newTask.Status = 'Scheduled';
                   if(newTask.Confirmed_Date__c != Null && newTask.Confirmed_Time__c == Null) 
                       newTask.addError('Please Enter Confirmed Time');
                   if(newTask.Confirmed_Date__c == Null && newTask.Confirmed_Time__c != Null) 
                       newTask.addError('Please Enter Confirmed Date');
                   if(newTask.Confirmed_Date__c != Null && newTask.Confirmed_Date__c < Date.Today() && newTask.Confirmed_Date__c != oldTaskMap.get(newTask.id).Confirmed_Date__c)
                       newTask.addError('Confirm Date should be greater than Today');
                   if(newTask.Confirmed_Date__c != Null && newTask.venue__c == Null)
                       newTask.addError('Please Enter Venue');
                   if(newTask.Availability_Time_Other1__c != Null && newTask.Available_Time1__c != 'Other')
                   {
                       newTask.Availability_Time_Other1__c = '';
                   }
				   if(newTask.Subject.contains(' ET : ') && newTask.status == 'Completed' && (newTask.SystemGeneratedTask__c == FALSE || newTask.ActivityDate != NULL)){
                       newTask.SystemGeneratedTask__c = True;
                       newTask.ActivityDate = null;
                   }
                   if(newTask.Availability_Time_Other2__c != Null && newTask.Available_Time2__c != 'Other')
                   {
                       newTask.Availability_Time_Other2__c = '';
                   }
                   if(newTask.Availability_Time_Other3__c != Null && newTask.Available_Time3__c != 'Other')
                   {
                       newTask.Availability_Time_Other3__c = '';
                   }
                   if(newTask.status=='Completed' && oldTaskMap.get(newTask.Id).Status != newTask.Status) {
                       validateTaskList.add(newTask);
                   }
                   if(newTask.WhoId != null && id.startsWith('003') && oldTaskMap.get(newTask.Id).WhoId != newTask.WhoId){
                       contactIdset.add(newTask.WhoId);
                       updateTaskList.add(newTask);
                   }
                   /********** Closure Rules *********/
                   if(newTask.status=='Completed' && oldTaskMap.get(newTask.Id).Status != newTask.Status && newTask.subject=='wish presentation date entered'){
                       caseInfoMap.put(newTask.id,newTask.whatid);
                   }
               }  
        }
        if(validateTaskList.size() > 0) {
            Task_OnBeforeUpdateHelper.colseTaskValidation(validateTaskList);
        }
        if((contactIdset.size()>0) && (updateTaskList.size()>0)){
            Task_OnBeforeUpdateHelper.updateTaskEmailMergeFields(contactIdset,updateTaskList);
        }
    }
    
}