/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/27/2016
Description : When a new Relationship record is updated then it will call the OnAfterInsertRelationshipTriggerHelper class based 
on the collection size() > 0.
Modification Log: 
04/18/2018 - Kanagaraj - WVC-1885
*******************************************************************************************************************/
Public class RelationshipOnAfterUpdateTriggerHandler{
     
    /*This method is used to once wishchild form get approved then all the relationship record are created then it will update the 
    Update_Wish_Child_Form_Info__c field in case record.*/
    public static void onAfterUpdate(Map<Id,npe4__Relationship__c> newMap,Map<Id,npe4__Relationship__c> oldMap){
        Set<id> relationshipIdSet = new Set<id>();
        List<npe4__Relationship__c> relationShipList = new List<npe4__Relationship__c>();
        for(npe4__Relationship__c newRecord : newMap.Values()){
                    if((newRecord.npe4__Contact__c != Null) && (newRecord.Wish_Participant__c != oldMap.get(newRecord.Id).Wish_Participant__c) || 
                        (newRecord.Parent_Legal_Guardian__c != oldMap.get(newRecord.Id).Wish_Participant__c) || (newRecord.Under_18__c != oldMap.get(newRecord.Id).Wish_Participant__c) || 
                         newRecord.npe4__Type__c != oldMap.get(newRecord.Id).npe4__Type__c){
                           relationshipIdSet.add(newRecord .npe4__Contact__c );
                           relationShipList.add(newRecord);
                    }
         }
         
         if(relationshipIdSet.size() > 0 && RecursiveTriggerHandler.relationShipRecursive == true){
         RelationshipOnAfterInsertTriggerHelper.updateApprovedCase(relationshipIdSet,relationShipList);
         }
    }
}