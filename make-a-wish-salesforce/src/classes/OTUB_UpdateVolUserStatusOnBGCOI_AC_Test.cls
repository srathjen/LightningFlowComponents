/*****************************************************************************************
Created By  : MST
Author : MST Solutions
Description : Used to cover code coverage for OTUB_UpdateVolUserStatusOnBGCOI_AC class
**********************************************************************************************/
@IsTest
public class OTUB_UpdateVolUserStatusOnBGCOI_AC_Test {

	//Used to update Background Check and COI record Hidden Inactive Volunteer Field based on Org Aff Status
	static testmethod void updateActiveStatus() {
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		Contact updateContact = new Contact();
		updateContact.id = con.id;
		updateContact.is_Application__c = 'Approved';
		update updateContact;

		npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(con.id);
		insert affiliation;
		affiliation.npe5__Status__c = 'Active';
		update affiliation;

		System.assertEquals(affiliation.npe5__Status__c, 'Active');
		Background_check__c createExpiredBC = new Background_check__c();
		createExpiredBC.Volunteer__c = affiliation.npe5__Contact__c;
		createExpiredBC.Status__c = 'Approved';
		createExpiredBC.Current__c = TRUE;
		createExpiredBC.Date__c = Date.Today().addDays(-5);
		createExpiredBc.Date_Completed__c = Date.Today();
		createExpiredBc.Volunteer_is_Inactive__c = True;
		insert createExpiredBC;

		Conflict_Of_Interest__c newCOI = new Conflict_Of_Interest__c();
		newCOI.Volunteer_Contact__c = affiliation.npe5__Contact__c;
		newCOI.Expiration_Date__c = Date.Today().addDays(-5);
		newCOI.Volunteer_is_Inactive__c = True;
		newCOI.Current__c = TRUE;
		insert newCOI;

		Test.startTest();
		OTUB_UpdateVolUserStatusOnBGCOI_AC batchAffiliation = new OTUB_UpdateVolUserStatusOnBGCOI_AC();
		Database.executeBatch(batchAffiliation, 200);
		Test.stopTest();

	}

	//Used to update Background Check and COI record Hidden Inactive Volunteer Field based on Org Aff Status
	static testmethod void updateInActiveStatus() {
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		Contact updateContact = new Contact();
		updateContact.id = con.id;
		updateContact.is_Application__c = 'Approved';
		update updateContact;

		npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(con.id);
		insert affiliation;
		affiliation.npe5__Status__c = 'Inactive';
		update affiliation;

		System.assertEquals(affiliation.npe5__Status__c, 'Inactive');
		Background_check__c createExpiredBC = new Background_check__c();
		createExpiredBC.Volunteer__c = affiliation.npe5__Contact__c;
		createExpiredBC.Status__c = 'Approved';
		createExpiredBC.Current__c = TRUE;
		createExpiredBC.Date__c = Date.Today().addDays(-5);
		createExpiredBc.Date_Completed__c = Date.Today();
		createExpiredBc.Volunteer_is_Inactive__c = false;
		insert createExpiredBC;

		Conflict_Of_Interest__c newCOI = new Conflict_Of_Interest__c();
		newCOI.Volunteer_Contact__c = affiliation.npe5__Contact__c;
		newCOI.Expiration_Date__c = Date.Today().addDays(-5);
		newCOI.Volunteer_is_Inactive__c = false;
		newCOI.Current__c = TRUE;
		insert newCOI;

		Test.startTest();
		OTUB_UpdateVolUserStatusOnBGCOI_AC batchAffiliation = new OTUB_UpdateVolUserStatusOnBGCOI_AC();
		Database.executeBatch(batchAffiliation, 200);
		Test.stopTest();
	}
}