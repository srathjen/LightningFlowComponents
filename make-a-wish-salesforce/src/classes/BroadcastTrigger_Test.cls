@IsTest
public class BroadcastTrigger_Test {

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
		System.runAs(Utils.currentUser) {
			Profile profile = [
					SELECT Id,Name
					FROM Profile
					WHERE Name = :profileName
					LIMIT 1
			];
			User u = users.get(0);
			u.ProfileId = profile.Id;
			u.PortalRole = portalRole;
			u.UserRoleId = userRoleId;
			insert users;
		}

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void createBroadcast() {
		User nationalStaff = [
				SELECT Id, UserRole.Name, AccountId
				FROM User
				WHERE Email = 'testuser0@testorg.com'
				LIMIT 1
		];

		List<Broadcast__c> broadcasts = TestDataFactory.createBroadcast(1);
		Broadcast__c broadcast = broadcasts.get(0);
		broadcast.Chapter_Name__c = nationalStaff.AccountId;
		broadcast.OwnerId = nationalStaff.Id;
		insert broadcasts;
	}

	@IsTest
	public static void updateBroadcast() {
		User nationalStaff = [
				SELECT Id, UserRole.Name, AccountId
				FROM User
				WHERE Email = 'testuser0@testorg.com'
				LIMIT 1
		];

		List<Broadcast__c> broadcasts = TestDataFactory.createBroadcast(1);
		Broadcast__c broadcast = broadcasts.get(0);
		broadcast.Chapter_Name__c = nationalStaff.AccountId;
		broadcast.OwnerId = Utils.currentUser.Id;
		insert broadcasts;

		broadcast.OwnerId = nationalStaff.Id;
		update broadcast;
	}
}