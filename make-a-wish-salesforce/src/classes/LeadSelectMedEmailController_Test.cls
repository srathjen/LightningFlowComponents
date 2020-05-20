@IsTest
public class LeadSelectMedEmailController_Test {

    private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;

    @TestSetup
    public static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;

        List<Account> accounts = TestDataFactory.createAccount(1);
        Account account = accounts.get(0);
        account.Name = 'Make-A-Wish Arizona';
        account.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
        insert accounts;

        List<ICD_Codes__c> icdCodesDataFactory = TestDataFactory.createIcdCode(1);
        ICD_Codes__c icdCode = icdCodesDataFactory.get(0);
        insert icdCode;

        List<Lead> leads = TestDataFactory.createLead(2);
        Lead lead = leads.get(0);
        lead.ChapterName__c = accounts[0].Id;
        lead.FirstName = 'Jack';
        lead.LastName = 'Smith';
        lead.HiddenMedicalProfessionalEmail__c = 'TestMed@test.org';
        lead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
        lead.PD_ICD_Code__c = icdCode.Id;
        lead.Phone = '9600467559';
        lead.Email = 'testmawa@gmail.com';
        lead.Street = 'KuttaiKarai Street';
        lead.StateCode = 'AZ';
        lead.City = 'Trichy';
        lead.PostalCode = '6201717';
        lead.CountryCode = 'US';
        lead.DOB__c = System.today() - 1435;
        lead.Company = 'MAW';
        lead.Status = 'Inquiry';
        lead.Gender__c = 'Male';
        lead.Referrer_FirstName__c = 'SteveJune';
        lead.Referrer_Last_Name__c = 'Waughone';
        lead.Referrer_Email__c = 'testmawa2d@gmail.com';
        lead.Referrer_Phone__c = '9600467578';
        lead.Referrer_City__c = 'Trichy';
        lead.Referrer_Zip__c = '6210';
        lead.Sibling_Detail__c = 'aa | aaab | 14 bbb | bbbc | 15';
        lead.PD_Condition_Description__c = 'Test Diagnosis';
        lead.Parent_First_Name__c = 'MAWAFirstJune';
        lead.Parent_Last_Name__c = 'MAWALastJune';
        lead.Medical_Professional_First_Name__c = 'SteveJune';
        lead.Medical_Professional_Last_Name__c = 'Waughone';
        lead.Medical_Professional_Phone__c = '9600467578';
        lead.Medical_Professional_Email__c = 'testmawa2d@gmail.com';
        lead.Hospital_Treatment_Facility__c = 'Steve Smith AC';
        lead.Treating_Medical_Professional_First_Name__c = 'SteveJune';
        lead.Treating_Medical_Professional_Last_Name__c = 'Waughone';
        lead.Treating_Medical_Professional_Phone__c = '9600467578';
        lead.Treating_Medical_Professional_Email__c = 'testmawa2d@gmail.com';
        lead.Hospital_Treatment_Facility_Treating__c = 'Steve Smith AC';
        lead.Best_Contact_for_Physician_First_Name__c = 'SteveJune';
        lead.Best_Contact_for_Physician_Last_Name__c = 'Waughone';
        lead.Best_contact_for_Physician_Email__c = 'testmawa2d@gmail.com';
        lead.is_Family_Aware_of_Referral__c = 'Yes';
        lead.Medical_Questions__c = 'Test Diagnosis';
        lead.Lung_Disease__c = 'Test1;Test2';
        lead.Angina__c = 'Test1;Test2';
        lead.Ventilator__c = 'Test1;Test2';
        lead.Arrhythmia__c = 'Test1;Test2';
        lead.Heart_Failure__c = 'Test1;Test2';
        lead.Congenital_Heart_Disease__c = 'Test1;Test2';
        lead.Chronic_Hepatitis__c = 'Test1;Test2';
        lead.Convulsive_Disorders__c = 'Test1;Test2';
        lead.Pulmonary_Hypertension__c = 'Test1;Test2';
        lead.Strokes__c = 'Test1;Test2';
        lead.Chronic_Heart_Failure__c = 'Test1;Test2';
        lead.isSign__c = true;
        lead.Travel_algorithm__c = 'Test1;Test2;';
        Lead lead2 = leads.get(1);
        lead2.ChapterName__c = accounts[0].Id;
        lead2.FirstName = 'Mark';
        lead2.LastName = 'Smith';
        lead2.Hidden_Chapter_Change_Confirmation__c = account.Id;
        lead2.is_Family_Aware_of_Referral__c = 'Yes';
        lead2.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
        lead2.PD_ICD_Code__c = icdCode.Id;
        lead2.Company = 'MAW';
        insert leads;

        List<Contact> contacts = TestDataFactory.createContact(1);
        Contact wishChildContact1 = contacts.get(0);
        wishChildContact1.AccountId = account.Id;
        wishChildContact1.FirstName = 'Will';
        wishChildContact1.LastName = 'Smith';
        wishChildContact1.ICD_10_Code__c = icdCode.Id;
        wishChildContact1.Birthdate = Date.today().addYears(-10);
        wishChildContact1.MailingPostalCode = '12345-9876';
        wishChildContact1.MailingStreet = 'Mark Street';
        wishChildContact1.MailingCountry = 'United States';
        wishChildContact1.MailingState = 'Arizona';
        wishChildContact1.MailingCity = 'Phoenix';
        insert contacts;

        List<Case> cases = TestDataFactory.createCase(1);
        Case wish = cases.get(0);
        wish.Lead__c = lead.Id;
        wish.RecordTypeId = Constant_AC.DIAGNOSIS_RT_ID;
        wish.ChapterName__c = accounts.get(0).Id;
        wish.Subject = 'Wish1';
        wish.Interview_date__c = System.today();
        wish.Wish_Type__c = 'Hawaii';
        wish.Start_Date__c = System.today();
        wish.End_Date__c = System.today();
        wish.ContactId = wishChildContact1.Id;
        wish.Status = 'New';
        wish.Start_Date__c = System.today();
        wish.Budget_Submitted_Date__c = System.today();
        wish.Budget_Approved_Date__c = System.today();
        wish.Update_Wish_Child_Form_Info__c = true;
        insert cases;

        List<dsfs__DocuSign_Status__c> docuSignStatuses = TestDataFactory.createDocusignStatus(1);
        dsfs__DocuSign_Status__c docuSignStatus = docuSignStatuses.get(0);
        docuSignStatus.dsfs__Lead__c = lead.Id;
        insert docuSignStatuses;

        List<Attachment> attachments = TestDataFactory.createAttachments(1, docuSignStatus.Id);
        insert attachments;

        List<cg__Lead_File__c> leadFilesDataFactory = TestDataFactory.createLeadFile(1);
        cg__Lead_File__c leadFile = leadFilesDataFactory.get(0);
        leadFile.cg__Lead__c = lead.Id;
        leadFile.cg__Content_Type__c = 'Text';
        insert leadFilesDataFactory;

        trac_TriggerHandlerBase.blockTrigger = false;
    }

    @IsTest
    public static void sendDVFormToBestPhysician() {
        Lead lead = [
                SELECT Id, HiddenMedicalProfessionalEmail__c
                FROM Lead
                WHERE Name = 'Jack Smith'
        ];
        PageReference pageRef = Page.LeadSelectMedEmail_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', lead.Id);
        ApexPages.currentPage().getParameters().put('sendOrRest', 'Reset');
        ApexPages.currentPage().getParameters().put('email', lead.HiddenMedicalProfessionalEmail__c);
        LeadSelectMedEmailController_AC selectLead = new LeadSelectMedEmailController_AC();
        selectLead.updateLead();
        selectLead.GoToLeadViewPage();
        System.assert(selectLead.success);
    }

    @IsTest
    public static void testSendError() {
        Lead lead = [
                SELECT Id, HiddenMedicalProfessionalEmail__c
                FROM Lead
                WHERE Name = 'Jack Smith'
        ];
        PageReference pageRef = Page.LeadSelectMedEmail_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', lead.Id);
        ApexPages.currentPage().getParameters().put('sendOrRest', 'Reset');
        LeadSelectMedEmailController_AC selectLead = new LeadSelectMedEmailController_AC();
        selectLead.updateLead();
        selectLead.GoToLeadViewPage();
        System.assert(!selectLead.success);
    }

    @IsTest
    public static void shouldNotResetLeadValuesWhenInvalidLead() {
        Lead invalidLead = [
                SELECT Id
                FROM Lead
                WHERE Name = 'Mark Smith'
        ];
        PageReference pageRef = Page.LeadSelectMedEmail_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', invalidLead.Id);
        LeadSelectMedEmailController_AC selectLead = new LeadSelectMedEmailController_AC();
        selectLead.resetDVValues();
        System.assert(!selectLead.success);
    }
}