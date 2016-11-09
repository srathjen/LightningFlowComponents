/*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kesavakumar Murugesan
Date        : 5/31/2016
Description : This class is used to create recurrence task for child wishes based on wish chapter name, wish stage and wish type.
It would look for matching records in the chapter action object and create tasks by referring the details in that object
if the previously opened related task is completed.
*******************************************************************************************************************/
global class WishTaskRecurrence_AC implements Database.Batchable<sObject> {
    
    Constant_AC  constant = new Constant_Ac();    
    Id wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
    Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
    
    //This method is used to get all open child wishes except parent wishes and wish type not equals to null. 
    global Database.QueryLocator Start(Database.BatchableContext BC) {
        
        String query = 'SELECT Id, RecordTypeId, ContactId, Wish_type__c, Chapter_Name__c, Subject, Status FROM Case  WHERE isClosed = false AND RecordTypeId !=: parentWishRecordTypeId and Wish_type__c != null';
        return Database.getQueryLocator(query);
    }
    
    //This method is used to create recurrence task for child wishes if the wish is not closed and related task with status completed
    global void Execute(Database.BatchableContext BC, List<Case> caseList) {
        Map<Id,Case> recurrenceTaskCasesMap = new Map<Id,Case>();
        for(Case recurrenceCase: caseList) {
            recurrenceTaskCasesMap.put(recurrenceCase.Id, recurrenceCase);
        }
        Map<Id,List<Task>> closedRecurrenceTasksMap = new Map<Id,List<Task>>();
        // Used to pull all non recurrence completed task
        for(Task closedTask : [SELECT Id, WhatId, CreatedDate, OwnerId, Status, Subject FROM Task WHERE WhatId IN : recurrenceTaskCasesMap.keySet() AND Status = 'Completed' AND isRecurrenceTask__c = false]) {
            if(closedRecurrenceTasksMap.containsKey(closedTask.WhatId)) {
                closedRecurrenceTasksMap.get(closedTask.WhatId).add(closedTask);
            } else {
                closedRecurrenceTasksMap.put(closedTask.WhatId, new List<Task>{closedTask});
            }
        }
        Set<String> wishTypeNamesSet = new Set<String>();
        Set<String> wishChaptersSet = new Set<String>();
        for(Case recurrenceCase : caseList) {
            If(closedRecurrenceTasksMap.containskey(recurrenceCase.Id)) {
                wishTypeNamesSet.add(recurrenceCase.Wish_Type__c);
                wishChaptersSet.add(recurrenceCase.Chapter_Name__c);
            }
        }
        
        Map<String, List<Chapter_Action_Track__c>> actionTracksMap = new Map<String,List<Chapter_Action_Track__c>>();
        for(Chapter_Action_Track__c actionTrack : [SELECT Id, Assigned_To__c, Wish_Type__c, Sort_Order__c, Name, Chapter_Name__r.Name, Recurring__c, Recurring_Frequency__c, Due_Date__c, 
                                                   Case_Type_Stage__c, Task_Name__c FROM Chapter_Action_Track__c WHERE Wish_Type__c IN : wishTypeNamesSet AND Chapter_Name__r.Name IN : wishChaptersSet]) {
                                                       if(actionTracksMap.containskey(actionTrack.Wish_Type__c)) {
                                                           actionTracksMap.get(actionTrack.Wish_Type__c).add(actionTrack);
                                                       } else { 
                                                           actionTracksMap .put(actionTrack.Wish_Type__c,new List<Chapter_Action_Track__c>{actionTrack});
                                                       }
                                                   }
        //Used to create recurrence task
        List<Task> newrecurrenceTaskList = new List<Task>();
        if(closedRecurrenceTasksMap.size()>0) {
            for(Id recTask : closedRecurrenceTasksMap.keySet()) {
                if(closedRecurrenceTasksMap.containsKey(recTask)) {
                    for(Task recTasks : closedRecurrenceTasksMap.get(recTask)) {
                        if(recurrenceTaskCasesMap.containsKey(recTasks.WhatId)) {
                            String wishType = recurrenceTaskCasesMap.get(recTasks.WhatId).Wish_Type__c;
                            for(Chapter_Action_Track__c chapterActionTrack : actionTracksMap.get(wishType)) {
                                if(recurrenceTaskCasesMap.get(recTasks.WhatId).Subject == chapterActionTrack.Case_Type_Stage__c && recTasks.Subject == chapterActionTrack.Task_Name__c 
                                   && System.today().daysBetween(Date.valueOf(recTasks.CreatedDate))/chapterActionTrack.Recurring_Frequency__c == 1 && chapterActionTrack.Recurring__c == true && chapterActionTrack.Chapter_Name__r.Name == recurrenceTaskCasesMap.get(recTasks.WhatId).Chapter_Name__c){
                                       Task newTask = new Task();
                                       newTask.ActivityDate = System.today()+Integer.valueOf(chapterActionTrack.Due_Date__c);
                                       newTask.WhatId = recTasks.WhatId;
                                       newTask.WhoId = recurrenceTaskCasesMap.get(recTasks.WhatId).ContactId;
                                       newTask.OwnerId = recTasks.OwnerId;
                                       newTask.Subject = recTasks.Subject;
                                       newTask.Sort_Order__c = chapterActionTrack.Sort_Order__c;
                                       newTask.TaskVolunteerRole__c = chapterActionTrack.Assigned_To__c;
                                       newTask.isRecurrenceTask__c = true;
                                       newrecurrenceTaskList.add(newTask);
                                   }
                            }                            
                        }
                    }
                }
            }
        }
        if(newrecurrenceTaskList.size()>0) {
            insert newrecurrenceTaskList; //Used to create recurrence task
        }
    }   
    
    global void Finish(Database.BatchableContext BC) {
    }
}