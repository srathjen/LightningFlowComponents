/**
* @description Domain class for the Account trigger
* @author Michelle Cominotto, Make-A-Wish
* @createdDate 3-13-2020
*/
public class AccountDomain extends trac_TriggerHandlerBase {

    private final static Id HOUSEHOLD_RECORD_TYPE_ID = Constant_AC.HOUSEHOLD_RT_ID;
    private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;
    private final static Id IN_KIND_RECORD_TYPE_ID = Constant_AC.IN_KIND_ACCOUNT_ID;
    private final static String IN_KIND_ACCOUNT_APPROVAL_STATUS_REJECTED = 'Rejected';

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
            if(newAccount.Chapter_Name__c != null) {
                newAccount.Hidden_Chapter__c = newAccount.Chapter_Name__c;
            }
        }
        //Populate chapter lookup and chapter email for In Kind Donors account
        if(!inKindAccountList.isEmpty()) {
            AccountService.matchChapterForAccount(ownerIdSet, inKindAccountList);
        }
        AccountService.populateChapterOnHospitalAccount(newAccountsList, null);
        AccountService.updateAccountOwner(newAccountsList, null);
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
        AccountService.populateChapterOnHospitalAccount(newAccountsList, oldAccountsMap);
        AccountService.updateAccountOwner(newAccountsList, oldAccountsMap);
    }
    
    /**
    * After insert of account
    */
    public override void handleAfterInsert() {
        AccountService.shareAccountToChapter(newAccountsList, null);
    }
    
    /**
    * After update of account
    */
    public override void handleAfterUpdate() {
        Set<Id> houseHoldAccountIdsSet = new Set<Id>();
        Map<Id, String> chapterEmailMap = new Map<Id, String>();
        List<Account> accountList = new List<Account>();
        for(Account newAccount : newAccountsMap.values()) {
            Account oldAccount = oldAccountsMap.get(newAccount.Id);
            if(newAccount.RecordTypeId == IN_KIND_RECORD_TYPE_ID) {
                if(newAccount.In_Kind_Approval_Status__c == IN_KIND_ACCOUNT_APPROVAL_STATUS_REJECTED 
                   && oldAccount.In_Kind_Approval_Status__c != IN_KIND_ACCOUNT_APPROVAL_STATUS_REJECTED) {
                       accountList.add(newAccount);
                   }
                if((newAccount.Chapter_Name__c != oldAccount.Chapter_Name__c 
                    && newAccount.In_Kind_Approval_Status__c != IN_KIND_ACCOUNT_APPROVAL_STATUS_REJECTED)
                   || newAccount.Chapter_Name__c == null &&  oldAccount.Chapter_Name__c != null) {
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
        }
        //Update dev staff email on case
        if(!chapterEmailMap.isEmpty()) {
            CaseService.updateGrantingCaseDevStaffEmail(chapterEmailMap);
        }
        //Update the wish family contact address
        if(!houseHoldAccountIdsSet.isEmpty()) {
            AccountService.updateRelatedContactAddressWithHousehold(houseHoldAccountIdsSet);
        }
        AccountService.shareChapterAccountsToGroups(accountList);
        AccountService.shareAccountToChapter(newAccountsList, oldAccountsMap);
    }
}