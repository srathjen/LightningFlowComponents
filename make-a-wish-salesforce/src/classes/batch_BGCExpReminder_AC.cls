/***************************************************************************
Author : MST Solutions
Created Date : 11/13/2017
Description : This class is used send reminder for Volunteers if their Background Check is expiring in next 30 days
****************************************************************************/
global class batch_BGCExpReminder_AC implements Database.Batchable<sObject>, Schedulable {
    
    @TestVisible
    private Date todayDate = Date.today();
    private final static String BACKGROUND_CHECK_STATUS_REJECTED = Constant_AC.BACKGROUND_CHECK_STATUS_REJECTED;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, Date__c, Current__c, CreatedDate, Volunteer__c, Volunteer__r.Name 
            FROM Background_check__c 
            WHERE Current__c = true 
            AND (Status__c != null AND Status__c != :BACKGROUND_CHECK_STATUS_REJECTED) 
            AND Date__c = NEXT_N_DAYS:30
        ]);
    }
    
    global void execute(Database.BatchableContext BC, List<Background_check__c> backGroundCheckExpiredList)  {
        Map<Id, Background_check__c> checkBGInitaitionProcessMap = new Map<Id, Background_check__c>();
        Set<Id> initiatedBGVolConSet = new Set<Id>();
        List<Background_check__c> sendReminderToVolunteerList = new List<Background_check__c>();
        
        for(Background_check__c bcExpired : backGroundCheckExpiredList) {
            if(bcExpired.Date__c.daysBetween(todayDate) == -30 
               || bcExpired.Date__c.daysBetween(todayDate) == -23 
               || bcExpired.Date__c.daysBetween(todayDate) == -16 
               || bcExpired.Date__c.daysBetween(todayDate) == -9 
               || bcExpired.Date__c.daysBetween(todayDate) == -2) {
                   checkBGInitaitionProcessMap.put(bcExpired.Volunteer__c, bcExpired);
               }
        }
        if(!checkBGInitaitionProcessMap.isEmpty()) {
            for(Background_check__c initiatedBg : [SELECT Id, Status__c, CreatedDate, Volunteer__c 
                                                   FROM Background_check__c 
                                                   WHERE Volunteer__c IN :checkBGInitaitionProcessMap.keySet() 
                                                   AND Status__c = null 
                                                   AND Date__c = null 
                                                   ORDER BY CreatedDate DESC]) {
                if(checkBGInitaitionProcessMap.containsKey(initiatedBg.Volunteer__c) 
                   && initiatedBg.CreatedDate >= checkBGInitaitionProcessMap.get(initiatedBg.Volunteer__c).CreatedDate) {
                    if(!initiatedBGVolConSet.contains(initiatedBg.Volunteer__c)) {
                        initiatedBGVolConSet.add(initiatedBg.Volunteer__c);
                    }
                }
            }
        }
        for(Id expiredBG : checkBGInitaitionProcessMap.keySet()) {
            if(!initiatedBGVolConSet.contains(expiredBG)) {
                if(checkBGInitaitionProcessMap.containsKey(expiredBG)) {
                    checkBGInitaitionProcessMap.get(expiredBG).Hidden_Trigger_BGC_Exp_Reminder__c = true;
                    sendReminderToVolunteerList.add(checkBGInitaitionProcessMap.get(expiredBG));
                }
            }
        }
        if(!sendReminderToVolunteerList.isEmpty()) {
            update sendReminderToVolunteerList;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
    global void execute(SchedulableContext SC){
        Database.executeBatch(new batch_BGCExpReminder_AC(), 200);
    }
}