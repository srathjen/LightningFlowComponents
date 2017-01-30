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
    
    //After insert trigger to fire the approval process once inkind donor account is created and sahre the record to group based on the chapter name
    if(trigger.isAfter && trigger.isInsert)
    {   
        Set<Id> chaptterAccountIdSet = new Set<Id> ();
        Set<Id> inKindDonorAccountSet = new Set<Id>();
        Map<Id,Id> chaptterMap = new Map<Id,Id>();
        Map<Id,Id> volunteerManagersMap = new map<Id,Id>();
        Constant_AC cons = new Constant_AC();
        Map<Id, String> chapterNameMap = new Map<Id, String>();
        Map<String,Id> publicGroupMap = new Map<String,Id>();
        List<AccountShare> accountShareList = New List<AccountShare>();
        Id groupId;
        Id inKindDonorsAccountRTId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('In Kind Donors').getRecordTypeId();
        Id chapterAccountRTId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(cons.chapterRT).getRecordTypeId();
        for(Account inKindAccount : trigger.new)
        {
            if(inKindAccount.Migrated_Record__c != True)
            {    
                if(inKindAccount.RecordTypeId == inKindDonorsAccountRTId && inKindAccount.Chapter_Name__c != Null){
                    chaptterAccountIdSet.add(inKindAccount.Chapter_Name__c);
                    inKindDonorAccountSet.add(inKindAccount.Id);
                }
            }
        }
        
        if(chaptterAccountIdSet.size() > 0)
        {
            for(Account daAccount : [SELECT Id,Name,Wish_Co_ordinator__c, Volunteer_Manager__c,RecordTypeId  FROM Account WHERE Id IN: chaptterAccountIdSet AND RecordTypeId =: chapterAccountRTId ]){
                chaptterMap.put(daAccount.Id,daAccount.Wish_Co_ordinator__c);
                volunteerManagersMap.put(daAccount.Id,daAccount.Volunteer_Manager__c);
                String chapterNameTrim = daAccount.Name.removeStart('Make-A-Wish ');
                chapterNameMap.put(daAccount.Id, chapterNameTrim);
            }
        }
        
        Set<Id> inKindDonorAccountWithChildRecords = new Set<Id>();
        for(Group currentGroup : [SELECT Id, Name FROM Group WHERE Type = 'Regular' AND Name IN: chapterNameMap.values()]){
            publicGroupMap.put(currentGroup.Name, currentGroup.id);
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
                    
                    if(chapterNameMap.containsKey(inkindAccount.Chapter_Name__c)) 
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
            
            if(!accountShareList.isEmpty()){
                
                Insert accountShareList;
            }
            
        }  
    }
    
    //After update trigger is used to remove the access from the group if the record was rejected based on the chapter name
    if(trigger.isAfter && trigger.isUpdate)
    {
        List<AccountShare> accountShareList = New List<AccountShare>();
        List<AccountShare> updateAccountShareList = New List<AccountShare>();
        Id inKindDonorsAccountRTId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('In Kind Donors').getRecordTypeId();
        Id chapterId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Chapter').getRecordTypeId();
        Constant_AC  constant = new Constant_Ac();
        Id parentWishRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(constant.parentWishRT).getRecordTypeId();
        String groupName;
        id groupId;
        set<String> accountIdsSet = new set<String>();
        map<string,id> publicGroupMap = new map<string,id>();
        Set<Id> chapterIdsSet = new Set<Id>();
        Set<Id> checkForChildRecordSet = new Set<Id>();
        Map<Id, Id> accWishCoorUpdateMap = new Map<Id, Id>();
        Map<Id, String> chapterNameMap = new Map<Id, String>();
        
        //This for loop is used to remove inkind account from the public group based on updated chapter name          
        for(Account currentAccount : trigger.new)
        {
            if(currentAccount.Wish_Co_ordinator__c != null && currentAccount.Wish_Co_ordinator__c != Trigger.oldMap.get(currentAccount.Id).Wish_Co_ordinator__c) {
                accWishCoorUpdateMap.put(currentAccount.Id, currentAccount.Wish_Co_ordinator__c);
            }
            
            if(currentAccount.RecordTypeId == inKindDonorsAccountRTId && currentAccount.Chapter_Name__c != Null && currentAccount.migrated_Record__c != True)
            {
                if(currentAccount.In_Kind_Approval_Status__c == 'Rejected' && Trigger.oldMap.get(currentAccount.id).In_Kind_Approval_Status__c != 'Rejected') {
                    accountIdsSet.add(currentAccount.id);
                    chapterIdsSet.add(currentAccount.Chapter_Name__c);
                }
                if(currentAccount.Chapter_Name__c != trigger.oldMap.get(currentAccount.id).Chapter_Name__c && currentAccount.In_Kind_Approval_Status__c != 'Rejected'){
                    accountIdsSet.add(currentAccount.id);
                    chapterIdsSet.add(trigger.oldMap.get(currentAccount.id).Chapter_Name__c);
                    
                }
            }
        }
        
        if(accWishCoorUpdateMap.size() > 0) {
            List<Case> caseOwnerUpdateList = new List<Case>();
            for(Case parentCase : [SELECT Id, OwnerId, ChapterName__c FROM Case WHERE isClosed = false AND RecordTypeId =: parentWishRecordTypeId AND ChapterName__c IN : accWishCoorUpdateMap.keySet()]) {
                parentCase.OwnerId = accWishCoorUpdateMap.get(parentCase.ChapterName__c);
                caseOwnerUpdateList.add(parentCase);
            }
            if(caseOwnerUpdateList.size() > 0) {
                //update caseOwnerUpdateList;
            }
        }
        
        if(chapterIdsSet.size() > 0){
            for(Account getAccountName : [SELECT Id, Name FROM Account WHERE RecordTypeId =: chapterId]){
                String chapterNameTrim = getAccountName.Name.removeStart('Make-A-Wish ');
                chapterNameMap.put(getAccountName.Id, chapterNameTrim);
            }
        }
        
        
        for(Group currentGroup : [SELECT Id, Name FROM Group WHERE Type = 'Regular']){
            publicGroupMap.put(currentGroup.Name, currentGroup.id);
        }
        if(accountIdsSet.size() > 0 && publicGroupMap.size() > 0 ){
            accountShareList = [SELECT Id,AccountId,UserOrGroupId FROM AccountShare WHERE AccountId IN: accountIdsSet AND UserOrGroupId IN: publicGroupMap.values()];
        }
        
        if(accountShareList.size() > 0 ){
            delete accountShareList;
        }
        
        //This for loop is used to add inkind account to the public group based on new updated chapter name          
        for(Account newInkind : trigger.new){
            if(newInkind.Chapter_Name__c != trigger.oldMap.get(newInkind.id).Chapter_Name__c){
                if(chapterNameMap.containsKey(newInkind.Chapter_Name__c)) 
                {    
                    if( publicGroupMap.containsKey(chapterNameMap.get(newInkind.Chapter_Name__c)))
                    {    
                        groupId = publicGroupMap.get(chapterNameMap.get(newInkind.Chapter_Name__c));
                        AccountShare dynamicAccountShare  = new AccountShare();
                        dynamicAccountShare.AccountId = newInkind.Id;
                        dynamicAccountShare.Accountaccesslevel = 'Read';
                        dynamicAccountShare.CaseAccessLevel = 'Read';
                        dynamicAccountShare.ContactAccessLevel = 'Read';
                        dynamicAccountShare.OpportunityAccessLevel = 'Read';
                        dynamicAccountShare.UserOrGroupId = groupId;
                        updateAccountShareList.add(dynamicAccountShare);
                        
                    }
                }
            }
            
        }
        
        if(!updateAccountShareList.isEmpty()){
            
            Insert updateAccountShareList;
        }
        
        
    }
    
}