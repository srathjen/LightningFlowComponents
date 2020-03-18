/**
 * JIRA: WLP-422
 * Author: Gustavo Mayer
 * Update: Changing the Volunteer_Roles status from 'Trained' to 'Active'
 */
global class batch_VolunteerRoleUpdate implements Database.Batchable<SObject> {

	private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;

	global Database.QueryLocator start(Database.BatchableContext BC) {

		return Database.getQueryLocator([
				SELECT Id,Status__c,Volunteer_Name__c,Role_Name__c,Chapter_Role__c
				FROM Volunteer_Roles__c
				WHERE Migrated_Record__c = TRUE
		]);
	}

	global void execute(Database.BatchableContext BC, List<Volunteer_Roles__c> scope) {
		Set<Id> volunteerContactIds = new Set<Id>();
		Map<Id, List<Volunteer_Roles__c>> volunteerRolesMap = new Map<Id, List<Volunteer_Roles__c>>();
		Map<Id, Volunteer_Roles__c> updateVolunteerRole = new Map<Id, Volunteer_Roles__c>();
		Map<Id, Boolean> volunteerTrainingMap = new Map<Id, Boolean>();
		Set<Id> chapterRoleIds = new Set<Id>();

		for (Volunteer_Roles__c currRole : scope) {
			volunteerContactIds.add(currRole.Volunteer_Name__c);
			chapterRoleIds.add(currRole.Chapter_Role__c);

			if (volunteerRolesMap.containsKey(currRole.Volunteer_Name__c)) {
				volunteerRolesMap.get(currRole.Volunteer_Name__c).add(currRole);
			} else {
				volunteerRolesMap.put(currRole.Volunteer_Name__c, new List<Volunteer_Roles__c>{
						currRole
				});
			}
		}

		for (Volunteer_Orientation_Training__c currTraining : [
				SELECT Id,Class_Offering__c,Class_Offering__r.Chapter_Role_O_T__r.Role_Name__c,
						Volunteer_Attendance__c,Volunteer__c
				FROM Volunteer_Orientation_Training__c
				WHERE Volunteer__c IN :volunteerContactIds
		]) {
			volunteerTrainingMap.put(currTraining.Volunteer__c, true);
			if (volunteerRolesMap.containsKey(currTraining.Volunteer__c)) {
				for (Volunteer_Roles__c currRec : volunteerRolesMap.get(currTraining.Volunteer__c)) {
					Volunteer_Roles__c updateRec = new Volunteer_Roles__c();
					updateRec.Id = currRec.Id;
					if (currTraining.Class_Offering__r.Chapter_Role_O_T__r.Role_Name__c == currRec.Role_Name__c) {
						if (currTraining.Volunteer_Attendance__c == 'Completed') {
							updateRec.Status__c = VOLUNTEER_ROLE_STATUS_ACTIVE;
							updateVolunteerRole.put(updateRec.Id, updateRec);
						} else {
							if (updateVolunteerRole.containsKey(updateRec.Id)) {
								if (updateVolunteerRole.get(updateRec.Id).Status__c != VOLUNTEER_ROLE_STATUS_ACTIVE) {
									updateRec.Status__c = 'Pending Training';
									updateVolunteerRole.put(updateRec.Id, updateRec);
								}
							} else {
								updateRec.Status__c = 'Pending Training';
								updateVolunteerRole.put(updateRec.Id, updateRec);
							}
						}
					} else {
						if (updateVolunteerRole.containsKey(updateRec.Id)) {
							if (updateVolunteerRole.get(updateRec.Id).Status__c != VOLUNTEER_ROLE_STATUS_ACTIVE) {
								updateRec.Status__c = 'Pending Training';
								updateVolunteerRole.put(updateRec.Id, updateRec);
							}
						} else {
							updateRec.Status__c = 'Pending Training';
							updateVolunteerRole.put(updateRec.Id, updateRec);
						}
					}
				}
			}
		}
		Set<String> requiredTrainingCO = new Set<String>();
		for (Chapter_Role_O_T__c currCOT : [
				SELECT Id, Chapter_Role__c, Required__c
				FROM Chapter_Role_O_T__c
				WHERE Required__c = TRUE AND Chapter_Role__c IN :chapterRoleIds
		]) {
			requiredTrainingCO.add(currCOT.Chapter_Role__c);
		}

		for (Volunteer_Roles__c currRole : scope) {
			if (currRole.Volunteer_Name__c != null) {
				Volunteer_Roles__c updateRec = new Volunteer_Roles__c();
				updateRec.Id = currRole.Id;
				if (!(volunteerTrainingMap.containsKey(currRole.Volunteer_Name__c))
						&& requiredTrainingCO.contains(currRole.Chapter_Role__c)) {
					updateRec.Status__c = 'Pending Training';
				} else if (!((volunteerTrainingMap.containsKey(currRole.Volunteer_Name__c))
						&& requiredTrainingCO.contains(currRole.Chapter_Role__c))) {
					updateRec.Status__c = VOLUNTEER_ROLE_STATUS_ACTIVE;
				}
				updateVolunteerRole.put(updateRec.Id, updateRec);
			}
		}

		if (updateVolunteerRole.size() > 0) {
			update updateVolunteerRole.values();
		}
	}

	global void finish(Database.BatchableContext BC) {
	}
}