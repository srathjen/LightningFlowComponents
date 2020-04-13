/*****************************************************************************************************************
Author      : MST Solutions
Date        : 10/4/2016
Description : This form is for Medical Professionals to fill up the Medical Summary Reports about the Wish child
              whom they are treating.
Modification Log:
              WVC-1835 : Sankar
              10/05/2018 - Yuvraj - IME-126 - Line No: 981,994,998,1066
              07/30/2019 - Samer  - SIW-235 - Fixed bug related to Primary Diagnosis and Secondary Condition
                           Descriptions 1-4 not populating when MP fills the form, save, then come back later to
                           sign the DV.
                           Modification Log:
              09/10/2019 - Manik - WLP-4232
              01/02/2020 - CSmith - SIW-342 All changes reverted.
1. 01/09/2020 - Manoj      - SIW-287 : Mapped newly created fields to insert values in lead records upon submission of DV form.
2. 04/02/2020 - Manoj      - SIW-379 : Mapped 'Travel_Restriction__c' field in lead records based on user selection.
3 .09/04/2020 - Manoj      - SIW-355 : Mapped 2 Wrapper fields values with lead fields value - timeFrameValue, idealtimeFrameValue
*******************************************************************************************************************/
public class DiagnosisVerification_AC {

    private Integer diagnosisBlockNum;
    private String leadId, icdOrPcd, medicalResponse;
    private Set<String> uniqueCurrentConditionSet;
    private List<Diagnosis_Verification__c> diagnosisVerificationLst;
    private Map<String, String> travelVal, travelLabel, travelAlgorithmMap;

    private transient Map<String, String> travelMap;
    private transient Map<Id, Medical_Questions__c> medicalQuestionMap;
    private transient Map<String, List<Medical_Questions__c>> condDesMedicalQuestionMap;

    public String pluHypTxt { get; set; }
    public String wishStatus { get; set; }
    public String otherDiagnosisBlock { get; set; }
    public Boolean showAddAnotherDiagnosisBtn { get; set; }
    public Lead currLead { get; set; }
    public DiagnosisWrapper wrapCls { get; set; }
    public WishChildWrapper wishChildWrapperIns { get; set; }
    public TravelAlgorithmWrapper travelAlgorithmWrapperIns { get; set; }
    public List<DiagnosisWrapper> diagnosisVerificationWrapperLst { get; set; }

    private static final List<Medical_Questions__c> ALL_MEDICAL_QUESTIONS =
        DiagnosisVerification_AC_Helper.getMedicalQuestions();
    private static final Map<String,List<Medical_Questions__c>> MAP_OF_MEDICAL_QUESTIONS_BY_DESCRIPTION =
        DiagnosisVerification_AC_Helper.createMapOfMedicalQuestionsByDescription(ALL_MEDICAL_QUESTIONS);
    private static final List<Condition_Description__c> ALL_CONDITION_DESCRIPTIONS =
        DiagnosisVerification_AC_Helper.getConditionDescriptionInfo();
    private static final List<Condition_Description__c> DEFAULT_CONDITION_DESCRIPTIONS =
        DiagnosisVerification_AC_Helper.createListOfDefaultDescriptions(ALL_CONDITION_DESCRIPTIONS);
    private static final Map<String,List<Condition_Description__c>> MAP_OF_CONDITION_DESCRIPTIONS_BY_NAME =
        DiagnosisVerification_AC_Helper.createMapOfConditionDescriptionsByName(ALL_CONDITION_DESCRIPTIONS);
    private static final Map<Id,Condition_Description__c> MAP_OF_CONDITION_DESCRIPTIONS_BY_ID =
        new Map<Id,Condition_Description__c>(ALL_CONDITION_DESCRIPTIONS);

    public DiagnosisVerification_AC() {
        pluHypTxt = '';
        wishChildWrapperIns = new WishChildWrapper();
        uniqueCurrentConditionSet = new Set<String>();
        wishChildWrapperIns.login = false;
        wishStatus = null;
        wrapCls = new DiagnosisWrapper();
        currLead = new Lead();
        leadId = ApexPages.currentPage().getParameters().get('leadId');

        if (leadId != null && leadId.length() > 0) {
            loadData();
        }
    }

    /*
     * @description     Fill in Child Information, Medical Professional Information & Diagnosis Information
     *                  when the form is loaded.
     *
     * @author          unknown
     * @date            unknown
     */
    public void loadData() {
        medicalQuestionMap = new Map<Id, Medical_Questions__c>();
        condDesMedicalQuestionMap = new Map<String, List<Medical_Questions__c>>();
        diagnosisVerificationWrapperLst = new List<DiagnosisWrapper>();
        travelAlgorithmWrapperIns = new TravelAlgorithmWrapper();
        travelAlgorithmWrapperIns.travelAgroithmList = new List<String>();
        travelVal = new Map<String, String>();
        travelLabel = new Map<String, String>();
        travelMap = new Map<String, String>();
        travelAlgorithmMap = new Map<String, String>();
        travelAlgorithmWrapperIns.travelSet = new Set<String>();

        currLead = getCurrLead(leadId);

        wishChildWrapperIns.additionalInfo = currLead.Provided_additional_information__c;
        currLead.Current_Condition_Label__c = currLead.Travel_algorithm__c;
        wishChildWrapperIns.medProfTypeHid = currLead.Hidden_DV_form_Medical_professional_Type__c;
        wishChildWrapperIns.stillEligibile = currLead.Why_do_you_feel_would_be_eligible_Wish__c;
        wishChildWrapperIns.treatingFName = currLead.Treating_Medical_Professional_First_Name__c;
        wishChildWrapperIns.treatingLName = currLead.Treating_Medical_Professional_Last_Name__c;
        wishChildWrapperIns.treatingPhone = currLead.Treating_Medical_Professional_Phone__c;
        wishChildWrapperIns.treatingEmail = currLead.Treating_Medical_Professional_Email__c;
        wishChildWrapperIns.treatingHospital = currLead.Hospital_Treatment_Facility_Treating__c;
        wishStatus = currLead.RFI_Form_Info_Hidden__c;
        wishChildWrapperIns.recognizationPickValSelected = currLead.I_am_Recognized_To_Practice_As_a__c;
        wishChildWrapperIns.healthCareWork = currLead.I_m_Part_of_The_Treating_HealthCare_Team__c;
        wishChildWrapperIns.vegetativeState = currLead.Is_in_a_Comatose_Vegetative_State__c;
        wishChildWrapperIns.explainDeteriorate = currLead.Please_Explain_Deteriorate__c;
        wishChildWrapperIns.expediteTheProcess = currLead.Any_medical_reason_for_moving_quickly__c;//Added as per IME-107
        wishChildWrapperIns.conditioDeteriorate = currLead.Will_Child_s_Condition_Deteriorate__c;
        wishChildWrapperIns.wishChildEligibilityNotes = currLead.Why_do_you_feel_would_be_eligible_Wish__c;
        wishChildWrapperIns.plzExplain = currLead.Please_Explain__c;
        wishChildWrapperIns.bestPhyFname = currLead.Best_Contact_for_Physician_First_Name__c;
        wishChildWrapperIns.bestPhyLname = currLead.Best_Contact_for_Physician_Last_Name__c;
        wishChildWrapperIns.bestPhyEmail = currLead.Best_contact_for_Physician_Email__c;
        wishChildWrapperIns.alt1MedFname = currLead.Alternate1MedProfessionalFirstName__c;
        wishChildWrapperIns.alt1MedLname = currLead.Alternate1MedProfessionalLastName__c;
        wishChildWrapperIns.alt1MedEmail = currLead.Alternate1MedicalProfessionalEmail__c;
        wishChildWrapperIns.alt1MedPhone = currLead.Alternate1MedProfessionalPhone__c;
        wishChildWrapperIns.alt1MedHosp = currLead.Alternate1HospitalTreatmentFacility__c;
        wishChildWrapperIns.alt2MedFname = currLead.Alternate2MedProfessionalFirstName__c;
        wishChildWrapperIns.alt2MedLname = currLead.Alternate2MedProfessionalLastName__c;
        wishChildWrapperIns.alt2MedEmail = currLead.Alternate2MedProfessionalEmail__c;
        wishChildWrapperIns.alt2MedPhone = currLead.Alternate2MedProfessionalPhone__c;
        wishChildWrapperIns.alt2MedHosp = currLead.Alternate2HospitalTreatmentFacility__c;
        wishChildWrapperIns.unplannedHospitalAdmission = currLead.Unplanned_hospital_admissions__c;
        wishChildWrapperIns.numberOfHospitalAdmission =  Integer.valueOf(currLead.Number_hospital_admissions__c);
        wishChildWrapperIns.admittingDiagnosis = currLead.Admitting_diagnosis__c;
        wishChildWrapperIns.ifICUAdmission = currLead.ICU_Admissions__c;
        //SIW-355 Start : Mapped 2 new added questions value to lead field on loading of page
        wishChildWrapperIns.timeFrameValue = currLead.Expedite_timeframe__c;
        wishChildWrapperIns.idealtimeFrameValue = currLead.Other_expedite_timeframe_comments__c;
        //SIW-355 End

        if (currLead.Child_will_ultimately_die_prematurely__c == true) {
            wishChildWrapperIns.describePatient = '1';
        } else if (currLead.Treatment_may_be_feasible_but_can_fail__c == true) {
            wishChildWrapperIns.describePatient = '2';
        } else if (currLead.Treatment_may_prolong_normal_activities__c == true) {
            wishChildWrapperIns.describePatient = '3';
        } else if (currLead.Debilitation_may_extend_over_many_years__c == true) {
            wishChildWrapperIns.describePatient = '4';
        } else if (currLead.Increased_probability_of_premature_death__c == true) {
            wishChildWrapperIns.describePatient = '5';
        } else if (currLead.Risk_of_complications_premature_death__c == true) {
            wishChildWrapperIns.describePatient = '6';
        } else if (currLead.Responds_to_treatment_with_normal_health__c == true) {
            wishChildWrapperIns.describePatient = '7';
        } else if (currLead.None_of_these_statements_describes_Child__c == true) {
            wishChildWrapperIns.describePatient = '8';
        }

        if (currLead.Communication__c != null || String.isNotBlank(currLead.Communication__c)) {
            for (String com : currLead.Communication__c.split(';')) {
                wishChildWrapperIns.communicationList.add(com);
            }
        }

        for (Medical_Questions__c medicalQuestion : ALL_MEDICAL_QUESTIONS) {
            if (medicalQuestion.Question__c != null) {
                medicalQuestion.Question__c = medicalQuestion.Question__c.replace('[child\'s name]', ' ' + currLead.FirstName + ' ' + currLead.LastName).replace(' (child\'s name) ', currLead.FirstName + ' ' + currLead.LastName).replace('[Insert child\'s name]', currLead.FirstName + ' ' + currLead.LastName);
            } else {
                travelAlgorithmMap.put(medicalQuestion.Current_Condition__c, medicalQuestion.Recommendation_to_Chapter__c);
            }
            medicalQuestionMap.put(medicalQuestion.Id, medicalQuestion);
            if (medicalQuestion.Condition_Description__c != null) {
                if (condDesMedicalQuestionMap.containsKey(medicalQuestion.Condition_Description__c)) {
                    condDesMedicalQuestionMap.get(medicalQuestion.Condition_Description__c).add(medicalQuestion);
                } else {
                    condDesMedicalQuestionMap.put(medicalQuestion.Condition_Description__c, new List<Medical_Questions__c>{
                        medicalQuestion
                    });
                }
            }
        }

        diagnosisVerificationLst = DiagnosisVerification_AC_Helper.getDiagnosisVerifications((Id) leadId);

        if (diagnosisVerificationLst.size() > 0) {
            for (Diagnosis_Verification__c buildWrapper : diagnosisVerificationLst) {
                DiagnosisWrapper diagonsisWrapper = new DiagnosisWrapper();
                diagonsisWrapper.icdCode = buildWrapper.ICD_Code__c;
                diagonsisWrapper.pcdOrIcd = buildWrapper.PCD_ICD__c;
                diagonsisWrapper.isGroup1Rec = buildWrapper.Group1__c;
                if (buildWrapper.PCD_ICD__c == 'ICD') {
                    diagonsisWrapper.valueSelectedICD = 'value-selected';
                } else if (buildWrapper.PCD_ICD__c == 'PCD') {
                    diagonsisWrapper.valueSelectedPCD = 'value-selected';
                }
                diagonsisWrapper.shortDescription = buildWrapper.Short_Description__c;
                diagonsisWrapper.isEligible = buildWrapper.isEligible__c;
                diagonsisWrapper.conditionDescription = (String) buildWrapper.Condition_Description__r.Name;
                diagonsisWrapper.conditionDescriptionObject = (String) buildWrapper.Condition_Description__c;

                Map<Id, DiagnosisMedicalQuestions__c> diagnosisQuestionMap = new Map<Id, DiagnosisMedicalQuestions__c>();
                if (buildWrapper.DiagnosisMedicalQuestions__r.size() > 0) {
                    for (DiagnosisMedicalQuestions__c currDiagnosisMedicalQuestion : buildWrapper.DiagnosisMedicalQuestions__r) {
                        diagnosisQuestionMap.put(currDiagnosisMedicalQuestion.Medical_Question__c, currDiagnosisMedicalQuestion);
                    }
                }

                if (condDesMedicalQuestionMap.containsKey(buildWrapper.Condition_Description__c)) {
                    for (Medical_Questions__c currMedicalQuestion : condDesMedicalQuestionMap.get(buildWrapper.Condition_Description__c)) {
                        DiagnosisWrapper.MedicalWrapper medicalWrapperItem = new DiagnosisWrapper.MedicalWrapper();
                        medicalWrapperItem.medicalQuestion = currMedicalQuestion;
                        if (diagnosisQuestionMap.containsKey(currMedicalQuestion.Id)) {
                            medicalWrapperItem.isEligible = diagnosisQuestionMap.get(currMedicalQuestion.Id).isEligible__c;
                        }

                        if (currMedicalQuestion.Picklist_values__c != null) {
                            List<SelectOption> pickVals = new List<SelectOption>();
                            pickVals.add(new SelectOption('', 'Please Select'));
                            for (String currString : currMedicalQuestion.Picklist_values__c.split(',')) {
                                pickVals.add(new SelectOption(currString, currString));
                            }
                            medicalWrapperItem.pickVals = pickVals;
                            if (diagnosisQuestionMap.containsKey(currMedicalQuestion.Id)) {
                                medicalWrapperItem.selectedPickVal = diagnosisQuestionMap.get(currMedicalQuestion.Id).Medical_Question_Answer__c;
                            }
                        }
                        if (currMedicalQuestion.Epilepsy_picklist__c != null) {
                            List<SelectOption> epilepsyPickVals = new List<SelectOption>();
                            epilepsyPickVals.add(new SelectOption('', 'Please Select'));
                            for (String currString : currMedicalQuestion.Epilepsy_picklist__c.split(',')) {
                                epilepsyPickVals.add(new SelectOption(currString, currString));
                            }
                            medicalWrapperItem.epilepsyPickVals = epilepsyPickVals;
                            if (diagnosisQuestionMap.containsKey(currMedicalQuestion.Id) && diagnosisQuestionMap.get(currMedicalQuestion.Id).Epilepsy_Value__c != null) {
                                medicalWrapperItem.epilepsySelectedPickVal = diagnosisQuestionMap.get(currMedicalQuestion.Id).Epilepsy_Value__c;
                            }
                        }
                        if (currMedicalQuestion.Data_Type__c == 'Comment box') {
                            if (diagnosisQuestionMap.containsKey(currMedicalQuestion.Id)) {
                                medicalWrapperItem.reasonForNeed = diagnosisQuestionMap.get(currMedicalQuestion.Id).Comment__c;
                            }

                        }
                        diagonsisWrapper.medicalWrapperList.add(medicalWrapperItem);
                    }
                }
                diagnosisVerificationWrapperLst.add(diagonsisWrapper);
            }
            Integer lastElement = diagnosisVerificationWrapperLst.size();
            if (wishStatus != 'Qualified' && diagnosisVerificationWrapperLst.size() < 5 && (diagnosisVerificationWrapperLst[lastElement - 1].icdCode != null || diagnosisVerificationWrapperLst[lastElement - 1].conditionDescription != null) && diagnosisVerificationWrapperLst[lastElement - 1].medicalWrapperList.size() == diagnosisVerificationLst[lastElement - 1].DiagnosisMedicalQuestions__r.size()) {
                showAddAnotherDiagnosisBtn = true;
            }
        } else {
            diagnosisVerificationWrapperLst.add(new DiagnosisWrapper());
        }

        // Travel Algorithm
        for (Medical_Questions__c currRec : ALL_MEDICAL_QUESTIONS) {
            if (currRec.RecordTypeId != Constant_AC.TRAVEL_ALGM_RT_ID) {
                continue;
            }

            if (currRec.Wrapper_Variable__c != null) {
                travelLabel.put(currRec.Wrapper_Variable__c, currRec.Current_Condition__c);
                travelVal.put(currRec.Wrapper_Variable__c, currRec.Recommendation_to_Chapter__c);
            }

            if (currRec.Current_Condition__c != null) {
                travelMap.put(currRec.Current_Condition__c, currRec.Wrapper_Variable__c);
            }
        }

        String jsonString = JSON.serialize(travelAlgorithmWrapperIns);
        Map<String, Object> wrapClsMap = new Map<String, Object>();
        wrapClsMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        if (currLead.Pulmonary_Hypertension__c != null) {
            pluHypTxt = currLead.Pulmonary_Hypertension__c;
        }

        if (currLead.Travel_algorithm__c != null) {
            for (String currVal : (currLead.Travel_algorithm__c.split(';'))) {
                if (travelMap.containsKey(currVal)) {
                    String fieldName = travelMap.get(currVal);
                    if (fieldName != null) {
                        wrapClsMap.put(fieldName, true);
                    }
                }
            }
            String jsonStringLoad = JSON.serialize(wrapClsMap);
            travelAlgorithmWrapperIns = (TravelAlgorithmWrapper) JSON.deserialize(jsonStringLoad, TravelAlgorithmWrapper.class);
        }

        if (currLead.Chronic_Hepatitis__c != null) {
            travelAlgorithmWrapperIns.chronicHepatitisString = currLead.Chronic_Hepatitis__c;
        }

        if (currLead.Strokes__c != null) {
            travelAlgorithmWrapperIns.strokesType = currLead.Strokes__c;
        }

        if (currLead.Hidden_Proto_Pulmonary_Hypertension__c != null) {
            travelAlgorithmWrapperIns.pulmonaryHypertensionString = currLead.Hidden_Proto_Pulmonary_Hypertension__c;
        }

        if (currLead.Convulsive_Disorders__c != null) {
            for (String currVal : currLead.Convulsive_Disorders__c.split(';')) {
                travelAlgorithmWrapperIns.convulsiveDisorders.add(currVal);
            }
        }

        if (currLead.Congenital_Heart_Disease__c != null) {
            for (String currVal : currLead.Congenital_Heart_Disease__c.split(';')) {
                travelAlgorithmWrapperIns.congenitalHeartDiseaseString.add(currVal);
            }
        }

        if (currLead.Chronic_Heart_Failure__c != null) {
            for (String currVal : currLead.Chronic_Heart_Failure__c.split(';')) {
                travelAlgorithmWrapperIns.chronicHeartFailureString.add(currVal);
            }
        }

        if (currLead.Heart_Failure__c != null) {
            for (String currVal : currLead.Heart_Failure__c.split(';')) {
                travelAlgorithmWrapperIns.heartFailureString.add(currVal);
            }
        }

        if (currLead.Arrhythmia__c != null) {
            for (String currVal : currLead.Arrhythmia__c.split(';')) {
                travelAlgorithmWrapperIns.ArrhythmiaString.add(currVal);
            }
        }

        if (currLead.Ventilator__c != null) {
            travelAlgorithmWrapperIns.ventilatorText = currLead.Ventilator__c;
        }

        if (currLead.Angina__c != null) {
            for (String currVal : currLead.Angina__c.split(';')) {
                travelAlgorithmWrapperIns.anginaString.add(currVal);
            }
        }

        if (currLead.Lung_Disease__c != null) {
            for (String currVal : currLead.Lung_Disease__c.split(';')) {
                travelAlgorithmWrapperIns.lungDiseaseString.add(currVal);
            }
        }
    }

    /*
     * @description     Used to clear the diagnosis information for removed block
     *
     * @author          unknown
     * @date            unknown
     */
    public void ResetDiagnosis() {
        diagnosisBlockNum = Integer.valueOf(ApexPages.currentPage().getParameters().get('diagnosisBlockNum'));

        diagnosisVerificationWrapperLst[diagnosisBlockNum].shortDescription = null;
        diagnosisVerificationWrapperLst[diagnosisBlockNum].pcdOrIcd = null;
        diagnosisVerificationWrapperLst[diagnosisBlockNum].valueSelectedICD = null;
        diagnosisVerificationWrapperLst[diagnosisBlockNum].valueSelectedPCD = null;
        diagnosisVerificationWrapperLst[diagnosisBlockNum].isEligible = false;

        if (diagnosisVerificationWrapperLst[diagnosisBlockNum].medicalWrapperList.size() > 0) {
            diagnosisVerificationWrapperLst[diagnosisBlockNum].medicalWrapperList.clear();
        }

        for (Integer i = 0; i < diagnosisVerificationWrapperLst.size(); i++) {
            if (String.isEmpty(diagnosisVerificationWrapperLst[i].icdCode) && String.isEmpty(diagnosisVerificationWrapperLst[i].conditionDescription) && i != diagnosisBlockNum) {
                diagnosisVerificationWrapperLst[i].shortDescription = null;
                diagnosisVerificationWrapperLst[i].pcdOrIcd = null;
                diagnosisVerificationWrapperLst[i].valueSelectedICD = null;
                diagnosisVerificationWrapperLst[i].valueSelectedPCD = null;
                diagnosisVerificationWrapperLst[i].isEligible = false;
                if (diagnosisVerificationWrapperLst[i].medicalWrapperList.size() > 0) {
                    diagnosisVerificationWrapperLst[i].medicalWrapperList.clear();
                }
                diagnosisVerificationWrapperLst.remove(i);
            }
        }

        setWishStatus();
    }

    /*
     * @description     Used to remove Diagnosis Block
     *
     * @author          unknown
     * @date            unknown
     */
    public void RemoveDiagnosisBlock() {
        diagnosisBlockNum = Integer.valueOf(ApexPages.currentPage().getParameters().get('diagnosisBlockNum')); // Used to hold the Diagnosis block number
        List<Diagnosis_Verification__c> removeDiagnosisVerificationList = [
            SELECT Id, Order__c
            FROM Diagnosis_Verification__c
            WHERE Order__c = :diagnosisBlockNum
        ];

        diagnosisVerificationWrapperLst[diagnosisBlockNum].shortDescription = null;
        diagnosisVerificationWrapperLst[diagnosisBlockNum].pcdOrIcd = null;
        diagnosisVerificationWrapperLst[diagnosisBlockNum].valueSelectedICD = null;
        diagnosisVerificationWrapperLst[diagnosisBlockNum].valueSelectedPCD = null;
        diagnosisVerificationWrapperLst[diagnosisBlockNum].isEligible = false;

        if (diagnosisVerificationWrapperLst[diagnosisBlockNum].medicalWrapperList.size() > 0) {
            diagnosisVerificationWrapperLst[diagnosisBlockNum].medicalWrapperList.clear();
        }

        diagnosisVerificationWrapperLst.remove(diagnosisBlockNum);
        if (diagnosisVerificationWrapperLst.size() < 5 && (diagnosisVerificationWrapperLst[diagnosisBlockNum - 1].icdCode.length() > 0 || diagnosisVerificationWrapperLst[diagnosisBlockNum - 1].conditionDescription.length() > 0)) {
            showAddAnotherDiagnosisBtn = true;
        }

        setWishStatus();
    }

    /*
     * @description     Used to add another diagnosis block
     *
     * @author          unknown
     * @date            unknown
     */
    public void addDiagnosisVerification() {
        if (diagnosisVerificationWrapperLst.size() < 5) {
            diagnosisVerificationWrapperLst.add(new DiagnosisWrapper());
            showAddAnotherDiagnosisBtn = false;
            otherDiagnosisBlock = null;
        }

        setWishStatus();
    }

    /*
     * @description     Auto Complete the ICD Code values.
     *
     * @author          unknown
     * @date            unknown
    */
    @RemoteAction
    public static List<ICD_Codes__c> searchDiagnosis(String searchTerm) {
        String query = 'SELECT ';

        final List<String> FIELDS_TO_SELECT = new List<String> {
            'Id',
            'Name',
            'Condition_Description__c',
            'Condition_Description__r.InActive__c',
            'Condition_Description__r.Name',
            'Short_Description__c'
        };

        for (String field : FIELDS_TO_SELECT) {
            query += field + ',';
        }

        query = query.removeEnd(',');
        query += ' FROM ICD_Codes__c ';
        query += ' WHERE Condition_Description__r.InActive__c != true AND ';
        query += ' Hidden_ICD_Code__c = false ';
        if (!String.isBlank(searchTerm)) {
            query += ' AND Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\'';
        }
        query += ' LIMIT 50000';

        List<ICD_Codes__c> icdCodes = Database.query(query);
        return icdCodes;
    }

    /*
     * @description     Auto Complete the Diagnosis field value.
     *
     * @param           String searchTerm
     *
     * @return          List<Condition_Description__c>
     *
     * @author          Chris Shinnimin, Traction on Demand
     * @date            2020-03-04
     */
    @RemoteAction
    public static List<Condition_Description__c> searchCondition(String searchTerm) {
        List<Condition_Description__c> conditionDescriptions = new List<Condition_Description__c>();
        Pattern pattern = Pattern.compile('(?i).*' + String.escapeSingleQuotes(searchTerm) + '.*');

        for (String cdName : MAP_OF_CONDITION_DESCRIPTIONS_BY_NAME.keySet()) {
            if (pattern.matcher(cdName).matches()) {
                conditionDescriptions.addAll(MAP_OF_CONDITION_DESCRIPTIONS_BY_NAME.get(cdName));
            }
        }

        if (conditionDescriptions.isEmpty()) {
            conditionDescriptions = DEFAULT_CONDITION_DESCRIPTIONS;
        }

        return conditionDescriptions;
    }

    /*
     * @description     Used to check login credentials and whether document is already signed
     *
     * @author          unknown
     * @date            unknown
     */
    public pagereference submit() {
        if (currLead.isSign__c == true) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.DiagnosisVerification_Already_Reviewed);
            ApexPages.addMessage(myMsg);
        } else if (currLead.IsConverted == true) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.DiagnosisVerification_Cannot_Review);
            ApexPages.addMessage(myMsg);
        } else if (wishChildWrapperIns.password != currLead.Part_A_Form_Password__c) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.DiagnosisVerification_Incorrect_Password);
            ApexPages.addMessage(myMsg);
        } else if (wishChildWrapperIns.password == currLead.Part_A_Form_Password__c) {
            wishChildWrapperIns.login = true;
        }

        return null;
    }

    /*
     * @description     Used to hold the describe patient value
     *
     * @author          unknown
     * @date            unknown
     */
    public void changePatientValue() {
        wishChildWrapperIns.describePatient = wishChildWrapperIns.selectedItemValue;
    }

    /*
     * @description     To check whether Wish Child is eligible based on ICD & Condition Description provided
     *
     * @author          unknown
     * @date            unknown
     */
    public void WishChildEligibilityCheck() {
        try {
            icdOrPcd = ApexPages.currentPage().getParameters().get('icdOrPcd'); //Used to hold the given auto complete input is ICD Code or Condition Description
            diagnosisBlockNum = Integer.valueOf(ApexPages.currentPage().getParameters().get('diagnosisBlockNum')); // Used to hold the Diagnosis block number
            diagnosisVerificationWrapperLst[diagnosisBlockNum].shortDescription = null;
            if (icdOrPcd == 'ICD') {
                diagnosisVerificationWrapperLst[diagnosisBlockNum].valueSelectedICD = 'value-selected';
            } else if (icdOrPcd == 'PCD') {
                diagnosisVerificationWrapperLst[diagnosisBlockNum].valueSelectedPCD = 'value-selected';
            }

            diagnosisVerificationWrapperLst[diagnosisBlockNum].isEligible = false;
            diagnosisVerificationWrapperLst[diagnosisBlockNum].pcdOrIcd = icdOrPcd;
            showAddAnotherDiagnosisBtn = false;
            if (diagnosisVerificationWrapperLst[diagnosisBlockNum].medicalWrapperList.size() > 0) {
                diagnosisVerificationWrapperLst[diagnosisBlockNum].medicalWrapperList.clear();
            }

            //ICD code
            if (icdOrPcd == 'ICD') {
                List<ICD_Codes__c> icdCodeInfo = DiagnosisVerification_AC_Helper.getIcdCodeInfo(diagnosisVerificationWrapperLst[diagnosisBlockNum].icdCode);
                if (icdCodeInfo.size() > 0) {
                    List<Medical_Questions__c> medicalQuestionList = MAP_OF_MEDICAL_QUESTIONS_BY_DESCRIPTION.get(icdCodeInfo[0].Condition_Description__c);

                    diagnosisVerificationWrapperLst[diagnosisBlockNum].shortDescription = icdCodeInfo[0].Short_Description__c;
                    diagnosisVerificationWrapperLst[diagnosisBlockNum].isGroup1Rec = icdCodeInfo[0].Group1__c;

                    if (!String.isEmpty(icdCodeInfo[0].Condition_Description__r.Name) && icdCodeInfo[0].Condition_Description__r.Name == 'Total Parenteral Nutrition (TPN)') {
                        showAddAnotherDiagnosisBtn = true;
                    }

                    else {
                        MedicalQuestions(icdCodeInfo[0].Name, icdCodeInfo[0].Condition_Description__c, icdCodeInfo[0].Group1__c, icdOrPcd, diagnosisBlockNum, medicalQuestionList, icdCodeInfo[0].Skip_Medical_Question__c);
                    }
                }

                // Condition Description
            } else if (icdOrPcd == 'PCD') {
                if (diagnosisVerificationWrapperLst[diagnosisBlockNum].conditionDescription == 'Total Parenteral Nutrition (TPN)') {
                    showAddAnotherDiagnosisBtn = true;
                }

                List<Condition_Description__c> conditionDescriptionInfo = MAP_OF_CONDITION_DESCRIPTIONS_BY_NAME.get(diagnosisVerificationWrapperLst[diagnosisBlockNum].conditionDescription);

                if (conditionDescriptionInfo.size() > 0) {
                    diagnosisVerificationWrapperLst[diagnosisBlockNum].isGroup1Rec = conditionDescriptionInfo[0].Group1__c;

                    List<Medical_Questions__c> medicalQuestionList = MAP_OF_MEDICAL_QUESTIONS_BY_DESCRIPTION.get(conditionDescriptionInfo[0].Id);

                    // Condition Description categories like Epilepsy, Cardiomyopathy with group 1 records are considered as eligible without asking Medical Questions
                    // Those questions are identified by using isEligible__c field
                    if (conditionDescriptionInfo[0].isEligible__c == true) {
                        if (wishChildWrapperIns.describePatient != '7' && wishChildWrapperIns.describePatient != '8' && wishChildWrapperIns.describePatient != '6') {
                            diagnosisVerificationWrapperLst[diagnosisBlockNum].isEligible = true;
                        } else {
                            showAddAnotherDiagnosisBtn = true;
                        }
                    } else {
                        if (!String.isEmpty(conditionDescriptionInfo[0].Code_To_Use__c)) {
                            //Medical question inputs for given Condition Description if the ICD Code is not null
                            List<ICD_Codes__c> icdCodeInfo = DiagnosisVerification_AC_Helper.getIcdCodeInfo(conditionDescriptionInfo[0].Code_To_Use__c);

                            if (icdCodeInfo.size() > 0) {
                                diagnosisVerificationWrapperLst[diagnosisBlockNum].valueSelectedICD = 'value-selected';
                                diagnosisVerificationWrapperLst[diagnosisBlockNum].shortDescription = icdCodeInfo[0].Short_Description__c;
                                MedicalQuestions(icdCodeInfo[0].Name, conditionDescriptionInfo[0].Id, icdCodeInfo[0].Group1__c, icdOrPcd, diagnosisBlockNum, medicalQuestionList, icdCodeInfo[0].Skip_Medical_Question__c);
                            } else {
                                diagnosisVerificationWrapperLst[diagnosisBlockNum].valueSelectedICD = 'value-selected';
                                MedicalQuestions(conditionDescriptionInfo[0].Code_To_Use__c, conditionDescriptionInfo[0].Id, conditionDescriptionInfo[0].Group1__c, icdOrPcd, diagnosisBlockNum, medicalQuestionList, icdCodeInfo[0].Skip_Medical_Question__c);
                            }

                        } else {
                            //Medical question inputs for given Condition Description if the ICD Code is null
                            MedicalQuestions(conditionDescriptionInfo[0].Code_To_Use__c, conditionDescriptionInfo[0].Id, conditionDescriptionInfo[0].Group1__c, icdOrPcd, diagnosisBlockNum, medicalQuestionList, false);
                        }
                    }
                }
            }

            setWishStatus();

            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }
        } catch (Exception ex) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);

        }
    }

    /*
     * @description     Used to set status based on Medical Question response.
     *
     * @author          unknown
     * @date            unknown
     */
    public void setWishStatus() {
        wishStatus = '';

        for (DiagnosisWrapper currDiagnosisWrapper : diagnosisVerificationWrapperLst) {
            if (currDiagnosisWrapper.isEligible) {
                wishStatus = 'Qualified';
            }
        }

        if (wishStatus != 'Qualified') {
            wishStatus = 'Not Qualified';
        }
    }

    /*
     * @description     Getting Medical Question List based on ICD Code & Condition Description given by Medical Professional
     *
     * @author          unknown
     * @date            unknown
     */
    @TestVisible
    private List<DiagnosisWrapper.MedicalWrapper> MedicalQuestions(String icdCode, String conditionDescription, Boolean isGroup1, String icdOrPcd, Integer diagnosisBlockNum, List<Medical_Questions__c> medicalQuestions, Boolean skipMedQues) {
        try {
            Condition_Description__c conditionDesc;
            diagnosisVerificationWrapperLst[diagnosisBlockNum].conditionDescriptionObject = conditionDescription;

            if (MAP_OF_CONDITION_DESCRIPTIONS_BY_ID.containsKey(conditionDescription) &&  medicalQuestions.size() > 0) {
                conditionDesc = MAP_OF_CONDITION_DESCRIPTIONS_BY_ID.get(conditionDescription);

                if (conditionDesc.Name == 'Arteriovenus Malformation (AVM)') {
                    diagnosisVerificationWrapperLst[diagnosisBlockNum].isEligible = true;
                }

                List<Medical_Questions__c> medicalQuestionList = new List<Medical_Questions__c>();
                medicalQuestionList.addAll(medicalQuestions);

                if (medicalQuestionList.size() > 0 && skipMedQues == false) {
                    for (Medical_Questions__c medicalQuestion : medicalQuestionList) {
                        DiagnosisWrapper.MedicalWrapper medicalWrapperItem = new DiagnosisWrapper.MedicalWrapper();
                        medicalWrapperItem.medicalQuestion = medicalQuestion;

                        medicalWrapperItem.pickVals = Utils.picklistStringToOptions(medicalQuestion.Picklist_values__c);
                        medicalWrapperItem.epilepsyPickVals = Utils.picklistStringToOptions(medicalQuestion.Epilepsy_picklist__c);

                        diagnosisVerificationWrapperLst[diagnosisBlockNum].medicalWrapperList.add(medicalWrapperItem);
                    }
                } else if (isGroup1 == true) {
                    if (wishChildWrapperIns.describePatient != '7' && wishChildWrapperIns.describePatient != '8' && wishChildWrapperIns.describePatient != '6') {
                        diagnosisVerificationWrapperLst[diagnosisBlockNum].isEligible = true;
                        diagnosisVerificationWrapperLst[diagnosisBlockNum].iCDCode = icdCode;
                    } else {
                        showAddAnotherDiagnosisBtn = true;
                    }
                } else {
                    if (diagnosisVerificationWrapperLst.size() < 5) {
                        showAddAnotherDiagnosisBtn = true;
                    } else {
                        showAddAnotherDiagnosisBtn = false;
                        diagnosisVerificationWrapperLst[diagnosisBlockNum].isEligible = false;
                    }
                }
            } else if (isGroup1 == true) {
                if (wishChildWrapperIns.describePatient != '7' && wishChildWrapperIns.describePatient != '8' && wishChildWrapperIns.describePatient != '6') {
                    diagnosisVerificationWrapperLst[diagnosisBlockNum].isEligible = true;
                    diagnosisVerificationWrapperLst[diagnosisBlockNum].icdCode = icdCode;
                } else {
                    showAddAnotherDiagnosisBtn = true;
                }
            } else {
                diagnosisVerificationWrapperLst[diagnosisBlockNum].isEligible = false;
                if (diagnosisVerificationWrapperLst.size() < 5) {
                    showAddAnotherDiagnosisBtn = true;
                } else {
                    showAddAnotherDiagnosisBtn = false;
                }
            }

            setWishStatus();

            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }
        } catch (Exception ex) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
        }

        return null;
    }

    //Making wish as Eligible & Not Eligible based on Medical Question Value
    public void MedicalResponse() {
        try {
            medicalResponse = ApexPages.currentPage().getParameters().get('medicalResponse'); // Used to hold the Medical Question response
            diagnosisBlockNum = Integer.valueOf(ApexPages.currentPage().getParameters().get('diagnosisBlockNum')); // Used to hold the Diagnosis block number
            Integer questionNumber = Integer.valueOf(ApexPages.currentPage().getParameters().get('questionNumber'));

            if (medicalResponse != null && medicalResponse == 'Yes') {
                if (wishChildWrapperIns.describePatient != '7' && wishChildWrapperIns.describePatient != '8' && wishChildWrapperIns.describePatient != '6') {
                    showAddAnotherDiagnosisBtn = false;
                    diagnosisVerificationWrapperLst[diagnosisBlockNum].isEligible = true;
                    diagnosisVerificationWrapperLst[diagnosisBlockNum].medicalWrapperList[questionNumber].isEligible = true;
                    currLead.Qualifying_Diagnosis__c = diagnosisVerificationWrapperLst[diagnosisBlockNum].conditionDescription;

                    if (currLead.Qualifying_Diagnosis__c != null) {
                        List<Condition_Description__c> descriptionList = MAP_OF_CONDITION_DESCRIPTIONS_BY_NAME.get(currLead.Qualifying_Diagnosis__c);
                        currLead.PR_Diagnosis__c = (descriptionList.size() > 0) ? descriptionList[0].PR_Diagnosis__c : '';
                    }

                    List<ICD_Codes__c> icdCodeInfo = DiagnosisVerification_AC_Helper.getIcdCodeInfo(diagnosisVerificationWrapperLst[diagnosisBlockNum].icdCode);

                    if (icdCodeInfo.size() > 0) {
                        currLead.Qualifying_ICD__c = icdCodeInfo[0].Id;
                    }
                }
            } else if ((medicalResponse != null) && (medicalResponse == 'No' || medicalResponse == 'ShowNext')) {
                if (diagnosisVerificationWrapperLst[diagnosisBlockNum].medicalWrapperList[questionNumber].isEligible) {
                    diagnosisVerificationWrapperLst[diagnosisBlockNum].isEligible = false;
                    diagnosisVerificationWrapperLst[diagnosisBlockNum].medicalWrapperList[questionNumber].isEligible = false;
                    currLead.Qualifying_Diagnosis__c = '';
                    currLead.Qualifying_ICD__c = null;
                    currLead.Is_Required_Bypass__c = true;
                    currLead.PR_Diagnosis__c = '';
                }

                if (diagnosisVerificationWrapperLst.size() < 5) {
                    showAddAnotherDiagnosisBtn = true;
                }
            } else if (diagnosisBlockNum > 5) {
                if (diagnosisVerificationWrapperLst[diagnosisBlockNum].medicalWrapperList[questionNumber].isEligible) {
                    diagnosisVerificationWrapperLst[diagnosisBlockNum].isEligible = false;
                    diagnosisVerificationWrapperLst[diagnosisBlockNum].medicalWrapperList[questionNumber].isEligible = false;
                    currLead.Qualifying_Diagnosis__c = '';
                    currLead.Qualifying_ICD__c = null;
                    currLead.Is_Required_Bypass__c = true;
                    currLead.PR_Diagnosis__c = '';
                }
            }

            setWishStatus();

            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }
        } catch (Exception ex) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
        }
    }

    /*
     * @description     To change the Wish status
     *
     * @author          unknown
     * @date            unknown
     */
    public void changeWishStatus() {
        diagnosisBlockNum = Integer.valueOf(ApexPages.currentPage().getParameters().get('diagnosisBlockNum')); // Used to hold the Diagnosis block number
        Integer questionNumber = Integer.valueOf(ApexPages.currentPage().getParameters().get('questionNumber'));

        if (diagnosisVerificationWrapperLst[diagnosisBlockNum].medicalWrapperList[questionNumber].isEligible) {
            diagnosisVerificationWrapperLst[diagnosisBlockNum].isEligible = false;
            diagnosisVerificationWrapperLst[diagnosisBlockNum].medicalWrapperList[questionNumber].isEligible = false;
        }

        setWishStatus();
    }

    /*
     * @description     Used to delete the Medical Summary Attachment
     *
     * @author          unknown
     * @date            unknown
     */
    public void deleteLeadFile() {
        String attachmentId = ApexPages.currentPage().getParameters().get('attachmentId'); // Used to hold the Diagnosis block number

        try {
            delete [
                SELECT Id
                FROM cg__Lead_File__c
                WHERE Id = :attachmentId
            ];

            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }
        } catch (Exception ex) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
        }
    }

    /*
     * @description     Used to save information given by MedicalProfessional
     *
     * @author          unknown
     * @date            unknown
     */
    public void SaveMedicalInformation() {
        try {
            String currentConditionFormattedString = ApexPages.currentPage().getParameters().get('travelString');
            String currentConditionChosenString = ApexPages.currentPage().getParameters().get('collectedConditionValue');

            currLead.Treating_Medical_Professional_First_Name__c = wishChildWrapperIns.treatingFName ;
            currLead.Treating_Medical_Professional_Last_Name__c = wishChildWrapperIns.treatingLName;
            currLead.Treating_Medical_Professional_Phone__c = wishChildWrapperIns.treatingPhone;
            currLead.Treating_Medical_Professional_Email__c = wishChildWrapperIns.treatingEmail;
            currLead.Hospital_Treatment_Facility_Treating__c = wishChildWrapperIns.treatingHospital;
            currLead.I_am_Recognized_To_Practice_As_a__c = wishChildWrapperIns.recognizationPickValSelected;
            currLead.I_m_Part_of_The_Treating_HealthCare_Team__c = wishChildWrapperIns.healthCareWork;
            currLead.Is_in_a_Comatose_Vegetative_State__c = wishChildWrapperIns.vegetativeState;
            currLead.RFI_Form_Info_Hidden__c = wishStatus;
            currLead.Any_medical_reason_for_moving_quickly__c = wishChildWrapperIns.expediteTheProcess;//Added as per IME-107
            currLead.Please_Explain_Deteriorate__c = wishChildWrapperIns.explainDeteriorate;
            currLead.Please_Explain__c = wishChildWrapperIns.plzExplain;
            currLead.Will_Child_s_Condition_Deteriorate__c = wishChildWrapperIns.conditioDeteriorate;
            currLead.Why_do_you_feel_would_be_eligible_Wish__c = wishChildWrapperIns.wishChildEligibilityNotes;
            currLead.Why_do_you_feel_would_be_eligible_Wish__c = wishChildWrapperIns.stillEligibile;
            currLead.Provided_additional_information__c = wishChildWrapperIns.additionalInfo;
            currLead.Child_will_ultimately_die_prematurely__c = false;
            currLead.Treatment_may_be_feasible_but_can_fail__c = false;
            currLead.Treatment_may_prolong_normal_activities__c = false;
            currLead.Debilitation_may_extend_over_many_years__c = false;
            currLead.Increased_probability_of_premature_death__c = false;
            currLead.Risk_of_complications_premature_death__c = false;
            currLead.None_of_these_statements_describes_Child__c = false;
            currLead.Responds_to_treatment_with_normal_health__c = false;
            currLead.Unplanned_hospital_admissions__c = wishChildWrapperIns.unplannedHospitalAdmission;
            currLead.Number_hospital_admissions__c =  wishChildWrapperIns.numberOfHospitalAdmission;
            currLead.Admitting_diagnosis__c = wishChildWrapperIns.admittingDiagnosis;
            currLead.ICU_Admissions__c = wishChildWrapperIns.ifICUAdmission;
            //SIW-355 Start : Mapped 2 new added questions value to lead field on submission of DV form
            currLead.Expedite_timeframe__c = wishChildWrapperIns.timeFrameValue;
            currLead.Other_expedite_timeframe_comments__c = wishChildWrapperIns.idealtimeFrameValue;
            //SIW-355 End

            if (wishChildWrapperIns.describePatient == '1') {
                currLead.Child_will_ultimately_die_prematurely__c = true;
            } else if (wishChildWrapperIns.describePatient == '2') {
                currLead.Treatment_may_be_feasible_but_can_fail__c = true;
            } else if (wishChildWrapperIns.describePatient == '3') {
                currLead.Treatment_may_prolong_normal_activities__c = true;
            } else if (wishChildWrapperIns.describePatient == '4') {
                currLead.Debilitation_may_extend_over_many_years__c = true;
            } else if (wishChildWrapperIns.describePatient == '5') {
                currLead.Increased_probability_of_premature_death__c = true;
            } else if (wishChildWrapperIns.describePatient == '6') {
                currLead.Risk_of_complications_premature_death__c = true;
            } else if (wishChildWrapperIns.describePatient == '7') {
                currLead.Responds_to_treatment_with_normal_health__c = true;
            } else if (wishChildWrapperIns.describePatient == '8') {
                currLead.None_of_these_statements_describes_Child__c = true;
            }

            if (wishChildWrapperIns.communicationList != null) {
                String communications = '';
                for (String s : (wishChildWrapperIns.communicationList)) {
                    communications += s + ';';
                }
                currLead.Communication__c = communications.removeEnd(';');
            }

            List<Diagnosis_Verification__c> diagnosisVerificationLstForInsert = new List<Diagnosis_Verification__c>();
            List<DiagnosisMedicalQuestions__c> diagnosisMedicalQuestionLst = new List<DiagnosisMedicalQuestions__c>();
            Integer order = 0;

            currLead.PD_Condition_Description__c = currLead.Diagnosis_Given_By_Referrer__c;
            currLead.PD_ICD_Code__c = currLead.ICD_Given_By_Referrer__c;

            currLead.SD1_Condition_Description__c = null;
            currLead.SD2_Condition_Description__c = null;
            currLead.SD3_Condition_Description__c = null;
            currLead.SD4_Condition_Description__c = null;
            currLead.SD1_ICD_Code__c = null;
            currLead.SD2_ICD_Code__c = null;
            currLead.SD3_ICD_Code__c = null;
            currLead.SD4_ICD_Code__c = null;

            Set<Integer> orderSet = new Set<Integer>();
            Set<String> icdCodeSet = new Set<String>();
            Map<String, Id> icdInfoMap = new Map<String, Id>();
            for (DiagnosisWrapper diagnosisVerificationItem : diagnosisVerificationWrapperLst) {
                icdCodeSet.add(diagnosisVerificationItem.icdCode);
            }

            for (ICD_Codes__c icdInfo : [
                SELECT Id, Name
                FROM ICD_Codes__c
                WHERE Name IN :icdCodeSet
            ]) {
                icdInfoMap.put(icdInfo.Name, icdInfo.Id);
            }

            for (DiagnosisWrapper diagnosisVerificationItem : diagnosisVerificationWrapperLst) {
                if (!orderSet.contains(order) && (!String.isEmpty(diagnosisVerificationItem.icdCode) || !String.isEmpty(diagnosisVerificationItem.conditionDescription))) {
                    Diagnosis_Verification__c diagnosisVerification = new Diagnosis_Verification__c();
                    diagnosisVerification.Order__c = order;
                    diagnosisVerification.Group1__c = diagnosisVerificationItem.isGroup1Rec;
                    diagnosisVerification.Lead__c = leadId;
                    diagnosisVerification.isEligible__c = diagnosisVerificationItem.isEligible;

                    diagnosisVerification.ICD_Code__c = diagnosisVerificationItem.icdCode;
                    diagnosisVerification.PCD_ICD__c = diagnosisVerificationItem.pcdOrIcd;
                    diagnosisVerification.Condition_Description__c = diagnosisVerificationItem.conditionDescriptionObject;
                    diagnosisVerification.Short_Description__c = diagnosisVerificationItem.shortDescription;
                    diagnosisVerificationItem.externalId = Math.random();
                    diagnosisVerification.Eternal_Id__c = String.valueOf(diagnosisVerificationItem.externalId);
                    diagnosisVerificationLstForInsert.add(diagnosisVerification);

                    if (order == 0) {
                        currLead.PD_Condition_Description__c = diagnosisVerificationItem.conditionDescription;
                        if (icdInfoMap.containsKey(diagnosisVerificationItem.icdCode)) {
                            currLead.PD_ICD_Code__c = icdInfoMap.get(diagnosisVerificationItem.icdCode);
                        }
                    }

                    if (order == 1) {
                        currLead.SD1_Condition_Description__c = diagnosisVerificationItem.conditionDescription;
                        if (icdInfoMap.containsKey(diagnosisVerificationItem.icdCode)) {
                            currLead.SD1_ICD_Code__c = icdInfoMap.get(diagnosisVerificationItem.icdCode);
                        }
                    }

                    if (order == 2) {
                        currLead.SD2_Condition_Description__c = diagnosisVerificationItem.conditionDescription;
                        if (icdInfoMap.containsKey(diagnosisVerificationItem.icdCode)) {
                            currLead.SD2_ICD_Code__c = icdInfoMap.get(diagnosisVerificationItem.icdCode);
                        }
                    }

                    if (order == 3) {
                        currLead.SD3_Condition_Description__c = diagnosisVerificationItem.conditionDescription;
                        if (icdInfoMap.containsKey(diagnosisVerificationItem.icdCode)) {
                            currLead.SD3_ICD_Code__c = icdInfoMap.get(diagnosisVerificationItem.icdCode);
                        }
                    }

                    if (order == 4) {
                        currLead.SD4_Condition_Description__c = diagnosisVerificationItem.conditionDescription;
                        if (icdInfoMap.containsKey(diagnosisVerificationItem.icdCode)) {
                            currLead.SD4_ICD_Code__c = icdInfoMap.get(diagnosisVerificationItem.icdCode);
                        }
                    }

                    orderSet.add(order);
                }
                order++;
            }

            for (DiagnosisWrapper diagnosisVerificationItem : diagnosisVerificationWrapperLst) {
                if ((diagnosisVerificationItem.icdCode != null && diagnosisVerificationItem.icdCode.length() > 0) || (diagnosisVerificationItem.conditionDescription != null && diagnosisVerificationItem.conditionDescription.length() > 0)) {
                    Diagnosis_Verification__c diagnosisVerificationReference = new Diagnosis_Verification__c(Eternal_Id__c = String.valueOf(diagnosisVerificationItem.externalId));
                    for (DiagnosisWrapper.MedicalWrapper medicalWrapperItem : diagnosisVerificationItem.medicalWrapperList) {
                        if ((medicalWrapperItem.selectedPickVal != null && medicalWrapperItem.selectedPickVal.length() > 0) || (medicalWrapperItem.reasonForNeed != null && medicalWrapperItem.reasonForNeed.length() > 0)) {
                            DiagnosisMedicalQuestions__c diagnosisQuestion = new DiagnosisMedicalQuestions__c();
                            diagnosisQuestion.Diagnosis_Verification__r = diagnosisVerificationReference;
                            diagnosisQuestion.Epilepsy_Value__c = medicalWrapperItem.epilepsySelectedPickVal;
                            diagnosisQuestion.Comment__c = medicalWrapperItem.reasonForNeed;
                            diagnosisQuestion.Medical_Question_Answer__c = medicalWrapperItem.selectedPickVal;
                            diagnosisQuestion.Medical_Question__c = medicalWrapperItem.medicalQuestion.Id;
                            diagnosisQuestion.isEligible__c = medicalWrapperItem.isEligible;
                            diagnosisMedicalQuestionLst.add(diagnosisQuestion);
                        }
                    }
                }
            }

            Set<String> travelValuesSet = new Set<String>();
            Set<String> travelValuesLabel = new Set<String>();
            String jsonString = JSON.serialize(travelAlgorithmWrapperIns);
            Map<String, Object> wrapClsMap = new Map<String, Object>();
            wrapClsMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);

            for (String currString : travelVal.keySet()) {
                if (wrapClsMap.get(currString) == true) {
                    travelValuesSet.add(travelVal.get(currString));
                    travelValuesLabel.add(travelLabel.get(currString));
                }
            }

            currLead.Current_Condition_Label__c = '';
            for (String currVal : travelValuesLabel) {
                currLead.Current_Condition_Label__c += currVal + ';';
            }

            if (travelAlgorithmWrapperIns.chronicHepatitisString != null) {
                currLead.Chronic_Hepatitis__c = travelAlgorithmWrapperIns.chronicHepatitisString;
            }

            if (pluHypTxt != null) {
                if (pluHypTxt == 'NYHA Class IV1') {
                    currLead.Pulmonary_Hypertension__c = 'NYHA Class IV';
                } else {
                    currLead.Pulmonary_Hypertension__c = pluHypTxt;
                }
            }

            if (travelAlgorithmWrapperIns.strokesType != null) {
                currLead.Strokes__c = travelAlgorithmWrapperIns.strokesType ;
            }

            if (travelAlgorithmWrapperIns.pulmonaryHypertensionString != null) {
                currLead.Hidden_Proto_Pulmonary_Hypertension__c = travelAlgorithmWrapperIns.pulmonaryHypertensionString ;
            }

            currLead.Convulsive_Disorders__c = '';
            if (travelAlgorithmWrapperIns.convulsiveDisorders != null) {
                for (String currVal : travelAlgorithmWrapperIns.convulsiveDisorders) {
                    currLead.Convulsive_Disorders__c += currVal + ';';
                }
            }

            currLead.Congenital_Heart_Disease__c = '';
            if (travelAlgorithmWrapperIns.congenitalHeartDiseaseString != null) {
                for (String currVal : travelAlgorithmWrapperIns.congenitalHeartDiseaseString) {
                    currLead.Congenital_Heart_Disease__c += currVal + ';';
                }
            }

            currLead.Chronic_Heart_Failure__c = '';
            if (travelAlgorithmWrapperIns.chronicHeartFailureString != null) {
                for (String currVal : travelAlgorithmWrapperIns.chronicHeartFailureString) {
                    currLead.Chronic_Heart_Failure__c += currVal + ';';
                }
            }

            currLead.Heart_Failure__c = '';
            if (travelAlgorithmWrapperIns.heartFailureString != null) {
                for (String currVal : travelAlgorithmWrapperIns.heartFailureString) {
                    currLead.Heart_Failure__c += currVal + ';';
                }
            }

            currLead.Arrhythmia__c = '';
            if (travelAlgorithmWrapperIns.ArrhythmiaString != null) {
                for (String currVal : travelAlgorithmWrapperIns.ArrhythmiaString) {
                    currLead.Arrhythmia__c += currVal + ';';
                }
            }

            currLead.Angina__c = '';
            if (travelAlgorithmWrapperIns.anginaString != null) {
                for (String currVal : travelAlgorithmWrapperIns.anginaString) {
                    currLead.Angina__c += currVal + ';';
                }
            }

            currLead.Ventilator__c = travelAlgorithmWrapperIns.ventilatorText;

            currLead.Lung_Disease__c = '';
            if (travelAlgorithmWrapperIns.lungDiseaseString != null) {
                for (String currVal : travelAlgorithmWrapperIns.lungDiseaseString) {
                    currLead.Lung_Disease__c += currVal + ';';
                }
            }

            uniqueCurrentConditionSet.clear();
            if (!String.isEmpty(currentConditionChosenString)) {
                for (String currCon : currentConditionChosenString.split(';')) {
                    if (travelAlgorithmMap.containsKey(currCon)) {
                        if (!uniqueCurrentConditionSet.contains(currCon)) {
                            if (!String.isEmpty(travelAlgorithmMap.get(currCon))) {
                                uniqueCurrentConditionSet.add(travelAlgorithmMap.get(currCon));
                            }
                        }
                    }
                }
            }

            currLead.Travel_Restriction__c = '';
            if (travelAlgorithmWrapperIns.travelRestriction) {
                currLead.Travel_Restriction__c = 'Travel Careful Consideration - Very High Risk of Complications';
            } else if (uniqueCurrentConditionSet.size() > 0) {
                Integer i = 1;
                for (String condition : uniqueCurrentConditionSet) {
                    currLead.Travel_Restriction__c += i + '. ' + condition + ';' + '\n';
                    i++;
                }
            }

            currLead.Travel_algorithm__c = currLead.Current_Condition_Label__c;

            currLead.Current_Condition_Label__c = '';
            if (!String.isEmpty(currentConditionFormattedString)) {
                currLead.Current_Condition_Label__c = currentConditionFormattedString;
            }

            currLead.Best_Contact_for_Physician_First_Name__c = wishChildWrapperIns.bestPhyFname;
            currLead.Best_Contact_for_Physician_Last_Name__c = wishChildWrapperIns.bestPhyLname;
            currLead.Best_contact_for_Physician_Email__c = wishChildWrapperIns.bestPhyEmail;
            currLead.Alternate1MedProfessionalFirstName__c = wishChildWrapperIns.alt1MedFname;
            currLead.Alternate1MedProfessionalLastName__c = wishChildWrapperIns.alt1MedLname;
            currLead.Alternate1MedicalProfessionalEmail__c = wishChildWrapperIns.alt1MedEmail;
            currLead.Alternate1MedProfessionalPhone__c = wishChildWrapperIns.alt1MedPhone;
            currLead.Alternate1HospitalTreatmentFacility__c = wishChildWrapperIns.alt1MedHosp;
            currLead.Alternate2MedProfessionalFirstName__c = wishChildWrapperIns.alt2MedFname;
            currLead.Alternate2MedProfessionalLastName__c = wishChildWrapperIns.alt2MedLname;
            currLead.Alternate2MedProfessionalEmail__c = wishChildWrapperIns.alt2MedEmail;
            currLead.Alternate2MedProfessionalPhone__c = wishChildWrapperIns.alt2MedPhone;
            currLead.Alternate2HospitalTreatmentFacility__c = wishChildWrapperIns.alt2MedHosp;

            if (wishChildWrapperIns.vegetativeState == 'Yes') {
                currLead.RFI_Form_Info_Hidden__c = 'Not Qualified';
            }

            update currLead;
            insert diagnosisVerificationLstForInsert;
            insert diagnosisMedicalQuestionLst;

            if (diagnosisVerificationLst.size() > 0) {
                delete diagnosisVerificationLst;
            }

            loadData();

            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test');
            }
        } catch (Exception ex) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
        }
    }

    /*
     * @description     Used to place sign signature in the docusign page
     *
     * @author          unknown
     * @date            unknown
     */
    public pageReference SubmitSign() {
        String mySenderName = '';
        String myEmail = '';
        PageReference reference;

        try {
            if (wishChildWrapperIns.medProfTypeHid == 'Treating Medical Professional') {
                mySenderName = currLead.Treating_Medical_Professional_First_Name__c + ' ' + currLead.Treating_Medical_Professional_Last_Name__c;
                myEmail = currLead.Treating_Medical_Professional_Email__c;
            } else if (wishChildWrapperIns.medProfTypeHid == 'Best contact for Physician') {
                mySenderName = currLead.Best_Contact_for_Physician_First_Name__c + ' ' + currLead.Best_Contact_for_Physician_Last_Name__c;
                myEmail = currLead.Best_contact_for_Physician_Email__c;
            } else if (wishChildWrapperIns.medProfTypeHid == 'Alternate 1 Medical Professional') {
                mySenderName = currLead.Alternate1MedProfessionalFirstName__c + ' ' + currLead.Alternate1MedProfessionalLastName__c;
                myEmail = currLead.Alternate1MedicalProfessionalEmail__c;
            } else if (wishChildWrapperIns.medProfTypeHid == 'Alternate 2 Medical Professional') {
                mySenderName = currLead.Alternate2MedProfessionalFirstName__c + ' ' + currLead.Alternate2MedProfessionalLastName__c;
                myEmail = currLead.Alternate2MedProfessionalEmail__c;
            } else {
                mySenderName = currLead.Treating_Medical_Professional_First_Name__c + ' ' + currLead.Treating_Medical_Professional_Last_Name__c;
                myEmail = currLead.Treating_Medical_Professional_Email__c;
            }

            String account;
            String IntegratorKey;
            Map<String, DocuSignCredentialsSetting__c> credentialSetting = DocuSignCredentialsSetting__c.getAll();

            for (DocuSignCredentialsSetting__c credentialIns : credentialSetting.values()) {
                account = credentialIns.account__c;
                IntegratorKey = credentialIns.IntegratorKey__c;
            }

            String authorizationHeader = '<DocuSignCredentials><Username>{!$Credential.Username}</Username><Password>{!$Credential.Password}</Password><IntegratorKey>' + IntegratorKey + '</IntegratorKey></DocuSignCredentials>';

            String boundary = 'AAA';
            PageReference PDF = Page.LeadPartA_ApprovalForm_VF_PDF;
            PDF.getParameters().put('leadId', leadId);

            String documentPDF;

            if (!Test.isRunningTest()) {
                documentPDF = EncodingUtil.base64Encode(PDF.getContentAsPDF());
            } else {
                EncodingUtil.base64Encode(Blob.valueOf('Test'));
            }

            String body = '{' +
                '  "status":"sent",' +
                '  "enableWetSign": "false",' +
                '  "emailBlurb":"",' +
                '  "emailSubject": "Diagnosis Verification Form",' +
                '  "enforceSignerVisibility":"True",' +
                '  "documents": [{' +
                '      "name": "document.pdf",' +
                '      "documentId":"1",' +
                '      "order":"1",' +
                '      "documentBase64":"' + documentPDF + '"' +
                '  }],' +
                '"recipients": {' +
                '    "signers" : [{' +
                '      "email": "' + myEmail + '",' +
                '      "name": "' + mySenderName + '",' +
                '      "recipientId":"1",' +
                '      "clientUserId":"1",' +
                '      "tabs": {' +
                '                "signHereTabs": [{' +
                '                    "anchorString": "~s1",' +
                '                    "anchorXOffset": "0.1",' +
                '                    "anchorYOffset": "0.1",' +
                '                    "anchorIgnoreIfNotPresent": "false",' +
                '                    "anchorUnits": "inches"' +
                '                }],' +
                '                "dateSignedTabs": [{' +
                '                      "anchorString": "~date1",' +
                '                       "anchorXOffset": "0",' +
                '                       "fontSize":      "Size12",' +
                '                       "fontColor":     "Black",' +
                '                       "fonttype":     "Helvetica",' +
                '                        "anchorYOffset": "0",' +
                '                        "anchorIgnoreIfNotPresent": "false",' +
                '                        "xPosition": "100",' +
                '                        "yPosition": "72",' +
                '                        "anchorUnits": "inches"' +
                '                    }]' +
                '            }' +
                '    }]' +
                '  }' +
                '}';

            String header = '--' + boundary + '\nContent-Type: application/json\nContent-Disposition: form-data';
            String jsonBody = header + '\n\n' + body + '\n\n--' + boundary + '--';

            HttpRequest req = new HttpRequest();
            req.setHeader('X-DocuSign-Authentication', authorizationHeader);
            req.setHeader('Accept', 'application/json');
            req.setHeader('Host', 'demo.docusign.net');
            req.setHeader('Content-Length', '162100');
            req.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
            req.setEndpoint('Callout:Docusign_Credential/accounts/' + account + '/envelopes');
            req.setMethod('POST');
            req.setBody(jsonBody);
            Http http = new Http();
            HttpResponse res = new HttpResponse();

            if (!Test.isRunningTest()) {
                res = http.send(req);
            } else {
                res.setStatusCode(200);
                res.setBody('{"envelopeId":"Test"}');
            }

            if (res.getStatusCode() != 200 && res.getStatusCode() != 201) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
                ApexPages.addMessage(myMsg);
                return null;
            } else {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                if ((String) results.get('envelopeId') != '') {
                    String env = (String) results.get('envelopeId');
                    HttpRequest request = new HttpRequest();
                    request.setHeader('X-DocuSign-Authentication', authorizationHeader);
                    request.setHeader('Accept', 'application/json');
                    request.setHeader('Host', 'demo.docusign.net');
                    request.setHeader('Content-Length', '162100');
                    request.setHeader('Content-Type', 'application/json');
                    request.setMethod('POST');
                    Http httprequest = new Http();
                    HttpResponse response = new HttpResponse();
                    request.setEndpoint('Callout:Docusign_Credential/accounts/' + account + '/envelopes/' + env + '/views/recipient');

                    String jsonPayload;
                    jsonPayload = '{' +
                        '    "userName": "' + mySenderName + '",' +
                        '    "email": "' + myEmail + '",' +
                        '    "recipientId": "1",' +
                        '    "clientUserId": "1",' +
                        '    "authenticationMethod": "None",' +
                        '    "returnUrl": "' + Endpoints__c.getInstance().DVReturn_URL__c + '/verification_success' + '"' +
                        '}';

                    request.setBody(jsonPayload);

                    if (!Test.isRunningTest()) {
                        response = httprequest.send(request);
                    } else {
                        response.setStatusCode(200);
                        response.setBody('{"envelopeId":"Test"}');
                    }

                    if (response.getStatusCode() != 200 && res.getStatusCode() != 201) {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
                        ApexPages.addMessage(myMsg);
                        return null;
                    } else {
                        results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                        if ((String) results.get('url') != '' || (String) results.get('url') != null) {
                            dsfs__DocuSign_Status__c dsfs = NEW dsfs__DocuSign_Status__c();
                            dsfs.dsfs__DocuSign_Envelope_ID__c = env;
                            dsfs.dsfs__Lead__c = currLead.Id;

                            insert dsfs;

                            reference = new PageReference((String) results.get('url'));
                            return reference;
                        }
                    }
                }
            }

            if (Test.isRunningTest()) {
                throw new CommonTriggerException('Test Class execution');
            }
        } catch (Exception ex) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Debug_log_error_message);
            ApexPages.addMessage(myMsg);
            return null;
        }

        return reference;
    }

    /*
     * @description     Private function to select the Lead for the verification form.
     *                  This was moved out of loadData() to reduce the size of that function and improve readability.
     *
     * @param           Id leadId
     *
     * @return          Lead
     *
     * @author          Chris Shinnimin, Traction on Demand
     * @createdDate     2020-02-28
     */
    private Lead getCurrLead(Id leadId) {
        String query = 'SELECT ';

        final List<String> FIELDS_TO_SELECT = new List<String> {
            'Id',
            'Name',
            'FirstName',
            'LastName',
            'Email',
            'Phone',
            'Provided_additional_information__c',
            'Hidden_Proto_Pulmonary_Hypertension__c',
            'Diagnosis_Given_By_Referrer__c',
            'ICD_Given_By_Referrer__c',
            'ICD_Given_By_Referrer__r.Name',
            'RFI_Form_Info_Hidden__c',
            'Override_Dupe_Check__c',
            'isConverted',
            'Please_Explain_Deteriorate__c',
            'Expedite_timeframe__c',
            'Other_expedite_timeframe_comments__c'
        };

        for (String field : FIELDS_TO_SELECT) {
            query += field + ',';
        }

        for (Schema.FieldSetMember currField : Utils.getPartAFields()) { 
            query += currField.getFieldPath() + ',';
        }

        query = query.removeEnd(',');
        query += ' FROM Lead WHERE Id = :leadId';

        return Database.query(query);
    }
}
