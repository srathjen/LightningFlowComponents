/***************************************************************************************************
Author      : MST Solutions
Date        : 10/15/2016
Description : Account_OnAfterUpdateTriggerHandler is used to call the Helper class when the
              account record is get updated.

              Modification Log
              ------------------
              WVC-1884    KANAGARAJ  03/04/2018

*****************************************************************************************************/
public class Account_OnAfterUpdateTriggerHandler {
    /*This method is used to call the updateGrantingCaseDevStaffEmail and updateChapterName method when the
    account record gets updated.*/
    public static void onAfterUpdate(Map<Id,Account> newAccountMap,Map<Id,Account> oldAccountMap){

        Id chapterAccountRTId = Constant_AC.CHAPTER_RT_ID;
        Id inKindDonorsAccountRTId = Constant_AC.IN_KIND_ACCOUNT_ID;
        Id householdAccountId = Constant_AC.HOUSEHOLD_RT_ID;
        Set<String> accountIdsSet = new Set<String>();
        Set<Id> chapterIdsSet = new Set<Id>();
        Set<Id> houseHoldAccountIdsSet = new Set<Id>();
        Map<Id, Id> accWishCoorUpdateMap = new Map<Id, Id>();
        Map<Id, String> chapterEmailmap = new Map<Id, String>();
        List<Account> accountList = new List<Account>();
        List<Account> wishFormAccountList = new List<Account>();
       //This for loop is used to remove inkind account from the public group based on updated chapter name
        for(Account currentAccount : newAccountMap.values())
        {

            if(currentAccount.Wish_Co_ordinator__c != null && currentAccount.Wish_Co_ordinator__c != oldAccountMap.get(currentAccount.Id).Wish_Co_ordinator__c) {
                accWishCoorUpdateMap.put(currentAccount.Id, currentAccount.Wish_Co_ordinator__c);
            }

            if(currentAccount.RecordTypeId == inKindDonorsAccountRTId)
            {
                if(currentAccount.In_Kind_Approval_Status__c == 'Rejected' && oldAccountMap.get(currentAccount.id).In_Kind_Approval_Status__c != 'Rejected') {
                    accountIdsSet.add(currentAccount.id);
                    chapterIdsSet.add(currentAccount.Chapter_Name__c);
                    accountList.add(currentAccount);
                }
                if((currentAccount.Chapter_Name__c != oldAccountMap.get(currentAccount.id).Chapter_Name__c && currentAccount.In_Kind_Approval_Status__c != 'Rejected') ||
                   currentAccount.Chapter_Name__c == Null &&  oldAccountMap.get(currentAccount.id).Chapter_Name__c != NUll){
                       accountIdsSet.add(currentAccount.id);
                       chapterIdsSet.add(oldAccountMap.get(currentAccount.id).Chapter_Name__c);
                       accountList.add(currentAccount);
                   }
            }

            if(currentAccount.RecordTypeId == chapterAccountRTId && currentAccount.DevStaffEmail__c != Null &&
               currentAccount.DevStaffEmail__c != oldAccountMap.get(currentAccount.id).DevStaffEmail__c){
                   chapterEmailmap.put(currentAccount.id, currentAccount.DevStaffEmail__c);
               }

            if(currentAccount.RecordTypeId == householdAccountId && (currentAccount.BillingStreet != oldAccountMap.get(currentAccount.id).BillingStreet || currentAccount.BillingCity != oldAccountMap.get(currentAccount.id).BillingCity || currentAccount.BillingState != oldAccountMap.get(currentAccount.id).BillingState
                                                                      || currentAccount.BillingCountry != oldAccountMap.get(currentAccount.id).BillingCountry || currentAccount.BillingPostalCode != oldAccountMap.get(currentAccount.id).BillingPostalCode)){
                houseHoldAccountIdsSet.add(currentAccount.id);
            }

            if(currentAccount.RecordTypeId == householdAccountId && (currentAccount.Emergency_Contact_Phone__c != oldAccountMap.get(currentAccount.id).Emergency_Contact_Phone__c || currentAccount.Relationship_type__c != oldAccountMap.get(currentAccount.id).Relationship_type__c || currentAccount.Emergency_Contact_Middle_Name__c != oldAccountMap.get(currentAccount.id).Emergency_Contact_Middle_Name__c
                                                                      || currentAccount.Email__c != oldAccountMap.get(currentAccount.id).Email__c) && currentAccount.Hidden_Wish_Form_Id__c != Null){
                    wishFormAccountList.add(currentAccount);
            }
        }

        if(chapterEmailmap.size() > 0){
            Account_OnAfterUpdateTriggerHelper.updateGrantingCaseDevStaffEmail(chapterEmailmap);
        } 
        if(chapterIdsSet.size() > 0){
        Account_OnAfterUpdateTriggerHelper.updateChapterName(chapterIdsSet,accountList);
        }

        if(houseHoldAccountIdsSet.size() > 0){
            Account_OnAfterUpdateTriggerHelper.updateRelatedContactAddressWithHoushold(houseHoldAccountIdsSet);
        }
        if(wishFormAccountList.size() > 0){
        Account_OnAfterUpdateTriggerHelper.updateWishFormRecord(wishFormAccountList);
        }


    }
}