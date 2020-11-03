/**
 * @description This test class used to perform unit testing for the DV Medical Summary Attachment
 * Modification Log:
 * 09/10/2019 - Manik - WLP-423
 *
 * @author MST Solutions
 *
 * @date : 1/23/2017
 **/
@IsTest
public class DVMedicalSummaryAttachment_AC_Test {

    private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;

    @TestSetup
    public static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;

        User currUser = Utils.currentUser;
        List<Account> accounts = TestDataFactory.createAccount(1);
        Account account = accounts.get(0);
        account.Name = 'Make-A-Wish Arizona';
        account.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
        account.Volunteer_Manager__c = currUser.Id;
        account.Alert_for_Unassigned_Wishes__c = 1;
        insert accounts;

        List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
        insert icdCodes;

        List<Contact> contactList = TestDataFactory.createContact(8);
        Contact mpContactLee = contactList.get(0);
        mpContactLee.FirstName = 'Ken';
        mpContactLee.LastName = 'Lee';
        mpContactLee.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        mpContactLee.Region_Chapter__c = account.Id;
        Contact mpContactMiller = contactList.get(1);
        mpContactMiller.FirstName = 'Jennifer';
        mpContactMiller.LastName = 'Miller';
        mpContactMiller.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        mpContactMiller.Region_Chapter__c = account.Id;
        Contact mpContactJohnson = contactList.get(2);
        mpContactJohnson.FirstName = 'Raymond';
        mpContactJohnson.LastName = 'Johnson';
        mpContactJohnson.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        mpContactJohnson.Region_Chapter__c = account.Id;
        Contact mpContactPatel = contactList.get(3);
        mpContactPatel.FirstName = 'Daniel';
        mpContactPatel.LastName = 'Patel';
        mpContactPatel.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        mpContactPatel.Region_Chapter__c = account.Id;
        Contact mpContactBrown = contactList.get(4);
        mpContactBrown.FirstName = 'Rachel';
        mpContactBrown.LastName = 'Brown';
        mpContactBrown.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        mpContactBrown.Region_Chapter__c = account.Id;
        Contact wishFamilyWalker = contactList.get(5);
        wishFamilyWalker.FirstName = 'Lucy';
        wishFamilyWalker.LastName = 'Walker';
        wishFamilyWalker.RecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
        wishFamilyWalker.Region_Chapter__c = account.Id;
        Contact boardMember = contactList.get(6);
        boardMember.FirstName = 'Samuel';
        boardMember.LastName = 'Crane';
        boardMember.RecordTypeId = Constant_AC.BOARD_MEMBER_RT_ID;
        boardMember.Region_Chapter__c = account.Id;
        Contact volunteer = contactList.get(7);
        volunteer.FirstName = 'Katherine';
        volunteer.LastName = 'Buckland';
        volunteer.RecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
        volunteer.AccountId = account.Id;
        volunteer.Region_Chapter__c = account.Id;
        insert contactList;

        List<Lead> leadsDataFactory = TestDataFactory.createLead(1);
        Lead lead = leadsDataFactory.get(0);
        lead.ChapterName__c = accounts[0].Id;
        lead.FirstName = 'Jack';
        lead.LastName = 'Smith';
        lead.unique_wish_identifier__c = '059-17-12367';
        lead.is_Family_Aware_of_Referral__c = 'Yes';
        lead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
        lead.PD_ICD_Code__c = icdCodes[0].Id;
        lead.Company = 'MAW';
        lead.Referring_MP__c = mpContactLee.Id;
        lead.Treating_MP__c = mpContactMiller.Id;
        lead.Best_Contact__c = mpContactJohnson.Id;
        lead.Alt_1_MP__c = mpContactPatel.Id;
        lead.Alt_2_MP__c = mpContactBrown.Id;
        lead.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_REFERRING_MEDICAL_PROFESSIONAL;
        insert leadsDataFactory;

        List<cg__Lead_File__c> leadFilesDataFactory = TestDataFactory.createLeadFile(1);
        cg__Lead_File__c leadFile = leadFilesDataFactory.get(0);
        leadFile.cg__Lead__c = lead.Id;
        insert leadFilesDataFactory;

        trac_TriggerHandlerBase.blockTrigger = false;
    }

    @IsTest
    public static void getAttachmentWhenSaved() {
        Lead lead = [
                SELECT Id, Hidden_DV_form_Medical_professional_Type__c, Referring_MP__c, Treating_MP__c, Best_Contact__c,
                        Alt_1_MP__c, Alt_2_MP__c
                FROM Lead
                WHERE Name = 'Jack Smith'
        ];
        List<cg__Lead_File__c> leadFile = [
                SELECT Id
                FROM cg__Lead_File__c
                WHERE cg__Lead__c = :lead.Id
        ];
        Test.startTest();
        PageReference pageRef = Page.DVMedicalSummaryAttachment_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', lead.Id);
        ApexPages.currentPage().getParameters().put('saved', 'true');
        DVMedicalSummaryAttachment_AC currDiagnosisVerificationDupe = new DVMedicalSummaryAttachment_AC();
        currDiagnosisVerificationDupe.getAttachments();
        Attachment attach = new Attachment();
        attach.Name = 'Wish Child Medical Summary';
        Blob bodyBlob = Blob.valueOf('Medical Summary Wish Child');
        attach.Body = bodyBlob;
        currDiagnosisVerificationDupe.newAttachment = attach;
        currDiagnosisVerificationDupe.save();
        currDiagnosisVerificationDupe.attachmentId = leadFile[0].Id;
        currDiagnosisVerificationDupe.removeAttachment();
        Test.stopTest();
    }

    @IsTest
    public static void getAttachmentWhenDeleted() {
        Lead lead = [
                SELECT Id, Hidden_DV_form_Medical_professional_Type__c, Referring_MP__c, Treating_MP__c, Best_Contact__c,
                        Alt_1_MP__c, Alt_2_MP__c
                FROM Lead
                WHERE Name = 'Jack Smith'
        ];
        List<cg__Lead_File__c> leadFile = [
                SELECT Id
                FROM cg__Lead_File__c
                WHERE cg__Lead__c = :lead.Id
        ];
        Test.startTest();
        PageReference pageRef = Page.DVMedicalSummaryAttachment_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', lead.Id);
        ApexPages.currentPage().getParameters().put('deleted', 'true');
        DVMedicalSummaryAttachment_AC currDiagnosisVerificationDupe = new DVMedicalSummaryAttachment_AC();
        currDiagnosisVerificationDupe.getAttachments();
        Attachment attach = new Attachment();
        attach.Name = 'Wish Child Medical Summary';
        Blob bodyBlob = Blob.valueOf('Medical Summary Wish Child');
        attach.Body = bodyBlob;
        currDiagnosisVerificationDupe.newAttachment = attach;
        currDiagnosisVerificationDupe.save();
        currDiagnosisVerificationDupe.attachmentId = leadFile[0].Id;
        currDiagnosisVerificationDupe.removeAttachment();
        Test.stopTest();
    }

    @IsTest
    public static void findAttachmentIdReferringMp() {
        Lead lead = [
                SELECT Id, Hidden_DV_form_Medical_professional_Type__c, Referring_MP__c, Treating_MP__c, Best_Contact__c,
                        Alt_1_MP__c, Alt_2_MP__c
                FROM Lead
                WHERE Name = 'Jack Smith'
        ];
        lead.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_REFERRING_MEDICAL_PROFESSIONAL;
        update lead;

        Test.startTest();
        Test.setCurrentPage(Page.DVMedicalSummaryAttachment_VF);
        ApexPages.currentPage().getParameters().put('id', lead.Id);
        ApexPages.currentPage().getParameters().put('saved', 'true');
        new DVMedicalSummaryAttachment_AC();
        Test.stopTest();
    }

    @IsTest
    public static void findAttachmentIdTreatingMp() {
        Lead lead = [
                SELECT Id, Hidden_DV_form_Medical_professional_Type__c, Referring_MP__c, Treating_MP__c, Best_Contact__c,
                        Alt_1_MP__c, Alt_2_MP__c
                FROM Lead
                WHERE Name = 'Jack Smith'
        ];
        lead.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL;
        update lead;

        Test.startTest();
        Test.setCurrentPage(Page.DVMedicalSummaryAttachment_VF);
        ApexPages.currentPage().getParameters().put('id', lead.Id);
        ApexPages.currentPage().getParameters().put('saved', 'true');
        new DVMedicalSummaryAttachment_AC();
        Test.stopTest();
    }

    @IsTest
    public static void findAttachmentIdBestMp() {
        Lead lead = [
                SELECT Id, Hidden_DV_form_Medical_professional_Type__c, Referring_MP__c, Treating_MP__c, Best_Contact__c,
                        Alt_1_MP__c, Alt_2_MP__c
                FROM Lead
                WHERE Name = 'Jack Smith'
        ];
        lead.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_BEST_CONTACT;
        update lead;

        Test.startTest();
        Test.setCurrentPage(Page.DVMedicalSummaryAttachment_VF);
        ApexPages.currentPage().getParameters().put('id', lead.Id);
        ApexPages.currentPage().getParameters().put('saved', 'true');
        new DVMedicalSummaryAttachment_AC();
        Test.stopTest();
    }

    @IsTest
    public static void findAttachmentIdAlt1Mp() {
        Lead lead = [
                SELECT Id, Hidden_DV_form_Medical_professional_Type__c, Referring_MP__c, Treating_MP__c, Best_Contact__c,
                        Alt_1_MP__c, Alt_2_MP__c
                FROM Lead
                WHERE Name = 'Jack Smith'
        ];
        lead.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL;
        update lead;

        Test.startTest();
        Test.setCurrentPage(Page.DVMedicalSummaryAttachment_VF);
        ApexPages.currentPage().getParameters().put('id', lead.Id);
        ApexPages.currentPage().getParameters().put('saved', 'true');
        new DVMedicalSummaryAttachment_AC();
        Test.stopTest();
    }

    @IsTest
    public static void findAttachmentIdAlt2Mp() {
        Lead lead = [
                SELECT Id, Hidden_DV_form_Medical_professional_Type__c, Referring_MP__c, Treating_MP__c, Best_Contact__c,
                        Alt_1_MP__c, Alt_2_MP__c
                FROM Lead
                WHERE Name = 'Jack Smith'
        ];
        lead.Hidden_DV_form_Medical_professional_Type__c = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL;
        update lead;

        Test.startTest();
        Test.setCurrentPage(Page.DVMedicalSummaryAttachment_VF);
        ApexPages.currentPage().getParameters().put('id', lead.Id);
        ApexPages.currentPage().getParameters().put('saved', 'true');
        new DVMedicalSummaryAttachment_AC();
        Test.stopTest();
    }
}