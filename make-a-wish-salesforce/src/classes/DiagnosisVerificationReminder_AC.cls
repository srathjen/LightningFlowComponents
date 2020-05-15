global class DiagnosisVerificationReminder_AC implements Database.Batchable<SObject>, Schedulable {
    @TestVisible
    private static final Date TODAY = Date.today();

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
                SELECT Id, Status, Sub_Status__c, OwnerId, Referred_Date__c,
                        Part_A_Sent__c, Treating_Medical_Professional_Email__c
                FROM Lead
                WHERE Status = :Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION
                OR Status = :Constant_AC.LEAD_STATUS_REFERRED
        ]);
    }

    global void execute(Database.BatchableContext BC, List<Lead> leadList) {
        List<Task> createTask = new List<Task>();
        List<Lead> updateLead = new List<Lead>();
        String days;
        for (Lead lead : leadList) {
            days = null;
            if (lead.Status == Constant_AC.LEAD_STATUS_REFERRED && lead.Referred_Date__c.addDays(3) == TODAY) {
                days = '3';
            } else if (lead.Sub_Status__c == Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION) {
                if (lead.Part_A_Sent__c.addDays(7) == TODAY) {
                    days = '7';
                } else if (lead.Part_A_Sent__c.addDays(14) == TODAY) {
                    days = '14';
                } else if (lead.Part_A_Sent__c.addDays(21) == TODAY) {
                    days = '21';
                }
                if (days != null) {
                    updateLead.add(updateLeadDiagnosisPendingDays(lead.Id, days));
                }
            }
            if (days != null) {
                createTask.add(createReminderTask(lead, days));
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new DiagnosisVerificationReminder_AC(), 25);
    }

    //Create task as reminder to complete diagnosis verification
    private Task createReminderTask(Lead lead, String days) {
        Task task = new Task();
        task.OwnerId = lead.OwnerId;
        task.Priority = Constant_AC.TASK_PRIORITY_NORMAL;
        task.Status = Constant_AC.TASK_STATUS_NOT_STARTED;
        if (lead.Status == Constant_AC.LEAD_STATUS_REFERRED) {
            task.Subject = Constant_AC.TASK_SUBJECT_SEND_DIAGNOSIS_VERIFICATION;
        } else if (lead.Sub_Status__c == Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION) {
            task.Subject = days + ' ' + Constant_AC.TASK_SUBJECT_REMINDER_FOR_DIAGNOSIS_VERIFICATION;
        }
        task.WhoId = lead.Id;
        task.Account_Email__c = lead.Treating_Medical_Professional_Email__c;
        return task;
    }

    //Update number of days pending diagnosis verification on lead
    private Lead updateLeadDiagnosisPendingDays(Id leadId, String days) {
        Lead lead = new Lead(Id = leadId);
        lead.Diagnosis_Pending_Days__c = days;
        return lead;
    }
}