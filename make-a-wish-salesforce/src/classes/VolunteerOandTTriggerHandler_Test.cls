/**
 * Author      : MST Solutions
 * CreatedBy   : Kanagaraj
 * Date        : 28/06/2016
 * Description : Unit TEst for Converting Prospective Volunteer as Active one.
 * Modification Log:
 * 28/03/2018 - Kanagaraj
 **/
@IsTest
public class VolunteerOandTTriggerHandler_Test {

    // Converting Prospective Volunteer As Active.
    @IsTest
    static void completeTraining() {
        trac_TriggerHandlerBase.blockTrigger = true;
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        insert acc;

        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.Id);
        insert con;

        npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(con.Id);
        insert affiliation;

        User currUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.Id);
            insert currUser;
        }

        Background_check__c currBC = OrientationandTrainingUtil.createBackgroundCheck(con.Id);
        currBC.Date_Completed__c = Date.today();
        currBC.Status__c = 'Approved';
        insert currBC;
        trac_TriggerHandlerBase.blockTrigger = false;

        Test.startTest();
        Conflict_Of_Interest__c createCOI = OrientationandTrainingUtil.createCOI(con.Id);
        insert createCOI;
        Role__c currRole = OrientationandTrainingUtil.createRole();
        insert currRole;
        Chapter_Role__c currChapRole = OrientationandTrainingUtil.createChapter(acc.Id, currRole.Id);
        insert currChapRole;
        Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.Id, currChapRole.Id);
        insert currVolRole;
        Orientation_Training__c currOandT = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
        insert currOandT;
        Chapter_Role_O_T__c currChapOandT = OrientationandTrainingUtil.createChapterOandT(currChapRole.Id, currOandT.Id);
        insert currChapOandT;
        Class_Offering__c currOffering = OrientationandTrainingUtil.createClassOffering(currChapOandT.Id);
        insert currOffering;
        Volunteer_Orientation_Training__c createVolTraining = OrientationandTrainingUtil.createVolTraining(currOandT.Id, currOffering.Id, con.Id, 'Registered');
        createVolTraining.Volunteer_Attendance__c = 'Completed';
        insert createVolTraining;
        Test.stopTest();
        System.assertEquals(createVolTraining.Volunteer_Attendance__c, 'Completed', 'Volunteer attendance does not match');
        System.assert(createVolTraining.Volunteer_Attendance__c == 'Completed', 'Volunteer attendance does not match');
    }
}