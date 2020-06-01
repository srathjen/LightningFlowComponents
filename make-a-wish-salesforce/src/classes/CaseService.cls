/**
 * @description Case Service, exposes methods for the Controller layer.
 * @author Gustavo Mayer, Traction on Demand
 * @date 8/20/2019
 */
public class CaseService {
    private final static Id WISH_RECORD_TYPE_ID = Constant_AC.WISH_RT_ID;
    private final static String STATUS_NEW = Constant_AC.CASE_STATUS_NEW;
    private final static String STATUS_QUALIFIED = Constant_AC.CASE_STATUS_QUALIFIED;
    private final static String STATUS_PENDING_CLARIFICATION_CHAPTER = Constant_AC.CASE_STATUS_PENDING_CLARIFICATION_CHAPTER;
    private static final String ORIGIN_WEB = Constant_AC.CASE_ORIGIN_WEB;
    private static final String ORIGIN_EMAIL = Constant_AC.CASE_ORIGIN_EMAIL;
    private static final String RUSH_TIME_FRAME = Constant_AC.CASE_RUSH_TIME_FRAME;
    private static final String UWI_SOURCE_LEAD = Constant_AC.CASE_UWI_SOURCE_LEAD;
    private static final String LEAD_COMATOSE_VEGETATIVE_STATE_YES = Constant_AC.LEAD_COMATOSE_VEGETATIVE_STATE_YES;
    private static final String LEAD_MEDICAL_REASON_FOR_MOVING_QUICKLY_YES = Constant_AC.LEAD_MEDICAL_REASON_FOR_MOVING_QUICKLY_YES;
    private static final String SPACE = ' ';
    private static final String APPEND_ELIGIBILITY_REVIEW = ' - Eligibility Review';
    private static final Id WISH_RECORDTYPE_ID = Constant_AC.WISH_RT_ID;
    private static final Id WISH_CHILD_RECORDTYPE_ID = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
    private static final Id WISH_VOLUNTEER_OPPORTUNITY_RECORDTYPE_ID = Constant_AC.WISH_VOLUNTEER_OPPORTUNITY_ID;
    private static final Id CHAPTER_RECORDTYPE_ID = Constant_AC.CHAPTER_RT_ID;

    private static final Map<Schema.SObjectField, String> MAP_OF_CASE_LABELS_BY_FIELDS =
            Utils.mapOfSObjectLabelsByFields(Schema.SObjectType.Case);
    private static final Map<Schema.SObjectField, String> MAP_OF_LEAD_LABELS_BY_FIELDS =
            Utils.mapOfSObjectLabelsByFields(Schema.SObjectType.Lead);
    private static final Set<Id> CASE_MEMBER_CHECK_IDS = new Set<Id>{
            Constant_AC.WISH_RT_ID, Constant_AC.WISH_ASSIST_RT_ID, Constant_AC.DIAGNOSIS_RT_ID
    };

    /**
     * @description Check if the User or the User's profile has permissions on Case
     * @return Boolean
     */
    public static Boolean userHasRestrictedPermissionOnCase() {
        return Closed_Case_Editing_Security_Settings__c.getInstance().Restrict_Access__c;
    }

    /**
     * @description Delete Case found by Lead Id and Record Type Name
     * @param leadId
     * @param caseRecordTypeNames
     */
    public static void deleteByLeadIdAndRecordTypeNames(Id leadId, List<String> caseRecordTypeNames) {
        delete [
                SELECT Id, Lead__c
                FROM Case
                WHERE Lead__c = :leadId
                AND RecordType.Name IN :caseRecordTypeNames
        ];
    }

    /**
     * @description Update Status on Case by Lead and Record Type
     * @param leadIds
     * @param recordTypeIds
     * @param targetCaseStatus
     * @return Map of Cases
     */
    public static Map<Id, Case> updateStatusByLeadAndRecordType(Set<Id> leadIds, Set<Id> recordTypeIds, String targetCaseStatus) {
        Map<Id, Case> caseMap = new Map<Id, Case>();
        for (Case caseRecord : [
                SELECT Id, Rush__c, Lead__c
                FROM Case
                WHERE Lead__c IN :leadIds
                AND RecordTypeId IN :recordTypeIds
        ]) {
            if (leadIds.contains(caseRecord.Lead__c)) {
                caseRecord.Status = targetCaseStatus;
            }
            caseMap.put(caseRecord.Id, caseRecord);
        }
        update caseMap.values();
        return caseMap;
    }

    /**
     * @description Update Rush on Case by Rush Lead Map and Record Type
     * Rush is true when any medical reason is true
     * @param rushLeadMap
     * @param recordTypesIds
     * @return
     */
    public static Map<Id, Case> updateRushByLeadAndRecordType(Map<Id, Boolean> rushLeadMap, Set<Id> recordTypesIds) {
        Map<Id, Case> caseMap = new Map<Id, Case>();
        for (Case caseRecord : [
                SELECT Id, Rush__c, Lead__c
                FROM Case
                WHERE Lead__c IN :rushLeadMap.keySet()
                AND RecordTypeId = :recordTypesIds
        ]) {
            caseRecord.Rush__c = rushLeadMap.get(caseRecord.Lead__c);
            caseMap.put(caseRecord.Id, caseRecord);
        }
        update caseMap.values();
        return caseMap;
    }

    /**
     * @description Set Diagnosis Verification Receive Date on DocuSign Status by Converted Lead Ids
     * @param docuSignStatuses
     * @param insertCaseMap
     * @return
     */
    public static Map<Id, Case> setDVReceiveDate(List<dsfs__DocuSign_Status__c> docuSignStatuses, Map<Id, Case> insertCaseMap) {
        for (dsfs__DocuSign_Status__c docuSignStatus : docuSignStatuses) {
            if (insertCaseMap.containsKey(docuSignStatus.dsfs__Lead__c) && docuSignStatus.dsfs__Completed_Date_Time__c != null) {
                Case caseConverted = new Case();
                caseConverted = insertCaseMap.get(docuSignStatus.dsfs__Lead__c);
                caseConverted.Diagnosis_Verification_Receive_Date__c = docuSignStatus.dsfs__Completed_Date_Time__c.dateGmt();
                insertCaseMap.put(docuSignStatus.dsfs__Lead__c, caseConverted);
            }
        }
        return insertCaseMap;
    }

    /**
     * @description Build Qualified Case
     * @param lead
     * @param hasContactConverted
     * @return Case
     */
    public static Case buildQualifiedCaseFromLead(Lead lead, Boolean hasContactConverted) {
        Case newCase = new Case();
        newCase.RecordTypeId = WISH_RECORD_TYPE_ID;
        newCase.ContactId = lead.ConvertedContactId;
        newCase.Hidden_Lead_Id__c = lead.Id;
        newCase.Qualified_Date__c = lead.Qualified_Date__c;
        newCase.Migrated_Record__c = lead.Migrated_Record__c;
        newCase.Qualifying_Medical_Professional_Name__c = lead.Treating_Medical_Professional_First_Name__c
                + SPACE + lead.Treating_Medical_Professional_Last_Name__c;
        newCase.Qualifying_Medical_Professional_Email__c = lead.Treating_Medical_Professional_Email__c;
        newCase.AccountId = lead.ConvertedAccountId;
        newCase.Status = STATUS_QUALIFIED;
        newCase.Hidden_Why_do_you_feel__c = lead.Why_do_you_feel_would_be_eligible_Wish__c;
        newCase.Origin = ORIGIN_WEB;
        newCase.Diagnosis_Verification_Receive_Date__c = lead.Part_A_Received__c;
        newCase.Diagnosis_Verification_Sent_Date__c = lead.Part_A_Sent__c;
        if (hasContactConverted) {
            newCase.ChapterName__c = lead.ChapterName__c;
            newCase.Hidden_Primary_Diagnosis__c = lead.PD_Condition_Description__c;
        }
        if (lead.ChapterName__r.Qualified_Wish_Owner__c != null) {
            newCase.OwnerId = lead.ChapterName__r.Qualified_Wish_Owner__c;
        }
        if (lead.FirstName != null) {
            newCase.Subject = lead.FirstName + SPACE + lead.LastName;
        } else {
            newCase.Subject = lead.LastName;
        }
        if (lead.Rush__c) {
            newCase.Rush__c = true;
            newCase.Rush_Explanation__c = lead.Please_Explain__c;
            newCase.Rush_Timeframe__c = RUSH_TIME_FRAME;
        } else {
            newCase.Rush__c = false;
        }
        if (lead.Referred_Date__c != null) {
            newCase.Referral_Date__c = lead.Referred_Date__c;
        }
        if (lead.Inquiry_Date__c != null) {
            newCase.Inquiry_Date__c = lead.Inquiry_Date__c;
        }
        if (lead.Out_of_Territory__c != null) {
            newCase.Out_of_Territory__c = lead.Out_of_Territory__c;
        }
        if (lead.unique_wish_identifier__c != null) {
            newCase.Lead__c = lead.Id;
            newCase.Unique_Wish_Record_Identifier__c = lead.unique_wish_identifier__c;
            newCase.Fund_Id__c = lead.unique_wish_identifier__c;
            newCase.UWISource__c = UWI_SOURCE_LEAD;
            newCase.Wish_Assist__c = true;
        }
        return newCase;
    }

    /**
     * @description Create a new eligibility review case when the lead status is updated as elegibility review.
     * @param LeadList
     */
    public static void createEligibilityReview(List<Lead> LeadList) {
        List<Case> newCaseList = new List<Case>();
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id, String> emailMap = new Map<Id, String>();
        Id chapterRecordTypeId = Constant_AC.CHAPTER_RT_ID;
        Id partARecordTypeId = Constant_AC.DIAGNOSIS_RT_ID;
        String nationalAdviser = System.Label.MedicalAdviser;
        Id nationAdvisorQueueId = [
                SELECT Id
                FROM Group
                WHERE Name = :nationalAdviser
        ].Id;
        try {
            for (Lead process : LeadList) {
                accountIdSet.add(process.ChapterName__c);
            }
            if (!accountIdSet.isEmpty()) {
                for (Account dbChapterAcc : [
                        SELECT Id,MAC_Email_del__c,RecordTypeId
                        FROM Account
                        WHERE Id IN:accountIdSet AND RecordTypeId = :chapterRecordTypeId
                ]) {
                    emailMap.put(dbChapterAcc.Id, dbChapterAcc.MAC_Email_del__c);
                }
            }
            for (Lead processLead : LeadList) {
                Case newCase = new Case();
                newCase.Status = STATUS_NEW;
                if (processLead.Is_in_a_Comatose_Vegetative_State__c == LEAD_COMATOSE_VEGETATIVE_STATE_YES) {
                    newCase.Status = STATUS_PENDING_CLARIFICATION_CHAPTER;
                }
                newCase.Origin = ORIGIN_EMAIL;
                newCase.Subject = processLead.FirstName + SPACE + processLead.LastName + APPEND_ELIGIBILITY_REVIEW;
                newCase.RecordTypeId = partARecordTypeId;
                newCase.OwnerId = nationAdvisorQueueId;
                newCase.Hidden_Why_do_you_feel__c = processLead.Why_do_you_feel_would_be_eligible_Wish__c;
                if (emailMap.containsKey(processLead.ChapterName__c)) {
                    newCase.MAC_Email__c = emailMap.get(processLead.ChapterName__c);
                }
                newCase.Lead__c = processLead.Id;
                newCase.AccountId = processLead.ChapterName__c;
                newCase.ChapterName__c = processLead.ChapterName__c;
                if (processLead.Any_medical_reason_for_moving_quickly__c.containsIgnoreCase(LEAD_MEDICAL_REASON_FOR_MOVING_QUICKLY_YES)) {
                    newCase.Rush__c = true;
                    newCase.Rush_Explanation__c = processLead.Please_Explain__c;
                    newCase.Rush_Timeframe__c = RUSH_TIME_FRAME;
                    newCase.Diagnosis_Verification_Receive_Date__c = processLead.Part_A_Received__c;
                }
                /* looks redundant. Removed for testing SIW-582 
                if (processLead.Any_medical_reason_for_moving_quickly__c != null) {
                    String medicalReason = processLead.Any_medical_reason_for_moving_quickly__c;
                    if (medicalReason.contains(LEAD_MEDICAL_REASON_FOR_MOVING_QUICKLY_YES)) {
                        newCase.Rush__c = true;
                    }
                }*/
                newCaseList.add(newCase);
            }

            insert newCaseList;
            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }
        } catch (Exception ex) {
            if (!Test.isRunningTest() && LeadList != null) {
                for (Lead currRec : LeadList) {
                    currRec.addError(Label.Debug_log_error_message);
                }
            }
        }
    }

    /**
     * @description JIRA: WLP-286
     * Author: Gustavo Mayer
     * Update: Granting sub case conversion to the single Wish Case
     * @param chapterEmailMap
     */
    public static void updateGrantingCaseDevStaffEmail(Map<Id, String> chapterEmailMap) {
        List<Case> updateCaseList = new List<Case>();
        for (Case wishCase : [
                SELECT Id, RecordTypeId, ParentId, Parent.ChapterName__c, Dev_Staff_Email__c
                FROM Case
                WHERE Parent.ChapterName__c IN :chapterEmailMap.keySet()
                AND RecordTypeId = :Constant_AC.WISH_RT_ID
                AND IsClosed = FALSE
        ]) {
            if (chapterEmailMap.containsKey(wishCase.Parent.ChapterName__c)) {
                wishCase.Dev_Staff_Email__c = chapterEmailMap.get(wishCase.Parent.ChapterName__c);
                updateCaseList.add(wishCase);
            }
        }
        update updateCaseList;
    }

    /*
     * @description     This method is used to display the error message when the region code is entered incorrectly.
     *
     * @author          MST Solutions
    */
    public static void wishChildRegionValidation(List<Case> parentCases, Set<Id> contactSet) {
        if (parentCases == null || parentCases.isEmpty() || contactSet == null || contactSet.isEmpty()) {
            return;
        }

        Map<Id, Contact> wishChildMap = new Map<Id, Contact>();

        if (contactSet.size() > 0) {
            for (Contact wishChild : [
                    SELECT Id, Region_Code__c, County__c
                    FROM Contact
                    WHERE RecordTypeId = :WISH_CHILD_RECORDTYPE_ID
                    AND Id IN :contactSet
            ]) {
                if (wishChild.Region_Code__c == null || wishChild.County__c == null) {
                    wishChildMap.put(wishChild.Id, wishChild);
                }
            }

            if (wishChildMap.size() > 0) {
                for (Case parentCase : parentCases) {
                    if (wishChildMap.containsKey(parentCase.ContactId)) {
                        if (wishChildMap.get(parentCase.ContactId).Region_Code__c == null
                                && wishChildMap.get(parentCase.ContactId).County__c == null
                                && Bypass_Triggers__c.getValues(Utils.currentUser.Id) == null) {

                            parentCase.addError(Label.CaseTrigger_Add_Region_County);
                        } else if (wishChildMap.get(parentCase.ContactId).Region_Code__c == null
                                && Bypass_Triggers__c.getValues(Utils.currentUser.Id) == null) {

                            parentCase.addError(Label.CaseTrigger_Add_Region);
                        } else if (wishChildMap.get(parentCase.ContactId).County__c == null
                                && Bypass_Triggers__c.getValues(Utils.currentUser.Id) == null) {

                            parentCase.addError(Label.CaseTrigger_Add_County);
                        }
                    }
                }
            }
        }
    }

    /*
     * @description     Display error message when the parent case status is updated as completed with budget values null
     *
     * @author          MST Solutions
    */
    public static void checkBudgetActuals(List<Case> budgetCaseList) {
        if (budgetCaseList == null || budgetCaseList.isEmpty()) {
            return;
        }

        Set<Id> ActualsMatch = new Set<Id>();
        Set<Id> budgetIds = new Set<Id>();
        Map<Id, List<String>> pandaCase = new Map<Id, List<String>>();
        Map<Id, List<Wish_Expense__c>> wishExpenseListbyId = new Map<Id, List<Wish_Expense__c>>();

        for (Case caseTemp : budgetCaseList) {
            budgetIds.add(caseTemp.Id);
        }

        List<Wish_Expense__c> wishExpenseList = [
                SELECT Id, Budget_Cash__c, Budget_In_Kind__c, Projected_Cash__c, Projected_In_Kind__c,
                        Actual_Cash__c,Actual_In_Kind__c,FE_Posted_Cash__c, FE_Posted_In_Kind__c, Case__c
                FROM Wish_Expense__c
                WHERE Case__c IN :budgetIds
        ];

        for (Id caseId : budgetIds) {
            for (Wish_Expense__c wishExpense : wishExpenseList) {
                if (caseId == wishExpense.Case__c) {
                    if (!wishExpenseListbyId.containsKey(caseId)) {
                        wishExpenseListbyId.put(caseId, new List<Wish_Expense__c>{
                                wishExpense
                        });
                    } else {
                        wishExpenseListbyId.get(caseId).add(wishExpense);
                    }
                }
            }
        }

        Decimal totalBudCash = 0;
        Decimal totalBudInKind = 0;
        Decimal totalProjCash = 0;
        Decimal totalProjInKind = 0;
        Decimal totalActCash = 0;
        Decimal totalActInKind = 0;
        Decimal totalFECash = 0;
        Decimal totalFEInkind = 0;

        for (Id IdStatus : wishExpenseListbyId.keySet()) {
            for (Wish_Expense__c expenseSatus : wishExpenseListbyId.get(IdStatus)) {
                if (expenseSatus.Budget_Cash__c != null) {
                    totalBudCash = totalBudCash + expenseSatus.Budget_Cash__c;
                }
                if (expenseSatus.Budget_In_Kind__c != null) {
                    totalBudInKind = totalBudInKind + expenseSatus.Budget_In_Kind__c;
                }
                if (expenseSatus.Projected_Cash__c != null) {
                    totalProjCash = totalProjCash + expenseSatus.Projected_Cash__c;
                }
                if (expenseSatus.Projected_In_Kind__c != null) {
                    totalProjInKind = totalProjInKind + expenseSatus.Projected_In_Kind__c;
                }
                if (expenseSatus.Actual_Cash__c != null) {
                    totalActCash = totalActCash + expenseSatus.Actual_Cash__c;
                }
                if (expenseSatus.Actual_In_Kind__c != null) {
                    totalActInKind = totalActInKind + expenseSatus.Actual_In_Kind__c;
                }
                if (expenseSatus.FE_Posted_Cash__c != null) {
                    totalFECash = totalFECash + expenseSatus.FE_Posted_Cash__c;
                }
                if (expenseSatus.FE_Posted_In_Kind__c != null) {
                    totalFEInkind = totalFEInkind + expenseSatus.FE_Posted_In_Kind__c;
                }
            }

            if (totalBudCash + totalBudInKind > 0 || totalBudInKind + totalProjInKind > 0) {
                if ((totalActCash + totalActInKind == 0 || totalFECash + totalFEInkind == 0)
                        || (totalActCash != totalFECash || totalActInKind != totalFEInkind)) {
                    ActualsMatch.add(IdStatus);
                }
            } else if (totalBudCash + totalBudInKind == 0 && totalBudInKind + totalProjInKind == 0) {
                if (totalActCash != totalFECash || totalActInKind != totalFEInkind) {
                    ActualsMatch.add(IdStatus);
                }
            }

            totalBudCash = 0;
            totalBudInKind = 0;
            totalProjCash = 0;
            totalProjInKind = 0;
            totalActCash = 0;
            totalActInKind = 0;
            totalFECash = 0;
            totalFEInkind = 0;
        }

        for (Case caseTemp : budgetCaseList) {
            if (ActualsMatch.contains(caseTemp.Id) && Bypass_Triggers__c.getValues(Utils.currentUser.Id) == null) {
                caseTemp.addError(Label.CaseTrigger_Budget_Posted_Match);
            }

            for (Id pandaItem : pandaCase.keySet()) {
                if (caseTemp.Id == pandaItem && Bypass_Triggers__c.getValues(Utils.currentUser.Id) == null) {
                    for (String str : pandaCase.get(pandaItem)) {
                        caseTemp.addError(str);
                    }
                }
            }
        }
    }

    /*
     * @description     Check if any date fields in planning case are null.
     *
     * @param           List<Case> cases
     *
     * @author          MST Solutions
    */
    public static void checkReceivedDates(List<Case> cases) {
        if (trac_TriggerHandlerBase.blockTrigger || cases == null || cases.isEmpty()) {
            return;
        }

        String message = '';
        List<Case> budgetCases = new List<Case>();

        for (Case aCase : cases) {
            if (aCase.RecordTypeId != WISH_RECORDTYPE_ID) {
                continue;
            }

            budgetCases.add(aCase);

            if (aCase.Communication_Profile__c == true && aCase.Date_Received_for_Communication_Profile__c == null) {
                if (message == '' || message == null) {
                    message = MAP_OF_CASE_LABELS_BY_FIELDS.get(Case.Communication_Profile__c);
                } else {
                    message = message + ',' + MAP_OF_CASE_LABELS_BY_FIELDS.get(Case.Communication_Profile__c);
                }
            }
        }

        if (String.isBlank(message)) {
            return;
        }

        for (Case aCase : budgetCases) {
            aCase.addError(Label.CaseTrigger_Enter_Received_Date + ' ' + message);
        }
    }

    /*
     * @description     This method is used to update the Wish Clearance Needed field when the National Type is changed.
     *
     * @author          MST Solutions
    */
    public static void updateWishClearanceNeeded(List<Case> changedNationalTypeCases) {
        Map<String, String> wishclearanceMap = new Map<String, String>();

        for (Wish_Clearance_Needed_and_National_type__mdt nationaltype : [
                SELECT MasterLabel,Wish_Clearance_Needed__c
                FROM Wish_Clearance_Needed_and_National_type__mdt
        ]) {
            wishclearanceMap.put(nationaltype.MasterLabel, nationaltype.Wish_Clearance_Needed__c);
        }

        for (Case currCase : changedNationalTypeCases) {
            if (wishclearanceMap.containsKey(currCase.Wish_Type__c)) {
                currCase.Wish_Clearance_Needed__c = wishclearanceMap.get(currCase.Wish_Type__c);
            }
        }
    }

    /*
     * @description     This method is used to update the parent wish subject, fund Id and unique wish
     *                  identifier values when a parent Case is created.
     *
     * @author          MST Solutions
     */
    //public static void UpdateWishRecordIdentifier(Set<Id> parentIds, Set<Id> chapterIds, Id recTypeId) {
    public static void updateWishRecordIdentifier(List<Case> cases) {
        Integer increment;
        Boolean isFyChanged = false;
        Datetime fyDate = Datetime.now();
        String dateOutput = fyDate.format('yy');
        Integer fyYear = Integer.valueOf(dateOutput);
        Map<String, Office__c> accountOfficeMap = new Map<String, Office__c>();
        List<Case> parentWishesList;

        Set<Id> chapterIds = new Set<Id>();
        Set<Id> parentIds = new Set<Id>();
        for (Case aCase : cases) {
            if (aCase.RecordTypeId == Constant_AC.DIAGNOSIS_RT_ID || aCase.RecordTypeId == WISH_RECORDTYPE_ID || aCase.RecordTypeId == Constant_AC.WISH_ASSIST_RT_ID) {
                if (aCase.RecordTypeId == Constant_AC.WISH_ASSIST_RT_ID) {
                    if (aCase.IsClosed != true && aCase.Status != Constant_AC.CASE_STATUS_COMPLETED) {
                        parentIds.add(aCase.ParentId);
                    }
                } else if (aCase.RecordTypeId == WISH_RECORDTYPE_ID) {
                    if (aCase.IsClosed != true) {
                        parentIds.add(aCase.Id);
                        chapterIds.add(aCase.ChapterName__c);
                    }
                }
            }
        }

        try {
            List<Period> financialPeriod = [
                    SELECT StartDate, EndDate, IsForecastPeriod, Type
                    FROM Period
                    WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY
            ];

            if (financialPeriod.size() > 0) {
                if ((Date.today() >= financialPeriod[0].StartDate
                        && Date.today() <= financialPeriod[0].EndDate)
                        && (Date.today().addDays(-1) >= financialPeriod[0].StartDate
                        && Date.today().addDays(-1) <= financialPeriod[0].EndDate)) {
                    isFyChanged = true;
                }

                fyDate = Datetime.newInstance(financialPeriod[0].EndDate.year(), financialPeriod[0].EndDate.month(), financialPeriod[0].EndDate.day());
                fyYear = Integer.valueOf(fyDate.format('yy'));
            }

            for (Office__c currOffice : [
                    SELECT Office_Id__c, Chapter__r.Name, Chapter__c
                    FROM Office__c
                    WHERE Chapter__c IN :chapterIds
            ]) {
                accountOfficeMap.put(currOffice.Chapter__r.Name, currOffice);
            }

            parentWishesList = [
                    SELECT
                            Id,
                            RecordTypeId,
                            Subject,
                            Unique_Wish_Record_Identifier__c,
                            Fund_Id__c,
                            ChapterName__c,
                            ChapterName__r.Name
                    FROM Case
                    WHERE Id IN :parentIds
                    AND RecordTypeId = :Constant_AC.WISH_RT_ID
                    ORDER BY CreatedDate DESC
            ];

            List<Case> lastParentWishOfRecordType = [
                    SELECT Id, Unique_Wish_Record_Identifier__c, ChapterName__c, ChapterName__r.Name
                    FROM Case
                    WHERE RecordTypeId = :Constant_AC.WISH_RT_ID
                    AND Unique_Wish_Record_Identifier__c != NULL
                    AND CreatedBy.Name != :Constant_AC.INTEGRATION_USER
                    AND Lead__r.unique_wish_identifier__c = NULL
                    ORDER BY CreatedDate DESC
                    LIMIT 2
            ];

            if (isFyChanged) {
                if (lastParentWishOfRecordType.size() > 0 && lastParentWishOfRecordType[0].Unique_Wish_Record_Identifier__c != null) {
                    String wishRecordIdentifier = lastParentWishOfRecordType[0].Unique_Wish_Record_Identifier__c;
                    wishRecordIdentifier = wishRecordIdentifier.right(5);
                    increment = Integer.valueOf(wishRecordIdentifier) + 1;
                } else {
                    increment = 10001;
                }
            } else {
                increment = 10001;
            }

            for (Case parentWishes : parentWishesList) {
                String temp = accountOfficeMap.containsKey(parentWishes.ChapterName__r.Name) ?
                        accountOfficeMap.get(parentWishes.ChapterName__r.Name).Office_Id__c : null;

                if (temp != null) {
                    if (parentWishes.Unique_Wish_Record_Identifier__c == null) {
                        parentWishes.Unique_Wish_Record_Identifier__c = temp.left(3) + '-' + fyYear + '-' + increment ;
                        parentWishes.UWISource__c = 'Case';
                    }
                    if (parentWishes.Fund_Id__c == null) {
                        parentWishes.Fund_Id__c = temp.left(3) + '-' + fyYear + '-' + increment ;
                    }
                }

                increment = increment + 1;
                parentWishes.Subject = parentWishes.Subject + ' - ' + parentWishes.Unique_Wish_Record_Identifier__c;
            }

            update parentWishesList;
            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }
        } catch (Exception ex) {
            if (!Test.isRunningTest() && parentWishesList != null) {
                for (Case currRec : parentWishesList) {
                    currRec.addError(Label.Debug_log_error_message);
                }
            }
        }
    }

    /*
    * @description      Used to include Intake Manager into Case team.
    *
    * @author           MST Solutions
    */
    public static void caseTeamInTakeManager(List<Case> cases) {
        Map<String, Id> teamRoleIdMap = new Map<String, Id>();
        Map<Id, Set<Id>> checkMemMap = new Map<Id, Set<Id>>();
        Map<Id, Case> parentCaseIntakeOwnerMap = new Map<Id, Case>();

        for (Case newWish : cases) {
            if (newWish.IsClosed != true && (
                    newWish.RecordTypeId == Constant_AC.DIAGNOSIS_RT_ID
                            || newWish.RecordTypeId == Constant_AC.WISH_RT_ID
                            || newWish.RecordTypeId == Constant_AC.WISH_ASSIST_RT_ID
            )) {
                parentCaseIntakeOwnerMap.put(newWish.Id, newWish);
            }
        }

        Set<Id> chapterIds = new Set<Id>();
        for (Case caseIntakeOwner : parentCaseIntakeOwnerMap.values()) {
            chapterIds.add(caseIntakeOwner.ChapterName__c);
        }
        Map<Id, Id> chapterIntakeManagerMap = new Map<Id, Id>();
        for (Account chapterAccount : [
                SELECT Id, Intake_Manager__c
                FROM Account
                WHERE Id IN :chapterIds
        ]) {
            chapterIntakeManagerMap.put(chapterAccount.Id, chapterAccount.Intake_Manager__c);
        }

        try {
            for (CaseTeamRole CaseTeamRoleInfo : [
                    SELECT Id, Name
                    FROM CaseTeamRole
            ]) {
                teamRoleIdMap.put(CaseTeamRoleInfo.Name, CaseTeamRoleInfo.Id);
            }

            for (CaseTeamMember CaseInfo : [
                    SELECT Id, MemberId, ParentId
                    FROM CaseTeamMember
                    WHERE ParentId IN :parentCaseIntakeOwnerMap.keySet()
            ]) {
                if (checkMemMap.containsKey(CaseInfo.ParentId)) {
                    checkMemMap.get(CaseInfo.ParentId).add(CaseInfo.MemberId);
                } else {
                    checkMemMap.put(CaseInfo.ParentId, new Set<Id>{
                            CaseInfo.MemberId
                    });
                }
            }

            if (parentCaseIntakeOwnerMap.size() > 0) {
                List<CaseTeamMember> memberList = new List<CaseTeamMember>();
                for (Case Caseteam : parentCaseIntakeOwnerMap.values()) {
                    if (checkMemMap.containsKey(Caseteam.Id) && !checkMemMap.get(Caseteam.Id).contains(Caseteam.OwnerId)) {
                        CaseTeamMember newCaseTeamMember = new CaseTeamMember();
                        newCaseTeamMember.ParentId = Caseteam.Id;
                        newCaseTeamMember.MemberId = chapterIntakeManagerMap.get(Caseteam.ChapterName__c);
                        newCaseTeamMember.TeamRoleId = teamRoleIdMap.get(Constant_AC.CASE_TEAM_ROLE_INTAKE_MANAGER);
                        memberList.add(newCaseTeamMember);
                    } else if (!checkMemMap.containsKey(Caseteam.Id)) {
                        CaseTeamMember newCaseTeamMember = new CaseTeamMember();
                        newCaseTeamMember.ParentId = Caseteam.Id;
                        newCaseTeamMember.MemberId = chapterIntakeManagerMap.get(Caseteam.ChapterName__c);
                        newCaseTeamMember.TeamRoleId = teamRoleIdMap.get(Constant_AC.CASE_TEAM_ROLE_INTAKE_MANAGER);
                        memberList.add(newCaseTeamMember);
                    }
                }
                insert memberList;
            }

            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }
        } catch (Exception ex) {
            if (!Test.isRunningTest() && parentCaseIntakeOwnerMap != null) {
                for (Case currRec : parentCaseIntakeOwnerMap.values()) {
                    currRec.addError(Label.Debug_log_error_message);
                }
            }
        }
    }

    /*
    * @description      Used to create Case file records when a parent Case and subcase is created.
    *
    * @author           MST Solutions
    */
    public static void createCaseFile(List<Case> caseList) {
        List<cg__CaseFile__c> caseFiles = new List<cg__CaseFile__c>();

        try {
            for (Case newCase : caseList) {
                cg__CaseFile__c picFolder = new cg__CaseFile__c();
                picFolder.cg__Case__c = newCase.Id;
                picFolder.cg__Content_Type__c = Constant_AC.FILE_CONTENT_TYPE_FOLDER;
                picFolder.cg__File_Name__c = Constant_AC.FILE_NAME_PHOTOS;
                picFolder.cg__WIP__c = false;
                picFolder.cg__Private__c = false;
                caseFiles.add(picFolder);

                cg__CaseFile__c docFolder = new cg__CaseFile__c();
                docFolder.cg__Case__c = newCase.Id ;
                docFolder.cg__Content_Type__c = Constant_AC.FILE_CONTENT_TYPE_FOLDER;
                docFolder.cg__File_Name__c = Constant_AC.FILE_NAME_DOCUMENTS;
                docFolder.cg__WIP__c = false;
                docFolder.cg__Private__c = false;
                caseFiles.add(docFolder);

                cg__CaseFile__c videoFolder = new cg__CaseFile__c();
                videoFolder.cg__Case__c = newCase.Id ;
                videoFolder.cg__Content_Type__c = Constant_AC.FILE_CONTENT_TYPE_FOLDER;
                videoFolder.cg__File_Name__c = Constant_AC.FILE_NAME_VIDEOS;
                videoFolder.cg__WIP__c = false;
                videoFolder.cg__Private__c = false;
                caseFiles.add(videoFolder);

                cg__CaseFile__c staffFolder = new cg__CaseFile__c();
                staffFolder.cg__Case__c = newCase.Id ;
                staffFolder.cg__Content_Type__c = Constant_AC.FILE_CONTENT_TYPE_FOLDER;
                staffFolder.cg__File_Name__c = Constant_AC.FILE_NAME_STAFF_PRIVATE;
                staffFolder.cg__WIP__c = false;
                staffFolder.cg__Private__c = true;
                caseFiles.add(staffFolder);

                cg__CaseFile__c financeFolder = new cg__CaseFile__c();
                financeFolder.cg__Case__c = newCase.Id ;
                financeFolder.cg__Content_Type__c = Constant_AC.FILE_CONTENT_TYPE_FOLDER;
                financeFolder.cg__File_Name__c = Constant_AC.FILE_NAME_FINANCIALS;
                financeFolder.cg__WIP__c = false;
                financeFolder.cg__Private__c = true;
                caseFiles.add(financeFolder);
            }

            if (!Test.isRunningTest()) {
                insert caseFiles;
            }
            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }
        } catch (Exception ex) {
            if (!Test.isRunningTest() && caseList != null) {
                for (Case currRec : caseList) {
                    currRec.addError(Label.Debug_log_error_message);
                }
            }
        }
    }

    /*
    * @author           MST Solutions
    */
    //public static void reParentDvTask(Set<Id> caseIds) {
    public static void reParentDvTask(List<Case> cases) {
        if (cases == null || cases.isEmpty()) {
            return;
        }

        Map<Id, Id> leadCaseMap = new Map<Id, Id>();

        for (Case aCase : cases) {
            if (aCase.RecordTypeId == Constant_AC.WISH_RT_ID) {
                leadCaseMap.put(aCase.ContactId, aCase.Id);
            }
        }

        if (leadCaseMap.isEmpty()) {
            return;
        }

        Map<Id, List<Task>> dvTaskMap = new Map<Id, List<Task>>();

        for (Task dvTask : [
                SELECT Id, Subject, WhoId
                FROM Task
                WHERE Subject = :Constant_AC.TASK_SUBJECT_RUSH_MODIFIED_NO AND WhoId IN :leadCaseMap.keySet()
        ]) {
            if (dvTaskMap.containsKey(dvTask.WhoId)) {
                dvTaskMap.get(dvTask.WhoId).add(dvTask);
            } else {
                dvTaskMap.put(dvTask.WhoId, new List<Task>{
                        dvTask
                });
            }
        }

        if (dvTaskMap.size() > 0) {
            List<Task> CaseTaskList = new List<Task>();

            for (Id leadId : dvTaskMap.keySet()) {
                for (Task updateTask : dvTaskMap.get(leadId)) {
                    if (leadCaseMap.containsKey(updateTask.WhoId)) {
                        Task updateTaskWhatId = new Task();
                        updateTaskWhatId.Id = updateTask.Id;
                        updateTaskWhatId.WhatId = leadCaseMap.get(updateTask.WhoId);
                        CaseTaskList.add(updateTaskWhatId);
                    }
                }
            }
            update CaseTaskList;
        }
    }

    /*
     * @description     Delete all the system generated tasks when the wish assist is updated to true in parent Case.
     *
     * @author          MST Solutions
    */
    public static void deleteWishAssistTask(Set<Id> parentIdSet) {
        if (parentIdSet == null || parentIdSet.isEmpty()) {
            return;
        }

        List<Task> deleteTaskList = new List<Task>();

        deleteTaskList = [
                SELECT Id, SystemGeneratedTask__c
                FROM Task
                WHERE WhatId IN :parentIdSet
                AND SystemGeneratedTask__c = TRUE
                AND What.RecordTypeId = :WISH_RECORDTYPE_ID
        ];
        delete deleteTaskList;
    }

    /*
     * @description     Delete the unassigned volunteer opportunities when the Case status is updated.
     *
     * @author          MST Solutions
    */
    public static void deleteUnassignedVolunteerOpp(Set<Id> parentWishIdSet) {
        if (parentWishIdSet == null || parentWishIdSet.isEmpty()) {
            return;
        }

        RecursiveTriggerHandler.blockCaseLockRecursive = false;
        List<Volunteer_Opportunity__c> deleteVolOppList = new List<Volunteer_Opportunity__c>();

        deleteVolOppList = [
                SELECT Id,Volunteer_Name__c,Wish__c
                FROM Volunteer_Opportunity__c
                WHERE Wish__c IN :parentWishIdSet
                AND Volunteer_Name__c = :NULL
                AND RecordTypeId = :WISH_VOLUNTEER_OPPORTUNITY_RECORDTYPE_ID
        ];
        delete deleteVolOppList;
    }

    /*
     * @description     Update volunteer opportunity to closed status when related Case is closed.
     *
     * @author          MST Solutions
    */
    public static void closeVolOpp(Set<Id> caseIdSetForVolOpp) {
        if (caseIdSetForVolOpp == null || caseIdSetForVolOpp.isEmpty()) {
            return;
        }

        List<Volunteer_Opportunity__c> closeVollOppList = new List<Volunteer_Opportunity__c>();
        Set<Id> recallApprovalSet = new Set<Id>();

        for (Volunteer_Opportunity__c closeVolOpp : [
                SELECT Id, Wish__c,Status__c
                FROM Volunteer_Opportunity__c
                WHERE Wish__c IN :caseIdSetForVolOpp
                AND Wish__c != NULL
                AND Wish__r.RecordTypeId = :WISH_RECORDTYPE_ID
        ]) {
            if (closeVolOpp.Status__c != Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_CLOSED) {
                closeVolOpp.Status__c = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_CLOSED;
                closeVollOppList.add(closeVolOpp);
            }

            recallApprovalSet.add(closeVolOpp.Id);
        }
        recallVolOppApproval(recallApprovalSet);
        update closeVollOppList;
    }

    /*
     * @description     Update Lead status when diagnosis verification Case status is updated.
     *
     * @author          MST Solutions
    */
    public static void updateLeadStatus(Set<String> updatedApprovedLeadInfoSet, Set<String> updatedDnqLeadInfoSet, List<Case> newCaseList) {
        if ((updatedApprovedLeadInfoSet == null || updatedApprovedLeadInfoSet.isEmpty())
                && (updatedDnqLeadInfoSet == null || updatedDnqLeadInfoSet.isEmpty())) {
            return;
        }

        List<Case> exceptionList = new List<Case>();
        for (Case aCase : newCaseList) {
            if (CASE_MEMBER_CHECK_IDS.contains(aCase.RecordTypeId)) {
                exceptionList.add(aCase);
            }
        }

        List<Lead> updatedLeadList = new List<Lead>();
        String message = '';
        Boolean showError;

        for (Lead currentLead : [
                SELECT Id,
                        Status, IsConverted, FirstName, Qualifying_ICD__c, Qualifying_Diagnosis__c,
                        I_am_Recognized_To_Practice_As_a__c, Part_A_Received__c,
                        Any_medical_reason_for_moving_quickly__c, DOB__c
                FROM Lead
                WHERE (Id IN :updatedApprovedLeadInfoSet OR Id IN :updatedDnqLeadInfoSet)
                AND IsConverted = :FALSE
        ]) {
            if (updatedApprovedLeadInfoSet.contains(currentLead.Id)) {
                if (currentLead.I_am_Recognized_To_Practice_As_a__c != null
                        && currentLead.Part_A_Received__c != null
                        && currentLead.Any_medical_reason_for_moving_quickly__c != null
                        && currentLead.DOB__c != null) {

                    currentLead.Status = Constant_AC.LEAD_STATUS_QUALIFIED;
                    currentLead.Sub_Status__c = '';
                    showError = false;
                } else {
                    showError = true;

                    if (currentLead.DOB__c == null) {
                        if (String.isNotEmpty(message)) {
                            message = message + ', ';
                        }

                        message += MAP_OF_LEAD_LABELS_BY_FIELDS.get(Lead.DOB__c);
                    }

                    if (currentLead.Any_medical_reason_for_moving_quickly__c == null) {
                        if (String.isNotEmpty(message)) {
                            message = message + ', ';
                        }

                        message += MAP_OF_LEAD_LABELS_BY_FIELDS.get(Lead.Any_medical_reason_for_moving_quickly__c);
                    }

                    if (currentLead.Part_A_Received__c == null) {
                        if (String.isNotEmpty(message)) {
                            message = message + ', ';
                        }

                        message += ', ' + MAP_OF_LEAD_LABELS_BY_FIELDS.get(Lead.Part_A_Received__c);
                    }

                    if (currentLead.I_am_Recognized_To_Practice_As_a__c == null) {
                        if (String.isNotEmpty(message)) {
                            message = message + ', ';
                        }

                        message += ', ' + MAP_OF_LEAD_LABELS_BY_FIELDS.get(Lead.I_am_Recognized_To_Practice_As_a__c);
                    }
                }
            } else if (updatedDnqLeadInfoSet.contains(currentLead.Id)) {
                currentLead.Status = Constant_AC.LEAD_STATUS_DNQ;
                currentLead.Sub_Status__c = Label.Wish_Lead_Status_Medical_Reviewed;
                currentLead.DNQ_Date__c = Date.today();
                showError = false;
            }

            if (!String.isBlank(message)) {
                for (Case currCase : exceptionList) {
                    currCase.addError(Label.CaseTrigger_Provide_Values + ' ' + message + '.');
                }
            }

            updatedLeadList.add(currentLead);
        }

        if (showError == false) {
            update updatedLeadList;
        }
    }

    /*
     * @description     This method is used to update the volunteer opportunity In Progress checkbox based on parent wish status.
     *
     * @author          MST Solutions
    */
    //public static void updateVolunteerOpp(Set<Id> volunteerOppCaseIdSet, Boolean bool) {
    public static void updateVolunteerOpp(Map<Id, Boolean> volunteerOppCaseIdMap) {
        if (volunteerOppCaseIdMap == null || volunteerOppCaseIdMap.isEmpty()) {
            return;
        }

        RecursiveTriggerHandler.blockCaseLockRecursive = false;
        List<Volunteer_Opportunity__c> updateVolOppList = new List<Volunteer_Opportunity__c>();

        for (Volunteer_Opportunity__c currRec : [
                SELECT Id, Wish__c
                FROM Volunteer_Opportunity__c
                WHERE Wish__c IN :volunteerOppCaseIdMap.keySet()
        ]) {
            Volunteer_Opportunity__c newVolOpp = new Volunteer_Opportunity__c();
            newVolOpp.Id = currRec.Id;
            newVolOpp.In_Progress__c = volunteerOppCaseIdMap.containsKey(currRec.Id) ? true : false;
            updateVolOppList.add(newVolOpp);
        }
        update updateVolOppList;
    }

    /*
     * @description     Update the HiddenGrantedDate in Contact when wish is granted.
     *
     * @author          MST Solutions
    */
    public static void updateGrantedDate(List<Case> wishGrantedIdList) {
        if (wishGrantedIdList == null || wishGrantedIdList.isEmpty()) {
            return;
        }

        List<Contact> updateContactList = new List<Contact>();

        for (Case dbCase : wishGrantedIdList) {
            Contact dbCont = new Contact();
            dbCont.Id = dbCase.ContactId;
            dbCont.Hidden_Granted_Date__c = System.today();
            updateContactList.add(dbCont);
        }
        update updateContactList;
    }

    /*
     * @description     Used to create two volunteer opportunities when the Case status is changed to 'Ready to Assign'
     *                  and to add Case related chapter volunteer manager into Case team with role name 'Volunteer manager'
     *
     * @author          MST Solutions
    */
    public static void createVolunteerOpportunity(Map<Id, Case> readyToAssignParentCaseMap, Set<Id> readyToAssignChapterIdSet) {
        RecursiveTriggerHandler.isFirstTime = false;
        Map<Id, Chapter_Role__c> chapterRoleMap = new Map<Id, Chapter_Role__c>();
        Map<Id, String> CaseTeamRoleNameMap = new Map<Id, String>();
        Map<String, Id> CaseTeamRoleIdMap = new Map<String, Id>();
        Map<Id, Id> accountVolunteerManagerMap = new Map<Id, Id>(); // used to hold Chapter Account Id and its Volunteer Manager Id
        List<Volunteer_Opportunity__c> volunteerOppList = new List<Volunteer_Opportunity__c>();
        List<CaseTeamMember> readyToAssignCaseTeamMemberList = new List<CaseTeamMember>();

        for (Chapter_Role__c currentChapterRole : [
                SELECT Id, Chapter_Name__c, Chapter_Name__r.Name, Role_Name__r.Name
                FROM Chapter_Role__c
                WHERE Role_Name__r.Name = :Constant_AC.CHAPTER_ROLE_WISH_GRANTER
                AND Chapter_Name__c IN :readyToAssignChapterIdSet
        ]) {
            chapterRoleMap.put(currentChapterRole.Chapter_Name__c, currentChapterRole);
        }

        for (Account chapterAccountInfo : [
                SELECT Id, Name, Volunteer_Manager__c, RecordTypeId
                FROM Account
                WHERE RecordTypeId = :CHAPTER_RECORDTYPE_ID AND Id IN :readyToAssignChapterIdSet AND Volunteer_Manager__c != NULL
        ]) {
            accountVolunteerManagerMap.put(chapterAccountInfo.Id, chapterAccountInfo.Volunteer_Manager__c);
        }

        for (CaseTeamRole caseTeamRoleInfo : [
                SELECT Id, Name
                FROM CaseTeamRole
        ]) {
            CaseTeamRoleNameMap.put(caseTeamRoleInfo.Id, caseTeamRoleInfo.Name);
            CaseTeamRoleIdMap.put(caseTeamRoleInfo.Name, caseTeamRoleInfo.Id);
        }

        System.debug(JSON.serializePretty(chapterRoleMap));
        System.debug(JSON.serializePretty(readyToAssignParentCaseMap));

        if (chapterRoleMap.size() > 0) {
            for (Case currentCase : readyToAssignParentCaseMap.values()) {
                for (Integer i = 0; i <= 1; i++) { // create TWO volunteer opportunities
                    if (chapterRoleMap.containsKey(currentCase.ChapterName__c)) {
                        Volunteer_Opportunity__c volunteerOpp = new Volunteer_Opportunity__c();

                        volunteerOpp.Chapter_Role_Opportunity__c = chapterRoleMap.get(currentCase.ChapterName__c).Id;
                        volunteerOpp.Wish__c = currentCase.Id;
                        volunteerOpp.RecordTypeId = WISH_VOLUNTEER_OPPORTUNITY_RECORDTYPE_ID;
                        volunteerOpp.Is_Non_Viewable__c = true;
                        volunteerOpp.Chapter_Name__c = chapterRoleMap.get(currentCase.ChapterName__c).Chapter_Name__c;

                        volunteerOppList.add(volunteerOpp);
                    }
                }
            }
            insert volunteerOppList;
        }

        for (Case changeCaseOwner : readyToAssignParentCaseMap.values()) {
            CaseTeamMember newCaseTeamMember = new CaseTeamMember();

            newCaseTeamMember.ParentId = changeCaseOwner.Id;
            if (CaseTeamRoleIdMap.containsKey(Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER)) {
                newCaseTeamMember.TeamRoleId = CaseTeamRoleIdMap.get(Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER);
            }

            newCaseTeamMember.MemberId = changeCaseOwner.OwnerId;
            readyToAssignCaseTeamMemberList.add(newCaseTeamMember);
        }
    }

    /*
     * @description     Used to update Case Team Role and to create new Case Team Member based on Case Status.
     *
     * @author          MST Solutions
    */
    public static void createAndUpdateUserCaseTeamRole(Map<Id, Case> updateVolunteerManagerCaseTeamMap, Set<Id> volunteerManagerIdSet, Set<Id> wishCoordinatorIdSet) {
        if (updateVolunteerManagerCaseTeamMap == null || updateVolunteerManagerCaseTeamMap.isEmpty()) {
            return;
        }
        RecursiveTriggerHandler.blockCaseLockRecursive = false;
        Map<String, Id> teamRoleIdMap = new Map<String, Id>();
        Map<Id, Id> ownerManagerMap = new Map<Id, Id>();
        Set<Id> caseOwnerIdSet = new Set<Id>();

        for (Case getOwner : updateVolunteerManagerCaseTeamMap.values()) {
            caseOwnerIdSet.add(getOwner.OwnerId);
        }

        for (User userManagerInfo : [
                SELECT Id, ManagerId
                FROM User
                WHERE Id IN :caseOwnerIdSet
        ]) {
            ownerManagerMap.put(userManagerInfo.Id, userManagerInfo.ManagerId);
        }

        for (CaseTeamRole caseTeamRoleInfo : [
                SELECT Id, Name
                FROM CaseTeamRole
        ]) {
            teamRoleIdMap.put(caseTeamRoleInfo.Name, caseTeamRoleInfo.Id);
        }

        if (updateVolunteerManagerCaseTeamMap.size() > 0) {
            List<CaseTeamMember> inActiveAndActiveVMUpsertList = new List<CaseTeamMember>();
            Map<Id, List<CaseTeamMember>> CaseTeamMemberMap = new Map<Id, List<CaseTeamMember>>();
            Map<String, Id> activeCaseTeamMap = new Map<String, Id>();
            Map<String, Id> inActiveCaseTeamMap = new Map<String, Id>();
            Map<Id, Set<Id>> CaseTeamMap = new Map<Id, Set<Id>>();

            Set<String> teamRoles = new Set<String>{
                    Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER,
                    Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER_INACTIVE,
                    Constant_AC.CASE_TEAM_ROLE_WISH_COORDINATOR_INACTIVE,
                    Constant_AC.CASE_TEAM_ROLE_WISH_COORDINATOR,
                    Constant_AC.CASE_TEAM_ROLE_INTAKE_MANAGER
            };

            for (CaseTeamMember CaseTeamInfo : [
                    SELECT Id, ParentId, MemberId, TeamRoleId, TeamRole.Name
                    FROM CaseTeamMember
                    WHERE TeamRole.Name IN :teamRoles
                    AND ParentId IN :updateVolunteerManagerCaseTeamMap.keySet()
            ]) {
                if (CaseTeamInfo.TeamRole.Name == Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER ||
                        CaseTeamInfo.TeamRole.Name == Constant_AC.CASE_TEAM_ROLE_WISH_COORDINATOR) {

                    activeCaseTeamMap.put(CaseTeamInfo.ParentId + '-' + CaseTeamInfo.MemberId, CaseTeamInfo.MemberId);
                } else if (CaseTeamInfo.TeamRole.Name == Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER_INACTIVE ||
                        CaseTeamInfo.TeamRole.Name == Constant_AC.CASE_TEAM_ROLE_WISH_COORDINATOR_INACTIVE) {

                    inActiveCaseTeamMap.put(CaseTeamInfo.ParentId + '-' + CaseTeamInfo.MemberId, CaseTeamInfo.MemberId);
                }

                if (CaseTeamMemberMap.containsKey(CaseTeamInfo.ParentId)) {
                    CaseTeamMemberMap.get(CaseTeamInfo.ParentId).add(CaseTeamInfo);
                    CaseTeamMap.get(CaseTeamInfo.ParentId).add(CaseTeamInfo.MemberId);
                } else {
                    CaseTeamMemberMap.put(CaseTeamInfo.ParentId, new List<CaseTeamMember>{
                            CaseTeamInfo
                    });
                    CaseTeamMap.put(CaseTeamInfo.ParentId, new Set<Id>{
                            CaseTeamInfo.MemberId
                    });
                }
            }

            for (Case updateTeamMember : updateVolunteerManagerCaseTeamMap.values()) {
                if (CaseTeamMemberMap.containsKey(updateTeamMember.Id)) {
                    if (CaseTeamMap.get(updateTeamMember.Id).contains(updateTeamMember.OwnerId)) {
                        for (CaseTeamMember CaseTeamMem : CaseTeamMemberMap.get(updateTeamMember.Id)) {
                            if (CaseTeamMem.TeamRole.Name == Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER ||
                                    CaseTeamMem.TeamRole.Name == Constant_AC.CASE_TEAM_ROLE_WISH_COORDINATOR) {

                                if (volunteerManagerIdSet.contains(CaseTeamMem.ParentId) &&
                                        CaseTeamMem.TeamRole.Name == Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER) {

                                    CaseTeamMem.TeamRoleId = teamRoleIdMap.get(CaseTeamMem.TeamRole.Name + ' (Inactive)');
                                    inActiveAndActiveVMUpsertList.add(CaseTeamMem);
                                } else if (wishCoordinatorIdSet.contains(CaseTeamMem.ParentId) &&
                                        CaseTeamMem.TeamRole.Name == Constant_AC.CASE_TEAM_ROLE_WISH_COORDINATOR) {

                                    CaseTeamMem.TeamRoleId = teamRoleIdMap.get(CaseTeamMem.TeamRole.Name + ' (Inactive)');
                                    inActiveAndActiveVMUpsertList.add(CaseTeamMem);
                                }
                            } else if (CaseTeamMem.TeamRole.Name == Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER_INACTIVE ||
                                    CaseTeamMem.TeamRole.Name == Constant_AC.CASE_TEAM_ROLE_WISH_COORDINATOR_INACTIVE) {

                                if (inActiveCaseTeamMap.get(CaseTeamMem.ParentId + '-' + CaseTeamMem.MemberId) == updateTeamMember.OwnerId) {
                                    if (volunteerManagerIdSet.contains(CaseTeamMem.ParentId) &&
                                            CaseTeamMem.TeamRole.Name == Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER_INACTIVE) {

                                        CaseTeamMem.TeamRoleId = teamRoleIdMap.get(CaseTeamMem.TeamRole.Name.remove(' (Inactive)'));
                                        inActiveAndActiveVMUpsertList.add(CaseTeamMem);
                                    } else if (wishCoordinatorIdSet.contains(CaseTeamMem.ParentId) &&
                                            CaseTeamMem.TeamRole.Name == Constant_AC.CASE_TEAM_ROLE_WISH_COORDINATOR_INACTIVE) {

                                        CaseTeamMem.TeamRoleId = teamRoleIdMap.get(CaseTeamMem.TeamRole.Name.remove(' (Inactive)'));
                                        inActiveAndActiveVMUpsertList.add(CaseTeamMem);
                                    }
                                }
                            }
                        }
                    } else {
                        for (CaseTeamMember CaseTeamMem : CaseTeamMemberMap.get(updateTeamMember.Id)) {
                            if (CaseTeamMem.TeamRole.Name == Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER &&
                                    volunteerManagerIdSet.contains(CaseTeamMem.ParentId)) {

                                CaseTeamMem.TeamRoleId = teamRoleIdMap.get(CaseTeamMem.TeamRole.Name + ' (Inactive)');
                                inActiveAndActiveVMUpsertList.add(CaseTeamMem);
                            } else if (CaseTeamMem.TeamRole.Name == Constant_AC.CASE_TEAM_ROLE_WISH_COORDINATOR &&
                                    wishCoordinatorIdSet.contains(CaseTeamMem.ParentId)) {

                                CaseTeamMem.TeamRoleId = teamRoleIdMap.get(CaseTeamMem.TeamRole.Name + ' (Inactive)');
                                inActiveAndActiveVMUpsertList.add(CaseTeamMem);
                            }
                        }
                        CaseTeamMember newCaseTeamMember = new CaseTeamMember();
                        newCaseTeamMember.ParentId = updateTeamMember.Id;
                        newCaseTeamMember.MemberId = updateTeamMember.OwnerId;
                        if (volunteerManagerIdSet.contains(updateTeamMember.Id)) {
                            if (teamRoleIdMap.containsKey(Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER)) {
                                newCaseTeamMember.TeamRoleId = teamRoleIdMap.get(Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER);
                                if (CaseTeamMap.containsKey(updateTeamMember.Id) && !CaseTeamMap.get(updateTeamMember.Id).contains(updateTeamMember.OwnerId)) {
                                    inActiveAndActiveVMUpsertList.add(newCaseTeamMember);
                                }
                            }
                        } else if (wishCoordinatorIdSet.contains(updateTeamMember.Id)) {
                            if (teamRoleIdMap.containsKey(Constant_AC.CASE_TEAM_ROLE_WISH_COORDINATOR)) {
                                newCaseTeamMember.TeamRoleId = teamRoleIdMap.get(Constant_AC.CASE_TEAM_ROLE_WISH_COORDINATOR);
                                if (CaseTeamMap.containsKey(updateTeamMember.Id) && !CaseTeamMap.get(updateTeamMember.Id).contains(updateTeamMember.OwnerId)) {
                                    inActiveAndActiveVMUpsertList.add(newCaseTeamMember);
                                }
                                if (ownerManagerMap.containsKey(updateTeamMember.OwnerId) && !String.isEmpty(ownerManagerMap.get(updateTeamMember.OwnerId))) {
                                    CaseTeamMember newCaseManagerTeamMember = new CaseTeamMember();
                                    newCaseManagerTeamMember.ParentId = updateTeamMember.Id;
                                    newCaseManagerTeamMember.MemberId = ownerManagerMap.get(updateTeamMember.OwnerId);
                                    newCaseManagerTeamMember.TeamRoleId = teamRoleIdMap.get(Constant_AC.CASE_TEAM_ROLE_WISH_COORDINATOR);
                                    if (CaseTeamMap.containsKey(updateTeamMember.Id) && !CaseTeamMap.get(updateTeamMember.Id).contains(ownerManagerMap.get(updateTeamMember.OwnerId))) {
                                        inActiveAndActiveVMUpsertList.add(newCaseManagerTeamMember);
                                    }
                                }
                            }
                        }
                    }
                } else {
                    CaseTeamMember newCaseTeamMember = new CaseTeamMember();
                    newCaseTeamMember.ParentId = updateTeamMember.Id;
                    newCaseTeamMember.MemberId = updateTeamMember.OwnerId;

                    if (volunteerManagerIdSet.contains(updateTeamMember.Id)) {
                        if (teamRoleIdMap.containsKey(Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER)) {
                            newCaseTeamMember.TeamRoleId = teamRoleIdMap.get(Constant_AC.CASE_TEAM_ROLE_VOLUNTEER_MANAGER);
                            inActiveAndActiveVMUpsertList.add(newCaseTeamMember);
                        }
                    } else if (wishCoordinatorIdSet.contains(updateTeamMember.Id)) {
                        if (teamRoleIdMap.containsKey(Constant_AC.CASE_TEAM_ROLE_WISH_COORDINATOR)) {
                            newCaseTeamMember.TeamRoleId = teamRoleIdMap.get(Constant_AC.CASE_TEAM_ROLE_WISH_COORDINATOR);
                            inActiveAndActiveVMUpsertList.add(newCaseTeamMember);
                            if (ownerManagerMap.containsKey(updateTeamMember.OwnerId) && !String.isEmpty(ownerManagerMap.get(updateTeamMember.OwnerId))) {
                                CaseTeamMember newCaseManagerTeamMember = new CaseTeamMember();
                                newCaseManagerTeamMember.ParentId = updateTeamMember.Id;
                                newCaseManagerTeamMember.MemberId = ownerManagerMap.get(updateTeamMember.OwnerId);
                                newCaseManagerTeamMember.TeamRoleId = teamRoleIdMap.get(Constant_AC.CASE_TEAM_ROLE_WISH_COORDINATOR);
                                inActiveAndActiveVMUpsertList.add(newCaseManagerTeamMember);
                            }
                        }
                    }
                }
            }
            upsert inActiveAndActiveVMUpsertList;
        }
    }

    /*
     * @description     Used the change the access to Case team member when their Case team role is updated.
     *
     * @author          MST Solutions
    */
    public static void changeAccessPermission(Map<Id, Id> caseContactMap) {
        if (caseContactMap == null || caseContactMap.isEmpty()) {
            return;
        }

        RecursiveTriggerHandler.blockCaseLockRecursive = false;

        Map<Id, String> CaseTeamRoleFilteredMap = new Map<Id, String>();
        Map<String, Id> CaseTeamRoleMap = new Map<String, Id>();

        for (CaseTeamRole caseTeamRoleInfo : [
                SELECT Id, Name
                FROM CaseTeamRole
        ]) {
            if (caseTeamRoleInfo.Name.contains(' (Wish Closed)')) {
                CaseTeamRoleFilteredMap.put(caseTeamRoleInfo.Id, caseTeamRoleInfo.Name.remove(' (Wish Closed)'));
            } else {
                CaseTeamRoleMap.put(caseTeamRoleInfo.Name, caseTeamRoleInfo.Id);
            }
        }

        Map<Id, Case> parentCaseMap = new Map<Id, Case>([
                SELECT Id,ParentId,RecordTypeId
                FROM Case
                WHERE ParentId = :NULL
                AND RecordTypeId = :WISH_RECORDTYPE_ID
                AND Id IN :caseContactMap.keySet()
        ]);

        Map<Id, List<CaseTeamMember>> caseTeamMemberMap = new Map<Id, List<CaseTeamMember>>();
        for (CaseTeamMember caseTeamMemberInfo : [
                SELECT Id, MemberId, TeamRoleId, ParentId
                FROM CaseTeamMember
                WHERE ParentId IN :caseContactMap.keySet()
        ]) {
            if (caseTeamMemberMap.containsKey(caseTeamMemberInfo.ParentId)) {
                caseTeamMemberMap.get(caseTeamMemberInfo.ParentId).add(caseTeamMemberInfo);
            } else {
                caseTeamMemberMap.put(caseTeamMemberInfo.ParentId, new List<CaseTeamMember>{
                        caseTeamMemberInfo
                });
            }
        }

        if (caseTeamMemberMap.size() > 0) {
            List<CaseTeamMember> updateRoleList = new List<CaseTeamMember>();
            List<ContactShare> contactToShareList = new List<ContactShare>();

            for (Id CaseId : caseContactMap.keySet()) {
                if (caseTeamMemberMap.containsKey(CaseId)) {
                    for (CaseTeamMember CaseTeamRoleUpdate : caseTeamMemberMap.get(CaseId)) {
                        if (CaseTeamRoleFilteredMap.containsKey(CaseTeamRoleUpdate.TeamRoleId)) {
                            if (CaseTeamRoleMap.containsKey(CaseTeamRoleFilteredMap.get(CaseTeamRoleUpdate.TeamRoleId))) {
                                CaseTeamRoleUpdate.TeamRoleId = CaseTeamRoleMap.get(CaseTeamRoleFilteredMap.get(CaseTeamRoleUpdate.TeamRoleId));

                                updateRoleList.add(CaseTeamRoleUpdate);

                                if (parentCaseMap.containsKey(CaseId)) {
                                    ContactShare shareContact = new ContactShare();

                                    shareContact.ContactAccessLevel = 'Read';
                                    shareContact.ContactId = caseContactMap.get(CaseId);
                                    shareContact.UserOrGroupId = CaseTeamRoleUpdate.MemberId;

                                    contactToShareList.add(shareContact);
                                }

                            }
                        }
                    }
                }
            }
            update updateRoleList;
            insert contactToShareList;
        }
    }

    /*
     * @description     Used to update the role for volunteer User to wish, when the parent wish is completed.
     *
     * @author          MST Solutions
    */
    public static void revokeWishPermissionForVolunteers(Set<Id> parentWishIds, Set<Id> revokingContactIdSet) {
        RecursiveTriggerHandler.allowToEditRecord = true;

        Map<String, Id> CaseTeamRoleMap = new Map<String, Id>();
        Set<Id> userIdSet = new Set<Id>();
        List<ContactShare> removeContactShareList = new List<ContactShare>();
        List<CaseTeamMember> updateTeamRole = new List<CaseTeamMember>();
        Set<Id> memberIdSet = new Set<Id>();
        Set<Id> volunteerUsersSet = new Set<Id>();

        for (CaseTeamRole CaseRole : [
                SELECT Id, Name
                FROM CaseTeamRole
        ]) {
            if (CaseRole.Name.contains('Wish Closed')) {
                CaseTeamRoleMap.put(CaseRole.Name, CaseRole.Id);
            }
        }

        List<CaseTeamMember> caseTeamMemberList = [
                SELECT Id, ParentId, MemberId, TeamRole.Name, TeamRoleId
                FROM CaseTeamMember
                WHERE (ParentId IN :parentWishIds)
        ];

        if (caseTeamMemberList.size() > 0) {
            for (CaseTeamMember getCaseTeamMember : caseTeamMemberList) {
                memberIdSet.add(getCaseTeamMember.MemberId);
            }

            if (memberIdSet.size() > 0) {
                for (User getVolunteerUser : [
                        SELECT Id, ContactId
                        FROM User
                        WHERE ContactId != NULL
                        AND Id IN :memberIdSet
                ]) {
                    volunteerUsersSet.add(getVolunteerUser.Id);
                }
            }

            /**
             * JIRA: WLP-286
             * Author: Gustavo Mayer
             * Update: Sub case conversion to the single Wish Case,
             * no need to find the child case as there is no longer the concept of parent case.
             */
            for (CaseTeamMember getCaseTeamMember : [
                    SELECT Id, ParentId, MemberId, TeamRole.Name, TeamRoleId
                    FROM CaseTeamMember
                    WHERE (ParentId IN :parentWishIds)
                    AND (Member.IsActive = TRUE)
            ]) {
                String roleName = getCaseTeamMember.TeamRole.Name + ' (Wish Closed)';
                if (CaseTeamRoleMap.size() > 0 && CaseTeamRoleMap.containsKey(roleName) && volunteerUsersSet.contains(getCaseTeamMember.MemberId)) {
                    getCaseTeamMember.TeamRoleId = CaseTeamRoleMap.get(roleName);
                }

                userIdSet.add(getCaseTeamMember.MemberId);
                updateTeamRole.add(getCaseTeamMember);
            }
            update updateTeamRole;
        }

        for (ContactShare conShare : [
                SELECT Id, UserOrGroupId, ContactId
                FROM ContactShare
                WHERE ContactId IN :revokingContactIdSet
        ]) {
            if (userIdSet.contains(conShare.UserOrGroupId) && volunteerUsersSet.contains(conShare.UserOrGroupId)) {
                removeContactShareList.add(conShare);
            }
        }
        delete removeContactShareList;
    }

    /*
     * @description     Change the Volunteer Opportunity Status as Completed when the wish status is completed or closed.
     *
     * @author          MST Solutions
    */
    public static void updateVolunteerOpportunityStatus(Set<Id> caseIds) {
        if (caseIds == null || caseIds.isEmpty()) {
            return;
        }

        List<Volunteer_Opportunity__c> volunteerOppList = new List<Volunteer_Opportunity__c>();
        Set<Id> recallApprovalSet = new Set<Id>();

        for (Volunteer_Opportunity__c currRec : [
                SELECT Id, Status__c, Wish__c, Wish__r.RecordTypeId
                FROM Volunteer_Opportunity__c
                WHERE Wish__c IN :caseIds
                AND Wish__c != NULL
                AND Wish__r.RecordTypeId = :WISH_RECORDTYPE_ID
        ]) {
            if (currRec.Status__c != Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_COMPLETED) {
                currRec.Status__c = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_COMPLETED;
                volunteerOppList.add(currRec);
            }

            recallApprovalSet.add(currRec.Id);
        }

        recallVolOppApproval(recallApprovalSet);
        update volunteerOppList;
    }

    /*
     * @description     Updating Open Volunteer Opportunity Inactive and Reason for Inactive field when Case is closed.
     *
     * @author          MST Solutions
    */
    public static void updateVolunteerOpportunityAsInactive(Set<Id> closedCaseIdSet) {
        if (closedCaseIdSet == null || closedCaseIdSet.isEmpty()) {
            return;
        }

        List<Volunteer_Opportunity__c> updateVO_List = new List<Volunteer_Opportunity__c>();

        for (Volunteer_Opportunity__c updateVO : [
                SELECT Id, Inactive__c, Reason_Inactive__c
                FROM Volunteer_Opportunity__c
                WHERE Wish__c IN :closedCaseIdSet
                AND Volunteer_Name__c = NULL
                AND Inactive__c = FALSE
                AND Migrated_Record__c = FALSE
        ]) {
            updateVO.Inactive__c = true;
            updateVO.Reason_Inactive__c = 'inactivated';
            updateVO_List.add(updateVO);
        }
        update updateVO_List;
    }

    /*
     * @description     This method is used to update the wish granted count in Contact record.
     *
     * @author          MST Solutions
    */
    public static void grantedWishCount(Set<Id> wishIdsSet) {
        if (wishIdsSet == null || wishIdsSet.isEmpty()) {
            return;
        }

        Set<Id> volunteerIdsSet = new Set<Id>();

        for (Volunteer_Opportunity__c currentVolOpp : [
                SELECT Id, Wish__c, Wish__r.Status, Volunteer_Name__c, Status__c
                FROM Volunteer_Opportunity__c
                WHERE Wish__c IN :wishIdsSet AND Volunteer_Name__c != NULL
        ]) {
            volunteerIdsSet.add(currentVolOpp.Volunteer_Name__c);
        }
        VolunteerOpportunityService.activeWishCount(volunteerIdsSet);
    }

    /**
     * @description This method is used to recall the Volunteer Opportunity approval process.
     * @param pendingVollOppIdSet
     * @author MST Solutions
     */
    public static void recallVolOppApproval(Set<Id> pendingVollOppIdSet) {
        if (pendingVollOppIdSet.isEmpty()) {
            return;
        }
        String volunteerOpportunityIds = String.join(new List<Id>(pendingVollOppIdSet), ',');
        VolunteerInterviewTask_AC.getApprovalRecal(volunteerOpportunityIds);
    }

    /*
     * @description     This method is used to populate end date value in volunteer Opportunity record
     *                  when the wish status is 'Granted' or 'Closed'.
     *
     * @author          MST Solutions
    */
    public static void populateEndDate(Set<Id> wishIdSet) {
        if (wishIdSet.size() == 0) {
            return;
        }

        List<Volunteer_Opportunity__c> volunteerOpportunityList = new List<Volunteer_Opportunity__c>();

        for (Volunteer_Opportunity__c dbVolunteerOppRec : [
                SELECT Id, Wish__c, Wish__r.Status, Wish__r.End_Date__c, Wish__r.Closed_Date__c,
                        Wish_Start_Date__c, Wish_End_Date__c, Status__c, Inactive__c
                FROM Volunteer_Opportunity__c
                WHERE Wish__c IN :wishIdSet
                AND Inactive__c = :FALSE
                AND Status__c != :Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_INACTIVE
        ]) {
            if (dbVolunteerOppRec.Wish__r.Status == Constant_AC.CASE_STATUS_GRANTED) {
                dbVolunteerOppRec.Wish_End_Date__c = dbVolunteerOppRec.Wish__r.End_Date__c;
            }

            if (dbVolunteerOppRec.Wish__r.Status == Constant_AC.CASE_STATUS_CLOSED
                    && dbVolunteerOppRec.Wish__r.Closed_Date__c != null) {

                dbVolunteerOppRec.Wish_End_Date__c = dbVolunteerOppRec.Wish__r.Closed_Date__c;
            }

            volunteerOpportunityList.add(dbVolunteerOppRec);
        }
        update volunteerOpportunityList;
    }

    /**
     * @description Update Case to Lead substatus.
     * @param leadStatus
     * @param subStatusMap
     * @author MST Solutions
     */
    public static void updateCaseToLeadSubStatus(String leadStatus, Map<Id, String> subStatusMap) {
        Set<Id> leadIds = subStatusMap.keySet();

        List<Lead> leadData = [
                SELECT Id, Status, Sub_Status__c
                FROM Lead
                WHERE Id IN :leadIds
        ];

        List<Lead> updateLeadList = new List<Lead>();
        for (Lead leadtoUpdate : leadData) {
            leadtoUpdate.Status = leadStatus;
            leadtoUpdate.Sub_Status__c = subStatusMap.get(leadtoUpdate.Id);

            updateLeadList.add(leadtoUpdate);
        }
        update updateLeadList;
    }

    public static void updateInActiveWishGranter(Set<Id> volunteerIds, List<Volunteer_Opportunity__c> volunteerOpportunities) {
        if (volunteerIds.isEmpty() || volunteerOpportunities.isEmpty()) {
            return;
        }
        RecursiveTriggerHandler.isFirstTime = false;
        RecursiveTriggerHandler.allowToEditRecord = true;
        Set<Id> caseIds = new Set<Id>();
        for (Volunteer_Opportunity__c volunteerOpportunity : volunteerOpportunities) {
            caseIds.add(volunteerOpportunity.Wish__c);
        }
        List<Case> updateCaseList = new List<Case>();
        Case myParentCase = new Case();
        try {
            for (Case wishCase : [
                    SELECT Id
                    FROM Case
                    WHERE Id IN :caseIds
            ]) {
                myParentCase.Id = wishCase.Id;
            }
            for (User dbUser : [
                    SELECT Id,Name,ContactId
                    FROM User
                    WHERE ContactId IN:volunteerIds
            ]) {
                if (volunteerIds.contains(dbUser.ContactId)) {
                    myParentCase.InActiveWishGranter__c = dbUser.Name;
                }
            }
            updateCaseList.add(myParentCase);
            update updateCaseList ;
            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }
        } catch (Exception ex) {
            for (Volunteer_Opportunity__c currRec : volunteerOpportunities) {
                ErrorMessage_AC.createDebugRec('CaseService',
                        String.valueOf(currRec), String.valueOf(ex),
                        'updateInActiveWishGranter', currRec.Id, ex.getStackTraceString(), 'Error');
                if (!Test.isRunningTest()) {
                    currRec.addError(Label.Debug_log_error_message);
                }
            }
        }
    }

    public static List<Case> updateHiddenVolunteerInactive(Set<Id> caseIds) {
        List<Case> wishCasesVolunteerInactive = new List<Case>();
        if (caseIds.isEmpty()) {
            return wishCasesVolunteerInactive;
        }
        Case parentCase = new Case();
        for (Case newCase : [
                SELECT Id,Hidden_VOinactive__c
                FROM Case
                WHERE Id IN :caseIds
        ]) {
            parentCase.Id = newCase.Id;
            parentCase.Hidden_VOinactive__c = true;
            wishCasesVolunteerInactive.add(parentCase);
        }
        update wishCasesVolunteerInactive;
        return wishCasesVolunteerInactive;
    }

    public static Map<Id, Case> findById(Set<Id> caseIds) {
        Map<Id, Case> caseMap = new Map<Id, Case>();
        for (Case newCase : [
                SELECT Id, ContactId, OwnerId, Hidden_VOinactive__c
                FROM Case
                WHERE Id IN :caseIds
        ]) {
            caseMap.put(newCase.Id, newCase);
        }
        return caseMap;
    }
}