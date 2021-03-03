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
  isShowAcknowledgeStatements = false;
  isShowSubmit = false;
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
      this.processStepNavigation(1, "load");
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

  updateProcess(stepId, step1Status, step2Status, step3Status, step4Status) {
    this.process = {
      currentStepId: stepId,
      steps: [
        {
          id: 1,
          label: "Medical Professional Information",
          status: step1Status
        },
        { id: 2, label: "Diagnosis", status: step2Status },
        {
          id: 3,
          label: "Additional Medical Questions",
          status: step3Status
        },
        { id: 4, label: "Travel Questions", status: step4Status }
      ]
    };
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
      this.processStepNavigation(
        processUpdate.currentStepId,
        processUpdate.stepAction
      );
    }
  }

  processStepNavigation(currentStepId, stepAction) {
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
    this.isShowAcknowledgeStatements = false;
    let validationCheck;
    if (currentStepId === 1) {
      this.updateProcess(1, "active", "incomplete", "incomplete", "incomplete");
      this.template
        .querySelector("c-dv-medical-professional-information")
        .handleLoadMedicalProfessionalInformation(this.leadId);
      this.show(step1);
    } else if (currentStepId === 2) {
      if (stepAction === "next") {
        this.show(step1);
        validationCheck = this.template
          .querySelector("c-dv-medical-professional-information")
          .validateInput();
      } else if (stepAction === "previous") {
        this.updateProcess(2, "active", "active", "incomplete", "incomplete");
        this.template
          .querySelector("c-dv-diagnosis")
          .handleLoadDvDiagnosis(this.leadId);
        this.show(step2);
      }
      if (validationCheck === false) {
        this.updateProcess(
          1,
          "active",
          "incomplete",
          "incomplete",
          "incomplete"
        );
      }
    } else if (currentStepId === 3) {
      if (stepAction === "next") {
        this.show(step2);
        validationCheck = this.template
          .querySelector("c-dv-diagnosis")
          .validateInput();
      } else if (stepAction === "previous") {
        this.updateProcess(3, "active", "active", "active", "incomplete");
        this.template
          .querySelector("c-dv-additional-medical-questions")
          .handleLoadAdditionalMedicalQuestions(this.leadId);
        this.show(step3);
      }
      if (validationCheck === false) {
        this.updateProcess(2, "active", "active", "incomplete", "incomplete");
      }
    } else if (currentStepId === 4) {
      this.show(step3);
      validationCheck = this.template
        .querySelector("c-dv-additional-medical-questions")
        .validateInput();
      if (validationCheck === false) {
        this.updateProcess(3, "active", "active", "active", "incomplete");
      }
    }
  }

  handleCancelSubmit(event) {
    this.isShowSpinner = false;
    if (event.detail.success) {
      this.isSubmitCanceled = true;
      this.updateLeadLastDvSaveDate();
    } else {
      this.showErrorMessage(event.detail.message);
    }
  }

  handleShowSpinner(event) {
    this.isShowSpinner = event.detail;
  }

  handleSaveMedicalProfessionalInformationEvent(event) {
    if (event.detail.success) {
      this.updateLeadLastDvSaveDate();
      if (event.detail.showMessage) {
        this.showSaveSuccessMessage();
      }
      if (event.detail.showNext) {
        this.updateProcess(2, "active", "active", "incomplete", "incomplete");
        this.template
          .querySelector("c-dv-diagnosis")
          .handleLoadDvDiagnosis(this.leadId);
        this.hide(this.template.querySelectorAll(".step1"));
        this.show(this.template.querySelectorAll(".step2"));
      }
    } else {
      this.showErrorMessage(event.detail.message);
    }
    this.isShowSpinner = event.detail.showSpinner;
  }

  handleSaveDiagnosisEvent(event) {
    if (event.detail.success) {
      this.updateLeadLastDvSaveDate();
      if (event.detail.showMessage) {
        this.showSaveSuccessMessage();
      }
      if (event.detail.showNext) {
        this.updateProcess(3, "active", "active", "active", "incomplete");
        this.template
          .querySelector("c-dv-additional-medical-questions")
          .handleLoadAdditionalMedicalQuestions(this.leadId);
        this.hide(this.template.querySelectorAll(".step2"));
        this.show(this.template.querySelectorAll(".step3"));
      }
    } else if (event.detail.success === false) {
      this.showErrorMessage(event.detail.message);
    }
    this.isShowSpinner = event.detail.showSpinner;
  }

  handleSaveAdditionalMedicalQuestionsEvent(event) {
    if (event.detail.success) {
      this.updateLeadLastDvSaveDate();
      if (event.detail.showMessage) {
        this.showSaveSuccessMessage();
      }
      if (event.detail.showNext) {
        this.updateProcess(4, "active", "active", "active", "active");
        this.template
          .querySelector("c-dv-travel-questions")
          .handleLoadTravelQuestions(this.leadId);
        this.hide(this.template.querySelectorAll(".step3"));
        this.show(this.template.querySelectorAll(".step4"));
        this.isShowAcknowledgeStatements = true;
      }
    } else if (event.detail.success === false) {
      this.showErrorMessage(event.detail.message);
    }
    this.isShowSpinner = event.detail.showSpinner;
  }

  handleSaveTravelQuestionsEvent(event) {
    const eventDetail = event.detail;
    if (eventDetail) {
      if (eventDetail.message) {
        if (eventDetail.success === true) {
          this.showSaveSuccessMessage();
        } else if (eventDetail.success === false) {
          this.showErrorMessage(eventDetail.message);
        }
      }
    }
    this.isShowSpinner = event.detail.showSpinner;
  }

  /*handleAcknowledgeCheckboxChange(event) {
    if (event.detail.checked) {
      this.isShowSubmit = true;
    } else {
      this.isShowSubmit = false;
    }
  }

  handleValidations(event) {
    let check = this.template
      .querySelector("c-dv-medical-professional-information")
      .validateInput();
  }*/

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

  showErrorMessage(message) {
    this.notificationConfig = {
      title: message,
      message: "",
      variant: "error",
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

  /*get mpTypeLabel() {
    return "&bull; I am recognized by my state to practice as a ---<br>";
  }

  get directKnowledgeLabel() {
    return "&bull; I have direct knowledge of this patients condition and I am part of the treating healthcare team<br>";
  }

  get informationProvidedLabel() {
    return "&bull; The information I have provided is accurate and complete to the best of my knowledge<br>";
  }*/
}
