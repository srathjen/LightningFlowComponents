/**
 * @description : This class is used to cover unit test for batch_BGCExpReminder_AC.
 * 1. wvc-2205 Kanagaraj A - 08/08/2018  //line 16 previously the affiliation status was "Prospective".
 * Now we have updated as "Pending"
 *
 * @author : MST Solutions
@createdDate : 11/13/2017
 **/
@IsTest
public class batch_BGCExpReminder_AC_Test {

    //Background check not initated by volunteer
    @IsTest
    static void testBatchAndSchedule() {
        trac_TriggerHandlerBase.blockTrigger = true;
        Account volunteerAccount = TestDataFactory.createChapterAccount(1)[0];
        insert volunteerAccount;

        List<Contact> volunteerContacts = TestDataFactory.createContact(2);
        volunteerContacts[0].AccountId = volunteerContacts[1].AccountId = volunteerAccount.Id;
        volunteerContacts[0].RecordTypeId = volunteerContacts[1].RecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
        insert volunteerContacts;

        List<Background_check__c> backgroundChecks = TestDataFactory.createBackgroundCheck(3);
        backgroundChecks[0].Volunteer__c = backgroundChecks[1].Volunteer__c = volunteerContacts[0].Id;
        backgroundChecks[2].Volunteer__c = volunteerContacts[1].Id;
        backgroundChecks[0].Current__c = backgroundChecks[1].Current__c = backgroundChecks[2].Current__c = true;
        backgroundChecks[0].Status__c = backgroundChecks[2].Status__c = Constant_AC.BACKGROUND_CHECK_STATUS_APPROVED;
        backgroundChecks[0].Date__c = backgroundChecks[0].Date_Completed__c =
                backgroundChecks[2].Date__c = backgroundChecks[2].Date_Completed__c = Date.today().addDays(2);
        insert backgroundChecks;

        Conflict_Of_Interest__c createCOI = TestDataFactory.createConflictOfInterest(1)[0];
        createCOI.Volunteer_Contact__c = volunteerContacts[0].Id;
        createCOI.Expiration_Date__c = System.today() + 3;
        insert createCOI;
        trac_TriggerHandlerBase.blockTrigger = false;

        Test.startTest();
        String sch = '0 0 13 * * ?';
        System.schedule('Backgroundcheck Expiration Notification', sch, new batch_BGCExpReminder_AC());
        Test.stopTest();
    }
}