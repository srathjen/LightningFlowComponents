/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/27/2016
Description : When a new Relationship record is insert then it will call the OnAfterInsertRelationshipTriggerHelper class based 
on the collection size() > 0.
Modification Log: 
04/18/2018 - Kanagaraj - WVC-1885
*******************************************************************************************************************/

Public class RelationshipOnAfterInsertTriggerHandler{
    
    /*This method is used to update the physician details in contact record and also it will call the 
     corresponding methods based on the conditions.*/
    public static void onAfterInsert(List<npe4__Relationship__c> newRelationShipList){
        set<id> relatedContactId = new set<id>();
        Set<id> relationshipIdSet = new Set<id>();
        Map<Id,String> relationshiptypeMap = new Map<Id,String>();
        List<npe4__Relationship__c> relationShipList = new List<npe4__Relationship__c>();
        
        for(npe4__Relationship__c newRecord : newRelationShipList){
                if(Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null){
                if(newRecord.npe4__Contact__c != Null && newRecord.npe4__Type__c== 'Medical Professional' && newRecord.Qualifying_Medical_Professional__c == true && newRecord.npe4__Status__c == 'Active'){
                        relatedContactId.add(newRecord.npe4__RelatedContact__c);
                    }
                }
                if((newRecord .npe4__Contact__c != Null) && (newRecord .Wish_Participant__c == true || newRecord.Parent_Legal_Guardian__c == true || newRecord.Under_18__c == true)){
                       relationshipIdSet.add(newRecord.npe4__Contact__c );
                       relationShipList.add(newRecord);
                }
                if(newRecord.npe4__Contact__c != Null && newRecord.npe4__RelatedContact__c != Null && newRecord.npe4__Type__c != 'Medical Professional' ){
                    relationshiptypeMap.put(newRecord.npe4__RelatedContact__c,newRecord.npe4__Type__c);
                 }
         }
         
         if(relatedContactId.size() > 0 && RecursiveTriggerHandler.isFirstTime == true || Test.isRunningTest()){
             RelationshipOnAfterInsertTriggerHelper.updatePhysicianDetails(relatedContactId,newRelationShipList);
         }
         if(relationshipIdSet.size() > 0 && RecursiveTriggerHandler.relationShipRecursive == true){
             RelationshipOnAfterInsertTriggerHelper.updateApprovedCase(relationshipIdSet,relationShipList);
         }
         if(relationshiptypeMap.size() > 0){
             RelationshipOnAfterInsertTriggerHelper.updateRelationshipType(relationshiptypeMap);
         }
    }

}