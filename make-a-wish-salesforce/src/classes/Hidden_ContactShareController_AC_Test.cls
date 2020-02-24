@isTest
public class Hidden_ContactShareController_AC_Test {
	static testMethod void createFamily() {
		Account acc = OrientationandTrainingUtil.createVolunteerAccount();
		insert acc;

		Contact con = OrientationandTrainingUtil.createVolunteerContact(acc.id);
		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		Contact wishFamily = OrientationandTrainingUtil.CreateWishFamily();
		insert new List<Contact>{
				con, wishChild, wishFamily
		};

		User currUser = new User();
		System.RunAs(new User(Id = UserInfo.getUserId())) {
			currUser = OrientationandTrainingUtil.createActiveVolunteerUser(con.id);
			insert currUser;
		}

		Test.StartTest();
		npe4__Relationship__c relationShip = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.Id, wishFamily.Id);
		npe4__Relationship__c relationShip2 = OrientationandTrainingUtil.CreateRelationshipRec(wishFamily.Id, wishChild.Id);
		insert new List<npe4__Relationship__c>{
				relationShip, relationShip2
		};
		Test.StopTest();

		ContactShare shareContact = new ContactShare();
		shareContact.ContactAccessLevel = 'Read';
		shareContact.ContactId = wishChild.Id;
		shareContact.UserOrGroupId = currUser.Id;
		ContactShare shareContact2 = new ContactShare();
		shareContact2.ContactAccessLevel = 'Read';
		shareContact2.ContactId = wishFamily.Id;
		shareContact2.UserOrGroupId = currUser.Id;
		insert new List<ContactShare>{
				shareContact, shareContact2
		};

		System.RunAs(currUser) {
			//PageReference pageRef = Page.Hidden_ContactShare_VF;
			//pageRef.getParameters().put('id', String.valueOf(wishChild.Id));
			Test.setCurrentPage(Page.Hidden_ContactShare_VF);
			//Test.setCurrentPage(pageRef);
			Hidden_ContactShareController_AC controller = new Hidden_ContactShareController_AC(new ApexPages.StandardController(wishChild));
			controller.test = wishChild.Id;
			controller.shareContact();
		}
	}
}