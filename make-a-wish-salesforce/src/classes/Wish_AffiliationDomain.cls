/**
 * @description Domain class for the Wish_Affiliation trigger
 * @author Mason Buhler, Traction on Demand
 * @date 7-26-2019
 */
public with sharing class Wish_AffiliationDomain extends trac_TriggerHandlerBase {
    private List<Wish_Affiliation__c> newWishAffiliationsList = (List<Wish_Affiliation__c>) newRecordsList;
    private Map<Id, Wish_Affiliation__c> newWishAffiliationsMap = (Map<Id, Wish_Affiliation__c>) newRecordsMap;
    private Map<Id, Wish_Affiliation__c> oldWishAffiliationsMap = (Map<Id, Wish_Affiliation__c>) oldRecordsMap;

    /**
     * @description Before inserting Wish Affiliation, update the Survey Recipients
     */
    public override void handleBeforeInsert() {
        SurveyRecipientService.updateSurveyRecipients(newWishAffiliationsList, oldWishAffiliationsMap);
    }

    /**
     * @description Before inserting Wish Affiliation, update the Survey Recipients
     */
    public override void handleBeforeUpdate() {
        SurveyRecipientService.updateSurveyRecipients(newWishAffiliationsList, oldWishAffiliationsMap);
    }

    /**
     * @description After inserting Wish Affiliation, create the Wish Child, Participant, Participant Guardian and Wish Child signatures
     */
    public override void handleAfterInsert() {
        WishRequiredSignatureService.createWishChildSignatures(newWishAffiliationsList, oldWishAffiliationsMap);
        WishRequiredSignatureService.createWishParticipantSignatures(newWishAffiliationsList, oldWishAffiliationsMap);
        WishRequiredSignatureService.createParticipantGuardianSignatures(newWishAffiliationsList, oldWishAffiliationsMap);
        WishRequiredSignatureService.createWishChildGuardianSignatures(newWishAffiliationsList, oldWishAffiliationsMap);
    }

    /**
     * @description After updating Wish Affiliation, create the Wish Child, Participant,
     * Participant Guardian and Wish Child signatures
     */
    public override void handleAfterUpdate() {
        WishRequiredSignatureService.createWishChildSignatures(newWishAffiliationsList, oldWishAffiliationsMap);
        WishRequiredSignatureService.createWishParticipantSignatures(newWishAffiliationsList, oldWishAffiliationsMap);
        WishRequiredSignatureService.createParticipantGuardianSignatures(newWishAffiliationsList, oldWishAffiliationsMap);
        WishRequiredSignatureService.createWishChildGuardianSignatures(newWishAffiliationsList, oldWishAffiliationsMap);
    }

}