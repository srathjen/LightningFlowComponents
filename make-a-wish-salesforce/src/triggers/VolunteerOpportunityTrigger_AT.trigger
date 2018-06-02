/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/27/2016
Description : When a new Volunteer Opportunity record is created or updated or delete then it will call the corresponding apex class.
Modification Log: 
04/17/2018 - Kanagaraj - WVC-1885
*******************************************************************************************************************/

trigger VolunteerOpportunityTrigger_AT on Volunteer_Opportunity__c (Before Insert,Before Update,After Insert,After Update,After delete, Before delete) {
    
    if(trigger.isBefore && Trigger.isUpdate){
       VolOpportunity_OnBefore_Update_Handler.onBeforeUpdate(trigger.newMap,trigger.oldMap);
    }
    if(trigger.isBefore && Trigger.isDelete){
       VolOpportunity_OnBefore_Delete_Handler.onBeforeDelete(trigger.old);
    }
    if(trigger.isAfter && Trigger.isInsert){
        VolOpportunity_OnAfter_Insert_Handler.OnAfterInsert(trigger.new);
    }
    if(trigger.isAfter && Trigger.isUpdate){
        VolOpportunity_OnAfter_Update_Handler.onAfterUpdate(trigger.newMap,trigger.oldMap);
    }
    if(trigger.isAfter && Trigger.isDelete){
        VolOpportunity_OnAfter_Delete_Handler.onAfterDelete(trigger.old);
    }
}