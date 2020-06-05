/**
 * @description VolunteerOpportunityServiceTest is used to increase the code coverage for VolunteerOpportunityTrigger_AT trigger and VolunteerOpportunityTriggerHandler.
 * @author Kanagaraj, MST Solutions
 * @date 28/06/2016
 **/
@IsTest
public class VolunteerOpportunityServiceTest {

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
		wish.Status = Constant_AC.CASE_STATUS_GRANTED;
		wish.Rush__c = false;
		wish.Start_Date__c = System.today();
		wish.Budget_Submitted_Date__c = System.today();
		wish.Budget_Approved_Date__c = System.today();
		wish.Update_Wish_Child_Form_Info__c = true;
		insert cases;

		List<Non_Wish_Events__c> nonWishEvents = TestDataFactory.createNonWishEvent(2);
		Non_Wish_Events__c nonWishEvent = nonWishEvents.get(0);
		nonWishEvent.Event_Name__c = 'Send Off 1';
		nonWishEvent.Event_Date__c = System.today() + 5;
		nonWishEvent.Event_Text__c = 'Sending Wish Child';
		nonWishEvent.Priority__c = '1';
		nonWishEvent.Chapter__c = volunteerUserContact.AccountId;
		nonWishEvent.RecordTypeId = Constant_AC.EVENTS_ID;
		Non_Wish_Events__c nonWishEvent2 = nonWishEvents.get(1);
		nonWishEvent2.Event_Name__c = 'Send Off 2';
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

        Volunteer_Count__c volunteerCount = TestDataFactory.createVolunteerCount(1)[0];
        volunteerCount.Non_Wish_Events__c = nonWishEvent.Id;
        volunteerCount.Description__c = 'Test Description';
        volunteerCount.Date__c = System.today() + 1;
        volunteerCount.Start_Time__c = '7.00 AM';
        volunteerCount.End_Time__c = '9.00 AM';
        volunteerCount.Volunteer_Needed__c = 2;
        volunteerCount.Description__c = nonWishEvent.Description__c;
        volunteerCount.Chapter_Role__c = nonWishEvent.Chapter_Role__c;
        insert volunteerCount;

		List<Volunteer_Roles__c> volunteerRoles = TestDataFactory.createVolunteerRole(2);
		Volunteer_Roles__c volunteerWishRole = volunteerRoles.get(0);
		volunteerWishRole.Volunteer_Name__c = volunteerUser.ContactId;
		volunteerWishRole.Chapter_Role__c = chapterRole.Id;
		volunteerWishRole.Status__c = Constant_AC.VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE;
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
		volunteerOpportunity.Chapter_Name__c = account.Id;
		volunteerOpportunity.RecordTypeId = Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID;
		volunteerOpportunity.Status__c = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_PENDING;
		volunteerOpportunity.Inactive__c = false;
		volunteerOpportunity.Volunteer_Name__c = volunteerUser.ContactId;
		volunteerOpportunity.Hidden_VolunteerCount_Desc__c = 'test';
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
	public static void shouldFindVolunteerOpportunityByVolunteer() {
		User user = [
				SELECT ContactId
				FROM User
				WHERE LastName = 'Smith0'
				LIMIT 1
		];
		Test.startTest();
		VolunteerOpportunityService.findVolunteerOpportunityByVolunteer(new Set<Id>{
				user.ContactId
		});
		Test.stopTest();
	}

	@IsTest
	public static void shouldUpdateVolunteerOpportunityByVolunteerRoles() {
		List<Volunteer_Roles__c> volunteerRoles = [
				SELECT Id, Volunteer_Name__c, Chapter_Name__c, Role_Name__c, Status__c
				FROM Volunteer_Roles__c
				WHERE Status__c = :Constant_AC.VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE
		];
		Volunteer_Opportunity__c volunteerOpportunity = [
				SELECT Id, Inactive__c, Reason_Inactive__c, Status__c, Inactivated_or_Rejected_Date__c, Wish__c,
						Wish_End_Date__c, Volunteer_Name__c, RecordTypeId
				FROM Volunteer_Opportunity__c
				WHERE RecordTypeId = :Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID
				LIMIT 1
		];
		volunteerOpportunity.Status__c = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_APPROVED;
		update volunteerOpportunity;

		Map<Id, List<Volunteer_Roles__c>> volunteerRolesMap = new Map<Id, List<Volunteer_Roles__c>>();
		volunteerRolesMap.put(volunteerRoles.get(0).Volunteer_Name__c, volunteerRoles);

		Test.startTest();
		VolunteerOpportunityService.updateVolunteerOpportunityByVolunteerRoles(volunteerRolesMap);
		Test.stopTest();
	}

	@IsTest
	public static void shouldDeleteNonApprovedByNonWishEventAndRecordType() {
		Non_Wish_Events__c nonWishEvent = [
				SELECT Id
				FROM Non_Wish_Events__c
				WHERE Event_Name__c = 'Send Off 1'
				LIMIT 1
		];

		Test.startTest();
		VolunteerOpportunityService.deleteNonApprovedByNonWishEventAndRecordType(nonWishEvent.Id, Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID);
		Test.stopTest();
	}

	@IsTest
	public static void shouldDeleteNonApprovedByChapterAndNonWishEvent() {
		Non_Wish_Events__c nonWishEvent = [
				SELECT Id
				FROM Non_Wish_Events__c
				WHERE Event_Name__c = 'Send Off 1'
				LIMIT 1
		];
		Chapter_Role__c chapterRole = [
				SELECT Id
				FROM Chapter_Role__c
				WHERE Background_Check_Required__c = TRUE
				LIMIT 1
		];

		Test.startTest();
		VolunteerOpportunityService.deleteNonApprovedByChapterAndNonWishEvent(new Set<Id>{
				chapterRole.Id
		}, nonWishEvent.Id);
		Test.stopTest();
	}

	@IsTest
	public static void shouldSetFields() {
		Volunteer_Opportunity__c volunteerOpportunity = [
				SELECT Id, Inactive__c, Reason_Inactive__c, Status__c, Inactivated_or_Rejected_Date__c, Wish__c,
						Wish_End_Date__c, Volunteer_Name__c, RecordTypeId
				FROM Volunteer_Opportunity__c
				WHERE RecordTypeId = :Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID
				LIMIT 1
		];

		Map<Id, Volunteer_Opportunity__c> oldMap = new Map<Id, Volunteer_Opportunity__c>();
		oldMap.put(volunteerOpportunity.Id, volunteerOpportunity);

		Map<Id, Volunteer_Opportunity__c> newMap = new Map<Id, Volunteer_Opportunity__c>();
		Volunteer_Opportunity__c volunteerOpportunityUpdate = new Volunteer_Opportunity__c();
		volunteerOpportunityUpdate.Id = volunteerOpportunity.Id;
		volunteerOpportunityUpdate.Status__c = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_APPROVED;
		volunteerOpportunityUpdate.Inactive__c = true;
		volunteerOpportunityUpdate.Volunteer_Name__c = Utils.currentUser.ContactId;
		newMap.put(volunteerOpportunityUpdate.Id, volunteerOpportunityUpdate);

		Test.startTest();
		VolunteerOpportunityService.setFields(newMap, oldMap);
		Test.stopTest();
	}

	@IsTest
	public static void shouldUpdateUserRoleId() {
		List<Volunteer_Opportunity__c> volunteerOpportunities = [
				SELECT Id, Volunteer_Name__c
				FROM Volunteer_Opportunity__c
				WHERE RecordTypeId = :Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID
				LIMIT 1
		];

		Test.startTest();
		VolunteerOpportunityService.updateUserRoleId(volunteerOpportunities);
		Test.stopTest();
	}

	@IsTest
	public static void shouldUpdateVolunteerNeededCount() {
		List<Volunteer_Opportunity__c> volunteerOpportunities = [
				SELECT Id, Volunteer_Name__c, Chapter_Role_Opportunity__c, Non_Wish_Event__c,
						Hidden_VolunteerCount_Desc__c, Date__c, Start_Time__c, End_Time__c
				FROM Volunteer_Opportunity__c
				WHERE RecordTypeId = :Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID
				LIMIT 1
		];

		Test.startTest();
		VolunteerOpportunityService.updateVolunteerNeededCount(new Map<Id, Volunteer_Opportunity__c>(volunteerOpportunities));
		Test.stopTest();
	}

	@IsTest
	public static void shouldUpdateVolunteerRegisteredCount() {
		List<Volunteer_Opportunity__c> volunteerOpportunities = [
				SELECT Id, Volunteer_Name__c, Chapter_Role_Opportunity__c, Non_Wish_Event__c,
						Hidden_VolunteerCount_Desc__c, Date__c, Start_Time__c, End_Time__c
				FROM Volunteer_Opportunity__c
				WHERE RecordTypeId = :Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID
				LIMIT 1
		];
		volunteerOpportunities.get(0).Status__c = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_APPROVED;
		volunteerOpportunities.get(0).Inactive__c = true;
		volunteerOpportunities.get(0).Reason_Inactive__c = Constant_AC.VOLUNTEER_OPPORTUNITY_REASON_INACTIVE_NOT_APPROVED;
		update volunteerOpportunities;

		Test.startTest();
		VolunteerOpportunityService.updateVolunteerRegisteredCount(volunteerOpportunities, new Set<Id>{
				volunteerOpportunities.get(0).Id
		}, false);
		Test.stopTest();
	}

	@IsTest
	public static void shouldUpdateInactive() {
		List<Volunteer_Opportunity__c> volunteerOpportunities = [
				SELECT Id, Volunteer_Name__c, Chapter_Role_Opportunity__c, Non_Wish_Event__c,
						Hidden_VolunteerCount_Desc__c, Date__c, Start_Time__c, End_Time__c,
						Date_Time__c, Description__c, Location__c, HiddenVolunteer_Count_Description__c,
						Chapter_Name__c, Volunteer_Notes__c, Wish__c, Reason_Inactive__c, Required_Forms_for_Volunteers__c
				FROM Volunteer_Opportunity__c
				WHERE RecordTypeId = :Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID
				LIMIT 1
		];

		Test.startTest();
		VolunteerOpportunityService.updateInactive(new Map<Id, Volunteer_Opportunity__c>(volunteerOpportunities));
		Test.stopTest();
	}

	@IsTest
	public static void shouldActiveWishCount() {
		User user = [
				SELECT ContactId
				FROM User
				WHERE LastName = 'Smith0'
				LIMIT 1
		];
		Volunteer_Opportunity__c volunteerOpportunity = [
				SELECT Id
				FROM Volunteer_Opportunity__c
				WHERE Volunteer_Name__c = :user.ContactId
		];
		volunteerOpportunity.Status__c = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_APPROVED;
		update volunteerOpportunity;


		Test.startTest();
		VolunteerOpportunityService.activeWishCount(new Set<Id>{user.ContactId});
		Test.stopTest();
	}

	@IsTest
	public static void shouldSubmitApprovalProcess() {
        List<Volunteer_Opportunity__c> volunteerOpportunities = [
                SELECT Id, Chapter_Name__c, RecordTypeId
                FROM Volunteer_Opportunity__c
                WHERE Status__c = :Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_PENDING
                LIMIT 1
        ];

		Test.startTest();
		VolunteerOpportunityService.submitApprovalProcess(volunteerOpportunities);
		Test.stopTest();
	}

    @IsTest
    public static void shouldCreateCaseTeamMembers() {
        List<Volunteer_Opportunity__c> volunteerOpportunities = [
                SELECT Id, Volunteer_Name__c, Chapter_Role_Opportunity__c, Non_Wish_Event__c,
                        Hidden_VolunteerCount_Desc__c, Date__c, Start_Time__c, End_Time__c, RecordTypeId
                FROM Volunteer_Opportunity__c
                WHERE RecordTypeId = :Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID
                LIMIT 1
        ];

        Test.startTest();
        VolunteerOpportunityService.createCaseTeamMembers(volunteerOpportunities);
        Test.stopTest();
    }

    @IsTest
    public static void shouldUpdateVolunteerRegisteredCountDelete() {
        List<Volunteer_Opportunity__c> volunteerOpportunities = [
                SELECT Id, Volunteer_Name__c, Chapter_Role_Opportunity__c, Non_Wish_Event__c,
                        Hidden_VolunteerCount_Desc__c, Date__c, Start_Time__c, End_Time__c
                FROM Volunteer_Opportunity__c
                WHERE RecordTypeId = :Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID
                LIMIT 1
        ];

        volunteerOpportunities.get(0).Status__c = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_APPROVED;
        volunteerOpportunities.get(0).Inactive__c = true;
        volunteerOpportunities.get(0).Reason_Inactive__c = 'test';

        Test.startTest();
        VolunteerOpportunityService.updateVolunteerRegisteredCountDelete(new Map<Id, Volunteer_Opportunity__c>(volunteerOpportunities));
        Test.stopTest();
    }

    @IsTest
    public static void shouldShareVolunteerOpportunityRecord() {
        List<Volunteer_Opportunity__c> volunteerOpportunities = [
                SELECT Id, Volunteer_Name__c, Chapter_Role_Opportunity__c, Non_Wish_Event__c,
                        Hidden_VolunteerCount_Desc__c, Date__c, Start_Time__c, End_Time__c
                FROM Volunteer_Opportunity__c
                WHERE RecordTypeId = :Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID
                LIMIT 1
        ];

        Test.startTest();
        VolunteerOpportunityService.shareVolunteerOpportunityRecord(volunteerOpportunities);
        Test.stopTest();
    }

    @IsTest
    public static void shouldBuildVolunteerOpportunitiesByChapterMap() {
        List<Volunteer_Opportunity__c> volunteerOpportunities = [
                SELECT Id
                FROM Volunteer_Opportunity__c
                WHERE RecordTypeId = :Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID
                LIMIT 1
        ];

        Test.startTest();
        VolunteerOpportunityService.buildVolunteerOpportunitiesByChapterMap(new Set<Id>{volunteerOpportunities.get(0).Id});
        Test.stopTest();
    }

    @IsTest
    public static void shouldBuildVolunteerOpportunitiesOutOfComplianceMap() {
        Volunteer_Opportunity__c volunteerOpportunity = [
                SELECT Id, Inactive__c, Reason_Inactive__c, Status__c, Inactivated_or_Rejected_Date__c, Wish__c,
                        Wish_End_Date__c, Volunteer_Name__c, RecordTypeId
                FROM Volunteer_Opportunity__c
                WHERE RecordTypeId = :Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID
                LIMIT 1
        ];

        Map<Id, Volunteer_Opportunity__c> oldMap = new Map<Id, Volunteer_Opportunity__c>();
        volunteerOpportunity.Status__c = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_PENDING;
        oldMap.put(volunteerOpportunity.Id, volunteerOpportunity);

        Map<Id, Volunteer_Opportunity__c> newMap = new Map<Id, Volunteer_Opportunity__c>();
        Volunteer_Opportunity__c volunteerOpportunityUpdate = new Volunteer_Opportunity__c();
        volunteerOpportunityUpdate.Id = volunteerOpportunity.Id;
        volunteerOpportunityUpdate.Status__c = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_OUT_OF_COMPLIANCE;
        volunteerOpportunityUpdate.Inactive__c = true;
        volunteerOpportunityUpdate.Volunteer_Name__c = volunteerOpportunity.Volunteer_Name__c;
        newMap.put(volunteerOpportunityUpdate.Id, volunteerOpportunityUpdate);

        Test.startTest();
        VolunteerOpportunityService.buildVolunteerOpportunitiesOutOfComplianceMap(newMap, oldMap);
        Test.stopTest();
    }

    @IsTest
    public static void shouldBuildVolunteerOpportunitiesForApprovalMap() {
        Volunteer_Opportunity__c volunteerOpportunity = [
                SELECT Id, Inactive__c, Reason_Inactive__c, Status__c, Inactivated_or_Rejected_Date__c, Wish__c,
                        Wish_End_Date__c, Volunteer_Name__c, RecordTypeId
                FROM Volunteer_Opportunity__c
                WHERE RecordTypeId = :Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID
                LIMIT 1
        ];

        Map<Id, Volunteer_Opportunity__c> oldMap = new Map<Id, Volunteer_Opportunity__c>();
        oldMap.put(volunteerOpportunity.Id, volunteerOpportunity);

        Map<Id, Volunteer_Opportunity__c> newMap = new Map<Id, Volunteer_Opportunity__c>();
        Volunteer_Opportunity__c volunteerOpportunityUpdate = new Volunteer_Opportunity__c();
        volunteerOpportunityUpdate.Id = volunteerOpportunity.Id;
        volunteerOpportunityUpdate.Status__c = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_PENDING;
        volunteerOpportunityUpdate.Inactive__c = true;
        volunteerOpportunityUpdate.Volunteer_Name__c = volunteerOpportunity.Volunteer_Name__c;
        newMap.put(volunteerOpportunityUpdate.Id, volunteerOpportunityUpdate);

        Test.startTest();
        VolunteerOpportunityService.buildVolunteerOpportunitiesForApprovalMap(newMap, oldMap);
        Test.stopTest();
    }

    @IsTest
    public static void shouldBuildVolunteerApprovedOpportunitiesIds() {
        List<Volunteer_Opportunity__c> volunteerOpportunities = [
                SELECT Id, Status__c, Migrated_Record__c, Volunteer_Name__c
                FROM Volunteer_Opportunity__c
                WHERE RecordTypeId = :Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID
                LIMIT 1
        ];

        Test.startTest();
        VolunteerOpportunityService.buildVolunteerApprovedOpportunitiesIds(volunteerOpportunities);
        Test.stopTest();
    }

    @IsTest
    public static void shouldBuildVolunteerApprovedMap() {
        Volunteer_Opportunity__c volunteerOpportunity = [
                SELECT Id, Inactive__c, Reason_Inactive__c, Status__c, Inactivated_or_Rejected_Date__c, Wish__c,
                        Wish_End_Date__c, Volunteer_Name__c, RecordTypeId
                FROM Volunteer_Opportunity__c
                WHERE RecordTypeId = :Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID
                LIMIT 1
        ];

        Map<Id, Volunteer_Opportunity__c> oldMap = new Map<Id, Volunteer_Opportunity__c>();
        oldMap.put(volunteerOpportunity.Id, volunteerOpportunity);

        Map<Id, Volunteer_Opportunity__c> newMap = new Map<Id, Volunteer_Opportunity__c>();
        Volunteer_Opportunity__c volunteerOpportunityUpdate = new Volunteer_Opportunity__c();
        volunteerOpportunityUpdate.Id = volunteerOpportunity.Id;
        volunteerOpportunityUpdate.Status__c = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_PENDING;
        volunteerOpportunityUpdate.Inactive__c = true;
        volunteerOpportunityUpdate.Volunteer_Name__c = volunteerOpportunity.Volunteer_Name__c;
        newMap.put(volunteerOpportunityUpdate.Id, volunteerOpportunityUpdate);

        Test.startTest();
        VolunteerOpportunityService.buildVolunteerApprovedMap(newMap, oldMap);
        Test.stopTest();
    }

    @IsTest
    public static void shouldBuildVolunteerOpportunityVolunteerIds() {
        List<Volunteer_Opportunity__c> volunteerOpportunities = [
                SELECT Id, Inactive__c, Reason_Inactive__c, Status__c, Inactivated_or_Rejected_Date__c, Wish__c,
                        Wish_End_Date__c, Volunteer_Name__c, RecordTypeId, Non_Wish_Event__c
                FROM Volunteer_Opportunity__c
                WHERE RecordTypeId = :Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID
                LIMIT 1
        ];

        Map<Id, Volunteer_Opportunity__c> newMap = new Map<Id, Volunteer_Opportunity__c>(volunteerOpportunities);

        Test.startTest();
        VolunteerOpportunityService.buildVolunteerOpportunityVolunteerIds(newMap);
        Test.stopTest();
    }

    @IsTest
    public static void shouldBuildVolunteerOpportunityCaseTeamMemberMap() {
        Volunteer_Opportunity__c volunteerOpportunity = [
                SELECT Id, Inactive__c, Reason_Inactive__c, Status__c, Inactivated_or_Rejected_Date__c, Wish__c,
                        Wish_End_Date__c, Volunteer_Name__c, RecordTypeId
                FROM Volunteer_Opportunity__c
                WHERE RecordTypeId = :Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID
                LIMIT 1
        ];

        Map<Id, Volunteer_Opportunity__c> oldMap = new Map<Id, Volunteer_Opportunity__c>();
        volunteerOpportunity.Status__c = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_PENDING;
        oldMap.put(volunteerOpportunity.Id, volunteerOpportunity);

        Map<Id, Volunteer_Opportunity__c> newMap = new Map<Id, Volunteer_Opportunity__c>();
        Volunteer_Opportunity__c volunteerOpportunityUpdate = new Volunteer_Opportunity__c();
        volunteerOpportunityUpdate.Id = volunteerOpportunity.Id;
        volunteerOpportunityUpdate.Status__c = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_APPROVED;
        volunteerOpportunityUpdate.Inactive__c = true;
        volunteerOpportunityUpdate.Volunteer_Name__c = volunteerOpportunity.Volunteer_Name__c;
        volunteerOpportunityUpdate.Wish__c = volunteerOpportunity.Wish__c;
        volunteerOpportunityUpdate.Non_Wish_Event__c = volunteerOpportunity.Non_Wish_Event__c;
        volunteerOpportunityUpdate.Reason_Inactive__c = null;
        newMap.put(volunteerOpportunityUpdate.Id, volunteerOpportunityUpdate);

        Test.startTest();
        VolunteerOpportunityService.buildVolunteerOpportunityCaseTeamMemberMap(newMap, oldMap);
        Test.stopTest();
    }

    @IsTest
    public static void shouldBuildVolunteerOpportunityReasonInactiveMap() {
        Volunteer_Opportunity__c volunteerOpportunity = [
                SELECT Id, Inactive__c, Reason_Inactive__c, Status__c, Inactivated_or_Rejected_Date__c, Wish__c,
                        Wish_End_Date__c, Volunteer_Name__c, RecordTypeId
                FROM Volunteer_Opportunity__c
                WHERE RecordTypeId = :Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID
                LIMIT 1
        ];

        Map<Id, Volunteer_Opportunity__c> oldMap = new Map<Id, Volunteer_Opportunity__c>();
        oldMap.put(volunteerOpportunity.Id, volunteerOpportunity);

        Map<Id, Volunteer_Opportunity__c> newMap = new Map<Id, Volunteer_Opportunity__c>();
        Volunteer_Opportunity__c volunteerOpportunityUpdate = new Volunteer_Opportunity__c();
        volunteerOpportunityUpdate.Id = volunteerOpportunity.Id;
        volunteerOpportunityUpdate.Status__c = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_PENDING;
        volunteerOpportunityUpdate.Inactive__c = true;
        volunteerOpportunityUpdate.Volunteer_Name__c = volunteerOpportunity.Volunteer_Name__c;
        newMap.put(volunteerOpportunityUpdate.Id, volunteerOpportunityUpdate);

        Test.startTest();
        VolunteerOpportunityService.buildVolunteerOpportunityReasonInactiveMap(newMap, oldMap);
        Test.stopTest();
    }

    @IsTest
    public static void shouldBuildVolunteerOpportunityNonWishMap() {
        Volunteer_Opportunity__c volunteerOpportunity = [
                SELECT Id, Inactive__c, Reason_Inactive__c, Status__c, Inactivated_or_Rejected_Date__c, Wish__c,
                        Wish_End_Date__c, Volunteer_Name__c, RecordTypeId
                FROM Volunteer_Opportunity__c
                WHERE RecordTypeId = :Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID
                LIMIT 1
        ];

        Map<Id, Volunteer_Opportunity__c> oldMap = new Map<Id, Volunteer_Opportunity__c>();
        volunteerOpportunity.Status__c = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_PENDING;
        oldMap.put(volunteerOpportunity.Id, volunteerOpportunity);

        Map<Id, Volunteer_Opportunity__c> newMap = new Map<Id, Volunteer_Opportunity__c>();
        Volunteer_Opportunity__c volunteerOpportunityUpdate = new Volunteer_Opportunity__c();
        volunteerOpportunityUpdate.Id = volunteerOpportunity.Id;
        volunteerOpportunityUpdate.Status__c = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_COMPLETED;
        volunteerOpportunityUpdate.Inactive__c = true;
        volunteerOpportunityUpdate.Volunteer_Name__c = volunteerOpportunity.Volunteer_Name__c;
        volunteerOpportunityUpdate.Wish__c = volunteerOpportunity.Wish__c;
        volunteerOpportunityUpdate.Non_Wish_Event__c = volunteerOpportunity.Non_Wish_Event__c;
        volunteerOpportunityUpdate.Reason_Inactive__c = null;
        newMap.put(volunteerOpportunityUpdate.Id, volunteerOpportunityUpdate);

        Test.startTest();
        VolunteerOpportunityService.buildVolunteerOpportunityNonWishMap(newMap);
        Test.stopTest();
    }

    @IsTest
    public static void shouldBuildVolunteerOpportunitySharingMap() {
        Volunteer_Opportunity__c volunteerOpportunity = [
                SELECT Id, Inactive__c, Reason_Inactive__c, Status__c, Inactivated_or_Rejected_Date__c, Wish__c,
                        Wish_End_Date__c, Volunteer_Name__c, RecordTypeId
                FROM Volunteer_Opportunity__c
                WHERE RecordTypeId = :Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID
                LIMIT 1
        ];

        Map<Id, Volunteer_Opportunity__c> oldMap = new Map<Id, Volunteer_Opportunity__c>();
        volunteerOpportunity.Status__c = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_PENDING;
        oldMap.put(volunteerOpportunity.Id, volunteerOpportunity);

        Map<Id, Volunteer_Opportunity__c> newMap = new Map<Id, Volunteer_Opportunity__c>();
        Volunteer_Opportunity__c volunteerOpportunityUpdate = new Volunteer_Opportunity__c();
        volunteerOpportunityUpdate.Id = volunteerOpportunity.Id;
        volunteerOpportunityUpdate.Status__c = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_APPROVED;
        volunteerOpportunityUpdate.Inactive__c = true;
        volunteerOpportunityUpdate.Volunteer_Name__c = volunteerOpportunity.Volunteer_Name__c;
        volunteerOpportunityUpdate.Wish__c = volunteerOpportunity.Wish__c;
        volunteerOpportunityUpdate.Non_Wish_Event__c = volunteerOpportunity.Non_Wish_Event__c;
        volunteerOpportunityUpdate.Reason_Inactive__c = volunteerOpportunity.Reason_Inactive__c;
        newMap.put(volunteerOpportunityUpdate.Id, volunteerOpportunityUpdate);

        Test.startTest();
        VolunteerOpportunityService.buildVolunteerOpportunitySharingMap(newMap, oldMap);
        Test.stopTest();
    }

    @IsTest
    public static void shouldBuildVolunteerOpportunityUpdateInActiveWishGranterMap() {
        Volunteer_Opportunity__c volunteerOpportunity = [
                SELECT Id, Inactive__c, Reason_Inactive__c, Status__c, Inactivated_or_Rejected_Date__c, Wish__c,
                        Wish_End_Date__c, Volunteer_Name__c, RecordTypeId
                FROM Volunteer_Opportunity__c
                WHERE RecordTypeId = :Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID
                LIMIT 1
        ];

        Map<Id, Volunteer_Opportunity__c> newMap = new Map<Id, Volunteer_Opportunity__c>();
        Volunteer_Opportunity__c volunteerOpportunityUpdate = new Volunteer_Opportunity__c();
        volunteerOpportunityUpdate.Id = volunteerOpportunity.Id;
        volunteerOpportunityUpdate.Status__c = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_PENDING;
        volunteerOpportunityUpdate.Inactive__c = true;
        volunteerOpportunityUpdate.Volunteer_Name__c = volunteerOpportunity.Volunteer_Name__c;
        volunteerOpportunityUpdate.Reason_Inactive__c = 'test';
        volunteerOpportunityUpdate.Wish__c = volunteerOpportunity.Wish__c;
        newMap.put(volunteerOpportunityUpdate.Id, volunteerOpportunityUpdate);

        Test.startTest();
        VolunteerOpportunityService.buildVolunteerOpportunityUpdateInActiveWishGranterMap(newMap);
        Test.stopTest();
    }

    @IsTest
    public static void shouldBuildVolunteerOpportunityNonWishListToUpdateMap() {
        Volunteer_Opportunity__c volunteerOpportunity = [
                SELECT Id, Inactive__c, Reason_Inactive__c, Status__c, Inactivated_or_Rejected_Date__c, Wish__c,
                        Wish_End_Date__c, Volunteer_Name__c, RecordTypeId, Non_Wish_Event__c, Hidden_VolunteerCount_Desc__c
                FROM Volunteer_Opportunity__c
                WHERE RecordTypeId = :Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID
                LIMIT 1
        ];

        Map<Id, Volunteer_Opportunity__c> newMap = new Map<Id, Volunteer_Opportunity__c>();
        Volunteer_Opportunity__c volunteerOpportunityUpdate = new Volunteer_Opportunity__c();
        volunteerOpportunityUpdate.Id = volunteerOpportunity.Id;
        volunteerOpportunityUpdate.Status__c = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_PENDING;
        volunteerOpportunityUpdate.Inactive__c = true;
        volunteerOpportunityUpdate.Volunteer_Name__c = volunteerOpportunity.Volunteer_Name__c;
        volunteerOpportunityUpdate.Non_Wish_Event__c = volunteerOpportunity.Non_Wish_Event__c;
        volunteerOpportunityUpdate.Reason_Inactive__c = volunteerOpportunity.Reason_Inactive__c;
        volunteerOpportunityUpdate.Hidden_VolunteerCount_Desc__c = volunteerOpportunity.Hidden_VolunteerCount_Desc__c;
        newMap.put(volunteerOpportunityUpdate.Id, volunteerOpportunityUpdate);

        Test.startTest();
        VolunteerOpportunityService.buildVolunteerOpportunityNonWishListToUpdateMap(newMap);
        Test.stopTest();
    }

    @IsTest
    public static void shouldBuildVolunteerOpportunityNonRegisteredMap() {
        Volunteer_Opportunity__c volunteerOpportunity = [
                SELECT Id, Inactive__c, Reason_Inactive__c, Status__c, Inactivated_or_Rejected_Date__c, Wish__c,
                        Wish_End_Date__c, Volunteer_Name__c, RecordTypeId, Non_Wish_Event__c, Hidden_VolunteerCount_Desc__c
                FROM Volunteer_Opportunity__c
                WHERE RecordTypeId = :Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID
                LIMIT 1
        ];

        Map<Id, Volunteer_Opportunity__c> newMap = new Map<Id, Volunteer_Opportunity__c>();
        Volunteer_Opportunity__c volunteerOpportunityUpdate = new Volunteer_Opportunity__c();
        volunteerOpportunityUpdate.Id = volunteerOpportunity.Id;
        volunteerOpportunityUpdate.Status__c = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_PENDING;
        volunteerOpportunityUpdate.Inactive__c = true;
        volunteerOpportunityUpdate.Volunteer_Name__c = volunteerOpportunity.Volunteer_Name__c;
        volunteerOpportunityUpdate.Non_Wish_Event__c = volunteerOpportunity.Non_Wish_Event__c;
        volunteerOpportunityUpdate.Hidden_VolunteerCount_Desc__c = volunteerOpportunity.Hidden_VolunteerCount_Desc__c;
        newMap.put(volunteerOpportunityUpdate.Id, volunteerOpportunityUpdate);

        Test.startTest();
        VolunteerOpportunityService.buildVolunteerOpportunityNonRegisteredMap(newMap);
        Test.stopTest();
    }
}