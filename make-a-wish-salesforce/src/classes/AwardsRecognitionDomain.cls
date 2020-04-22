/**
* @description Domain class for Awards Recognition trigger
* @author Michelle Cominotto, Make-A-Wish
* @createdDate 4/20/2020
*/

public class AwardsRecognitionDomain extends trac_TriggerHandlerBase {
    
    private List<Awards_Recognition__c> newAwardsRecognitionList = (List<Awards_Recognition__c>)newRecordsList;
    private List<Awards_Recognition__c> oldAwardsRecognitionList = (List<Awards_Recognition__c>)oldRecordsList;
    private Map<Id, Awards_Recognition__c> newAwardsRecognitionMap = (Map<Id, Awards_Recognition__c>)newRecordsMap;
    private Map<Id, Awards_Recognition__c> oldAwardsRecognitionMap = (Map<Id, Awards_Recognition__c>)oldRecordsMap;
    
    /**
    * After insert of awards and recognition
    */
    public override void handleAfterInsert() {
        AwardsRecognitionService.checkChapterRolePermission(newAwardsRecognitionList);
    }
    
    /**
    * After update of awards and recognition
    */
    public override void handleAfterUpdate() {
        AwardsRecognitionService.checkChapterRolePermission(newAwardsRecognitionList, oldAwardsRecognitionMap);
    }
}