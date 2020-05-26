/**
 * @description Batch job to flag expired wish required signatures
 *
 * @author Mason Buhler, Traction on Demand
 *
 * @date 2019-04-24
 */
global without sharing class RequiredSignatureExpiredBatch implements Database.Batchable<SObject>, Schedulable {

    private static final List<String> INVALID_STATUS_LIST = new List<String>{
            Constant_AC.WISH_REQUIRED_SIGNATURE_STATUS_EXPIRED,
            Constant_AC.WISH_REQUIRED_SIGNATURE_STATUS_SIGNED,
            Constant_AC.WISH_REQUIRED_SIGNATURE_STATUS_VOIDED
    };

    /**
     * @description Isolate the expired wish required signature records
     *
     * @param bc Batchable context object
     *
     * @return Query locator containing query results
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('STEVE:');
        System.debug([SELECT Id, Status__c, Signature_Expiry_Date__c FROM Wish_Required_Signature__c]);
        return Database.getQueryLocator(
                'SELECT Id, Status__c '
                        + 'FROM Wish_Required_Signature__c '
                        + 'WHERE Signature_Expiry_Date__c <= TODAY AND Status__c NOT IN :INVALID_STATUS_LIST'
        );
    }

    /**
     * @description Set the status of all expired wish required signature records to Expired
     *
     * @param bc Batchable context object
     * @param sigs List of wish required signature records
     */
    global void execute(Database.BatchableContext bc, List<Wish_Required_Signature__c> sigs) {
        for (Wish_Required_Signature__c sig : sigs) {
            sig.Status__c = Constant_AC.WISH_REQUIRED_SIGNATURE_STATUS_EXPIRED;
        }
        update sigs;
    }

    /**
     * @description Final processing after the last batch
     *
     * @param bc Batchable context object
     */
    global void finish(Database.BatchableContext bc) {
    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new RequiredSignatureExpiredBatch());
    }
}