/*****************************************************************************************
Created By  : MST
CreatedDate : 11/17/2017
Author : MST Solutions
Description : This class is used to increase the code coverage for batch_CreateBirthdayTask_AC
*************************************************************************************/

@isTest(seeAllData=False)
public class batch_CreateBirthdayTask_AC_Test {
/*

	//Used to create birthday task for volunteers
	static testmethod void assignTaskToVolunteer() {
		Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
		Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
		insert new List<Account>{
				chapterAccount, chapterAmericaAccount
		};

		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		insert wishChild;

		Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		insert parentCase;

		Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
		insert volunterCon;

		User volunterUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunterCon.id);
		insert volunterUser;

		CaseTeamRole roleRec = [
				SELECT Id
				FROM CaseTeamRole
				WHERE Name = 'Wish Granter'
		];
		CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(parentCase.id, volunterUser.id, roleRec.id);
		insert caseTeamMeber;
		//System.assertEquals(parentCase.Birthdate__c, wishChild.Birthdate);
		Test.startTest();
		DataBase.executeBatch(new batch_CreateBirthdayTask_AC());
		Test.stopTest();
	}

	//Used to create birthday task for Case Owner
	static testmethod void assignTaskToCaseOwner() {
		Account chapAccount = OrientationandTrainingUtil.AlabamaAccount();
		insert chapAccount;

		Contact wishChildCon = OrientationandTrainingUtil.CreateWishChild();
		Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapAccount.id);
		insert new List<Contact>{
				wishChildCon, volunterCon
		};

		Case parentWish = OrientationandTrainingUtil.CreateParentCase(wishChildCon.Id);
		insert parentWish;

		//System.assertEquals(parentWish.Birthdate__c, wishChildCon.Birthdate);
		Test.startTest();
		DataBase.executeBatch(new batch_CreateBirthdayTask_AC());
		Test.stopTest();
	}

	//Used to test schedule method
	static testmethod void testschedule() {
		Test.startTest();
		batch_CreateBirthdayTaskSchedule_AC reminder = new batch_CreateBirthdayTaskSchedule_AC();
		String sch = '0 0 13 * * ?';
		String jobID = System.schedule('Wish Child Birthday', sch, reminder);
		Test.stopTest();
	}
*/

}