@isTest
private class DynamicContentServiceTest {

    private final static Id PROSPECTIVE_VOLUNTEER_RT_ID = Constant_AC.PROSPECTIVE_VOLUNTEER_RT_ID;
    private final static Id CHAPTER_RT_ID = Constant_AC.CHAPTER_RT_ID;

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

        List<Dynamic_Content__c> dynamicContent = TestDataFactory.createDynamicContent(2);
        Dynamic_Content__c volunteerAzContent = dynamicContent.get(0);
        volunteerAzContent.RecordTypeId = PROSPECTIVE_VOLUNTEER_RT_ID;
        volunteerAzContent.Chapter_Name__c = accountAzChapter.Id;
        volunteerAzContent.Active__c = true;
        Dynamic_Content__c volunteerAzContent2 = dynamicContent.get(1);
        volunteerAzContent2.RecordTypeId = PROSPECTIVE_VOLUNTEER_RT_ID;
        volunteerAzContent2.Chapter_Name__c = accountAzChapter.Id;
        insert dynamicContent;
        
        List<Chapter_Vs_Role__c> chapterRoleList = TestDataFactory.createChapterVsRole(2);
        Chapter_Vs_Role__c azChapter = chapterRoleList.get(0);
        azChapter.Chapter_Name__c = 'Make-A-Wish Arizona';
        azChapter.Role_Name__c = 'Arizona - Chapter'; 
        azChapter.Name = 'Make-A-Wish Arizona';
        Chapter_Vs_Role__c flChapter = chapterRoleList.get(1);
        flChapter.Chapter_Name__c = 'Make-A-Wish Central & Northern Florida';
        flChapter.Role_Name__c = 'Central & Northern Florida - Chapter'; 
        flChapter.Name = 'Make-A-Wish Central & Northern Flor';
        insert chapterRoleList;
        
        trac_TriggerHandlerBase.blockTrigger = false;
    }
    
    @isTest
    private static void validateCheckChapterPermission() {
        Account floridaChapter = [
            SELECT Id, Name 
            FROM Account 
            WHERE Name = 'Make-A-Wish Central & Northern Florida'  
            LIMIT 1];
        
        Map<Id, Dynamic_Content__c> dynamicContentMap = new Map<Id, Dynamic_Content__c>([
            SELECT Id, Chapter_Name__c 
            FROM Dynamic_Content__c
        ]);
        List<Dynamic_Content__c> dynamicContentUpdated = new List<Dynamic_Content__c>();
        for(Dynamic_Content__c content : dynamicContentMap.values()) {
            Dynamic_Content__c updatedContent = new Dynamic_Content__c(Id = content.Id);
            updatedContent.Chapter_Name__c = floridaChapter.Id;
            dynamicContentUpdated.add(updatedContent);
        }
        
         User azUser = [
            SELECT Id FROM User 
            WHERE IsActive = true 
            AND UserRole.Name = 'Arizona - Chapter'
            LIMIT 1];
        
        Test.startTest();
        System.runAS(azUser) {
            DynamicContentService.checkChapterPermission(dynamicContentUpdated, dynamicContentMap);
        }
        Test.stopTest();
        
        List<Dynamic_Content__c> dynamicContentCheck = [
            SELECT Id, Chapter_Name__c 
            FROM Dynamic_Content__c 
            WHERE Id IN :dynamicContentMap.keySet()];
        System.assert(dynamicContentCheck[0].Chapter_Name__c != floridaChapter.Id);
    }
    
    @isTest
    private static void validateRestrictActiveUpdateForDupes() {
        String errorMessage = '';
        Map<Id, Dynamic_Content__c> inactiveContentMap = new Map<Id, Dynamic_Content__c>([
            SELECT Id, Active__c, RecordTypeId, Chapter_Name__c 
            FROM Dynamic_Content__c 
            WHERE Active__c = false]);
        List<Dynamic_Content__c> updatedContentList = new List<Dynamic_Content__c>();
        for(Dynamic_Content__c content : inactiveContentMap.values()) {
            Dynamic_Content__c updatedContent = new Dynamic_Content__c(Id = content.Id);
            updatedContent.Active__c = true;
            updatedContent.RecordTypeId = content.RecordTypeId;
            updatedContent.Chapter_Name__c = content.Chapter_Name__c;
            updatedContentList.add(updatedContent);
        }
        
        Test.startTest();
        try {
            update updatedContentList;
        } catch(Exception ex) {
            errorMessage = ex.getMessage();
        }
        Test.stopTest();
        
        System.assert(errorMessage.contains('Active record already exist for this chapter and record type'));
    }

    @isTest
    private static void validateUpdateActiveFlagFalse() {
        Account arizonaChapter = [
            SELECT Id 
            FROM Account 
            WHERE Name = 'Make-A-Wish Arizona' 
            LIMIT 1];
        
        Map<Id, Dynamic_Content__c> mapDynamicContent = new Map<Id, Dynamic_Content__c>([
            SELECT Id, Active__c 
            FROM Dynamic_Content__c 
            WHERE Chapter_Name__c = :arizonaChapter.Id
            AND Active__c = true
        ]);

        List<Dynamic_Content__c> newDynamicContent = TestDataFactory.createDynamicContent(1);
        Dynamic_Content__c volunteerAzContent = newDynamicContent.get(0);
        volunteerAzContent.RecordTypeId = PROSPECTIVE_VOLUNTEER_RT_ID;
        volunteerAzContent.Chapter_Name__c = arizonaChapter.Id;

        Test.startTest();
        insert newDynamicContent;
        Test.stopTest();

        List<Dynamic_Content__c> updatedDynamicContentList = [
            SELECT Id, Active__c 
            FROM Dynamic_Content__c 
            WHERE Id IN :mapDynamicContent.keySet()];
        System.assert(updatedDynamicContentList[0].Active__c == false);
    }
}