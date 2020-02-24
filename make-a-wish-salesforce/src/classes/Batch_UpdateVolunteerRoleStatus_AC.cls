/**
 * JIRA: WLP-422
 * Author: Gustavo Mayer
 * Update: Changing the Volunteer_Roles status from 'Trained' to 'Active'
 */
global class Batch_UpdateVolunteerRoleStatus_AC implements Database.Batchable<SObject> {

	private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;
	private final static String VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_NOT_APPROVED = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_NOT_APPROVED;
	private final static String VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_FOLLOW_UP_REQUESTED = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_FOLLOW_UP_REQUESTED;
	private final static String VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING;
	private final static String VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED;
	private final static String VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE = Constant_AC.VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE;

	global static Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator([
				SELECT Id,Volunteer_Name__c,Status__c,Chapter_Role__c,Hidden_Previous_Sub_Status__c,Hidden_Previous_Status__c,Sub_status__c
				FROM Volunteer_Roles__c
				WHERE Status__c = :VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE
				AND Volunteer_Name__c != NULL
				AND Hidden_Previous_Status__c = NULL
				AND Hidden_Previous_Sub_Status__c = NULL
		]);
	}

	global static void execute(Database.BatchableContext bc, List<Volunteer_Roles__c> volunteerRoleList) {
		Set<Id> volunteerIdSet = new Set<Id>();
		Map<Id, List<Volunteer_Roles__c>> volunteerIdRoleMap = new Map<Id, List<Volunteer_Roles__c>>();
		Set<Id> prospectiveIdSet = new Set<Id>();
		Set<Id> activeIdSet = new Set<Id>();
//		Set<Id> activeContactIdsSet = new Set<Id>();
//		List<npe5__Affiliation__c> affiliationList = new List<npe5__Affiliation__c>();
		Set<Id> chapterRoleIds = new Set<Id>();
		Map<Id, Set<Id>> contactChapterRolesMap = new Map<Id, Set<Id>>();
		Map<Id, Set<Id>> chapterRoleOAndTMap = new Map<Id, Set<Id>>();
		Set<Id> orientationIds = new Set<Id>();
//		Set<Id> contactIds = new Set<Id>();
//		Set<String> activeChapterRoleIds = new Set<String>();
		Map<String, Id> volunteerRoleMap = new Map<String, Id>();
		Id trainingRecordTypeId = Constant_AC.TRAINING_RT_ID;
		Map<Id, List<Volunteer_Orientation_Training__c>> volunteerTrainingMap = new Map<Id, List<Volunteer_Orientation_Training__c>>();
		List<Volunteer_Roles__c> updateVolRoleList = new List<Volunteer_Roles__c>();

		for (Volunteer_Roles__c volunteerRole : volunteerRoleList) {
			volunteerIdSet.add(volunteerRole.Volunteer_Name__c);
			if (volunteerIdRoleMap.containsKey(volunteerRole.Volunteer_Name__c)) {
				volunteerIdRoleMap.get(volunteerRole.Volunteer_Name__c).add(volunteerRole);
			} else {
				volunteerIdRoleMap.put(volunteerRole.Volunteer_Name__c, new List<Volunteer_Roles__c>{
						volunteerRole
				});
			}
			chapterRoleIds.add(volunteerRole.Chapter_Role__c);
			if (contactChapterRolesMap.containsKey(volunteerRole.Volunteer_Name__c)) {
				contactChapterRolesMap.get(volunteerRole.Volunteer_Name__c).add(volunteerRole.Chapter_Role__c);
			} else {
				contactChapterRolesMap.put(volunteerRole.Volunteer_Name__c, new Set<Id>{
						volunteerRole.Chapter_Role__c
				});
			}
			volunteerRoleMap.put(volunteerRole.Volunteer_Name__c + '-' + volunteerRole.Chapter_Role__c, volunteerRole.id);
		}
		for (User volunteerUser : [
				SELECT Id,ContactId,Profile.Name,Profile.Id
				FROM User
				WHERE ContactId IN:volunteerIdSet
		]) {
			if (volunteerUser.Profile.Id == Label.Prospective_Volunteer_Profile) {
				prospectiveIdSet.add(volunteerUser.ContactId);
			} else {
				activeIdSet.add(volunteerUser.ContactId);
			}
		}

		for (Class_Offering__c currRec : [
				SELECT Id, Chapter_Role_O_T__r.Chapter_Role__c,Date__c,End_Time__c,Location__c,Chapter_Role_O_T__r.Orientation_Training__c
				FROM Class_Offering__c
				WHERE Chapter_Role_O_T__r.Chapter_Role__c IN :chapterRoleIds
				AND Chapter_Role_O_T__r.Required__c = TRUE
				AND Chapter_Role_O_T__r.Orientation_Training__r.RecordTypeId = :trainingRecordTypeId
		]) {
			orientationIds.add(currRec.Chapter_Role_O_T__r.Orientation_Training__c);
			if (chapterRoleOAndTMap.containsKey(currRec.Chapter_Role_O_T__r.Chapter_Role__c)) {
				chapterRoleOAndTMap.get(currRec.Chapter_Role_O_T__r.Chapter_Role__c).add(currRec.Chapter_Role_O_T__r.Orientation_Training__c);
			} else {
				chapterRoleOAndTMap.put(currRec.Chapter_Role_O_T__r.Chapter_Role__c, new Set<Id>{
						currRec.Chapter_Role_O_T__r.Orientation_Training__c
				});
			}
		}
		/* for(Volunteer_Orientation_Training__c currTraining : [SELECT id, Volunteer__c,Hidden_O_T_Id__c FROM Volunteer_Orientation_Training__c WHERE Volunteer__c IN :volunteerIdSet AND Hidden_O_T_Id__c IN :orientationIds AND Type__c = 'Training' AND Volunteer_Attendance__c = 'Completed'])
		 {
			 if(volunteerTrainingMap.containsKey(currTraining.Hidden_O_T_Id__c))
				 volunteerTrainingMap.get(currTraining.Hidden_O_T_Id__c).add(currTraining);
			 else
				 volunteerTrainingMap.put(currTraining.Hidden_O_T_Id__c, new List<Volunteer_Orientation_Training__c>{currTraining});
		 }*/
		/**
		 * JIRA: WLP-422
		 * Author: Gustavo Mayer
		 * Update: Adding the Completion Status of the Training as a condition
		 */
		for (Volunteer_Orientation_Training__c currTraining : [
				SELECT Id, Volunteer__c,Hidden_O_T_Id__c,Class_Offering__r.Chapter_Role_O_T__r.Orientation_Training__c
				FROM Volunteer_Orientation_Training__c
				WHERE Volunteer__c IN :volunteerIdSet
				AND Hidden_O_T_Id__c IN :orientationIds
				AND Type__c = :VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING
				AND Volunteer_Attendance__c = :VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED
				AND Completion_Status__c NOT IN (:VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_NOT_APPROVED,
						:VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_FOLLOW_UP_REQUESTED)
		]) {
			if (volunteerTrainingMap.containsKey(currTraining.Class_Offering__r.Chapter_Role_O_T__r.Orientation_Training__c)) {
				volunteerTrainingMap.get(currTraining.Class_Offering__r.Chapter_Role_O_T__r.Orientation_Training__c).add(currTraining);
			} else {
				volunteerTrainingMap.put(currTraining.Class_Offering__r.Chapter_Role_O_T__r.Orientation_Training__c, new List<Volunteer_Orientation_Training__c>{
						currTraining
				});
			}
		}

		for (Id currConId : volunteerIdSet) {
			/*if(prosepectiveIdSet.contains(currConId)){
				for(Volunteer_Roles__c currVolRole : volunteerIdRoleMap.get(currConId)){
					Volunteer_Roles__c updateRec = new Volunteer_Roles__c();
					updateRec.Hidden_Previous_Status__c = 'Pending';
					updateRec.Hidden_Previous_Sub_Status__c = 'Missing Requirement';
					updateRec.id = currVolRole.Id;
					updateVolRoleList.add(updateRec);
				}

			}*/
			if (activeIdSet.contains(currConId) || prospectiveIdSet.contains(currConId)) {
				for (Id currChapRolId : contactChapterRolesMap.get(currConId)) {
					Integer trainingSize = 0;
					if (chapterRoleOAndTMap.containsKey(currChapRolId)) {
						for (Id currOrientationId : chapterRoleOAndTMap.get(currChapRolId)) {
							if (volunteerTrainingMap.containsKey(currOrientationId)) {
								for (Volunteer_Orientation_Training__c Training : volunteerTrainingMap.get(currOrientationId)) {
									trainingSize = trainingSize + 1;
								}
							}
						}
					}
					if (chapterRoleOAndTMap.containsKey(currChapRolId)) {
						Volunteer_Roles__c volunteerRole = new Volunteer_Roles__c();
						if (trainingSize == (chapterRoleOAndTMap.get(currChapRolId).size())) {
							volunteerRole.Hidden_Previous_Status__c = VOLUNTEER_ROLE_STATUS_ACTIVE;
							volunteerRole.Hidden_Previous_Sub_Status__c = '';
						} else {
							volunteerRole.Hidden_Previous_Status__c = 'Pending';
							volunteerRole.Hidden_Previous_Sub_Status__c = 'Missing Requirement';
						}
						volunteerRole.Id = volunteerRoleMap.get(currConId + '-' + currChapRolId);
						updateVolRoleList.add(volunteerRole);
					} else if (!chapterRoleOAndTMap.containsKey(currChapRolId)) {
						Volunteer_Roles__c updateRec = new Volunteer_Roles__c();
						updateRec.Hidden_Previous_Status__c = VOLUNTEER_ROLE_STATUS_ACTIVE;
						updateRec.Id = volunteerRoleMap.get(currConId + '-' + currChapRolId);
						updateVolRoleList.add(updateRec);
					}

				}
			}
		}
		if (updateVolRoleList.size() > 0) {
			update updateVolRoleList;
		}
	}

	global static void finish(Database.BatchableContext bc) {
	}
}