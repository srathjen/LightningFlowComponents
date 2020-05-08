/*********************************************
Description : Test Class create ChapterStaffRecordSharing.
**********************************************/
//This class used to do the unit testing
// createRecords methosd will create chapter role record
@IsTest
public class ChapterStaffRecordSharing_ACTest {
    
    private final static Id CHAPTER_RT_ID = Constant_AC.CHAPTER_RT_ID;
    private final static Id CONTACT_WISH_CHILD_RT_ID = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
    private final static Id HOUSEHOLD_RECORD_TYPE_ID = Constant_AC.HOUSEHOLD_RT_ID;
    private final static Id VOLUNTEER_RT_ID = Constant_AC.VOLUNTEER_RT_ID;
    private final static Id CLASS_OFFERING_RECORD_TYPE_ID = Constant_AC.CLASS_OFFERING_RECORD_TYPE_ID;
    
    @TestSetup
    public static void setUp() {
        trac_TriggerHandlerBase.blockTrigger = true;
        
        List<Account> accountList = TestDataFactory.createAccount(2);
        Account accountAzChapter = accountList.get(0);
        accountAzChapter.Name = 'Make-A-Wish Arizona';
        accountAzChapter.RecordTypeId = CHAPTER_RT_ID;
        Account accountCullenFamily = accountList.get(1);
        accountCullenFamily.Name = 'Mallory Cullen & Family Account';
        accountCullenFamily.RecordTypeId = HOUSEHOLD_RECORD_TYPE_ID;
        accountCullenFamily.Emergency_Contact_Phone__c = '5208205555';
        accountCullenFamily.Relationship_type__c = 'Mother';
        accountCullenFamily.BillingCity = 'Phoenix';
        accountCullenFamily.BillingState = 'Arizona';
        accountCullenFamily.BillingPostalCode = '85016';
        insert accountList;
        
        List<Chapter_Vs_Role__c> chapterVsRoleList = TestDataFactory.createChapterVsRole(1, 'Arizona');
        insert chapterVsRoleList;
        
        List<Lead> leadList = TestDataFactory.createLead(1);
        Lead leadMallory = leadList.get(0);
        leadMallory.ChapterName__c = accountAzChapter.Id;
        leadMallory.FirstName = 'Mallory';
        leadMallory.LastName = 'Cullen';
        leadMallory.Diagnosis_Given_By_Referrer__c = 'Test Diagnosis';
        leadMallory.Phone = '9600467559';
        leadMallory.Email = 'testmawa@gmail.com';
        leadMallory.Street = '100 Mesa Avenue';
        leadMallory.StateCode = 'AZ';
        leadMallory.City = 'Scottsdale';
        leadMallory.PostalCode = '85261';
        leadMallory.CountryCode = 'US';
        leadMallory.DOB__c = System.today() - 1435;
        leadMallory.Company = 'MAW';
        leadMallory.Status = 'Inquiry';
        leadMallory.Gender__c = 'Female';
        leadMallory.is_Family_Aware_of_Referral__c = 'Yes';
        leadMallory.Referrer_FirstName__c = 'Harriet';
        leadMallory.Referrer_Last_Name__c = 'Walker';
        leadMallory.Referrer_Email__c = 'testmawa2d@gmail.com';
        leadMallory.Referrer_Phone__c = '9600467578';
        leadMallory.Referrer_City__c = 'Scottsdale';
        leadMallory.Referrer_Zip__c = '85261';
        leadMallory.Current_Condition_Label__c = 'Surgery in the past 3 months;I am not sure';
        leadMallory.PD_Condition_Description__c = 'Malignant Melanoma';
        leadMallory.Communication__c = 'rec1;rec2';
        insert leadList;
        
        List<Contact> contactList = TestDataFactory.createContact(2);
        Contact wishChildCameron = contactList.get(0);
        wishChildCameron.FirstName = 'Cameron';
        wishChildCameron.LastName = 'Avalon';
        wishChildCameron.Parent_Guardian_Name__c = 'Lucia Avalon';
        wishChildCameron.RecordTypeId = CONTACT_WISH_CHILD_RT_ID;
        wishChildCameron.Birthdate = Date.today().addYears(-7);
        wishChildCameron.MailingPostalCode = '94105-5188';
        wishChildCameron.MailingStreet = '7540 E Gold Dust Ave';
        wishChildCameron.MailingCountry = 'United States';
        wishChildCameron.MailingState = 'Arizona';
        wishChildCameron.MailingCity = 'Scottsdale';
        wishChildCameron.MailingLatitude = -24.355798;
        wishChildCameron.MailingLongitude = 69.830469;
        Contact volunteerLenny = contactList.get(1);
        volunteerLenny.FirstName = 'Lenny';
        volunteerLenny.LastName = 'Buckland';
        volunteerLenny.Email = 'Hey.Bucko@gmail.com';
        volunteerLenny.RecordTypeId = VOLUNTEER_RT_ID;
        volunteerLenny.AccountId = accountAzChapter.Id;
        insert contactList;
        
        List<Background_check__c> backgroundCheckList = TestDataFactory.createBackgroundCheck(1);
        Background_check__c volunteerCheck = backgroundCheckList.get(0);
        volunteerCheck.Current__c = true;
        volunteerCheck.Status__c = 'Manual';
        volunteerCheck.Date_Completed__c = Date.today();
        volunteerCheck.Date__c = Date.today().addDays(30);
        volunteerCheck.Volunteer__c = volunteerLenny.Id;
        insert backgroundCheckList;
        
        List<Conflict_Of_Interest__c> coiList = TestDataFactory.createConflictOfInterest(1);
        Conflict_Of_Interest__c volunteerCoi = coiList.get(0);
        volunteerCoi.Volunteer_Contact__c = volunteerLenny.Id;
        volunteerCoi.Expiration_Date__c = Date.today().addDays(30);
        insert coiList;
        
        List<Broadcast__c> broadcastList = TestDataFactory.createBroadcast(1);
        Broadcast__c azBroadcast = broadcastList.get(0);
        azBroadcast.Broadcast_Message__c = 'General Policy Broadcast';
        azBroadcast.Chapter_Name__c = accountAzChapter.Id;
        insert broadcastList;
        
        List<Chapter_Action_Track__c> chapterActionTrackList = TestDataFactory.createChapterActionTrack(1);
        Chapter_Action_Track__c azChapterAction = chapterActionTrackList.get(0);
        azChapterAction.Chapter_Name__c = accountAzChapter.Id;
        insert chapterActionTrackList;
        
        List<Chapter_Role__c> chapterRoleList = TestDataFactory.createChapterRole(1);
        Chapter_Role__c azChapterRole = chapterRoleList.get(0);
        azChapterRole.Chapter_Name__c = accountAzChapter.Id;
        insert chapterRoleList;
        
        List<Chapter_Role_O_T__c> chapterRoleOT = TestDataFactory.createChapterRoleOrientationAndTraining(1);
        Chapter_Role_O_T__c azChapterRoleOT = chapterRoleOT.get(0);
        azChapterRoleOT.Chapter_Role__c = azChapterRole.Id;
        insert azChapterRoleOT;
        
        List<Class_Offering__c> classOfferingList = TestDataFactory.createClassOffering(1);
        Class_Offering__c azOnlineClass = classOfferingList.get(0);
        azOnlineClass.Chapter_Role_O_T__c = azChapterRoleOT.Id;
        azOnlineClass.Date__c = System.Today() + 10;
        azOnlineClass.Start_Time__c = '10:00 AM';
        azOnlineClass.End_Time__c = '11:00 AM';
        azOnlineClass.max_capacity__c = 100;
        azOnlineClass.Location__c = 'Online';
        azOnlineClass.RecordTypeId = CLASS_OFFERING_RECORD_TYPE_ID;
        insert classOfferingList;
        
        List<Volunteer_Opportunity__c> volunteerOppList = TestDataFactory.createVolunteerOpportunity(1);
        Volunteer_Opportunity__c volOpp = volunteerOppList.get(0);
        volOpp.Volunteer_Name__c = volunteerLenny.Id;
        volOpp.Chapter_Name__c = accountAzChapter.Id;
        insert volunteerOppList;
        
        trac_TriggerHandlerBase.blockTrigger = false;
    }
    
    @IsTest
    static void leadSharing() {
        Test.startTest();
        Account chapterAccount = [
            SELECT Id, Name 
            FROM Account 
            WHERE Name = 'Make-A-Wish Arizona'
        ];
        List<Lead> leadList = [
            SELECT Id 
            FROM Lead
        ];
        
        Map<String, List<Lead>> leadMap = new Map<String, List<Lead>>();
        leadMap.put(chapterAccount.Name, leadList);
        ChapterStaffRecordSharing_AC.LeadSharing(leadMap);
        Test.stopTest();
        
        List<LeadShare> leadsToShare = [
            SELECT Id 
            FROM LeadShare 
            WHERE LeadId = :leadList[0].Id
        ];
        System.assert(!leadsToShare.isEmpty());
    }
    
    @IsTest
    public static void contactSharing() {
        Test.startTest();
        Account chapterAccount = [
            SELECT Id, Name 
            FROM Account 
            WHERE Name = 'Make-A-Wish Arizona'
        ];
        List<Contact> contactList = [
            SELECT Id, OwnerId
            FROM Contact
        ];
        Map<String, List<Contact>> contactMapforSharing = new Map<String, List<Contact>>();
        contactMapforSharing.put(chapterAccount.Name, contactList);
        ChapterStaffRecordSharing_AC.ContactSharing(contactMapforSharing);
        Test.stopTest();
        
        List<ContactShare> contactsToShare = [
            SELECT Id 
            FROM ContactShare 
            WHERE ContactId = :contactList[0].Id
        ];
        System.assert(!contactsToShare.isEmpty());
    }
    
    @IsTest
    static void accountSharing() {
        Test.startTest();
        Account chapterAccount = [
            SELECT Id, Name 
            FROM Account 
            WHERE Name = 'Make-A-Wish Arizona'
        ];
        List<Account> accountList = [
            SELECT Id 
            FROM Account 
            WHERE Name = 'Mallory Cullen & Family Account'
        ];
        
        Map<String, List<Account>> accountMapforSharing = new Map<String, List<Account>>();
        accountMapforSharing.put(chapterAccount.Name, accountList);
        ChapterStaffRecordSharing_AC.AccountSharing(accountMapforSharing);
        Test.stopTest();
        
        List<AccountShare> accountsToShare = [
            SELECT Id 
            FROM AccountShare 
            WHERE AccountId = :accountList[0].Id
        ];
        System.assert(!accountsToShare.isEmpty());
    }
    
    @IsTest
    static void backGroundCheckSharing() {
        Test.startTest();
        Account chapterAccount = [
            SELECT Id, Name 
            FROM Account 
            WHERE Name = 'Make-A-Wish Arizona'
        ];
        List<Background_check__c> backgroundCheckList = [
            SELECT Id 
            FROM Background_check__c
        ];
        
        Map<String, List<Background_check__c>> backgroundCheckMap = new Map<String, List<Background_check__c>>();
        backgroundCheckMap.put(chapterAccount.Name, backgroundCheckList);
        ChapterStaffRecordSharing_AC.BGCRecordSharing(backgroundCheckMap);
        Test.stopTest();
        
        List<Background_check__Share> backgroundCheckToShare = [
            SELECT Id
            FROM Background_check__Share
            WHERE ParentId = :backgroundCheckList[0].Id
        ];
        System.assert(!backgroundCheckToShare.isEmpty());
    }
    
    @isTest
    static void conflictOfInterestSharing() {
        Test.startTest();
        Account chapterAccount = [
            SELECT Id, Name 
            FROM Account 
            WHERE Name = 'Make-A-Wish Arizona'
        ];
        List<Conflict_Of_Interest__c> coiList = [
            SELECT Id 
            FROM Conflict_Of_Interest__c
        ];
        
        Map<String, List<Conflict_Of_Interest__c>> coiMapforSharing = new Map<String, List<Conflict_Of_Interest__c>>();
        coiMapforSharing.put(chapterAccount.Name, coiList);
        ChapterStaffRecordSharing_AC.COIRecordSharing(coiMapforSharing);
        Test.stopTest();
        
        List<Conflict_Of_Interest__Share> coiToShare = [
            SELECT Id 
            FROM Conflict_Of_Interest__Share 
            WHERE ParentId = :coiList[0].Id
        ];
        System.assert(!coiToShare.isEmpty());
    }
    
    @IsTest
    static void broadCastRecordSharing() {       
        Test.startTest();
        Account chapterAccount = [
            SELECT Id, Name 
            FROM Account 
            WHERE Name = 'Make-A-Wish Arizona'
        ];
        List<Broadcast__c> broadcastList = [
            SELECT Id 
            FROM Broadcast__c
        ];
        
        Map<String, List<Broadcast__c>> broadCastMap = new Map<String, List<Broadcast__c>>();
        broadCastMap.put(chapterAccount.Name, broadcastList);
        ChapterStaffRecordSharing_AC.broadRecordSharing(broadCastMap);
        Test.stopTest();
        
        List<Broadcast__Share> broadcastToShare = [
            SELECT Id 
            FROM Broadcast__Share 
            WHERE ParentId = :broadcastList[0].Id
        ];
        System.assert(!broadcastToShare.isEmpty());
    }
    
    @IsTest
    static void chapterActionSharing() {    
        Test.startTest();
        Account chapterAccount = [
            SELECT Id, Name 
            FROM Account 
            WHERE Name = 'Make-A-Wish Arizona'
        ];
        List<Chapter_Action_Track__c> chapterActionTrackList = [
            SELECT Id 
            FROM Chapter_Action_Track__c
        ];
        
        Map<String, List<Chapter_Action_Track__c>> chapterActionMap = new Map<String, List<Chapter_Action_Track__c>>();
        chapterActionMap.put(chapterAccount.Name, chapterActionTrackList);
        ChapterStaffRecordSharing_AC.chapterActionTrackSharing(chapterActionMap);
        Test.stopTest();
        
        List<Chapter_Action_Track__Share> chapterActionToShareList = [
            SELECT Id 
            FROM Chapter_Action_Track__Share 
            WHERE ParentId = :chapterActionTrackList[0].Id
        ];
        System.assert(!chapterActionToShareList.isEmpty());
    }
    
    @IsTest
    static void chapterRoleSharing() {
        Test.startTest();
        Account chapterAccount = [
            SELECT Id, Name 
            FROM Account 
            WHERE Name = 'Make-A-Wish Arizona'
        ];
        List<Chapter_Role__c> chapterRoleList = [
            SELECT Id 
            FROM Chapter_Role__c
        ];
        
        Map<String, List<Chapter_Role__c>> chapterRoleMap = new Map<String, List<Chapter_Role__c>>();
        chapterRoleMap.put(chapterAccount.Name, chapterRoleList);
        ChapterStaffRecordSharing_AC.chapterRoleSharing(chapterRoleMap);
        Test.stopTest();
        
        List<Chapter_Role__Share> chapterRoleToShareList = [
            SELECT Id 
            FROM Chapter_Role__Share 
            WHERE ParentId = :chapterRoleList[0].Id
        ];
        System.assert(!chapterRoleToShareList.isEmpty());
    }
    
    @IsTest
    static void chapterRoleOTSharing() {
        Test.startTest();
        Account chapterAccount = [
            SELECT Id, Name 
            FROM Account 
            WHERE Name = 'Make-A-Wish Arizona'
        ];
        List<Chapter_Role_O_T__c> chapterRoleOTList = [
            SELECT Id 
            FROM Chapter_Role_O_T__c
        ];
        
        Map<String, List<Chapter_Role_O_T__c>> chapterRoleMap = new Map<String, List<Chapter_Role_O_T__c>>();
        chapterRoleMap.put(chapterAccount.Name, chapterRoleOTList);
        ChapterStaffRecordSharing_AC.chapterRoleOTSharing(chapterRoleMap);
        Test.stopTest();
        
        List<Chapter_Role_O_T__Share> chapterRoleOTToShareList = [
            SELECT Id 
            FROM Chapter_Role_O_T__Share 
            WHERE ParentId = :chapterRoleOTList[0].Id
        ];
        System.assert(!chapterRoleOTToShareList.isEmpty());
    }
    
    @IsTest
    static void classOfferingSharing() {
        Test.startTest();
        Account chapterAccount = [
            SELECT Id, Name 
            FROM Account 
            WHERE Name = 'Make-A-Wish Arizona'
        ];
        List<Class_Offering__c> classOfferingList = [
            SELECT Id 
            FROM Class_Offering__c
        ];
        
        Map<String, List<Class_Offering__c>> classOfferingMap = new Map<String, List<Class_Offering__c>>();
        classOfferingMap.put(chapterAccount.Name, classOfferingList);
        ChapterStaffRecordSharing_AC.classOfferingSharing(classOfferingMap);
        Test.stopTest();
        
        List<Class_Offering__Share> classOfferingShareList = [
            SELECT Id 
            FROM Class_Offering__Share 
            WHERE ParentId = :classOfferingList[0].Id
        ];
        System.assert(!classOfferingShareList.isEmpty());
    }
    
    @IsTest
    static void volunteerOpportunitySharing() {
        Test.startTest();
        Account chapterAccount = [
            SELECT Id, Name 
            FROM Account 
            WHERE Name = 'Make-A-Wish Arizona'
        ];
        List<Volunteer_Opportunity__c> volOppList = [
            SELECT Id 
            FROM Volunteer_Opportunity__c
        ];
        
        Map<String, List<Volunteer_Opportunity__c>> volMapForSharing = new Map<String, List<Volunteer_Opportunity__c>>();
        volMapForSharing.put(chapterAccount.Name, volOppList);
        ChapterStaffRecordSharing_AC.volunteerOpportunitySharing(volMapForSharing);
        Test.stopTest();
        
        List<Volunteer_Opportunity__Share> volunteerOppShareList = [
            SELECT Id 
            FROM Volunteer_Opportunity__Share 
            WHERE ParentId = :volOppList[0].Id
        ];
        System.assert(!volunteerOppShareList.isEmpty());
    }
    
    @isTest
    static void getChapterNameTest() {
        Test.startTest();
        Account chapterAccount = [
            SELECT Id, Name 
            FROM Account 
            WHERE Name = 'Make-A-Wish Arizona'
        ];
        Chapter_Vs_Role__c azChapterRole = [
            SELECT Id, Role_Name__c 
            FROM Chapter_Vs_Role__c 
            WHERE Role_Name__c = 'Arizona - Chapter'
        ];
        Map<Id, String> chapterNameMap = new Map<Id, String>();
        chapterNameMap = ChapterStaffRecordSharing_AC.getChapterName(new Set<Id>{chapterAccount.Id});
        Test.stopTest();
        
        System.assert(chapterNameMap.get(chapterAccount.Id) == azChapterRole.Role_Name__c);
    }
}