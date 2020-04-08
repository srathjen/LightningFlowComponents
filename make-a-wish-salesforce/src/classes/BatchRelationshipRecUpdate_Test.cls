@IsTest
public class BatchRelationshipRecUpdate_Test {

	private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;
	private final static Id WISH_FAMILY_RT = Constant_AC.WISH_FAMILY_RT_ID;

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

		List<Contact> contacts = TestDataFactory.createContact(4);
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
		wishChild.RecordTypeId = Constant_AC.WISH_FORM_CHILD_ID;
		wishChild.Preferred_Name__c = wishChild.Preferred_Name__c;

		wishChild.RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
		Contact family1 = contacts.get(1);
		family1.FirstName = 'Bob';
		family1.LastName = 'Smith';
		family1.RecordTypeId = WISH_FAMILY_RT;
		family1.Email = 'bobsmith@email.com';
		family1.Phone = '9600467559';
		family1.MailingStreet = '123 Street';
		family1.MailingCity = 'Phoenix';
		family1.MailingStateCode = 'AZ';
		family1.MailingPostalCode = '84001';
		family1.MailingCountryCode = 'US';
		family1.IsParentGuardian__c = 'Yes';
		family1.Birthdate = System.today() + 11234;
		Contact family2 = contacts.get(2);
		family2.FirstName = 'Mary';
		family2.LastName = 'Smith';
		family2.RecordTypeId = WISH_FAMILY_RT;
		family2.Email = 'marysmith@email.com';
		family2.Phone = '9600467559';
		family2.MailingStreet = '123 Street';
		family2.MailingCity = 'Phoenix';
		family2.MailingStateCode = 'AZ';
		family2.MailingPostalCode = '84001';
		family2.MailingCountryCode = 'US';
		family2.IsParentGuardian__c = 'Yes';
		Contact participant = contacts.get(3);
		participant.FirstName = 'John';
		participant.LastName = 'Smith';
		participant.Email = 'jd@email.com';
		participant.Phone = '9600467559';
		participant.MailingStreet = '456 Street';
		participant.MailingCity = 'Phoenix';
		participant.MailingStateCode = 'AZ';
		participant.MailingPostalCode = '84001';
		participant.MailingCountryCode = 'US';
		participant.IsParentGuardian__c = 'No';
		insert contacts;

		List<npe4__Relationship__c> relationships = TestDataFactory.createRelationship(3);
		npe4__Relationship__c fatherRelationship = relationships.get(0);
		fatherRelationship.npe4__Contact__c = wishChild.Id;
		fatherRelationship.npe4__RelatedContact__c = family1.Id;
		fatherRelationship.npe4__Status__c = 'Active';
		fatherRelationship.npe4__Type__c = 'Father';
		fatherRelationship.Parent_Legal_Guardian__c = false;
		fatherRelationship.Wish_Participant__c = true;
		npe4__Relationship__c motherRelationship = relationships.get(1);
		motherRelationship.npe4__Contact__c = wishChild.Id;
		motherRelationship.npe4__RelatedContact__c = family2.Id;
		motherRelationship.npe4__Status__c = 'Active';
		motherRelationship.npe4__Type__c = 'Mother';
		motherRelationship.Parent_Legal_Guardian__c = false;
		motherRelationship.Wish_Participant__c = true;
		npe4__Relationship__c participantRelationship = relationships.get(2);
		participantRelationship.npe4__Contact__c = wishChild.Id;
		participantRelationship.npe4__RelatedContact__c = participant.Id;
		participantRelationship.npe4__Status__c = 'Active';
		participantRelationship.npe4__Type__c = 'Friend';
		participantRelationship.Parent_Legal_Guardian__c = false;
		participantRelationship.Wish_Participant__c = true;
		insert relationships;

		List<Case> cases = TestDataFactory.createCase(1);
		Case wish = cases.get(0);
		wish.Lead__c = lead.Id;
		wish.RecordTypeId = Constant_AC.WISH_RT_ID;
		wish.ChapterName__c = accounts.get(0).Id;
		wish.Subject = 'Wish1';
		wish.Interview_date__c = System.today();
		wish.Wish_Type__c = 'Hawaii';
		wish.Start_Date__c = System.today();
		wish.End_Date__c = System.today();
		wish.ContactId = wishChild.Id;
		wish.Status = 'New';
		wish.Rush__c = false;
		wish.Start_Date__c = System.today();
		wish.Budget_Submitted_Date__c = System.today();
		wish.Budget_Approved_Date__c = System.today();
		wish.Update_Wish_Child_Form_Info__c = true;
		insert cases;

		List<Wish_Child_Form__c> wishChildForms = TestDataFactory.createWishForm(1);
		Wish_Child_Form__c wishChildForm1 = wishChildForms.get(0);
		wishChildForm1.FirstName__c = family1.FirstName;
		wishChildForm1.LastName__c = family1.LastName;
		wishChildForm1.Middle_Name__c = family1.Middle_Name__c;
		wishChildForm1.BirthDate__c = family1.Birthdate;
		wishChildForm1.Diagnosis__c = family1.Diagnosis__c;
		wishChildForm1.Gender__c = family1.Gender__c;
		wishChildForm1.Self_describe_comment_box__c = family1.Self_describe_comment_box__c;
		wishChildForm1.mobilePhone__c = family1.MobilePhone;
		wishChildForm1.Case__c = wish.Id;
		wishChildForm1.Email__c = family1.Email;
		wishChildForm1.T_Shirt_Size__c = family1.T_Shirt_Size__c;
		wishChildForm1.Street__c = family1.MailingStreet;
		wishChildForm1.State__c = family1.MailingState;
		wishChildForm1.City__c = family1.MailingCity;
		wishChildForm1.Zip_Code__c = family1.MailingPostalCode;
		wishChildForm1.Contact__c = family1.Id;
		wishChildForm1.RecordTypeId = Constant_AC.WISH_FORM_FAMILY_ID;
		wishChildForm1.Preferred_Name__c = family1.Preferred_Name__c;
		insert wishChildForms;
	}

	@IsTest
	public static void createInterviewDate() {
		Test.startTest();
		Database.executeBatch(new BatchRelationshipRecUpdate());
		Test.stopTest();

		List<Wish_Child_Form__c> results = [
				SELECT Id
				FROM Wish_Child_Form__c
				WHERE LastName__c = 'Smith'
				AND RecordTypeId = :Constant_AC.WISH_FORM_FAMILY_ID
		];
		System.assertEquals(4, results.size());
	}
}