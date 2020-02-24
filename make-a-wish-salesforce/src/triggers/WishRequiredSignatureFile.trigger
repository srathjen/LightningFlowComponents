/* 
* @Description When a new WishRequiredSignatureFile record is created or updated and deleted then it will call the corresponding apex class
* @author Mitali Nahar, Traction on Demand
* @Date 2019-07-15
*/
trigger WishRequiredSignatureFile on Wish_Required_Signature_File__c (After insert) {
    trac_TriggerHandlerBase.triggerHandler(new WishRequiredSignatureFileDomain());
}