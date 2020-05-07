/************************************************************************************
Author : Mst Solutions
Description : This class is used to increase the code coverage for RecallApprovalRest Class
*************************************************************************************/

@IsTest
public class RecallApprovalRest_AC_Test {

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

		User volunteerUser = TestDataFactory.createVolunteerUser(1).get(0);
		volunteerUser.LastName = 'Smith0';
		volunteerUser.Email = 'js@email.com';
		System.runAs(TestDataFactory.adminUser) {
			insert volunteerUser;
		}
		Contact volunteerContact = new Contact();
		volunteerContact.Id = volunteerUser.ContactId;
		volunteerContact.Title = 'Mr.';
		volunteerContact.Email = 'js@email.com';
		volunteerContact.Birth_Month__c = 'May';
		volunteerContact.Birth_Day__c = '16';
		volunteerContact.npe01__PreferredPhone__c = '5555555555';
		volunteerContact.HomePhone = '5555555555';
		volunteerContact.I_m_on_LinkedIn__c = 'Yes';
		volunteerContact.How_did_you_hear_about_Make_A_Wish__c = 'Friend';
		volunteerContact.MailingStreet = '123 St';
		volunteerContact.MailingCity = 'Phoenix';
		volunteerContact.County__c = 'Arizona';
		volunteerContact.MailingPostalCode = '84001';
		volunteerContact.MailingStateCode = 'AZ';
		volunteerContact.Emergency_Contact__c = 'Mark';
		volunteerContact.Emergency_Contact_Relationship__c = 'Friend';
		volunteerContact.Emergency_Contact_Phone__c = '5555555555';
		volunteerContact.Read__c = 'English';
		volunteerContact.Write__c = 'English';
		volunteerContact.Speak__c = 'English';
		volunteerContact.Understand__c = 'English';
		volunteerContact.Language__c = 'English';
		update volunteerContact;

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

		List<Role__c> roles = TestDataFactory.createRole(1, true);
		Role__c wishGranterRole = roles.get(0);
		wishGranterRole.Name = 'Wish Granter';
		wishGranterRole.isWishRole__c = true;
		insert roles;

		List<Chapter_Role__c> chapterRoles = TestDataFactory.createChapterRole(1);
		Chapter_Role__c wishGranterArizonaRole = chapterRoles.get(0);
		wishGranterArizonaRole.Chapter_Name__c = account.Id;
		wishGranterArizonaRole.Role_Name__c = wishGranterRole.Id;
		wishGranterArizonaRole.Background_Check_Required__c = false;
		insert chapterRoles;

		List<Volunteer_Opportunity__c> volunteerOpportunities = TestDataFactory.createVolunteerOpportunity(2);
		Volunteer_Opportunity__c volunteerOpportunity = volunteerOpportunities.get(0);
		volunteerOpportunity.Wish__c = wish.Id;
		volunteerOpportunity.Chapter_Role_Opportunity__c = wishGranterArizonaRole.Id;
		volunteerOpportunity.Volunteer_Name__c = volunteerUser.ContactId;
		insert volunteerOpportunities;

		Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
		app.setObjectId(volunteerOpportunity.Id);
		app.setProcessDefinitionNameOrId('Volunteer_Role_Approval_Process');
		app.setSkipEntryCriteria(true);
		app.setNextApproverIds(new Id[]{
				UserInfo.getUserId()
		});
		Approval.ProcessResult result = Approval.process(app);
		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void volOppRecallApproval() {
		Volunteer_Opportunity__c volunteerOpportunity = [
				SELECT Id
				FROM Volunteer_Opportunity__c
		][0];
		Test.startTest();
		RecallApprovalRest_AC recallApprovalRest = new RecallApprovalRest_AC();
		String JsonMsg = JSON.serialize(recallApprovalRest);
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/recalApproval/' + volunteerOpportunity.Id;
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf(JsonMsg);
		RestContext.request = req;
		RestContext.response = res;
		RecallApprovalRest_AC.getBackApproval();
		Test.stopTest();
	}
}