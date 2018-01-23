/*****************************************************************************************
Created By  : MST
CreatedDate : 10/11/2017
Author : MST Solutions
Description : This class is used to create birthday task for volunteers when the birthday day difference is greater than 21
*************************************************************************************/
global class batch_CreateBirthdayTask_AC implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Constant_AC  constant = new Constant_Ac();
        Id parentWishRT = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        Date bdayDay = system.today().addDays(21);
        List<Case> cc = [SELECT Id, CurrentDOB__c FROM Case];
        return Database.getQueryLocator([SELECT Id,CurrentDOB__c,ContactId, OwnerId FROM Case WHERE RecordTypeId =: parentWishRT AND CurrentDOB__c =: bdayDay AND Status != 'Completed' AND Status != 'Closed' AND Status != 'DNQ' AND Status != 'Denied' AND Status != 'Granted' AND Status != 'Medical' AND Contact.npsp__Deceased__c != True]);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> parentCase) {
        Constant_AC  constant = new Constant_Ac();
        Id volunteerTaskRT = Schema.Sobjecttype.Task.getRecordTypeInfosByName().get(constant.volunteerTaskRT).getRecordTypeId();
        Id staffRt = Schema.SObjectType.Task.getRecordTypeInfosByName().get(constant.staffTaskRT).getRecordTypeId();        
        Set<Id> parentIdSet = new Set<Id>();
        List<Task> taskList = New List<Task>();
        for(Case parentWish: parentCase) {
            parentIdSet.add(parentWish.Id);
        }
        
        Map<Id, Id> caseTeamInfoMap = new Map<Id, Id>();
        for(CaseTeamMember caseTeamInfo : [SELECT Id, ParentId, MemberId FROM CaseTeamMember WHERE parentId IN : parentIdSet AND TeamRole.name = 'Wish Granter' Order By createdDate ASC]) {
            if(!caseTeamInfoMap.containsKey(caseTeamInfo.ParentId)) {
                caseTeamInfoMap.put(caseTeamInfo.ParentId, caseTeamInfo.MemberId);
            }
        }
        
        for(Case createBdaytask : parentCase) {
            Task birthDayTask = new Task();
            birthDayTask.WhoId = createBdaytask.ContactId;
            birthDayTask.WhatId = createBdaytask.Id;
            birthDayTask.Subject = 'Wish Child Birthday Reminder';
            birthDayTask.ActivityDate = createBdaytask.CurrentDOB__c;
            if(caseTeamInfoMap.ContainsKey(createBdaytask.Id)){
                birthDayTask.RecordTypeId = volunteerTaskRT;
                birthDayTask.OwnerId = caseTeamInfoMap.get(createBdaytask.Id);
            }
            else{
                birthDayTask.RecordTypeId = staffRt;
                birthDayTask.OwnerId = createBdaytask.OwnerId;
            }
            taskList.add(birthDayTask);
        }
        
        If(taskList.Size() > 0)
            Insert taskList;
        
    }  
    
    global void finish(Database.BatchableContext BC) {
        
    }
}