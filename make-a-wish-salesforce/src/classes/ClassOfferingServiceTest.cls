@IsTest
public class ClassOfferingServiceTest {

	@TestSetup
	public static void setup() {
		trac_TriggerHandlerBase.blockTrigger = true;
		
		String profileName = 'Full Access National Staff';
		String portalRole = 'Manager';
		Id userRoleId = [
				SELECT Id
				FROM UserRole
				WHERE Name = 'National Staff'
		].Id;

		List<User> users = TestDataFactory.createUser(1);
		User nationalUser = users.get(0);
		System.runAs(Utils.currentUser) {
			Profile profile = [
					SELECT Id,Name
					FROM Profile
					WHERE Name = :profileName
					LIMIT 1
			];
			nationalUser.ProfileId = profile.Id;
			nationalUser.PortalRole = portalRole;
			nationalUser.UserRoleId = userRoleId;
			nationalUser.LastName = 'Doe1';
			nationalUser.Alias = 'Nat';
			nationalUser.Email = 'nationaluser1@testorg.com';
			nationalUser.Username = 'nationaluser1@testorg.com';
			nationalUser.EmailEncodingKey = 'UTF-8';
			nationalUser.LastName = 'Test';
			nationalUser.LanguageLocaleKey = 'en_US';
			nationalUser.LocaleSidKey = 'en_US';
			nationalUser.TimeZoneSidKey = 'America/Los_Angeles';
			insert nationalUser;
		}

		List<Class_Offering__c> classOfferings = TestDataFactory.createClassOffering(1);
		Class_Offering__c classOffering = classOfferings.get(0);
		classOffering.Date__c = Date.today() + 3;
		classOffering.Start_Time__c = '9:00 AM';
		classOffering.End_Time__c = '10:00 AM';
		classOffering.OwnerId = nationalUser.Id;
		insert classOfferings;
		
		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void shouldBuildClassOfferingChapterMap() {
		List<Class_Offering__c> classOfferings = [
				SELECT Id
				FROM Class_Offering__c
		];

		Test.startTest();
		ClassOfferingService.buildClassOfferingChapterMap(new Map<Id, Class_Offering__c>(classOfferings));
		Test.stopTest();
	}

	@IsTest
	public static void shouldBuildClassOfferingChapterMapUpdate() {
		List<Class_Offering__c> classOfferings = [
				SELECT Id, OwnerId
				FROM Class_Offering__c
		];

		Class_Offering__c oldClassOffering = new Class_Offering__c();
		oldClassOffering.Id = classOfferings.get(0).Id;
		oldClassOffering.OwnerId = Utils.currentUser.Id;

		Test.startTest();
		ClassOfferingService.buildClassOfferingChapterMap(new Map<Id, Class_Offering__c>(classOfferings),
				new Map<Id, Class_Offering__c>{oldClassOffering.Id => oldClassOffering});
		Test.stopTest();
	}
}
