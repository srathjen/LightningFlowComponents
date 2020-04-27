/**
 * @description Domain class for the Orientation Training trigger
 * @author	Gustavo Mayer, Traction on Demand
 * @createdDate	4/15/2020
 */
public class OrientationTrainingDomain extends trac_TriggerHandlerBase {
	List<Orientation_Training__c> newOrientationTrainingList = (List<Orientation_Training__c>) newRecordsList;
	List<Orientation_Training__c> oldOrientationTrainingList = (List<Orientation_Training__c>) oldRecordsList;
	Map<Id, Orientation_Training__c> newOrientationTrainingMap = (Map<Id, Orientation_Training__c>) newRecordsMap;
	Map<Id, Orientation_Training__c> oldOrientationTrainingMap = (Map<Id, Orientation_Training__c>) oldRecordsMap;
}