/***************************************************************************************************
Author      : MST Solutions
Date        : 10/15/2016
Description : AccountTrigger_AT is used to call the Account trigger Handler classes and helper classes when the
              new account record is created and updated.
              
              Modification Log
              ------------------
              WVC-1884    KANAGARAJ  03/04/2018
              
*****************************************************************************************************/
trigger AccountTrigger_AT on Account (before insert, after insert, after update, before update) {
    trac_TriggerHandlerBase.triggerHandler(new AccountDomain());
}