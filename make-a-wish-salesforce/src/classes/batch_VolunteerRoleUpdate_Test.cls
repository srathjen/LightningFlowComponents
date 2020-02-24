@isTest
public class batch_VolunteerRoleUpdate_Test {

	static testmethod void testVolunteerRoleUpdate() {
		Account chapterAccount = OrientationandTrainingUtil.CreateAlabamaAccount();
		insert chapterAccount;
		Role__c role = OrientationandTrainingUtil.createRole();
		insert role;
		Contact volumnteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
		insert volumnteerContact;
		Chapter_Role__c chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.Id, role.id);
		insert chapterRole;
		Orientation_Training__c orientationT = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
		insert orientationT;
		Chapter_Role_O_T__c chatpterROT = OrientationandTrainingUtil.createChapterOandT(chapterRole.Id, orientationT.Id);
		insert chatpterROT;
		Class_Offering__c classOfferinf = OrientationandTrainingUtil.createClassOffering(chatpterROT.Id);
		insert classOfferinf;
		Volunteer_Roles__c vRole = OrientationandTrainingUtil.createVolRole(volumnteerContact.Id, chapterRole.Id);
		insert vRole;
		vRole.Migrated_Record__c = True;
		update vRole;
		Volunteer_Orientation_Training__c newVolunteerOreTrain = new Volunteer_Orientation_Training__c ();
		newVolunteerOreTrain.Volunteer__c = volumnteerContact.Id;
		newVolunteerOreTrain.Class_Offering__c = classOfferinf.Id;
		newVolunteerOreTrain.Volunteer_Attendance__c = 'Completed';
		Insert newVolunteerOreTrain;
		Test.StartTest();
		Database.executeBatch(new batch_VolunteerRoleUpdate(), 25);
		Test.StopTest();
	}

	static testmethod void testVolunteerRoleUpdate1() {
		Account chapterAccount = OrientationandTrainingUtil.CreateAlabamaAccount();
		insert chapterAccount;
		Role__c role = OrientationandTrainingUtil.createRole();
		insert role;
		Contact volumnteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
		insert volumnteerContact;
		Chapter_Role__c chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.Id, role.id);
		insert chapterRole;
		Orientation_Training__c orientationT = OrientationandTrainingUtil.CreateVolunteerOrientationRecord();
		insert orientationT;
		Chapter_Role_O_T__c chatpterROT = OrientationandTrainingUtil.createChapterOandT(chapterRole.Id, orientationT.Id);
		insert chatpterROT;
		Class_Offering__c classOfferinf = OrientationandTrainingUtil.createClassOffering(chatpterROT.Id);
		insert classOfferinf;
		Volunteer_Roles__c vRole = orientationandTrainingUtil.createVolRole(volumnteerContact.Id, chapterRole.Id);
		insert vRole;
		vRole.Migrated_Record__c = True;
		update vRole;
		Test.StartTest();
		Database.executeBatch(new batch_VolunteerRoleUpdate(), 25);
		Test.StopTest();
	}
}