/**
 * Volunteer Update Role Status Batch
 */
global class Batch_UpdateVolunteerRoleStatus_AC implements Database.Batchable<SObject> {

	private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;
	private final static String VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_NOT_APPROVED = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_NOT_APPROVED;
	private final static String VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_FOLLOW_UP_REQUESTED = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_FOLLOW_UP_REQUESTED;
	private final static String VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING;
	private final static String VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED;
	private final static String VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE = Constant_AC.VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE;
	private final static String VOLUNTEER_ROLE_STATUS_PENDING = Constant_AC.VOLUNTEER_ROLE_STATUS_PENDING;
	private final static String VOLUNTEER_ROLE_STATUS_MISSING_REQUIREMENT = Constant_AC.VOLUNTEER_ROLE_STATUS_MISSING_REQUIREMENT;
	private final static String DASH = '-';
	private final static String BLANK = '';

	global Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator([
				SELECT Id,Volunteer_Name__c, Status__c, Chapter_Role__c,
						Hidden_Previous_Sub_Status__c, Hidden_Previous_Status__c, Sub_status__c
				FROM Volunteer_Roles__c
				WHERE Status__c = :VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE
				AND Volunteer_Name__c != NULL
				AND Hidden_Previous_Status__c = NULL
				AND Hidden_Previous_Sub_Status__c = NULL
		]);
	}

	global void execute(Database.BatchableContext bc, List<Volunteer_Roles__c> volunteerRoleList) {
		Set<Id> volunteerContactIds = new Set<Id>();
		Map<Id, List<Volunteer_Roles__c>> volunteerIdRoleMap = new Map<Id, List<Volunteer_Roles__c>>();
		Set<Id> prospectiveIdSet = new Set<Id>();
		Set<Id> activeIdSet = new Set<Id>();
		Set<Id> chapterRoleIds = new Set<Id>();
		Map<Id, Set<Id>> contactChapterRolesMap = new Map<Id, Set<Id>>();
		Map<Id, Set<Id>> chapterRoleOTMap = new Map<Id, Set<Id>>();
		Set<Id> orientationIds = new Set<Id>();
		Map<String, Id> volunteerRoleMap = new Map<String, Id>();
		Id trainingRecordTypeId = Constant_AC.TRAINING_RT_ID;
		Map<Id, List<Volunteer_Orientation_Training__c>> volunteerTrainingMap = new Map<Id, List<Volunteer_Orientation_Training__c>>();
		List<Volunteer_Roles__c> updateVolunteerRoles = new List<Volunteer_Roles__c>();

		for (Volunteer_Roles__c volunteerRole : volunteerRoleList) {
			volunteerContactIds.add(volunteerRole.Volunteer_Name__c);
			if (volunteerIdRoleMap.containsKey(volunteerRole.Volunteer_Name__c)) {
				volunteerIdRoleMap.get(volunteerRole.Volunteer_Name__c).add(volunteerRole);
			} else {
				volunteerIdRoleMap.put(volunteerRole.Volunteer_Name__c, new List<Volunteer_Roles__c>{
						volunteerRole
				});
			}
			chapterRoleIds.add(volunteerRole.Chapter_Role__c);
			if (!contactChapterRolesMap.containsKey(volunteerRole.Volunteer_Name__c)) {
				contactChapterRolesMap.put(volunteerRole.Volunteer_Name__c, new Set<Id>{
						volunteerRole.Chapter_Role__c
				});
			}
			contactChapterRolesMap.get(volunteerRole.Volunteer_Name__c).add(volunteerRole.Chapter_Role__c);
			volunteerRoleMap.put(volunteerRole.Volunteer_Name__c + DASH + volunteerRole.Chapter_Role__c, volunteerRole.id);
		}

		for (User volunteerUser : [
				SELECT Id,ContactId,Profile.Name,Profile.Id
				FROM User
				WHERE ContactId IN:volunteerContactIds
		]) {
			if (volunteerUser.Profile.Id == Label.Prospective_Volunteer_Profile) {
				prospectiveIdSet.add(volunteerUser.ContactId);
			} else {
				activeIdSet.add(volunteerUser.ContactId);
			}
		}

		for (Class_Offering__c classOffering : [
				SELECT Id, Chapter_Role_O_T__r.Chapter_Role__c,Date__c,End_Time__c,Location__c,Chapter_Role_O_T__r.Orientation_Training__c
				FROM Class_Offering__c
				WHERE Chapter_Role_O_T__r.Chapter_Role__c IN :chapterRoleIds
				AND Chapter_Role_O_T__r.Required__c = TRUE
				AND Chapter_Role_O_T__r.Orientation_Training__r.RecordTypeId = :trainingRecordTypeId
		]) {
			orientationIds.add(classOffering.Chapter_Role_O_T__r.Orientation_Training__c);
			if (!chapterRoleOTMap.containsKey(classOffering.Chapter_Role_O_T__r.Chapter_Role__c)) {
				chapterRoleOTMap.put(classOffering.Chapter_Role_O_T__r.Chapter_Role__c, new Set<Id>{
						classOffering.Chapter_Role_O_T__r.Orientation_Training__c
				});
			}
			chapterRoleOTMap.get(classOffering.Chapter_Role_O_T__r.Chapter_Role__c).add(classOffering.Chapter_Role_O_T__r.Orientation_Training__c);
		}
		for (Volunteer_Orientation_Training__c volunteerOT : [
				SELECT Id, Volunteer__c,Hidden_O_T_Id__c,Class_Offering__r.Chapter_Role_O_T__r.Orientation_Training__c
				FROM Volunteer_Orientation_Training__c
				WHERE Volunteer__c IN :volunteerContactIds
				AND Hidden_O_T_Id__c IN :orientationIds
				AND Type__c = :VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING
				AND Volunteer_Attendance__c = :VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED
				AND Completion_Status__c NOT IN (:VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_NOT_APPROVED,
						:VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_FOLLOW_UP_REQUESTED)
		]) {
			if (!volunteerTrainingMap.containsKey(volunteerOT.Class_Offering__r.Chapter_Role_O_T__r.Orientation_Training__c)) {
				volunteerTrainingMap.put(volunteerOT.Class_Offering__r.Chapter_Role_O_T__r.Orientation_Training__c, new List<Volunteer_Orientation_Training__c>{
						volunteerOT
				});
			}
			volunteerTrainingMap.get(volunteerOT.Class_Offering__r.Chapter_Role_O_T__r.Orientation_Training__c).add(volunteerOT);
		}

		for (Id contactId : volunteerContactIds) {
			if (activeIdSet.contains(contactId) || prospectiveIdSet.contains(contactId)) {
				for (Id chapterRoleId : contactChapterRolesMap.get(contactId)) {
					Integer trainingSize = 0;
					if (chapterRoleOTMap.containsKey(chapterRoleId)) {
						for (Id currOrientationId : chapterRoleOTMap.get(chapterRoleId)) {
							if (volunteerTrainingMap.containsKey(currOrientationId)) {
								for (Volunteer_Orientation_Training__c Training : volunteerTrainingMap.get(currOrientationId)) {
									trainingSize = trainingSize + 1;
								}
							}
						}
					}
					if (chapterRoleOTMap.containsKey(chapterRoleId)) {
						Volunteer_Roles__c volunteerRole = new Volunteer_Roles__c();
						if (trainingSize == (chapterRoleOTMap.get(chapterRoleId).size())) {
							volunteerRole.Hidden_Previous_Status__c = VOLUNTEER_ROLE_STATUS_ACTIVE;
							volunteerRole.Hidden_Previous_Sub_Status__c = BLANK;
						} else {
							volunteerRole.Hidden_Previous_Status__c = VOLUNTEER_ROLE_STATUS_PENDING;
							volunteerRole.Hidden_Previous_Sub_Status__c = VOLUNTEER_ROLE_STATUS_MISSING_REQUIREMENT;
						}
						volunteerRole.Id = volunteerRoleMap.get(contactId + DASH + chapterRoleId);
						updateVolunteerRoles.add(volunteerRole);
					} else if (!chapterRoleOTMap.containsKey(chapterRoleId)) {
						Volunteer_Roles__c volunteerRole = new Volunteer_Roles__c();
						volunteerRole.Hidden_Previous_Status__c = VOLUNTEER_ROLE_STATUS_ACTIVE;
						volunteerRole.Id = volunteerRoleMap.get(contactId + DASH + chapterRoleId);
						updateVolunteerRoles.add(volunteerRole);
					}
				}
			}
		}
		update updateVolunteerRoles;
	}

	global void finish(Database.BatchableContext bc) {
	}
}