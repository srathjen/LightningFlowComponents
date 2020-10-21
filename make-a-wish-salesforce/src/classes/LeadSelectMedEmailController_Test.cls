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

        List<Contact> contacts = TestDataFactory.createContact(6);
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

        Contact referringMp = contacts.get(1);
        referringMp.AccountId = account.Id;
        referringMp.FirstName = 'Bob';
        referringMp.LastName = 'ReferringMp';
        referringMp.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        referringMp.npe01__WorkEmail__c = 'bob@email.com';
        referringMp.npe01__AlternateEmail__c = 'bobAlt1@email.com';
        referringMp.Alternate_Email_2__c = 'bobAlt2@email.com';
        referringMp.Contact_Notes__c = 'Contact notes for Referring MP';
        referringMp.Region_Chapter__c = account.Id;

        Contact treatingMp = contacts.get(2);
        treatingMp.AccountId = account.Id;
        treatingMp.FirstName = 'Jack';
        treatingMp.LastName = 'TreatingMp';
        treatingMp.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        treatingMp.npe01__WorkEmail__c = 'jack@email.com';
        treatingMp.npe01__AlternateEmail__c = 'jackAlt2@email.com';
        treatingMp.Alternate_Email_2__c = 'jackAlt2@email.com';
        treatingMp.Contact_Notes__c = 'Contact notes for Treating MP';
        treatingMp.Region_Chapter__c = account.Id;

        Contact bestMp = contacts.get(3);
        bestMp.AccountId = account.Id;
        bestMp.FirstName = 'Mark';
        bestMp.LastName = 'BestMp';
        bestMp.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        bestMp.npe01__WorkEmail__c = 'mark@email.com';
        bestMp.npe01__AlternateEmail__c = 'markAlt2@email.com';
        bestMp.Alternate_Email_2__c = 'markAlt2@email.com';
        bestMp.Contact_Notes__c = 'Contact notes for Best MP';
        bestMp.Region_Chapter__c = account.Id;

        Contact alt1Mp = contacts.get(4);
        alt1Mp.AccountId = account.Id;
        alt1Mp.FirstName = 'Joe';
        alt1Mp.LastName = 'Alt1Mp';
        alt1Mp.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        alt1Mp.npe01__WorkEmail__c = 'joe@email.com';
        alt1Mp.npe01__AlternateEmail__c = 'joeAlt1@email.com';
        alt1Mp.Alternate_Email_2__c = 'joeAlt2@email.com';
        alt1Mp.Contact_Notes__c = 'Contact notes for Alt 1 MP';
        alt1Mp.Region_Chapter__c = account.Id;

        Contact alt2Mp = contacts.get(5);
        alt2Mp.AccountId = account.Id;
        alt2Mp.FirstName = 'Dan';
        alt2Mp.LastName = 'Alt2Mp';
        alt2Mp.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        alt2Mp.npe01__WorkEmail__c = 'dan@email.com';
        alt2Mp.npe01__AlternateEmail__c = 'danAlt2@email.com';
        alt2Mp.Alternate_Email_2__c = 'danAlt2@email.com';
        alt2Mp.Contact_Notes__c = 'Contact notes for Alt 2 MP';
        alt2Mp.Region_Chapter__c = account.Id;
        insert contacts;

        List<Lead> leads = TestDataFactory.createLead(1);
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
        lead.PD_Condition_Description__c = 'Test Diagnosis';
        lead.Parent_First_Name__c = 'MAWAFirstJune';
        lead.Parent_Last_Name__c = 'MAWALastJune';
        lead.Referring_MP__c = referringMp.Id;
        lead.Referring_MP_Email__c = 'mp@email.com';
        lead.Treating_MP__c = treatingMp.Id;
        lead.Treating_Medical_Professional_Email__c = 'mp@email.com';
        lead.Best_Contact__c = bestMp.Id;
        lead.Best_contact_for_Physician_Email__c = 'mp@email.com';
        lead.Alt_1_MP__c = alt1Mp.Id;
        lead.Alt_2_MP__c = alt2Mp.Id;
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
        lead.Relationship_to_child__c = Constant_AC.LEAD_RELATIONSHIP_TO_CHILD_MEDICAL_PROFESSIONAL;
        insert leads;

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
    public static void sendDVFormToMedicalProfessional() {
        Lead lead = [
                SELECT Id, FirstName, ChapterName__c, Part_A_Form_Password__c, Part_A_Sent__c,
                        Part_A_Received__c, Using_Paper_Process_For_DV__c,
                        HiddenMedicalProfessionalEmail__c, Of_Times_Email_Sent__c, Referring_MP__c,
                        Referring_MP__r.Name, Referring_MP__r.npe01__WorkEmail__c,
                        Referring_MP__r.npe01__AlternateEmail__c, Referring_MP__r.Alternate_Email_2__c,
                        Referring_MP__r.Contact_Notes__c, Treating_MP__c, Treating_MP__r.Name,
                        Treating_MP__r.npe01__WorkEmail__c, Treating_MP__r.npe01__AlternateEmail__c,
                        Treating_MP__r.Alternate_Email_2__c, Treating_MP__r.Contact_Notes__c,
                        Best_Contact__c, Best_Contact__r.Name, Best_Contact__r.npe01__WorkEmail__c,
                        Best_Contact__r.npe01__AlternateEmail__c, Best_Contact__r.Alternate_Email_2__c,
                        Best_Contact__r.Contact_Notes__c, Alt_1_MP__c, Alt_1_MP__r.Name,
                        Alt_1_MP__r.npe01__WorkEmail__c, Alt_1_MP__r.npe01__AlternateEmail__c,
                        Alt_1_MP__r.Alternate_Email_2__c, Alt_1_MP__r.Contact_Notes__c, Alt_2_MP__c,
                        Alt_2_MP__r.Name, Alt_2_MP__r.npe01__WorkEmail__c, Alt_2_MP__r.npe01__AlternateEmail__c,
                        Alt_2_MP__r.Alternate_Email_2__c, Alt_2_MP__r.Contact_Notes__c, Hidden_DV_Form_Name__c
                FROM Lead
                WHERE Name = 'Jack Smith'
        ];
        PageReference pageRef = Page.LeadSelectMedEmail_VF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', lead.Id);
        ApexPages.currentPage().getParameters().put('action', 'sendDv');
        ApexPages.currentPage().getParameters().put('email', lead.HiddenMedicalProfessionalEmail__c);
        LeadSelectMedEmailController_AC selectLead = new LeadSelectMedEmailController_AC();
        selectLead.sendDiagnosisVerification();
        selectLead.GoToLeadViewPage();
        System.assert(selectLead.success);
    }
}