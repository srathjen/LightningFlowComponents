/**
 * @description     Domain class for the Case object
 *
 * @author          Chris Shinnimin, Traction on Demand
 * @date            2020-03-12
 */
public with sharing class CaseDomain extends trac_TriggerHandlerBase {
    List<Case> newCasesList = (List<Case>) newRecordsList;
    List<Case> oldCasesList = (List<Case>) oldRecordsList;
    Map<Id, Case> newCasesMap = (Map<Id, Case>) newRecordsMap;
    Map<Id, Case> oldCasesMap = (Map<Id, Case>) oldRecordsMap;

    private static final Id WISH_RECORDTYPE_ID = Constant_AC.WISH_RT_ID;
    private static final Id DIAGNOSIS_VERIFICATION_RECORDTYPE_ID = Constant_AC.DIAGNOSIS_RT_ID;
    private static final Id WISH_ASSIST_RECORDTYPE_ID = Constant_AC.WISH_ASSIST_RT_ID;
    private static final Boolean USER_HAS_RESTRICTED_PERMISSIONS_ON_CASE = CaseService.userHasRestrictedPermissionOnCase();

    // Sets used to make conditionals in handleBeforeUpdate more readable:

    private static final Set<Id> WISH_OWNER_CHECK_RECORD_TYPE_IDS =
        new Set<Id> {Constant_AC.WISH_RT_ID, Constant_AC.WISH_ASSIST_RT_ID, Constant_AC.DIAGNOSIS_RT_ID};
    private static final Set<String> DNQ_DATE_STATUSES = new Set<String>{
        Constant_AC.CASE_STATUS_DNQ_NATIONAL_STAFF,
        Constant_AC.CASE_STATUS_DNQ_NATIONAL_MEDICAL_COUNCIL,
        Constant_AC.CASE_STATUS_DNQ_CHAPTER_STAFF,
        Constant_AC.CASE_STATUS_DNQ_CHAPTER_MEDICAL_ADVISOR
    };
    private static final Set<String> IS_LOCKED_STATUSES =
        new Set<String>{Constant_AC.CASE_STATUS_DNQ, Constant_AC.CASE_STATUS_COMPLETED, Constant_AC.CASE_STATUS_CLOSED};

    // Sets used to make conditionals in handleAfterUpdate more readable:

    private static final Set<Id> CASE_MEMBER_CHECK_IDS = new Set<Id>
    {WISH_RECORDTYPE_ID, WISH_ASSIST_RECORDTYPE_ID, DIAGNOSIS_VERIFICATION_RECORDTYPE_ID};
    private static final Set<String> WISH_COORDINATOR_ID_CHECK_STATUSES = new Set<String>{
        Constant_AC.CASE_STATUS_WISH_DETERMINED, Constant_AC.CASE_STATUS_WISH_DESIGN,
        Constant_AC.CASE_STATUS_WISH_SCHEDULED, Constant_AC.CASE_STATUS_PENDING_APPROVAL
    };
    private static final Set<String> VOLUNTEER_CASE_ID_CHECK_HAS_STATUS = new Set<String>{
        Constant_AC.CASE_STATUS_WISH_DETERMINED, Constant_AC.CASE_STATUS_PENDING_APPROVAL,
        Constant_AC.CASE_STATUS_WISH_DESIGN, Constant_AC.CASE_STATUS_WISH_SCHEDULED,
        Constant_AC.CASE_STATUS_GRANTED
    };
    private static final Set<String> VOLUNTEER_CASE_ID_CHECK_NOT_HAS_STATUSES = new Set<String>{
        Constant_AC.CASE_STATUS_WISH_DETERMINED, Constant_AC.CASE_STATUS_PENDING_APPROVAL,
        Constant_AC.CASE_STATUS_WISH_DESIGN, Constant_AC.CASE_STATUS_WISH_SCHEDULED,
        Constant_AC.CASE_STATUS_GRANTED
    };
    private static final Set<String> CLOSE_BIRTHDAY_TASK_SET_STATUSES = new Set<String>{
        Constant_AC.CASE_STATUS_COMPLETED, Constant_AC.CASE_STATUS_CLOSED,
        Constant_AC.CASE_STATUS_GRANTED, Constant_AC.CASE_STATUS_INACTIVE
    };
    private static final Set<String> CASE_MEMBER_WISH_TYPE_CHECK = new Set<String>{
        Constant_AC.CASE_WISH_TYPE_CRUISE_CELEBRITY_ROYAL, Constant_AC.CASE_WISH_TYPE_CRUISE_DISNEY,
        Constant_AC.CASE_WISH_TYPE_CRUISE_OTHER, Constant_AC.CASE_WISH_TYPE_TRAVEL_INTERNATIONAL,
        Constant_AC.CASE_WISH_TYPE_TRAVEL_HAWAII, Constant_AC.CASE_WISH_TYPE_TRAILER_CAMPER,
        Constant_AC.CASE_WISH_TYPE_TRAVEL_OTHER
    };
    private static final Set<String> IN_PROGRESS_UNCHECK_HAS_STATUS = new Set<String>{
        Constant_AC.CASE_STATUS_CLOSED, Constant_AC.CASE_STATUS_COMPLETED,
        Constant_AC.CASE_STATUS_INACTIVE, Constant_AC.CASE_STATUS_QUALIFIED,
        Constant_AC.CASE_STATUS_READY_TO_ASSIGN, Constant_AC.CASE_STATUS_READY_TO_INTERVIEW
    };
    private static final Set<String> IN_PROGRESS_UNCHECK_NOT_HAS_STATUSES = new Set<String>{
        Constant_AC.CASE_STATUS_CLOSED, Constant_AC.CASE_STATUS_COMPLETED,
        Constant_AC.CASE_STATUS_INACTIVE, Constant_AC.CASE_STATUS_READY_TO_ASSIGN,
        Constant_AC.CASE_STATUS_READY_TO_INTERVIEW, Constant_AC.CASE_STATUS_QUALIFIED
    };
    private static final Set<String> PARENT_WISH_ID_SET_STATUSES = new Set<String>{
        Constant_AC.CASE_STATUS_COMPLETED, Constant_AC.CASE_STATUS_CLOSED,
        Constant_AC.CASE_STATUS_GRANTED, Constant_AC.CASE_STATUS_INACTIVE
    };

    /*
     * @description		OnBeforeInsert trigger handler for the Case object
     *
     * @author 			MST Solutions
     * @createdDate		2018-03-23
     */
    public override void handleBeforeInsert() {
        Set<Id> wishOwnerIdSet = new Set<Id>();
        Map<Id, User> wishOwnerMap = new Map<Id, User>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        Set<Id> chapterSet = new Set<Id>();

        for (Case newCase : newCasesList) {
            if (Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null && newCase.RecordTypeId == WISH_RECORDTYPE_ID) {
                wishOwnerIdSet.add(newCase.OwnerId);
            }
            if (newCase.RecordTypeId == WISH_RECORDTYPE_ID && newCase.ParentId != null) {
                caseMap.put(newCase.Id, newCase);
            }
            if (newCase.RecordTypeId == WISH_RECORDTYPE_ID) {
                chapterSet.add(newCase.ChapterName__c);
            }
            if (!newCase.Rush__c && newCase.RecordTypeId == WISH_RECORDTYPE_ID) {
                newCase.Rush_Timeframe__c = null;
                newCase.Rush_Explanation__c = null;
            }
        }

        if (wishOwnerIdSet.size() > 0) {
            for (User wishOwner : [
                SELECT Id,ManagerId,Manager.Name,Manager.Email
                FROM User
                WHERE Id IN:wishOwnerIdSet
                AND ManagerId != NULL
            ]) {
                wishOwnerMap.put(wishOwner.Id, wishOwner);
            }
        }

        for (Case newCase : newCasesList) {
            if (wishOwnerMap.containsKey(newCase.OwnerId) && newCase.RecordTypeId == WISH_RECORDTYPE_ID) {
                if (wishOwnerMap.get(newCase.OwnerId).ManagerId != null) {
                    newCase.Hidden_Wish_Owner_Manager__c = wishOwnerMap.get(newCase.OwnerId).Manager.Name;
                    newCase.Hidden_Wish_Owner_Email__c = wishOwnerMap.get(newCase.OwnerId).Manager.Email;
                }
            }
        }
    }

    /*
     * @description		OnBeforeUpdate trigger handler for the Case object
     *
     * @author 			MST Solutions
     * @createdDate		2018-03-23
     */
    public override void handleBeforeUpdate() {
        // During code cleanup, RecursiveTrigger.blockBeforeUpdate was found to manage BEFORE UPDATE
        // trigger recursion. It isn't presently clear what the consequences of removing this check
        // will be, so leaving it here for the time being.
        if (RecursiveTriggerHandler.blockBeforeUpdate) {
            return;
        }

        Id chapterRecordTypeId = Constant_AC.CHAPTER_RT_ID;
        Id diagnosisVerificationRT = Constant_AC.DIAGNOSIS_RT_ID;

        List<Account> dbAccountList = [
            SELECT MAC_Email_del__c
            FROM Account
            WHERE Name = :Constant_AC.ACCOUNT_NAME_MAW_AMERICA
            AND RecordTypeId = :chapterRecordTypeId
            LIMIT 1
        ];

        for (Case currentCase : newCasesMap.values()) {
            if (CaseValidations.beforeUpdateValidations(currentCase, oldCasesMap.get(currentCase.Id))) {
                continue;
            }

            if (WISH_OWNER_CHECK_RECORD_TYPE_IDS.contains(currentCase.RecordTypeId)) {
                if (currentCase.Comment_1__c != null && oldCasesMap.get(currentCase.Id).Comment_1__c != currentCase.Comment_1__c) {
                    currentCase.Comment__c = currentCase.Comment_1__c;
                }
            }

            if ((Constant_AC.CASE_STATUS_READY_TO_ASSIGN.equals(currentCase.Status))
                && !Constant_AC.CASE_STATUS_READY_TO_ASSIGN.equals(oldCasesMap.get(currentCase.Id).Status)
                && currentCase.RecordTypeId == WISH_RECORDTYPE_ID) {

                currentCase.Ready_to_Assign_Date__c = Date.today();
            }

            if (Constant_AC.CASE_STATUS_READY_TO_INTERVIEW.equals(currentCase.Status)
                && Constant_AC.CASE_STATUS_READY_TO_ASSIGN.equals(oldCasesMap.get(currentCase.Id).Status)
                && currentCase.RecordTypeId == WISH_RECORDTYPE_ID) {

                currentCase.Sub_Status__c = Constant_AC.CASE_SUB_STATUS_PENDING;
            }

            if (currentCase.RecordTypeId == diagnosisVerificationRT
                && Constant_AC.CASE_STATUS_ESCALATED.equals(currentCase.Status)
                && Constant_AC.CASE_STATUS_ESCALATED.equals(oldCasesMap.get(currentCase.Id).Status)
                && currentCase.Case_Comment__c != oldCasesMap.get(currentCase.Id).Case_Comment__c) {

                currentCase.isNationalReply__c = true;
            }

            if (currentCase.Comment_1__c != oldCasesMap.get(currentCase.Id).Comment_1__c
                && currentCase.RecordTypeId == WISH_RECORDTYPE_ID) {

                currentCase.Air_Travel_Details__c = Label.CaseTrigger_Air_Travel_Aware;
            }

            if (currentCase.Appropriate_Comments__c != oldCasesMap.get(currentCase.Id).Appropriate_Comments__c
                && currentCase.RecordTypeId == WISH_RECORDTYPE_ID) {

                currentCase.Wish_Clearance__c = Constant_AC.CASE_WISH_CLEARANCE_APPROPRIATE;
            }

            if (currentCase.Please_Explain__c != oldCasesMap.get(currentCase.Id).Please_Explain__c
                && currentCase.RecordTypeId == WISH_RECORDTYPE_ID) {

                currentCase.Wish_Clearance__c = Constant_AC.CASE_WISH_CLEARANCE_NOT_APPROPRIATE;
            }

            if (Constant_AC.CASE_STATUS_WISH_DETERMINED.equals(currentCase.Status)
                && currentCase.Wish_Type__c != null
                && currentCase.RecordTypeId == WISH_RECORDTYPE_ID) {

                currentCase.Meet_PWL_Criteria__c = Constant_AC.MEET_PWL_CRITERIA_YES;
                currentCase.Concept_Approval_Date__c = Date.today();
            }

            if (Constant_AC.CASE_STATUS_WISH_DETERMINED.equals(currentCase.Status)
                && !Constant_AC.CASE_STATUS_WISH_DETERMINED.equals(oldCasesMap.get(currentCase.Id).Status)
                && currentCase.RecordTypeId == WISH_RECORDTYPE_ID) {

                currentCase.Wish_Determined_Date__c = System.today();
            }

            if (currentCase.RecordTypeId == WISH_RECORDTYPE_ID
                && (Constant_AC.CASE_STATUS_PENDING_APPROVAL.equals(currentCase.Status)
                && !Constant_AC.CASE_STATUS_PENDING_APPROVAL.equals(oldCasesMap.get(currentCase.Id).Status))) {

                currentCase.Sub_Status__c = null;
            }

            if (Constant_AC.CASE_STATUS_ESCALATED.equals(currentCase.Status)
                && currentCase.RecordTypeId == diagnosisVerificationRT
                && !Constant_AC.CASE_STATUS_ESCALATED.equals(oldCasesMap.get(currentCase.Id).Status)) {

                currentCase.isNational__c = true;
                currentCase.MAC_Email__c = dbAccountList[0].MAC_Email_del__c;
            }

            if (DNQ_DATE_STATUSES.contains(currentCase.Status)
                && currentCase.RecordTypeId == diagnosisVerificationRT) {

                currentCase.DNQ_Date__c = Date.today();
            }

            if (IS_LOCKED_STATUSES.contains(currentCase.Status)
                && currentCase.RecordTypeId == WISH_RECORDTYPE_ID) {

                currentCase.IsLocked__c = true;
            }

            if ((!Constant_AC.CASE_STATUS_DNQ.equals(currentCase.Status)
                && Constant_AC.CASE_STATUS_DNQ.equals(oldCasesMap.get(currentCase.Id).Status))
                || (!Constant_AC.CASE_STATUS_COMPLETED.equals(currentCase.Status)
                && Constant_AC.CASE_STATUS_COMPLETED.equals(oldCasesMap.get(currentCase.Id).Status))
                || (!Constant_AC.CASE_STATUS_CLOSED.equals(currentCase.Status)
                && Constant_AC.CASE_STATUS_CLOSED.equals(oldCasesMap.get(currentCase.Id).Status))
                || (currentCase.IsClosed == false
                && oldCasesMap.get(currentCase.Id).IsClosed == true) &&
                currentCase.RecordTypeId == WISH_RECORDTYPE_ID) {

                currentCase.IsLocked__c = false;
            }

            if (Constant_AC.CASE_STATUS_INACTIVE.equals(currentCase.Status)
                && !Constant_AC.CASE_STATUS_INACTIVE.equals(oldCasesMap.get(currentCase.Id).Status)
                && currentCase.RecordTypeId == WISH_RECORDTYPE_ID) {

                currentCase.Inactive_Date__c = Date.today();
            } else if ((Constant_AC.CASE_STATUS_CLOSED.equals(currentCase.Status)
                || Constant_AC.CASE_STATUS_COMPLETED.equals(currentCase.Status))
                && Constant_AC.CASE_STATUS_GRANTED.equals(oldCasesMap.get(currentCase.Id).Status)
                && currentCase.RecordTypeId == WISH_RECORDTYPE_ID) {

                currentCase.Completed_Date__c = Date.today();
            }

            if (Constant_AC.CASE_SUB_STATUS_ABANDONED.equals(currentCase.Sub_Status__c)
                && !Constant_AC.CASE_SUB_STATUS_ABANDONED.equals(currentCase.Sub_Status__c)
                && currentCase.RecordTypeId == WISH_RECORDTYPE_ID) {

                currentCase.Closed_Date__c = Date.today();
            }

            if (currentCase.Wish_Clearance_Needed__c != oldCasesMap.get(currentCase.Id).Wish_Clearance_Needed__c
                && currentCase.RecordTypeId == WISH_RECORDTYPE_ID
                && currentCase.Wish_Clearance_Needed__c != null) {

                if (currentCase.Wish_Clearance_Needed__c == 'Yes') {
                    currentCase.Wish_Safety_Authorization_Part_B_Form__c = true;
                } else {
                    currentCase.Wish_Safety_Authorization_Part_B_Form__c = false;
                }
            }
        }

        populateHiddenWishOwnerFields();

        CaseService.updateWishClearanceNeeded(getWishChildRegionValidationCases());
        CaseService.wishChildRegionValidation(getWishChildRegionValidationParentCases(),
            getWishChildRegionValidationContactIds());
        CaseService.checkBudgetActuals(getCheckBudgetActualsCases());
        CaseService.checkReceivedDates(getCheckReceivedDatesCases());
    }

    // BEFORE DELETE
    public override void handleBeforeDelete() {

    }

    /*
     * @description		OnAfterInsert trigger handler for the Case object
     *
     * @author 			MST Solutions
     * @createdDate		2016-05-26
     */
    public override void handleAfterInsert() {
        CaseService.updateWishRecordIdentifier(newCasesList);
        CaseService.caseTeamInTakeManager(newCasesList);
        CaseService.createCaseFile(newCasesList);
        CaseService.reParentDvTask(newCasesList);
    }

    /*
     * @description		OnAfterUpdate trigger handler for the Case object
     *
     * @author 			MST Solutions
     * @createdDate		2018-03-26
     */
    public override void handleAfterUpdate() {
        // During code cleanup, RecursiveTrigger.blockBeforeUpdate was found to manage BEFORE UPDATE
        // trigger recursion. It isn't presently clear what the consequences of removing this check
        // will be, so leaving it here for the time being.
        if (RecursiveTriggerHandler.blockAfterUpdate) {
            return;
        }

        List<Set<String>> updateLeadStatusApprovedAndDnqLeadIds =
            getUpdateLeadStatusApprovedAndDnqLeadIds();

        CreateAndUpdateUserCaseTeamRoleWrapper uctrWrapper =
            prepareCreateAndUpdateUserCaseTeamRoleWrapper();

        Map<Id,Id> revokeWishPermissionForVolunteersIdsAndContactIds =
            getRevokeWishPermissionForVolunteersIdsAndContactIds();

        Set<Id> readyToAssignChapterIdSet = new Set<Id>();
        Map<Id,Case> createVolunteerOpportunityCaseMap = getCreateVolunteerOpportunityCaseMap();
        for (Case aCase : createVolunteerOpportunityCaseMap.values()) {
            readyToAssignChapterIdSet.add(aCase.ChapterName__c);
        }

        CaseService.populateEndDate(getPopulateEndDateCaseIds());
        CaseService.deleteWishAssistTask(getDeleteWishAssistTaskCaseIds());
        CaseService.deleteUnassignedVolunteerOpp(getDeleteUnassignedVolunteerOppCaseIds());
        CaseService.closeVolOpp(getCloseVolOppCaseIds());
        CaseService.updateLeadStatus(updateLeadStatusApprovedAndDnqLeadIds[0],
            updateLeadStatusApprovedAndDnqLeadIds[1], newCasesList);
        CaseService.updateVolunteerOpp(getUpdateVolunteerOppMap());
        CaseService.updateGrantedDate(getUpdateGrantedDateCases());
        CaseService.createAndUpdateUserCaseTeamRole(uctrWrapper.updateVolunteerManagerCaseTeamMap,
            uctrWrapper.volunteerManagerIdSet, uctrWrapper.wishCoordinatorIdSet);
        CaseService.changeAccessPermission(getChangeAccessPermissionMap());
        CaseService.revokeWishPermissionForVolunteers(revokeWishPermissionForVolunteersIdsAndContactIds.keySet(),
            new Set<Id>(revokeWishPermissionForVolunteersIdsAndContactIds.values()));
        CaseService.grantedWishCount(getGrantedWishCountCaseIds());
        CaseService.updateVolunteerOpportunityStatus(getUpdateVolunteerOpportunityStatusCaseIds());
        CaseService.createVolunteerOpportunity(createVolunteerOpportunityCaseMap, readyToAssignChapterIdSet);
        CaseService.updateVolunteerOpportunityAsInactive(getUpdateVolunteerOpportunityAsInactiveCaseIds());
        CaseService.updateCaseToLeadSubStatus(Constant_AC.LEAD_STATUS_ELIGIBILITY_REVIEW, getMapOfCaseStatusesByLeadId());
    }

    /**
     * @description     Private function to prepare Set of Case Ids for CaseService.populateEndDate
     *
     * @return          Set<Id>
     *
     * @author          Chris Shinnimin, Traction on Demand
     * @createdDate     2020-04-13
     */
    private Set<Id> getPopulateEndDateCaseIds() {
        Set<Id> populateEndDateCaseIds = new Set<Id>();

        for (Case aCase : newCasesList) {
            if (CASE_MEMBER_CHECK_IDS.contains(aCase.RecordTypeId)
                && (Constant_AC.CASE_STATUS_GRANTED.equals(aCase.Status)
                || Constant_AC.CASE_STATUS_CLOSED.equals(aCase.Status))
                && aCase.Status != oldCasesMap.get(aCase.Id).Status
                && aCase.RecordTypeId == WISH_RECORDTYPE_ID) {

                populateEndDateCaseIds.add(aCase.Id);
            }
        }

        return populateEndDateCaseIds;
    }

    /**
     * @description     Private function to prepare Set of Case Ids for CaseService.deleteWishAssistTask
     *
     * @return          Set<Id>
     *
     * @author          Chris Shinnimin, Traction on Demand
     * @createdDate     2020-04-13
     */
    private Set<Id> getDeleteWishAssistTaskCaseIds() {
        Set<Id> deleteWishAssistTaskCaseIds = new Set<Id>();

        for (Case aCase : newCasesList) {
            if (CASE_MEMBER_CHECK_IDS.contains(aCase.RecordTypeId)
                && aCase.RecordTypeId == WISH_RECORDTYPE_ID && aCase.Wish_Assist__c == true
                && oldCasesMap.get(aCase.Id).Wish_Assist__c != true) {

                deleteWishAssistTaskCaseIds.add(aCase.Id);
            }
        }

        return deleteWishAssistTaskCaseIds;
    }

    /**
     * @description     Private function to prepare Set of Case Ids for CaseService.deleteUnassignedVolunteerOpp
     *
     * @return          Set<Id>
     *
     * @author          Chris Shinnimin, Traction on Demand
     * @createdDate     2020-04-13
     */
    private Set<Id> getDeleteUnassignedVolunteerOppCaseIds() {
        Set<Id> deleteUnassignedVolunteerOppCaseIds = new Set<Id>();

        for (Case aCase : newCasesList) {
            if (CASE_MEMBER_CHECK_IDS.contains(aCase.RecordTypeId)
                && aCase.RecordTypeId == WISH_RECORDTYPE_ID
                && PARENT_WISH_ID_SET_STATUSES.contains(aCase.Status)
                && oldCasesMap.get(aCase.Id).Status != aCase.Status
                && RecursiveTriggerHandler.blockCaseLockRecursive == true) {

                deleteUnassignedVolunteerOppCaseIds.add(aCase.Id);
            }
        }

        return deleteUnassignedVolunteerOppCaseIds;
    }

    /**
     * @description     Private function to prepare Set of Case Ids for CaseService.closeVolOpp
     *
     * @return          Set<Id>
     *
     * @author          Chris Shinnimin, Traction on Demand
     * @createdDate     2020-04-13
     */
    private Set<Id> getCloseVolOppCaseIds() {
        Set<Id> closeVolOppCaseIds = new Set<Id>();

        for (Case aCase : newCasesList) {
            if (CASE_MEMBER_CHECK_IDS.contains(aCase.RecordTypeId)
                && (Constant_AC.CASE_STATUS_CLOSED.equals(aCase.Status))
                && aCase.RecordTypeId == WISH_RECORDTYPE_ID
                && aCase.Status != oldCasesMap.get(aCase.Id).Status) {

                closeVolOppCaseIds.add(aCase.Id);
            }
        }

        return closeVolOppCaseIds;
    }

    /**
     * @description     Private function to prepare a List<Set<String>> of Lead Ids for CaseService.updateLeadStatus
     *
     * @return          List<Set<String>>
     *
     * @author          Chris Shinnimin, Traction on Demand
     * @createdDate     2020-04-13
     */
    private List<Set<String>> getUpdateLeadStatusApprovedAndDnqLeadIds() {
        List<Set<String>> updateLeadStatusApprovedAndDnqLeadIds = new List<Set<String>>();
        updateLeadStatusApprovedAndDnqLeadIds.add(new Set<String>()); // updated leads
        updateLeadStatusApprovedAndDnqLeadIds.add(new Set<String>()); // dnq leads

        for (Case aCase : newCasesList) {
            if ((Constant_AC.CASE_STATUS_APPROVED_NATIONAL_MEDICAL_REVIEW.equals(aCase.Status)
                && !Constant_AC.CASE_STATUS_APPROVED_NATIONAL_MEDICAL_REVIEW.equals(oldCasesMap.get(aCase.Id).Status))
                || (Constant_AC.CASE_STATUS_APPROVED_NATIONAL_MAC_REVIEW.equals(aCase.Status)
                && !Constant_AC.CASE_STATUS_APPROVED_NATIONAL_MAC_REVIEW.equals(oldCasesMap.get(aCase.Id).Status))
                && aCase.RecordTypeId == DIAGNOSIS_VERIFICATION_RECORDTYPE_ID) {

                updateLeadStatusApprovedAndDnqLeadIds[0].add(aCase.Lead__c);
            } else if ((Constant_AC.CASE_STATUS_DNQ_NATIONAL_MEDICAL_REVIEW.equals(aCase.Status)
                || Constant_AC.CASE_STATUS_DNQ_NATIONAL_MAC_REVIEW.equals(aCase.Status))
                && aCase.RecordTypeId == DIAGNOSIS_VERIFICATION_RECORDTYPE_ID
                && oldCasesMap.get(aCase.Id).Status != aCase.Status) {

                updateLeadStatusApprovedAndDnqLeadIds[1].add(aCase.Lead__c);
            }
        }

        return updateLeadStatusApprovedAndDnqLeadIds;
    }

    /**
     * @description     Private function to prepare Map of Boolean by VolunteerOpportunity Id for CaseService.updateVolunteerOpp
     *
     * @return          Map<Id,Boolean>
     *
     * @author          Chris Shinnimin, Traction on Demand
     * @createdDate     2020-04-09
     */
    private Map<Id,Boolean> getUpdateVolunteerOppMap() {
        Map<Id,Boolean> updateVolunteerOppMap = new Map<Id,Boolean>();

        for (Case aCase : newCasesList) {
            if (!CASE_MEMBER_CHECK_IDS.contains(aCase.RecordTypeId)) {
                continue;
            }

            if (VOLUNTEER_CASE_ID_CHECK_HAS_STATUS.contains(aCase.Status)
                && aCase.RecordTypeId == WISH_RECORDTYPE_ID
                && RecursiveTriggerHandler.blockCaseLockRecursive == true
                && !VOLUNTEER_CASE_ID_CHECK_NOT_HAS_STATUSES.contains(oldCasesMap.get(aCase.Id).Status)) {

                updateVolunteerOppMap.put(aCase.Id, true);
            }

            if (IN_PROGRESS_UNCHECK_HAS_STATUS.contains(aCase.Status)
                && aCase.RecordTypeId == WISH_RECORDTYPE_ID
                && !IN_PROGRESS_UNCHECK_NOT_HAS_STATUSES.contains(oldCasesMap.get(aCase.Id).Status)) {

                updateVolunteerOppMap.put(aCase.Id, false);
            }
        }

        return updateVolunteerOppMap;
    }

    /**
     * @description     Private function to prepare List of Cases for CaseService.updateGrantedDate
     *
     * @return          List<Case>
     *
     * @author          Chris Shinnimin, Traction on Demand
     * @createdDate     2020-04-09
     */
    private List<Case> getUpdateGrantedDateCases() {
        List<Case> updateGrantedDateCases = new List<Case>();

        for (Case aCase : newCasesList) {
            if (CASE_MEMBER_CHECK_IDS.contains(aCase.RecordTypeId)
                && Constant_AC.CASE_STATUS_GRANTED.equals(aCase.Status)
                && !Constant_AC.CASE_STATUS_GRANTED.equals(oldCasesMap.get(aCase.Id).Status)
                && aCase.ContactId != null
                && aCase.RecordTypeId == WISH_RECORDTYPE_ID) {

                updateGrantedDateCases.add(aCase);
            }
        }

        return updateGrantedDateCases;
    }

    /**
     * @description     Private function to prepare a wrapper object for CaseService.createAndUpdateUserCaseTeamRole
     *
     * @return          CreateAndUpdateUserCaseTeamRoleWrapper
     *
     * @author          Chris Shinnimin, Traction on Demand
     * @createdDate     2020-04-09
     */
    private CreateAndUpdateUserCaseTeamRoleWrapper prepareCreateAndUpdateUserCaseTeamRoleWrapper() {
        CreateAndUpdateUserCaseTeamRoleWrapper wrapper = new CreateAndUpdateUserCaseTeamRoleWrapper();

        wrapper.updateVolunteerManagerCaseTeamMap = new Map<Id,Case>();
        wrapper.volunteerManagerIdSet = new Set<Id>();
        wrapper.wishCoordinatorIdSet = new Set<Id>();

        for (Case aCase : newCasesList) {
            if (!CASE_MEMBER_CHECK_IDS.contains(aCase.RecordTypeId)) {
                continue;
            }

            if (Constant_AC.CASE_STATUS_READY_TO_ASSIGN.equals(aCase.Status)
                && aCase.Status != oldCasesMap.get(aCase.Id).Status
                && RecursiveTriggerHandler.blockCaseLockRecursive == true
                && aCase.RecordTypeId == WISH_RECORDTYPE_ID) {

                wrapper.updateVolunteerManagerCaseTeamMap.put(aCase.Id, aCase);
                wrapper.volunteerManagerIdSet.add(aCase.Id);
            } else if ((Constant_AC.CASE_STATUS_READY_TO_ASSIGN.equals(aCase.Status)
                || Constant_AC.CASE_STATUS_READY_TO_INTERVIEW.equals(aCase.Status))
                && aCase.OwnerId != oldCasesMap.get(aCase.Id).OwnerId
                && RecursiveTriggerHandler.blockCaseLockRecursive == true
                && aCase.RecordTypeId == WISH_RECORDTYPE_ID) {

                wrapper.updateVolunteerManagerCaseTeamMap.put(aCase.Id, aCase);
                wrapper.volunteerManagerIdSet.add(aCase.Id);
            }

            if (aCase.Status != oldCasesMap.get(aCase.Id).Status
                && Constant_AC.CASE_STATUS_WISH_DETERMINED.equals(aCase.Status)
                && RecursiveTriggerHandler.blockCaseLockRecursive == true
                && aCase.RecordTypeId == WISH_RECORDTYPE_ID) {

                wrapper.updateVolunteerManagerCaseTeamMap.put(aCase.Id, aCase);
                wrapper.wishCoordinatorIdSet.add(aCase.Id);
            } else if ((aCase.OwnerId != oldCasesMap.get(aCase.Id).OwnerId
                && RecursiveTriggerHandler.blockCaseLockRecursive == true)
                && WISH_COORDINATOR_ID_CHECK_STATUSES.contains(aCase.Status)
                && aCase.RecordTypeId == WISH_RECORDTYPE_ID) {

                wrapper.updateVolunteerManagerCaseTeamMap.put(aCase.Id, aCase);
                wrapper.wishCoordinatorIdSet.add(aCase.Id);
            }
        }

        return wrapper;
    }

    private class CreateAndUpdateUserCaseTeamRoleWrapper {
        public Map<Id,Case> updateVolunteerManagerCaseTeamMap;
        public Set<Id> volunteerManagerIdSet;
        public Set<Id> wishCoordinatorIdSet;
    }

    /**
     * @description     Private function to prepare Map of Contact Ids by Case Id for CaseService.changeAccessPermission
     *
     * @return          Map<Id,Id>
     *
     * @author          Chris Shinnimin, Traction on Demand
     * @createdDate     2020-04-09
     */
    private Map<Id,Id> getChangeAccessPermissionMap() {
        Map<Id,Id> changeAccessPermissionMap = new Map<Id,Id>();

        for (Case aCase : newCasesList) {
            if (CASE_MEMBER_CHECK_IDS.contains(aCase.RecordTypeId)
                && (!Constant_AC.CASE_STATUS_CLOSED.equals(aCase.Status)
                && !Constant_AC.CASE_STATUS_COMPLETED.equals(aCase.Status)
                && RecursiveTriggerHandler.blockCaseLockRecursive == true)
                && (Constant_AC.CASE_STATUS_CLOSED.equals(oldCasesMap.get(aCase.Id))
                || Constant_AC.CASE_STATUS_COMPLETED.equals(oldCasesMap.get(aCase.Id)))
                && aCase.RecordTypeId == WISH_RECORDTYPE_ID) {

                changeAccessPermissionMap.put(aCase.Id, aCase.ContactId);
            }
        }

        return changeAccessPermissionMap;
    }

    /**
     * @description     Private function to prepare a Set<Id> of Case Ids and a Set<Id> of Contact Ids for CaseService.grantedWishCount
     *
     * @return          Map<Id,Id>
     *
     * @author          Chris Shinnimin, Traction on Demand
     * @createdDate     2020-04-09
     */
    private Map<Id,Id> getRevokeWishPermissionForVolunteersIdsAndContactIds() {
        Map<Id,Id> revokeWishPermissionForVolunteers = new Map<Id,Id>();

        for (Case aCase : newCasesList) {
            if (CASE_MEMBER_CHECK_IDS.contains(aCase.RecordTypeId)
                && (Constant_AC.CASE_STATUS_COMPLETED.equals(aCase.Status)
                || Constant_AC.CASE_STATUS_CLOSED.equals(aCase.Status))
                && (oldCasesMap.get(aCase.Id).Status != aCase.Status
                && aCase.RecordTypeId == WISH_RECORDTYPE_ID)) {

                revokeWishPermissionForVolunteers.put(aCase.Id, aCase.ContactId);
            }
        }

        return revokeWishPermissionForVolunteers;
    }

    /**
     * @description     Private function to prepare Set of Case Ids for CaseService.grantedWishCount
     *
     * @return          Set<Id>
     *
     * @author          Chris Shinnimin, Traction on Demand
     * @createdDate     2020-04-09
     */
    private Set<Id> getGrantedWishCountCaseIds() {
        Set<Id> grantedWishCountCaseIds = new Set<Id>();

        for (Case aCase : newCasesList) {
            if (CASE_MEMBER_CHECK_IDS.contains(aCase.RecordTypeId)
                && Constant_AC.CASE_STATUS_GRANTED.equals(aCase.Status)
                && (!Constant_AC.CASE_STATUS_GRANTED.equals(oldCasesMap.get(aCase.Id).Status)
                && !Constant_AC.CASE_STATUS_COMPLETED.equals(oldCasesMap.get(aCase.Id).Status)
                && !Constant_AC.CASE_STATUS_CLOSED.equals(oldCasesMap.get(aCase.Id).Status))
                && WISH_RECORDTYPE_ID == aCase.RecordTypeId) {

                grantedWishCountCaseIds.add(aCase.Id);
            }
        }

        return grantedWishCountCaseIds;
    }

    /**
     * @description     Private function to prepare Set of Case Ids for CaseService.updateVolunteerOpportunityStatus
     *
     * @return          Set<Id>
     *
     * @author          Chris Shinnimin, Traction on Demand
     * @createdDate     2020-04-09
     */
    private Set<Id> getUpdateVolunteerOpportunityStatusCaseIds() {
        Set<Id> updateVolunteerOpportunityStatusCaseIds = new Set<Id>();

        for (Case aCase : newCasesList) {
            if (CASE_MEMBER_CHECK_IDS.contains(aCase.RecordTypeId)
                && Constant_AC.CASE_STATUS_COMPLETED.equals(aCase.Status)
                && !Constant_AC.CASE_STATUS_COMPLETED.equals(oldCasesMap.get(aCase.Id).Status)
                && aCase.RecordTypeId == WISH_RECORDTYPE_ID) {

                updateVolunteerOpportunityStatusCaseIds.add(aCase.Id);
            }
        }

        return updateVolunteerOpportunityStatusCaseIds;
    }

    /**
     * @description     Private function to prepare Map of Cases by Id for CaseService.createVolunteerOpportunity
     *
     * @return          Map<Id,Case>
     *
     * @author          Chris Shinnimin, Traction on Demand
     * @createdDate     2020-04-09
     */
    private Map<Id,Case> getCreateVolunteerOpportunityCaseMap() {
        Map<Id,Case> createVolunteerOpportunityCaseMap = new Map<Id,Case>();

        if (RecursiveTriggerHandler.isFirstTime == true) {
            return createVolunteerOpportunityCaseMap;
        }

        for (Case aCase : newCasesList) {
            if (CASE_MEMBER_CHECK_IDS.contains(aCase.RecordTypeId)
                && (Constant_AC.CASE_STATUS_READY_TO_ASSIGN.equals(aCase.Status))
                && Constant_AC.CASE_STATUS_QUALIFIED.equals(oldCasesMap.get(aCase.Id).Status)
                && aCase.RecordTypeId == WISH_RECORDTYPE_ID
                && aCase.Wish_Assist__c == false) {

                createVolunteerOpportunityCaseMap.put(aCase.Id, aCase);
            }
        }

        return createVolunteerOpportunityCaseMap;
    }

    /**
     * @description     Private function to prepare Set of Case Ids for CaseService.updateVolunteerOpportunityAsInactive
     *
     * @return          Set<Id>
     *
     * @author          Chris Shinnimin, Traction on Demand
     * @createdDate     2020-04-09
     */
    private Set<Id> getUpdateVolunteerOpportunityAsInactiveCaseIds() {
        Set<Id> updateVolunteerOpportunityAsInactiveCaseIds = new Set<Id>();

        for (Case aCase : newCasesList) {
            if (CASE_MEMBER_CHECK_IDS.contains(aCase.RecordTypeId)
                && !Constant_AC.CASE_STATUS_CLOSED.equals(oldCasesMap.get(aCase.Id).Status)
                && Constant_AC.CASE_STATUS_CLOSED.equals(aCase.Status)
                && aCase.RecordTypeId == WISH_RECORDTYPE_ID) {

                updateVolunteerOpportunityAsInactiveCaseIds.add(aCase.Id);
            }
        }

        return updateVolunteerOpportunityAsInactiveCaseIds;
    }

    /**
     * @description     Private function to prepare Map of Case Statuses by Lead Id for CaseService.updateCaseToLeadSubStatus
     *
     * @return          Map<Id,String>
     *
     * @author          Chris Shinnimin, Traction on Demand
     * @createdDate     2020-04-09
     */
    private Map<Id,String> getMapOfCaseStatusesByLeadId() {
        Map<Id,String> mapOfCaseStatusesByLeadId = new Map<Id,String>();

        for (Case aCase : newCasesList) {
            if (CASE_MEMBER_CHECK_IDS.contains(aCase.RecordTypeId)
                && aCase.RecordTypeId == DIAGNOSIS_VERIFICATION_RECORDTYPE_ID
                && ((Constant_AC.CASE_STATUS_NEW.equals(aCase.Status)
                && !Constant_AC.CASE_STATUS_NEW.equals(oldCasesMap.get(aCase.Id).Status))
                || (Constant_AC.CASE_STATUS_PENDING_CLARIFICATION_MAC.equals(aCase.Status)
                && !Constant_AC.CASE_STATUS_PENDING_CLARIFICATION_MAC.equals(oldCasesMap.get(aCase.Id).Status))
                || (Constant_AC.CASE_STATUS_PENDING_CLARIFICATION_MAC_CONSULT_REQ.equals(aCase.Status)
                && !Constant_AC.CASE_STATUS_PENDING_CLARIFICATION_MAC_CONSULT_REQ.equals(oldCasesMap.get(aCase.Id).Status))
                || (Constant_AC.CASE_STATUS_PENDING_CLARIFICATION_CHAPTER.equals(aCase.Status)
                && !Constant_AC.CASE_STATUS_PENDING_CLARIFICATION_CHAPTER.equals(oldCasesMap.get(aCase.Id).Status)))) {

                mapOfCaseStatusesByLeadId.put(aCase.Lead__c, aCase.Status);
            }
        }

        return mapOfCaseStatusesByLeadId;
    }



    /**
     * @description     Private function used by handleOnBeforeUpdate to populate hidden wish owner fields
     *                  and add errors to parent cases with restriceted permissions.
     *                  Moved to private function by Chris Shinnimin, Traction on Demand, 2020-04-09.
     *
     * @author          MST Solutions
     * @createdDate     unknown
     */
    private void populateHiddenWishOwnerFields() {
        Set<Id> wishOwnerIdSet = new Set<Id>();
        Map<Id,User> wishOwnerMap = new Map<Id,User>();
        Set<Id> parentIdSet = new Set<Id>();

        for (Case aCase : newCasesList) {
            if (WISH_OWNER_CHECK_RECORD_TYPE_IDS.contains(aCase.RecordTypeId)) {
                if (aCase.OwnerId != null && aCase.OwnerId != oldCasesMap.get(aCase.Id).OwnerId) {
                    wishOwnerIdSet.add(aCase.OwnerId);
                }
            }

            if ((aCase.RecordTypeId == WISH_RECORDTYPE_ID || aCase.RecordTypeId == WISH_ASSIST_RECORDTYPE_ID
                || aCase.ParentId != null) && USER_HAS_RESTRICTED_PERMISSIONS_ON_CASE) {

                if (aCase.Status == Constant_AC.CASE_STATUS_COMPLETED && aCase.RecordTypeId == WISH_RECORDTYPE_ID) {
                    parentIdSet.add(aCase.ParentId);
                }
            }
        }

        if (wishOwnerIdSet.isEmpty()) {
            return;
        }

        for (User wishOwner : [
            SELECT Id, ManagerId, Manager.Name, Manager.Email, Email
            FROM User
            WHERE Id IN :wishOwnerIdSet AND ManagerId != NULL
        ]) {
            wishOwnerMap.put(wishOwner.Id, wishOwner);
        }

        for (Case aCase : newCasesList) {
            if (wishOwnerMap.containsKey(aCase.OwnerId)) {
                if (wishOwnerMap.get(aCase.OwnerId).ManagerId != null && aCase.RecordTypeId == WISH_RECORDTYPE_ID) {
                    aCase.Hidden_Wish_Owner_Manager__c = wishOwnerMap.get(aCase.OwnerId).Manager.Name;
                    aCase.Hidden_Wish_Owner_Email__c = wishOwnerMap.get(aCase.OwnerId).Manager.Email;
                }
            }

            if (parentIdSet.contains(aCase.ParentId)) {
                aCase.addError(Label.CaseTrigger_Permission_Error);
            }
        }
    }

    /**
     * @description     Private function to prepare List of Cases for CaseService.updateWishClearanceNeeded
     *
     * @return          List<Case>
     *
     * @author          Chris Shinnimin, Traction on Demand
     * @createdDate     2020-04-08
     */
    private List<Case> getWishChildRegionValidationCases() {
        List<Case> changedNationalTypeCases = new List<Case>();

        for (Case aCase : newCasesList) {
            if (aCase.RecordTypeId == WISH_RECORDTYPE_ID
                && aCase.Wish_Type__c != null
                && aCase.Wish_Type__c != oldCasesMap.get(aCase.Id).Wish_Type__c) {

                changedNationalTypeCases.add(aCase);
            }
        }

        return changedNationalTypeCases;
    }

    /**
     * @description     Private function to prepare List of Cases for CaseService.wishChildRegionValidation
     *
     * @return          List<Case>
     *
     * @author          Chris Shinnimin, Traction on Demand
     * @createdDate     2020-04-08
     */
    private List<Case> getWishChildRegionValidationParentCases() {
        List<Case> parentCases = new List<Case>();

        for (Case aCase : newCasesList) {
            if ((Constant_AC.CASE_STATUS_READY_TO_ASSIGN.equals(aCase.Status))
                && !Constant_AC.CASE_STATUS_READY_TO_ASSIGN.equals(oldCasesMap.get(aCase.Id).Status)
                && aCase.RecordTypeId == WISH_RECORDTYPE_ID) {

                parentCases.add(aCase);
            }
        }

        return parentCases;
    }

    /**
     * @description     Private function to prepare Set of Contacts for CaseService.wishChildRegionValidation
     *
     * @return          Set<Id>
     *
     * @author          Chris Shinnimin, Traction on Demand
     * @createdDate     2020-04-08
     */
    private Set<Id> getWishChildRegionValidationContactIds() {
        Set<Id> contactIds = new Set<Id>();

        for (Case aCase : newCasesList) {
            if ((Constant_AC.CASE_STATUS_READY_TO_ASSIGN.equals(aCase.Status))
                && !Constant_AC.CASE_STATUS_READY_TO_ASSIGN.equals(oldCasesMap.get(aCase.Id).Status)
                && aCase.RecordTypeId == WISH_RECORDTYPE_ID) {

                contactIds.add(aCase.ContactId);
            }
        }

        return contactIds;
    }

    /**
     * @description     Private function to prepare List of Cases for CaseService.checkBudgetActuals
     *
     * @return          List<Case>
     *
     * @author          Chris Shinnimin, Traction on Demand
     * @createdDate     2020-04-08
     */
    private List<Case> getCheckBudgetActualsCases() {
        List<Case> checkBudgetActualsCases = new List<Case>();

        for (Case aCase : newCasesList) {
            if ((Constant_AC.CASE_STATUS_COMPLETED.equals(aCase.Status))
                && (!Constant_AC.CASE_STATUS_COMPLETED.equals(oldCasesMap.get(aCase.Id).Status))
                && aCase.RecordTypeId == WISH_RECORDTYPE_ID) {

                checkBudgetActualsCases.add(aCase);
            }
        }

        return checkBudgetActualsCases;
    }

    /**
     * @description     Private function to prepare List of Cases for CaseService.checkReceivedDates
     *
     * @return          List<Case>
     *
     * @author          Chris Shinnimin, Traction on Demand
     * @createdDate     2020-04-07
     */
    private List<Case> getCheckReceivedDatesCases() {
        List<Case> checkReceivedDatesCases = new List<Case>();

        for (Case aCase : newCasesList) {
            if (aCase.RecordTypeId == WISH_RECORDTYPE_ID
                && aCase.Status != oldCasesMap.get(aCase.Id).Status
                && ((Constant_AC.CASE_STATUS_GRANTED.equals(aCase.Status)
                && (Constant_AC.CASE_STATUS_WISH_SCHEDULED.equals(oldCasesMap.get(aCase.Id).Status)))
                || ((Constant_AC.CASE_STATUS_COMPLETED.equals(aCase.Status))
                && (!Constant_AC.CASE_STATUS_COMPLETED.equals(oldCasesMap.get(aCase.Id).Status))))) {

                checkReceivedDatesCases.add(aCase);
            }
        }

        return checkReceivedDatesCases;
    }
}