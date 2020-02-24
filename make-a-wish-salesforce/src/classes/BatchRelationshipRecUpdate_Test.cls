@isTest
public class BatchRelationshipRecUpdate_Test {

	static testMethod void createInterviewDate() {
		Test.startTest();
		insert OrientationandTrainingUtil.createchapterAccount();
		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		Contact parentGurdianContact = OrientationandTrainingUtil.CreateWishFamily();
		Contact participantContact = OrientationandTrainingUtil.CreateWishFamilyparticipant();
		Contact parentGurdianSecondContact = OrientationandTrainingUtil.CreateWishFamily();
		insert new List<Contact>{
				wishChild, parentGurdianContact, participantContact, parentGurdianSecondContact
		};

		//npe4__Relationship__c gurdianRelationShipRec = OrientationandTrainingUtil.ParentLegualGuardianRelation(wishChild.Id,parentGurdianContact.Id);
		//npe4__Relationship__c participantRelationShipRec = OrientationandTrainingUtil.ParticipantRelationShip(wishChild.Id,participantContact.Id);
		OrientationandTrainingUtil.ParticipantRelationShip(wishChild.Id, parentGurdianSecondContact.Id);
		case wish = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
        insert wish;
		List<Wish_Child_Form__c> wishChildFormIns = OrientationandTrainingUtil.createWishChildForm(wish.id, wishChild, parentGurdianContact, participantContact);
		insert wishChildFormIns;
		Test.stopTest();

		Database.executeBatch(new BatchRelationshipRecUpdate());
	}
}