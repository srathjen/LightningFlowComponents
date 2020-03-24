trigger BackGroundCheck_AT on Background_check__c (before insert, before update, before delete, 
                                                   after insert, after update, after delete, after undelete) {
    trac_TriggerHandlerBase.triggerHandler(new BackgroundCheckDomain());
}