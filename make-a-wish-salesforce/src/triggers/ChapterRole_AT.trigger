/**
 * @description Chapter Role Trigger
 * @author		Gustavo Mayer, Traction on Demand
 * @date 		04-15-2020
 */
trigger ChapterRole_AT on Chapter_Role__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    trac_TriggerHandlerBase.triggerHandler(new ChapterRoleDomain());
}