/*************************************************************************************************************
Author : Mst Solutions
Description : This class is used to increase the code coverage for VolunteerOrientation_AC controller
Modification Log
1. WVC-2205 - Kanagaraj - 08/08/2018 // line - 237,55,99,142,189 Previously the affilliation status 
                                       was "Prospective". Now we have updated as "Pending".
**************************************************************************************************************/

@IsTest
public class VolunteerOrientation_AC_Test {
    
    @TestSetup
    private static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;
        
        Account accountAzChapter = TestDataFactory.createAccount(1)[0];
        accountAzChapter.Name = 'Make-A-Wish Arizona';
        accountAzChapter.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
        insert accountAzChapter;
        
        User volunteerUser = TestDataFactory.createVolunteerUser(1, 'Active Volunteer (Login)', 'Manager').get(0);
        volunteerUser.LastName = 'Smith0';
        volunteerUser.Email = 'js@email.com';
        System.runAs(TestDataFactory.adminUser) {
            insert volunteerUser;
        }

        Role__c wishRole = TestDataFactory.createRole(1, true)[0];
        wishRole.Name = 'Fundraising – Assist';
        insert wishRole;
        
        Chapter_Role__c chapterRoleFundraising = TestDataFactory.createChapterRole(1)[0];
        chapterRoleFundraising.Chapter_Name__c = accountAzChapter.Id;
        chapterRoleFundraising.Role_Name__c = wishRole.Id;
        insert chapterRoleFundraising;
        
        Volunteer_Roles__c volunteerRole = TestDataFactory.createVolunteerRole(1)[0];
        volunteerRole.Chapter_Role__c = chapterRoleFundraising.Id;
        volunteerRole.Volunteer_Name__c = volunteerUser.ContactId;
        volunteerRole.Status__c = 'Pending';
        volunteerRole.Sub_status__c = 'Missing Requirement';
        insert volunteerRole;
        
        List<Orientation_Training__c> orientationTrainingList = TestDataFactory.createOrientationTraining(2);
        Orientation_Training__c volunteerOrientationTraining = orientationTrainingList.get(0);
        volunteerOrientationTraining.Name = 'Volunteer Orientation';
        volunteerOrientationTraining.Chapter_Name__c = accountAzChapter.Id;
        volunteerOrientationTraining.RecordTypeId = Constant_AC.ORIENTATION_RT_ID;
        volunteerOrientationTraining.Start_Time__c = '8:00 AM';
        volunteerOrientationTraining.End_Time__c = '12:00 PM';
        Orientation_Training__c volunteerFundraiseTraining = orientationTrainingList.get(1);
        volunteerFundraiseTraining.Name = 'Volunteer Fundraising Training';
        volunteerFundraiseTraining.Chapter_Name__c = accountAzChapter.Id;
        volunteerFundraiseTraining.RecordTypeId = Constant_AC.ORIENTATION_RT_ID;
        volunteerFundraiseTraining.Start_Time__c = '1:00 PM';
        volunteerFundraiseTraining.End_Time__c = '5:00 PM';
        insert orientationTrainingList;
        
        List<Chapter_Role_O_T__c> chapterRoleOTList = TestDataFactory.createChapterRoleOrientationAndTraining(2);
        Chapter_Role_O_T__c azChapterOrientationTraining = chapterRoleOTList.get(0);
        azChapterOrientationTraining.Chapter_Role__c = chapterRoleFundraising.Id;
        azChapterOrientationTraining.Orientation_Training__c = volunteerOrientationTraining.Id;
        azChapterOrientationTraining.Required__c = true;
        Chapter_Role_O_T__c azChapterFundraiseTraining = chapterRoleOTList.get(1);
        azChapterFundraiseTraining.Chapter_Role__c = chapterRoleFundraising.Id;
        azChapterFundraiseTraining.Orientation_Training__c = volunteerFundraiseTraining.Id;
        azChapterFundraiseTraining.Required__c = true;
        insert azChapterOrientationTraining;
        
        List<Class_Offering__c> classOfferingList = TestDataFactory.createClassOffering(2);
        Class_Offering__c classOfferingOnline = classOfferingList.get(0);
        classOfferingOnline.Chapter_Role_O_T__c = azChapterOrientationTraining.Id;
        classOfferingOnline.Date__c = System.today() + 10;
        classOfferingOnline.Start_Time__c = '10:00 AM';
        classOfferingOnline.End_Time__c = '12:00 PM';
        classOfferingOnline.max_capacity__c = 100;
        classOfferingOnline.Location__c = 'Online';
        classOfferingOnline.RecordTypeId = Constant_AC.CLASS_OFFERING_RECORD_TYPE_ID;
        Class_Offering__c classOfferingLibrary = classOfferingList.get(1);
        classOfferingLibrary.Chapter_Role_O_T__c = azChapterFundraiseTraining.Id;
        classOfferingLibrary.Date__c = System.today() + 13;
        classOfferingLibrary.Start_Time__c = '1:00 PM';
        classOfferingLibrary.End_Time__c = '3:00 PM';
        classOfferingLibrary.max_capacity__c = 25;
        classOfferingLibrary.Location__c = 'Library';
        classOfferingLibrary.RecordTypeId = Constant_AC.CLASS_OFFERING_RECORD_TYPE_ID;
        insert classOfferingList;
        
        List<Volunteer_Orientation_Training__c> volunteerOTList = TestDataFactory.createVolunteerOrientationAndTraining(2);
        Volunteer_Orientation_Training__c completedVolunteerOT = volunteerOTList.get(0);
        completedVolunteerOT.Class_Offering__c = classOfferingOnline.Id;
        completedVolunteerOT.Hidden_O_T_Id__c = volunteerOrientationTraining.Id;
        completedVolunteerOT.Registered_Date__c = Date.today();
        completedVolunteerOT.Volunteer__c = volunteerUser.ContactId;
        completedVolunteerOT.Volunteer_Attendance__c = 'Completed';
        completedVolunteerOT.Type__c = 'Orientation';
        completedVolunteerOT.Volunteer__c = volunteerUser.ContactId;
        Volunteer_Orientation_Training__c noShowVolunteerOT = volunteerOTList.get(1);
        noShowVolunteerOT.Class_Offering__c = classOfferingOnline.Id;
        noShowVolunteerOT.Hidden_O_T_Id__c = volunteerOrientationTraining.Id;
        noShowVolunteerOT.Registered_Date__c = Date.today();
        noShowVolunteerOT.Volunteer__c = volunteerUser.ContactId;
        noShowVolunteerOT.Volunteer_Attendance__c = 'No Show';
        noShowVolunteerOT.Type__c = 'Orientation';
        noShowVolunteerOT.Volunteer__c = volunteerUser.ContactId;
        insert volunteerOTList;
        
        Dynamic_Content__c nationalContent = TestDataFactory.createDynamicContent(1)[0];
        nationalContent.RecordTypeId = Constant_AC.NATIONAL_RT_ID;
        nationalContent.Active__c = true;
        insert nationalContent;
        
        LMS_Credentials__c lmsIntegration = TestDataFactory.createLMSCredentials();
        insert lmsIntegration;

        npe5__Affiliation__c neworgAffiliation = TestDataFactory.createAffiliation(1)[0];
        neworgAffiliation.npe5__Contact__c = volunteerUser.ContactId;
        neworgAffiliation.npe5__Organization__c = accountAzChapter.Id;
        neworgAffiliation.npe5__Primary__c = true;
        neworgAffiliation.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
        neworgAffiliation.Constituent_Code__c = Constant_AC.BOARD_MEMBER_RT_LABEL;
        insert neworgAffiliation;

        trac_TriggerHandlerBase.blockTrigger = false;
    }
    
    @IsTest
    static void testRegistration() {
        User volunteer = [
                SELECT Id, ContactId
                FROM User
                WHERE Email = 'js@email.com'
                LIMIT 1
        ];
        Class_Offering__c libraryClass = [
            SELECT Id, Chapter_Role_O_T__r.Orientation_Training__c, Date__c, RecordTypeId
            FROM Class_Offering__c 
            WHERE Location__c = 'Library'
        ];
        Test.startTest();
        VolunteerOrientation_AC controller;
        System.runAs(volunteer) {
            PageReference pageRef = Page.VolunteerTraining_VF;
            Test.setCurrentPage(pageRef);
            System.currentPageReference().getParameters().put('bgRequired', 'true');
            System.currentPageReference().getParameters().put('trainingRequired', 'true');
            controller = new VolunteerOrientation_AC();
            Boolean bgTabPermission = controller.bgTabPermission;
            Boolean trainingTabVisible = controller.trainingTabVisible;
            controller.Beginning();
            controller.Next();
            controller.Previous();
            controller.TimingInfo();
            controller.getOrientationRecordList();
            controller.trainingId = libraryClass.Id;
            controller.classOfferingMap.put(libraryClass.Id, libraryClass);
            controller.Register();
        }
        Test.stopTest();
        System.assert(controller.isOrientationExist == true);
    }
    
    @IsTest
    static void testRegistrationCancelled() {
        User volunteer = [
                SELECT Id, ContactId
                FROM User
                WHERE Email = 'js@email.com'
                LIMIT 1
        ];
        Class_Offering__c onlineClass = [
            SELECT Id, Chapter_Role_O_T__r.Orientation_Training__c, Date__c, RecordTypeId
            FROM Class_Offering__c 
            WHERE Location__c = 'Online'
        ];
        Volunteer_Orientation_Training__c volOTCancel = [
            SELECT Id, Volunteer_Attendance__c 
            FROM Volunteer_Orientation_Training__c 
            WHERE Class_Offering__c = :onlineClass.Id 
            AND Volunteer_Attendance__c = 'Completed'
        ];
        volOTCancel.Volunteer_Attendance__c = 'Volunteer Cancelled';
        update volOTCancel;
        Test.startTest();
        VolunteerOrientation_AC controller;
        System.runAs(volunteer) {
            PageReference pageRef = Page.VolunteerTraining_VF;
            Test.setCurrentPage(pageRef);
            controller = new VolunteerOrientation_AC();
            controller.getOrientationRecordList();
            controller.trainingId = onlineClass.Id;
            controller.classOfferingMap.put(onlineClass.Id, onlineClass);
            controller.Register();
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testCancellation() {
        Account account = [
                SELECT Id
                FROM Account
                WHERE Name = 'Make-A-Wish Arizona'
                LIMIT 1
        ];
        User volunteer = [
                SELECT Id, ContactId
                FROM User
                WHERE Email = 'js@email.com'
                LIMIT 1
        ];
        npe5__Affiliation__c neworgAffiliation = TestDataFactory.createAffiliation(1)[0];
        neworgAffiliation.npe5__Contact__c = volunteer.ContactId;
        neworgAffiliation.npe5__Organization__c = account.Id;
        neworgAffiliation.npe5__Primary__c = true;
        neworgAffiliation.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
        insert neworgAffiliation;

        Class_Offering__c onlineClass = [
            SELECT Id, Chapter_Role_O_T__r.Orientation_Training__c, Date__c, RecordTypeId
            FROM Class_Offering__c 
            WHERE Location__c = 'Online'
        ];
        Test.startTest();
        VolunteerOrientation_AC controller;
        System.runAs(volunteer) {
            PageReference pageRef = Page.VolunteerTraining_VF;
            Test.setCurrentPage(pageRef);
            controller = new VolunteerOrientation_AC();
            controller.getOrientationRecordList();
            controller.total_size = 10;
            controller.list_size = 10;
            controller.getTotalPages();
            controller.getPageNumber();
            controller.getDisableNext();
            controller.getDisablePrevious();
            controller.trainingId = onlineClass.Id;
            controller.classOfferingMap.put(onlineClass.Id, onlineClass);
            controller.Cancel();
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testUserUpdate() {
        User volunteer = [
                SELECT Id, ContactId
                FROM User
                WHERE Email = 'js@email.com'
                LIMIT 1
        ];
        Test.startTest();
        System.runAs(volunteer) {
            PageReference pageRef = Page.VolunteerTraining_VF;
            Test.setCurrentPage(pageRef);
            VolunteerOrientation_AC.updateUser('3409379', 'selina.kyle@mawvolunteer.com', 'selina.kyle@mawvolunteer.com', volunteer.Id);
        }
        Test.stopTest();
        User volunteerUpdated = [
            SELECT Id, LMS_Id__c 
            FROM User 
            WHERE Id = :volunteer.Id
        ];
        System.assert(volunteerUpdated.LMS_Id__c == '3409379');
    }
    
    @IsTest
    static void testViewLMS() {
        User volunteer = [
                SELECT Id, ContactId
                FROM User
                WHERE Email = 'js@email.com'
                LIMIT 1
        ];
        System.runAs(volunteer) {
            LMSCourseSyncMockImpl currLMSCourseSyncMockImpl = new LMSCourseSyncMockImpl();
            HttpResponse response = new HttpResponse();
            response.setStatus('OK');
            response.setStatusCode(200);
            LMSUserResponse currLMSUserResponse = new LMSUserResponse();
            currLMSUserResponse.id = 1234;
            currLMSUserResponse.login = 'test@test.com';
            currLMSUserResponse.code = 'test@test.com';
            currLMSUserResponse.first_name = 'test';
            currLMSUserResponse.last_name = 'test';
            currLMSUserResponse.last_name = 'test@test.com';
            currLMSUserResponse.is_active = true;
            currLMSUserResponse.last_login_at = '2016-08-04T19:20:05.407-04:00';
            String payload = JSON.serialize(currLMSUserResponse);
            response.setBody(payload);
            currLMSCourseSyncMockImpl.addResponse(response);
            Test.setMock(HttpCalloutMock.class, currLMSCourseSyncMockImpl);
        }
        Test.startTest();
        VolunteerOrientation_AC controller;
        System.runAs(volunteer) {
            PageReference pageRef = Page.VolunteerOrientation_VF;
            Test.setCurrentPage(pageRef);
            controller = new VolunteerOrientation_AC();
            controller.lMSCourseId = 'TestCourse123';
            controller.viewLMS();
        }
        Test.stopTest();
    }
}