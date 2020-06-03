/**
 * @description
 * @author mbuhler
 * @date 7/11/2019.
 */
@IsTest
public class WishAffiliationServiceTest {

    private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;
    private final static Id WISH_RECORD_TYPE_ID = Constant_AC.WISH_RT_ID;
    private static final String WISH_AFFILIATION_API_NAME = Constant_AC.WISH_AFFILIATION_API_NAME;
    private static final String CONTACT_API_NAME = Constant_AC.CONTACT_API_NAME;
    private static final String RELATIONSHIP_API_NAME = Constant_AC.RELATIONSHIP_API_NAME;

    @TestSetup
    public static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;

        insert new Bypass_Triggers__c(SetupOwnerId = UserInfo.getUserId());

        List<Account> accounts = TestDataFactory.createAccount(2);
        Account account = accounts.get(0);
        account.Name = 'Make-A-Wish Arizona';
        account.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
        Account hospital = accounts.get(1);
        hospital.Name = 'Make-A-Wish Arizona Hospital';
        hospital.RecordTypeId = Constant_AC.HOSPITAL_TREATMENT_ID;
        insert accounts;

        List<ICD_Codes__c> icdCodesDataFactory = TestDataFactory.createIcdCode(1);
        ICD_Codes__c icdCode = icdCodesDataFactory.get(0);
        insert icdCode;

        List<Contact> contactsDataFactory = TestDataFactory.createContact(4);
        List<Contact> contacts = new List<Contact>();
        Contact wishChildContact1 = contactsDataFactory.get(0);
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
        Contact wishChildContact2 = contactsDataFactory.get(1);
        wishChildContact2.FirstName = 'Mark';
        wishChildContact2.LastName = 'Smith';
        wishChildContact2.ICD_10_Code__c = icdCode.Id;
        wishChildContact2.Birthdate = Date.today().addYears(-10);
        wishChildContact2.MailingPostalCode = '12345-9876';
        wishChildContact2.MailingStreet = 'Mark Street';
        wishChildContact2.MailingCountry = 'United States';
        wishChildContact2.MailingState = 'Arizona';
        wishChildContact2.MailingCity = 'Phoenix';
        Contact wishFamilyContact = contactsDataFactory.get(2);
        wishFamilyContact.FirstName = 'Jack';
        wishFamilyContact.Middle_Name__c = 'D';
        wishFamilyContact.LastName = 'Smith';
        wishFamilyContact.Birthdate = Date.parse('1/1/2000');
        wishFamilyContact.RecordTypeId = '01236000000xW2qAAE';
        wishFamilyContact.MailingPostalCode = '12345-9876';
        wishFamilyContact.MailingStreet = 'Jack Street';
        wishFamilyContact.MailingCountry = 'United States';
        wishFamilyContact.MailingState = 'Arizona';
        wishFamilyContact.MailingCity = 'Phoenix';
        wishFamilyContact.npe01__HomeEmail__c = 'jds@email.com';
        wishFamilyContact.T_Shirt_Size__c = 'S';
        Contact wishFamilyContact2 = contactsDataFactory.get(3);
        wishFamilyContact2.FirstName = 'Billy';
        wishFamilyContact2.LastName = 'Smith';
        wishFamilyContact2.RecordTypeId = '01236000000xW2qAAE';
        wishFamilyContact2.MailingPostalCode = '12345-9876';
        wishFamilyContact2.MailingStreet = 'Jack Street';
        wishFamilyContact2.MailingCountry = 'United States';
        wishFamilyContact2.MailingState = 'Arizona';
        wishFamilyContact2.MailingCity = 'Phoenix';
        contacts.add(wishChildContact1);
        contacts.add(wishChildContact2);
        contacts.add(wishFamilyContact);
        contacts.add(wishFamilyContact2);
        insert contacts;

        List<Lead> leadsDataFactory = TestDataFactory.createLead(1);
        Lead lead = leadsDataFactory.get(0);
        lead.ChapterName__c = accounts[0].Id;
        lead.FirstName = 'Will';
        lead.LastName = 'Smith';
        lead.Phone = '5555555555';
        lead.Email = 'js@email.com';
        lead.Street = '123 St';
        lead.StateCode = 'AZ';
        lead.City = 'Phoenix';
        lead.PostalCode = '85001';
        lead.CountryCode = 'US';
        lead.DOB__c = System.today() - 1435;
        lead.IsConverted = true;
        lead.ConvertedAccountId = account.Id;
        lead.ConvertedContactId = wishChildContact1.Id;
        lead.Company = 'MAWA';
        lead.Status = 'Inquiry';
        lead.Gender__c = 'Male';
        lead.Referrer_FirstName__c = 'Carol';
        lead.Referrer_Last_Name__c = 'Jones';
        lead.Referrer_Email__c = 'cj@email.com';
        lead.Referrer_Phone__c = '5555555555';
        lead.Referrer_City__c = 'Phoenix';
        lead.Referrer_Zip__c = '85123';
        lead.Sibling_Detail__c = 'aa | aaab | 14 bbb | bbbc | 15';
        lead.PD_Condition_Description__c = 'Test Diagnosis';
        lead.Parent_First_Name__c = 'Bob';
        lead.Parent_Last_Name__c = 'Smith';
        lead.Medical_Professional_First_Name__c = 'Dr Max';
        lead.Medical_Professional_Last_Name__c = 'Roger';
        lead.Medical_Professional_Phone__c = '55555555555';
        lead.Medical_Professional_Email__c = 'testmawa1s@gmail.com';
        lead.Hospital_Treatment_Facility__c = 'Banner Hospital';
        lead.Treating_Medical_Professional_First_Name__c = 'Dr Max';
        lead.Treating_Medical_Professional_Last_Name__c = 'Roger';
        lead.Treating_Medical_Professional_Phone__c = '5555555555';
        lead.Treating_Medical_Professional_Email__c = 'testmawa2d@gmail.com';
        lead.Hospital_Treatment_Facility_Treating__c = 'Banner Hospital';
        lead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
        lead.is_Family_Aware_of_Referral__c = 'Yes';
        lead.Medical_Questions__c = 'Test Diagnosis';
        lead.PD_ICD_Code__c = icdCode.Id;
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
        insert lead;

        List<Case> casesDataFactory = TestDataFactory.createCase(2);
        List<Case> cases = new List<Case>();
        Case wishCase1 = casesDataFactory.get(0);
        wishCase1.RecordTypeId = WISH_RECORD_TYPE_ID;
        wishCase1.ChapterName__c = accounts.get(0).Id;
        wishCase1.Subject = 'Wish1';
        wishCase1.Interview_date__c = System.today();
        wishCase1.Wish_Type__c = 'Hawaii';
        wishCase1.Start_Date__c = System.today();
        wishCase1.End_Date__c = System.today();
        wishCase1.ContactId = wishChildContact2.Id;
        wishCase1.Status = 'New';
        wishCase1.Start_Date__c = System.today();
        wishCase1.Budget_Submitted_Date__c = System.today();
        wishCase1.Budget_Approved_Date__c = System.today();
        wishCase1.Update_Wish_Child_Form_Info__c = true;
        Case wishCase2 = casesDataFactory.get(1);
        wishCase2.RecordTypeId = WISH_RECORD_TYPE_ID;
        wishCase2.ChapterName__c = accounts.get(0).Id;
        wishCase2.Subject = 'Wish2';
        wishCase2.Interview_date__c = System.today();
        wishCase2.Wish_Type__c = 'Disney World';
        wishCase2.Start_Date__c = System.today();
        wishCase2.End_Date__c = System.today();
        wishCase2.ContactId = wishChildContact2.Id;
        wishCase2.Status = 'New';
        wishCase2.Start_Date__c = System.today();
        wishCase2.Budget_Submitted_Date__c = System.today();
        wishCase2.Budget_Approved_Date__c = System.today();
        wishCase2.Update_Wish_Child_Form_Info__c = true;
        cases.add(wishCase1);
        cases.add(wishCase2);
        insert cases;

        List<npe4__Relationship__c> relationshipsDataFactory = TestDataFactory.createRelationship(3);
        List<npe4__Relationship__c> relationships = new List<npe4__Relationship__c>();
        npe4__Relationship__c relationship1 = relationshipsDataFactory.get(0);
        relationship1.npe4__Type__c = 'Father';
        relationship1.npe4__Description__c = 'Jack Smith is Will Smiths Father';
        relationship1.Parent_Legal_Guardian__c = false;
        relationship1.npe4__Contact__c = wishChildContact1.Id;
        relationship1.npe4__RelatedContact__c = wishFamilyContact.Id;
        npe4__Relationship__c relationship2 = relationshipsDataFactory.get(1);
        relationship2.npe4__Type__c = Constant_AC.MEDICAL_PROFESSIONAL_RT_LABEL;
        relationship2.npe4__Description__c = 'Jack Smith is Mark Smiths Father';
        relationship2.Parent_Legal_Guardian__c = false;
        relationship2.npe4__Contact__c = wishChildContact2.Id;
        relationship2.npe4__RelatedContact__c = wishFamilyContact.Id;
        npe4__Relationship__c relationship3 = relationshipsDataFactory.get(2);
        relationship3.npe4__Type__c = 'Brother';
        relationship3.npe4__Description__c = 'Billy Smith is Mark Smiths Brother';
        relationship3.Parent_Legal_Guardian__c = false;
        relationship3.npe4__Contact__c = wishChildContact2.Id;
        relationship3.npe4__RelatedContact__c = wishFamilyContact.Id;
        relationships.add(relationship1);
        relationships.add(relationship2);
        relationships.add(relationship3);
        insert relationships;

        Wish_Affiliation_Category__mdt wishAffiliationCategory = [
                SELECT Type__c, Is_Default_for_Category__c
                FROM Wish_Affiliation_Category__mdt
                WHERE Type__c <> 'Wish Child'
                LIMIT 1
        ];
        trac_TriggerHandlerBase.blockTrigger = false;

        List<Wish_Affiliation__c> wishAffiliationsDataFactory = TestDataFactory.createWishAffiliation(2);
        List<Wish_Affiliation__c> wishAffiliations = new List<Wish_Affiliation__c>();
        Wish_Affiliation__c wishAffiliationParticipant1 = wishAffiliationsDataFactory.get(0);
        wishAffiliationParticipant1.Wish__c = wishCase2.Id;
        wishAffiliationParticipant1.Non_Comped__c = false;
        wishAffiliationParticipant1.Survey_Recipient__c = false;
        wishAffiliationParticipant1.Medical_Needs__c = false;
        wishAffiliationParticipant1.Contact__c = wishFamilyContact.Id;
        wishAffiliationParticipant1.Relationship__c = relationship2.Id;
        wishAffiliationParticipant1.Health_Treatment_Facility__c = hospital.Id;
        wishAffiliationParticipant1.Residing_with_Wish_child__c = 'Yes';
        wishAffiliationParticipant1.Wish_Affiliation_Type__c = wishAffiliationCategory.Type__c;
        wishAffiliationParticipant1.Hide_from_Restricted_Users__c = false;
        Wish_Affiliation__c wishAffiliationParticipant2 = wishAffiliationsDataFactory.get(1);
        wishAffiliationParticipant2.Wish__c = wishCase2.Id;
        wishAffiliationParticipant2.Non_Comped__c = false;
        wishAffiliationParticipant2.Survey_Recipient__c = false;
        wishAffiliationParticipant2.Medical_Needs__c = false;
        wishAffiliationParticipant2.Contact__c = wishFamilyContact2.Id;
        wishAffiliationParticipant2.Relationship__c = relationship3.Id;
        wishAffiliationParticipant2.Residing_with_Wish_child__c = 'No';
        wishAffiliationParticipant2.Wish_Affiliation_Type__c = wishAffiliationCategory.Type__c;
        wishAffiliationParticipant2.Hide_from_Restricted_Users__c = true;
        wishAffiliations.add(wishAffiliationParticipant1);
        wishAffiliations.add(wishAffiliationParticipant2);
        insert wishAffiliations;
        update wishAffiliations;

        List<Wish_Change_Request__c> wishChangeRequestsDataFactory = TestDataFactory.createWishChangeRequests(15, wishCase2.Id, wishAffiliationParticipant1.Id);
        List<Wish_Change_Request__c> wishChangeRequests = new List<Wish_Change_Request__c>();
        DescribeSObjectResult wishAffiliationDescribeSObjectResult = Schema.getGlobalDescribe().get(Constant_AC.WISH_AFFILIATION_API_NAME).getDescribe();
        Map<String, Schema.SObjectField> wishAffiliationFieldsByName = Schema.getGlobalDescribe().get(Constant_AC.WISH_AFFILIATION_API_NAME).getDescribe().fields.getMap();
        DescribeSObjectResult contactDescribeSObjectResult = Schema.getGlobalDescribe().get(Constant_AC.CONTACT_API_NAME).getDescribe();
        Map<String, Schema.SObjectField> contactFieldsByName = Schema.getGlobalDescribe().get(Constant_AC.CONTACT_API_NAME).getDescribe().fields.getMap();
        DescribeSObjectResult relationshipDescribeSObjectResult = Schema.getGlobalDescribe().get(Constant_AC.RELATIONSHIP_API_NAME).getDescribe();
        Map<String, Schema.SObjectField> relationshipFieldsByName = Schema.getGlobalDescribe().get(Constant_AC.RELATIONSHIP_API_NAME).getDescribe().fields.getMap();
        Wish_Change_Request__c cr1 = wishChangeRequestsDataFactory.get(0);
        Schema.DescribeFieldResult wishAffiliationType = wishAffiliationFieldsByName.get(Constant_AC.WISH_AFFILIATION_WISH_AFFILIATION_TYPE_API_NAME).getDescribe();
        cr1.Object_API_Name_for_Proposed_Change__c = wishAffiliationDescribeSObjectResult.name;
        cr1.Record_Name__c = wishAffiliationDescribeSObjectResult.label;
        cr1.Record_Id__c = wishAffiliationParticipant1.Id;
        cr1.Field_Previous_Value__c = wishAffiliationParticipant1.Wish_Affiliation_Type__c;
        cr1.Field_New_Value__c = 'Approved Participant';
        cr1.Field_API_Name_for_Proposed_Change__c = wishAffiliationType.getName();
        cr1.Field_Label_for_Proposed_Change__c = wishAffiliationType.getLabel();
        cr1.Wish_Case_Id__c = wishCase2.Id;
        cr1.Wish_Affiliation__c = wishAffiliationParticipant1.Id;
        Wish_Change_Request__c cr2 = wishChangeRequestsDataFactory.get(1);
        Schema.DescribeFieldResult residingWithWishChild = wishAffiliationFieldsByName.get(Constant_AC.WISH_AFFILIATION_RESIDING_WITH_WISH_CHILD_API_NAME).getDescribe();
        cr2.Object_API_Name_for_Proposed_Change__c = wishAffiliationDescribeSObjectResult.name;
        cr2.Record_Name__c = wishAffiliationDescribeSObjectResult.label;
        cr2.Record_Id__c = wishAffiliationParticipant1.Id;
        cr2.Field_Previous_Value__c = wishAffiliationParticipant1.Residing_with_Wish_child__c;
        cr2.Field_New_Value__c = 'Yes';
        cr2.Field_API_Name_for_Proposed_Change__c = residingWithWishChild.getName();
        cr2.Field_Label_for_Proposed_Change__c = residingWithWishChild.getLabel();
        cr2.Wish_Case_Id__c = wishCase2.Id;
        cr2.Wish_Affiliation__c = wishAffiliationParticipant1.Id;
        Wish_Change_Request__c cr3 = wishChangeRequestsDataFactory.get(2);
        Schema.DescribeFieldResult firstName = contactFieldsByName.get(Constant_AC.CONTACT_FIRSTNAME_API_NAME).getDescribe();
        cr3.Object_API_Name_for_Proposed_Change__c = contactDescribeSObjectResult.name;
        cr3.Record_Name__c = contactDescribeSObjectResult.label;
        cr3.Record_Id__c = wishFamilyContact.Id;
        cr3.Field_Previous_Value__c = String.valueOf(wishFamilyContact.FirstName);
        cr3.Field_New_Value__c = 'Sam';
        cr3.Field_API_Name_for_Proposed_Change__c = firstName.getName();
        cr3.Field_Label_for_Proposed_Change__c = firstName.getLabel();
        cr3.Wish_Case_Id__c = wishCase2.Id;
        cr3.Wish_Affiliation__c = wishAffiliationParticipant1.Id;
        Wish_Change_Request__c cr4 = wishChangeRequestsDataFactory.get(3);
        Schema.DescribeFieldResult lastName = contactFieldsByName.get(Constant_AC.CONTACT_LASTNAME_API_NAME).getDescribe();
        cr4.Object_API_Name_for_Proposed_Change__c = contactDescribeSObjectResult.name;
        cr4.Record_Name__c = contactDescribeSObjectResult.label;
        cr4.Record_Id__c = wishFamilyContact.Id;
        cr4.Field_Previous_Value__c = wishFamilyContact.LastName;
        cr4.Field_New_Value__c = 'Johnson';
        cr4.Field_API_Name_for_Proposed_Change__c = lastName.getName();
        cr4.Field_Label_for_Proposed_Change__c = lastName.getLabel();
        cr4.Wish_Case_Id__c = wishCase2.Id;
        cr4.Wish_Affiliation__c = wishAffiliationParticipant1.Id;
        Wish_Change_Request__c cr5 = wishChangeRequestsDataFactory.get(4);
        Schema.DescribeFieldResult birthdate = contactFieldsByName.get(Constant_AC.CONTACT_BIRTHDATE_API_NAME).getDescribe();
        cr5.Object_API_Name_for_Proposed_Change__c = contactDescribeSObjectResult.name;
        cr5.Record_Name__c = contactDescribeSObjectResult.label;
        cr5.Record_Id__c = wishFamilyContact.Id;
        cr5.Field_Previous_Value__c = String.valueOf(wishFamilyContact.Birthdate);
        cr5.Field_New_Value__c = '1/30/2000';
        cr5.Field_API_Name_for_Proposed_Change__c = birthdate.getName();
        cr5.Field_Label_for_Proposed_Change__c = birthdate.getLabel();
        cr5.Wish_Case_Id__c = wishCase2.Id;
        cr5.Wish_Affiliation__c = wishAffiliationParticipant1.Id;
        Wish_Change_Request__c cr6 = wishChangeRequestsDataFactory.get(5);
        Schema.DescribeFieldResult mailingStreet = contactFieldsByName.get(Constant_AC.CONTACT_MAILINGSTREET_API_NAME).getDescribe();
        cr6.Object_API_Name_for_Proposed_Change__c = contactDescribeSObjectResult.name;
        cr6.Record_Name__c = contactDescribeSObjectResult.label;
        cr6.Record_Id__c = wishFamilyContact.Id;
        cr6.Field_Previous_Value__c = String.valueOf(wishFamilyContact.MailingStreet);
        cr6.Field_New_Value__c = 'Sam Street';
        cr6.Field_API_Name_for_Proposed_Change__c = mailingStreet.getName();
        cr6.Field_Label_for_Proposed_Change__c = mailingStreet.getLabel();
        cr6.Wish_Case_Id__c = wishCase2.Id;
        cr6.Wish_Affiliation__c = wishAffiliationParticipant1.Id;
        Wish_Change_Request__c cr7 = wishChangeRequestsDataFactory.get(6);
        Schema.DescribeFieldResult mailingCity = contactFieldsByName.get(Constant_AC.CONTACT_MAILINGCITY_API_NAME).getDescribe();
        cr7.Object_API_Name_for_Proposed_Change__c = contactDescribeSObjectResult.name;
        cr7.Record_Name__c = contactDescribeSObjectResult.label;
        cr7.Record_Id__c = wishFamilyContact.Id;
        cr7.Field_Previous_Value__c = wishFamilyContact.MailingCity;
        cr7.Field_New_Value__c = 'New York';
        cr7.Field_API_Name_for_Proposed_Change__c = mailingCity.getName();
        cr7.Field_Label_for_Proposed_Change__c = mailingCity.getLabel();
        cr7.Wish_Case_Id__c = wishCase2.Id;
        cr7.Wish_Affiliation__c = wishAffiliationParticipant1.Id;
        Wish_Change_Request__c cr8 = wishChangeRequestsDataFactory.get(7);
        Schema.DescribeFieldResult mailingState = contactFieldsByName.get(Constant_AC.CONTACT_MAILINGSTATE_API_NAME).getDescribe();
        cr8.Object_API_Name_for_Proposed_Change__c = contactDescribeSObjectResult.name;
        cr8.Record_Name__c = contactDescribeSObjectResult.label;
        cr8.Record_Id__c = wishFamilyContact.Id;
        cr8.Field_Previous_Value__c = wishFamilyContact.MailingCity;
        cr8.Field_New_Value__c = 'New York';
        cr8.Field_API_Name_for_Proposed_Change__c = mailingState.getName();
        cr8.Field_Label_for_Proposed_Change__c = mailingState.getLabel();
        cr8.Wish_Case_Id__c = wishCase2.Id;
        cr8.Wish_Affiliation__c = wishAffiliationParticipant1.Id;
        Wish_Change_Request__c cr9 = wishChangeRequestsDataFactory.get(8);
        Schema.DescribeFieldResult mailingCountry = contactFieldsByName.get(Constant_AC.CONTACT_MAILINGCOUNTRY_API_NAME).getDescribe();
        cr9.Object_API_Name_for_Proposed_Change__c = contactDescribeSObjectResult.name;
        cr9.Record_Name__c = contactDescribeSObjectResult.label;
        cr9.Record_Id__c = wishFamilyContact.Id;
        cr9.Field_Previous_Value__c = wishFamilyContact.MailingCountry;
        cr9.Field_New_Value__c = 'United States';
        cr9.Field_API_Name_for_Proposed_Change__c = mailingCountry.getName();
        cr9.Field_Label_for_Proposed_Change__c = mailingCountry.getLabel();
        cr9.Wish_Case_Id__c = wishCase2.Id;
        cr9.Wish_Affiliation__c = wishAffiliationParticipant1.Id;
        Wish_Change_Request__c cr10 = wishChangeRequestsDataFactory.get(9);
        Schema.DescribeFieldResult mailingPostalCode = contactFieldsByName.get(Constant_AC.CONTACT_MAILINGPOSTALCODE_API_NAME).getDescribe();
        cr10.Object_API_Name_for_Proposed_Change__c = contactDescribeSObjectResult.name;
        cr10.Record_Name__c = contactDescribeSObjectResult.label;
        cr10.Record_Id__c = wishFamilyContact.Id;
        cr10.Field_Previous_Value__c = wishFamilyContact.MailingPostalCode;
        cr10.Field_New_Value__c = '98765-4321';
        cr10.Field_API_Name_for_Proposed_Change__c = mailingPostalCode.getName();
        cr10.Field_Label_for_Proposed_Change__c = mailingPostalCode.getLabel();
        cr10.Wish_Case_Id__c = wishCase2.Id;
        cr10.Wish_Affiliation__c = wishAffiliationParticipant1.Id;
        Wish_Change_Request__c cr11 = wishChangeRequestsDataFactory.get(10);
        Schema.DescribeFieldResult preferredPhone = contactFieldsByName.get(Constant_AC.CONTACT_NPE01_PREFERREDPHONE_API_NAME).getDescribe();
        cr11.Object_API_Name_for_Proposed_Change__c = contactDescribeSObjectResult.name;
        cr11.Record_Name__c = contactDescribeSObjectResult.label;
        cr11.Record_Id__c = wishFamilyContact.Id;
        cr11.Field_Previous_Value__c = wishFamilyContact.npe01__PreferredPhone__c;
        cr11.Field_New_Value__c = 'Home';
        cr11.Field_API_Name_for_Proposed_Change__c = preferredPhone.getName();
        cr11.Field_Label_for_Proposed_Change__c = preferredPhone.getLabel();
        cr11.Wish_Case_Id__c = wishCase2.Id;
        cr11.Wish_Affiliation__c = wishAffiliationParticipant1.Id;
        Wish_Change_Request__c cr12 = wishChangeRequestsDataFactory.get(11);
        Schema.DescribeFieldResult phoneNumber = contactFieldsByName.get(Constant_AC.CONTACT_PHONE_API_NAME).getDescribe();
        cr12.Object_API_Name_for_Proposed_Change__c = contactDescribeSObjectResult.name;
        cr12.Record_Name__c = contactDescribeSObjectResult.label;
        cr12.Record_Id__c = wishFamilyContact.Id;
        cr12.Field_Previous_Value__c = wishFamilyContact.Phone;
        cr12.Field_New_Value__c = '5551234567';
        cr12.Field_API_Name_for_Proposed_Change__c = phoneNumber.getName();
        cr12.Field_Label_for_Proposed_Change__c = phoneNumber.getLabel();
        cr12.Wish_Case_Id__c = wishCase2.Id;
        cr12.Wish_Affiliation__c = wishAffiliationParticipant1.Id;
        Wish_Change_Request__c cr13 = wishChangeRequestsDataFactory.get(12);
        Schema.DescribeFieldResult homeEmail = contactFieldsByName.get(Constant_AC.CONTACT_NPE01_HOMEEMAIL_API_NAME).getDescribe();
        cr13.Object_API_Name_for_Proposed_Change__c = contactDescribeSObjectResult.name;
        cr13.Record_Name__c = contactDescribeSObjectResult.label;
        cr13.Record_Id__c = wishFamilyContact.Id;
        cr13.Field_Previous_Value__c = wishFamilyContact.npe01__HomeEmail__c;
        cr13.Field_New_Value__c = 'sj@email.com';
        cr13.Field_API_Name_for_Proposed_Change__c = homeEmail.getName();
        cr13.Field_Label_for_Proposed_Change__c = homeEmail.getLabel();
        cr13.Wish_Case_Id__c = wishCase2.Id;
        cr13.Wish_Affiliation__c = wishAffiliationParticipant1.Id;
        Wish_Change_Request__c cr14 = wishChangeRequestsDataFactory.get(13);
        Schema.DescribeFieldResult relationshipType = relationshipFieldsByName.get(Constant_AC.RELATIONSHIP_NPE4_TYPE_API_NAME).getDescribe();
        cr14.Object_API_Name_for_Proposed_Change__c = relationshipDescribeSObjectResult.name;
        cr14.Record_Name__c = relationshipDescribeSObjectResult.label;
        cr14.Record_Id__c = relationship2.Id;
        cr14.Field_Previous_Value__c = relationship2.npe4__Type__c;
        cr14.Field_New_Value__c = 'Brother';
        cr14.Field_API_Name_for_Proposed_Change__c = relationshipType.getName();
        cr14.Field_Label_for_Proposed_Change__c = relationshipType.getLabel();
        cr14.Wish_Case_Id__c = wishCase2.Id;
        cr14.Wish_Affiliation__c = wishAffiliationParticipant1.Id;
        Wish_Change_Request__c cr15 = wishChangeRequestsDataFactory.get(14);
        Schema.DescribeFieldResult parentLegalGuardian = relationshipFieldsByName.get(Constant_AC.RELATIONSHIP_PARENT_LEGAL_GUARDIAN_API_NAME).getDescribe();
        cr15.Object_API_Name_for_Proposed_Change__c = relationshipDescribeSObjectResult.name;
        cr15.Record_Name__c = relationshipDescribeSObjectResult.label;
        cr15.Record_Id__c = relationship2.Id;
        cr15.Field_Previous_Value__c = String.valueOf(relationship2.Parent_Legal_Guardian__c);
        cr15.Field_New_Value__c = String.valueOf(true);
        cr15.Field_API_Name_for_Proposed_Change__c = parentLegalGuardian.getName();
        cr15.Field_Label_for_Proposed_Change__c = parentLegalGuardian.getLabel();
        cr15.Wish_Case_Id__c = wishCase2.Id;
        cr15.Wish_Affiliation__c = wishAffiliationParticipant1.Id;
        wishChangeRequests.add(cr1);
        wishChangeRequests.add(cr2);
        wishChangeRequests.add(cr3);
        wishChangeRequests.add(cr4);
        wishChangeRequests.add(cr5);
        wishChangeRequests.add(cr6);
        wishChangeRequests.add(cr7);
        wishChangeRequests.add(cr8);
        wishChangeRequests.add(cr9);
        wishChangeRequests.add(cr10);
        wishChangeRequests.add(cr11);
        wishChangeRequests.add(cr12);
        wishChangeRequests.add(cr13);
        wishChangeRequests.add(cr14);
        wishChangeRequests.add(cr15);
        insert wishChangeRequests;

    }

    @IsTest
    public static void shouldCreateWishChildWishAffiliation() {
        // ARRANGE
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        Map<Id, Case> caseMapByLeadId = new Map<Id, Case>();
        Lead lead = [
                SELECT Id, ConvertedContactId
                FROM Lead
                WHERE Name = 'Will Smith'
        ];
        Case wishCase = [
                SELECT Id
                FROM Case
                WHERE Wish_Type__c = 'Hawaii'
        ];
        leadMap.put(lead.Id, lead);
        caseMapByLeadId.put(lead.Id, wishCase);

        // ACT
        Test.startTest();
        List<Wish_Affiliation__c> wishAffiliations = WishAffiliationService.createWishChildren(caseMapByLeadId, leadMap);
        Test.stopTest();

        // ASSERT
        Wish_Affiliation__c wishAffiliation = wishAffiliations.get(0);
        System.assertEquals(1, wishAffiliations.size());
        System.assertEquals('Wish Child', wishAffiliation.Wish_Affiliation_Type__c);
    }

    @IsTest
    public static void shouldFindWishAffiliationsByTypeAndCategories() {
        // ARRANGE
        Wish_Affiliation_Category__mdt wishAffiliationCategory = [
                SELECT Category__c
                FROM Wish_Affiliation_Category__mdt
                LIMIT 1
        ];
        List<String> categories = new List<String>();
        categories.add(wishAffiliationCategory.Category__c);

        // ACT
        Test.startTest();
        List<String> types = WishAffiliationService.findWishAffiliationTypesByCategories(categories);
        Test.stopTest();

        // ASSERT
        System.assert(!types.isEmpty());
    }

    @IsTest
    public static void shouldFindWishAffiliationTypesByCategory() {
        // ARRANGE
        Wish_Affiliation_Category__mdt wishAffiliationCategory = [
                SELECT Category__c
                FROM Wish_Affiliation_Category__mdt
                LIMIT 1
        ];

        // ACT
        Test.startTest();
        Map<Object, Object> returnValuesMap = new Map<Object, Object>();
        List<String> types = WishAffiliationService.findWishAffiliationTypesByCategory(wishAffiliationCategory.Category__c, returnValuesMap);
        Test.stopTest();

        // ASSERT
        System.assert(!types.isEmpty());
    }

    @IsTest
    public static void shouldFindWishAffiliationsTypes() {
        // ACT
        Test.startTest();
        List<String> types = WishAffiliationService.findWishAffiliationTypes();
        Test.stopTest();

        // ASSERT
        System.assert(!types.isEmpty());
    }

    @IsTest
    public static void shouldFindWishAffiliations() {
        // ARRANGE
        Case wishCase = [
                SELECT Id
                FROM Case
                WHERE Wish_Type__c = 'Disney World'
        ];
        List<String> wishAffiliationTypes = new List<String>();
        for (Wish_Affiliation_Category__mdt wishAffiliationCategory : [
                SELECT Type__c
                FROM Wish_Affiliation_Category__mdt
        ]) {
            wishAffiliationTypes.add(wishAffiliationCategory.Type__c);
        }

        // ACT
        Test.startTest();
        List<Wish_Affiliation__c> wishAffiliations = WishAffiliationService.findWishAffiliationsByCaseIdAndTypes(wishCase.Id, wishAffiliationTypes);
        Test.stopTest();

        // ASSERT
        System.assertEquals(2, wishAffiliations.size());
    }

    @IsTest
    public static void shouldNotFindWishAffiliations_WhenHideFromRestrictedUsersIsTrue() {
        // ARRANGE
        Case wishCase = [
                SELECT Id
                FROM Case
                WHERE Wish_Type__c = 'Disney World'
        ];
        List<String> wishAffiliationTypes = new List<String>();
        for (Wish_Affiliation_Category__mdt wishAffiliationCategory : [
                SELECT Type__c
                FROM Wish_Affiliation_Category__mdt
        ]) {
            wishAffiliationTypes.add(wishAffiliationCategory.Type__c);
        }
        Boolean isUserAllowedToUpdateWishAffiliation = false;

        // ACT
        Test.startTest();
        List<Wish_Affiliation__c> wishAffiliations = WishAffiliationService.findWishAffiliationsByCaseIdAndTypes(wishCase.Id, wishAffiliationTypes, isUserAllowedToUpdateWishAffiliation);
        Test.stopTest();

        // ASSERT
        Wish_Affiliation__c wishAffiliation = wishAffiliations.get(0);
        System.assertEquals(1, wishAffiliations.size());
        System.assertEquals('Jack Smith', wishAffiliation.Contact__r.Name);
    }

    @IsTest
    public static void shouldFindWishAffiliationTypesNotBelongingToCategory() {
        // ARRANGE
        Wish_Affiliation_Category__mdt wishAffiliationCategory = [
                SELECT Category__c
                FROM Wish_Affiliation_Category__mdt
                LIMIT 1
        ];
        String wishAffiliationCategoryExcluded = wishAffiliationCategory.Category__c;

        // ACT
        Test.startTest();
        List<String> result = WishAffiliationService.findWishAffiliationTypesNotBelongingToCategory(wishAffiliationCategoryExcluded);
        Test.stopTest();

        // ASSERT
        List<Wish_Affiliation_Category__mdt> wishAffiliationTypes = [
                SELECT Type__c
                FROM Wish_Affiliation_Category__mdt
                WHERE Category__c = :wishAffiliationCategoryExcluded
        ];
        System.assertNotEquals(wishAffiliationTypes[0].Type__c, result[0]);
    }

    // Test for Validation Rule Wish_Child_Cannot_Be_Hidden
    @IsTest
    public static void shouldNotCreateWishAffiliation_WhenTypeIsWishChildAndHideFromRestrictedUsersIsTrue() {
        // ARRANGE
        Contact wishChild = [
                SELECT Id
                FROM Contact
                WHERE Name = 'Will Smith'
        ];
        Case wishCase = [
                SELECT Id
                FROM Case
                WHERE Wish_Type__c = 'Disney World'
        ];
        Wish_Affiliation__c childWishAffiliation = new Wish_Affiliation__c();
        childWishAffiliation.Wish__c = wishCase.Id;
        childWishAffiliation.Non_Comped__c = false;
        childWishAffiliation.Survey_Recipient__c = false;
        childWishAffiliation.Medical_Needs__c = false;
        childWishAffiliation.Contact__c = wishChild.Id;
        childWishAffiliation.Wish_Affiliation_Type__c = 'Wish Child';
        childWishAffiliation.Hide_from_Restricted_Users__c = true;

        // ACT
        String validationError;
        Test.startTest();
        try {
            insert childWishAffiliation;
        } catch (DmlException e) {
            validationError = e.getMessage();
        }
        Test.stopTest();

        // ASSERT
        System.assert(validationError.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    }

    @IsTest
    public static void shouldCreateWishAffiliations_WhenNotWishChildOrMedical() {
        // ARRANGE
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        Map<Id, Case> caseMapByLeadId = new Map<Id, Case>();
        Lead lead = [
                SELECT Id, ConvertedContactId
                FROM Lead
                WHERE Name = 'Will Smith'
        ];
        Case wishCase = [
                SELECT Id
                FROM Case
                WHERE Wish_Type__c = 'Hawaii'
        ];
        List<npe4__Relationship__c> relationships = [
                SELECT Id, npe4__Contact__c, npe4__RelatedContact__c, npe4__Type__c, Referring_Medical_Professional__c
                FROM npe4__Relationship__c
        ];
        leadMap.put(lead.Id, lead);
        caseMapByLeadId.put(lead.Id, wishCase);

        List<Contact> contacts = [
                SELECT Id, Hidden_Hospital_Account__c
                FROM Contact
        ];
        // ACT
        Test.startTest();
        List<Wish_Affiliation__c> wishAffiliations = WishAffiliationService.createWishAffiliations(caseMapByLeadId, leadMap, contacts, relationships, null);
        Test.stopTest();

        // ASSERT
        Wish_Affiliation__c wishAffiliation = wishAffiliations.get(0);
        System.assertEquals(1, wishAffiliations.size());
        System.assertEquals('Other', wishAffiliation.Wish_Affiliation_Type__c);
    }

    @IsTest
    public static void shouldUpdateWishAffiliationOfApprovedWishChangeRequests() {
        // ARRANGE
        Wish_Affiliation__c wishAffiliation = [
                SELECT Id
                FROM Wish_Affiliation__c
                WHERE Contact__r.Name = 'Jack Smith'
        ];
        List<Wish_Change_Request__c> wishChangeRequests = [
                SELECT Id, Wish_Case_Id__c,Wish_Affiliation__c,Object_API_Name_for_Proposed_Change__c,Record_Name__c,
                        Record_Id__c,Field_Previous_Value__c,Field_New_Value__c,Field_API_Name_for_Proposed_Change__c,
                        Field_Label_for_Proposed_Change__c, Status__c
                FROM Wish_Change_Request__c
                WHERE Wish_Affiliation__c = :wishAffiliation.Id
        ];
        Map<Id, List<Wish_Change_Request__c>> wishChangeRequestsMapByWishAffiliationId
                = new Map<Id, List<Wish_Change_Request__c>>();
        wishChangeRequestsMapByWishAffiliationId.put(wishAffiliation.Id, wishChangeRequests);

        // ACT
        Test.startTest();
        Map<String, List<SObject>> updatedWishAffiliations = WishAffiliationService.updateWishAffiliationOfApprovedWishChangeRequests(wishChangeRequestsMapByWishAffiliationId);
        Test.stopTest();

        // ASSERT
        List<Wish_Affiliation__c> wishAffiliations = updatedWishAffiliations.get(WISH_AFFILIATION_API_NAME);
        Wish_Affiliation__c wishAffiliationUpdated = wishAffiliations.get(0);
        List<Contact> contacts = updatedWishAffiliations.get(CONTACT_API_NAME);
        Contact contactUpdated = contacts.get(0);
        List<npe4__Relationship__c> relationships = updatedWishAffiliations.get(RELATIONSHIP_API_NAME);
        npe4__Relationship__c relationshipUpdated = relationships.get(0);
        Integer year = contactUpdated.Birthdate.year();
        Integer month = contactUpdated.Birthdate.month();
        Integer day = contactUpdated.Birthdate.day();
        System.assertEquals('Yes', wishAffiliationUpdated.Residing_with_Wish_child__c);
        System.assertEquals('Sam', contactUpdated.FirstName);
        System.assertEquals('Johnson', contactUpdated.LastName);
        System.assertEquals(2000, year);
        System.assertEquals(1, month);
        System.assertEquals(30, day);
        System.assertEquals('Sam Street', contactUpdated.MailingStreet);
        System.assertEquals('New York', contactUpdated.MailingCity);
        System.assertEquals('New York', contactUpdated.MailingState);
        System.assertEquals('98765-4321', contactUpdated.MailingPostalCode);
        System.assertEquals('Home', contactUpdated.npe01__PreferredPhone__c);
        System.assertEquals('5551234567', contactUpdated.Phone);
        System.assertEquals('5551234567', contactUpdated.HomePhone);
        System.assertEquals('sj@email.com', contactUpdated.npe01__HomeEmail__c);
        System.assertEquals('Brother', relationshipUpdated.npe4__Type__c);
        System.assertEquals(true, relationshipUpdated.Parent_Legal_Guardian__c);
    }

    @IsTest
    static void coverUpdateSpecificPhoneField() {
        Contact con = [
                SELECT Id, npe01__PreferredPhone__c, npe01__WorkPhone__c,
                        HomePhone, MobilePhone, OtherPhone, Phone
                FROM Contact
                LIMIT 1
        ];
        con.npe01__PreferredPhone__c = Constant_AC.CONTACT_PHONE_HOME;
        WishAffiliationService.updateSpecificPhoneField(con);
        con.npe01__PreferredPhone__c = Constant_AC.CONTACT_PHONE_MOBILE;
        WishAffiliationService.updateSpecificPhoneField(con);
        con.npe01__PreferredPhone__c = Constant_AC.CONTACT_PHONE_WORK;
        WishAffiliationService.updateSpecificPhoneField(con);
        con.npe01__PreferredPhone__c = Constant_AC.CONTACT_PHONE_OTHER;
        WishAffiliationService.updateSpecificPhoneField(con);
    }

    @IsTest
    static void coverIsUserIdOrUserProfileAllowedToUpdateWishAffiliation() {
        Wish_Affiliation_Security_Settings__c security = new Wish_Affiliation_Security_Settings__c(SetupOwnerId = UserInfo.getUserId());
        insert security;
        WishAffiliationService.isUserIdOrUserProfileAllowedToUpdateWishAffiliation();
        WishAffiliationService.isUserIdOrUserProfileAllowedToUpdateWishAffiliation(UserInfo.getUserId(), null);
        security.Restrict_Access__c = true;
        update security;
        WishAffiliationService.isUserIdOrUserProfileAllowedToUpdateWishAffiliation();
        WishAffiliationService.isUserIdOrUserProfileAllowedToUpdateWishAffiliation(UserInfo.getUserId(), null);
    }

    @IsTest
    static void coverFindHouseholdAddressByContactId() {
        Contact con = [
                SELECT Id
                FROM Contact
                LIMIT 1
        ];
        con.AccountId = null;
        update con;
        WishAffiliationService.findHouseholdAddressByContactId(con.Id);

        Account acc = [
                SELECT Id, BillingStreet, BillingPostalCode, BillingCity, BillingState, BillingCountry
                FROM Account
                LIMIT 1
        ];
        con.AccountId = acc.Id;
        update con;
        acc.BillingStreet = acc.BillingPostalCode = acc.BillingCity
                = acc.BillingState = acc.BillingCountry
                        = null;
        update acc;
        WishAffiliationService.findHouseholdAddressByContactId(con.Id);

        acc.BillingStreet = acc.BillingPostalCode = acc.BillingCity = 'Test';
        acc.BillingState = 'Arizona';
        acc.BillingCountry = 'United States';
        update acc;
        WishAffiliationService.findHouseholdAddressByContactId(con.Id);
    }

    @IsTest
    static void coverBuildWishChangeRequests() {
        Wish_Affiliation__c wishAffiliation = [
                SELECT Id, Wish__c, Residing_with_Wish_child__c, Wish_Affiliation_Type__c, Parent_Legal_Guardian__c,
                        Contact__r.MailingStreet, Contact__r.MailingPostalCode, Contact__r.MailingCity,
                        Contact__r.MailingState, Contact__r.MailingCountry,
                        Contact__r.Id, Contact__r.FirstName, Contact__r.LastName,
                        Contact__r.Birthdate, Contact__r.Phone,
                        Contact__r.npe01__PreferredPhone__c, Contact__r.npe01__HomeEmail__c
                FROM Wish_Affiliation__c
                LIMIT 1
        ];
        npe4__Relationship__c rel = [
                SELECT Id, npe4__Type__c, Parent_Legal_Guardian__c
                FROM npe4__Relationship__c
                LIMIT 1
        ];
        WishAffiliationService.buildWishChangeRequests(wishAffiliation, rel, true, false);
        WishAffiliationService.buildWishChangeRequests(wishAffiliation, rel, false, true);
    }

    @IsTest
    static void shouldFindRelationshipByRelatedContactAndContact() {
        // ARRANGE
        Contact relatedContact = [
                SELECT Id
                FROM Contact
                WHERE Name = 'Will Smith'
        ];
        Contact contact = [
                SELECT Id
                FROM Contact
                WHERE Name = 'Jack Smith'
        ];

        // ACT
        Test.startTest();
        npe4__Relationship__c relationship = WishAffiliationService.findRelationshipByRelatedContactAndContact(relatedContact.Id, contact.Id);
        Test.stopTest();

        // ASSERT
        System.assert(relationship != null);
    }

    @IsTest
    static void shouldFindWishChangeRequests() {
        // ARRANGE
        Case wishCase = [
                SELECT Id
                FROM Case
                WHERE Wish_Type__c = 'Disney World'
        ];
        List<Wish_Affiliation__c> wishAffiliations = [
                SELECT Id
                FROM Wish_Affiliation__c
                WHERE Contact__r.Name = 'Jack Smith'
        ];

        // ACT
        Test.startTest();
        Map<Id, List<SObject>> changeRequests = WishAffiliationService.findChangeRequests(wishCase.Id, wishAffiliations);
        Test.stopTest();

        // ASSERT
        System.assertEquals(1, changeRequests.keySet().size());
    }

    @IsTest
    static void shouldBuildChangeRequests() {
        // ARRANGE
        Wish_Affiliation__c modifiedWishAffiliation = [
                SELECT Id, Name, Wish_Affiliation_Type__c, Wish__c, Residing_with_Wish_child__c, Medical_Needs__c,
                        Survey_Recipient__c, Non_Comped__c, Details__c, Send_Clearance_Forms_To__c, Medical_Professional_Status__c,
                        Contact__r.Name, Contact__r.FirstName, Contact__r.LastName, Contact__r.Birthdate, Contact__r.Current_Age__c,
                        Contact__r.MailingStreet, Contact__r.MailingCity, Contact__r.MailingState, Contact__r.MailingPostalCode,
                        Contact__r.MailingCountry, Contact__r.npe01__PreferredPhone__c, Contact__r.Phone, Contact__r.HomePhone,
                        Contact__r.MobilePhone, Contact__r.OtherPhone, Contact__r.npe01__WorkPhone__c, Contact__r.npe01__HomeEmail__c,
                        Contact__r.npe01__WorkEmail__c, Contact__r.npsp__Do_Not_Contact__c, Contact__r.Do_Not_Contact_Notes__c,
                        Contact__r.npsp__Deceased__c, Contact__r.Provider_Type__c, Contact__r.Fax, Contact__r.npsp__is_Address_Override__c,
                        Relationship__r.npe4__Type__c, Relationship__r.Parent_Legal_Guardian__c,
                        Relationship__r.npe4__Contact__c, Relationship__r.npe4__Contact__r.Name,
                        Relationship__r.Qualifying_Medical_Professional__c, Relationship__r.Treating_HCP__c,
                        Relationship__r.Best_Contact__c, Health_Treatment_Facility__c, Health_Treatment_Facility__r.Name, Relationship__r.Referring_Medical_Professional__c
                FROM Wish_Affiliation__c
                WHERE Contact__r.Name = 'Jack Smith'
        ];
        modifiedWishAffiliation.Wish_Affiliation_Type__c = '';
        modifiedWishAffiliation.Residing_with_Wish_child__c = '';
        modifiedWishAffiliation.Medical_Needs__c = false;
        modifiedWishAffiliation.Survey_Recipient__c = false;
        modifiedWishAffiliation.Non_Comped__c = false;
        modifiedWishAffiliation.Details__c = '';
        modifiedWishAffiliation.Send_Clearance_Forms_To__c = false;
        modifiedWishAffiliation.Contact__r.FirstName = '';
        modifiedWishAffiliation.Contact__r.LastName = '';
        modifiedWishAffiliation.Contact__r.Birthdate = Date.parse('4/4/2000');
        modifiedWishAffiliation.Contact__r.MailingStreet = 'Abc St';
        modifiedWishAffiliation.Contact__r.MailingCity = 'New York';
        modifiedWishAffiliation.Contact__r.MailingState = 'New York';
        modifiedWishAffiliation.Contact__r.MailingPostalCode = '123456';
        modifiedWishAffiliation.Contact__r.npe01__PreferredPhone__c = 'Work';
        modifiedWishAffiliation.Contact__r.Phone = '1234569876';
        modifiedWishAffiliation.Contact__r.HomePhone = '';
        modifiedWishAffiliation.Contact__r.MobilePhone = '';
        modifiedWishAffiliation.Contact__r.OtherPhone = '';
        modifiedWishAffiliation.Contact__r.npe01__WorkPhone__c = '';
        modifiedWishAffiliation.Contact__r.npe01__HomeEmail__c = 'a123@test.com';
        modifiedWishAffiliation.Contact__r.npe01__WorkEmail__c = '';
        modifiedWishAffiliation.Contact__r.npsp__Do_Not_Contact__c = false;
        modifiedWishAffiliation.Contact__r.Do_Not_Contact_Notes__c = '';
        modifiedWishAffiliation.Contact__r.npsp__Deceased__c = false;
        modifiedWishAffiliation.Contact__r.Provider_Type__c = '';
        modifiedWishAffiliation.Contact__r.Fax = '';
        npe4__Relationship__c modifiedRelationship = [
                SELECT Id, Name, npe4__Type__c, Parent_Legal_Guardian__c
                FROM npe4__Relationship__c
                WHERE Id = :modifiedWishAffiliation.Relationship__c
        ];
        modifiedRelationship.npe4__Type__c = 'Sibling';
        modifiedRelationship.Parent_Legal_Guardian__c = true;

        // ACT
        Test.startTest();
        List<Wish_Change_Request__c> changeRequests = WishAffiliationService.buildWishChangeRequests(modifiedWishAffiliation,
                modifiedRelationship, false, false);
        Test.stopTest();

        // ASSERT
        System.assertEquals(13, changeRequests.size());
    }

    @IsTest
    static void shouldBuildVolunteerChangeRequests() {
        // ARRANGE
        Wish_Affiliation__c oldWishAffiliation = [
                SELECT Id, Name, Residing_with_Wish_child__c, Wish__c, Relationship__c, Relationship__r.npe4__Type__c,
                        Contact__c, Contact__r.Name, Contact__r.FirstName, Contact__r.Middle_Name__c, Contact__r.LastName,
                        Contact__r.Birthdate, Contact__r.npe01__HomeEmail__c, Contact__r.T_Shirt_Size__c
                FROM Wish_Affiliation__c
                WHERE Contact__r.Name = 'Jack Smith'
        ];
        Wish_Affiliation__c modifiedWishAffiliation = [
                SELECT Id, Name, Residing_with_Wish_child__c, Wish__c, Relationship__c, Relationship__r.Name, Relationship__r.npe4__Type__c,
                        Contact__c, Contact__r.Name, Contact__r.FirstName, Contact__r.Middle_Name__c, Contact__r.LastName,
                        Contact__r.Birthdate, Contact__r.npe01__HomeEmail__c, Contact__r.T_Shirt_Size__c
                FROM Wish_Affiliation__c
                WHERE Contact__r.Name = 'Jack Smith'
        ];
        modifiedWishAffiliation.Residing_with_Wish_child__c = 'No';
        modifiedWishAffiliation.Relationship__r.npe4__Type__c = 'Sibling';
        modifiedWishAffiliation.Contact__r.FirstName = 'JJ';
        modifiedWishAffiliation.Contact__r.Middle_Name__c = 'M';
        modifiedWishAffiliation.Contact__r.LastName = 'Johnson';
        modifiedWishAffiliation.Contact__r.Birthdate = Date.today();
        modifiedWishAffiliation.Contact__r.npe01__HomeEmail__c = 'bobj@testemail.com';
        modifiedWishAffiliation.Contact__r.T_Shirt_Size__c = 'XL';

        // ACT
        Test.startTest();
        List<Wish_Change_Request__c> changeRequests = WishAffiliationService.buildVolunteerChangeRequests(modifiedWishAffiliation, oldWishAffiliation);
        Test.stopTest();

        // ASSERT
        System.assertEquals(8, changeRequests.size());
    }

    @IsTest
    static void shouldFindWishAffiliations_WhenContactAlreadyWishAffiliation() {
        // ARRANGE
        Case wishCase = [
                SELECT Id
                FROM Case
                WHERE Wish_Type__c = 'Disney World'
        ];
        Contact contact = [
                SELECT Id
                FROM Contact
                WHERE Name = 'Jack Smith'
        ];

        // ACT
        Test.startTest();
        String wishAffiliations = WishAffiliationService.isContactAlreadyWishAffiliation(contact, wishCase.Id);
        Test.stopTest();

        // ASSERT
        System.assert(String.isNotEmpty(wishAffiliations));
    }
}