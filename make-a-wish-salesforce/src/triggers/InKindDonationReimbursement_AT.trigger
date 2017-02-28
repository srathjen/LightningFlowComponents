/***************************************************************************************************
Author      : MST Solutions
CreatedBy   : Chandrasekar
Date        : 4/10/2016
Description : This trigger us used to fetch the associated case owner,case owner's manager and current loged in user details
****************************************************************************************************/
trigger InKindDonationReimbursement_AT on In_Kind_Donation_Reimbursement__c (before insert,before update) {
    
    List<Contact> volunteerContactList = new List<Contact>();
    List<User> volunteerUserList = new List<User>();
    Constant_AC newConstant =  new Constant_AC();
    Id reImbursementRtId = Schema.Sobjecttype.In_Kind_Donation_Reimbursement__c.getRecordTypeInfosByName().get(newConstant.Reimbursement).getRecordTypeId();
    if(trigger.isBefore && trigger.isInsert){
        set<string> wishIdsSet = new set<string>();
        map<id,id> wishOwnerMap = new map<id,id>();
        map<id,id> wishManagerMap = new map<id,id>();
        Id inKindRtId = Schema.Sobjecttype.In_Kind_Donation_Reimbursement__c.getRecordTypeInfosByName().get(newConstant.InKind).getRecordTypeId();
        for(In_Kind_Donation_Reimbursement__c newRecord : trigger.new){
            if(newRecord.Wish__c != Null ){
                wishIdsSet.add(newRecord.Wish__c);
            }
            
            
            if(wishIdsSet.size()>0){
                for(Case newCase : [SELECT Id,ownerId FROM Case WHERE Id IN:wishIdsSet ]){
                    wishOwnerMap.put(newCase.Id, newCase.OwnerId);
                }
            }
            if(wishOwnerMap.size()>0){
                for(User getManager: [Select Id,ManagerId FROM User Where Id IN:wishOwnerMap.values()]){
                    wishManagerMap.put(getManager.Id, getManager.ManagerId);
                }
            }
            
            if(wishManagerMap.size()>0){
                for(In_Kind_Donation_Reimbursement__c newReImburse : trigger.new){
                    if(newReImburse.Wish__c != Null && wishOwnerMap.containsKey(newReImburse.Wish__c)){
                        newReImburse.Wish_Owner__c = wishOwnerMap.get(newReImburse.Wish__c);
                        if(wishManagerMap.containsKey(newReImburse.Wish_Owner__c))
                            newReImburse.Wish_Owner_s_Manager__c = wishManagerMap.get(newReImburse.Wish_Owner__c);
                    }
                }
            }
        }
    }
        //Before update trigger is used fetch the associated case owner,case owner's manager and update with In-Kind record
    if(trigger.isbefore && trigger.isUpdate){
        set<string> wishIdsSet = new set<string>();
        map<id,id> wishOwnerMap = new map<id,id>();
        map<id,id> wishManagerMap = new map<id,id>();
        for(In_Kind_Donation_Reimbursement__c inkindReimburse : trigger.new){
            if(inkindReimburse.Wish__c != Null && trigger.oldMap.get(inkindReimburse.id).Wish__c != inkindReimburse.Wish__c){
                wishIdsSet.add(inkindReimburse.Wish__c);
            }
            
            if(wishIdsSet.size()>0){
                for(Case newCase : [SELECT Id,ownerId FROM Case WHERE Id IN:wishIdsSet ]){
                    wishOwnerMap.put(newCase.Id, newCase.OwnerId);
                }
            }
            if(wishOwnerMap.size()>0){
                for(User getManager: [Select Id,ManagerId FROM User Where Id IN:wishOwnerMap.values()]){
                    wishManagerMap.put(getManager.Id, getManager.ManagerId);
                }
            }
            
            if(wishManagerMap.size()>0){
                for(In_Kind_Donation_Reimbursement__c newReImburse : trigger.new){
                    if(newReImburse.Wish__c != Null && wishOwnerMap.containsKey(newReImburse.Wish__c)){
                        newReImburse.Wish_Owner__c = wishOwnerMap.get(newReImburse.Wish__c);
                        if(wishManagerMap.containsKey(newReImburse.Wish_Owner__c))
                            newReImburse.Wish_Owner_s_Manager__c = wishManagerMap.get(newReImburse.Wish_Owner__c);
                    }
                }
            }
            
        }
        
    }
}