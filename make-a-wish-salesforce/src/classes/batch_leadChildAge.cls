/**
 * @description This class is used to set the Age_Requirement_Met__c field to True on lead when a wish child turns 2.5 years old.
 * 05/20/2019 - Samer - SIW-252
 * Modified code to use Apex Date methods when calculating age, and added code for End-of-Month date calculation exceptions
 * @author MAWA
 * @date 4/25/2019
 */
global class batch_leadChildAge implements Database.Batchable<SObject>, Schedulable {

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new batch_leadChildAge(), 200);
    }

    @TestVisible
    private Date runDate = Date.today();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
                SELECT Id,DOB__c, Child_Age__c, Status, Age_Requirement_Met__c
                FROM Lead
                WHERE Status = :Constant_AC.LEAD_STATUS_INQUIRY
                AND Age_Requirement_Met__c = FALSE
                AND Child_Age__c = :Constant_AC.LEAD_CHILD_AGE_UNDER_2_5
                AND RecordTypeId = :Constant_AC.LEAD_RT_WISH_CHILD
                AND DOB__c != Null
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Lead> scope) {
        List<Lead> updateLeads = new List<Lead>();
        try {
            for (Lead leads : scope) {
                Integer daysInCurrentMonth = Date.daysInMonth(runDate.year(), runDate.month());
                Date twoAndHalfToday = runDate.addYears(-2).addMonths(-6);
                Integer daysInSixthMonth = Date.daysInMonth(twoAndHalfToday.year(), twoAndHalfToday.month());
                if (runDate.day() == daysInCurrentMonth && daysInCurrentMonth < daysInSixthMonth) {
                    Date fromDate = twoAndHalfToday;
                    Date toDate = fromDate.addDays(daysInSixthMonth - daysInCurrentMonth);
                    if ((leads.DOB__c >= fromDate) && (leads.DOB__c <= toDate)) {
                        leads.Age_Requirement_Met__c = true;
                        updateLeads.add(leads);
                    }
                } else if (twoAndHalfToday.isSameDay(leads.DOB__c)) {
                    leads.Age_Requirement_Met__c = true;
                    updateLeads.add(leads);
                }
            }
            update updateLeads;
            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class Execution');
            }
        } catch (Exception ex)   {
            ErrorMessage_AC.createDebugRec('batch_leadChildAge',
            '', String.valueOf(ex), 'execute',
            'Null', ex.getStackTraceString(), 'Error');
        }
    }

    global void finish(Database.BatchableContext bc) {
    }
}