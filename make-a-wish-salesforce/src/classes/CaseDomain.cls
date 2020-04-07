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
        Id wishAssistRecordTypeId = Constant_AC.WISH_ASSIST_RT_ID;
        UserSetting__c usc = UserSetting__c.getValues(UserInfo.getUserId());
        List<Case> budgetCaseList = new List<Case>();
        Set<Id> wishOwnerIdSet = new Set<Id>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        Map<Id, Case> parentCaseMap = new Map<Id, Case>();
        Set<Id> contactSet = new Set<Id>();
        Set<Id> parentIdSet = new Set<Id>();
        Map<Id, User> wishOwnerMap = new Map<Id, User>();
        Set<Id> compltedParentIdSet = new Set<Id>();
        Map<Id, Account> managerUserMap = new Map<Id, Account>();
        Map<Id, Case> changedNationalTypeCaseMap = new Map<Id, Case>();

        List<Account> dbAccountList = [
            SELECT Id,MAC_Email_del__c,Name,RecordTypeId
            FROM Account
            WHERE Name = :Constant_AC.ACCOUNT_NAME_MAW_AMERICA
            AND RecordTypeId = :chapterRecordTypeId
            LIMIT 1
        ];

        for (Case currentCase : newCasesMap.values()) {
            if (WISH_OWNER_CHECK_RECORD_TYPE_IDS.contains(currentCase.RecordTypeId)) {
                if (currentCase.OwnerId != null && currentCase.OwnerId != oldCasesMap.get(currentCase.Id).OwnerId) {
                    wishOwnerIdSet.add(currentCase.OwnerId);
                }
                if (currentCase.Comment_1__c != null && oldCasesMap.get(currentCase.Id).Comment_1__c != currentCase.Comment_1__c) {
                    currentCase.Comment__c = currentCase.Comment_1__c;
                }
            }

            if ((Constant_AC.CASE_STATUS_READY_TO_ASSIGN.equals(currentCase.Status))
                && !Constant_AC.CASE_STATUS_READY_TO_ASSIGN.equals(oldCasesMap.get(currentCase.Id).Status)
                && currentCase.RecordTypeId == WISH_RECORDTYPE_ID) {

                caseMap.put(currentCase.ChapterName__c, currentCase);
                currentCase.Ready_to_Assign_Date__c = Date.today();
                parentCaseMap.put(currentCase.Id, currentCase);
                contactSet.add(currentCase.ContactId);
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

            if (currentCase.RecordTypeId == WISH_RECORDTYPE_ID
                && Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null
                && Constant_AC.CASE_STATUS_WISH_DETERMINED.equals(currentCase.Status)
                && currentCase.Wish_Type__c == null) {

                currentCase.Wish_Type__c.addError(Label.CaseTrigger_Enter_Wish_Type);
            }

            if (currentCase.RecordTypeId == WISH_RECORDTYPE_ID
                && Constant_AC.CASE_STATUS_WISH_DETERMINED.equals(currentCase.Status)
                && currentCase.Wish_Type__c != null) {

                caseMap.put(currentCase.ChapterName__c, currentCase);
            }

            //Update the wish clearance needed when the wish national type is changed.
            if (currentCase.RecordTypeId == WISH_RECORDTYPE_ID
                && currentCase.Wish_Type__c != null
                && currentCase.Wish_Type__c != oldCasesMap.get(currentCase.Id).Wish_Type__c) {

                changedNationalTypeCaseMap.put(currentCase.Id, currentCase);
            }

            /* Used to close the wish determine case and open the new planning and Granting and Impact sub cases will open. */
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

            if ((Constant_AC.CASE_STATUS_COMPLETED.equals(currentCase.Status))
                && (!Constant_AC.CASE_STATUS_COMPLETED.equals(oldCasesMap.get(currentCase.Id).Status))
                && currentCase.RecordTypeId == WISH_RECORDTYPE_ID) {

                budgetCaseList.add(currentCase);
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

            Boolean userHasRestrictedPermissionOnCase = CaseService.userHasRestrictedPermissionOnCase();
            if ((currentCase.RecordTypeId == WISH_RECORDTYPE_ID || currentCase.RecordTypeId == wishAssistRecordTypeId
                || currentCase.ParentId != null) && userHasRestrictedPermissionOnCase) {

                parentIdSet.add(currentCase.ParentId);
            }

            if (currentCase.IsLocked__c == true
                && oldCasesMap.get(currentCase.Id).IsLocked__c == true
                && usc != null) {
                if (usc.All_Closed_Cases_except_Abandoned__c == false
                    && currentCase.IsClosed == true
                    && userHasRestrictedPermissionOnCase
                    && currentCase.RecordTypeId == WISH_RECORDTYPE_ID
                    && (!(Constant_AC.CASE_STATUS_COMPLETED.equals(currentCase.Status)
                    && (currentCase.Adoptable__c != oldCasesMap.get(currentCase.Id).Adoptable__c
                    || currentCase.Adopted__c != oldCasesMap.get(currentCase.Id).Adopted__c
                    || currentCase.Adopted_By__c != oldCasesMap.get(currentCase.Id).Adopted_By__c)))) {

                    currentCase.addError(Label.CaseTrigger_Permission_Error);
                }

                if (usc.Edit_Abandoned_Cases__c == false
                    && currentCase.IsClosed == true
                    && userHasRestrictedPermissionOnCase
                    && currentCase.RecordTypeId == WISH_RECORDTYPE_ID) {

                    currentCase.addError(Label.CaseTrigger_Permission_Error);
                }
            } else if (currentCase.IsLocked__c == true
                && oldCasesMap.get(currentCase.Id).IsLocked__c == true
                && userHasRestrictedPermissionOnCase
                && currentCase.RecordTypeId == WISH_RECORDTYPE_ID
                && (!(Constant_AC.CASE_STATUS_COMPLETED.equals(currentCase.Status)
                && (currentCase.Adoptable__c != oldCasesMap.get(currentCase.Id).Adoptable__c
                || currentCase.Adopted__c != oldCasesMap.get(currentCase.Id).Adopted__c
                || currentCase.Adopted_By__c != oldCasesMap.get(currentCase.Id).Adopted_By__c)))) {

                currentCase.addError(Label.CaseTrigger_Permission_Error);
            }

            if (Constant_AC.CASE_SUB_STATUS_ABANDONED.equals(currentCase.Sub_Status__c)
                && Constant_AC.CASE_STATUS_GRANTED.equals(oldCasesMap.get(currentCase.Id).Status)
                && usc == null
                && Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null
                && currentCase.RecordTypeId == WISH_RECORDTYPE_ID) {

                currentCase.addError(Label.CaseTrigger_Permission_Error_Abandoned);
            } else if (Constant_AC.CASE_SUB_STATUS_ABANDONED.equals(currentCase.Sub_Status__c)
                && Constant_AC.CASE_STATUS_GRANTED.equals(oldCasesMap.get(currentCase.Id).Status)
                && usc != null
                && Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null
                && currentCase.RecordTypeId == WISH_RECORDTYPE_ID) {
                if (usc.Abandon_the_Granted_case__c == false) {

                    currentCase.addError(Label.CaseTrigger_Permission_Error_Abandoned);
                }
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
        }

        if (wishOwnerIdSet.size() > 0) {
            for (User wishOwner : [
                SELECT Id,ManagerId,Manager.Name,Manager.Email,Email
                FROM User
                WHERE Id IN :wishOwnerIdSet AND ManagerId != NULL
                LIMIT 50000
            ]) {
                wishOwnerMap.put(wishOwner.Id, wishOwner);
            }
        }

        if (parentIdSet.size() > 0) {
            for (Case parentCase : [
                SELECT Id,Status
                FROM Case
                WHERE Status = :Constant_AC.CASE_STATUS_COMPLETED
                AND Id IN :parentIdSet
                AND RecordTypeId = :WISH_RECORDTYPE_ID
                LIMIT 50000
            ]) {
                compltedParentIdSet.add(parentCase.Id);
            }
        }

        for (Case newCase : newCasesMap.values()) {
            if (wishOwnerMap.containsKey(newCase.OwnerId)) {
                if (wishOwnerMap.get(newCase.OwnerId).ManagerId != null && newCase.RecordTypeId == WISH_RECORDTYPE_ID) {
                    newCase.Hidden_Wish_Owner_Manager__c = wishOwnerMap.get(newCase.OwnerId).Manager.Name;
                    newCase.Hidden_Wish_Owner_Email__c = wishOwnerMap.get(newCase.OwnerId).Manager.Email;
                }
            }

            if (compltedParentIdSet.contains(newCase.ParentId)) {
                newCase.addError(Label.CaseTrigger_Permission_Error);
            }
        }

        // Case Owner Old Logic
        if (caseMap.size() > 0) {
            for (Account currentAccount : [
                SELECT Id,Volunteer_Manager__c,Wish_Co_ordinator__c
                FROM Account
                WHERE Id IN:caseMap.keySet()
                LIMIT 50000
            ]) {
                managerUserMap.put(currentAccount.Id, currentAccount);
            }
        }

        if (changedNationalTypeCaseMap.size() > 0) {
            CaseService.updateWishClearanceNeeded(changedNationalTypeCaseMap);
        }
        if (parentCaseMap.size() > 0) {
            CaseService.wishChildRegionValidation(parentCaseMap, contactSet);
        }

        if (budgetCaseList.size() > 0) {
            CaseService.checkBudgetActuals(budgetCaseList);
        }

        CaseService.checkReceivedDates(getCheckReceivedDatesCases());
    }

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
        List<Case> eligibilityReviewCaseList = new List<Case>();
        Set<Id> parentIdsSet = new Set<Id>();
        Map<Id, Case> parentCaseIntakeOwnerMap = new Map<Id, Case>();
        Set<Id> chapterNames = new Set<Id>();
        Set<Id> wishFormCaseIdSet = new Set<Id>();
        List<Case> newCaseFileList = new List<Case>();
        List<Case> potentialRushList = new List<Case>();

        for (Case newWish : newCasesList) {
            if (newWish.RecordTypeId == DIAGNOSIS_VERIFICATION_RECORDTYPE_ID || newWish.RecordTypeId == WISH_RECORDTYPE_ID || newWish.RecordTypeId == WISH_ASSIST_RECORDTYPE_ID) {
                if (newWish.RecordTypeId == DIAGNOSIS_VERIFICATION_RECORDTYPE_ID && newWish.Subject == Constant_AC.CASE_SUBJECT_ELIGIBILITY_REVIEW) {
                    eligibilityReviewCaseList.add(newWish);
                }

                if (newWish.RecordTypeId == WISH_ASSIST_RECORDTYPE_ID) {
                    if (newWish.IsClosed != true && newWish.Status != Constant_AC.CASE_STATUS_COMPLETED) {
                        parentIdsSet.add(newWish.ParentId);
                    }
                } else if (newWish.RecordTypeId == WISH_RECORDTYPE_ID) {
                    wishFormCaseIdSet.add(newWish.Id);
                    if (newWish.IsClosed != true) {
                        parentCaseIntakeOwnerMap.put(newWish.Id, newWish);
                        parentIdsSet.add(newWish.Id);
                        chapterNames.add(newWish.ChapterName__c);
                    }

                    if (!newWish.Rush__c) {
                        potentialRushList.add(newWish);
                    }
                }
            }
            newCaseFileList.add(newWish);
        }

        if (parentIdsSet.size() > 0 && chapterNames.size() > 0) {
            CaseService.UpdateWishRecordIdentifier(parentIdsSet, chapterNames, WISH_RECORDTYPE_ID);
        }

        if (parentCaseIntakeOwnerMap.size() > 0) {
            CaseService.caseTeamInTakeManager(parentCaseIntakeOwnerMap);
        }

        if (newCaseFileList.size() > 0) {
            CaseService.createCaseFile(newCaseFileList);
        }

        if (wishFormCaseIdSet.size() > 0) {
            CaseService.wishFormChildRec(wishFormCaseIdSet);
            CaseService.reParentDvTask(wishFormCaseIdSet);
        }
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

        Set<Id> newWishClearanceSet = new Set<Id>();
        Set<Id> closeTaskParentIdSet = new Set<Id>();
        Set<Id> caseIdSetForVolOpp = new Set<Id>();
        Map<Id, Case> updateVolunteerManagerCaseTeamMap = new Map<Id, Case>();
        Set<Id> volunteerManagerIdSet = new Set<Id>();
        Set<Id> wishCoordinatorIdSet = new Set<Id>();
        Map<Id, Id> caseContactMap = new Map<Id, Id>();
        Set<Id> volunteerCaseIdSet = new Set<Id>();
        Map<Id, Case> caseIdsMap = new Map<Id, Case>();
        Set<String> newWishTypeSet = new Set<String>();
        Set<String> updatedApprovedLeadInfoSet = new Set<String>();
        Set<String> updatedDnqLeadInfoSet = new Set<String>();
        Set<Id> caseTeamMemberParentIdSet = new Set<Id>();
        Set<Id> revokingContactIdSet = new Set<Id>();
        Set<Id> presentationCloseTaskIdsSet = new Set<Id>();
        Map<Id, Case> presentationCloseTaskParentIdMap = new Map<Id, Case>();
        Set<Id> presentationOpenTaskIdsSet = new Set<Id>();
        Set<Id> endDateIdSet = new Set<Id>();
        Set<Id> newMedicalSummarySet = new Set<Id>();
        Map<Id, Case> wishClearanceMap = new Map<Id, Case>();
        Map<Id, String> approvedBudgetStatus = new Map<Id, String>();
        Set<Id> wishIds = new Set<Id>();
        List<Case> PartAWishList = new List<Case>();
        Map<Id, Case> removeAnticipationTaskMap = new Map<Id, Case>();
        Map<Id, Case> updateAnticipationTaskMap = new Map<Id, Case>();
        Set<String> wishTypes = new Set<String>();
        Set<Id> inProgressUnCheckCaseIdsSet = new Set<Id>();
        Map<Id, Case> readyToAssignParentCaseMap = new Map<Id, Case>();
        Set<Id> readyToAssignChapterIdSet = new Set<Id>();
        List<Case> wishGrantedIdList = new List<Case>();
        Set<Id> parentWishIdSet = new Set<Id>();
        Set<Id> closedCaseIdSet = new Set<Id>();
        Set<Id> completedCaseIdSet = new Set<Id>();
        List<Case> exceptionList = new List<Case>();
        Set<Id> wishGrantedSet = new Set<Id>();
        Map<Id, Case> parentWishClearanceMap = new Map<Id, Case>();
        Map<Id, String> caseToLeadSubStatusUpdate = new Map<Id, String>();
        Set<Id> closeBirthDayTaskSet = new Set<Id>();

        for (Case caseMemberCheck : newCasesMap.values()) {
            if (CASE_MEMBER_CHECK_IDS.contains(caseMemberCheck.RecordTypeId)) {

                if (caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID && caseMemberCheck.Wish_Assist__c == true
                    && oldCasesMap.get(caseMemberCheck.Id).Wish_Assist__c != true) {

                    closeTaskParentIdSet.add(caseMemberCheck.Id);
                }

                if ((Constant_AC.CASE_STATUS_CLOSED.equals(caseMemberCheck.Status))
                    && caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID
                    && caseMemberCheck.Status != oldCasesMap.get(caseMemberCheck.Id).Status) {

                    caseIdSetForVolOpp.add(caseMemberCheck.Id);
                }

                if ((Constant_AC.CASE_STATUS_GRANTED.equals(caseMemberCheck.Status)
                    || Constant_AC.CASE_STATUS_CLOSED.equals(caseMemberCheck.Status))
                    && caseMemberCheck.Status != oldCasesMap.get(caseMemberCheck.Id).Status
                    && caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID) {

                    wishGrantedSet.add(caseMemberCheck.Id);
                }

                if (Constant_AC.CASE_STATUS_READY_TO_ASSIGN.equals(caseMemberCheck.Status)
                    && caseMemberCheck.Status != oldCasesMap.get(caseMemberCheck.Id).Status
                    && RecursiveTriggerHandler.blockCaseLockRecursive == true
                    && caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID) {

                    updateVolunteerManagerCaseTeamMap.put(caseMemberCheck.Id, caseMemberCheck);
                    volunteerManagerIdSet.add(caseMemberCheck.Id);
                } else if ((Constant_AC.CASE_STATUS_READY_TO_ASSIGN.equals(caseMemberCheck.Status)
                    || Constant_AC.CASE_STATUS_READY_TO_INTERVIEW.equals(caseMemberCheck.Status))
                    && caseMemberCheck.OwnerId != oldCasesMap.get(caseMemberCheck.Id).OwnerId
                    && RecursiveTriggerHandler.blockCaseLockRecursive == true
                    && caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID) {

                    updateVolunteerManagerCaseTeamMap.put(caseMemberCheck.Id, caseMemberCheck);
                    volunteerManagerIdSet.add(caseMemberCheck.Id);
                }

                if (caseMemberCheck.Status != oldCasesMap.get(caseMemberCheck.Id).Status
                    && Constant_AC.CASE_STATUS_WISH_DETERMINED.equals(caseMemberCheck.Status)
                    && RecursiveTriggerHandler.blockCaseLockRecursive == true
                    && caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID) {

                    updateVolunteerManagerCaseTeamMap.put(caseMemberCheck.Id, caseMemberCheck);
                    wishCoordinatorIdSet.add(caseMemberCheck.Id);
                } else if ((caseMemberCheck.OwnerId != oldCasesMap.get(caseMemberCheck.Id).OwnerId
                    && RecursiveTriggerHandler.blockCaseLockRecursive == true)
                    && WISH_COORDINATOR_ID_CHECK_STATUSES.contains(caseMemberCheck.Status)
                    && caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID) {

                    updateVolunteerManagerCaseTeamMap.put(caseMemberCheck.Id, caseMemberCheck);
                    wishCoordinatorIdSet.add(caseMemberCheck.Id);
                }

                if ((!Constant_AC.CASE_STATUS_CLOSED.equals(caseMemberCheck.Status)
                    && !Constant_AC.CASE_STATUS_COMPLETED.equals(caseMemberCheck.Status)
                    && RecursiveTriggerHandler.blockCaseLockRecursive == true)
                    && (Constant_AC.CASE_STATUS_CLOSED.equals(oldCasesMap.get(caseMemberCheck.Id))
                    || Constant_AC.CASE_STATUS_COMPLETED.equals(oldCasesMap.get(caseMemberCheck.Id)))
                    && caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID) {

                    caseContactMap.put(caseMemberCheck.Id, caseMemberCheck.ContactId);
                }

                if (VOLUNTEER_CASE_ID_CHECK_HAS_STATUS.contains(caseMemberCheck.Status)
                    && caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID
                    && RecursiveTriggerHandler.blockCaseLockRecursive == true
                    && !VOLUNTEER_CASE_ID_CHECK_NOT_HAS_STATUSES.contains(oldCasesMap.get(caseMemberCheck.Id).Status)) {

                    volunteerCaseIdSet.add(caseMemberCheck.Id);
                }

                if (oldCasesMap.get(caseMemberCheck.Id).Wish_Type__c != caseMemberCheck.Wish_Type__c
                    && caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID) {

                    caseIdsMap.put(caseMemberCheck.Id, caseMemberCheck);
                    newWishTypeSet.add(caseMemberCheck.Wish_Type__c);
                }

                if ((Constant_AC.CASE_STATUS_APPROVED_NATIONAL_MEDICAL_REVIEW.equals(caseMemberCheck.Status)
                    && !Constant_AC.CASE_STATUS_APPROVED_NATIONAL_MEDICAL_REVIEW.equals(oldCasesMap.get(caseMemberCheck.Id).Status))
                    || (Constant_AC.CASE_STATUS_APPROVED_NATIONAL_MAC_REVIEW.equals(caseMemberCheck.Status)
                    && !Constant_AC.CASE_STATUS_APPROVED_NATIONAL_MAC_REVIEW.equals(oldCasesMap.get(caseMemberCheck.Id).Status))
                    && caseMemberCheck.RecordTypeId == DIAGNOSIS_VERIFICATION_RECORDTYPE_ID) {

                    updatedApprovedLeadInfoSet.add(caseMemberCheck.Lead__c);
                } else if ((Constant_AC.CASE_STATUS_DNQ_NATIONAL_MEDICAL_REVIEW.equals(caseMemberCheck.Status)
                    || Constant_AC.CASE_STATUS_DNQ_NATIONAL_MAC_REVIEW.equals(caseMemberCheck.Status))
                    && caseMemberCheck.RecordTypeId == DIAGNOSIS_VERIFICATION_RECORDTYPE_ID
                    && oldCasesMap.get(caseMemberCheck.Id).Status != caseMemberCheck.Status) {

                    updatedDnqLeadInfoSet.add(caseMemberCheck.Lead__c);
                }

                if ((Constant_AC.CASE_STATUS_COMPLETED.equals(caseMemberCheck.Status)
                    || Constant_AC.CASE_STATUS_CLOSED.equals(caseMemberCheck.Status))
                    && (oldCasesMap.get(caseMemberCheck.Id).Status != caseMemberCheck.Status
                    && caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID)) {

                    caseTeamMemberParentIdSet.add(caseMemberCheck.Id);
                    revokingContactIdSet.add(caseMemberCheck.ContactId);
                }

                if (CLOSE_BIRTHDAY_TASK_SET_STATUSES.contains(caseMemberCheck.Status)
                    && (oldCasesMap.get(caseMemberCheck.Id).Status != caseMemberCheck.Status
                    && caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID)) {

                    closeBirthDayTaskSet.add(caseMemberCheck.Id);
                }

                // Wish Granted task
                if (caseMemberCheck.End_Date__c != null
                    && oldCasesMap.get(caseMemberCheck.Id).End_Date__c
                    != caseMemberCheck.End_Date__c
                    && caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID) {

                    endDateIdSet.add(caseMemberCheck.Id);
                    presentationCloseTaskIdsSet.add(caseMemberCheck.Id);
                    presentationCloseTaskParentIdMap.put(caseMemberCheck.Id, caseMemberCheck);
                }

                // New medical summary needed
                if ((caseMemberCheck.Start_Date__c != oldCasesMap.get(caseMemberCheck.Id).Start_Date__c)
                    && CASE_MEMBER_WISH_TYPE_CHECK.contains(caseMemberCheck.Wish_Type__c)
                    && caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID) {

                    if ((caseMemberCheck.Start_Date__c == null) || ((caseMemberCheck.Start_Date__c != null))) {
                        newMedicalSummarySet.add(caseMemberCheck.Id);
                        wishClearanceMap.put(caseMemberCheck.Id, caseMemberCheck);
                    }
                }

                // New wish clearance needed
                if (caseMemberCheck.End_Date__c != null
                    && caseMemberCheck.End_Date__c != oldCasesMap.get(caseMemberCheck.Id).End_Date__c
                    && caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID) {

                    if ((caseMemberCheck.Wish_Clearance_Received_Date__c == null)
                        || (Date.today().monthsBetween(caseMemberCheck.Wish_Clearance_Received_Date__c) > 6)) {
                        newWishClearanceSet.add(caseMemberCheck.Id);
                        wishClearanceMap.put(caseMemberCheck.Id, caseMemberCheck);
                    }
                }

                if (caseMemberCheck.End_Date__c == null
                    && oldCasesMap.get(caseMemberCheck.Id).End_Date__c != caseMemberCheck.End_Date__c
                    && caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID) {

                    endDateIdSet.add(caseMemberCheck.Id);
                    if (caseMemberCheck.Wish_Assist__c == false) {
                        presentationOpenTaskIdsSet.add(caseMemberCheck.Id);
                    }

                    presentationCloseTaskParentIdMap.put(caseMemberCheck.Id, caseMemberCheck);
                }

                if (Constant_AC.CASE_BUDGET_APPROVAL_STATUS_APPROVED.equals(caseMemberCheck.Budget_Approval_Status__c)
                    && caseMemberCheck.Budget_Approval_Status__c != oldCasesMap.get(caseMemberCheck.Id).Budget_Approval_Status__c
                    && caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID) {

                    approvedBudgetStatus.put(caseMemberCheck.Id, caseMemberCheck.Budget_Approval_Status__c);
                }

                if (Constant_AC.CASE_STATUS_GRANTED.equals(caseMemberCheck.Status)
                    && (!Constant_AC.CASE_STATUS_GRANTED.equals(oldCasesMap.get(caseMemberCheck.Id).Status)
                    && !Constant_AC.CASE_STATUS_COMPLETED.equals(oldCasesMap.get(caseMemberCheck.Id).Status)
                    && !Constant_AC.CASE_STATUS_CLOSED.equals(oldCasesMap.get(caseMemberCheck.Id).Status))
                    && WISH_RECORDTYPE_ID == caseMemberCheck.RecordTypeId) {

                    wishIds.add(caseMemberCheck.Id);
                }

                if (caseMemberCheck.Status != oldCasesMap.get(caseMemberCheck.Id).Status
                    && caseMemberCheck.RecordTypeId == DIAGNOSIS_VERIFICATION_RECORDTYPE_ID
                    && caseMemberCheck.Lead__c != null) {

                    if (Constant_AC.CASE_STATUS_OPEN.equals(caseMemberCheck.Status)
                        || Constant_AC.CASE_STATUS_ESCALATED.equals(caseMemberCheck.Status)) {

                        PartAWishList.add(caseMemberCheck);
                    }
                }

                if (caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID
                    && caseMemberCheck.Start_Date__c == null
                    && oldCasesMap.get(caseMemberCheck.Id).Start_Date__c != null) {

                    removeAnticipationTaskMap.put(caseMemberCheck.Id, caseMemberCheck);
                } else if (caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID
                    && caseMemberCheck.Start_Date__c != null
                    && caseMemberCheck.Start_Date__c != oldCasesMap.get(caseMemberCheck.Id).Start_Date__c) {

                    updateAnticipationTaskMap.put(caseMemberCheck.Id, caseMemberCheck);
                    wishTypes.add(caseMemberCheck.Wish_Type__c);
                }


                if (IN_PROGRESS_UNCHECK_HAS_STATUS.contains(caseMemberCheck.Status)
                    && caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID
                    && !IN_PROGRESS_UNCHECK_NOT_HAS_STATUSES.contains(oldCasesMap.get(caseMemberCheck.Id).Status)) {

                    inProgressUnCheckCaseIdsSet.add(caseMemberCheck.Id);
                }

                // For creating 2 volunteer opportunity record when the case status changed to "Ready to Assign" from "Qualified".
                if ((Constant_AC.CASE_STATUS_READY_TO_ASSIGN.equals(caseMemberCheck.Status))
                    && Constant_AC.CASE_STATUS_QUALIFIED.equals(oldCasesMap.get(caseMemberCheck.Id).Status)
                    && caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID
                    && caseMemberCheck.Wish_Assist__c == false) {
                    if (RecursiveTriggerHandler.isFirstTime == true) {

                        readyToAssignParentCaseMap.put(caseMemberCheck.Id, caseMemberCheck);
                        readyToAssignChapterIdSet.add(caseMemberCheck.ChapterName__c);
                    }
                }

                // if Status is 'Granted' then populate the hiddengranteddate in Contact
                if (Constant_AC.CASE_STATUS_GRANTED.equals(caseMemberCheck.Status)
                    && !Constant_AC.CASE_STATUS_GRANTED.equals(oldCasesMap.get(caseMemberCheck.Id).Status)
                    && caseMemberCheck.ContactId != null
                    && caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID) {

                    wishGrantedIdList.add(caseMemberCheck);
                }

                if (caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID
                    && PARENT_WISH_ID_SET_STATUSES.contains(caseMemberCheck.Status)
                    && oldCasesMap.get(caseMemberCheck.Id).Status != caseMemberCheck.Status
                    && RecursiveTriggerHandler.blockCaseLockRecursive == true) {

                    parentWishIdSet.add(caseMemberCheck.Id);
                }

                if (Constant_AC.CASE_STATUS_COMPLETED.equals(caseMemberCheck.Status)
                    && !Constant_AC.CASE_STATUS_COMPLETED.equals(oldCasesMap.get(caseMemberCheck.Id).Status)
                    && caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID) {

                    completedCaseIdSet.add(caseMemberCheck.Id);
                }
                if (!Constant_AC.CASE_STATUS_CLOSED.equals(oldCasesMap.get(caseMemberCheck.Id).Status)
                    && Constant_AC.CASE_STATUS_CLOSED.equals(caseMemberCheck.Status)
                    && caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID) {

                    closedCaseIdSet.add(caseMemberCheck.Id);
                }

                if (caseMemberCheck.Wish_Clearance_Needed__c != oldCasesMap.get(caseMemberCheck.Id).Wish_Clearance_Needed__c
                    && caseMemberCheck.RecordTypeId == WISH_RECORDTYPE_ID
                    && caseMemberCheck.Wish_Clearance_Needed__c != null) {

                    parentWishClearanceMap.put(caseMemberCheck.Id, caseMemberCheck);
                }

                exceptionList.add(caseMemberCheck);
            }

            if (caseMemberCheck.RecordTypeId == DIAGNOSIS_VERIFICATION_RECORDTYPE_ID
                && ((Constant_AC.CASE_STATUS_NEW.equals(caseMemberCheck.Status)
                && !Constant_AC.CASE_STATUS_NEW.equals(oldCasesMap.get(caseMemberCheck.Id).Status))
                || (Constant_AC.CASE_STATUS_PENDING_CLARIFICATION_MAC.equals(caseMemberCheck.Status)
                && !Constant_AC.CASE_STATUS_PENDING_CLARIFICATION_MAC.equals(oldCasesMap.get(caseMemberCheck.Id).Status))
                || (Constant_AC.CASE_STATUS_PENDING_CLARIFICATION_MAC_CONSULT_REQ.equals(caseMemberCheck.Status)
                && !Constant_AC.CASE_STATUS_PENDING_CLARIFICATION_MAC_CONSULT_REQ.equals(oldCasesMap.get(caseMemberCheck.Id).Status))
                || (Constant_AC.CASE_STATUS_PENDING_CLARIFICATION_CHAPTER.equals(caseMemberCheck.Status)
                && !Constant_AC.CASE_STATUS_PENDING_CLARIFICATION_CHAPTER.equals(oldCasesMap.get(caseMemberCheck.Id).Status)))) {

                caseToLeadSubStatusUpdate.put(caseMemberCheck.Lead__c, caseMemberCheck.Status);
            }
        }

        if (wishGrantedSet.size() > 0) {
            CaseService.populateEndDate(wishGrantedSet);
        }
        if (closeTaskParentIdSet.size() > 0) {
            CaseService.deleteWishAssistTask(closeTaskParentIdSet, exceptionList);
        }
        if (parentWishIdSet.size() > 0) {
            CaseService.deleteUnassignedVolunteerOpp(parentWishIdSet, exceptionList);
        }
        if (caseIdSetForVolOpp.size() > 0) {
            CaseService.closeVolOpp(caseIdSetForVolOpp, exceptionList);
        }
        if (updatedApprovedLeadInfoSet.size() > 0 || updatedDnqLeadInfoSet.size() > 0) {
            CaseService.updateLeadStatus(updatedApprovedLeadInfoSet, updatedDnqLeadInfoSet, exceptionList);
        }
        if (volunteerCaseIdSet.size() > 0) {
            CaseService.updateVolunteerOpp(volunteerCaseIdSet, true, exceptionList);
        }
        if (inProgressUnCheckCaseIdsSet.size() > 0) {
            CaseService.updateVolunteerOpp(inProgressUnCheckCaseIdsSet, false, exceptionList);
        }
        if (wishGrantedIdList.size() > 0) {
            CaseService.updateGrantedDate(wishGrantedIdList);
        }
        if (updateVolunteerManagerCaseTeamMap.size() > 0) {
            CaseService.createAndUpdateUserCaseTeamRole(updateVolunteerManagerCaseTeamMap, volunteerManagerIdSet, wishCoordinatorIdSet);
        }
        if (caseContactMap.size() > 0) {
            CaseService.changeAccessPermission(caseContactMap, exceptionList);
        }
        if (caseTeamMemberParentIdSet.size() > 0 && revokingContactIdSet.size() > 0) {
            CaseService.revokeWishPermissionForVolunteers(caseTeamMemberParentIdSet, revokingContactIdSet);
        }
        /*
		 * SCC-75:	CaseService.updateLeadStatus(List<Case> caseList) is found to do nothing.
		 * Chris Shinnimin, Traction on Demand
		if (PartAWishList.size() > 0) {
			CaseService.updateLeadStatus(PartAWishList);
		}
		*/
        if (wishIds.size() > 0) {
            CaseService.grantedWishCount(wishIds);
        }
        if (completedCaseIdSet.size() > 0 && completedCaseIdSet != null) {
            CaseService.updateVolunteerOpportunityStatus(completedCaseIdSet, exceptionList);
        }
        if (readyToAssignParentCaseMap.size() > 0 && readyToAssignChapterIdSet.size() > 0) {
            CaseService.createVolunteerOpportunity(readyToAssignParentCaseMap, readyToAssignChapterIdSet);
        }
        if (closedCaseIdSet.size() > 0) {
            CaseService.updateVolunteerOpportunityasInactive(closedCaseIdSet, exceptionList);
        }
        if (parentWishClearanceMap.size() > 0) {
            CaseService.updateWishClearanceForm(parentWishClearanceMap);
        }
        if (caseToLeadSubStatusUpdate.size() > 0) {
            CaseService.updateCaseToLeadSubStatus(Constant_AC.LEAD_STATUS_ELIGIBILITY_REVIEW, caseToLeadSubStatusUpdate);
        }
    }
}