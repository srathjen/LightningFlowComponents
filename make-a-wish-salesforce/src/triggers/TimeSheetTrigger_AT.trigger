/**
 * @description     Trigger for Time_sheet__c object.
 * @author          MST Solutions
 * @createdDate     2016-05-23
 */
trigger TimeSheetTrigger_AT on Time_sheet__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    trac_TriggerHandlerBase.triggerHandler(new TimesheetDomain());
}