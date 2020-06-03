@IsTest
public class BroadcastServiceTest {

	@TestSetup
	public static void setUp() {
		trac_TriggerHandlerBase.blockTrigger = true;

		List<Account> accounts = TestDataFactory.createAccount(2);
		Account account1 = accounts.get(0);
		account1.Name = 'Make-A-Wish Arizona';
		account1.RecordTypeId = Constant_AC.CHAPTER_RT_ID;

		Account account2 = accounts.get(1);
		account2.Name = 'Make-A-Wish New York';
		account2.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
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

		List<Broadcast__c> broadcasts = TestDataFactory.createBroadcast(1);
		Broadcast__c broadcast = broadcasts.get(0);
		broadcast.Chapter_Name__c = nationalStaffUser.AccountId;
		broadcast.OwnerId = nationalStaffUser.Id;
		insert broadcasts;

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void shouldBuildChapterNames() {
		List<Broadcast__c> broadcasts = [
				SELECT Id, Chapter_Name__c
				FROM Broadcast__c
				LIMIT 1
		];

		Test.startTest();
		BroadcastService.buildChapterNames(broadcasts);
		Test.stopTest();
	}

	@IsTest
	public static void shouldBuildChapterNamesMap() {
		List<Broadcast__c> broadcasts = [
				SELECT Id, Chapter_Name__c
				FROM Broadcast__c
				LIMIT 1
		];
		Account account = [
				SELECT Id
				FROM Account
				WHERE Name = 'Make-A-Wish New York'
		];
		Broadcast__c broadcastOld = new Broadcast__c();
		broadcastOld.Id = broadcasts.get(0).Id;
		broadcastOld.Chapter_Name__c = account.Id;

		Test.startTest();
		BroadcastService.buildChapterNames(broadcasts, new Map<Id, Broadcast__c>{broadcastOld.Id => broadcastOld});
	}

	@IsTest
	public static void shouldBuildBroadcastShare() {
		List<Broadcast__c> broadcasts = [
				SELECT Id
				FROM Broadcast__c
				LIMIT 1
		];

		Test.startTest();
		BroadcastService.buildBroadcastShare(new Map<Id, Broadcast__c>(broadcasts));
		Test.stopTest();
	}

	@IsTest
	public static void shouldBuildBroadcastShareMap() {
		List<Broadcast__c> broadcasts = [
				SELECT Id
				FROM Broadcast__c
				LIMIT 1
		];
		Broadcast__c broadcastOld = new Broadcast__c();
		broadcastOld.Id = broadcasts.get(0).Id;
		broadcastOld.OwnerId = Utils.currentUser.Id;

		Test.startTest();
		BroadcastService.buildBroadcastShare(new Map<Id, Broadcast__c>(broadcasts), new Map<Id, Broadcast__c>{broadcastOld.Id => broadcastOld});
		Test.stopTest();
	}
}