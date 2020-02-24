/**
 * @description Domain class for the Wish_Change_Request trigger
 * @author		Gustavo Mayer, Traction on Demand
 * @createdDate 		9/11/2019
 */
public with sharing class Wish_Change_RequestDomain extends trac_TriggerHandlerBase {
	private List<Wish_Change_Request__c> newWishChangeRequestsList = (List<Wish_Change_Request__c>) newRecordsList;
	private Map<Id, Wish_Change_Request__c> oldWishChangeRequestsMap = (Map<Id, Wish_Change_Request__c>) oldRecordsMap;

	public override void handleAfterUpdate() {
		/**
		 * WLP-363
		 * Process the Approved Change Requests to update the Wish Affiliation records
		 */
		Wish_Change_RequestService.processApprovedChangeRequests(newWishChangeRequestsList, oldWishChangeRequestsMap);
	}
}