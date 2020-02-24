/*****************************************************************************************************************
Author      : MST Solutions
Date        : 07/09/2018
Description : This Handler is used to when the relationship record get deleted then it will aslo delete the corresponding wish form record.
Modification Log: 
07/09/2018 - Kanagaraj - WVC-2082
*******************************************************************************************************************/

public class RelationshipOnBeforeDeleteTriggerHandler{
    
    public static void onBeforeDelete(List<npe4__Relationship__c> OldRelationShipList){
        Set<Id> contactIdSet = new Set<Id>();
        for(npe4__Relationship__c dbOldRelationShipRec : OldRelationShipList){
            contactIdSet.add(dbOldRelationShipRec.npe4__RelatedContact__c);
        }
        
        if(contactIdSet.size() > 0){
            RelationshipOnBeforeDeleteTriggerHelper.deleteWishFormRecord(contactIdSet);
        }
    }
}