trigger ContactFile_AT on cg__ContactFile__c (before insert, before update, before delete,
        after insert, after update, after delete, after undelete) {
    trac_TriggerHandlerBase.triggerHandler(new ContactFileDomain());
}