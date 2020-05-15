/**
 * @description : This class is used send reminder for Volunteers if their Background Check is expiring in next 30 days
 *
 * @author : MST Solutions
@createdDate : 11/13/2017
 **/
global class batch_BGCExpReminder_AC implements Database.Batchable<SObject>, Schedulable {

    @TestVisible private static final Date TODAY = Date.today();
    private final static String BACKGROUND_CHECK_STATUS_REJECTED = Constant_AC.BACKGROUND_CHECK_STATUS_REJECTED;

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
                SELECT Id, Date__c, Current__c, CreatedDate, Volunteer__c, Volunteer__r.Name
                FROM Background_check__c
                WHERE Current__c = TRUE
                AND (Status__c != NULL AND Status__c != :BACKGROUND_CHECK_STATUS_REJECTED)
                AND Date__c = NEXT_N_DAYS:30
        ]);
    }

    global void execute(Database.BatchableContext BC, List<Background_check__c> backGroundCheckExpiredList) {
        Map<Id, Background_check__c> checkBGInitaitionProcessMap = new Map<Id, Background_check__c>();
        Set<Id> initiatedBGVolConSet = new Set<Id>();
        List<Background_check__c> sendReminderToVolunteerList = new List<Background_check__c>();

        for (Background_check__c bcExpired : backGroundCheckExpiredList) {
            if (bcExpired.Date__c.daysBetween(TODAY) == -30
                    || bcExpired.Date__c.daysBetween(TODAY) == -23
                    || bcExpired.Date__c.daysBetween(TODAY) == -16
                    || bcExpired.Date__c.daysBetween(TODAY) == -9
                    || bcExpired.Date__c.daysBetween(TODAY) == -2) {
                checkBGInitaitionProcessMap.put(bcExpired.Volunteer__c, bcExpired);
            }
        }
        if (!checkBGInitaitionProcessMap.isEmpty()) {
            for (Background_check__c initiatedBg : [
                    SELECT Id, Status__c, CreatedDate, Volunteer__c
                    FROM Background_check__c
                    WHERE Volunteer__c IN :checkBGInitaitionProcessMap.keySet()
                    AND Status__c = NULL
                    AND Date__c = NULL
                    ORDER BY CreatedDate DESC
            ]) {
                if (checkBGInitaitionProcessMap.containsKey(initiatedBg.Volunteer__c)
                        && initiatedBg.CreatedDate >= checkBGInitaitionProcessMap.get(initiatedBg.Volunteer__c).CreatedDate) {
                    initiatedBGVolConSet.add(initiatedBg.Volunteer__c);
                }
            }
            for (Id expiredBG : checkBGInitaitionProcessMap.keySet()) {
                if (!initiatedBGVolConSet.contains(expiredBG) && checkBGInitaitionProcessMap.containsKey(expiredBG)) {
                    checkBGInitaitionProcessMap.get(expiredBG).Hidden_Trigger_BGC_Exp_Reminder__c = true;
                    sendReminderToVolunteerList.add(checkBGInitaitionProcessMap.get(expiredBG));
                }
            }
        }
        update sendReminderToVolunteerList;
    }

    global void finish(Database.BatchableContext BC) {
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new batch_BGCExpReminder_AC(), 200);
    }
}