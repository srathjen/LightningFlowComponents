/*************************************************************************************************************************************************
Created by: Pavithra
Author : MST Solutions
CreateDate : 10/05/2016
Description :Batch_UpdateVolunteerStatus_Test is used to increase the code coverage for Batch_UpdateVolunteerStatus_AC class.
*************************************************************************************************************************************************/

@isTest
public class Batch_UpdateVolunteerRoleStatus_Test {
    
    private final static Id CHAPTER_RT_ID = Constant_AC.CHAPTER_RT_ID;
    private final static Id VOLUNTEER_RT_ID = Constant_AC.VOLUNTEER_RT_ID;
    private final static String VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING;
    private final static Id TRAINING_RT_ID = Constant_AC.TRAINING_RT_ID;
    private final static Id CLASS_OFFERING_RECORD_TYPE_ID = Constant_AC.CLASS_OFFERING_RECORD_TYPE_ID;
    private final static String VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE = Constant_AC.VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE;
    private final static String VOLUNTEER_ROLE_STATUS_PENDING = Constant_AC.VOLUNTEER_ROLE_STATUS_PENDING;
    private final static String VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED;
    
    @TestSetup
    static void setUp() {
        trac_TriggerHandlerBase.blockTrigger = true;
        
        List<Account> accountList = TestDataFactory.createAccount(1);
        Account accountAzChapter = accountList.get(0);
        accountAzChapter.Name = 'Make-A-Wish Arizona';
        accountAzChapter.RecordTypeId = CHAPTER_RT_ID;
        insert accountList;
        
        List<Contact> contactList = TestDataFactory.createContact(1);
        Contact volunteerKelly = contactList.get(0);
        volunteerKelly.FirstName = 'Kelly';
        volunteerKelly.LastName = 'Maddox';
        volunteerKelly.Email = 'Test.Mawa@gmail.com';
        volunteerKelly.RecordTypeId = VOLUNTEER_RT_ID;
        volunteerKelly.AccountId = accountAzChapter.Id;
        insert contactList;
        
        List<User> userList = TestDataFactory.createUser(1);
        User volunteerUser = userList.get(0);
        volunteerUser.ContactId = volunteerKelly.Id;
        volunteerUser.ProfileId = Label.Active_Volunteer_Profile;
        insert userList;
        
        List<npe5__Affiliation__c> affiliationList = TestDataFactory.createAffiliation(1);
        npe5__Affiliation__c affiliation = affiliationList.get(0);
        affiliation.npe5__Organization__c = accountAzChapter.Id;
        affiliation.npe5__Primary__c = true;
        affiliation.npe5__Contact__c = volunteerKelly.Id;
        insert affiliationList;
        
        List<Role__c> roleList = TestDataFactory.createRole(2, true);
        Role__c wishRole = roleList.get(0);
        wishRole.Name = 'Wish Granter';
        Role__c nonWishRole = roleList.get(1);
        nonWishRole.Name  = 'Assistant';
        nonWishRole.isWishRole__c = false;
        insert roleList;
        
        List<Chapter_Role__c> chapterRoleList = TestDataFactory.createChapterRole(2);
        Chapter_Role__c wishGranterChapterRole = chapterRoleList.get(0);
        wishGranterChapterRole.Chapter_Name__c = accountAzChapter.Id;
        wishGranterChapterRole.Role_Name__c = wishRole.Id;
        wishGranterChapterRole.Background_Check_Required__c = true;
        Chapter_Role__c nonWishChapterRole = chapterRoleList.get(1);
        nonWishChapterRole.Chapter_Name__c = accountAzChapter.Id;
        nonWishChapterRole.Role_Name__c = nonWishRole.Id;
        nonWishChapterRole.Background_Check_Required__c = false;
        insert chapterRoleList;
        
        List<Orientation_Training__c> orientationTrainingList = TestDataFactory.createOrientationTraining(1);
        Orientation_Training__c orientationTraining = orientationTrainingList.get(0);
        orientationTraining.Chapter_Name__c = accountAzChapter.Id;
        orientationTraining.RecordTypeId = TRAINING_RT_ID;
        insert orientationTrainingList;
        
        List<Chapter_Role_O_T__c>  chapterRoleOTList = TestDataFactory.createChapterRoleOrientationAndTraining(2);
        Chapter_Role_O_T__c wishRoleOT = chapterRoleOTList.get(0);
        wishRoleOT.Chapter_Role__c = wishGranterChapterRole.Id;
        wishRoleOT.Required__c = true;
        wishRoleOT.Orientation_Training__c = orientationTraining.Id;
        Chapter_Role_O_T__c nonwishRoleOT = chapterRoleOTList.get(1);
        nonwishRoleOT.Chapter_Role__c = nonWishChapterRole.Id;
        nonwishRoleOT.Required__c = true;
        nonwishRoleOT.Orientation_Training__c = orientationTraining.Id;
        insert chapterRoleOTList;
        
        List<Class_Offering__c> classOfferingList = TestDataFactory.createClassOffering(2);
        Class_Offering__c classOne = classOfferingList.get(0);
        classOne.Chapter_Role_O_T__c = wishRoleOT.Id;
        classOne.Date__c = System.Today() + 10;
        classOne.Start_Time__c = '10:00 AM';
        classOne.End_Time__c = '11:00 AM';
        classOne.max_capacity__c = 100;
        classOne.Location__c = 'Online';
        classOne.RecordTypeId = CLASS_OFFERING_RECORD_TYPE_ID;
        Class_Offering__c classTwo = classOfferingList.get(1);
        classTwo.Chapter_Role_O_T__c = nonwishRoleOT.Id;
        classTwo.Date__c = System.Today() + 10;
        classTwo.Start_Time__c = '10:00 AM';
        classTwo.End_Time__c = '11:00 AM';
        classTwo.max_capacity__c = 100;
        classTwo.Location__c = 'Online';
        classTwo.RecordTypeId = CLASS_OFFERING_RECORD_TYPE_ID;
        insert classOfferingList;
        
        List<Volunteer_Roles__c> volunteerRolesList = TestDataFactory.createVolunteerRole(2);
        Volunteer_Roles__c volunteerWishRole = volunteerRolesList.get(0);
        volunteerWishRole.Volunteer_Name__c = volunteerKelly.Id;
        volunteerWishRole.Chapter_Role__c = wishGranterChapterRole.Id;
        volunteerWishRole.Status__c = VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE;
        Volunteer_Roles__c volunteerNonwishRole = volunteerRolesList.get(1);
        volunteerNonwishRole.Volunteer_Name__c = volunteerKelly.Id;
        volunteerNonwishRole.Chapter_Role__c = nonWishChapterRole.Id;
        volunteerNonwishRole.Status__c = VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE;
        insert volunteerRolesList;
        
        List<Volunteer_Orientation_Training__c> volunteerOTList = TestDataFactory.createVolunteerOrientationAndTraining(1);
        Volunteer_Orientation_Training__c volunteerOT = volunteerOTList.get(0);
		volunteerOT.class_offering__c = classOne.Id;
		volunteerOT.Hidden_O_T_Id__c = orientationTraining.Id;
		volunteerOT.Registered_Date__c = Date.today();
		volunteerOT.Volunteer__c = volunteerKelly.Id;
		volunteerOT.Volunteer_Attendance__c = VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED;
		volunteerOT.Type__c = VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING;
		volunteerOT.RE_Completed_Date__c = String.valueOf(System.today());
        insert volunteerOTList;
        
        trac_TriggerHandlerBase.blockTrigger = false;
    }

    @isTest
    static void updateVolunteerHiddenStatus() {
        Test.startTest();
        Map<Id, Volunteer_Roles__c> volunteerRolesMap = new Map<Id, Volunteer_Roles__c>([
            SELECT Id, Status__c, Hidden_Previous_Status__c, Hidden_Previous_Sub_Status__c 
            FROM Volunteer_Roles__c
        ]);
        Database.executeBatch(new Batch_UpdateVolunteerRoleStatus_AC());
        Test.stopTest();
        
        List<Volunteer_Roles__c> volunteerRolesListUpdated = [
            SELECT Id, Status__c, Hidden_Previous_Status__c, Hidden_Previous_Sub_Status__c 
            FROM Volunteer_Roles__c
        ];
        System.assert(volunteerRolesListUpdated[0].Hidden_Previous_Status__c != volunteerRolesMap.get(volunteerRolesListUpdated[0].Id).Hidden_Previous_Status__c);
        System.assert(volunteerRolesListUpdated[0].Hidden_Previous_Status__c == VOLUNTEER_ROLE_STATUS_PENDING);
    }
}