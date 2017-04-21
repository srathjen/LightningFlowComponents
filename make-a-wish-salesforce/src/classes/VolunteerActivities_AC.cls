/*****************************************************************************************************************
Author      : MST Solutions
Date        : 11/10/2016
Description : This class is used to display open and closed activities for volunteers
*******************************************************************************************************************/

public with sharing class VolunteerActivities_AC {
    
    public Id taskId {get;set;}
    private Id volunteerUserId;
    public Boolean showActive {get;set;}
    public Boolean showHistorical {get;set;}
    Constant_AC constant = new Constant_AC();
    public Id nonWishRecordTypeId = Schema.Sobjecttype.Non_Wish_Events__c.getRecordTypeInfosByName().get(constant.nonWishRT).getRecordTypeId();
    public Id eventRecordTypeId = Schema.Sobjecttype.Non_Wish_Events__c.getRecordTypeInfosByName().get(constant.events).getRecordTypeId();
    
    public VolunteerActivities_AC() {
        showHistorical = false;
        showActive = true;
        volunteerUserId = userinfo.getUserId();
    }
    
    //Used to pull all open activities for volunteer
    public List<OpenActivitiesWrapper> getOpenActivities() {
        
        List<OpenActivitiesWrapper> openActivitiesList = new List<OpenActivitiesWrapper>();
        Set<Id> wishTypeTaskSet = new Set<Id>();
        Set<Id> nonWishAndEvents = new Set<Id>();
        Set<Id> volunteerOpportunityIdSet = new Set<Id>();
        
        Map<Id,String> eventTypeMap = new Map<Id, String>();
        
        Map<Id, String> eventNameMap = new Map<Id, String>();
        Map<Id, String> wishNameMap = new Map<Id, String>();
        //List<Task> openActivities = Database.Query('SELECT Id, WhatId, What.Type, WhoId, Subject, ActivityDate, Status FROM Task WHERE Status != \'Completed\' AND OwnerId =:volunteerUserId ORDER BY CreatedDate DESC');
        List<Task> openActivities = Database.Query('SELECT Id, WhatId, What.Type, WhoId, Subject, ActivityDate, Status FROM Task WHERE Status != \'Completed\' ORDER BY CreatedDate DESC');
        if(openActivities.size() > 0) {
            for(Task checkType : openActivities) {
                if(checkType.what.Type == 'Case') {
                    wishTypeTaskSet.add(checkType.WhatId);
                }
                if(checkType.what.Type == 'Non_Wish_Events__c') {
                    nonWishAndEvents.add(checkType.WhatId);
                }
                if(checkType.what.Type == 'Volunteer_Opportunity__c') {
                    volunteerOpportunityIdSet.add(checkType.WhatId);
                }
            }
            Map<Id, Id> caseSubMap = new Map<Id, Id>();
            
            if(volunteerOpportunityIdSet.size() > 0) {
                for(Volunteer_Opportunity__c volOppInfo : [SELECT Id, Non_Wish_Event__c,Wish__r.ContactId,Non_Wish_Event__r.Event_Name__c, Non_Wish_Event__r.RecordType.Name, Wish__c FROM Volunteer_Opportunity__c WHERE Id IN : volunteerOpportunityIdSet]) {
                    if(volOppInfo.Wish__c != null) {
                        wishTypeTaskSet.add(volOppInfo.Wish__c);
                        //eventNameMap.put(volOppInfo.Id,volOppInfo.Wish__r.ContactId);
                        caseSubMap.put(volOppInfo.Id,volOppInfo.Wish__c);
                    }
                    if(volOppInfo.Non_Wish_Event__c != null) {
                        nonWishAndEvents.add(volOppInfo.Id);
                        eventTypeMap.put(volOppInfo.Id, volOppInfo.Non_Wish_Event__r.RecordType.Name);
                        eventNameMap.put(volOppInfo.Id, volOppInfo.Non_Wish_Event__r.Event_Name__c);
                    }
                }
            }
            
            
            if(nonWishAndEvents.size() > 0) {
                for(Non_Wish_Events__c getRecordType : [SELECT Id, Event_Name__c, RecordTypeId, RecordType.Name FROM Non_Wish_Events__c WHERE Id IN : nonWishAndEvents]) {
                    eventTypeMap.put(getRecordType.Id, getRecordType.RecordType.Name);
                    eventNameMap.put(getRecordType.Id, getRecordType.Event_Name__c);
                }
            }
            
            if(wishTypeTaskSet.size() > 0) {
                for(Case getContactName : [SELECT Id, Contact.Name FROM Case WHERE Id IN : wishTypeTaskSet]) {
                    wishNameMap.put(getContactName.Id, getContactName.Contact.Name);
                }
            }
            
            
            
            for(Task taskTypeNameMerge : openActivities) {
                
                OpenActivitiesWrapper mergeInfoWithTask = new OpenActivitiesWrapper();
                mergeInfoWithTask.volunteerTask = taskTypeNameMerge;
                if(taskTypeNameMerge.WhatId != null) {
                    if(eventTypeMap.containsKey(taskTypeNameMerge.WhatId)) {
                        if(eventNameMap.containsKey(taskTypeNameMerge.WhatId)) {
                            mergeInfoWithTask.wishType = eventTypeMap.get(taskTypeNameMerge.WhatId);
                            mergeInfoWithTask.nameField = eventNameMap.get(taskTypeNameMerge.WhatId);
                        }
                        
                    } else if(wishNameMap.containsKey(taskTypeNameMerge.WhatId)) {
                        mergeInfoWithTask.wishType = 'Wish';
                        mergeInfoWithTask.nameField = wishNameMap.get(taskTypeNameMerge.WhatId);
                    } else if (caseSubMap.containsKey(taskTypeNameMerge.WhatId)) {
                        mergeInfoWithTask.wishType = 'Wish';
                        mergeInfoWithTask.nameField = wishNameMap.get(caseSubMap.get(taskTypeNameMerge.WhatId));
                    }
                }
                openActivitiesList.add(mergeInfoWithTask);
            }
        }
        
        return openActivitiesList;
    }
    
    
    //Used to pull all open activities for volunteer
    public List<CloseActivitiesWrapper> getCloseActivities() {
        
        List<CloseActivitiesWrapper> closedActivitiesList = new List<CloseActivitiesWrapper>();
        Set<Id> wishTypeTaskSet = new Set<Id>();
        Set<Id> nonWishAndEvents = new Set<Id>();
        Set<Id> volunteerOpportunityIdSet = new Set<Id>();
        
        Map<Id,String> eventTypeMap = new Map<Id, String>();
        
        Map<Id, String> eventNameMap = new Map<Id, String>();
        Map<Id, String> wishNameMap = new Map<Id, String>();
        //List<Task> openActivities = Database.Query('SELECT Id, WhatId, What.Type, WhoId, Subject, ActivityDate, Status FROM Task WHERE Status = \'Completed\' AND OwnerId =:volunteerUserId');
        List<Task> openActivities = Database.Query('SELECT Id, WhatId, What.Type, WhoId, Subject, ActivityDate, Status FROM Task WHERE Status = \'Completed\' ORDER BY LastModifiedDate DESC'); 
        if(openActivities.size() > 0) {
            for(Task checkType : openActivities) {
                if(checkType.what.Type == 'Case') {
                    wishTypeTaskSet.add(checkType.WhatId);
                }
                if(checkType.what.Type == 'Non_Wish_Events__c') {
                    nonWishAndEvents.add(checkType.WhatId);
                }
                if(checkType.what.Type == 'Volunteer_Opportunity__c') {
                    volunteerOpportunityIdSet.add(checkType.WhatId);
                }
            }
            Map<Id, Id> caseSubMap = new Map<Id, Id>();
            
            if(volunteerOpportunityIdSet.size() > 0) {
                for(Volunteer_Opportunity__c volOppInfo : [SELECT Id, Non_Wish_Event__c,Wish__r.ContactId,Non_Wish_Event__r.Event_Name__c, Non_Wish_Event__r.RecordType.Name, Wish__c FROM Volunteer_Opportunity__c WHERE Id IN : volunteerOpportunityIdSet]) {
                    if(volOppInfo.Wish__c != null) {
                        wishTypeTaskSet.add(volOppInfo.Wish__c);
                        //eventNameMap.put(volOppInfo.Id,volOppInfo.Wish__r.ContactId);
                        caseSubMap.put(volOppInfo.Id,volOppInfo.Wish__c);
                    }
                    if(volOppInfo.Non_Wish_Event__c != null) {
                        nonWishAndEvents.add(volOppInfo.Id);
                        eventTypeMap.put(volOppInfo.Id, volOppInfo.Non_Wish_Event__r.RecordType.Name);
                        eventNameMap.put(volOppInfo.Id, volOppInfo.Non_Wish_Event__r.Event_Name__c);
                    }
                }
            }
            
            
            if(nonWishAndEvents.size() > 0) {
                for(Non_Wish_Events__c getRecordType : [SELECT Id, Event_Name__c, RecordTypeId, RecordType.Name FROM Non_Wish_Events__c WHERE Id IN : nonWishAndEvents]) {
                    eventTypeMap.put(getRecordType.Id, getRecordType.RecordType.Name);
                    eventNameMap.put(getRecordType.Id, getRecordType.Event_Name__c);
                }
            }
            
            if(wishTypeTaskSet.size() > 0) {
                for(Case getContactName : [SELECT Id, Contact.Name FROM Case WHERE Id IN : wishTypeTaskSet]) {
                    wishNameMap.put(getContactName.Id, getContactName.Contact.Name);
                }
            }
            
            
            
            for(Task taskTypeNameMerge : openActivities) {
                
                CloseActivitiesWrapper mergeInfoWithTask = new CloseActivitiesWrapper();
                mergeInfoWithTask.volunteerTask = taskTypeNameMerge;
                if(taskTypeNameMerge.WhatId != null) {
                    if(eventTypeMap.containsKey(taskTypeNameMerge.WhatId)) {
                        if(eventNameMap.containsKey(taskTypeNameMerge.WhatId)) {
                            mergeInfoWithTask.wishType = eventTypeMap.get(taskTypeNameMerge.WhatId);
                            mergeInfoWithTask.nameField = eventNameMap.get(taskTypeNameMerge.WhatId);
                        }
                        
                    } else if(wishNameMap.containsKey(taskTypeNameMerge.WhatId)) {
                        mergeInfoWithTask.wishType = 'Wish';
                        mergeInfoWithTask.nameField = wishNameMap.get(taskTypeNameMerge.WhatId);
                    } else if (caseSubMap.containsKey(taskTypeNameMerge.WhatId)) {
                        mergeInfoWithTask.wishType = 'Wish';
                        mergeInfoWithTask.nameField = wishNameMap.get(caseSubMap.get(taskTypeNameMerge.WhatId));
                    }
                }
                closedActivitiesList.add(mergeInfoWithTask);
            }
        }
        return closedActivitiesList;
    }
    
    
    public PageReference closeTask() {
        List<Task> taskList = [SELECT Id FROM Task WHERE Id =: taskId];
        if(taskList.size() > 0) {
            taskList[0].Status = 'Completed';
            update taskList;
        }
        PageReference pg = new PageReference('/VolunteerActivities_VF');
        return pg;
    }
    public class OpenActivitiesWrapper {
        public Task volunteerTask {get; set;}
        public string wishType {get;set;}
        public string nameField {get;set;}
    }    
    
    public class CloseActivitiesWrapper {
        public Task volunteerTask {get; set;}
        public string wishType {get;set;}
        public string nameField {get;set;}
    }
}