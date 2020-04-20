/**
 * @description Domain class for the Chapter Role Orientation and Training trigger
 * @author	Gustavo Mayer, Traction on Demand
 * @createdDate	4/15/2020
 */
public class ChapterRoleOTDomain extends trac_TriggerHandlerBase {

	List<Chapter_Role_O_T__c> newChapterRoleOTList = (List<Chapter_Role_O_T__c>) newRecordsList;
	List<Chapter_Role_O_T__c> oldChapterRoleOTList = (List<Chapter_Role_O_T__c>) oldRecordsList;
	Map<Id, Chapter_Role_O_T__c> newChapterRolesOTMap = (Map<Id, Chapter_Role_O_T__c>) newRecordsMap;
	Map<Id, Chapter_Role_O_T__c> oldChapterRolesOTMap = (Map<Id, Chapter_Role_O_T__c>) oldRecordsMap;

	/**
	 * After insert of Chapter Role
	 */
	public override void handleAfterInsert() {
		Map<String, List<Chapter_Role_O_T__c>> chapterRoleOTOwnerChangedShareMap =
				ChapterRoleOTService.buildChapterRoleOTShareNationalStaffRecords(newChapterRolesOTMap);
		ChapterStaffRecordSharing_AC.chapterRoleOTSharing(chapterRoleOTOwnerChangedShareMap);
	}

	/**
	 * After update of Chapter Role
	 */
	public override void handleAfterUpdate() {
		Map<Id, Chapter_Role_O_T__c> chapterRoleOTOwnerChangedMap =
				ChapterRoleOTService.buildChapterRoleOTChangedOwnerMap(newChapterRolesOTMap, oldChapterRolesOTMap);
		Map<String, List<Chapter_Role_O_T__c>> chapterRoleOTOwnerChangedShareMap =
				ChapterRoleOTService.buildChapterRoleOTShareNationalStaffRecords(chapterRoleOTOwnerChangedMap);
		ChapterStaffRecordSharing_AC.chapterRoleOTSharing(chapterRoleOTOwnerChangedShareMap);
	}
}