/**
* @description Centralizes business rules for Dynamic Content
* @author Michelle Cominotto, Make-A-Wish
* @createdDate 4/21/2020
*/

public class DynamicContentService {

    private final static String ROLE_NATIONAL_STAFF = Constant_AC.ROLE_NATIONAL_STAFF;
    private final static Id NATIONAL_RT_ID = Constant_AC.NATIONAL_RT_ID;
    
    /**
    * Set active flag to true
    * @param dynamicContentList
    */
    public static void setActiveFlagTrue(List<Dynamic_Content__c> dynamicContentList) {
        for(Dynamic_Content__c content : dynamicContentList) {
            content.Active__c = true;
        }
    }
    
    /**
    * Check if current user has permission to insert/update record based on chapter and role
    * @param dynamicContentList
    */
    public static void checkChapterPermission(List<Dynamic_Content__c> dynamicContentList) {
        String userRole = Utils.currentUser.UserRole.Name;
        Set<Id> chapterIdSet = new Set<Id>();
        Map<Id, String> chapterNameMap = new Map<Id, String>();
        
        if(userRole == ROLE_NATIONAL_STAFF) {
            return;
        }     
        for(Dynamic_Content__c content : dynamicContentList) {
            if(content.Chapter_Name__c != null) {
                chapterIdSet.add(content.Chapter_Name__c);
            }
        }
        if(chapterIdSet.isEmpty()) {
            return;
        }
        chapterNameMap = ChapterStaffRecordSharing_AC.getChapterName(chapterIdSet);
        for(Dynamic_Content__c content : dynamicContentList) {
            if(chapterNameMap.containsKey(content.Chapter_Name__c) 
               && userRole != chapterNameMap.get(content.Chapter_Name__c)) {
                   content.addError('You have no access to create Dynamic Content records for other chapters');
               }
        }
    }
    
    /**
    * Check if chapter lookup has changed and verify current user has permission to make update
    * @param newDynamicContentList
    * @param oldDynamicContentMap
    */
    public static void checkChapterPermission(List<Dynamic_Content__c> newDynamicContentList, Map<Id, Dynamic_Content__c> oldDynamicContentMap) {
        List<Dynamic_Content__c> updatedDynamicContentList = new List<Dynamic_Content__c>();
        for(Dynamic_Content__c newContent : newDynamicContentList) {
            if(newContent.Chapter_Name__c != oldDynamicContentMap.get(newContent.Id).Chapter_Name__c) {
                updatedDynamicContentList.add(newContent);
            }
        }
        if(!updatedDynamicContentList.isEmpty()) {
            checkChapterPermission(updatedDynamicContentList);
        }
    }
    
    /**
    * Prevent updating active flag to true for duplicate records 
    * @param newDynamicContentList
    * @param oldDynamicContentMap
    */
    public static void restrictActiveUpdateForDupes(List<Dynamic_Content__c> newDynamicContentList, Map<Id, Dynamic_Content__c> oldDynamicContentMap) {
        Set<Id> recordTypeNewSet = new Set<Id>();
        Set<Id> chapterIdSet = new Set<Id>();
        Set<Id> recordTypeOldSet = new Set<Id>();
        for(Dynamic_Content__c newContent : newDynamicContentList) {
            if(newContent.Active__c == true && oldDynamicContentMap.get(newContent.Id).Active__c == false) {
                recordTypeNewSet.add(newContent.RecordTypeId);
            }
        }
        if(recordTypeNewSet.isEmpty()) {
            return;
        }
        for(Dynamic_Content__c existingContent : [
            SELECT Id, RecordTypeId, Chapter_Name__c 
            FROM Dynamic_Content__c 
            WHERE RecordTypeId IN :recordTypeNewSet 
            AND Active__c = true]) {
                recordTypeOldSet.add(existingContent.RecordTypeId);
                chapterIdSet.add(existingContent.Chapter_Name__c);
            }
        for(Dynamic_Content__c newContent : newDynamicContentList) {
            if(newContent.RecordTypeId == NATIONAL_RT_ID && recordTypeOldSet.contains(NATIONAL_RT_ID)) {
                newContent.addError('Active National Record already exist');
            } else if(chapterIdSet.contains(newContent.Chapter_Name__c) && recordTypeOldSet.contains(newContent.RecordTypeId)) {
                newContent.addError('Active record already exist for this chapter and record type');
            }
        }
    }
    
    /**
    * Update active flag to false for existing records when new active dynamic content record created  
    * @param dynamicContentList
    */
    public static void updateActiveFlagFalse(List<Dynamic_Content__c> newDynamicContentList) {
        Set<Id> recordIdSet = new Set<Id>();
        Set<Id> recordTypeIdSet = new Set<Id>();
        Set<Id> chapterIdSet = new Set<Id>();
        for(Dynamic_Content__c content : newDynamicContentList) {
            if(content.Active__c == true) {
                recordIdSet.add(content.Id);
                recordTypeIdSet.add(content.RecordTypeId);
                chapterIdSet.add(content.Chapter_Name__c);
            }
        }
        if(recordIdSet.isEmpty()) {
            return;
        }
        List<Dynamic_Content__c> activeContentList = new List<Dynamic_Content__c>([
            SELECT Id, Active__c, Chapter_Name__c, RecordTypeId 
            FROM Dynamic_Content__c 
            WHERE RecordTypeId IN :recordTypeIdSet 
            AND Id NOT IN :recordIdSet 
            AND Active__c = true
        ]);
        for(Dynamic_Content__c content : activeContentList) {
            if(content.RecordTypeId == NATIONAL_RT_ID || chapterIdSet.contains(content.Chapter_Name__c)) {
                content.Active__c = false;
            }
        }
        update activeContentList;
    }
}