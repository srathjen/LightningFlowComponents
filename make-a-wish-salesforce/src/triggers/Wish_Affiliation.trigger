/**
 * @description Trigger for the Wish_Affiliaton object
 * @author		Mason Buhler, Traction on Demand
 * @date 		7-26-2019
 */
trigger Wish_Affiliation on Wish_Affiliation__c (before insert, before update,after insert, after update) {
    trac_TriggerHandlerBase.triggerHandler(new Wish_AffiliationDomain());
}