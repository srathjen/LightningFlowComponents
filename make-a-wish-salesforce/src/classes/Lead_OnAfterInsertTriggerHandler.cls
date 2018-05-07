/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 26/05/2016
Description : This Lead_OnAfterInsertTriggerHandler class is invoke after the lead record is created.
and also we are sharing this record based on the chapter.
*****************************************************************************************************/
Public Class Lead_OnAfterInsertTriggerHandler{
    
/********************************************************************************************
    This method is used to create a task when the lead record is created. And share the lead
    record based on the chapter.
*********************************************************************************************/
    public static void onAfterInsert(List<Lead> newLeadList){
        Map<Id,Lead> newLeadMap = new Map<Id,Lead>();
        Constant_AC  constant = new Constant_Ac();    
        Id staffTaskRT = Schema.SObjectType.Task.getRecordTypeInfosByName().get(constant.staffTaskRT).getRecordTypeId();
        Map<String, List<Lead>> leadMap = new Map<String,List<Lead>>();
       
            for(Lead newLead : newLeadList)
            {
                if(Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null){
                    newLeadMap.put(newLead.Id,newLead);
                }
                if(newLead.ChapterName__c!= Null && newLead.Owner.UserRole.Name == 'National Staff'){
                    if(leadMap.containsKey(newLead.ChapterName__r.Name))
                        leadMap.get(newLead.ChapterName__r.Name).add(newLead);
                    else
                        leadMap.put(newLead.ChapterName__r.Name, new List<Lead>{newLead});
                }
            }
            if(newLeadMap.size() > 0){
                Lead_OnAfterInsertTriggerHandlerHelper.createTask(newLeadMap);
            }
            if(leadMap.size() > 0){
                ChapterStaffRecordSharing_AC.LeadSharing(leadMap);
            }
    }
}