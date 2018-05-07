/***************************************************************************************************
Author      : MST Solutions
Date        : 10/15/2016
Description : Account_OnBeforeInsertTriggerHandlerHelper is used to call the Helper class when the
              new account record is created.
              
              Modification Log
              ------------------
              WVC-1884    KANAGARAJ  03/04/2018
              
*****************************************************************************************************/
Public class Account_OnBeforeInsertTriggerHelper
{
 //Used to populate chaptername and chapter email
    public static void matchChapterForInkindAccount(Set<Id> ownerIdSet, List<Account> newInkAccountList) {
        Map<Id, Account> chapterMap = new Map<Id, Account>();
        Map<Id, Id> ownerChapterMap = new Map<Id, Id>();
        Map<String, Id> nonPortalChapterMap = new Map<String, Id>();
        Map<Id, String> ownerNoPortalMap = new Map<Id, String>();
        try{
        for(Account chapterInfo : [SELECT Id, Name, Wish_Co_ordinator__r.Email FROM Account WHERE RecordType.Name = 'Chapter' Limit 50000]) {
            chapterMap.put(chapterInfo.Id, chapterInfo);
            nonPortalChapterMap.put(chapterInfo.Name.remove('Make-A-Wish ')+' - Chapter', chapterInfo.Id);
        }
        
        for(User checkUserType : [SELECT Id, ContactId, UserRole.Name, contact.AccountId FROM User WHERE Id IN : ownerIdSet Limit 50000]) {
            if(checkUserType.ContactId != NULL) {
                //For portal user
                ownerChapterMap.put(checkUserType.Id, checkUserType.Contact.AccountId);
            } else if(checkUserType.UserRole.Name != NULL && checkUserType.UserRole.Name != 'National Staff') {
                //For non portal user
                ownerNoPortalMap.put(checkUserType.Id, checkUserType.UserRole.Name);
            }
            
        }
        
        for(Account matchChapter : newInkAccountList) {
            if(ownerChapterMap.containsKey(matchChapter.OwnerId)) {
                if(chapterMap.containsKey(ownerChapterMap.get(matchChapter.OwnerId))) {
                    matchChapter.Wish_Co_ordinator_Hidden_Email__c = chapterMap.get(ownerChapterMap.get(matchChapter.OwnerId)).Wish_Co_ordinator__r.Email;
                    matchChapter.Chapter_Name__c = chapterMap.get(ownerChapterMap.get(matchChapter.OwnerId)).Id;
                }
            } else if(ownerNoPortalMap.containsKey(matchChapter.OwnerId)) {
                if(nonPortalChapterMap.containsKey(ownerNoPortalMap.get(matchChapter.OwnerId))) {
                    matchChapter.Wish_Co_ordinator_Hidden_Email__c = chapterMap.get(nonPortalChapterMap.get(ownerNoPortalMap.get(matchChapter.OwnerId))).Wish_Co_ordinator__r.Email;
                    matchChapter.Chapter_Name__c = nonPortalChapterMap.get(ownerNoPortalMap.get(matchChapter.OwnerId));
                }
            } else if(matchChapter.Chapter_Name__c == NULL && !ownerNoPortalMap.containsKey(matchChapter.OwnerId) && !ownerChapterMap.containsKey(matchChapter.OwnerId)) {
                matchChapter.addError('Please select Chapter Name');
            }
        }
    }
    catch(Exception ex){
       for(Account currRec : newInkAccountList){
             ErrorMessage_AC.createdebugRec('Account_OnBeforeInsertTriggerHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'matchChapterForInkindAccount',currRec.Id,ex.getStackTraceString(),'Error');
            }
       for(Account currRec : newInkAccountList){
             currRec.addError(Label.Debug_log_error_message);
           }
        }
    }
}