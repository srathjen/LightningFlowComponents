/**
 * @description Background Check Service, centralizes Background Check business rules
 * @author Michelle Cominotto, Make-A-Wish
 * @createdDate 3/18/2020
 */
public with sharing class BackgroundCheckService {
    
    private final static String AFFILIATION_STATUS_ACTIVE = Constant_AC.ORG_AFFILIATION_STATUS_ACTIVE;
    private final static String AFFILIATION_STATUS_NOT_APPROVED = Constant_AC.ORG_AFFILIATION_STATUS_NOT_APPROVED;
    private final static String VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE = Constant_AC.VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE;
    private final static String VOLUNTEER_ROLE_STATUS_FORMER = Constant_AC.VOLUNTEER_ROLE_STATUS_FORMER;
    private final static String VOLUNTEER_ROLE_STATUS_NOT_APPROVED = Constant_AC.VOLUNTEER_ROLE_STATUS_NOT_APPROVED;
    private final static String HIDDEN_ORIENTATION_STATUS_ROLE_SPECIFIC_TRAINING_AVAILABLE = Constant_AC.CONTACT_STATUS_ROLE_SPECIFIC_TRAINING_AVAILABLE;
    private final static Id TASK_BACKGROUND_CHECK_RT = Constant_AC.BACKGROUND_RT_ID;
    private final static String TASK_SUBJECT_REVIEW_BACKGROUND_CHECK = Constant_AC.TASK_SUBJECT_REVIEW_BACKGROUND_CHECK;
    private final static String ROLE_NATIONAL_STAFF = Constant_AC.ROLE_NATIONAL_STAFF;
    private final static String PROFILE_INTEGRATION = Constant_AC.PROFILE_INTEGRATION;
    private final static String PROFILE_SYSTEM_ADMINISTRATOR = Constant_AC.PROFILE_INTEGRATION;
    private final static String BACKGROUND_CHECK_STATUS_REJECTED = Constant_AC.BACKGROUND_CHECK_STATUS_REJECTED;
    private final static String BACKGROUND_CHECK_STATUS_APPROVED = Constant_AC.BACKGROUND_CHECK_STATUS_APPROVED;
    private final static String BACKGROUND_CHECK_STATUS_APPROVED_WITH_CONDITIONS = Constant_AC.BACKGROUND_CHECK_STATUS_APPROVED_WITH_CONDITIONS;
    private final static String BACKGROUND_CHECK_STATUS_RECEIVED_FROM_FIRST_ADVANTAGE = Constant_AC.BACKGROUND_CHECK_STATUS_FIRST_ADVANTAGE;


    /**
     * Updates hidden email field and owner of background check to match related volunteer record
     * @param volunteerIds
     * @param newBackgroundChecksList
     * @return
     */
    public static List<Background_check__c> updateHiddenEmailAndOwner(Set<Id> volunteerIds, List<Background_check__c> newBackgroundChecksList) {
        Map<Id, Contact> volunteerMap = new Map<Id, Contact>([SELECT Id, OwnerId, Email 
                                                                FROM Contact 
                                                                WHERE Id IN :volunteerIds]);

        for(Background_check__c backgroundCheck : newBackgroundChecksList) {
            if(volunteerMap.containsKey(backgroundCheck.Volunteer__c)) {
                backgroundCheck.Hidden_Volunteer_Contact_Email__c = volunteerMap.get(backgroundCheck.Volunteer__c).Email;
                backgroundCheck.OwnerId = volunteerMap.get(backgroundCheck.Volunteer__c).OwnerId;
            }
        }
        return newBackgroundChecksList;
    }

    /**
     * Returns map of user Id and user role based on owner of background check
     * @param backgroundChecksList
     * @return
     */
    public static Map<Id, String> getOwnerUserRole(List<Background_check__c> newBackgroundChecksList) {
        Set<Id> ownerIdSet = new Set<Id>();
        for(Background_check__c backgroundCheck : newBackgroundChecksList) {
            ownerIdSet.add(backgroundCheck.OwnerId);
        }
        Map<Id, String> ownerRoleMap = new Map<Id, String>(UserRoleUtility.getUserRole(ownerIdSet));
        return ownerRoleMap;
    }

    /**
     * Deactivate previous background checks for a volunteer if a new, current one is active
     * @param backgroundCheckVolunteersMap
     */
    public static void deactivateBackgroundCheck(Map<Id, Id> backgroundCheckVolunteersMap) {
        List<Background_check__c> deactivateBackgroundChecks = new List<Background_check__c>();
        for(Background_check__c existingBackgroundChecks : [SELECT Id, Current__c 
                                                            FROM Background_check__c
                                                            WHERE Current__c = true 
                                                            AND Id NOT IN :backgroundCheckVolunteersMap.keySet()
                                                            AND Volunteer__c IN :backgroundCheckVolunteersMap.values()]) {
            existingBackgroundChecks.Current__c = false;
            deactivateBackgroundChecks.add(existingBackgroundChecks);
        }
        if(!deactivateBackgroundChecks.isEmpty()) {
            try {
                update deactivateBackgroundChecks;
            } catch(Exception e) {
                createBackgroundCheckDebugLog(deactivateBackgroundChecks, 'deactivateBackgroundCheck', e);
            }
        }
    }

    /**
     * Update background check expiration date on volunteer contact
     * @param backgroundCheckList
     */
    public static void updateVolunteerExpirationDate(List<Background_check__c> backgroundCheckList) {
        List<Contact> updateVolunteersList = new List<Contact>();
        for(Background_check__c backgroundCheck : backgroundCheckList) {
            if(backgroundCheck.Current__c == true 
                && backgroundCheck.Date__c != null 
                && backgroundCheck.Volunteer__c != null) {
                    Contact volunteer = new Contact();
                    volunteer.Id = backgroundCheck.Volunteer__c;
                    volunteer.B_C_Expiration_Date__c = backgroundCheck.Date__c;
                    updateVolunteersList.add(volunteer);
            }
        }
        if(!updateVolunteersList.isEmpty()) {
            try {
                update updateVolunteersList;
            } catch(Exception e) {
                createBackgroundCheckDebugLog(backgroundCheckList, 'updateVolunteerExpirationDate', e);
            }
        }
    }
    
    /**
     * Alert user of insufficient permissions to edit background check record
     * @param chapterNameMap
     * @param newBackgroundChecksList
     * @param oldBackgroundChecksMap
     */
    public static void checkUpdatePrivilege(Map<Id, String> chapterNameMap, List<Background_check__c> newBackgroundChecksList, Map<Id, Background_check__c> oldBackgroundChecksMap) {
        String userRoleName = getUserRoleName();
        if(userRoleName != 'bypass') {
            Set<String> chapterNameSet = new Set<String>(chapterNameMap.values());
            Map<String, String> chapterRoleMap = ChapterStaffRecordSharing_AC.FindChapterRole(chapterNameSet);
            for(Background_check__c backgroundCheck : newBackgroundChecksList) {
                if((chapterRoleMap.get(chapterNameMap.get(backgroundCheck.Id)) != userRoleName
                    || backgroundCheck.Account_Name__c != oldBackgroundChecksMap.get(backgroundCheck.Id).Account_Name__c)
                   && !Test.isRunningTest()) {
                       backgroundCheck.addError('Insufficient previlege to update this record. Please contact system administrator.');
                   }
            }
        }
    }
    
    //Return user role name
    private static String getUserRoleName() {
        User currentUser = [SELECT UserRole.Name, Profile.Name, Profile.Id 
                            FROM User 
                            WHERE Id = :UserInfo.getUserId()];
        if(currentUser.UserRole.Name != ROLE_NATIONAL_STAFF && currentUser.Profile.Name != PROFILE_SYSTEM_ADMINISTRATOR 
           && currentUser.Profile.Name != PROFILE_INTEGRATION && currentUser.Profile.Id != Label.Active_Volunteer_Profile
           && currentUser.Profile.Id != Label.Prospective_Volunteer_Profile) {
               return currentUser.UserRole.Name;
           }
        return 'bypass';
    }
    
    /**
     * Update volunteer affiliation record status to not approved
     * @param newBackgroundChecksList
     * @param oldBackgroundChecksMap
     */
    public static void updateAffiliationStatusNotApproved(List<Background_check__c> newBackgroundChecksList, Map<Id, Background_check__c> oldBackgroundChecksMap) {
        Set<Id> rejectedVolunteerIds = new Set<Id>();
        for(Background_check__c newBackgroundCheck: newBackgroundChecksList) {
            if(newBackgroundCheck.Status__c == BACKGROUND_CHECK_STATUS_REJECTED 
               && oldBackgroundChecksMap.get(newBackgroundCheck.Id).Status__c != BACKGROUND_CHECK_STATUS_REJECTED) {
                 rejectedVolunteerIds.add(newBackgroundCheck.Volunteer__c);
            }
        }
        if(!rejectedVolunteerIds.isEmpty()) {
            List<npe5__Affiliation__c> affiliationList = new List<npe5__Affiliation__c>();
            for(npe5__Affiliation__c affiliation : [SELECT Id, npe5__Status__c 
                                                    FROM npe5__Affiliation__c 
                                                    WHERE npe5__Contact__c IN :rejectedVolunteerIds 
                                                    AND npe5__Status__c != :AFFILIATION_STATUS_ACTIVE]) {
                affiliation.npe5__Status__c = AFFILIATION_STATUS_NOT_APPROVED;
                affiliationList.add(affiliation);
            }
            if(!affiliationList.isEmpty()) {
                try {
                    update affiliationList;
                } catch(Exception e) {
                    createBackgroundCheckDebugLog(newBackgroundChecksList, 'updateAffiliationStatusToDeclined', e);
                }
            }
        }
    }

    /**
     * Update volunteer role status
     * @param approvedVolunteerIds
     * @param newBackgroundChecksList
     */
    public static void updateVolunteerRoleStatus(Set<Id> approvedVolunteerIds, List<Background_check__c> newBackgroundChecksList) {
        Map<Id, Conflict_Of_Interest__c> conflictOfInterestMap = new Map<Id, Conflict_Of_Interest__c>();
        List<Volunteer_Roles__c> updateVolunteerRoleList = new List<Volunteer_Roles__c>();

        for(Conflict_Of_Interest__c coi : [SELECT Id, Volunteer_Contact__c, Expiration_Date__c
                                            FROM Conflict_Of_Interest__c
					                        WHERE Volunteer_Contact__c IN :approvedVolunteerIds
                                            AND Expiration_Date__c > :Date.today()]) {
            conflictOfInterestMap.put(coi.Volunteer_Contact__c, coi);
        }
        for(Volunteer_Roles__c role : [SELECT Id, Status__c, Hidden_Previous_Sub_Status__c, Hidden_Previous_Status__c,
                                        Chapter_Role__r.Background_Check_Required__c
                                        FROM Volunteer_Roles__c
                                        WHERE Volunteer_Name__c IN :conflictOfInterestMap.keySet()
                                        AND Status__c = :VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE]) {
            if(role.Status__c == VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE 
                && !String.isEmpty(role.Hidden_Previous_Status__c) 
                && role.Chapter_Role__r.Background_Check_Required__c) {
                    role.Status__c = role.Hidden_Previous_Status__c;
                    role.Sub_status__c = role.Hidden_Previous_Sub_Status__c;
                    role.Hidden_Previous_Status__c = '';
                    role.Hidden_Previous_Sub_Status__c = '';
                    updateVolunteerRoleList.add(role);
            }
        }
        if(!updateVolunteerRoleList.isEmpty()) {
            try {
                update updateVolunteerRoleList;
            } catch(Exception e) {
                createBackgroundCheckDebugLog(newBackgroundChecksList, 'updateVolunteerRoleStatus', e);
            }
        }
    }
    
    /**
     * Update volunteer hidden orientation status
     * @param newBackgroundChecksList
     * @param oldBackgroundChecksMap
     * @return
     */
    public static Set<Id> updateVolunteerOrientationStatus(List<Background_check__c> newBackgroundChecksList, Map<Id, Background_check__c> oldBackgroundChecksMap) {
        Set<Id> approvedVolunteerIds = new Set<Id>();
        Map<Id, Id> chapterRoleVolunteerMap = new Map<Id, Id>();
        Set<Id> volunteerIdSet = new Set<Id>();
        List<Contact> updateVolunteerList = new List<Contact>();
        for(Background_check__c newBackgroundCheck: newBackgroundChecksList) {
            if((newBackgroundCheck.Status__c == BACKGROUND_CHECK_STATUS_APPROVED 
                || newBackgroundCheck.Status__c == BACKGROUND_CHECK_STATUS_APPROVED_WITH_CONDITIONS)
               && newBackgroundCheck.Current__c == true 
               && oldBackgroundChecksMap.get(newBackgroundCheck.Id).Current__c == false ) {
                   approvedVolunteerIds.add(newBackgroundCheck.Volunteer__c);
               }
        }
        if(!approvedVolunteerIds.isEmpty()) {
            for(Volunteer_Roles__c volRole : [SELECT Id, Chapter_Role__c, Volunteer_Name__c
                                              FROM Volunteer_Roles__c
                                              WHERE Volunteer_Name__c IN :approvedVolunteerIds]) {
                chapterRoleVolunteerMap.put(volRole.Chapter_Role__c, volRole.Volunteer_Name__c);
            }
            if(!chapterRoleVolunteerMap.isEmpty()) {
                for(Chapter_Role_O_T__c chapterRole : [SELECT Id, Chapter_Role__c
                                                       FROM Chapter_Role_O_T__c
                                                       WHERE Chapter_Role__c IN :chapterRoleVolunteerMap.keySet()
                                                       AND Required__c = true]) {
                    if(chapterRoleVolunteerMap.containsKey(chapterRole.Chapter_Role__c)) {
                        volunteerIdSet.add(chapterRoleVolunteerMap.get(chapterRole.Chapter_Role__c));
                    }
                }
                if(!volunteerIdSet.isEmpty()) {
                    for(Contact contact : [SELECT Id 
                                           FROM Contact 
                                           WHERE Id IN :volunteerIdSet]) {
                        contact.Hidden_Volunteer_OT_Status__c = HIDDEN_ORIENTATION_STATUS_ROLE_SPECIFIC_TRAINING_AVAILABLE;
                        updateVolunteerList.add(contact);
                    }
                }
                if(!updateVolunteerList.isEmpty()) {
                    try {
                        update updateVolunteerList;
                    } catch(Exception e) {
                        createBackgroundCheckDebugLog(newBackgroundChecksList, 'updateVolunteerOrientationStatus', e);
                    }
                }
            }
        }
        return approvedVolunteerIds;
    }

    /**
     * Update volunteer roles status fields
     * @param volunteerIds
     * @param objectName
     * @param exceptionList
     */
    public static void updateVolunteerRoleHiddenStatus(Set<Id> volunteerIds, String objectName, List<SObject> exceptionList) {
        List<Volunteer_Roles__c> updateVolunteerRoleList = new List<Volunteer_Roles__c>();
        for(Volunteer_Roles__c volRole : [SELECT Id, Volunteer_Name__c, Hidden_Previous_Sub_Status__c, Hidden_Previous_Status__c, 
                                          Status__c, Sub_status__c, Chapter_Role__c, Chapter_Role__r.Background_Check_Required__c,
                                          Chapter_Role__r.COI_Required__c
                                          FROM Volunteer_Roles__c
                                          WHERE Volunteer_Name__c IN :volunteerIds
                                          AND Status__c != :VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE
                                          AND Status__c != :VOLUNTEER_ROLE_STATUS_FORMER
                                          AND Status__c != :VOLUNTEER_ROLE_STATUS_NOT_APPROVED]) {
            if(objectName == 'backgroundcheck' 
                && volRole.Chapter_Role__r.Background_Check_Required__c) {
                    volRole.Hidden_Previous_Status__c = volRole.Status__c;
                    volRole.Hidden_Previous_Sub_Status__c = volRole.Sub_status__c;
                    volRole.Status__c = VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE;
            } else if(objectName == 'COI'
                && volRole.Chapter_Role__r.COI_Required__c) {
                    volRole.Hidden_Previous_Status__c = volRole.Status__c;
                    volRole.Hidden_Previous_Sub_Status__c = volRole.Sub_status__c;
                    volRole.Status__c = VOLUNTEER_ROLE_STATUS_OUT_OF_COMPLIANCE;
            }
            updateVolunteerRoleList.add(volRole);
        }
        if(!updateVolunteerRoleList.isEmpty()) {
            try {
                update updateVolunteerRoleList;
            } catch(Exception e) {
                createBackgroundCheckDebugLog(exceptionList, 'updateVolunteerRoleHiddenStatus', e);
            }
        }
    }

    /**
     * Create task to review background check
     * @param newBackgroundChecksList
     */
    public static void createBackgroundCheckReviewTask(List<Background_check__c> newBackgroundChecksList) {
        List<Task> taskList = new List<Task>();
        for(Background_check__c backgroundCheck : newBackgroundChecksList) {
            if(backgroundCheck.Status__c == BACKGROUND_CHECK_STATUS_RECEIVED_FROM_FIRST_ADVANTAGE) {
                Task task = new Task();
                task.Description = '';
                task.WhoId = backgroundCheck.Volunteer__c;
                task.WhatId = backgroundCheck.Id;
                task.OwnerId = backgroundCheck.OwnerId;
                task.Subject = TASK_SUBJECT_REVIEW_BACKGROUND_CHECK;
                task.SystemGeneratedTask__c = true;
                task.ActivityDate = System.today() + 1;
                task.RecordTypeId = TASK_BACKGROUND_CHECK_RT;
                taskList.add(task);
            }
        }
        if(!taskList.isEmpty()) {
            try {
                insert taskList;
            } catch(Exception e) {
                createBackgroundCheckDebugLog(newBackgroundChecksList, 'createBackgroundCheckReviewTask', e);
            }
        }
    }

    /**
     * Create debug log when error occurs
     * @param exceptionList
     * @param methodName
     * @param exception
     */
    public static void createBackgroundCheckDebugLog(List<SObject> exceptionList, String methodName, Exception ex) {
        for(SObject record : exceptionList) {
            ErrorMessage_AC.createdebugRec('BackgroundCheckService', String.valueOf(record), String.valueOf(ex), 
                                           methodName, record.Id, ex.getStackTraceString() + ' ' + ex.getMessage(), 'Error');
            record.addError(Label.Debug_log_error_message);
        }
    }
}