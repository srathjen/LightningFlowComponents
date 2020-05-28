/**
 * @description Domain class for the Orientation Training trigger
 * @author Gustavo Mayer, Traction on Demand
 * @date 4/15/2020
 */
public class BroadcastDomain extends trac_TriggerHandlerBase {

    List<Broadcast__c> newBroadcastList = (List<Broadcast__c>) newRecordsList;
    List<Broadcast__c> oldBroadcastList = (List<Broadcast__c>) oldRecordsList;
    Map<Id, Broadcast__c> newBroadcastMap = (Map<Id, Broadcast__c>) newRecordsMap;
    Map<Id, Broadcast__c> oldBroadcastMap = (Map<Id, Broadcast__c>) oldRecordsMap;

    /**
     * @description Before insert of Broadcast
     */
    public override void handleBeforeInsert() {
        Set<Id> chapterIds = BroadcastService.buildChapterNames(newBroadcastList);
        BroadcastValidation.validatePermission(chapterIds, newBroadcastList);
    }

    /**
     * @description Before update of Broadcast
     */
    public override void handleBeforeUpdate() {
        Set<Id> chapterIds = BroadcastService.buildChapterNames(newBroadcastList, oldBroadcastMap);
        BroadcastValidation.validatePermission(chapterIds, newBroadcastList);
    }

    /**
     * @description After insert of Broadcast
     */
    public override void handleAfterInsert() {
        Map<String, List<Broadcast__c>> broadcastMapShare = BroadcastService.buildBroadcastShare(newBroadcastMap);
        ChapterStaffRecordSharing_AC.broadRecordSharing(broadcastMapShare);
    }

    /**
     * @description After update of Broadcast
     */
    public override void handleAfterUpdate() {
        Map<String, List<Broadcast__c>> broadcastMapShare = BroadcastService.buildBroadcastShare(newBroadcastMap, oldBroadcastMap);
        ChapterStaffRecordSharing_AC.broadRecordSharing(broadcastMapShare);
    }
}