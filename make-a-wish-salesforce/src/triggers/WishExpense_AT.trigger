/**
 * @description Trigger for the Wish Expense object
 * @author		MST Solutions
 * @createDate 	6-01-2018
 * @update  Mitali Nahar, Traction On Demand
 */
trigger WishExpense_AT on Wish_Expense__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    trac_TriggerHandlerBase.triggerHandler(new Wish_ExpenseDomain());
}