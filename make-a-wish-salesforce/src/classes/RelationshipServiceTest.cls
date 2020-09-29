@IsTest
public class RelationshipServiceTest {

	@TestSetup
	public static void setup() {
		trac_TriggerHandlerBase.blockTrigger = true;

		Account azAccount = TestDataFactory.createAccount(1)[0];
		azAccount.Name = 'Make-A-Wish Arizona';
		azAccount.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
		insert azAccount;

		ICD_Codes__c icdCode = TestDataFactory.createIcdCode(1)[0];
		icdCode.Name = 'Q917';
		insert icdCode;

		Contact wishChild = new Contact();
		wishChild.FirstName = 'Jacky';
		wishChild.LastName = 'Johnson';
		wishChild.RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
		wishChild.AccountId = azAccount.Id;

		List<Contact> contactList = TestDataFactory.createContact(7);
		Contact medHolland = contactList.get(0);
		medHolland.FirstName = 'Francis';
		medHolland.LastName = 'Holland';
		medHolland.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
		medHolland.AccountId = azAccount.Id;
		Contact medWatson = contactList.get(1);
		medWatson.FirstName = 'Jessica';
		medWatson.LastName = 'Watson';
		medWatson.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
		medWatson.Type_of_Contact__c = 'Referrer&Treating';
		medWatson.npe01__WorkEmail__c = 'nurse.watson@email.com';
		medWatson.AccountId = azAccount.Id;
		Contact medSmith = contactList.get(2);
		medSmith.FirstName = 'Jacobi';
		medSmith.LastName = 'Smith';
		medSmith.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
		medSmith.AccountId = azAccount.Id;
		Contact medJohnson = contactList.get(3);
		medJohnson.FirstName = 'Pam';
		medJohnson.LastName = 'Johnson';
		medJohnson.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
		medJohnson.AccountId = azAccount.Id;
		Contact famGeorge = contactList.get(4);
		famGeorge.FirstName = 'William';
		famGeorge.LastName = 'George';
		famGeorge.RecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
		famGeorge.AccountId = azAccount.Id;
		famGeorge.Type_of_Contact__c = Constant_AC.CONTACT_TYPE_REFERRING;
		famGeorge.Email = 'william@george.com';
		famGeorge.Phone = '520-830-8978';
		famGeorge.Relationship_Type__c = Constant_AC.CONTACT_TYPE_PARENT_LEGAL_GUARDIAN;
		famGeorge.Wish_Child_Id_Hidden__c = wishChild.Id;
		famGeorge.Relationship__c = 'Father';
		Contact famGeorge2 = contactList.get(5);
		famGeorge2.FirstName = 'Natalie';
		famGeorge2.LastName = 'George';
		famGeorge2.RecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
		famGeorge2.AccountId = azAccount.Id;
		famGeorge2.Type_of_Contact__c = Constant_AC.CONTACT_TYPE_SIBLING;
		famGeorge2.Relationship_Type__c = Constant_AC.CONTACT_TYPE_SIBLING;
		famGeorge2.Wish_Child_Id_Hidden__c = wishChild.Id;
		insert contactList;

		Lead qualifiedLead = TestDataFactory.createQualifiedLead(azAccount.Id, icdCode.Id);
		qualifiedLead.FirstName = 'Fred';
		qualifiedLead.LastName = 'George';
		qualifiedLead.Referring_MP__c = medWatson.Id;
		qualifiedLead.Treating_MP__c = medHolland.Id;
		qualifiedLead.Best_Contact__c = famGeorge.Id;
		qualifiedLead.Alt_1_MP__c = medSmith.Id;
		qualifiedLead.Alt_2_MP__c = medJohnson.Id;
		qualifiedLead.Wish_Family_ContactId__c = famGeorge.Id;
		qualifiedLead.Hidden_Additional_Parent_Id__c = famGeorge2.Id;
		insert qualifiedLead;

		Database.LeadConvert leadConvert = new Database.LeadConvert();
		leadConvert.setLeadId(qualifiedLead.Id);
		leadConvert.setConvertedStatus('Qualified');
		leadConvert.setDoNotCreateOpportunity(true);
		Database.convertLead(leadConvert);

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void buildLeadConvertRelationships() {
		Lead lead = [
				SELECT Id, ConvertedContactId, Referring_MP__c, Treating_MP__c, Best_Contact__c, Alt_1_MP__c, Alt_2_MP__c,
						Hidden_DV_form_Medical_professional_Type__c, Wish_Family_ContactId__c,
						Hidden_Additional_Parent_Id__c, Relationship_to_child__c,
						Additional_Parent_Relationship_to_Child__c, Parent_Relationship_to_Child__c
				FROM Lead
		];
		Test.startTest();
		RelationshipService.buildLeadConvertRelationships(lead);
		Test.stopTest();
	}

	@IsTest
	public static void buildLeadConvertRelationshipFamily() {
		List<Contact> familyContacts = [
				SELECT Id, FirstName, LastName, RecordTypeId, Type_of_Contact__c, Email, Phone, Wish_Child_Id_Hidden__c,
                        Relationship__c, Relationship_Type__c
				FROM Contact
				WHERE Name IN ('William George', 'Natalie George')
				ORDER BY Name DESC
		];

		Test.startTest();
		List<npe4__Relationship__c> famRelation = RelationshipService.buildWishFamilyLeadConvertRelationship(familyContacts);
		Test.stopTest();

		System.assertEquals(true, famRelation[0].Parent_Legal_Guardian__c);
		System.assertEquals(Constant_AC.CONTACT_TYPE_SIBLING, famRelation[1].npe4__Type__c);
	}
}