/**
 * @description Test
 * @author MST
 * @createdDate
 */
@IsTest
public class OTUB_UpdateVolUserStatusOnBGCOI_AC_Test {

	private final static Id VOLUNTEER_RECORD_TYPE_ID = Constant_AC.VOLUNTEER_RT_ID;

	@TestSetup
	public static void setup(){
		trac_TriggerHandlerBase.blockTrigger = true;
		List<Account> accounts = TestDataFactory.createAccount(2);
		Account arizonaChapter = accounts.get(0);
		arizonaChapter.Name = 'Make-A-Wish Arizona';
		arizonaChapter.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
		arizonaChapter.Phone = '555555555';
		arizonaChapter.Email__c = 'maw@email.com';
		insert accounts;

		List<Contact> contacts = TestDataFactory.createContact(1);
		Contact volunteerArizona = contacts.get(0);
		volunteerArizona.RecordTypeId = VOLUNTEER_RECORD_TYPE_ID;
		volunteerArizona.is_Application__c = 'Approved';
		volunteerArizona.AccountId = arizonaChapter.Id;
		volunteerArizona.FirstName = 'Mark';
		volunteerArizona.LastName = 'Smith';
		volunteerArizona.Birthdate = Date.today().addYears(-10);
		volunteerArizona.MailingPostalCode = '12345-9876';
		volunteerArizona.MailingStreet = 'Mark Street';
		volunteerArizona.MailingCountry = 'United States';
		volunteerArizona.MailingState = 'Arizona';
		volunteerArizona.MailingCity = 'Phoenix';
		volunteerArizona.Email = 'ms@email.com';
		insert contacts;

		List<npe5__Affiliation__c> affiliations = TestDataFactory.createAffiliation(1);
		npe5__Affiliation__c affiliation = affiliations.get(0);
		affiliation.npe5__Contact__c = volunteerArizona.Id;
		affiliation.npe5__Organization__c = arizonaChapter.Id;
		affiliation.npe5__Primary__c = true;
		affiliation.npe5__Status__c = 'Pending';
		affiliation.Constituent_Code__c = Constant_AC.BOARD_MEMBER_RT_LABEL;
		insert affiliations;

		List<Conflict_Of_Interest__c> conflictOfInterests = TestDataFactory.createConflictOfInterest(2);
		Conflict_Of_Interest__c coi1 = conflictOfInterests.get(0);
		coi1.Volunteer_Contact__c = volunteerArizona.Id;
		coi1.Expiration_Date__c = Date.today().addDays(-5);
		coi1.Volunteer_is_Inactive__c = true;
		coi1.Current__c = true;
		Conflict_Of_Interest__c coi2 = conflictOfInterests.get(1);
		coi2.Volunteer_Contact__c = volunteerArizona.Id;
		coi2.Expiration_Date__c = Date.today().addDays(-5);
		coi2.Volunteer_is_Inactive__c = false;
		coi2.Current__c = true;
		insert conflictOfInterests;

		List<Background_check__c> backgroundChecks = TestDataFactory.createBackgroundCheck(1);
		Background_check__c backgroundCheck = backgroundChecks.get(0);
		backgroundCheck.Current__c = true;
		backgroundCheck.Volunteer__c = volunteerArizona.Id;
		backgroundCheck.Status__c = 'Approved';
		backgroundCheck.Date__c = Date.today().addDays(-5);
		backgroundCheck.Date_Completed__c = Date.today();
		backgroundCheck.Volunteer_is_Inactive__c = false;
		insert backgroundChecks;

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	static void updateActiveStatus() {
		Contact volunteer = [
				SELECT Id
				FROM Contact
				WHERE Name = 'Mark Smith'
		];
		List<npe5__Affiliation__c> affiliation = [
				SELECT Id
				FROM npe5__Affiliation__c
				WHERE npe5__Contact__c = :volunteer.Id
		];
		affiliation[0].npe5__Status__c = 'Active';
		update affiliation[0];

		Test.startTest();
		OTUB_UpdateVolUserStatusOnBGCOI_AC batchAffiliation = new OTUB_UpdateVolUserStatusOnBGCOI_AC();
		Database.executeBatch(batchAffiliation, 200);
		Test.stopTest();
	}

	@IsTest
	static void updateInactiveStatus() {
		Contact volunteer = [
				SELECT Id
				FROM Contact
				WHERE Name = 'Mark Smith'
		];
		List<npe5__Affiliation__c> affiliation = [
				SELECT Id
				FROM npe5__Affiliation__c
				WHERE npe5__Contact__c = :volunteer.Id
		];
		affiliation[0].npe5__Status__c = 'Inactive';
		update affiliation;

		Test.startTest();
		OTUB_UpdateVolUserStatusOnBGCOI_AC batchAffiliation = new OTUB_UpdateVolUserStatusOnBGCOI_AC();
		Database.executeBatch(batchAffiliation, 200);
		Test.stopTest();
	}
}