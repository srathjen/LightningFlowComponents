/**
 * @description Account Service, centralizes Account business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 3/05/2020
 */
public class AccountService {

	private final static Id HOUSEHOLD_RECORD_TYPE_ID = Constant_AC.HOUSEHOLD_RT_ID;
	private final static String FAMILY_HOUSEHOLD_NAME_APPEND = Constant_AC.FAMILY_HOUSEHOLD_NAME_APPEND;
	private final static Id HOSPITAL_TREATMENT_RECORD_TYPE_ID = Constant_AC.HOSPITAL_TREATMENT_ID;

	/**
	 * Sets FirstName, LastName and Household fields on Account
	 * @param leadConvertAccountIds
	 * @param convertedAccountMap
	 * @return
	 */
	public static Map<Id, Account> setHouseholdFields(Map<Id, Lead> convertedAccountMap) {
		Map<Id, Account> accountMap = new Map<Id, Account>();
		for (Account account : [
				SELECT Id, Name, Volunteer_Manager__c, Intake_Manager__c,
						Volunteer_Manager__r.Name, Volunteer_Manager__r.Email,
						RecordTypeId
				FROM Account
				WHERE Id IN:convertedAccountMap.keySet()
		]) {
			if (convertedAccountMap.containsKey(account.Id)) {
				if (convertedAccountMap.get(account.Id).FirstName == null) {
					account.Name = convertedAccountMap.get(account.Id).LastName
							+ FAMILY_HOUSEHOLD_NAME_APPEND;
				} else {
					account.Name = convertedAccountMap.get(account.Id).FirstName
							+ ' '
							+ convertedAccountMap.get(account.Id).LastName
							+ FAMILY_HOUSEHOLD_NAME_APPEND;
				}
				account.RecordTypeId = HOUSEHOLD_RECORD_TYPE_ID;
				account.PrimaryLanguage__c =
						convertedAccountMap.get(account.Id).What_is_the_family_s_primary_spoken_lang__c;
				accountMap.put(account.Id, account);
			}
		}
		return accountMap;
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
        for(Account chapterAccount : [SELECT Id, Name, Wish_Co_ordinator__r.Email 
                                      FROM Account 
                                      WHERE RecordType.Name = :Constant_AC.CHAPTER_RT_ID]) {
            chapterMap.put(chapterAccount.Id, chapterAccount);
            nonPortalChapterMap.put(chapterAccount.Name.remove('Make-A-Wish ') + ' - Chapter', chapterAccount.Id);
        }
        for(User userRecord : [SELECT Id, ContactId, UserRole.Name, Contact.AccountId 
                               FROM User 
                               WHERE Id IN :ownerIdSet]) {
            if(userRecord.ContactId != null) {
                //portal user
                portalUserOwnerMap.put(userRecord.Id, userRecord.Contact.AccountId);
            } else if(userRecord.UserRole.Name != NULL && userRecord.UserRole.Name != 'National Staff') {
                //non-portal user
                nonportalUserOwnerMap.put(userRecord.Id, userRecord.UserRole.Name);
            }
                               }
        for(Account accountRecord : accountList) {
            if(portalUserOwnerMap.containsKey(accountRecord.OwnerId)) {
                if(chapterMap.containsKey(portalUserOwnerMap.get(accountRecord.OwnerId))) {
                    accountRecord.Wish_Co_ordinator_Hidden_Email__c = 
                        chapterMap.get(portalUserOwnerMap.get(accountRecord.OwnerId)).Wish_Co_ordinator__r.Email;
                    accountRecord.Chapter_Name__c = chapterMap.get(portalUserOwnerMap.get(accountRecord.OwnerId)).Id;
                }
            } else if(nonportalUserOwnerMap.containsKey(accountRecord.OwnerId)) {
                if(nonPortalChapterMap.containsKey(nonportalUserOwnerMap.get(accountRecord.OwnerId))) {
                    accountRecord.Wish_Co_ordinator_Hidden_Email__c = 
                        chapterMap.get(nonPortalChapterMap.get(nonportalUserOwnerMap.get(accountRecord.OwnerId))).Wish_Co_ordinator__r.Email;
                    accountRecord.Chapter_Name__c = nonPortalChapterMap.get(nonportalUserOwnerMap.get(accountRecord.OwnerId));
                }
            } else if(accountRecord.Chapter_Name__c == null
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
        for(Contact contactRecord : [SELECT Id, Name, AccountId, RecordTypeId 
                                     FROM Contact 
                                     WHERE AccountId IN :accountMap.keySet() 
                                     AND RecordTypeId = :Constant_AC.CONTACT_WISH_CHILD_RT_ID]) {
        	wishChildMap.put(contactRecord.AccountId, contactRecord.Id);              
        }        
        if(!wishChildMap.isEmpty()) {
            for(Account accountRecord : accountMap.values()) {
                if(wishChildMap.containsKey(accountRecord.Id)) {
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
		for(Account accountRecord : accountList) {
			if(accountWishCoordinatorMap.containsKey(accountRecord.Chapter_Name__c) 
				&& accountWishCoordinatorMap.get(accountRecord.Chapter_Name__c) != NULL) {
					Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
					req.setComments('Submitting request for approval');
					req.setObjectId(accountRecord.Id);
					req.setProcessDefinitionNameOrId('Account_In_Kind_Donors_Approval');
					req.setNextApproverIds(new Id[]{accountWishCoordinatorMap.get(accountRecord.Chapter_Name__c)});
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
		for(Account accountRecord : [SELECT Id, Name
										FROM Account
										WHERE RecordTypeId = :Constant_AC.CHAPTER_RT_ID]) {
			String chapterNameTrim = accountRecord.Name.removeStart('Make-A-Wish ');
			chapterNameMap.put(accountRecord.Id, chapterNameTrim);
		}
		for (Group publicGroup : [SELECT Id, Name
									FROM Group
									WHERE Type = 'Regular']) {
			publicGroupMap.put(publicGroup.Name, publicGroup.Id);
		}
		if(!chapterNameMap.isEmpty() && !publicGroupMap.isEmpty()) {
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
		for(Account accountRecord : accountList) {
			groupId = NULL;
			if(accountChapterNameMap.containsKey(accountRecord.Chapter_Name__c) 
				&& publicGroupMap.containsKey(accountChapterNameMap.get(accountRecord.Chapter_Name__c))) {
					groupId = publicGroupMap.get(accountChapterNameMap.get(accountRecord.Chapter_Name__c));
					AccountShare accountShare = new AccountShare();
					accountShare.AccountId = accountRecord.Id;
					accountShare.Accountaccesslevel = 'Read';
					accountShare.CaseAccessLevel = 'None';
					accountShare.ContactAccessLevel = 'None';
					accountShare.OpportunityAccessLevel = 'None';
					accountShare.UserOrGroupId = groupId;
					accountShareList.add(accountShare);
			}
		}
        if(!accountShareList.isEmpty()) {
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
        for(Chapter_Vs_Role__c chapterRole : [SELECT Chapter_Name__c, Role_Name__c
												FROM Chapter_Vs_Role__c
												WHERE Chapter_Name__c IN :chapterNames]) {
			chapterRoleMap.put(chapterRole.Chapter_Name__c, chapterRole.Role_Name__c);
		}        
        for(User user : [SELECT Id, userRole.Name
                         FROM User
                         WHERE userRole.Name IN :chapterRoleMap.values()
                         AND isActive = true]) {
            if(userRoleMap.containsKey(user.userRole.Name)) {
                userRoleMap.get(user.userRole.Name).add(user);
            } else {
                userRoleMap.put(user.userRole.Name, new List<User>{user});
            }
        }
        for(Account account : accountsList) {
            if(account.Chapter_Name__r.Name != null) {
                for(User user : userRoleMap.get(account.Chapter_Name__r.Name)) {
                    AccountShare accountShare = new AccountShare();
                    accountShare.accountId = account.id;
                    accountShare.UserOrGroupId = user.Id;
                    accountShare.accountAccessLevel = 'Edit';
                    accountShare.OpportunityAccessLevel = 'Read';
                    accountShare.CaseAccessLevel = 'Edit';
                    accountShare.ContactAccessLevel = 'Edit';
                    accountShare.RowCause = Schema.AccountShare.RowCause.Manual;
                    accountShareEditList.add(accountShare);
                }
            }
        }
        if(!accountShareEditList.isEmpty()) {
            insert accountShareEditList;
        }
	}
    
    /**
	 * Update wish form emergency contact information
	 * @param accountList
	 */
	public static void updateWishFormRecordEmergencyContact(List<Account> accountList) {
		Map<Id, Account> accountMap = new Map<Id, Account>();
		List<Wish_Child_Form__c> updateWishFormList = new List<Wish_Child_Form__c>();
		for (Account accountRecord : accountList) {
			if(accountRecord.RecordTypeId == Constant_AC.HOUSEHOLD_RT_ID 
			&& accountRecord.Hidden_Wish_Form_Id__c != null) {
				accountMap.put(accountRecord.Hidden_Wish_Form_Id__c, accountRecord);
			}
		}
		for (Wish_Child_Form__c wishForm : [SELECT Id, mobilePhone__c, Emergency_Relationship__c, 
											LastName__c, Middle_Name__c, Email__c, RecordTypeId, Migrated__c
											FROM Wish_Child_Form__c
											WHERE Id IN :accountMap.keySet() 
											AND RecordTypeId = :Constant_AC.WISH_FORM_CHILD_EMERGENCY_ID 
											AND Migrated__c = false]) {
				if (accountMap.containsKey(wishForm.Id)) {
					wishForm.mobilePhone__c = accountMap.get(wishForm.Id).Emergency_Contact_Phone__c;
					wishForm.Emergency_Relationship__c = accountMap.get(wishForm.Id).Relationship_type__c;
					wishForm.Middle_Name__c = accountMap.get(wishForm.Id).Emergency_Contact_Middle_Name__c;
					wishForm.Email__c = accountMap.get(wishForm.Id).Emergency_Contact_Email__c;
					updateWishFormList.add(wishForm);
				}
		}
		if(!updateWishFormList.isEmpty()) {
			update updateWishFormList;
		}
	}
    
    /**
	 * Update the wish family contact address if household account address changes
	 * @param houseHoldAccountIdsSet
	 */
	public static void updateRelatedContactAddressWithHousehold(Set<Id> houseHoldAccountIdsSet) {
		Set<Id> wishFamilyContactIdSet = new Set<Id>();
		for (Contact updatedContact : [SELECT Id, AccountId, Same_as_Household_Address__c 
										FROM Contact
										WHERE AccountId IN :houseHoldAccountIdsSet 
										AND Same_as_Household_Address__c = true 
										AND recordType.Name = :Constant_AC.WISH_FAMILY_RT_LABEL]) {
				wishFamilyContactIdSet.add(updatedContact.id);
		}
		
		if (!wishFamilyContactIdSet.isEmpty()) {
			Contact_OnAfterUpdateTriggerHepler.updateHouseHoldAddress(wishFamilyContactIdSet);	//MOVE TO CONTACT SERVICE
		}
	}
}