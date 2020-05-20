/*--*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Chandrasekar Nallusamy
Date        : 7/18/2016
Description : This test class used for unit test and code coverage
Modification Log: 
28/03/2018 - Kanagaraj
*******************************************************************************************************************/
@IsTest
public class VolunteerProfile_AC_Test {
     
    @TestSetup
    private static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;
        
        List<Account> accountList = TestDataFactory.createAccount(1);
        Account accountAzChapter = accountList.get(0);
        accountAzChapter.Name = 'Make-A-Wish Arizona';
        accountAzChapter.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
        insert accountList;
        
        List<Contact> contactList = TestDataFactory.createContact(1);
        Contact volunteerRon = contactList.get(0);
        volunteerRon.FirstName = 'Ronald';
        volunteerRon.LastName = 'Granger';
        volunteerRon.Email = 'Test.Mawa@gmail.com';
        volunteerRon.RecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
        volunteerRon.AccountId = accountAzChapter.Id;
        volunteerRon.read__c = 'English;Spanish';
        volunteerRon.Speak__c = 'English;Spanish';
        volunteerRon.Write__c = 'English;Spanish';
        volunteerRon.Understand__c = 'English;Spanish';
        volunteerRon.Language__c = 'English;Spanish';
        volunteerRon.Race_Ethnicity__c = 'Hispanic or Latino;White';
        volunteerRon.Professional_Skills__c = 'Graphic Design / Art Design;Photography';
        insert contactList;
        
        List<User> userList = TestDataFactory.createUser(1);
        User volunteerUser = userList.get(0);
        volunteerUser.FirstName = 'Ronald';
        volunteerUser.LastName = 'Granger';
        volunteerUser.ContactId = volunteerRon.Id;
        volunteerUser.ProfileId = Label.Active_Volunteer_Profile;
        insert userList;
        
        List<Background_check__c> backgroundCheckList = TestDataFactory.createBackgroundCheck(1);
        Background_check__c volunteerCheck = backgroundCheckList.get(0);
        volunteerCheck.Current__c = true;
        volunteerCheck.Status__c = 'Manual';
        volunteerCheck.Date_Completed__c = Date.today();
        volunteerCheck.Date__c = Date.today().addDays(30);
        volunteerCheck.Volunteer__c = volunteerRon.Id;
        insert backgroundCheckList;
        
        List<Conflict_Of_Interest__c> coiList = TestDataFactory.createConflictOfInterest(1);
        Conflict_Of_Interest__c volunteerCoi = coiList.get(0);
        volunteerCoi.Volunteer_Contact__c = volunteerRon.Id;
        volunteerCoi.Expiration_Date__c = Date.today().addDays(30);
        insert coiList;
        
        List<npe5__Affiliation__c> affiliationList = TestDataFactory.createAffiliation(1);
        npe5__Affiliation__c affiliation = affiliationList.get(0);
        affiliation.npe5__Organization__c = accountAzChapter.Id;
        affiliation.npe5__Primary__c = true;
        affiliation.npe5__Contact__c = volunteerRon.Id;
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
        orientationTraining.RecordTypeId = Constant_AC.TRAINING_RT_ID;
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
        classOne.RecordTypeId = Constant_AC.CLASS_OFFERING_RECORD_TYPE_ID;
        Class_Offering__c classTwo = classOfferingList.get(1);
        classTwo.Chapter_Role_O_T__c = nonwishRoleOT.Id;
        classTwo.Date__c = System.Today() + 10;
        classTwo.Start_Time__c = '10:00 AM';
        classTwo.End_Time__c = '11:00 AM';
        classTwo.max_capacity__c = 100;
        classTwo.Location__c = 'Online';
        classTwo.RecordTypeId = Constant_AC.CLASS_OFFERING_RECORD_TYPE_ID;
        insert classOfferingList;
        
        List<Volunteer_Orientation_Training__c> volunteerOTList = TestDataFactory.createVolunteerOrientationAndTraining(1);
        Volunteer_Orientation_Training__c volunteerOT = volunteerOTList.get(0);
        volunteerOT.class_offering__c = classOne.Id;
        volunteerOT.Hidden_O_T_Id__c = orientationTraining.Id;
        volunteerOT.Registered_Date__c = Date.today();
        volunteerOT.Volunteer__c = volunteerRon.Id;
        volunteerOT.Volunteer_Attendance__c = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED;
        volunteerOT.Type__c = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING;
        volunteerOT.RE_Completed_Date__c = String.valueOf(System.today());
        insert volunteerOTList;
        
        List<Awards_Recognition__c> awardsList = TestDataFactory.createAwardsRecognitions(1);
        Awards_Recognition__c awardVolunteer = awardsList.get(0);
        awardVolunteer.Chapter_Name__c = accountAzChapter.Id;
        awardVolunteer.Volunteer_Contact__c = volunteerRon.Id;
        insert awardsList;
        
        insert new LMS_Credentials__c(Name = 'LMS Integration');
        
        trac_TriggerHandlerBase.blockTrigger = false;
    }
    
    @isTest
    static void validateMissingInformationError() {
        List<Apexpages.Message> pageMessages;
        String errorMsg = '';
        User volunteerUser = [
            SELECT Id, ContactId 
            FROM User 
            WHERE Name = 'Ronald Granger'
        ];
        
        Test.startTest();
        System.RunAs(volunteerUser) {
            Test.setCurrentPage(Page.VolunteerProfile_VF);
            VolunteerProfile_AC profileController = new VolunteerProfile_AC();
            profileController.contactInstance[0].Email = null;
            profileController.SavePersonalInfo();
            pageMessages = ApexPages.getMessages();
        }
        Test.stopTest();
        for(Apexpages.Message msg : pageMessages) {
            errorMsg = errorMsg + msg.getSummary() + ' ';
        }
        System.assert(errorMsg.contains('Please enter all the mandatory fields'));
    }
    
    @isTest
    static void validateEditPersonalInfo() {
        PageReference returnPage;
        User volunteerUser = [
            SELECT Id, ContactId 
            FROM User 
            WHERE Name = 'Ronald Granger'
        ];
        Test.startTest();
        VolunteerProfile_AC profileController;
        System.RunAs(volunteerUser) {
            Test.setCurrentPage(Page.VolunteerProfile_VF);
            ApexPages.currentPage().getParameters().put('PersonalInfo', 'false');
            ApexPages.currentPage().getParameters().put('employeeInfo', 'false');
            ApexPages.currentPage().getParameters().put('emergencyInfo', 'false');
            profileController = new VolunteerProfile_AC();
            returnPage = profileController.EditPersonalInfo();
        }
        Test.stopTest();
        System.assert(String.valueOf(returnPage).contains('/apex/VolunteerProfile_VF?emergencyInfo=false&employeeInfo=false&PersonalInfo=false'));
    }
    
    @isTest
    static void validateCancelPersonalInfo() {
        PageReference returnPage;
        User volunteerUser = [
            SELECT Id, ContactId 
            FROM User 
            WHERE Name = 'Ronald Granger'
        ];
        Test.startTest();
        VolunteerProfile_AC profileController;
        System.RunAs(volunteerUser) {
            Test.setCurrentPage(Page.VolunteerProfile_VF);
            ApexPages.currentPage().getParameters().put('PersonalInfo', 'true');
            ApexPages.currentPage().getParameters().put('employeeInfo', 'true');
            ApexPages.currentPage().getParameters().put('emergencyInfo', 'true');
            profileController = new VolunteerProfile_AC();
            returnPage = profileController.CancelPersonalInfo();
        }
        Test.stopTest();
        System.assert(String.valueOf(returnPage).contains('/apex/VolunteerProfile_VF?emergencyInfo=true&employeeInfo=true&PersonalInfo=true'));
    }
    
    @isTest
    static void updateContactInfo() {
        User volunteerUser = [
            SELECT Id, ContactId 
            FROM User 
            WHERE Name = 'Ronald Granger'
        ];
        Contact volunteerContact = [
            SELECT Id, read__c, Speak__c, Write__c, Understand__c, Language__c, 
            Race_Ethnicity__c, Professional_Skills__c 
            FROM Contact 
            WHERE Id = :volunteerUser.ContactId
        ];
        volunteerContact.read__c = null;
        volunteerContact.Speak__c = null;
        volunteerContact.Write__c = null;
        volunteerContact.Understand__c = null;
        volunteerContact.Language__c = null;
        volunteerContact.Race_Ethnicity__c = null;
        volunteerContact.Professional_Skills__c = null;
        update volunteerContact;
        
        VolunteerProfile_AC profileController;
        Test.startTest();
        System.RunAs(volunteerUser) {
            profileController = new VolunteerProfile_Ac();
            profileController.COIExpirationDate = Date.today();
            profileController.bcExpirationDate = Date.today();
            profileController.lMSCourseId = 'TestCourseId';
            profileController.sSOUrl = 'TestSSO';
            profileController.courseURL = 'TestCourse';
            profileController.getStates();
            profileController.getGender();
            profileController.getBirthDay();
            profileController.getBirthYear();
            profileController.getBirthMonth();
            profileController.getRaceEthnicity();
            profileController.getPreferedEmail();
            profileController.getProfessionalSKills();
            profileController.getLanguages();
            profileController.getOtherState();
            profileController.getAddType();
            profileController.getMake_A_Wish();
            profileController.getConatctAtWork();
            profileController.getEmpState();
            profileController.getRelationShip();
            profileController.getPreferedPhoneType();
            profileController.viewLMS();
            VolunteerProfile_AC.AwardsWrapper awd = new VolunteerProfile_AC.AwardsWrapper('Test Name', 'Test Type', 'Test aName', Date.today());
            profileController.getTitles();
            profileController.contactInstance[0].Email = 'TestUpdate@gmail.com';
            profileController.contactInstance[0].Birth_Month__c = 'May';
            profileController.contactInstance[0].Birth_Day__c = '1';
            profileController.contactInstance[0].Birth_Year__c = String.valueOf(System.today().year() - 20);
            profileController.contactInstance[0].HomePhone = '8220708920';
            profileController.contactInstance[0].MailingStreet = '100 Cactus Blvd';
            profileController.contactInstance[0].MailingCity = 'Phoenix';
            profileController.contactInstance[0].MailingPostalCode = '85614';
            profileController.contactInstance[0].County__c = 'Maricopa';
            profileController.contactInstance[0].Mailingstatecode = 'AZ';
            profileController.contactInstance[0].MailingState = 'AZ';
            profileController.contactInstance[0].Understand__c = 'English;Spanish';
            profileController.contactInstance[0].Read__c = 'English;Spanish';
            profileController.contactInstance[0].Write__c = 'English;Spanish';
            profileController.contactInstance[0].Language__c = 'English;Spanish';
            profileController.contactInstance[0].Speak__c = 'English;Spanish';
            profileController.contactInstance[0].npe01__PreferredPhone__c = 'Home';
            profileController.contactInstance[0].Alternate_Phone_Type__c = 'Mobile';
            profileController.SavePersonalInfo();
        }
        Test.stopTest();
        System.assert(profileController.PersonalInfoSave == true);
    }
}