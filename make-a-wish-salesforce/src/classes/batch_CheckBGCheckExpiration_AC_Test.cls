@isTest(seeAllData=False)
public class batch_CheckBGCheckExpiration_AC_Test {
    
    //Check background check expiration
    static testmethod void bgExpired(){
        Account volunteerAccount = OrientationandTrainingUtil.createVolunteerAccount();
        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.id);
        npe5__Affiliation__c neworgAffiliation = new npe5__Affiliation__c (npe5__Contact__c  = volunteerContact.id,npe5__Organization__c = TestClassUtil.createVolunteerAccount().Id,npe5__Primary__c = true,
                                                                           npe5__Status__c = 'Prospective', Constituent_code__c = 'Volunteer', Hidden_Status_Updated__c = false);
        insert neworgAffiliation;
        
        Volunteer_Roles__c volunteerRole = new Volunteer_Roles__c(Status__c = 'Trained', Volunteer_Name__c = volunteerContact .id);
        System.assertEquals(volunteerRole.status__c, 'Trained');
        insert volunteerRole ;
        
        Background_check__c createBackCheck = OrientationandTrainingUtil.createBackgroundCheckFasleRec(volunteerContact.id);
        Conflict_Of_Interest__c createCOI = OrientationandTrainingUtil.createCOI(volunteerContact.id);
        createBackCheck.Current__c = true;
        createBackCheck.Date__c = Date.today() - 1;
        update createBackCheck;
        
        Test.startTest();
        DataBase.executeBatch(new batch_CheckBackGroundCheckExpiration_AC() );
        Test.stopTest();
    }
    
    //Used to test schedule method
    static testmethod void  testschedule(){
        Test.startTest();
        batch_CheckBGCheckExpirationSchedule_AC reminder = new batch_CheckBGCheckExpirationSchedule_AC();
        String sch = '0 0 13 * * ?';
        String jobID = System.schedule('VolOpp Out of Comp on Bc Expiration', sch, reminder);
        List<Background_check__c> objectList = new List<Background_check__c>(); 
        Test.stopTest();
    }
}