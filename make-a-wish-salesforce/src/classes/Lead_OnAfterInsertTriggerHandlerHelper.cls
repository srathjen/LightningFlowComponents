/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 26/05/2016
Description : This Lead_OnAfterInsertTriggerHandlerHelper class is invoked by Lead_OnAfterInsertTriggerHandler 
and its used to create a 'New Inquiry Task' 
*****************************************************************************************************/

Public Class Lead_OnAfterInsertTriggerHandlerHelper{
    
/************************************************************************************************
createTask method is used to create a 'New Inquiry Task'.
*************************************************************************************************/    
    
    Public static void createTask(Map<Id,Lead> leadMap){
        Constant_AC  constant = new Constant_Ac();    
        Id staffTaskRT = Schema.SObjectType.Task.getRecordTypeInfosByName().get(constant.staffTaskRT).getRecordTypeId();
        List<Task> newTaskList = new List<Task>();
        List<Database.SaveResult> srList = new List<Database.SaveResult>();
        
            for(Lead newLead : [SELECT id,Migrated_Record__c, OwnerId,Owner.UserRole.Name,Status, ChapterName__c,ChapterName__r.Name,PD_Condition_Description__C FROM Lead WHERE Id IN : leadMap.keySet() Limit 50000])
            {
                Task newTask = new Task();
                if(newLead.status == 'Inquiry') {
                    newTask.subject = 'New Inquiry Submitted';
                    newTask.ActivityDate = Date.Today().addDays(30);
                }
                if(newLead.status == 'Referred') {
                    newTask.subject = 'New Referral Submitted';
                    newTask.ActivityDate = Date.Today().addDays(10);
                }
                newTask.ownerId = newLead.OwnerId;
                newTask.RecordTypeId = staffTaskRT;
                newTask.whoId = newLead.id;
                newTask.priority = 'Normal';
                newTask.SystemGeneratedTask__c = TRUE;
                newTaskList.add(newTask);
            } 
            if(newTaskList.size() > 0)
                srList = Database.insert(newTaskList,false);
                
       
    }
}