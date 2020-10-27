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
		if (accountList.isEmpty()) {
			return;
		}
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
	* Share record to chapter users based on primary chapter ownership
	* @param accountList
	* @param oldAccountsMap
	*/
	public static void shareAccountToChapter(List<Account> accountsList, Map<Id, Account> oldAccountsMap) {
		if (accountsList.isEmpty()) {
			return;
		}
		Set<Id> inKindChapterAccountIdSet = new Set<Id>();
		Set<Id> chapterAccountIdSet = new Set<Id>();
		List<Account> inKindAccountsList = new List<Account>();
		Set<Id> chapterIdsHtf = new Set<Id>();
		Set<Id> accountIdsDeleteShare = new Set<Id>();
		List<Account> htfAccountList = new List<Account>();
		for (Account account : accountsList) {
			if (oldAccountsMap == null) {
				if (account.RecordTypeId == Constant_AC.IN_KIND_ACCOUNT_ID) {
					inKindAccountsList.add(account);
					if (account.Chapter_Name__c != null) {
						inKindChapterAccountIdSet.add(account.Chapter_Name__c);
					}
				} else if (account.RecordTypeId == CHAPTER_RECORD_TYPE_ID) {
					chapterAccountIdSet.add(account.Id);
				} else if (account.RecordTypeId == Constant_AC.HOSPITAL_TREATMENT_ID && account.Chapter_Name__c != null) {
					chapterIdsHtf.add(account.Chapter_Name__c);
					htfAccountList.add(account);
				} else {
					chapterAccountIdSet.add(account.Chapter_Name__c);
				}
			} else {
				Account oldAccount = oldAccountsMap.get(account.Id);
				if (account.RecordTypeId == Constant_AC.HOSPITAL_TREATMENT_ID && account.Chapter_Name__c != oldAccount.Chapter_Name__c) {
					chapterIdsHtf.add(account.Chapter_Name__c);
					htfAccountList.add(account);
					accountIdsDeleteShare.add(account.Id);
				}
			}
		}
		if (!inKindChapterAccountIdSet.isEmpty() || !chapterAccountIdSet.isEmpty()) {
			Map<Id, Id> wishCoordinatorMap = new Map<Id, Id>();
			Set<Id> accountIdSet = (new Map<Id, Account>(accountsList)).keySet();
			Map<String, List<Account>> accountMapforSharing = new Map<String, List<Account>>();

			List<Account> inKindChapterList = new List<Account>([
					SELECT Id, Name, Wish_Co_ordinator__c, OwnerId, Owner.UserRole.Name, Owner.ContactId, Volunteer_Manager__c,
							RecordTypeId, Chapter_Name__c, Chapter_Name__r.Name
					FROM Account
					WHERE (Id IN :inKindChapterAccountIdSet OR (Chapter_Name__c IN :chapterAccountIdSet AND Id IN :accountIdSet))
			]);
			for (Account accountRecord : inKindChapterList) {
				if (accountRecord.RecordTypeId == CHAPTER_RECORD_TYPE_ID) {
					wishCoordinatorMap.put(accountRecord.Id, accountRecord.Wish_Co_ordinator__c);
				} else if (accountRecord.Owner.userRole.Name == USER_ROLE_NAME_NATIONAL_STAFF) {
					if (accountMapforSharing.containsKey(accountRecord.Chapter_Name__r.Name)) {
						accountMapforSharing.get(accountRecord.Chapter_Name__r.Name).add(accountRecord);
					} else {
						accountMapforSharing.put(accountRecord.Chapter_Name__r.Name, new List<Account>{
								accountRecord
						});
					}
				}
			}
			submitAccountApprovalProcess(inKindAccountsList, wishCoordinatorMap);
			shareChapterAccountsToGroups(inKindAccountsList);
			ChapterStaffRecordSharing_AC.AccountSharing(accountMapforSharing);
		}
		if (!htfAccountList.isEmpty()) {
			ChapterStaffRecordSharing_AC.deleteAccountShare(accountIdsDeleteShare);
			Map<String, List<Account>> chapterAccountMap = new Map<String, List<Account>>();
			Map<Id, Account> chapterNameMap = new Map<Id, Account>(ChapterStaffRecordSharing_AC.getChapterNameById(chapterIdsHtf));
			for (Account account : htfAccountList) {
				String chapterName;
				if (chapterNameMap.containsKey(account.Chapter_Name__c)) {
					chapterName = chapterNameMap.get(account.Chapter_Name__c).Name;
					if (chapterAccountMap.containsKey(chapterName)) {
						chapterAccountMap.get(chapterName).add(account);
					} else {
						chapterAccountMap.put(chapterName, new List<Account>{
								account
						});
					}
				}
			}
			ChapterStaffRecordSharing_AC.AccountSharing(chapterAccountMap);
		}
	}

	/**
	* Share accounts to public groups based on chapter
	* @param chapterIdSet
	* @param accountList
	*/
	public static void shareChapterAccountsToGroups(List<Account> accountList) {
		if (accountList.isEmpty()) {
			return;
		}
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
		ChapterStaffRecordSharing_AC.createAccountShareReadAccess(accountList, chapterNameMap, publicGroupMap);
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
		if (accountsList.isEmpty()) {
			return;
		}
		List<String> zipCodesList = new List<String>();
		Map<String, Id> zipChapterMap = new Map<String, Id>();
		Map<Id, Account> htfAccountMap = new Map<Id, Account>();
		for (Account account : accountsList) {
			if (account.RecordTypeId == Constant_AC.HOSPITAL_TREATMENT_ID && account.Chapter_Name__c == null) {
				if (oldAccountsMap == null || (account.BillingPostalCode != oldAccountsMap.get(account.Id).BillingPostalCode ||
						account.ShippingPostalCode != oldAccountsMap.get(account.Id).ShippingPostalCode)) {
					if (String.isNotBlank(account.BillingPostalCode)) {
						zipCodesList.add(Utils.splitString(account.BillingPostalCode, '-')[0]);
						htfAccountMap.put(account.Id, account);
					} else if (String.isNotBlank(account.ShippingPostalCode)) {
						zipCodesList.add(Utils.splitString(account.ShippingPostalCode, '-')[0]);
						htfAccountMap.put(account.Id, account);
					}
				}
			}
		}
		zipChapterMap = ChapterStaffRecordSharing_AC.getChapterByZipcode(zipCodesList);
		for (Account account : htfAccountMap.values()) {
			String zip;
			if (String.isNotBlank(account.BillingPostalCode)) {
				zip = Utils.splitString(account.BillingPostalCode, '-')[0];
				if (zipChapterMap.containsKey(zip)) {
					account.Chapter_Name__c = zipChapterMap.get(zip);
					account.Hidden_Chapter__c = account.Chapter_Name__c;
                    account.Region_Code__c = null;
				}
			} else if (String.isNotBlank(account.ShippingPostalCode)) {
				zip = Utils.splitString(account.ShippingPostalCode, '-')[0];
				if (zipChapterMap.containsKey(zip)) {
					account.Chapter_Name__c = zipChapterMap.get(zip);
					account.Hidden_Chapter__c = account.Chapter_Name__c;
                    account.Region_Code__c = null;
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
	public static void updateAccountOwner(List<Account> accountsList, Map<Id, Account> oldAccountsMap) {
        if (accountsList.isEmpty()) {
            return;
        }
        Set<Id> chapterIdSet = new Set<Id>();
        List<Account> hospitalAccountList = new List<Account>();
        Map<Id, Account> accountContactMap = new Map<Id, Account>();
        for (Account account : accountsList) {
            if (account.RecordTypeId == Constant_AC.HOSPITAL_TREATMENT_ID) {
                if ((oldAccountsMap == null && account.Chapter_Name__c != null) || 
                    (oldAccountsMap != null && account.Chapter_Name__c != oldAccountsMap.get(account.Id).Chapter_Name__c)) {
                    chapterIdSet.add(account.Chapter_Name__c);
                    hospitalAccountList.add(account);
                }
            } else if(account.RecordTypeId == Constant_AC.HOUSEHOLD_RT_ID) {
                if(oldAccountsMap != null && account.npe01__One2OneContact__c != oldAccountsMap.get(account.Id).npe01__One2OneContact__c) {
                    accountContactMap.put(account.npe01__One2OneContact__c, account);
                }
            }
        }
        if (!chapterIdSet.isEmpty()) {
            Map<Id, Account> accountOwnerMap = new Map<Id, Account>(
                ChapterStaffRecordSharing_AC.getAccountOwner(chapterIdSet));
            for (Account account : hospitalAccountList) {
                if (accountOwnerMap.containsKey(account.Chapter_Name__c)) {
                    account.OwnerId = accountOwnerMap.get(account.Chapter_Name__c).Intake_Manager__c;
                }
            }
        }
        if (!accountContactMap.isEmpty()) {
            Map<Id, Contact> contactMap = new Map<Id, Contact>([
                SELECT Id, OwnerId 
                FROM Contact WHERE 
                Id IN :accountContactMap.keySet()
            ]);
            for (Account householdAccount : accountContactMap.values()) {
                householdAccount.OwnerId = contactMap.get(householdAccount.npe01__One2OneContact__c).OwnerId;
            }
        }
    }

	/**
	* @description Get duplicate records for Account records according to Duplicate Rules
	* @param accountInputs AccountDuplicateInput
	* @return Wrapper List of Accounts
	*/
	@InvocableMethod(Label='Find Account Duplicates' Description='Find duplicate contact records')
	public static List<List<Account>> getDuplicateRecords(List<AccountDuplicateInput> accountInputs) {
		List<Account> accounts = new List<Account>();
		for (AccountDuplicateInput input : accountInputs) {
			accounts.add(input.accountInput);
		}
		List<Datacloud.FindDuplicatesResult> results = new List<Datacloud.FindDuplicatesResult>();
		if (!Test.isRunningTest()) {
			results = Datacloud.FindDuplicates.findDuplicates(accounts);
		}
		Set<Id> duplicateAccountsIds = new Set<Id>();
		for (Datacloud.FindDuplicatesResult findDupeResult : results) {
			for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
				for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
					for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
						Account duplicateAccount = (Account) matchRecord.getRecord();
						duplicateAccountsIds.add(duplicateAccount.Id);
					}
				}
			}
		}
		List<Account> duplicatedAccounts = [
				SELECT Id, Name, Department__c, Phone, BillingStreet, BillingCity, BillingState, BillingPostalCode,
						Chapter_Name_Text__c
				FROM Account
				WHERE Id IN :duplicateAccountsIds
		];
		List<List<Account>> duplicatedAccountsList = new List<List<Account>>();
		duplicatedAccountsList.add(duplicatedAccounts);
		return duplicatedAccountsList;
	}

	public class AccountDuplicateInput {
		@InvocableVariable(Label='Input Account Record' Description='Single record to evaluate duplicates' Required=true)
		public Account accountInput;
	}
}