trigger AccountTrigger_AT on Account (before insert,after insert,after update) {
    
    
    //Before insert update wish co-ordinator email value to the hidden field to send emai alert
    if(trigger.isBefore && trigger.isInsert){
        string userId = UserInfo.getUserId();
        string contactId;
        list<User> userList = [SELECT Id,ContactId FROM User WHERE Id =: userId AND ContactId != Null limit 1];
        if(userList.Size() == 1)
            contactId = userList[0].ContactId;
        list<Contact> contactList;
        set<id> chapterAccountIdsSet = new set<id>();
        map<id,string> chapterMap = new map<id,string>();
        Id inKindDonorsAccountRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('In Kind Donors').getRecordTypeId();
        if(contactId != Null){
            contactList = [SELECT ID,AccountId,Account.Wish_Co_ordinator__c FROM Contact WHERE ID =: contactId AND Account.Wish_Co_ordinator__c != Null];
            for(Account currentAccount : Trigger.new){
                 
                if(currentAccount.RecordTypeId == inKindDonorsAccountRecordTypeId && contactList[0].Account.Wish_Co_ordinator__c!= Null){
                    currentAccount.Chapter_Name__c = contactList[0].AccountId;
                }
                else{
                    
                     currentAccount.addError('There is no approver for this account.');
                }
            }
        }
        
        for(Account inKindAccount : trigger.new){
            if(inKindAccount.RecordTypeId == inKindDonorsAccountRecordTypeId && inKindAccount.Chapter_Name__c != Null){
            
                chapterAccountIdsSet.add(inKindAccount.Chapter_Name__c);
            }
            
            if(chapterAccountIdsSet.size() > 0){
                for(Account chapterAccount : [SELECT Id,Wish_Co_ordinator__c,Wish_Co_ordinator__r.Email FROM Account WHERE Id IN: chapterAccountIdsSet AND Wish_Co_ordinator__c != Null]){
                    chapterMap.put(chapterAccount.Id,chapterAccount.Wish_Co_ordinator__r.Email);
                }
            }
        }
        
        for(Account inKindAccount : trigger.new){
           if(inKindAccount.RecordTypeId == inKindDonorsAccountRecordTypeId ){
            if(inKindAccount.Chapter_Name__c != Null && chapterMap.containsKey(inKindAccount.Chapter_Name__c )){
                
                inKindAccount.Wish_Co_ordinator_Hidden_Email__c = chapterMap.get(inKindAccount.Chapter_Name__c);
               
            }
              else
                inKindAccount.addError('There is no approver for this account.');
           } 
        }
    }
    
    //After insert trigger to fire the approval process once inkind donor account is created
    if(trigger.isAfter && trigger.isInsert){
        Set<Id> chaptterAccountIdSet = new Set<Id> ();
        Set<Id> inKindDonorAccountSet = new Set<Id>();
        Map<Id,Id> chaptterMap = new Map<Id,Id>();
        Map<Id,Id> volunteerManagersMap = new map<Id,Id>();
        Id inKindDonorsAccountRTId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('In Kind Donors').getRecordTypeId();
        for(Account inKindAccount : trigger.new){
            
            if(inKindAccount.RecordTypeId == inKindDonorsAccountRTId){
                chaptterAccountIdSet.add(inKindAccount.Chapter_Name__c);
                inKindDonorAccountSet.add(inKindAccount.Id);
            }
        }
        if(chaptterAccountIdSet.size() > 0){
            
            for(Account daAccount : [SELECT Id,Wish_Co_ordinator__c, Volunteer_Manager__c FROM Account WHERE Id IN: chaptterAccountIdSet]){
                chaptterMap.put(daAccount.Id,daAccount.Wish_Co_ordinator__c);
                volunteerManagersMap.put(daAccount.Id,daAccount.Volunteer_Manager__c);
            }
        }
        Set<Id> inKindDonorAccountWithChildRecords = new Set<Id>();
        for(In_Kind_Donation_Reimbursement__c inKindRecordCheck : [SELECT Id, In_Kind_Donor_Name__c FROM In_Kind_Donation_Reimbursement__c WHERE In_Kind_Donor_Name__c IN :inKindDonorAccountSet]) {
            inKindDonorAccountWithChildRecords.add(inKindRecordCheck.In_Kind_Donor_Name__c);
        }
        for(Account inKindAccount : trigger.new){
            System.debug('????????????2????????????');
            /*if(volunteerManagersMap.containsKey(inKindAccount.Chapter_Name__c) && !inKindDonorAccountWithChildRecords.contains(inKindAccount.Id) && !String.isEmpty(volunteerManagersMap.get(inKindAccount.Chapter_Name__c))) {
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitting request for approval');
                req.setObjectId(inKindAccount.id);
                req.setProcessDefinitionNameOrId('Account_In_Kind_Donors_Approval');
                req.setNextApproverIds(new Id[]{volunteerManagersMap.get(inKindAccount.Chapter_Name__c)});
                req.setSkipEntryCriteria(true);
                Approval.ProcessResult result = Approval.process(req);
            } else*/ if(chaptterMap.containsKey(inKindAccount.Chapter_Name__c) && !String.isEmpty(chaptterMap.get(inKindAccount.Chapter_Name__c))){
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitting request for approval');
                req.setObjectId(inKindAccount.id);
                req.setProcessDefinitionNameOrId('Account_In_Kind_Donors_Approval');
                req.setNextApproverIds(new Id[]{chaptterMap.get(inKindAccount.Chapter_Name__c)});
                req.setSkipEntryCriteria(true);
              //  Approval.ProcessResult result = Approval.process(req);
            }
        }
    }
    
    if(trigger.isAfter && trigger.isUpdate){
        List<AccountShare> accountShareList = New List<AccountShare>();
        Id inKindDonorsAccountRTId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('In Kind Donors').getRecordTypeId();
        Id chapterId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Chapter').getRecordTypeId();
        String groupName;
        id groupId;
        map<string,string> groupNameMap = new map<string,string>();
        List<Account> accountList = new List<Account>();
        map<string,id> publicGroupMap = new map<string,id>();
        Set<Id> chapterIdsSet = new Set<Id>();
        Set<Id> checkForChildRecordSet = new Set<Id>();
        for(Account currentAccount :trigger.new){
            if(currentAccount.RecordTypeId == inKindDonorsAccountRTId && currentAccount.Chapter_Name__c != Null ){
                if(currentAccount.In_Kind_Approval_Status__c == 'Approved') {
                    chapterIdsSet.add(currentAccount.Chapter_Name__c);
                    groupName = currentAccount.Chapter_Name__c;
                    groupName = groupName.remove('Make-A-Wish ');
                    groupNameMap.put(currentAccount.Chapter_Name__c, groupName);
                } else if(currentAccount.In_Kind_Approval_Status__c == 'Rejected') {
                    checkForChildRecordSet.add(currentAccount.Id);
                    accountList.add(currentAccount);
                }
            }
        }
        
        Set<Id> inKindDonorAccountWithChildRecords = new Set<Id>();
        for(In_Kind_Donation_Reimbursement__c inKindRecordCheck : [SELECT Id, In_Kind_Donor_Name__c FROM In_Kind_Donation_Reimbursement__c WHERE In_Kind_Donor_Name__c IN : checkForChildRecordSet]) {
            inKindDonorAccountWithChildRecords.add(inKindRecordCheck.In_Kind_Donor_Name__c);
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
        for(Account inkindAccount : trigger.new){
            
            if(chapterNameMap.containsKey(inkindAccount.Chapter_Name__c) && inkindAccount.In_Kind_Approval_Status__c == 'Approved'){
                if( publicGroupMap.containsKey(chapterNameMap.get(inkindAccount.Chapter_Name__c))){
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
        
        if(!accountShareList.isEmpty())
            Insert accountShareList;
    }
    
}