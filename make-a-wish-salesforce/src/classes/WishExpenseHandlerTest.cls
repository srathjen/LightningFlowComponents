/**
 * @description Wish Expense Handler Test Class
 * @author Mitali Nahar, Traction on Demand
 * @createdDate 9/9/2019
 */
@IsTest
public with sharing class WishExpenseHandlerTest {
    private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;
    private final static Id WISH_RECORD_TYPE_ID = Constant_AC.WISH_RT_ID;
    private final static Id WISH_FAMILY_RECORD_TYPE_ID = Constant_AC.WISH_FAMILY_RT_ID;
    private final static Id HOUSEHOLD_RECORD_TYPE_ID = Constant_AC.HOUSEHOLD_RT_ID;
    private final static Id WISH_CHILD_RECORD_TYPE_ID = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
    private final static Id MEDICAL_PROF_RECORD_TYPE_ID = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;

    @TestSetup
    private static void insertTestData() {
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
        insert contactsDataFactory;

        List<Case> casesDataFactory = TestDataFactory.createCase(1);
        casesDataFactory[0].RecordTypeId = WISH_RECORD_TYPE_ID;
        casesDataFactory[0].ChapterName__c = accountsDataFactory[1].Id;
        casesDataFactory[0].AccountId = accountsDataFactory[0].Id;
        casesDataFactory[0].ContactId = contactsDataFactory[0].Id;
        casesDataFactory[0].Origin = 'Email';
        casesDataFactory[0].Status = 'Qualified';
        insert casesDataFactory;

        List<Wish_Expense_Type__c> wishExpTypeList = TestDataFactory.createWishExpenseTypes(1, 'Airfare');
        insert wishExpTypeList;

        List<Wish_Expense_Transaction_Code__c> wishExpTransCode = TestDataFactory.createWishTransCodes(1, 'Airfare Westjet');
        wishExpTransCode[0].Wish_Expense_Type__c = wishExpTypeList[0].Id;
        insert wishExpTransCode;

    }

    @isTest
    public static void testUpdateWishExpense(){
        
        List<Case> casesDataFactory = [SELECT Id FROM Case ];
        List<Wish_Expense_Transaction_Code__c> wishExpTrans = [SELECT Id FROM Wish_Expense_Transaction_Code__c ];
        List<Wish_Budget__c> wishBudgetList = TestDataFactory.createWishBudget(5,casesDataFactory[0].Id);
        insert wishBudgetList;
        Test.startTest();
        List<Wish_Expense__c> wishExpenseList = TestDataFactory.createWishExpense(1,wishBudgetList[0].Id );
        wishExpenseList[0].Case__c = casesDataFactory[0].Id;
        wishExpenseList[0].FE_Posted_Cash__c = 100;
        wishExpenseList[0].Wish_Expense_Transaction_Code__c = wishExpTrans[0].Id;
        wishExpenseList[0].RecordTypeId = Constant_AC.WISH_EXPENSE_RT_FINANCE;
        insert wishExpenseList;
        Test.stopTest();
        List<Wish_Expense__c> wishExpenses = [SELECT Id, Hidden_Wish_Expense_Type__c  FROM Wish_Expense__c ];
        System.assertEquals(true, wishExpenses[0].Hidden_Wish_Expense_Type__c!= null);
    }

    @isTest
    public static void testPopulateWishBudget(){

        List<Case> casesDataFactory = [SELECT Id FROM Case ];
        List<Wish_Expense_Transaction_Code__c> wishExpTrans = [SELECT Id FROM Wish_Expense_Transaction_Code__c ];
        Test.startTest();
        List<Wish_Expense__c> wishExpList = TestDataFactory.createWishExpense(1,null );
        wishExpList[0].FE_Posted_Cash__c = 10;
        wishExpList[0].Wish_Expense_Transaction_Code__c = wishExpTrans[0].Id;
        wishExpList[0].RecordTypeId = Constant_AC.WISH_EXPENSE_RT_FINANCE;
        wishExpList[0].Case__c = casesDataFactory[0].Id;
        insert wishExpList;

        List<Wish_Budget__c> wishBudgetList = TestDataFactory.createWishBudget(5,casesDataFactory[0].Id);
        insert wishBudgetList;

        List<Wish_Expense__c> wishExpenseList = TestDataFactory.createWishExpense(2,wishBudgetList[0].Id );
        wishExpenseList[0].FE_Posted_Cash__c = 100;
        wishExpenseList[0].Wish_Expense_Transaction_Code__c = wishExpTrans[0].Id;
        wishExpenseList[0].RecordTypeId = Constant_AC.WISH_EXPENSE_RT_FINANCE;
        wishExpenseList[1].FE_Posted_Cash__c = 200;
        wishExpenseList[1].Wish_Expense_Transaction_Code__c = wishExpTrans[0].Id;
        wishExpenseList[1].RecordTypeId = Constant_AC.WISH_EXPENSE_RT_FINANCE;
        wishExpenseList[1].Wish_Budget__c = null;
        wishExpenseList[1].Case__c = casesDataFactory[0].Id;
        insert wishExpenseList;


        Test.stopTest();
        List<Wish_Expense__c> wishExpenses = [SELECT Id, Case__c  FROM Wish_Expense__c WHERE FE_Posted_Cash__c = 100];
        System.assertEquals(true, wishExpenses[0].Case__c!= null);
        List<Wish_Expense__c> wishExpensesList = [SELECT Id, Wish_Budget__c  FROM Wish_Expense__c WHERE FE_Posted_Cash__c = 200];
        System.assertEquals(true, wishExpensesList[0].Wish_Budget__c!= null);
        List<Wish_Expense__c> wishExp = [SELECT Id, Wish_Budget__c  FROM Wish_Expense__c WHERE FE_Posted_Cash__c = 10];
        System.assertEquals(true, wishExp[0].Wish_Budget__c!= null);
    }

}