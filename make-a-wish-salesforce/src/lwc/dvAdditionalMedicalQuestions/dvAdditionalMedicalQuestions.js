/**
@description Additional Medical Questions component, the additional medical questions component for the Diagnosis Verification process.
@author Gustavo Mayer, Traction on Demand
@createdDate 08/Feb/2021
**/
import { api, LightningElement, wire } from "lwc";
import findAdditionalMedicalQuestions from "@salesforce/apex/DvAdditionalMedicalQuestionsController.getAdditionalMedicalQuestionsByLeadId";
import saveAdditionalMedicalQuestions from "@salesforce/apex/DvAdditionalMedicalQuestionsController.saveAdditionalMedicalQuestions";

export default class DvAdditionalMedicalQuestions extends LightningElement {
  /**
   * PROPERTIES:
   */
  leadId;
  isLeadQualifying;
  wishChildFirstName = "";
  unplannedHospitalAdmissions = "";
  timesChildAdmitted = "";
  admittedDiagnosis = "";
  hospitalizationAdmissionIcu = "";
  additionalClinicalDetails = "";
  statementDescribePatient = "";
  expectConditionDeteriorate = "";
  expectConditionDeteriorateExplain = "";
  medicalExpediteProcess = "";
  medicalExpediteProcessReason = "";
  provideTimeFrameWish = "";
  provideTimeFrameWishInformation = "";
  medicalSummaryAttachment = "";
  additionalInfoProvide = "";
  cognitiveDelay = "";
  levelOfDelay = "";
  speechLanguageDelay = "";
  expressNeedsDesires = "";
  describeCommunicationNeeds = [""];
  describeCommunicationNeedsInformation = "";

  isUnplannedHospitalAdmissionsRequired = true;
  isTimesChildAdmittedRequired = false;
  isAdmittedDiagnosisRequired = false;
  isHospitalizationAdmissionIcuRequired = false;
  isAdditionalClinicalDetailsRequired = true;
  isStatementDescribePatientRequired = true;
  isExpectConditionDeteriorateRequired = true;
  isExpectConditionDeteriorateExplainRequired = false;
  isMedicalExpediteProcessRequired = true;
  isMedicalExpediteProcessReasonRequired = false;
  isProvideTimeFrameWishRequired = false;
  isProvideTimeFrameWishInformationRequired = false;
  isMedicalSummaryAttachmentRequired = false;
  isAdditionalInfoProvideRequired = false;
  isCognitiveDelayRequired = true;
  isLevelOfDelayRequired = false;
  isSpeechLanguageDelayRequired = false;
  isExpressNeedsDesiresRequired = false;
  isDescribeCommunicationNeedsRequired = false;
  isDescribeCommunicationNeedsInformationRequired = false;

  @api handleLoadAdditionalMedicalQuestions(leadId) {
    this.leadId = leadId;
  }

  @wire(findAdditionalMedicalQuestions, {
    leadId: "$leadId",
  })
  wired(result) {
    if (result.data) {
      const amq = result.data;
      this.isLeadQualifying = amq.isLeadQualifying;
      this.wishChildFirstName = amq.wishChildFirstName;
      this.unplannedHospitalAdmissions = amq.unplannedHospitalAdmissions;
      this.timesChildAdmitted = amq.timesChildAdmitted;
      this.admittedDiagnosis = amq.admittedDiagnosis;
      this.hospitalizationAdmissionIcu = amq.hospitalizationAdmissionIcu;
      this.additionalClinicalDetails = amq.additionalClinicalDetails;
      this.statementDescribePatient = amq.statementDescribePatient;
      this.expectConditionDeteriorate = amq.expectConditionDeteriorate;
      this.expectConditionDeteriorateExplain =
        amq.expectConditionDeteriorateExplain;
      this.medicalExpediteProcess = amq.medicalExpediteProcess;
      this.medicalExpediteProcessReason = amq.medicalExpediteProcessReason;
      this.provideTimeFrameWish = amq.provideTimeFrameWish;
      this.provideTimeFrameWishInformation =
        amq.provideTimeFrameWishInformation;
      this.medicalSummaryAttachment = amq.medicalSummaryAttachment;
      this.additionalInfoProvide = amq.additionalInfoProvide;
      this.cognitiveDelay = amq.cognitiveDelay;
      this.levelOfDelay = amq.levelOfDelay;
      this.speechLanguageDelay = amq.speechLanguageDelay;
      this.expressNeedsDesires = amq.expressNeedsDesires;
      this.describeCommunicationNeeds = amq.describeCommunicationNeeds;
      this.describeCommunicationNeedsInformation =
        amq.describeCommunicationNeedsInformation;

      this.showHideUnplannedHospitalAdmissionFields(
        this.unplannedHospitalAdmissions
      );
      this.showHideConditionDeteriorateFields(this.expectConditionDeteriorate);
      this.showHideAdditionalClinicalDetailsFields();
      this.showHideStatementDescribePatientFields();
      this.showHideMedicalExpediteProcessFields(this.medicalExpediteProcess);
      this.showHideProvideTimeFrameFields(this.provideTimeFrameWish);
      this.showHideCognitiveDelayFields(
        this.cognitiveDelay,
        this.cognitiveDelay
      );
      this.showHideLevelOfDelayFields(this.levelOfDelay, this.levelOfDelay);
      this.showHideSpeechLanguageDelayFields(
        this.speechLanguageDelay,
        this.speechLanguageDelay
      );
      this.showHideExpressNeedsDesiresFields(this.expressNeedsDesires);

      const fileManager = this.template.querySelector("c-file-manager");
      fileManager.handleLoadFileManager(this.leadId);

      this.setRequiredFields();
    } else if (result.error) {
      console.error(result.error);
    }
  }

  /**
   * HANDLERS:
   */
  handleChangeUnplannedHospitalAdmissions(event) {
    this.unplannedHospitalAdmissions = event.target.value;
    this.showHideUnplannedHospitalAdmissionFields(
      this.unplannedHospitalAdmissions
    );
    this.setRequiredFields();
  }

  showHideUnplannedHospitalAdmissionFields(value) {
    const unplannedHospitalAdmissions = this.template.querySelectorAll(
      ".unplannedHospitalAdmissions"
    );
    const timesChildAdmitted = this.template.querySelectorAll(
      ".timesChildAdmitted"
    );
    const admittedDiagnosis = this.template.querySelectorAll(
      ".admittedDiagnosis"
    );
    const hospitalizationAdmissionIcu = this.template.querySelectorAll(
      ".hospitalizationAdmissionIcu"
    );

    if (this.isLeadQualifying) {
      this.hide(unplannedHospitalAdmissions);
      this.hide(timesChildAdmitted);
      this.hide(admittedDiagnosis);
      this.hide(hospitalizationAdmissionIcu);
      this.unplannedHospitalAdmissions = "";
      this.timesChildAdmitted = "";
      this.admittedDiagnosis = "";
      this.hospitalizationAdmissionIcu = "";
    } else if (!this.isLeadQualifying) {
      this.show(unplannedHospitalAdmissions);
      if (value && value === "Yes") {
        this.show(timesChildAdmitted);
        this.show(admittedDiagnosis);
        this.show(hospitalizationAdmissionIcu);
      } else {
        this.hide(timesChildAdmitted);
        this.hide(admittedDiagnosis);
        this.hide(hospitalizationAdmissionIcu);
        this.timesChildAdmitted = "";
        this.admittedDiagnosis = "";
        this.hospitalizationAdmissionIcu = "";
      }
    }
  }

  handleChangeTimesChildAdmitted(event) {
    this.timesChildAdmitted = event.target.value;
    this.setRequiredFields();
  }

  handleChangeAdmittedDiagnosis(event) {
    this.admittedDiagnosis = event.target.value;
    this.setRequiredFields();
  }

  handleChangeHospitalizationAdmissionIcu(event) {
    this.hospitalizationAdmissionIcu = event.target.value;
  }

  handleChangeAdditionalClinicalDetails(event) {
    this.additionalClinicalDetails = event.target.value;
    this.showHideAdditionalClinicalDetailsFields();
    this.setRequiredFields();
  }

  showHideAdditionalClinicalDetailsFields() {
    const additionalClinicalDetails = this.template.querySelectorAll(
      ".additionalClinicalDetails"
    );
    if (this.isLeadQualifying) {
      this.additionalClinicalDetails = "";
      this.hide(additionalClinicalDetails);
    } else if (!this.isLeadQualifying) {
      this.show(additionalClinicalDetails);
    }
    this.setRequiredFields();
  }

  handleChangeStatementDescribePatient(event) {
    this.statementDescribePatient = event.target.value;
    this.showHideStatementDescribePatientFields();
    this.setRequiredFields();
  }

  showHideStatementDescribePatientFields() {
    const statementDescribePatient = this.template.querySelectorAll(
      ".statementDescribePatient"
    );
    if (this.isLeadQualifying) {
      this.statementDescribePatient = "";
      this.hide(statementDescribePatient);
    } else if (!this.isLeadQualifying) {
      this.show(statementDescribePatient);
    }
  }

  handleChangeExpectConditionDeteriorate(event) {
    this.expectConditionDeteriorate = event.target.value;
    this.showHideConditionDeteriorateFields(this.expectConditionDeteriorate);
    this.setRequiredFields();
  }

  showHideConditionDeteriorateFields(value) {
    const expectConditionDeteriorateExplain = this.template.querySelectorAll(
      ".expectConditionDeteriorateExplain"
    );
    if (value && value === "Yes") {
      this.show(expectConditionDeteriorateExplain);
    } else {
      this.hide(expectConditionDeteriorateExplain);
      this.expectConditionDeteriorateExplain = "";
    }
  }

  handleChangeExpectConditionDeteriorateExplain(event) {
    this.expectConditionDeteriorateExplain = event.target.value;
  }

  handleChangeMedicalExpediteProcess(event) {
    this.medicalExpediteProcess = event.target.value;
    this.showHideMedicalExpediteProcessFields(this.medicalExpediteProcess);
    this.setRequiredFields();
  }

  showHideMedicalExpediteProcessFields(value) {
    const medicalExpediteProcessReason = this.template.querySelectorAll(
      ".medicalExpediteProcessReason"
    );
    const provideTimeFrameWish = this.template.querySelectorAll(
      ".provideTimeFrameWish"
    );
    const provideTimeFrameWishInformation = this.template.querySelectorAll(
      ".provideTimeFrameWishInformation"
    );
    if (value && value === "Yes") {
      this.show(medicalExpediteProcessReason);
      this.show(provideTimeFrameWish);
    } else {
      this.hide(medicalExpediteProcessReason);
      this.hide(provideTimeFrameWish);
      this.hide(provideTimeFrameWishInformation);
      this.medicalExpediteProcessReason = "";
      this.provideTimeFrameWish = "";
      this.provideTimeFrameWishInformation = "";
    }
  }

  handleChangeMedicalExpediteProcessReason(event) {
    this.medicalExpediteProcessReason = event.target.value;
    this.setRequiredFields();
  }

  handleChangeProvideTimeFrameWish(event) {
    this.provideTimeFrameWish = event.target.value;
    this.showHideProvideTimeFrameFields(this.provideTimeFrameWish);
    this.setRequiredFields();
  }

  showHideProvideTimeFrameFields(value) {
    const provideTimeFrameWishInformation = this.template.querySelectorAll(
      ".provideTimeFrameWishInformation"
    );
    if (value && value === "Other") {
      this.show(provideTimeFrameWishInformation);
    } else {
      this.hide(provideTimeFrameWishInformation);
      this.provideTimeFrameWishInformation = "";
    }
  }

  handleChangeProvideTimeFrameWishInformation(event) {
    this.provideTimeFrameWishInformation = event.target.value;
    this.setRequiredFields();
  }

  handleChangeAdditionalInfoProvide(event) {
    this.additionalInfoProvide = event.target.value;
    this.setRequiredFields();
  }

  handleChangeCognitiveDelay(event) {
    const cognitiveDelayCurrent = this.cognitiveDelay;
    this.showHideCognitiveDelayFields(
      cognitiveDelayCurrent,
      event.target.value
    );
    this.cognitiveDelay = event.target.value;
    this.setRequiredFields();
  }

  showHideCognitiveDelayFields(value, newValue) {
    const speechLanguageDelay = this.template.querySelectorAll(
      ".speechLanguageDelay"
    );
    const levelOfDelay = this.template.querySelectorAll(".levelOfDelay");
    const expressNeedsDesires = this.template.querySelectorAll(
      ".expressNeedsDesires"
    );
    const describeCommunicationNeeds = this.template.querySelectorAll(
      ".describeCommunicationNeeds"
    );
    const describeCommunicationNeedsInformation = this.template.querySelectorAll(
      ".describeCommunicationNeedsInformation"
    );

    // Reset all fields if there is a change to the value
    if (value && value !== newValue) {
      this.speechLanguageDelay = "";
      this.hide(speechLanguageDelay);
      this.hide(levelOfDelay);
      this.hide(expressNeedsDesires);
      this.hide(describeCommunicationNeeds);
      this.hide(describeCommunicationNeedsInformation);
      this.levelOfDelay = "";
      this.expressNeedsDesires = "";
      this.describeCommunicationNeeds = "";
      this.describeCommunicationNeedsInformation = "";
    }

    if (
      newValue &&
      (newValue === "No" ||
        newValue ===
          "I do not have access to that information. I recommend the chapter follow up with the medical team")
    ) {
      this.show(speechLanguageDelay);
      this.hide(levelOfDelay);
      this.hide(expressNeedsDesires);
      this.hide(describeCommunicationNeeds);
      this.hide(describeCommunicationNeedsInformation);
      this.levelOfDelay = "";
    } else if (newValue && newValue === "Yes") {
      this.show(levelOfDelay);
      this.hide(speechLanguageDelay);
      this.hide(expressNeedsDesires);
      this.hide(describeCommunicationNeeds);
      this.hide(describeCommunicationNeedsInformation);
    } else {
      this.hide(speechLanguageDelay);
      this.hide(levelOfDelay);
      this.hide(expressNeedsDesires);
      this.hide(describeCommunicationNeeds);
      this.hide(describeCommunicationNeedsInformation);
      this.speechLanguageDelay = "";
      this.levelOfDelay = "";
      this.expressNeedsDesires = "";
      this.describeCommunicationNeeds = "";
      this.describeCommunicationNeedsInformation = "";
    }
  }

  handleChangeLevelOfDelay(event) {
    const levelOfDelayCurrent = this.levelOfDelay;
    this.showHideLevelOfDelayFields(levelOfDelayCurrent, event.target.value);
    this.levelOfDelay = event.target.value;
    this.setRequiredFields();
  }

  showHideLevelOfDelayFields(value, newValue) {
    const speechLanguageDelay = this.template.querySelectorAll(
      ".speechLanguageDelay"
    );
    const expressNeedsDesires = this.template.querySelectorAll(
      ".expressNeedsDesires"
    );
    const describeCommunicationNeeds = this.template.querySelectorAll(
      ".describeCommunicationNeeds"
    );
    const describeCommunicationNeedsInformation = this.template.querySelectorAll(
      ".describeCommunicationNeedsInformation"
    );

    // Reset all fields if there is a change to the value
    if (value && value !== newValue) {
      this.hide(speechLanguageDelay);
      this.hide(expressNeedsDesires);
      this.hide(describeCommunicationNeeds);
      this.hide(describeCommunicationNeedsInformation);
      this.speechLanguageDelay = "";
      this.expressNeedsDesires = "";
      this.describeCommunicationNeeds = "";
      this.describeCommunicationNeedsInformation = "";
    }

    if (
      newValue &&
      (newValue === "Mild: Functions close to peers" ||
        newValue === "Moderate: Functions below peers")
    ) {
      this.show(speechLanguageDelay);
      this.hide(describeCommunicationNeeds);
      this.hide(describeCommunicationNeedsInformation);
    } else if (
      newValue &&
      newValue ===
        "Severe: Functions nothing like same-age peers, extremely cognitively delayed."
    ) {
      this.show(describeCommunicationNeeds);
      this.show(describeCommunicationNeedsInformation);
      this.hide(speechLanguageDelay);
    } else {
      this.hide(speechLanguageDelay);
      this.hide(expressNeedsDesires);
      this.hide(describeCommunicationNeeds);
      this.hide(describeCommunicationNeedsInformation);
      this.speechLanguageDelay = "";
      this.expressNeedsDesires = "";
      this.describeCommunicationNeeds = "";
      this.describeCommunicationNeedsInformation = "";
    }
  }

  handleChangeSpeechLanguageDelay(event) {
    this.speechLanguageDelay = event.target.value;
    this.showHideSpeechLanguageDelayFields(
      this.speechLanguageDelay,
      this.speechLanguageDelay
    );
    this.setRequiredFields();
  }

  showHideSpeechLanguageDelayFields(value, newValue) {
    const expressNeedsDesires = this.template.querySelectorAll(
      ".expressNeedsDesires"
    );
    const describeCommunicationNeeds = this.template.querySelectorAll(
      ".describeCommunicationNeeds"
    );
    const describeCommunicationNeedsInformation = this.template.querySelectorAll(
      ".describeCommunicationNeedsInformation"
    );

    // Reset all fields if there is a change to the value
    if (value && value !== newValue) {
      this.hide(expressNeedsDesires);
      this.hide(describeCommunicationNeeds);
      this.hide(describeCommunicationNeedsInformation);
      this.expressNeedsDesires = "";
      this.describeCommunicationNeeds = "";
      this.describeCommunicationNeedsInformation = "";
    }

    if (newValue && newValue === "Yes") {
      this.show(expressNeedsDesires);
    } else {
      this.hide(expressNeedsDesires);
      this.hide(describeCommunicationNeeds);
      this.hide(describeCommunicationNeedsInformation);
      this.expressNeedsDesires = "";
      this.describeCommunicationNeeds = "";
      this.describeCommunicationNeedsInformation = "";
    }
  }

  handleChangeExpressNeedsDesires(event) {
    this.expressNeedsDesires = event.target.value;
    this.showHideExpressNeedsDesiresFields(this.expressNeedsDesires);
    this.setRequiredFields();
  }

  showHideExpressNeedsDesiresFields(value) {
    const describeCommunicationNeeds = this.template.querySelectorAll(
      ".describeCommunicationNeeds"
    );
    const describeCommunicationNeedsInformation = this.template.querySelectorAll(
      ".describeCommunicationNeedsInformation"
    );
    if (value && value === "No, child is non-verbal") {
      this.show(describeCommunicationNeeds);
      this.show(describeCommunicationNeedsInformation);
    } else {
      this.hide(describeCommunicationNeeds);
      this.hide(describeCommunicationNeedsInformation);
      this.describeCommunicationNeeds = "";
      this.describeCommunicationNeedsInformation = "";
    }
  }

  handleChangeDescribeCommunicationNeeds(event) {
    this.describeCommunicationNeeds = event.target.value;
    this.setRequiredFields();
  }

  handleChangeDescribeCommunicationNeedsInformation(event) {
    this.describeCommunicationNeedsInformation = event.target.value;
    this.setRequiredFields();
  }

  setRequiredFields() {
    const unplannedHospitalAdmissions = this.template.querySelectorAll(
      ".field, .unplannedHospitalAdmissions"
    );

    if (this.isLeadQualifying) {
      this.isUnplannedHospitalAdmissionsRequired = false;
      this.isTimesChildAdmittedRequired = false;
      this.isAdmittedDiagnosisRequired = false;
      this.isHospitalizationAdmissionIcuRequired = false;
    } else if (!this.isLeadQualifying) {
      this.isUnplannedHospitalAdmissionsRequired = true;
      if (unplannedHospitalAdmissions.value === "Yes") {
        this.isTimesChildAdmittedRequired = true;
        this.isAdmittedDiagnosisRequired = true;
        this.isHospitalizationAdmissionIcuRequired = true;
      } else {
        this.isTimesChildAdmittedRequired = false;
        this.isAdmittedDiagnosisRequired = false;
        this.isHospitalizationAdmissionIcuRequired = false;
      }
    }

    if (this.isLeadQualifying) {
      this.isAdditionalClinicalDetailsRequired = false;
    } else if (!this.isLeadQualifying) {
      this.isAdditionalClinicalDetailsRequired = true;
    }

    if (this.isLeadQualifying) {
      this.isStatementDescribePatientRequired = false;
    } else if (!this.isLeadQualifying) {
      this.isStatementDescribePatientRequired = true;
    }

    const expectConditionDeteriorate = this.template.querySelectorAll(
      ".expectConditionDeteriorate"
    );
    if (expectConditionDeteriorate.value === "Yes") {
      this.isExpectConditionDeteriorateExplainRequired = true;
    } else {
      this.isExpectConditionDeteriorateExplainRequired = false;
    }

    const medicalExpediteProcess = this.template.querySelectorAll(
      ".medicalExpediteProcess"
    );
    if (medicalExpediteProcess.value === "Yes") {
      this.isMedicalExpediteProcessReasonRequired = true;
      this.isProvideTimeFrameWishRequired = true;
    } else {
      this.isMedicalExpediteProcessReasonRequired = false;
      this.isProvideTimeFrameWishRequired = false;
    }

    const provideTimeFrameWish = this.template.querySelectorAll(
      ".provideTimeFrameWish"
    );
    if (provideTimeFrameWish.value === "Other") {
      this.isProvideTimeFrameWishInformationRequired = true;
    } else {
      this.isProvideTimeFrameWishInformationRequired = false;
    }

    const cognitiveDelay = this.template.querySelectorAll(".cognitiveDelay");
    if (cognitiveDelay.value === "Yes") {
      this.isLevelOfDelayRequired = true;
      this.isSpeechLanguageDelayRequired = false;
    } else if (
      cognitiveDelay.value === "No" ||
      cognitiveDelay.value ===
        "I do not have access to that information. I recommend the chapter follow up with the medical team"
    ) {
      this.isLevelOfDelayRequired = false;
      this.isSpeechLanguageDelayRequired = true;
    } else {
      this.isLevelOfDelayRequired = false;
      this.isSpeechLanguageDelayRequired = false;
    }

    const levelOfDelay = this.template.querySelectorAll(".levelOfDelay");
    if (
      levelOfDelay.value === "Mild: Functions close to peers" ||
      levelOfDelay.value === "Moderate: Functions below peers"
    ) {
      this.isSpeechLanguageDelayRequired = true;
      this.isDescribeCommunicationNeedsRequired = false;
      this.isDescribeCommunicationNeedsInformationRequired = false;
    } else if (
      levelOfDelay.value ===
      "Severe: Functions nothing like same-age peers, extremely cognitively delayed."
    ) {
      this.isSpeechLanguageDelayRequired = false;
      this.isDescribeCommunicationNeedsRequired = true;
      this.isDescribeCommunicationNeedsInformationRequired = true;
    } else {
      this.isSpeechLanguageDelayRequired = false;
      this.isDescribeCommunicationNeedsRequired = false;
      this.isDescribeCommunicationNeedsInformationRequired = false;
    }

    const speechLanguageDelay = this.template.querySelectorAll(
      ".speechLanguageDelay"
    );
    if (speechLanguageDelay.value === "Yes") {
      this.isExpressNeedsDesiresRequired = true;
    } else {
      this.isExpressNeedsDesiresRequired = false;
    }

    const expressNeedsDesires = this.template.querySelectorAll(
      ".expressNeedsDesires"
    );
    if (expressNeedsDesires.value === "No, child is non-verbal") {
      this.isDescribeCommunicationNeedsRequired = true;
      this.isDescribeCommunicationNeedsInformationRequired = true;
    } else {
      this.isDescribeCommunicationNeedsRequired = false;
      this.isDescribeCommunicationNeedsInformationRequired = false;
    }
  }

  handleClickSave() {
    this.dispatchEvent(
      new CustomEvent("saveadditionalmedicalquestions", {
        detail: {
          showSpinner: true,
        },
      })
    );

    const describeCommunicationNeedsList = this.describeCommunicationNeeds
      ? this.describeCommunicationNeeds
      : [""];
    const additionalMedicalQuestions = {
      leadId: this.leadId,
      unplannedHospitalAdmissions: this.unplannedHospitalAdmissions,
      timesChildAdmitted: this.timesChildAdmitted,
      admittedDiagnosis: this.admittedDiagnosis,
      hospitalizationAdmissionIcu: this.hospitalizationAdmissionIcu,
      additionalClinicalDetails: this.additionalClinicalDetails,
      statementDescribePatient: this.statementDescribePatient,
      expectConditionDeteriorate: this.expectConditionDeteriorate,
      expectConditionDeteriorateExplain: this.expectConditionDeteriorateExplain,
      medicalExpediteProcess: this.medicalExpediteProcess,
      medicalExpediteProcessReason: this.medicalExpediteProcessReason,
      provideTimeFrameWish: this.provideTimeFrameWish,
      provideTimeFrameWishInformation: this.provideTimeFrameWishInformation,
      medicalSummaryAttachment: this.medicalSummaryAttachment,
      additionalInfoProvide: this.additionalInfoProvide,
      cognitiveDelay: this.cognitiveDelay,
      levelOfDelay: this.levelOfDelay,
      speechLanguageDelay: this.speechLanguageDelay,
      expressNeedsDesires: this.expressNeedsDesires,
      describeCommunicationNeeds: describeCommunicationNeedsList,
      describeCommunicationNeedsInformation: this
        .describeCommunicationNeedsInformation,
    };
    saveAdditionalMedicalQuestions({
      amq: additionalMedicalQuestions,
    })
      .then((result) => {
        this.dispatchEvent(
          new CustomEvent("saveadditionalmedicalquestions", {
            detail: {
              showSpinner: false,
            },
          })
        );
      })
      .catch((error) => {});
  }

  /**
   * LABELS AND OPTIONS:
   */
  get unplannedHospitalAdmissionsLabel() {
    return `HAS ${this.wishChildFirstName.toUpperCase()} HAD ANY UNPLANNED HOSPITAL ADMISSIONS IN THE PAST 12 MONTHS?`;
  }

  get timesChildAdmittedLabel() {
    return `HOW MANY TIMES HAS THE CHILD BEEN ADMITTED?`;
  }

  get admittedDiagnosisLabel() {
    return `WHAT WAS THE ADMITTING DIAGNOSIS?`;
  }

  get hospitalizationAdmissionIcuLabel() {
    return `DID ANY OF THE HOSPITALIZATIONS INCLUDE ADMISSION INTO THE ICU?`;
  }

  get additionalClinicalDetailsLabel() {
    return `PLEASE PROVIDE ADDITIONAL CLINICAL DETAILS OUTLINING ${this.wishChildFirstName.toUpperCase()} MAY MEET MAKE-A-WISH MEDICAL ELIGIBILITY CRITERIA (A CONDITION CURRENTLY PLACING THE CHILD'S LIFE IN JEOPARDY):`;
  }

  get additionalClinicalDetailsSecondLabel() {
    return `(e.g., current complications placing life in jeopardy, acuity, contributing health conditions, treatment, treatment failures, dependence on medical equipment or specialists involved in care. You also have the option to add notes and/or attach a medical summary below.)`;
  }

  get statementDescribePatientLabel() {
    return `PLEASE CHOOSE THE ONE STATEMENT THAT BEST DESCRIBES YOUR PATIENT:`;
  }

  get expectConditionDeteriorateLabel() {
    return `DO YOU EXPECT THIS CHILD'S CONDITION WILL SIGNIFICANTLY DETERIORATE IN THE NEXT 3-6 MONTHS?`;
  }

  get expectConditionDeteriorateExplainLabel() {
    return `PLEASE EXPLAIN:`;
  }

  get medicalExpediteProcessLabel() {
    return `IS THERE A MEDICAL NECESSITY TO EXPEDITE THE PROCESS?`;
  }

  get medicalExpediteProcessReasonLabel() {
    return `PLEASE PROVIDE MEDICAL REASON FOR REQUEST:`;
  }

  get provideTimeFrameWishLabel() {
    return `PLEASE PROVIDE IDEAL TIMEFRAME FOR WISH, IF ELIGIBLE:`;
  }

  get provideTimeFrameWishInformationLabel() {
    return `PLEASE PROVIDE IDEAL TIMEFRAME:`;
  }

  get medicalSummaryAttachmentLabel() {
    return `MEDICAL SUMMARY (RECENT ECHO/MRI REPORTS MAY ALSO BE HELPFUL, DEPENDING ON DIAGNOSIS):`;
  }

  get medicalSummaryAttachmentSecondLabel() {
    return `File upload might take a while, please click refresh if you do not see your file.`;
  }

  get additionalInfoProvideLabel() {
    return `IS THERE ADDITIONAL INFORMATION YOU WOULD LIKE TO PROVIDE?`;
  }

  get additionalInfoProvideSecondLabel() {
    return `(e.g., additional information that will help us make an eligibility determination for conditions that require review on a case-by-case basis.)`;
  }

  get cognitiveDelayLabel() {
    return `DOES ${this.wishChildFirstName.toUpperCase()} HAVE COGNITIVE DELAYS?`;
  }

  get cognitiveDelaySecondLabel() {
    return `(this question does not affect eligibility criteria. if the child's condition is eligible, this information helps our volunteers and staff to plan an appropriate wish.)`;
  }

  get levelOfDelayLabel() {
    return `PLEASE INDICATE THE LEVEL OF DELAY:`;
  }

  get speechLanguageDelayLabel() {
    return `DOES ${this.wishChildFirstName.toUpperCase()} HAVE SPEECH OR LANGUAGE DELAYS OR USE AN ALTERNATIVE FORM OF COMMUNICATION?`;
  }

  get expressNeedsDesiresLabel() {
    return `CAN ${this.wishChildFirstName.toUpperCase()} EXPRESS THEIR NEEDS AND DESIRES BY SAYING THEM WITH WORDS?`;
  }

  get describeCommunicationNeedsLabel() {
    return `WHICH OF THE FOLLOWING BEST DESCRIBES HOW ${this.wishChildFirstName.toUpperCase()} COMMUNICATES NEEDS AND WANTS?`;
  }

  get describeCommunicationNeedsInformationLabel() {
    return `PLEASE ADD ANY ADDITIONAL INFORMATION ABOUT THE CHILD’S ABILITY TO COMMUNICATE:`;
  }

  get yesOrNoOptions() {
    return [
      { label: "Yes", value: "Yes" },
      { label: "No", value: "No" },
    ];
  }

  get yesOrNoOrNotSureOptions() {
    return [
      { label: "Yes", value: "Yes" },
      { label: "No", value: "No" },
      { label: "Not Sure", value: "Not Sure" },
    ];
  }

  get statementDescribePatientOptions() {
    return [
      {
        label: `${this.wishChildFirstName} has a condition for which curative treatment may be feasible but can fail; non-adherence is not included as a treatment failure. (e.g., cancer, irreversible organ failure)`,
        value: "TREATMENT_MAY_BE_FEASIBLE_BUT_CAN_FAIL",
      },
      {
        label: `${this.wishChildFirstName} has a condition with a known history of a significantly shortened life expectancy, but frequent and/or long periods of intensive treatment may prolong life and allow participation in normal activities (e.g., cystic fibrosis, solid organ transplant)`,
        value: "TREATMENT_MAY_PROLONG_NORMAL_ACTIVITIES",
      },
      {
        label: `${this.wishChildFirstName} has a condition without curative treatment options in which debilitation may extend over many years (e.g., severe treatment-resistant epilepsy, some metabolic diseases)`,
        value: "DEBILITATION_MAY_EXTEND_OVER_MANY_YEARS",
      },
      {
        label: `${this.wishChildFirstName} has an irreversible but non-progressive condition with life-threatening comorbidities and a known history of a significantly shortened life expectancy (e.g. anoxic brain injury, severe cerebral palsy)`,
        value: "INCREASED_PROBABILITY_OF_PREMATURE_DEATH",
      },
      {
        label: `${this.wishChildFirstName} has a condition for which there is no reasonable hope of cure and from which children or young people will experience a significantly shortened life expectancy (e.g., Duchenne muscular dystrophy or neurodegenerative disease)`,
        value: "CHILD_WILL_ULTIMATELY_DIE_PREMATURELY",
      },
      {
        label: `None of these statements describe ${this.wishChildFirstName}`,
        value: "NONE_OF_THESE_STATEMENTS_DESCRIBES_CHILD",
      },
    ];
  }

  get cognitiveDelayOptions() {
    return [
      { label: "Yes", value: "Yes" },
      { label: "No", value: "No" },
      {
        label:
          "I do not have access to that information. I recommend the chapter follow up with the medical team",
        value:
          "I do not have access to that information. I recommend the chapter follow up with the medical team",
      },
    ];
  }

  get provideTimeFrameWishOptions() {
    return [
      { label: "< 1 month", value: "< 1 month" },
      { label: "1-3 months", value: "< 1 month" },
      { label: "3-6 months", value: "3-6 months" },
      { label: "Other", value: "Other" },
    ];
  }

  get levelOfDelayOptions() {
    return [
      {
        label: "Mild: Functions close to peers",
        value: "Mild: Functions close to peers",
      },
      {
        label: "Moderate: Functions below peers",
        value: "Moderate: Functions below peers",
      },
      {
        label:
          "Severe: Functions nothing like same-age peers, extremely cognitively delayed.",
        value:
          "Severe: Functions nothing like same-age peers, extremely cognitively delayed.",
      },
    ];
  }

  get speechLanguageDelayOptions() {
    return [
      {
        label: "No, child is verbal at an age-appropriate level.",
        value: "No, child is verbal at an age-appropriate level.",
      },
      { label: "Yes", value: "Yes" },
      {
        label:
          "I do not have access to that information. I recommend the chapter follow up with the medical team",
        value:
          "I do not have access to that information. I recommend the chapter follow up with the medical team",
      },
    ];
  }

  get expressNeedsDesiresOptions() {
    return [
      {
        label:
          "Yes, child is verbal but delayed and able to be understood by others",
        value:
          "Yes, child is verbal but delayed and able to be understood by others",
      },
      { label: "No, child is non-verbal", value: "No, child is non-verbal" },
    ];
  }

  get describeCommunicationNeedsOptions() {
    return [
      {
        label:
          "Crying without the capacity to indicate needs or wants to a caregiver well known to the child",
        value:
          "Crying without the capacity to indicate needs or wants to a caregiver well known to the child",
      },
      {
        label:
          "Pointing at desired objects, reaching out for something or someone they want,  taking your hand to what they want",
        value:
          "Pointing at desired objects, reaching out for something or someone they want,  taking your hand to what they want",
      },
      {
        label:
          "Repeating something they just heard in a manner suggesting the child is desiring (as opposed to just echoing words)",
        value:
          "Repeating something they just heard in a manner suggesting the child is desiring (as opposed to just echoing words)",
      },
      {
        label: "Sign language (either standard or specific to the child)",
        value: "Sign language (either standard or specific to the child)",
      },
      {
        label: "Assistive communication tool, tablet, or computer",
        value: "Assistive communication tool, tablet, or computer",
      },
    ];
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
