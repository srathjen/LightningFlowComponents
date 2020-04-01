global class batch_BUpdateAffiliation_AC implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
                SELECT Id, npe5__Contact__c,npe5__Status__c
                FROM npe5__Affiliation__c
                WHERE npe5__Contact__r.RecordType.Name = :Constant_AC.VOLUNTEER_RT_LABEL AND npe5__Primary__c = TRUE
                AND npe5__Status__c != :Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE AND npe5__Status__c != :Constant_AC.ORG_AFFILIATION_STATUS_PENDING
        ]);
    }

    global void execute(Database.BatchableContext BC, List<npe5__Affiliation__c> AffiliationList) {
        // Declarations
        Set<Id> volunteerIdsSet = new Set<Id>();
        List<Volunteer_Roles__c> volRoleList = new List<Volunteer_Roles__c>();
        Map<Id, List<Volunteer_Roles__c>> volunteerRoleStatusMap = new Map<Id, List<Volunteer_Roles__c>>();

        //Fetch affiliation records based on the volunteer contact and primary
        for (npe5__Affiliation__c currAff : AffiliationList) {
            volunteerIdsSet.add(currAff.npe5__Contact__c);
        }

        //Fetch Volunteer role records based on the volunteerIdsSet
        for (Volunteer_Roles__c currVolRole : [
                SELECT Id,Status__c,Volunteer_Name__c
                FROM Volunteer_Roles__c
                WHERE Volunteer_Name__c IN :volunteerIdsSet
        ]) {
			if (!volunteerRoleStatusMap.containsKey(currVolRole.Volunteer_Name__c)) {
				volunteerRoleStatusMap.put(currVolRole.Volunteer_Name__c, new List<Volunteer_Roles__c>());
			}
			volunteerRoleStatusMap.get(currVolRole.Volunteer_Name__c).add(currVolRole);
            volRoleList.add(currVolRole);
        }

        VolunteerRole_OnAfterInsertHelper_AC.updateVolunteerRoleStatus(volunteerRoleStatusMap, 'Update', volRoleList);
    }

    global void finish(Database.BatchableContext BC) {
    }
}