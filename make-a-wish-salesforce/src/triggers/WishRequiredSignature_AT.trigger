trigger WishRequiredSignature_AT on Wish_Required_Signature__c (before insert, before update, before delete, 
                                                                after insert, after update, after delete, after undelete) {
    trac_TriggerHandlerBase.triggerHandler(new WishRequiredSignatureDomain());
}