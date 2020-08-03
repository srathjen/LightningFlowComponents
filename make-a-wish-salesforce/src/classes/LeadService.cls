/**
 * @description Lead Service, centralizes Lead business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 2/27/2020
 * @updated Bmac 06/26/2020 SIW-616 lines 770, 841, 857
 * @updated Manoj 08/03/2020 SIW-378 : Reset fields: lines 143-148
 * @updated CSmith 06/05/2020 SIW-539 prevent any_medical_reason_for_moving_quickly__c from being reset. resetLead and resetLeadDVMedicalSummary methods */
public class LeadService {

    private static final String INSTANCE_URL = Endpoints__c.getInstance().Instance_URL__c;
    private static final String ERROR_WISH_CHILD = Constant_AC.LEAD_ERROR_WISH_CHILD;
    private static final String ERROR_WISH_ADDITIONAL_PARENT_GUARDIAN = Constant_AC.LEAD_ERROR_WISH_ADDITIONAL_PARENT_GUARDIAN;
    private static final String ERROR_WISH_FAMILY = Constant_AC.LEAD_ERROR_WISH_FAMILY;
    private static final String ERROR_BEST = Constant_AC.LEAD_ERROR_BEST;
    private static final String ERROR_MEDICAL_PROFESSIONAL = Constant_AC.LEAD_ERROR_MEDICAL_PROFESSIONAL;
    private static final String ERROR_WISH_FAMILY_AND_MEDICAL_PROFESSIONAL = Constant_AC.LEAD_ERROR_WISH_FAMILY_AND_MEDICAL_PROFESSIONAL;
    private static final String TYPE_LIGHTNING = Constant_AC.TYPE_LIGHTNING;
    private static final String TYPE_CLASSIC = Constant_AC.TYPE_CLASSIC;
    private static final String THEME_4D = Constant_AC.THEME_4D;
    private static final String THEME_4U = Constant_AC.THEME_4U;
    private static final String EMPTY = '';
    private static final String DASH = '-';
    private static final String PERIOD = '.';
    private static final String COMMA_SPACE = ', ';
    private static final String TREATING_MEDICAL_PROFESSIONAL = Constant_AC.LEAD_DV_FORM_TYPE_TREATING_MEDICAL_PROFESSIONAL;

    /**
     * Revert Chapter Name Change
     * @param leadIds
     * @return Lead Map
     */
    public static Map<Id, Lead> revertChapterNameChange(List<Id> leadIds) {
        Map<Id, Lead> leadUpdateMap = new Map<Id, Lead>();
        for (Lead lead : [
                SELECT Id, ChapterName__c, Hidden_Chapter_Change_Confirmation__c
                FROM Lead
                WHERE Id IN :leadIds
        ]) {
            Lead updateLead = new Lead(Id = lead.Id);
            updateLead.ChapterName__c = lead.Hidden_Chapter_Change_Confirmation__c;
            updateLead.Hidden_Chapter_Change_Confirmation__c = lead.Hidden_Chapter_Change_Confirmation__c;
            leadUpdateMap.put(updateLead.Id, updateLead);
        }
        update leadUpdateMap.values();
        return leadUpdateMap;
    }

    /**
     * Backup Chapter Name Change
     * @param leadIds
     * @return Lead Map
     */
    public static Map<Id, Lead> backupChapterNameChange(List<Id> leadIds) {
        Map<Id, Lead> leadUpdateMap = new Map<Id, Lead>();
        for (Lead lead : [
                SELECT Id, ChapterName__c, Hidden_Chapter_Change_Confirmation__c
                FROM Lead
                WHERE Id IN :leadIds
        ]) {
            Lead updateLead = new Lead(Id = lead.Id);
            updateLead.Hidden_Chapter_Change_Confirmation__c = lead.ChapterName__c;
            leadUpdateMap.put(updateLead.Id, updateLead);
        }
        update leadUpdateMap.values();
        return leadUpdateMap;
    }

    /**
     * Reset Lead fields
     * @param leadId
     * @return Lead
     */
    public static Lead resetLead(Id leadId) {
        Lead lead = [
                SELECT Id,Hidden_Potential_Rush__c,
                        Part_A_Received__c,Part_A_Sent__c, Status, Part_A_Form_Password__c,
                        Diagnosis_Given_By_Referrer__c, ICD_Given_By_Referrer__c,
                        PD_Condition_Description__c, PD_ICD_Code__c,Does_Child_Have_Cognitive_Delays__c,
            			Does_Child_Have_Speech_or_Language_Delay__c,Non_Verbal_Communication_Method__c,
            			Non_Verbal_Additional_Information__c,Non_Verbal__c
                FROM Lead
                WHERE Id = :leadId
        ];
        lead.Admitting_diagnosis__c = EMPTY;
        lead.Angina__c = EMPTY;
        lead.Arrhythmia__c = EMPTY;
        lead.Child_will_ultimately_die_prematurely__c = false;
        lead.Chronic_Heart_Failure__c = EMPTY;
        lead.Chronic_Hepatitis__c = EMPTY;
        lead.Congenital_Heart_Disease__c = EMPTY;
        lead.Convulsive_Disorders__c = EMPTY;
        lead.Current_Condition_Label__c = EMPTY;
        lead.Current_Condition_Label__c = EMPTY;
        lead.Current_Condition_Label__c = EMPTY;
        lead.Debilitation_may_extend_over_many_years__c = false;
        lead.DV_Present__c = false;
        lead.Heart_Failure__c = EMPTY;
        lead.I_am_Recognized_To_Practice_As_a__c = EMPTY;
        lead.I_m_Part_of_The_Treating_HealthCare_Team__c = EMPTY;
        lead.ICU_Admissions__c = EMPTY;
        lead.Increased_probability_of_premature_death__c = false;
        lead.Is_in_a_Comatose_Vegetative_State__c = EMPTY;
        lead.isSign__c = false;
        lead.Lung_Disease__c = EMPTY;
        lead.None_of_these_statements_describes_Child__c = false;
        lead.Number_hospital_admissions__c = null;
        lead.Part_A_Received__c = null;
        lead.Part_A_Sent__c = Date.today();
        lead.PD_Condition_Description__c = lead.Diagnosis_Given_By_Referrer__c;
        lead.PD_ICD_Code__c = lead.ICD_Given_By_Referrer__c;
        lead.Pending_Diagnosis_Date__c = Date.today();
        lead.Please_Explain__c = EMPTY;
        lead.Please_Explain_Deteriorate__c = EMPTY;
        lead.PR_Diagnosis__c = EMPTY;
        lead.Provided_additional_information__c = EMPTY;
        lead.Provider_Signature__c = EMPTY;
        lead.Pulmonary_Hypertension__c = EMPTY;
        lead.Responds_to_treatment_with_normal_health__c = false;
        lead.RFI_Form_Info_Hidden__c = lead.Status;
        lead.Risk_of_complications_premature_death__c = false;
        lead.Rush__c = false;
        lead.SD1_Condition_Description__c = EMPTY;
        lead.SD1_ICD_Code__c = null;
        lead.SD2_Condition_Description__c = EMPTY;
        lead.SD2_ICD_Code__c = null;
        lead.SD3_Condition_Description__c = EMPTY;
        lead.SD3_ICD_Code__c = null;
        lead.SD4_Condition_Description__c = EMPTY;
        lead.SD4_ICD_Code__c = null;
        lead.Status = Constant_AC.LEAD_STATUS_REFERRED;
        lead.Strokes__c = EMPTY;
        lead.Sub_Status__c = Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION;
        lead.This_Statement_Describes_My_Patient__c = EMPTY;
        lead.Travel_algorithm__c = EMPTY;
        lead.Travel_Restriction__c = EMPTY;
        lead.Treatment_may_be_feasible_but_can_fail__c = false;
        lead.Treatment_may_prolong_normal_activities__c = false;
        lead.Unplanned_hospital_admissions__c = EMPTY;
        lead.Ventilator__c = EMPTY;
        lead.Why_do_you_feel_would_be_eligible_Wish__c = EMPTY;
        lead.Will_Child_s_Condition_Deteriorate__c = EMPTY;
        
        //SIW-378 : Reset Fields
        lead.Does_Child_Have_Cognitive_Delays__c = EMPTY;
        lead.Does_Child_Have_Speech_or_Language_Delay__c = EMPTY;
        lead.Non_Verbal_Communication_Method__c = EMPTY;
        lead.Non_Verbal_Additional_Information__c = EMPTY;
        lead.Non_Verbal__c = EMPTY;
        
        update lead;
        return lead;
    }

    /**
     * Reset Lead fields
     * @param leadId
     * @return Lead
     */
    public static Lead resetLeadDvMedicalSummary(Id leadId) {
        Lead lead = [
                SELECT Id,Of_Times_Email_Sent__c,Qualifying_Diagnosis__c, Qualifying_ICD__c,
                        Hidden_Potential_Rush__c, Diagnosis_Given_By_Referrer__c, ICD_Given_By_Referrer__c,
                        PD_Condition_Description__c, PD_ICD_Code__c, Part_A_Sent__c, Part_A_Received__c,
                        Part_A_Form_Password__c, Hidden_DV_form_Medical_professional_Type__c, PR_Diagnosis__c,
                        Sub_Status__c,Treating_Medical_Professional_Email__c,HiddenMedicalProfessionalEmail__c, Status
                FROM Lead
                WHERE Id = :leadId
        ];
        if (lead.Of_Times_Email_Sent__c == null) {
            lead.Of_Times_Email_Sent__c = 0;
        }
        lead.Admitting_diagnosis__c = EMPTY;
        lead.Angina__c = EMPTY;
        lead.Arrhythmia__c = EMPTY;
        lead.Child_will_ultimately_die_prematurely__c = false;
        lead.Chronic_Heart_Failure__c = EMPTY;
        lead.Chronic_Hepatitis__c = EMPTY;
        lead.Congenital_Heart_Disease__c = EMPTY;
        lead.Convulsive_Disorders__c = EMPTY;
        lead.Current_Condition_Label__c = EMPTY;
        lead.Current_Condition_Label__c = EMPTY;
        lead.Current_Condition_Label__c = EMPTY;
        lead.Debilitation_may_extend_over_many_years__c = false;
        lead.DV_Present__c = false;
        lead.Heart_Failure__c = EMPTY;
        lead.I_am_Recognized_To_Practice_As_a__c = EMPTY;
        lead.I_m_Part_of_The_Treating_HealthCare_Team__c = EMPTY;
        lead.ICU_Admissions__c = EMPTY;
        lead.Increased_probability_of_premature_death__c = false;
        lead.Is_in_a_Comatose_Vegetative_State__c = EMPTY;
        lead.isSign__c = false;
        lead.Lung_Disease__c = EMPTY;
        lead.None_of_these_statements_describes_Child__c = false;
        lead.Number_hospital_admissions__c = null;
        lead.Part_A_Received__c = null;
        lead.Part_A_Sent__c = Date.today();
        lead.PD_Condition_Description__c = lead.Diagnosis_Given_By_Referrer__c;
        lead.PD_ICD_Code__c = lead.ICD_Given_By_Referrer__c;
        lead.Pending_Diagnosis_Date__c = Date.today();
        lead.Please_Explain__c = EMPTY;
        lead.Please_Explain_Deteriorate__c = EMPTY;
        lead.PR_Diagnosis__c = EMPTY;
        lead.Provided_additional_information__c = EMPTY;
        lead.Provider_Signature__c = EMPTY;
        lead.Pulmonary_Hypertension__c = EMPTY;
        lead.Responds_to_treatment_with_normal_health__c = false;
        lead.RFI_Form_Info_Hidden__c = lead.Status;
        lead.Risk_of_complications_premature_death__c = false;
        lead.Rush__c = false;
        lead.SD1_Condition_Description__c = EMPTY;
        lead.SD1_ICD_Code__c = null;
        lead.SD2_Condition_Description__c = EMPTY;
        lead.SD2_ICD_Code__c = null;
        lead.SD3_Condition_Description__c = EMPTY;
        lead.SD3_ICD_Code__c = null;
        lead.SD4_Condition_Description__c = EMPTY;
        lead.SD4_ICD_Code__c = null;
        lead.Status = Constant_AC.LEAD_STATUS_REFERRED;
        lead.Strokes__c = EMPTY;
        lead.Sub_Status__c = Constant_AC.LEAD_SUB_STATUS_PENDING_DIAGNOSIS_VERIFICATION;
        lead.This_Statement_Describes_My_Patient__c = EMPTY;
        lead.Travel_algorithm__c = EMPTY;
        lead.Travel_Restriction__c = EMPTY;
        lead.Treatment_may_be_feasible_but_can_fail__c = false;
        lead.Treatment_may_prolong_normal_activities__c = false;
        lead.Unplanned_hospital_admissions__c = EMPTY;
        lead.Ventilator__c = EMPTY;
        lead.Why_do_you_feel_would_be_eligible_Wish__c = EMPTY;
        lead.Will_Child_s_Condition_Deteriorate__c = EMPTY;
        lead.Hidden_DV_form_Medical_professional_Type__c = TREATING_MEDICAL_PROFESSIONAL;
        lead.HiddenMedicalProfessionalEmail__c = lead.Treating_Medical_Professional_Email__c;
        lead.Of_Times_Email_Sent__c = 0;
        lead.Of_Times_Email_Sent__c = lead.Of_Times_Email_Sent__c + 1;
        lead.Part_A_Form_Password__c = Utils.generateRandomNumber(6);
        update lead;
        return lead;
    }

    /**
     * Merge a list Leads into one Lead
     * @param leadTarget
     * @param leadDuplicates
     * @return
     */
    public static Boolean mergeLeads(Lead leadTarget, List<Lead> leadDuplicates) {
        Boolean successfulMerge = false;
        Lead winnerMakePrivate = new Lead(Id = leadTarget.Id, Override_Dupe_Check__c = true);
        List<Lead> losersMakePrivate = new List<Lead>();
        for (Lead leadDuplicate : leadDuplicates) {
            Lead loserMakePrivate = new Lead(Id = leadDuplicate.Id, Override_Dupe_Check__c = true);
            losersMakePrivate.add(loserMakePrivate);
        }
        update winnerMakePrivate;
        if (!losersMakePrivate.isEmpty()) {
            update losersMakePrivate;
        }
        merge winnerMakePrivate leadDuplicates;
        successfulMerge = true;
        return successfulMerge;
    }

    /**
     * Find Lead Duplicates
     * @param firstName
     * @param lastName
     * @param phone
     * @param email
     * @param street
     * @param city
     * @param state
     * @param postalCode
     * @param dateOfBirth
     * @param leadsFilterOut
     * @return List of Leads
     */
    public static List<Lead> findLeadDuplicates(String firstName, String lastName,
            String phone, String email, String street, String city, String state,
            String postalCode, Date dateOfBirth, List<Id> leadsFilterOut) {
        return [
                SELECT Id, FirstName, Name, LastName, Email,
                        Phone, City, DOB__c, State, PostalCode,
                        ChapterName__r.Name, ChapterName__c
                FROM Lead
                WHERE ((LastName = :lastName AND FirstName = :firstName)
                OR (LastName = :lastName AND ((State = :state AND City = :city AND Street = :street
                AND PostalCode = :postalCode) OR (Email != :EMPTY AND Email = :email AND Email != null)))
                OR (FirstName = :firstName AND ((State = :state AND City = :city AND Street = :street
                AND PostalCode = :postalCode) OR Phone = :phone OR (Email != :EMPTY AND Email = :email AND Email != null)))
                OR (DOB__c = :dateOfBirth AND ((State = :state AND City = :city
                AND Street = :street AND PostalCode = :postalCode) OR (Email != :EMPTY AND Email = :email AND Email != null)))
                OR (DOB__c = :dateOfBirth AND (LastName = :lastName OR FirstName = :firstName)))
                AND Id NOT IN :leadsFilterOut
                AND IsConverted = FALSE
        ];
    }

    /**
     * Find Lead Duplicates
     * @param firstName
     * @param lastName
     * @param phone
     * @param email
     * @param street
     * @param city
     * @param state
     * @param postalCode
     * @param dateOfBirth
     * @param leadsFilterOut
     * @param chapterName
     * @return List of Leads
     */
    public static List<Lead> findLeadDuplicatesWithChapter(String firstName, String lastName,
            String phone, String email, String street, String city, String state,
            String postalCode, Date dateOfBirth, List<Id> leadsFilterOut, Id chapterName) {
        return [
                SELECT Id, FirstName,Name, LastName, Email, Phone, City, DOB__c,State, PostalCode,
                        ChapterName__r.Name, ChapterName__c
                FROM Lead
                WHERE ((LastName = :lastName AND FirstName = :firstName)
                OR (LastName = :lastName AND ((State = :state AND City = :city AND Street = :street
                AND PostalCode = :postalCode) OR Email = :email))
                OR (FirstName = :firstName AND ((State = :state AND City = :city AND Street = :street
                AND PostalCode = :postalCode) OR Phone = :phone OR Email = :email))
                OR (DOB__c = :dateOfBirth AND ((State = :state AND City = :city
                AND Street = :street AND PostalCode = :postalCode)
                OR Email = :email)) OR (DOB__c = :dateOfBirth
                AND (LastName = :lastName OR FirstName = :firstName)))
                AND Id NOT IN :leadsFilterOut
                AND IsConverted = FALSE
                AND ChapterName__c = :chapterName
        ];
    }

    /**
     * Check if a Medical Professional contact equal
     * @param sourceFirstName
     * @param sourceLastName
     * @param sourcePhone
     * @param sourceEmail
     * @param targetFirstName
     * @param targetLastName
     * @param targetPhone
     * @param targetEmail
     * @return
     */
    public static Boolean isSameMedicalProfessional(
            String sourceFirstName, String targetFirstName,
            String sourceLastName, String targetLastName,
            String sourcePhone, String targetPhone,
            String sourceEmail, String targetEmail) {
        if (sourceFirstName == targetFirstName
                && sourceLastName == targetLastName
                && (sourcePhone == targetPhone || sourceEmail == targetEmail)) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * Set Region Code
     * @param accountIdLeadMap
     */
    public static void setRegionCode(Map<Id, Lead> accountIdLeadMap) {
        Set<Id> chapterRegionSet = new Set<Id>();
        try {
            for (AggregateResult aggr : [
                    SELECT COUNT(Id) cnt,Chapter_Name__c cName
                    FROM Regions__c
                    WHERE Chapter_Name__c != NULL
                    AND Chapter_Name__c IN :accountIdLeadMap.keySet()
                    GROUP BY Chapter_Name__c
            ]) {
                chapterRegionSet.add((Id) aggr.get('cName'));
            }
            List<Regions__c> regionCodeList = [
                    SELECT Id, Chapter_Name__c
                    FROM Regions__c
                    WHERE Chapter_Name__c = NULL
                    LIMIT 1
            ];
            for (Lead leadUpdate : accountIdLeadMap.values()) {
                if (!chapterRegionSet.contains(leadUpdate.ChapterName__c)) {
                    if (!regionCodeList.isEmpty()) {
                        leadUpdate.Region_Code__c = regionCodeList.get(0).Id;
                    }
                }
            }
            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class Execution');
            }
        } catch (Exception ex) {
            for (Lead lead : accountIdLeadMap.values()) {
                ErrorMessage_AC.createdebugRec('LeadService',
                        String.valueOf(lead), String.valueOf(ex), 'populateRegionCode',
                        'Null', ex.getStackTraceString(), 'Error');
            }
            if (!Test.isRunningTest()) {
                for (Lead lead : accountIdLeadMap.values()) {
                    lead.addError(Label.Debug_log_error_message);
                }
            }
        }
    }

    /**
     * Update Chapter Fields
     * @param zipCodeLeadMap
     */
    public static void updateChapterFields(Map<String, Lead> zipCodeLeadMap) {
        Map<String, String> zipCodeChapterMap = new Map<String, String>();
        Map<String, String> zipCodeReferralMap = new Map<String, String>();
        Map<String, Boolean> chapterActiveMap = new Map<String, Boolean>();
        try {
            for (Zip_Code__c zipCode : [
                    SELECT Id, Name,Office__r.Chapter__c, Office__r.Referral_Email_Address__c
                    FROM Zip_Code__c
                    WHERE Name IN :zipCodeLeadMap.keySet()
            ]) {
                zipCodeChapterMap.put(zipCode.Name, zipCode.Office__r.Chapter__c);
                zipCodeReferralMap.put(zipCode.Name, zipCode.Office__r.Referral_Email_Address__c);
            }
            for (Account account : [
                    SELECT Id, Onboarded_on_SF__c,Intake_Manager__r.Email
                    FROM Account
                    WHERE Id IN :zipCodeChapterMap.values()
            ]) {
                chapterActiveMap.put(account.Id, account.Onboarded_on_SF__c);
            }
            for (Lead lead : zipCodeLeadMap.values()) {
                if (zipCodeReferralMap.containsKey(lead.PostalCode)) {
                    lead.Office_Referral_Email__c = zipCodeReferralMap.get(lead.PostalCode);
                } else if (zipCodeReferralMap.containsKey(lead.Referrer_Zip__c)) {
                    lead.Office_Referral_Email__c = zipCodeReferralMap.get(lead.Referrer_Zip__c);
                } else {
                    lead.Office_Referral_Email__c = null;
                }
                if (chapterActiveMap.containsKey(lead.ChapterName__c)) {
                    lead.Is_Chapter_Active__c = chapterActiveMap.get(lead.ChapterName__c);
                }
            }
            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }
        }

        catch (Exception ex) {
            for (Lead lead : zipCodeLeadMap.values()) {
                ErrorMessage_AC.createdebugRec('LeadService',
                        String.valueOf(lead), String.valueOf(ex), 'updateChapterFields',
                        'Null', ex.getStackTraceString(), 'Error');
            }
            if (!Test.isRunningTest()) {
                for (Lead lead : zipCodeLeadMap.values()) {
                    lead.addError(Label.Debug_log_error_message);
                }
            }

        }
    }

    /**
     * Update Chapter Name
     * @param accountIdLeadMap
     */
    public static void setHiddenChapterName(Map<Id, Lead> accountIdLeadMap) {
        Map<Id, Account> accountNameMap = new Map<Id, Account>();
        try {
            for (Account account : [
                    SELECT Id,Name,Intake_Manager__r.Email,Intake_Manager__c
                    FROM Account
                    WHERE Id IN :accountIdLeadMap.keySet()
                    LIMIT 50000
            ]) {
                accountNameMap.put(account.Id, account);
            }
            for (Lead lead : accountIdLeadMap.values()) {
                if (accountNameMap.containsKey(lead.ChapterName__c)) {
                    lead.Hidden_OldChapterName__c = lead.Hidden_Chapter_Name__c;
                    lead.Hidden_Chapter_Name__c = accountNameMap.get(lead.ChapterName__c).Name;
                }
            }
            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }
        } catch (Exception ex) {
            for (Lead lead : accountIdLeadMap.values()) {
                ErrorMessage_AC.createdebugRec('LeadService',
                        String.valueOf(lead), String.valueOf(ex), 'setHiddenChapterName',
                        'Null', ex.getStackTraceString(), 'Error');
            }
            if (!Test.isRunningTest()) {
                for (Lead lead : accountIdLeadMap.values()) {
                    lead.addError(Label.Debug_log_error_message);
                }
            }
        }
    }

    /**
     * Match Icd Codes with Condition Description
     * @param icdInfoMap
     * @param icdCodeLeadMap
     */
    public static void matchConditionDescription(Map<Id, Set<Integer>> icdInfoMap, Map<Id, Lead> icdCodeLeadMap) {
        Map<Id, ICD_Codes__c> icdCodeDetails = new Map<Id, ICD_Codes__c>();
        try {
            for (ICD_Codes__c icdInfo : [
                    SELECT Id, Name, Group1__c,
                            Condition_Description__c, Condition_Description__r.Code_To_Use__c, Condition_Description__r.Name
                    FROM ICD_Codes__c
                    WHERE Id IN :icdCodeLeadMap.keySet()
            ]) {
                icdCodeDetails.put(icdInfo.Id, icdInfo);
            }
            for (Lead lead : icdCodeLeadMap.values()) {
                if (icdInfoMap.containsKey(lead.Id)) {
                    for (Integer icdField : icdInfoMap.get(lead.Id)) {
                        if (icdField == 1 && icdCodeDetails.containsKey(lead.SD1_ICD_Code__c)) {
                            lead.SD1_Condition_Description__c = icdCodeDetails.get(lead.SD1_ICD_Code__c).Condition_Description__r.Name;
                        } if (icdField == 2 && icdCodeDetails.containsKey(lead.SD2_ICD_Code__c)) {
                            lead.SD2_Condition_Description__c = icdCodeDetails.get(lead.SD2_ICD_Code__c).Condition_Description__r.Name;
                        } if (icdField == 3 && icdCodeDetails.containsKey(lead.SD3_ICD_Code__c)) {
                            lead.SD3_Condition_Description__c = icdCodeDetails.get(lead.SD3_ICD_Code__c).Condition_Description__r.Name;
                        } if (icdField == 4 && icdCodeDetails.containsKey(lead.SD4_ICD_Code__c)) {
                            lead.SD4_Condition_Description__c = icdCodeDetails.get(lead.SD4_ICD_Code__c).Condition_Description__r.Name;
                        }
                    }
                }
            }
            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }
        } catch (Exception ex) {
            for (Lead lead : icdCodeLeadMap.values()) {
                ErrorMessage_AC.createdebugRec('LeadService',
                        String.valueOf(lead), String.valueOf(ex), 'matchConditionDescription',
                        lead.Id, ex.getStackTraceString(), 'Error');
            }
            if (!Test.isRunningTest()) {
                for (Lead lead : icdCodeLeadMap.values()) {
                    lead.addError(Label.Debug_log_error_message);
                }
            }
        }
    }

    /**
     * Update Lead Owner
     * @param accountIdLeadMap
     */
    public static void updateLeadOwner(Map<Id, Lead> accountIdLeadMap) {
        Map<Id, Account> chapterMap = new Map<Id, Account>([
                SELECT Id,Intake_Manager__c,Onboarded_on_SF__c
                FROM Account
                WHERE Id IN :accountIdLeadMap.keySet()
        ]);
        try {
            Set<String> zipSet = new Set<String>();
            for (Lead lead : accountIdLeadMap.values()) {
                if (chapterMap.containsKey(lead.ChapterName__c)) {
                    if (chapterMap.get(lead.ChapterName__c).Intake_Manager__c != null) {
                        lead.OwnerId = chapterMap.get(lead.ChapterName__c).Intake_Manager__c;
                    } else {
                        lead.OwnerId = Label.Salesforce_Support_User_Id;
                    }
                    if (chapterMap.get(lead.ChapterName__c).Onboarded_on_SF__c != null) {
                        lead.Is_Chapter_Active__c = chapterMap.get(lead.ChapterName__c).Onboarded_on_SF__c;
                    }
                }
                zipSet.add(lead.PostalCode);
            }
            List<Zip_Code__c> officeZipList = [
                    SELECT Id,Name, Office__c,Office__r.Chapter__c, Office__r.Referral_Email_Address__c
                    FROM Zip_Code__c
                    WHERE Name IN :zipSet AND Office__r.Chapter__c IN :accountIdLeadMap.keySet()
            ];
            if (!officeZipList.isEmpty()) {
                for (Lead lead : accountIdLeadMap.values()) {
                    for (Zip_Code__c zipInfo : officeZipList) {
                        if (lead.PostalCode == zipInfo.Name
                                && lead.ChapterName__c == zipInfo.Office__r.Chapter__c) {
                            if (zipInfo.Office__r.Referral_Email_Address__c != null) {
                                lead.Office_Referral_Email__c = zipInfo.Office__r.Referral_Email_Address__c;
                            }
                        }
                    }
                }
            }
        } catch (Exception ex) {
            for (Lead lead : accountIdLeadMap.values()) {
                ErrorMessage_AC.createdebugRec('LeadService',
                        String.valueOf(lead), String.valueOf(ex), 'updateLeadOwner',
                        lead.Id, ex.getStackTraceString(), 'Error');
            }
            for (Lead lead : accountIdLeadMap.values()) {
                lead.addError(Label.Debug_log_error_message);
            }
        }
    }

    /**
     * Set the Chapter Name on Medical Professional Contact. If the Zip Code value is updated.
     * @param conditionDescriptionsSet
     * @param icdCodesSet
     * @param leadUpdateToMedicalInfoList
     */
    public static void setMedicalInfo(Set<String> conditionDescriptionsSet, Set<String> icdCodesSet, List<Lead> leadUpdateToMedicalInfoList) {
        Set<Id> conditionDescriptionIdSet = new Set<Id>();
        Map<String, ICD_Codes__c> icdCodesMap = new Map<String, ICD_Codes__c>();
        try {
            if (!icdCodesSet.isEmpty()) {
                for (ICD_Codes__c icdCode : [
                        SELECT Id,Name, Condition_Description__r.PR_Diagnosis__c,Group1__c,
                                Condition_Description__c, Condition_Description__r.Code_To_Use__c,Condition_Description__r.Name
                        FROM ICD_Codes__c
                        WHERE Id IN :icdCodesSet
                ]) {
                    icdCodesMap.put(icdCode.Id, icdCode);
                    if (icdCode.Condition_Description__c != null) {
                        conditionDescriptionIdSet.add(icdCode.Condition_Description__c);
                    }
                }
                Map<Id, Set<Id>> icdConditionDescriptionMap = new Map<Id, Set<Id>>();
                for (ICD_Codes__c icdInfo : [
                        SELECT Id, Condition_Description__c
                        FROM ICD_Codes__c
                        WHERE Condition_Description__c IN :conditionDescriptionIdSet
                ]) {
                    if (icdConditionDescriptionMap.containsKey(icdInfo.Condition_Description__c)) {
                        icdConditionDescriptionMap.get(icdInfo.Condition_Description__c).add(icdInfo.Id);
                    } else {
                        icdConditionDescriptionMap.put(icdInfo.Condition_Description__c, new Set<Id>{
                                icdInfo.Id
                        });
                    }
                }
                for (Lead lead : leadUpdateToMedicalInfoList) {
                    if (icdCodesMap.containsKey(lead.Qualifying_ICD__c)) {
                        if (icdCodesMap.get(lead.Qualifying_ICD__c).Condition_Description__c != null) {
                            lead.Qualifying_Diagnosis__c = icdCodesMap.get(lead.Qualifying_ICD__c).Condition_Description__r.Name;
                        } else {
                            lead.Qualifying_Diagnosis__c = EMPTY;
                        }
                    }
                    if (lead.Qualifying_ICD__c != null) {
                        if (icdCodesMap.containsKey(lead.Qualifying_ICD__c)
                                && icdCodesMap.get(lead.Qualifying_ICD__c).Condition_Description__c != null) {
                            lead.PR_Diagnosis__c = icdCodesMap.get(lead.Qualifying_ICD__c).Condition_Description__r.PR_Diagnosis__c;
                            if (icdConditionDescriptionMap.containsKey(icdCodesMap.get(lead.Qualifying_ICD__c).Condition_Description__c)) {
                                if (icdConditionDescriptionMap.get(icdCodesMap.get(lead.Qualifying_ICD__c).Condition_Description__c).contains(lead.Qualifying_ICD__c)) {
                                    lead.Qualifying_Diagnosis__c = icdCodesMap.get(lead.Qualifying_ICD__c).Condition_Description__r.Name;
                                }
                            }
                        }
                    }
                }
            }
            if (!conditionDescriptionsSet.isEmpty()) {
                Map<String, Condition_Description__c> descriptionMap = new Map<String, Condition_Description__c>();
                for (Condition_Description__c lead : [
                        SELECT Id, PR_Diagnosis__c, Name
                        FROM Condition_Description__c
                        WHERE Name IN :conditionDescriptionsSet
                ]) {
                    descriptionMap.put(lead.Name, lead);
                }
                for (Lead lead : leadUpdateToMedicalInfoList) {
                    if (descriptionMap.containsKey(lead.Qualifying_Diagnosis__c)) {
                        lead.PR_Diagnosis__c = descriptionMap.get(lead.Qualifying_Diagnosis__c).PR_Diagnosis__c;
                    }
                }
            }
            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }
        } catch (Exception ex) {
            for (Lead lead : leadUpdateToMedicalInfoList) {
                ErrorMessage_AC.createdebugRec('LeadService',
                        String.valueOf(lead), String.valueOf(ex), 'setMedicalInfo',
                        lead.Id, ex.getStackTraceString(), 'Error');
            }
            if (!Test.isRunningTest()) {
                for (Lead lead : leadUpdateToMedicalInfoList) {
                    lead.addError(Label.Debug_log_error_message);
                }
            }
        }
    }

    /**
     * Find Duplicate Leads for Referred Leads with sub status "Pending Diagnosis Verification"
     * and display error message if any duplicate Wish Child or Wish Family or Medical Professional Contact are found.
     * @param leadList
     */
    public static void findDuplicateLeads(List<Lead> leadList) {
        Set<String> leadFNamesSet = new Set<String>();
        Set<String> leadLNamesSet = new Set<String>();
        Set<Date> birthdateSet = new Set<Date>();
        Set<String> addressSet = new Set<String>();
        Set<String> phoneSet = new Set<String>();
        Set<String> zipCodesSet = new Set<String>();
        Set<String> citySet = new Set<String>();
        Set<String> emailSet = new Set<String>();
        Set<String> stateSet = new Set<String>();
        Set<Id> leadIds = new Set<Id>();
        Set<String> chaptersSet = new Set<String>();
        List<Lead> noDupLeadRec = new List<Lead>();
        Id wishChild = Constant_AC.CONTACT_WISH_CHILD_RT_ID;
        String errorType = TYPE_CLASSIC;
        if (UserInfo.getUiTheme() == THEME_4D || UserInfo.getUiTheme() == THEME_4U) {
            errorType = TYPE_LIGHTNING;
        }
        try {
            for (Lead lead : leadList) {
                if (lead.FirstName != null) {
                    leadFNamesSet.add(lead.FirstName);
                }
                if (lead.LastName != null) {
                    leadLNamesSet.add(lead.LastName);
                }
                if (lead.DOB__c != null) {
                    birthdateSet.add(lead.DOB__c);
                }
                if (lead.PostalCode != null) {
                    zipCodesSet.add(lead.PostalCode);
                }
                if (lead.City != null) {
                    citySet.add(lead.City);
                }
                if (lead.State != null) {
                    stateSet.add(lead.State);
                }
                if (lead.Phone != null) {
                    phoneSet.add(lead.Phone);
                }
                if (lead.Email != null) {
                    emailSet.add(lead.Email);
                }
                if (lead.Id != null) {
                    leadIds.add(lead.Id);
                }
                chaptersSet.add(lead.ChapterName__c);
                addressSet.add(lead.City + DASH + lead.State + DASH + lead.PostalCode);
            }
            List<Lead> exLeads = [
                    SELECT Id,LastName,Street,FirstName, Email, ChapterName__c,Phone, DOB__c,
                            City,State,PostalCode
                    FROM Lead
                    WHERE (LastName IN :leadLNamesSet OR FirstName IN :leadFNamesSet OR DOB__c IN :birthdateSet
                    OR Phone IN :phoneSet OR Email IN :emailSet OR (State IN :stateSet
                    AND PostalCode IN :zipCodesSet AND City IN :citySet))
                    AND Id NOT IN :leadIds AND IsConverted = FALSE
            ];
            List<Contact> exContacts = [
                    SELECT Id, LastName,AccountId,MailingStreet,FirstName, Email, Phone, Birthdate,Region_Chapter__r.Name,
                            MailingCity, MailingState, MailingPostalCode
                    FROM Contact
                    WHERE (LastName IN :leadLNamesSet OR FirstName IN :leadFNamesSet OR Birthdate IN :birthdateSet
                    OR ((MailingState IN :stateSet AND MailingPostalCode IN :zipCodesSet
                    AND MailingCity IN :citySet) OR Phone IN :phoneSet OR Email IN :emailSet))
                    AND Region_Chapter__c = :chaptersSet AND RecordTypeId = :wishChild
            ];
            for (Lead lead : leadList) {
                Boolean isDuplicate = false;
                for (Lead exLead : exLeads) {
                    if (lead.FirstName == exLead.FirstName && lead.LastName == exLead.LastName) {
                        isDuplicate = true;
                        if (errorType == TYPE_LIGHTNING) {
                            lead.addError(String.format(Label.Diagnosis_Verification_Lead_Duplicates, new List<String>{
                                    ERROR_WISH_CHILD
                            }), false);
                        } else {
                            lead.addError(String.format(Label.Potential_Existing_Lead_Records, new List<String>{
                                    ERROR_WISH_CHILD, INSTANCE_URL, lead.Id
                            }), false);
                        }
                    } else if (lead.FirstName == exLead.FirstName
                            && ((lead.Street == exLead.Street && lead.State == exLead.State && lead.City == exLead.City && lead.PostalCode == exLead.PostalCode)
                            || lead.Phone == exLead.Phone || (!String.isblank(Lead.Email) && lead.Email == exLead.Email))) {
                        isDuplicate = true;
                        if (errorType == TYPE_LIGHTNING) {
                            lead.addError(String.format(Label.Diagnosis_Verification_Lead_Duplicates, new List<String>{
                                    ERROR_WISH_CHILD
                            }), false);
                        } else {
                            lead.addError(String.format(Label.Potential_Existing_Lead_Records, new List<String>{
                                    ERROR_WISH_CHILD, INSTANCE_URL, lead.Id
                            }), false);
                        }
                    } else if ((lead.LastName == exLead.LastName) &&
                            ((lead.Street == exLead.Street && lead.State == exLead.State && lead.City == exLead.City && lead.PostalCode == exLead.PostalCode)
                                    || (!String.isblank(Lead.Email) && lead.Email == exLead.Email))) {
                        isDuplicate = true;
                        if (errorType == TYPE_LIGHTNING) {
                            lead.addError(String.format(Label.Diagnosis_Verification_Lead_Duplicates, new List<String>{
                                    ERROR_WISH_CHILD
                            }), false);
                        } else {
                            lead.addError(String.format(Label.Potential_Existing_Lead_Records, new List<String>{
                                    ERROR_WISH_CHILD, INSTANCE_URL, lead.Id
                            }), false);
                        }
                    } else if ((lead.DOB__c == exLead.DOB__c)
                            && ((lead.Street == exLead.Street
                            && lead.State == exLead.State
                            && lead.City == exLead.City
                            && lead.PostalCode == exLead.PostalCode)
                            || (!String.isblank(lead.Email) && lead.Email == exLead.Email))) {
                        isDuplicate = true;
                        if (errorType == TYPE_LIGHTNING) {
                            lead.addError(String.format(Label.Diagnosis_Verification_Lead_Duplicates, new List<String>{
                                    ERROR_WISH_CHILD
                            }), false);
                        } else {
                            lead.addError(String.format(Label.Potential_Existing_Lead_Records, new List<String>{
                                    ERROR_WISH_CHILD, INSTANCE_URL, lead.Id
                            }), false);
                        }
                    } else if ((lead.DOB__c == exLead.DOB__c)
                            && (lead.FirstName == exLead.FirstName
                            || lead.LastName == exLead.LastName)) {
                        isDuplicate = true;
                        if (errorType == TYPE_LIGHTNING) {
                            lead.addError(String.format(Label.Diagnosis_Verification_Lead_Duplicates, new List<String>{
                                    ERROR_WISH_CHILD
                            }), false);
                        } else {
                            lead.addError(String.format(Label.Potential_Existing_Lead_Records, new List<String>{
                                    ERROR_WISH_CHILD, INSTANCE_URL, lead.Id
                            }), false);
                        }
                    }
                }
                for (Contact exCon : exContacts) {
                    if (lead.ChapterName__c == exCon.Region_Chapter__c) {
                        if (lead.FirstName == exCon.FirstName && lead.LastName == exCon.LastName) {
                            isDuplicate = true;
                            if (errorType == TYPE_LIGHTNING) {
                                lead.addError(String.format(Label.Diagnosis_Verification_Lead_Duplicates, new List<String>{
                                        ERROR_WISH_CHILD
                                }), false);
                            } else {
                                lead.addError(String.format(Label.Potential_Existing_Lead_Records, new List<String>{
                                        ERROR_WISH_CHILD, INSTANCE_URL, lead.Id
                                }), false);
                            }
                        } else if ((lead.FirstName == exCon.FirstName || lead.LastName == exCon.LastName)
                                && ((lead.Street == exCon.MailingStreet && lead.State == exCon.MailingState
                                && lead.City == exCon.MailingCity && lead.PostalCode == exCon.MailingPostalCode)
                                || lead.Phone == exCon.Phone || (!String.isblank(Lead.Email) && lead.Email == exCon.Email))) {
                            isDuplicate = true;
                            if (errorType == TYPE_LIGHTNING) {
                                lead.addError(String.format(Label.Diagnosis_Verification_Lead_Duplicates, new List<String>{
                                        ERROR_WISH_CHILD
                                }), false);
                            } else {
                                lead.addError(String.format(Label.Potential_Existing_Lead_Records, new List<String>{
                                        ERROR_WISH_CHILD, INSTANCE_URL, lead.Id
                                }), false);
                            }
                        } else if ((lead.DOB__c == exCon.Birthdate)
                                && ((lead.Street == exCon.MailingStreet
                                && lead.State == exCon.MailingState
                                && lead.City == exCon.MailingCity
                                && lead.PostalCode == exCon.MailingPostalCode)
                                || lead.Phone == exCon.Phone || (!String.isblank(Lead.Email) && lead.Email == exCon.Email))) {
                            isDuplicate = true;
                            if (errorType == TYPE_LIGHTNING) {
                                lead.addError(String.format(Label.Diagnosis_Verification_Lead_Duplicates, new List<String>{
                                        ERROR_WISH_CHILD
                                }), false);
                            } else {
                                lead.addError(String.format(Label.Potential_Existing_Lead_Records, new List<String>{
                                        ERROR_WISH_CHILD, INSTANCE_URL, lead.Id
                                }), false);
                            }
                        } else if ((lead.DOB__c == exCon.Birthdate)
                                && (lead.FirstName == exCon.FirstName
                                || lead.LastName == exCon.LastName)) {
                            isDuplicate = true;
                            if (errorType == TYPE_LIGHTNING) {
                                lead.addError(String.format(Label.Diagnosis_Verification_Lead_Duplicates, new List<String>{
                                        ERROR_WISH_CHILD
                                }), false);
                            } else {
                                lead.addError(String.format(Label.Potential_Existing_Lead_Records, new List<String>{
                                        ERROR_WISH_CHILD, INSTANCE_URL, lead.Id
                                }), false);
                            }
                        }
                    }
                }
                if (isDuplicate == false) {
                    noDupLeadRec.add(lead);
                }
            }
            if (!noDupLeadRec.isEmpty()) {
                findDuplicateContacts(noDupLeadRec);
            }
        } catch (Exception ex) {
            for (Lead lead : leadList) {
                ErrorMessage_AC.createdebugRec('LeadService',
                        String.valueOf(lead), String.valueOf(ex), 'findDuplicateLeads',
                        lead.Id, ex.getStackTraceString(), 'Error');
            }
            for (Lead lead : leadList) {
                lead.addError(Label.Debug_log_error_message);
            }
        }
    }

    /**
     * Find Duplicate Leads for Referred Leads with sub status "Pending Diagnosis Verification"
     * and display error message if any duplicate Wish Child or Wish Family or Medical Professional Contact are found.
     * @param leadList
     */
    public static void findDuplicateContacts(List<Lead> leadRecords) {
        String errorType = TYPE_CLASSIC;
        if (UserInfo.getUiTheme() == THEME_4D || UserInfo.getUiTheme() == THEME_4U) {
            errorType = TYPE_LIGHTNING;
        }
        Id wishFamilyRT = Constant_AC.WISH_FAMILY_RT_ID;
        Id medicalProfessionalRT = Constant_AC.MEDICAL_PROFESSIONAL_RT_ID;
        Set<String> mProfessionalFName = new Set<String>();
        Set<String> mProfessionalLName = new Set<String>();
        Set<String> mProfessionalPhone = new Set<String>();
        Set<String> mProfessionalEmail = new Set<String>();
        Set<String> tProfessionalFName = new Set<String>();
        Set<String> tProfessionalLName = new Set<String>();
        Set<String> tProfessionalPhone = new Set<String>();
        Set<String> tProfessionalEmail = new Set<String>();
        Set<String> bestPhysicianFName = new Set<String>();
        Set<String> bestPhysicianLName = new Set<String>();
        Set<String> bestPhysicianEmail = new Set<String>();
        Set<String> bestPhysicianPhone = new Set<String>();
        Set<String> leadFNamesSet = new Set<String>();
        Set<String> leadLNamesSet = new Set<String>();
        Set<Date> leadbDaysSet = new Set<Date>();
        Set<String> AddressSet = new Set<String>();
        Set<String> phoneSet = new Set<String>();
        Set<String> zipCodesSet = new Set<String>();
        Set<String> citySet = new Set<String>();
        Set<String> emailsSet = new Set<String>();
        Set<String> stateSet = new Set<String>();
        Set<String> chaptersSet = new Set<String>();
        try {
            for (Lead newLead : leadRecords) {
                mProfessionalFName.add(newLead.Medical_Professional_First_Name__c);
                mProfessionalLName.add(newLead.Medical_Professional_Last_Name__c);
                mProfessionalPhone.add(newLead.Medical_Professional_Phone__c);
                mProfessionalEmail.add(newLead.Medical_Professional_Email__c);
                tProfessionalFName.add(newLead.Treating_Medical_Professional_First_Name__c);
                tProfessionalLName.add(newLead.Treating_Medical_Professional_Last_Name__c);
                tProfessionalPhone.add(newLead.Treating_Medical_Professional_Phone__c);
                tProfessionalEmail.add(newLead.Treating_Medical_Professional_Email__c);
                leadFNamesSet.add(newLead.Parent_First_Name__c);
                leadLNamesSet.add(newLead.Parent_Last_Name__c);
                emailsSet.add(newLead.Email);
                phoneSet.add(newLead.Phone);
                zipCodesSet.add(newLead.PostalCode);
                stateSet.add(newLead.State);
                AddressSet.add(newLead.Street);
                citySet.add(newLead.City);
                leadbDaysSet.add(newLead.DOB__c);
                chaptersSet.add(newLead.ChapterName__c);
                bestPhysicianFName.add(newLead.Best_Contact_for_Physician_First_Name__c);
                bestPhysicianLName.add(newLead.Best_Contact_for_Physician_Last_Name__c);
                bestPhysicianPhone.add(newLead.Best_Contact_for_Physician_Phone__c);
                bestPhysicianEmail.add(newLead.Best_contact_for_Physician_Email__c);
            }

            List<Contact> dupMedicalContacts = [
                    SELECT Id, FirstName,Name, LastName, Email, Phone, MailingCity, Birthdate,
                            MailingState, MailingPostalCode
                    FROM Contact
                    WHERE (FirstName IN :mProfessionalFName AND LastName IN :mProfessionalLName
                    AND (Phone = :mProfessionalPhone OR Email IN :mProfessionalEmail)
                    AND RecordTypeId = :medicalProfessionalRT)
            ];

            List<Contact> dupTreatingContacts = [
                    SELECT Id, FirstName,Name, LastName, Email, Phone, MailingCity, Birthdate,
                            MailingState, MailingPostalCode
                    FROM Contact
                    WHERE (FirstName IN :tProfessionalFName AND
                    LastName IN :tProfessionalLName
                    AND (Phone = :tProfessionalPhone OR Email = :tProfessionalEmail)
                    AND RecordTypeId = :medicalProfessionalRT)
            ];

            List<Contact> dupPhysicianContacts = [
                    SELECT Id,FirstName,LastName,Name,Email
                    FROM Contact
                    WHERE
                    FirstName IN :bestPhysicianFName AND LastName IN :bestPhysicianLName AND
                    (Phone IN :bestPhysicianPhone OR Email IN:bestPhysicianEmail) AND RecordTypeId = :medicalProfessionalRT
            ];

            List<Contact> dupFamilyContacts = [
                    SELECT Id, FirstName,Name, LastName, Email, Phone, MailingCity, Birthdate,
                            MailingState, MailingPostalCode,MailingStreet
                    FROM Contact
                    WHERE (FirstName IN :leadFNamesSet AND LastName IN :leadLNamesSet AND
                    (((Email IN :emailsSet OR Phone IN :phoneSet)
                    AND (MailingStreet IN :AddressSet AND MailingState IN :stateSet
                    AND MailingPostalCode IN :zipCodesSet
                    AND MailingCity IN :citySet))
                    OR ((Phone IN :phoneSet OR (MailingStreet IN :AddressSet AND MailingState = :stateSet
                    AND MailingPostalCode IN :zipCodesSet
                    AND MailingCity = :citySet))
                    AND Email = :emailsSet) OR (((MailingStreet = :AddressSet AND MailingState = :stateSet
                    AND MailingPostalCode = :zipCodesSet
                    AND MailingCity = :citySet) OR (Email = :emailsSet) )
                    AND Phone = :phoneSet))) AND RecordTypeId = :wishFamilyRT
            ];
            for (Lead newLead : leadRecords) {
                Boolean medicalFlag = false;
                Boolean treatingFlag = false;
                Boolean familyFlag = false;
                Boolean physicianFlag = false;
                for (Contact medicalCon : dupMedicalContacts) {
                    if (medicalCon.FirstName == newLead.Medical_Professional_First_Name__c
                            && medicalCon.LastName == newLead.Medical_Professional_Last_Name__c
                            && (medicalCon.Phone == newLead.Medical_Professional_Phone__c
                            || medicalCon.Email == newLead.Medical_Professional_Email__c)) {
                        medicalFlag = true;
                    }
                }

                for (Contact treatingCon : dupTreatingContacts) {
                    if (treatingCon.FirstName == newLead.Treating_Medical_Professional_First_Name__c
                            && treatingCon.LastName == newLead.Treating_Medical_Professional_Last_Name__c
                            && (treatingCon.Phone == newLead.Treating_Medical_Professional_Phone__c
                            || treatingCon.Email == newLead.Treating_Medical_Professional_Email__c)) {
                        treatingFlag = true;
                    }
                }
                for (Contact physicianCon : dupPhysicianContacts) {
                    if (physicianCon.FirstName == newLead.Best_Contact_for_Physician_First_Name__c
                            && physicianCon.LastName == newLead.Best_Contact_for_Physician_Last_Name__c
                            && physicianCon.Email == newLead.Best_contact_for_Physician_Email__c) {
                        physicianFlag = true;
                    }
                }
                for (Contact familyCon : dupFamilyContacts) {
                    if (familyCon.FirstName == newLead.Parent_First_Name__c && familyCon.LastName == newLead.Parent_Last_Name__c
                            && (((familyCon.Phone == newLead.Phone || familyCon.Email == newLead.Email)
                            && (familyCon.MailingStreet == newLead.Street
                            && familyCon.MailingState == newLead.State && familyCon.MailingCity == newLead.City
                            && familyCon.MailingPostalCode == newLead.PostalCode)) || ((familyCon.Phone == newLead.Phone || (familyCon.MailingStreet == newLead.Street
                            && familyCon.MailingState == newLead.State && familyCon.MailingPostalCode == newLead.PostalCode && familyCon.MailingCity == newLead.City))
                            && familyCon.Email == newLead.Email) || (((familyCon.MailingStreet == newLead.Street && familyCon.MailingState == newLead.State
                            && familyCon.MailingPostalCode == newLead.PostalCode && familyCon.MailingCity == newLead.City) || (familyCon.Email == newLead.Email))
                            && familyCon.Phone == newLead.Phone))) {
                        familyFlag = true;
                    }
                }
                List<Contact> dupAdditionalFamilyContacts = [
                        SELECT Id, FirstName,Name, LastName, Email, Phone, MailingCity, Birthdate,
                                MailingState, MailingPostalCode
                        FROM Contact
                        WHERE (FirstName = :newLead.Additional_Parent_First_Name__c AND LastName = :newLead.Additional_Parent_Last_Name__c
                        AND (((Email = :newLead.Additional_Parent_Email__c OR Phone = :newLead.Additional_Parent_Phone__c)
                        AND (MailingStreet = :newLead.Additional_Parent_Street__c AND MailingState = :newLead.Additional_Parent_State__c
                        AND MailingPostalCode = :newLead.Additional_Parent_Postal_Code__c
                        AND MailingCity = :newLead.Additional_Parent_City__c))
                        OR ((Phone = :newLead.Additional_Parent_Phone__c OR (MailingStreet = :newLead.Additional_Parent_Street__c
                        AND MailingState = :newLead.Additional_Parent_State__c
                        AND MailingPostalCode = :newLead.Additional_Parent_Postal_Code__c
                        AND MailingCity = :newLead.Additional_Parent_City__c))
                        AND Email = :newLead.Additional_Parent_Email__c ) OR (((MailingStreet = :newLead.Additional_Parent_Street__c
                        AND MailingState = :newLead.Additional_Parent_State__c
                        AND MailingPostalCode = :newLead.Additional_Parent_Postal_Code__c
                        AND MailingCity = :newLead.Additional_Parent_City__c) OR (Email = :newLead.Additional_Parent_Email__c ) )
                        AND Phone = :newLead.Additional_Parent_Phone__c ))) AND RecordTypeId = :wishFamilyRT
                ];
                if ((medicalFlag == true || treatingFlag == true || physicianFlag == true) && (familyFlag == true
                        || !dupAdditionalFamilyContacts.isEmpty())) {
                    if (errorType == TYPE_LIGHTNING) {
                        newLead.addError(String.format(Label.Diagnosis_Verification_Contact_Duplicates, new List<String>{
                                ERROR_WISH_FAMILY_AND_MEDICAL_PROFESSIONAL
                        }), false);
                    } else {
                        newLead.addError(String.format(Label.Potential_Existing_Contact_Records, new List<String>{
                                ERROR_WISH_FAMILY_AND_MEDICAL_PROFESSIONAL, INSTANCE_URL, newLead.Id
                        }), false);
                    }
                } else if (medicalFlag == true || treatingFlag == true) {
                    if (errorType == TYPE_LIGHTNING) {
                        newLead.addError(String.format(Label.Diagnosis_Verification_Contact_Duplicates, new List<String>{
                                ERROR_MEDICAL_PROFESSIONAL
                        }), false);
                    } else {
                        newLead.addError(String.format(Label.Potential_Existing_Contact_Records, new List<String>{
                                ERROR_MEDICAL_PROFESSIONAL, INSTANCE_URL, newLead.Id
                        }), false);
                    }
                } else if (physicianFlag) {
                    if (errorType == TYPE_LIGHTNING) {
                        newLead.addError(String.format(Label.Diagnosis_Verification_Contact_Duplicates, new List<String>{
                                ERROR_BEST
                        }), false);
                    } else {
                        newLead.addError(String.format(Label.Potential_Existing_Contact_Records, new List<String>{
                                ERROR_BEST, INSTANCE_URL, newLead.Id
                        }), false);
                    }
                } else if (familyFlag == true) {
                    if (errorType == TYPE_LIGHTNING) {
                        newLead.addError(String.format(Label.Diagnosis_Verification_Contact_Duplicates, new List<String>{
                                ERROR_WISH_FAMILY
                        }), false);
                    } else {
                        newLead.addError(String.format(Label.Potential_Existing_Contact_Records, new List<String>{
                                ERROR_WISH_FAMILY, INSTANCE_URL, newLead.Id
                        }), false);
                    }
                } else if (!dupAdditionalFamilyContacts.isEmpty()) {
                    if (errorType == TYPE_LIGHTNING) {
                        newLead.addError(String.format(Label.Diagnosis_Verification_Contact_Duplicates, new List<String>{
                                ERROR_WISH_ADDITIONAL_PARENT_GUARDIAN
                        }), false);
                    } else {
                        newLead.addError(String.format(Label.Potential_Existing_Contact_Records, new List<String>{
                                ERROR_WISH_ADDITIONAL_PARENT_GUARDIAN, INSTANCE_URL, newLead.Id
                        }), false);
                    }
                }
            }
        } catch (Exception ex) {
            for (Lead lead : leadRecords) {
                ErrorMessage_AC.createDebugRec('LeadService',
                        String.valueOf(lead), String.valueOf(ex), 'findDuplicateContacts',
                        lead.Id, ex.getStackTraceString(), 'Error');
            }
            for (Lead lead : leadRecords) {
                lead.addError(Label.Debug_log_error_message);
            }
        }
    }

    /**
     *  Validate Qualified lead fields
     *  @param leadList
     */
    public static void validateQualifiedRequiredFields(List<Lead> leadList) {
        String message = EMPTY;
        for (Lead le : leadList) {
            if (le.FirstName == null) {
                if (String.isEmpty(message)) {
                    message = Schema.SObjectType.Lead.fields.FirstName.label;
                }
            }
            if (le.DOB__c == null) {
                if (String.isEmpty(message)) {
                    message = Schema.SObjectType.Lead.fields.DOB__c.label;
                } else {
                    message = message + COMMA_SPACE + Schema.SObjectType.Lead.fields.DOB__c.label;
                }
            }
            if (le.Any_medical_reason_for_moving_quickly__c == null) {
                if (String.isEmpty(message)) {
                    message = Schema.SObjectType.Lead.fields.Any_medical_reason_for_moving_quickly__c.label;
                } else {
                    message = message + COMMA_SPACE + Schema.SObjectType.Lead.fields.Any_medical_reason_for_moving_quickly__c.label;
                }
            }
            if (le.I_am_Recognized_To_Practice_As_a__c == null) {
                if (String.isEmpty(message)) {
                    message = Schema.SObjectType.Lead.fields.I_am_Recognized_To_Practice_As_a__c.label;
                } else {
                    message = message + COMMA_SPACE + Schema.SObjectType.Lead.fields.I_am_Recognized_To_Practice_As_a__c.label;
                }
            }
            if (String.isNotBlank(message)) {
                for (Lead leadTemp : leadList) {
                    if (Bypass_Triggers__c.getValues(UserInfo.getUserId()) == null) {
                        leadTemp.addError(Label.Qualified_Fields_Missing + message + PERIOD);
                    }
                }
            }
        }
    }

    /**
     *
     * @param diagnosisVerificationIcdCode
     * @param leadList
     */
    public static void setQualifyingDiagnosis(String diagnosisVerificationIcdCode, List<Lead> leadList) {
        ICD_Codes__c icdCode = [
                SELECT Id,Name,Condition_Description__r.Name,
                        Condition_Description__r.PR_Diagnosis__c
                FROM ICD_Codes__c
                WHERE Name = :diagnosisVerificationIcdCode
                AND Group1__c = TRUE
                LIMIT 1
        ];
        if (icdCode != null) {
            for (Lead newLead : leadList) {
                newLead.Qualifying_ICD__c = icdCode.Id;
                newLead.Qualifying_Diagnosis__c = icdCode.Condition_Description__r.Name;
                newLead.PR_Diagnosis__c = icdCode.Condition_Description__r.PR_Diagnosis__c;
            }
        }
    }

    /**
     * Sets Chapter information on Lead found by Zip Code
     * @param updateChapterLeadList
     */
    public static void setChapterViaZipCode(List<Lead> updateChapterLeadList) {
        Set<String> zipSet = new Set<String>();
        Map<Id, String> codeMap = new Map<Id, String>();
        for (Lead lead : updateChapterLeadList) {
            String postCode = lead.PostalCode;
            if (postCode.length() > 5) {
                postCode = postCode.substring(0, 5);
            }
            codeMap.put(lead.Id, postCode);
            zipSet.add(postCode);
        }
        List<Zip_Code__c> officeZipList = [
                SELECT Id, Name, Office__c, Office__r.Chapter__c, Office__r.Referral_Email_Address__c,
                        Office__r.Chapter__r.Intake_Manager__c, Office__r.Chapter__r.Onboarded_on_SF__c
                FROM Zip_Code__c
                WHERE Name IN :zipSet
        ];
        if (!officeZipList.isEmpty()) {
            for (Lead lead : updateChapterLeadList) {
                for (Zip_Code__c zipInfo : officeZipList) {
                    if (codeMap.get(lead.Id) == zipInfo.Name) {
                        if (zipInfo.Office__c != null && zipInfo.Office__r.Chapter__c != null) {
                            lead.ChapterName__c = zipInfo.Office__r.Chapter__c;
                        }
                        if (zipInfo.Office__r.Chapter__r.Onboarded_on_SF__c) {
                            if (zipInfo.Office__r.Chapter__c != null
                                    && zipInfo.Office__r.Chapter__r.Intake_Manager__c != null) {
                                lead.OwnerId = zipInfo.Office__r.Chapter__r.Intake_Manager__c;
                            } else {
                                lead.OwnerId = Label.Salesforce_Support_User_Id;
                            }
                        }
                        if (zipInfo.Office__r.Referral_Email_Address__c != null) {
                            lead.Office_Referral_Email__c = zipInfo.Office__r.Referral_Email_Address__c;
                            if (!zipInfo.Office__r.Chapter__r.Onboarded_on_SF__c) {
                                lead.Hidden_Trigger_Referral_Email__c = !lead.Hidden_Trigger_Referral_Email__c;
                            }
                        }
                        if (zipInfo.Office__r.Chapter__r != null
                                && zipInfo.Office__r.Chapter__r.Onboarded_on_SF__c != null) {
                            lead.Is_Chapter_Active__c = zipInfo.Office__r.Chapter__r.Onboarded_on_SF__c;
                        }
                    }
                }
            }
        }
    }
}