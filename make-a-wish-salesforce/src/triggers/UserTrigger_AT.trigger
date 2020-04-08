/*************************************************************************************************
Author   : MST Solutions
CreatedBy: Kanagaraj 
CreatedDate : 05/27/2015
Description : This UserTrigger_AT is used to create a public group and public group member when ever a new
              user record is created.
*************************************************************************************************/

trigger UserTrigger_AT on User (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    trac_TriggerHandlerBase.triggerHandler(new UserDomain());
}