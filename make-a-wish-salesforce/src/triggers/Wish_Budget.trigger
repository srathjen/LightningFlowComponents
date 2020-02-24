/**
 * @description Trigger for the Wish Budget object
 * @author		Mitali Nahar, Traction on Demand
 * @date 		8/22/2019.
 */
trigger Wish_Budget on Wish_Budget__c (after insert, after update, before update) {
    trac_TriggerHandlerBase.triggerHandler(new Wish_BudgetDomain());
}