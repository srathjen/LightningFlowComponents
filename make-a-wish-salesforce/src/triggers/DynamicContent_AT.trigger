/*********************************************************************************************
Created by: Vennila Paramasivam
Author : MST Solutions
Created DAte:07/08/2015
Description : Dynamic Content should be just 1 national record and 63 chapter prospective and 63 chapter active (one for each chapter). 
So we can add an Active flag on the record. if we are creating a new national record or new chapter prospective record for Arizona 
(or any other chapter), then the previous record needs to inactive and the new one would be active.
2.Prevent outside chapter user cannot create dynamic content record for other chapter.


                    Modification Log
                    ----------------
          SonarQube    Pavithra G 04/11/2018

**********************************************************************************************/

trigger DynamicContent_AT on Dynamic_Content__c (before insert, before update, before delete, 
                                                 after insert, after update, after delete, after undelete) {
    trac_TriggerHandlerBase.triggerHandler(new DynamicContentDomain());
}