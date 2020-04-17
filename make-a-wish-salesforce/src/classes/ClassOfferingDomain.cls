/**
 * @description Domain class for the Class Offering trigger
 * @author	Gustavo Mayer, Traction on Demand
 * @createdDate	4/15/2020
 */
public with sharing class ClassOfferingDomain extends trac_TriggerHandlerBase {

	List<Class_Offering__c> newClassOfferingList = (List<Class_Offering__c>) newRecordsList;
	List<Class_Offering__c> oldClassOfferingList = (List<Class_Offering__c>) oldRecordsList;
	Map<Id, Class_Offering__c> newClassOfferingMap = (Map<Id, Class_Offering__c>) newRecordsMap;
	Map<Id, Class_Offering__c> oldClassOfferingMap = (Map<Id, Class_Offering__c>) oldRecordsMap;

	/**
	 * After insert of Class Offering
	 */
	public override void handleAfterInsert() {
		ClassOfferingValidation.validateStartEnd(newClassOfferingList);
		Map<String, List<Class_Offering__c>> classOfferingMap =
				ClassOfferingService.buildClassOfferingChapterMap(newClassOfferingMap);
		ChapterStaffRecordSharing_AC.classOfferingSharing(classOfferingMap);
	}

	/**
	 * After update of Class Offering
	 */
	public override void handleAfterUpdate() {
		ClassOfferingValidation.validateStartEnd(newClassOfferingList);
		Map<String, List<Class_Offering__c>> classOfferingMap =
				ClassOfferingService.buildClassOfferingChapterMap(newClassOfferingMap, oldClassOfferingMap);
		ChapterStaffRecordSharing_AC.classOfferingSharing(classOfferingMap);
	}
}