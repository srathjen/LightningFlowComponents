/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 5/23/2016
Description : This TimeSheetTrigger_AT is used to calculate the total hours spent by volunteers to close the wish and 
              Non-wish & Event.
*******************************************************************************************************************/
Trigger TimeSheetTrigger_AT on Time_sheet__c (before insert, before update, before delete, 
                                              after insert, after update, after delete, after undelete) {
    trac_TriggerHandlerBase.triggerHandler(new TimesheetDomain());
}