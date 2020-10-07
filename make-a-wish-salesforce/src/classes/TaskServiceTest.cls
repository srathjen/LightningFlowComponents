/**
 * @description Task Service Test class
 * @author	Gustavo Mayer, Traction on Demand
 * @createdDate	3-04-2020
 */
@IsTest
public class TaskServiceTest {
    
    private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;
    
    @TestSetup
    public static void setup() {
        trac_TriggerHandlerBase.blockTrigger = true;
        List<Account> accounts = TestDataFactory.createAccount(1);
        Account account1 = accounts.get(0);
        account1.Name = 'Make-A-Wish Arizona';
        account1.RecordTypeId = CHAPTER_RECORD_TYPE_ID;
        insert accounts;
        
        List<ICD_Codes__c> icdCodesDataFactory = TestDataFactory.createIcdCode(1);
        ICD_Codes__c icdCode = icdCodesDataFactory.get(0);
        insert icdCode;
        
        List<Lead> leads = TestDataFactory.createLead(1);
        Lead lead = leads.get(0);
        lead.ChapterName__c = account1.Id;
        lead.FirstName = 'Jack';
        lead.LastName = 'Smith';
        lead.DOB__c = System.today().addYears(-5);
        lead.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
        lead.PD_ICD_Code__c = icdCode.Id;
        lead.Phone = '9600467559';
        lead.Email = 'testmawa@gmail.com';
        lead.Street = 'KuttaiKarai Street';
        lead.StateCode = 'AZ';
        lead.City = 'Trichy';
        lead.PostalCode = '6201717';
        lead.is_Family_Aware_of_Referral__c = 'Yes';
        lead.CountryCode = 'US';
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
        insert leads;
        
        List<Task> tasks = TestDataFactory.createTask(1);
        Task task = tasks[0];
        task.WhoId = lead.Id;
        insert tasks;
        
        Contact medHolland = TestDataFactory.createContact(1)[0];
        medHolland.FirstName = 'Francis';
        medHolland.LastName = 'Holland';
        medHolland.RecordTypeId = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        medHolland.AccountId = account1.Id;
        insert medHolland;
        
        trac_TriggerHandlerBase.blockTrigger = false;
    }
    
    @IsTest
    public static void shouldCreateLeadInquiryTask() {
        Lead lead = [
            SELECT Id
            FROM Lead
            WHERE Name = 'Jack Smith'
        ];
        Set<Id> leadIds = new Set<Id>();
        leadIds.add(lead.Id);
        
        Test.startTest();
        List<Database.SaveResult> results = TaskService.createLeadTask(leadIds);
        Test.stopTest();
        
        System.assertEquals(true, results[0].success);
    }
    
    @IsTest
    public static void shouldCreateLeadReferredTask() {
        Lead lead = [
            SELECT Id
            FROM Lead
            WHERE Name = 'Jack Smith'
        ];
        update new Lead(Id=lead.Id, Status='Referred');
        Set<Id> leadIds = new Set<Id>();
        leadIds.add(lead.Id);
        
        Test.startTest();
        List<Database.SaveResult> results = TaskService.createLeadTask(leadIds);
        Test.stopTest();
        
        System.assertEquals(true, results[0].success);
    }
    
    @IsTest
    public static void shouldNotCreateLeadTask() {
        Set<Id> leadIds = new Set<Id>();
        
        Test.startTest();
        List<Database.SaveResult> results = TaskService.createLeadTask(leadIds);
        Test.stopTest();
        
        System.assertEquals(0, results.size());
    }
    
    @IsTest
    public static void createRushTask() {
        List<Lead> leadList = [
            SELECT Id, OwnerId 
            FROM Lead
        ];
        Test.startTest();
        TaskService.createRushTask(leadList);
        Test.stopTest();
        List<Task> rushTask = [
            SELECT Id, Subject 
            FROM Task 
            WHERE WhoId = :leadList[0].Id
            AND Subject = :Constant_AC.TASK_SUBJECT_RUSH_MODIFIED_NO
        ];
        System.assert(!rushTask.isEmpty());
    }
    
    @IsTest
    public static void buildWelcomeLetter() {
        Contact contact = [
            SELECT Id, OwnerId 
            FROM Contact 
            WHERE Name = 'Francis Holland'
        ];
        Test.startTest();
        Task welcomeTask = TaskService.buildSendWelcomeLetter(contact.Id, contact.OwnerId);
        Test.stopTest();
        System.assert(welcomeTask.Subject == Constant_AC.TASK_SUBJECT_SEND_WELCOME_LETTER);
    }
    
    @IsTest
    public static void buildRush() {
        Contact contact = [
            SELECT Id, OwnerId 
            FROM Contact 
            WHERE Name = 'Francis Holland'
        ];
        Test.startTest();
        Task rushTask = TaskService.buildRush(contact.Id);
        Test.stopTest();
        System.assert(rushTask.Subject == Constant_AC.TASK_SUBJECT_RUSH_QUALIFIED);
    }
}