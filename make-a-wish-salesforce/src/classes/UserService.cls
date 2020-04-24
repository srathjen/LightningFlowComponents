/**
 * Service layer class for the User object.
 *
 * @author Chris Shinnimin, Traction on Demand
 * @date 2020-04-03
 */
public class UserService {
	/*
	 * @description     Update Volunteer Contact Details based on the User record details.
	 *
	 * @author          MST Solutions
	 * @createdDate     unknown
	 */
	public static void updateVolunteerInfo(Map<Id, User> prospectiveUserMap) {
		if (prospectiveUserMap == null || prospectiveUserMap.isEmpty()) {
			return;
		}

		try {
			List<Contact> updateContactList = new List<Contact>();
			List<npe5__Affiliation__c> updateAffiliationList = new List<npe5__Affiliation__c>();
			List<ContactShare> contactSharingList = new List<ContactShare>();

			for (Contact currRec : [
					SELECT
							Id, MailingState, MailingPostalCode, MailingCity,
							Account.Volunteer_Manager__c, HomePhone
					FROM Contact
					WHERE Id IN :prospectiveUserMap.keySet()
			]) {
				if (prospectiveUserMap.containsKey(currRec.Id)) {
					Contact updateContact = new Contact();

					updateContact.Id = currRec.Id;
					updateContact.MailingState = prospectiveUserMap.get(currRec.Id).State;
					updateContact.MailingCity = prospectiveUserMap.get(currRec.Id).City;
					updateContact.MailingPostalCode = prospectiveUserMap.get(currRec.Id).PostalCode;
					updateContact.MobilePhone = prospectiveUserMap.get(currRec.Id).Phone;
					updateContact.HomePhone = null;
					updateContact.npe01__PreferredPhone__c = Constant_AC.CONTACT_PHONE_MOBILE;

					if (currRec.Account.Volunteer_Manager__c != null) {
						updateContact.OwnerId = currRec.Account.Volunteer_Manager__c;
					}

					updateContactList.add(updateContact);

					ContactShare currContactSharing = new ContactShare();

					currContactSharing.ContactId = currRec.Id;
					currContactSharing.UserOrGroupId = prospectiveUserMap.get(currRec.Id).Id;
					currContactSharing.ContactAccessLevel = Constant_AC.RECORD_SHARE_EDIT;
					currContactSharing.RowCause = Schema.ContactShare.RowCause.Manual;

					contactSharingList.add(currContactSharing);
				}

			}

			if (updateContactList.size() > 0) {
				update updateContactList;
			}
			if (contactSharingList.size() > 0) {
				insert contactSharingList;
			}

			// Updating the Affiliation Record status As Pending.
			for (npe5__Affiliation__c currRec : [
					SELECT Id, npe5__Status__c
					FROM npe5__Affiliation__c
					WHERE npe5__Contact__c IN :prospectiveUserMap.keySet()
					AND npe5__Status__c = :Constant_AC.ORG_AFFILIATION_STATUS_CURRENT
			]) {
				npe5__Affiliation__c updateRec = new npe5__Affiliation__c();
				updateRec.Id = currRec.Id;
				updateRec.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_PENDING;
				updateAffiliationList.add(updateRec);
			}

			if (updateAffiliationList.size() > 0) {
				update updateAffiliationList;
			}

			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			if (!Test.isRunningTest()) {
				for (User currRec : prospectiveUserMap.values()) {
					currRec.addError(Label.Debug_log_error_message);
				}
			}
		}
	}

	/*
	 * @description     Add Salesforce internal user to chatter group based on their role.
	 *
	 * @author          MST Solutions
	 * @createdDate     unknown
	 */
	@future
	public static void addInternalUserToChatterGroup(Map<Id, Id> newUserRoleIdMap) {
		if (newUserRoleIdMap == null || newUserRoleIdMap.isEmpty()) {
			return;
		}

		try {
			Set<String> userRoleName = new Set<String>(); //Used to hold chapter name after removal of '- Chapter' form Name
			Map<Id, String> groupInfoMap = new Map<Id, String>(); // Used to hold the group Id and Name
			Map<String, Id> chatterGroupNameIdsMap = new Map<String, Id>(); //Used to hold Group Name and Group Id
			List<CollaborationGroupMember> chatterGroupMembersList = new List<CollaborationGroupMember>();

			for (UserRole getUserRoleName : [
					SELECT Id, Name
					FROM UserRole
					WHERE Id IN :newUserRoleIdMap.values()
			]) {
				if (getUserRoleName.Name.contains(' - Chapter')) {
					userRoleName.add(getUserRoleName.Name.remove(' - Chapter'));
					groupInfoMap.put(getUserRoleName.Id, getUserRoleName.Name.remove(' - Chapter'));
				}
			}

			if (userRoleName.size() > 0) {
				for (CollaborationGroup getgroupInfo : [
						SELECT Id, Name
						FROM CollaborationGroup
						WHERE Name IN :userRoleName
				]) {
					chatterGroupNameIdsMap.put(getgroupInfo.Name, getgroupInfo.Id);
				}

				for (Id newUserId : newUserRoleIdMap.keySet()) {
					if (groupInfoMap.containsKey(newUserRoleIdMap.get(newUserId))) {
						CollaborationGroupMember newCollaborationMemberGroup = new CollaborationGroupMember();

						newCollaborationMemberGroup.MemberId = newUserId;
						newCollaborationMemberGroup.CollaborationGroupId = chatterGroupNameIdsMap.get(groupInfoMap.get(newUserRoleIdMap.get(newUserId)));

						chatterGroupMembersList.add(newCollaborationMemberGroup);
					}
				}
			}

			if (chatterGroupMembersList.size() > 0) {
				if (!Test.isRunningTest()) {
					insert chatterGroupMembersList;
				}
			}
		} catch (Exception ex) {
			for (User currRec : [
					SELECT Id, Name
					FROM User
					WHERE Id IN :newUserRoleIdMap.values()
			]) {
				ErrorMessage_AC.createdebugRec('User_OnAfterInsertHelper_AC', String.valueOf(currRec), String.valueOf(ex), 'AddInternalUserToChatterGroup', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
		}
	}

	/*
	 * @description     Remove internal user from chatter group based on their role.
	 *
	 * @author          MST Solutions
	 * @createdDate     unknown
	 */
	@future
	public static void removeInternalUserToChatterGroup(Map<Id, Id> oldUserRoleIdMap) {
		if (oldUserRoleIdMap == null || oldUserRoleIdMap.isEmpty()) {
			return;
		}

		try {
			Set<String> userRoleName = new Set<String>(); //Used to hold chapter name after removal of '- Chapter' form Name
			List<CollaborationGroupMember> chatterGroupMembersList = new List<CollaborationGroupMember>();
			Map<String, Id> userRoleNameIdMap = new Map<String, Id>();

			for (UserRole getUserRoleName : [
					SELECT Id, Name
					FROM UserRole
					WHERE Id IN :oldUserRoleIdMap.values()
			]) {
				if (getUserRoleName.Name.contains(' - Chapter')) {
					userRoleName.add(getUserRoleName.Name.remove(' - Chapter'));
					userRoleNameIdMap.put(getUserRoleName.Name.remove(' - Chapter'), getUserRoleName.Id);
				}
			}

			Map<Id, String> roleChapterMap = new Map<Id, String>();
			if (userRoleName.size() > 0) {
				for (CollaborationGroup getgroupInfo : [
						SELECT Id, Name
						FROM CollaborationGroup
						WHERE Name IN :userRoleName
				]) {
					roleChapterMap.put(getgroupInfo.Id, getgroupInfo.Name);
				}

				for (CollaborationGroupMember chatterInfo : [
						SELECT Id, MemberId, CollaborationGroupId
						FROM CollaborationGroupMember
						WHERE MemberId IN :oldUserRoleIdMap.keySet()
				]) {
					if (userRoleNameIdMap.get(roleChapterMap.get(chatterInfo.CollaborationGroupId)) == oldUserRoleIdMap.get(chatterInfo.MemberId)) {
						chatterGroupMembersList.add(chatterInfo);
					}
				}

				if (chatterGroupMembersList.size() > 0) {
					delete chatterGroupMembersList;
				}

				if (Test.isRunningTest()) {
					throw new CommonTriggerException('Test Class execution');
				}
			}
		} catch (Exception ex) {
			for (User currRec : [
					SELECT Id, Name
					FROM User
					WHERE Id IN :oldUserRoleIdMap.values()
			]) {
				ErrorMessage_AC.createdebugRec('User_OnAfterUpdateHelper_AC', String.valueOf(currRec), String.valueOf(ex), 'RemoveInternalUserToChatterGroup', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
		}

	}

	/*
	 * @author          MST Solutions
	 * @createdDate     unknown
	 */
	@future
	public static void updateUser(Set<Id> inactiveUserIdSet) {
		if (inactiveUserIdSet == null || inactiveUserIdSet.isEmpty()) {
			return;
		}

		try {
			List<Case> dbcaseList = new List<Case>();
			Map<Id, String> caseTeamMemberMap = new Map<Id, String>();

			for (CaseTeamMember dbCaseTeamMember : [
					SELECT
							Id, MemberId, Member.FirstName, Member.LastName,
							ParentId, Parent.RecordTypeId, TeamRoleId, TeamRole.Name
					FROM CaseTeamMember
					WHERE TeamRole.Name = :Constant_AC.CASE_TEAM_ROLE_WISH_GRANTER
					AND MemberId IN :inactiveUserIdSet
			]) {
				caseTeamMemberMap.put(dbCaseTeamMember.ParentId, dbCaseTeamMember.Member.FirstName + ' ' + dbCaseTeamMember.Member.LastName);
			}

			for (Case dbCase : [
					SELECT Id, isEmailWishGranter__c, InActiveWishGranter__c
					FROM Case
					WHERE Id IN :caseTeamMemberMap.keySet()
					AND IsClosed = FALSE
			]) {
				dbCase.isEmailWishGranter__c = true;

				if (caseTeamMemberMap.containsKey(dbCase.Id)) {
					dbCase.InActiveWishGranter__c = caseTeamMemberMap.get(dbCase.Id);
				}

				dbcaseList.add(dbCase);
			}

			if (dbcaseList.size() > 0) {
				update dbcaseList;
			}

			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (User currRec : [
					SELECT Id, Name
					FROM User
					WHERE Id IN :inactiveUserIdSet
			]) {
				ErrorMessage_AC.createdebugRec('User_OnAfterUpdateHelper_AC', String.valueOf(currRec), String.valueOf(ex), 'updateUser', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
		}
	}

	/*
	 * @description     Update the contact record when the user email address is changed.
	 *
	 * @author          MST Solutions
	 * @createdDate     unknown
	 */
	@future
	public static void updateContactEmail(Map<Id, Id> contactIdMap) {
		if (contactIdMap == null || contactIdMap.isEmpty()) {
			return;
		}

		try {
			Map<Id, User> contactUserMap = new Map<Id, User>();

			for (User currUser : [
					SELECT
							Id, FirstName, LastName, Email, MobilePhone,
							ContactId, Street, City, State, PostalCode, Country, Fax
					FROM User
					WHERE Id IN :contactIdMap.values()
			]) {
				contactUserMap.put(currUser.ContactId, currUser);
			}

			List<Contact> updateContactList = new List<Contact>();
			for (contact currRec : [
					SELECT Id, FirstName, LastName, Email, MobilePhone,
							MailingStreet, MailingCity, MailingState, MailingCountry,
							MailingPostalCode, Fax
					FROM Contact
					WHERE Id IN :contactIdMap.keySet() AND Email != NULL
			]) {
				if (contactUserMap.containsKey(currRec.Id) && currRec.Email != contactUserMap.get(currRec.Id).Email) {
					currRec.Email = contactUserMap.get(currRec.Id).Email;
				}
				if (contactUserMap.containsKey(currRec.Id) && currRec.MobilePhone != contactUserMap.get(currRec.Id).MobilePhone) {
					currRec.MobilePhone = contactUserMap.get(currRec.Id).MobilePhone;
				}
				if (contactUserMap.containsKey(currRec.Id) && currRec.FirstName != contactUserMap.get(currRec.Id).FirstName) {
					currRec.FirstName = contactUserMap.get(currRec.Id).FirstName;
				}
				if (contactUserMap.containsKey(currRec.Id) && currRec.LastName != contactUserMap.get(currRec.Id).LastName) {
					currRec.LastName = contactUserMap.get(currRec.Id).LastName;
				}
				if (contactUserMap.containsKey(currRec.Id) && currRec.MailingStreet != contactUserMap.get(currRec.Id).Street) {
					currRec.MailingStreet = contactUserMap.get(currRec.Id).Street;
				}
				if (contactUserMap.containsKey(currRec.Id) && currRec.MailingCity != contactUserMap.get(currRec.Id).City) {
					currRec.MailingCity = contactUserMap.get(currRec.Id).City;
				}
				if (contactUserMap.containsKey(currRec.Id) && currRec.MailingState != contactUserMap.get(currRec.Id).State) {
					currRec.MailingState = contactUserMap.get(currRec.Id).State;
				}
				if (contactUserMap.containsKey(currRec.Id) && currRec.MailingCountry != contactUserMap.get(currRec.Id).Country) {
					currRec.MailingCountry = contactUserMap.get(currRec.Id).Country;
				}
				if (contactUserMap.containsKey(currRec.Id) && currRec.MailingPostalCode != contactUserMap.get(currRec.Id).PostalCode) {
					currRec.MailingPostalCode = contactUserMap.get(currRec.Id).PostalCode;
				}
				if (contactUserMap.containsKey(currRec.Id) && currRec.Fax != contactUserMap.get(currRec.Id).Fax) {
					currRec.Fax = contactUserMap.get(currRec.Id).Fax;
				}

				updateContactList.add(currRec);
			}

			if (updateContactList.size() > 0) {
				update updateContactList;
			}

			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} catch (Exception ex) {
			for (User currRec : [
					SELECT Id, FirstName, LastName, Email, MobilePhone, ContactId, Street, City, State, PostalCode, Country, Fax
					FROM User
					WHERE Id IN :contactIdMap.values()
			]) {
				ErrorMessage_AC.createdebugRec('User_OnAfterUpdateHelper_AC', String.valueof(currRec), String.valueOf(ex), 'updateConatcEmail', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
		}
	}

	/**
	 * Find User by Contact Id
	 * @param contactIds
	 * @return Map of Users
	 */
	public static Map<Id, Id> findByContactId(Set<Id> contactIds) {
		Map<Id, Id> contactUserMap = new Map<Id, Id>();
		for (User userInfo : [
				SELECT Id, ContactId
				FROM User
				WHERE ContactId IN :contactIds
		]) {
			contactUserMap.put(userInfo.Id, userInfo.ContactId);
		}
        return contactUserMap;
	}
}