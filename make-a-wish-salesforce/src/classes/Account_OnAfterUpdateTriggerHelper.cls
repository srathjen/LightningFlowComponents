/***************************************************************************************************
Author      : MST Solutions
Date        : 10/15/2016
Description : Account_OnAfterUpdateTriggerHelper is used to call the Helper class when the
account record is get updated.

Modification Log
------------------
WVC-1884    KANAGARAJ  03/04/2018

*****************************************************************************************************/
public class Account_OnAfterUpdateTriggerHelper {

	/**
	 * JIRA: WLP-286
	 * Author: Gustavo Mayer
	 * Update: Granting sub case conversion to the single Wish Case
	 */
	public static void updateGrantingCaseDevStaffEmail(Map<Id, String> chapterEmailMap) {

		List<Case> updateCaseList = new List<Case>();
		for (Case wishCase : [
				SELECT Id, RecordTypeId, ParentId, Parent.ChapterName__c, Dev_Staff_Email__c
				FROM Case
				WHERE Parent.ChapterName__c IN:chapterEmailMap.keySet()
				AND RecordTypeId = :Constant_AC.WISH_RT_ID AND IsClosed = FALSE
				LIMIT 50000
		]) {
			if (chapterEmailMap.containsKey(wishCase.Parent.ChapterName__c)) {
				wishCase.Dev_Staff_Email__c = chapterEmailMap.get(wishCase.Parent.ChapterName__c);
				updateCaseList.add(wishCase);
			}
		}
		if (updateCaseList.size() > 0) {
			update updateCaseList;
		}
	}

	// This method is used to share the account record when the chapter name is updated.
	public static void updateChapterName(Set<Id> chapterIdSet, List<Account> accountList) {
		Id chapterRecType = Constant_AC.CHAPTER_RT_ID;
		Map<Id, String> chapterNameMap = new Map<Id, String>();
		Map<String, Id> publicGroupMap = new Map<String, Id>();
		Set<String> accountIdsSet = new Set<String>();
		List<AccountShare> accountShareList = new List<AccountShare>();
		List<AccountShare> updateAccountShareList = new List<AccountShare>();
		Id groupId;
		try {
			if (chapterIdSet.size() > 0) {
				for (Account getAccountName : [
						SELECT Id, Name
						FROM Account
						WHERE RecordTypeId = :chapterRecType
						LIMIT 50000
				]) {
					String chapterNameTrim = getAccountName.Name.removeStart('Make-A-Wish ');
					chapterNameMap.put(getAccountName.Id, chapterNameTrim);
				}
			}

			for (Group currentGroup : [
					SELECT Id, Name
					FROM Group
					WHERE Type = 'Regular'
					LIMIT 50000
			]) {
				publicGroupMap.put(currentGroup.Name, currentGroup.Id);
			}
			if (accountIdsSet.size() > 0 && publicGroupMap.size() > 0) {
				accountShareList = [
						SELECT Id,AccountId,UserOrGroupId
						FROM AccountShare
						WHERE AccountId IN:accountIdsSet AND UserOrGroupId IN:publicGroupMap.values()
						Limit 50000
				];
			}

			if (accountShareList.size() > 0) {
				delete accountShareList;
			}

			//This for loop is used to add inkind account to the public group based on new updated chapter name
			for (Account newInkind : accountList) {
				//if(newInkind.Chapter_Name__c != trigger.oldMap.get(newInkind.id).Chapter_Name__c){
				if (chapterNameMap.containsKey(newInkind.Chapter_Name__c)) {
					if (publicGroupMap.containsKey(chapterNameMap.get(newInkind.Chapter_Name__c))) {
						groupId = publicGroupMap.get(chapterNameMap.get(newInkind.Chapter_Name__c));
						AccountShare dynamicAccountShare = new AccountShare();
						dynamicAccountShare.AccountId = newInkind.Id;
						dynamicAccountShare.Accountaccesslevel = 'Read';
						dynamicAccountShare.CaseAccessLevel = 'None';
						dynamicAccountShare.ContactAccessLevel = 'None';
						dynamicAccountShare.OpportunityAccessLevel = 'None';
						dynamicAccountShare.UserOrGroupId = groupId;
						updateAccountShareList.add(dynamicAccountShare);

					}
				}
				//}

			}

			if (!updateAccountShareList.isEmpty()) {

				Insert updateAccountShareList;
			}

			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}

		} catch (Exception ex) {
			for (Account currRec : accountList) {
				ErrorMessage_AC.createdebugRec('Account_OnAfterUpdateTriggerHelper', String.valueof(currRec), String.valueOf(ex), 'updateChapterName', currRec.Id, ex.getStackTraceString(), 'Error');
			}

			if (!Test.isRunningTest()) {
				for (Account currRec : accountList) {
					currRec.addError(Label.Debug_log_error_message);
				}

			}
		}
	}
	// This method will update the wishfamily contact address if the contact marked as same as hoshold address whenever the household acccount address gets updated
	public static void updateRelatedContactAddressWithHoushold(Set<ID> houseHoldAccountIdsSet) {
		Set<ID> wishFamilyContactIdsSet = new Set<ID>();
		String wishFamilyRtLabel = Constant_AC.WISH_FAMILY_RT_LABEL;
		if (houseHoldAccountIdsSet.size() > 0) {
			for (Contact updatedContact : [
					Select ID,AccountId,Same_as_Household_Address__c
					from Contact
					where AccountId IN:houseHoldAccountIdsSet AND Same_as_Household_Address__c = true AND recordType.Name = :wishFamilyRtLabel
			]) {
				wishFamilyContactIdsSet.add(updatedContact.id);
			}
		}

		if (wishFamilyContactIdsSet.size() > 0) {
			Contact_OnAfterUpdateTriggerHepler.updateHouseHoldAddress(wishFamilyContactIdsSet);
		}
	}

	public static void updateWishFormRecord(List<Account> accountList) {
		Id emergencyContactRecordTypeId = Constant_AC.WISH_FORM_CHILD_EMERGENCY_ID;
		Id householdAccountId = Constant_AC.HOUSEHOLD_RT_ID;
		Map<Id, Account> accountMap = new Map<Id, Account>();
		List<Wish_Child_Form__c> updateWishFormList = new List<Wish_Child_Form__c>();
		for (Account processAccount : accountList) {
			if (processAccount.RecordTypeId == householdAccountId && processAccount.Hidden_Wish_Form_Id__c != Null) {

				accountMap.put(processAccount.Hidden_Wish_Form_Id__c, processAccount);
			}
		}
		for (Wish_Child_Form__c dbWishForm : [
				SELECT Id,mobilePhone__c,Emergency_Relationship__c,LastName__c,Middle_Name__c,Email__c,RecordTypeId,Migrated__c
				FROM Wish_Child_Form__c
				WHERE Id IN:accountMap.KeySet() AND RecordTypeId = :emergencyContactRecordTypeId AND Migrated__c = False
		]) {
			if (accountMap.containsKey(dbWishForm.Id)) {
				dbWishForm.mobilePhone__c = accountMap.get(dbWishForm.Id).Emergency_Contact_Phone__c;
				dbWishForm.Emergency_Relationship__c = accountMap.get(dbWishForm.Id).Relationship_type__c;
				dbWishForm.Middle_Name__c = accountMap.get(dbWishForm.Id).Emergency_Contact_Middle_Name__c;
				dbWishForm.Email__c = accountMap.get(dbWishForm.Id).Emergency_Contact_Email__c;
				updateWishFormList.add(dbWishForm);
			}
		}
		if (updateWishFormList.size() > 0)
			update updateWishFormList;
	}
}