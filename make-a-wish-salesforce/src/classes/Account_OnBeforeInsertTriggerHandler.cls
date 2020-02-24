/***************************************************************************************************
Author      : MST Solutions
Date        : 10/15/2016
Description : Account_OnBeforeInsertTriggerHandler is used to call the Helper class when the
              new account record is created.
              
              Modification Log
              ------------------
              WVC-1884    KANAGARAJ  03/04/2018
              
*****************************************************************************************************/
public class Account_OnBeforeInsertTriggerHandler{
 //When new accoun record is created then it will call the matchChapterForInkindAccount() to populate email for chapter account.
 public static void OnBeforeInsert(List<Account> beforeInsertAccountList){
     Id inKindDonorsAccountRecordTypeId = Constant_AC.IN_KIND_ACCOUNT_ID;
     Id houseHoldRT = Constant_AC.HOUSEHOLD_RT_ID;
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