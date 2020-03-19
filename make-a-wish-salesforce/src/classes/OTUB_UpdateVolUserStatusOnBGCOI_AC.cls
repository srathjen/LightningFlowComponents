/**
 * @description Update COI and BG Volunteer Status Active Hidden field based on Org Affiliation status
 * @author MST
 * @createdDate
 */
global class OTUB_UpdateVolUserStatusOnBGCOI_AC implements Database.Batchable<SObject> {

	private static String AFFILIATION_STATUS_ACTIVE = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
	private static String AFFILIATION_STATUS_INACTIVE = Constant_AC.ORG_AFFILIATION_STATUS_INACTIVE;

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([
				SELECT Id, npe5__Contact__c
				FROM npe5__Affiliation__c
				WHERE (npe5__Status__c = :AFFILIATION_STATUS_ACTIVE OR npe5__Status__c = :AFFILIATION_STATUS_INACTIVE)
				AND npe5__Primary__c = TRUE
		]);
	}

	global void execute(Database.BatchableContext BC, List<npe5__Affiliation__c> affiliations) {
		Set<Id> contactIds = new Set<Id>();
		Map<Id, Background_check__c> backGroundContactMap = new Map<Id, Background_check__c>();
		Map<Id, Conflict_Of_Interest__c> coiContactMap = new Map<Id, Conflict_Of_Interest__c>();
		List<Background_check__c> backgroundChecks = new List<Background_check__c>();
		List<Conflict_Of_Interest__c> conflictOfInterests = new List<Conflict_Of_Interest__c>();

		for (npe5__Affiliation__c affiliation : affiliations) {
			contactIds.add(affiliation.npe5__Contact__c);
		}

		for (Background_check__c bgc : [
				SELECT Id, Current__c, Date__c, Volunteer__c, Volunteer_is_Inactive__c
				FROM Background_check__c
				WHERE Volunteer__c IN:contactIds
				AND Current__c = TRUE
		]) {
			backGroundContactMap.put(bgc.Volunteer__c, bgc);
		}

		for (Conflict_Of_Interest__c coi : [
				SELECT Id,Expiration_Date__c,Volunteer_Contact__c, Volunteer_is_Inactive__c
				FROM Conflict_Of_Interest__c
				WHERE Volunteer_Contact__c IN:contactIds AND Current__c = TRUE
		]) {
			coiContactMap.put(coi.Volunteer_Contact__c, coi);
		}

		for (npe5__Affiliation__c affiliation : [
				SELECT Id, npe5__Contact__c, npe5__Status__c
				FROM npe5__Affiliation__c
				WHERE npe5__Primary__c = TRUE
				AND (npe5__Status__c = :AFFILIATION_STATUS_ACTIVE OR npe5__Status__c = :AFFILIATION_STATUS_INACTIVE)
				AND npe5__Contact__c IN :contactIds
		]) {
			if (affiliation.npe5__Status__c == AFFILIATION_STATUS_ACTIVE) {
				if (backGroundContactMap.containsKey(affiliation.npe5__Contact__c)
						&& backGroundContactMap.get(affiliation.npe5__Contact__c).Volunteer_is_Inactive__c) {
					backGroundContactMap.get(affiliation.npe5__Contact__c).Volunteer_is_Inactive__c = false;
					backgroundChecks.add(backGroundContactMap.get(affiliation.npe5__Contact__c));
				}
				if (coiContactMap.containsKey(affiliation.npe5__Contact__c)
						&& coiContactMap.get(affiliation.npe5__Contact__c).Volunteer_is_Inactive__c) {
					coiContactMap.get(affiliation.npe5__Contact__c).Volunteer_is_Inactive__c = false;
					conflictOfInterests.add(coiContactMap.get(affiliation.npe5__Contact__c));
				}
			} else {
				if (backGroundContactMap.containsKey(affiliation.npe5__Contact__c)
						&& !backGroundContactMap.get(affiliation.npe5__Contact__c).Volunteer_is_Inactive__c) {
					backGroundContactMap.get(affiliation.npe5__Contact__c).Volunteer_is_Inactive__c = true;
					backgroundChecks.add(backGroundContactMap.get(affiliation.npe5__Contact__c));
				}
				if (coiContactMap.containsKey(affiliation.npe5__Contact__c)
						&& !coiContactMap.get(affiliation.npe5__Contact__c).Volunteer_is_Inactive__c) {
					coiContactMap.get(affiliation.npe5__Contact__c).Volunteer_is_Inactive__c = true;
					conflictOfInterests.add(coiContactMap.get(affiliation.npe5__Contact__c));
				}
			}
		}
		if (!conflictOfInterests.isEmpty()) {
			update conflictOfInterests;
		}
		if (!backgroundChecks.isEmpty()) {
			update backgroundChecks;
		}
	}
	global void finish(Database.BatchableContext BC) {
	}
}