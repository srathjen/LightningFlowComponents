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

    @IsTest
    static void inActivateCaseOwner() {
        Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
        insert chapterAccount;

		List<User> adminUsers = new List<User>();
        User sysAdmin = OrientationandTrainingUtil.createUser();
        User sysAdmin1 = OrientationandTrainingUtil.createUser();
		adminUsers.add(sysAdmin);
		adminUsers.add(sysAdmin1);
        insert adminUsers;

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
}