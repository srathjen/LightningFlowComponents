/**
 * @description Account Service Test
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 2/27/2020
 */
@IsTest
public class AccountTriggerTest {

	@IsTest
	public static void createUpdate() {
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

		List<Account> accounts = TestDataFactory.createAccount(3);
		Account account1 = accounts.get(0);
		account1.Name = 'Make-A-Wish Arizona';
		account1.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
        account1.OwnerId = nationalStaffUser.Id;

        Account account2 = accounts.get(1);
		account2.Name = 'Jack Smith & Family Account';
		account2.RecordTypeId = Constant_AC.HOUSEHOLD_RT_ID;
		account2.Emergency_Contact_Phone__c = '5208205555';
		account2.Relationship_type__c = 'Mother';
		account2.BillingCity = 'Phoenix';
		account2.BillingState = 'Arizona';
		account2.BillingPostalCode = '85016';

        Account account3 = accounts.get(2);
		account3.Name = 'Make-A-Wish Central & Northern Florida';
		account3.Wish_Co_ordinator__c = nationalStaffUser.Id;
		account3.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
		account3.OwnerId = nationalStaffUser.Id;
		insert accounts;

        List<Account> accounts2 = TestDataFactory.createAccount(1);
        Account account4 = accounts2.get(0);
        account4.Name = 'In Kind Donors Central & Northern Florida';
        account4.RecordTypeId = Constant_AC.IN_KIND_ACCOUNT_ID;
        account4.Chapter_Name__c = accounts[2].Id;
        account4.OwnerId = Utils.currentUser.Id;
        insert accounts2;

        account1.DevStaffEmail__c = 'test@email.com';

        account2.Name = 'Jack Johnson & Family Account';
        account2.Emergency_Contact_Phone__c = '1234445556';
        account2.Relationship_type__c = 'Friend';
        account2.Emergency_Contact_Middle_Name__c = 'Doe';
        account2.Email__c = 'test@email.com';
        account2.BillingStreet = '123 St';

        account4.Name = 'In Kind Donors Central & Southern Florida';
        account4.In_Kind_Approval_Status__c = 'Rejected';
        update new List<Account>{account1, account2, account4};
	}
}