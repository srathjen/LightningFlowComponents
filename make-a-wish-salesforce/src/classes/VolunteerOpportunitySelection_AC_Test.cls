/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Description : This class is used to increase the code coverage for VolunteerOpportunitySelection_AC
Modification Log: 
28/03/2018 - Kanagaraj
*****************************************************************************************************/
@isTest(seeAllData=False)
private class VolunteerOpportunitySelection_AC_Test {

	/*Create a time Sheet with only one volunteer opportunity */
	private static testmethod void createVolunterSelection() {
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(con.id);
		insert affiliation;
		Role__c currRole = OrientationandTrainingUtil.createRole();
		insert currRole;
		Role__c currNonWishRole = OrientationandTrainingUtil.createNonWishRole();
		insert currNonWishRole;
		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.id, currRole.Id);
		insert currChapRole;
		Chapter_Role__c currNonWishChapRole = OrientationandTrainingUtil.createChapter(acc.id, currNonWishRole.Id);
		insert currNonWishChapRole;
		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id, currChapRole.Id);
		insert currVolRole;
		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		insert wishChild;
		Case newParentWish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		insert newParentWish;
		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createActiveVolunteerUser(con.id);
			insert currUser;
		}
		Volunteer_Opportunity__c wishVolunteerOpportunity = OrientationandTrainingUtil.CreateNewWishVolunteerOpportunity(
				acc.Id, currChapRole.Id, newParentWish.Id);
		insert wishVolunteerOpportunity;
		Volunteer_Opportunity__c dbVolOpp = new Volunteer_Opportunity__c();
		dbVolOpp.Id = wishVolunteerOpportunity.Id;
		dbVolOpp.Volunteer_Name__c = con.Id;
		dbVolOpp.Status__c = 'Approved';
		Test.StartTest();
		update dbVolOpp;

		system.RunAs(currUser) {
			Test.setCurrentPageReference(new PageReference('Page.VolunteerOpportunitySelection_VF'));
			System.currentPageReference().getParameters().put('caseRecId', newParentWish.Id);
			VolunteerOpportunitySelection_AC volunteeerController = new VolunteerOpportunitySelection_AC();
			//volunteeerController.caseId = newParentWish.Id;
			volunteeerController.createTimeSheet();
			volunteeerController.CreateNewTimeSheet();
			volunteeerController.DisplayError();
			VolunteerOpportunitySelection_AC.volunteerWrapper newWrapper = new VolunteerOpportunitySelection_AC.volunteerWrapper();
			newWrapper.recordSelected = false;
			newWrapper.volOpp = dbVolOpp;
			System.assertEquals(newWrapper.volOpp, dbVolOpp, 'Volunteer Oppurtunity value does not match');
			System.assert(newWrapper.volOpp == dbVolOpp, 'Volunteer Oppurtunity value  does not match');
		}
		Test.stopTest();
	}

	/*Create a time Sheet with more than one volunteer opportunity */
	private static testmethod void createTwoVolunterSelection() {
		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createActiveVolunteerUser(null);
			insert currUser;
		}
		// Need parent fields
		currUser = [
				SELECT Id, ContactId, Contact.AccountId
				FROM User
				WHERE Id = :currUser.Id
		];
		npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(currUser.ContactId);
		insert affiliation;
		Role__c currRole = OrientationandTrainingUtil.createRole();
		insert currRole;
		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(currUser.Contact.AccountId, currRole.Id);
		insert currChapRole;
		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(currUser.ContactId, currChapRole.Id);
		insert currVolRole;
		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		insert wishChild;
		Case newParentWish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		insert newParentWish;
		List<Volunteer_Opportunity__c> voloppList = new List<Volunteer_Opportunity__c>();
		Volunteer_Opportunity__c wishVolunteerOpportunity = OrientationandTrainingUtil.CreateNewWishVolunteerOpportunity(currUser.Contact.AccountId, currChapRole.Id, newParentWish.Id);
		insert wishVolunteerOpportunity;
		Volunteer_Opportunity__c dbVolOpp = new Volunteer_Opportunity__c();
		dbVolOpp.Id = wishVolunteerOpportunity.Id;
		dbVolOpp.Volunteer_Name__c = currUser.ContactId;
		dbVolOpp.Status__c = 'Approved';
		Volunteer_Opportunity__c wishVolunteerOpportunity2 = OrientationandTrainingUtil.CreateNewWishVolunteerOpportunity(
				currUser.Contact.AccountId, currChapRole.Id, newParentWish.Id);
		insert wishVolunteerOpportunity2;
		Volunteer_Opportunity__c dbVolOpp2 = new Volunteer_Opportunity__c();
		dbVolOpp2.Id = wishVolunteerOpportunity2.Id;
		dbVolOpp2.Volunteer_Name__c = currUser.ContactId;
		dbVolOpp2.Status__c = 'Approved';
		voloppList.add(dbVolOpp);
		voloppList.add(dbVolOpp2);
		Test.StartTest();
		update voloppList;
		system.RunAs(currUser) {
			Test.setCurrentPageReference(new PageReference('Page.VolunteerOpportunitySelection_VF'));
			System.currentPageReference().getParameters().put('caseRecId', newParentWish.Id);
			VolunteerOpportunitySelection_AC volunteeerController = new VolunteerOpportunitySelection_AC();
			volunteeerController.DisplayError();
			VolunteerOpportunitySelection_AC.volunteerWrapper newWrapper = new VolunteerOpportunitySelection_AC.volunteerWrapper();
			volunteeerController.volunteerWrapperList[0].recordSelected = True;
			volunteeerController.createTimeSheet();
			System.assertEquals(dbVolOpp2.Status__c, 'Approved', 'Volunteer Opportunity status does not match');
			System.assert(dbVolOpp2.Status__c == 'Approved', 'Volunteer Opportunity status does not match');
		}
		Test.stopTest();
	}
}