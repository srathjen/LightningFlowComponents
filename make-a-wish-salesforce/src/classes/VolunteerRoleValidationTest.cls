/**
 * @description Test
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 3/18/2020
 */
@IsTest
public class VolunteerRoleValidationTest {

	@TestSetup
	public static void setUp() {
		trac_TriggerHandlerBase.blockTrigger = true;

		List<Account> accounts = TestDataFactory.createAccount(2);
		Account arizonaChapter = accounts.get(0);
		arizonaChapter.Name = 'Make-A-Wish Arizona';
		arizonaChapter.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
		arizonaChapter.Phone = '555555555';
		arizonaChapter.Email__c = 'maw@email.com';
		insert accounts;

		List<Contact> contacts = TestDataFactory.createContact(1);
		Contact volunteerArizona = contacts.get(0);
		volunteerArizona.RecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
		volunteerArizona.AccountId = arizonaChapter.Id;
		volunteerArizona.FirstName = 'Mark';
		volunteerArizona.LastName = 'Smith';
		volunteerArizona.Birthdate = Date.today().addYears(-10);
		volunteerArizona.MailingPostalCode = '12345-9876';
		volunteerArizona.MailingStreet = 'Mark Street';
		volunteerArizona.MailingCountry = 'United States';
		volunteerArizona.MailingState = 'Arizona';
		volunteerArizona.MailingCity = 'Phoenix';
		volunteerArizona.Email = 'ms@email.com';
		insert contacts;

		List<Role__c> roles = TestDataFactory.createRole(2, true);
		Role__c wishGranterRole = roles.get(0);
		wishGranterRole.Name = 'Wish Granter';
		Role__c wishGranterMentorRole = roles.get(1);
		wishGranterMentorRole.Name = 'Wish Granter Mentor';
		insert roles;

		List<Chapter_Role__c> chapterRoles = TestDataFactory.createChapterRole(1);
		Chapter_Role__c wishGranterArizonaRole = chapterRoles.get(0);
		wishGranterArizonaRole.Chapter_Name__c = arizonaChapter.Id;
		wishGranterArizonaRole.Role_Name__c = wishGranterRole.Id;
		wishGranterArizonaRole.Background_Check_Required__c = false;
		wishGranterArizonaRole.COI_Required__c = true;
		insert chapterRoles;

		List<Volunteer_Roles__c> volunteerRoles = TestDataFactory.createVolunteerRole(1);
		Volunteer_Roles__c volunteerRoleArizonaPending = volunteerRoles.get(0);
		volunteerRoleArizonaPending.Chapter_Role__c = wishGranterArizonaRole.Id;
		volunteerRoleArizonaPending.Volunteer_Name__c = volunteerArizona.Id;
		volunteerRoleArizonaPending.Status__c = Constant_AC.VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE;
		volunteerRoleArizonaPending.Hidden_Previous_Status__c = 'Status';
		volunteerRoleArizonaPending.Hidden_Previous_Sub_Status__c = 'Sub Status';
		insert volunteerRoles;

		trac_TriggerHandlerBase.blockTrigger = false;
	}

	@IsTest
	public static void shouldValidateVolunteerRole() {
		List<Volunteer_Roles__c> volunteerRoles = [
				SELECT Id, Chapter_Name__c
				FROM Volunteer_Roles__c
		];

		Map<String, String> chapterNameRoleMap = new Map<String, String>();
		chapterNameRoleMap.put('Make-A-Wish Arizona', 'Arizona - Chapter');

		VolunteerRoleValidation.validatePermission(volunteerRoles, chapterNameRoleMap);
	}
}