/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/26/2016
Description : When a new case record is created or updated then it will call the corresponding apex class.
*******************************************************************************************************************/
trigger CaseTrigger_AT on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    trac_TriggerHandlerBase.triggerHandler(new CaseDomain());
}