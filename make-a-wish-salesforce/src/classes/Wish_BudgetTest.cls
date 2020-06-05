/**
 * @description Wish Budget Test Class
 * @author Mitali Nahar, Traction on Demand
 * @date 8/22/2019
 */
@IsTest
public with sharing class Wish_BudgetTest {

    private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;
    private final static Id WISH_RECORD_TYPE_ID = Constant_AC.WISH_RT_ID;
    private final static Id WISH_FAMILY_RECORD_TYPE_ID = Constant_AC.WISH_FAMILY_RT_ID;
    private final static Id HOUSEHOLD_RECORD_TYPE_ID = Constant_AC.HOUSEHOLD_RT_ID;
    private final static Id WISH_CHILD_RECORD_TYPE_ID = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
    private final static Id MEDICAL_PROF_RECORD_TYPE_ID = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;

    @TestSetup
    private static void insertTestData() {
        trac_TriggerHandlerBase.blockTrigger = true;

        List<Account> accountsDataFactory = TestDataFactory.createAccount(2);
        accountsDataFactory[0].RecordTypeId = HOUSEHOLD_RECORD_TYPE_ID;
        accountsDataFactory[1].RecordTypeId = CHAPTER_RECORD_TYPE_ID ;
        insert accountsDataFactory;

        ICD_Codes__c obj = new ICD_Codes__c();
        obj.Name = 'Q917';
        insert obj;
        List<Contact> contactsDataFactory = TestDataFactory.createContact(4);
        contactsDataFactory[0].RecordTypeId = WISH_CHILD_RECORD_TYPE_ID;
        contactsDataFactory[0].ICD_10_Code__c = obj.Id;
        contactsDataFactory[1].RecordTypeId = WISH_FAMILY_RECORD_TYPE_ID;
        contactsDataFactory[1].Birthdate = System.today().addYears(-20);
        contactsDataFactory[2].RecordTypeId = MEDICAL_PROF_RECORD_TYPE_ID;
        contactsDataFactory[3].RecordTypeId = WISH_FAMILY_RECORD_TYPE_ID;
        contactsDataFactory[3].Birthdate = System.today().addYears(-10);
        insert contactsDataFactory;

        List<Case> casesDataFactory = TestDataFactory.createCase(1);
        casesDataFactory[0].RecordTypeId = WISH_RECORD_TYPE_ID;
        casesDataFactory[0].ChapterName__c = accountsDataFactory[1].Id;
        casesDataFactory[0].AccountId = accountsDataFactory[0].Id;
        casesDataFactory[0].ContactId = contactsDataFactory[0].Id;
        casesDataFactory[0].Origin = 'Email';
        casesDataFactory[0].Status = 'Qualified';
        insert casesDataFactory;

        List<Wish_Budget__c> wishBudgetList = new List<Wish_Budget__c>();
        for (Wish_Budget__c objBud : TestDataFactory.createWishBudget(5, casesDataFactory[0].Id)) {
            objBud.Is_Active_Budget__c = true;
            wishBudgetList.add(objBud);
        }
        insert wishBudgetList;

        List<Wish_Expense__c> wishExpenseList = TestDataFactory.createWishExpense(1, wishBudgetList[0].Id);
        wishExpenseList[0].Case__c = casesDataFactory[0].Id;
        wishExpenseList[0].FE_Posted_Cash__c = 100;
        wishExpenseList[0].RecordTypeId = Schema.SObjectType.Wish_Expense__c.getRecordTypeInfosByDeveloperName().get('Finance').getRecordTypeId();
        insert wishExpenseList;

        trac_TriggerHandlerBase.blockTrigger = false;
    }

    @IsTest
    public static void deActivateBudgetsTest() {
        Case wishCase = [
                SELECT Id
                FROM Case
                LIMIT 1
        ];
        System.assertEquals(true, wishCase != null);
        Test.startTest();
        List<Wish_Budget__c> wishBudgetList = TestDataFactory.createWishBudget(1, wishCase.Id);
        wishBudgetList[0].Is_Active_Budget__c = true;
        insert wishBudgetList;
        Test.stopTest();
        List<Wish_Budget__c> wishBudgets = [
                SELECT Id, Is_Active_Budget__c
                FROM Wish_Budget__c
                WHERE Id NOT IN :wishBudgetList
        ];
        System.assertEquals(false, wishBudgets[2].Is_Active_Budget__c);
    }

    @IsTest
    public static void updateWishExpenseTest() {
        Case wishCase = [
                SELECT Id
                FROM Case
                LIMIT 1
        ];
        System.assertEquals(true, wishCase != null);
        Test.startTest();
        List<Wish_Budget__c> wishBudgetList = TestDataFactory.createWishBudget(1, wishCase.Id);
        wishBudgetList[0].Is_Active_Budget__c = true;
        insert wishBudgetList;
        Test.stopTest();
        List<Wish_Expense__c> wishExpenses = [
                SELECT Id
                FROM Wish_Expense__c
                WHERE Wish_Budget__c IN :wishBudgetList
        ];
        System.assertEquals(1, wishExpenses.size());
    }

    @IsTest
    public static void updateExpensesToApprovedTest() {
        List<Wish_Expense__c> wishExpenses = [
                SELECT Id,Wish_Budget__r.Budget_Approval_Status__c
                FROM Wish_Expense__c
        ];
        wishExpenses[0].Projected_Cash__c = 0;
        wishExpenses[0].Budget_Cash__c = 100;
        wishExpenses[0].Projected_In_Kind__c = 0;
        wishExpenses[0].Budget_In_Kind__c = 200;
        wishExpenses[0].Projected_Approval_Status__c = 'Submitted';
        update wishExpenses;
        Test.startTest();
        Wish_Budget__c budgets = [
                SELECT Id, Budget_Approval_Status__c
                FROM Wish_Budget__c
                LIMIT 1
        ];
        budgets.Budget_Approval_Status__c = 'Approved';
        update budgets;
        Test.stopTest();
        List<Wish_Expense__c> updatedwishExpenses = [
                SELECT Projected_Cash__c
                FROM Wish_Expense__c
        ];
        System.assertEquals(100, updatedwishExpenses[0].Projected_Cash__c);
    }

    @IsTest
    public static void coverEmptyList() {
        Wish_Budget__c budget = [
                SELECT Id, Budget_Approval_Status__c, Is_Active_Budget__c, Wish_Case__c
                FROM Wish_Budget__c
                LIMIT 1
        ];
        budget.Id = null;
        budget.Is_Active_Budget__c = false;
        insert budget;
    }
}