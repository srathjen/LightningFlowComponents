/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 28/06/2016
Description : Unit TEst for Converting Prospective Volunteer as Active one.
Modification Log: 
28/03/2018 - Kanagaraj
*****************************************************************************************************/
@isTest
public class VolunteerOandTTriggerHandler_Test {

	// Converting Prospective Volunteer As Active.
	static testmethod void completeTraining() {
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(con.id);
		insert affiliation;
		User currUser;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
			insert currUser;
		}
		Background_check__c currBC = OrientationandTrainingUtil.createBackgroundCheck(con.id);
		currBC.Date_Completed__C = Date.Today();
		currBC.status__c = 'Approved';
		insert currBC;
		test.startTest();
		Conflict_Of_Interest__c createCOI = OrientationandTrainingUtil.createCOI(con.id);
		insert createCOI;
		Role__c currRole = OrientationandTrainingUtil.createRole();
		insert currRole;
		Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.id, currRole.id);
		insert currChapRole;
		Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id, currChapRole.id);
		insert currVolRole;
		Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
		insert currOandT;
		Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.id, currOandT.id);
		insert currChapOandT;
		Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.id);
		insert currOffering;
		Volunteer_Orientation_Training__c createVolTraining = OrientationandTrainingUtil.createVolTraining(currOandT.id, currOffering.id, con.id, 'Registered');
		createVolTraining.Volunteer_Attendance__c = 'Completed';
		insert createVolTraining;
		test.stopTest();
		System.assertEquals(createVolTraining.Volunteer_Attendance__c, 'Completed', 'Volunteer attendance does not match');
		System.assert(createVolTraining.Volunteer_Attendance__c == 'Completed', 'Volunteer attendance does not match');
	}
}