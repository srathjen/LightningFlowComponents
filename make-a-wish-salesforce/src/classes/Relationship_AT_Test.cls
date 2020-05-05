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

	private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;
	private final static Id WISH_FAMILY_RT = Constant_AC.WISH_FAMILY_RT_ID;
	private final static Id MEDICAL_PROFESSIONAL_RT_ID = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;

	@TestSetup
	public static void setup() {
		List<Account> accounts = TestDataFactory.createAccount(1);
		Account account1 = accounts.get(0);
		account1.Name = 'Make-A-Wish Arizona';
		account1.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
		insert accounts;

		List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
		ICD_Codes__c icdCode = icdCodes.get(0);
		insert icdCode;

		List<Lead> leadsDataFactory = TestDataFactory.createLead(1);
		Lead lead = leadsDataFactory.get(0);
		lead.ChapterName__c = accounts[0].Id;
		lead.FirstName = 'Jack';
		lead.LastName = 'Smith';
		lead.Hidden_Chapter_Change_Confirmation__c = account1.Id;
		lead.is_Family_Aware_of_Referral__c = 'Yes';
		lead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
		lead.PD_ICD_Code__c = icdCode.Id;
		lead.Company = 'MAW';
		insert lead;

		List<Contact> contacts = TestDataFactory.createContact(3);
		Contact wishChild = contacts.get(0);
		wishChild.FirstName = 'Jack';
		wishChild.LastName = 'Smith';
		wishChild.AccountId = account1.Id;
		wishChild.ICD_10_Code__c = icdCode.Id;
		wishChild.Birthdate = Date.today().addYears(-3);
		wishChild.Diagnosis__c = wishChild.Diagnosis__c;
		wishChild.Gender__c = wishChild.Gender__c;
		wishChild.Self_describe_comment_box__c = wishChild.Self_describe_comment_box__c;
		wishChild.MobilePhone = '123456789';
		wishChild.Email = '';
		wishChild.MailingStreet = '123 Street';
		wishChild.MailingCity = 'Phoenix';
		wishChild.MailingStateCode = 'AZ';
		wishChild.MailingPostalCode = '84001';
		wishChild.MailingCountryCode = 'US';
		wishChild.Street__c = wishChild.MailingStreet;
		wishChild.State__c = wishChild.MailingState;
		wishChild.T_Shirt_Size__c = wishChild.T_Shirt_Size__c;
		wishChild.Preferred_Name__c = wishChild.Preferred_Name__c;
		wishChild.RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
		Contact family = contacts.get(1);
		family.FirstName = 'Bob';
		family.LastName = 'Smith';
		family.RecordTypeId = WISH_FAMILY_RT;
		family.Email = 'bobsmith@email.com';
		family.Phone = '9600467559';
		family.MailingStreet = '123 Street';
		family.MailingCity = 'Phoenix';
		family.MailingStateCode = 'AZ';
		family.MailingPostalCode = '84001';
		family.MailingCountryCode = 'US';
		family.IsParentGuardian__c = 'ParentGuardian';
		family.Birthdate = System.today() + 11234;
		Contact treatingMedicalProfessional = contacts.get(2);
		treatingMedicalProfessional.FirstName = 'Mark';
		treatingMedicalProfessional.LastName = 'Smith';
		treatingMedicalProfessional.Email = 'marksmith@email.com';
		treatingMedicalProfessional.Phone = '123456759';
		treatingMedicalProfessional.MailingStreet = 'KuttaiKarai Street';
		treatingMedicalProfessional.MailingCity = 'Trichy';
		treatingMedicalProfessional.MailingStateCode = 'AZ';
		treatingMedicalProfessional.MailingPostalCode = '6201717';
		treatingMedicalProfessional.Provider_Type__c = 'Nurse Practitioner';
		treatingMedicalProfessional.MailingCountryCode = 'US';
		treatingMedicalProfessional.RecordTypeId = MEDICAL_PROFESSIONAL_RT_ID;
		insert contacts;
	}

	@IsTest
	static void relatedContactParentGuardian() {
		List<Contact> contacts = [
				SELECT Id, FirstName, LastName
				FROM Contact
				WHERE LastName = 'Smith'
		];

		Contact contactWishChild;
		Contact contactWishFamily;
		for (Contact contact : contacts) {
			if (contact.FirstName.equals('Jack')) {
				contactWishChild = contact;
			} else if (contact.FirstName.equals('Bob')) {
				contactWishFamily = contact;
			}
		}

		List<npe4__Relationship__c> relationships = TestDataFactory.createRelationship(1);
		npe4__Relationship__c newRelationship = relationships.get(0);
		newRelationship.npe4__Contact__c = contactWishChild.Id;
		newRelationship.npe4__RelatedContact__c = contactWishFamily.Id;
		newRelationship.Parent_Legal_Guardian__c = true;
		insert relationships;
	}

	@IsTest
	static void relatedContactParticipantGuardian() {
		List<Contact> contacts = [
				SELECT Id, FirstName, LastName
				FROM Contact
				WHERE LastName = 'Smith'
		];

		Contact contactWishChild;
		Contact contactWishFamily;
		for (Contact contact : contacts) {
			if (contact.FirstName.equals('Jack')) {
				contactWishChild = contact;
			} else if (contact.FirstName.equals('Bob')) {
				contactWishFamily = contact;
			}
		}
		Contact contactWishParticipant = new Contact();
		contactWishParticipant.Id = contactWishFamily.Id;
		contactWishParticipant.IsParentGuardian__c = 'Participant';
		update contactWishParticipant;

		List<npe4__Relationship__c> relationships = TestDataFactory.createRelationship(1);
		npe4__Relationship__c newRelationship = relationships.get(0);
		newRelationship.npe4__Contact__c = contactWishChild.Id;
		newRelationship.npe4__RelatedContact__c = contactWishParticipant.Id;
		newRelationship.Parent_Legal_Guardian__c = true;
		insert relationships;
	}

	@IsTest
	static void relatedContactParentOrLegalGuardian() {
		List<Contact> contacts = [
				SELECT Id, FirstName, LastName
				FROM Contact
				WHERE LastName = 'Smith'
		];

		Contact contactWishChild;
		Contact contactWishFamily;
		for (Contact contact : contacts) {
			if (contact.FirstName.equals('Jack')) {
				contactWishChild = contact;
			} else if (contact.FirstName.equals('Bob')) {
				contactWishFamily = contact;
			}
		}
		contactWishFamily.IsParentGuardian__c = 'ParentGuardian';
		contactWishFamily.Parent_Legal_Guardian__c = 'Parent/Guardian';
		contactWishFamily.Recipient_Email__c = 'test@gmail.com';
		contactWishFamily.First_Recipient_Name__c = 'test';
		update contactWishFamily;

		List<npe4__Relationship__c> relationships = TestDataFactory.createRelationship(1);
		npe4__Relationship__c newRelationship = relationships.get(0);
		newRelationship.npe4__Contact__c = contactWishChild.Id;
		newRelationship.npe4__RelatedContact__c = contactWishFamily.Id;
		newRelationship.Parent_Legal_Guardian__c = true;
		insert relationships;
	}

	@IsTest
	static void relationshipRecordUpdate() {
		List<Contact> contacts = [
				SELECT Id, FirstName, LastName
				FROM Contact
				WHERE LastName = 'Smith'
		];

		Contact contactWishChild;
		Contact contactWishFamily;
		for (Contact contact : contacts) {
			if (contact.FirstName.equals('Jack')) {
				contactWishChild = contact;
			} else if (contact.FirstName.equals('Bob')) {
				contactWishFamily = contact;
			}
		}
		List<npe4__Relationship__c> relationships = TestDataFactory.createRelationship(1);
		npe4__Relationship__c newRelationship = relationships.get(0);
		newRelationship.npe4__Contact__c = contactWishChild.Id;
		newRelationship.npe4__RelatedContact__c = contactWishFamily.Id;
		newRelationship.Parent_Legal_Guardian__c = false;
		newRelationship.npe4__Type__c = 'Medical Professional';
		newRelationship.Qualifying_Medical_Professional__c = true;
		newRelationship.npe4__Status__c = 'Active';
		newRelationship.Parent_Legal_Guardian__c = true;
		insert relationships;
	}

	@IsTest
	static void updatewish_test1() {
		List<Contact> contacts = [
				SELECT Id, FirstName, LastName
				FROM Contact
				WHERE LastName = 'Smith'
		];

		Contact contactWishChild;
		Contact contactWishFamily;
		for (Contact contact : contacts) {
			if (contact.FirstName.equals('Jack')) {
				contactWishChild = contact;
			} else if (contact.FirstName.equals('Bob')) {
				contactWishFamily = contact;
			}
		}
		List<npe4__Relationship__c> relationships = TestDataFactory.createRelationship(1);
		npe4__Relationship__c newRelationship = relationships.get(0);
		newRelationship.npe4__Contact__c = contactWishChild.Id;
		newRelationship.npe4__RelatedContact__c = contactWishFamily.Id;
		newRelationship.Parent_Legal_Guardian__c = false;
		newRelationship.npe4__Type__c = 'Medical Professional';
		newRelationship.Qualifying_Medical_Professional__c = true;
		newRelationship.npe4__Status__c = 'Active';
		newRelationship.Parent_Legal_Guardian__c = false;
		insert relationships;
		npe4__Relationship__c updateRelationship = new npe4__Relationship__c();
		updateRelationship.Id = newRelationship.Id;
		updateRelationship.Parent_Legal_Guardian__c = true;
		updateRelationship.Wish_Participant__c = true;
		update updateRelationship;
	}

	@IsTest
	static void updatewish_test2() {
		List<Contact> contacts = [
				SELECT Id, FirstName, LastName
				FROM Contact
				WHERE LastName = 'Smith'
		];

		Contact contactWishChild;
		Contact contactWishFamily;
		for (Contact contact : contacts) {
			if (contact.FirstName.equals('Jack')) {
				contactWishChild = contact;
			} else if (contact.FirstName.equals('Bob')) {
				contactWishFamily = contact;
			}
		}
		List<npe4__Relationship__c> relationships = TestDataFactory.createRelationship(1);
		npe4__Relationship__c newRelationship = relationships.get(0);
		newRelationship.npe4__Contact__c = contactWishChild.Id;
		newRelationship.npe4__RelatedContact__c = contactWishFamily.Id;
		newRelationship.Parent_Legal_Guardian__c = false;
		newRelationship.npe4__Type__c = 'Medical Professional';
		newRelationship.Qualifying_Medical_Professional__c = true;
		newRelationship.npe4__Status__c = 'Active';
		newRelationship.Parent_Legal_Guardian__c = false;
		insert relationships;
		newRelationship.Parent_Legal_Guardian__c = false;
		newRelationship.Wish_Participant__c = false;
		update newRelationship;
	}

	@IsTest
	static void updatewish_test3() {
		List<Contact> contacts = [
				SELECT Id, FirstName, LastName
				FROM Contact
				WHERE LastName = 'Smith'
		];

		Contact contactWishChild;
		Contact contactWishFamily;
		for (Contact contact : contacts) {
			if (contact.FirstName.equals('Jack')) {
				contactWishChild = contact;
			} else if (contact.FirstName.equals('Bob')) {
				contactWishFamily = contact;
			}
		}
		List<npe4__Relationship__c> relationships = TestDataFactory.createRelationship(1);
		npe4__Relationship__c newRelationship = relationships.get(0);
		newRelationship.npe4__Contact__c = contactWishChild.Id;
		newRelationship.npe4__RelatedContact__c = contactWishFamily.Id;
		newRelationship.Parent_Legal_Guardian__c = false;
		newRelationship.npe4__Type__c = 'Medical Professional';
		newRelationship.Qualifying_Medical_Professional__c = true;
		newRelationship.npe4__Status__c = 'Active';
		newRelationship.Parent_Legal_Guardian__c = false;
		insert relationships;
		newRelationship.Parent_Legal_Guardian__c = false;
		newRelationship.Wish_Participant__c = true;
		update newRelationship;
	}

	@IsTest
	static void createMedicalProfContact() {
		List<Contact> contacts = [
				SELECT Id, FirstName, LastName
				FROM Contact
				WHERE LastName = 'Smith'
		];

		Contact contactWishChild;
		Contact contactMedicalProfessional;
		for (Contact contact : contacts) {
			if (contact.FirstName.equals('Jack')) {
				contactWishChild = contact;
			} else if (contact.FirstName.equals('Mark')) {
				contactMedicalProfessional = contact;
			}
		}
		List<npe4__Relationship__c> relationships = TestDataFactory.createRelationship(1);
		npe4__Relationship__c newRelationship = relationships.get(0);
		newRelationship.npe4__Contact__c = contactWishChild.Id;
		newRelationship.npe4__RelatedContact__c = contactMedicalProfessional.Id;
		newRelationship.Parent_Legal_Guardian__c = false;
		newRelationship.npe4__Type__c = 'Medical Professional';
		newRelationship.Qualifying_Medical_Professional__c = true;
		newRelationship.npe4__Status__c = 'Active';
		newRelationship.Parent_Legal_Guardian__c = false;
		insert relationships;
	}

	@IsTest
	static void deleteRelationship() {
		List<Contact> contacts = [
				SELECT Id, FirstName, LastName
				FROM Contact
				WHERE LastName = 'Smith'
		];

		Contact contactWishChild;
		Contact contactMedicalProfessional;
		for (Contact contact : contacts) {
			if (contact.FirstName.equals('Jack')) {
				contactWishChild = contact;
			} else if (contact.FirstName.equals('Mark')) {
				contactMedicalProfessional = contact;
			}
		}
		List<npe4__Relationship__c> relationships = TestDataFactory.createRelationship(1);
		npe4__Relationship__c newRelationship = relationships.get(0);
		newRelationship.npe4__Contact__c = contactWishChild.Id;
		newRelationship.npe4__RelatedContact__c = contactMedicalProfessional.Id;
		newRelationship.Parent_Legal_Guardian__c = false;
		newRelationship.npe4__Type__c = 'Medical Professional';
		newRelationship.Qualifying_Medical_Professional__c = true;
		newRelationship.npe4__Status__c = 'Active';
		newRelationship.Parent_Legal_Guardian__c = false;
		insert relationships;
		delete newRelationship;
	}
}