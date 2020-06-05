/**
 * @description
 *
 * @author Steve Doucette, Traction on Demand
 *
 * @date 5/27/2020
 */
@IsTest
private class CaseTeamMemberServiceTest {

    private static final Integer NUM_RECORDS = 3; // Number of records to query/create

    @TestSetup
    static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;

        Account account = TestDataFactory.createAccount(1)[0];
        insert account;

        Contact wishChild = TestDataFactory.createContact(1)[0];
        wishChild.AccountId = account.Id;
        insert wishChild;

        Case wishCase = TestDataFactory.createCase(1)[0];
        wishCase.AccountId = account.Id;
        wishCase.ContactId = wishChild.Id;
        insert wishCase;

        CaseTeamRole ctr = new CaseTeamRole(AccessLevel = 'Edit', Name = 'Test');
        CaseTeamRole ctrInactive = new CaseTeamRole(AccessLevel = 'Edit', Name = 'Test ' + CaseTeamMemberService.INACTIVE);
        System.runAs(Utils.currentUser) {
            insert new List<CaseTeamRole>{
                    ctr, ctrInactive
            };
        }

        List<User> users = getCommunityUsers(NUM_RECORDS);
        List<CaseTeamMember> caseTeamMembers = TestDataFactory.createCaseTeamMember(NUM_RECORDS);
        for (Integer i = 0; i < NUM_RECORDS; i++) {
            caseTeamMembers[i].ParentId = wishCase.Id;
            caseTeamMembers[i].MemberId = users[i].Id;
            if (Math.mod(i, 2) == 0) {
                caseTeamMembers[i].TeamRoleId = ctr.Id;
            } else {
                caseTeamMembers[i].TeamRoleId = ctrInactive.Id;
            }
        }
        insert caseTeamMembers;

        trac_TriggerHandlerBase.blockTrigger = false;
    }

    @IsTest
    static void testUpdateInactiveCaseTeamMember() {
        Case wishCase = getCase();
        Map<Id, User> communityUsersMap = new Map<Id, User>(getCommunityUsers(NUM_RECORDS));
        Map<Id, Id> inactiveWishVolunteerIdMap = new Map<Id, Id>();
        for (User u : communityUsersMap.values()) {
            inactiveWishVolunteerIdMap.put(wishCase.Id, u.ContactId);
        }

        Test.startTest();
        List<CaseTeamMember> result = CaseTeamMemberService.updateInactiveCaseTeamMember(new Map<Id, Id>(), new Map<Id, Set<String>>());
        List<CaseTeamMember> result2 = CaseTeamMemberService.updateInactiveCaseTeamMember(inactiveWishVolunteerIdMap, new Map<Id, Set<String>>{
                wishCase.Id => new Set<String>()
        });
        Test.stopTest();
        System.assertEquals(true, result.isEmpty());
        System.assertEquals(true, result2.isEmpty());
    }

    @IsTest
    static void testUpdateTeamRoleId() {
        Case wishCase = getCase();
        Map<Id, User> communityUsersMap = new Map<Id, User>(getCommunityUsers(NUM_RECORDS - 1));
        CaseTeamRole ctr;
        CaseTeamRole ctrInactive;
        for (CaseTeamRole caseTeamRole : [
                SELECT Id, Name
                FROM CaseTeamRole
                WHERE Name LIKE 'Test%'
        ]) {
            if (caseTeamRole.Name == 'Test') {
                ctr = caseTeamRole;
            } else if (caseTeamRole.Name == 'Test ' + CaseTeamMemberService.INACTIVE) {
                ctrInactive = caseTeamRole;
            }
        }

        Set<Id> wishIds = new Set<Id>{
                wishCase.Id
        };
        Map<Id, String> caseTeamMap = new Map<Id, String>{
                ctr.Id => 'Test'
        };
        Map<Id, String> volunteerOpMap = new Map<Id, String>();
        Map<String, Id> caseTeamNameMap = new Map<String, Id>{
                'Test' => ctr.Id,
                'Test ' + CaseTeamMemberService.INACTIVE => ctrInactive.Id
        };
        Map<Id, Id> contactUserMap = new Map<Id, Id>();
        for (User u : communityUsersMap.values()) {
            contactUserMap.put(u.Id, u.ContactId);
            volunteerOpMap.put(u.ContactId, 'Test');
        }

        Test.startTest();
        Set<Id> result = CaseTeamMemberService.updateTeamRoleId(wishIds, communityUsersMap.keySet(), caseTeamMap, contactUserMap, volunteerOpMap, caseTeamNameMap);
        Set<Id> result2 = CaseTeamMemberService.updateTeamRoleId(wishIds, communityUsersMap.keySet(), caseTeamMap, contactUserMap, new Map<Id, String>(), caseTeamNameMap);
        Test.stopTest();

        System.assertEquals(false, result.isEmpty());
        System.assertEquals(false, result2.isEmpty());
    }

    @IsTest
    static void testFindByTeamRoleNamesAndParentIdsAndMemberIds() {
        Case wishCase = getCase();

        Test.startTest();
        Map<Id, User> userMap = new Map<Id, User>(getUsers(NUM_RECORDS - 1));
        Map<Id, Id> result = CaseTeamMemberService.findByTeamRoleNamesAndParentIdsAndMemberIds(new Set<String>{
                'Test'
        }, new Set<Id>{
                wishCase.Id
        }, userMap.keySet());
        Test.stopTest();

        System.assertEquals(false, result.isEmpty());
    }

    private static List<User> getUsers(Integer numRecords) {
        return [
                SELECT Id
                FROM User
                WHERE Id != :UserInfo.getUserId() AND IsActive = TRUE AND Profile.Name = 'System Administrator'
                ORDER BY CreatedDate
                LIMIT :numRecords
        ];
    }

    private static List<User> getCommunityUsers(Integer numRecords) {
        return [
                SELECT Id, ContactId
                FROM User
                WHERE ContactId != NULL
                ORDER BY CreatedDate
        ];
    }

    private static Case getCase() {
        return [
                SELECT Id
                FROM Case
        ];
    }
}