/**
* @description Domain class for the Account trigger
* @author Michelle Cominotto, Make-A-Wish
* @createdDate 3-13-2020
*/
public with sharing class AccountDomain extends trac_TriggerHandlerBase {

    private final static Id HOUSEHOLD_RECORD_TYPE_ID = Constant_AC.HOUSEHOLD_RT_ID;
    private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;
    private final static Id IN_KIND_RECORD_TYPE_ID = Constant_AC.IN_KIND_ACCOUNT_ID;
    private final static String USER_ROLE_NAME_NATIONAL_STAFF = 'National Staff';
    private final static String IN_KIND_ACCOUNT_APPROVAL_STATUS_REJECTED = 'Rejected';
    private final static String GROUP_TYPE_REGULAR = 'Regular';
    private final static String RECORD_NAME_REMOVE_SUBSTRING_MAW = 'Make-A-Wish ';
    
    private List<Account> newAccountsList = (List<Account>)newRecordsList;
    private List<Account> oldAccountsList = (List<Account>)oldRecordsList;
    private Map<Id, Account> newAccountsMap = (Map<Id, Account>)newRecordsMap;
    private Map<Id, Account> oldAccountsMap = (Map<Id, Account>)oldRecordsMap;
    
    /**
    * Before insert of account
    */
    public override void handleBeforeInsert() {
        Set<Id> ownerIdSet = new Set<Id>();
        List<Account> inKindAccountList = new List<Account>();
        for(Account newAccount : newAccountsList) {
            if(newAccount.RecordTypeId == IN_KIND_RECORD_TYPE_ID) {
                ownerIdSet.add(newAccount.OwnerId);
                inKindAccountList.add(newAccount);
            } else if(newAccount.RecordTypeId == HOUSEHOLD_RECORD_TYPE_ID) {
                newAccount.Migrated_Record__c = true;
            }
        }
        //Populate chapter lookup and chapter email for In Kind Donors account
        if(!inKindAccountList.isEmpty()) {
            AccountService.matchChapterForAccount(ownerIdSet, inKindAccountList);
        }
    }
    
    /**
    * Before update of account
    */
    public override void handleBeforeUpdate() {
        Map<Id, Account> houseHoldAccountMap = new Map<Id, Account>();
        for(Account newAccount : newAccountsMap.values()) {
            Account oldAccount = oldAccountsMap.get(newAccount.Id);
            if(newAccount.RecordTypeId == HOUSEHOLD_RECORD_TYPE_ID) {
                houseHoldAccountMap.put(newAccount.Id, newAccount);
            }
            //Update address verified field if address fields are updated
            if(newAccount.BillingStreet != oldAccount.BillingStreet 
               || newAccount.BillingState != oldAccount.BillingState 
               || newAccount.BillingStateCode != oldAccount.BillingStateCode 
               || newAccount.BillingCity != oldAccount.BillingCity 
               || newAccount.BillingPostalCode != oldAccount.BillingPostalCode) {
                   newAccount.BillingAddressVerified__c = false;
                   newAccount.BillingAddressVerificationAttempted__c = null;
               }
            if(newAccount.ShippingStreet != oldAccount.ShippingStreet 
               || newAccount.ShippingState != oldAccount.ShippingState 
               || newAccount.ShippingStateCode != oldAccount.ShippingStateCode 
               || newAccount.ShippingCity != oldAccount.ShippingCity 
               || newAccount.ShippingPostalCode != oldAccount.ShippingPostalCode) {
                   newAccount.ShippingAddressVerified__c = false;
                   newAccount.ShippingAddressVerificationAttempted__c = null;
               }
        }
        //Set primary contact for account
        if(!houseHoldAccountMap.isEmpty()) {
        	AccountService.setPrimaryContactForAccount(houseHoldAccountMap);
        }
    }
    
    /**
    * After insert of account
    */
    public override void handleAfterInsert() {
        Set<Id> inKindChapterAccountIdSet = new Set<Id>();
        Set<Id> chapterAccountIdSet = new Set<Id>();
        List<Account> inKindAccountsList = new List<Account>();
        Set<Id> accountIdSet = (new Map<Id, Account>(newAccountsList)).keySet();
        Map<Id,Id> wishCoordinatorMap = new Map<Id,Id>();
        Map<Id, String> chapterNameMap = new Map<Id, String>();
        Map<String, Id> publicGroupMap = new Map<String,Id>();
        List<Account> accountsToShareList = new List<Account>();
        List<String> chapterNameList = new List<String>();
        
        for(Account newAccount : newAccountsList) {
            if(newAccount.RecordTypeId == IN_KIND_RECORD_TYPE_ID) {
                inKindAccountsList.add(newAccount);
                if(newAccount.Chapter_Name__c != null) {
                    inKindChapterAccountIdSet.add(newAccount.Chapter_Name__c);
                }
            } else if(newAccount.RecordTypeId == CHAPTER_RECORD_TYPE_ID) {
				chapterAccountIdSet.add(newAccount.Id);
			} else {
				chapterAccountIdSet.add(newAccount.Chapter_Name__c);
			}
        }
        for(Account accountRecord : [SELECT Id, Name, Wish_Co_ordinator__c, OwnerId, Owner.UserRole.Name, Owner.ContactId, 
                                    Volunteer_Manager__c, RecordTypeId, Chapter_Name__c, Chapter_Name__r.Name
                                    FROM Account
                                    WHERE (Id IN :inKindChapterAccountIdSet 
                                    OR (Chapter_Name__c IN :chapterAccountIdSet AND Id IN :accountIdSet))]) {
                if(accountRecord.RecordTypeId == CHAPTER_RECORD_TYPE_ID) {
                    wishCoordinatorMap.put(accountRecord.Id, accountRecord.Wish_Co_ordinator__c);
                    chapterNameMap.put(accountRecord.Id, accountRecord.Name.removeStart(RECORD_NAME_REMOVE_SUBSTRING_MAW));
                } else if(accountRecord.Owner.userRole.Name == USER_ROLE_NAME_NATIONAL_STAFF 
                          && accountRecord.Chapter_Name__r.Name != null) {
                              accountsToShareList.add(accountRecord);
                              chapterNameList.add(accountRecord.Chapter_Name__r.Name);
                }
        }
        if(!chapterNameMap.isEmpty()) {
            for(Group publicGroup : [SELECT Id, Name 
                                	FROM Group 
                                	WHERE Type = :GROUP_TYPE_REGULAR 
                                	AND Name IN :chapterNameMap.values()]) {
                publicGroupMap.put(publicGroup.Name, publicGroup.Id);
            }
        }
        //Create approval process request for In Kind Donors account
        if(!wishCoordinatorMap.isEmpty()) {
            AccountService.submitAccountApprovalProcess(inKindAccountsList, wishCoordinatorMap);
        }
        //Share accounts to public groups based on chapter
        if(!publicGroupMap.isEmpty() && !chapterNameMap.isEmpty()) {
            AccountService.createAccountShareReadAccess(inKindAccountsList, chapterNameMap, publicGroupMap);
        }
        //Share accounts to users based on chapter and role
        if(!accountsToShareList.isEmpty()) {
            AccountService.createAccountShareEditAccess(accountsToShareList, chapterNameList);
        }
    }
    
    /**
    * After update of account
    */
    public override void handleAfterUpdate() {
        Set<Id> chapterIdsSet = new Set<Id>();
        Set<Id> houseHoldAccountIdsSet = new Set<Id>();
        Map<Id, String> chapterEmailMap = new Map<Id, String>();
        List<Account> accountList = new List<Account>();
        List<Account> wishFormAccountList = new List<Account>();
        for(Account newAccount : newAccountsMap.values()) {
            Account oldAccount = oldAccountsMap.get(newAccount.Id);
            if(newAccount.RecordTypeId == IN_KIND_RECORD_TYPE_ID) {
                if(newAccount.In_Kind_Approval_Status__c == IN_KIND_ACCOUNT_APPROVAL_STATUS_REJECTED 
                    && oldAccount.In_Kind_Approval_Status__c != IN_KIND_ACCOUNT_APPROVAL_STATUS_REJECTED) {
                    	chapterIdsSet.add(newAccount.Chapter_Name__c);
                    	accountList.add(newAccount);
                }
                if((newAccount.Chapter_Name__c != oldAccount.Chapter_Name__c 
                    && newAccount.In_Kind_Approval_Status__c != IN_KIND_ACCOUNT_APPROVAL_STATUS_REJECTED)
                    || newAccount.Chapter_Name__c == null &&  oldAccount.Chapter_Name__c != null) {
                       	chapterIdsSet.add(oldAccount.Chapter_Name__c);
                       	accountList.add(newAccount);
                }
            }
            if(newAccount.RecordTypeId == CHAPTER_RECORD_TYPE_ID 
                && newAccount.DevStaffEmail__c != null 
                && newAccount.DevStaffEmail__c != oldAccount.DevStaffEmail__c) {
                   chapterEmailMap.put(newAccount.Id, newAccount.DevStaffEmail__c);
            }
            if(newAccount.RecordTypeId == HOUSEHOLD_RECORD_TYPE_ID 
                && (newAccount.BillingStreet != oldAccount.BillingStreet 
                || newAccount.BillingCity != oldAccount.BillingCity 
                || newAccount.BillingState != oldAccount.BillingState
                || newAccount.BillingCountry != oldAccount.BillingCountry 
                || newAccount.BillingPostalCode != oldAccount.BillingPostalCode)) {
                    houseHoldAccountIdsSet.add(newAccount.Id);
            }
            if(newAccount.RecordTypeId == HOUSEHOLD_RECORD_TYPE_ID 
                && (newAccount.Emergency_Contact_Phone__c != oldAccount.Emergency_Contact_Phone__c 
                || newAccount.Relationship_type__c != oldAccount.Relationship_type__c 
                || newAccount.Emergency_Contact_Middle_Name__c != oldAccount.Emergency_Contact_Middle_Name__c
                || newAccount.Email__c != oldAccount.Email__c) 
                && newAccount.Hidden_Wish_Form_Id__c != null) {
                    wishFormAccountList.add(newAccount);
            }
        }
        //Update dev staff email on case
        if(!chapterEmailMap.isEmpty()) {
            CaseService.updateGrantingCaseDevStaffEmail(chapterEmailMap);
        }
        //Share chapter accounts to public groups
        if(!chapterIdsSet.isEmpty()) {
            AccountService.shareChapterAccountsToGroups(chapterIdsSet, accountList);
        }
        //Update the wish family contact address
        if(!houseHoldAccountIdsSet.isEmpty()) {
            AccountService.updateRelatedContactAddressWithHousehold(houseHoldAccountIdsSet);
        }
        //Update emergency contact information
        if(!wishFormAccountList.isEmpty()) {
            AccountService.updateWishFormRecordEmergencyContact(wishFormAccountList);
        }
    }
}