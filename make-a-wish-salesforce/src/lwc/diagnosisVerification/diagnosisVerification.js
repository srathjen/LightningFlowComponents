/**
@description Diagnosis Verification component, the parent component for the Diagnosis Verification process.
@author Gustavo Mayer, Traction on Demand
@createdDate 08/Feb/2021
*/
import { LightningElement, api, wire } from "lwc";
import findDiagnosisVerification from "@salesforce/apex/DiagnosisVerificationController.getDiagnosisVerificationByLeadId";
import updateLastDvSaveDate from "@salesforce/apex/DiagnosisVerificationController.updateLastDvSaveDate";

export default class DiagnosisVerification extends LightningElement {
  @api leadId;

  _leadId;
  process;
  isLoginSuccessful = false;
  isShowNavigation = false;
  isSubmitCanceled = false;
  isShowSpinner = false;
  notificationConfig = {
    title: "",
    message: "",
    variant: "success",
    autoClose: true,
    autoCloseErrorWarning: true
  };

  @wire(findDiagnosisVerification, {
    leadId: "$_leadId"
  })
  wired(result) {
    if (result.data) {
      this.process = result.data.process;
      this.isShowNavigation = true;
      this.processStepNavigation(1);
    } else if (result.error) {
      console.error("Test " + result.error);
    }
  }

  handleLoginEvent(event) {
    const login = event.detail;
    if (login.isLoginSuccessful) {
      this._leadId = this.leadId;
      this.isLoginSuccessful = true;
    } else {
      this.isLoginSuccessful = false;
      this.notificationConfig = {
        title: login.message,
        message: "",
        variant: "error",
        autoClose: true,
        autoCloseErrorWarning: true
      };
      this.template.querySelector("c-notification-toast").showCustomNotice();
    }
  }

  handleNavigationStepEvent(event) {
    if (event.detail.error) {
      this.notificationConfig = {
        title:
          "Please fill out the Medical Professional Information and click save",
        message: "",
        variant: "error",
        autoClose: true,
        autoCloseErrorWarning: true
      };
      this.template.querySelector("c-notification-toast").showCustomNotice();
    } else {
      let processUpdate = event.detail.process;
      this.process = processUpdate;
      this.processStepNavigation(processUpdate.currentStepId);
    }
  }

  processStepNavigation(currentStepId) {
    this.template
      .querySelector("c-dv-child-information")
      .handleLoadChildInformation(this.leadId);
    const step1 = this.template.querySelectorAll(".step1");
    this.hide(step1);
    const step2 = this.template.querySelectorAll(".step2");
    this.hide(step2);
    const step3 = this.template.querySelectorAll(".step3");
    this.hide(step3);
    const step4 = this.template.querySelectorAll(".step4");
    this.hide(step4);
    if (currentStepId === 1) {
      this.template
        .querySelector("c-dv-medical-professional-information")
        .handleLoadMedicalProfessionalInformation(this.leadId);
      this.show(step1);
    } else if (currentStepId === 2) {
      this.template
        .querySelector("c-dv-diagnosis")
        .handleLoadDvDiagnosis(this.leadId);
      this.show(step2);
    } else if (currentStepId === 3) {
      this.template
        .querySelector("c-dv-additional-medical-questions")
        .handleLoadAdditionalMedicalQuestions(this.leadId);
      this.show(step3);
    } else if (currentStepId === 4) {
      /*this.template
        .querySelector("c-dv-travel-questions")
        .handleLoadTravelQuestions(this.leadId);*/
      this.show(step4);
    }
  }

  handleCancelSubmit(event) {
    this.isShowSpinner = false;
    this.isSubmitCanceled = true;
    const spinner = this.template.querySelectorAll(".spinner");
    this.hide(spinner);
  }

  handleShowSpinner(event) {
    this.isShowSpinner = event.detail;
  }

  handleSaveMedicalProfessionalInformationEvent(event) {
    this.updateLeadLastDvSaveDate();
    this.showSaveSuccessMessage();
    this.isShowSpinner = event.detail.showSpinner;

    if (event.detail.medicalProfessionalInformation) {
      const {
        partOfHealthcareTeam
      } = event.detail.medicalProfessionalInformation;
      if (partOfHealthcareTeam === "Yes") {
        this.process = {
          currentStepId: 1,
          steps: [
            {
              id: 1,
              label: "Medical Professional Information",
              status: "active"
            },
            { id: 2, label: "Diagnosis", status: "active" },
            { id: 3, label: "Additional Medical Questions", status: "active" },
            { id: 4, label: "Travel Questions", status: "active" }
          ]
        };
      } else {
        this.process = {
          currentStepId: 1,
          steps: [
            {
              id: 1,
              label: "Medical Professional Information",
              status: "active"
            },
            { id: 2, label: "Diagnosis", status: "incomplete" },
            {
              id: 3,
              label: "Additional Medical Questions",
              status: "incomplete"
            },
            { id: 4, label: "Travel Questions", status: "incomplete" }
          ]
        };
      }
    }
  }

  handleSaveAdditionalMedicalQuestionsEvent(event) {
    this.updateLeadLastDvSaveDate();
    this.showSaveSuccessMessage();
    this.isShowSpinner = event.detail.showSpinner;
  }

  handleSaveDiagnosis(event) {
    this.updateLeadLastDvSaveDate();
    this.showSaveSuccessMessage();
    this.isShowSpinner = event.detail.showSpinner;
  }

  showSaveSuccessMessage() {
    this.notificationConfig = {
      title:
        "Your form has been successfully saved but has not yet been submitted.",
      message: "Please click ‘Submit’ to complete Diagnosis Verification.",
      variant: "success",
      autoClose: true,
      autoCloseErrorWarning: true
    };
    this.template.querySelector("c-notification-toast").showCustomNotice();
  }

  updateLeadLastDvSaveDate() {
    updateLastDvSaveDate({ leadId: this._leadId })
      .then((result) => {
        console.log("Last DV Save date updated successfully.");
      })
      .catch((error) => {
        console.log("Error updating last dv save date.");
      });
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
