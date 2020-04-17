@IsTest
public class ClassOffering_AT_Test {

    @IsTest
	public static void createClassOffering() {
		Class_Offering__c currOffering = new Class_Offering__c();
		currOffering.Date__c = Date.today() + 3;
		currOffering.Start_Time__c = '9:30 AM';
		currOffering.End_Time__c = '9:00 AM';
		Database.SaveResult result = Database.insert(currOffering, false);
	}

    @IsTest
	public static void createClassOfferingSameTime() {
		Class_Offering__c currOffering = new Class_Offering__c();
		currOffering.Date__c = Date.today() + 3;
		currOffering.Start_Time__c = '7:00 PM';
		currOffering.End_Time__c = '10:00 AM';
		Database.insert(currOffering, false);
	}

    @IsTest
	public static void startTimeBlank() {
		Class_Offering__c currOffering = new Class_Offering__c();
		currOffering.Date__c = Date.today() + 3;
		currOffering.End_Time__c = '10:00 AM';
		Database.SaveResult result = Database.insert(currOffering, false);
		System.assertEquals('Please enter a valid Start Time', result.getErrors()[0].getMessage());
	}

    @IsTest
	public static void createClassOfferingNationalStaffasOwner() {
		Chapter_Vs_Role__c arizonaChap = OrientationandTrainingUtil.createArizonaChapter();
		Chapter_Vs_Role__c alabamaChap = OrientationandTrainingUtil.createAlabamaChapter();
		insert alabamaChap;
		insert arizonaChap;
		User currUser = Utils.currentUser;
		User nationalStaff;
		System.runAs(currUser) {
			nationalStaff = OrientationandTrainingUtil.createUserWithRole([
					SELECT Id
					FROM UserRole
                    WHERE Name = 'National Staff'
			].Id);
			insert nationalStaff;
		}
		System.runAs(nationalStaff) {
			Chapter_Role__c newChapterRole = OrientationandTrainingUtil.createChapter(OrientationandTrainingUtil.createchapterAccount().Id, OrientationandTrainingUtil.createRole().Id);
			insert newChapterRole;
			Chapter_Role_O_T__c newChapterOT = OrientationandTrainingUtil.createChapterOandT(newChapterRole.Id, OrientationandTrainingUtil.CreateVolunteerOrientationRecord().Id);
			insert newChapterOT;
			Class_Offering__c newClassOff = OrientationandTrainingUtil.createClassOffering(newChapterOT.Id);
			insert newClassOff;
		}
	}
}