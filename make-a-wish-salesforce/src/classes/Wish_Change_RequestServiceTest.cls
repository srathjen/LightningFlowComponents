/**
 * @description Wish Change Request Test Class
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 7/5/2019
 */
@IsTest
public class Wish_Change_RequestServiceTest {

	private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;
	private final static Id WISH_RECORD_TYPE_ID = Constant_AC.WISH_RT_ID;

	@TestSetup
	public static void setUpData() {
		List<ICD_Codes__c> icdCodesDataFactory = TestDataFactory.createIcdCode(1);
		ICD_Codes__c icdCode = icdCodesDataFactory.get(0);
		insert icdCode;
		List<Contact> contactsDataFactory = TestDataFactory.createContact(4);
		List<Contact> contacts = new List<Contact>();
		Contact wishChildContact = contactsDataFactory.get(0);
		wishChildContact.FirstName = 'Mark';
		wishChildContact.LastName = 'Smith';
		wishChildContact.ICD_10_Code__c = icdCode.Id;
		wishChildContact.Birthdate = Date.today().addYears(-10);
		wishChildContact.MailingPostalCode = '12345-9876';
		wishChildContact.MailingStreet = 'Mark Street';
		wishChildContact.MailingCountry = 'United States';
		wishChildContact.MailingState = 'Arizona';
		wishChildContact.MailingCity = 'Phoenix';
		Contact wishFamilyContact = contactsDataFactory.get(1);
		wishFamilyContact.FirstName = 'Jack';
		wishFamilyContact.LastName = 'Smith';
		wishFamilyContact.RecordTypeId = '01236000000xW2qAAE';
		wishFamilyContact.MailingPostalCode = '12345-9876';
		wishFamilyContact.MailingStreet = 'Jack Street';
		wishFamilyContact.MailingCountry = 'United States';
		wishFamilyContact.MailingState = 'Arizona';
		wishFamilyContact.MailingCity = 'Phoenix';
		contacts.add(wishChildContact);
		contacts.add(wishFamilyContact);
		insert contacts;
		List<Account> accountsDataFactory = TestDataFactory.createAccount(1);
		List<Account> accounts = new List<Account>();
		Account account = accountsDataFactory.get(0);
		account.Name = 'Make-A-Wish Arizona';
		account.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
		accounts.add(account);
		insert accounts;
		List<Case> casesDataFactory = TestDataFactory.createCase(1);
		List<Case> cases = new List<Case>();
		Case wishCase = casesDataFactory.get(0);
		wishCase.RecordTypeId = WISH_RECORD_TYPE_ID;
		wishCase.ChapterName__c = accounts.get(0).Id;
		wishCase.Subject = 'Wish';
		wishCase.Interview_date__c = System.today();
		wishCase.Wish_Type__c = 'Disney World';
		wishCase.Start_Date__c = System.today();
		wishCase.End_Date__c = System.today();
		wishCase.ContactId = wishChildContact.Id;
		wishCase.Status = 'New';
		wishCase.Start_Date__c = System.today();
		wishCase.Budget_Submitted_Date__c = System.today();
		wishCase.Budget_Approved_Date__c = System.today();
		wishCase.Update_Wish_Child_Form_Info__c = true;
		cases.add(wishCase);
		insert cases;
		List<npe4__Relationship__c> relationshipsDataFactory = TestDataFactory.createRelationship(1);
		List<npe4__Relationship__c> relationships = new List<npe4__Relationship__c>();
		npe4__Relationship__c relationship = relationshipsDataFactory.get(0);
		relationship.npe4__Type__c = 'Father';
		relationship.Parent_Legal_Guardian__c = false;
		relationship.npe4__Contact__c = wishChildContact.Id;
		relationship.npe4__RelatedContact__c = wishFamilyContact.Id;
		relationships.add(relationship);
		insert relationships;
		List<Wish_Affiliation__c> wishAffiliationsDataFactory = TestDataFactory.createWishAffiliation(1);
		List<Wish_Affiliation__c> wishAffiliations = new List<Wish_Affiliation__c>();
		Wish_Affiliation__c wishAffiliation = wishAffiliationsDataFactory.get(0);
		wishAffiliation.Wish__c = wishCase.Id;
		wishAffiliation.Non_Comped__c = false;
		wishAffiliation.Survey_Recipient__c = false;
		wishAffiliation.Medical_Needs__c = false;
		wishAffiliation.Contact__c = wishFamilyContact.Id;
		wishAffiliation.Relationship__c = relationship.Id;
		wishAffiliation.Residing_with_Wish_child__c = 'No';
		wishAffiliation.Wish_Affiliation_Type__c = 'Requested Participant';
		wishAffiliations.add(wishAffiliation);
		insert wishAffiliations;
		List<Wish_Change_Request__c> wishChangeRequestsDataFactory = TestDataFactory.createWishChangeRequests(15, wishCase.Id, wishAffiliation.Id);
		List<Wish_Change_Request__c> wishChangeRequests = new List<Wish_Change_Request__c>();
		DescribeSObjectResult wishAffiliationDescribeSObjectResult = Schema.getGlobalDescribe().get(Constant_AC.WISH_AFFILIATION_API_NAME).getDescribe();
		Map<String, Schema.SObjectField> wishAffiliationFieldsByName = Schema.getGlobalDescribe().get(Constant_AC.WISH_AFFILIATION_API_NAME).getDescribe().fields.getMap();
		DescribeSObjectResult contactDescribeSObjectResult = Schema.getGlobalDescribe().get(Constant_AC.CONTACT_API_NAME).getDescribe();
		Map<String, Schema.SObjectField> contactFieldsByName = Schema.getGlobalDescribe().get(Constant_AC.CONTACT_API_NAME).getDescribe().fields.getMap();
		Wish_Change_Request__c cr1Proposed = wishChangeRequestsDataFactory.get(0);
		Schema.DescribeFieldResult wishAffiliationType = wishAffiliationFieldsByName.get(Constant_AC.WISH_AFFILIATION_WISH_AFFILIATION_TYPE_API_NAME).getDescribe();
		cr1Proposed.Object_API_Name_for_Proposed_Change__c = wishAffiliationDescribeSObjectResult.name;
		cr1Proposed.Status__c = 'Proposed';
		cr1Proposed.Record_Name__c = wishAffiliationDescribeSObjectResult.label;
		cr1Proposed.Record_Id__c = wishAffiliation.Id;
		cr1Proposed.Field_Previous_Value__c = wishAffiliation.Wish_Affiliation_Type__c;
		cr1Proposed.Field_New_Value__c = 'Approved Participant';
		cr1Proposed.Field_API_Name_for_Proposed_Change__c = wishAffiliationType.getName();
		cr1Proposed.Field_Label_for_Proposed_Change__c = wishAffiliationType.getLabel();
		Wish_Change_Request__c cr2Proposed = wishChangeRequestsDataFactory.get(1);
		Schema.DescribeFieldResult residingWithWishChild = wishAffiliationFieldsByName.get(Constant_AC.WISH_AFFILIATION_RESIDING_WITH_WISH_CHILD_API_NAME).getDescribe();
		cr2Proposed.Object_API_Name_for_Proposed_Change__c = wishAffiliationDescribeSObjectResult.name;
		cr2Proposed.Status__c = 'Proposed';
		cr2Proposed.Record_Name__c = wishAffiliationDescribeSObjectResult.label;
		cr2Proposed.Record_Id__c = wishAffiliation.Id;
		cr2Proposed.Field_Previous_Value__c = wishAffiliation.Residing_with_Wish_child__c;
		cr2Proposed.Field_New_Value__c = 'Yes';
		cr2Proposed.Field_API_Name_for_Proposed_Change__c = residingWithWishChild.getName();
		cr2Proposed.Field_Label_for_Proposed_Change__c = residingWithWishChild.getLabel();
		wishChangeRequests.add(cr1Proposed);
		wishChangeRequests.add(cr2Proposed);
		insert wishChangeRequests;
	}

	static testMethod void shouldProcessApprovedChangeRequests() {
		// ARRANGE
		Wish_Affiliation__c wishAffiliation = [
				SELECT Id
				FROM Wish_Affiliation__c
				WHERE Wish_Affiliation_Type__c = 'Requested Participant'
		];
		List<Wish_Change_Request__c> wishChangeRequests = [
				SELECT Id, Wish_Case_Id__c,Wish_Affiliation__c,Object_API_Name_for_Proposed_Change__c,Record_Name__c,
						Record_Id__c,Field_Previous_Value__c,Field_New_Value__c,Field_API_Name_for_Proposed_Change__c,
						Field_Label_for_Proposed_Change__c, Status__c
				FROM Wish_Change_Request__c
				WHERE Wish_Affiliation__c = :wishAffiliation.Id
		];
		Map<Id, Wish_Change_Request__c> oldWishChangeRequestsMap = new Map<Id, Wish_Change_Request__c>();
		for (Wish_Change_Request__c cr : wishChangeRequests) {
			oldWishChangeRequestsMap.put(cr.Id, cr);
		}
		List<Wish_Change_Request__c> updatedWishChangeRequestsList = new List<Wish_Change_Request__c>();
		Wish_Change_Request__c cr1Approved = new Wish_Change_Request__c();
		cr1Approved.Id = wishChangeRequests.get(0).Id;
		cr1Approved.Status__c = 'Approved';
		cr1Approved.Wish_Affiliation__c = wishChangeRequests.get(0).Wish_Affiliation__c;
		cr1Approved.Object_API_Name_for_Proposed_Change__c = wishChangeRequests.get(0).Object_API_Name_for_Proposed_Change__c;
		cr1Approved.Record_Name__c = wishChangeRequests.get(0).Record_Name__c;
		cr1Approved.Record_Id__c = wishChangeRequests.get(0).Record_Id__c;
		cr1Approved.Field_Previous_Value__c = wishChangeRequests.get(0).Field_Previous_Value__c;
		cr1Approved.Field_New_Value__c = wishChangeRequests.get(0).Field_New_Value__c;
		cr1Approved.Field_API_Name_for_Proposed_Change__c = wishChangeRequests.get(0).Field_API_Name_for_Proposed_Change__c;
		cr1Approved.Field_Label_for_Proposed_Change__c = wishChangeRequests.get(0).Field_Label_for_Proposed_Change__c;
		Wish_Change_Request__c cr2Rejected = new Wish_Change_Request__c();
		cr2Rejected.Id = wishChangeRequests.get(1).Id;
		cr2Rejected.Status__c = 'Rejected';
		cr2Rejected.Wish_Affiliation__c = wishChangeRequests.get(1).Wish_Affiliation__c;
		cr2Rejected.Object_API_Name_for_Proposed_Change__c = wishChangeRequests.get(1).Object_API_Name_for_Proposed_Change__c;
		cr2Rejected.Record_Name__c = wishChangeRequests.get(1).Record_Name__c;
		cr2Rejected.Record_Id__c = wishChangeRequests.get(1).Record_Id__c;
		cr2Rejected.Field_Previous_Value__c = wishChangeRequests.get(1).Field_Previous_Value__c;
		cr2Rejected.Field_New_Value__c = wishChangeRequests.get(1).Field_New_Value__c;
		cr2Rejected.Field_API_Name_for_Proposed_Change__c = wishChangeRequests.get(1).Field_API_Name_for_Proposed_Change__c;
		cr2Rejected.Field_Label_for_Proposed_Change__c = wishChangeRequests.get(1).Field_Label_for_Proposed_Change__c;
		updatedWishChangeRequestsList.add(cr1Approved);
		updatedWishChangeRequestsList.add(cr2Rejected);

		// ACT
		Test.startTest();
		Map<Id, List<Wish_Change_Request__c>> approvedChangeRequests = Wish_Change_RequestService.processApprovedChangeRequests(updatedWishChangeRequestsList, oldWishChangeRequestsMap);
        update updatedWishChangeRequestsList;
		Test.stopTest();

		// ASSERT
		System.assertEquals(1, approvedChangeRequests.keySet().size());
		System.assertEquals(1, approvedChangeRequests.get(wishAffiliation.Id).size());
	}
}