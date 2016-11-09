/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 28/06/2016
Description : BackGroundCheck_AT_Test is used to increase the code coverage for Application_AC controller.
*****************************************************************************************************/
@isTest
public class BackGroundCheck_AT_Test {
    
     /*This method is used to update the background check record to approved*/
     
     public testmethod static void UpdateBackGroundChecktoApproved(){  
         Account volunteerAccount = OrientationandTrainingUtil.createVolunteerAccount();
         Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.Id);
         Role__c  role = OrientationandTrainingUtil.createRole();
         Chapter_Role__c  chapterRole = OrientationandTrainingUtil.createChapter(volunteerAccount.Id,role.Id);
         Volunteer_Roles__c volunteerRole = OrientationandTrainingUtil.createVolRole(volunteerContact.Id,chapterRole.Id);
         Orientation_Training__c  orientationId = OrientationandTrainingUtil.CreateVolunteerTrainingRecord();
         Chapter_Role_O_T__c chapterRoleT = OrientationandTrainingUtil.createChapterOandT (chapterRole.Id,orientationId.id);
         npe5__Affiliation__c  orgAfflitation = OrientationandTrainingUtil.CreateAffiliationwithAccount(volunteerContact.Id,volunteerAccount.Id);
         OrientationandTrainingUtil.createCOI(volunteerContact.Id);
         Background_check__c  backgroundcheck = OrientationandTrainingUtil.createBackgroundCheckFasleRec(volunteerContact.id);
        
       
             backgroundcheck.Status__c = 'Approved';
             backgroundcheck.Active__c = true;
             backgroundcheck.Date_Completed__c = system.today();
             update backgroundcheck; 
        
     }
     
     /*This method is used to update the background check record to Rejected*/
     
      public testmethod static void UpdateBackGroundChecktoRejected(){  
         Account volunteerAccount = OrientationandTrainingUtil.createVolunteerAccount();
         Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.Id);
         Background_check__c  backgroundcheck = OrientationandTrainingUtil.createBackgroundCheckFasleRec(volunteerContact.id);
       
             backgroundcheck.Status__c = 'Rejected';
             update backgroundcheck; 
       
     }
     /*This method is used to create background check record*/
     
     public testmethod static void CreateBackGroundCheckRecord(){  
         Account volunteerAccount = OrientationandTrainingUtil.createVolunteerAccount();
         Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.Id);
         OrientationandTrainingUtil.createBackgroundCheckRec(volunteerContact.Id);
         Background_check__c  backgroundcheck = OrientationandTrainingUtil.createBackgroundCheckActiveRec(volunteerContact.id);
         
     }
     
     
     /*This method is used to create background check record to Active*/
     
     public testmethod static void updateBackgroundChecktoActive(){  
         Account volunteerAccount = OrientationandTrainingUtil.createVolunteerAccount();
         Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.Id);
         Background_check__c  backgroundcheck = OrientationandTrainingUtil.createBackgroundCheckActiveRec(volunteerContact.id);
         Background_check__c  backgroundcheckfalse = OrientationandTrainingUtil.createBackgroundCheckFasleRec(volunteerContact.Id);
         backgroundcheckfalse.active__c= true;
         backgroundcheckfalse.Date_Completed__c = system.today() + 9;
         Database.SaveResult result = Database.update(backgroundcheckfalse,false);
         System.assertEquals('Active Background Check Already Exist',result.getErrors()[0].getMessage());
         
     }
     
     /*This method is used to create background check exisiting background record is Active or not*/
     
      public testmethod static void CheckExisitingRecordtoActive(){  
         Account volunteerAccount = OrientationandTrainingUtil.createVolunteerAccount();
         Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.Id);
         Background_check__c  backgroundcheck = OrientationandTrainingUtil.createBackgroundCheckActiveRec(volunteerContact.id);
         Background_check__c  backgroundcheckActive = OrientationandTrainingUtil.createBackgroundCheckActiveRec(volunteerContact.id);
         Background_check__c  backgroundcheckfalse = OrientationandTrainingUtil.createBackgroundCheckFasleRec(volunteerContact.Id);
         backgroundcheckfalse.active__c= true;
         backgroundcheckfalse.Date_Completed__c = system.today() + 9;
         Database.SaveResult result = Database.update(backgroundcheckfalse,false);
         System.assertEquals('Active Background Check Already Exist',result.getErrors()[0].getMessage());
         
     }
   }