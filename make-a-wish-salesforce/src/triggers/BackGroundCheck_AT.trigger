/**************************************************************************************************
Description : Its updating the Active flag as True whenever new records are inserted. And also its 
preventing duplicate active background check record.
Its updating Affiliation Record status based the Background check verification status.
***************************************************************************************************/

trigger BackGroundCheck_AT on Background_check__c (Before insert, Before update, After insert,After update) {
        
    if(Trigger.isBefore && Trigger.isInsert)
    {   
        BackGroundCheck_OnBeforeInsertHandler.OnBeforeInsert(Trigger.new);
    }
    
    if(Trigger.isAfter && Trigger.isInsert)
    {
        BackGroundCheck_OnAfterInsertHandler.OnAfterInsert(Trigger.new);        
    }
    if(Trigger.isBefore && Trigger.isUpdate)
    {
        BackGroundCheck_OnBeforeUpdateHandler.OnBeforeUpdate(Trigger.new,Trigger.oldMap);
    }
    If(Trigger.isAfter && Trigger.isUpdate)
    {
       BackGroundCheck_OnAfterUpdateHandler.OnAfterUpdate(Trigger.new,Trigger.oldMap);  
    }
    
    
}