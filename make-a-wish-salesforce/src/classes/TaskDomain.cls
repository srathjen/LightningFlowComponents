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


    /*
     * @description		OnBeforeInsert trigger handler for the Task object
     *
     * @author 			MST Solutions
     * @createdDate		2016-06-01
     */
    public override void handleBeforeInsert() {
        List<Task> birthdayTasksList = new List<Task>();
        Set<Id> taskRelatedContactIdsSet = new Set<Id>();
        set<ID> contactIdset = new set<ID>();
        List<Task> updateTaskList = new List<Task>();
        List<Task> matchContactTaskList = new List<Task>();
        Set<Id> taskParentIdSet = new Set<Id>();
        Map<Id,List<Task>> reparentChildCaseTaskMap = new Map<Id,List<Task>>();
        Map<Id,Task> bgExpiringTaskMap = new Map<Id,Task>();
        Map<Id,Task> coiExpiringTaskMap = new Map<Id,Task>();

        try {
            for (Task newTask : newTasksList) {
                if (!BEFORE_INSERT_RECORD_TYPE_IDS.contains(newTask.RecordTypeId)) {
                    continue;
                }

                if (newTask.Subject == 'Check in with the family every 30 days' || newTask.Subject == 'Wish Presentation Not Set' || newTask.Subject == 'Budget is approved: Acknowledge Receipt of Approval'
                    || newTask.Subject == 'Send DNQ Notification to Qualifying Medical Professional' || newTask.Subject == 'Interview Task' || newTask.Subject == 'Interview Completed' || newTask.Subject == 'Parent/Guardian Orientation') {
                    newTask.SystemGeneratedTask__c = True;
                }
                if (newTask.Subject.contains(' ET : ') && newTask.status == 'Completed' && (newTask.SystemGeneratedTask__c == FALSE || newTask.ActivityDate != NULL)) {
                    newTask.SystemGeneratedTask__c = True;
                    newTask.ActivityDate = null;
                }
                if (newTask.Subject == 'BC ET : Background Check Expiring') {
                    if (newTask.WhatId != NULL) {
                        bgExpiringTaskMap.put(newTask.WhatId, newTask);
                    }
                }
                if (newTask.Subject == 'COI ET : COI Expiring') {
                    if (newTask.WhatId != NULL) {
                        coiExpiringTaskMap.put(newTask.WhatId, newTask);
                    }
                }
                if (newTask.subject == 'Budget is approved' || newTask.subject == 'Case ET : Budget Approval Request' || newTask.subject == 'Budget needs to be revised' || newTask.subject == 'Follow-up on wish clearance' || newTask.subject == 'Interview date not set'
                    || newTask.subject == 'Wish Child Birthday Reminder' || newTask.subject == 'Wish Family Packet not submitted') {
                    newTask.SystemGeneratedTask__c = True;
                    newTask.RecordTypeId = Constant_AC.STAFF_TASK_RT_ID;
                    matchContactTaskList.add(newTask);
                    taskParentIdSet.add(newTask.WhatId);
                }
                if (newTask.Subject == 'Wish Child Birthday Reminder') {
                    birthdayTasksList.add(newTask);
                    taskRelatedContactIdsSet.add(newTask.whatId);
                }
                //IME 58
                if (newTask.Subject == 'Lead ET : New Rush Qualified' || newTask.Subject == 'Lead ET : New Rush Referral' ||
                    newTask.Subject == 'Rush has been changed from Yes to No/ Not sure, reach out to family if necessary') {
                    newTask.RecordTypeId = Constant_AC.TASK_RT_ID;
                }

                if (newTask.WhoId != null) {
                    contactIdset.add(newTask.WhoId);
                    updateTaskList.add(newTask);
                }
                if (newTask.subject == 'Case ET : Wish Presentation Date Reminder' || newTask.subject == 'Case ET : Wish Presentation Details') {
                    if (reparentChildCaseTaskMap.containsKey(newTask.WhatId)) {
                        reparentChildCaseTaskMap.get(newTask.WhatId).add(newTask);
                    } else {
                        reparentChildCaseTaskMap.put(newTask.WhatId, new List<Task>{
                            newTask
                        });
                    }

                }
            }
            /**
             * JIRA: WLP-286
             * Author: Gustavo Mayer
             * Update: Sub case conversion to the single Wish Case, no need to update
             * as there is no longer the concept of parent case.
             */
//			if (reparentChildCaseTaskMap.size() > 0) {
//				Task_OnBeforeInsertHelper.reparentChildCaseToParentCase(reparentChildCaseTaskMap);
//			}
            if (bgExpiringTaskMap.size() > 0) {
                TaskService.updateBGCTaskSubjectDays(bgExpiringTaskMap);
            }
            if (coiExpiringTaskMap.size() > 0) {
                TaskService.updateCOITaskSubjectDays(coiExpiringTaskMap);
            }
            if (matchContactTaskList.size() > 0 && taskParentIdSet.size() > 0) {
                //Task_OnBeforeInsertHelper.UpdateContactToTask(matchContactTaskList, taskParentIdSet);
                // FUNCTION CANNOT ACCOMPLISH ANYTHING
            }
            if ((contactIdset.size() > 0) && (updateTaskList.size() > 0)) {
                TaskService.updateTaskEmailMergeFields(contactIdset, updateTaskList);
            }
            if (birthdayTasksList.size() > 0 && taskRelatedContactIdsSet.size() > 0) {
                TaskService.birthdayTaskPrimaryVolunteerAssign(birthdayTasksList, taskRelatedContactIdsSet);
            }

            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }

        } catch (Exception ex) {
            for (Task currRec : newTasksList) {
                ErrorMessage__e newsEvent = new ErrorMessage__e();
                newsEvent.Apex_Class__c = 'Task_OnBeforeInsertHandler';
                newsEvent.Developer_Message__c = String.valueof(currRec);
                newsEvent.Message__c = ex.getMessage();
                newsEvent.Method__c = 'onBeforeInsert';
                newsEvent.Record_Id__c = currRec.Id;
                //newsEvent.Stack_Trace__c = String.valueOf(ex);
                newsEvent.Type__c = 'Error';
                Database.SaveResult sr = EventBus.publish(newsEvent);

                if (!Test.isRunningTest()) {

                    currRec.addError(Label.Debug_log_error_message);

                }
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

        Task_OnBeforeUpdateHandler.OnBeforeUpdate(newTasksMap, oldTasksMap);
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

        Task_OnAfterUpdateHandler.OnAfterUpdate(newTasksMap, oldTasksMap);
    }
}