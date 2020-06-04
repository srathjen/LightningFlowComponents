/**
 * @description Domain class for the Lead trigger
 * @author  Mason Buhler, Traction on Demand
 * @createdDate 7/26/2019
 * @update 3/25/2020 - SCC-155 New Lead Record types introduced
 * @update 4/14/2020 - SIW-297 Initial Address Verification check
 */
public class LeadDomain extends trac_TriggerHandlerBase {

    private final static Id DIAGNOSIS_RECORD_TYPE_ID = Constant_AC.DIAGNOSIS_RT_ID;
    private final static Id LEAD_RT_WISH_CHILD = Constant_AC.LEAD_RT_WISH_CHILD;
    private final static String CASE_PENDING_CLARIFICATION = Constant_AC.CASE_STATUS_PENDING_CLARIFICATION_CHAPTER;
    private final static String LEAD_NEW = Constant_AC.LEAD_STATUS_NEW;
    private final static String LEAD_DUPLICATE = Constant_AC.LEAD_STATUS_DUPLICATE;
    private final static String LEAD_DECEASED = Constant_AC.LEAD_STATUS_DECEASED;
    private final static String LEAD_DNQ = Constant_AC.LEAD_STATUS_DNQ;
    private final static String LEAD_REFERRED = Constant_AC.LEAD_STATUS_REFERRED;
    private final static String LEAD_INQUIRY = Constant_AC.LEAD_STATUS_INQUIRY;
    private final static String LEAD_QUALIFIED = Constant_AC.LEAD_STATUS_QUALIFIED;
    private final static String LEAD_ELIGIBILITY_REVIEW = Constant_AC.LEAD_STATUS_ELIGIBILITY_REVIEW;
    private static final String LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION = Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION;
    private static final String LEAD_SUB_STATUS_PENDING_PART_A = Constant_AC.LEAD_SUB_STATUS_PENDING_PART_A;
    private static final String LEAD_SUB_STATUS_PENDING_PAPER_DV = Constant_AC.LEAD_SUB_STATUS_PENDING_PAPER_DV;
    private static final String LEAD_SUB_STATUS_PENDING_CLARIFICATION_CHAPTER = Constant_AC.LEAD_SUB_STATUS_PENDING_CLARIFICATION_CHAPTER;
    private static final String LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL;
    private static final String LEAD_DV_FORM_TYPE_BEST_CONTACT = Constant_AC.LEAD_DV_FORM_TYPE_BEST_CONTACT;
    private static final String LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL;
    private static final String LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL;
    private static final String COMATOSE_VEGETATIVE_STATE_YES = Constant_AC.LEAD_COMATOSE_VEGETATIVE_STATE_YES;
    private static final String MEDICAL_REASON_MOVING_QUICKLY_YES = Constant_AC.LEAD_MEDICAL_REASON_FOR_MOVING_QUICKLY_YES;
    private static final String LEAD_DUP_CHECK_BLOCK_LEAD_DUP = Constant_AC.LEAD_DUP_CHECK_BLOCK_LEAD_DUP;
    private static final String LEAD_DUP_CHECK_BLOCK_CONTACT_DUP = Constant_AC.LEAD_DUP_CHECK_BLOCK_CONTACT_DUP;
    private static final String ROLE_NATIONAL_STAFF = Constant_AC.ROLE_NATIONAL_STAFF;
    private static final String EMPTY = '';

    List<Lead> newLeadsList = (List<Lead>) newRecordsList;
    List<Lead> oldLeadsList = (List<Lead>) oldRecordsList;
    Map<Id, Lead> newLeadsMap = (Map<Id, Lead>) newRecordsMap;
    Map<Id, Lead> oldLeadsMap = (Map<Id, Lead>) oldRecordsMap;

    /**
     * Before insert of Lead
     */
    public override void handleBeforeInsert() {
        List<Lead> inquiryReferredLeads = new List<Lead>();
        Map<Id, Lead> accountIdLeadMap = new Map<Id, Lead>();
        Map<String, Lead> zipCodeLeadMap = new Map<String, Lead>();
        if (Utils.currentUser.Profile.Name != Constant_AC.PROFILE_INTEGRATION) {
            for (Lead newLead : newLeadsList) {
                if (LEAD_RT_WISH_CHILD.equals(newLead.RecordTypeId)) {
                    initializeFields(newLead);
                    accountIdLeadMap.put(newLead.ChapterName__c, newLead);
                    if (Bypass_Triggers__c.getValues(Utils.currentUser.Id) == null) {
                        if (newLead.Status == LEAD_INQUIRY) {
                            Boolean referred = true;
                            newLead.Inquiry_Date__c = System.today();
                            if (newLead.City == null
                                    || newLead.StateCode == null
                                    || newLead.PostalCode == null
                                    || newLead.Street == null) {
                                referred = false;
                            }
                            for (Schema.FieldSetMember f : SObjectType.Lead.fieldSets.Non_Medical_Referral_Required_Fields.getFields()) {
                                if (newLead.get(f.getFieldPath()) == null) {
                                    referred = false;
                                }
                            }
                            if (referred == true) {
                                newLead.Status = LEAD_REFERRED;
                            }
                        }
                        if (newLead.RFI_Form_Info_Hidden__c == null
                                && newLead.Override_Dupe_Check__c == false
                                && (newLead.Status == LEAD_INQUIRY || newLead.Status == LEAD_REFERRED)) {
                            inquiryReferredLeads.add(newLead);
                        }
                        if (newLead.Status == LEAD_REFERRED) {
                            newLead.Inquiry_Date__c = Date.today();
                            newLead.Referred_Date__c = Date.today();
                        }
                    }
                    if (newLead.PostalCode != null) {
                        zipCodeLeadMap.put(newLead.PostalCode, newLead);
                    } else {
                        zipCodeLeadMap.put(newLead.Referrer_Zip__c, newLead);
                    }
                }
            }
        }
        if (!accountIdLeadMap.isEmpty()) {
            LeadService.setRegionCode(accountIdLeadMap);
        }
        if (!zipCodeLeadMap.isEmpty()) {
            LeadService.updateChapterFields(zipCodeLeadMap);
        }
        if (!accountIdLeadMap.isEmpty()) {
            LeadService.setHiddenChapterName(accountIdLeadMap);
        }
    }

    /**
     * Before update of Lead
     */
    public override void handleBeforeUpdateIgnoreBypass() {
        Map<Id, Lead> accountIdLeadMap = new Map<Id, Lead>();
        Map<Id, Lead> icdCodeLeadMap = new Map<Id, Lead>();
        Map<Id, Set<Integer>> icdCodeDescriptionMatchMap = new Map<Id, Set<Integer>>();
        List<Lead> eligibilityReviewLeads = new List<Lead>();
        List<Lead> potentialReferredLeadDuplicates = new List<Lead>();
        List<Lead> potentialReferredLeadContactDuplicates = new List<Lead>();
        List<Lead> qualifiedLeadsFieldValidation = new List<Lead>();
        List<Lead> qualifiedRushLeads = new List<Lead>();
        List<Lead> potentialRushLeads = new List<Lead>();
        List<Lead> updatedDiagnosisLeads = new List<Lead>();
        List<Lead> updateChapterLeadList = new List<Lead>();
        Set<String> updatedQualifyingIcdCode = new Set<String>();
        Set<String> updatedQualifyingDiagnoses = new Set<String>();
        List<Diagnosis_Verification__c> diagnosisVerifications = new List<Diagnosis_Verification__c>();
        Set<Id> completedTaskLeadSet = new Set<Id>();

        if (Utils.currentUser.Profile.Name == Constant_AC.PROFILE_INTEGRATION) {
            for (Lead newLead : newLeadsMap.values()) {
                if (LEAD_RT_WISH_CHILD.equals(newLead.RecordTypeId)) {
                    Lead oldLead = oldLeadsMap.get(newLead.Id);
                    if (Bypass_Triggers__c.getValues(Utils.currentUser.Id) == null && hasLeadAddressChanged(newLead, oldLead)) {
                        newLead.AddressVerified__c = false;
                        newLead.AddressVerificationAttempted__c = null;
                        newLead.County__c = null;
                    }
                    if (hasLeadZipCodeChanged(newLead, oldLead)) {
                        newLead.Initial_Address_Verification__c = true;
                        newLead.Hidden_Chapter_Change_Confirmation__c = null;
                        updateChapterLeadList.add(newLead);
                    }
                    if (hasLeadChangedChapter(newLead, oldLead)) {
                        if (hasLeadChapterBackupChanged(newLead, oldLead)) {
                            newLead.Hidden_Chapter_Change_Confirmation__c = oldLead.ChapterName__c;
                        }
                        accountIdLeadMap.put(newLead.ChapterName__c, newLead);
                    }
                }
            }
            if (!updateChapterLeadList.isEmpty()) {
                LeadService.setChapterViaZipCode(updateChapterLeadList);
            }
            if (!accountIdLeadMap.isEmpty()) {
                LeadService.setHiddenChapterName(accountIdLeadMap);
                LeadService.updateLeadOwner(accountIdLeadMap);
            }
        } else {
            for (Lead newLead : newLeadsMap.values()) {
                if (LEAD_RT_WISH_CHILD.equals(newLead.RecordTypeId)) {
                    Lead oldLead = oldLeadsMap.get(newLead.Id);
                    if (Bypass_Triggers__c.getValues(Utils.currentUser.Id) == null && hasLeadAddressChanged(newLead, oldLead)) {
                        newLead.AddressVerified__c = false;
                        newLead.AddressVerificationAttempted__c = null;
                        newLead.County__c = null;
                    }
                    if (isLeadNew(newLead, oldLead)) {
                        newLead.Sub_Status__c = LEAD_NEW;
                        newLead.Eligibility_Review_Date__c = Date.today();
                    }
                    if (isLeadEligibilityReviewComatoseVegState(newLead, oldLead)) {
                        newLead.Sub_Status__c = LEAD_SUB_STATUS_PENDING_CLARIFICATION_CHAPTER;
                    }
                    if (canLeadCompleteTask(newLead, oldLead)) {
                        completedTaskLeadSet.add(newLead.Id);
                    }
                    if (isLeadDNQ(newLead, oldLead)) {
                        newLead.DNQ_Date__c = Date.today();
                    }
                    if (hasLeadChangedChapter(newLead, oldLead)) {
                        if (hasLeadChapterBackupChanged(newLead, oldLead)) {
                            newLead.Hidden_Chapter_Change_Confirmation__c = oldLead.ChapterName__c;
                        }
                        accountIdLeadMap.put(newLead.ChapterName__c, newLead);
                    }
                    if (hasLeadTreatingMedicalEmailChanged(newLead, oldLead)) {
                        newLead.HiddenMedicalProfessionalEmail__c = newLead.Treating_Medical_Professional_Email__c;
                    }
                    if (isLeadReferred(newLead, oldLead)) {
                        newLead.Referred_Date__c = Date.today();
                    }
                    if (hasLeadPartASent(newLead, oldLead)) {
                        newLead.Part_A_Sent__c = Date.today();
                    }
                    if (isLeadQualified(newLead, oldLead)) {
                        diagnosisVerifications = DiagnosisVerificationService.findByLeadId(newLead.Id);
                        newLead.Sub_Status__c = null;
                        newLead.Qualified_Date__c = Date.today();//Added per IME-69
                    }
                    if (isLeadQualifiedRequiredFieldValidation(newLead)) {
                        qualifiedLeadsFieldValidation.add(newLead);
                    }
                    if (isLeadEligibilityReviewPendingChapterClarification(newLead)) {
                        newLead.Sub_Status__c = null;
                    }
                    if (hasLeadMedicalProfessionalChanged(newLead, oldLead)) {
                        newLead.Of_Times_Email_Sent__c = 0;
                        newLead.Part_A_Form_Password__c = Utils.generateRandomNumber(6);
                    }
                    if (hasLeadReferredPotentialDuplicates(newLead, oldLead)) {
                        potentialReferredLeadDuplicates.add(newLead);
                        if (newLead.Contact_Dup_Check__c != LEAD_DUP_CHECK_BLOCK_CONTACT_DUP) {
                            potentialReferredLeadContactDuplicates.add(newLead);
                        }
                    }
                    if (hasLeadQualifyingIcdCodeChanged(newLead, oldLead)) {
                        updatedQualifyingIcdCode.add(newLead.Qualifying_ICD__c);
                        updatedDiagnosisLeads.add(newLead);
                    } else if (newLead.Qualifying_ICD__c == null) {
                        newLead.PR_Diagnosis__c = EMPTY;
                    }
                    if (hasLeadQualifyingDiagnosisChanged(newLead, oldLead)) {
                        updatedQualifyingDiagnoses.add(newLead.Qualifying_Diagnosis__c);
                        updatedDiagnosisLeads.add(newLead);
                    } else if (isLeadQualifyingDiagnosisNull(newLead, oldLead)) {
                        newLead.PR_Diagnosis__c = EMPTY;
                    }
                    if (isLeadEligibilityReview(newLead, oldLead)) {
                        eligibilityReviewLeads.add(newLead);
                    }
                    if (hasLeadMedicalReasonMoveQuickly(newLead) && isLeadQualified(newLead, oldLead)) {
                        qualifiedRushLeads.add(newLead);
                    }
                    if (hasLeadMedicalReasonMoveQuickly(newLead)) {
                        newLead.Rush__c = true;
                    } else if (String.isNotBlank(newLead.Any_medical_reason_for_moving_quickly__c)
                            && (!newLead.Any_medical_reason_for_moving_quickly__c.containsIgnoreCase(MEDICAL_REASON_MOVING_QUICKLY_YES))) {
                        newLead.Rush__c = false;
                        if (newLead.Any_medical_reason_for_moving_quickly__c.containsIgnoreCase(MEDICAL_REASON_MOVING_QUICKLY_YES)) {
                            potentialRushLeads.add(newLead);
                        }
                    } else {
                        newLead.Rush__c = false;
                    }
                    if (isLeadPending(newLead)) {
                        newLead.Pending_Diagnosis_Date__c = Date.today();
                    }
                    if (newLead.SD1_ICD_Code__c != oldLead.SD1_ICD_Code__c && newLead.SD1_ICD_Code__c != null) {
                        icdCodeLeadMap.put(newLead.SD1_ICD_Code__c, newLead);
                        if (icdCodeDescriptionMatchMap.containsKey(newLead.Id)) {
                            icdCodeDescriptionMatchMap.get(newLead.Id).add(1);
                        } else {
                            icdCodeDescriptionMatchMap.put(newLead.Id, new Set<Integer>{
                                    1
                            });
                        }
                    }
                    if (newLead.SD2_ICD_Code__c != oldLead.SD2_ICD_Code__c && newLead.SD2_ICD_Code__c != null) {
                        icdCodeLeadMap.put(newLead.SD2_ICD_Code__c, newLead);
                        if (icdCodeDescriptionMatchMap.containsKey(newLead.Id)) {
                            icdCodeDescriptionMatchMap.get(newLead.Id).add(2);
                        } else {
                            icdCodeDescriptionMatchMap.put(newLead.Id, new Set<Integer>{
                                    2
                            });
                        }
                    }
                    if (newLead.SD3_ICD_Code__c != oldLead.SD3_ICD_Code__c && newLead.SD3_ICD_Code__c != null) {
                        icdCodeLeadMap.put(newLead.SD3_ICD_Code__c, newLead);
                        if (icdCodeDescriptionMatchMap.containsKey(newLead.Id)) {
                            icdCodeDescriptionMatchMap.get(newLead.Id).add(3);
                        } else {
                            icdCodeDescriptionMatchMap.put(newLead.Id, new Set<Integer>{
                                    3
                            });
                        }
                    }
                    if (newLead.SD4_ICD_Code__c != oldLead.SD4_ICD_Code__c && newLead.SD4_ICD_Code__c != null) {
                        icdCodeLeadMap.put(newLead.SD4_ICD_Code__c, newLead);
                        if (icdCodeDescriptionMatchMap.containsKey(newLead.Id)) {
                            icdCodeDescriptionMatchMap.get(newLead.Id).add(4);
                        } else {
                            icdCodeDescriptionMatchMap.put(newLead.Id, new Set<Integer>{
                                    4
                            });
                        }
                    }
                    if (newLead.ICD_Given_By_Referrer__c != oldLead.ICD_Given_By_Referrer__c && newLead.ICD_Given_By_Referrer__c != null) {
                        icdCodeLeadMap.put(newLead.ICD_Given_By_Referrer__c, newLead);
                        if (icdCodeDescriptionMatchMap.containsKey(newLead.Id)) {
                            icdCodeDescriptionMatchMap.get(newLead.Id).add(5);
                        } else {
                            icdCodeDescriptionMatchMap.put(newLead.Id, new Set<Integer>{
                                    5
                            });
                        }
                    }
                }
            }
            if (!accountIdLeadMap.isEmpty()) {
                LeadService.setHiddenChapterName(accountIdLeadMap);
                LeadService.updateLeadOwner(accountIdLeadMap);
            }
            if (!icdCodeDescriptionMatchMap.isEmpty()) {
                LeadService.matchConditionDescription(icdCodeDescriptionMatchMap, icdCodeLeadMap);
            }
            if (!updatedDiagnosisLeads.isEmpty()) {
                LeadService.setMedicalInfo(updatedQualifyingDiagnoses, updatedQualifyingIcdCode, updatedDiagnosisLeads);
            }
            if (!eligibilityReviewLeads.isEmpty()) {
                CaseService.createEligibilityReview(eligibilityReviewLeads);
            }
            if (!potentialReferredLeadDuplicates.isEmpty()) {
                LeadService.findDuplicateLeads(potentialReferredLeadDuplicates);
            }
            if (!potentialReferredLeadContactDuplicates.isEmpty()) {
                LeadService.findDuplicateContacts(potentialReferredLeadContactDuplicates);
            }
            if (!qualifiedLeadsFieldValidation.isEmpty()) {
                LeadService.validateQualifiedRequiredFields(qualifiedLeadsFieldValidation);
            }
            if (!potentialRushLeads.isEmpty()) {
                TaskService.createRushTask(potentialRushLeads);
            }
            if (!diagnosisVerifications.isEmpty() && !eligibilityReviewLeads.isEmpty()) {
                LeadService.setQualifyingDiagnosis(diagnosisVerifications[0].ICD_Code__c, eligibilityReviewLeads);
            }
            if (!completedTaskLeadSet.isEmpty()) {
                TaskService.updateCompleted(completedTaskLeadSet);
            }
        }
    }

    /**
     * Before delete of Lead
     */
    public override void handleBeforeDelete() {
        Set<Id> ids = new Set<Id>();
        Set<Id> leadIdSet = new Set<Id>();
        for (Lead lead : oldLeadsList) {
            if (LEAD_RT_WISH_CHILD.equals(lead.RecordTypeId)) {
                if (Bypass_Triggers__c.getValues(Utils.currentUser.Id) == null) {
                    ids.add(lead.Id);
                }
            }
        }
        if (!ids.isEmpty()) {
            for (cg__Lead_File__c tempCount : [
                    SELECT Id, cg__Lead__c
                    FROM cg__Lead_File__c
                    WHERE cg__Lead_File__c.cg__WIP__c = FALSE
                    AND cg__Lead__c IN:ids
            ]) {
                leadIdSet.add(tempCount.cg__Lead__c);
            }
        }
        for (Lead obj : oldLeadsList) {
            if (leadIdSet.contains(obj.Id)) {
                obj.addError(Label.Existing_Files_Attached);
            }
        }
    }

    /**
     * After insert of Lead
     */
    public override void handleAfterInsert() {
        Map<Id, Lead> newLeadMap = new Map<Id, Lead>();
        Map<String, List<Lead>> leadMap = new Map<String, List<Lead>>();
        for (Lead newLead : newLeadsList) {
            if (LEAD_RT_WISH_CHILD.equals(newLead.RecordTypeId)) {
                if (Bypass_Triggers__c.getValues(Utils.currentUser.Id) == null) {
                    newLeadMap.put(newLead.Id, newLead);
                }
                if (newLead.ChapterName__c != null
                        && newLead.Owner.UserRole.Name == ROLE_NATIONAL_STAFF) {
                    if (leadMap.containsKey(newLead.ChapterName__r.Name)) {
                        leadMap.get(newLead.ChapterName__r.Name).add(newLead);
                    } else {
                        leadMap.put(newLead.ChapterName__r.Name, new List<Lead>{
                                newLead
                        });
                    }
                }
            }
            if (!newLeadMap.isEmpty()) {
                TaskService.createLeadTask(newLeadMap.keySet());
            }
            if (!leadMap.isEmpty()) {
                ChapterStaffRecordSharing_AC.LeadSharing(leadMap);
            }
        }
    }

    /**
     * After update of Lead
     */
    public override void handleAfterUpdate() {
        Map<Id, Lead> qualifiedLeadMap = new Map<Id, Lead>();
        Set<Id>LeadIdSet = new Set<Id>();
        Set<String> chapterSet = new Set<String>();
        Map<Id, Boolean> rushLeadMap = new Map<Id, Boolean>();
        for (Chapter_Name_Setting__mdt chapters : [
                SELECT Id, Chapter_Name__c
                FROM Chapter_Name_Setting__mdt
        ]) {
            chapterSet.add(chapters.Chapter_Name__c);
        }
        Map<Id, Account> chapterAccountMap = new Map<Id, Account>([
                SELECT Id
                FROM Account
                WHERE Name IN :chapterSet
        ]);
        if (RecursiveTriggerHandler.isFirstTime == true) {
            for (Lead newLead : newLeadsMap.values()) {
                if (LEAD_RT_WISH_CHILD.equals(newLead.RecordTypeId)) {
                    Lead oldLead = oldLeadsMap.get(newLead.Id);
                    if (!newLead.IsConverted && newLead.Status == LEAD_QUALIFIED
                            && oldLead.Status != LEAD_QUALIFIED
                            && (!chapterAccountMap.containsKey(newLead.ChapterName__c))) {
                        qualifiedLeadMap.put(newLead.Id, newLead);
                    }
                    if ((newLead.Is_in_a_Comatose_Vegetative_State__c == COMATOSE_VEGETATIVE_STATE_YES
                            && newLead.Status == LEAD_ELIGIBILITY_REVIEW
                            && oldLead.Status != LEAD_ELIGIBILITY_REVIEW)
                            || (newLead.Is_in_a_Comatose_Vegetative_State__c == COMATOSE_VEGETATIVE_STATE_YES
                            && oldLead.Is_in_a_Comatose_Vegetative_State__c != COMATOSE_VEGETATIVE_STATE_YES
                            && newLead.Status == LEAD_ELIGIBILITY_REVIEW)) {
                        LeadIdSet.add(newLead.Id);
                    }
                    String medicalReason = newLead.Any_medical_reason_for_moving_quickly__c;
                    String oldMedicalReason = oldLead.Any_medical_reason_for_moving_quickly__c;
                    if (medicalReason != null && newLead.Status == LEAD_ELIGIBILITY_REVIEW) {
                        if (medicalReason.containsIgnoreCase(MEDICAL_REASON_MOVING_QUICKLY_YES)
                                && (oldMedicalReason == null || !oldMedicalReason.containsIgnoreCase(MEDICAL_REASON_MOVING_QUICKLY_YES))) {
                            rushLeadMap.put(newLead.Id, true);
                        } else if (!medicalReason.containsIgnoreCase(MEDICAL_REASON_MOVING_QUICKLY_YES)
                                && (oldMedicalReason == null || oldMedicalReason.containsIgnoreCase(MEDICAL_REASON_MOVING_QUICKLY_YES))) {
                            rushLeadMap.put(newLead.Id, false);
                        }
                    }
                }
            }
        }
        if (!qualifiedLeadMap.isEmpty()) {
            Map<Id, Id> convertedLeadByContactId = LeadConvertService.convertLead(qualifiedLeadMap);
            LeadConvertService.processConvertedLead(convertedLeadByContactId);
        }
        if (!rushLeadMap.isEmpty()) {
            CaseService.updateRushByLeadAndRecordType(rushLeadMap, new Set<Id>{
                    DIAGNOSIS_RECORD_TYPE_ID
            });
        }
        if (!LeadIdSet.isEmpty()) {
            CaseService.updateStatusByLeadAndRecordType(LeadIdSet, new Set<Id>{
                    DIAGNOSIS_RECORD_TYPE_ID
            }, CASE_PENDING_CLARIFICATION);
        }
    }

    /**
     * Before inserting the Lead, initialize some field values
     * @param lead
     */
    private static void initializeFields(Lead lead) {
        lead.Override_Dupe_Check__c = false;
        lead.Contact_Dup_Check__c = null;
        lead.Dup_Check__c = null;
        lead.Part_A_Form_Password__c = Utils.generateRandomNumber(6);
        if (lead.Additional_Parent_First_Name__c == lead.Parent_First_Name__c
                && lead.Additional_Parent_Last_Name__c == lead.Parent_Last_Name__c
                && lead.Additional_Parent_Phone__c == lead.Phone
                && lead.Additional_Parent_Email__c == lead.Email
                && lead.Additional_Parent_City__c == lead.City
                && lead.Additional_Parent_Postal_Code__c == lead.PostalCode) {
            lead.Additional_Parent_First_Name__c = EMPTY;
            lead.Additional_Parent_Last_Name__c = EMPTY;
            lead.Additional_Parent_Phone__c = EMPTY;
            lead.Additional_Parent_Email__c = EMPTY;
            lead.Additional_Parent_City__c = EMPTY;
            lead.Additional_Parent_Postal_Code__c = EMPTY;
        }
        if (lead.Additional_Parent_First_Name__c == null
                && lead.Additional_Parent_Last_Name__c == null
                && lead.Additional_Parent_Phone__c == null
                && lead.Additional_Parent_Email__c == null
                && lead.Additional_Parent_City__c == null
                && lead.Additional_Parent_Postal_Code__c == null) {
            lead.Additional_Parent_State__c = EMPTY;
        }
    }

    /**
     * Check if Address changed
     * @param newLead
     * @param oldLead
     * @return Boolean
     */
    private static Boolean hasLeadAddressChanged(Lead newLead, Lead oldLead) {
        return newLead.Street != oldLead.Street
                || newLead.State != oldLead.State
                || newLead.StateCode != oldLead.StateCode
                || newLead.City != oldLead.City
                || newLead.PostalCode != oldLead.PostalCode;
    }

    /**
     * Check if Lead is New
     * @param newLead
     * @param oldLead
     * @return Boolean
     */
    private static Boolean isLeadNew(Lead newLead, Lead oldLead) {
        return newLead.Status == LEAD_ELIGIBILITY_REVIEW
                && oldLead.Status != LEAD_ELIGIBILITY_REVIEW
                && oldLead.Status != LEAD_DNQ;
    }

    /**
     * Check if Lead has been changed to DNQ
     * @param newLead
     * @param oldLead
     * @return Boolean
     */
    private static Boolean isLeadDNQ(Lead newLead, Lead oldLead) {
        return newLead.Status == LEAD_DNQ && oldLead.Status != LEAD_DNQ;
    }

    /**
     * Check if Lead has been changed to Referred
     * @param newLead
     * @param oldLead
     * @return Boolean
     */
    private static Boolean isLeadReferred(Lead newLead, Lead oldLead) {
        return newLead.Status == LEAD_REFERRED && oldLead.Status == LEAD_INQUIRY;
    }

    /**
     * Check if Lead has been changed to Referred
     * @param newLead
     * @param oldLead
     * @return Boolean
     */
    private static Boolean isLeadQualified(Lead newLead, Lead oldLead) {
        return newLead.Status == LEAD_QUALIFIED && oldLead.Status != newLead.Status;
    }

    /**
     * Check if Lead has been changed to Eligibility Review
     * @param newLead
     * @param oldLead
     * @return Boolean
     */
    private static Boolean isLeadEligibilityReview(Lead newLead, Lead oldLead) {
        return newLead.Status == LEAD_ELIGIBILITY_REVIEW && oldLead.Status != LEAD_ELIGIBILITY_REVIEW;
    }

    /**
     * Check if Lead is in Eligibility Review and Comatose Vegetative State
     * @param newLead
     * @param oldLead
     * @return Boolean
     */
    private static Boolean isLeadEligibilityReviewComatoseVegState(Lead newLead, Lead oldLead) {
        return ((newLead.Is_in_a_Comatose_Vegetative_State__c == COMATOSE_VEGETATIVE_STATE_YES
                && newLead.Status == LEAD_ELIGIBILITY_REVIEW && oldLead.Status != LEAD_ELIGIBILITY_REVIEW)
                || (newLead.Is_in_a_Comatose_Vegetative_State__c == COMATOSE_VEGETATIVE_STATE_YES
                && newLead.Status == LEAD_ELIGIBILITY_REVIEW
                && oldLead.Is_in_a_Comatose_Vegetative_State__c != COMATOSE_VEGETATIVE_STATE_YES));
    }

    /**
     * Check if Lead is in Eligibility Review and Comatose Vegetative State
     * @param newLead
     * @return Boolean
     */
    private static Boolean isLeadEligibilityReviewPendingChapterClarification(Lead newLead) {
        return newLead.Status == LEAD_ELIGIBILITY_REVIEW
                && newLead.Sub_Status__c == LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION;
    }

    /**
     * Check if Lead is Pending
     * @param newLead
     * @return Boolean
     */
    private static Boolean isLeadPending(Lead newLead) {
        return newLead.Sub_Status__c == LEAD_SUB_STATUS_PENDING_PART_A
                || newLead.Sub_Status__c == LEAD_SUB_STATUS_PENDING_PAPER_DV
                || newLead.Sub_Status__c == LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION;
    }

    /**
     * Check if Lead is in one of the Status and can Complete related tasks
     * @param newLead
     * @param oldLead
     * @return Boolean
     */
    private static Boolean canLeadCompleteTask(Lead newLead, Lead oldLead) {
        return (newLead.Status == LEAD_QUALIFIED && oldLead.Status != LEAD_QUALIFIED)
                || (newLead.Status == LEAD_DNQ && oldLead.Status != LEAD_DNQ)
                || (newLead.Status == LEAD_DUPLICATE && oldLead.Status != LEAD_DUPLICATE)
                || (newLead.Status == LEAD_DECEASED && oldLead.Status != LEAD_DECEASED);
    }

    /**
     * Check if Lead Chapter changed
     * @param newLead
     * @param oldLead
     * @return Boolean
     */
    private static Boolean hasLeadChangedChapter(Lead newLead, Lead oldLead) {
        return newLead.ChapterName__c != oldLead.ChapterName__c;
    }

    /**
     * Check if Lead backup Chapter changed
     * @param newLead
     * @param oldLead
     * @return Boolean
     */
    private static Boolean hasLeadChapterBackupChanged(Lead newLead, Lead oldLead) {
        return newLead.Hidden_Chapter_Change_Confirmation__c == null
                || newLead.Hidden_Chapter_Change_Confirmation__c
                != oldLead.Hidden_Chapter_Change_Confirmation__c;
    }

    /**
     * Check if Lead Treating Medical Professional changed Email
     * @param newLead
     * @param oldLead
     * @return Boolean
     */
    private static Boolean hasLeadTreatingMedicalEmailChanged(Lead newLead, Lead oldLead) {
        return newLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL
                && oldLead.Hidden_DV_form_Medical_professional_Type__c
                != newLead.Hidden_DV_form_Medical_professional_Type__c;
    }

    /**
     * Check if Lead Part A sent
     * @param newLead
     * @param oldLead
     * @return Boolean
     */
    private static Boolean hasLeadPartASent(Lead newLead, Lead oldLead) {
        return (newLead.Of_Times_Email_Sent__c != oldLead.Of_Times_Email_Sent__c)
                || (newLead.Sub_Status__c != oldLead.Sub_Status__c
                && (newLead.Using_Paper_Process_For_DV__c == true
                && (newLead.Sub_Status__c == LEAD_SUB_STATUS_PENDING_PART_A
                || newLead.Sub_Status__c == LEAD_SUB_STATUS_PENDING_PAPER_DV)));
    }

    /**
     * Check if Lead Medical Professionals changed
     * @param newLead
     * @param oldLead
     * @return Boolean
     */
    private static Boolean hasLeadMedicalProfessionalChanged(Lead newLead, Lead oldLead) {
        return (newLead.Treating_Medical_Professional_Email__c != oldLead.Treating_Medical_Professional_Email__c
                && newLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL)
                || (newLead.Best_contact_for_Physician_Email__c != oldLead.Best_contact_for_Physician_Email__c
                && newLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_BEST_CONTACT)
                || (newLead.Alternate1MedicalProfessionalEmail__c != oldLead.Alternate1MedicalProfessionalEmail__c
                && newLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_ALTERNATE_1_MEDICAL_PROFESSIONAL)
                || (newLead.Alternate2MedProfessionalEmail__c != oldLead.Alternate2MedProfessionalEmail__c
                && newLead.Hidden_DV_form_Medical_professional_Type__c == LEAD_DV_FORM_TYPE_ALTERNATE_2_MEDICAL_PROFESSIONAL);
    }

    /**
     * Check if Lead has potential duplicates
     * @param newLead
     * @param oldLead
     * @return Boolean
     */
    private static Boolean hasLeadReferredPotentialDuplicates(Lead newLead, Lead oldLead) {
        return (newLead.Status == LEAD_REFERRED)
                && (newLead.Sub_Status__c == LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION
                || newLead.Sub_Status__c == LEAD_SUB_STATUS_PENDING_PART_A
                || newLead.Sub_Status__c == LEAD_SUB_STATUS_PENDING_PAPER_DV)
                && newLead.Sub_Status__c != oldLead.Sub_Status__c
                && newLead.Dup_Check__c != LEAD_DUP_CHECK_BLOCK_LEAD_DUP;
    }

    /**
     * Check if Qualified Lead is required field validation
     * @param newLead
     * @return Boolean
     */
    private static Boolean isLeadQualifiedRequiredFieldValidation(Lead newLead) {
        return newLead.Status == LEAD_QUALIFIED && !newLead.Is_Required_Bypass__c;
    }

    /**
     * Check if Lead Qualifying Icd Code changed
     * @param newLead
     * @param oldLead
     * @return Boolean
     */
    private static Boolean hasLeadQualifyingIcdCodeChanged(Lead newLead, Lead oldLead) {
        return newLead.Qualifying_ICD__c != null && newLead.Qualifying_ICD__c != oldLead.Qualifying_ICD__c;
    }

    /**
     * Check if Lead Qualifying Diagnosis changed
     * @param newLead
     * @param oldLead
     * @return Boolean
     */
    private static Boolean hasLeadQualifyingDiagnosisChanged(Lead newLead, Lead oldLead) {
        return newLead.Qualifying_Diagnosis__c != null && newLead.Qualifying_Diagnosis__c != oldLead.Qualifying_Diagnosis__c;
    }

    /**
     * Check if Lead Qualifying Diagnosis null
     * @param newLead
     * @param oldLead
     * @return Boolean
     */
    private static Boolean isLeadQualifyingDiagnosisNull(Lead newLead, Lead oldLead) {
        return newLead.Qualifying_Diagnosis__c == null && newLead.Qualifying_Diagnosis__c != oldLead.Qualifying_Diagnosis__c;
    }

    /**
     * Check if Lead has Medical Reason to move quickly
     * @param newLead
     * @return Boolean
     */
    private static Boolean hasLeadMedicalReasonMoveQuickly(Lead newLead) {
        return newLead.Any_medical_reason_for_moving_quickly__c != null
                && newLead.Any_medical_reason_for_moving_quickly__c.containsIgnoreCase(MEDICAL_REASON_MOVING_QUICKLY_YES);
    }

    /**
     * Check if Integration User changed the Lead Zip Code
     * @param newLead
     * @param oldLead
     * @return Boolean
     */
    private static Boolean hasLeadZipCodeChanged(Lead newLead, Lead oldLead) {
        return newLead.PostalCode != null
                && (newLead.PostalCode != oldLead.PostalCode)
                && oldLead.Initial_Address_Verification__c == false;
    }
}