/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Kanagaraj
Date        : 28/06/2016
Description : DocusignStatusTrigger_AT_Test is used to increase the code coverage for Application_AC controller.
*****************************************************************************************************/
@IsTest
public class DocusignStatusTrigger_AT_Test {
    
    @TestSetup 
    static void setUp() {
        trac_TriggerHandlerBase.blockTrigger = true;
        
        Account accountAzChapter = TestDataFactory.createAccount(1)[0];
        accountAzChapter.Name = 'Make-A-Wish Arizona';
        accountAzChapter.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
        insert accountAzChapter;
        
        List<Contact> contactList = TestDataFactory.createContact(2);
        Contact volunteerHector = contactList.get(0);
        volunteerHector.RecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
        volunteerHector.AccountId = accountAzChapter.Id;
        volunteerHector.FirstName = 'Hector';
        volunteerHector.LastName = 'Sol';
        volunteerHector.Email = 'h.sol@email.com';
        Contact wishChildAnthony = contactList.get(1);
        wishChildAnthony.FirstName = 'Anthony';
        wishChildAnthony.LastName = 'Edwards';
        wishChildAnthony.Parent_Guardian_Name__c = 'Jonathan Edwards';
        wishChildAnthony.RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
        wishChildAnthony.Birthdate = Date.today().addDays(+21);
        wishChildAnthony.Birthdate = wishChildAnthony.Birthdate.addYears(-5);
        wishChildAnthony.MailingPostalCode = '94105-5188';
        wishChildAnthony.MailingStreet = '7540 E Gold Dust Ave';
        wishChildAnthony.MailingCountry = 'United States';
        wishChildAnthony.MailingState = 'Arizona';
        wishChildAnthony.MailingCity = 'Scottsdale';
        wishChildAnthony.MailingLatitude = -24.355798;
        wishChildAnthony.MailingLongitude = 69.830469;
        insert contactList;
        
        Case wishChildCase = TestDataFactory.createCase(1)[0];
        wishChildCase.RecordTypeId = Constant_AC.WISH_RT_ID;
        wishChildCase.ChapterName__c = accountAzChapter.Id;
        wishChildCase.Subject = 'Parent Wish';
        wishChildCase.Interview_date__c = System.today();
        wishChildCase.Wish_Type__c = 'Disney World';
        wishChildCase.Start_Date__c = System.today();
        wishChildCase.End_Date__c = System.today();
        wishChildCase.ContactId = wishChildAnthony.Id;
        wishChildCase.Status = 'New';
        wishChildCase.Start_Date__c = System.today();
        wishChildCase.LiabilitySignerMapKeyPair__c = 'Vennila';
        wishChildCase.Budget_Submitted_Date__c = System.today();
        wishChildCase.Budget_Approved_Date__c = System.today();
        insert wishChildCase;
        
        Lead referredLead = TestDataFactory.createLead(1)[0];
        referredLead.FirstName = 'Thomas';
        referredLead.LastName = 'Naranja';
        referredLead.Company = 'MAWA';
        referredLead.Street = '123 Cactus Road';
        referredLead.State = 'Arizona';
        referredLead.StateCode = 'AZ';
        referredLead.City = 'Phoenix';
        referredLead.Postalcode = '85264';
        referredLead.CountryCode = 'US';
        referredLead.Gender__c = 'Male';
        referredLead.Phone = '7600467559';
        referredLead.ChapterName__c = accountAzChapter.Id;
        referredLead.DOB__c = System.today() - 1435;
        referredLead.is_Family_Aware_of_Referral__c = 'Yes';
        referredLead.Referrer_FirstName__c = 'Janet';
        referredLead.Referrer_Last_Name__c = 'Evans';
        referredLead.Referrer_Email__c = 'janet.evans.test@gmail.com';
        referredLead.Referrer_Phone__c = '0600467559';
        referredLead.Referrer_City__c = 'Phoenix';
        referredLead.Referrer_Zip__c = '85264';
        referredLead.PD_Condition_Description__c = 'Malignant Melanoma';
        referredLead.Diagnosis_Given_By_Referrer__c = 'Malignant Melanoma';
        referredLead.I_am_Recognized_To_Practice_As_a__c = 'Physician';
        referredLead.Status = Constant_AC.LEAD_STATUS_REFERRED;
        referredLead.RFI_Form_Info_Hidden__c = Constant_AC.LEAD_RFI_FORM_INFO_QUALIFIED;
        insert referredLead;
        
        List<dsfs__DocuSign_Status__c> docusignStatusList = TestDataFactory.createDocusignStatus(3);
        dsfs__DocuSign_Status__c dsfsVolunteer = docusignStatusList.get(0);
        dsfsVolunteer.Docusign_Hidden_Contact__c = volunteerHector.Id;
        dsfsVolunteer.dsfs__Contact__c = volunteerHector.Id;
        dsfs__DocuSign_Status__c dsfsLead = docusignStatusList.get(1);
        dsfsLead.dsfs__Lead__c = referredLead.Id;
        dsfs__DocuSign_Status__c dsfsCase = docusignStatusList.get(2);
        dsfsCase.dsfs__Case__c = wishChildCase.Id;
        dsfsCase.dsfs__Subject__c = Constant_AC.DOCUSIGN_STATUS_SUBJECT_SIGNATURE_REQUIRED_WISH_CLEARANCE_FORM;
        insert docusignStatusList;
        
        Attachment attachment = TestDataFactory.createAttachments(1, dsfsVolunteer.Id)[0];
        insert attachment;
        
        Wish_Signature_Forms__c wishForm = TestDataFactory.createWishSignatureForm(1)[0];
        insert wishForm;     
        
        Wish_Required_Signature__c wishSignature = TestDataFactory.createWishRequiredSignature(1)[0];
        wishSignature.Wish_Case__c = wishChildCase.Id;
        wishSignature.Wish_Signature_Form__c = wishform.Id;
        insert wishSignature;
        
        trac_TriggerHandlerBase.blockTrigger = false;
    }
    
    /*This method is used to update the isConflict status as true when the envelop status is completed.*/
    @IsTest
    public static void updateIsConfilictToTrue() {
        dsfs__DocuSign_Status__c dsfs = [
            SELECT Id, Docusign_Hidden_Contact__c
            FROM dsfs__DocuSign_Status__c 
            WHERE Docusign_Hidden_Contact__r.Name = 'Hector Sol'
        ];
        dsfs.dsfs__Envelope_Status__c = Constant_AC.DOCUSIGN_ENVELOPE_STATUS_COMPLETED;
        dsfs.isConflict__c = true;
        Test.startTest();
        update dsfs;
        Test.stopTest();
        List<Conflict_Of_Interest__c> newCOIs = [
            SELECT Id, Volunteer_Contact__c 
            FROM Conflict_Of_Interest__c
            WHERE Volunteer_Contact__c = :dsfs.Docusign_Hidden_Contact__c
        ];
        System.assert(newCOIs.size() == 1);
    }
    
    /*This method is used to update the isConfilict status as false when the envelop status is completed.*/
    @IsTest
    public static void updateIsConfilictToFalse() {
        dsfs__DocuSign_Status__c dsfs = [
            SELECT Id, Docusign_Hidden_Contact__c
            FROM dsfs__DocuSign_Status__c 
            WHERE Docusign_Hidden_Contact__r.Name = 'Hector Sol'
        ];
        dsfs.dsfs__Envelope_Status__c = Constant_AC.DOCUSIGN_ENVELOPE_STATUS_COMPLETED;
        dsfs.isConflict__c = false;
        Test.startTest();
        update dsfs;
        Test.stopTest();
        Contact volunteerUpdated = [
            SELECT Id, is_Application__c 
            FROM Contact 
            WHERE Id = :dsfs.Docusign_Hidden_Contact__c
        ];
        System.assert(volunteerUpdated.is_Application__c == 'Approved');
    }
    
    /*This method is used to convert the lead when the docusign status is completed.*/
    @IsTest
    public static void convertLead() {
        Lead referredLead = [
            SELECT Id, Sub_Status__c 
            FROM Lead 
            WHERE Name = 'Thomas Naranja'
        ];
        referredLead.Sub_Status__c = Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION;
        update referredLead;
        dsfs__DocuSign_Status__c dsfs = [
            SELECT Id, dsfs__Lead__c, dsfs__Envelope_Status__c
            FROM dsfs__DocuSign_Status__c 
            WHERE dsfs__Lead__c = :referredLead.Id
        ];
        dsfs.dsfs__Envelope_Status__c = Constant_AC.DOCUSIGN_ENVELOPE_STATUS_COMPLETED;
        Test.startTest();
        update dsfs;
        Test.stopTest();
        Lead leadUpdated = [
            SELECT Id, Status 
            FROM Lead 
            WHERE Id = :referredLead.Id
        ];
        System.assert(leadUpdated.Status == Constant_AC.LEAD_STATUS_QUALIFIED);
    }
    
    @IsTest
    public static void convertLeadStatusNotQualified() {
        Lead referredLead = [
            SELECT Id, Sub_Status__c 
            FROM Lead 
            WHERE Name = 'Thomas Naranja'
        ];
        referredLead.Sub_Status__c = Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION;
        referredLead.RFI_Form_Info_Hidden__c = Constant_AC.LEAD_RFI_FORM_INFO_NOT_QUALIFIED;
        update referredLead;
        dsfs__DocuSign_Status__c dsfs = [
            SELECT Id, dsfs__Lead__c, dsfs__Envelope_Status__c
            FROM dsfs__DocuSign_Status__c 
            WHERE dsfs__Lead__c = :referredLead.Id
        ];
        dsfs.dsfs__Envelope_Status__c = Constant_AC.DOCUSIGN_ENVELOPE_STATUS_COMPLETED;
        Test.startTest();
        update dsfs;
        Test.stopTest();
        Lead leadUpdated = [
            SELECT Id, Status 
            FROM Lead 
            WHERE Id = :referredLead.Id
        ];
        System.assert(leadUpdated.Status == Constant_AC.LEAD_STATUS_ELIGIBILITY_REVIEW);
    }
    
    @IsTest
    public static void insertAttachment() {
        Contact wishChild = [
            SELECT Id 
            FROM Contact 
            WHERE Name = 'Anthony Edwards'
        ];
        dsfs__DocuSign_Status__c dsfs = [
            SELECT Id
            FROM dsfs__DocuSign_Status__c 
            WHERE dsfs__Contact__r.Name = 'Hector Sol'
        ];
        dsfs.dsfs__Contact__c = wishChild.Id;
        dsfs.dsfs__Subject__c = Constant_AC.DOCUSIGN_SUBJECT_DIAGNOSIS_VERIFICATION_FORM;
        Test.startTest();
        update dsfs;
        Test.stopTest();
        List<Attachment> attachmentList = [
            SELECT Id 
            FROM Attachment 
            WHERE ParentId = :wishChild.Id
        ];
        System.assert(!attachmentList.isEmpty());
    }
    
    @IsTest
    public static void sendWishClearance() {
        dsfs__DocuSign_Status__c dsfs = [
            SELECT Id, dsfs__Case__c
            FROM dsfs__DocuSign_Status__c 
            WHERE dsfs__Case__c != null
        ];
        dsfs.dsfs__Envelope_Status__c = Constant_AC.DOCUSIGN_ENVELOPE_STATUS_COMPLETED;
        Test.startTest();
        update dsfs;
        Test.stopTest();
        Case updatedCase = [
            SELECT Id, Wish_Clearance_Received_Date__c 
            FROM Case 
            WHERE Id = :dsfs.dsfs__Case__c
        ];
        System.assert(updatedCase.Wish_Clearance_Received_Date__c == System.today());
    }
    
    @IsTest
    public static void updateWishSignature() {
        Wish_Required_Signature__c wishSignature = [
            SELECT Id 
            FROM Wish_Required_Signature__c 
            LIMIT 1
        ];
        dsfs__DocuSign_Status__c dsfsWishSignature = TestDataFactory.createDocusignStatus(1)[0];
        dsfsWishSignature.Wish_Required_Signature__c = wishSignature.Id;
        Test.startTest();
        insert dsfsWishSignature;
        Test.stopTest();
        Wish_Required_Signature__c wishSignatureUpdated = [
            SELECT Id, Status__c, Sent_Date__c
            FROM Wish_Required_Signature__c 
            WHERE Id = :wishSignature.Id
        ];
        System.assert(wishSignatureUpdated.Status__c == Constant_AC.WISH_REQUIRED_SIGNATURE_STATUS_SENT);
        System.assert(wishSignatureUpdated.Sent_Date__c == System.today());
    }
}