@IsTest
public class AwardsRecognitionTrigger_Test {

	@TestSetup
	public static void setup() {
		trac_TriggerHandlerBase.blockTrigger = true;

		List<Account> accounts = TestDataFactory.createAccount(2);
		Account account1 = accounts.get(0);
		account1.Name = 'Make-A-Wish Arizona';
		account1.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
		Account account2 = accounts.get(1);
		account2.Name = 'Make-A-Wish New York';
		account2.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
		insert accounts;

		List<User> users = TestDataFactory.createVolunteerUser(1);
		insert users;

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void createAwardsRecognition() {
		Account account = [
				SELECT Id
				FROM Account
				WHERE Name = 'Make-A-Wish Arizona'
				LIMIT 1
		];

		List<Awards_Recognition__c> awardsRecognitions = TestDataFactory.createAwardsRecognitions(1);
		Awards_Recognition__c awardsRecognition = awardsRecognitions.get(0);
		awardsRecognition.Chapter_Name__c = account.Id;
		insert awardsRecognitions;
	}

	@IsTest
	public static void updateAwardsRecognition() {
		List<Account> accounts = [
				SELECT Id
				FROM Account
		];

		List<Awards_Recognition__c> awardsRecognitions = TestDataFactory.createAwardsRecognitions(1);
		Awards_Recognition__c awardsRecognition = awardsRecognitions.get(0);
		awardsRecognition.Chapter_Name__c = accounts.get(0).Id;
		insert awardsRecognitions;

		awardsRecognition.Chapter_Name__c = accounts.get(1).Id;
		update awardsRecognition;
	}
}