/**
 * @description Case Team Member Service, centralizes Case Team Member business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 4/14/2020
 */
public class CaseTeamMemberService {

	private final static String INACTIVE = '(Inactive)';
	private final static String TEAM_MEMBER_NAME_INACTIVE = 'Inactive';

	/**
	 * Update Inactive Case Team Member
	 * @param inactiveWishVolunteerIdMap
	 * @return Updated List of Case Team Member
	 */
	public static List<CaseTeamMember> updateInactiveCaseTeamMember(Map<Id, Id> inactiveWishVolunteerIdMap,
			Map<Id, Set<String>> inactiveVolunteerRoleMap) {
		List<CaseTeamMember> updateTeamList = new List<CaseTeamMember>();
		if (inactiveWishVolunteerIdMap.isEmpty()) {
			return updateTeamList;
		}
		Map<String, Id> caseTeamRoleMap = new Map<String, Id>();
		Set<Id> subCaseIdSet = new Set<Id>();
		Map<Id, Id> userContactMap = new Map<Id, Id>();
		for (CaseTeamRole caseTeamInfo : [
				SELECT Id, Name
				FROM CaseTeamRole
		]) {
			caseTeamRoleMap.put(caseTeamInfo.Name, caseTeamInfo.Id);
		}
		for (User volUser : [
				SELECT Id,ContactId
				FROM User
				WHERE ContactId IN :inactiveWishVolunteerIdMap.values()
		]) {
			userContactMap.put(volUser.Id, volUser.ContactId);
		}
		for (CaseTeamMember caseTeamMember : [
				SELECT Id,MemberId, ParentId, TeamRoleId, TeamRole.Name
				FROM CaseTeamMember
				WHERE (ParentId IN :subCaseIdSet
				OR ParentId IN :inactiveWishVolunteerIdMap.keySet())
				AND MemberId IN :userContactMap.keySet()
		]) {
			if (!caseTeamMember.TeamRole.Name.contains(INACTIVE)
					&& inactiveWishVolunteerIdMap.containsKey(caseTeamMember.ParentId)
					&& inactiveVolunteerRoleMap.containsKey(userContactMap.get(caseTeamMember.MemberId))
					&& inactiveVolunteerRoleMap.get(userContactMap.get(caseTeamMember.MemberId)).contains(caseTeamMember.TeamRole.Name)) {
				if (caseTeamRoleMap.containsKey(caseTeamMember.TeamRole.Name + ' ' + INACTIVE)) {
					caseTeamMember.TeamRoleId = caseTeamRoleMap.get(caseTeamMember.TeamRole.Name + ' ' + INACTIVE);
					updateTeamList.add(caseTeamMember);
				}
			}
		}
		update updateTeamList;
		return updateTeamList;
	}

	public static Set<Id> updateTeamRoleId(Set<Id> parentIds, Set<Id> memberIds, Map<Id, String> caseTeamMap,
			Map<Id, Id> contactUserMap, Map<Id, String> volunteerOppMap, Map<String, Id> caseTeamNameMap) {
		Set<Id> parentUpdatedIds = new Set<Id>();
		List<CaseTeamMember> caseTeamMembers = new List<CaseTeamMember>();
		for (CaseTeamMember caseTeamMember : [
				SELECT Id,MemberId, ParentId, TeamRoleId, TeamRole.Name
				FROM CaseTeamMember
				WHERE ParentId IN :parentIds
				AND MemberId IN :memberIds
		]) {
			if (!caseTeamMap.isEmpty() && caseTeamMap.containsKey(caseTeamMember.TeamRoleId)) {
				if (contactUserMap.containsKey(caseTeamMember.MemberId)) {
					if (volunteerOppMap.containsKey(contactUserMap.get(caseTeamMember.MemberId))) {
						caseTeamMember.TeamRoleId = caseTeamNameMap.get(volunteerOppMap.get(contactUserMap.get(caseTeamMember.MemberId)));
						caseTeamMembers.add(caseTeamMember);
						parentUpdatedIds.add(caseTeamMember.ParentId);
					} else if (caseTeamNameMap.containsKey(caseTeamMember.TeamRole.Name + ' (' + TEAM_MEMBER_NAME_INACTIVE + ')')) {
						caseTeamMember.TeamRoleId = caseTeamNameMap.get(caseTeamMember.TeamRole.Name + ' (' + TEAM_MEMBER_NAME_INACTIVE + ')');
						caseTeamMembers.add(caseTeamMember);
						parentUpdatedIds.add(caseTeamMember.ParentId);
					}
				}
			}
		}
		update caseTeamMembers;
		return parentUpdatedIds;
	}

	public static Map<Id, Id> findByTeamRoleNamesAndParentIdsAndMemberIds(Set<String> teamRoleNames,
			Set<Id> inactiveOwners, Set<Id> userIds) {
		Map<Id, Id> activeVolunteerMap = new Map<Id, Id>();
		for (CaseTeamMember caseTeamInfo : [
				SELECT Id, TeamRole.Name, ParentId, MemberId
				FROM CaseTeamMember
				WHERE TeamRole.Name IN :teamRoleNames
				AND ParentId IN :inactiveOwners
				AND MemberId NOT IN :userIds
				ORDER BY CreatedDate ASC
		]) {
			if (!activeVolunteerMap.containsKey(caseTeamInfo.ParentId)) {
				activeVolunteerMap.put(caseTeamInfo.ParentId, caseTeamInfo.MemberId);
			}
		}
		return activeVolunteerMap;
	}
}