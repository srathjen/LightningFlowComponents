@IsTest
public class ContactTrigger_AT_Test {

	@TestSetup
	static void setup() {
		trac_TriggerHandlerBase.blockTrigger = true;
		
		List<Account> accounts = TestDataFactory.createAccount(2);
		Account account = accounts.get(0);
		account.Name = 'Make-A-Wish Arizona';
		account.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
		account.Alert_for_Unassigned_Wishes__c = 1;
        Account knowlesFamily = accounts.get(1);
        knowlesFamily.Name = 'Jenna Knowles & Family Household';
        knowlesFamily.RecordTypeId = Constant_AC.HOUSEHOLD_RT_ID;
		insert accounts;
        
        List<Contact> contacts = TestDataFactory.createContact(1);
        Contact contactKnowles = contacts.get(0);
        contactKnowles.RecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
        contactKnowles.Region_Chapter__c = account.Id;
        contactKnowles.AccountId = knowlesFamily.Id;
        contactKnowles.FirstName = 'Allison';
        contactKnowles.LastName = 'Knowles';
        insert contacts;

		List<Chapter_Vs_Role__c> chapterVsRoleList = TestDataFactory.createChapterVsRole(1, 'Arizona');
		insert chapterVsRoleList;

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void createVolunteerContact() {
		Account account = [
				SELECT Id
				FROM Account
				LIMIT 1
		];

		List<Contact> contacts = TestDataFactory.createContact(1);
		Contact contact = contacts.get(0);
		contact.FirstName = 'Jack';
		contact.Middle_Name__c = 'Jacksons';
		contact.LastName = 'Smithsons';
		contact.Birthdate = System.today() - 1;
		contact.Parent_Guardian_Name__c = 'Bob Smith';
		contact.RecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
		contact.Title = 'Mr';
		contact.Birth_Month__c = 'January';
		contact.Birth_Day__c = '12';
		contact.Birth_Year__c = '1985';
		contact.Alternate_Phone_Type__c = 'Home';
		contact.npe01__PreferredPhone__c = 'Mobile';
		contact.OtherPhone = '3332211144';
		contact.HomePhone = '9003910426';
		contact.MobilePhone = '9003910426';
		contact.I_m_on_LinkedIn__c = 'Yes';
		contact.How_did_you_hear_about_Make_A_Wish__c = 'Family';
		contact.MailingPostalCode = '94105-5188';
		contact.MailingStreet = 'One Market Street';
		contact.MailingCountry = 'United States';
		contact.MailingState = 'Texas';
		contact.MailingCity = 'San Francisco';
		contact.MailingLatitude = -24.355798;
		contact.MailingLongitude = 69.830469;
		contact.Emergency_Contact__c = 'Test';
		contact.Emergency_Contact_Relationship__c = 'Father';
		contact.Emergency_Contact_Phone__c = '9003910426';
		contact.Read__c = 'English';
		contact.Language__c = 'English';
		contact.Speak__c = 'English';
		contact.Understand__c = 'English';
		contact.Professional_Skills__c = 'Photography';
		contact.Language_Notes__c = 'Test';
		contact.is_Application__c = 'Partial Submit';
		contact.AccountId = account.Id;
		contact.Volunteer_Role__c = 'Water Handler';
		contact.npe01__Preferred_Email__c = 'test@gmail.com';
		contact.Email = 'test@gmail.com';
		contact.Do_Not_Create_User__c = false;
		contact.Migrated_Record__c = true;
		insert contact;

		contact.MailingPostalCode = '12345-5188';
		contact.OtherPostalCode = '85005';
		Date birthdate = Date.today().addYears(-15);
		contact.Birth_Year__c = String.valueOf(birthdate.year());
		contact.Birth_Month__c = 'May';
		contact.Birth_Day__c = String.valueOf(birthdate.day());
		update contact;

		delete contact;
	}

	@IsTest
	public static void createWishChildContact() {
		Account account = [
				SELECT Id
				FROM Account
				LIMIT 1
		];

		List<Contact> contacts = TestDataFactory.createContact(1);
		Contact contact = contacts.get(0);
		contact.Region_Chapter__c = account.Id;
		contact.FirstName = 'Jack';
		contact.LastName = 'Smith';
		contact.Email = 'jacksmith@email.com';
		contact.Phone = '1233213333';
		contact.MailingStreet = '123 Street';
		contact.MailingCity = 'Phoenix';
		contact.MailingState = 'Arizona';
		contact.MailingStateCode = 'AZ';
		contact.MailingPostalCode = '85001';
		contact.MailingCountryCode = 'US';
		contact.RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
		contact.Primary_Diagnosis_Condition_Description__c = 'Test';
		contact.Diagnosis__c = 'test';
		insert contacts;
	}
    
    @IsTest
    public static void updateContactSpanishValues() {
        Contact contactToUpdate = [
            SELECT Id, Relationship__c, npe01__PreferredPhone__c
            FROM Contact 
            WHERE Name = 'Allison Knowles'
        ];
        contactToUpdate.Relationship__c = 'Madre';
        contactToUpdate.npe01__PreferredPhone__c = 'Móvil';
        
        Test.startTest();
        update contactToUpdate;
        Test.stopTest();
        
        Contact updatedContact = [
            SELECT Id, Relationship__c, npe01__PreferredPhone__c 
            FROM Contact 
            WHERE Id = :contactToUpdate.Id
        ];
        System.assert(updatedContact.Relationship__c == 'Mother');
        System.assert(updatedContact.npe01__PreferredPhone__c == 'Mobile');
    }
}