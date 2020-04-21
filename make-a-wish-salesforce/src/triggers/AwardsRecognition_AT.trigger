/*******************************************************************************
Author      : MST Solutions
Description : Sharing Records to Inside Chapter Staff.
*********************************************************************************/

trigger AwardsRecognition_AT on Awards_Recognition__c (before insert, before update, before delete, 
                                                       after insert, after update, after delete, after undelete) {
    trac_TriggerHandlerBase.triggerHandler(new AwardsRecognitionDomain());
}