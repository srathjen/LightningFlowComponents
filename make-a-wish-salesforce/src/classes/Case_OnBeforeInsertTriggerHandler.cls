/*****************************************************************************************************************
Author      : MST Solutions
Date        : 5/26/2016
Description : When a new case record is created from Manually or lead convertion then this calss has been called by
theCase_OnBeforeInsertTriggerHandler and we are updating the Dev staff Email Id in this class.
Modification Log: 
23/03/2018 - Sankar - WVC-1835
*******************************************************************************************************************/
Public class Case_OnBeforeInsertTriggerHandler{
    
    Static Constant_AC  constant = new Constant_Ac();   
    Static String parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
    Static String wishGrantRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.wishGrantRT).getRecordTypeId();
    
    /******************************************************************************************************************
This method is called when ever a new case record is created then the value is assigned to the coressponding 
fields in case record.
******************************************************************************************************************/
    public static void OnBeforeInsert(List<Case> beforeInsertCaseList){
        Set<Id> wishOwnerIdSet = new Set<Id>();
        Map<Id,User> wishOwnerMap = new Map<Id,User>();
        map<id,Case> parentChildCaseMap = new map<id,Case>();
        Set<Id> chapterSet = new Set<Id>();
        
        for(Case newCase : beforeInsertCaseList){
            if(Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null && newCase.RecordTypeId == parentWishRecordTypeId) {
                wishOwnerIdSet.add(newCase.OwnerId);
            }
            if(newCase.RecordTypeId == wishGrantRecordTypeId && newCase.ParentId != Null){
                parentChildCaseMap.put(newCase.ParentId,newCase);
            }
            if(newCase.RecordTypeId == parentWishRecordTypeId) {
                chapterSet.add(newCase.ChapterName__c);
            }
            if(!newCase.Rush__c && newCase.RecordTypeId == parentWishRecordTypeId){
                newCase.Rush_Timeframe__c=Null;
                newCase.Rush_Explanation__c=Null;
            }
        }
        
        if(wishOwnerIdSet.size() > 0){
            for(User wishOwner : [SELECT Id,ManagerId,Manager.Name,Manager.Email From User WHERE Id IN: wishOwnerIdSet AND ManagerId != Null LIMIT 50000]){
                wishOwnerMap.put(wishOwner.id,wishOwner);
            }
        }
        
        for(Case newCase : beforeInsertCaseList){
            if(wishOwnerMap.containsKey(newCase.OwnerId) && newCase.RecordTypeId == parentWishRecordTypeId){
                if(wishOwnerMap.get(newCase.OwnerId).ManagerId != Null){
                    newCase.Hidden_Wish_Owner_Manager__c  = wishOwnerMap.get(newCase.OwnerId).Manager.Name;
                    newCase.Hidden_Wish_Owner_Email__c = wishOwnerMap.get(newCase.OwnerId).Manager.Email;
                }
            }
        }
        
        if(parentChildCaseMap.size() > 0 ){
            Case_OnBeforeInsertTriggerHandlerHelper.updateGrantingCaseDevEmail(parentChildCaseMap,parentWishRecordTypeId);
        }
    }
    
}