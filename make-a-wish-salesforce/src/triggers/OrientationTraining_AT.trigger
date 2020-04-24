/*****************************************************************************************************************
Author      : MST Solutions
Date        : 7/25/2016
Description : 
*******************************************************************************************************************/
trigger OrientationTraining_AT on Orientation_Training__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    trac_TriggerHandlerBase.triggerHandler(new OrientationTrainingDomain());
}