/**
 * @description Update Volunteer Opportunity and Volunteer Role to "Out of Compliance" when the Conflict of Interest is expired
 * @author MST
 * @createdDate
 */
global class batch_CheckCOIExpiration_AC implements Database.Batchable<SObject>, Schedulable {

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([
				SELECT Id, Expiration_Date__c, Current__c, Volunteer_Contact__c
				FROM Conflict_Of_Interest__c
				WHERE Current__c = TRUE
                AND Expiration_Date__c <= TODAY
		]);
	}

	global void execute(Database.BatchableContext BC, List<Conflict_Of_Interest__c> coiExpiredList) {
		Set<Id> contactIds = new Set<Id>();
		for (Conflict_Of_Interest__c coiExpired : coiExpiredList) {
			contactIds.add(coiExpired.Volunteer_Contact__c);
		}
		if (contactIds.size() > 0) {
			BackGroundCheck_OnAfterUpdateHelper.UpdateVOppAndVRoleStatus(contactIds, 'COI', coiExpiredList);
		}
	}

	global void finish(Database.BatchableContext BC) {
	}

	global void execute(SchedulableContext schedulableContext) {
		Database.executeBatch(new batch_CheckCOIExpiration_AC(), 200);
	}
}