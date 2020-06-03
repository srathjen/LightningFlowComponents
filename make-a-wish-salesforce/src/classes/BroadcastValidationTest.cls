@IsTest
public class BroadcastValidationTest {

	@TestSetup
	public static void setUp() {
		trac_TriggerHandlerBase.blockTrigger = true;

		List<Account> accounts = TestDataFactory.createAccount(1);
		Account account1 = accounts.get(0);
		account1.Name = 'Make-A-Wish Arizona';
		account1.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
		insert accounts;

		String profileName = 'Full Access National Staff';
		String portalRole = 'Manager';
		Id userRoleId = [
				SELECT Id
				FROM UserRole
				WHERE Name = 'National Staff'
		].Id;

		List<User> users = TestDataFactory.createUser(1);
		User nationalStaffUser = users.get(0);
		System.runAs(Utils.currentUser) {
			Profile profile = [
					SELECT Id,Name
					FROM Profile
					WHERE Name = :profileName
					LIMIT 1
			];
			nationalStaffUser.ProfileId = profile.Id;
			nationalStaffUser.PortalRole = portalRole;
			nationalStaffUser.UserRoleId = userRoleId;
			insert users;
		}

		Chapter_Vs_Role__c createRec = new Chapter_Vs_Role__c();
		createRec.Chapter_Name__c = 'Make-A-Wish Arizona';
		createRec.Role_Name__c = 'Arizona - Chapter';
		createRec.Name = 'Make-A-Wish Arizona';
		insert createRec;

		List<Broadcast__c> broadcasts = TestDataFactory.createBroadcast(1);
		Broadcast__c broadcast = broadcasts.get(0);
		broadcast.Chapter_Name__c = nationalStaffUser.AccountId;
		broadcast.OwnerId = nationalStaffUser.Id;
		insert broadcasts;

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void shouldValidatePermission() {
		Account account = [
				SELECT Id, Chapter_Name__c
				FROM Account
				LIMIT 1
		];
		List<Broadcast__c> broadcasts = [
				SELECT Id, Chapter_Name__c
				FROM Broadcast__c
		];

		Test.startTest();
		BroadcastValidation.validatePermission(new Set<Id>{account.Id}, broadcasts);
		Test.stopTest();
	}
}