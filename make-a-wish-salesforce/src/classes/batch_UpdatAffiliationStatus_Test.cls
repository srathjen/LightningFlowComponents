/***************************************************************************************************************************
Modification Log 
1. wvc-2205 Kanagaraj A - 08/08/2018  //line 29 previously the affiliation status was "Prospective".
Now we have updated as "Pending"
***************************************************************************************************************/
@isTest(seeAllData=False)
public class batch_UpdatAffiliationStatus_Test{
    //Used to create volunteer account, contact and affilation with status active for volunteer user.
    static testmethod void affiliationUpdateWithActive(){
        String CRON_EXP = '0 0 1 * * ? *';
        Account volunteerAccount = OrientationandTrainingUtil.createVolunteerAccount();
        insert volunteerAccount;
        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.id);
        insert volunteerContact;
        volunteerContact.Migrated_Record__c = True;
        update volunteerContact;
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        Role__c currRole = OrientationandTrainingUtil.createRole();
        Chapter_Role__c  currChapRole = OrientationandTrainingUtil.createChapter(acc.id,currRole.id);
        List<Volunteer_Roles__c> volRoleList = new List<Volunteer_Roles__c>();
        Volunteer_Roles__c newVOlROle = OrientationandTrainingUtil.createVolRole(volunteerContact.id,currChapRole.id);
        Volunteer_Roles__c newVOlROle1 = OrientationandTrainingUtil.createVolRole(volunteerContact.id,currChapRole.id);
        // newVOlROle1.Status__c = 'Trained';
        // update newVOlROle1;
        volRoleList.add(newVOlROle);
        volRoleList.add(newVOlROle1);
        Group alabamaGroup = new Group();
        alabamaGroup.Name = 'Make-A-Wish Alabama';
        alabamaGroup.DeveloperName = 'ABC';
        insert alabamaGroup;
        
        Background_check__c createBackCheck = OrientationandTrainingUtil.createBackgroundCheckFasleRec(volunteerContact.id);
        Conflict_Of_Interest__c createCOI = OrientationandTrainingUtil.createCOI(volunteerContact.id);
        
        npe5__Affiliation__c neworgAffiliation = new npe5__Affiliation__c ();
        neworgAffiliation.npe5__Contact__c  = volunteerContact.id;
        neworgAffiliation.npe5__Organization__c = TestClassUtil.createVolunteerAccount().Id;
        neworgAffiliation.npe5__Primary__c = true;
        neworgAffiliation.npe5__Status__c = 'Pending';
        neworgAffiliation.Constituent_code__c = Constant_AC.VOLUNTEER_TASK_RT_LABEL;
        neworgAffiliation.Hidden_Status_Updated__c = false;
        //newOrgAffiliation.Migrated_Record__c = True;
        insert neworgAffiliation;
        Test.startTest();
        Database.executeBatch(new batch_UpdatAffiliationStatus());
        Test.stopTest();       
    }
}