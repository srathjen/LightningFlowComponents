/**
 * @description Domain class for the Volunteer Opportunity trigger
 * @author	Gustavo Mayer, Traction on Demand
 * @createdDate	4/15/2020
 */
public class VolunteerOpportunityDomain extends trac_TriggerHandlerBase {

	List<Volunteer_Opportunity__c> newVolunteerOpportunityList = (List<Volunteer_Opportunity__c>) newRecordsList;
	List<Volunteer_Opportunity__c> oldVolunteerOpportunityList = (List<Volunteer_Opportunity__c>) oldRecordsList;
	Map<Id, Volunteer_Opportunity__c> newVolunteerOpportunityMap = (Map<Id, Volunteer_Opportunity__c>) newRecordsMap;
	Map<Id, Volunteer_Opportunity__c> oldVolunteerOpportunityMap = (Map<Id, Volunteer_Opportunity__c>) oldRecordsMap;

	/**
	 * Before update of Volunteer Opportunity
	 */  
	public override void handleBeforeUpdate() {
		VolunteerOpportunityService.setFields(newVolunteerOpportunityMap, oldVolunteerOpportunityMap);
	}

	/**
	 * Before delete of Volunteer Opportunity
	 */
	public override void handleBeforeDelete() {
		VolunteerOpportunityService.updateUserRoleId(oldVolunteerOpportunityList);
	}

	/**
	 * After insert of Volunteer Opportunity
	 */
	public override void handleAfterInsert() {
		Set<Id> volunteerIds = VolunteerOpportunityService.buildVolunteerApprovedOpportunitiesIds(newVolunteerOpportunityList);
		ContactService.updateAssignedNumberOfOpportunities(volunteerIds);
		Map<String, List<Volunteer_Opportunity__c>> volunteerOpportunityShareMap =
				VolunteerOpportunityService.buildVolunteerOpportunitiesByChapterMap(newVolunteerOpportunityMap.keySet());
		ChapterStaffRecordSharing_AC.volunteerOpportunitySharing(volunteerOpportunityShareMap);
	}

	/**
	 * After update of Volunteer Opportunity
	 */
	public override void handleAfterUpdate() {
		Set<Id> recallApprovalIdSet = VolunteerOpportunityService.buildVolunteerOpportunitiesOutOfComplianceMap(
				newVolunteerOpportunityMap, oldVolunteerOpportunityMap);
		CaseService.recallVolOppApproval(recallApprovalIdSet);

		Set<Id> volunteerIds = VolunteerOpportunityService.buildVolunteerOpportunityVolunteerIds(newVolunteerOpportunityMap);
		Map<Id, Volunteer_Opportunity__c> volunteerInactiveWithGranter =
				VolunteerOpportunityService.buildVolunteerOpportunityUpdateInActiveWishGranterMap(newVolunteerOpportunityMap);
		if (RecursiveTriggerHandler.isFirstTime) {
			CaseService.updateInActiveWishGranter(volunteerIds, volunteerInactiveWithGranter.values());
		}

		Map<Id, Volunteer_Opportunity__c> volunteerOpportunityMap =
				VolunteerOpportunityService.buildVolunteerOpportunityReasonInactiveMap(newVolunteerOpportunityMap, oldVolunteerOpportunityMap);
		VolunteerOpportunityService.updateInactive(volunteerOpportunityMap);

		Set<Id> volunteerNewlyApprovedIds = VolunteerOpportunityService.buildVolunteerApprovedMap(newVolunteerOpportunityMap, oldVolunteerOpportunityMap);
		VolunteerOpportunityService.activeWishCount(volunteerNewlyApprovedIds);

		VolunteerOpportunityService.updateUserRoleId(newVolunteerOpportunityList);

		Map<Id, Volunteer_Opportunity__c> recordsForApprovalProcess =
				VolunteerOpportunityService.buildVolunteerOpportunitiesForApprovalMap(newVolunteerOpportunityMap, oldVolunteerOpportunityMap);
		VolunteerOpportunityService.submitApprovalProcess(recordsForApprovalProcess.values());

		Map<Id, Volunteer_Opportunity__c> recordsForCreatingCaseTeams =
				VolunteerOpportunityService.buildVolunteerOpportunityCaseTeamMemberMap(newVolunteerOpportunityMap, oldVolunteerOpportunityMap);
		VolunteerOpportunityService.createCaseTeamMembers(recordsForCreatingCaseTeams.values());

		Map<Id, Volunteer_Opportunity__c> nonWishListUpdateCount =
				VolunteerOpportunityService.buildVolunteerOpportunityNonWishMap(newVolunteerOpportunityMap);
		VolunteerOpportunityService.updateVolunteerRegisteredCount(nonWishListUpdateCount.values(), volunteerIds, false);

		Map<Id, Volunteer_Opportunity__c> volOpportunitySharingMap =
				VolunteerOpportunityService.buildVolunteerOpportunitySharingMap(newVolunteerOpportunityMap, oldVolunteerOpportunityMap);
		VolunteerOpportunityService.shareVolunteerOpportunityRecord(volOpportunitySharingMap.values());

		Set<Id> volunteerApprovedIds = VolunteerOpportunityService.buildVolunteerApprovedOpportunitiesIds(newVolunteerOpportunityList);
		ContactService.updateAssignedNumberOfOpportunities(volunteerApprovedIds);

		Map<String, List<Volunteer_Opportunity__c>> volunteerOpportunityShareMap =
				VolunteerOpportunityService.buildVolunteerOpportunitiesByChapterMap(newVolunteerOpportunityMap.keySet());
		ChapterStaffRecordSharing_AC.volunteerOpportunitySharing(volunteerOpportunityShareMap);
	}

	/**
 	* After delete of Volunteer Opportunity
 	*/
	public override void handleAfterDelete() {
		Map<Id, Volunteer_Opportunity__c> nonWishUpdateMap =
				VolunteerOpportunityService.buildVolunteerOpportunityNonWishListToUpdateMap(oldVolunteerOpportunityMap);
		Map<Id, Volunteer_Opportunity__c> nonWishRegisteredMap =
				VolunteerOpportunityService.buildVolunteerOpportunityNonRegisteredMap(oldVolunteerOpportunityMap);
		VolunteerOpportunityService.updateVolunteerNeededCount(nonWishUpdateMap);
		VolunteerOpportunityService.updateVolunteerRegisteredCountDelete(nonWishRegisteredMap);
	}
}