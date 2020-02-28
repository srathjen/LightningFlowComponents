/*****************************************************************************************************************
Created By : MST Solutions
Created Date : 1/23/2017
Description : This test class used to perform unit testing for the DV Medical Summary Attachment

Modification Log:
09/10/2019 - Manik - WLP-423
*******************************************************************************************************************/
@IsTest
public class DVMedicalSummaryAttachment_AC_Test {

    private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;

    @TestSetup
    public static void setup() {
        User currUser = [
                SELECT Id
                FROM User
                WHERE Id = :UserInfo.getUserId()
                LIMIT 1
        ];
        List<Account> accounts = TestDataFactory.createAccount(1);
        Account account = accounts.get(0);
        account.Name = 'Make-A-Wish Arizona';
        account.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
        account.Volunteer_Manager__c = currUser.Id;
        account.Alert_for_Unassigned_Wishes__c = 1;
        insert accounts;
        List<ICD_Codes__c> icdCodes = TestDataFactory.createIcdCode(1);
        insert icdCodes;
        List<Lead> leadsDataFactory = TestDataFactory.createLead(1);
        Lead lead = leadsDataFactory.get(0);
        lead.ChapterName__c = accounts[0].Id;
        lead.FirstName = 'Jack';
        lead.LastName = 'Smith';
        lead.unique_wish_identifier__c = '059-17-12367';
        lead.is_Family_Aware_of_Referral__c = 'Yes';
        lead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
        lead.PD_ICD_Code__c = icdCodes[0].Id;
        lead.Company = 'MAWA';
        insert leadsDataFactory;
        List<cg__Lead_File__c> leadFilesDataFactory = TestDataFactory.createLeadFile(1);
        cg__Lead_File__c leadFile = leadFilesDataFactory.get(0);
        leadFile.cg__Lead__c = lead.Id;
        insert leadFilesDataFactory;
    }

	//Attachment for Diagnosis Verification
    @IsTest
	public static void getAttachmentWhenSaved() {
		Lead lead = [
				SELECT Id
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
		currDiagnosisVerificationDupe.Refresh();
		currDiagnosisVerificationDupe.attachmentId = leadFile[0].Id;
		currDiagnosisVerificationDupe.removeAttachment();
		Test.stopTest();
	}

    //Attachment for Diagnosis Verification
    @IsTest
    public static void getAttachmentWhenDeleted() {
        Lead lead = [
                SELECT Id
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
        currDiagnosisVerificationDupe.Refresh();
        currDiagnosisVerificationDupe.attachmentId = leadFile[0].Id;
        currDiagnosisVerificationDupe.removeAttachment();
        Test.stopTest();
    }
}