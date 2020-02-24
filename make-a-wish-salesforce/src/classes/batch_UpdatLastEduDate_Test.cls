@isTest(seeAllData=False)
public class batch_UpdatLastEduDate_Test {
	public static testMethod void createVolunteerTraing() {
		Account chapterAccount = orientationandTrainingUtil.CreateAlabamaAccount();
		insert chapterAccount;

		Role__c role = orientationandTrainingUtil.createRole();
		insert role;

		Contact volumnteerContact = orientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
		insert volumnteerContact;

		Chapter_Role__c chapterRole = orientationandTrainingUtil.createChapter(chapterAccount.Id, role.id);
		insert chapterRole;

		Volunteer_Roles__c volunteerRole = orientationandTrainingUtil.createVolRole(volumnteerContact.Id, chapterRole.Id);
		insert volunteerRole;

		Orientation_Training__c orientationT = orientationandTrainingUtil.CreateVolunteerOrientationRecord();
		insert orientationT;

		Chapter_Role_O_T__c chatpterROT = orientationandTrainingUtil.createChapterOandT(chapterRole.Id, orientationT.Id);
		insert chatpterROT;

		Class_Offering__c classOfferinf = orientationandTrainingUtil.createClassOffering(chatpterROT.Id);
		insert classOfferinf;

		Volunteer_Orientation_Training__c createNewTraining = orientationandTrainingUtil.createVolTraining(orientationT.Id, classOfferinf.Id, volumnteerContact.Id, 'completed');
		createNewTraining.Migrated_Record__c = True;
		Volunteer_Orientation_Training__c createNewTraining2 = orientationandTrainingUtil.createVolTraining(orientationT.Id, classOfferinf.Id, volumnteerContact.Id, 'completed');
		createNewTraining2.Migrated_Record__c = True;
		insert new List<Volunteer_Orientation_Training__c>{
				createNewTraining, createNewTraining2
		};

		Test.startTest();
		DataBase.executeBatch(new batch_UpdatLastEduDate());
		Test.stopTest();
	}

	public static testMethod void createVolunteerOpportunity() {
		Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
		insert chapterAccount;

		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		Contact VolunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.id);
		volunteerContact.migrated_record__c = True;
		volunteerContact.Date_of_last_engagement__c = Date.Today().addDays(-10);
		insert new List<Contact>{
				wishChild, volunteerContact
		};

		Case parentCase = OrientationandTrainingUtil.ParentCasetoAddCaseMember(wishChild.Id);
		insert parentCase;

		Role__c roleName = OrientationandTrainingUtil.createRole();
		insert roleName;

		Chapter_Role__c chapterRole = OrientationandTrainingUtil.createChapter(chapterAccount.Id, roleName.id);
		insert chapterRole;

		List<Volunteer_Opportunity__c> wishVolunteerOpportunityList = OrientationandTrainingUtil.NewWishVolunteerOpportunityList(chapterAccount.id, chapterRole.id, parentCase.id, 1);
		insert wishVolunteerOpportunityList;

		Volunteer_Opportunity__c updateREc = new Volunteer_Opportunity__c();
		updateRec.id = wishVolunteerOpportunityList[0].id;
		updateRec.migrated_record__c = True;
		updateRec.volunteer_Name__c = volunteerContact.id;
		update updateRec;

		Test.startTest();
		DataBase.executeBatch(new batch_UpdatLastEduDateforVO());
		Test.stopTest();
	}
}