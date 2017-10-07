@isTest
public class Hidden_ContactShareController_AC_Test {
    
     static testMethod  void setup(){  
        Account acc = OrientationandTrainingUtil.createVolunteerAccount();
        Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
        User currUser = new User();
         System.RunAs(new User(Id = UserInfo.getUserId())) {
            currUser = OrientationandTrainingUtil.createActiveVolunteerUser(con.id);
        }
        Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
        Contact wishFamiy = OrientationandTrainingUtil.CreateWishFamily();
        npe4__Relationship__c  relationShip = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.Id,wishFamiy.Id);
        ContactShare shareContact = new ContactShare();
                  shareContact.ContactAccessLevel = 'Read';   
                  shareContact.ContactId = wishChild.Id;
                  shareContact.UserOrGroupId = currUser.Id;
                  Insert shareContact;
        ContactShare shareContact2 = new ContactShare();
                  shareContact2.ContactAccessLevel = 'Read';   
                  shareContact2.ContactId = wishFamiy.Id;
                  shareContact2.UserOrGroupId = currUser.Id;
                  Insert shareContact2;
        System.RunAs(currUser) {      
        //PageReference pageRef = Page.Hidden_ContactShare_VF;
        //pageRef.getParameters().put('id', String.valueOf(wishChild.Id));
        Test.setCurrentPage(Page.Hidden_ContactShare_VF);
        //Test.setCurrentPage(pageRef);  
        
        Hidden_ContactShareController_AC controller = new Hidden_ContactShareController_AC(new ApexPages.StandardController(wishChild));
        controller.shareContact();
        }
        }
    }