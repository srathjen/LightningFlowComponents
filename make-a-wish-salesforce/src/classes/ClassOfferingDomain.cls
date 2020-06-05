/**
 * @description Domain class for the Class Offering trigger
 * @author Gustavo Mayer, Traction on Demand
 * @date 4/15/2020
 */
public class ClassOfferingDomain extends trac_TriggerHandlerBase {

    List<Class_Offering__c> newClassOfferingList = (List<Class_Offering__c>) newRecordsList;
    List<Class_Offering__c> oldClassOfferingList = (List<Class_Offering__c>) oldRecordsList;
    Map<Id, Class_Offering__c> newClassOfferingMap = (Map<Id, Class_Offering__c>) newRecordsMap;
    Map<Id, Class_Offering__c> oldClassOfferingMap = (Map<Id, Class_Offering__c>) oldRecordsMap;

	/**
     * @description After insert of Class Offering
     */
    public override void handleAfterInsert() {
        ClassOfferingValidation.validateStartEnd(newClassOfferingList);
        Map<String, List<Class_Offering__c>> classOfferingMap =
                ClassOfferingService.buildClassOfferingChapterMap(newClassOfferingMap);
        ChapterStaffRecordSharing_AC.classOfferingSharing(classOfferingMap);
    }

	/**
     * @description After update of Class Offering
     */
    public override void handleAfterUpdate() {
        ClassOfferingValidation.validateStartEnd(newClassOfferingList);
        Map<String, List<Class_Offering__c>> classOfferingMap =
                ClassOfferingService.buildClassOfferingChapterMap(newClassOfferingMap, oldClassOfferingMap);
        ChapterStaffRecordSharing_AC.classOfferingSharing(classOfferingMap);
    }
}