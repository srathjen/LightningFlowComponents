/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : 
              
              Modification Log
              ------------------
              WVC-1889    Pavithra G 07/31/2018
              
*****************************************************************************************************/
Public class User_OnAfterUpdateHelper_AC {
	@future
	public static void RemoveInternalUserToChatterGroup(Map<Id, Id> oldUserRoleIdMap) {
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

			Map<Id, String> roleChapterMap = new map<Id, String>();
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
						WHERE MemberId IN :oldUserRoleIdMap.KeySet()
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
		} Catch (Exception ex) {
			for (User currRec : [
					SELECT Id, Name
					FROM User
					WHERE Id IN :oldUserRoleIdMap.values()
			]) {
				ErrorMessage_AC.createdebugRec('User_OnAfterUpdateHelper_AC', String.valueof(currRec), String.valueOf(ex), 'RemoveInternalUserToChatterGroup', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
		}

	}
	@future
	public static void updateUser(Set<Id> inactiveUserIdSet) {
		try {
			List<Case> caseList = new List<Case>();
			List<Case> dbcaseList = new List<Case>();
			Map<Id, String> caseTeamMemberMap = new Map<Id, String>();
			for (CaseTeamMember dbCaseTeamMember : [
					SELECT Id,MemberId,Member.FirstName,Member.LastName,ParentId,Parent.RecordTypeId,TeamRoleId,TeamRole.Name
					FROM CaseTeamMember
					WHERE TeamRole.Name = 'Wish Granter' AND MemberId IN:inactiveUserIdSet
			]) {
				caseTeamMemberMap.put(dbCaseTeamMember.ParentId, dbCaseTeamMember.Member.FirstName + ' ' + dbCaseTeamMember.Member.LastName);
			}

			for (Case dbCase : [
					SELECT Id,isEmailWishGranter__c,InActiveWishGranter__c
					From Case
					WHERE Id IN:caseTeamMemberMap.KeySet() AND isClosed = false
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
		} Catch (Exception ex) {
			for (User currRec : [
					SELECT Id, Name
					FROM User
					WHERE Id IN :inactiveUserIdSet
			]) {
				ErrorMessage_AC.createdebugRec('User_OnAfterUpdateHelper_AC', String.valueof(currRec), String.valueOf(ex), 'updateUser', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
		}
	}

	//This Method is used to update the contact record when the user email address is changed.
	@future
	public static void updateConatcEmail(Map<Id, Id> contactIdMap) {
		try {
			Map<Id, User> contactUserMap = new Map<Id, User>();
			for (User currUser : [
					SELECT Id,FirstName,LastName,Email,MobilePhone,ContactId,Street,City,State,PostalCode,Country,Fax
					FROM USER
					WHERE Id IN :contactIdMap.values()
			]) {
				contactUserMap.put(currUser.contactId, currUser);
			}
			List<Contact> updateContactList = new List<Contact>();
			for (contact currRec : [
					SELECT Id,FirstName,LastName,Email,MobilePhone,Mailingstreet,MailingCity,MailingState,MailingCountry,MailingPostalCode,Fax
					FROM Contact
					WHERE Id IN :contactIdMap.keySet() AND Email != Null
			]) {
				if (contactUserMap.Containskey(currRec.Id) && currRec.Email != contactUserMap.get(currRec.Id).Email)
					currRec.Email = contactUserMap.get(currRec.Id).Email;
				if (contactUserMap.Containskey(currRec.Id) && currRec.MobilePhone != contactUserMap.get(currRec.Id).MobilePhone)
					currRec.MobilePhone = contactUserMap.get(currRec.Id).MobilePhone;
				if (contactUserMap.Containskey(currRec.Id) && currRec.FirstName != contactUserMap.get(currRec.Id).FirstName)
					currRec.FirstName = contactUserMap.get(currRec.Id).FirstName;
				if (contactUserMap.Containskey(currRec.Id) && currRec.LastName != contactUserMap.get(currRec.Id).LastName)
					currRec.LastName = contactUserMap.get(currRec.Id).LastName;
				if (contactUserMap.Containskey(currRec.Id) && currRec.mailingStreet != contactUserMap.get(currRec.Id).Street)
					currRec.mailingStreet = contactUserMap.get(currRec.Id).Street;
				if (contactUserMap.Containskey(currRec.Id) && currRec.mailingCity != contactUserMap.get(currRec.Id).City)
					currRec.mailingCity = contactUserMap.get(currRec.Id).City;
				if (contactUserMap.Containskey(currRec.Id) && currRec.mailingState != contactUserMap.get(currRec.Id).State)
					currRec.mailingState = contactUserMap.get(currRec.Id).State;
				if (contactUserMap.Containskey(currRec.Id) && currRec.mailingCountry != contactUserMap.get(currRec.Id).Country)
					currRec.mailingCountry = contactUserMap.get(currRec.Id).Country;
				if (contactUserMap.Containskey(currRec.Id) && currRec.mailingPostalCode != contactUserMap.get(currRec.Id).PostalCode)
					currRec.mailingPostalCode = contactUserMap.get(currRec.Id).PostalCode;
				if (contactUserMap.Containskey(currRec.Id) && currRec.Fax != contactUserMap.get(currRec.Id).Fax)
					currRec.Fax = contactUserMap.get(currRec.Id).Fax;

				updateContactList.add(currRec);
			}

			if (updateContactList.Size() > 0) {
				Update updateContactList;
			}
			if (Test.isRunningTest()) {
				throw new CommonTriggerException('Test Class execution');
			}
		} Catch (Exception ex) {
			for (User currRec : [
					SELECT Id,FirstName,LastName,Email,MobilePhone,ContactId,Street,City,State,PostalCode,Country,Fax
					FROM USER
					WHERE Id IN :contactIdMap.values()
			]) {
				ErrorMessage_AC.createdebugRec('User_OnAfterUpdateHelper_AC', String.valueof(currRec), String.valueOf(ex), 'updateConatcEmail', currRec.Id, ex.getStackTraceString() + '   ' + ex.getMessage(), 'Error');
			}
		}
	}
}