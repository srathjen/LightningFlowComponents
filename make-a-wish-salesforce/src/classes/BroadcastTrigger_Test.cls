@IsTest
public class BroadcastTrigger_Test {

	@TestSetup
	private static void createUser() {
		trac_TriggerHandlerBase.blockTrigger = true;
		User arizonaUser = OrientationandTrainingUtil.createUserWithRole([
				SELECT Id
				FROM UserRole
				WHERE Name = 'Arizona - Chapter'
		].Id);
		insert arizonaUser;
		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void createBroadCastOtherChapter() {
		Broadcast__c newBroad = new Broadcast__c();
		newBroad.Broadcast_Message__c = 'Test';
		Account account = OrientationandTrainingUtil.createchapterAccount();
		insert account;
		newBroad.Chapter_Name__c = account.Id;
		Chapter_Vs_Role__c newCR = new Chapter_Vs_Role__c();
		newCR.Chapter_Name__c = 'Make-A-Wish Arizona';
		newCR.Role_Name__c = 'Arizona - Chapter';
		newCR.Name = 'Make-A-Wish Arizona';
		insert newCR;
		Chapter_Vs_Role__c alabamaCR = new Chapter_Vs_Role__c();
		alabamaCR.Chapter_Name__c = 'Make-A-Wish Alabama';
		alabamaCR.Role_Name__c = 'Alabama - Chapter';
		alabamaCR.Name = 'Make-A-Wish Alabama';
		insert alabamaCR;
		User arizonaUser = [
				SELECT Id
				FROM User
				WHERE UserRole.Name = 'Arizona - Chapter' AND IsActive = TRUE
				LIMIT 1
		];
		System.runAs(arizonaUser) {
			try {
				insert newBroad;
			} catch (Exception ex) {
			}
		}
	}

	@IsTest
	public static void updateBroadCastOtherChapter() {
		Broadcast__c newBroad = new Broadcast__c();
		newBroad.Broadcast_Message__c = 'Test';
		Account account = OrientationandTrainingUtil.CreateAmericaAccount();
		insert account;
		newBroad.Chapter_Name__c = account.Id;
		insert newBroad;
		Account account2 = OrientationandTrainingUtil.CreateAlabamaAccount();
		newBroad.Chapter_Name__c = account2.Id;
		Chapter_Vs_Role__c newCR = new Chapter_Vs_Role__c();
		newCR.Chapter_Name__c = 'Make-A-Wish Arizona';
		newCR.Role_Name__c = 'Arizona - Chapter';
		newCR.Name = 'Make-A-Wish Arizona';
		insert newCR;
		Chapter_Vs_Role__c alabamaCR = new Chapter_Vs_Role__c();
		alabamaCR.Chapter_Name__c = 'Make-A-Wish Alabama';
		alabamaCR.Role_Name__c = 'Alabama - Chapter';
		alabamaCR.Name = 'Make-A-Wish Alabama';
		insert alabamaCR;
		User arizonaUser = [
				SELECT Id
				FROM User
				WHERE UserRole.Name = 'Arizona - Chapter' AND IsActive = TRUE
				LIMIT 1
		];
		arizonaUser.UserRoleId = [
				SELECT Id
				FROM UserRole
				WHERE Name = 'National Staff'
		].Id;
		System.runAs(new User(Id = UserInfo.getUserId())) {
			update arizonaUser;
		}
		newBroad.OwnerId = arizonaUser.Id;
		System.runAs(arizonaUser) {
			try {
				update newBroad;
			} catch (Exception ex) {
				// System.assert(ex.getmessage().contains('You have no access to create broadcast records for other chapters'));
			}
		}
	}

	@IsTest
	public static void updateUser() {
		User nationalStaff = [
				SELECT Id,UserRole.Name
				FROM User
				WHERE UserRole.Name = 'Arizona - Chapter' AND IsActive = TRUE
				LIMIT 1
		];
		nationalStaff.UserRoleId = [
				SELECT Id
				FROM UserRole
				WHERE Name = 'National Staff'
		].Id;
		update nationalStaff;
		System.assertEquals([
				SELECT UserRole.Name
				FROM User
				WHERE Id = :nationalStaff.Id
		].UserRole.Name, 'National Staff');
	}

	@IsTest
	public static void createBroadCastNationalstaff() {
		Chapter_Vs_Role__c arizonaChap = OrientationandTrainingUtil.createArizonaChapter();
		Chapter_Vs_Role__c alabamaChap = OrientationandTrainingUtil.createAlabamaChapter();
		insert alabamaChap;
		insert arizonaChap;
		Broadcast__c newBroad = new Broadcast__c();
		newBroad.Broadcast_Message__c = 'Test';
		Account account = OrientationandTrainingUtil.createchapterAccount();
		insert account;
		newBroad.Chapter_Name__c = account.Id;
		User currUser = [
				SELECT Id
				FROM User
				WHERE Id = :UserInfo.getUserId()
				LIMIT 1
		];
		User nationalStaff;
		System.runAs(currUser) {
			nationalStaff = [
					SELECT Id,UserRole.Name
					FROM User
					WHERE UserRole.Name = 'Arizona - Chapter' AND IsActive = TRUE
					LIMIT 1
			];
			nationalStaff.UserRoleId = [
					SELECT Id
					FROM UserRole
					WHERE Name = 'National Staff'
			].Id;
			update nationalStaff;
		}
		newBroad.OwnerId = nationalStaff.Id;
		insert newBroad;
		System.assertEquals('National Staff', [
				SELECT Owner.UserRole.Name
				FROM Broadcast__c
				WHERE Id = :newBroad.Id
		].Owner.UserRole.Name);
	}

	@IsTest
	public static void updateAsArizonaUser() {
		Chapter_Vs_Role__c arizonaChap = OrientationandTrainingUtil.createArizonaChapter();
		Chapter_Vs_Role__c alabamaChap = OrientationandTrainingUtil.createAlabamaChapter();
		insert alabamaChap;
		insert arizonaChap;
		Broadcast__c newBroad = new Broadcast__c();
		newBroad.Broadcast_Message__c = 'Test';
		User currUser = [
				SELECT Id
				FROM User
				WHERE Id = :UserInfo.getUserId()
				LIMIT 1
		];
		User notNationalStaff;
		System.runAs(currUser) {
			notNationalStaff = [
					SELECT Id,UserRole.Name
					FROM User
					WHERE UserRole.Name = 'Arizona - Chapter' AND IsActive = TRUE
					LIMIT 1
			];
			notNationalStaff.UserRoleId = [
					SELECT Id
					FROM UserRole
					WHERE Name = 'Arizona - Chapter'
			].Id;
			update notNationalStaff;
		}
		newBroad.OwnerId = notNationalStaff.Id;
		insert newBroad;
		Account account = OrientationandTrainingUtil.createchapterAccount();
		insert account;
		newBroad.Chapter_Name__c = account.Id;
		update newBroad;
		System.assertEquals('Arizona - Chapter', [
				SELECT Owner.UserRole.Name
				FROM Broadcast__c
				WHERE Id = :newBroad.Id
		].Owner.UserRole.Name);
	}
}