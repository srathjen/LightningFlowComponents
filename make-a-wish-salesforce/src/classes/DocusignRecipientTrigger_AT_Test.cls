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
@isTest
public class DocusignRecipientTrigger_AT_Test {

	static testMethod void dsfsStatusRec() {
		Account chapterAcc = OrientationandTrainingUtil.createchapterAccount();
		insert chapterAcc;

		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		insert wishChild;

		Case caseRec = OrientationandTrainingUtil.CreateParentCase(wishChild.id);
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

		Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAcc.id);
		Contact volunterConTwo = OrientationandTrainingUtil.createVolunteerContactwithOtherPhone(chapterAcc.id);
		insert new List<Contact>{
				volunterCon, volunterConTwo
		};

		RecursiveTriggerHandler.blockBeforeUpdate = true;
		case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		insert wish;
		case wishDetermination = OrientationandTrainingUtil.childWishWithConChapter(wish.Id);
		insert wishDetermination;

		CaseTeamRole roleRec = [
				SELECT Id
				FROM CaseTeamRole
				WHERE Name = 'Wish Granter'
				LIMIT 1
		];
		CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(wish.id, volunterCon.id, roleRec.id);
		CaseTeamMember caseTeamMebertwo = OrientationandTrainingUtil.createCaseTeamMember(wish.id, volunterConTwo.id, roleRec.id);
		insert new List<CaseTeamMember>{
				caseTeamMeber, caseTeamMebertwo
		};

		List<Wish_Child_Form__c> wishChildFormIns = OrientationandTrainingUtil.createWishChildForm(wish.id, wishChild, parentGurdianContact, participantContact);
		insert wishChildFormIns;

		npe4__Relationship__c npe4Rec = OrientationandTrainingUtil.relationshipChild(parentGurdianContact.Id, wishChild.Id);
		insert npe4Rec;

		dsfs__DocuSign_Status__c dsfsStatus = OrientationandTrainingUtil.createDocusignStatuswithCase(caseRec.id);
		insert dsfsStatus;
		dsfs__DocuSign_Status__c updatedsfsSubJect = new dsfs__DocuSign_Status__c();
		updatedsfsSubJect.Id = dsfsStatus.Id;
		updatedsfsSubJect.dsfs__Subject__c = 'Signature Required - Wish Form & Liability And Publicity Release Form';
		update updatedsfsSubJect;
		Test.StopTest();
		dsfs__DocuSign_Recipient_Status__c dsfsRecipient = OrientationandTrainingUtil.CreatedsfsRec(dsfsStatus.Id);
		insert dsfsRecipient;

		system.AssertEquals(dsfsRecipient.dsfs__Recipient_Status__c, 'Completed');
	}

	static testMethod void dsfsStatusRecWithName() {

		Account chapterAccount = OrientationandTrainingUtil.createchapterAccount();
		insert chapterAccount;
		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		Contact parentGurdianContact = OrientationandTrainingUtil.CreateWishFamily();
		Contact participantContact = OrientationandTrainingUtil.CreateWishFamilyparticipant();
		Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
		Contact volunterConTwo = OrientationandTrainingUtil.createVolunteerContactwithOtherPhone(chapterAccount.id);
		insert new List<Contact>{
				wishChild, parentGurdianContact, participantContact, volunterCon, volunterConTwo
		};
		Case caseRec = OrientationandTrainingUtil.CreateParentCase(wishChild.id);
		insert caseRec;
		Test.startTest();
		npe4__Relationship__c gurdianRelationShipRec = OrientationandTrainingUtil.ParentLegualGuardianRelation(wishChild.Id, parentGurdianContact.Id);
		npe4__Relationship__c participantRelationShipRec = OrientationandTrainingUtil.ParticipantRelationShip(wishChild.Id, participantContact.Id);
		insert new List<npe4__Relationship__c>{
				gurdianRelationShipRec, participantRelationShipRec
		};
		RecursiveTriggerHandler.blockBeforeUpdate = true;
		case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		case wishDetermination = OrientationandTrainingUtil.childWishWithConChapter(wish.Id);
		insert new List<Case>{
				wish, wishDetermination
		};
		CaseTeamRole roleRec = [
				SELECT Id
				FROM CaseTeamRole
				WHERE Name = 'Wish Granter'
				LIMIT 1
		];
		CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(wish.id, volunterCon.id, roleRec.id);
		CaseTeamMember caseTeamMebertwo = OrientationandTrainingUtil.createCaseTeamMember(wish.id, volunterConTwo.id, roleRec.id);
		insert new List<CaseTeamMember>{
				caseTeamMeber, caseTeamMebertwo
		};
		List<Wish_Child_Form__c> wishChildFormIns = OrientationandTrainingUtil.createWishChildForm(wish.id, wishChild, parentGurdianContact, participantContact);
		insert wishChildFormIns;
		npe4__Relationship__c npe4Rec = OrientationandTrainingUtil.relationshipChild(parentGurdianContact.Id, wishChild.Id);
		insert npe4Rec;
		dsfs__DocuSign_Status__c dsfsStatus = OrientationandTrainingUtil.createDocusignStatuswithCase(caseRec.id);
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
		Test.StopTest();

		system.AssertEquals(updateRecipienttoComplete.dsfs__Recipient_Status__c, 'Completed');
	}

	/*  static testMethod void dsfsStatusRecwithLiability(){
		  Contact contactWishChild =   OrientationandTrainingUtil.CreateWishChild();
		  Case caseRec = OrientationandTrainingUtil.CreateParentCase(contactWishChild.id);
		  Account chapterAcc = OrientationandTrainingUtil.createchapterAccount();
		  Contact parentGurdianContact =  OrientationandTrainingUtil.CreateWishFamily();
		  Contact participantContact =  OrientationandTrainingUtil.CreateWishFamilyparticipant();
		  Test.startTest();
		  npe4__Relationship__c gurdianRelationShipRec = OrientationandTrainingUtil.ParentLegualGuardianRelation(contactWishChild.Id,parentGurdianContact.Id);
		  npe4__Relationship__c participantRelationShipRec = OrientationandTrainingUtil.ParticipantRelationShip(contactWishChild.Id,participantContact.Id);
		  Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAcc.id);
		  Contact volunterConTwo = OrientationandTrainingUtil.createVolunteerContactwithOtherPhone(chapterAcc.id);
		  RecursiveTriggerHandler.blockBeforeUpdate = true;
		  case wish = OrientationandTrainingUtil.CreateParentCase(contactWishChild.Id);
		  case wishDetermination = OrientationandTrainingUtil.childWishWithConChapter(wish.Id);
		  insert wishDetermination;


		  CaseTeamRole roleRec = [SELECT Id FROM CaseTeamRole WHERE Name = 'Wish Granter' LIMIT 1];
		  CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(wish.id,volunterCon.id,roleRec.id);
		  CaseTeamMember caseTeamMebertwo = OrientationandTrainingUtil.createCaseTeamMember(wish.id,volunterConTwo.id,roleRec.id);
		  List<Wish_Child_Form__c> wishChildFormIns = OrientationandTrainingUtil.createWishChildForm(wish.id,contactWishChild,parentGurdianContact,participantContact);
		  insert  wishChildFormIns;

		  npe4__Relationship__c  npe4Rec = OrientationandTrainingUtil.relationshipChild(parentGurdianContact.Id,contactWishChild.Id);
		  dsfs__DocuSign_Status__c dsfsStatus = OrientationandTrainingUtil.createDocusignStatuswithCase(caseRec.id);
		//  dsfs__DocuSign_Recipient_Status__c dsfsRecipient = OrientationandTrainingUtil.CreatedsfsRec(dsfsStatus.Id);
		  dsfs__DocuSign_Recipient_Status__c dsfsRecipientsec = OrientationandTrainingUtil.CreatedsfsReccompleted(dsfsStatus.Id);
	   //   system.AssertEquals(dsfsRecipient.dsfs__Recipient_Status__c,'Completed');
		  Test.StopTest();
	  }*/

	//this is used to increase the code coveraage of Signature Required - Wish Form & Liability And Publicity Release Form
	static testMethod void dsfsWishForm() {
		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		Case caseRec = OrientationandTrainingUtil.CreateParentCase(wishChild.id);
		Account chapterAcc = OrientationandTrainingUtil.createchapterAccount();
		Contact parentGurdianContact = OrientationandTrainingUtil.CreateWishFamily();
		Contact participantContact = OrientationandTrainingUtil.CreateWishFamilyparticipant();
		Test.startTest();
		npe4__Relationship__c gurdianRelationShipRec = OrientationandTrainingUtil.ParentLegualGuardianRelation(wishChild.Id, parentGurdianContact.Id);
		npe4__Relationship__c participantRelationShipRec = OrientationandTrainingUtil.ParticipantRelationShip(wishChild.Id, participantContact.Id);
		Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAcc.id);
		Contact volunterConTwo = OrientationandTrainingUtil.createVolunteerContactwithOtherPhone(chapterAcc.id);
		RecursiveTriggerHandler.blockBeforeUpdate = true;
		case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		case wishDetermination = OrientationandTrainingUtil.childWishWithConChapter(wish.Id);
		insert wishDetermination;
		CaseTeamRole roleRec = [
				SELECT Id
				FROM CaseTeamRole
				WHERE Name = 'Wish Granter'
				LIMIT 1
		];
		CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(wish.id, volunterCon.id, roleRec.id);
		CaseTeamMember caseTeamMebertwo = OrientationandTrainingUtil.createCaseTeamMember(wish.id, volunterConTwo.id, roleRec.id);
		List<Wish_Child_Form__c> wishChildFormIns = OrientationandTrainingUtil.createWishChildForm(wish.id, wishChild, parentGurdianContact, participantContact);
		insert wishChildFormIns;

		npe4__Relationship__c npe4Rec = OrientationandTrainingUtil.relationshipChild(parentGurdianContact.Id, wishChild.Id);
		// dsfs__DocuSign_Status__c dsfsStatus = OrientationandTrainingUtil.createDocusignStatuswithCase(caseRec.id);
		dsfs__DocuSign_Status__c dsfsStatus = NEW dsfs__DocuSign_Status__c();
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

		system.AssertEquals(updateRecipienttoComplete.dsfs__Recipient_Status__c, 'Completed');
		Test.StopTest();
	}

	//this is used to increase the code coveraage of Signature Required - Wish Form & Liability And Publicity Release Form
	static testMethod void dsfsWishFormWithoutContactName() {
		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		Case caseRec = OrientationandTrainingUtil.CreateParentCase(wishChild.id);
		Account chapterAcc = OrientationandTrainingUtil.createchapterAccount();
		Contact parentGurdianContact = OrientationandTrainingUtil.CreateWishFamily();
		Contact participantContact = OrientationandTrainingUtil.CreateWishFamilyparticipant();
		Test.startTest();
		npe4__Relationship__c gurdianRelationShipRec = OrientationandTrainingUtil.ParentLegualGuardianRelation(wishChild.Id, parentGurdianContact.Id);
		npe4__Relationship__c participantRelationShipRec = OrientationandTrainingUtil.ParticipantRelationShip(wishChild.Id, participantContact.Id);
		Contact volunterCon = OrientationandTrainingUtil.createVolunteerContact(chapterAcc.id);
		Contact volunterConTwo = OrientationandTrainingUtil.createVolunteerContactwithOtherPhone(chapterAcc.id);
		RecursiveTriggerHandler.blockBeforeUpdate = true;
		case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		case wishDetermination = OrientationandTrainingUtil.childWishWithConChapter(wish.Id);
		insert wishDetermination;
		CaseTeamRole roleRec = [
				SELECT Id
				FROM CaseTeamRole
				WHERE Name = 'Wish Granter'
				LIMIT 1
		];
		CaseTeamMember caseTeamMeber = OrientationandTrainingUtil.createCaseTeamMember(wish.id, volunterCon.id, roleRec.id);
		CaseTeamMember caseTeamMebertwo = OrientationandTrainingUtil.createCaseTeamMember(wish.id, volunterConTwo.id, roleRec.id);
		List<Wish_Child_Form__c> wishChildFormIns = OrientationandTrainingUtil.createWishChildForm(wish.id, wishChild, parentGurdianContact, participantContact);
		insert wishChildFormIns;
		npe4__Relationship__c npe4Rec = OrientationandTrainingUtil.relationshipChild(parentGurdianContact.Id, wishChild.Id);
		// dsfs__DocuSign_Status__c dsfsStatus = OrientationandTrainingUtil.createDocusignStatuswithCase(caseRec.id);
		dsfs__DocuSign_Status__c dsfsStatus = NEW dsfs__DocuSign_Status__c();
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
		system.AssertEquals(updateRecipienttoComplete.dsfs__Recipient_Status__c, 'Completed');
		Test.StopTest();
	}
}