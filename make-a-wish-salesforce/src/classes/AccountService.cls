/**
 * @description Account Service, centralizes Account business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 3/05/2020
 */
public class AccountService {

    private final static Id HOUSEHOLD_RECORD_TYPE_ID = Constant_AC.HOUSEHOLD_RT_ID;
    private final static String FAMILY_HOUSEHOLD_NAME_APPEND = Constant_AC.FAMILY_HOUSEHOLD_NAME_APPEND;
    private final static Id HOSPITAL_TREATMENT_RECORD_TYPE_ID = Constant_AC.HOSPITAL_TREATMENT_ID;
    private final static Id CHAPTER_RECORD_TYPE_ID = Constant_AC.CHAPTER_RT_ID;
    private final static Id CONTACT_WISH_CHILD_RECORD_TYPE_ID = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
    private final static String WISH_FAMILY_RECORD_TYPE_LABEL = Constant_AC.WISH_FAMILY_RT_LABEL;
    private final static String READ = Constant_AC.RECORD_SHARE_READ;
    private final static String EDIT = Constant_AC.RECORD_SHARE_EDIT;
    private final static String NONE = Constant_AC.RECORD_SHARE_NONE;
    private final static String RECORD_NAME_REMOVE_SUBSTRING_MAW = 'Make-A-Wish ';
    private final static String CHAPTER_SUBSTRING = ' - Chapter';
    private final static String USER_ROLE_NAME_NATIONAL_STAFF = 'National Staff';
    private final static String GROUP_TYPE_REGULAR = 'Regular';

    /**
     * Sets FirstName, LastName and Household fields on Account
     * @param leadConvertAccountIds
     * @param convertedAccountMap
     * @return
     */
    public static Account setHouseholdFields(Lead lead) {
		Account wishChildHouseholdAccount = new Account();
		wishChildHouseholdAccount.Id = lead.ConvertedAccountId;
		if (lead.FirstName == null) {
			wishChildHouseholdAccount.Name = lead.LastName + FAMILY_HOUSEHOLD_NAME_APPEND;
		} else {
			wishChildHouseholdAccount.Name = lead.FirstName + ' ' + lead.LastName + FAMILY_HOUSEHOLD_NAME_APPEND;
		}
		wishChildHouseholdAccount.RecordTypeId = HOUSEHOLD_RECORD_TYPE_ID;
		wishChildHouseholdAccount.PrimaryLanguage__c =
				lead.What_is_the_family_s_primary_spoken_lang__c;
        return wishChildHouseholdAccount;
    }

    /**
    * Create Hospital Treatment Facility Account
    * @param convertedLeadIds
    * @param medicalAccountMap
    * @return
    */
    public static Map<String, Account> createHospitalTreatmentFacilities(Set<Id> convertedLeadIds, Map<String, Account> medicalAccountMap) {
        Map<String, Account> hospitalTreatmentFacilityMap = new Map<String, Account>();
        for (Lead processConvertedLeads : [
                SELECT Id,Name,Alternate1HospitalTreatmentFacility__c,
                        Alternate2HospitalTreatmentFacility__c,
                        Hospital_Treatment_Facility__c,Migrated_Record__c,
                        Hospital_Treatment_Facility_Treating__c,ChapterName__c,
                        Department__c
                FROM Lead
                WHERE Id IN:convertedLeadIds
        ]) {
            if (!medicalAccountMap.containsKey(processConvertedLeads.Hospital_Treatment_Facility_Treating__c)
                    && processConvertedLeads.Hospital_Treatment_Facility_Treating__c != null) {
                Account newAccount = new Account();
                newAccount.Name = processConvertedLeads.Hospital_Treatment_Facility_Treating__c;
                newAccount.RecordTypeId = HOSPITAL_TREATMENT_RECORD_TYPE_ID;
                newAccount.Migrated_Record__c = processConvertedLeads.Migrated_Record__c;
                hospitalTreatmentFacilityMap.put(newAccount.Name, newAccount);
            }
            if (!medicalAccountMap.containsKey(processConvertedLeads.Alternate1HospitalTreatmentFacility__c)
                    && processConvertedLeads.Alternate1HospitalTreatmentFacility__c != null) {
                Account newAccount = new Account();
                newAccount.Name = processConvertedLeads.Alternate1HospitalTreatmentFacility__c;
                newAccount.RecordTypeId = HOSPITAL_TREATMENT_RECORD_TYPE_ID;
                newAccount.Migrated_Record__c = processConvertedLeads.Migrated_Record__c;
                hospitalTreatmentFacilityMap.put(newAccount.Name, newAccount);
            }
            if (!medicalAccountMap.containsKey(processConvertedLeads.Alternate2HospitalTreatmentFacility__c)
                    && processConvertedLeads.Alternate2HospitalTreatmentFacility__c != null) {
                Account newAccount = new Account();
                newAccount.Name = processConvertedLeads.Alternate2HospitalTreatmentFacility__c;
                newAccount.RecordTypeId = HOSPITAL_TREATMENT_RECORD_TYPE_ID;
                newAccount.Migrated_Record__c = processConvertedLeads.Migrated_Record__c;
                hospitalTreatmentFacilityMap.put(newAccount.Name, newAccount);
            }
        }
        if (!hospitalTreatmentFacilityMap.isEmpty()) {
            RecursiveTriggerHandler.blockBeforeUpdate = true;
            RecursiveTriggerHandler.blockAfterUpdate = true;
            insert hospitalTreatmentFacilityMap.values();
        }
        return hospitalTreatmentFacilityMap;
    }

    /** 
    * Populate chapter name lookup and chapter email on account
    * @param ownerIdSet
    * @param accountList
    * @return
    */
    public static List<Account> matchChapterForAccount(Set<Id> ownerIdSet, List<Account> accountList) {
        Map<Id, Account> chapterMap = new Map<Id, Account>();
        Map<String, Id> nonPortalChapterMap = new Map<String, Id>();
        Map<Id, Id> portalUserOwnerMap = new Map<Id, Id>();
        Map<Id, String> nonportalUserOwnerMap = new Map<Id, String>();
        for (Account chapterAccount : [
                SELECT Id, Name, Wish_Co_ordinator__r.Email
                FROM Account
                WHERE RecordType.Id = :CHAPTER_RECORD_TYPE_ID
        ]) {
            chapterMap.put(chapterAccount.Id, chapterAccount);
            nonPortalChapterMap.put(chapterAccount.Name.remove(RECORD_NAME_REMOVE_SUBSTRING_MAW) + CHAPTER_SUBSTRING, chapterAccount.Id);
        }
        for (User userRecord : [
                SELECT Id, ContactId, UserRole.Name, Contact.AccountId
                FROM User
                WHERE Id IN :ownerIdSet
        ]) {
            if (userRecord.ContactId != null) {
                portalUserOwnerMap.put(userRecord.Id, userRecord.Contact.AccountId);
            } else if (userRecord.UserRole.Name != NULL && userRecord.UserRole.Name != USER_ROLE_NAME_NATIONAL_STAFF) {
                nonportalUserOwnerMap.put(userRecord.Id, userRecord.UserRole.Name);
            }
        }
        for (Account accountRecord : accountList) {
            if (portalUserOwnerMap.containsKey(accountRecord.OwnerId)) {
                if (chapterMap.containsKey(portalUserOwnerMap.get(accountRecord.OwnerId))) {
                    accountRecord.Wish_Co_ordinator_Hidden_Email__c =
                            chapterMap.get(portalUserOwnerMap.get(accountRecord.OwnerId)).Wish_Co_ordinator__r.Email;
                    accountRecord.Chapter_Name__c = chapterMap.get(portalUserOwnerMap.get(accountRecord.OwnerId)).Id;
                }
            } else if (nonportalUserOwnerMap.containsKey(accountRecord.OwnerId)) {
                if (nonPortalChapterMap.containsKey(nonportalUserOwnerMap.get(accountRecord.OwnerId))) {
                    accountRecord.Wish_Co_ordinator_Hidden_Email__c =
                            chapterMap.get(nonPortalChapterMap.get(nonportalUserOwnerMap.get(accountRecord.OwnerId))).Wish_Co_ordinator__r.Email;
                    accountRecord.Chapter_Name__c = nonPortalChapterMap.get(nonportalUserOwnerMap.get(accountRecord.OwnerId));
                }
            } else if (accountRecord.Chapter_Name__c == null
                    && !nonportalUserOwnerMap.containsKey(accountRecord.OwnerId)
                    && !portalUserOwnerMap.containsKey(accountRecord.OwnerId)) {
                accountRecord.addError('Please Select Chapter Name');
            }
        }
        return accountList;
    }

    /** 
    * Update primary contact for account
    * @param accountMap
    * @return
    */
    public static List<Account> setPrimaryContactForAccount(Map<Id, Account> accountMap) {
        Map<Id, Id> wishChildMap = new Map<Id, Id>();
        for (Contact contactRecord : [
                SELECT Id, Name, AccountId, RecordTypeId
                FROM Contact
                WHERE AccountId IN :accountMap.keySet()
                AND RecordTypeId = :CONTACT_WISH_CHILD_RECORD_TYPE_ID
        ]) {
            wishChildMap.put(contactRecord.AccountId, contactRecord.Id);
        }
        if (!wishChildMap.isEmpty()) {
            for (Account accountRecord : accountMap.values()) {
                if (wishChildMap.containsKey(accountRecord.Id)) {
                    accountRecord.npe01__One2OneContact__c = wishChildMap.get(accountRecord.Id);
                }
            }
        }
        return accountMap.values();
    }

    /**
    * Create and submit approval request for In Kind Donors account
    * @param accountList
    * @param accountWishCoordinatorMap
    */
    public static void submitAccountApprovalProcess(List<Account> accountList, Map<Id, Id> accountWishCoordinatorMap) {
        List<Approval.ProcessSubmitRequest> requestList = new List<Approval.ProcessSubmitRequest>();
        for (Account accountRecord : accountList) {
            if (accountWishCoordinatorMap.containsKey(accountRecord.Chapter_Name__c)
                    && accountWishCoordinatorMap.get(accountRecord.Chapter_Name__c) != NULL) {
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitting request for approval');
                req.setObjectId(accountRecord.Id);
                req.setProcessDefinitionNameOrId('Account_In_Kind_Donors_Approval');
                req.setNextApproverIds(new Id[]{
                        accountWishCoordinatorMap.get(accountRecord.Chapter_Name__c)
                });
                req.setSkipEntryCriteria(true);
                requestList.add(req);
            } else {
                accountRecord.addError('There is no wish coordinator to approve this record');
            }
        }
        Approval.process(requestList);
    }

    /**
    * Share accounts to public groups based on chapter
    * @param chapterIdSet
    * @param accountList
    */
    public static void shareChapterAccountsToGroups(Set<Id> chapterIdSet, List<Account> accountList) {
        Map<Id, String> chapterNameMap = new Map<Id, String>();
        Map<String, Id> publicGroupMap = new Map<String, Id>();
        for (Account accountRecord : [
                SELECT Id, Name
                FROM Account
                WHERE RecordTypeId = :CHAPTER_RECORD_TYPE_ID
        ]) {
            String chapterNameTrim = accountRecord.Name.removeStart(RECORD_NAME_REMOVE_SUBSTRING_MAW);
            chapterNameMap.put(accountRecord.Id, chapterNameTrim);
        }
        for (Group publicGroup : [
                SELECT Id, Name
                FROM Group
                WHERE Type = :GROUP_TYPE_REGULAR
        ]) {
            publicGroupMap.put(publicGroup.Name, publicGroup.Id);
        }
        if (!chapterNameMap.isEmpty() && !publicGroupMap.isEmpty()) {
            createAccountShareReadAccess(accountList, chapterNameMap, publicGroupMap);
        }
    }

    /**
    * Create AccountShare records to give public groups read access on accounts
    * @param accountList
    * @param accountChapterNameMap
    * @param publicGroupMap
    */
    public static void createAccountShareReadAccess(List<Account> accountList, Map<Id, String> accountChapterNameMap, Map<String, Id> publicGroupMap) {
        List<AccountShare> accountShareList = new List<AccountShare>();
        Id groupId;
        for (Account accountRecord : accountList) {
            groupId = NULL;
            if (accountChapterNameMap.containsKey(accountRecord.Chapter_Name__c)
                    && publicGroupMap.containsKey(accountChapterNameMap.get(accountRecord.Chapter_Name__c))) {
                groupId = publicGroupMap.get(accountChapterNameMap.get(accountRecord.Chapter_Name__c));
                AccountShare accountShare = new AccountShare();
                accountShare.AccountId = accountRecord.Id;
                accountShare.Accountaccesslevel = READ;
                accountShare.CaseAccessLevel = NONE;
                accountShare.ContactAccessLevel = NONE;
                accountShare.OpportunityAccessLevel = NONE;
                accountShare.UserOrGroupId = groupId;
                accountShareList.add(accountShare);
            }
        }
        if (!accountShareList.isEmpty()) {
            insert accountShareList;
        }
    }

    /**
    * Create AccountShare records to give users edit access on accounts based on chapter and role
    * @param accountsList
    * @param chapterNames
    */
    public static void createAccountShareEditAccess(List<Account> accountsList, List<String> chapterNames) {
        Map<String, String> chapterRoleMap = new Map<String, String>();
        Map<String, List<User>> userRoleMap = new Map<String, List<User>>();
        List<AccountShare> accountShareEditList = new List<AccountShare>();
        for (Chapter_Vs_Role__c chapterRole : [
                SELECT Chapter_Name__c, Role_Name__c
                FROM Chapter_Vs_Role__c
                WHERE Chapter_Name__c IN :chapterNames
        ]) {
            chapterRoleMap.put(chapterRole.Chapter_Name__c, chapterRole.Role_Name__c);
        }
        for (User user : [
                SELECT Id, userRole.Name
                FROM User
                WHERE userRole.Name IN :chapterRoleMap.values()
                AND isActive = true
        ]) {
            if (userRoleMap.containsKey(user.userRole.Name)) {
                userRoleMap.get(user.userRole.Name).add(user);
            } else {
                userRoleMap.put(user.userRole.Name, new List<User>{
                        user
                });
            }
        }
        for (Account account : accountsList) {
            if (account.Chapter_Name__r.Name != null) {
                String accountChapter = account.Chapter_Name__r.Name.remove(RECORD_NAME_REMOVE_SUBSTRING_MAW) + CHAPTER_SUBSTRING;
                if (userRoleMap.containsKey(accountChapter)) {
                    for (User user : userRoleMap.get(accountChapter)) {
                        if (account.OwnerId != user.Id) {
                            AccountShare accountShare = new AccountShare();
                            accountShare.accountId = account.Id;
                            accountShare.UserOrGroupId = user.Id;
                            accountShare.accountAccessLevel = EDIT;
                            accountShare.OpportunityAccessLevel = READ;
                            accountShare.CaseAccessLevel = EDIT;
                            accountShare.ContactAccessLevel = EDIT;
                            accountShare.RowCause = Schema.AccountShare.RowCause.Manual;
                            accountShareEditList.add(accountShare);
                        }
                    }
                }
            }
        }
        if (!accountShareEditList.isEmpty()) {
            insert accountShareEditList;
        }
    }

    /**
    * Update the wish family contact address if household account address changes
    * @param houseHoldAccountIdsSet
    */
    public static void updateRelatedContactAddressWithHousehold(Set<Id> houseHoldAccountIdsSet) {
        Set<Id> wishFamilyContactIdSet = new Set<Id>();
        for (Contact updatedContact : [
                SELECT Id, AccountId, Same_as_Household_Address__c
                FROM Contact
                WHERE AccountId IN :houseHoldAccountIdsSet
                AND Same_as_Household_Address__c = true
                AND recordType.Name = :WISH_FAMILY_RECORD_TYPE_LABEL
        ]) {
            wishFamilyContactIdSet.add(updatedContact.Id);
        }

        if (!wishFamilyContactIdSet.isEmpty()) {
            ContactService.updateHouseHoldAddress(wishFamilyContactIdSet);
        }
    }
    
    /**
    * Populate Chapter Name on the HTF Account
    * @param accountList
    */
    public static void populateChapterOnHospitalAccount(List<Account> accountsList, Map<Id, Account> oldAccountsMap) {
        if(accountsList.isEmpty()) {
            return;
        }
        List<String> zipCodesList = new List<String>();
        Map<String, Id> zipChapterMap = new Map<String, Id>();
        Map<Id, Account> htfAccountMap = new Map<Id, Account>();
        for(Account account : accountsList) {
            if(account.RecordTypeId == Constant_AC.HOSPITAL_TREATMENT_ID && account.Chapter_Name__c == null ) {
                if(oldAccountsMap == null || (account.BillingPostalCode != oldAccountsMap.get(account.Id).BillingPostalCode || 
                                              account.ShippingPostalCode != oldAccountsMap.get(account.Id).ShippingPostalCode)) 
                {
                    if(String.isNotBlank(account.BillingPostalCode)) {
                        zipCodesList.add(Utils.splitString(account.BillingPostalCode, '-')[0]);
                        htfAccountMap.put(account.Id, account);
                    } else if(String.isNotBlank(account.ShippingPostalCode)) {
                        zipCodesList.add(Utils.splitString(account.ShippingPostalCode, '-')[0]);
                        htfAccountMap.put(account.Id, account);
                    }
                }
            }
        }
        zipChapterMap = ChapterStaffRecordSharing_AC.getChapterByZipcode(zipCodesList);
        for(Account account : htfAccountMap.values()) {
            String zip;
            if(String.isNotBlank(account.BillingPostalCode)) {
                zip = Utils.splitString(account.BillingPostalCode, '-')[0];
                if(zipChapterMap.containsKey(zip)) {
                    account.Chapter_Name__c = zipChapterMap.get(zip);
                    account.Hidden_Chapter__c = account.Chapter_Name__c;
                }
            } else if(String.isNotBlank(account.ShippingPostalCode) && zipChapterMap.containsKey(Utils.splitString(account.ShippingPostalCode, '-')[0])) {
                zip = Utils.splitString(account.ShippingPostalCode, '-')[0];
                if(zipChapterMap.containsKey(zip)) {
                    account.Chapter_Name__c = zipChapterMap.get(zip);
                    account.Hidden_Chapter__c = account.Chapter_Name__c;
                }
            }
        }
        ContactService.updateRegionChapterOnMedicalProfessional(htfAccountMap);
    }
    
    /**
    * Update account owner to chapter intake manager
    * @param accountList
    * @param oldAccountsMap
    */
    public static void updateAccountOwnerToChapter(List<Account> accountsList, Map<Id, Account> oldAccountsMap) {
        if(accountsList.isEmpty()) {
            return;
        }
        Map<Id, Account> accountChapterMap = new Map<Id, Account>();
        for(Account account : accountsList) {
            if(account.RecordTypeId == Constant_AC.HOSPITAL_TREATMENT_ID) {
                if(oldAccountsMap == null && account.Chapter_Name__c != null) {
                    accountChapterMap.put(account.Chapter_Name__c, account);
                } else if(oldAccountsMap != null && account.Chapter_Name__c != oldAccountsMap.get(account.Id).Chapter_Name__c) {
                    accountChapterMap.put(account.Chapter_Name__c, account);
                }
            }
        }
        if(!accountChapterMap.isEmpty()) {
            Map<Id, Account> accountOwnerMap = new Map<Id, Account>(
                ChapterStaffRecordSharing_AC.getAccountOwner(accountChapterMap.keySet()));
            for(Account account : accountChapterMap.values()) {
                if(accountOwnerMap.containsKey(account.Chapter_Name__c)) {
                    account.OwnerId = accountOwnerMap.get(account.Chapter_Name__c).Intake_Manager__c;
                }
            }
        }
    }
    
    /**
    * Share HTF record to chapter users based on primary chapter ownership 
    * @param accountList
    * @param oldAccountsMap
    */
    public static void shareHospitalAccountToChapter(List<Account> accountsList, Map<Id, Account> oldAccountsMap) {
        if(accountsList.isEmpty()) {
            return;
        }
        Set<Id> chapterIds = new Set<Id>();
        List<Account> htfAccountList = new List<Account>();
        for(Account account : accountsList) {
            if(account.RecordTypeId == Constant_AC.HOSPITAL_TREATMENT_ID 
               && ((oldAccountsMap == null && account.Chapter_Name__c != null) 
                   || (oldAccountsMap != null && account.Chapter_Name__c != oldAccountsMap.get(account.Id).Chapter_Name__c))) 
            {
                chapterIds.add(account.Chapter_Name__c);
                htfAccountList.add(account);
            }
        }
        if(!chapterIds.isEmpty()) {
            Map<String, List<Account>> chapterAccountMap = new Map<String, List<Account>>();
            Map<Id, Account> chapterNameMap = new Map<Id, Account>(ChapterStaffRecordSharing_AC.getChapterNameById(chapterIds));
            for(Account account : htfAccountList) {
                String chapterName;
                if(chapterNameMap.containsKey(account.Chapter_Name__c)) {
                    chapterName = chapterNameMap.get(account.Chapter_Name__c).Name;
                    if(chapterAccountMap.containsKey(chapterName)) {
                        chapterAccountMap.get(chapterName).add(account);
                    } else {
                        chapterAccountMap.put(chapterName, new List<Account>{account});
                    }
                }
            }
            if(!chapterAccountMap.isEmpty()) {
                ChapterStaffRecordSharing_AC.AccountSharing(chapterAccountMap);
            }
        }
    }
}