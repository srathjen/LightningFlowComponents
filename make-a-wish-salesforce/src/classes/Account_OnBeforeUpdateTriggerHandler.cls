/***************************************************************************************************
Author      : MST Solutions
Date        : 10/15/2016
Description : Account_OnBeforeUpdateTriggerHandler is used to call the Helper class when the
              account record is get updated.
              
              Modification Log
              ------------------
              WVC-1884    KANAGARAJ  03/04/2018
              
*****************************************************************************************************/
Public class Account_OnBeforeUpdateTriggerHandler{
    
    /*This onBeforeUpdate() is used to update the billing Address verified field and shipping address verified field
    when Billing address or shipping address field values are update.*/
    public static void onBeforeUpdate(Map<Id,Account> newAccountMap,Map<Id,Account> oldAccountMap){
         
        Constant_AC cons = new Constant_AC();
        Id housHoldAccountRTId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(cons.HouseholdRT).getRecordTypeId();
        Id wishChildRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(cons.contactWishChildRT).getRecordTypeId();
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id,Id> wishChildMap = new Map<Id,Id>();
        List<Account> primaryContactUpdateList = new List<Account>();
        
        for(Account newAccount : newAccountMap.Values()){
            if(newAccount.RecordTypeId == housHoldAccountRTId && (Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null)){
                accountIdSet.add(newAccount.Id);
            }
            // the billing address is already marked as verified and one of the shipping address fields changed
            if(Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null && (newAccount.BillingStreet != oldAccountMap.get(newAccount.Id).BillingStreet ||
                newAccount.BillingState != oldAccountMap.get(newAccount.Id).BillingState ||
                newAccount.BillingStateCode != oldAccountMap.get(newAccount.Id).BillingStateCode ||
                newAccount.BillingCity != oldAccountMap.get(newAccount.Id).BillingCity ||
                newAccount.BillingPostalCode != oldAccountMap.get(newAccount.Id).BillingPostalCode)){
                  
                  newAccount.BillingAddressVerified__c = false;
                  newAccount.BillingAddressVerificationAttempted__c = null;
                  
              }
              
              // the shipping address is already marked as verified and one of the shipping address fields changed
            if(Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null && (newAccount.ShippingStreet != oldAccountMap.get(newAccount.Id).ShippingStreet ||
                newAccount.ShippingState != oldAccountMap.get(newAccount.Id).ShippingState ||
                newAccount.ShippingStateCode != oldAccountMap.get(newAccount.Id).ShippingStateCode ||
                newAccount.ShippingCity != oldAccountMap.get(newAccount.Id).ShippingCity ||
                newAccount.ShippingPostalCode != oldAccountMap.get(newAccount.Id).ShippingPostalCode)){
                  
                  newAccount.ShippingAddressVerified__c = false;
                  newAccount.ShippingAddressVerificationAttempted__c = null;
                  
              }
        }
        
        if(accountIdSet.size() > 0){
            for(contact dbWishChild : [SELECT Id,Name,AccountId,RecordTypeId FROM Contact WHERE AccountId IN :accountIdSet AND RecordTypeId =: wishChildRT Limit 1]){
                wishChildMap.put(dbWishChild.AccountId,dbWishChild.Id);
            }
        }
        
        if(wishChildMap.size() > 0){
            for(Account newAccount : newAccountMap.Values()){
               if(newAccount.RecordTypeId == housHoldAccountRTId && wishChildMap.containsKey(newAccount.Id) &&  (Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null)){
                    newAccount.npe01__One2OneContact__c = wishChildMap.get(newAccount.Id);
                }
            }
            
        }
    }
}