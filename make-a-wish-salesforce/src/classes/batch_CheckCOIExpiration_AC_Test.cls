/**
 * @description Test
 * @author MST
 * @createdDate
 */
@IsTest(SeeAllData=false)
public class batch_CheckCOIExpiration_AC_Test {

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

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	static void bgExpired() {
		Test.startTest();
		Database.executeBatch(new batch_CheckCOIExpiration_AC());
		Test.stopTest();
	}

	@IsTest
	static void testSchedule() {
		Test.startTest();
		batch_CheckCOIExpiration_AC reminder = new batch_CheckCOIExpiration_AC();
		String sch = '0 0 13 * * ?';
		System.schedule('Volunteer Opportunity Out of Compliance on Background Check Expiration', sch, reminder);
		Test.stopTest();
	}
}