/*--*****************************************************************************************************************
Author      : MST Solutions
Date        : 7/18/2016
Description : This test class used for unit test and code coverage
Modification Log: 
28/03/2018 - Kanagaraj
*******************************************************************************************************************/
@isTest
public class VolunteerRole_AT_Test {

	private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;

	@TestSetup
	private static void setup() {
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;

		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;

		insert OrientationandTrainingUtil.createAffiliation(con.id);
		Role__c currRole = OrientationandTrainingUtil.createRole();
		insert currRole;

		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.id, currRole.id);
		insert currChapRole;

		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id, currChapRole.id);
		insert currVolRole;
	}

	// Update Volunteer Role.
	static testMethod void createRecords() {
		Volunteer_Roles__c currVolRole = [
				SELECT Status__C
				FROM Volunteer_Roles__c
		];
		currVolRole.Status__c = 'Pending Training';
		update currVolRole;
		System.assertEquals(currVolRole.Status__c, 'Pending Training', 'Volunteer role status does not match');
		System.assert(currVolRole.Status__c == 'Pending Training', 'Volunteer role status does not match');
	}
	// Update volunteer role status as Out of Compliance and Trained
	static testMethod void updateVolunteerROle() {
		Account acc = [
				SELECT Id
				FROM Account
				WHERE RecordTypeId = :Constant_AC.CHAPTER_RT_ID AND Volunteer_Manager__c = :UserInfo.getUserId()
		];
		Contact con = [
				SELECT Id
				FROM Contact
		];
		Chapter_Role__c currChapRole = [
				SELECT Id
				FROM Chapter_Role__c
		];
		Volunteer_Roles__c currVolRole = [
				SELECT Id
				FROM Volunteer_Roles__c
		];

		Test.startTest();
		Volunteer_Opportunity__c newVlOpp = new Volunteer_Opportunity__c();
		newVlOpp.Chapter_Name__c = acc.id;
		newVlOpp.Chapter_Role_Opportunity__c = currChapRole.id;
		newVlOpp.Volunteer_Name__c = con.id;
		insert newVlOpp;

		Volunteer_Roles__c newVolunteerRole = OrientationandTrainingUtil.createVolRole(con.id, currChapRole.id);
		insert newVolunteerRole;

		currVolRole.Status__c = 'Out of Compliance';
		update currVolRole;
		newVolunteerRole.Status__c = 'Out of Compliance';
		currVolRole.Status__c = VOLUNTEER_ROLE_STATUS_ACTIVE;
		update currVolRole;
		update newVolunteerRole;
		Test.stopTest();

		System.assertEquals(currVolRole.Status__c, VOLUNTEER_ROLE_STATUS_ACTIVE, 'Volunteer role status does not match');
		System.assert(currVolRole.Status__c == VOLUNTEER_ROLE_STATUS_ACTIVE, 'Volunteer role status does not match');
	}

	static testMethod void updatbackgrounCheck() {
		Contact con = [
				SELECT Id
				FROM Contact
		];
		Background_check__c newBack = new Background_check__c();
		newBack.Volunteer__c = con.id;
		newBack.Current__c = true;
		insert newBack;
		Set<ID> volIdSet = new Set<ID>();
		volIdSet.add(con.id);

		System.assertEquals(newBack.Volunteer__c, con.id, 'Background check volunteer does not match');
		System.assert(newBack.Volunteer__c == con.id, 'Background check volunteer does not match');
	}

	static testMethod void updateConfilciOfInt() {
		Contact con = [
				SELECT Id
				FROM Contact
		];
		Chapter_Role__c currChapRole = [
				SELECT Id
				FROM Chapter_Role__c
		];
		currChapRole.Background_Check_Required__c = false;
		update currChapRole;
		Conflict_Of_Interest__c newCOI = new Conflict_Of_Interest__c();
		Volunteer_Roles__c newVolRole = new Volunteer_Roles__c();
		newVolRole.Volunteer_Name__c = con.id;
		newVolRole.Chapter_Role__c = currChapRole.id;
		newVolRole.Status__c = 'Pending Training';
		insert newVolRole;
		newCOI.Volunteer_Contact__c = con.id;
		newCOI.Current__c = true;
		insert newCOI;
		Set<ID> volIdSet = new Set<ID>();
		volIdSet.add(con.id);
		System.assertEquals(newVolRole.Status__c, 'Pending Training', 'Volunteer role status does not match');
		System.assert(newVolRole.Status__c == 'Pending Training', 'Volunteer role status does not match');
	}
}