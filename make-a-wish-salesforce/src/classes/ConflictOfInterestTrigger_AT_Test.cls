@isTest
public class ConflictOfInterestTrigger_AT_Test {
	// Mapping fields.
	public static testMethod void createConflictOfInterest() {
		Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
		insert chapterAccount;

		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
		insert volunteerContact;

		Conflict_Of_Interest__c coiRec = OrientationandTrainingUtil.createCOI(volunteerContact.Id);
		insert coiRec;
	}

	public static testMethod void updateConflictOfInterest() {
		Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
		insert chapterAccount;

		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
		volunteerContact.Region_Chapter__C = chapterAccount.Id;
		insert volunteerContact;

		Conflict_Of_Interest__c coiRec = OrientationandTrainingUtil.createCOI(volunteerContact.Id);
		insert coiRec;
		coiRec.Expiration_Date__c = Date.Today().addYears(1);
		update coiRec;
	}

	public static testMethod void nationalStaffConflictOfInterest() {
		Chapter_Vs_Role__c arizonaChap = OrientationandTrainingUtil.createArizonaChapter();
		Chapter_Vs_Role__c alabamaChap = OrientationandTrainingUtil.createAlabamaChapter();
		insert new List<Chapter_Vs_Role__c>{
				arizonaChap, alabamaChap
		};

		Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
		insert chapterAccount;

		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
		volunteerContact.Region_Chapter__c = chapterAccount.Id;
		insert volunteerContact;

		Role__c newR = new Role__c(Name = 'Wish Granter');
		insert newR;

		Chapter_Role__c newCR = new Chapter_Role__c(Role_Name__c = newR.Id, Chapter_Name__c = chapterAccount.Id);
		insert newCR;

		Volunteer_Roles__c newVR = new Volunteer_Roles__c(Volunteer_Name__c = volunteerContact.Id, Status__c = 'Out of Compliance', Chapter_Role__c = newCR.Id);
		insert newVR;

		Background_check__c newBg = new Background_check__c(Volunteer__c = volunteerContact.Id, Current__c = TRUE, Date__c = Date.today().addDays(-10), Date_Completed__c = Date.today().addDays(-50), Status__c = 'Completed');
		newBg.Date__c = Date.today().addDays(-11);
		insert newBg;

		User nationalStaff;
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			nationalStaff = OrientationandTrainingUtil.createUserWithRole([
					SELECT Id
					FROM UserRole
					WHERE Name = 'National Staff'
			].Id);
			insert nationalStaff;
		}

		Test.startTest();
		System.runAs(nationalStaff) {
			Conflict_Of_Interest__c newCOI1 = new Conflict_Of_Interest__c();
			newCOI1.Volunteer_Contact__c = volunteerContact.Id;
			newCOI1.Expiration_Date__c = System.today() + 3;
			newCOI1.Current__c = true;
			newCOI1.Account_Name__c = chapterAccount.Id;
			newCOI1.OwnerId = nationalStaff.Id;
			insert newCOI1;
		}
		Test.stopTest();
	}
	public static testMethod void UpdateOwnerConflictOfInterest() {
		Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccount();
		insert chapterAccount;

		Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
		volunteerContact.Region_Chapter__c = chapterAccount.Id;
		insert volunteerContact;

		Conflict_Of_Interest__c newCOI = new Conflict_Of_Interest__c();
		newCOI.Volunteer_Contact__c = volunteerContact.Id;
		newCOI.Expiration_Date__c = System.today() + 3;
		newCOI.Signed_Date__c = System.today() - 2;
		newCOI.Current__c = false;
		insert newCOI;

		User currUser = [
				SELECT id
				from User
				where id = :Userinfo.getUserId()
				limit 1
		];
		User nationalStaff;
		System.RunAs(currUser) {
			nationalStaff = OrientationandTrainingUtil.createUserWithRole([
					select Id
					from UserRole
					where Name = 'National Staff'
			].Id);
			insert nationalStaff;
		}
		System.runAs(nationalStaff) {
			newCOI.OwnerId = nationalStaff.Id;
			newCOI.Signed_Date__c = System.today();
			newCOI.HiddenConflictExpire__c = true;
			newCOI.Current__C = true;
			update newCOI;
		}
	}
}