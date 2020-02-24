/***************************************************************************
Author : MST Solutions
Created Date : 11/16/2017
Description : This class is used to cover unit test for batch_COIExpReminder_AC.
1. wvc-2205 Kanagaraj A - 08/08/2018  //line 17 previously the affiliation status was "Prospective".
                                        Now we have updated as "Pending"
****************************************************************************/
@isTest(seeAllData=False)
public class batch_COIExpReminder_AC_Test {

	private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;

	//COI not initiated
	static testmethod void coiExpired() {
		Account volunteerAccount = OrientationandTrainingUtil.createVolunteerAccount();
		insert volunteerAccount;

		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(volunteerAccount.id);
		insert volunteerContact;

		npe5__Affiliation__c neworgAffiliation = new npe5__Affiliation__c (npe5__Contact__c = volunteerContact.id,
				npe5__Organization__c = TestClassUtil.createVolunteerAccount().Id, npe5__Primary__c = true,
				npe5__Status__c = 'Pending', Constituent_code__c = Constant_AC.VOLUNTEER_TASK_RT_LABEL, Hidden_Status_Updated__c = false);

		Volunteer_Roles__c volunteerRole = new Volunteer_Roles__c(Status__c = VOLUNTEER_ROLE_STATUS_ACTIVE, Volunteer_Name__c = volunteerContact .id);
		System.assertEquals(volunteerRole.status__c, VOLUNTEER_ROLE_STATUS_ACTIVE);
		insert volunteerRole ;

		Background_check__c createBackCheck = OrientationandTrainingUtil.createBackgroundCheckFasleRec(volunteerContact.id);
		insert createBackCheck;
		Conflict_Of_Interest__c createCOI = OrientationandTrainingUtil.createCOI(volunteerContact.id);
		createCOI.Current__c = true;
		createCOI.Expiration_Date__c = Date.today().addDays(2);
		insert createCOI;

		Test.startTest();
		DataBase.executeBatch(new batch_COIExpReminder_AC());
		Test.stopTest();
	}

	//Used to test schedule method
	static testmethod void testschedule() {
		Test.startTest();
		batch_COIExpReminderSchedule_AC reminder = new batch_COIExpReminderSchedule_AC();
		String sch = '0 0 13 * * ?';
		//String jobID = System.schedule('COI Expiration Reminder', sch, reminder);
		reminder.execute(Null);
		List<Background_check__c> objectList = new List<Background_check__c>();
		Test.stopTest();
	}
}