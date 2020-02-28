/**
 * @description Case Service, exposes methods for the Controller layer.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 8/20/2019
 */
public with sharing class CaseService {

	/**
	* Check if the User or the User's profile has permissions on Case
	* @param userId
	* @param userProfileId
	* @return Boolean
	*/
	public static Boolean userHasRestrictedPermissionOnCase() {
		return Closed_Case_Editing_Security_Settings__c.getInstance().Restrict_Access__c;
	}

	public static void deleteByLeadIdAndRecordTypeNames(Id leadId, List<String> caseRecordTypeNames){
		List<Case> cases = [
				SELECT Id, Lead__c
				FROM Case
				WHERE Lead__c = :leadId
				AND RecordType.Name IN :caseRecordTypeNames
		];
		if (!cases.isEmpty()) {
			delete cases;
		}
	}
}