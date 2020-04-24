/**
* @description Domain class for Dynamic Content trigger
* @author Michelle Cominotto, Make-A-Wish
* @createdDate 4/21/2020
*/

public class DynamicContentDomain extends trac_TriggerHandlerBase {
    private List<Dynamic_Content__c> newDynamicContentList = (List<Dynamic_Content__c>)newRecordsList;
    private List<Dynamic_Content__c> oldDynamicContentList = (List<Dynamic_Content__c>)oldRecordsList;
    private Map<Id, Dynamic_Content__c> newDynamicContentMap = (Map<Id, Dynamic_Content__c>)newRecordsMap;
    private Map<Id, Dynamic_Content__c> oldDynamicContentMap = (Map<Id, Dynamic_Content__c>)oldRecordsMap;
    
    /**
    * Before insert of dynamic content
    */
    public override void handleBeforeInsert() {
        DynamicContentService.checkChapterPermission(newDynamicContentList);
        DynamicContentService.setActiveFlagTrue(newDynamicContentList);
    }
    
    /**
    * Before update of dynamic content
    */
    public override void handleBeforeUpdate() {
        DynamicContentService.checkChapterPermission(newDynamicContentList, oldDynamicContentMap);
        DynamicContentService.restrictActiveUpdateForDupes(newDynamicContentList, oldDynamicContentMap);
    }
    
    /**
    * After insert of dynamic content
    */
    public override void handleAfterInsert() {
        DynamicContentService.updateActiveFlagFalse(newDynamicContentList);
    }
}
