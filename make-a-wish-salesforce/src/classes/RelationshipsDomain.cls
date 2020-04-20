/**
 * @description Domain class for the Relationship trigger
 * @author	Gustavo Mayer, Traction on Demand
 * @createdDate	4/08/2019
 */
public class RelationshipsDomain extends trac_TriggerHandlerBase {

	List<npe4__Relationship__c> newRelationshipsList = (List<npe4__Relationship__c>) newRecordsList;
	List<npe4__Relationship__c> oldRelationshipsList = (List<npe4__Relationship__c>) oldRecordsList;
	Map<Id, npe4__Relationship__c> newRelationshipsMap = (Map<Id, npe4__Relationship__c>) newRecordsMap;
	Map<Id, npe4__Relationship__c> oldRelationshipsMap = (Map<Id, npe4__Relationship__c>) oldRecordsMap;

	/**
	 * After insert of Lead
	 */
	public override void handleAfterInsert() {
		Set<Id> qualifyingMedicalProfessionalContactIds =
				RelationshipService.buildQualifyingMedProfessionalRelationshipMap(newRelationshipsList);
		RelationshipService.updatePhysicianDetails(qualifyingMedicalProfessionalContactIds, newRelationshipsList);
		Map<Id, String> relationshipMap = RelationshipService.buildNonMedicalRelationshipMap(newRelationshipsList);
		RelationshipService.updateRelationshipType(relationshipMap);
		Map<Id, Id> contactMap = RelationshipService.buildContactMap(newRelationshipsList);
		RelationshipService.populateGuardianName(contactMap);
	}

	/**
	 * After update of Lead
	 */
	public override void handleAfterUpdate() {
		if (RecursiveTriggerHandler.blockAfterUpdate) {
			return;
		}
		WishRequiredSignatureService.createChildGuardianSignatures(newRelationshipsList, oldRelationshipsMap);
	}
}