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


    /*
     * @description		OnBeforeInsert trigger handler for the Task object
     *
     * @author 			MST Solutions
     * @createdDate		2016-06-01
     */
    public override void handleBeforeInsert() {
        Task_OnBeforeInsertHandler.onBeforeInsert(newTasksList);
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