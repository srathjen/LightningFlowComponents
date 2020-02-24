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
public class Relationship_AT_Test {

	// Method to invoke Contact Parent Guardian
	static testMethod void relatedContactParentGuardian() {
		Contact contactWishChild = OrientationandTrainingUtil.CreateWishChild();
		insert contactWishChild;
		Contact contactWishParent = OrientationandTrainingUtil.CreateWishFamily();
		insert contactWishParent;
		contact contactswish = new contact();
		contactswish.id = contactWishParent.id;
		contactswish.IsParentGuardian__c = 'ParentGuardian';
		update contactswish;
		npe4__Relationship__c relationShip = OrientationandTrainingUtil.relationshipChild(contactWishChild.id, contactswish.id);
		insert relationShip;
	}

	// Method to invoke Contact Participant Guardian
	static testMethod void relatedContactParticipantGuardian() {
		Contact contactWishChild = OrientationandTrainingUtil.CreateWishChild();
		insert contactWishChild;
		Contact contactWishParent = OrientationandTrainingUtil.CreateWishFamily();
		insert contactWishParent;
		contact contactswish = new contact();
		contactswish.id = contactWishParent.id;
		contactswish.IsParentGuardian__c = 'Participant';
		update contactswish;
		npe4__Relationship__c relationShip = OrientationandTrainingUtil.relationshipChild(contactWishChild.id, contactswish.id);
		insert relationShip;
	}

	// Method to invoke Contact Parent/Legal Guardian
	static testMethod void relatedContactParentOrLegalGuardian() {
		Contact contactWishChild = OrientationandTrainingUtil.CreateWishChild();
		insert contactWishChild;
		Contact contactWishParent = OrientationandTrainingUtil.CreateWishFamily();
		insert contactWishParent;
		contact contactswish = new contact();
		contactswish.id = contactWishChild.id;
		contactswish.IsParentGuardian__c = 'ParentGuardian';
		contactswish.Parent_Legal_Guardian__c = 'Parent/Guardian';
		contactswish.Recipient_Email__c = 'test@gmail.com';
		contactswish.First_Recipient_Name__c = 'test';
		update contactswish;
		npe4__Relationship__c relationShip = OrientationandTrainingUtil.relationshipChild(contactWishParent.id, contactswish.id);
		insert relationShip;
	}

	//This method is used to verify the after update functionlity when upadte parent guardian as true
	static testMethod void relationshipRecordUpdate() {
		Contact contactWishChild = OrientationandTrainingUtil.CreateWishChildCon();
		insert contactWishChild;
		Contact contactWishParent = OrientationandTrainingUtil.CreateWishFamilyForRelationship();
		insert contactWishParent;
		npe4__Relationship__c relationShip = OrientationandTrainingUtil.relationshipChildWithFalse(contactWishParent.id, contactWishChild.id);
		insert relationShip;
		npe4__Relationship__c newRelation = new npe4__Relationship__c();
		newRelation.Id = relationShip.Id;
		newRelation.Parent_Legal_Guardian__c = True;
		update newRelation;
	}

	static testMethod void updatewish_test1() {
		Contact contactWishChild = OrientationandTrainingUtil.CreateWishChildCon();
		insert contactWishChild;
		Contact contactWishParent = OrientationandTrainingUtil.CreateWishFamilyForRelationship();
		insert contactWishParent;
		npe4__Relationship__c relationShip = OrientationandTrainingUtil.relationshipChildWithFalse(contactWishParent.id,
				contactWishChild.id);
		insert relationShip;
		npe4__Relationship__c newRelation = new npe4__Relationship__c();
		newRelation.Id = relationShip.Id;
		newRelation.Parent_Legal_Guardian__c = True;
		newRelation.Wish_Participant__c = True;
		update newRelation;
	}
	static testMethod void updatewish_test2() {
		Contact contactWishChild = OrientationandTrainingUtil.CreateWishChildCon();
		insert contactWishChild;
		Contact contactWishParent = OrientationandTrainingUtil.CreateWishFamilyForRelationship();
		insert contactWishParent;
		npe4__Relationship__c relationShip = OrientationandTrainingUtil.relationshipChildWithFalse(contactWishParent.id,
				contactWishChild.id);
		insert relationShip;
		npe4__Relationship__c newRelation = new npe4__Relationship__c();
		newRelation.Id = relationShip.Id;
		newRelation.Parent_Legal_Guardian__c = False;
		newRelation.Wish_Participant__c = False;
		update newRelation;
	}
	static testMethod void updatewish_test3() {
		Contact contactWishChild = OrientationandTrainingUtil.CreateWishChildCon();
		insert contactWishChild;
		Contact contactWishParent = OrientationandTrainingUtil.CreateWishFamilyForRelationship();
		insert contactWishParent;
		npe4__Relationship__c relationShip = OrientationandTrainingUtil.relationshipChildWithFalse(contactWishParent.id,
				contactWishChild.id);
		insert relationShip;
		npe4__Relationship__c newRelation = new npe4__Relationship__c();
		newRelation.Id = relationShip.Id;
		newRelation.Parent_Legal_Guardian__c = False;
		newRelation.Wish_Participant__c = True;
		update newRelation;
	}

	//This method is used to create test data for medicalprofcontact
	static testMethod void createMedicalProfContact() {
		Contact contactWishChild = OrientationandTrainingUtil.CreateWishChildCon();
		insert contactWishChild;
		Contact contactMedicalProf = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
		insert contactMedicalProf;
		npe4__Relationship__c relationShip = OrientationandTrainingUtil.relationshipChildWithFalse(contactMedicalProf.id,
				contactWishChild.id);
		insert relationShip;
	}

	static testMethod void deleteRelationship() {
		Contact contactWishChild = OrientationandTrainingUtil.CreateWishChildCon();
		insert contactWishChild;
		Contact contactMedicalProf = OrientationandTrainingUtil.CreateTreatingMedicalProfContact();
		insert contactMedicalProf;
		npe4__Relationship__c relationShip = OrientationandTrainingUtil.relationshipChildWithFalse(contactMedicalProf.id,
				contactWishChild.id);
		insert relationShip;
		Delete relationShip;
	}
}