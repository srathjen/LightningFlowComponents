/**
* @description Domain class for Timesheet trigger
* @author Michelle Cominotto, Make-A-Wish
* @createdDate 4/10/2020
*/
public with sharing class TimesheetDomain extends trac_TriggerHandlerBase {
    private List<Time_sheet__c> newTimesheetsList = (List<Time_sheet__c>)newRecordsList;
    private List<Time_sheet__c> oldTimesheetsList = (List<Time_sheet__c>)oldRecordsList;
    private Map<Id, Time_sheet__c> newTimesheetsMap = (Map<Id, Time_sheet__c>)newRecordsMap;
    private Map<Id, Time_sheet__c> oldTimesheetsMap = (Map<Id, Time_sheet__c>)oldRecordsMap;
    
    /**
    * Before insert of timesheet
    */
    public override void handleBeforeInsert() {
        if(!blockTrigger) {
            TimesheetService.splitHoursMinutes(newTimesheetsList);
        }
        TimesheetService.shareVolunteerOpportunity(newTimesheetsList);
    }
    
    /**
    * Before update of timesheet
    */
    public override void handleBeforeUpdate() {
        if(blockTrigger) {
            return;
        }
        TimesheetService.splitHoursMinutes(newTimesheetsList, oldTimesheetsMap);
    }
    
    /**
    * After insert of timesheet
    */
    public override void handleAfterInsert() {
        if(blockTrigger) {
            return;
        }
        TimesheetService.calculateHoursOfWish(newTimesheetsList);
        TimesheetService.calculateHoursOfNonwish(newTimesheetsList);
        TimesheetService.findRecentTimesheetDate(newTimesheetsList);
    }
    
    /**
    * After update of timesheet
    */
    public override void handleAfterUpdate() {
        if(blockTrigger) {
            return;
        }
        TimesheetService.calculateHoursOfWish(newTimesheetsList, oldTimesheetsMap);
        TimesheetService.findRecentTimesheetDate(newTimesheetsList, oldTimesheetsMap);
    }
    
    /**
    * After delete of timesheet
    */
    public override void handleAfterDelete() {
        TimesheetService.calculateHoursOfWish(oldTimesheetsList);
        TimesheetService.calculateHoursOfNonwish(oldTimesheetsList);
    }
}