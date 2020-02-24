@isTest
public class BroadcastTrigger_Test {
	//Used to create a user with Arizona Chapter Role.
	@testSetup
	private static void createUser() {
		trac_TriggerHandlerBase.blockTrigger = true;
		User arizonaUser = OrientationandTrainingUtil.createUserWithRole([
				select Id
				from UserRole
				where Name = 'Arizona - Chapter'
		].Id);
		insert arizonaUser;
		trac_TriggerHandlerBase.blockTrigger = false;
	}

	//Used to Create a broadcast record with Alabama chapter.
	static testmethod void createBroadCastOtherChapter() {
		Broadcast__c newBroad = new Broadcast__c();
		newBroad.Broadcast_Message__c = 'Test';
		Account account = OrientationandTrainingUtil.createchapterAccount();
		insert account;
		newBroad.Chapter_Name__c = account.Id;
		Chapter_Vs_Role__c newCR = new Chapter_Vs_Role__c();
		newCR.Chapter_Name__c = 'Make-A-Wish Arizona';
		newCR.Role_Name__c = 'Arizona - Chapter';
		newCR.Name = 'Make-A-Wish Arizona';
		Insert newCR;
		Chapter_Vs_Role__c alabamaCR = new Chapter_Vs_Role__c();
		alabamaCR.Chapter_Name__c = 'Make-A-Wish Alabama';
		alabamaCR.Role_Name__c = 'Alabama - Chapter';
		alabamaCR.Name = 'Make-A-Wish Alabama';
		Insert alabamaCR;
		User arizonaUser = [
				SELECT Id
				FROM USER
				WHERE UserRole.Name = 'Arizona - Chapter' AND isActive = true
				LIMIT 1
		];
		System.runAs(arizonaUser) {
			try {
				Insert newBroad;
			} catch (Exception ex) {
				// System.assert(ex.getmessage().contains('You have no access to create broadcast records for other chapters'));
			}
		}
	}

	//Used to Update a broadcast record with Alabama chapter.
	static testmethod void updateBroadCastOtherChapter() {
		Broadcast__c newBroad = new Broadcast__c();
		newBroad.Broadcast_Message__c = 'Test';
		Account account = OrientationandTrainingUtil.CreateAmericaAccount();
		insert account;
		newBroad.Chapter_Name__c = account.Id;
		Insert newBroad;
		Account account2 = OrientationandTrainingUtil.CreateAlabamaAccount();
		newBroad.Chapter_Name__c = account2.Id;
		Chapter_Vs_Role__c newCR = new Chapter_Vs_Role__c();
		newCR.Chapter_Name__c = 'Make-A-Wish Arizona';
		newCR.Role_Name__c = 'Arizona - Chapter';
		newCR.Name = 'Make-A-Wish Arizona';
		Insert newCR;
		Chapter_Vs_Role__c alabamaCR = new Chapter_Vs_Role__c();
		alabamaCR.Chapter_Name__c = 'Make-A-Wish Alabama';
		alabamaCR.Role_Name__c = 'Alabama - Chapter';
		alabamaCR.Name = 'Make-A-Wish Alabama';
		Insert alabamaCR;
		User arizonaUser = [
				SELECT Id
				FROM USER
				WHERE UserRole.Name = 'Arizona - Chapter' AND isActive = true
				LIMIT 1
		];
		arizonaUser.UserRoleId = [
				select Id
				from UserRole
				where Name = 'National Staff'
		].Id;
		System.runAs(new User(Id = UserInfo.getUserId())) {
			Update arizonaUser;
		}
		newBroad.OwnerId = arizonaUser.Id;
		System.runAs(arizonaUser) {
			try {
				Update newBroad;
			} catch (Exception ex) {
				// System.assert(ex.getmessage().contains('You have no access to create broadcast records for other chapters'));
			}
		}
	}

	//Update a user role as the National staff.
	static testmethod void updateUser() {
		User nationalStaff = [
				SELECT Id,UserRole.Name
				FROM USER
				WHERE UserRole.Name = 'Arizona - Chapter' AND isActive = true
				LIMIT 1
		];
		nationalStaff.UserRoleId = [
				select Id
				from UserRole
				where Name = 'National Staff'
		].Id;
		Update nationalStaff;
		system.assertEquals([
				SELECT UserRole.Name
				FROM User
				WHERE Id = :nationalStaff.Id
		].UserRole.Name, 'National Staff');
	}

	//Used to create a broadcast record with owner as a National staff role.
	static testmethod void createBroadCastNationalstaff() {
		Chapter_Vs_Role__c arizonaChap = OrientationandTrainingUtil.createArizonaChapter();
		Chapter_Vs_Role__c alabamaChap = OrientationandTrainingUtil.createAlabamaChapter();
		Insert alabamaChap;
		Insert arizonaChap;
		Broadcast__c newBroad = new Broadcast__c();
		newBroad.Broadcast_Message__c = 'Test';
		Account account = OrientationandTrainingUtil.createchapterAccount();
		insert account;
		newBroad.Chapter_Name__c = account.Id;
		User currUser = [
				SELECT id
				from User
				where id = :Userinfo.getUserId()
				limit 1
		];
		User nationalStaff;
		System.RunAs(currUser) {
			nationalStaff = [
					SELECT Id,UserRole.Name
					FROM USER
					WHERE UserRole.Name = 'Arizona - Chapter' AND isActive = true
					LIMIT 1
			];
			nationalStaff.UserRoleId = [
					select Id
					from UserRole
					where Name = 'National Staff'
			].Id;
			Update nationalStaff;
		}
//		System.runAs(nationalStaff) {
			newBroad.OwnerId = nationalStaff.id;
			Insert newBroad;
			system.assertEquals('National Staff', [
					SELECT Owner.UserRole.Name
					FROM Broadcast__c
					WHERE Id = :newBroad.Id
			].Owner.UserRole.Name);
//		}
	}

	//Used to create a broadcast record with owner as a National staff role.
	static testmethod void updateAsArizonaUser() {
		Chapter_Vs_Role__c arizonaChap = OrientationandTrainingUtil.createArizonaChapter();
		Chapter_Vs_Role__c alabamaChap = OrientationandTrainingUtil.createAlabamaChapter();
		Insert alabamaChap;
		Insert arizonaChap;
		Broadcast__c newBroad = new Broadcast__c();
		newBroad.Broadcast_Message__c = 'Test';
		User currUser = [
				SELECT id
				from User
				where id = :Userinfo.getUserId()
				limit 1
		];
		User notNationalStaff;
		System.RunAs(currUser) {
			notNationalStaff = [
					SELECT Id,UserRole.Name
					FROM USER
					WHERE UserRole.Name = 'Arizona - Chapter' AND isActive = true
					LIMIT 1
			];
			notNationalStaff.UserRoleId = [
					select Id
					from UserRole
					where Name = 'Arizona - Chapter'
			].Id;
			Update notNationalStaff;
		}
		//  System.runAs(notNationalStaff) {
		newBroad.OwnerId = notNationalStaff.id;
		Insert newBroad;
		Account account = OrientationandTrainingUtil.createchapterAccount();
		insert account;
		newBroad.Chapter_Name__c = account.Id;
		update newBroad;
		system.assertEquals('Arizona - Chapter', [
				SELECT Owner.UserRole.Name
				FROM Broadcast__c
				WHERE Id = :newBroad.Id
		].Owner.UserRole.Name);
		//currRec.Owner.UserRole.Name == 'National Staff'
		//    }
	}
}