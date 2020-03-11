/**
 * @description This class is used to set the Age_Requirement_Met__c field to True on lead when a wish child turns 2.5 years old.
 * @author MAWA
 * @createdDate 4/25/2019
 * @updatedDate 05/20/2019 - Samer - SIW-252
 * @update Modified code to use Apex Date methods when calculating age, and added code for End-of-Month date calculation exceptions
 */
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

	global void execute(Database.BatchableContext bc, List<Lead> scope) {
		List<Lead> updateLeads = new List<Lead>();
		for (Lead leads : scope) {
			Integer daysInCurrentMonth = Date.daysInMonth(runDate.year(), runDate.month());
			Date twoAndHalfToday = runDate.addYears(-2).addMonths(-6);
			Integer daysInSixthMonth = Date.daysInMonth(twoAndHalfToday.year(), twoAndHalfToday.month());
			if ((runDate.day() == daysInCurrentMonth) && (daysInCurrentMonth < daysInSixthMonth)) {
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
		if (updateLeads.size() > 0) {
			update updateLeads;
		}
	}

	global void finish(Database.BatchableContext bc) {
	}
}