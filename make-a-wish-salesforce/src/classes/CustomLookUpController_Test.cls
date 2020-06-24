@isTest
public class CustomLookUpController_Test {
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
        accountsDataFactory[1].RecordTypeId = CHAPTER_RECORD_TYPE_ID  ;  
        accountsDataFactory[1].Name = 'Make-A-Wish-Arizona';
        accountsDataFactory[1].Email__c = 'MAW.Arizona.Test@wish.org';
        insert accountsDataFactory;
        
        Condition_Description__c conditionMelanoma = TestDataFactory.createConditionDescription(1)[0];
        conditionMelanoma.Name = 'Malignant Melanoma';
        conditionMelanoma.Treatment_Subspecialty__c = 'Oncology';
        conditionMelanoma.Code_To_Use__c = 'C43.30';
        conditionMelanoma.PR_Diagnosis__c = 'Malignant Melanoma';
        conditionMelanoma.Group1__c = true;
        conditionMelanoma.Not_Listed__c = true;
        conditionMelanoma.InActive__c = false;
        insert conditionMelanoma;
        
        List<ICD_Codes__c> icdCodeList = TestDataFactory.createIcdCode(1);
        icdCodeList[0].Name = 'C43.30';
        icdCodeList[0].Condition_Description__c = conditionMelanoma.Id;
        icdCodeList[0].Short_Description__c = 'Malignant Melanoma';
        insert icdCodeList;
        
        List<Contact> contactsDataFactory = TestDataFactory.createContact(4);
        contactsDataFactory[0].RecordTypeId = WISH_CHILD_RECORD_TYPE_ID;
        contactsDataFactory[0].ICD_10_Code__c = icdCodeList[0].Id;
        contactsDataFactory[1].RecordTypeId = WISH_FAMILY_RECORD_TYPE_ID;
        contactsDataFactory[1].BirthDate = System.today().addYears(-20);
        contactsDataFactory[2].RecordTypeId = MEDICAL_PROF_RECORD_TYPE_ID;
        contactsDataFactory[3].RecordTypeId = WISH_FAMILY_RECORD_TYPE_ID;
        contactsDataFactory[3].BirthDate = System.today().addYears(-10);
        contactsDataFactory[3].FirstName = 'William';
        contactsDataFactory[3].LastName = 'Buckley';
        insert  contactsDataFactory;
        
        List<Case> casesDataFactory = TestDataFactory.createCase(1);
        casesDataFactory[0].RecordTypeId = WISH_RECORD_TYPE_ID;
        casesDataFactory[0].ChapterName__c =  accountsDataFactory[1].Id;
        casesDataFactory[0].AccountId =  accountsDataFactory[0].Id;
        casesDataFactory[0].ContactId =  contactsDataFactory[0].Id;
        casesDataFactory[0].Origin = 'Email';
        casesDataFactory[0].Status = 'Qualified';
        insert casesDataFactory;
        
        List<Wish_Affiliation__c> wishAffiliationsDataFactory = TestDataFactory.createWishAffiliation(2);
        wishAffiliationsDataFactory[0].Contact__c = contactsDataFactory[1].Id;
        wishAffiliationsDataFactory[0].Wish_Affiliation_Type__c = 'Approved Participant' ;
        wishAffiliationsDataFactory[0].Wish__c = casesDataFactory[0].Id;
        wishAffiliationsDataFactory[1].Contact__c = contactsDataFactory[3].Id;
        wishAffiliationsDataFactory[1].Wish_Affiliation_Type__c = 'Approved Participant' ;
        wishAffiliationsDataFactory[1].Wish__c = casesDataFactory[0].Id;
        insert wishAffiliationsDataFactory;
        
        List<Wish_Signature_Forms__c> wishSignFormsDataFactory  = TestDataFactory.createWishSignatureForm(2);
        wishSignFormsDataFactory[0].Form_Type__c = 'Medical';
        wishSignFormsDataFactory[1].Form_Type__c = 'Family';
        insert wishSignFormsDataFactory;
        
        List<Wish_Signature_Chapter_Form__c> wishSignChapFormsDataFactory = TestDataFactory.createWishSignatureChapterForm(1);
        wishSignChapFormsDataFactory[0].Chapter_Account__c = accountsDataFactory[1].Id;
        wishSignChapFormsDataFactory[0].Wish_Signature_Form__c = wishSignFormsDataFactory[0].Id;
        insert wishSignChapFormsDataFactory;
        trac_TriggerHandlerBase.blockTrigger = false;
    }
    
    @isTest
    public static void testWishSignature() {
        Test.startTest();
        Case wishCase = [SELECT Id FROM Case LIMIT 1];
        System.assertEquals(true, wishCase != null);
        List<sObject> objList = customLookUpController.fetchLookUpValues('Medical', 'Wish_Signature_Forms__c', new List<String>(), wishCase.Id, 'Medical');
        System.assertEquals(true, !objList.isEmpty());
        List<sObject> objListFamily = customLookUpController.fetchLookUpValues('Family', 'Wish_Signature_Forms__c', new List<String>(), wishCase.Id, 'Family');
        Test.stopTest();
    }
    
    @isTest
    public static void testContact() {
        Test.startTest();
        Case wishCase = [SELECT Id FROM Case LIMIT 1];
        system.assertEquals(true, wishCase != null);
        List<sObject> objList = customLookUpController.fetchLookUpValues('John','Contact', new List<String>(), wishCase.Id, 'Family');
        List<sObject> objContactMedicalList = customLookUpController.fetchLookUpValues('John','Contact', new List<String>(), wishCase.Id, 'Medical');
        System.assertEquals(true, !objList.isEmpty());
        
        List<String> additionalAttributes = new List<String>();
        additionalAttributes.add('Email');
        additionalAttributes.add('Phone');
        List<sObject> objContactList = customLookUpController.fetchLookUpValues('William','Contact', additionalAttributes, null, '');
        System.assertEquals(true, !objContactList.isEmpty());
        Test.stopTest();
    }
    
    @isTest
    public static void testSobjectLookup() {
        Test.startTest();
        List<String> additionalAttributes = new List<String>();
        additionalAttributes.add('Email__c');
        List<sObject> objAccountList = customLookUpController.fetchLookUpValues('Make-A-Wish','Account', additionalAttributes, null, '');
        System.assertEquals(true, !objAccountList.isEmpty());
        Test.stopTest();
    }
    
    @isTest
    public static void testConditionDescription() {
        Test.startTest();
        List<String> additionalAttributes = new List<String>();
        additionalAttributes.add('Inactive__c');
        Condition_Description__c returnValue = (Condition_Description__c)customLookUpController.fetchLookUpValues('Malignant','Condition_Description__c', additionalAttributes, null, '')[0];
        Test.stopTest();
        System.assert(returnValue.Inactive__c == false);
    }
    
    @isTest
    public static void testIcdCode() {
        Test.startTest();
        List<String> additionalAttributes = new List<String>();
        additionalAttributes.add('Short_Description__c');
        ICD_Codes__c returnCode = (ICD_Codes__c)customLookUpController.fetchLookUpValues('C43','ICD_Codes__c', additionalAttributes, null, '')[0];
        Test.stopTest();
        System.assert(returnCode.Short_Description__c == 'Malignant Melanoma');
    }
}