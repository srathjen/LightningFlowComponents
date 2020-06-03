/**
 * @description Wish Affiliation Test Class
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 7/5/2019
 */
@IsTest
public class WishAffiliation_AC_Test {

	private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;
	private final static Id WISH_RECORD_TYPE_ID = Constant_AC.WISH_RT_ID;

	@TestSetup
	public static void setUpData() {
		Wish_Affiliation_Category__mdt wishAffiliationCategory = [
				SELECT Type__c, Is_Default_for_Category__c
				FROM Wish_Affiliation_Category__mdt
				LIMIT 1
		];
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
		Contact wishFamilyContactFather = contactsDataFactory.get(1);
		wishFamilyContactFather.FirstName = 'Jack';
		wishFamilyContactFather.LastName = 'Smith';
		wishFamilyContactFather.RecordTypeId = '01236000000xW2qAAE';
		wishFamilyContactFather.MailingPostalCode = '12345-9876';
		wishFamilyContactFather.MailingStreet = 'Jack Street';
		wishFamilyContactFather.MailingCountry = 'United States';
		wishFamilyContactFather.MailingState = 'Arizona';
		wishFamilyContactFather.MailingCity = 'Phoenix';
		Contact wishFamilyContactBrother = contactsDataFactory.get(2);
		wishFamilyContactBrother.FirstName = 'Danny';
		wishFamilyContactBrother.LastName = 'Smith';
		wishFamilyContactBrother.RecordTypeId = '01236000000xW2qAAE';
		wishFamilyContactBrother.MailingPostalCode = '12345-9876';
		wishFamilyContactBrother.MailingStreet = 'Danny Street';
		wishFamilyContactBrother.MailingCountry = 'United States';
		wishFamilyContactBrother.MailingState = 'Arizona';
		wishFamilyContactBrother.MailingCity = 'Phoenix';
		Contact wishFamilyContactMother = contactsDataFactory.get(3);
		wishFamilyContactMother.FirstName = 'Lucy';
		wishFamilyContactMother.LastName = 'Smith';
		wishFamilyContactMother.RecordTypeId = '01236000000xW2qAAE';
		wishFamilyContactMother.MailingPostalCode = '12345-9876';
		wishFamilyContactMother.MailingStreet = '987 Street';
		wishFamilyContactMother.MailingCountry = 'United States';
		wishFamilyContactMother.MailingState = 'Arizona';
		wishFamilyContactMother.MailingCity = 'Phoenix';
		contacts.add(wishChildContact);
		contacts.add(wishFamilyContactFather);
		contacts.add(wishFamilyContactBrother);
		contacts.add(wishFamilyContactMother);
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
		relationship.npe4__RelatedContact__c = wishFamilyContactFather.Id;
		relationships.add(relationship);
		insert relationships;
		List<Wish_Affiliation__c> wishAffiliationsDataFactory = TestDataFactory.createWishAffiliation(1);
		List<Wish_Affiliation__c> wishAffiliations = new List<Wish_Affiliation__c>();
		Wish_Affiliation__c wishAffiliation = wishAffiliationsDataFactory.get(0);
		wishAffiliation.Wish__c = wishCase.Id;
		wishAffiliation.Non_Comped__c = false;
		wishAffiliation.Survey_Recipient__c = false;
		wishAffiliation.Medical_Needs__c = false;
		wishAffiliation.Contact__c = wishFamilyContactFather.Id;
		wishAffiliation.Relationship__c = relationship.Id;
		wishAffiliation.Residing_with_Wish_child__c = 'No';
		wishAffiliation.Wish_Affiliation_Type__c = wishAffiliationCategory.Type__c;
		wishAffiliations.add(wishAffiliation);
		insert wishAffiliations;
	}

	@IsTest
	public static void shouldGetParticipants() {
		// ARRANGE
		Wish_Affiliation__c wishAffiliation = [
				SELECT Wish_Affiliation_Type__c
				FROM Wish_Affiliation__c
				WHERE Contact__r.Name = 'Jack Smith'
		];
		Wish_Affiliation_Category__mdt wishAffiliationCategory = [
				SELECT Category__c
				FROM Wish_Affiliation_Category__mdt
				WHERE Type__c = :wishAffiliation.Wish_Affiliation_Type__c
		];
		Case wishCase = [
				SELECT Id
				FROM Case
				WHERE Wish_Type__c = 'Disney World'
		];

		// ACT
		Test.startTest();
		Map<Object, Object> resultMap = WishAffiliation_AC.findWishAffiliations(wishCase.Id, wishAffiliationCategory.Category__c);
		Test.stopTest();

		// ASSERT
		List<Wish_Affiliation__c> wishAffiliations = (List<Wish_Affiliation__c>) resultMap.get('wishAffiliations');
		System.assertEquals('Jack Smith', wishAffiliations[0].Contact__r.Name);
	}

	@IsTest
	public static void shouldSaveWishAffiliation() {
		// ARRANGE
		Case wishCase = [
				SELECT Id
				FROM Case
				WHERE Wish_Type__c = 'Disney World'
		];
		Wish_Affiliation__c wishAffiliation = [
				SELECT Id, Name, Wish_Affiliation_Type__c, Wish__c, Residing_with_Wish_child__c, Medical_Needs__c,
						Survey_Recipient__c, Non_Comped__c, Details__c, Send_Clearance_Forms_To__c, Medical_Professional_Status__c,
						Contact__r.Name, Contact__r.FirstName, Contact__r.LastName, Contact__r.Birthdate, Contact__r.Current_Age__c,
						Contact__r.MailingStreet, Contact__r.MailingCity, Contact__r.MailingState, Contact__r.MailingPostalCode,
						Contact__r.MailingCountry, Contact__r.npe01__PreferredPhone__c, Contact__r.Phone, Contact__r.HomePhone,
						Contact__r.MobilePhone, Contact__r.OtherPhone, Contact__r.npe01__WorkPhone__c, Contact__r.npe01__HomeEmail__c,
						Contact__r.npe01__WorkEmail__c, Contact__r.npsp__Do_Not_Contact__c, Contact__r.Do_Not_Contact_Notes__c,
						Contact__r.npsp__Deceased__c, Contact__r.Provider_Type__c, Contact__r.Fax, Contact__r.npsp__is_Address_Override__c,
						Relationship__r.npe4__Type__c, Relationship__r.Parent_Legal_Guardian__c,
						Relationship__r.npe4__Contact__c, Relationship__r.npe4__Contact__r.Name,
						Relationship__r.Qualifying_Medical_Professional__c, Relationship__r.Treating_HCP__c,
						Relationship__r.Best_Contact__c, Health_Treatment_Facility__c, Health_Treatment_Facility__r.Name
				FROM Wish_Affiliation__c
				WHERE Wish__c = :wishCase.Id
		];
		String payload = '{ ' +
				'"Id":"' + wishAffiliation.Id + '","Name":"' + wishAffiliation.Name + '",' +
				'"Wish__c":"' + wishCase.Id + '","Wish_Affiliation_Type__c":"Approved Participant","Residing_with_Wish_child__c":"No",' +
				'"Medical_Needs__c":true,"Survey_Recipient__c":true,"Non_Comped__c":true,"Details__c":"The father of the wish child","Contact__c":"'
				+ wishAffiliation.Contact__c + '","Relationship__c":"' + wishAffiliation.Relationship__c + '",' +
				'"Contact__r":{"Id":"' + wishAffiliation.Contact__c + '","Name":"Jack Smith","FirstName":"Jack","LastName":"Smith",' +
				'"Birthdate":"1950-01-01","npe01__PreferredPhone__c":"Home","Phone":"5553334444","npe01__HomeEmail__c":"js@email.com",' +
				'"npsp__Do_Not_Contact__c":true,"Do_Not_Contact_Notes__c":"Do no Contact Father","npsp__Deceased__c":false,' +
				'"MailingStreet":"1234 E Gold Dust Ave","MailingCity":"Phoenix","MailingPostalCode":"88333-2222","MailingState":"Arizona","MailingCountry":"United States"},' +
				'"Relationship__r":{"Id":"' + wishAffiliation.Relationship__c + '","npe4__Type__c":"Stepfather","Parent_Legal_Guardian__c":true,' +
				'"npe4__Contact__c":"' + wishAffiliation.Relationship__r.npe4__Contact__c + '",' +
				'"npe4__Contact__r":{"Name":"Jack Smith","Id":"' + wishAffiliation.Relationship__r.npe4__Contact__c + '"}}}';

		// ACT
		Test.startTest();
		Map<Object, Object> resultMap = WishAffiliation_AC.saveWishAffiliation(payload, true, false, false);
		Test.stopTest();

		// ASSERT
		Wish_Affiliation__c newWishAffiliation = (Wish_Affiliation__c) resultMap.get('wishAffiliation');
		System.assertEquals(wishCase.Id, newWishAffiliation.Wish__c);
		System.assertEquals('Approved Participant', newWishAffiliation.Wish_Affiliation_Type__c);
		System.assertEquals('No', newWishAffiliation.Residing_with_Wish_child__c);
		System.assertEquals(true, newWishAffiliation.Medical_Needs__c);
		System.assertEquals(true, newWishAffiliation.Survey_Recipient__c);
		System.assertEquals(true, newWishAffiliation.Non_Comped__c);
		System.assertEquals('The father of the wish child', newWishAffiliation.Details__c);
		System.assertEquals('Jack', newWishAffiliation.Contact__r.FirstName);
		System.assertEquals('Smith', newWishAffiliation.Contact__r.LastName);
		System.assertEquals('1234 E Gold Dust Ave', newWishAffiliation.Contact__r.MailingStreet);
		System.assertEquals('Phoenix', newWishAffiliation.Contact__r.MailingCity);
		System.assertEquals('Arizona', newWishAffiliation.Contact__r.MailingState);
		System.assertEquals('88333-2222', newWishAffiliation.Contact__r.MailingPostalCode);
		System.assertEquals('United States', newWishAffiliation.Contact__r.MailingCountry);
		System.assertEquals('Home', newWishAffiliation.Contact__r.npe01__PreferredPhone__c);
		System.assertEquals('5553334444', newWishAffiliation.Contact__r.Phone);
		System.assertEquals('5553334444', newWishAffiliation.Contact__r.HomePhone);
		System.assertEquals(null, newWishAffiliation.Contact__r.MobilePhone);
		System.assertEquals(null, newWishAffiliation.Contact__r.OtherPhone);
		System.assertEquals(null, newWishAffiliation.Contact__r.npe01__WorkPhone__c);
		System.assertEquals('js@email.com', newWishAffiliation.Contact__r.npe01__HomeEmail__c);
		System.assertEquals(true, newWishAffiliation.Contact__r.npsp__Do_Not_Contact__c);
		System.assertEquals('Do no Contact Father', newWishAffiliation.Contact__r.Do_Not_Contact_Notes__c);
		System.assertEquals(false, newWishAffiliation.Contact__r.npsp__Deceased__c);
		System.assertEquals('Stepfather', newWishAffiliation.Relationship__r.npe4__Type__c);
		System.assertEquals(wishAffiliation.Relationship__r.npe4__Contact__c, newWishAffiliation.Relationship__r.npe4__Contact__c);
	}

	@IsTest
	public static void shouldSaveChangeRequestsForWishAffiliation_WhenUserIsNotAllowedToEditWishAffiliation() {
		// ARRANGE
		Case wishCase = [
				SELECT Id
				FROM Case
				WHERE Wish_Type__c = 'Disney World'
		];
		Contact wishFamilyContactMother = [
				SELECT Id
				FROM Contact
				WHERE Name = 'Lucy Smith'
		];
		Wish_Affiliation__c wishAffiliation = [
				SELECT Id, Name, Contact__c, Relationship__c
				FROM Wish_Affiliation__c
				WHERE Wish__c = :wishCase.Id
		];
		String payload = '{ ' +
				'"Id":"' + wishAffiliation.Id + '","Name":"' + wishAffiliation.Name + '",' +
				'"Wish__c":"' + wishCase.Id + '","Wish_Affiliation_Type__c":"Requested Participant","Residing_with_Wish_child__c":"Yes",' +
				'"Medical_Needs__c":true,"Survey_Recipient__c":true,"Non_Comped__c":true,"Details__c":"The father of the wish child","Contact__c":"'
				+ wishAffiliation.Contact__c + '","Relationship__c":"' + wishAffiliation.Relationship__c + '",' +
				'"Contact__r":{"Id":"' + wishAffiliation.Contact__c + '","Name":"Jack Smith","FirstName":"Jacky","LastName":"Smithz",' +
				'"Birthdate":"1950-12-12","npe01__PreferredPhone__c":"Work","Phone":"5553331111","npe01__HomeEmail__c":"jacky@email.com",' +
				'"npsp__Do_Not_Contact__c":true,"Do_Not_Contact_Notes__c":"Do no Contact Father","npsp__Deceased__c":true,' +
				'"MailingStreet":"9999 Street","MailingCity":"New York","MailingPostalCode":"113377-2222","MailingState":"New York","MailingCountry":"United States"},' +
				'"Relationship__r":{"Id":"' + wishAffiliation.Relationship__c + '","npe4__Type__c":"Husband","Parent_Legal_Guardian__c":true,' +
				'"npe4__Contact__c":"' + wishFamilyContactMother.Id + '"}}';

		// ACT
		Test.startTest();
		WishAffiliation_AC.saveWishAffiliation(payload, false, false, false);
		List<Wish_Change_Request__c> changeRequests = [
				SELECT Wish_Case_Id__c,Wish_Affiliation__c,Object_API_Name_for_Proposed_Change__c,
						Record_Name__c,Record_Id__c,Field_Previous_Value__c,Field_New_Value__c,
						Field_API_Name_for_Proposed_Change__c,Field_Label_for_Proposed_Change__c
				FROM Wish_Change_Request__c
				WHERE Wish_Affiliation__c = :wishAffiliation.Id
		];
		Test.stopTest();

		// ASSERT
		System.assert(!changeRequests.isEmpty());
	}

	@IsTest
	public static void shouldCreateNewWishAffiliationWithNewContactOverridingAddressOfRelatedContact() {
		// ARRANGE
		Case wishCase = [
				SELECT Id
				FROM Case
				WHERE Wish_Type__c = 'Disney World'
		];
		Contact wishChildContact = [
				SELECT Id
				FROM Contact
				WHERE Name = 'Mark Smith'
		];
		String payload = '{ ' +
				'"Wish__c":"' + wishCase.Id + '", "Wish_Affiliation_Type__c":"Approved Participant","Residing_with_Wish_child__c":"",' +
				'"Medical_Needs__c":true,"Survey_Recipient__c":true,"Non_Comped__c":true,"Details__c":"The father",' +
				'"Contact__r":{"FirstName":"John","LastName":"Doe","Birthdate":"","MailingStreet":"ABCDEF Street","MailingCity":"Phoenix","MailingState":"Arizona",' +
				'"MailingPostalCode":"ABCDEF","MailingCountry":"United States","npe01__PreferredPhone__c":"Home", "Phone":"5554443333","npe01__HomeEmail__c":"jd@email.com",' +
				'"npsp__Do_Not_Contact__c":true,"Do_Not_Contact_Notes__c":"Do not contact John","npsp__Deceased__c":false,"npsp__is_Address_Override__c":true},' +
				'"Relationship__r":{"npe4__Type__c":"Father","Parent_Legal_Guardian__c":true,' +
				'"npe4__Contact__c":"' + wishChildContact.Id + '"}}';

		// ACT
		Test.startTest();
		Map<Object, Object> resultMap = WishAffiliation_AC.createWishAffiliation(payload, null,
				true, wishChildContact.Id, '');
		Test.stopTest();

		// ASSERT
		Wish_Affiliation__c newWishAffiliation = (Wish_Affiliation__c) resultMap.get('newWishAffiliation');

		System.assertEquals(wishCase.Id, newWishAffiliation.Wish__c);
		System.assertEquals('Approved Participant', newWishAffiliation.Wish_Affiliation_Type__c);
		System.assertEquals('Yes', newWishAffiliation.Residing_with_Wish_child__c);
		System.assertEquals(true, newWishAffiliation.Medical_Needs__c);
		System.assertEquals(true, newWishAffiliation.Survey_Recipient__c);
		System.assertEquals(true, newWishAffiliation.Non_Comped__c);
		System.assertEquals('The father', newWishAffiliation.Details__c);
		System.assertEquals('John', newWishAffiliation.Contact__r.FirstName);
		System.assertEquals('Doe', newWishAffiliation.Contact__r.LastName);
		System.assertEquals(null, newWishAffiliation.Contact__r.Birthdate);
		System.assertEquals('ABCDEF Street', newWishAffiliation.Contact__r.MailingStreet);
		System.assertEquals('Phoenix', newWishAffiliation.Contact__r.MailingCity);
		System.assertEquals('Arizona', newWishAffiliation.Contact__r.MailingState);
		System.assertEquals('ABCDEF', newWishAffiliation.Contact__r.MailingPostalCode);
		System.assertEquals('United States', newWishAffiliation.Contact__r.MailingCountry);
		System.assertEquals('Home', newWishAffiliation.Contact__r.npe01__PreferredPhone__c);
		System.assertEquals('5554443333', newWishAffiliation.Contact__r.Phone);
		System.assertEquals('5554443333', newWishAffiliation.Contact__r.HomePhone);
		System.assertEquals(null, newWishAffiliation.Contact__r.MobilePhone);
		System.assertEquals(null, newWishAffiliation.Contact__r.OtherPhone);
		System.assertEquals(null, newWishAffiliation.Contact__r.npe01__WorkPhone__c);
		System.assertEquals('jd@email.com', newWishAffiliation.Contact__r.npe01__HomeEmail__c);
		System.assertEquals(true, newWishAffiliation.Contact__r.npsp__Do_Not_Contact__c);
		System.assertEquals('Do not contact John', newWishAffiliation.Contact__r.Do_Not_Contact_Notes__c);
		System.assertEquals(false, newWishAffiliation.Contact__r.npsp__Deceased__c);
		System.assertEquals('Father', newWishAffiliation.Relationship__r.npe4__Type__c);
		System.assertEquals(wishChildContact.Id, newWishAffiliation.Relationship__r.npe4__Contact__c);
	}

	@IsTest
	public static void shouldCreateNewWishAffiliationWithNewContactUsingAddressOfRelatedContact() {
		// ARRANGE
		Case wishCase = [
				SELECT Id
				FROM Case
				WHERE Wish_Type__c = 'Disney World'
		];
		Contact wishChildContact = [
				SELECT Id
				FROM Contact
				WHERE Name = 'Mark Smith'
		];
		String payload = '{ ' +
				'"Wish__c":"' + wishCase.Id + '", "Wish_Affiliation_Type__c":"Approved Participant","Residing_with_Wish_child__c":"",' +
				'"Medical_Needs__c":true,"Survey_Recipient__c":true,"Non_Comped__c":true,"Details__c":"The father",' +
				'"Contact__r":{"FirstName":"John","LastName":"Doe","Birthdate":"","MailingStreet":"ABCDEF Street","MailingCity":"Phoenix","MailingState":"Arizona",' +
				'"MailingPostalCode":"ABCDEF","MailingCountry":"United States","npe01__PreferredPhone__c":"Home", "Phone":"5554443333","npe01__HomeEmail__c":"jd@email.com",' +
				'"npsp__Do_Not_Contact__c":true,"Do_Not_Contact_Notes__c":"Do not contact John","npsp__Deceased__c":false,"npsp__is_Address_Override__c":false},' +
				'"Relationship__r":{"npe4__Type__c":"Father","Parent_Legal_Guardian__c":true,' +
				'"npe4__Contact__c":"' + wishChildContact.Id + '"}}';

		// ACT
		Test.startTest();
		Map<Object, Object> resultMap = WishAffiliation_AC.createWishAffiliation(payload, null,
				true, wishChildContact.Id, '');
		Test.stopTest();

		// ASSERT
		Wish_Affiliation__c newWishAffiliation = (Wish_Affiliation__c) resultMap.get('newWishAffiliation');

		System.assertEquals(wishCase.Id, newWishAffiliation.Wish__c);
		System.assertEquals('Approved Participant', newWishAffiliation.Wish_Affiliation_Type__c);
		System.assertEquals('Yes', newWishAffiliation.Residing_with_Wish_child__c);
		System.assertEquals(true, newWishAffiliation.Medical_Needs__c);
		System.assertEquals(true, newWishAffiliation.Survey_Recipient__c);
		System.assertEquals(true, newWishAffiliation.Non_Comped__c);
		System.assertEquals('The father', newWishAffiliation.Details__c);
		System.assertEquals('John', newWishAffiliation.Contact__r.FirstName);
		System.assertEquals('Doe', newWishAffiliation.Contact__r.LastName);
		System.assertEquals(null, newWishAffiliation.Contact__r.Birthdate);
		System.assertEquals('Mark Street', newWishAffiliation.Contact__r.MailingStreet);
		System.assertEquals('Phoenix', newWishAffiliation.Contact__r.MailingCity);
		System.assertEquals('Arizona', newWishAffiliation.Contact__r.MailingState);
		System.assertEquals('12345-9876', newWishAffiliation.Contact__r.MailingPostalCode);
		System.assertEquals('United States', newWishAffiliation.Contact__r.MailingCountry);
		System.assertEquals('Home', newWishAffiliation.Contact__r.npe01__PreferredPhone__c);
		System.assertEquals('5554443333', newWishAffiliation.Contact__r.Phone);
		System.assertEquals('5554443333', newWishAffiliation.Contact__r.HomePhone);
		System.assertEquals(null, newWishAffiliation.Contact__r.MobilePhone);
		System.assertEquals(null, newWishAffiliation.Contact__r.OtherPhone);
		System.assertEquals(null, newWishAffiliation.Contact__r.npe01__WorkPhone__c);
		System.assertEquals('jd@email.com', newWishAffiliation.Contact__r.npe01__HomeEmail__c);
		System.assertEquals(true, newWishAffiliation.Contact__r.npsp__Do_Not_Contact__c);
		System.assertEquals('Do not contact John', newWishAffiliation.Contact__r.Do_Not_Contact_Notes__c);
		System.assertEquals(false, newWishAffiliation.Contact__r.npsp__Deceased__c);
		System.assertEquals('Father', newWishAffiliation.Relationship__r.npe4__Type__c);
		System.assertEquals(wishChildContact.Id, newWishAffiliation.Relationship__r.npe4__Contact__c);
	}

	@IsTest
	public static void shouldCreateNewWishAffiliationWithExistingContact() {
		// ARRANGE
		Case wishCase = [
				SELECT Id
				FROM Case
				WHERE Wish_Type__c = 'Disney World'
		];
		Contact wishChildContact = [
				SELECT Id
				FROM Contact
				WHERE Name = 'Mark Smith'
		];
		Contact wishFamilyContactBrother = [
				SELECT Id
				FROM Contact
				WHERE Name = 'Danny Smith'
		];
		String payload = '{ ' +
				'"Wish__c":"' + wishCase.Id + '", "Wish_Affiliation_Type__c":"Approved Participant","Residing_with_Wish_child__c":"",' +
				'"Medical_Needs__c":false,"Survey_Recipient__c":false,"Non_Comped__c":false,"Details__c":"Residing with Child",' +
				'"Relationship__r":{"npe4__Type__c":"Brother","Parent_Legal_Guardian__c":false,' +
				'"npe4__Contact__c":"' + wishChildContact.Id + '"}}';

		// ACT
		Test.startTest();
		Map<Object, Object> resultMap = WishAffiliation_AC.createWishAffiliation(payload, wishFamilyContactBrother.Id,
				true, wishChildContact.Id, '');
		Test.stopTest();

		// ASSERT
		Wish_Affiliation__c newWishAffiliation = (Wish_Affiliation__c) resultMap.get('newWishAffiliation');
		System.assertEquals(false, newWishAffiliation.Medical_Needs__c);
		System.assertEquals('Danny', newWishAffiliation.Contact__r.FirstName);
		System.assertEquals('Smith', newWishAffiliation.Contact__r.LastName);
		System.assertEquals(false, newWishAffiliation.Relationship__r.Parent_Legal_Guardian__c);
	}

	@IsTest
	public static void shouldNotCreateNewWishAffiliationWithExistingContact_WhenExistingContactIsAlreadyWishAffiliation() {
		// ARRANGE
		Case wishCase = [
				SELECT Id
				FROM Case
				WHERE Wish_Type__c = 'Disney World'
		];
		Contact wishChildContact = [
				SELECT Id
				FROM Contact
				WHERE Name = 'Mark Smith'
		];
		Contact wishFamilyContact = [
				SELECT Id
				FROM Contact
				WHERE Name = 'Jack Smith'
		];
		Wish_Affiliation__c existingWishAffiliation = [
				SELECT Name
				FROM Wish_Affiliation__c
				WHERE Wish__c = :wishCase.Id
		];
		String payload = '{ ' +
				'"Wish__c":"' + wishCase.Id + '", "Wish_Affiliation_Type__c":"Approved Participant","Residing_with_Wish_child__c":"",' +
				'"Medical_Needs__c":true,"Survey_Recipient__c":true,"Non_Comped__c":true,"Details__c":"Residing with Child",' +
				'"Relationship__r":{"npe4__Type__c":"Father","Parent_Legal_Guardian__c":true,' +
				'"npe4__Contact__c":"' + wishChildContact.Id + '"}}';

		// ACT
		Test.startTest();
		Map<Object, Object> resultMap;
		resultMap = WishAffiliation_AC.createWishAffiliation(payload, wishFamilyContact.Id,
				true, wishChildContact.Id, '');
		Test.stopTest();

		// ASSERT
		Wish_Affiliation__c newWishAffiliation = (Wish_Affiliation__c) resultMap.get('newWishAffiliation');
		List<String> validationErrors = (List<String>) resultMap.get('validationErrors');
		System.assertEquals(null, newWishAffiliation);
		System.assertEquals('This contact is already on Wish Affiliation ( ' + existingWishAffiliation.Name + ' )', validationErrors.get(0));
	}

	@IsTest
	public static void shouldCreateNewWishAffiliationWithExistingContact_WhenHouseholdAddressSet() {
		// ARRANGE
		Case wishCase = [
				SELECT Id
				FROM Case
				WHERE Wish_Type__c = 'Disney World'
		];
		Contact wishChildContact = [
				SELECT Id
				FROM Contact
				WHERE Name = 'Mark Smith'
		];
		Contact wishFamilyContactBrother = [
				SELECT Id
				FROM Contact
				WHERE Name = 'Danny Smith'
		];
		String payload = '{ ' +
				'"Wish__c":"' + wishCase.Id + '", "Wish_Affiliation_Type__c":"Approved Participant","Residing_with_Wish_child__c":"",' +
				'"Medical_Needs__c":false,"Survey_Recipient__c":false,"Non_Comped__c":false,"Details__c":"Residing with Child",' +
				'"Relationship__r":{"npe4__Type__c":"Brother","Parent_Legal_Guardian__c":false,' +
				'"npe4__Contact__c":"' + wishChildContact.Id + '"}}';
		String householdAddress = '{' +
				'"city":"Phoenix",' +
				'"country":"United States",' +
				'"countryCode":"US",' +
				'"geocodeAccuracy":"",' +
				'"postalCode":"840001",' +
				'"state":"Arizona",' +
				'"stateCode":"AZ",' +
				'"street":"123 Street"' +
				'}';

		// ACT
		Test.startTest();
		Map<Object, Object> resultMap = WishAffiliation_AC.createWishAffiliation(payload, wishFamilyContactBrother.Id,
				true, wishChildContact.Id, householdAddress);
		Test.stopTest();

		// ASSERT
		Wish_Affiliation__c newWishAffiliation = (Wish_Affiliation__c) resultMap.get('newWishAffiliation');
		System.assertEquals(false, newWishAffiliation.Medical_Needs__c);
		System.assertEquals('Danny', newWishAffiliation.Contact__r.FirstName);
		System.assertEquals('Smith', newWishAffiliation.Contact__r.LastName);
		System.assertEquals(false, newWishAffiliation.Relationship__r.Parent_Legal_Guardian__c);
	}
}