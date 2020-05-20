/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 28/06/2016
Description : VolunteerOpportunityTrigger_AT_Test is used to increase the code coverage for VolunteerOpportunityTrigger_AT trigger and VolunteerOpportunityTriggerHandler.
*****************************************************************************************************/
@IsTest
public class VolunteerOpportunityTrigger_AT_Test {

	@TestSetup
	public static void setUp() {
		trac_TriggerHandlerBase.blockTrigger = true;
		User currentUser = Utils.currentUser;
		List<Account> accounts = TestDataFactory.createAccount(1);
		Account account = accounts.get(0);
		account.Name = 'Make-A-Wish Arizona';
		account.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
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

		List<Non_Wish_Events__c> nonWishEvents = TestDataFactory.createNonWishEvent(2);
		Non_Wish_Events__c nonWishEvent = nonWishEvents.get(0);
		nonWishEvent.Event_Name__c = 'Send Off';
		nonWishEvent.Event_Date__c = System.today() + 5;
		nonWishEvent.Event_Text__c = 'Sending Wish Child';
		nonWishEvent.Priority__c = '1';
		nonWishEvent.Chapter__c = volunteerUserContact.AccountId;
		nonWishEvent.RecordTypeId = Constant_AC.EVENTS_ID;
		Non_Wish_Events__c nonWishEvent2 = nonWishEvents.get(1);
		nonWishEvent2.Event_Name__c = 'Send Off';
		nonWishEvent2.Event_Date__c = System.today() + 5;
		nonWishEvent2.Event_Text__c = 'Sending Wish Child';
		nonWishEvent2.Priority__c = '2';
		nonWishEvent2.Chapter__c = volunteerUserContact.AccountId;
		nonWishEvent2.RecordTypeId = Constant_AC.EVENTS_ID;
		insert nonWishEvents;

		List<Role__c> roles = TestDataFactory.createRole(1, true);
		Role__c wishGranterRole = roles.get(0);
		wishGranterRole.Name = 'Wish Granter';
		wishGranterRole.isWishRole__c = true;
		insert roles;

		List<Chapter_Role__c> chapterRoles = TestDataFactory.createChapterRole(1);
		Chapter_Role__c chapterRole = chapterRoles.get(0);
		chapterRole.Chapter_Name__c = account.Id;
		chapterRole.Role_Name__c = wishGranterRole.Id;
		chapterRole.Background_Check_Required__c = true;
		insert chapterRoles;

		List<Volunteer_Roles__c> volunteerRoles = TestDataFactory.createVolunteerRole(2);
		Volunteer_Roles__c volunteerWishRole = volunteerRoles.get(0);
		volunteerWishRole.Volunteer_Name__c = volunteerUser.ContactId;
		volunteerWishRole.Chapter_Role__c = chapterRole.Id;
		volunteerWishRole.Status__c = Constant_AC.VOLUNTEER_ROLE_STATUS_PENDING;
		insert volunteerRoles;

		List<Orientation_Training__c> orientationTrainings = TestDataFactory.createOrientationTraining(2);
		Orientation_Training__c orientationTraining = orientationTrainings.get(0);
		orientationTraining.Name = 'Trainging1';
		orientationTraining.RecordTypeId = Constant_AC.TRAINING_RT_ID;
		orientationTraining.Start_Time__c = '7:00 AM';
		orientationTraining.End_Time__c = '7:00 PM';
		orientationTraining.Prompt_upon_Login__c = true;
		insert orientationTrainings;

		List<Chapter_Role_O_T__c> chapterRoleOTs = TestDataFactory.createChapterRoleOrientationAndTraining(1);
		Chapter_Role_O_T__c chapterRoleOT = chapterRoleOTs.get(0);
		chapterRoleOT.Orientation_Training__c = orientationTraining.Id;
		chapterRoleOT.Chapter_Role__c = chapterRole.Id;
		chapterRoleOT.Required__c = true;
		insert chapterRoleOTs;

		List<Volunteer_Opportunity__c> volunteerOpportunities = TestDataFactory.createVolunteerOpportunity(1);
		Volunteer_Opportunity__c volunteerOpportunity = volunteerOpportunities.get(0);
		volunteerOpportunity.Chapter_Role_Opportunity__c = chapterRole.Id;
		volunteerOpportunity.Wish__c = wish.Id;
		volunteerOpportunity.Non_Wish_Event__c = nonWishEvent.Id;
		volunteerOpportunity.Chapter_Name__c = wish.AccountId;
		volunteerOpportunity.RecordTypeId = Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID;
		volunteerOpportunity.Status__c = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_PENDING;
		insert volunteerOpportunities;

		CaseTeamRole caseTeamRole = [
				SELECT Id,Name
				FROM CaseTeamRole
				WHERE Name = :'Wish Granter'
				LIMIT 1
		];

		List<CaseTeamMember> caseTeamMembers = TestDataFactory.createCaseTeamMember(1);
		CaseTeamMember caseMember = caseTeamMembers.get(0);
		caseMember.ParentId = wish.Id;
		caseMember.MemberId = volunteerUser.Id;
		caseMember.TeamRoleId = caseTeamRole.Id;

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void SubmittoApproval() {
		Case wish = [
				SELECT Id, AccountId
				FROM Case
				WHERE Subject = 'Wish1'
		][0];
		Chapter_Role__c chapterRole = [
				SELECT Id
				FROM Chapter_Role__c
				WHERE Chapter_Name__c = :wish.AccountId
		][0];

		Test.startTest();
		List<Volunteer_Opportunity__c> volunteerOpportunities = TestDataFactory.createVolunteerOpportunity(3);
		Volunteer_Opportunity__c volunteerOpportunity1 = volunteerOpportunities.get(0);
		volunteerOpportunity1.Chapter_Role_Opportunity__c = chapterRole.Id;
		volunteerOpportunity1.Wish__c = wish.Id;
		volunteerOpportunity1.Chapter_Name__c = wish.AccountId;
		volunteerOpportunity1.RecordTypeId = Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID;
		volunteerOpportunity1.Status__c = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_PENDING;
		Volunteer_Opportunity__c volunteerOpportunity2 = volunteerOpportunities.get(1);
		volunteerOpportunity2.Chapter_Role_Opportunity__c = chapterRole.Id;
		volunteerOpportunity2.Wish__c = wish.Id;
		volunteerOpportunity2.Chapter_Name__c = wish.AccountId;
		volunteerOpportunity2.RecordTypeId = Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID;
		volunteerOpportunity2.Status__c = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_APPROVED;
		Volunteer_Opportunity__c volunteerOpportunity3 = volunteerOpportunities.get(2);
		volunteerOpportunity3.Chapter_Role_Opportunity__c = chapterRole.Id;
		volunteerOpportunity3.Wish__c = wish.Id;
		volunteerOpportunity3.Chapter_Name__c = wish.AccountId;
		volunteerOpportunity3.RecordTypeId = Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID;
		insert new List<Volunteer_Opportunity__c>{
				volunteerOpportunity1, volunteerOpportunity2, volunteerOpportunity3
		};
		Test.stopTest();
	}

	@IsTest
	public static void CreateCaseTeamMember() {
		Case wish = [
				SELECT Id, AccountId
				FROM Case
				WHERE Subject = 'Wish1'
		][0];
		Chapter_Role__c chapterRole = [
				SELECT Id
				FROM Chapter_Role__c
				WHERE Chapter_Name__c = :wish.AccountId
		][0];
		User volunteerUser = [
				SELECT Id, ContactId
				FROM User
				WHERE Email = 'js@email.com'
		][0];
		Volunteer_Opportunity__c volunteerOpportunity = [
				SELECT Id
				FROM Volunteer_Opportunity__c
		][0];
		System.runAs(Utils.currentUser) {
			Volunteer_Opportunity__c updateVolunteerOpportunity = new Volunteer_Opportunity__c();
			updateVolunteerOpportunity.Id = volunteerOpportunity.Id;
			updateVolunteerOpportunity.Status__c = 'Approved';
			updateVolunteerOpportunity.Chapter_Role_Opportunity__c = chapterRole.Id;
			updateVolunteerOpportunity.Volunteer_Name__c = volunteerUser.ContactId;
			Test.startTest();
			update updateVolunteerOpportunity;
			Test.stopTest();
		}
	}

	@IsTest
	public static void DeleteOpportunityCount() {
		Volunteer_Opportunity__c volunteerOpportunity = [
				SELECT Id
				FROM Volunteer_Opportunity__c
				WHERE Non_Wish_Event__c != NULL
		][0];
		Test.startTest();
		delete volunteerOpportunity;
		Test.stopTest();
	}
}