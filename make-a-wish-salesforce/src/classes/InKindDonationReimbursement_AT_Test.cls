/**
 * @description		Test class for InKindDonationReimbursement trigger, domain and service classes.
 * @author			MST Solutions
 * @createdDate		2016-04-10
 */
@isTest
public class InKindDonationReimbursement_AT_Test {
	@testSetup
	static void setup() {
		trac_TriggerHandlerBase.blockTrigger = true;

		List<Account> accounts = TestDataFactory.createAccount(1);
		accounts[0].Name = Constant_AC.ACCOUNT_NAME_MAW_ALABAMA;
		accounts[0].RecordTypeId = Constant_AC.CHAPTER_RT_ID;
		accounts[0].Volunteer_Manager__c = Utils.currentUser.Id;
		accounts[0].Alert_for_Unassigned_Wishes__c = 1;
		insert accounts;

		List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
		icdCodes[0].Name = 'Q917';
		insert icdCodes;

		List<Contact> contacts = TestDataFactory.createContact(2);

		contacts[0].FirstName = 'Volunteer';
		contacts[0].LastName = 'TestContact';
		contacts[0].RecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
		contacts[0].AccountId = accounts[0].Id;
		contacts[0].Volunteer_Role__c = 'Water Handler';
		contacts[0].Email = 'test@gmail.com';

		contacts[1].FirstName = 'WishChild';
		contacts[1].LastName = 'TestContact';
		contacts[1].Parent_Guardian_Name__c = 'Parental Unit';
		contacts[1].RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
		contacts[1].ICD_10_Code__c = icdCodes[0].Id;
		contacts[1].Birthdate = Date.today().addDays(+21);
		contacts[1].Birthdate = contacts[1].Birthdate.addYears(-3);

		insert contacts;

		List<Case> cases = TestDataFactory.createCase(1);
		cases[0].RecordTypeId = Constant_AC.WISH_RT_ID;
		cases[0].ChapterName__c = accounts[0].Id;
		cases[0].Subject = 'Parent Wish';
		cases[0].Interview_date__c = System.today();
		cases[0].Wish_Type__c = 'Disney World';
		cases[0].Start_Date__c = System.today();
		cases[0].End_Date__c = System.today();
		cases[0].ContactId = contacts[1].Id;
		cases[0].Status = 'New';
		cases[0].Start_Date__c = System.today();
		cases[0].LiabilitySignerMapKeyPair__c = 'Vennila';
		cases[0].Budget_Submitted_Date__c = System.today();
		cases[0].Budget_Approved_Date__c = System.today();
		insert cases;

		List<In_Kind_Donation_Reimbursement__c> inKindDonationReimbursements = TestDataFactory.createInKindDonationReimbursement(1);
		inKindDonationReimbursements[0].Date_of_Gift__c = System.today() + 2;
		inKindDonationReimbursements[0].Gift_Type__c = 'Goods';
		inKindDonationReimbursements[0].Gift_Value__c = 123456;
		inKindDonationReimbursements[0].Documentation__c = 'Not available';
		inKindDonationReimbursements[0].RecordTypeId = Constant_AC.IN_KIND_ID;
		inKindDonationReimbursements[0].Make_check_payable_to_me__c = true;
		inKindDonationReimbursements[0].Wish__c = cases[0].Id;
		insert inKindDonationReimbursements;
	}

	@isTest
	static void testInsertInkindRecord() {
		List<In_Kind_Donation_Reimbursement__c> newInKindDonationReimbursements = TestDataFactory.createInKindDonationReimbursement(1);
		newInKindDonationReimbursements[0].Documentation__c = 'Not available';
		newInKindDonationReimbursements[0].RecordTypeId = Constant_AC.REIMBURSEMENT_ID;
		newInKindDonationReimbursements[0].Make_check_payable_to_me__c = true;

		Test.startTest();
		System.runAs(new User(Id = UserInfo.getUserId())) {
			insert newInKindDonationReimbursements;
		}
		Test.stopTest();

		newInKindDonationReimbursements = [SELECT Id FROM In_Kind_Donation_Reimbursement__c WHERE RecordTypeId = :Constant_AC.REIMBURSEMENT_ID];
		System.assert(!newInKindDonationReimbursements.isEmpty());
	}

	@isTest
	static void testInsertInkindRecordPayableFalse() {
		List<In_Kind_Donation_Reimbursement__c> newInKindDonationReimbursements = TestDataFactory.createInKindDonationReimbursement(1);
		newInKindDonationReimbursements[0].Documentation__c = 'Not available';
		newInKindDonationReimbursements[0].RecordTypeId = Constant_AC.REIMBURSEMENT_ID;
		newInKindDonationReimbursements[0].Make_check_payable_to_me__c = false;

		Test.startTest();
		System.runAs(new User(Id = UserInfo.getUserId())) {
			insert newInKindDonationReimbursements;
		}
		Test.stopTest();

		newInKindDonationReimbursements = [SELECT Id FROM In_Kind_Donation_Reimbursement__c WHERE RecordTypeId = :Constant_AC.REIMBURSEMENT_ID];
		System.assert(!newInKindDonationReimbursements.isEmpty());
	}


	@isTest
	static void updateInkindRecordWithCase() {
		Case wishCase = [SELECT Id FROM Case];
		In_Kind_Donation_Reimbursement__c inKindDonationReimbursement = [SELECT Id, Wish__c FROM In_Kind_Donation_Reimbursement__c];

		inKindDonationReimbursement.Wish__c = wishCase.Id;
		update inKindDonationReimbursement;

		List<In_Kind_Donation_Reimbursement__c> newInKindDonationReimbursements = TestDataFactory.createInKindDonationReimbursement(1);
		newInKindDonationReimbursements[0].Documentation__c = 'Not available';
		newInKindDonationReimbursements[0].RecordTypeId = Constant_AC.REIMBURSEMENT_ID;
		newInKindDonationReimbursements[0].Make_check_payable_to_me__c = false;

		Test.startTest();
		System.runAs(new User(Id = UserInfo.getUserId())) {
			insert newInKindDonationReimbursements;
		}
		Test.stopTest();

		newInKindDonationReimbursements = [SELECT Id FROM In_Kind_Donation_Reimbursement__c WHERE RecordTypeId = :Constant_AC.REIMBURSEMENT_ID];
		System.assert(!newInKindDonationReimbursements.isEmpty());
	}
}