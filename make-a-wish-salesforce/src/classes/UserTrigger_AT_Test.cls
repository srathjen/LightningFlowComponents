/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 28/06/2016
Description : UserTrigger_AT_Test is used to increase the code coverage for Application_AC controller.
*****************************************************************************************************/
@isTest
public class UserTrigger_AT_Test {
    
   /*This method is used to create a system Addmin user records*/
    @testSetup static void setup(){   
     OrientationandTrainingUtil.createrSystemAdminUser();
     }
     /*This method is used to create a prospectiv user records*/
     
     public testmethod static void createProspectiveUser(){ 
       User dbUser = [SELECT Id,UserRoleId,UserName,ProfileId,Email,FirstName,LastName,isActive From User WHERE FirstName =: 'Test FirstName' Limit 1];
       system.RunAs(dbUser){
       Test.StartTest();
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
        contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
        OrientationandTrainingUtil.createProspectiveVolunteerUser(volunteerContact.id);
       Test.StopTest();
       }
     }
     
    /*This method is used to create a public Group records*/
    
     public testmethod static void createPublicGroup(){ 
         User dbUser = [SELECT Id,UserRoleId,UserName,ProfileId,Email,FirstName,LastName,isActive From User WHERE FirstName =: 'Test FirstName' Limit 1];
         system.RunAs(dbUser){
         Test.StartTest();
         OrientationandTrainingUtil.cretateGroup();
         //TestClassUtil.createProspectiveVolunteerUserthree();
         Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
         contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
         OrientationandTrainingUtil.createProspectiveVolunteerUser(volunteerContact.id);
         Test.StopTest();
         }
     }

   }