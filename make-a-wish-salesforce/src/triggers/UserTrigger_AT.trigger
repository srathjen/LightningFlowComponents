/**
 * @description     A trigger used to create a public group and public group member
 *                  whenever a new user record is created.
 * @author          MST Solutions
 * @createdDate     2015-05-27
 */
trigger UserTrigger_AT on User (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    trac_TriggerHandlerBase.triggerHandler(new UserDomain());
}