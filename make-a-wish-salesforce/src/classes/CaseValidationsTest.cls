/**
 * @description
 * @author Steve Doucette, Traction on Demand
 * @date 5/27/2020
 */
@IsTest
private class CaseValidationsTest {

    @TestSetup
    static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;

        insert new Closed_Case_Editing_Security_Settings__c(SetupOwnerId = UserInfo.getUserId(), Restrict_Access__c = true);
        insert new UserSetting__c(SetupOwnerId = UserInfo.getUserId());

        Account account = TestDataFactory.createAccount(1)[0];
        insert account;

        Contact wishChild = TestDataFactory.createContact(1)[0];
        wishChild.AccountId = account.Id;
        insert wishChild;

        Case validationCase = TestDataFactory.createCase(1)[0];
        validationCase.RecordTypeId = Constant_AC.WISH_RT_ID;
        validationCase.ContactId = wishChild.Id;
        validationCase.AccountId = account.Id;
        insert validationCase;

        trac_TriggerHandlerBase.blockTrigger = false;
    }

    @IsTest
    static void testWishTypeNull() {
        Case newCase = getTestCase();
        Case oldCase = newCase.clone(true, true, true, true);
        newCase.Status = Constant_AC.CASE_STATUS_WISH_DETERMINED;

        CaseValidations.beforeUpdateValidations(newCase, oldCase);
    }

    @IsTest
    static void testReopenCase() {
        Case newCase = getTestCase();
        Case oldCase = newCase.clone(true, true, true, true);
        oldCase.Status = Constant_AC.CASE_STATUS_CLOSED;
        newCase.Status = Constant_AC.CASE_STATUS_NEW;

        CaseValidations.beforeUpdateValidations(newCase, oldCase);
    }

    @IsTest
    static void testLockedAdoptableCase() {
        Case newCase = getTestCase();
        Case oldCase = newCase.clone(true, true, true, true);
        newCase.IsLocked__c = oldCase.IsLocked__c = true;
        newCase.Status = Constant_AC.CASE_STATUS_CLOSED;
        newCase.Closed_Date__c = Date.today();
        newCase.Adopted_By__c = 'Smiths';

        trac_TriggerHandlerBase.blockTrigger = true;
        update newCase;
        trac_TriggerHandlerBase.blockTrigger = false;

        Boolean valid = CaseValidations.beforeUpdateValidations(getTestCase(), oldCase);
        System.assertEquals(false, valid);
    }

    @IsTest
    static void testNoEditPermission() {
        Case newCase = getTestCase();
        Case oldCase = newCase.clone(true, true, true, true);
        newCase.IsLocked__c = oldCase.IsLocked__c = true;
        newCase.Status = Constant_AC.CASE_STATUS_CLOSED;
        newCase.Closed_Date__c = Date.today();

        trac_TriggerHandlerBase.blockTrigger = true;
        update newCase;
        UserSetting__c usc = UserSetting__c.getInstance();
        usc.All_Closed_Cases_except_Abandoned__c = true;
        update usc;
        trac_TriggerHandlerBase.blockTrigger = false;

        Boolean valid = CaseValidations.beforeUpdateValidations(getTestCase(), oldCase);
        System.assertEquals(false, valid);
    }

    @IsTest
    static void testLockedAndAdopted() {
        Case newCase = getTestCase();
        Case oldCase = newCase.clone(true, true, true, true);
        newCase.IsLocked__c = oldCase.IsLocked__c = true;
        newCase.Adopted_By__c = 'Smiths';
        oldCase.Status = Constant_AC.CASE_STATUS_CLOSED;
        newCase.Closed_Date__c = Date.today();

        trac_TriggerHandlerBase.blockTrigger = true;
        update oldCase;
        UserSetting__c usc = UserSetting__c.getInstance();
        usc.All_Closed_Cases_except_Abandoned__c = true;
        usc.Edit_Abandoned_Cases__c = true;
        update usc;
        trac_TriggerHandlerBase.blockTrigger = false;

        Boolean valid = CaseValidations.beforeUpdateValidations(newCase, getTestCase());
        System.assertEquals(false, valid);
    }

    @IsTest
    static void testAbandonedError() {
        Case newCase = getTestCase();
        Case oldCase = newCase.clone(true, true, true, true);
        newCase.Sub_Status__c = Constant_AC.CASE_SUB_STATUS_ABANDONED;
        oldCase.Status = Constant_AC.CASE_STATUS_GRANTED;

        Boolean valid = CaseValidations.beforeUpdateValidations(newCase, oldCase);
        System.assertEquals(false, valid);
    }

    @IsTest
    static void testPass() {
        Case newCase = getTestCase();
        Case oldCase = newCase.clone(true, true, true, true);

        Boolean valid = CaseValidations.beforeUpdateValidations(newCase, oldCase);
        System.assertEquals(true, valid);
    }

    private static Case getTestCase() {
        return [
                SELECT Id, AccountId, ContactId, Status, RecordTypeId, IsClosed,
                        Wish_Type__c, IsLocked__c, Sub_Status__c,
                        Adopted_By__c, Adopted__c, Adoptable__c
                FROM Case
        ];
    }
}