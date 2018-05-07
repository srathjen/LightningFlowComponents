/***************************************************************************************************
Author      : MST Solutions
Date        : 10/15/2016
Description : Account_OnBeforeInsertTriggerHandler is used to call the Helper class when the
              new account record is created.
              
              Modification Log
              ------------------
              WVC-1884    KANAGARAJ  03/04/2018
              
*****************************************************************************************************/
Public class Account_OnBeforeInsertTriggerHandler{
 //When new accoun record is created then it will call the matchChapterForInkindAccount() to populate email for chapter account.
 public static void OnBeforeInsert(List<Account> beforeInsertAccountList){
      Constant_AC  constant = new Constant_AC();
     Id inKindDonorsAccountRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('In Kind Donors').getRecordTypeId();
     Id houseHoldRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get(constant.HouseholdRT).getRecordTypeId();
     Set<Id> ownerIdSet = new Set<Id>();
     List<Account> newInkAccountList = new List<Account>();
     for(Account newAccount : beforeInsertAccountList){
         if(Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null) {
                if(newAccount.RecordTypeId == inKindDonorsAccountRecordTypeId) {
                    ownerIdSet.add(newAccount.OwnerId);
                    newInkAccountList.add(newAccount);
                }
          }
            if(Bypass_Triggers__c.getValues(userInfo.getUserId()) != Null){
                if(newAccount.RecordTypeId == houseHoldRT){
                    newAccount.Migrated_Record__c = true;
                }
            }
     }
     
    if(newInkAccountList.size() > 0) {
              Account_OnBeforeInsertTriggerHelper.matchChapterForInkindAccount(ownerIdSet,newInkAccountList);
    }
}
}