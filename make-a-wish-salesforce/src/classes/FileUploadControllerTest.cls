/* 
* @Description Test class for FileUploadController
* @author Mitali Nahar, Traction on Demand
* @Date 2019-07-20
*/

@isTest
public class FileUploadControllerTest {
    
    private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;
	private final static Id WISH_RECORD_TYPE_ID = Constant_AC.WISH_RT_ID;
	private final static Id WISH_FAMILY_RECORD_TYPE_ID = Constant_AC.WISH_FAMILY_RT_ID;
    private final static Id HOUSEHOLD_RECORD_TYPE_ID = Constant_AC.HOUSEHOLD_RT_ID;
    private final static Id WISH_CHILD_RECORD_TYPE_ID = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
    
    
    @TestSetup
    private static void insertTestData() {
        List<Account> accountsDataFactory = TestDataFactory.createAccount(2);
        accountsDataFactory[0].RecordTypeId = HOUSEHOLD_RECORD_TYPE_ID;
        accountsDataFactory[1].RecordTypeId = CHAPTER_RECORD_TYPE_ID  ;  
        insert accountsDataFactory;
        
        ICD_Codes__c obj = new ICD_Codes__c();
		obj.Name = 'Q917';
		insert obj;
        List<Contact> contactsDataFactory = TestDataFactory.createContact(2);
        contactsDataFactory[0].RecordTypeId = WISH_CHILD_RECORD_TYPE_ID;
        contactsDataFactory[0].ICD_10_Code__c = obj.Id;
        contactsDataFactory[1].RecordTypeId = WISH_FAMILY_RECORD_TYPE_ID;
        contactsDataFactory[1].BirthDate = System.today().addYears(-20);
        insert  contactsDataFactory;
            
        List<Case> casesDataFactory = TestDataFactory.createCase(1);
        casesDataFactory[0].RecordTypeId = WISH_RECORD_TYPE_ID;
        casesDataFactory[0].ChapterName__c =  accountsDataFactory[1].Id;
        casesDataFactory[0].AccountId =  accountsDataFactory[0].Id;
        casesDataFactory[0].ContactId =  contactsDataFactory[0].Id;
        casesDataFactory[0].Origin = 'Email';
        casesDataFactory[0].Status = 'Qualified';
        insert casesDataFactory;
        
        List<Wish_Affiliation__c> wishAffiliationsDataFactory = TestDataFactory.createWishAffiliation(1);
        wishAffiliationsDataFactory[0].Contact__c = contactsDataFactory[1].Id;
        wishAffiliationsDataFactory[0].Wish_Affiliation_Type__c = 'Approved Participant' ;
        wishAffiliationsDataFactory[0].Wish__c = casesDataFactory[0].Id;
        insert wishAffiliationsDataFactory;
       
        List<Wish_Signature_Forms__c> wishSignFormsDataFactory  = TestDataFactory.createWishSignatureForm(1);
        wishSignFormsDataFactory[0].Form_Type__c = 'Medical';
        insert wishSignFormsDataFactory;
        
        List<Wish_Required_Signature__c> wishReqSignsDataFactory = TestDataFactory.createWishRequiredSignature(1);
        wishReqSignsDataFactory[0].Wish_Case__c = casesDataFactory[0].Id;
		wishReqSignsDataFactory[0].Wish_Signature_Form__c = wishSignFormsDataFactory[0].Id;
		wishReqSignsDataFactory[0].Status__c = 'Not Sent';
		wishReqSignsDataFactory[0].Type__c = 'Medical';
		wishReqSignsDataFactory[0].Wish_Affiliation__c = wishAffiliationsDataFactory[0].Id;
        insert wishReqSignsDataFactory;
    }
    
    @isTest
    public static void testuploadFile(){
        Test.startTest();
        Wish_Required_Signature__c wishSign = [SELECT Id FROM Wish_Required_Signature__c LIMIT 1];
        system.assertEquals(false, wishSign == null);
        
        Id attachId = FileUploadController.updateWRSAndSaveFile(wishSign.Id, 'Test File','Test Data','Test',wishSign );
        System.assertEquals(true, attachId != null);
        
        Id fileId = FileUploadController.updateWRSAndSaveFile(wishSign.Id, 'Test File','Test Data','Test', null );
        System.assertEquals(true, fileId != null);
        Test.stopTest();
    }
    
}