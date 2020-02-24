@isTest
public class ContactInfo_AC_Test {

	private static testmethod void testContactInfo() {
		Id updateContactRT = Constant_AC.UPDATE_CONTACT_RT_ID;
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;
		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		insert con;
		Task openTask = new Task(Subject = 'Test Task', activityDate = system.today(),
				whoId = con.Id, recordTypeId = updateContactRT);
		insert openTask;
		ApexPages.StandardController sc = new ApexPages.StandardController(openTask);
		ContactInfo_AC contactInfo = new ContactInfo_AC(sc);
	}
}