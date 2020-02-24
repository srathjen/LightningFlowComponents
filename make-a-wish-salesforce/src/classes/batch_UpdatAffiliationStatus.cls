/**
 * JIRA: WLP-422
 * Author: Gustavo Mayer
 * Update: Changing the Volunteer_Roles status from 'Trained' to 'Active'
 */
global class batch_UpdatAffiliationStatus implements Database.Batchable<AggregateResult> {

	private String volunteerTaskRtLabel = Constant_AC.VOLUNTEER_TASK_RT_LABEL;
	private String volunteerRtLabel = Constant_AC.VOLUNTEER_RT_LABEL;
	private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;

	global Iterable<AggregateResult> start(Database.BatchableContext bc) {
		List<AggregateResult> volunteerOppList = [
				SELECT npe5__Contact__c
				FROM npe5__Affiliation__c
				WHERE
				npe5__Contact__r.RecordType.Name = :volunteerRtLabel
				AND npe5__Status__c != 'Inactive'
				AND Constituent_Code__c = :volunteerTaskRtLabel
				AND Hidden_Status_Updated__c = FALSE
				AND npe5__Organization__r.RecordType.Name = 'Chapter'
				AND Migrated_Record__c = TRUE
				GROUP BY npe5__Contact__c
		];
		return volunteerOppList;
	}

	global void execute(Database.BatchableContext bc, List<AggregateResult> scope) {
		Set<Id> volunteerIds = new Set<Id>();
		Map<Id, String> volunteerRoleMap = new Map<Id, String>();
		Set<Id> bcgAvailable = new Set<Id>();
		Map<Id, Background_check__c> validBCG = new Map<Id, Background_check__c>();
		Map<Id, Conflict_Of_Interest__c> validCOI = new Map<Id, Conflict_Of_Interest__c>();

		for (AggregateResult currVol : scope) {
			volunteerIds.add(String.valueOf(currVol.get('npe5__Contact__c')));
		}

		for (Background_check__c currRec : [
				SELECT Id,Volunteer__c,Date__c
				FROM Background_check__c
				WHERE Volunteer__c IN :volunteerIds
		]) {
			bcgAvailable.add(currRec.Volunteer__c);

			if (currRec.Date__c >= Date.today()) {
				validBCG.put(currRec.Volunteer__c, currRec);
			}
		}

		for (Conflict_Of_Interest__c currRec : [
				SELECT Id,Volunteer_Contact__c, Expiration_Date__c
				FROM Conflict_Of_Interest__c
				WHERE Expiration_Date__c >= :Date.today() AND Volunteer_Contact__c IN :volunteerIds
		]) {
			validCOI.put(currRec.Volunteer_Contact__c, currRec);
		}

		for (Volunteer_Roles__c currContact : [
				SELECT Id, Status__c, Volunteer_Name__c
				FROM Volunteer_Roles__c
				WHERE Volunteer_Name__c IN :volunteerIds
		]) {
			if (volunteerRoleMap.containsKey(currContact.Volunteer_Name__c)) {
				if (volunteerRoleMap.get(currContact.Volunteer_Name__c) != VOLUNTEER_ROLE_STATUS_ACTIVE) {
					volunteerRoleMap.put(currContact.Volunteer_Name__c, currContact.Status__c);
				}
			} else {
				volunteerRoleMap.put(currContact.Volunteer_Name__c, currContact.Status__c);
			}
		}

		List<npe5__Affiliation__c> affList = new List<npe5__Affiliation__c>();
		for (npe5__Affiliation__c currAffiliation : [
				SELECT Id, npe5__Contact__c
				FROM npe5__Affiliation__c
				WHERE
				npe5__Contact__r.RecordType.Name = :volunteerRtLabel
				AND npe5__Status__c != 'Inactive'
				AND Constituent_Code__c = :volunteerTaskRtLabel
				AND npe5__Organization__r.RecordType.Name = 'Chapter'
				AND npe5__Contact__c IN :volunteerIds
				AND Migrated_Record__c = TRUE
				AND Hidden_Status_Updated__c = FALSE
		]) {
			npe5__Affiliation__c currAff = new npe5__Affiliation__c();
			currAff.Id = currAffiliation.Id;
			if (volunteerRoleMap.get(currAffiliation.npe5__Contact__c) == VOLUNTEER_ROLE_STATUS_ACTIVE
					&& validCOI.containsKey(currAffiliation.npe5__Contact__c)) {

				if (bcgAvailable.contains(currAffiliation.npe5__Contact__c)) {
					if (validBCG.containsKey(currAffiliation.npe5__Contact__c)) {
						currAff.npe5__Status__c = 'Active';
					} else {
						currAff.npe5__Status__c = 'Inactive';
					}
				} else {
					currAff.npe5__Status__c = 'Active';
				}
			} else if (volunteerRoleMap.get(currAffiliation.npe5__Contact__c) != VOLUNTEER_ROLE_STATUS_ACTIVE
					&& validCOI.containsKey(currAffiliation.npe5__Contact__c)) {
				if (bcgAvailable.contains(currAffiliation.npe5__Contact__c)) {
					if (validBCG.containsKey(currAffiliation.npe5__Contact__c)) {
						currAff.npe5__Status__c = 'Pending';
					} else {
						currAff.npe5__Status__c = 'Inactive';
					}
				} else {
					currAff.npe5__Status__c = 'Pending';
				}
			} else {
				currAff.npe5__Status__c = 'Inactive';
				currAff.Hidden_Status_Updated__c = true;
				affList.add(currAff);
			}
		}
		if (affList.size() > 0) {
			update affList;
		}
	}

	global void finish(Database.BatchableContext bc) {
	}
}