/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/27/2016
Description : When a new RelationShip record is created or updated then it will call the corresponding apex class.
Modification Log: 
04/18/2018 - Kanagaraj - WVC-1885
*******************************************************************************************************************/
trigger Relationship_AT on npe4__Relationship__c (after insert,before insert,after update){
    
    if((trigger.isBefore && trigger.isUpdate && RecursiveTriggerHandler.blockBeforeUpdate == true) || (trigger.isAfter && trigger.isUpdate && RecursiveTriggerHandler.blockAfterUpdate)){
     return; 
    }
    if(trigger.isInsert && trigger.isAfter){
       RelationshipOnAfterInsertTriggerHandler.onAfterInsert(trigger.new);
    }
    if(trigger.isAfter && trigger.isUpdate && RecursiveTriggerHandler.blockAfterUpdate == false){
       RelationshipOnAfterUpdateTriggerHandler.onAfterUpdate(trigger.newMap,trigger.oldMap);
    }
}