trigger AffiliationTrigger_AT on npe5__Affiliation__c (Before Insert,Before Update,After Insert,After Update,After Delete)
{
       
     if((trigger.isBefore && trigger.isUpdate && RecursiveTriggerHandler.blockBeforeUpdate == true) || (trigger.isAfter && trigger.isUpdate && RecursiveTriggerHandler.blockAfterUpdate)){
     return; 
    }
    // Whenever first Affiliation record is fallon under contact, assigning that record as primary.
    if(Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null)
    {
        if(Trigger.isBefore && Trigger.isInsert) 
        {
            Affiliation_OnBeforeInsertTriggerHandler.OnBeforeInsert(Trigger.new);
        }
        //This used to get affiliation's crossponding user name and email to merge in active user welcome email template
        else if(Trigger.isBefore&& Trigger.isUpdate && RecursiveTriggerHandler.blockBeforeUpdate == false)
        {
            Affiliation_BeforeUpdateTriggerHandler.OnBeforeUpdate(Trigger.new,Trigger.oldMap);
        }
        //Used to add user to chatter group when a user becomes active to particular chapter
        else if(Trigger.isAfter && Trigger.isUpdate && RecursiveTriggerHandler.blockAfterUpdate == false)
        {
            Affiliation_OnAfterUpdateTriggerHandler.OnAfterUpdate(Trigger.new,Trigger.oldMap);
        }
        // After insert trigger is used to add the user to the public group to access the approved In-Kind donor account record based on the affiliation record   
        else if(Trigger.isAfter && ((Trigger.isUpdate&& RecursiveTriggerHandler.blockAfterUpdate == false) || trigger.isinsert ))
        {
            Affiliation_OnAfterUpdateTriggerHandler.OnAfterUpsert(Trigger.new,Trigger.oldMap);
        }
        // After delete trigger is used to remove the user to the public group to restrict the approved In-Kind donor account record based on the affiliation record   
        else if(Trigger.isAfter && Trigger.isDelete)
        {
            Affiliation_OnAfterDeleteTriggerHandler.OnAfterDelete(Trigger.old);
        }
    }

}