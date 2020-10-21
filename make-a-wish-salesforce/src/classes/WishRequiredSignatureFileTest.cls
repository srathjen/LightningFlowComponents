/* 
* @Description Test class for WishRequiredSignatureFile Trigger
* @author Mitali Nahar, Traction on Demand
* @Date 2019-07-20
*/
@IsTest
public class WishRequiredSignatureFileTest {

    private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;
    private final static Id WISH_RECORD_TYPE_ID = Constant_AC.WISH_RT_ID;
    private final static Id WISH_FAMILY_RECORD_TYPE_ID = Constant_AC.WISH_FAMILY_RT_ID;
    private final static Id HOUSEHOLD_RECORD_TYPE_ID = Constant_AC.HOUSEHOLD_RT_ID;
    private final static Id WISH_CHILD_RECORD_TYPE_ID = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
    private final static Id MEDICAL_PROF_RECORD_TYPE_ID = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;

    @TestSetup
    private static void insertTestData() {
        List<Account> accountsDataFactory = TestDataFactory.createAccount(4);
        accountsDataFactory[0].RecordTypeId = HOUSEHOLD_RECORD_TYPE_ID;
        accountsDataFactory[1].RecordTypeId = CHAPTER_RECORD_TYPE_ID;
        accountsDataFactory[2].RecordTypeId = CHAPTER_RECORD_TYPE_ID;
        accountsDataFactory[3].RecordTypeId = CHAPTER_RECORD_TYPE_ID;
        insert accountsDataFactory;

        ICD_Codes__c obj = new ICD_Codes__c();
        obj.Name = 'Q917';
        insert obj;
        List<Contact> contactsDataFactory = TestDataFactory.createContact(4);
        contactsDataFactory[0].RecordTypeId = WISH_CHILD_RECORD_TYPE_ID;
        contactsDataFactory[0].ICD_10_Code__c = obj.Id;
        contactsDataFactory[1].RecordTypeId = WISH_FAMILY_RECORD_TYPE_ID;
        contactsDataFactory[1].Birthdate = System.today().addYears(-20);
        contactsDataFactory[1].Region_Chapter__c = accountsDataFactory[1].Id;
        contactsDataFactory[2].RecordTypeId = MEDICAL_PROF_RECORD_TYPE_ID;
        contactsDataFactory[2].Region_Chapter__c = accountsDataFactory[2].Id;
        contactsDataFactory[3].RecordTypeId = WISH_FAMILY_RECORD_TYPE_ID;
        contactsDataFactory[3].Birthdate = System.today().addYears(-10);
        contactsDataFactory[3].Region_Chapter__c = accountsDataFactory[3].Id;
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

        List<Wish_Required_Signature__c> wishReqSignsDataFactory = TestDataFactory.createWishRequiredSignature(1);
        wishReqSignsDataFactory[0].Wish_Case__c = casesDataFactory[0].Id;
        wishReqSignsDataFactory[0].Wish_Signature_Form__c = wishSignFormsDataFactory[0].Id;
        wishReqSignsDataFactory[0].Status__c = 'Not Sent';
        wishReqSignsDataFactory[0].Type__c = 'Medical';
        wishReqSignsDataFactory[0].Wish_Affiliation__c = wishAffiliationsDataFactory[0].Id;
        insert wishReqSignsDataFactory;
    }

    @IsTest
    public static void createWishRequiredSignatureFile() {
        Test.startTest();
        Wish_Required_Signature__c wishSign = [
                SELECT Id
                FROM Wish_Required_Signature__c
                LIMIT 1
        ];
        System.assertEquals(false, wishSign == null);
        Wish_Required_Signature_File__c wrsFile = TestDataFactory.createWRSFileRecord(wishSign.Id);
        insert wrsFile;
        System.assertEquals(wishSign.Id, wrsFile.Wish_Required_Signature__c, 'Id dose not match');
        System.assert(wishSign.Id == wrsFile.Wish_Required_Signature__c, 'The value of wishSign.id is: ' + wishSign.id + ' and the value of wrsFile.Wish_Required_Signature__c is: ' + wrsFile.Wish_Required_Signature__c);
        Test.stopTest();
    }
}