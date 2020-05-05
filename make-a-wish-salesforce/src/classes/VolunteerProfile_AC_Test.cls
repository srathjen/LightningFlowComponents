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
        insert new Bypass_Triggers__c(SetupOwnerId = UserInfo.getUserId());
    }
    
    // This test class used to cover all the picklist value retrieve function.
    static testMethod void coverAllPicklistFunction() {
        insert new LMS_Credentials__c(Name = 'LMS Integration');
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        insert acc;
        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
        con.Read__c = con.Speak__c = con.Write__c = con.Understand__c = con.Language__c = null;
        con.Race_Ethnicity__c = 'TestRace';
        insert con;
        npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(con.id);
        insert affiliation;
        User currUser;
        System.RunAs(new User(Id = UserInfo.getUserId())) {
            currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
            insert currUser;
        }
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
        Volunteer_Orientation_Training__c createVolOrientation = OrientationandTrainingUtil.createVolTraining(
            currOandT.id, currOffering.id, currUser.Contactid, 'Completed');
        Volunteer_Orientation_Training__c createVolOrientation2 = OrientationandTrainingUtil.createVolTraining(
            currOandT.id, currOffering.id, currUser.Contactid, 'Completed');
        createVolOrientation2.Type__c = 'Orientation';
        insert new List<Volunteer_Orientation_Training__c>{
            createVolOrientation, createVolOrientation2
                };
                    Background_check__c currBC = OrientationandTrainingUtil.createBackgroundCheck(con.id);
        insert currBC;
        Conflict_Of_Interest__c currCOI = OrientationandTrainingUtil.createCOI(con.id);
        insert currCOI;
        
        insert new Awards_Recognition__c(Volunteer_Contact__c = currUser.ContactId);
        
        Test.startTest();
        System.RunAs(currUser) {
            VolunteerProfile_AC profileController = new VolunteerProfile_Ac();
            profileController.COIExpirationDate = Date.Today();
            profileController.bcExpirationDate = Date.Today();
            profileController.lMSCourseId = 'Test';
            profileController.sSOUrl = 'Test';
            profileController.courseURL = 'Test';
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
            // Adding value for mulitselect list.
            profileController.raceEthinicityList.add('English');
            profileController.languagesList.add('English');
            profileController.langToRead.add('English');
            profileController.langToWrite.add('English');
            profileController.langToSpeak.add('English');
            profileController.langToUndetstand.add('English');
            profileController.professionalSkillsList.add('English');
            profileController.SavePersonalInfo();
            profileController.EditPersonalInfo();
            profileController.CancelPersonalInfo();
            profileController.viewLMS();
        }
        Test.stopTest();
    }
    
    // This test class used to cover all the picklist value retrieve function.
    static testMethod void updateContactInfowithHomePhoneType() {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        insert acc;
        Contact con = OrientationandTrainingUtil.VolunteerContactwithHomePhone(acc.id);
        insert con;
        npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(con.id);
        insert affiliation;
        User currUser;
        System.RunAs(new User(Id = UserInfo.getUserId())) {
            currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
            insert currUser;
        }
        System.RunAs(currUser) {
            VolunteerProfile_AC profileController = new VolunteerProfile_Ac();
            profileController.SavePersonalInfo();
        }
    }
    
    // This method is used to update the volunteer contact personal informations
    static testMethod void updateContactInfo() {
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
        System.RunAs(currUser) {
            VolunteerProfile_AC profileController = new VolunteerProfile_Ac();
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
            // Adding value for mulitselect list.
            profileController.raceEthinicityList.add('English');
            profileController.languagesList.add('English');
            profileController.langToRead.add('English');
            profileController.langToWrite.add('English');
            profileController.langToSpeak.add('English');
            profileController.langToUndetstand.add('English');
            profileController.professionalSkillsList.add('English');
            profileController.contactInstance.add(con);
            VolunteerProfile_AC.AwardsWrapper awd = new VolunteerProfile_AC.AwardsWrapper('Test Name', 'Test Type', 'Test aName', Date.today());
            profileController.getTitles();
            profileController.contactInstance[0].Email = 'Test@gmail.com';
            profileController.contactInstance[0].Birth_Month__c = 'May';
            profileController.contactInstance[0].Birth_Month__c = 'May';
            profileController.contactInstance[0].Birth_Day__c = '1';
            profileController.contactInstance[0].HomePhone = '8220708920';
            profileController.contactInstance[0].MailingStreet = 'Test';
            profileController.contactInstance[0].MailingCity = 'Test';
            profileController.contactInstance[0].MailingPostalCode = '12345';
            profileController.contactInstance[0].County__c = 'Test';
            profileController.contactInstance[0].mailingstatecode = 'AZ';
            profileController.contactInstance[0].Understand__c = 'English';
            profileController.contactInstance[0].Read__c = 'English';
            profileController.contactInstance[0].Write__c = 'English';
            profileController.contactInstance[0].Language__c = 'English';
            profileController.contactInstance[0].Speak__c = 'English';
            profileController.contactInstance[0].npe01__PreferredPhone__c = 'Home';
            profileController.contactInstance[0].Alternate_Phone_Type__c = 'Mobile';
            profileController.SavePersonalInfo();
            System.assertEquals(profileController.contactInstance[0].Email, 'Test@gmail.com', 'Volunteer profile email does not match');
            System.assert(profileController.contactInstance[0].Email == 'Test@gmail.com', 'Volunteer profile email does not match');
        }
    }
    
    // This test class used to Employee Update.
    static testMethod void updateEmployeeContactInfo() {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        insert acc;
        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
        insert con;
        npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(con.id);
        insert affiliation;
        User currUser;
        VolunteerProfile_AC profileController;
        System.RunAs(new User(Id = UserInfo.getUserId())) {
            currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
            insert currUser;
        }
        System.RunAs(currUser) {
            profileController = new VolunteerProfile_Ac();
            profileController.contactInstance.add(con);
            profileController.contactInstance[0].id = con.id;
        }
        profileController.SavePersonalInfo();
        System.assertEquals(profileController.contactInstance[0].id, con.id, 'Volunteer profile related contact does not match');
        System.assert(profileController.contactInstance[0].id == con.id, 'Volunteer profile related contact does not match');
    }
    
    // This test class used to Emergency Update.
    static testMethod void updateEmergencyContactInfo() {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        insert acc;
        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
        insert con;
        npe5__Affiliation__c affiliation = OrientationandTrainingUtil.createAffiliation(con.id);
        insert affiliation;
        User currUser;
        Test.setCurrentPageReference(Page.VolunteerProfile_VF);
        System.currentPageReference().getParameters().put('PersonalInfo', 'false');
        System.currentPageReference().getParameters().put('employeeInfo', 'false');
        System.currentPageReference().getParameters().put('emergencyInfo', 'false');
        VolunteerProfile_AC profileController;
        System.RunAs(new User(Id = UserInfo.getUserId())) {
            currUser = OrientationandTrainingUtil.createProspectiveVolunteerUser(con.id);
            insert currUser;
        }
        System.RunAs(currUser) {
            profileController = new VolunteerProfile_Ac();
            profileController.contactInstance.add(con);
            profileController.contactInstance[0].id = con.id;
            profileController.contactInstance[0].Emergency_Contact_Relationship__c = 'Friend';
            profileController.contactInstance[0].Emergency_Contact__c = 'Friend';
            profileController.contactInstance[0].Emergency_Contact_Phone__c = '8220708920';
            System.assertEquals(profileController.contactInstance[0].Emergency_Contact_Phone__c, '8220708920', 'Volunteer profile emergency contact does not match');
            System.assert(profileController.contactInstance[0].Emergency_Contact_Phone__c == '8220708920', 'Volunteer profile emergency contact does not match');
        }
        profileController.SavePersonalInfo();
    }
}