/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : User_OnAfterUpdateHandler_AC is used to call the Helper class when the
              new user  record is Updated.
              
              Modification Log
              ------------------
              WVC-1889    Pavithra G 07/31/2018
              
*****************************************************************************************************/
Public class User_OnAfterUpdateHandler_AC {
	Public static void OnAfterUpdate(List<User> newUserList, Map<Id, User> oldUserMap) {
		Set<Id> inActiveUserIdSet = new Set<Id>();
		Set<Id> inactiveUserSet = new Set<Id>();
		Set<Id> activeUserSet = new Set<Id>();
		Map<Id, Id> newUserRoleIdMap = new Map<Id, Id>(); // Used to hold the new user role Id
		Map<Id, Id> oldUserRoleIdMap = new Map<Id, Id>(); // Used to hold the new user role Id
		Set<string> userIdsSet = new Set<string>(); // useed to holds unique rolename
		Map<Id, Id> contactUSerIdMap = new Map<Id, Id>(); // used to hold the contact id and user id.
		for (User newUser : newUserList) {
			if (Bypass_Triggers__c.getValues(userInfo.getUserId()) == Null) {
				if (newUser.IsActive == false && oldUserMap.get(newUser.Id).IsActive != newUser.IsActive) {
					inActiveUserIdSet.add(newUser.Id);
				}
				if (newUser.ContactId != Null && newUser.IsActive == false && oldUserMap.get(newUser .id).IsActive == True) {
					inactiveUserSet.add(newUser.ContactId);
				}

				if (newUser.ContactId != Null && newUser.IsActive == True && oldUserMap.get(newUser .id).IsActive == False) {
					activeUserSet.add(newUser.ContactId);
				}

				if (newUser.UserRoleId != Null && newUser.UserRoleId != oldUserMap.get(newUser.id).UserRoleId) {
					userIdsSet.add(newUser.id);
				}

				if ((newUser.ContactId != Null) && ((newUser.FirstName != Null && oldUserMap.get(newUser.id).FirstName != newUser.FirstName) || (newUser.LastName != Null && oldUserMap.get(newUser.id).LastName != newUser.LastName) || (newUser.mobilePhone != Null && oldUserMap.get(newUser.id).mobilePhone != newUser.mobilePhone) || (newUser.Email != Null && oldUserMap.get(newUser.id).Email != newUser.Email) ||
						(newUser.Street != Null && oldUserMap.get(newUser.id).Street != newUser.Street) || (newUser.City != Null && oldUserMap.get(newUser.id).City != newUser.City) || (newUser.state != Null && oldUserMap.get(newUser.id).state != newUser.state) || (newUser.postalcode != Null && oldUserMap.get(newUser.id).postalcode != newUser.postalcode) ||
						(newUser.Country != Null && oldUserMap.get(newUser.id).Country != newUser.Country) || (newUser.Fax != Null && oldUserMap.get(newUser.id).Fax != newUser.Fax))) {
					contactUSerIdMap.put(newUser.ContactId, newUser.Id);
				}

			}

			if (newUser.UserRoleId != null && oldUserMap.get(newUser.Id).UserRoleId != newUser.UserRoleId) {
				newUserRoleIdMap.put(newUser.Id, newUser.UserRoleId);
				oldUserRoleIdMap.put(newUser.Id, oldUserMap.get(newUser.Id).UserRoleId);
			}
		}

		if (inActiveUserIdSet.size() > 0) {
			User_OnAfterUpdateHelper_AC.updateUser(inActiveUserIdSet);
		}

		if (inactiveUserSet.size() > 0 && inactiveUserSet != Null) {
			InactiveVolunteerHandler.createTaskforVolunteerManager(inactiveUserSet);
			InactiveVolunteerHandler.updateBCandCOIVolunteerInactive(inactiveUserSet, True);
		}
		if (activeUserSet.Size() > 0) {
			Set<Id> activeVolunteerIdSet = new Set<Id>();
			for (npe5__Affiliation__c currAff : [
					SELECT id,npe5__Status__c,npe5__Contact__c
					FROM npe5__Affiliation__c
					WHERE npe5__Contact__c IN :activeUserSet
			]) {

				if (currAff.npe5__Status__c == 'Active') {
					activeVolunteerIdSet.add(currAff.npe5__Contact__c);
				}
			}
			if (activeVolunteerIdSet.Size() > 0) {
				InactiveVolunteerHandler.updateBCandCOIVolunteerInactive(activeVolunteerIdSet, False);
			}

		}
		//Used to add new user to chatter group based on their role name
		if (newUserRoleIdMap.size() > 0) {
			User_OnAfterInsertHelper_AC.AddInternalUserToChatterGroup(newUserRoleIdMap);
		}

		if (oldUserRoleIdMap.size() > 0) {
			User_OnAfterUpdateHelper_AC.RemoveInternalUserToChatterGroup(oldUserRoleIdMap);
		}
		if (contactUSerIdMap.size() > 0) {
			User_OnAfterUpdateHelper_AC.updateConatcEmail(contactUSerIdMap);
		}
	}
}