/***************************************************************************************************
Author      : MST Solutions
Date        : 
Description : User_OnAfterInsertHandler_AC is used to call the Helper class when the
              new user  record is created.
              
              Modification Log
              ------------------
              WVC-1889    Pavithra G 07/31/2018
              
*****************************************************************************************************/
Public class User_OnAfterInsertHandler_AC {
	Public static void OnAfterInsert(List<User> newUserList) {
		Map<Id, Id> newUserRoleIdMap = new Map<Id, Id>(); // Used to hold the new user role Id
		Set<string> userIdsSet = new Set<string>(); // useed to holds unique rolename
		Map<Id, User> prospectiveUserMap = new Map<Id, User>();
		for (User newUser : newUserList) {
			if (newUser.Migrated_User__c == false && newUser.created_from_portal__c == true) {
				if (newUser.State != null) {
					//newUserList.add(newUser);
				}

				if ((newUser.ProfileId == label.Prospective_Volunteer_Profile || newUser.ProfileId == String.valueOf(label.Active_Volunteer_Profile).trim()) && (newUser.contactId != Null))

				{
					prospectiveUserMap.put(newUser.contactId, newUser);
				}

				if (newUser.UserRoleId != null) {
					newUserRoleIdMap.put(newUser.Id, newUser.UserRoleId);
				}
			}
			if (newUser.Migrated_User__c == false && newUser.UserRoleId != Null) {
				userIdsSet.add(newUser.Id);

			}
		}
		if (prospectiveUserMap.size() > 0) {
			User_OnAfterInsertHelper_AC.UpdateVolunteerInfo(prospectiveUserMap);
		}

		//Used to add new user to chatter group based on their role name
		if (newUserRoleIdMap.size() > 0) {
			User_OnAfterInsertHelper_AC.AddInternalUserToChatterGroup(newUserRoleIdMap);
		}
	}
}