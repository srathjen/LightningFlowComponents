@IsTest
/*******************************************************************************************
Author : MST Solutions
Created Date:3/15/2018 
Description: This class is used to increase the code coverage for batch_sendAgeNotificationToCaseOwner_AC. 

**********************************************************************************************/
public class batch_sendAgeNotification_Test {
	//Set the wish Child age is 18.
	@IsTest static void wishChildAge18Birthday() {
		Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
		insert chapterAccount;
		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		wishChild.Birthdate = Date.parse(String.valueOf(System.today().month()) + '/'
				+ String.valueOf(System.today().day()) + '/'
				+ String.valueOf(System.today().year() - 18));
		insert wishChild;
		Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
		insert chapterAmericaAccount;
		Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		insert parentCase;

		Contact childFamily = OrientationandTrainingUtil.CreateWishFamily();
		childFamily.Birthdate = Date.parse(String.valueOf(System.today().month()) + '/'
				+ String.valueOf(System.today().day()) + '/'
				+ String.valueOf(System.today().year() - 18));
		insert childFamily;
		npe4__Relationship__c npcr = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.Id, childFamily.Id);
		insert npcr;
		Database.executeBatch(new batch_sendAgeNotificationToCaseOwner_AC());
	}

	// This test does not make sense, depending on the day it might break the test as it sums up dates
	//Set the wish Child age is 17 years and 11 month.
//	@IsTest static void wishChildAge18beforeoneMonthBirthday() {
//		Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
//		insert chapterAccount;
//		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
//		//Date today month has 30 days (4-apr,6-june,9-sept,11-nov)
//		if (System.today().month() + 1 == 5
//				|| System.today().month() + 1 == 7
//				|| System.today().month() + 1 == 10
//				|| System.today().month() + 1 == 12) {
//			//Take todays month + 1 / todays date / todays year-18 to set 18bday as 30 days from now.
//			wishChild.Birthdate = Date.parse(
//					String.valueOf(System.today().month() + 1) + '/'
//							+ String.valueOf(System.today().day()) + '/'
//							+ String.valueOf(System.today().year() - 18));
//		} else if (System.today().month() == 12) {
//			wishChild.Birthdate = Date.parse((System.today().month()) + '/'
//					+ System.today().day() + '/'
//					+ (System.today().year() - 18));
//		}
//		//If today date Jan29-31, Feb bday will be set as TODAY Date-3
//		else if (System.today().month() == 1 && System.today().Day() > 28) {
//			wishChild.Birthdate = Date.parse(String.valueOf(System.today().month() + 1) + '/'
//					+ String.valueOf(System.today().day() - 3) + '/'
//					+ String.valueOf(System.today().year() - 18));
//		} else {
//			wishChild.Birthdate = Date.parse((System.today().month() + 1) + '/'
//					+ System.today().day() + '/'
//					+ (System.today().year() - 18));
//		}
//		insert wishChild;
//		Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
//		insert chapterAmericaAccount;
//		Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
//		insert parentCase;
//		Contact childFamily = OrientationandTrainingUtil.CreateWishFamily();
//		//Date today month has 31 days (3-Mar,5-May,7-July,8-Aug,10-Oct)
//		if (System.today().month() + 1 == 5
//				|| System.today().month() + 1 == 7
//				|| System.today().month() + 1 == 10
//				|| System.today().month() + 1 == 12) {
//			//Take todays month + 1 / todays date / todays year-18 to set bday as 30 days from now.
//			Date.parse(String.valueOf(System.today().month() + 1) + '/'
//					+ String.valueOf(System.today().day()) + '/'
//					+ String.valueOf(System.today().year() - 18));
//		} else {
//			if (System.today().month() == 12) {
//				wishChild.Birthdate = Date.parse((System.today().month()) + '/' + System.today().day() + '/' + (System.today().year() - 18));
//				//If today is Jan29-31, FEBRUARY bday will be set as TODAY Date - 3
//			} else if (System.today().month() == 1 && System.today().day() > 28) {
//				wishChild.Birthdate = Date.parse(String.valueOf(System.today().month() + 1) + '/'
//						+ String.valueOf(System.today().day() - 3) + '/'
//						+ String.valueOf(System.today().year() - 18));
//			} else {
//				wishChild.Birthdate = Date.parse((System.today().month() + 1) + '/' + System.today().day() + '/' + (System.today().year() - 18));
//			}
//		}
//		insert childFamily;
//		npe4__Relationship__c npcr = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.Id, childFamily.Id);
//		insert npcr;
//		Database.executeBatch(new batch_sendAgeNotificationToCaseOwner_AC());
//	}

	@IsTest
	static void inActivateCaseOwner() {
		Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
		insert chapterAccount;
		User sysAdmin = OrientationandTrainingUtil.createUser();
		insert sysAdmin;
		User sysAdmin1 = OrientationandTrainingUtil.createUser();
		insert sysAdmin1;
		System.runAs(sysAdmin1) {
			Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
			insert wishChild;
			Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
			insert chapterAmericaAccount;
			Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
			parentCase.OwnerId = sysAdmin.Id;
			insert parentCase;
			Test.startTest();
			sysAdmin.IsActive = false;
			update sysAdmin;
			Test.stopTest();
			wishChild.Birthdate = Date.parse(String.valueOf(System.today().month()) + '/'
					+ String.valueOf(System.today().day()) + '/'
					+ String.valueOf(System.today().year() - 18));
			update wishChild;
			Contact childFamily = OrientationandTrainingUtil.CreateWishFamily();
			childFamily.Birthdate = Date.parse(String.valueOf(System.today().month()) + '/'
					+ String.valueOf(System.today().day()) + '/'
					+ String.valueOf(System.today().year() - 18));
			insert childFamily;
			npe4__Relationship__c npcr = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.Id, childFamily.Id);
			insert npcr;
			Database.executeBatch(new batch_sendAgeNotificationToCaseOwner_AC());
		}
	}

	//Set the wish Participant age is 18.
	/* @isTest static void  wishParticipantAge18Birthday(){
Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
Account chapterAmericaAccount = OrientationandTrainingUtil.CreateAmericaAccount();
Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
wishChild.Birthdate = Date.parse(String.valueOf(System.today().month())+'/'+String.valueOf(System.today().day())+'/'+String.valueOf(System.today().year()-18));
Update wishChild;
Database.executeBatch(new batch_sendAgeNotificationToCaseOwner_AC());
}*/
}