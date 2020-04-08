@IsTest
public class Hidden_ContactShareController_AC_Test {

    @IsTest
    public static void createFamily() {
        trac_TriggerHandlerBase.blockTrigger = true;
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        insert acc;

        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.Id);
        Contact wishChild = OrientationandTrainingUtil.createWishChild();
        Contact wishFamily = OrientationandTrainingUtil.createWishFamily();
        insert new List<Contact>{
                con, wishChild, wishFamily
        };

        User currUser = new User();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            currUser = OrientationandTrainingUtil.createActiveVolunteerUser(con.Id);
            insert currUser;
        }
        trac_TriggerHandlerBase.blockTrigger = false;

        Test.startTest();
        npe4__Relationship__c relationShip = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.Id, wishFamily.Id);
        npe4__Relationship__c relationShip2 = OrientationandTrainingUtil.CreateRelationshipRec(wishFamily.Id, wishChild.Id);
        insert new List<npe4__Relationship__c>{
                relationShip, relationShip2
        };
        Test.stopTest();

        ContactShare shareContact = new ContactShare();
        shareContact.ContactAccessLevel = Constant_AC.RECORD_SHARE_READ;
        shareContact.ContactId = wishChild.Id;
        shareContact.UserOrGroupId = currUser.Id;
        ContactShare shareContact2 = new ContactShare();
        shareContact2.ContactAccessLevel = Constant_AC.RECORD_SHARE_READ;
        shareContact2.ContactId = wishFamily.Id;
        shareContact2.UserOrGroupId = currUser.Id;
        insert new List<ContactShare>{
                shareContact, shareContact2
        };

        System.runAs(currUser) {
            Test.setCurrentPage(Page.Hidden_ContactShare_VF);
            Hidden_ContactShareController_AC controller = new Hidden_ContactShareController_AC(new ApexPages.StandardController(wishChild));
            controller.shareContact();
        }
    }
}