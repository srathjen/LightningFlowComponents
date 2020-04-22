/**
* @description Test class for AwardsRecognitionService
* @author Michelle Cominotto, Make-A-Wish
* @createdDate 4/20/2020
*/
@isTest
private class AwardsRecognitionServiceTest {
    
    private final static Id CHAPTER_RT_ID = Constant_AC.CHAPTER_RT_ID;
    private final static Id VOLUNTEER_RT_ID = Constant_AC.VOLUNTEER_RT_ID;
    
    @testSetup
    private static void setUp() {
        trac_TriggerHandlerBase.blockTrigger = true;
        
        List<Account> accounts = TestDataFactory.createAccount(2);
        Account accountAzChapter = accounts.get(0);
        accountAzChapter.Name = 'Make-A-Wish Arizona';
        accountAzChapter.RecordTypeId = CHAPTER_RT_ID;
        Account accountFlChapter = accounts.get(1);
        accountFlChapter.Name = 'Make-A-Wish Central & Northern Florida';
        accountFlChapter.RecordTypeId = CHAPTER_RT_ID;
        insert accounts;
        
        List<Contact> contactList = TestDataFactory.createContact(1);
        Contact volunteerMarie = contactList.get(0);
        volunteerMarie.FirstName = 'Marie';
        volunteerMarie.LastName = 'Gardner';
        volunteerMarie.Email = 'marie.gardner@testmail.com';
        volunteerMarie.RecordTypeId = VOLUNTEER_RT_ID;
        volunteerMarie.AccountId = accountAzChapter.Id;
        insert contactList;
        
        List<Awards_Recognition__c> awardsList = TestDataFactory.createAwardsRecognitions(1);
        Awards_Recognition__c awardVolunteer = awardsList.get(0);
        awardVolunteer.Chapter_Name__c = accountAzChapter.Id;
        awardVolunteer.Volunteer_Contact__c = volunteerMarie.Id;
        insert awardsList;
        
        trac_TriggerHandlerBase.blockTrigger = false;
    }
    
    @isTest
    private static void validateCheckChapterRolePermission() {       
        Account floridaChapter = [
            SELECT Id, Name 
            FROM Account 
            WHERE Name = 'Make-A-Wish Central & Northern Florida'  
            LIMIT 1];		
        
        Map<Id, Awards_Recognition__c> awardRecognitionMap = new Map<Id, Awards_Recognition__c>([
            SELECT Id, Chapter_Name__c 
            FROM Awards_Recognition__c
        ]);
        List<Awards_Recognition__c> awardsListUpdated = new List<Awards_Recognition__c>();
        for(Awards_Recognition__c award : awardRecognitionMap.values()) {
            Awards_Recognition__c updatedAward = new Awards_Recognition__c(Id = award.Id);
            updatedAward.Chapter_Name__c = floridaChapter.Id;
            awardsListUpdated.add(updatedAward);
        }
        
        User azUser = [
            SELECT Id FROM User 
            WHERE IsActive = true 
            AND UserRole.Name = 'Arizona - Chapter'
            LIMIT 1];
        
        Test.startTest();
        System.runAS(azUser) {
            AwardsRecognitionService.checkChapterRolePermission(awardsListUpdated, awardRecognitionMap);
        }
        Test.stopTest();
        
        Awards_Recognition__c awardChangeCheck = [
            SELECT Id, Chapter_Name__c 
            FROM Awards_Recognition__c 
            LIMIT 1];
        System.assert(awardChangeCheck.Chapter_Name__c != floridaChapter.Id);
    }
}