trigger CaseFile_AT on cg__CaseFile__c (before insert, before update, before delete,
        after insert, after update, after delete, after undelete) {
    trac_TriggerHandlerBase.triggerHandler(new CaseFileDomain());
}