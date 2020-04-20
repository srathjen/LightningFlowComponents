/**
 * Lead Trigger
 *
 * @author Gustavo Mayer, Traction on Demand
 *
 * @date 3-04-2020
 */
trigger LeadTrigger_AT on Lead (before insert, before update, before delete,
        after insert, after update, after delete, after undelete) {
    trac_TriggerHandlerBase.triggerHandler(new LeadDomain());
}