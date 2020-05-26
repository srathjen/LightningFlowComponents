@IsTest
public class ClassOffering_AT_Test {

	@IsTest
	public static void createClassOffering() {
		Class_Offering__c classOffering = new Class_Offering__c();
		classOffering.Date__c = Date.today() + 3;
		classOffering.Start_Time__c = '9:00 AM';
		classOffering.End_Time__c = '10:00 AM';
		insert classOffering;

		classOffering.Date__c = Date.today() + 4;
		classOffering.Start_Time__c = '10:00 AM';
		classOffering.End_Time__c = '11:00 AM';
		update classOffering;
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
	public static void validateClassOfferingStartTimeBlank() {
		Class_Offering__c currOffering = new Class_Offering__c();
		currOffering.Date__c = Date.today() + 3;
		currOffering.End_Time__c = '10:00 AM';
		Database.SaveResult result = Database.insert(currOffering, false);
		System.assertEquals('Please enter a valid Start Time', result.getErrors()[0].getMessage());
	}

	@IsTest
	public static void createClassOfferingAsNationalStaff() {
		User nationalStaff;
		System.runAs(Utils.currentUser) {
			Id roleId = [
					SELECT Id
					FROM UserRole
					WHERE Name = 'National Staff'
			].Id;

			Profile systemAdministrator = [
					SELECT Id
					FROM Profile
					WHERE Name = 'System Administrator'
			];
			nationalStaff = new User(firstname = 'JonJesu', lastName = 'EdwardsJo', email = 'jonemail@gma111il.com', Username = 'jonsamp0@gma11il.com',
					EmailEncodingKey = 'ISO-8859-1', Alias = 'jone', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
					LanguageLocaleKey = 'en_US', UserRoleId = roleId, ProfileId = systemAdministrator.Id, isActive = true, Statecode = 'AZ');
			insert nationalStaff;
		}
		System.runAs(nationalStaff) {
			Class_Offering__c classOffering = new Class_Offering__c();
			classOffering.Date__c = Date.today() + 3;
			classOffering.Start_Time__c = '9:00 AM';
			classOffering.End_Time__c = '10:00 AM';
			classOffering.OwnerId = Utils.currentUser.Id;
			insert classOffering;

			classOffering.Date__c = Date.today() + 4;
			classOffering.Start_Time__c = '10:00 AM';
			classOffering.End_Time__c = '11:00 AM';
			classOffering.OwnerId = nationalStaff.Id;
			update classOffering;
		}
	}
}