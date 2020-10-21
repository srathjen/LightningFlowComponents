/**
 * @description Batch Create Signature Participants Test Class
 * @author Mitali Nahar, Traction on Demand
 * @createdDate 7/23/2019
 */
@isTest
private class Batch_createWishSignParticipantsTest{

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
        contactsDataFactory[1].BirthDate = System.today().addYears(-20);
        contactsDataFactory[1].Region_Chapter__c = accountsDataFactory[1].Id;
        contactsDataFactory[2].RecordTypeId = MEDICAL_PROF_RECORD_TYPE_ID;
        contactsDataFactory[2].Region_Chapter__c = accountsDataFactory[2].Id;
        contactsDataFactory[3].RecordTypeId = WISH_FAMILY_RECORD_TYPE_ID;
        contactsDataFactory[3].BirthDate = System.today().addYears(-18);
        contactsDataFactory[3].Region_Chapter__c = accountsDataFactory[3].Id;
        insert  contactsDataFactory;
        
        List<Case> casesDataFactory = TestDataFactory.createCase(1);
        casesDataFactory[0].RecordTypeId = WISH_RECORD_TYPE_ID;
        casesDataFactory[0].ChapterName__c =  accountsDataFactory[1].Id;
        casesDataFactory[0].AccountId =  accountsDataFactory[0].Id;
        casesDataFactory[0].ContactId =  contactsDataFactory[0].Id;
        casesDataFactory[0].Origin = 'Email';
        casesDataFactory[0].Status = 'Qualified';
        insert casesDataFactory;
        
        List<Wish_Affiliation__c> wishAffiliationsDataFactory = TestDataFactory.createWishAffiliation(3);
        wishAffiliationsDataFactory[0].Contact__c = contactsDataFactory[1].Id;
        wishAffiliationsDataFactory[0].Wish_Affiliation_Type__c = 'Approved Participant' ;
        wishAffiliationsDataFactory[0].Wish__c = casesDataFactory[0].Id;
        wishAffiliationsDataFactory[1].Contact__c = contactsDataFactory[2].Id;
        wishAffiliationsDataFactory[1].Wish_Affiliation_Type__c = 'Approved Participant' ;
        wishAffiliationsDataFactory[1].Wish__c = casesDataFactory[0].Id;
        wishAffiliationsDataFactory[2].Contact__c = contactsDataFactory[3].Id;
        wishAffiliationsDataFactory[2].Wish_Affiliation_Type__c = 'Wish Child' ;
        wishAffiliationsDataFactory[2].Wish__c = casesDataFactory[0].Id;
        insert wishAffiliationsDataFactory;
        
        List<Wish_Signature_Forms__c> wishSignFormsDataFactory  = TestDataFactory.createWishSignatureForm(1);
        wishSignFormsDataFactory[0].Form_Type__c = 'Medical';
        wishSignFormsDataFactory[0].Auto_add_for_Participant__c = true;
        wishSignFormsDataFactory[0].Auto_add_for_Wish_Child__c = true;
        insert wishSignFormsDataFactory;
        
        List<Wish_Signature_Chapter_Form__c> wishSignChapFormsDataFactory = TestDataFactory.createWishSignatureChapterForm(1);
        wishSignChapFormsDataFactory[0].Chapter_Account__c = accountsDataFactory[1].Id;
        wishSignChapFormsDataFactory[0].Wish_Signature_Form__c = wishSignFormsDataFactory[0].Id;
        insert wishSignChapFormsDataFactory;
        
    }

    @IsTest
    static void createSignatureParticipantsTest() {
        String CRON_EXP = '0 0 0 15 3 ? *';
        //Schedule the Job and run the Batch immediately too
        Test.startTest();
        Batch_createWishSignatureForParticipants obj = new Batch_createWishSignatureForParticipants();
        String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new Batch_createWishSignatureForParticipants());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        Database.executeBatch(obj);
        Test.stopTest();
        List<Wish_Required_Signature__c> wishReqSignsDataFactory = [SELECT Id FROM Wish_Required_Signature__c];
        System.assertEquals(true, wishReqSignsDataFactory.size()>0);
    }
}