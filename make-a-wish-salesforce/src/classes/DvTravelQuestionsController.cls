/**
 * @description Travel Algorithm and Current Condtion Controller
 * @author Christopher Smith, Make-A-Wish America
 * @createdDate 02/10/2021
 */

public without sharing class DvTravelQuestionsController {
  private static final String DOT_SPACE = '. ';
  //private static Map<String, String> travelAlgorithmFieldMap;

  /**
   * @description Creates a new TravelAlgorithm Wrapper
   * @author Christopher Smith, MAWA
   * @createdDate Feb/10/2021
   * @param leadId
   * @return TravelQuestionsWrapper
   */
  @AuraEnabled(Cacheable=true)
  public static TravelQuestionsWrapper getTravelWrapperByLead(String leadId) {
    //try {
    return setLoadValues(leadId);
    /* } catch (Exception e) {
      ErrorMessage_AC.createDebugRec(
        'dvTravelQuestionsController',
        '',
        String.valueOf(e),
        'getTravelWrapperByLead',
        'Null',
        e.getStackTraceString(),
        'Error'
      );
      return newTravelQuestionsWrapper();
    } */
  }

  /**
   * @description Fills a new TravelQuestionWrapper with values from the specified lead and returns the wrapper
   */
  private static TravelQuestionsWrapper setLoadValues(String leadToFetch) {
    Lead wishChild = [
      SELECT
        id,
        Lung_Disease__c,
        Pulmonary_Hypertension__c,
        Ventilator__c,
        Angina__c,
        Arrhythmia__c,
        Heart_Failure__c,
        Chronic_Heart_Failure__c,
        Congenital_Heart_Disease__c,
        Chronic_Hepatitis__c,
        Hidden_Proto_Pulmonary_Hypertension__c,
        Strokes__c,
        Convulsive_Disorders__c,
        Travel_Restriction__c,
        Current_Condition_Label__c,
        Travel_Algorithm__c
      FROM Lead
      WHERE id = :leadToFetch
    ];
    Map<String, String> travelAlgorithmFieldMap = new Map<String, String>();
    TravelQuestionsWrapper wrapper = new TravelQuestionsWrapper();

    wrapper.leadId = leadToFetch;

    if (!String.isBlank(wishChild.lung_disease__c)) {
      wrapper.lungDiseaseSelections = wishChild.lung_disease__c.split(';');
      wrapper.isLungDisease = true;
    } else {
      wrapper.lungDiseaseSelections = new List<String>();
      wrapper.isLungDisease = false;
    }

    //some of the values are not stored to individual fields and are only listed in the Current Condition Label
    //this can be moved to a helper method and perhaps a helper Class? For length alone and SOC.
    if (!String.isBlank(wishChild.Travel_Algorithm__c)) {
      for (String condition : wishChild.Travel_Algorithm__c.split(';')) {
        if (!travelAlgorithmFieldMap.containsKey(condition)) {
          travelAlgorithmFieldMap.put(condition, condition);
        }
      }
    }

    wrapper.isTuberculosisChecked = travelAlgorithmFieldMap.containsKey(
        Constant_AC.INFECTIOUS_TUBERCULOSIS
      )
      ? true
      : false;
    wrapper.isAirborneChecked = travelAlgorithmFieldMap.containsKey(
        Constant_AC.AIRBORNE_VIRAL_INFECTIONS_OF_HIGH_MORTALITY
      )
      ? true
      : false;
    wrapper.isPneumothoraxChecked = travelAlgorithmFieldMap.containsKey(
        Constant_AC.PNEUMOTHORAX
      )
      ? true
      : false;
    wrapper.isPleuralEffusionChecked = travelAlgorithmFieldMap.containsKey(
        Constant_AC.PLEURAL_EFFUSION
      )
      ? true
      : false;
    wrapper.isOxygenDependenceChecked = travelAlgorithmFieldMap.containsKey(
        Constant_AC.OXYGEN_DEPENDENCE_AT_SEA_LEVEL
      )
      ? true
      : false;
    wrapper.isOxygenRequiredGreaterThan4 = travelAlgorithmFieldMap.containsKey(
        Constant_AC.OXYGEN_REQUIREMENT_4L_MIN_AT_SEA_LEVEL
      )
      ? true
      : false;
    wrapper.isLongTermOxygenChecked = travelAlgorithmFieldMap.containsKey(
        Constant_AC.LONG_TERM_OXYGEN_WITHIN_LAST_6_MONTHS
      )
      ? true
      : false;
    wrapper.isAcuteRespiratoryHospitalizationChecked = travelAlgorithmFieldMap.containsKey(
        Constant_AC.HOSPITALIZATION_FOR_ACUTE_RESPIRATORY
      )
      ? true
      : false;
    if (!String.isBlank(wishChild.Pulmonary_Hypertension__c)) {
      wrapper.pulmonaryHypertensionSelection = wishChild.Pulmonary_Hypertension__c;
      wrapper.isPulmonaryHypertensionChecked = true;
    } else {
      wrapper.pulmonaryHypertensionSelection = '';
      wrapper.isPulmonaryHypertensionChecked = false;
    }
    if (!String.isBlank(wishChild.Ventilator__c)) {
      wrapper.isVentilatorDependenceChecked = true;
      wrapper.ventilatorDependenceSelection = wishChild.Ventilator__c;
    } else {
      wrapper.isVentilatorDependenceChecked = false;
      wrapper.ventilatorDependenceSelection = '';
    }
    if (!String.isBlank(wishChild.angina__c)) {
      wrapper.isChestPainChecked = true;
      wrapper.chestPainSelections = wishChild.angina__c.split(';');
    } else {
      wrapper.isChestPainChecked = false;
      wrapper.chestPainSelections = new List<String>();
    }
    if (!String.isBlank(wishChild.arrhythmia__c)) {
      wrapper.isArrhythmiaChecked = true;
      wrapper.arrhythmiaSelections = wishChild.arrhythmia__c.split(';');
    } else {
      wrapper.isArrhythmiaChecked = false;
      wrapper.arrhythmiaSelections = new List<String>();
    }
    if (!String.isBlank(wishChild.Heart_Failure__c)) {
      wrapper.isAcuteHeartFailureChecked = true;
      wrapper.acuteHeartFailureSelections = wishChild.Heart_Failure__c.split(
        ';'
      );
    } else {
      wrapper.isAcuteHeartFailureChecked = false;
      wrapper.acuteHeartFailureSelections = new List<String>();
    }
    if (!String.isBlank(wishChild.Chronic_Heart_Failure__c)) {
      wrapper.isChronicHeartFailureChecked = true;
      wrapper.chronicHeartFailureSelections = wishChild.Chronic_Heart_Failure__c.split(
        ';'
      );
    } else {
      wrapper.isChronicHeartFailureChecked = false;
      wrapper.chronicHeartFailureSelections = new List<String>();
    }
    if (!String.isBlank(wishChild.Congenital_Heart_Disease__c)) {
      wrapper.isCyanoticHeartDiseaseChecked = true;
      wrapper.cyanoticHeartDiseaseSelections = wishChild.Congenital_Heart_Disease__c.split(
        ';'
      );
    } else {
      wrapper.isCyanoticHeartDiseaseChecked = false;
      wrapper.cyanoticHeartDiseaseSelections = new List<String>();
    }

    wrapper.isUncontrolledHypertensionChecked = travelAlgorithmFieldMap.containsKey(
        Constant_AC.SEVERE_UNCONTROLLED_HYPERTENSION
      )
      ? true
      : false;

    if (!String.isBlank(wishChild.Chronic_Hepatitis__c)) {
      wrapper.isHepatitisChecked = true;
      wrapper.hepatitisSelection = wishChild.Chronic_Hepatitis__c;
    } else {
      wrapper.isHepatitisChecked = false;
      wrapper.hepatitisSelection = '';
    }

    wrapper.isPortalHypertensionChecked = travelAlgorithmFieldMap.containsKey(
        Constant_AC.PORTAL_HYPERTENSION
      )
      ? true
      : false;
    wrapper.isHeptopulmonaryChecked = travelAlgorithmFieldMap.containsKey(
        Constant_AC.HEPTOPULMONARY_SYNDROME
      )
      ? true
      : false;

    wrapper.isLiverDiseaseChecked = travelAlgorithmFieldMap.containsKey(
        Constant_AC.CHRONIC_LIVER_DISEASE
      )
      ? true
      : false;

    wrapper.isEndStageLiverChecked = travelAlgorithmFieldMap.containsKey(
        Constant_AC.END_STAGE_LIVER_DISEASE
      )
      ? true
      : false;

    wrapper.isEsophogealVaricesChecked = travelAlgorithmFieldMap.containsKey(
        Constant_AC.ESOPHAGEAL_VARICES_OR_HISTORY_OF
      )
      ? true
      : false;

    if (!String.isBlank(wishChild.Hidden_Proto_Pulmonary_Hypertension__c)) {
      wrapper.isPortopulmonaryChecked = true;
      wrapper.portopulmonarySelection = wishChild.Hidden_Proto_Pulmonary_Hypertension__c;
    } else {
      wrapper.isPortopulmonaryChecked = false;
      wrapper.portopulmonarySelection = '';
    }
    wrapper.isIntracranialPressureChecked = travelAlgorithmFieldMap.containsKey(
        Constant_AC.INCREASED_INTRACRANIAL_PRESSURE
      )
      ? true
      : false;

    if (!String.isBlank(wishChild.Strokes__c)) {
      wrapper.isStrokeChecked = true;
      wrapper.strokeSelection = wishChild.Strokes__c;
    } else {
      wrapper.isStrokeChecked = false;
      wrapper.strokeSelection = '';
    }

    if (!String.isBlank(wishChild.Convulsive_Disorders__c)) {
      wrapper.isConvulsiveDisorderChecked = true;
      wrapper.convulsiveDisorderSelections = wishChild.Convulsive_Disorders__c.split(
        ';'
      );
    } else {
      wrapper.isConvulsiveDisorderChecked = false;
      wrapper.convulsiveDisorderSelections = new List<String>();
    }
    wrapper.isPanicDisorderChecked = travelAlgorithmFieldMap.containsKey(
        Constant_AC.PANIC_DISORDER
      )
      ? true
      : false;
    wrapper.isMajorBleedingChecked = travelAlgorithmFieldMap.containsKey(
        Constant_AC.MAJOR_BLEEDING
      )
      ? true
      : false;
    wrapper.isSymptomaticAnemiaChecked = travelAlgorithmFieldMap.containsKey(
        Constant_AC.SYMPTOMATIC_ANEMIA
      )
      ? true
      : false;
    wrapper.isSickleCellChecked = travelAlgorithmFieldMap.containsKey(
        Constant_AC.SICKLE_CELL_ANEMIA
      )
      ? true
      : false;
    wrapper.isSurgeryChecked = travelAlgorithmFieldMap.containsKey(
        Constant_AC.SURGERY_IN_THE_PAST_2_MONTHS
      )
      ? true
      : false;

    wrapper.isMedicallyFragileChecked = travelAlgorithmFieldMap.containsKey(
        Constant_AC.MEDICALLY_FRAGILE_MEDICALLY_COMPLEX
      )
      ? true
      : false;
    wrapper.isNotSureChecked = travelAlgorithmFieldMap.containsKey(
        Constant_AC.I_AM_NOT_SURE
      )
      ? true
      : false;
    wrapper.isNoneChecked = travelAlgorithmFieldMap.containsKey(
        Constant_AC.NONE_APPLY
      )
      ? true
      : false;
    return wrapper;
  }

  /**
   * @description Recieves filled wrapper and updates the specified Lead with selected values
   * @author Christopher Smith, MAWA
   * @createdDate Feb/22/2021
   * @param TravelQuestionsWrapper wrapper
   */
  @AuraEnabled
  public static void saveTravelQuestionData(TravelQuestionsWrapper wrapper) {
    List<Medical_Questions__c> travelConditions = [
      SELECT id, current_condition__c, recommendation_to_chapter__c
      FROM Medical_Questions__c
      WHERE recordTypeId = :Constant_AC.TRAVEL_ALGM_RT_ID
    ];
    Map<String, String> conditionsToRecommendations = new Map<String, String>();
    String algorithmString = '';
    String conditionString = '';
    String recommendationString = '';
    Integer conditionCount = 1;

    Lead wishChild = [
      SELECT
        id,
        Lung_Disease__c,
        Pulmonary_Hypertension__c,
        Ventilator__c,
        Angina__c,
        Arrhythmia__c,
        Heart_Failure__c,
        Chronic_Heart_Failure__c,
        Congenital_Heart_Disease__c,
        Chronic_Hepatitis__c,
        Hidden_Proto_Pulmonary_Hypertension__c,
        Strokes__c,
        Convulsive_Disorders__c,
        Travel_Restriction__c,
        Current_Condition_Label__c,
        Travel_Algorithm__c
      FROM Lead
      WHERE id = :wrapper.leadId
    ];

    //fill map with medical question records for translating conditions to recommendations
    if (!travelConditions.isEmpty()) {
      for (Medical_Questions__c condition : travelConditions) {
        conditionsToRecommendations.put(
          condition.current_condition__c,
          condition.recommendation_to_chapter__c
        );
      }
    }

    //algorithmString stores all of the values selected if the selection is one that does not have it's own field on the lead.
    //Values are separated by semicolons
    if (wrapper.isNoneChecked) {
      algorithmString = Constant_AC.NONE_APPLY;
    } else {
      algorithmString = wrapper.isTuberculosisChecked
        ? algorithmString += Constant_AC.INFECTIOUS_TUBERCULOSIS + ';'
        : algorithmString;
      algorithmString = wrapper.isAirborneChecked
        ? algorithmString +=
            Constant_AC.AIRBORNE_VIRAL_INFECTIONS_OF_HIGH_MORTALITY + ';'
        : algorithmString;
      algorithmString = wrapper.isPneumothoraxChecked
        ? algorithmString += Constant_AC.PNEUMOTHORAX + ';'
        : algorithmString;
      algorithmString = wrapper.isPleuralEffusionChecked
        ? algorithmString += Constant_AC.PLEURAL_EFFUSION + ';'
        : algorithmString;
      algorithmString = wrapper.isOxygenDependenceChecked
        ? algorithmString += Constant_AC.OXYGEN_DEPENDENCE_AT_SEA_LEVEL + ';'
        : algorithmString;
      algorithmString = wrapper.isOxygenRequiredGreaterThan4
        ? algorithmString +=
            Constant_AC.OXYGEN_REQUIREMENT_4L_MIN_AT_SEA_LEVEL + ';'
        : algorithmString;
      algorithmString = wrapper.isLongTermOxygenChecked
        ? algorithmString +=
            Constant_AC.LONG_TERM_OXYGEN_WITHIN_LAST_6_MONTHS + ';'
        : algorithmString;
      algorithmString = wrapper.isAcuteRespiratoryHospitalizationChecked
        ? algorithmString +=
            Constant_AC.HOSPITALIZATION_FOR_ACUTE_RESPIRATORY + ';'
        : algorithmString;
      algorithmString = wrapper.isUncontrolledHypertensionChecked
        ? algorithmString += Constant_AC.SEVERE_UNCONTROLLED_HYPERTENSION + ';'
        : algorithmString;
      algorithmString = wrapper.isPortalHypertensionChecked
        ? algorithmString += Constant_AC.PORTAL_HYPERTENSION + ';'
        : algorithmString;
      algorithmString = wrapper.isHeptopulmonaryChecked
        ? algorithmString += Constant_AC.HEPTOPULMONARY_SYNDROME + ';'
        : algorithmString;
      algorithmString = wrapper.isLiverDiseaseChecked
        ? algorithmString += Constant_AC.END_STAGE_LIVER_DISEASE + ';'
        : algorithmString;
      algorithmString = wrapper.isEndStageLiverChecked
        ? algorithmString += Constant_AC.END_STAGE_LIVER_DISEASE + ';'
        : algorithmString;
      algorithmString = wrapper.isEsophogealVaricesChecked
        ? algorithmString += Constant_AC.ESOPHAGEAL_VARICES_OR_HISTORY_OF + ';'
        : algorithmString;
      algorithmString = wrapper.isIntracranialPressureChecked
        ? algorithmString += Constant_AC.INCREASED_INTRACRANIAL_PRESSURE + ';'
        : algorithmString;
      algorithmString = wrapper.isPanicDisorderChecked
        ? algorithmString += Constant_AC.PANIC_DISORDER + ';'
        : algorithmString;
      algorithmString = wrapper.isMajorBleedingChecked
        ? algorithmString += Constant_AC.MAJOR_BLEEDING + ';'
        : algorithmString;
      algorithmString = wrapper.isSymptomaticAnemiaChecked
        ? algorithmString += Constant_AC.SYMPTOMATIC_ANEMIA + ';'
        : algorithmString;
      algorithmString = wrapper.isSickleCellChecked
        ? algorithmString += Constant_AC.SICKLE_CELL_ANEMIA + ';'
        : algorithmString;
      algorithmString = wrapper.isSurgeryChecked
        ? algorithmString += Constant_AC.SURGERY_IN_THE_PAST_2_MONTHS + ';'
        : algorithmString;
      algorithmString = wrapper.isMedicallyFragileChecked
        ? algorithmString +=
            Constant_AC.MEDICALLY_FRAGILE_MEDICALLY_COMPLEX + ';'
        : algorithmString;
      algorithmString = wrapper.isNotSureChecked
        ? algorithmString += Constant_AC.I_AM_NOT_SURE + ';'
        : algorithmString;

      if (!String.isBlank(algorithmString)) {
        algorithmString.removeEnd(';');
      }
    }
    wishChild.Travel_Algorithm__c = algorithmString;

    //algorithmString contains only the conditions that were selected at the time save was called.
    //Perform the translation and store
    for (String condition : algorithmString.split(';')) {
      conditionString +=
        Integer.valueOf(conditionCount) +
        DOT_SPACE +
        condition +
        '\n';
      recommendationString +=
        Integer.valueOf(conditionCount) +
        DOT_SPACE +
        conditionsToRecommendations.get(condition) +
        '\n';
      conditionCount += 1;
    }

    //process lung disease subselections
    wishChild.lung_disease__c = String.join(wrapper.lungDiseaseSelections, ';');
    if (!wrapper.lungDiseaseSelections.isEmpty()) {
      for (String lungSelection : wrapper.lungDiseaseSelections) {
        if (!conditionString.contains(lungSelection)) {
          conditionString +=
            Integer.valueOf(conditionCount) +
            DOT_SPACE +
            Constant_AC.SEVERE_RESTRICTIVE_LUNG_DISEASE +
            ': ' +
            lungSelection +
            '\n';
          recommendationString +=
            Integer.valueOf(conditionCount) +
            DOT_SPACE +
            conditionsToRecommendations.get(lungSelection) +
            '\n';
          conditionCount += 1;
        }
      }
    }

    //process pulmonary hypertension subselection
    wishChild.Pulmonary_Hypertension__c = wrapper.pulmonaryHypertensionSelection;
    if (
      !String.isBlank(wrapper.pulmonaryHypertensionSelection) &&
      !conditionString.contains(wrapper.pulmonaryHypertensionSelection)
    ) {
      conditionString +=
        Integer.valueOf(conditionCount) +
        DOT_SPACE +
        Constant_AC.PULMONARY_HYPERTENSION +
        ': ' +
        wrapper.pulmonaryHypertensionSelection +
        '\n';
      recommendationString +=
        Integer.valueOf(conditionCount) +
        DOT_SPACE +
        conditionsToRecommendations.get(
          wrapper.pulmonaryHypertensionSelection
        ) +
        '\n';
      conditionCount += 1;
    }

    //process ventilator subselection
    wishChild.Ventilator__c = wrapper.ventilatorDependenceSelection;
    if (!String.isBlank(wrapper.ventilatorDependenceSelection)) {
      conditionString +=
        Integer.valueOf(conditionCount) +
        DOT_SPACE +
        Constant_AC.VENTILATOR_DEPENDENCE +
        ': ' +
        wrapper.ventilatorDependenceSelection +
        '\n';
      recommendationString +=
        Integer.valueOf(conditionCount) +
        DOT_SPACE +
        conditionsToRecommendations.get(wrapper.ventilatorDependenceSelection) +
        '\n';
      conditionCount += 1;
    }

    //The remaining conditions have their own field to store the information
    //The conditions are one per line and formatted like this: <condition>: <subselection>;

    wishChild.angina__c = String.join(wrapper.chestPainSelections, ';');
    if (!wrapper.chestPainSelections.isEmpty()) {
      for (String selection : wrapper.chestPainSelections) {
        if (!conditionString.contains(selection)) {
          conditionString +=
            Integer.valueOf(conditionCount) +
            DOT_SPACE +
            Constant_AC.CHEST_PAIN_ANGINA +
            ': ' +
            selection +
            '\n';
          recommendationString +=
            Integer.valueOf(conditionCount) +
            DOT_SPACE +
            conditionsToRecommendations.get(selection) +
            '\n';
          conditionCount += 1;
        }
      }
    }

    wishChild.arrhythmia__c = String.join(wrapper.arrhythmiaSelections, ';');
    if (!wrapper.arrhythmiaSelections.isEmpty()) {
      for (String selection : wrapper.arrhythmiaSelections) {
        if (!conditionString.contains(selection)) {
          conditionString +=
            Integer.valueOf(conditionCount) +
            DOT_SPACE +
            Constant_AC.ARRHYTHMIA +
            ': ' +
            selection +
            '\n';
          recommendationString +=
            Integer.valueOf(conditionCount) +
            DOT_SPACE +
            conditionsToRecommendations.get(selection) +
            '\n';
          conditionCount += 1;
        }
      }
    }

    wishChild.Heart_Failure__c = String.join(
      wrapper.acuteHeartFailureSelections,
      ';'
    );
    if (!wrapper.acuteHeartFailureSelections.isEmpty()) {
      for (String selection : wrapper.acuteHeartFailureSelections) {
        if (!conditionString.contains(selection)) {
          conditionString +=
            Integer.valueOf(conditionCount) +
            DOT_SPACE +
            Constant_AC.ACUTE_HEART_FAILURE +
            ': ' +
            selection +
            '\n';
          recommendationString +=
            Integer.valueOf(conditionCount) +
            DOT_SPACE +
            conditionsToRecommendations.get(selection) +
            '\n';
          conditionCount += 1;
        }
      }
    }

    wishChild.Chronic_Heart_Failure__c = String.join(
      wrapper.chronicHeartFailureSelections,
      ';'
    );
    if (!wrapper.chronicHeartFailureSelections.isEmpty()) {
      for (String selection : wrapper.chronicHeartFailureSelections) {
        if (!conditionString.contains(selection)) {
          conditionString +=
            Integer.valueOf(conditionCount) +
            DOT_SPACE +
            Constant_AC.CHRONIC_HEART_FAILURE +
            ': ' +
            selection +
            '\n';
          recommendationString +=
            Integer.valueOf(conditionCount) +
            DOT_SPACE +
            conditionsToRecommendations.get(selection) +
            '\n';
          conditionCount += 1;
        }
      }
    }

    wishChild.Congenital_Heart_Disease__c = String.join(
      wrapper.cyanoticHeartDiseaseSelections,
      ';'
    );
    if (!wrapper.cyanoticHeartDiseaseSelections.isEmpty()) {
      for (String selection : wrapper.cyanoticHeartDiseaseSelections) {
        if (!conditionString.contains(selection)) {
          conditionString +=
            Integer.valueOf(conditionCount) +
            DOT_SPACE +
            Constant_AC.CYANOTIC_CONGENITAL_HEART_DISEASE +
            ': ' +
            wrapper.cyanoticHeartDiseaseSelections +
            '\n';
          recommendationString +=
            Integer.valueOf(conditionCount) +
            DOT_SPACE +
            conditionsToRecommendations.get(selection) +
            '\n';
          conditionCount += 1;
        }
      }
    }

    wishChild.Chronic_Hepatitis__c = wrapper.hepatitisSelection;
    if (!String.isBlank(wrapper.hepatitisSelection)) {
      conditionString +=
        Integer.valueOf(conditionCount) +
        DOT_SPACE +
        Constant_AC.ACUTE_OR_CHRONIC_HEPATITIS +
        ': ' +
        wrapper.hepatitisSelection +
        '\n';
      recommendationString +=
        Integer.valueOf(conditionCount) +
        DOT_SPACE +
        conditionsToRecommendations.get(wrapper.hepatitisSelection) +
        '\n';
      conditionCount += 1;
    }

    wishChild.Hidden_Proto_Pulmonary_Hypertension__c = wrapper.portopulmonarySelection;
    if (!String.isBlank(wrapper.hepatitisSelection)) {
      conditionString +=
        Integer.valueOf(conditionCount) +
        DOT_SPACE +
        Constant_AC.ACUTE_OR_CHRONIC_HEPATITIS +
        ': ' +
        wrapper.hepatitisSelection +
        '\n';
      recommendationString +=
        Integer.valueOf(conditionCount) +
        DOT_SPACE +
        conditionsToRecommendations.get(wrapper.hepatitisSelection) +
        '\n';
      conditionCount += 1;
    }

    wishChild.Strokes__c = wrapper.strokeSelection;
    if (!String.isBlank(wrapper.strokeSelection)) {
      conditionString +=
        Integer.valueOf(conditionCount) +
        DOT_SPACE +
        Constant_AC.TRANSIENT_ISCHEMIC_ATTACKS_OR_STROKES +
        ': ' +
        wrapper.strokeSelection +
        '\n';
      recommendationString +=
        Integer.valueOf(conditionCount) +
        DOT_SPACE +
        conditionsToRecommendations.get(wrapper.strokeSelection) +
        '\n';
      conditionCount += 1;
    }

    wishChild.Convulsive_Disorders__c = String.join(
      wrapper.convulsiveDisorderSelections,
      ';'
    );
    if (!wrapper.convulsiveDisorderSelections.isEmpty()) {
      for (String selection : wrapper.convulsiveDisorderSelections) {
        if (!conditionString.contains(selection)) {
          conditionString +=
            Integer.valueOf(conditionCount) +
            DOT_SPACE +
            Constant_AC.UNSTABLE_OR_UNCONTROLLED_EPILEPSY +
            ': ' +
            selection +
            '\n';
          recommendationString +=
            Integer.valueOf(conditionCount) +
            DOT_SPACE +
            conditionsToRecommendations.get(selection) +
            '\n';
          conditionCount += 1;
        }
      }
    }

    wishChild.Travel_Algorithm__c = algorithmString;
    wishChild.Current_Condition_Label__c = conditionString;
    wishChild.travel_restriction__c = recommendationString;

    try {
      update wishChild;
    } catch (Exception e) {
      ErrorMessage_AC.createDebugRec(
        'DvTravelQuestionsController',
        String.valueOf(wishChild.id),
        String.valueOf(e),
        'saveTravelQuestionData',
        wishChild.id,
        e.getStackTraceString() +
        ' ' +
        e.getMessage(),
        'Error'
      );
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description Simple Wrapper Class containing a lead id and travel question related values
   * @author Christopher Smith, MAWA
   * @createdDate 10/Feb/2021
   */
  public class TravelQuestionsWrapper {
    @AuraEnabled
    public String leadId { get; set; }

    @AuraEnabled
    public Boolean isLungDisease { get; set; }

    @AuraEnabled
    public List<String> lungDiseaseSelections { get; set; }

    @auraEnabled
    public Boolean isTuberculosisChecked { get; set; }

    @AuraEnabled
    public Boolean isAirborneChecked { get; set; }

    @AuraEnabled
    public Boolean isPneumothoraxChecked { get; set; }

    @AuraEnabled
    public Boolean isPleuralEffusionChecked { get; set; }

    @AuraEnabled
    public Boolean isOxygenRequiredGreaterThan4 { get; set; }

    @AuraEnabled
    public Boolean isLongTermOxygenChecked { get; set; }

    @AuraEnabled
    public Boolean isAcuteRespiratoryHospitalizationChecked { get; set; }

    @AuraEnabled
    public Boolean isPulmonaryHypertensionChecked { get; set; }

    @AuraEnabled
    public String pulmonaryHypertensionSelection { get; set; }

    @AuraEnabled
    public Boolean isOxygenDependenceChecked { get; set; }

    @AuraEnabled
    public Boolean isVentilatorDependenceChecked { get; set; }

    @AuraEnabled
    public String ventilatorDependenceSelection { get; set; }

    @AuraEnabled
    public Boolean isChestPainChecked { get; set; }

    @AuraEnabled
    public List<String> chestPainSelections { get; set; }

    @AuraEnabled
    public Boolean isArrhythmiaChecked { get; set; }

    @AuraEnabled
    public List<String> arrhythmiaSelections { get; set; }

    @AuraEnabled
    public Boolean isAcuteHeartFailureChecked { get; set; }

    @AuraEnabled
    public List<String> acuteHeartFailureSelections { get; set; }

    @AuraEnabled
    public Boolean isChronicHeartFailureChecked { get; set; }

    @AuraEnabled
    public List<String> chronicHeartFailureSelections { get; set; }

    @AuraEnabled
    public Boolean isCyanoticHeartDiseaseChecked { get; set; }

    @AuraEnabled
    public List<String> cyanoticHeartDiseaseSelections { get; set; }

    @AuraEnabled
    public Boolean isUncontrolledHypertensionChecked { get; set; }

    @AuraEnabled
    public Boolean isHepatitisChecked { get; set; }

    @AuraEnabled
    public String hepatitisSelection { get; set; }

    @AuraEnabled
    public Boolean isPortalHypertensionChecked { get; set; }

    @AuraEnabled
    public Boolean isHeptopulmonaryChecked { get; set; }

    @AuraEnabled
    public Boolean isLiverDiseaseChecked { get; set; }

    @AuraEnabled
    public Boolean isEndStageLiverChecked { get; set; }

    @AuraEnabled
    public Boolean isEsophogealVaricesChecked { get; set; }

    @AuraEnabled
    public Boolean isPortopulmonaryChecked { get; set; }

    @AuraEnabled
    public String portopulmonarySelection { get; set; }

    @AuraEnabled
    public Boolean isIntracranialPressureChecked { get; set; }

    @AuraEnabled
    public Boolean isStrokeChecked { get; set; }

    @AuraEnabled
    public String strokeSelection { get; set; }

    @AuraEnabled
    public Boolean isConvulsiveDisorderChecked { get; set; }

    @AuraEnabled
    public List<String> convulsiveDisorderSelections { get; set; }

    @AuraEnabled
    public Boolean isPanicDisorderChecked { get; set; }

    @AuraEnabled
    public Boolean isMajorBleedingChecked { get; set; }

    @AuraEnabled
    public Boolean isSymptomaticAnemiaChecked { get; set; }

    @AuraEnabled
    public Boolean isSickleCellChecked { get; set; }

    @AuraEnabled
    public Boolean isSurgeryChecked { get; set; }

    @AuraEnabled
    public Boolean isMedicallyFragileChecked { get; set; }

    @AuraEnabled
    public Boolean isNotSureChecked { get; set; }

    @AuraEnabled
    public Boolean isNoneChecked { get; set; }
  }
}