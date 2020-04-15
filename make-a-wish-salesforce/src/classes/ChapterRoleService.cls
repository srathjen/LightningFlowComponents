/**
 * @description Chapter Role Service, centralizes Chapter Role business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 3/19/2020
 */
public class ChapterRoleService {

	private final static String ROLE_NATIONAL_STAFF = Constant_AC.ROLE_NATIONAL_STAFF;

	/**
	 * Set Role on Chapter Role
	 * @param chapterRoles
	 */
	public static void setRole(List<Chapter_Role__c> chapterRoles) {
		Set<Id> roleIds = new Set<Id>();
		Map<Id, Role__c> roleMap = new Map<Id, Role__c>();
		for (Chapter_Role__c newChapterRole : chapterRoles) {
			if (newChapterRole.Role_Name__c != null) {
				roleIds.add(newChapterRole.Role_Name__c);
			}
		}
		if (roleIds.isEmpty()) {
		}
		for (Role__c role : [
				SELECT Id,Name
				FROM Role__c
				WHERE Id IN:roleIds
		]) {
			roleMap.put(role.Id, role);
		}
		for (Chapter_Role__c newChapterRole : chapterRoles) {
			if (roleMap.containsKey(newChapterRole.Role_Name__c)) {
				newChapterRole.Role__c = roleMap.get(newChapterRole.Role_Name__c).Name;
			}
		}
	}

	/**
	 * Build Chapter Role Record Sharing Update Map
	 * @param newChapterRoleMap
	 * @return Map of List of Roles by Chapter Name
	 */
	public static Map<String, List<Chapter_Role__c>> buildChapterRoleRecordSharingUpdateMap(
			Map<Id, Chapter_Role__c> newChapterRoleMap) {
		Map<String, List<Chapter_Role__c>> chapterRoleMap = new Map<String, List<Chapter_Role__c>>();
		for (Chapter_Role__c currRec : [
				SELECT Id, Chapter_Name__c, Chapter_Name__r.Name, OwnerId, Owner.UserRoleId,
						Owner.UserRole.Name
				FROM Chapter_Role__c
				WHERE Id IN :newChapterRoleMap.keySet()
		]) {
			if (ROLE_NATIONAL_STAFF.equals(currRec.Owner.UserRole.Name)) {
				if (chapterRoleMap.containsKey(currRec.Chapter_Name__r.Name)) {
					chapterRoleMap.get(currRec.Chapter_Name__r.Name).add(currRec);
				} else {
					chapterRoleMap.put(currRec.Chapter_Name__r.Name, new List<Chapter_Role__c>{
							currRec
					});
				}
			}
		}
		return chapterRoleMap;
	}

	/**
	 * Build Chapter Role Record Sharing Update Map
	 * @param newChapterRoleMap
	 * @param oldChapterRoleMap
	 * @return Map of List of Roles by Chapter Name
	 */
	public static Map<String, List<Chapter_Role__c>> buildChapterRoleRecordSharingUpdateMap(
			Map<Id, Chapter_Role__c> newChapterRoleMap,
			Map<Id, Chapter_Role__c> oldChapterRoleMap) {
		Map<String, List<Chapter_Role__c>> chapterRoleMap = new Map<String, List<Chapter_Role__c>>();
		for (Chapter_Role__c currRec : [
				SELECT Id, Chapter_Name__c, Chapter_Name__r.Name, OwnerId, Owner.UserRoleId,
						Owner.UserRole.Name
				FROM Chapter_Role__c
				WHERE Id IN :newChapterRoleMap.keySet()
		]) {
			if (!oldChapterRoleMap.isEmpty() && currRec.OwnerId != oldChapterRoleMap.get(currRec.Id).OwnerId) {
				if (ROLE_NATIONAL_STAFF.equals(currRec.Owner.UserRole.Name)) {
					if (chapterRoleMap.containsKey(currRec.Chapter_Name__r.Name)) {
						chapterRoleMap.get(currRec.Chapter_Name__r.Name).add(currRec);
					} else {
						chapterRoleMap.put(currRec.Chapter_Name__r.Name, new List<Chapter_Role__c>{
								currRec
						});
					}
				}
			}
		}
		return chapterRoleMap;
	}
}
