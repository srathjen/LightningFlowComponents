/*****************************************************************************************************************
Author      : MST Solutions
Date        : 10/26/2016
Description : This class contains test method for InKindDonationReimbursementFile object
*******************************************************************************************************************/
@isTest
public class InKindDonationReimbursementFile_AT_Test {
    
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
        
        List<In_Kind_Donation_Reimbursement__c> reimbursementList = TestDataFactory.createInKindDonationReimbursement(2);
        In_Kind_Donation_Reimbursement__c reimbursementGoods = reimbursementList.get(0);
        reimbursementGoods.Date_of_Gift__c = System.today() + 2;
        reimbursementGoods.Gift_Type__c = 'Goods';
        reimbursementGoods.Gift_Value__c = 123456;
        reimbursementGoods.Documentation__c = 'Not available';
        reimbursementGoods.RecordTypeId = Constant_AC.IN_KIND_ID;
        reimbursementGoods.Make_check_payable_to_me__c = true;
        reimbursementGoods.Wish__c = wishChildCase.Id;
        In_Kind_Donation_Reimbursement__c reimbursementServices = reimbursementList.get(1);
        reimbursementServices.Date_of_Gift__c = System.today() + 2;
        reimbursementServices.Gift_Type__c = 'Services';
        reimbursementServices.Gift_Value__c = 234567;
        reimbursementServices.Documentation__c = 'Not available';
        reimbursementServices.RecordTypeId = Constant_AC.IN_KIND_ID;
        reimbursementServices.Make_check_payable_to_me__c = true;
        reimbursementServices.Wish__c = wishChildCase.Id;
        insert reimbursementList;
        
        InkindDon_reimburseFile__c reimbursementServicesFile = TestDataFactory.createInKindDonationReimbursementFile(reimbursementServices.Id);
        reimbursementServicesFile.File_Name__c = 'ReimbursementSummary.txt';
        insert reimbursementServicesFile;
        
        trac_TriggerHandlerBase.blockTrigger = false;
    }
    
    @isTest
    static void createFile() {
        In_Kind_Donation_Reimbursement__c reimbursement = [
            SELECT Id 
            FROM In_Kind_Donation_Reimbursement__c 
            WHERE Gift_Type__c = 'Goods'
        ];
        InkindDon_reimburseFile__c reimbursementFile = TestDataFactory.createInKindDonationReimbursementFile(reimbursement.Id);
        Test.startTest();
        insert reimbursementFile;
        Test.stopTest();
        In_Kind_Donation_Reimbursement__c reimbursementUpdated = [
            SELECT Id, Documentation__c
            FROM In_Kind_Donation_Reimbursement__c
            WHERE Id = :reimbursement.Id
        ];
        System.assert(reimbursementUpdated.Documentation__c == 'Attached');
    }
    
    @isTest
    static void deleteFile() {
        InkindDon_reimburseFile__c reimbursementFile = [
            SELECT Id, Parent__c
            FROM InkindDon_reimburseFile__c 
            WHERE File_Name__c = 'ReimbursementSummary.txt'
        ];
        Test.startTest();
        delete reimbursementFile;
        Test.stopTest();
        In_Kind_Donation_Reimbursement__c reimbursementUpdated = [
            SELECT Id, Documentation__c
            FROM In_Kind_Donation_Reimbursement__c
            WHERE Id = :reimbursementFile.Parent__c
        ];
        System.assert(reimbursementUpdated.Documentation__c == Constant_AC.INKIND_REIMBURSEMENT_FILE_DOCUMENTATION);
    }
}