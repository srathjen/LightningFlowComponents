/**
 * @description Chapter Role Orientation and Training Trigger
 * @author		Gustavo Mayer, Traction on Demand
 * @date 		04-15-2020
 */
trigger ChapterRoleO_T_AT on Chapter_Role_O_T__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    trac_TriggerHandlerBase.triggerHandler(new ChapterRoleOTDomain());
}