/**
 * @description Domain class for Background Check trigger
 * @author Michelle Cominotto, Make-A-Wish
 * @createdDate 3/18/2020
 */
public with sharing class BackgroundCheckDomain extends trac_TriggerHandlerBase {

    private final static String BACKGROUND_CHECK_STATUS_REJECTED = Constant_AC.BACKGROUND_CHECK_STATUS_REJECTED;
    private final static String BACKGROUND_CHECK_STATUS_APPROVED = Constant_AC.BACKGROUND_CHECK_STATUS_APPROVED;
    private final static String BACKGROUND_CHECK_STATUS_APPROVED_WITH_CONDITIONS = Constant_AC.BACKGROUND_CHECK_STATUS_APPROVED_WITH_CONDITIONS;
    private final static String BACKGROUND_CHECK_STATUS_RECEIVED_FROM_FIRST_ADVANTAGE = Constant_AC.BACKGROUND_CHECK_STATUS_FIRST_ADVANTAGE;
    private final static String ROLE_NATIONAL_STAFF = Constant_AC.ROLE_NATIONAL_STAFF;
    private final static String PROFILE_INTEGRATION = Constant_AC.PROFILE_INTEGRATION;
    private final static String PROFILE_SYSTEM_ADMINISTRATOR = Constant_AC.PROFILE_SYSTEM_ADMINISTRATOR;
    private List<Background_check__c> newBackgroundChecksList = (List<Background_check__c>)newRecordsList;
    private List<Background_check__c> oldBackgroundChecksList = (List<Background_check__c>)oldRecordsList;
    private Map<Id, Background_check__c> newBackgroundChecksMap = (Map<Id, Background_check__c>)newRecordsMap;
    private Map<Id, Background_check__c> oldBackgroundChecksMap = (Map<Id, Background_check__c>)oldRecordsMap;

    /**
    * Before insert of background check
    */
    public override void handleBeforeInsert() {
        Set<Id> volunteerIds = new Set<Id>();
        for(Background_check__c  backgroundCheck : newBackgroundChecksList) {
            if(Bypass_Triggers__c.getValues(userInfo.getUserId()) == null) {
                if(backgroundCheck.Date_Completed__c != null 
                   && backgroundCheck.Status__c != null) {
                       backgroundCheck.Current__c = true;
                   }
                volunteerIds.add(backgroundCheck.Volunteer__c);
            }
            if(backgroundCheck.Date_Completed__c != null) {
                backgroundCheck.Date_Completed__c.addYears(3);
            }
        }
        //Update hidden email and record owner
        if(!volunteerIds.isEmpty()) {
            BackgroundCheckService.updateHiddenEmailAndOwner(volunteerIds, newBackgroundChecksList);
        }
    }

    /**
    * Before update of background check
    */
    public override void handleBeforeUpdate() {
        Set<Id> volunteerIds = new Set<Id>();
        for(Background_check__c newBackgroundCheck : newBackgroundChecksList) {
            Background_check__c oldBackgroundCheck = oldBackgroundChecksMap.get(newBackgroundCheck.Id);
            volunteerIds.add(newBackgroundCheck.Volunteer__c);
            if(newBackgroundCheck.Status__c != oldBackgroundCheck.Status__c) {
                if(newBackgroundCheck.Status__c == BACKGROUND_CHECK_STATUS_RECEIVED_FROM_FIRST_ADVANTAGE) {
                    newBackgroundCheck.Date_Completed__c = Date.today();
                } else if(newBackgroundCheck.Status__c == BACKGROUND_CHECK_STATUS_APPROVED 
                            || newBackgroundCheck.Status__c == BACKGROUND_CHECK_STATUS_APPROVED_WITH_CONDITIONS) {
                    newBackgroundCheck.Current__c = true;
                }
            }
        }
        //Update hidden email and record owner
        if(!volunteerIds.isEmpty()) {
            BackgroundCheckService.updateHiddenEmailAndOwner(volunteerIds, newBackgroundChecksList);
        }
    }

    /**
    * After insert of background check
    */
    public override void handleAfterInsert() {
        Map<Id, String> ownerRoleMap = 
            new Map<Id, String>(BackgroundCheckService.getOwnerUserRole(newBackgroundChecksList));
        Set<Id> currentBackgroundCheckIds = new Set<Id>();
        Set<Id> volunteerIds = new Set<Id>();
        Map<String, List<Background_check__c>> backgroundCheckAccountMap = 
            new Map<String, List<Background_check__c>>();
        Map<Id, Background_check__c> backgroundCheckExpirationMap = new Map<Id, Background_check__c>();
        
        for(Background_check__c backgroundCheck : newBackgroundChecksList) {
            if(Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null) {
                if(backgroundCheck.Current__c == true) {
                    currentBackgroundCheckIds.add(backgroundCheck.Id);
                    volunteerIds.add(backgroundCheck.Volunteer__c);
                    if(backgroundCheck.Date__c != null) {
                        backgroundCheckExpirationMap.put(backgroundCheck.Id, backgroundCheck);
                    }
                }
                if(backgroundCheck.Account_Name__c != null 
                   && ownerRoleMap.get(backgroundCheck.OwnerId) == ROLE_NATIONAL_STAFF) {
                       if(backgroundCheckAccountMap.containsKey(backgroundCheck.Account_Name__c)) {
                           backgroundCheckAccountMap.get(backgroundCheck.Account_Name__c).add(backgroundCheck);
                       } else {
                           backgroundCheckAccountMap.put(backgroundCheck.Account_Name__c, 
                                                         new List<Background_check__c>{backgroundCheck});
                       }
                   }
            }
        }
        //Check for previous background checks and deactivate
        if(!currentBackgroundCheckIds.isEmpty() && !volunteerIds.isEmpty()) {
            BackgroundCheckService.deactivateBackgroundCheck(currentBackgroundCheckIds, volunteerIds);
        }
        //Share background check record to chapter role
        if(!backgroundCheckAccountMap.isEmpty()) {
            ChapterStaffRecordSharing_AC.BGCRecordSharing(backgroundCheckAccountMap);
        }
        //Update background check expiration date for volunteers
        if(!backgroundCheckExpirationMap.isEmpty()) {
            BackgroundCheckService.updateVolunteerExpirationDate(backgroundCheckExpirationMap);
        }
        //Process volunteers to try to activate its Volunteer Role, User and Organization Affiliation
        if(!volunteerIds.isEmpty()) {
            VolunteerJourneyService.processVolunteersChapterRequirements(volunteerIds);
		}
    }

    /**
    * After update of background check
    */
    public override void handleAfterUpdate() {
        Set<Id> rejectedVolunteerIds = new Set<Id>();
        Map<Id, Background_check__c> backgroundCheckExpirationMap = new Map<Id, Background_check__c>();
        Set<Id> newBackgroundCheckIds = new Set<Id>();
        Set<Id> volunteerIds = new Set<Id>();
        Set<Id> volunteerIdsExpiredRejected = new Set<Id>();
        Set<Id> volunteerIdsRejected = new Set<Id>();
        Map<Id, String> chapterNameMap = new Map<Id, String>();
        List<Background_check__c> backgroundCheckTaskList = new List<Background_check__c>();
        Set<Id> volunteerIdsBgcApprovedCurrent = new Set<Id>();
        String userRoleName = getUserRoleName();

        for(Background_check__c newBackgroundCheck : newBackgroundChecksList) {
            Background_check__c oldBackgroundCheck = oldBackgroundChecksMap.get(newBackgroundCheck.Id);
            if(newBackgroundCheck.Status__c == BACKGROUND_CHECK_STATUS_REJECTED 
                && oldBackgroundCheck.Status__c != BACKGROUND_CHECK_STATUS_REJECTED) {
                    rejectedVolunteerIds.add(newBackgroundCheck.Volunteer__c);
            }
            if(newBackgroundCheck.Current__c == true) {
                if(oldBackgroundCheck.Current__c == false) {
                    newBackgroundCheckIds.add(newBackgroundCheck.Id);
                    volunteerIds.add(newBackgroundCheck.Volunteer__c);
                }
                if(newBackgroundCheck.Date__c != oldBackgroundCheck.Date__c) {
                    backgroundCheckExpirationMap.put(newBackgroundCheck.Volunteer__c, newBackgroundCheck);
                }
            }
            if(newBackgroundCheck.HiddenBackgroundExpire__c == true 
                && oldBackgroundCheck.HiddenBackgroundExpire__c == false) {
                    volunteerIdsExpiredRejected.add(newBackgroundCheck.Volunteer__c);
            }
            if(newBackgroundCheck.Hidden_Background_Rejected__c == true 
                && oldBackgroundCheck.Hidden_Background_Rejected__c == false) {
                    volunteerIdsRejected.add(newBackgroundCheck.Volunteer__c);
                    volunteerIdsExpiredRejected.add(newBackgroundCheck.Volunteer__c);
            }
            if(newBackgroundCheck.Status__c != oldBackgroundCheck.Status__c) {
                if(newBackgroundCheck.Status__c == BACKGROUND_CHECK_STATUS_RECEIVED_FROM_FIRST_ADVANTAGE) {
                    backgroundCheckTaskList.add(newBackgroundCheck);
                }
                if((newBackgroundCheck.Status__c == BACKGROUND_CHECK_STATUS_APPROVED 
                    || newBackgroundCheck.Status__c == BACKGROUND_CHECK_STATUS_APPROVED_WITH_CONDITIONS)
                    && newBackgroundCheck.Current__c == true && oldBackgroundCheck.Current__c != true ) {
                        volunteerIdsBgcApprovedCurrent.add(newBackgroundCheck.Volunteer__c);
                }
            }
            if(newBackgroundCheck.Account_Name__c != null && userRoleName != 'bypass') {
                chapterNameMap.put(newBackgroundCheck.Id, newBackgroundCheck.Account_Name__c);
            }
        }
        //Check user permission to update record
        if(!chapterNameMap.isEmpty()) {
            BackgroundCheckService.checkUpdatePrivilege(chapterNameMap, userRoleName, newBackgroundChecksList, oldBackgroundChecksMap);
        }
        //Update volunteer affiliation record status
        if(!volunteerIdsRejected.isEmpty()) {
            BackgroundCheckService.updateAffiliationStatusNotApproved(rejectedVolunteerIds, newBackgroundChecksList);
        }
        //Check for previous background checks and deactivate
        if(!newBackgroundCheckIds.isEmpty() && !volunteerIds.isEmpty()) {
            BackgroundCheckService.deactivateBackgroundCheck(newBackgroundCheckIds, volunteerIds);
        }
        //Activate Volunteer Role, User and Organization Affiliation and update volunteer role and orientation status
        if(!volunteerIdsBgcApprovedCurrent.isEmpty()) {
            BackgroundCheckService.updateVolunteerRoleStatus(volunteerIdsBgcApprovedCurrent, newBackgroundChecksList);
            BackgroundCheckService.updateVolunteerOrientationStatus(volunteerIdsBgcApprovedCurrent, newBackgroundChecksList);
            VolunteerJourneyService.processVolunteersChapterRequirements(volunteerIdsBgcApprovedCurrent);
        }
        //Update background check expiration date
        if(!backgroundCheckExpirationMap.isEmpty()) {
            BackgroundCheckService.updateVolunteerExpirationDate(backgroundCheckExpirationMap);
        }
        //Update volunteer role statuses
        if(!volunteerIdsExpiredRejected.isEmpty()) {
            BackgroundCheckService.updateVolunteerRoleHiddenStatus(volunteerIdsExpiredRejected, 'backgroundcheck', newBackgroundChecksList);
        }
        //Create task to review background check
        if(!backgroundCheckTaskList.isEmpty()) {
            BackgroundCheckService.createBackgroundCheckReviewTask(newBackgroundChecksList);
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
}