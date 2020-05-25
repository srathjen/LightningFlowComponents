/**
 * @description 	Test class for Volunteer Role (Volunteer_Roles__c) trigger, domain and service classes.
 * @author 			MST Solutions
 * @createdDate		2016-07-18
 */
@IsTest
private class VolunteerRole_AT_Test {
	@TestSetup
	static void setup() {
		trac_TriggerHandlerBase.blockTrigger = true;

		List<Account> accounts = TestDataFactory.createAccount(1);
		accounts[0].Name = Constant_AC.ACCOUNT_NAME_MAW_ALABAMA;
		accounts[0].RecordTypeId = Constant_AC.CHAPTER_RT_ID;
		accounts[0].Volunteer_Manager__c = Utils.currentUser.Id;
		accounts[0].Alert_for_Unassigned_Wishes__c = 1;
		insert accounts;

		List<Contact> contacts = TestDataFactory.createContact(1);
		contacts[0].FirstName = 'Volunteer';
		contacts[0].LastName = 'TestContact';
		contacts[0].RecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
		contacts[0].AccountId = accounts[0].Id;
		contacts[0].Volunteer_Role__c = 'Water Handler';
		contacts[0].Email = 'test@gmail.com';
		insert contacts;

		List<npe5__Affiliation__c> affiliations = TestDataFactory.createAffiliation(1);
		affiliations[0].npe5__Contact__c = contacts[0].Id;
		affiliations[0].npe5__Organization__c = TestClassUtil.createVolunteerAccount().Id;
		affiliations[0].npe5__Primary__c = true;
		affiliations[0].npe5__Status__c = 'Pending';
		affiliations[0].Constituent_Code__c = Constant_AC.BOARD_MEMBER_RT_LABEL;
		insert affiliations;

		List<Role__c> roles = TestDataFactory.createRole(1);
		roles[0].Name = 'Wish Granter';
		roles[0].isWishRole__c = true;
		insert roles;

		List<Chapter_Role__c> chapterRoles = TestDataFactory.createChapterRole(1);
		chapterRoles[0].Chapter_Name__c = accounts[0].Id;
		chapterRoles[0].Role_Name__c = roles[0].Id;
		chapterRoles[0].Background_Check_Required__c = true;
		insert chapterRoles;

		List<Volunteer_Roles__c> volunteerRoles = TestDataFactory.createVolunteerRole(1);
		volunteerRoles[0].Chapter_Role__c = chapterRoles[0].Id;
		volunteerRoles[0].Volunteer_Name__c = contacts[0].Id;
		volunteerRoles[0].Status__c = 'Chapter Review';
		insert volunteerRoles;
		
		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	static void createRecords() {
		Volunteer_Roles__c currVolRole = [SELECT Status__c FROM Volunteer_Roles__c];
		currVolRole.Status__c = 'Pending Training';
		update currVolRole;

		System.assertEquals(currVolRole.Status__c, 'Pending Training', 'Volunteer role status does not match');
	}

	@IsTest
	static void updateVolunteerRole() {
		Account acc = [SELECT Id FROM Account WHERE RecordTypeId = :Constant_AC.CHAPTER_RT_ID AND Volunteer_Manager__c = :UserInfo.getUserId()];
		Contact con = [SELECT Id FROM Contact];
		Chapter_Role__c currChapRole = [SELECT Id FROM Chapter_Role__c];
		Volunteer_Roles__c currVolRole = [SELECT Id FROM Volunteer_Roles__c];

		Test.startTest();
		List<Volunteer_Opportunity__c> volunteerOpportunities = TestDataFactory.createVolunteerOpportunity(1);
		volunteerOpportunities[0].Chapter_Name__c = acc.Id;
		volunteerOpportunities[0].Chapter_Role_Opportunity__c = currChapRole.Id;
		volunteerOpportunities[0].Volunteer_Name__c = con.Id;
		insert volunteerOpportunities;

		List<Volunteer_Roles__c> volunteerRoles = TestDataFactory.createVolunteerRole(1);
		volunteerRoles[0].Chapter_Role__c = currChapRole.Id;
		volunteerRoles[0].Volunteer_Name__c = con.Id;
		volunteerRoles[0].Status__c = 'Chapter Review';
		insert volunteerRoles;

		currVolRole.Status__c = 'Out of Compliance';
		update currVolRole;

		volunteerRoles[0].Status__c = 'Out of Compliance';
		currVolRole.Status__c = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;

		update currVolRole;
		update volunteerRoles[0];
		Test.stopTest();

		System.assertEquals(currVolRole.Status__c, Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE, 'Volunteer role status does not match');
	}
}
