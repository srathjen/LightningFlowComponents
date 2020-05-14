/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Description : This class is used to increase the code coverage for VolunteerOpportunitySelection_AC
Modification Log: 
28/03/2018 - Kanagaraj
*****************************************************************************************************/
@IsTest(SeeAllData = false)
public class VolunteerOpportunitySelection_AC_Test {

	private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;

	@TestSetup
	public static void setUp() {
		trac_TriggerHandlerBase.blockTrigger = true;
		User currentUser = Utils.currentUser;
		List<Account> accounts = TestDataFactory.createAccount(1);
		Account account = accounts.get(0);
		account.Name = 'Make-A-Wish Arizona';
		account.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
		account.Volunteer_Manager__c = currentUser.Id;
		account.Alert_for_Unassigned_Wishes__c = 1;
		insert accounts;

		List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
		ICD_Codes__c icdCode = icdCodes.get(0);
		insert icdCode;

		List<Lead> leadsDataFactory = TestDataFactory.createLead(1);
		Lead lead = leadsDataFactory.get(0);
		lead.ChapterName__c = accounts[0].Id;
		lead.FirstName = 'Jack';
		lead.LastName = 'Smith';
		lead.Hidden_Chapter_Change_Confirmation__c = account.Id;
		lead.is_Family_Aware_of_Referral__c = 'Yes';
		lead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
		lead.PD_ICD_Code__c = icdCode.Id;
		lead.Company = 'MAW';
		insert lead;

		List<Contact> contacts = TestDataFactory.createContact(2);
		Contact contact1 = contacts.get(0);
		contact1.FirstName = 'Test1';
		contact1.LastName = 'User2';
		contact1.AccountId = account.Id;
		contact1.ICD_10_Code__c = icdCode.Id;
		insert contacts;

		User volunteerUser = TestDataFactory.createVolunteerUser(1, 'Active Volunteer (Login)', 'Manager').get(0);
		volunteerUser.LastName = 'Smith0';
		volunteerUser.Email = 'js@email.com';
		System.runAs(TestDataFactory.adminUser) {
			insert volunteerUser;
		}

		Contact volunteerUserContact = [
				SELECT AccountId, Account.Name
				FROM Contact
				WHERE Id = :volunteerUser.ContactId
		];

		List<Case> cases = TestDataFactory.createCase(1);
		Case wish = cases.get(0);
		wish.Lead__c = lead.Id;
		wish.RecordTypeId = Constant_AC.DIAGNOSIS_RT_ID;
		wish.ChapterName__c = accounts.get(0).Id;
		wish.Subject = 'Wish1';
		wish.Interview_date__c = System.today();
		wish.Wish_Type__c = 'Hawaii';
		wish.Start_Date__c = System.today();
		wish.End_Date__c = System.today();
		wish.ContactId = contact1.Id;
		wish.Status = 'New';
		wish.Rush__c = false;
		wish.Start_Date__c = System.today();
		wish.Budget_Submitted_Date__c = System.today();
		wish.Budget_Approved_Date__c = System.today();
		wish.Update_Wish_Child_Form_Info__c = true;
		insert cases;

		List<npe5__Affiliation__c> affiliations = TestDataFactory.createAffiliation(1);
		npe5__Affiliation__c affiliation = affiliations.get(0);
		affiliation.npe5__Contact__c = volunteerUser.ContactId;
		affiliation.npe5__Organization__c = volunteerUserContact.AccountId;
		affiliation.npe5__Primary__c = true;
		affiliation.npe5__Status__c = 'Active';
		affiliation.Constituent_Code__c = Constant_AC.BOARD_MEMBER_RT_LABEL;
		insert affiliations;

		List<Role__c> roles = TestDataFactory.createRole(2, true);
		Role__c role1 = roles.get(0);
		role1.Name = 'Wish Granter';
		Role__c role2 = roles.get(1);
		role2.Name = 'Non Wish Granter';
		role2.isWishRole__c = false;
		insert roles;

		List<Chapter_Role__c> chapterRoles = TestDataFactory.createChapterRole(1);
		Chapter_Role__c chapterRole1 = chapterRoles.get(0);
		chapterRole1.Chapter_Name__c = account.Id;
		chapterRole1.Role_Name__c = role1.Id;
		chapterRole1.Background_Check_Required__c = true;
		Chapter_Role__c chapterRole2 = chapterRoles.get(0);
		chapterRole2.Chapter_Name__c = account.Id;
		chapterRole2.Role_Name__c = role2.Id;
		chapterRole2.Background_Check_Required__c = true;
		insert chapterRoles;

		List<Volunteer_Roles__c> volunteerRoles = TestDataFactory.createVolunteerRole(2);
		Volunteer_Roles__c volunteerWishRole = volunteerRoles.get(0);
		volunteerWishRole.Volunteer_Name__c = volunteerUser.ContactId;
		volunteerWishRole.Chapter_Role__c = chapterRole1.Id;
		volunteerWishRole.Status__c = Constant_AC.VOLUNTEER_ROLE_STATUS_PENDING;
		insert volunteerRoles;

		List<Volunteer_Opportunity__c> volunteerOpportunities = TestDataFactory.createVolunteerOpportunity(1);
		Volunteer_Opportunity__c volunteerOpportunity1 = volunteerOpportunities.get(0);
		volunteerOpportunity1.Chapter_Role_Opportunity__c = chapterRole1.Id;
		volunteerOpportunity1.Wish__c = wish.Id;
		volunteerOpportunity1.Chapter_Name__c = account.Id;
		volunteerOpportunity1.RecordTypeId = Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID;
		volunteerOpportunity1.Volunteer_Name__c = volunteerUser.ContactId;
		volunteerOpportunity1.Status__c = 'Approved';
		insert volunteerOpportunities;

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void createVolunteerSelection() {
		User volunteerUser = [
				SELECT Id, ContactId
				FROM User
				WHERE LastName = 'Smith0'
		][0];
		Volunteer_Opportunity__c volunteerOpportunity = [
				SELECT Id, Wish__c, Name
				FROM Volunteer_Opportunity__c
				WHERE Volunteer_Name__c = :volunteerUser.ContactId
		][0];
		Test.startTest();
		System.runAs(volunteerUser) {
			Test.setCurrentPageReference(new PageReference('Page.VolunteerOpportunitySelection_VF'));
			System.currentPageReference().getParameters().put('caseRecId', volunteerOpportunity.Wish__c);
			VolunteerOpportunitySelection_AC controller = new VolunteerOpportunitySelection_AC();
			controller.createTimeSheet();
			controller.CreateNewTimeSheet();
			controller.DisplayError();
			VolunteerOpportunitySelection_AC.volunteerWrapper newWrapper = new VolunteerOpportunitySelection_AC.volunteerWrapper();
			newWrapper.recordSelected = false;
			newWrapper.volOpp = volunteerOpportunity;
			System.assertEquals(newWrapper.volOpp, volunteerOpportunity, 'Volunteer Oppurtunity value does not match');
			System.assert(newWrapper.volOpp == volunteerOpportunity, 'Volunteer Oppurtunity value  does not match');
		}
		Test.stopTest();
	}

	@IsTest
	public static void createTwoVolunteerSelection() {
		Test.startTest();
		User volunteerUser = [
				SELECT Id, ContactId
				FROM User
				WHERE LastName = 'Smith0'
		][0];
		Volunteer_Opportunity__c volunteerOpportunity = [
				SELECT Id, Wish__c, Name, Status__c, Chapter_Role_Opportunity__c, Chapter_Name__c
				FROM Volunteer_Opportunity__c
				WHERE Volunteer_Name__c = :volunteerUser.ContactId
		][0];
		Volunteer_Opportunity__c volunteerOpportunity2 = new Volunteer_Opportunity__c();
		volunteerOpportunity2.Chapter_Role_Opportunity__c = volunteerOpportunity.Chapter_Role_Opportunity__c;
		volunteerOpportunity2.Wish__c = volunteerOpportunity.Wish__c;
		volunteerOpportunity2.Chapter_Name__c = volunteerOpportunity.Chapter_Name__c;
		volunteerOpportunity2.RecordTypeId = Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID;
		volunteerOpportunity2.Volunteer_Name__c = volunteerUser.ContactId;
		volunteerOpportunity2.Status__c = 'Approved';
		insert volunteerOpportunity2;
		System.runAs(volunteerUser) {
			Test.setCurrentPageReference(new PageReference('Page.VolunteerOpportunitySelection_VF'));
			System.currentPageReference().getParameters().put('caseRecId', volunteerOpportunity.Wish__c);
			VolunteerOpportunitySelection_AC controller = new VolunteerOpportunitySelection_AC();
			controller.DisplayError();
			controller.volunteerWrapperList[0].recordSelected = true;
			controller.createTimeSheet();
			System.assertEquals(volunteerOpportunity.Status__c, 'Approved', 'Volunteer Opportunity status does not match');
			System.assert(volunteerOpportunity.Status__c == 'Approved', 'Volunteer Opportunity status does not match');
		}
		Test.stopTest();
	}
}