/**
 * @description
 *
 * @author Steve Doucette, Traction on Demand
 *
 * @date 4/22/2020
 */
public class VolunteerOTService {

    private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;
    private final static String VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_NOT_APPROVED = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_NOT_APPROVED;
    private final static String VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_FOLLOW_UP_REQUESTED = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_FOLLOW_UP_REQUESTED;
    private final static String VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING;
    private final static String VOLUNTEER_ORIENTATION_TRAINING_TYPE_ORIENTATION = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_TYPE_ORIENTATION;
    private final static String VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED;
    private final static String VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED;
    private final static String VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED = Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED;

    private final static String USER_VOLUNTEER_ORIENTATION_STATUS_CANCELLED = Constant_AC.USER_VOLUNTEER_ORIENTATION_STATUS_CANCELLED;
    private final static String USER_VOLUNTEER_ORIENTATION_STATUS_REGISTERED = Constant_AC.USER_VOLUNTEER_ORIENTATION_STATUS_REGISTERED;

    private final static String ACTION_TRAINING = 'Training';
    private final static String ACTION_REGISTERED = 'Registered';
    private final static String ACTION_ORIENTATION = 'Orientation';
    private final static String ACTION_VOLUNTEER_CANCELLED = 'Volunteer Cancelled';

    /**
     * @description Updating Affiliation status as Active.
     *
     * @param volunteerContactIds
     */
    public static void updateAffiliationStatusAsActive(Set<Id> volunteerContactIds) {
        if (volunteerContactIds.isEmpty()) {
            return;
        }

        Id trainingRecordTypeId = Constant_AC.TRAINING_RT_ID;
        Set<Id> backGroundContactIdsSet = new Set<Id>();
        for (Background_check__c dbbackgroundCheckRec : [
                SELECT Id, Current__c, Date__c, Volunteer__c
                FROM Background_check__c
                WHERE Volunteer__c IN :volunteerContactIds
                AND Date__c > :Date.today()
        ]) {
            backGroundContactIdsSet.add(dbbackgroundCheckRec.Volunteer__c);
        }

        Set<Id> coiContactIdsSet = new Set<Id>();
        for (Conflict_Of_Interest__c dbconflictInterestRec : [
                SELECT Id, Expiration_Date__c, Volunteer_Contact__c
                FROM Conflict_Of_Interest__c
                WHERE Volunteer_Contact__c IN :volunteerContactIds
                AND Expiration_Date__c > :Date.today()
        ]) {
            coiContactIdsSet.add(dbconflictInterestRec.Volunteer_Contact__c);
        }

        Set<Id> chapterRoleIds = new Set<Id>();
        Map<Id, Set<Id>> contactChapterRolesMap = new Map<Id, Set<Id>>();
        Map<String, Id> volunteerRoleMap = new Map<String, Id>();
        for (Volunteer_Roles__c currRec : [
                SELECT Id, Chapter_Role__c,Volunteer_Name__c
                FROM Volunteer_Roles__c
                WHERE Volunteer_Name__c IN :volunteerContactIds
        ]) {
            chapterRoleIds.add(currRec.Chapter_Role__c);
            if (contactChapterRolesMap.containsKey(currRec.Volunteer_Name__c)) {
                contactChapterRolesMap.get(currRec.Volunteer_Name__c).add(currRec.Chapter_Role__c);
            } else {
                contactChapterRolesMap.put(currRec.Volunteer_Name__c, new Set<Id>{
                        currRec.Chapter_Role__c
                });
            }
            volunteerRoleMap.put(currRec.Volunteer_Name__c + '-' + currRec.Chapter_Role__c, currRec.Id);
        }

        Map<Id, Set<Id>> chapterRoleOandTMap = new Map<Id, Set<Id>>();
        Set<Id> orientationIds = new Set<Id>();
        for (Class_Offering__c currRec : [
                SELECT Id, Chapter_Role_O_T__r.Chapter_Role__c,Date__c,End_Time__c,Location__c,Chapter_Role_O_T__r.Orientation_Training__c
                FROM Class_Offering__c
                WHERE Chapter_Role_O_T__r.Chapter_Role__c IN :chapterRoleIds
                AND (Date__c > :Date.today() OR Date__c = NULL)
                AND Chapter_Role_O_T__r.Required__c = TRUE
                AND Chapter_Role_O_T__r.Orientation_Training__r.RecordTypeId = :trainingRecordTypeId
        ]) {
            orientationIds.add(currRec.Chapter_Role_O_T__r.Orientation_Training__c);
            if (chapterRoleOandTMap.containsKey(currRec.Chapter_Role_O_T__r.Chapter_Role__c)) {
                chapterRoleOandTMap.get(currRec.Chapter_Role_O_T__r.Chapter_Role__c).add(currRec.Chapter_Role_O_T__r.Orientation_Training__c);
            } else {
                chapterRoleOandTMap.put(currRec.Chapter_Role_O_T__r.Chapter_Role__c, new Set<Id>{
                        currRec.Chapter_Role_O_T__r.Orientation_Training__c
                });
            }
        }

        /**
         * JIRA: WLP-422
         * Author: Gustavo Mayer
         * Update: Adding the Completion Status of the Training as a condition
         */
        Map<Id, List<Volunteer_Orientation_Training__c>> volunteerTrainingMap = new Map<Id, List<Volunteer_Orientation_Training__c>>();
        for (Volunteer_Orientation_Training__c currTraining : [
                SELECT Id, Volunteer__c,Hidden_O_T_Id__c
                FROM Volunteer_Orientation_Training__c
                WHERE Volunteer__c IN :volunteerContactIds
                AND Hidden_O_T_Id__c IN :orientationIds
                AND Type__c = :VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING
                AND Volunteer_Attendance__c = :VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED
                AND Completion_Status__c NOT IN (:VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_NOT_APPROVED,
                        :VOLUNTEER_ORIENTATION_TRAINING_COMPLETION_FOLLOW_UP_REQUESTED)
        ]) {
            if (!volunteerTrainingMap.containsKey(currTraining.Hidden_O_T_Id__c)) {
                volunteerTrainingMap.put(currTraining.Hidden_O_T_Id__c, new List<Volunteer_Orientation_Training__c>());
            }
            volunteerTrainingMap.get(currTraining.Hidden_O_T_Id__c).add(currTraining);
        }

        Set<Id> contactIds = new Set<Id>();
        Set<String> activeChapterRoleIds = new Set<String>();
        for (Id currConId : volunteerContactIds) {
            if (contactChapterRolesMap.containsKey(currConId)) {
                for (Id currChapRolId : contactChapterRolesMap.get(currConId)) {
                    Integer trainingSize = 0;
                    if (chapterRoleOandTMap.containsKey(currChapRolId)) {
                        for (Id currOrientationId : chapterRoleOandTMap.get(currChapRolId)) {
                            if (volunteerTrainingMap.containsKey(currOrientationId)) {
                                for (Volunteer_Orientation_Training__c Training : volunteerTrainingMap.get(currOrientationId)) {
                                    trainingSize++;
                                }
                            }
                        }
                        if (trainingSize == (chapterRoleOandTMap.get(currChapRolId).size())) {
                            contactIds.add(currConId);
                            activeChapterRoleIds.add(currConId + '-' + currChapRolId);
                        }
                    }
                }
            }
        }

        Set<Id> activeContactIdsSet = new Set<Id>();
        List<npe5__Affiliation__c> affiliationList = new List<npe5__Affiliation__c>();
        for (npe5__Affiliation__c dbAffiliationRec : [
                SELECT Id,npe5__Contact__c,npe5__Primary__c,npe5__Status__c,npe5__Organization__c
                FROM npe5__Affiliation__c
                WHERE npe5__Contact__c IN:contactIds
        ]) {

            if (coiContactIdsSet.contains(dbAffiliationRec.npe5__Contact__c)) {
                npe5__Affiliation__c updateAff = new npe5__Affiliation__c();
                updateAff.Id = dbAffiliationRec.Id;
                updateAff.npe5__Status__c = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
                affiliationList.add(updateAff);
                activeContactIdsSet.add(dbAffiliationRec.npe5__Contact__c);
            }
        }

        List<Volunteer_Roles__c> volRoleList = new List<Volunteer_Roles__c>();
        for (String currString : activeChapterRoleIds) {
            if (volunteerRoleMap.containsKey(currString)) {
                Volunteer_Roles__c updateRec = new Volunteer_Roles__c();
                updateRec.Id = volunteerRoleMap.get(currString);
                updateRec.Status__c = VOLUNTEER_ROLE_STATUS_ACTIVE;
                volRoleList.add(updateRec);
            }
        }

        if (affiliationList.size() > 0) {
            update affiliationList;
            if (activeContactIdsSet.size() > 0) {
                updateUserFuture(activeContactIdsSet);
            }
            update volRoleList;
        }

        List<Contact> updateContactList = new List<Contact>();

        for (Id currContactId : volunteerContactIds) {
            Contact updateCon = new Contact();
            updateCon.Id = currContactId;
            updateCon.Last_Continuing_Edu_Date__c = Date.today();
            updateCon.Date_of_last_engagement__c = Date.today();
            updateContactList.add(updateCon);
        }
        update updateContactList;
    }

    /**
     * @description This method is used to update the volunteer contact field to send an email to volunteer.
     *
     * @param volunteerOrientationTrainingList
     */
    public static void updateContactRec(List<Volunteer_Orientation_Training__c> volunteerOrientationTrainingList) {
        if (volunteerOrientationTrainingList.isEmpty()) {
            return;
        }
        Id classOfferingRT = Constant_AC.CLASS_OFFERING_RECORD_TYPE_ID;
        String status;
        Map<Id, Id> volunteerOandTMap = new Map<Id, Id>();
        Set<Id> volunteerIdSet = new Set<Id>();
        Set<Id> currentId = new Set<Id>();
        for (Volunteer_Orientation_Training__c processVolunteerOpp : volunteerOrientationTrainingList) {
            volunteerOandTMap.put(processVolunteerOpp.Class_Offering__c, processVolunteerOpp.Volunteer__c);
            volunteerIdSet.add(processVolunteerOpp.Volunteer__c);
            status = processVolunteerOpp.Volunteer_Attendance__c;
            if (processVolunteerOpp.Id != null) {
                currentId.add(processVolunteerOpp.Id);
            }
        }
        if (volunteerOandTMap.isEmpty()) {
            return;
        }

        Map<Id, Class_Offering__c> classOffringMap = new Map<Id, Class_Offering__c>();
        for (Class_Offering__c dbClassOffering : [
                SELECT Id,Chapter_Role_O_T__c,RecordTypeId
                FROM Class_Offering__c
                WHERE Id IN :volunteerOandTMap.keySet() AND RecordTypeId = :classOfferingRT
        ]) {
            if (volunteerOandTMap.containsKey(dbClassOffering.Id)) {
                classOffringMap.put(dbClassOffering.Id, dbClassOffering);
            }
        }
        if (classOffringMap.isEmpty()) {
            return;
        }

        Map<Id, User> UserMap = new Map<Id, User>();
        for (User dbUser : [
                SELECT Id, Username, ContactId, ProfileId, Profile.Name
                FROM User
                WHERE ContactId IN:volunteerIdSet AND (Profile.Id = :Label.Prospective_Volunteer_Profile)
        ]) {
            UserMap.put(dbUser.ContactId, dbUser);
        }
        if (UserMap.isEmpty()) {
            return;
        }

        Boolean isCanceled = false;
        Set<Id> dbSet = new Set<Id>();
        if (status == Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED && !currentId.isEmpty()) {
            for (Volunteer_Orientation_Training__c dbVolunteerOrientation : [
                    SELECT Id,Volunteer__c,Type__c,Volunteer_Attendance__c
                    FROM Volunteer_Orientation_Training__c
                    WHERE Volunteer__c IN :UserMap.keySet()
                    AND Type__c = :Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING AND Id NOT IN :currentId
            ]) {
                if (dbVolunteerOrientation.Volunteer_Attendance__c == Constant_AC.VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED) {
                    dbSet.add(dbVolunteerOrientation.Id);
                }
            }
            if (dbSet.isEmpty()) {
                isCanceled = true;
            }
        }

        for (Volunteer_Orientation_Training__c processVolunteerOpp : volunteerOrientationTrainingList) {
            if (classOffringMap.containsKey(processVolunteerOpp.Class_Offering__c) && UserMap.containsKey(processVolunteerOpp.Volunteer__c)) {
                if (processVolunteerOpp.Volunteer_Attendance__c != VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED) {
                    processVolunteerOpp.Hidden_Volunteer_Training_Status__c = processVolunteerOpp.Volunteer_Attendance__c;
                }
                if (processVolunteerOpp.Volunteer_Attendance__c == VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED && isCanceled == true) {
                    processVolunteerOpp.Hidden_Volunteer_Training_Status__c = processVolunteerOpp.Volunteer_Attendance__c;
                }
                processVolunteerOpp.Hidden_Volunteer_User_Name__c = UserMap.get(processVolunteerOpp.Volunteer__c).Username;
            }
        }
    }

    /**
     * @description
     *
     * @param newList
     */
    public static void setVolOTFields(List<Volunteer_Orientation_Training__c> newList) {
        setVolOTFields(newList, null);
    }

    /**
     * @description
     *
     * @param newList
     * @param oldMap
     */
    public static void setVolOTFields(List<Volunteer_Orientation_Training__c> newList, Map<Id, Volunteer_Orientation_Training__c> oldMap) {
        Set<Id> volunteerIds = getVolunteerIds(newList);
        Map<Id, Contact> contactInfoMap = new Map<Id, Contact>();
        if (!volunteerIds.isEmpty()) {
            for (Contact getContactInfo : [
                    SELECT Id, Name, Account.Name, Account.Phone,Email,Account.Email__c
                    FROM Contact
                    WHERE Id IN :getVolunteerIds(newList)
            ]) {
                if (!contactInfoMap.containsKey(getContactInfo.Id)) {
                    contactInfoMap.put(getContactInfo.Id, getContactInfo);
                }
            }
        }

        Set<Id> classOfferingIds = getClassOfferingIds(newList, oldMap);
        Map<String, String> orientationIdMap = new Map<String, String>();
        if (!classOfferingIds.isEmpty()) {
            for (Class_Offering__c currRec : [
                    SELECT Id,Chapter_Role_O_T__r.Orientation_Training__c
                    FROM Class_Offering__c
                    WHERE Id IN :classOfferingIds
            ]) {
                orientationIdMap.put(currRec.Id, currRec.Chapter_Role_O_T__r.Orientation_Training__c);
            }
        }

        for (Volunteer_Orientation_Training__c currRec : newList) {
            if (!trac_TriggerHandlerBase.blockTrigger) {
                if (currRec.Volunteer__c != null && contactInfoMap.containsKey(currRec.Volunteer__c)) {
                    currRec.Account_Name__c = contactInfoMap.get(currRec.Volunteer__c).Account.Name;
                    currRec.Account_Phone__c = contactInfoMap.get(currRec.Volunteer__c).Account.Phone;
                    currRec.VolunteerHidden_Email__c = contactInfoMap.get(currRec.Volunteer__c).Email;
                    currRec.Account_Email__c = contactInfoMap.get(currRec.Volunteer__c).Account.Email__c;
                }

                //Update the hidden O&T Id field with the orientation and training Id.
                if (currRec.Class_Offering__c != null && currRec.Class_Offering__c != null && orientationIdMap.containsKey(currRec.Class_Offering__c)) {
                    currRec.Hidden_O_T_Id__c = orientationIdMap.get(currRec.Class_Offering__c);
                }
            }
        }
    }

    /**
     * @description
     *
     * @param volIdsSet
     * @param action
     */
    public static void updateVolunteerHiddenVolOTStatus(Set<Id> volIdsSet, String action) {
        if (volIdsSet.isEmpty()) {
            return;
        }
        List<Contact> updateContactList = new List<Contact>();
        for (Contact currentCon : [
                SELECT Id, Hidden_Volunteer_OT_Status__c
                FROM Contact
                WHERE Id IN :volIdsSet
        ]) {
            if (action == ACTION_TRAINING) {
                currentCon.Hidden_Volunteer_OT_Status__c = Constant_AC.CONTACT_HIDDEN_VOLUNTEER_STATUS_TRAINING_REGISTERED;
            } else if (action == ACTION_ORIENTATION) {
                currentCon.Hidden_Volunteer_OT_Status__c = Constant_AC.CONTACT_HIDDEN_VOLUNTEER_STATUS_ORIENTATION_COMPLETED;
            }
            updateContactList.add(currentCon);
        }
        update updateContactList;
    }

    /**
     * @description
     *
     * @param volunteerContactIds
     * @param Action
     */
    public static void updateUserVolunteerStatus(Set<Id> volunteerContactIds, String Action) {
        if (volunteerContactIds.isEmpty()) {
            return;
        }
        List<User> userUpdateList = new List<User>();
        for (User userUpdate : [
                SELECT Id, Volunteer_Orientation_Status__c, Profile.Name
                FROM User
                WHERE ContactId IN :volunteerContactIds AND (Profile.Name = :Label.Prospective_Volunteer_Profile)
        ]) {
            if (Action == ACTION_REGISTERED) {
                userUpdate.Volunteer_Orientation_Status__c = USER_VOLUNTEER_ORIENTATION_STATUS_REGISTERED;
            } else if (Action == ACTION_VOLUNTEER_CANCELLED) {
                userUpdate.Volunteer_Orientation_Status__c = USER_VOLUNTEER_ORIENTATION_STATUS_CANCELLED;
            }
            userUpdateList.add(userUpdate);
        }
        update userUpdateList;
    }

    // Return set of volunteer Ids from VOT records
    public static Set<Id> getVolunteerIds(List<Volunteer_Orientation_Training__c> newList) {
        Set<Id> ret = new Set<Id>();
        for (Volunteer_Orientation_Training__c currRec : newList) {
            if (currRec.Volunteer__c != null) {
                ret.add(currRec.Volunteer__c);
            }
        }
        return ret;
    }

    // Return set of Ids for registered orientation volunteers
    public static Set<Id> getRegisteredOrientationVolunteerIds(List<Volunteer_Orientation_Training__c> newList) {
        return getRegisteredOrientationVolunteerIds(newList, null);
    }
    public static Set<Id> getRegisteredOrientationVolunteerIds(List<Volunteer_Orientation_Training__c> newList, Map<Id, Volunteer_Orientation_Training__c> oldMap) {
        Set<Id> ret = new Set<Id>();
        for (Volunteer_Orientation_Training__c currRec : newList) {
            if (currRec.Type__c == VOLUNTEER_ORIENTATION_TRAINING_TYPE_ORIENTATION
                    && (oldMap == null || currRec.Volunteer_Attendance__c == VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED && oldMap.get(currRec.Id).Volunteer_Attendance__c != VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED)) {
                ret.add(currRec.Volunteer__c);
            }
        }
        return ret;
    }

    // Return set of Ids for registered orientation volunteers
    public static Set<Id> getCompletedOrientationVolunteerIds(List<Volunteer_Orientation_Training__c> newList) {
        return getRegisteredOrientationVolunteerIds(newList, null);
    }
    public static Set<Id> getCompletedOrientationVolunteerIds(List<Volunteer_Orientation_Training__c> newList, Map<Id, Volunteer_Orientation_Training__c> oldMap) {
        Set<Id> ret = new Set<Id>();
        for (Volunteer_Orientation_Training__c currRec : newList) {
            if (currRec.Type__c == VOLUNTEER_ORIENTATION_TRAINING_TYPE_ORIENTATION
                    && (oldMap == null || currRec.Volunteer_Attendance__c == VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED && oldMap.get(currRec.Id).Volunteer_Attendance__c != VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED)) {
                ret.add(currRec.Volunteer__c);
            }
        }
        return ret;
    }

    // Return set of Ids for completed training volunteers
    public static Set<Id> getTrainingCompletedVolunteerIds(List<Volunteer_Orientation_Training__c> newList) {
        Set<Id> ret = new Set<Id>();
        for (Volunteer_Orientation_Training__c currRec : newList) {
            if (currRec.Type__c == VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING
                    && currRec.Volunteer_Attendance__c == VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED) {
                ret.add(currRec.Volunteer__c);
            }
        }
        return ret;
    }

    // Return set of Ids for registered training volunteers
    public static Set<Id> getTrainingRegisteredVolunteerIds(List<Volunteer_Orientation_Training__c> newList) {
        Set<Id> ret = new Set<Id>();
        for (Volunteer_Orientation_Training__c currRec : newList) {
            if (currRec.Type__c == VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING
                    && currRec.Volunteer_Attendance__c == VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED) {
                ret.add(currRec.Volunteer__c);
            }
        }
        return ret;
    }

    // Return list of VOT records of type training and valid status
    public static List<Volunteer_Orientation_Training__c> getTrainingVOTRecords(List<Volunteer_Orientation_Training__c> newList) {
        List<Volunteer_Orientation_Training__c> ret = new List<Volunteer_Orientation_Training__c>();
        for (Volunteer_Orientation_Training__c currRec : newList) {
            if (currRec.Type__c == VOLUNTEER_ORIENTATION_TRAINING_TYPE_TRAINING
                    && (currRec.Volunteer_Attendance__c == VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_REGISTERED || currRec.Volunteer_Attendance__c == VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_COMPLETED || currRec.Volunteer_Attendance__c == VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED)) {
                ret.add(currRec);
            }
        }
        return ret;
    }

    // Return set of volunteer Ids from cancelled VOT records
    public static Set<Id> getCancelledTrainingVolunteers(List<Volunteer_Orientation_Training__c> newList, Map<Id, Volunteer_Orientation_Training__c> oldMap) {
        Set<Id> ret = new Set<Id>();
        for (Volunteer_Orientation_Training__c currRec : newList) {
            if (currRec.Type__c == VOLUNTEER_ORIENTATION_TRAINING_TYPE_ORIENTATION
                    && (oldMap == null || currRec.Volunteer_Attendance__c == VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED && oldMap.get(currRec.Id).Volunteer_Attendance__c != VOLUNTEER_ORIENTATION_TRAINING_VOLUNTEER_ATTENDANCE_VOLUNTEER_CANCELLED)) {
                ret.add(currRec.Volunteer__c);
            }
        }
        return ret;
    }

    // Return set of class offering Ids from VOT records
    public static Set<Id> getClassOfferingIds(List<Volunteer_Orientation_Training__c> newList, Map<Id, Volunteer_Orientation_Training__c> oldMap) {
        Set<Id> ret = new Set<Id>();
        for (Volunteer_Orientation_Training__c currRec : newList) {
            if (currRec.Volunteer__c != null && currRec.Class_Offering__c != null
                    && (oldMap == null || oldMap.get(currRec.Id).Class_Offering__c != currRec.Class_Offering__c)) {
                ret.add(currRec.Class_Offering__c);
            }
        }
        return ret;
    }

    /**
     * @description
     *
     * @param userIds
     */
    @Future
    public static void updateUserFuture(Set<Id> userIds) {
        if (userIds.isEmpty()) {
            return;
        }
        String prospectiveProfileId = Label.Prospective_Volunteer_Profile;
        List<User> updateUserList = new List<User>();
        for (User currUser : [
                SELECT Id, ProfileId
                FROM User
                WHERE ContactId IN :userIds AND ProfileId = :prospectiveProfileId
        ]) {
            User newUser = new User();
            newUser.Id = currUser.Id;
            newUser.ProfileId = Label.Active_Volunteer_Profile;
            updateUserList.add(newUser);
        }
        update updateUserList;
    }
}