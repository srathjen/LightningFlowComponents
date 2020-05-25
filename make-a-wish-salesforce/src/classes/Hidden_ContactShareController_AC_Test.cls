@IsTest
public class Hidden_ContactShareController_AC_Test {

    private final static Id CHAPTER_RT_ID = Constant_AC.CHAPTER_RT_ID;
    private final static Id VOLUNTEER_RT_ID = Constant_AC.VOLUNTEER_RT_ID;
    private final static Id CONTACT_WISH_CHILD_RT_ID = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
    private final static Id WISH_FAMILY_RT_ID = Constant_AC.WISH_FAMILY_RT_ID;
    
    @TestSetup
    public static void setUp() {
        trac_TriggerHandlerBase.blockTrigger = true;
        
        List<Account> accountList = TestDataFactory.createAccount(1);
        Account accountAzChapter = accountList.get(0);
        accountAzChapter.Name = 'Make-A-Wish Arizona';
        accountAzChapter.RecordTypeId = CHAPTER_RT_ID;
        insert accountList;
        
        List<Contact> contactList = TestDataFactory.createContact(3);
        Contact volunteerLily = contactList.get(0);
        volunteerLily.FirstName = 'Lilian';
        volunteerLily.LastName = 'Bubbles';
        volunteerLily.Email = 'Test.Mawa@gmail.com';
        volunteerLily.RecordTypeId = VOLUNTEER_RT_ID;
        volunteerLily.AccountId = accountAzChapter.Id;
        Contact wishChildJenny = contactList.get(1);
        wishChildJenny.FirstName = 'Jennifer';
        wishChildJenny.LastName = 'Bell';
        wishChildJenny.Parent_Guardian_Name__c = 'Jonathan Bell';
        wishChildJenny.RecordTypeId = CONTACT_WISH_CHILD_RT_ID;
        wishChildJenny.Birthdate = Date.today().addYears(-7);
        wishChildJenny.MailingPostalCode = '94105-5188';
        wishChildJenny.MailingStreet = '7540 E Gold Dust Ave';
        wishChildJenny.MailingCountry = 'United States';
        wishChildJenny.MailingState = 'Arizona';
        wishChildJenny.MailingCity = 'Scottsdale';
        wishChildJenny.MailingLatitude = -24.355798;
        wishChildJenny.MailingLongitude = 69.830469;
        Contact wishFamilyJon = contactList.get(2);
        wishFamilyJon.FirstName = 'Jonathan';
        wishFamilyJon.LastName = 'Bell';
        wishFamilyJon.Email = 'testmawa@gmail.com';
        wishFamilyJon.Phone = '9600467559';
        wishFamilyJon.MailingStreet = '7540 E Gold Dust Ave';
        wishFamilyJon.MailingCity = 'Scottsdale';
        wishFamilyJon.MailingStateCode = 'AZ';
        wishFamilyJon.MailingPostalCode = '94105-5188';
        wishFamilyJon.MailingCountryCode = 'US';
        wishFamilyJon.RecordTypeId = WISH_FAMILY_RT_ID ;
        wishFamilyJon.IsParentGuardian__c = 'ParentGuardian';
        wishFamilyJon.Region_Chapter__c = accountAzChapter.Id;
        insert contactList;
        
        List<npe4__Relationship__c> relationshipList = TestDataFactory.createRelationship(2);
        npe4__Relationship__c relationshipOne = relationshipList.get(0);
        relationshipOne.npe4__Contact__c = wishChildJenny.Id;
        relationshipOne.npe4__RelatedContact__c = wishFamilyJon.Id;
        relationshipOne.npe4__Status__c = 'Active';
        npe4__Relationship__c relationshipTwo = relationshipList.get(1);
        relationshipTwo.npe4__Contact__c = wishFamilyJon.Id;
        relationshipTwo.npe4__RelatedContact__c = wishChildJenny.Id;
        relationshipTwo.npe4__Status__c = 'Active';
        insert relationshipList;
        
        trac_TriggerHandlerBase.blockTrigger = false;
    }
    
    @isTest
    private static void validateController() {
        User volunteer = [
            SELECT Id, ContactId 
            FROM User 
            WHERE ContactId != null 
            AND IsActive = true 
            LIMIT 1
        ];
        
        Contact wishChild = [
            SELECT Id 
            FROM Contact 
            WHERE Name = 'Jennifer Bell' 
            AND RecordTypeId = :CONTACT_WISH_CHILD_RT_ID
        ];
        
        Test.startTest();
        System.runAs(volunteer) {
            Test.setCurrentPage(Page.Hidden_ContactShare_VF);
            Hidden_ContactShareController_AC controller = new Hidden_ContactShareController_AC(new ApexPages.StandardController(wishChild));
            controller.shareContact();
        }
        Test.stopTest();
    }
}