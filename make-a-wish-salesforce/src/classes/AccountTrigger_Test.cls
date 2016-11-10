@isTest
public class AccountTrigger_Test {
    static testmethod void inKindDonor() {
        User systemAdmin = OrientationandTrainingUtil.createrSystemAdminUser();
        Account chapterAccount = OrientationandTrainingUtil.createVolunteerAccountWithWishCoordinatior(systemAdmin.Id);
        Contact volunteerContact = OrientationandTrainingUtil.createVolunteerContact(chapterAccount.Id);
        User volunteerUser = OrientationandTrainingUtil.CreateActiveVolunteerUser(volunteerContact.Id);
        
        System.RunAs(volunteerUser) {
            test.startTest();
            Account inkindAccount = OrientationandTrainingUtil.inKindAccount();
            //inkindAccount.Wish_Co_ordinator__c = systemAdmin.Id;
            //update inkindAccount;
			test.stopTest();
        }
    }
}