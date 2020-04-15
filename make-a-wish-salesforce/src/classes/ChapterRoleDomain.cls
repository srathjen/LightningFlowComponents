/**
 * @description Domain class for the Chapter Role trigger
 * @author	Gustavo Mayer, Traction on Demand
 * @createdDate	4/15/2020
 */
public with sharing class ChapterRoleDomain extends trac_TriggerHandlerBase {

	List<Chapter_Role__c> newChapterRoleList = (List<Chapter_Role__c>) newRecordsList;
	List<Chapter_Role__c> oldChapterRoleList = (List<Chapter_Role__c>) oldRecordsList;
	Map<Id, Chapter_Role__c> newChapterRolesMap = (Map<Id, Chapter_Role__c>) newRecordsMap;
	Map<Id, Chapter_Role__c> oldChapterRolesMap = (Map<Id, Chapter_Role__c>) oldRecordsMap;

	/**
	 * Before insert of Chapter Role
	 */
	public override void handleBeforeInsert() {
		ChapterRoleService.setRole(newChapterRoleList);
	}

	/**
	 * Before update of Chapter Role
	 */
	public override void handleBeforeUpdate() {
		ChapterRoleService.setRole(newChapterRoleList);
	}

	/**
	 * After insert of Chapter Role
	 */
	public override void handleAfterInsert() {
		Map<String, List<Chapter_Role__c>> chapterRoleMap =
				ChapterRoleService.buildChapterRoleRecordSharingUpdateMap(newChapterRolesMap);
		ChapterStaffRecordSharing_AC.chapterRoleSharing(chapterRoleMap);
	}

	/**
	 * After update of Chapter Role
	 */
	public override void handleAfterUpdate() {
		Map<String, List<Chapter_Role__c>> chapterRoleMap =
				ChapterRoleService.buildChapterRoleRecordSharingUpdateMap(newChapterRolesMap, oldChapterRolesMap);
		ChapterStaffRecordSharing_AC.chapterRoleSharing(chapterRoleMap);
	}
}