/*****************************************************************************************************************
Author      : MST Solutions
Date        : 12/01/2016
Description : This class contains test method for CaseFile object
Modification Log: 
28/03/2018 - Kanagaraj
*******************************************************************************************************************/
@IsTest
public class VolunteerTaskTransfer_AC_Test {
	//This method is used to transfer the task
	static testMethod void transferTask() {
		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		insert wishChild;
		Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		insert parentCase;
		Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
		insert chapterAccount;
		Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
		insert volunterCon;
		User volunterUser;
		System.runAs (new User(Id = UserInfo.getUserId())) {
			volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.id);
			insert volunterUser;
		}
		Task newTask = new Task();
		newTask.Subject = 'Conduct Interview';
		newTask.ActivityDate = Date.today();
		newTask.WhatId = parentCase.Id;
		newTask.OwnerId = volunterUser.Id;
		insert newTask;
		ApexPages.StandardController sc = new ApexPages.StandardController(newTask);
		VolunteerTaskTransfer_AC volunteerTask = new VolunteerTaskTransfer_AC(sc);
		CaseTeamRole roleRec = [
				SELECT Id
				FROM CaseTeamRole
				WHERE Name = 'Wish Granter'
		];
		CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.id, volunterUser.id, roleRec.id);
		insert caseTeamMeber;
		volunteerTask.getAssigners();
		volunteerTask.assignerId = volunterUser.Id;
		volunteerTask.transferTask();
		System.assertEquals(newTask.Subject, 'Conduct Interview', 'Task subject does not match');
		System.assert(newTask.Subject == 'Conduct Interview', 'Task subject does not match');
	}
}