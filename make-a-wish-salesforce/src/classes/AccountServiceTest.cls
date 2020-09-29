/**
 * @description Account Service Test
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 2/27/2020
 */
@IsTest
public class AccountServiceTest {
    
    private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;
    private final static Id IN_KIND_DONORS_RECORD_TYPE_ID = Constant_AC.IN_KIND_ACCOUNT_ID;
    private final static Id HOUSEHOLD_RECORD_TYPE_ID = Constant_AC.HOUSEHOLD_RT_ID;
    private final static Id CONTACT_WISH_CHILD = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
    private final static Id CONTACT_WISH_FAMILY = Constant_AC.WISH_FAMILY_RT_ID;

    @TestSetup
    public static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;
        User user1 = [SELECT Id FROM User WHERE IsActive = TRUE AND UserRole.Name = 'Central & Northern Florida - Chapter' LIMIT 1];
        
        List<Account> accounts = TestDataFactory.createAccount(3);
        Account account1 = accounts.get(0);
        account1.Name = 'Make-A-Wish Arizona';
        account1.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
        Account account2 = accounts.get(1);
        account2.Name = 'Jack Smith & Family Account';
        account2.RecordTypeId = HOUSEHOLD_RECORD_TYPE_ID;
        account2.Emergency_Contact_Phone__c = '5208205555';
        account2.Relationship_type__c = 'Mother';
        account2.BillingCity = 'Phoenix';
        account2.BillingState = 'Arizona';
        account2.BillingPostalCode = '85016';
        Account account3 = accounts.get(2);
        account3.Name = 'Make-A-Wish Central & Northern Florida';
        account3.Wish_Co_ordinator__c = user1.Id;
        account3.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
        account3.OwnerId = user1.Id;
        insert accounts;
        List<Account> inKindAccounts = TestDataFactory.createAccount(1);
        Account account4 = inKindAccounts.get(0);
        account4.Name = 'In Kind Donors Central & Northern Florida';
        account4.RecordTypeId = IN_KIND_DONORS_RECORD_TYPE_ID;
        account4.Chapter_Name__c = accounts[2].Id;
        account4.OwnerId = user1.Id;
        insert inKindAccounts;
        
        List<Group> groups = TestDataFactory.createGroup(1);
        Group group1 = groups.get(0);
        group1.Name = 'Central & Northern Florida';
        group1.Type = 'Regular';
        insert groups;
        
        List<ICD_Codes__c> icdCodesDataFactory = TestDataFactory.createIcdCode(1);
        ICD_Codes__c icdCode = icdCodesDataFactory.get(0);
        insert icdCode;
        
        List<Lead> leads = TestDataFactory.createLead(2);
        Lead lead = leads.get(0);
        lead.ChapterName__c = account1.Id;
        lead.FirstName = 'Jack';
        lead.LastName = 'Smith';
        lead.Hidden_Chapter_Change_Confirmation__c = account1.Id;
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
        lead.What_is_the_family_s_primary_spoken_lang__c = 'English';
        Lead lead2 = leads.get(1);
        lead2.ChapterName__c = accounts[0].Id;
        lead2.FirstName = 'Gary';
        lead2.LastName = 'Johnson';
        lead2.is_Family_Aware_of_Referral__c = 'Yes';
        lead2.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
        lead2.PD_ICD_Code__c = icdCode.Id;
        lead2.Company = 'MAW';
        lead2.Alternate1HospitalTreatmentFacility__c = 'Phoenix Medical Center';
        lead2.Alternate2HospitalTreatmentFacility__c = 'Scottsdale Medical Center';
        lead2.Hospital_Treatment_Facility_Treating__c = 'Arizona State Hospital';
        insert leads;
        
        List<Office__c> officeList = TestDataFactory.createOffice(2);
        Office__c azOffice = officeList.get(0);
        azOffice.Name = 'Make-A-Wish-Arizona';
        azOffice.Chapter__c = account1.Id;
        Office__c flOffice = officeList.get(1);
        flOffice.Name = 'Make-A-Wish-Central & Northern Florida';
        flOffice.Chapter__c = account3.Id;
        insert officeList;
        
        List<Zip_Code__c> zipList = TestDataFactory.createZipCode(2);
        Zip_Code__c arizonaZip = zipList.get(0);
        arizonaZip.Name = '85001';
        arizonaZip.Office__c = azOffice.Id;
        arizonaZip.External_Id__c = '85001';
        Zip_Code__c floridaZip = zipList.get(1);
        floridaZip.Name = '33601';
        floridaZip.Office__c = flOffice.Id;
        floridaZip.External_Id__c = '33601';
        insert zipList;
        
        Account htfAccount = TestDataFactory.createAccount(1)[0];
        htfAccount.RecordTypeId = Constant_AC.HOSPITAL_TREATMENT_ID;
        htfAccount.Name = 'Sun Valley General Hospital';
        htfAccount.BillingPostalCode = '85001';
        insert htfAccount;
        
        trac_TriggerHandlerBase.blockTrigger = false;
    }
    
    @IsTest
    public static void shouldSetHouseholdFields() {
        Account account = [
            SELECT Id
            FROM Account
            WHERE Name IN ('Make-A-Wish Arizona')
        ];
        Lead lead = [
            SELECT Id, FirstName, LastName, ChapterName__c, What_is_the_family_s_primary_spoken_lang__c, ConvertedAccountId
            FROM Lead
            WHERE Name = 'Jack Smith'
        ];

        Test.startTest();
        Account result = AccountService.setHouseholdFields(lead);
        Test.stopTest();

        String expectedName =
            lead.FirstName
            + ' '
            + lead.LastName
            + Constant_AC.FAMILY_HOUSEHOLD_NAME_APPEND;
        System.assertNotEquals(null, account.Id);
        System.assertEquals(expectedName, result.Name);
    }
    
    @isTest 
    private static void validateMatchChapterForAccount() {
        List<Account> accountsInKindDonors = new List<Account>([SELECT Id, Name, OwnerId, Chapter_Name__c, Wish_Co_ordinator_Hidden_Email__c
                                                                FROM Account 
                                                                WHERE RecordTypeId = :IN_KIND_DONORS_RECORD_TYPE_ID]);
        Set<Id> accountOwnerIdSet = new Set<Id>();
        for(Account acc : accountsInKindDonors) {
            accountOwnerIdSet.add(acc.OwnerId);
        }
        Account accountNoChapter = new Account(Name = 'In Kind Donors - No Chapter', RecordTypeId = IN_KIND_DONORS_RECORD_TYPE_ID);
        accountsInKindDonors.add(accountNoChapter);
        System.assert(accountsInKindDonors[0].Wish_Co_ordinator_Hidden_Email__c == null);
        Test.startTest();
        List<Account> accountsUpdatedList = AccountService.matchChapterForAccount(accountOwnerIdSet, accountsInKindDonors);
        Test.stopTest();
        System.assert(accountsUpdatedList[0].Wish_Co_ordinator_Hidden_Email__c != null);
    }
    
    @isTest 
    private static void validatePrimaryContactForAccount() {
        List<Account> accountList = new List<Account>([SELECT Id, npe01__One2OneContact__c 
                                                       FROM Account
                                                       WHERE Name = 'Jack Smith & Family Account'
                                                       AND RecordTypeId = :HOUSEHOLD_RECORD_TYPE_ID]);
        Map<Id, Account> accountMap = new Map<Id, Account>();
        accountMap.putAll(accountList);
        Contact contact = new Contact(FirstName = 'Jack', LastName = 'Smith', AccountId = accountList[0].Id, RecordTypeId = CONTACT_WISH_CHILD);
        insert contact;
        System.assert(accountList[0].npe01__One2OneContact__c == null);
        Test.startTest();
        accountList = AccountService.setPrimaryContactForAccount(accountMap);
        Test.stopTest();
        System.assert(accountList[0].npe01__One2OneContact__c == contact.Id);
    }    
    
    @isTest
    private static void validateSubmitAccountApprovalProcess() {
        List<Account> accountsInKindList = new List<Account>();
        Map<Id, Id> wishCoordinatorMap = new Map<Id, Id>();
        List<Account> accountsChapterList = new List<Account>();
        List<Account> accountsList = new List<Account>([SELECT Id, Name, Wish_Co_ordinator__c, OwnerId, Owner.UserRole.Name, Owner.ContactId, 
                                                        Volunteer_Manager__c, RecordTypeId, Chapter_Name__c, Chapter_Name__r.Name 
                                                        FROM Account]);
        for(Account account : accountsList) {
            if(account.RecordTypeId == CHAPTER_RECORD_TYPE_ID && account.Wish_Co_ordinator__c != null) {
                accountsChapterList.add(account);
                wishCoordinatorMap.put(account.Id, account.Wish_Co_ordinator__c);
            } else if(account.RecordTypeId == IN_KIND_DONORS_RECORD_TYPE_ID) {
                accountsInKindList.add(account);
            }
        }
        List<ProcessInstanceWorkitem> processItem = [SELECT Id FROM ProcessInstanceWorkitem 
                                                     WHERE ProcessInstance.TargetObjectId IN :accountsInKindList];
        system.assert(processItem.size() == 0);
        Test.startTest();
        AccountService.submitAccountApprovalProcess(accountsInKindList, wishCoordinatorMap);
        Test.stopTest();
        processItem = [SELECT Id FROM ProcessInstanceWorkitem
                       WHERE ProcessInstance.TargetObjectId IN :accountsInKindList];
        system.assert(processItem.size() > 0);
    }
    
    @isTest
    private static void validateCreateAccountShareReadAccess() {
        List<Account> accountsInKindList = new List<Account>();
        Set<Id> chapterIdSet = new Set<Id>();
        List<Account> accountList = new List<Account>([SELECT Id, Name, Wish_Co_ordinator__c, OwnerId, Owner.UserRole.Name, Owner.ContactId, 
                                                       Volunteer_Manager__c, RecordTypeId, Chapter_Name__c, Chapter_Name__r.Name 
                                                       FROM Account]);
        
        for(Account account : accountList) {
            if(account.RecordTypeId == IN_KIND_DONORS_RECORD_TYPE_ID) {
                accountsInKindList.add(account);
            } else if(account.RecordTypeId == CHAPTER_RECORD_TYPE_ID) {
                chapterIdSet.add(account.Id);
            }
        }
        List<AccountShare> accountShareList = [SELECT Id 
                                               FROM AccountShare 
                                               WHERE Accountaccesslevel = 'Read' 
                                               AND AccountId IN :accountList];
        system.assert(accountShareList.size() == 0);
        Test.startTest();
        AccountService.shareChapterAccountsToGroups(chapterIdSet, accountsInKindList);
        Test.stopTest();
        accountShareList = [SELECT Id 
                            FROM AccountShare 
                            WHERE Accountaccesslevel = 'Read' 
                            AND AccountId IN :accountList];
        system.assert(accountShareList.size() > 0);
    }
    
    @isTest
    private static void validateCreateAccountShareEditAccess() {
        Chapter_Vs_Role__c chapterRole = new Chapter_Vs_Role__c(Name = 'Central & Northern Florida', 
                                                                Chapter_Name__c = 'Make-A-Wish Central & Northern Florida', 
                                                                Role_Name__c = 'Central & Northern Florida - Chapter');
        insert chapterRole;
        List<String> chapterNamesList = new List<String>();
        List<Account> accountsList = new List<Account>([SELECT Id, Name, Wish_Co_ordinator__c, OwnerId, Owner.UserRole.Name, Owner.ContactId, 
                                                        Volunteer_Manager__c, RecordTypeId, Chapter_Name__c, Chapter_Name__r.Name 
                                                        FROM Account]);
        for(Account account : accountsList) {
            if(account.Chapter_Name__r.Name != null) {
                chapterNamesList.add(account.Chapter_Name__r.Name);
            }
        }
        Test.startTest();
        AccountService.createAccountShareEditAccess(accountsList, chapterNamesList);
        Test.stopTest();
    }
    
    @isTest
    private static void validateUpdateRelatedContactAddressWithHousehold() {
        Set<Id> accountIdSet = new Set<Id>();
        List<Account> accountList  = new List<Account>([SELECT Id, BillingCity, BillingState, BillingPostalCode
                                                        FROM Account 
                                                        WHERE Name = 'Jack Smith & Family Account'
                                                        AND RecordTypeId = :HOUSEHOLD_RECORD_TYPE_ID]);
        Contact contact = new Contact(FirstName = 'Jack', LastName = 'Smith', AccountId = accountList[0].Id, 
                                      RecordTypeId = CONTACT_WISH_FAMILY, Same_as_Household_Address__c = true);
        System.assert(accountList[0].BillingCity == 'Phoenix');
        for(Account account : accountList) {
            accountIdSet.add(account.Id);
            account.BillingCity = 'Scottsdale';
            account.BillingPostalCode = '85260';
        }
        update accountList;
        Test.startTest();
        AccountService.updateRelatedContactAddressWithHousehold(accountIdSet);
        Test.stopTest();
        System.assert(accountList[0].BillingCity == 'Scottsdale');
    }
    
    @isTest
    private static void validateCreateHospitalTreatmentFacilities() {
        Lead lead = [
            SELECT Id, Alternate1HospitalTreatmentFacility__c, Alternate2HospitalTreatmentFacility__c, 
            Hospital_Treatment_Facility_Treating__c 
            FROM Lead 
            WHERE Name = 'Gary Johnson'
        ];
        Map<String, Account> accountMap = new Map<String, Account>([
            SELECT Id, Name 
            FROM Account 
        ]);
        Map<String, Account> hospitalAccountMap = new Map<String, Account>();
        Test.startTest();
        hospitalAccountMap = AccountService.createHospitalTreatmentFacilities(new Set<Id>{lead.Id}, accountMap);
        Test.stopTest();
        System.assert(hospitalAccountMap.containsKey(lead.Alternate1HospitalTreatmentFacility__c));
    }
    
    @isTest
    private static void validatePopulateChapterOnHospitalAccount() {
        Account htfAccount = [
            SELECT Id, Chapter_Name__c, BillingPostalCode 
            FROM Account 
            WHERE Name = 'Sun Valley General Hospital'
        ];
        System.assert(htfAccount.Chapter_Name__c == null);
        htfAccount.BillingPostalCode = '33601';
        Test.startTest();
        update htfAccount;
        Test.stopTest();
        Account htfUpdated = [
            SELECT Id, Chapter_Name__c 
            FROM Account 
            WHERE Name = 'Sun Valley General Hospital'
        ];
        System.assert(htfUpdated.Chapter_Name__c != null);
    }
}