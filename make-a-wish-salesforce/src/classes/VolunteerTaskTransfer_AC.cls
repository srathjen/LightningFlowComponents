/**
 * @description		Used to transfer open activities task for "Wish Granter" and "Wish Mentor"
 *
 * @author			MST Solutions
 * @createdDate		2016-11-28
 */
public class VolunteerTaskTransfer_AC {
	public Task currentTask;
	public Id assignerId { get; set; }
	public String communityBaseUrl { get; set; }

	public VolunteerTaskTransfer_AC(ApexPages.StandardController controller) {
		this.currentTask = (Task) controller.getRecord();
		communityBaseUrl = '';
	}

	/**
     * @description		Get the assigner list from parent case.
     *
     * @return			List<SelectOption>
     *
     * @author			MST Solutions
     * @createdDate		unknown
     */
	public List<SelectOption> getAssigners() {
		List<Task> taskInfoList = [
			SELECT Id, OwnerId, WhatId
			FROM Task
			WHERE Id = :currentTask.Id
		];

		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('Select', 'Please Select', true));

		if (taskInfoList.size() > 0) {
			Set<Id> caseTeamMemberIdSet = new Set<Id>();
			Map<Id,String> userInfoMap = new Map<Id,String>();

			for (CaseTeamMember caseTeamMem : [
				SELECT Id, MemberId, ParentId
				FROM CaseTeamMember
				WHERE (TeamRole.Name = :Constant_AC.CASE_TEAM_ROLE_WISH_GRANTER_MENTOR OR TeamRole.Name = :Constant_AC.CASE_TEAM_ROLE_WISH_GRANTER)
				AND ParentId = :taskInfoList[0].WhatId
			]) {
				if (caseTeamMem.MemberId != taskInfoList[0].OwnerId) {
					caseTeamMemberIdSet.add(caseTeamMem.MemberId);
				}
			}

			if (caseTeamMemberIdSet.isEmpty()) {
				return options; // return empty List
			}

			for (User userInfo : [
				SELECT Id, Name
				FROM User
				WHERE Id IN :caseTeamMemberIdSet
			]) {
				userInfoMap.put(userInfo.Id, userInfo.Name);
			}

			for (Id userId : caseTeamMemberIdSet) {
				if (userInfoMap.containsKey(userId)) {
					options.add(new SelectOption(userId, userInfoMap.get(userId)));
				}
			}
		}

		return options;
	}

	/**
     * @description		Transfer Task.
     *
     * @author			MST Solutions
     * @createdDate		unknown
     */
	public void transferTask() {
		Task updateOwner = new Task();
		updateOwner.Id = currentTask.Id;
		updateOwner.OwnerId = assignerId;

		update updateOwner;

		communityBaseUrl = Url.getSalesforceBaseUrl().toExternalForm() + '/VolunteerActivities_VF';
	}

}