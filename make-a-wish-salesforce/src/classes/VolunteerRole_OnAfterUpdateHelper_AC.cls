/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : VolunteerRole_OnAfterUpdateHelper_AC is Update the Volunteer Opportunity based on volunteer Role status.
              
              Modification Log
              ------------------
              WVC-1889    Pavithra G 07/31/2018
              WVC-2206    Pavithra G 07/31/2018
              
*****************************************************************************************************/
/**
 * JIRA: WLP-422
 * Author: Gustavo Mayer
 * Update: Changing the Volunteer_Roles status from 'Trained' to 'Active'
 */
Public class VolunteerRole_OnAfterUpdateHelper_AC {

	private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;

	public static void updateVolunteerOpportunity(Map<Id, List<Volunteer_Roles__c>> volRoleMap, list<Volunteer_Roles__c> exceptionList) {
		//list<Volunteer_Opportunity__c> updateVolOppList = new list<Volunteer_Opportunity__c>();
		try {
			Map<Id, Id> wishVolunteerIdMap = new Map<Id, Id>();
			Map<Id, Id> inactiveWishVolunteerIdMap = new Map<Id, Id>();
			Map<Id, Volunteer_Opportunity__c> updateVolOppMap = new Map<Id, Volunteer_Opportunity__c>();
			Map<Id, Set<String>> volunteerRoleMap = new Map<Id, Set<String>>();
			if (volRoleMap.size() > 0) {
				for (Volunteer_Opportunity__c currVolOpp : [
						SELECT ID,Status__c,Chapter_Name__c,Hidden_allow_Hold_status__c,
								Wish__C,Wish__r.Status,Chapter_Name__r.Name,Volunteer_Name__c,Role__c
						FROM Volunteer_Opportunity__c
						WHERE Volunteer_Name__c IN:volRoleMap.keySet()
				]) {

					if (volRoleMap.containsKey(currVolOpp.Volunteer_Name__c)) {
						for (Volunteer_Roles__c newVolRole : volRoleMap.get(currVolOpp.Volunteer_Name__c)) {
							if (currVolOpp.Chapter_Name__r.Name == newVolRole.Chapter_Name__c
									&& currVolOpp.Role__c == newVolRole.Role_Name__c) {

								if (newVolRole.Status__c == VOLUNTEER_ROLE_STATUS_ACTIVE
										&& currVolOpp.Status__c == 'Out of Compliance') {
									/************ Changed Status = Aproved to Hold WVC-2206 *********/
									currVolOpp.Status__c = 'Hold';
									currVolOpp.Hidden_allow_Hold_status__c = True;
									/****** WVC-2085 *********/
									/*If(currVolOpp.Wish__c != Null){
										wishVolunteerIdMap.put(currVolOpp.Wish__c,currVolOpp.Volunteer_Name__C);
									}*/
									/****** WVC-2085 *********/
								} else if (newVolRole.Status__c == 'Out of Compliance'
										&& currVolOpp.Status__c == 'Approved'
										&& ((currVolOpp.Wish__C != Null && currVolOpp.Wish__r.Status != 'Granted' && currVolOpp.Wish__r.Status != 'Completed')
										|| currVolOpp.Wish__C == Null)) {
									currVolOpp.Status__c = 'Out of Compliance';
								}
								/************ WVC-2199 & WVC-2205 ********/
								If (currVolOpp.Wish__c != Null
										&& (newVolRole.Status__c == 'Out of Compliance'
										|| newVolRole.Status__c == 'Not Approved'
										|| newVolRole.Status__c == 'Former')) {
									inactiveWishVolunteerIdMap.put(currVolOpp.Wish__c, currVolOpp.Volunteer_Name__C);
									If (volunteerRoleMap.containsKey(currVolOpp.Volunteer_Name__C)) {
										volunteerRoleMap.get(currVolOpp.Volunteer_Name__C).add(currVolOpp.Role__c);
									} else {
										volunteerRoleMap.put(currVolOpp.Volunteer_Name__C, new Set<String>{
												currVolOpp.Role__c
										});
									}
								}
								/************ WVC-2199 & WVC-2205 ********/
								updateVolOppMap.put(currVolOpp.id, currVolOpp);
							}
						}
					}
				}
			}
			if (updateVolOppMap.size() > 0) {
				update updateVolOppMap.Values();
			}
			/****** WVC-2085 *********/
			if (wishVolunteerIdMap.size() > 0 || inactiveWishVolunteerIdMap.size() > 0) {
				Map<Id, String> TeamRoleIdMap = new Map<Id, String>();
				Map<String, Id> TeamNameMap = new Map<String, Id>();
				List<CaseTeamMember> UpdateTeamList = new List<CaseTeamMember>();
				Set<Id> userIdSet = new Set<Id>();
				Set<Id> subCaseIdSet = new Set<Id>();
				Map<Id, Id> userContactMap = new Map<Id, Id>();
				for (CaseTeamRole caseTeamInfo : [
						SELECT Id, Name
						FROM CaseTeamRole
				]) {
					TeamRoleIdMap.put(caseTeamInfo.Id, caseTeamInfo.Name);
					TeamNameMap.put(caseTeamInfo.Name, caseTeamInfo.Id);
				}
				/**
				 * JIRA: WLP-286
				 * Author: Gustavo Mayer
				 * Update: Sub case conversion to the single Wish Case, no need to update
				 * as there is no longer the concept of parent case.
				 */
//				for (Case subCase : [
//						SELECT Id
//						FROM Case
//						WHERE ParentId IN :inactiveWishVolunteerIdMap.keySet()
//				]) {
//					subCaseIdSet.add(subcase.Id);
//				}
				for (User volUser : [
						SELECT Id,ContactId
						FROM User
						WHERE ContactId IN :wishVolunteerIdMap.values()
						OR ContactId IN :inactiveWishVolunteerIdMap.values()
				]) {
					userIdSet.add(volUser.Id);
					userContactMap.put(volUser.Id, volUser.ContactId);
				}
				for (CaseTeamMember dbcaseTeamMember : [
						SELECT Id,MemberId, ParentId, TeamRoleId, TeamRole.Name
						FROM CaseTeamMember
						WHERE (ParentId IN :subCaseIdSet
						OR ParentId IN :inactiveWishVolunteerIdMap.keySet())
						AND MemberId IN :userIdSet
				]) {
					/****** commented for WVC-2206 **********/
					/* If(dbcaseTeamMember.TeamRole.Name.contains('(Inactive)') && wishVolunteerIdMap.containsKey(dbcaseTeamMember.ParentId)){
						 String role = dbcaseTeamMember.TeamRole.Name.Remove(' (Inactive)');
						 If(TeamNameMap.containsKey(role)){
								 dbcaseTeamMember.TeamRoleId = TeamNameMap.get(role);
								 updateTeamList.add(dbcaseTeamMember);
						 }
					 }*/
					/******** END WVC-2206 ********/
					if (!dbcaseTeamMember.TeamRole.Name.contains('(Inactive)')
							&& inactiveWishVolunteerIdMap.containsKey(dbcaseTeamMember.ParentId)
							&& volunteerRoleMap.containsKey(userContactMap.get(dbcaseTeamMember.memberId))
							&& volunteerRoleMap.get(userContactMap.get(dbcaseTeamMember.memberId)).Contains(dbcaseTeamMember.TeamRole.Name)) {
						//String role = dbcaseTeamMember.TeamRole.Name.Remove(' (Inactive)');
						if (TeamNameMap.containsKey(dbcaseTeamMember.TeamRole.Name + ' (Inactive)')) {
							dbcaseTeamMember.TeamRoleId = TeamNameMap.get(dbcaseTeamMember.TeamRole.Name + ' (Inactive)');
							updateTeamList.add(dbcaseTeamMember);
						}
					}
				}
				If (updateTeamList.Size() > 0)
					Update updateTeamList;
				/***** End WVC-2085 *******/
			}

			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} Catch (Exception ex) {
			for (Volunteer_Roles__c currRec : exceptionList) {
				ErrorMessage_AC.createdebugRec('VolunteerRole_OnAfterUpdateHelper_AC', String.valueof(currRec),
						String.valueOf(ex), 'updateVolunteerOpportunity',
						currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
			if (!Test.isRunningTest()) {
				for (Volunteer_Roles__c currRec : exceptionList) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}
}