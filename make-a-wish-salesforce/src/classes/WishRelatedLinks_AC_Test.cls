@IsTest
public class WishRelatedLinks_AC_Test {

	public static testMethod void wishRelatedLink() {

		Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
		insert chapterAccount;

		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		wishChild.Birthdate = Date.today().addYears(-19);
		wishChild.Email = 'Test@test.com';
		wishChild.Relationship_Type__c = Constant_AC.CONTACT_WISH_CHILD_RT_LABEL;
		wishChild.Recipient_Email__c = 'Test1@test.com';
		wishChild.First_Recipient_Name__c = 'Test1';
		wishChild.Second_Recipient_Email__c = 'Test2@test.com';
		wishChild.Second_Recipient_Name__c = 'Test2';
		wishChild.Hidden_Third_Recipient_Email__c = 'Test3@test.com';
		wishChild.Hidden_Third_Recipient_Name__c = 'Test3';
		Contact wishFamilyContact = OrientationandTrainingUtil.CreateWishFamily();
		insert new List<Contact>{
				wishChild, wishFamilyContact
		};
		Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		insert parentCase;

		npe4__Relationship__c relationship = OrientationandTrainingUtil.CreateRelationshipRec(wishChild.id, wishFamilyContact.id);
		relationship.Parent_Legal_Guardian__c = true;
		relationship.Under_18__c = false;
		insert relationship;

		WishRelatedLinks_AC.WrapperClass wrapper = new WishRelatedLinks_AC.WrapperClass(wishChild);
		wrapper.selected = true;

		ApexPages.StandardController sc = new ApexPages.StandardController(parentCase);
		WishRelatedLinks_AC testAccPlan = new WishRelatedLinks_AC(sc);
		testAccPlan.querychildCase = new List<Case>{
				parentCase
		};
		String WishReceipt = testAccPlan.WishReceipt;
		testAccPlan.DisplayError();
		testAccPlan.updateSenderInfo();
		testAccPlan.DisplayErrorMessage();
		testAccPlan.DisplayErrormsg();
		testAccPlan.DisplayErr();
		testAccPlan.wrapperList.add(wrapper);
		testAccPlan.recipitLink = 'wishreceipt';
		testAccPlan.updateWishChildContact();
		testAccPlan.downLoadWishReceipt();
		testAccPlan.recipitLink = 'wishreceiptSpanish';
		testAccPlan.updateWishChildContact();
		testAccPlan.downLoadWishReceipt();
		testAccPlan.LiabilityFrom();
		Boolean showPopup = testAccPlan.showPopup;
		Boolean formTrackerVal = testAccPlan.formTrackerVal;
		PageReference pageRef = Page.WishRelatedLinks_VF;
		//pageRef.getParameters().put('Id', String.valueOf(pay.Id));
		Test.setCurrentPage(pageRef);
	}

	public static testMethod void wisGrantedCase() {

		Account chapterAccount = OrientationandTrainingUtil.AlabamaAccount();
		insert chapterAccount;

		Contact wishChild = OrientationandTrainingUtil.CreateWishChild();
		insert wishChild;

		Case parentCase = OrientationandTrainingUtil.CreateParentCase(wishChild.Id);
		Case wishGrantCase = OrientationandTrainingUtil.createWishGrantCase(wishChild.Id, parentCase.Id);
		insert new List<Case>{
				parentCase, wishGrantCase
		};

		ApexPages.StandardController sc = new ApexPages.StandardController(wishGrantCase);
		WishRelatedLinks_AC testAccPlan = new WishRelatedLinks_AC(sc);
		testAccPlan.LiabilityFrom();
		PageReference pageRef = Page.WishRelatedLinks_VF;
		//pageRef.getParameters().put('Id', String.valueOf(pay.Id));
		Test.setCurrentPage(pageRef);
	}

	public static testMethod void callmethods() {
		Case cse = new Case();
		insert cse;
		ApexPages.StandardController stdcase = new ApexPages.StandardController(cse);
		WishRelatedLinks_AC obj = new WishRelatedLinks_AC(stdcase);
		User u = [
				SELECT Id, Name, MobilePhone, Contact.MobilePhone
				FROM User
				WHERE Id = :UserInfo.getUserId()
		];
		obj.userDetailList = new List<User>{
				u
		};
		obj.updateCaseTeamMember();
		obj.DisplayErr();
	}
}