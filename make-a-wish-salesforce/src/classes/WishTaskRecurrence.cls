global class WishTaskRecurrence implements Database.Batchable<sObject> {
    
    Constant_AC  constant = new Constant_Ac();    
    Id wishDeterminationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishDeterminationRT).getRecordTypeId();
    Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query = 'SELECT Id, RecordTypeId, ContactId, Wish_type__c, ChapterName__r.Name,Subject, Status FROM Case  WHERE isClosed = false AND RecordTypeId !=: parentWishRecordTypeId and Wish_type__c != NULL';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> caseList) {
        Map<Id,Case> recurrenceTaskCasesMap = new Map<Id,Case>();
        for(Case recurrenceCases: caseList) {
            recurrenceTaskCasesMap.put(recurrenceCases.Id, recurrenceCases);
        }
        Map<Id,List<Task>> closedRecurrenceTasksMap = new Map<Id,List<Task>>();
        for(Task closedTasks : [SELECT Id, WhatId,CreatedDate,OwnerId, Status, Subject FROM Task WHERE WhatId IN : recurrenceTaskCasesMap.keySet() AND Status = 'Completed' AND isRecurrenceTask__c = false]) {
            if(closedRecurrenceTasksMap.containsKey(closedTasks.WhatId)) {
                closedRecurrenceTasksMap.get(closedTasks.WhatId).add(closedTasks);
            } else {
                closedRecurrenceTasksMap.put(closedTasks.WhatId, new List<Task>{closedTasks});
            }
        }
        Set<String> wishTypeNamesSet = new Set<String>();
        Set<String> wishChaptersSet = new Set<String>();
        List<Case> caseWithClosedTasks = new List<Case>();
        For(Case recurrenceCases : caseList) {
            If(closedRecurrenceTasksMap.containskey(recurrenceCases.Id)) {
                wishTypeNamesSet.add(recurrenceCases.Wish_Type__c);
                caseWithClosedTasks.add(recurrenceCases);
                wishChaptersSet.add(recurrenceCases.ChapterName__r.Name);
            }
        }
        
        Map<String, List<Chapter_Action_Track__c>> actionTrackMap = new Map<String,List<Chapter_Action_Track__c>>();
        For(Chapter_Action_Track__c actionTrackList : [SELECT Id, Assigned_To__c,Wish_Type__c,Sort_Order__c,Name,Chapter_Name__r.Name,Recurring__c,Recurring_Frequency__c,Due_Date__c, Case_Type_Stage__c,Task_Name__c FROM Chapter_Action_Track__c WHERE Wish_Type__c IN : wishTypeNamesSet AND Chapter_Name__r.Name IN : wishChaptersSet]) {
            If(actionTrackMap.containskey(actionTrackList.Wish_Type__c)) {
                actionTrackMap.get(actionTrackList.Wish_Type__c).add(actionTrackList);
            } else { 
                actionTrackMap .put(actionTrackList.Wish_Type__c,new List<Chapter_Action_Track__c>{actionTrackList});
            }
        }
        List<Task> newrecurrenceTaskList = new List<Task>();
        if(closedRecurrenceTasksMap.size()>0) {
            for(Id recTas : closedRecurrenceTasksMap.keySet()) {
                if(closedRecurrenceTasksMap.containsKey(recTas)) {
                    for(Task recTasks : closedRecurrenceTasksMap.get(recTas)) {
                        String test = recurrenceTaskCasesMap.get(recTasks.WhatId).Wish_Type__c;
                        
                        for(Chapter_Action_Track__c chapterActionTrack : actionTrackMap.get(test)) {
                            
                            if(recurrenceTaskCasesMap.get(recTasks.WhatId).Subject == chapterActionTrack.Case_Type_Stage__c && recTasks.Subject == chapterActionTrack.Task_Name__c 
                               && System.today().daysBetween(Date.valueOf(recTasks.CreatedDate)+1)/chapterActionTrack.Recurring_Frequency__c == 1 && chapterActionTrack.Recurring__c == true && chapterActionTrack.Chapter_Name__r.Name ==recurrenceTaskCasesMap.get(recTasks.WhatId).ChapterName__r.Name){
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
        if(newrecurrenceTaskList.size()>0) {
            insert newrecurrenceTaskList;
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
    }
}