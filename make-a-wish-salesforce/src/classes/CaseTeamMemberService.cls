/**
 * @description Case Team Member Service, centralizes Case Team Member business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 4/14/2020
 */
public class CaseTeamMemberService {

	private final static String INACTIVE = '(Inactive)';

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
}