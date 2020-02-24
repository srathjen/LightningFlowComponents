/*******************************************************************************
Author      : MST Solutions
Description : Sharing Records to Inside Chapter Staff.
*********************************************************************************/

trigger AwardsRecognition_AT on Awards_Recognition__c (after insert,after update) 
{
  
    If(Trigger.isAfter && Trigger.isUPdate){
        AwardsRecognition_OnAfterUpdateHandler.OnAfterUpdate(Trigger.newMap,Trigger.oldMap);
    }
    If(Trigger.isAfter && Trigger.isInsert){
        AwardsRecognition_OnAfterInsertHandler.OnAfterInsert(Trigger.new);
    }

}