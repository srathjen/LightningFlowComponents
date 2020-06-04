/**
 * @description Wish Budget Controller Test Class
 * @author Mitali Nahar, Traction on Demand
 * @createdDate 9/6/2019
 */
@IsTest
public with sharing class wishBudgetsControllerTest {

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

        List<Wish_Budget__c> budgetList = TestDataFactory.createWishBudget(1, casesDataFactory[0].Id);
        insert budgetList;
    }

    @IsTest
    public static void testgetWish() {
        Test.startTest();
        Wish_Budget__c wishBudget = [SELECT Id FROM Wish_Budget__c LIMIT 1];
        System.assertEquals(true, wishBudget != null);
        Id caseId = WishBudgetsController.getWishId(wishBudget.Id);
        System.assertEquals(true, caseId != null);
        Id caseIdnull = WishBudgetsController.getWishId(null);
        System.assertEquals(true, caseIdnull == null);
        String baseURL =  WishBudgetsController.getBaseOrgURL();
        System.assertEquals(false, baseURL == null);
        Test.stopTest();
    }
    
    @IsTest
    public static void testException() {
        Account acc = [
            SELECT Id 
            FROM Account 
            LIMIT 1
        ];
        String errorMsg = '';
        test.startTest();
        try {
            WishBudgetsController.getWishId(acc.Id);
        } catch(Exception e) {
            errorMsg = e.getMessage();
        }
        test.stopTest();
        System.assert(String.isNotEmpty(errorMsg));
    }
}