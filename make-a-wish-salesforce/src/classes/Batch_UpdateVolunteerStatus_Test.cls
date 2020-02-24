/*************************************************************************************************************************************************
Created by: Pavithra
Author : MST Solutions
CreateDate : 10/05/2016
Description :Batch_UpdateVolunteerStatus_Test is used to increase the code coverage for Batch_UpdateVolunteerStatus_AC class.
*************************************************************************************************************************************************/

@isTest
public class Batch_UpdateVolunteerStatus_Test {

	static testmethod void updateVolunteerStatus() {
		Account chapterAc = OrientationandTrainingUtil.createchapterAccount();
        insert chapterAc;
		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAc.Id);
        insert volunteerContact;
		npe5__Affiliation__c affiliation = OrientationandTrainingUtil.CreateAffiliation(volunteerContact.Id);
        insert affiliation;
		affiliation.npe5__Status__c = 'Active';
		Update affiliation;
		Background_check__c bc = OrientationandTrainingUtil.createBackgroundCheckRec(volunteerContact.Id);
        insert bc;
		Conflict_Of_Interest__c conOfIntrest = OrientationandTrainingUtil.createCOI(volunteerContact.Id);
        insert conOfIntrest;
		Role__c wishGranterRole = OrientationandTrainingUtil.createRole();
        insert wishGranterRole;
		Role__c nonWishRole = OrientationandTrainingUtil.createNonWishRole();
        insert nonWishRole;
		Role__C boardMemberRole = OrientationandTrainingUtil.createRole();
        insert boardMemberRole;
		boardMemberRole.Name = Constant_AC.BOARD_MEMBER_RT_LABEL;
		Update boardMemberRole;

		Chapter_Role__c wishGranterChapterRole = OrientationandTrainingUtil.createChapter(chapterAc.Id, wishGranterRole.Id);
        insert wishGranterChapterRole;
		Chapter_Role__c nonWishChapterRole = OrientationandTrainingUtil.createChapter(chapterAc.Id, nonWishRole.Id);
        insert nonWishChapterRole;
		Chapter_Role__c boardMemberChapterRole = OrientationandTrainingUtil.createChapter(chapterAc.Id, boardMemberRole.Id);
        insert boardMemberChapterRole;

        Volunteer_Roles__c wishGranterVolRole = OrientationandTrainingUtil.createVolRole(volunteerContact.Id, wishGranterChapterRole.Id);
        insert wishGranterVolRole;
        Volunteer_Roles__c nonWishVolRole = OrientationandTrainingUtil.createVolRole(volunteerContact.Id, nonWishChapterRole.Id);
        insert nonWishVolRole;
		Volunteer_Roles__c boardMemberVolRole = OrientationandTrainingUtil.createVolRole(volunteerContact.Id, boardMemberChapterRole.Id);
        insert boardMemberVolRole;
		Database.executeBatch(new Batch_UpdateVolunteerStatus_AC());
		system.assertEquals(boardMemberRole.Name, Constant_AC.BOARD_MEMBER_RT_LABEL, 'Role is not board member');
		system.assert(affiliation.npe5__Status__c == 'Active', 'status updated incorrectly');
	}
	
	static testmethod void updateVolunteerSingleActiveStatus() {
		Account chapterAc = OrientationandTrainingUtil.createchapterAccount();
        insert chapterAc;
		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAc.Id);
        insert volunteerContact;
		npe5__Affiliation__c affiliation = OrientationandTrainingUtil.CreateAffiliation(volunteerContact.Id);
        insert affiliation;
		affiliation.npe5__Status__c = 'Active';
		Update affiliation;
		//Chapter_Role__c singleDayChapterRole = OrientationandTrainingUtil.createChapter(chapterAc.Id,wishGranterRole.Id);
		Role__C singleDayEventRole = OrientationandTrainingUtil.createRole();
        insert singleDayEventRole;
		singleDayEventRole.Name = 'Single Day Event Volunteer';
		Update singleDayEventRole;

		Chapter_Role__c singleDayChapterRole = OrientationandTrainingUtil.createChapter(chapterAc.Id, singleDayEventRole.Id);
        insert singleDayChapterRole;
		Volunteer_Roles__c singleDayVolRole = OrientationandTrainingUtil.createVolRole(volunteerContact.Id, singleDayChapterRole.Id);
        insert singleDayVolRole;
		Non_Wish_Events__c event = OrientationandTrainingUtil.CreateEventRec(singleDayChapterRole.Id, chapterAc.Id);
        insert event;
		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        insert wishChild;
		Case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        insert wish;
		Volunteer_Opportunity__c wishVolOpp = OrientationandTrainingUtil.CreateNewWishVolunteerOpportunity(chapterAc.Id, singleDayChapterRole.Id, wish.Id);
        insert wishVolOpp;
        wishVolOpp.Volunteer_Name__c = volunteerContact.Id;
        update wishVolOpp;
		Volunteer_Opportunity__c nonWishVolOpp = OrientationandTrainingUtil.CreateNonWishVolunteerOpportunity(chapterAc.Id, singleDayChapterRole.Id, event.Id);
        insert nonWishVolOpp;
        nonWishVolOpp.Volunteer_Name__c = volunteerContact.Id;
        update nonWishVolOpp;
		List<Volunteer_Opportunity__c> volOppList = new List<Volunteer_Opportunity__c>();
		volOppList.add(wishVolOpp);
		volOppList.add(nonWishVolOpp);
//		insert volOppList;
		Database.executeBatch(new Batch_UpdateVolunteerStatus_AC());
		system.assertEquals(volOppList[0].Volunteer_Name__c, volunteerContact.Id, 'Contact id does not match');
		system.assert(singleDayEventRole.Name == 'Single Day Event Volunteer', 'Role name does not match');
	}
}