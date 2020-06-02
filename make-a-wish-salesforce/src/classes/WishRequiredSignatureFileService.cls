/**
 * @description Service class for the WishRequiredSignatureFile trigger
 * @author Mitali Nahar, Traction on Demand
 * @date 08/01/2019
 */
public with sharing class WishRequiredSignatureFileService {

	/**
     * @description To perform modifications on Wish Signature File records after they are Inserted
     * @param newList
     */
    public static void onAfterInsert(List<Wish_Required_Signature_File__c> newList) {
        List<Id> wishSignIds = new List<Id>();
        Map<Id, String> wishSignFileMap = new Map<Id, String>();
        for (Wish_Required_Signature_File__c wishSign : newList) {
            wishSignIds.add(wishSign.Id);
            wishSignFileMap.put(wishSign.Id, String.valueOf(wishSign));
        }
        AWSFilePathService.updateWishRequiredSignatureFilePath(wishSignIds, wishSignFileMap);
    }
}