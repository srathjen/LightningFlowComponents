/*--*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Chandrasekar Nallusamy
Date        : 7/18/2016
Description : This test class used for unit test and code coverage
*******************************************************************************************************************/
@isTest
public class VolunteerProfile_Controller_Test{

  /*  @testSetup static void setup(){
        Test.StartTest(); 
        TestClassUtil.createActiveVolunteerUser();
        TestClassUtil.createBackgroundCheckRec();
        TestClassUtil.createVolunteerTrainingForProfile();
        TestClassUtil.createVolunteerOrientationForProfile();
    }
    public static testMethod void createActiveVolunteerCommunityUser(){
        User dbUser = [SELECT Id,UserName, contactId ,ProfileId,Email,FirstName,LastName,isActive From User WHERE FirstName =: 'Jonathan' and profile.Name =: 'Active Volunteer' Limit 1];
        Volunteer_Orientation_Training__c newVol = new Volunteer_Orientation_Training__c();
        newVol.Orientation_Training__c = TestClassUtil.createTrainingForProfile().id;
        newVol.Volunteer__c = dbUser.ContactId;
        newVol.Volunteer_Attendance__c = 'Completed';
        insert newVol;
        
        system.RunAs(dbUser){
            PageReference pageRef = Page.VolunteerProfile_VF  ; 
            Test.setCurrentPage(pageRef);
            VolunteerProfile_Controller volProfile = new VolunteerProfile_Controller();
            volProfile.perSave();
            volProfile.getStates();
            volProfile.getCountry();
            volProfile.getGender();
            volProfile.getBirthDay();
            volProfile.getBirthMonth();
            volProfile.getRaceEthnicity();
            volProfile.getPreferedPhoneType();
            volProfile.getPreferedEmail();
            volProfile.getProfessionalSKills();
            volProfile.getLanguages();
            volProfile.getAddType();
            volProfile.getOtherCountry();
            volProfile.getOtherState();
            volProfile.getMake_A_Wish();
            volProfile.getConatctAtWork();
            volProfile.getEmpState();
            volProfile.getRelationShip();
            volProfile.getConatctAtWork();
            volProfile.perEdit();
            volProfile.perCancel();
            volProfile.empEdit();
            volProfile.empCancel();
            volProfile.emergencyEdit();
            volProfile.emergencyCancel();
        }
    } */
}