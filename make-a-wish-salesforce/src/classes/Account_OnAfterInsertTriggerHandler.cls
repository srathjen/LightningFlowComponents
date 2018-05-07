/***************************************************************************************************
Author      : MST Solutions
Date        : 10/15/2016
Description : Account_OnAfterInsertTriggerHandler is used to call the Helper class when a
              new account record is created.
              
              Modification Log
              ------------------
              WVC-1884    KANAGARAJ  03/04/2018
              
*****************************************************************************************************/
Public class Account_OnAfterInsertTriggerHandler{
    
    /*This OnAfterInsert() is used to when the chapter account or inkind account record is created then 
    it will store that record into collection then it will pass that collection to another Account_OnAfterInsertTriggerHelper.shareAccountrecord()*/
    public static void OnAfterInsert(List<Account> newAccountList){
    Constant_AC cons = new Constant_AC();
    Id inKindDonorsAccountRTId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('In Kind Donors').getRecordTypeId();
    Id chapterAccountRTId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(cons.chapterRT).getRecordTypeId();
    Set<Id> inKindDonorAccountSet = new Set<Id>();
    Set<Id> chaptterAccountIdSet = new Set<Id> ();
    Set<String> chapterIds = new Set<String>();
    List<Account> newAccountRecList = new List<Account>();
        for(Account inKindAccount : newAccountList)
        {
            if(Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null)
            {    
                if(inKindAccount.RecordTypeId == inKindDonorsAccountRTId && inKindAccount.Chapter_Name__c != Null)
                {
                    chaptterAccountIdSet.add(inKindAccount.Chapter_Name__c);
                    inKindDonorAccountSet.add(inKindAccount.Id);
                }
                
                
            }
            
            if(inKindAccount.RecordTypeId == chapterAccountRTId)
                chapterIds.add(inKindAccount.id);
            else
                chapterIds.add(inKindAccount.Chapter_Name__c);
                
             if(chaptterAccountIdSet.size() > 0 || chapterIds.size() > 0){
                     newAccountRecList.add(inKindAccount);
             }
        }
        
        if(newAccountList.size() > 0){
            Account_OnAfterInsertTriggerHelper.shareAccountrecord(newAccountRecList,chaptterAccountIdSet,chapterIds);
        }
    }
}