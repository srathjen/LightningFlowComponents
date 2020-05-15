/**
 * @description Modification Log
 * 1. wvc-2205 Kanagaraj A - 08/08/2018  //line 14 previously the affiliation status was "Prospective".
 * Now we have updated as "Pending"
 **/
@IsTest
public class batch_CheckBGCheckExpiration_AC_Test {

    private final static String SCHEDULE = '0 0 13 * * ?';

    //Check background check expiration
    @IsTest
    static void bgExpired() {
        trac_TriggerHandlerBase.blockTrigger = true;
        Account volunteerAccount = TestDataFactory.createChapterAccount(1)[0];
        insert volunteerAccount;

        Contact volunteerContact = TestDataFactory.createContact(1)[0];
        volunteerContact.AccountId = volunteerAccount.Id;
        volunteerContact.RecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
        insert volunteerContact;

        Background_check__c backgroundCheck = TestDataFactory.createBackgroundCheck(1)[0];
        backgroundCheck.Current__c = true;
        backgroundCheck.Date__c = Date.today() - 1;
        backgroundCheck.Volunteer__c = volunteerContact.Id;
        backgroundCheck.Date_Completed__c = Date.today();
        backgroundCheck.Status__c = Constant_AC.BACKGROUND_CHECK_STATUS_MANUAL;
        insert backgroundCheck;

        trac_TriggerHandlerBase.blockTrigger = false;
        Test.startTest();
        System.schedule('VolOpp Out of Comp on Bc Expiration', SCHEDULE, new batch_CheckBackGroundCheckExpiration_AC());
        Test.stopTest();
    }
}