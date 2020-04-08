trigger AffiliationTrigger_AT on npe5__Affiliation__c (before insert, before update, before delete,
        after insert, after update, after delete, after undelete) {
    trac_TriggerHandlerBase.triggerHandler(new AffiliationDomain());
}