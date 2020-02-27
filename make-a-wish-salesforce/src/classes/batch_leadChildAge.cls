/******************************************************************************
Author : MAWA
Created Date: 4/25/2019
Description:  This class is used to set the Age_Requirement_Met__c field to 
              True on lead when a wish child turns 2.5 years old.
Modification: 05/20/2019 - Samer - SIW-252
              Modified code to use Apex Date methods when calculating age, and
              added code for End-of-Month date calculation exceptions 
*******************************************************************************/
global class batch_leadChildAge implements Database.Batchable<SObject> {

	@TestVisible
	private Date runDate = Date.today();

	global Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator([
				SELECT Id,DOB__c, Child_Age__c, Status, Age_Requirement_Met__c
				FROM Lead
				WHERE Status = :Constant_AC.LEAD_STATUS_INQUIRY
				AND Age_Requirement_Met__c = FALSE
				AND Child_Age__c = :Constant_AC.LEAD_CHILD_AGE_UNDER_2_5
		]);
	}

	global void execute(Database.BatchableContext bc, List<Lead> leads) {
		List<Lead> updateLeads = new List<Lead>();
        // Get last day of the current month
        Integer lastDayOfRunDateMonth = Date.daysInMonth(runDate.year(), runDate.month());
        // Subtract 2 years and 6 months from current date
        Date twoAndHalfYearsAgoBeforeRunDate = runDate.addYears(-2).addMonths(-6);
        // Get last day of DOB month
        Integer daysInSixthMonth = Date.daysInMonth(twoAndHalfYearsAgoBeforeRunDate.year(), twoAndHalfYearsAgoBeforeRunDate.month());
        // Is today the last day of the current month
        Date fromDate = twoAndHalfYearsAgoBeforeRunDate;
        Date toDate = fromDate.addDays(daysInSixthMonth - lastDayOfRunDateMonth);
		for (Lead leadRecord : leads) {
			if ((runDate.day() == lastDayOfRunDateMonth) && (lastDayOfRunDateMonth < daysInSixthMonth)) {
				if ((leadRecord.DOB__c >= fromDate) && (leadRecord.DOB__c <= toDate)) {
					leadRecord.Age_Requirement_Met__c = true;
					updateLeads.add(leadRecord);
				}
			}
            // Compare Lead's DOB to twoAndHalfToday
            else if (twoAndHalfYearsAgoBeforeRunDate.isSameDay(leadRecord.DOB__c)) {
				leadRecord.Age_Requirement_Met__c = true;
				updateLeads.add(leadRecord);
			}
		}
		if (updateLeads.size() > 0) {
			update updateLeads;
		}
	}

	global void finish(Database.BatchableContext bc) {
	}
}