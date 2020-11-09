/**
 * @description Unit TEst for Converting Prospective Volunteer as Active one.
 * @author Kanagaraj, MST Solutions
 * @date 28/06/2016
 **/
@IsTest
public class VolunteerOandTTriggerHandler_Test {

    @TestSetup
    static void setup() {
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
        User adminWithRole = [
                SELECT Id
                FROM User
                WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE AND UserRoleId != NULL
                LIMIT 1
        ];
        System.runAs(adminWithRole) {
            currUser = TestDataFactory.createVolunteerUser(1, 'Prospective Volunteer (Login)', 'Manager')[0];
            currUser.ContactId = con.Id;
            insert currUser;
        }

        Background_check__c currBC = TestDataFactory.createBackgroundCheck(1)[0];
        currBC.Date__c = Date.today().addDays(1);
        currBC.Date_Completed__c = Date.today().addDays(1);
        currBC.Status__c = Constant_AC.BACKGROUND_CHECK_STATUS_APPROVED;
        currBC.Volunteer__c = con.Id;
        insert currBC;

        Conflict_Of_Interest__c createCOI = TestDataFactory.createConflictOfInterest(1)[0];
        createCOI.Volunteer_Contact__c = con.Id;
        createCOI.Expiration_Date__c = Date.today().addDays(1);
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
        currChapOandT.Required__c = true;
        insert currChapOandT;

        Class_Offering__c currOffering = TestDataFactory.createClassOffering(1)[0];
        currOffering.Chapter_Role_O_T__c = currChapOandT.Id;
        currOffering.RecordTypeId = Constant_AC.CLASS_OFFERING_RECORD_TYPE_ID;
        insert currOffering;

        trac_TriggerHandlerBase.blockTrigger = false;
    }

    // Converting Prospective Volunteer As Active.
    @IsTest
    static void cancelledTraining() {
        SetupPackage pkg = new SetupPackage();
        Test.startTest();
        Volunteer_Orientation_Training__c createVolTraining = TestDataFactory.createVolunteerOrientationAndTraining(1)[0];
        createVolTraining.Class_Offering__c = pkg.classOffering.Id;
        createVolTraining.Hidden_O_T_Id__c = pkg.orientationTraining.Id;
        createVolTraining.Registered_Date__c = Date.today();
        createVolTraining.Volunteer__c = pkg.volunteer.Id;
        createVolTraining.Type__c = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING;
        createVolTraining.RE_Completed_Date__c = String.valueOf(System.today());
        createVolTraining.Volunteer_Attendance__c = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED;
        insert createVolTraining;
        update createVolTraining;
        Test.stopTest();

        System.assertEquals(createVolTraining.Volunteer_Attendance__c, Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED);
    }

    // Converting Prospective Volunteer As Active.
    @IsTest
    static void registeredTraining() {
        SetupPackage pkg = new SetupPackage();
        Test.startTest();
        Volunteer_Orientation_Training__c createVolTraining = TestDataFactory.createVolunteerOrientationAndTraining(1)[0];
        createVolTraining.Class_Offering__c = pkg.classOffering.Id;
        createVolTraining.Hidden_O_T_Id__c = pkg.orientationTraining.Id;
        createVolTraining.Registered_Date__c = Date.today();
        createVolTraining.Volunteer__c = pkg.volunteer.Id;
        createVolTraining.Type__c = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING;
        createVolTraining.RE_Completed_Date__c = String.valueOf(System.today());
        createVolTraining.Volunteer_Attendance__c = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED;
        insert createVolTraining;
        update createVolTraining;
        Test.stopTest();

        System.assertEquals(createVolTraining.Volunteer_Attendance__c, Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED);
    }

    // Converting Prospective Volunteer As Active.
    @IsTest
    static void registeredOrientation() {
        SetupPackage pkg = new SetupPackage();
        Test.startTest();
        Volunteer_Orientation_Training__c createVolTraining = TestDataFactory.createVolunteerOrientationAndTraining(1)[0];
        createVolTraining.Class_Offering__c = pkg.classOffering.Id;
        createVolTraining.Hidden_O_T_Id__c = pkg.orientationTraining.Id;
        createVolTraining.Registered_Date__c = Date.today();
        createVolTraining.Volunteer__c = pkg.volunteer.Id;
        createVolTraining.Type__c = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_TYPE_ORIENTATION;
        createVolTraining.RE_Completed_Date__c = String.valueOf(System.today());
        createVolTraining.Volunteer_Attendance__c = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED;
        insert createVolTraining;
        update createVolTraining;
        Test.stopTest();

        System.assertEquals(createVolTraining.Volunteer_Attendance__c, Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED);
    }

    // Converting Prospective Volunteer As Active.
    @IsTest
    static void completedOrientation() {
        SetupPackage pkg = new SetupPackage();
        Test.startTest();
        Volunteer_Orientation_Training__c createVolTraining = TestDataFactory.createVolunteerOrientationAndTraining(1)[0];
        createVolTraining.Class_Offering__c = pkg.classOffering.Id;
        createVolTraining.Hidden_O_T_Id__c = pkg.orientationTraining.Id;
        createVolTraining.Registered_Date__c = Date.today();
        createVolTraining.Volunteer__c = pkg.volunteer.Id;
        createVolTraining.Type__c = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_TYPE_ORIENTATION;
        createVolTraining.RE_Completed_Date__c = String.valueOf(System.today());
        insert createVolTraining;
        createVolTraining.Volunteer_Attendance__c = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED;
        update createVolTraining;
        Test.stopTest();

        System.assertEquals(createVolTraining.Volunteer_Attendance__c, Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED);
    }

    // Converting Prospective Volunteer As Active.
    @IsTest
    static void cancelledOrientation() {
        SetupPackage pkg = new SetupPackage();
        Test.startTest();
        Volunteer_Orientation_Training__c createVolTraining = TestDataFactory.createVolunteerOrientationAndTraining(1)[0];
        createVolTraining.Class_Offering__c = pkg.classOffering.Id;
        createVolTraining.Hidden_O_T_Id__c = pkg.orientationTraining.Id;
        createVolTraining.Registered_Date__c = Date.today();
        createVolTraining.Volunteer__c = pkg.volunteer.Id;
        createVolTraining.Type__c = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_TYPE_ORIENTATION;
        createVolTraining.RE_Completed_Date__c = String.valueOf(System.today());
        insert createVolTraining;
        createVolTraining.Volunteer_Attendance__c = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED;
        update createVolTraining;
        Test.stopTest();

        System.assertEquals(createVolTraining.Volunteer_Attendance__c, Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED);
    }

    // Converting Prospective Volunteer As Active.
    @IsTest
    static void updateVolunteerHiddenVolOTStatus() {
        SetupPackage pkg = new SetupPackage();
        Test.startTest();
        VolunteerOTService.updateVolunteerHiddenVolOTStatus(new Set<Id>{
                pkg.volunteer.Id
        }, VolunteerOTService.ACTION_TRAINING);
        System.assertEquals(Constant_AC.CONTACT_HIDDEN_VOLUNTEER_STATUS_TRAINING_REGISTERED, [
                SELECT Id, Hidden_Volunteer_OT_Status__c
                FROM Contact
                WHERE Id = :pkg.volunteer.Id
        ].Hidden_Volunteer_OT_Status__c);
        VolunteerOTService.updateVolunteerHiddenVolOTStatus(new Set<Id>{
                pkg.volunteer.Id
        }, VolunteerOTService.ACTION_ORIENTATION);
        System.assertEquals(Constant_AC.CONTACT_HIDDEN_VOLUNTEER_STATUS_ORIENTATION_COMPLETED, [
                SELECT Id, Hidden_Volunteer_OT_Status__c
                FROM Contact
                WHERE Id = :pkg.volunteer.Id
        ].Hidden_Volunteer_OT_Status__c);
        Test.stopTest();
    }

    // Converting Prospective Volunteer As Active.
    @IsTest
    static void updateUserVolunteerStatusRegistered() {
        SetupPackage pkg = new SetupPackage();
        Test.startTest();
        VolunteerOTService.updateUserVolunteerStatus(new Set<Id>{
                pkg.volunteer.Id
        }, VolunteerOTService.ACTION_REGISTERED);
        Test.stopTest();
        System.assertEquals(Constant_AC.USER_VOLUNTEER_ORIENTATION_STATUS_REGISTERED, [
                SELECT Id, Volunteer_Orientation_Status__c
                FROM User
                WHERE ContactId = :pkg.volunteer.Id
        ].Volunteer_Orientation_Status__c);
    }

    // Converting Prospective Volunteer As Active.
    @IsTest
    static void updateUserVolunteerStatusCancelled() {
        SetupPackage pkg = new SetupPackage();
        Test.startTest();
        VolunteerOTService.updateUserVolunteerStatus(new Set<Id>{
                pkg.volunteer.Id
        }, VolunteerOTService.ACTION_VOLUNTEER_CANCELLED);
        Test.stopTest();
        System.assertEquals(Constant_AC.USER_VOLUNTEER_ORIENTATION_STATUS_CANCELLED, [
                SELECT Id, Volunteer_Orientation_Status__c
                FROM User
                WHERE ContactId = :pkg.volunteer.Id
        ].Volunteer_Orientation_Status__c);
    }

    private class SetupPackage {
        public Class_Offering__c classOffering { get; set; }
        public Orientation_Training__c orientationTraining { get; set; }
        public Contact volunteer { get; set; }
        public SetupPackage() {
            classOffering = [
                    SELECT Id
                    FROM Class_Offering__c
            ];
            orientationTraining = [
                    SELECT Id
                    FROM Orientation_Training__c
            ];
            volunteer = [
                    SELECT Id
                    FROM Contact
                    WHERE RecordTypeId = :Constant_AC.VOLUNTEER_RT_ID
                    LIMIT 1
            ];
        }
    }
}