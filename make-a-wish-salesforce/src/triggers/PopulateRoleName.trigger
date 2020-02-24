trigger PopulateRoleName on Chapter_Role__c (before insert,before update) {    
    if(Trigger.isBefore && Trigger.isinsert)
        ChapterRole_OnBeforeInsertHandler.onBeforeInsert(Trigger.new);
     if(Trigger.isBefore && Trigger.isUpdate)
        ChapterRole_OnBeforeUpdateHandler.onBeforeUpdate(Trigger.new,Trigger.oldMap); 
}