/**
 * @description Domain class for the Affiliation trigger
 * @author Gustavo Mayer, Traction on Demand
 * @date 3-19-2020
 */
public class AffiliationDomain extends trac_TriggerHandlerBase {

    List<npe5__Affiliation__c> newList = (List<npe5__Affiliation__c>) newRecordsList;
    List<npe5__Affiliation__c> oldList = (List<npe5__Affiliation__c>) oldRecordsList;
    Map<Id, npe5__Affiliation__c> newMap = (Map<Id, npe5__Affiliation__c>) newRecordsMap;
    Map<Id, npe5__Affiliation__c> oldMap = (Map<Id, npe5__Affiliation__c>) oldRecordsMap;

    /**
     * @description Before insert of Affiliation
     */
    public override void handleBeforeInsert() {
        AffiliationService.setStatusAndPrimary(newList);
    }

    /**
     * @description Before update of Affiliation
     */
    public override void handleBeforeUpdate() {
        AffiliationService.setHiddenUserFields(newList, oldMap);
    }

    /**
     * @description After insert of Affiliation
     */
    public override void handleAfterInsert() {
        AffiliationService.addToPublicGroup(newList);
    }

    /**
     * @description After update of Affiliation
     */
    public override void handleAfterUpdate() {
        AffiliationService.addToChatterGroup(newList, oldMap);
        AffiliationService.addToPublicGroup(newList, oldMap);
    }

    /**
     * @description After update of Affiliation
     */
    public override void handleAfterDelete() {
        Set<String> volunteerNameSet = new Set<String>();
        Set<String> chapterNameSet = new Set<String>();
        Map<Id, String> affiliationRecMap = new Map<Id, String>();
        for (npe5__Affiliation__c currentRecord : oldList) {
            volunteerNameSet.add(currentRecord.npe5__Contact__c);
            chapterNameSet.add(currentRecord.npe5__Organization__c);
            affiliationRecMap.put(currentRecord.Id, String.valueOf(currentRecord));
        }
        AffiliationService.removeMemberFromGroup(volunteerNameSet, chapterNameSet, affiliationRecMap);
    }
}