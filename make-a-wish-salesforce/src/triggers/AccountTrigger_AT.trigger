/***************************************************************************************************
Author      : MST Solutions
Date        : 10/15/2016
Description : AccountTrigger_AT is used to assign the chapter account name for inkind account when volunteer creates inkind account.
After insert In-Kind account it is automatically send for approval to wish co-ordinator of the associated chapter
*****************************************************************************************************/
trigger AccountTrigger_AT on Account (before insert,after insert,after update) {
    //Before insert update wish co-ordinator email value to the hidden field to send emai alert
    if(trigger.isBefore && trigger.isInsert)
    {
        string userId = UserInfo.getUserId();
        string contactId;
        list<User> userList = [SELECT Id,ContactId FROM User WHERE Id =: userId AND ContactId != Null limit 1];
        list<Contact> contactList;
        if(userList.Size() == 1){
            contactId = userList[0].ContactId;
            contactList = [SELECT ID,AccountId,Account.Wish_Co_ordinator__c FROM Contact WHERE ID =: contactId];
        }
        set<id> chapterAccountIdsSet = new set<id>();
        map<id,string> chapterMap = new map<id,string>();
        Id inKindDonorsAccountRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('In Kind Donors').getRecordTypeId();
        for(Account currentAccount : Trigger.new){
            if(currentAccount.Migrated_Record__c != True)
            {
                if(contactId != Null){
                    currentAccount.Chapter_Name__c = contactList[0].AccountId;
                }
                if(currentAccount.RecordTypeId == inKindDonorsAccountRecordTypeId && currentAccount.Chapter_Name__c != Null){
                    
                    chapterAccountIdsSet.add(currentAccount.Chapter_Name__c);
                } 
            }
        }
        if(chapterAccountIdsSet.size() > 0){
            for(Account chapterAccount : [SELECT Id,Wish_Co_ordinator__c,Wish_Co_ordinator__r.Email FROM Account WHERE Id IN: chapterAccountIdsSet AND Wish_Co_ordinator__c != Null]){
                chapterMap.put(chapterAccount.Id,chapterAccount.Wish_Co_ordinator__r.Email);
            }
        }
        
        for(Account inKindAccount : trigger.new){
            if(inKindAccount.Migrated_Record__c != True)
            {
                if(inKindAccount.RecordTypeId == inKindDonorsAccountRecordTypeId && inKindAccount.Chapter_Name__c != Null && chapterMap.containsKey(inKindAccount.Chapter_Name__c)){
                    inKindAccount.Wish_Co_ordinator_Hidden_Email__c = chapterMap.get(inKindAccount.Chapter_Name__c);
                }
            }
        }
        
    }
    
    //After insert trigger to fire the approval process once inkind donor account is created
    if(trigger.isAfter && trigger.isInsert)
    {
        Set<Id> chaptterAccountIdSet = new Set<Id> ();
        Set<Id> inKindDonorAccountSet = new Set<Id>();
        Map<Id,Id> chaptterMap = new Map<Id,Id>();
        Map<Id,Id> volunteerManagersMap = new map<Id,Id>();
        Id inKindDonorsAccountRTId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('In Kind Donors').getRecordTypeId();
        
        for(Account inKindAccount : trigger.new)
        {
            if(inKindAccount.Migrated_Record__c != True)
            {   
                if(inKindAccount.RecordTypeId == inKindDonorsAccountRTId){
                    chaptterAccountIdSet.add(inKindAccount.Chapter_Name__c);
                    inKindDonorAccountSet.add(inKindAccount.Id);
                }
            }
        }
        
        if(chaptterAccountIdSet.size() > 0)
        {
            
            for(Account daAccount : [SELECT Id,Wish_Co_ordinator__c, Volunteer_Manager__c,RecordTypeId  FROM Account WHERE Id IN: chaptterAccountIdSet AND RecordTypeId =: inKindDonorsAccountRTId ]){
                chaptterMap.put(daAccount.Id,daAccount.Wish_Co_ordinator__c);
                volunteerManagersMap.put(daAccount.Id,daAccount.Volunteer_Manager__c);
            }
        }
        
        Set<Id> inKindDonorAccountWithChildRecords = new Set<Id>();
        
        if(inKindDonorAccountSet.size() > 0)
        {
            for(In_Kind_Donation_Reimbursement__c inKindRecordCheck : [SELECT Id, In_Kind_Donor_Name__c FROM In_Kind_Donation_Reimbursement__c WHERE In_Kind_Donor_Name__c IN :inKindDonorAccountSet]) {
                inKindDonorAccountWithChildRecords.add(inKindRecordCheck.In_Kind_Donor_Name__c);
            }
        }
        
        
        if(chaptterMap.size() > 0)
        {
            for(Account inKindAccount : trigger.new){
                
                if(inKindAccount.Migrated_Record__c != True)
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
                        inKindAccount.addError('There is no Wis Co-ordinator to approve this record');
                        
                    }
                }
            }
        }
    }
    
    if(trigger.isAfter && trigger.isUpdate)
    {
        List<AccountShare> accountShareList = New List<AccountShare>();
        Id inKindDonorsAccountRTId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('In Kind Donors').getRecordTypeId();
        Id chapterId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Chapter').getRecordTypeId();
        String groupName;
        id groupId;
        List<Account> accountList = new List<Account>();
        map<string,id> publicGroupMap = new map<string,id>();
        Set<Id> chapterIdsSet = new Set<Id>();
        Set<Id> checkForChildRecordSet = new Set<Id>();
        
        for(Account currentAccount :trigger.new)
        {
            if(currentAccount.RecordTypeId == inKindDonorsAccountRTId && currentAccount.Chapter_Name__c != Null 
               && currentAccount.migrated_Record__c != True)
            {
                if(currentAccount.In_Kind_Approval_Status__c == 'Rejected' && Trigger.oldMap.get(currentAccount.id).In_Kind_Approval_Status__c != 'Rejected') {
                    checkForChildRecordSet.add(currentAccount.Id);
                    accountList.add(currentAccount);
                }
            }
        }
        
        Set<Id> inKindDonorAccountWithChildRecords = new Set<Id>();
        if(checkForChildRecordSet.size() > 0)
        {        
            for(In_Kind_Donation_Reimbursement__c inKindRecordCheck : [SELECT Id, In_Kind_Donor_Name__c FROM In_Kind_Donation_Reimbursement__c WHERE In_Kind_Donor_Name__c IN : checkForChildRecordSet]) {
                inKindDonorAccountWithChildRecords.add(inKindRecordCheck.In_Kind_Donor_Name__c);
            }
        }
        
        Map<Id, String> chapterNameMap = new Map<Id, String>();
        for(Account getAccountName : [SELECT Id, Name FROM Account WHERE RecordTypeId =: chapterId]){
            String chapterNameTrim = getAccountName.Name.removeStart('Make-A-Wish ');
            chapterNameMap.put(getAccountName.Id, chapterNameTrim);
        }
        List<Id> deleteRejectedAccountList = new List<Id>();
        for(Account deleteAccount : accountList) {
            if(!inKindDonorAccountWithChildRecords.contains(deleteAccount.Id)) {
                deleteRejectedAccountList.add(deleteAccount.Id);
            }
        }
        
        if(deleteRejectedAccountList.size() > 0) {
            Database.delete(deleteRejectedAccountList);
        }
        for(Group currentGroup : [SELECT Id, Name FROM Group WHERE Type = 'Regular']){
            publicGroupMap.put(currentGroup.Name, currentGroup.id);
        }
        for(Account inkindAccount : trigger.new)
        {
            if(inkindAccount.migrated_Record__c != True)
            { 
                if(chapterNameMap.containsKey(inkindAccount.Chapter_Name__c) && inkindAccount.In_Kind_Approval_Status__c == 'Approved' 
                   && Trigger.oldMap.get(inkindAccount.id).In_Kind_Approval_Status__c != 'Approved')
                {
                    if( publicGroupMap.containsKey(chapterNameMap.get(inkindAccount.Chapter_Name__c)))
                    {
                        groupId = publicGroupMap.get(chapterNameMap.get(inkindAccount.Chapter_Name__c));
                        AccountShare dynamicAccountShare  = new AccountShare();
                        dynamicAccountShare.AccountId = inkindAccount.Id;
                        dynamicAccountShare.Accountaccesslevel = 'Read';
                        dynamicAccountShare.CaseAccessLevel = 'Read';
                        dynamicAccountShare.ContactAccessLevel = 'Read';
                        dynamicAccountShare.OpportunityAccessLevel = 'Read';
                        dynamicAccountShare.UserOrGroupId = groupId;
                        accountShareList.add(dynamicAccountShare);
                        
                    }
                }
            }
        }
        
        if(!accountShareList.isEmpty())
            Insert accountShareList;
    }
    
}