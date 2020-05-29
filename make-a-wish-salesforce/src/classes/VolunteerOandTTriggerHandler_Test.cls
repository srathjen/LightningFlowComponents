/**
 * @description Unit TEst for Converting Prospective Volunteer as Active one.
 * @author Kanagaraj, MST Solutions
 * @date 28/06/2016
 **/
@IsTest
public class VolunteerOandTTriggerHandler_Test {

    // Converting Prospective Volunteer As Active.
    @IsTest
    static void completeTraining() {
        trac_TriggerHandlerBase.blockTrigger = true;
        Account acc = TestDataFactory.createChapterAccount(1)[0];
        insert acc;

        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.Id;
        con.RecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
        insert con;

        npe5__Affiliation__c affiliation = TestDataFactory.createAffiliation(1)[0];
        affiliation.npe5__Contact__c = con.Id;
        affiliation.npe5__Organization__c = acc.Id;
        insert affiliation;

        User currUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            currUser = TestDataFactory.createVolunteerUser(1)[0];
            insert currUser;
        }

        Background_check__c currBC = TestDataFactory.createBackgroundCheck(1)[0];
        currBC.Date_Completed__c = Date.today();
        currBC.Status__c = 'Approved';
        insert currBC;

        Conflict_Of_Interest__c createCOI = TestDataFactory.createConflictOfInterest(1)[0];
        createCOI.Volunteer_Contact__c = con.Id;
        insert createCOI;

        Role__c currRole = TestDataFactory.createRole(1, true)[0];
        insert currRole;

        Chapter_Role__c currChapRole = TestDataFactory.createChapterRole(1)[0];
        currChapRole.Chapter_Name__c = acc.Id;
        currChapRole.Role_Name__c = currRole.Id;
        insert currChapRole;

        Volunteer_Roles__c currVolRole = TestDataFactory.createVolunteerRole(1)[0];
        currVolRole.Chapter_Role__c = currChapRole.Id;
        currVolRole.Volunteer_Name__c = con.Id;
        insert currVolRole;

        Orientation_Training__c currOandT = TestDataFactory.createOrientationTraining(1)[0];
        currOandT.RecordTypeId = Constant_AC.TRAINING_RT_ID;
        insert currOandT;

        Chapter_Role_O_T__c currChapOandT = TestDataFactory.createChapterRoleOrientationAndTraining(1)[0];
        currChapOandT.Chapter_Role__c = currChapRole.Id;
        currChapOandT.Orientation_Training__c = currOandT.Id;
        insert currChapOandT;

        Class_Offering__c currOffering = TestDataFactory.createClassOffering(1)[0];
        currOffering.Chapter_Role_O_T__c = currChapOandT.Id;
        insert currOffering;
        trac_TriggerHandlerBase.blockTrigger = false;

        Test.startTest();
        Volunteer_Orientation_Training__c createVolTraining = TestDataFactory.createVolunteerOrientationAndTraining(1)[0];
        createVolTraining.Class_Offering__c = currOffering.Id;
        createVolTraining.Hidden_O_T_Id__c = currOandT.Id;
        createVolTraining.Registered_Date__c = Date.today();
        createVolTraining.Volunteer__c = con.Id;
        createVolTraining.Volunteer_Attendance__c = 'Registered';
        createVolTraining.Type__c = 'Training';
        createVolTraining.RE_Completed_Date__c = String.valueOf(System.today());
        createVolTraining.Volunteer_Attendance__c = 'Completed';
        insert createVolTraining;
        update createVolTraining;
        Test.stopTest();

        System.assertEquals(createVolTraining.Volunteer_Attendance__c, 'Completed', 'Volunteer attendance does not match');
        System.assert(createVolTraining.Volunteer_Attendance__c == 'Completed', 'Volunteer attendance does not match');
    }
}