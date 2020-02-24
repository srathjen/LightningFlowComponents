/****************************************************************************************
Author : MST Solutions
CreateDate : 10/06/2017
Description : This MovetoHistorical_Test is used to increase the code coverage for MovetoHistorical controller.
*****************************************************************************************/

@isTest
public class MovetoHistorical_Test {
	//This callCheckHistoricalRole method is used to increase the code coverage for "UpdateVolunteerOpportunity" methods.
	private static testmethod void callCheckHistoricalRole() {
		Id wishVolunteerOpportunity = Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID;
		Role__c currRole = OrientationandTrainingUtil.createRole();
		insert currRole;
		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		insert wishChild;
		Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
		insert chapterAccount;
		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
		insert volunteerContact;
		//Contact wishChild1=OrientationandTrainingUtil.CreateWishChild();

		Account acc = OrientationandTrainingUtil.createchapterAccount();
		insert acc;
		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.id, currRole.Id);
		insert currChapRole;
		Contact volCnt = OrientationandTrainingUtil.createVolunteerContact(acc.Id);
		insert volCnt;
		Case newParentWish = OrientationandTrainingUtil.CreateParentCase(volCnt.Id);
		insert newParentWish;
		Volunteer_Opportunity__c volOpp = OrientationandTrainingUtil.CreateNewWishVolunteerOpportunity(acc.Id, currChapRole.Id, newParentWish.Id);
		insert volOpp;
		MovetoHistorical.CheckHistoricalRole(volOpp.Id);
		Volunteer_Opportunity__c opp = new Volunteer_Opportunity__c();
		opp.Wish__c = newParentWish.Id;
		opp.Chapter_Role_Opportunity__c = currChapRole.Id;
		opp.RecordTypeId = wishVolunteerOpportunity;
		opp.Volunteer_Name__c = volunteerContact.id;
		insert opp;
		User thisUser = [
				SELECT Id
				FROM User
				WHERE Id = :UserInfo.getUserId()
		];
		MovetoHistorical.UpdateVolunteerOpportunity(opp.Id);
		System.runAs (thisUser) {
			Test.startTest();
			Id CaseTeamId;
			CaseTeamRole ctr = [
					SELECT id
					from CaseTeamRole
					where Name = 'Wish Granter'
			];
			CaseTeamId = ctr.Id;
			if (ctr.Id == NULL) {
				CaseTeamRole ctr1 = OrientationandTrainingUtil.CreateCaseTeamRole();
				CaseTeamId = ctr1.Id;
			}
			CaseTeamMember caseMemeber = OrientationandTrainingUtil.createWishTeamMemberwithTeamRole(newParentWish.Id, wishChild.Id, CaseTeamId);
			Test.stopTest();
		}
		// MovetoHistorical.UpdateVolunteerOpportunity(volOpp.Id);
		//System.AssertEquals(opp.Id, volOpp.Id);
	}
}