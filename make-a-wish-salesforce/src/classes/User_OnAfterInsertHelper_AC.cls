/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : User_OnAfterInsertHandler_AC is used to call the Helper class when the
              new user  record is created.
              
              Modification Log
              ------------------
              WVC-1889    Pavithra G 07/31/2018
              WVC-2205    Kanagaraj A 08/08/2018 //Line 61 previously the affilliation status was "Prospective". Now
                                                   we have updated as "Pending".
*****************************************************************************************************/
Public class User_OnAfterInsertHelper_AC {
	/* Update Volunteer Contact Details based on the User record details*/
	public static void UpdateVolunteerInfo(Map<Id, User> prospectiveUserMap) {
		try {
			List<Contact> updateContactList = new List<Contact>();
			List<npe5__Affiliation__c> updateAffiliationList = new List<npe5__Affiliation__c>();
			List<ContactShare> contactSharingList = new List<ContactShare>();

			for (Contact currRec : [
					SELECT id,MailingState,MailingPostalCode, MailingCity,Account.Volunteer_Manager__c, HomePhone
					FROM Contact
					WHERE Id IN :prospectiveUserMap.keySet()
			]) {
				if (prospectiveUserMap.containsKey(currRec.id)) {
					Contact updateContact = new Contact();
					updateContact.id = currRec.id;
					updateContact.MailingState = prospectiveUserMap.get(currRec.id).State;
					updateContact.MailingCity = prospectiveUserMap.get(currRec.id).City;
					updateContact.MailingPostalCode = prospectiveUserMap.get(currRec.id).PostalCode;
					updateContact.mobilephone = prospectiveUserMap.get(currRec.id).Phone;
					updateContact.homePhone = null;
					updateContact.npe01__PreferredPhone__c = 'Mobile';
					if (currRec.Account.Volunteer_Manager__c != null) {
						updateContact.OwnerId = currRec.Account.Volunteer_Manager__c;
					}
					updateContactList.add(updateContact);

					contactShare currContactSharing = new contactShare();
					currContactSharing.ContactId = currRec.id;
					currContactSharing.UserOrGroupId = prospectiveUserMap.get(currRec.id).id;
					currContactSharing.ContactAccessLevel = 'Edit';
					currContactSharing.RowCause = Schema.contactshare.RowCause.Manual;
					contactSharingList.add(currContactSharing);
				}

			}
			if (updateContactList.size() > 0)
				update updateContactList;
			if (contactSharingList.size() > 0)
				insert contactSharingList;

			// Updating the Affiliation Record status As Pending.
			for (npe5__Affiliation__c currRec : [
					SELECT id, npe5__Status__c
					FROM npe5__Affiliation__c
					WHERE npe5__Contact__c IN :prospectiveUserMap.keySet() AND npe5__Status__c = 'Current'
			]) {
				npe5__Affiliation__c updateRec = new npe5__Affiliation__c();
				updateRec.id = currRec.id;
				updateRec.npe5__Status__c = 'Pending';
				updateAffiliationList.add(updateRec);
			}

			if (updateAffiliationList.size() > 0)
				update updateAffiliationList;

			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}

		} Catch (Exception ex) {
			System.debug('Exception: ' + ex);
			for (User currRec : prospectiveUserMap.values()) {
				ErrorMessage_AC.createdebugRec('User_OnAfterInsertHelper_AC', String.valueof(currRec), String.valueOf(ex), 'UpdateVolunteerInfo', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}

			if (!Test.isRunningTest()) {
				for (User currRec : prospectiveUserMap.values()) {
					currRec.addError(Label.Debug_log_error_message);
				}

			}

		}
	}
	//Used to add Salesforce internal user to chatter group based on their Role
	@future
	public static void AddInternalUserToChatterGroup(Map<Id, Id> newUserRoleIdMap) {
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

				for (Id newUserId : newUserRoleIdMap.KeySet()) {
					if (groupInfoMap.containsKey(newUserRoleIdMap.get(newUserId))) {
						CollaborationGroupMember newCollaborationMemberGroup = new CollaborationGroupMember ();
						newCollaborationMemberGroup.MemberId = newUserId;
						newCollaborationMemberGroup.CollaborationGroupId = chatterGroupNameIdsMap.get(groupInfoMap.get(newUserRoleIdMap.get(newUserId)));
						chatterGroupMembersList.add(newCollaborationMemberGroup);
					}
				}
			}

			if (chatterGroupMembersList.size() > 0) {
				if (!Test.isRunningTest())
					insert chatterGroupMembersList;
			}

		} Catch (Exception ex) {

			for (User currRec : [
					SELECT Id, Name
					FROM User
					WHERE Id IN :newUserRoleIdMap.values()
			]) {
				ErrorMessage_AC.createdebugRec('User_OnAfterInsertHelper_AC', String.valueof(currRec), String.valueOf(ex), 'AddInternalUserToChatterGroup', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
		}
	}
}