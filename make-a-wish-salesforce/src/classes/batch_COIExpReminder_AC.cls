/**
 * @description Send reminder for Volunteers if their COI is expiring in next 30 days
 * @author MST
 * @createdDate 11/16/2017
 */
global class batch_COIExpReminder_AC implements Database.Batchable<sObject> {
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([
				SELECT Id, Expiration_Date__c, Current__c, Volunteer_Contact__c, Volunteer_Contact__r.Name
				FROM Conflict_Of_Interest__c
				WHERE Current__c = TRUE
				AND Expiration_Date__c = NEXT_N_DAYS:30
		]);
	}

	global void execute(Database.BatchableContext BC, List<Conflict_Of_Interest__c> coiExpiredList) {
		List<Conflict_Of_Interest__c> sendReminderToVolunteerList = new List<Conflict_Of_Interest__c>();
		for (Conflict_Of_Interest__c coiExpired : coiExpiredList) {
			if (coiExpired.Expiration_Date__c.daysBetween(Date.today()) == -30
					|| coiExpired.Expiration_Date__c.daysBetween(Date.today()) == -23
					|| coiExpired.Expiration_Date__c.daysBetween(Date.today()) == -16
					|| coiExpired.Expiration_Date__c.daysBetween(Date.today()) == -9
					|| coiExpired.Expiration_Date__c.daysBetween(Date.today()) == -2) {
				coiExpired.Hidden_Trigger_COI_Exp_Reminder__c = true;
				sendReminderToVolunteerList.add(coiExpired);
			}
		}
		if (sendReminderToVolunteerList.size() > 0) {
			update sendReminderToVolunteerList;
		}
	}

	global void finish(Database.BatchableContext BC) {
	}
}