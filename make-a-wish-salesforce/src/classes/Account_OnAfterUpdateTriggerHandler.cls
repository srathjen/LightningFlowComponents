/***************************************************************************************************
Author      : MST Solutions
Date        : 10/15/2016
Description : Account_OnAfterUpdateTriggerHandler is used to call the Helper class when the
              account record is get updated.
              
              Modification Log
              ------------------
              WVC-1884    KANAGARAJ  03/04/2018
              
*****************************************************************************************************/
Public class Account_OnAfterUpdateTriggerHandler {
    /*This method is used to call the updateGrantingCaseDevStaffEmail and updateChapterName method when the 
    account record gets updated.*/
    public static void onAfterUpdate(Map<Id,Account> newAccountMap,Map<Id,Account> oldAccountMap){
       
       Constant_AC  constant = new Constant_Ac();
       Id chapterAccountRTId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(constant.chapterRT).getRecordTypeId();
       Id inKindDonorsAccountRTId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('In Kind Donors').getRecordTypeId();
       set<String> accountIdsSet = new set<String>();
       Set<Id> chapterIdsSet = new Set<Id>();
       Map<Id, Id> accWishCoorUpdateMap = new Map<Id, Id>();
       map<id,string> chapterEmailmap = new map<id,string>();
       List<Account> accountList = new List<Account>();
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
        }
        
        // This is used to update wisgrantingcase devstaff email field     
        if(chapterEmailmap.size() > 0){
            Account_OnAfterUpdateTriggerHelper.updateGrantingCaseDevStaffEmai(chapterEmailmap);
        }
        if(chapterIdsSet.size() > 0){
        Account_OnAfterUpdateTriggerHelper.updateChapterName(chapterIdsSet,accountList);
        }
    }
}