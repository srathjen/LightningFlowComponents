/***************************************************************************************************
Author      : MST Solutions
Date        : 10/15/2016
Description : ContactTrigger_AT is used to call the Account trigger Handler classes and helper classes when the
              new account record is created and updated.
              
              Modification Log
              ------------------
              WVC-1884    KANAGARAJ  04/04/2018
              
*****************************************************************************************************/
trigger ContactTrigger_AT on Contact(before insert, before update, before delete, 
                                     after insert, after update, after delete, after undelete) {
    trac_TriggerHandlerBase.triggerHandler(new ContactDomain());
}