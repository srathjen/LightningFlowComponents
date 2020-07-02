public class WishRequiredSignatureDomain extends trac_TriggerHandlerBase {

    private List<Wish_Required_Signature__c> newWishSignatureList = (List<Wish_Required_Signature__c>)newRecordsList;
    private List<Wish_Required_Signature__c> oldWishSignatureList = (List<Wish_Required_Signature__c>)oldRecordsList;
    private Map<Id, Wish_Required_Signature__c> newWishSignaturesMap = (Map<Id, Wish_Required_Signature__c>)newRecordsMap;
    private Map<Id, Wish_Required_Signature__c> oldWishSignaturesMap = (Map<Id, Wish_Required_Signature__c>)oldRecordsMap;
    
    /**
    * After insert of wish required signature
    */
    public override void handleAfterInsert() {
        ContactService.updateRaceEthnicity(newWishSignaturesMap, null);
    }
    
    /**
    * After update of wish required signature
    */
    public override void handleAfterUpdate() {
        ContactService.updateRaceEthnicity(newWishSignaturesMap, oldWishSignaturesMap);
    }
}