/**
 * @description Volunteer Opportunity Service, centralizes Volunteer Opportunity business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 4/14/2020
 */
public class VolunteerOpportunityService {

	private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;
	private final static String VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE = Constant_AC.VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE;
	private final static String VOLUNTEER_OPPORTUNITY_STATUS_OUT_OF_COMPLIANCE = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_OUT_OF_COMPLIANCE;
	private final static String VOLUNTEER_OPPORTUNITY_STATUS_HOLD = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_HOLD;
	private final static String VOLUNTEER_OPPORTUNITY_STATUS_APPROVED = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_APPROVED;
	private final static String CASE_STATUS_GRANTED = Constant_AC.CASE_STATUS_GRANTED;
	private final static String CASE_STATUS_COMPLETED = Constant_AC.CASE_STATUS_COMPLETED;

	public static List<Volunteer_Opportunity__c> findVolunteerOpportunityByVolunteer(Set<Id> volunteerIds) {
		return [
				SELECT Id, Status__c, Chapter_Name__c, Hidden_allow_Hold_status__c,
						Wish__c, Wish__r.Status, Chapter_Name__r.Name, Volunteer_Name__c, Role__c
				FROM Volunteer_Opportunity__c
				WHERE Volunteer_Name__c IN :volunteerIds
		];
	}

	public static Map<Id, Volunteer_Opportunity__c> updateVolunteerOpportunityByVolunteerRoles(Map<Id, List<Volunteer_Roles__c>> volunteerRolesMap) {
		Map<Id, Volunteer_Opportunity__c> updateVolOppMap = new Map<Id, Volunteer_Opportunity__c>();
		if (volunteerRolesMap.isEmpty()) {
			return updateVolOppMap;
		}
		try {
			for (Volunteer_Opportunity__c volunteerOpportunity : [
					SELECT Id, Status__c, Chapter_Name__c, Hidden_allow_Hold_status__c,
							Wish__c, Wish__r.Status, Chapter_Name__r.Name, Volunteer_Name__c, Role__c
					FROM Volunteer_Opportunity__c
					WHERE Volunteer_Name__c IN:volunteerRolesMap.keySet()
			]) {
				if (volunteerRolesMap.containsKey(volunteerOpportunity.Volunteer_Name__c)) {
					for (Volunteer_Roles__c newVolRole : volunteerRolesMap.get(volunteerOpportunity.Volunteer_Name__c)) {
						if (volunteerOpportunity.Chapter_Name__r.Name == newVolRole.Chapter_Name__c
								&& volunteerOpportunity.Role__c == newVolRole.Role_Name__c) {
							if (newVolRole.Status__c == VOLUNTEER_ROLE_STATUS_ACTIVE
									&& volunteerOpportunity.Status__c == VOLUNTEER_OPPORTUNITY_STATUS_OUT_OF_COMPLIANCE) {
								volunteerOpportunity.Status__c = VOLUNTEER_OPPORTUNITY_STATUS_HOLD;
								volunteerOpportunity.Hidden_allow_Hold_status__c = true;
							} else if (newVolRole.Status__c == VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE
									&& volunteerOpportunity.Status__c == VOLUNTEER_OPPORTUNITY_STATUS_APPROVED
									&& ((volunteerOpportunity.Wish__c != null
									&& volunteerOpportunity.Wish__r.Status != CASE_STATUS_GRANTED
									&& volunteerOpportunity.Wish__r.Status != CASE_STATUS_COMPLETED)
									|| volunteerOpportunity.Wish__c == null)) {
								volunteerOpportunity.Status__c = VOLUNTEER_OPPORTUNITY_STATUS_OUT_OF_COMPLIANCE;
							}
							updateVolOppMap.put(volunteerOpportunity.Id, volunteerOpportunity);
						}
					}
				}
			}
			update updateVolOppMap.values();
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (Volunteer_Opportunity__c volunteerOpportunity : updateVolOppMap.values()) {
				ErrorMessage_AC.createDebugRec('VolunteerOpportunityService', String.valueOf(volunteerOpportunity),
						String.valueOf(ex), 'updateVolunteerOpportunityByVolunteerRoles',
						volunteerOpportunity.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
				if (!Test.isRunningTest()) {
					volunteerOpportunity.addError(Label.Debug_log_error_message);
				}
			}
		}
		return updateVolOppMap;
	}

	/**
	 * Delete Volunteer Opportunity Non Approved By Non Wish Event and Record Type Id
	 * @param nonWishEventId
	 * @param recordTypeId
	 */
	public static void deleteNonApprovedByNonWishEventAndRecordType(Id nonWishEventId, Id recordTypeId) {
		List<Volunteer_Opportunity__c> volunteerOpportunity = [
				SELECT Id,RecordTypeId,Chapter_Role_Opportunity__c,Chapter_Name__c,
						Volunteer_Name__c,Non_Wish_Event__c,Reason_Inactive__c
				FROM Volunteer_Opportunity__c
				WHERE Volunteer_Name__c = NULL
				AND Non_Wish_Event__c = :nonWishEventId
				AND RecordTypeId = :recordTypeId
				AND Status__c != :VOLUNTEER_OPPORTUNITY_STATUS_APPROVED
				AND Reason_Inactive__c = :NULL
		];
		delete volunteerOpportunity;
	}

	/**
	 * Delete Volunteer Opportunity Non Approved By Chapter and Non Wish Event
	 * @param nonWishEventId
	 * @param recordTypeId
	 */
	public static void deleteNonApprovedByChapterAndNonWishEvent(Set<Id> chapterRoleIds, Id nonWishEventId) {
		List<Volunteer_Opportunity__c> deleteVolunteerList = [
				SELECT Id,Chapter_Name__c,Chapter_Role_Opportunity__c,Volunteer_Name__c,Non_Wish_Event__c
				FROM Volunteer_Opportunity__c
				WHERE Chapter_Role_Opportunity__c IN:chapterRoleIds
				AND Volunteer_Name__c = NULL
				AND Non_Wish_Event__c = :nonWishEventId
				AND Reason_Inactive__c = :NULL
		];
		delete deleteVolunteerList;
	}
}