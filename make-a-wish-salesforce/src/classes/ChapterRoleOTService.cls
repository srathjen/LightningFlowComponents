/**
 * @description Chapter Role Orientation and Training Service, centralizes Chapter Role Orientation and Training business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 3/19/2020
 */
public class ChapterRoleOTService {

	private final static String ROLE_NATIONAL_STAFF = Constant_AC.ROLE_NATIONAL_STAFF;

	public static Map<Id, Chapter_Role_O_T__c> buildChapterRoleOTChangedOwnerMap(
			Map<Id, Chapter_Role_O_T__c> chapterRoleOTMap,
			Map<Id, Chapter_Role_O_T__c> chapterRoleOTOldMap) {
		Map<Id, Chapter_Role_O_T__c> chapterRoleOTOwnerChangedMap = new Map<Id, Chapter_Role_O_T__c>();
		for (Chapter_Role_O_T__c currRec : chapterRoleOTMap.values()) {
			if (chapterRoleOTOldMap.get(currRec.Id).OwnerId != currRec.OwnerId) {
				chapterRoleOTOwnerChangedMap.put(currRec.Id, currRec);
			}
		}
		return chapterRoleOTOwnerChangedMap;
	}

	public static Map<String, List<Chapter_Role_O_T__c>> buildChapterRoleOTShareNationalStaffRecords(
			Map<Id, Chapter_Role_O_T__c> chapterRoleOTMap) {
		Map<String, List<Chapter_Role_O_T__c>> chapterRoleMap = new Map<String, List<Chapter_Role_O_T__c>>();
		for (Chapter_Role_O_T__c currRec : [
				SELECT Id, Chapter_Name__c,OwnerId, Owner.UserRoleId,
						Owner.UserRole.Name
				FROM Chapter_Role_O_T__c
				WHERE Id IN :chapterRoleOTMap.keySet()
		]) {
			if (ROLE_NATIONAL_STAFF.equals(currRec.Owner.UserRole.Name)) {
				if (!chapterRoleMap.containsKey(currRec.Chapter_Name__c)) {
					chapterRoleMap.put(currRec.Chapter_Name__c, new List<Chapter_Role_O_T__c>());
				}
				chapterRoleMap.get(currRec.Chapter_Name__c).add(currRec);
			}
		}
		return chapterRoleMap;
	}
}
