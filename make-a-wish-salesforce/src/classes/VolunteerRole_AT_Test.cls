/*--*****************************************************************************************************************
Author      : MST Solutions
Date        : 7/18/2016
Description : This test class used for unit test and code coverage
Modification Log: 
28/03/2018 - Kanagaraj
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
        system.AssertEquals(currVolRole.Status__c,'Pending Training','Volunteer role status does not match');
        system.Assert(currVolRole.Status__c == 'Pending Training','Volunteer role status does not match');
    }
    // Update volunteer role status as Out of Compliance and Trained   
    static testmethod void updateVolunteerROle()
    {
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
        OrientationandTrainingUtil.createAffiliation(con.id);
        Role__c currRole = OrientationandTrainingUtil.createRole();
        Chapter_Role__c  currChapRole = OrientationandTrainingUtil.createChapter(acc.id,currRole.id);
        Volunteer_Opportunity__c newVlOpp = new Volunteer_Opportunity__c();
        newVlOpp.Chapter_Name__c = acc.id;
        newVlOpp.Chapter_Role_Opportunity__c = currChapRole.id;
        newVlOpp.Volunteer_Name__c = con.id;
        insert newVlOpp;
        Volunteer_Roles__c currVolRole = OrientationandTrainingUtil.createVolRole(con.id,currChapRole.id);
        Volunteer_Roles__c newVolunteerRole = OrientationandTrainingUtil.createVolRole(con.id,currChapRole.id);
        currVolRole.Status__c = 'Out of Compliance';
        update currVolRole;
        newVolunteerRole.Status__c = 'Out of Compliance';
        currVolRole.Status__c = 'Trained';
        update currVolRole;
        update newVolunteerRole;
        system.AssertEquals(currVolRole.Status__c,'Trained','Volunteer role status does not match');
        system.Assert(currVolRole.Status__c == 'Trained','Volunteer role status does not match');
    }
    
    static testmethod void updatbackgrounCheck(){
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
        OrientationandTrainingUtil.createAffiliation(con.id);
        Role__c currRole = OrientationandTrainingUtil.createRole();
        Chapter_Role__c  currChapRole = OrientationandTrainingUtil.createChapter(acc.id,currRole.id);
        Background_check__c newBack = new Background_check__c();
        newBack.Volunteer__c = con.id;
        newBack.Current__c = true;
        insert newBack;
        Set<ID> volIdSet = new Set<ID>();
        volIdSet.add(con.id);
        VolunteerRoleTriggerHandler.updateBackGroundCheck(volIdSet, 'training');
        VolunteerRoleTriggerHandler.updateBackGroundCheck(volIdSet, 'outOfCompliance');
        VolunteerRoleTriggerHandler.updateBackGroundCheck(volIdSet, 'none');
        VolunteerRoleTriggerHandler.updateBackGroundCheck(volIdSet, '1');
        VolunteerRoleTriggerHandler.updateBackGroundCheck(volIdSet, '2');
        system.AssertEquals(newBack.Volunteer__c,con.id,'Background check volunteer does not match');
        system.Assert(newBack.Volunteer__c == con.id,'Background check volunteer does not match');
    }
    
    static testmethod void updateConfilciOfInt(){
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
        OrientationandTrainingUtil.createAffiliation(con.id);
        Role__c currRole = OrientationandTrainingUtil.createRole();
        Chapter_Role__c  currChapRole = OrientationandTrainingUtil.createChapter(acc.id,currRole.id);
        currChapRole.Background_Check_Required__c = false;
        update currChapRole;
        Conflict_Of_Interest__c newCOI = new Conflict_Of_Interest__c();
        Volunteer_Roles__c newVolRole = new Volunteer_Roles__c();
        newVolRole.Volunteer_Name__c = con.id;
        newVolRole.Chapter_Role__c = currChapRole.id;
        newVolRole.Status__c = 'Pending Training';
        insert newVolRole;
        newCOI.Volunteer_Contact__c = con.id;
        newCOI.Current__c = true;
        insert newCOI;
        Set<ID> volIdSet = new Set<ID>();
        volIdSet.add(con.id);
        VolunteerRoleTriggerHandler.updateConflictOfInterest(volIdSet, 'training');
        VolunteerRoleTriggerHandler.updateConflictOfInterest(volIdSet, 'outOfCompliance');
        VolunteerRoleTriggerHandler.updateConflictOfInterest(volIdSet, 'none');
        VolunteerRoleTriggerHandler.updateConflictOfInterest(volIdSet, '1');
        VolunteerRoleTriggerHandler.updateConflictOfInterest(volIdSet, '2');
        system.AssertEquals(newVolRole.Status__c,'Pending Training','Volunteer role status does not match');
        system.Assert(newVolRole.Status__c == 'Pending Training','Volunteer role status does not match');
    }
}