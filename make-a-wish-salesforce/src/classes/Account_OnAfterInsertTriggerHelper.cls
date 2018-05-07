/***************************************************************************************************
Author      : MST Solutions
Date        : 10/15/2016
Description : Account_OnAfterInsertTriggerHelper is used to call the Helper class when a
              new account record is created.
              
              Modification Log
              ------------------
              WVC-1884    KANAGARAJ  03/04/2018
              
*****************************************************************************************************/
public class Account_OnAfterInsertTriggerHelper{
    /*This shareAccountrecord() is used to share the account records to public group based on the chapter and state*/
    public static void shareAccountrecord(List<Account> newAccountList,set<Id> chaptterAccountIdSet,set<String> chapterIds){
        Constant_AC cons = new Constant_AC();
        Id chapterAccountRTId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(cons.chapterRT).getRecordTypeId();
        Id inKindDonorsAccountRTId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('In Kind Donors').getRecordTypeId();
        Id groupId;
        Map<Id,Id> chaptterMap = new Map<Id,Id>();
        Map<Id,Id> volunteerManagersMap = new map<Id,Id>();
        Map<Id, String> chapterNameMap = new Map<Id, String>();
        Map<String,List<Account>> accountMapforSharing = new Map<String, List<Account>>();
        Map<String,Id> publicGroupMap = new Map<String,Id>();
        List<AccountShare> accountShareList = New List<AccountShare>();
        try{
        for(Account daAccount : [SELECT Id,Name,Wish_Co_ordinator__c, OwnerId,Owner.UserRole.Name,Owner.ContactId,Volunteer_Manager__c,RecordTypeId,Chapter_Name__c,
                                     Chapter_Name__r.Name  FROM Account WHERE (Id IN: chaptterAccountIdSet OR 
                                                                               (Chapter_Name__c IN :chapterIds AND Id IN :Trigger.newMap.keySet())) LIMIT 50000])
            {
                
                if(daAccount.RecordTypeId == chapterAccountRTId){
                    chaptterMap.put(daAccount.Id,daAccount.Wish_Co_ordinator__c);
                    volunteerManagersMap.put(daAccount.Id,daAccount.Volunteer_Manager__c);
                    String chapterNameTrim = daAccount.Name.removeStart('Make-A-Wish ');
                    chapterNameMap.put(daAccount.Id, chapterNameTrim);
                }
                
                else
                {
                    if(daAccount.Owner.userRole.Name == 'National Staff' ) //|| (daAccount.RecordTypeId == inKindDonorsAccountRTId && daAccount.Owner.ContactId != Null)
                    {
                        if(accountMapforSharing.containsKey(daAccount.Chapter_Name__r.Name))
                        {
                            accountMapforSharing.get(daAccount.Chapter_Name__r.Name).add(daAccount);
                        }
                        else
                            accountMapforSharing.put(daAccount.Chapter_Name__r.Name, new List<Account>{daAccount}); 
                    }
                }
            }
           if(chapterNameMap.size() > 0){
            for(Group currentGroup : [SELECT Id, Name FROM Group WHERE Type = 'Regular' AND Name IN: chapterNameMap.values() LIMIT 50000]){
                publicGroupMap.put(currentGroup.Name, currentGroup.id);
            }
        }
        
        if(chaptterMap.size() > 0)
        {    
            for(Account inKindAccount : newAccountList){
                if(Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null)
                {   
                    if(inKindAccount.RecordTypeId == inKindDonorsAccountRTId)
                    {
                        
                        if(chaptterMap.containsKey(inKindAccount.Chapter_Name__c) && !String.isEmpty(chaptterMap.get(inKindAccount.Chapter_Name__c))){
                            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                            req.setComments('Submitting request for approval');
                            req.setObjectId(inKindAccount.id);
                            req.setProcessDefinitionNameOrId('Account_In_Kind_Donors_Approval');
                            req.setNextApproverIds(new Id[]{chaptterMap.get(inKindAccount.Chapter_Name__c)});
                            req.setSkipEntryCriteria(true);
                            Approval.ProcessResult result = Approval.process(req);
                        }
                        else{
                            inKindAccount.addError('There is no wish co-ordinator to approve this record');
                        }
                        
                        if(chapterNameMap.containsKey(inkindAccount.Chapter_Name__c)) 
                        {    
                            if( publicGroupMap.containsKey(chapterNameMap.get(inkindAccount.Chapter_Name__c)))
                            {    
                                groupId = publicGroupMap.get(chapterNameMap.get(inkindAccount.Chapter_Name__c));
                                AccountShare dynamicAccountShare  = new AccountShare();
                                dynamicAccountShare.AccountId = inkindAccount.Id;
                                dynamicAccountShare.Accountaccesslevel = 'Read';
                                dynamicAccountShare.CaseAccessLevel = 'None';
                                dynamicAccountShare.ContactAccessLevel = 'None';
                                dynamicAccountShare.OpportunityAccessLevel = 'None';
                                dynamicAccountShare.UserOrGroupId = groupId;
                                accountShareList.add(dynamicAccountShare); 
                                
                            }
                        }                    
                    }  
                }
            }
            
            if(!accountShareList.isEmpty()){
                
                Insert accountShareList;
            }
            
        }  
        if(accountMapforSharing.size() > 0)
          ChapterStaffRecordSharing_AC.AccountSharing(accountMapforSharing);
    }
    
     catch(Exception ex){
       for(Account currRec : newAccountList){
             ErrorMessage_AC.createdebugRec('Account_OnAfterInsertTriggerHelper',String.valueof(currRec),String.valueOf(ex.getCause()),'shareAccountrecord',currRec.Id,ex.getStackTraceString(),'Error');
            }
       for(Account currRec : newAccountList){
             currRec.addError(Label.Debug_log_error_message);
           }
        }
        }
}