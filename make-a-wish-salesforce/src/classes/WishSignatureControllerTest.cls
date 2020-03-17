/* 
* @Description Test class for WishSignatureController
* @author Mitali Nahar, Traction on Demand
* @Date 2019-06-29
*/

@IsTest
private class WishSignatureControllerTest {

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

        List<Wish_Affiliation__c> wishAffiliationsDataFactory = TestDataFactory.createWishAffiliation(3);
        wishAffiliationsDataFactory[0].Contact__c = contactsDataFactory[1].Id;
        wishAffiliationsDataFactory[0].Wish_Affiliation_Type__c = 'Approved Participant' ;
        wishAffiliationsDataFactory[0].Wish__c = casesDataFactory[0].Id;
        wishAffiliationsDataFactory[1].Contact__c = contactsDataFactory[3].Id;
        wishAffiliationsDataFactory[1].Wish_Affiliation_Type__c = 'Approved Participant' ;
        wishAffiliationsDataFactory[1].Wish__c = casesDataFactory[0].Id;
        wishAffiliationsDataFactory[2].Contact__c = contactsDataFactory[2].Id;
        wishAffiliationsDataFactory[2].Wish_Affiliation_Type__c = 'Medical Professional' ;
        wishAffiliationsDataFactory[2].Wish__c = casesDataFactory[0].Id;
        insert wishAffiliationsDataFactory;

        List<Wish_Signature_Forms__c> wishSignFormsDataFactory = TestDataFactory.createWishSignatureForm(1);
        wishSignFormsDataFactory[0].Form_Type__c = 'Medical';
        insert wishSignFormsDataFactory;

        List<Wish_Signature_Chapter_Form__c> wishSignChapFormsDataFactory = TestDataFactory.createWishSignatureChapterForm(1);
        wishSignChapFormsDataFactory[0].Chapter_Account__c = accountsDataFactory[1].Id;
        wishSignChapFormsDataFactory[0].Wish_Signature_Form__c = wishSignFormsDataFactory[0].Id;
        insert wishSignChapFormsDataFactory;
    }

    @IsTest
    public static void testGetWishAffiliations() {
        Test.startTest();
        Case wishCase = [
                SELECT Id
                FROM Case
                LIMIT 1
        ];
        System.assertEquals(true, wishCase != null);
        List<WishSignatureController.childWrapper> wrapperList = WishSignatureController.getWishAffiliations(wishCase.Id);
        System.assertEquals(false, wrapperList.isEmpty());
        Test.stopTest();
    }

    @IsTest
    public static void testGetWishAffiliationsMeds() {
        Test.startTest();
        Case wishCase = [
                SELECT Id
                FROM Case
                LIMIT 1
        ];
        System.assertEquals(true, wishCase != null);
        List<WishSignatureController.childWrapper> wrapperList = WishSignatureController.getWishAffiliationsMedical(wishCase.Id);
        System.assertEquals(false, wrapperList.isEmpty());
        Test.stopTest();
    }

    @IsTest
    public static void testSaveMedicalWishSignatures() {
        Test.startTest();
        Case wishCase = [
                SELECT Id
                FROM Case
                LIMIT 1
        ];
        System.assertEquals(true, wishCase != null);

        Wish_Signature_Forms__c wishForm = [
                SELECT Id
                FROM Wish_Signature_Forms__c
                LIMIT 1
        ];
        System.assertEquals(true, wishForm != null);

        Contact wishAdult = [
                SELECT Id
                FROM Contact
                WHERE Current_Age__c > 18
        ];
        System.assertEquals(true, wishAdult != null);
        Wish_Affiliation__c wishAff = [
                SELECT Id
                FROM Wish_Affiliation__c
                WHERE Contact__c = :wishAdult.Id
        ];

        WishSignatureController.AdultWrapData wrapperData = new WishSignatureController.AdultWrapData();
        wrapperData.adult = String.valueOf(wishAdult.Id);
        wrapperData.wishAff = String.valueOf(wishAff.Id);

        WishSignatureController.saveMedicalWishSignatures('[' + JSON.serialize(wrapperData) + ']', String.valueOf(wishCase.Id), String.valueOf(wishForm.Id));
        List<Wish_Required_Signature__c> wrsList = [
                SELECT Id
                FROM Wish_Required_Signature__c
        ];
        System.assertEquals(false, wrsList.isEmpty());
        Test.stopTest();
    }

    @IsTest
    public static void testSaveFamilyWishSignatures() {
        Test.startTest();
        Case wishCase = [
                SELECT Id
                FROM Case
                LIMIT 1
        ];
        System.assertEquals(true, wishCase != null);

        Wish_Signature_Forms__c wishForm = [
                SELECT Id
                FROM Wish_Signature_Forms__c
                LIMIT 1
        ];
        System.assertEquals(true, wishForm != null);

        Contact wishAdult = [
                SELECT Id
                FROM Contact
                WHERE Current_Age__c > 18
        ];
        System.assertEquals(true, wishAdult != null);
        Wish_Affiliation__c wishAff = [
                SELECT Id
                FROM Wish_Affiliation__c
                WHERE Contact__c = :wishAdult.Id
        ];

        WishSignatureController.AdultWrapData wrapperData = new WishSignatureController.AdultWrapData();
        wrapperData.adult = String.valueOf(wishAdult.Id);
        wrapperData.wishAff = String.valueOf(wishAff.Id);

        Contact wishChild = [
                SELECT Id
                FROM Contact
                WHERE Current_Age__c < 18
        ];
        WishSignatureController.AdultMinorWrapData childWrapperData = new WishSignatureController.AdultMinorWrapData();
        childWrapperData.adult = String.valueOf(wishAdult.Id);
        childWrapperData.minor = String.valueOf(wishChild.Id);
        childWrapperData.wishAffMinor = String.valueOf(wishAff.Id);

        WishSignatureController.saveFamilyWishSignatures('[' + JSON.serialize(wrapperData) + ']', '[' + JSON.serialize(childWrapperData) + ']', String.valueOf(wishCase.Id), String.valueOf(wishForm.Id));
        List<Wish_Required_Signature__c> wrsList = [
                SELECT Id
                FROM Wish_Required_Signature__c
        ];
        System.assertEquals(false, wrsList.isEmpty());
        Test.stopTest();
    }

    @IsTest
    public static void testGetSignatureForms() {
        Test.startTest();
        Case wishCase = [
                SELECT Id
                FROM Case
                LIMIT 1
        ];
        System.assertEquals(true, wishCase != null);
        List<Wish_Signature_Forms__c> wishForm = WishSignatureController.getWishSignatureForms(wishCase.Id, 'Medical');
        Test.stopTest();
        System.assertEquals(true, wishForm != null);
    }
}