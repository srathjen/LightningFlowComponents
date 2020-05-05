/*****************************************************************************************************************
Author      : MST Solutions
Date        : 11/14/2016
Created By  : Mariyappan Sivathanu.
Description : 
1.This testClass is used to Relationship_AT for Relationship Contact.
2.Create Record for child wishes.
3.Submits parent wish for approval once the required number of volunteers added to the parent wish team.
4.Add parent wish team members to child wish team.
*****************************************************************************************************************/
@IsTest
public class DocusignRecipientTrigger_AT_Test {

	@IsTest
	public static void dsfsStatusRec() {
		Account chapterAcc = OrientationandTrainingUtil.createchapterAccount();
		insert chapterAcc;

		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		insert wishChild;

		Case caseRec = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		insert caseRec;

		Contact parentGurdianContact = OrientationandTrainingUtil.CreateWishFamily();
		Contact participantContact = OrientationandTrainingUtil.CreateWishFamilyparticipant();
		insert new List<Contact>{
				parentGurdianContact, participantContact
		};

		Test.startTest();
		npe4__Relationship__c gurdianRelationShipRec = OrientationandTrainingUtil.ParentLegualGuardianRelation(wishChild.Id, parentGurdianContact.Id);
		npe4__Relationship__c participantRelationShipRec = OrientationandTrainingUtil.ParticipantRelationShip(wishChild.Id, participantContact.Id);
		insert new List<npe4__Relationship__c>{
				gurdianRelationShipRec, participantRelationShipRec
		};

		Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAcc.Id);
		Contact volunterConTwo = OrientationandTrainingUtil.createVolunteerContactwithOtherPhone(chapterAcc.Id);
		insert new List<Contact>{
				volunterCon, volunterConTwo
		};

		RecursiveTriggerHandler.blockBeforeUpdate = true;
		Case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		insert wish;
		Case wishDetermination = OrientationandTrainingUtil.childWishWithConChapter(wish.Id);
		insert wishDetermination;

		CaseTeamRole roleRec = [
				SELECT Id
				FROM CaseTeamRole
				WHERE Name = 'Wish Granter'
				LIMIT 1
		];
		CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(wish.Id, volunterCon.Id, roleRec.Id);
		CaseTeamMember caseTeamMebertwo = OrientationandTrainingUtil.createCaseTeamMember(wish.Id, volunterConTwo.Id, roleRec.Id);
		insert new List<CaseTeamMember>{
				caseTeamMeber, caseTeamMebertwo
		};

		npe4__Relationship__c npe4Rec = OrientationandTrainingUtil.relationshipChild(parentGurdianContact.Id, wishChild.Id);
		insert npe4Rec;

		dsfs__DocuSign_Status__c dsfsStatus = OrientationandTrainingUtil.createDocusignStatuswithCase(caseRec.Id);
		insert dsfsStatus;
		dsfs__DocuSign_Status__c updatedsfsSubJect = new dsfs__DocuSign_Status__c();
		updatedsfsSubJect.Id = dsfsStatus.Id;
		updatedsfsSubJect.dsfs__Subject__c = 'Signature Required - Wish Form & Liability And Publicity Release Form';
		update updatedsfsSubJect;
		Test.stopTest();
		dsfs__DocuSign_Recipient_Status__c dsfsRecipient = OrientationandTrainingUtil.CreatedsfsRec(dsfsStatus.Id);
		insert dsfsRecipient;

		System.assertEquals(dsfsRecipient.dsfs__Recipient_Status__c, 'Completed');
	}

	@IsTest
	public static void dsfsStatusRecWithName() {
		Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
		insert chapterAccount;
		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		Contact parentGurdianContact = OrientationandTrainingUtil.CreateWishFamily();
		Contact participantContact = OrientationandTrainingUtil.CreateWishFamilyparticipant();
		Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
		Contact volunterConTwo = OrientationandTrainingUtil.createVolunteerContactwithOtherPhone(chapterAccount.Id);
		insert new List<Contact>{
				wishChild, parentGurdianContact, participantContact, volunterCon, volunterConTwo
		};
		Case caseRec = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		insert caseRec;
		Test.startTest();
		npe4__Relationship__c gurdianRelationShipRec = OrientationandTrainingUtil.ParentLegualGuardianRelation(wishChild.Id, parentGurdianContact.Id);
		npe4__Relationship__c participantRelationShipRec = OrientationandTrainingUtil.ParticipantRelationShip(wishChild.Id, participantContact.Id);
		insert new List<npe4__Relationship__c>{
				gurdianRelationShipRec, participantRelationShipRec
		};
		RecursiveTriggerHandler.blockBeforeUpdate = true;
		Case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		Case wishDetermination = OrientationandTrainingUtil.childWishWithConChapter(wish.Id);
		insert new List<Case>{
				wish, wishDetermination
		};
		CaseTeamRole roleRec = [
				SELECT Id
				FROM CaseTeamRole
				WHERE Name = 'Wish Granter'
				LIMIT 1
		];
		CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(wish.Id, volunterCon.Id, roleRec.Id);
		CaseTeamMember caseTeamMebertwo = OrientationandTrainingUtil.createCaseTeamMember(wish.Id, volunterConTwo.Id, roleRec.Id);
		insert new List<CaseTeamMember>{
				caseTeamMeber, caseTeamMebertwo
		};
		npe4__Relationship__c npe4Rec = OrientationandTrainingUtil.relationshipChild(parentGurdianContact.Id, wishChild.Id);
		insert npe4Rec;
		dsfs__DocuSign_Status__c dsfsStatus = OrientationandTrainingUtil.createDocusignStatuswithCase(caseRec.Id);
		insert dsfsStatus;
		Attachment newAttachment = OrientationandTrainingUtil.CreateAttachmentRecordWishChild(dsfsStatus.Id);
		insert newAttachment;

		dsfs__DocuSign_Recipient_Status__c dsfsRecipient = OrientationandTrainingUtil.CreatedsfsRecAsDeliver(dsfsStatus.Id);
		insert dsfsRecipient;

		dsfs__DocuSign_Recipient_Status__c updateRecipienttoComplete = new dsfs__DocuSign_Recipient_Status__c();
		updateRecipienttoComplete.Id = dsfsRecipient.Id;
		updateRecipienttoComplete .dsfs__Recipient_Status__c = 'Completed';
		update updateRecipienttoComplete;

		dsfs__DocuSign_Recipient_Status__c dsfsRecipientRec = OrientationandTrainingUtil.CreatedsfsRecAsDeliverRecord(dsfsStatus.Id);
		insert dsfsRecipientRec;

		dsfs__DocuSign_Recipient_Status__c updateRecipienttodelivered = new dsfs__DocuSign_Recipient_Status__c();
		updateRecipienttodelivered.Id = dsfsRecipientRec.Id;
		updateRecipienttodelivered.dsfs__Recipient_Status__c = 'Completed';
		update updateRecipienttodelivered;
		Test.stopTest();

		System.assertEquals(updateRecipienttoComplete.dsfs__Recipient_Status__c, 'Completed');
	}

	@IsTest
	public static void dsfsWishForm() {
		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		Case caseRec = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		Account chapterAcc = OrientationandTrainingUtil.createchapterAccount();
		Contact parentGurdianContact = OrientationandTrainingUtil.CreateWishFamily();
		Contact participantContact = OrientationandTrainingUtil.CreateWishFamilyparticipant();
		Test.startTest();
		OrientationandTrainingUtil.ParentLegualGuardianRelation(wishChild.Id, parentGurdianContact.Id);
		OrientationandTrainingUtil.ParticipantRelationShip(wishChild.Id, participantContact.Id);
		Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAcc.Id);
		Contact volunterConTwo = OrientationandTrainingUtil.createVolunteerContactwithOtherPhone(chapterAcc.Id);
		RecursiveTriggerHandler.blockBeforeUpdate = true;
		Case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		Case wishDetermination = OrientationandTrainingUtil.childWishWithConChapter(wish.Id);
		insert wishDetermination;
		CaseTeamRole roleRec = [
				SELECT Id
				FROM CaseTeamRole
				WHERE Name = 'Wish Granter'
				LIMIT 1
		];
		OrientationandTrainingUtil.createCaseTeamMember(wish.Id, volunterCon.Id, roleRec.Id);
		OrientationandTrainingUtil.createCaseTeamMember(wish.Id, volunterConTwo.Id, roleRec.Id);
		OrientationandTrainingUtil.relationshipChild(parentGurdianContact.Id, wishChild.Id);
		dsfs__DocuSign_Status__c dsfsStatus = new dsfs__DocuSign_Status__c();
		dsfsStatus .dsfs__DocuSign_Envelope_ID__c = '0204C9DD-B8B3-4D7D-B9C5-F88B921E1511';
		dsfsStatus .dsfs__Case__c = caseRec.Id;
		dsfsStatus .isConflict__c = false;
		dsfsStatus .dsfs__Envelope_Status__c = 'Sent';
		dsfsStatus .dsfs__Subject__c = 'Signature Required - Wish Form & Liability And Publicity Release Form';
		insert dsfsStatus ;
		Attachment newAttachment = OrientationandTrainingUtil.CreateAttachmentRecordWishChild(dsfsStatus .Id);
		insert newAttachment;
		dsfs__DocuSign_Recipient_Status__c dsfsRecipient = OrientationandTrainingUtil.CreatedsfsRecAsDeliver(dsfsStatus.Id);
		insert dsfsRecipient;
		dsfs__DocuSign_Recipient_Status__c updateRecipienttoComplete = new dsfs__DocuSign_Recipient_Status__c();
		updateRecipienttoComplete.Id = dsfsRecipient.Id;
		updateRecipienttoComplete .dsfs__Recipient_Status__c = 'Completed';
		update updateRecipienttoComplete;

		dsfs__DocuSign_Recipient_Status__c dsfsRecipientRec = OrientationandTrainingUtil.CreatedsfsRecAsDeliverRecord(dsfsStatus.Id);
		insert dsfsRecipientRec;

		dsfs__DocuSign_Recipient_Status__c updateRecipienttodelivered = new dsfs__DocuSign_Recipient_Status__c();
		updateRecipienttodelivered.Id = dsfsRecipientRec.Id;
		updateRecipienttodelivered.dsfs__Recipient_Status__c = 'Completed';
		update updateRecipienttodelivered;

		System.assertEquals(updateRecipienttoComplete.dsfs__Recipient_Status__c, 'Completed');
		Test.stopTest();
	}

	@IsTest
	public static void dsfsWishFormWithoutContactName() {
		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		Case caseRec = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		Account chapterAcc = OrientationandTrainingUtil.createchapterAccount();
		Contact parentGurdianContact = OrientationandTrainingUtil.CreateWishFamily();
		Contact participantContact = OrientationandTrainingUtil.CreateWishFamilyparticipant();
		Test.startTest();
		OrientationandTrainingUtil.ParentLegualGuardianRelation(wishChild.Id, parentGurdianContact.Id);
		OrientationandTrainingUtil.ParticipantRelationShip(wishChild.Id, participantContact.Id);
		Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAcc.Id);
		Contact volunterConTwo = OrientationandTrainingUtil.createVolunteerContactwithOtherPhone(chapterAcc.Id);
		RecursiveTriggerHandler.blockBeforeUpdate = true;
		Case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		Case wishDetermination = OrientationandTrainingUtil.childWishWithConChapter(wish.Id);
		insert wishDetermination;
		CaseTeamRole roleRec = [
				SELECT Id
				FROM CaseTeamRole
				WHERE Name = 'Wish Granter'
				LIMIT 1
		];
		OrientationandTrainingUtil.createCaseTeamMember(wish.Id, volunterCon.Id, roleRec.Id);
		OrientationandTrainingUtil.createCaseTeamMember(wish.Id, volunterConTwo.Id, roleRec.Id);
		OrientationandTrainingUtil.relationshipChild(parentGurdianContact.Id, wishChild.Id);
		dsfs__DocuSign_Status__c dsfsStatus = new dsfs__DocuSign_Status__c();
		dsfsStatus .dsfs__DocuSign_Envelope_ID__c = '0204C9DD-B8B3-4D7D-B9C5-F88B921E1511';
		dsfsStatus .dsfs__Case__c = caseRec.Id;
		dsfsStatus .isConflict__c = false;
		dsfsStatus .dsfs__Envelope_Status__c = 'Sent';
		dsfsStatus .dsfs__Subject__c = 'Signature Required - Wish Form & Liability And Publicity Release Form';
		insert dsfsStatus;
		Attachment newAttachment = OrientationandTrainingUtil.CreateAttachmentRecordWishChild(dsfsStatus .Id);
		insert newAttachment;
		dsfs__DocuSign_Recipient_Status__c dsfsRecipient = OrientationandTrainingUtil.CreatedsfsRecAsDeliver(dsfsStatus.Id);
		insert dsfsRecipient;
		dsfs__DocuSign_Recipient_Status__c updateRecipienttoComplete = new dsfs__DocuSign_Recipient_Status__c();
		updateRecipienttoComplete.Id = dsfsRecipient.Id;
		updateRecipienttoComplete .dsfs__Recipient_Status__c = 'Completed';
		update updateRecipienttoComplete;
		dsfs__DocuSign_Recipient_Status__c dsfsRecipientRec = OrientationandTrainingUtil.CreatedsfsRecAsDeliverRecord(dsfsStatus.Id);
		insert dsfsRecipientRec;
		dsfs__DocuSign_Recipient_Status__c updateRecipienttodelivered = new dsfs__DocuSign_Recipient_Status__c();
		updateRecipienttodelivered.Id = dsfsRecipientRec.Id;
		updateRecipienttodelivered.dsfs__Recipient_Status__c = 'Completed';
		update updateRecipienttodelivered;
		System.assertEquals(updateRecipienttoComplete.dsfs__Recipient_Status__c, 'Completed');
		Test.stopTest();
	}
}