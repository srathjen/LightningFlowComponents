/**
 * @description Domain class for Background Check trigger
 * @author Michelle Cominotto, Make-A-Wish
 * @createdDate 3/18/2020
 */
public class BackgroundCheckDomain extends trac_TriggerHandlerBase {

    private final static String BACKGROUND_CHECK_STATUS_APPROVED = Constant_AC.BACKGROUND_CHECK_STATUS_APPROVED;
    private final static String BACKGROUND_CHECK_STATUS_APPROVED_WITH_CONDITIONS = Constant_AC.BACKGROUND_CHECK_STATUS_APPROVED_WITH_CONDITIONS;
    private final static String BACKGROUND_CHECK_STATUS_RECEIVED_FROM_FIRST_ADVANTAGE = Constant_AC.BACKGROUND_CHECK_STATUS_FIRST_ADVANTAGE;
    private final static String ROLE_NATIONAL_STAFF = Constant_AC.ROLE_NATIONAL_STAFF;
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
        if(!volunteerIds.isEmpty()) {
            BackgroundCheckService.updateHiddenEmailAndOwner(volunteerIds, newBackgroundChecksList);
        }
    }

    /**
    * After insert of background check
    */
    public override void handleAfterInsert() {
        Map<Id, Id> backgroundCheckVolunteerMap = new Map<Id, Id>();
        Map<Id, String> ownerRoleMap = 
            new Map<Id, String>(BackgroundCheckService.getOwnerUserRole(newBackgroundChecksList));
        Map<String, List<Background_check__c>> backgroundCheckAccountMap = 
            new Map<String, List<Background_check__c>>();
        
        for(Background_check__c backgroundCheck : newBackgroundChecksList) {
            if(Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null) {
                if(backgroundCheck.Current__c == true) {
                    backgroundCheckVolunteerMap.put(backgroundCheck.Id, backgroundCheck.Volunteer__c);
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
        if(!backgroundCheckVolunteerMap.isEmpty()) {
            BackgroundCheckService.deactivateBackgroundCheck(backgroundCheckVolunteerMap);
            BackgroundCheckService.updateVolunteerExpirationDate(newBackgroundChecksList);
            VolunteerJourneyService.processVolunteersChapterRequirements(new Set<Id>(backgroundCheckVolunteerMap.values()));
        }
        if(!backgroundCheckAccountMap.isEmpty()) {
            ChapterStaffRecordSharing_AC.BGCRecordSharing(backgroundCheckAccountMap);
        }
    }

    /**
    * After update of background check
    */
    public override void handleAfterUpdate() {
        List<Background_check__c> backgroundCheckExpireList = new List<Background_check__c>();
        Set<Id> volunteerIdsExpiredRejected = new Set<Id>();
        Map<Id, String> chapterNameMap = new Map<Id, String>();
        Set<Id> volunteerIdsBgcApprovedCurrent = new Set<Id>();
        Map<Id, Id> backgroundCheckVolunteerMap = new Map<Id, Id>();
        List<Background_check__c> backgroundCheckStatusChangeList = new List<Background_check__c>();
        
        for(Background_check__c newBackgroundCheck : newBackgroundChecksList) {
            Background_check__c oldBackgroundCheck = oldBackgroundChecksMap.get(newBackgroundCheck.Id);
            if(newBackgroundCheck.Current__c == true && oldBackgroundCheck.Current__c == false) {
                backgroundCheckVolunteerMap.put(newBackgroundCheck.Id, newBackgroundCheck.Volunteer__c);
            }
            if(newBackgroundCheck.Date__c != oldBackgroundCheck.Date__c) {
                backgroundCheckExpireList.add(newBackgroundCheck);
            }
            if(newBackgroundCheck.HiddenBackgroundExpire__c == true 
                && oldBackgroundCheck.HiddenBackgroundExpire__c == false) {
                    volunteerIdsExpiredRejected.add(newBackgroundCheck.Volunteer__c);
            }
            if(newBackgroundCheck.Hidden_Background_Rejected__c == true 
                && oldBackgroundCheck.Hidden_Background_Rejected__c == false) {
                    volunteerIdsExpiredRejected.add(newBackgroundCheck.Volunteer__c);
            }
            if(newBackgroundCheck.Status__c != oldBackgroundCheck.Status__c) {
                backgroundCheckStatusChangeList.add(newBackgroundCheck);
            }
            if(newBackgroundCheck.Account_Name__c != null) {
                chapterNameMap.put(newBackgroundCheck.Id, newBackgroundCheck.Account_Name__c);
            }
        }
        if(!chapterNameMap.isEmpty()) {
            BackgroundCheckService.checkUpdatePrivilege(chapterNameMap, newBackgroundChecksList, oldBackgroundChecksMap);
        }
        if(!backgroundCheckVolunteerMap.isEmpty()) {
            BackgroundCheckService.deactivateBackgroundCheck(backgroundCheckVolunteerMap);
        }
        if(!backgroundCheckExpireList.isEmpty()) {
            BackgroundCheckService.updateVolunteerExpirationDate(backgroundCheckExpireList);
        }
        if(!volunteerIdsExpiredRejected.isEmpty()) {
            BackgroundCheckService.updateVolunteerRoleHiddenStatus(volunteerIdsExpiredRejected, 'backgroundcheck', newBackgroundChecksList);
        }
        if(!backgroundCheckStatusChangeList.isEmpty()) {
            BackgroundCheckService.updateAffiliationStatusNotApproved(backgroundCheckStatusChangeList, oldBackgroundChecksMap);
            BackgroundCheckService.createBackgroundCheckReviewTask(backgroundCheckStatusChangeList);
            volunteerIdsBgcApprovedCurrent = BackgroundCheckService.updateVolunteerOrientationStatus(backgroundCheckStatusChangeList, oldBackgroundChecksMap);
        }
        if(!volunteerIdsBgcApprovedCurrent.isEmpty()) {
            BackgroundCheckService.updateVolunteerRoleStatus(volunteerIdsBgcApprovedCurrent, newBackgroundChecksList);
            VolunteerJourneyService.processVolunteersChapterRequirements(volunteerIdsBgcApprovedCurrent);
        }
    }
}