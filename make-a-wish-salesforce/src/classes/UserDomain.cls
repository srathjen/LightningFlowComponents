/**
 * @description     Domain class for the User object
 *
 * @author          Chris Shinnimin, Traction on Demand
 * @date            2020-04-03
 */
public class UserDomain extends trac_TriggerHandlerBase {
    List<User> newUsersList = (List<User>) newRecordsList;
    List<User> oldUsersList = (List<User>) oldRecordsList;
    Map<Id, User> newUsersMap = (Map<Id, User>) newRecordsMap;
    Map<Id, User> oldUsersMap = (Map<Id, User>) oldRecordsMap;

    /*
     * @description		OnBeforeInsert trigger handler for the User object
     *
     * @author 			MST Solutions
     * @createdDate		2018-07-31
     */
    public override void handleBeforeInsert() {
        String DocuSignUserid = Label.DSProSFUsername;
        for (User newUser : newUsersList) {
            if (newUser.IsActive == true) {
                newUser.dsfs__DSProSFUsername__c = DocuSignUserid;
            }
        }
    }

    /*
     * @description		OnBeforeUpdate trigger handler for the User object
     *
     * @author 			MST Solutions
     * @createdDate		2018-07-31
     */
    public override void handleBeforeUpdate() {
        for (User newUser : newUsersList) {
            if (Bypass_Triggers__c.getValues(Utils.currentUser.Id) == null) {
                if (newUser.IsActive == false && oldUsersMap.get(newUser.Id).IsActive == true) {
                    newUser.Inactive_Date__c = System.today();
                }
                if (newUser.IsActive == true && oldUsersMap.get(newUser.Id).IsActive == false) {
                    newUser.Inactive_Date__c = null;
                }
                if (newUser.Email != null && newUser.Email != oldUsersMap.get(newUser.Id).Email && newUser.Hidden_Email__c == null) {
                    newUser.Hidden_Email__c = oldUsersMap.get(newUser.Id).Email;
                }
            }
        }
    }

    /*
     * @description		OnAfterInsert trigger handler for the User object
     *
     * @author 			MST Solutions
     * @createdDate		2018-07-31
     */
    public override void handleAfterInsert() {
        Map<Id, Id> newUserRoleIdMap = new Map<Id, Id>();
        Map<Id, User> prospectiveUserMap = new Map<Id, User>();

        for (User newUser : newUsersList) {
            if (newUser.Migrated_User__c == false && newUser.Created_from_Portal__c == true) {
                if ((newUser.ProfileId == Label.Prospective_Volunteer_Profile ||
                    newUser.ProfileId == String.valueOf(Label.Active_Volunteer_Profile).trim())
                    && (newUser.ContactId != null)) {

                    prospectiveUserMap.put(newUser.ContactId, newUser);
                }

                if (newUser.UserRoleId != null) {
                    newUserRoleIdMap.put(newUser.Id, newUser.UserRoleId);
                }
            }
        }

        if (prospectiveUserMap.size() > 0) { // avoid @future call if possible
            UserService.updateVolunteerInfo(prospectiveUserMap);
        }

        if (newUserRoleIdMap.size() > 0) { // avoid @future call if possible
            UserService.addInternalUserToChatterGroup(newUserRoleIdMap);
        }
    }

    /*
     * @description		OnAfterUpdate trigger handler for the User object
     *
     * @author 			MST Solutions
     * @createdDate		2018-07-31
     */
    public override void handleAfterUpdate() {
        Set<Id> inActiveUserIdSet = new Set<Id>();
        Set<Id> inactiveUserSet = new Set<Id>();
        Set<Id> activeUserSet = new Set<Id>();
        Map<Id, Id> newUserRoleIdMap = new Map<Id, Id>();
        Map<Id, Id> oldUserRoleIdMap = new Map<Id, Id>();
        Map<Id, Id> contactUserIdMap = new Map<Id, Id>();

        for (User newUser : newUsersList) {
            if (Bypass_Triggers__c.getValues(Utils.currentUser.Id) == null) {
                if (newUser.IsActive == false && oldUsersMap.get(newUser.Id).IsActive != newUser.IsActive) {
                    inActiveUserIdSet.add(newUser.Id);
                }
                if (newUser.ContactId != null && newUser.IsActive == false && oldUsersMap.get(newUser .Id).IsActive == true) {
                    inactiveUserSet.add(newUser.ContactId);
                }
                if (newUser.ContactId != null && newUser.IsActive == true && oldUsersMap.get(newUser.Id).IsActive == false) {
                    activeUserSet.add(newUser.ContactId);
                }

                if ((newUser.ContactId != null) &&
                    ((newUser.FirstName != null && oldUsersMap.get(newUser.Id).FirstName != newUser.FirstName) ||
                        (newUser.LastName != null && oldUsersMap.get(newUser.Id).LastName != newUser.LastName) ||
                        (newUser.MobilePhone != null && oldUsersMap.get(newUser.Id).MobilePhone != newUser.MobilePhone) ||
                        (newUser.Email != null && oldUsersMap.get(newUser.Id).Email != newUser.Email) ||
                        (newUser.Street != null && oldUsersMap.get(newUser.Id).Street != newUser.Street) ||
                        (newUser.City != null && oldUsersMap.get(newUser.Id).City != newUser.City) ||
                        (newUser.State != null && oldUsersMap.get(newUser.Id).State != newUser.State) ||
                        (newUser.PostalCode != null && oldUsersMap.get(newUser.Id).PostalCode != newUser.PostalCode) ||
                        (newUser.Country != null && oldUsersMap.get(newUser.Id).Country != newUser.Country) ||
                        (newUser.Fax != null && oldUsersMap.get(newUser.Id).Fax != newUser.Fax))
                    ) {
                    contactUserIdMap.put(newUser.ContactId, newUser.Id);
                }

            }

            if (newUser.UserRoleId != null && oldUsersMap.get(newUser.Id).UserRoleId != newUser.UserRoleId) {
                newUserRoleIdMap.put(newUser.Id, newUser.UserRoleId);
                oldUserRoleIdMap.put(newUser.Id, oldUsersMap.get(newUser.Id).UserRoleId);
            }
        }

        if (inActiveUserIdSet.size() > 0) { // avoid @future call if possible
            UserService.updateUser(inActiveUserIdSet);
        }

        if (inactiveUserSet.size() > 0) { // avoid @future call if possible
            BackgroundCheckService.toggleBackgroundCheckInactiveFlag(inactiveUserSet, true);
            ConflictOfInterestService.toggleConflictOfInterestInactiveFlag(inactiveUserSet, true);
        }

        if (activeUserSet.size() > 0) {
            Set<Id> activeVolunteerIdSet = new Set<Id>();

            for (npe5__Affiliation__c currAff : [
                SELECT Id, npe5__Status__c, npe5__Contact__c
                FROM npe5__Affiliation__c
                WHERE npe5__Contact__c IN :activeUserSet
            ]) {
                if (currAff.npe5__Status__c == Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE) {
                    activeVolunteerIdSet.add(currAff.npe5__Contact__c);
                }
            }

            if (activeVolunteerIdSet.size() > 0) { // avoid @future call if possible
                BackgroundCheckService.toggleBackgroundCheckInactiveFlag(activeVolunteerIdSet, false);
                ConflictOfInterestService.toggleConflictOfInterestInactiveFlag(activeVolunteerIdSet, false);
            }

        }

        if (newUserRoleIdMap.size() > 0) { // avoid @future call if possible
            UserService.addInternalUserToChatterGroup(newUserRoleIdMap);
        }

        if (oldUserRoleIdMap.size() > 0) { // avoid @future call if possible
            UserService.removeInternalUserToChatterGroup(oldUserRoleIdMap);
        }
        if (contactUserIdMap.size() > 0) { // avoid @future call if possible
            UserService.updateContactEmail(contactUserIdMap);
        }
    }
}