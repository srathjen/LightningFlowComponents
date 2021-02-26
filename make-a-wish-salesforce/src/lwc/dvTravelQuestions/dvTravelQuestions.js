/**
@description Travel Questions Component, provides conditions and recommended travel restrictions for wish children
@author Christopher Smith, MAWA
@createdDate 10/Feb/2021
*/

import { api, LightningElement, wire } from "lwc";
import getTravelQuestions from "@salesforce/apex/DvTravelQuestionsController.getTravelWrapperByLead";
import saveTravelQuestions from "@salesforce/apex/DvTravelQuestionsController.saveTravelQuestionData";

export default class DvTravelQuestions extends LightningElement {
  /**
   * Properties
   */
  leadId;
  lungDiseaseSelections = [""];
  isLungDisease = false;
  isTuberculosisChecked = false;
  isAirborneChecked = false;
  isPneumothoraxChecked = false;
  isPleuralEffusionChecked = false;
  isOxygenDependenceChecked = false;
  isOxygenRequiredGreaterThan4 = false;
  isLongTermOxygenChecked = false;
  isAcuteRespiratoryHospitalizationChecked = false;
  isPulmonaryHypertensionChecked = false;
  pulmonaryHypertensionSelection = "";
  isVentilatorDependenceChecked = false;
  ventilatorDependenceSelection = "";
  isChestPainChecked = false;
  chestPainSelections = [""];
  isArrhythmiaChecked = false;
  arrhythmiaSelections = [""];
  isAcuteHeartFailureChecked = false;
  acuteHeartFailureSelections = [""];
  isChronicHeartFailureChecked = false;
  chronicHeartFailureSelections = [""];
  isCyanoticHeartDiseaseChecked = false;
  cyanoticHeartDiseaseSelections = [""];
  isUncontrolledHypertensionChecked = false;
  isHepatitisChecked = false;
  hepatitisSelection = "";
  isPortalHypertensionChecked = false;
  isHeptopulmonaryChecked = false;
  isLiverDiseaseChecked = false;
  isEndStageLiverChecked = false;
  isEsophogealVaricesChecked = false;
  isPortopulmonaryChecked = false;
  portopulmonarySelection = "";
  isIntracranialPressureChecked = false;
  isStrokeChecked = false;
  strokeSelection = "";
  isConvulsiveDisorderChecked = false;
  convulsiveDisorderSelections = [""];
  isPanicDisorderChecked = false;
  isMajorBleedingChecked = false;
  isSymptomaticAnemiaChecked = false;
  isSickleCellChecked = false;
  isSurgeryChecked = false;
  isMedicallyFragileChecked = false;
  isNotSureChecked = false;
  isNoneChecked = false;
  arePrimaryConditionsChecked = false;

  @api handleLoadTravelQuestions(leadId) {
    this.leadId = leadId;
  }

  @wire(getTravelQuestions, { leadId: "$leadId" })
  wired(result) {
    if (result.data) {
      this.lungDiseaseSelections = result.data.lungDiseaseSelections;
      this.isLungDisease = result.data.isLungDisease;
      this.showHideLungDiseaseCheckboxSet();
      this.isTuberculosisChecked = result.data.isTuberculosisChecked;
      this.isAirborneChecked = result.data.isAirborneChecked;
      this.isPneumothoraxChecked = result.data.isPneumothoraxChecked;
      this.isPleuralEffusionChecked = result.data.isPleuralEffusionChecked;
      this.isOxygenDependenceChecked = result.data.isOxygenDependenceChecked;
      this.isOxygenRequiredGreaterThan4 =
        result.data.isOxygenRequiredGreaterThan4;
      this.isLongTermOxygenChecked = result.data.isLongTermOxygenChecked;
      this.isAcuteRespiratoryHospitalizationChecked =
        result.data.isAcuteRespiratoryHospitalizationChecked;
      this.isPulmonaryHypertensionChecked =
        result.data.isPulmonaryHypertensionChecked;
      this.pulmonaryHypertensionSelection =
        result.data.pulmonaryHypertensionSelection;
      this.showHidePulmonaryHypertensionCombobox();
      this.isVentilatorDependenceChecked =
        result.data.isVentilatorDependenceChecked;
      this.ventilatorSelection = result.data.ventilatorDependenceSelection;
      this.showHideVentilatorDependenceCombobox();
      this.isChestPainChecked = result.data.isChestPainChecked;
      this.chestPainSelections = result.data.chestPainSelections;
      this.showHideChestPainCheckboxset();
      this.isArrhythmiaChecked = result.data.isArrhythmiaChecked;
      this.arrhythmiaSelections = result.data.arrhythmiaSelections;
      this.showHideArrhythmiaCheckboxset();
      this.isAcuteHeartFailureChecked = result.data.isAcuteHeartFailureChecked;
      this.acuteHeartFailureSelections =
        result.data.acuteHeartFailureSelections;
      this.showHideAcuteHeartFailureCheckboxset();
      this.isChronicHeartFailureChecked =
        result.data.isChronicHeartFailureChecked;
      this.chronicHeartFailureSelections =
        result.data.chronicHeartFailureSelections;
      this.showHideChronicHeartFailureCheckboxset();
      this.isCyanoticHeartDiseaseChecked =
        result.data.isCyanoticHeartDiseaseChecked;
      this.cyanoticHeartDiseaseSelections =
        result.data.cyanoticHeartDiseaseSelections;
      this.showHideCyanoticHeartDiseaseCheckboxset();
      this.isUncontrolledHypertensionChecked =
        result.data.isUncontrolledHypertensionChecked;
      this.isHepatitisChecked = result.data.isHepatitisChecked;
      this.hepatitisSelection = result.data.hepatitisSelection;
      this.showHideHepatitisCombobox();
      this.isPortalHypertensionChecked =
        result.data.isPortalHypertensionChecked;
      this.isHeptopulmonaryChecked = result.data.isHeptopulmonaryChecked;
      this.isLiverDiseaseChecked = result.data.isLiverDiseaseChecked;
      this.isEndStageLiverChecked = result.data.isEndStageLiverChecked;
      this.isEsophogealVaricesChecked = result.data.isEsophogealVaricesChecked;
      this.isPortopulmonaryChecked = result.data.isPortopulmonaryChecked;
      this.portopulmonarySelection = result.data.portopulmonarySelection;
      this.showHidePortopulmonaryCombobox();
      this.isIntracranialPressureChecked =
        result.data.isIntracranialPressureChecked;
      this.isStrokeChecked = result.data.isStrokeChecked;
      this.strokeSelection = result.data.strokeSelection;
      this.showHideStrokeCombobox();
      this.isConvulsiveDisorderChecked =
        result.data.isConvulsiveDisorderChecked;
      this.convulsiveDisorderSelections =
        result.data.convulsiveDisorderSelections;
      this.showHideConvulsiveDisorderCheckboxset();
      this.isPanicDisorderChecked = result.data.isPanicDisorderChecked;
      this.isMajorBleedingChecked = result.data.isMajorBleedingChecked;
      this.isSymptomaticAnemiaChecked = result.data.isSymptomaticAnemiaChecked;
      this.isSickleCellChecked = result.data.isSickleCellChecked;
      this.isSurgeryChecked = result.data.isSurgeryChecked;
      this.isMedicallyFragileChecked = result.data.isMedicallyFragileChecked;
      this.isNotSureChecked = result.data.isNotSureChecked;
      this.isNoneChecked = result.data.isNoneChecked;
    }
  }

  /**
   * get methods for picklists and checkbox sets
   */
  get lungDiseaseOptions() {
    return [
      {
        label: "Vital capacity less than 1 liter or less than 20 ml/kg",
        value: "Vital capacity less than 1 liter or less than 20 ml/kg"
      },
      {
        label: "Current or frequent hypoxemia",
        value: "Current or frequent hypoxemia"
      },
      {
        label: "Current or frequent hypercapnia",
        value: "Current or frequent hypercapnia"
      },
      {
        label: "FEV1 less than 50% predicted",
        value: "FEV1 less than 50% predicted"
      },
      {
        label: "Required long-term oxygen in the past 6 months",
        value: "Required long-term oxygen in the past 6 months"
      },
      {
        label: "Oxygen dependence at sea level",
        value: "Oxygen dependence at sea level"
      },
      {
        label: "I do not know",
        value: "I do not know"
      }
    ];
  }

  get pulmonaryHypertensionOptions() {
    return [
      {
        label: "NYHA Class IV",
        value: "NYHA Class IV"
      },
      {
        label: "NYHA Class III",
        value: "NYHA Class III"
      },
      {
        label: "I do not know",
        value: "I do not know"
      },
      {
        label: "Not applicable",
        value: "Not applicable"
      }
    ];
  }

  get ventilatorDependenceOptions() {
    return [
      {
        label: "I am the treating provider for the ventilator",
        value: "I am the treating provider for the ventilator"
      },
      {
        label: "I am not the treating provider for the ventilator",
        value: "I am not the treating provider for the ventilator"
      }
    ];
  }

  get chestPainOptions() {
    return [
      {
        label: "CCS Class III",
        value: "CCS Class III"
      },
      {
        label: "CCS Class IV",
        value: "CCS Class IV"
      },
      {
        label:
          "Chest pain with everyday living activities with moderate limitations",
        value:
          "Chest pain with everyday living activities with moderate limitations"
      },
      {
        label:
          "Chest pain on minimal exertion with no change to symptoms or medication in the last 6 weeks",
        value:
          "Chest pain on minimal exertion with no change to symptoms or medication in the last 6 weeks"
      },
      {
        label:
          "Is unable to perform any activity without chest pain or is experiencing chest pain at rest and/or severe limitation",
        value:
          "Is unable to perform any activity without chest pain or is experiencing chest pain at rest and/or severe limitation"
      },
      {
        label: "Chest pain at rest",
        value: "Chest pain at rest"
      },
      {
        label: "Change in symptoms and/or medication in the past 6 weeks",
        value: "Change in symptoms and/or medication in the past 6 weeks"
      },
      {
        label: "I do not know",
        value: "I do not know"
      },
      {
        label: "Not applicable",
        value: "Not applicable"
      }
    ];
  }

  get arrhythmiaOptions() {
    return [
      {
        label: "Unstable arrhythmia",
        value: "Unstable arrhythmia"
      },
      {
        label: "High-grade premature ventricular contractions",
        value: "High-grade premature ventricular contractions"
      },
      {
        label: "Recent ablation therapy",
        value: "Recent ablation therapy"
      },
      {
        label:
          "Internal Cardiac Defibrillator (ICD) – the device has delivered a shock, individual is unstable",
        value:
          "Internal Cardiac Defibrillator (ICD) – the device has delivered a shock, individual is unstable"
      },
      {
        label:
          "Internal Cardiac Defibrillator (ICD) – the device has delivered a shock, the individual has been stable for at least 6 weeks",
        value:
          "Internal Cardiac Defibrillator (ICD) – the device has delivered a shock, the individual has been stable for at least 6 weeks"
      },
      {
        label:
          "Valve Disease of functional class IV or is experiencing chest pain or syncope",
        value:
          "Valve Disease of functional class IV or is experiencing chest pain or syncope"
      },
      {
        label: "Pacemaker placement less than one week ago",
        value: "Pacemaker placement less than one week ago"
      },
      {
        label: "I do not know",
        value: "I do not know"
      },
      {
        label: "Not applicable",
        value: "Not applicable"
      }
    ];
  }

  get acuteHeartFailureOptions() {
    return [
      {
        label: "Hospitalized or treated for pleural effusion in past 6 weeks",
        value: "Hospitalized or treated for pleural effusion in past 6 weeks"
      },
      {
        label: "Hospitalized or treated for dyspnea in past 6 weeks",
        value: "Hospitalized or treated for dyspnea in past 6 weeks"
      },
      {
        label: "I do not know",
        value: "I do not know"
      },
      {
        label: "Not applicable",
        value: "Not applicable"
      }
    ];
  }

  get chronicHeartFailureOptions() {
    return [
      {
        label: "NYHA Class IV",
        value: "NYHA Class IV"
      },
      {
        label: "NYHA Class III",
        value: "NYHA Class III"
      },
      {
        label: "Is unable to carry on any physical activity without discomfort",
        value: "Is unable to carry on any physical activity without discomfort"
      },
      {
        label: "Has symptoms of heart failure at rest",
        value: "Has symptoms of heart failure at rest"
      },
      {
        label: "Has discomfort that increases with any physical activity",
        value: "Has discomfort that increases with any physical activity"
      },
      {
        label: "Is dyspnea at rest",
        value: "Is dyspnea at rest"
      },
      {
        label: "Has a change in symptoms and/or medication in the past 6 weeks",
        value: "Has a change in symptoms and/or medication in the past 6 weeks"
      },
      {
        label: "I do not know",
        value: "I do not know"
      },
      {
        label: "Not applicable",
        value: "Not applicable"
      }
    ];
  }

  get cyanoticHeartDiseaseOptions() {
    return [
      {
        label: "NYHA class IV",
        value: "NYHA class IV"
      },
      {
        label: "Dyspnea at rest",
        value: "Dyspnea at rest"
      },
      {
        label: "Mainly bedbound due to heart disease",
        value: "Mainly bedbound due to heart disease"
      },
      {
        label: "Change in symptoms and/or medication in the past 6 weeks",
        value: "Change in symptoms and/or medication in the past 6 weeks"
      },
      {
        label: "Dyspnea on exertion",
        value: "Dyspnea on exertion"
      },
      {
        label: "I do not know",
        value: "I do not know"
      },
      {
        label: "Not applicable",
        value: "Not applicable"
      }
    ];
  }

  get hepatitisOptions() {
    return [
      {
        label: "Impaired gas exchange",
        value: "Impaired gas exchange"
      },
      {
        label: "I do not know",
        value: "I do not know"
      },
      {
        label: "Not applicable",
        value: "Not applicable"
      }
    ];
  }

  get portopulmonaryOptions() {
    return [
      {
        label: "With intrapulmonary shunting",
        value: "With intrapulmonary shunting"
      },
      {
        label: "Without intrapulmonary shunting",
        value: "Without intrapulmonary shunting"
      },
      {
        label: "Not applicable",
        value: "Not applicable"
      }
    ];
  }
  get strokeOptions() {
    return [
      {
        label: "Frequent or crescendo transient ischemic attacks or strokes",
        value: "Frequent or crescendo transient ischemic attacks or strokes"
      },
      {
        label: "I do not know",
        value: "I do not know"
      },
      {
        label: "Not applicable",
        value: "Not applicable"
      }
    ];
  }

  get convulsiveDisorderOptions() {
    return [
      {
        label:
          "Has frequent, uncontrolled, prolonged, generalized seizures that last greater than five minutes without cessation after abortive seizure medication treatment",
        value:
          "Has frequent, uncontrolled, prolonged, generalized seizures that last greater than five minutes without cessation after abortive seizure medication treatment"
      },
      {
        label: "Has had a seizure in the last 24 hours",
        value: "Has had a seizure in the last 24 hours"
      },
      {
        label: "I do not know",
        value: "I do not know"
      },
      {
        label: "Not applicable",
        value: "Not applicable"
      }
    ];
  }

  /**
   * event handlers
   */
  handleChangeTuberculosisCheckbox(event) {
    this.isTuberculosisChecked = event.target.checked;
    //updatePrimaryConditions tracks whether or not a Condition has been selected other than "None Apply"
    this.updatePrimaryConditions();
  }

  handleChangeAirborneCheckbox(event) {
    this.isAirborneChecked = event.target.checked;
    this.updatePrimaryConditions();
  }

  handleChangePneumothoraxCheckbox(event) {
    this.isPneumothoraxChecked = event.target.checked;
    this.updatePrimaryConditions();
  }

  handleChangePleuralEffusionCheckbox(event) {
    this.isPleuralEffusionChecked = event.target.checked;
    this.updatePrimaryConditions();
  }

  handleChangeLungDiseaseCheckbox(event) {
    this.isLungDisease = event.target.checked;
    if (this.isLungDisease === false) {
      this.lungDiseaseSelections = [""];
    }
    this.updatePrimaryConditions();
    this.showHideLungDiseaseCheckboxSet();
  }

  handleChangeLungDiseaseCheckboxSet(event) {
    this.lungDiseaseSelections = event.target.value;
    this.updatePrimaryConditions();
  }

  handleChangeOxygenDependenceCheckbox(event) {
    this.isOxygenDependenceChecked = event.target.checked;
    this.updatePrimaryConditions();
  }

  handleChangeOxygenRequriedGreaterThan4Checkbox(event) {
    this.isOxygenRequiredGreaterThan4 = event.target.checked;
    this.updatePrimaryConditions();
  }

  handleChangeLongTermOxygenCheckbox(event) {
    this.isLongTermOxygenChecked = event.target.checked;
    this.updatePrimaryConditions();
  }

  handleChangeAcuteRespiratoryHospitalizationCheckbox(event) {
    this.isAcuteRespiratoryHospitalizationChecked = event.target.checked;
    this.updatePrimaryConditions();
  }

  handleChangePulmonaryHypertensionCheckbox(event) {
    this.isPulmonaryHypertensionChecked = event.target.checked;
    // the checked property does not equal false. It is either null, empty, or undefined
    if (this.isPulmonaryHypertensionChecked === false) {
      this.pulmonaryHypertensionSelection = "";
    }
    this.updatePrimaryConditions();
    this.showHidePulmonaryHypertensionCombobox();
  }

  handleChangePulmonaryHypertensionCombobox(event) {
    this.pulmonaryHypertensionSelection = event.target.value;
    this.updatePrimaryConditions();
  }

  handleChangeVentilatorDependenceCheckbox(event) {
    this.isVentilatorDependenceChecked = event.target.checked;
    if (this.isVentilatorDependenceChecked === false) {
      this.ventilatorDependenceSelection = "";
    }
    this.updatePrimaryConditions();
    this.showHideVentilatorDependenceCombobox();
  }

  handleChangeVentilatorDependenceCombobox(event) {
    this.ventilatorDependenceSelection = event.target.value;
    this.updatePrimaryConditions();
  }

  handleChangeChestPainCheckbox(event) {
    this.isChestPainChecked = event.target.checked;
    if (this.isChestPainChecked === false) {
      this.chestPainSelections = [""];
    }
    this.updatePrimaryConditions();
    this.showHideChestPainCheckboxset();
  }

  handleChangeChestPainCheckboxset(event) {
    this.chestPainSelections = event.target.value;
    this.updatePrimaryConditions();
  }

  handleChangeArrhythmiaCheckbox(event) {
    this.isArrhythmiaChecked = event.target.checked;
    if (this.isArrhythmiaChecked === false) {
      this.arrhythmiaSelections = [""];
    }
    this.updatePrimaryConditions();
    this.showHideArrhythmiaCheckboxset();
  }

  handleChangeArrhythmiaCheckboxset(event) {
    this.arrhythmiaSelections = event.target.value;
    this.updatePrimaryConditions();
  }

  handleChangeAcuteHeartFailureCheckbox(event) {
    this.isAcuteHeartFailureChecked = event.target.checked;
    if (this.isAcuteHeartFailureChecked === false) {
      this.acuteHeartFailureSelections = [""];
    }
    this.updatePrimaryConditions();
    this.showHideAcuteHeartFailureCheckboxset();
  }

  handleChangeAcuteHeartFailureCheckboxset(event) {
    this.acuteHeartFailureSelections = event.target.value;
    this.updatePrimaryConditions();
  }

  handleChangeChronicHeartFailureCheckbox(event) {
    this.isChronicHeartFailureChecked = event.target.checked;
    if (this.isChronicHeartFailureChecked === false) {
      this.chronicHeartFailureSelections = [""];
    }
    this.showHideChronicHeartFailureCheckboxset();
    this.updatePrimaryConditions();
  }

  handleChangeChronicHeartFailureCheckboxset(event) {
    this.chronicHeartFailureSelections = event.target.value;
    this.updatePrimaryConditions();
  }

  handleChangeCyanoticHeartDiseaseCheckbox(event) {
    this.isCyanoticHeartDiseaseChecked = event.target.checked;
    if (this.isCyanoticHeartDiseaseChecked === false) {
      this.cyanoticHeartDiseaseSelections = [""];
    }
    this.updatePrimaryConditions();
    this.showHideCyanoticHeartDiseaseCheckboxset();
  }

  handleChangeCyanoticHeartDiseaseCheckboxset(event) {
    this.cyanoticHeartDiseaseSelections = event.target.value;
    this.updatePrimaryConditions();
  }

  handleChangeUncontrolledHypertensionCheckbox(event) {
    this.isUncontrolledHypertensionChecked = event.target.checked;
    this.updatePrimaryConditions();
  }

  handleChangeHepatitisCheckbox(event) {
    this.isHepatitisChecked = event.target.checked;
    if (this.isHepatitisChecked === false) {
      this.hepatitisSelection = "";
    }
    this.showHideHepatitisCombobox();
    this.updatePrimaryConditions();
  }

  handleChangeHepatitisCombobox(event) {
    this.hepatitisSelection = event.target.value;
    this.updatePrimaryConditions();
  }

  handleChangePortalHypertensionCheckbox(event) {
    this.isPortalHypertensionChecked = event.target.checked;
    this.updatePrimaryConditions();
  }

  handleChangeHeptopulmonaryCheckbox(event) {
    this.isHeptopulmonaryChecked = event.target.checked;
    this.updatePrimaryConditions();
  }

  handleChangeLiverDiseaseCheckbox(event) {
    this.isLiverDiseaseChecked = event.detail.checked;
    this.updatePrimaryConditions();
  }

  handleChangeEndStageLiverCheckbox(event) {
    this.isEndStageLiverChecked = event.target.checked;
    this.updatePrimaryConditions();
  }

  handleChangeEsophogealVaricesCheckbox(event) {
    this.isEsophogealVaricesChecked = event.target.checked;
    this.updatePrimaryConditions();
  }

  handleChangePortopulmonaryCheckbox(event) {
    this.isPortopulmonaryChecked = event.target.checked;
    if (this.isPortopulmonaryChecked === false) {
      this.portopulmonarySelection = "";
    }
    this.updatePrimaryConditions();
    this.showHidePortopulmonaryCombobox();
  }

  handleChangePortopulmonaryCombobox(event) {
    this.portopulmonarySelection = event.target.value;
    this.updatePrimaryConditions();
  }

  handleChangeIntracranialPressureCheckbox(event) {
    this.isIntracranialPressureChecked = event.target.checked;
    this.updatePrimaryConditions();
  }

  handleChangeStrokeCheckbox(event) {
    this.isStrokeChecked = event.target.checked;
    if (this.isStrokeChecked === false) {
      this.strokeSelection = "";
    }
    this.updatePrimaryConditions();
    this.showHideStrokeCombobox();
  }

  handleChangeStrokeCombobox(event) {
    this.strokeSelection = event.target.value;
  }

  handleChangeConvulsiveDisorderCheckbox(event) {
    this.isConvulsiveDisorderChecked = event.target.checked;
    if (this.isConvulsiveDisorderChecked === false) {
      this.convulsiveDisorderSelections = [""];
    }
    this.updatePrimaryConditions();
    this.showHideConvulsiveDisorderCheckboxset();
  }

  handleChangeConvulsiveDisorderCheckboxset(event) {
    this.convulsiveDisorderSelections = event.target.value;
    this.updatePrimaryConditions();
  }

  handleChangePanicDisorderCheckbox(event) {
    this.isPanicDisorderChecked = event.target.checked;
    this.updatePrimaryConditions();
  }

  handleChangeMajorBleedingCheckbox(event) {
    this.isMajorBleedingChecked = event.target.checked;
    this.updatePrimaryConditions();
  }

  handleChangeSymptomaticAnemiaCheckbox(event) {
    this.isSymptomaticAnemiaChecked = event.target.checked;
    this.updatePrimaryConditions();
  }

  handleChangeSickleCellCheckbox(event) {
    this.isSickleCellChecked = event.target.checked;
    this.updatePrimaryConditions();
  }

  handleChangeSurgeryCheckbox(event) {
    this.isSurgeryChecked = event.target.checked;
    this.updatePrimaryConditions();
  }

  handleChangeMedicallyFragileCheckbox(event) {
    this.isMedicallyFragileChecked = event.target.checked;
    this.updatePrimaryConditions();
  }

  handleChangeNotSureCheckbox(event) {
    this.isNotSureChecked = event.target.checked;
    this.updatePrimaryConditions();
  }

  handleChangeNoneCheckbox(event) {
    this.isNoneChecked = event.target.checked;
    this.updatePrimaryConditions();
  }

  handleSaveClick(event) {
    this.dispatchEvent(
      new CustomEvent("savetravelquestionsaveevent", {
        detail: {
          showSpinner: true
        }
      })
    );
    const travelQuestions = {
      leadId: this.leadId,
      isLungDisease: this.isLungDisease,
      lungDiseaseSelections: this.lungDiseaseSelections,
      isTuberculosisChecked: this.isTuberculosisChecked,
      isAirborneChecked: this.isAirborneChecked,
      isPneumothoraxChecked: this.isPneumothoraxChecked,
      isPleuralEffusionChecked: this.isPleuralEffusionChecked,
      isOxygenRequiredGreaterThan4: this.isOxygenRequiredGreaterThan4,
      isLongTermOxygenChecked: this.isLongTermOxygenChecked,
      isAcuteRespiratoryHospitalizationChecked: this
        .isAcuteRespiratoryHospitalizationChecked,
      isPulmonaryHypertensionChecked: this.isPulmonaryHypertensionChecked,
      pulmonaryHypertensionSelection: this.pulmonaryHypertensionSelection,
      isOxygenDependenceChecked: this.isOxygenDependenceChecked,
      isVentilatorDependenceChecked: this.isVentilatorDependenceChecked,
      ventilatorDependenceSelection: this.ventilatorDependenceSelection,
      isChestPainChecked: this.isChestPainChecked,
      chestPainSelections: this.chestPainSelections,
      isArrhythmiaChecked: this.isArrhythmiaChecked,
      arrhythmiaSelections: this.arrhythmiaSelections,
      isAcuteHeartFailureChecked: this.isAcuteHeartFailureChecked,
      acuteHeartFailureSelections: this.acuteHeartFailureSelections,
      isChronicHeartFailureChecked: this.isChronicHeartFailureChecked,
      chronicHeartFailureSelections: this.chronicHeartFailureSelections,
      isCyanoticHeartDiseaseChecked: this.isCyanoticHeartDiseaseChecked,
      cyanoticHeartDiseaseSelections: this.cyanoticHeartDiseaseSelections,
      isUncontrolledHypertensionChecked: this.isUncontrolledHypertensionChecked,
      isHepatitisChecked: this.isHepatitisChecked,
      hepatitisSelection: this.hepatitisSelection,
      isPortalHypertensionChecked: this.isPortalHypertensionChecked,
      isHeptopulmonaryChecked: this.isHeptopulmonaryChecked,
      isLiverDiseaseChecked: this.isLiverDiseaseChecked,
      isEndStageLiverChecked: this.isEndStageLiverChecked,
      isEsophogealVaricesChecked: this.isEsophogealVaricesChecked,
      isPortopulmonaryChecked: this.isPortopulmonaryChecked,
      portopulmonarySelection: this.portopulmonarySelection,
      isIntracranialPressureChecked: this.isIntracranialPressureChecked,
      isStrokeChecked: this.isStrokeChecked,
      strokeSelection: this.strokeSelection,
      isConvulsiveDisorderChecked: this.isConvulsiveDisorderChecked,
      convulsiveDisorderSelections: this.convulsiveDisorderSelections,
      isPanicDisorderChecked: this.isPanicDisorderChecked,
      isMajorBleedingChecked: this.isMajorBleedingChecked,
      isSymptomaticAnemiaChecked: this.isSymptomaticAnemiaChecked,
      isSickleCellChecked: this.isSickleCellChecked,
      isSurgeryChecked: this.isSurgeryChecked,
      isMedicallyFragileChecked: this.isMedicallyFragileChecked,
      isNotSureChecked: this.isNotSureChecked,
      isNoneChecked: this.isNoneChecked
    };
    const selectionMade =
      this.isNoneChecked || this.arePrimaryConditionsChecked;
    if (selectionMade === true) {
      saveTravelQuestions({ wrapper: travelQuestions })
        .then((result) => {
          this.dispatchEvent(
            new CustomEvent("savetravelquestionsaveevent", {
              detail: {
                success: true,
                message: "Selections saved.",
                showSpinner: false
              }
            })
          );
        })
        .catch((error) => {
          this.dispatchEvent(
            new CustomEvent("savetravelquestionsaveevent", {
              detail: {
                success: false,
                message: "An error occurred while saving.",
                showSpinner: false
              }
            })
          );
        });
    } else if (selectionMade === false) {
      this.dispatchEvent(
        new CustomEvent("savetravelquestionsaveevent", {
          detail: {
            success: false,
            message:
              "Please select at least one condition. If no conditions apply, select None Apply.",
            showSpinner: false
          }
        })
      );
    }
  }

  /**
   * methods to dynamically hide or show various checkbox groups and picklists
   */
  showHideLungDiseaseCheckboxSet() {
    const lungDiseaseCheckboxSet = this.template.querySelectorAll(
      ".innerLungDiseaseOptions"
    );
    if (this.isLungDisease && this.isLungDisease === true) {
      this.show(lungDiseaseCheckboxSet);
    } else {
      this.hide(lungDiseaseCheckboxSet);
    }
  }

  showHidePulmonaryHypertensionCombobox() {
    const pulmonaryHypertensionCombo = this.template.querySelectorAll(
      ".innerPulmonaryHypertensionOptions"
    );
    if (
      this.isPulmonaryHypertensionChecked &&
      this.isPulmonaryHypertensionChecked === true
    ) {
      this.show(pulmonaryHypertensionCombo);
    } else {
      this.hide(pulmonaryHypertensionCombo);
    }
  }

  showHideVentilatorDependenceCombobox() {
    const ventilatorCombo = this.template.querySelectorAll(
      ".innerVentilatorDependenceOptions"
    );
    if (
      this.isVentilatorDependenceChecked &&
      this.isVentilatorDependenceChecked === true
    ) {
      this.show(ventilatorCombo);
    } else {
      this.hide(ventilatorCombo);
    }
  }

  showHideChestPainCheckboxset() {
    const chestPainCheckboxSet = this.template.querySelectorAll(
      ".innerChestPainOptions"
    );
    if (this.isChestPainChecked && this.isChestPainChecked === true) {
      this.show(chestPainCheckboxSet);
    } else {
      this.hide(chestPainCheckboxSet);
    }
  }

  showHideArrhythmiaCheckboxset() {
    const arrhythmiaCheckboxSet = this.template.querySelectorAll(
      ".innerArrhythmiaOptions"
    );
    if (this.isArrhythmiaChecked && this.isArrhythmiaChecked === true) {
      this.show(arrhythmiaCheckboxSet);
    } else {
      this.hide(arrhythmiaCheckboxSet);
    }
  }

  showHideAcuteHeartFailureCheckboxset() {
    const acuteHeartFailureCheckboxset = this.template.querySelectorAll(
      ".innerAcuteHeartFailureOptions"
    );
    if (
      this.isAcuteHeartFailureChecked &&
      this.isAcuteHeartFailureChecked === true
    ) {
      this.show(acuteHeartFailureCheckboxset);
    } else {
      this.hide(acuteHeartFailureCheckboxset);
    }
  }

  showHideChronicHeartFailureCheckboxset() {
    const chronicHFCheckboxset = this.template.querySelectorAll(
      ".innerChronicHeartFailureOptions"
    );
    if (
      this.isChronicHeartFailureChecked &&
      this.isChronicHeartFailureChecked === true
    ) {
      this.show(chronicHFCheckboxset);
    } else {
      this.hide(chronicHFCheckboxset);
    }
  }

  showHideCyanoticHeartDiseaseCheckboxset() {
    const cyanoticCheckboxSet = this.template.querySelectorAll(
      ".innerCyanoticicHeartDiseaseOptions"
    );
    if (
      this.isCyanoticHeartDiseaseChecked &&
      this.isCyanoticHeartDiseaseChecked === true
    ) {
      this.show(cyanoticCheckboxSet);
    } else {
      this.hide(cyanoticCheckboxSet);
    }
  }

  showHideHepatitisCombobox() {
    const hepatitisCombobox = this.template.querySelectorAll(
      ".innerHepatitisOptions"
    );
    if (this.isHepatitisChecked && this.isHepatitisChecked === true) {
      this.show(hepatitisCombobox);
    } else {
      this.hide(hepatitisCombobox);
    }
  }

  showHidePortopulmonaryCombobox() {
    const portoCombobox = this.template.querySelectorAll(
      ".innerPortopulmonaryOptions"
    );
    if (this.isPortopulmonaryChecked && this.isPortopulmonaryChecked === true) {
      this.show(portoCombobox);
    } else {
      this.hide(portoCombobox);
    }
  }

  showHideStrokeCombobox() {
    const strokeCombobox = this.template.querySelectorAll(
      ".innerStrokeOptions"
    );
    if (this.isStrokeChecked && this.isStrokeChecked === true) {
      this.show(strokeCombobox);
    } else {
      this.hide(strokeCombobox);
    }
  }

  showHideConvulsiveDisorderCheckboxset() {
    const convDisorderCheckboxset = this.template.querySelectorAll(
      ".innerConvulsiveDisorderOptions"
    );
    if (
      this.isConvulsiveDisorderChecked &&
      this.isConvulsiveDisorderChecked === true
    ) {
      this.show(convDisorderCheckboxset);
    } else {
      this.hide(convDisorderCheckboxset);
    }
  }

  /**
   * updatePrimaryConditions sets boolean arePrimaryConditionsChecked to true if any
   * selection has been made except for "None Apply." It is used to disable the None Apply button.
   */
  updatePrimaryConditions() {
    if (
      this.isLungDisease === true ||
      this.isTuberculosisChecked === true ||
      this.isAirborneChecked === true ||
      this.isPneumothoraxChecked === true ||
      this.isPleuralEffusionChecked === true ||
      this.isOxygenDependenceChecked === true ||
      this.isOxygenRequiredGreaterThan4 === true ||
      this.isLongTermOxygenChecked === true ||
      this.isAcuteRespiratoryHospitalizationChecked === true ||
      this.isPulmonaryHypertensionChecked === true ||
      this.isVentilatorDependenceChecked === true ||
      this.isChestPainChecked === true ||
      this.isArrhythmiaChecked === true ||
      this.isAcuteHeartFailureChecked === true ||
      this.isChronicHeartFailureChecked === true ||
      this.isCyanoticHeartDiseaseChecked === true ||
      this.isUncontrolledHypertensionChecked === true ||
      this.isHepatitisChecked === true ||
      this.isPortalHypertensionChecked === true ||
      this.isHeptopulmonaryChecked === true ||
      this.isLiverDiseaseChecked === true ||
      this.isEndStageLiverChecked === true ||
      this.isEsophogealVaricesChecked === true ||
      this.isPortopulmonaryChecked === true ||
      this.isIntracranialPressureChecked === true ||
      this.isStrokeChecked === true ||
      this.isConvulsiveDisorderChecked === true ||
      this.isPanicDisorderChecked === true ||
      this.isMajorBleedingChecked === true ||
      this.isSymptomaticAnemiaChecked === true ||
      this.isSickleCellChecked === true ||
      this.isSurgeryChecked === true ||
      this.isMedicallyFragileChecked === true ||
      this.isNotSureChecked === true
    ) {
      this.arePrimaryConditionsChecked = true;
    } else {
      this.arePrimaryConditionsChecked = false;
    }
  }

  show(elms) {
    elms.forEach((element) => {
      element.classList.remove("slds-hide");
      element.classList.add("slds-show");
    });
  }

  hide(elms) {
    elms.forEach((element) => {
      element.classList.add("slds-hide");
      element.classList.remove("slds-show");
    });
  }
}