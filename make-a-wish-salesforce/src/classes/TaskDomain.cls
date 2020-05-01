/**
 * @description     Domain class for the Task object
 *
 * @author          Chris Shinnimin, Traction on Demand
 * @date            2020-04-22
 */
public with sharing class TaskDomain extends trac_TriggerHandlerBase {
    List<Task> newTasksList = (List<Task>) newRecordsList;
    List<Task> oldTasksList = (List<Task>) oldRecordsList;
    Map<Id,Task> newTasksMap = (Map<Id,Task>) newRecordsMap;
    Map<Id,Task> oldTasksMap = (Map<Id,Task>) oldRecordsMap;

    private static final Set<Id> BEFORE_INSERT_RECORD_TYPE_IDS = new Set<Id>{
        Constant_AC.GRANT_TASK_RT_ID, Constant_AC.PLANNING_ANTICIPATION_TASK_RT_ID,
        Constant_AC.DETERMINATION_TASK_RT_ID, Constant_AC.VOLUNTEER_TASK_RT_ID,
        Constant_AC.STAFF_TASK_RT_ID, Constant_AC.BACKGROUND_RT_ID,
        Constant_AC.UPDATE_CONTACT_RT_ID, Constant_AC.TASK_RT_ID,
        Constant_AC.INTERVIEW_RT_ID
    };

    private static final Set<Id> BEFORE_UPDATE_RECORD_TYPE_IDS = new Set<Id>{
        Constant_AC.GRANT_TASK_RT_ID, Constant_AC.BACKGROUND_RT_ID,
        Constant_AC.UPDATE_CONTACT_RT_ID, Constant_AC.PLANNING_ANTICIPATION_TASK_RT_ID,
        Constant_AC.DETERMINATION_TASK_RT_ID, Constant_AC.VOLUNTEER_TASK_RT_ID,
        Constant_AC.STAFF_TASK_RT_ID, Constant_AC.TASK_RT_ID,
        Constant_AC.INTERVIEW_RT_ID
    };

    private static final Set<Id> AFTER_UPDATE_RECORD_TYPE_IDS = new Set<Id>{
        Constant_AC.GRANT_TASK_RT_ID, Constant_AC.BACKGROUND_RT_ID,
        Constant_AC.UPDATE_CONTACT_RT_ID, Constant_AC.PLANNING_ANTICIPATION_TASK_RT_ID,
        Constant_AC.DETERMINATION_TASK_RT_ID, Constant_AC.VOLUNTEER_TASK_RT_ID,
        Constant_AC.STAFF_TASK_RT_ID, Constant_AC.TASK_RT_ID,
        Constant_AC.INTERVIEW_RT_ID
    };

    /*
     * @description		OnBeforeInsert trigger handler for the Task object
     *
     * @author 			MST Solutions
     * @createdDate		2016-06-01
     */
    public override void handleBeforeInsert() {
        List<Task> beforeInsertTasks = new List<Task>();
        for (Task newTask : newTasksList) {
            if (!BEFORE_INSERT_RECORD_TYPE_IDS.contains(newTask.RecordTypeId)) {
                continue;
            }

            beforeInsertTasks.add(newTask);
        }

        try {
            TaskService.updateBGCTaskSubjectDays(beforeInsertTasks);
            TaskService.updateCOITaskSubjectDays(beforeInsertTasks);
            TaskService.updateTaskEmailMergeFields(beforeInsertTasks);
            TaskService.birthdayTaskPrimaryVolunteerAssign(beforeInsertTasks);
        } catch (Exception ex) {
            for (Task currRec : newTasksList) {
                ErrorMessage__e newsEvent = new ErrorMessage__e();

                newsEvent.Apex_Class__c = 'Task_OnBeforeInsertHandler';
                newsEvent.Developer_Message__c = String.valueOf(currRec);
                newsEvent.Message__c = ex.getMessage();
                newsEvent.Method__c = 'onBeforeInsert';
                newsEvent.Record_Id__c = currRec.Id;
                newsEvent.Type__c = 'Error';
                Database.SaveResult sr = EventBus.publish(newsEvent);

                if (!Test.isRunningTest()) {
                    currRec.addError(Label.Debug_log_error_message);
                }
            }
        }

        for (Task newTask : beforeInsertTasks) {
            if (newTask.Subject == Constant_AC.TASK_SUBJECT_CHECK_IN_WITH_FAMILY ||
                newTask.Subject == Constant_AC.TASK_SUBJECT_WISH_PRESENTATION_NOT_SET ||
                newTask.Subject == Constant_AC.TASK_SUBJECT_BUDGET_IS_APPROVED_ACKNOWLEDGE ||
                newTask.Subject == Constant_AC.TASK_SUBJECT_SEND_DNQ ||
                newTask.Subject == Constant_AC.TASK_SUBJECT_INTERVIEW_TASK ||
                newTask.Subject == Constant_AC.TASK_SUBJECT_INTERVIEW_COMPLETED ||
                newTask.Subject == Constant_AC.TASK_SUBJECT_PARENT_ORIENTATION) {

                newTask.SystemGeneratedTask__c = true;
            }

            if (newTask.Subject.contains(' ET : ') &&
                newTask.Status == Constant_AC.TASK_STATUS_COMPLETED &&
                (newTask.SystemGeneratedTask__c == false || newTask.ActivityDate != null)) {

                newTask.SystemGeneratedTask__c = true;
                newTask.ActivityDate = null;
            }


            if (newTask.Subject == Constant_AC.TASK_SUBJECT_BUDGET_IS_APPROVED ||
                newTask.Subject == Constant_AC.TASK_SUBJECT_BUDGET_APPROVAL_REQUEST ||
                newTask.Subject == Constant_AC.TASK_SUBJECT_BUDGET_NEEDS_REVISED ||
                newTask.Subject == Constant_AC.TASK_SUBJECT_FOLLOWUP_ON_CLEARANCE ||
                newTask.Subject == Constant_AC.TASK_SUBJECT_INTERVIEW_DATE_NOT_SET ||
                newTask.Subject == Constant_AC.TASK_SUBJECT_BIRTHDAY_REMINDER ||
                newTask.Subject == Constant_AC.TASK_SUBJECT_FAMILY_PACKET_NOT_SUBMITTED) {

                newTask.SystemGeneratedTask__c = true;
                newTask.RecordTypeId = Constant_AC.STAFF_TASK_RT_ID;
            }

            if (newTask.Subject == Constant_AC.TASK_SUBJECT_RUSH_QUALIFIED ||
                newTask.Subject == Constant_AC.TASK_SUBJECT_RUSH_REFERRAL ||
                newTask.Subject == Constant_AC.TASK_SUBJECT_RUSH_CHANGED) {

                newTask.RecordTypeId = Constant_AC.TASK_RT_ID;
            }
        }
    }

    /*
     * @description		OnBeforeUpdate trigger handler for the Task object
     *
     * @author 			MST Solutions
     * @createdDate		2018-06-01
     */
    public override void handleBeforeUpdate() {
        // During code cleanup, RecursiveTrigger.blockBeforeUpdate was found to manage BEFORE UPDATE
        // trigger recursion. It isn't presently clear what the consequences of removing this check
        // will be, so leaving it here for the time being.
        if (RecursiveTriggerHandler.blockBeforeUpdate) {
            return;
        }

        List<Task> beforeUpdateTasks = new List<Task>();
        for (Task newTask : newTasksList) {
            if (!BEFORE_UPDATE_RECORD_TYPE_IDS.contains(newTask.RecordTypeId)) {
                continue;
            }

            beforeUpdateTasks.add(newTask);
        }

        TaskService.closeTaskValidation(beforeUpdateTasks, oldTasksMap);
        TaskService.updateTaskEmailMergeFields(beforeUpdateTasks, oldTasksMap);
        TaskService.dateTimeValidations(beforeUpdateTasks, oldTasksMap);

        for (Task newTask : beforeUpdateTasks) {
            if (newTask.Confirmed_Date__c != null && oldTasksMap.get(newTask.Id).Confirmed_Date__c == null) {
                newTask.Status = Constant_AC.TASK_STATUS_SCHEDULED;
            }

            if (newTask.Availability_Time_Other1__c != null && newTask.Available_Time1__c != Constant_AC.TASK_AVAILABLE_TIME_OTHER) {
                newTask.Availability_Time_Other1__c = '';
            }

            if (newTask.Subject.contains(' ET : ') && newTask.Status == Constant_AC.TASK_STATUS_COMPLETED
                && (newTask.SystemGeneratedTask__c == false || newTask.ActivityDate != null)) {

                newTask.SystemGeneratedTask__c = true;
                newTask.ActivityDate = null;
            }

            if (newTask.Availability_Time_Other2__c != null && newTask.Available_Time2__c != Constant_AC.TASK_AVAILABLE_TIME_OTHER) {
                newTask.Availability_Time_Other2__c = '';
            }

            if (newTask.Availability_Time_Other3__c != null && newTask.Available_Time3__c != Constant_AC.TASK_AVAILABLE_TIME_OTHER) {
                newTask.Availability_Time_Other3__c = '';
            }
        }
    }

    /*
     * @description		OnAfterUpdate trigger handler for the Task object
     *
     * @author 			MST Solutions
     * @createdDate		2016-06-01
     */
    public override void handleAfterUpdate() {
        // During code cleanup, RecursiveTrigger.blockBeforeUpdate was found to manage BEFORE UPDATE
        // trigger recursion. It isn't presently clear what the consequences of removing this check
        // will be, so leaving it here for the time being.
        if (RecursiveTriggerHandler.blockAfterUpdate) {
            return;
        }

        List<Task> afterUpdateTasks = new List<Task>();
        for (Task newTask : newTasksList) {
            if (!AFTER_UPDATE_RECORD_TYPE_IDS.contains(newTask.RecordTypeId)) {
                continue;
            }

            afterUpdateTasks.add(newTask);
        }

        TaskService.checkFollowUpTask(afterUpdateTasks, oldTasksMap);
        TaskService.updateVolunteerRecord(afterUpdateTasks, oldTasksMap);
        TaskService.updateAffiliationStatusAsDeclined(afterUpdateTasks, oldTasksMap);
        TaskService.updateAffiliationStatus(afterUpdateTasks, oldTasksMap);
        TaskService.sneakPeekTask(afterUpdateTasks, oldTasksMap);
        TaskService.autoCloseTask(afterUpdateTasks, oldTasksMap);
        TaskService.updateLeadCloseDate(afterUpdateTasks, oldTasksMap);
    }
}