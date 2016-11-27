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
        list<User> userList = [SELECT Id,ContactId,Contact.Name,Contact.FirstName,Contact.LastName,City,State,Street,Country,PostalCode FROM User WHERE Id =: UserInfo.getUserId() AND ContactId != Null limit 1];
        set<string> wishIdsSet = new set<string>();
        map<id,id> wishOwnerMap = new map<id,id>();
        map<id,id> wishManagerMap = new map<id,id>();
        Id inKindRtId = Schema.Sobjecttype.In_Kind_Donation_Reimbursement__c.getRecordTypeInfosByName().get(newConstant.InKind).getRecordTypeId();
        for(In_Kind_Donation_Reimbursement__c newRecord : trigger.new){
            if(newRecord.Wish__c != Null ){
                wishIdsSet.add(newRecord.Wish__c);
            }
            if(userList.size()>0 && newRecord.Make_check_payable_to_me__c == True && newRecord.RecordTypeId == reImbursementRtId){
                newRecord.Volunteer_Name__c = userList[0].Contact.Name;
                newRecord.Login_Users_City__c =  userList[0].City;
                newRecord.login_users_State__c = userList[0].State;
                newRecord.Login_users_Street__c = userList[0].Street;
                newRecord.Login_users_Zip__c = userList[0].PostalCode;
                newRecord.Country__c = userList[0].Country;
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
    //Before update trigger is used to update the current login user details if make check payable to me is checked
    if(trigger.isbefore && trigger.isUpdate){
        list<User> userList = [SELECT Id,ContactId,Contact.Name,Contact.FirstName,Contact.LastName,City,State,Street,Country,PostalCode FROM User WHERE Id =: UserInfo.getUserId() AND ContactId != Null limit 1];
        for(In_Kind_Donation_Reimbursement__c inkindReimburse : trigger.new){
            if(inkindReimburse.Make_check_payable_to_me__c == true && trigger.oldMap.get(inkindReimburse.id).Make_check_payable_to_me__c != true && inkindReimburse.RecordTypeId == reImbursementRtId){
                inkindReimburse.Volunteer_Name__c = userList[0].Contact.Name;
                inkindReimburse.Login_users_Street__c =  userList[0].Street;
                inkindReimburse.Login_Users_City__c = userList[0].City;
                inkindReimburse.login_users_State__c = userList[0].State;
                inkindReimburse.Country__c =  userList[0].Country;
                inkindReimburse.Login_users_Zip__c = userList[0].PostalCode;
                
                
            }
        }
        
    }
}