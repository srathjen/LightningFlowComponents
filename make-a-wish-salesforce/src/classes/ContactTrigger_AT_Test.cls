@IsTest
public class ContactTrigger_AT_Test {
    
    @TestSetup
    static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;
        
        User testUser = TestDataFactory.createIntegrationUser(1, 'Intake Manager', null)[0];
        insert testUser;
        
        List<Account> accounts = TestDataFactory.createAccount(3);
        Account account = accounts.get(0);
        account.Name = 'Make-A-Wish Arizona';
        account.Intake_Manager__c = testUser.Id;
        account.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
        account.Alert_for_Unassigned_Wishes__c = 1;
        Account knowlesFamily = accounts.get(1);
        knowlesFamily.Name = 'Jenna Knowles & Family Household';
        knowlesFamily.RecordTypeId = Constant_AC.HOUSEHOLD_RT_ID;
        Account chapterIllinois = accounts.get(2);
        chapterIllinois.Name = 'Make-A-Wish Illinois';
        chapterIllinois.RecordTypeId = Constant_AC.CHAPTER_RT_ID;
        insert accounts;
        Account htfIllinois = TestDataFactory.createAccount(1)[0];
        htfIllinois.RecordTypeId = Constant_AC.HOSPITAL_TREATMENT_ID;
        htfIllinois.Name = 'Chicago General Hospital';
        htfIllinois.Chapter_Name__c = chapterIllinois.Id;
        insert htfIllinois;
        
        List<Contact> contacts = TestDataFactory.createContact(2);
        Contact contactKnowles = contacts.get(0);
        contactKnowles.RecordTypeId = Constant_AC.WISH_FAMILY_RT_ID;
        contactKnowles.Region_Chapter__c = account.Id;
        contactKnowles.AccountId = knowlesFamily.Id;
        contactKnowles.FirstName = 'Allison';
        contactKnowles.LastName = 'Knowles';
        Contact mpContact = contacts.get(1);
        mpContact.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        mpContact.FirstName = 'Willow';
        mpContact.LastName = 'Summers';
        mpContact.Region_Chapter__c = chapterIllinois.Id;
        insert contacts;
        
        List<Chapter_Vs_Role__c> chapterVsRoleList = TestDataFactory.createChapterVsRole(1, 'Arizona');
        insert chapterVsRoleList;
        
        Office__c mawAzOffice = TestDataFactory.createOffice(1)[0];
        mawAzOffice.Name = 'Make-A-Wish-Arizona';
        mawAzOffice.Chapter__c = account.Id;
        insert mawAzOffice;
        
        Zip_Code__c zipAz = TestDataFactory.createZipCode(1)[0];
        zipAz.Name = '85069';
        zipAz.Office__c = mawAzOffice.Id;
        zipAz.External_Id__c = '85069';
        insert zipAz;
        
        trac_TriggerHandlerBase.blockTrigger = false;
    }
    
    @IsTest
    public static void createVolunteerContact() {
        Account account = [
            SELECT Id
            FROM Account
            LIMIT 1
        ];
        
        List<Contact> contacts = TestDataFactory.createContact(1);
        Contact contact = contacts.get(0);
        contact.FirstName = 'Jack';
        contact.Middle_Name__c = 'Jacksons';
        contact.LastName = 'Smithsons';
        contact.Birthdate = System.today() - 1;
        contact.Parent_Guardian_Name__c = 'Bob Smith';
        contact.RecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
        contact.Title = 'Mr';
        contact.Birth_Month__c = 'January';
        contact.Birth_Day__c = '12';
        contact.Birth_Year__c = '1985';
        contact.Alternate_Phone_Type__c = 'Home';
        contact.npe01__PreferredPhone__c = 'Mobile';
        contact.OtherPhone = '3332211144';
        contact.HomePhone = '9003910426';
        contact.MobilePhone = '9003910426';
        contact.I_m_on_LinkedIn__c = 'Yes';
        contact.How_did_you_hear_about_Make_A_Wish__c = 'Family';
        contact.MailingPostalCode = '94105-5188';
        contact.MailingStreet = 'One Market Street';
        contact.MailingCountry = 'United States';
        contact.MailingState = 'Texas';
        contact.MailingCity = 'San Francisco';
        contact.MailingLatitude = -24.355798;
        contact.MailingLongitude = 69.830469;
        contact.Emergency_Contact__c = 'Test';
        contact.Emergency_Contact_Relationship__c = 'Father';
        contact.Emergency_Contact_Phone__c = '9003910426';
        contact.Read__c = 'English';
        contact.Language__c = 'English';
        contact.Speak__c = 'English';
        contact.Understand__c = 'English';
        contact.Professional_Skills__c = 'Photography';
        contact.Language_Notes__c = 'Test';
        contact.is_Application__c = 'Partial Submit';
        contact.AccountId = account.Id;
        contact.Volunteer_Role__c = 'Water Handler';
        contact.npe01__Preferred_Email__c = 'test@gmail.com';
        contact.Email = 'test@gmail.com';
        contact.Do_Not_Create_User__c = false;
        contact.Migrated_Record__c = true;
        insert contact;
        
        contact.MailingPostalCode = '12345-5188';
        contact.OtherPostalCode = '85005';
        Date birthdate = Date.today().addYears(-15);
        contact.Birth_Year__c = String.valueOf(birthdate.year());
        contact.Birth_Month__c = 'May';
        contact.Birth_Day__c = String.valueOf(birthdate.day());
        update contact;
        
        delete contact;
    }
    
    @IsTest
    public static void createWishChildContact() {
        Account account = [
            SELECT Id
            FROM Account
            LIMIT 1
        ];
        
        List<Contact> contacts = TestDataFactory.createContact(1);
        Contact contact = contacts.get(0);
        contact.Region_Chapter__c = account.Id;
        contact.FirstName = 'Jack';
        contact.LastName = 'Smith';
        contact.Email = 'jacksmith@email.com';
        contact.Phone = '1233213333';
        contact.MailingStreet = '123 Street';
        contact.MailingCity = 'Phoenix';
        contact.MailingState = 'Arizona';
        contact.MailingStateCode = 'AZ';
        contact.MailingPostalCode = '85001';
        contact.MailingCountryCode = 'US';
        contact.RecordTypeId = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
        contact.Primary_Diagnosis_Condition_Description__c = 'Test';
        contact.Diagnosis__c = 'test';
        insert contacts;
    }
    
    @IsTest
    public static void updateContactSpanishValues() {
        Contact contactToUpdate = [
            SELECT Id, Relationship__c, npe01__PreferredPhone__c
            FROM Contact 
            WHERE Name = 'Allison Knowles'
        ];
        contactToUpdate.Relationship__c = 'Madre';
        contactToUpdate.npe01__PreferredPhone__c = 'Móvil';
        
        Test.startTest();
        update contactToUpdate;
        Test.stopTest();
        
        Contact updatedContact = [
            SELECT Id, Relationship__c, npe01__PreferredPhone__c 
            FROM Contact 
            WHERE Id = :contactToUpdate.Id
        ];
        System.assert(updatedContact.Relationship__c == 'Mother');
        System.assert(updatedContact.npe01__PreferredPhone__c == 'Mobile');
    }
    
    @isTest
    public static void updateContactOwner() {
        Account azAccount = [
            SELECT Id, Intake_Manager__c  
            FROM Account WHERE Name = 'Make-A-Wish Arizona'
        ];
        Contact mpContact = TestDataFactory.createContact(1)[0];
        mpContact.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        mpContact.FirstName = 'Samantha';
        mpContact.LastName = 'Jackson';
        mpContact.Region_Chapter__c = azAccount.Id;
        Test.startTest();
        insert mpContact;
        Test.stopTest();
        
        Contact mpContactUpdated = [
            SELECT Id, OwnerId 
            FROM Contact 
            WHERE Name = 'Samantha Jackson'
        ];
        System.assert(mpContactUpdated.OwnerId == azAccount.Intake_Manager__c);
    }
    
    @isTest
    public static void populateRegionChapterOnMedicalProfessional() {
        Account htfAccount = [
            SELECT Id, Chapter_Name__c
            FROM Account 
            WHERE Name = 'Chicago General Hospital'
        ];
        Contact mpContact = [
            SELECT Id, npsp__Primary_Affiliation__c, Region_Chapter__c 
            FROM Contact 
            WHERE Name = 'Willow Summers'
        ];
        Test.startTest();
        mpContact.Region_Chapter__c = null;
        mpContact.npsp__Primary_Affiliation__c = htfAccount.Id;
        update mpContact;
        Test.stopTest();
        Contact mpContactUpdated = [
            SELECT Id, npsp__Primary_Affiliation__c, Region_Chapter__c 
            FROM Contact 
            WHERE Name = 'Willow Summers'
        ];
        System.assert(mpContactUpdated.npsp__Primary_Affiliation__c == htfAccount.Id);
        System.assert(mpContactUpdated.Region_Chapter__c == htfAccount.Chapter_Name__c);
    }
    
    @isTest
    public static void populateRegionChapterOnMedicalProfessionalByZipcode() {
        Account azChapter = [
            SELECT Id 
            FROM Account 
            WHERE Name = 'Make-A-Wish Arizona'
        ];
        Contact mpContact = [
            SELECT Id, npsp__Primary_Affiliation__c, Region_Chapter__c 
            FROM Contact 
            WHERE Name = 'Willow Summers'
        ];
        Test.startTest();
        mpContact.Region_Chapter__c = null;
        mpContact.MailingPostalCode = '85069';
        update mpContact;
        Test.stopTest();
        Contact mpContactUpdated = [
            SELECT Id, Region_Chapter__c 
            FROM Contact 
            WHERE Id = :mpContact.Id
        ];
        System.assert(mpContactUpdated.Region_Chapter__c == azChapter.Id);
    }
}