/*--*****************************************************************************************************************
Author      : MST Solutions
CreatedBy   : Chandrasekar Nallusamy
Date        : 7/18/2016
Description : This test class used for unit test and code coverage
*******************************************************************************************************************/
@isTest
public class VolunteerRole_AT_Test{
    
    // Update Volunteer Role.
    static testmethod void createRecords()
    {
    
         Account acc = OrientationandTrainingUtil.createVolunteerAccount();
         Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
         OrientationandTrainingUtil.createAffiliation(con.id);
         Role__c currRole = OrientationandTrainingUtil.createRole();
         Chapter_Role__c  currChapRole = OrientationandTrainingUtil.createChapter(acc.id,currRole.id);
         Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id,currChapRole.id);
         currVolRole.Status__c = 'Pending Training';
         update currVolRole;
               
      
     
    }
 }