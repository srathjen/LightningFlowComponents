/**
@description Medical Professional Information component for the Diagnosis Verification process
@author Michelle Cominotto, Make-A-Wish
@createdDate 02/08/2021
**/

import { LightningElement, api, wire } from "lwc";
import getLeadMedicalProfessionalInformation from "@salesforce/apex/DvMedicalProfessionalInfoController.getLeadMedicalProfessionalInformation";
import saveLeadMedicalProfessionalInformation from "@salesforce/apex/DvMedicalProfessionalInfoController.saveLeadMedicalProfessionalInformation";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import MPTYPE_FIELD from "@salesforce/schema/Lead.I_am_Recognized_To_Practice_As_a__c";
import InputUtils from "c/inputUtils";

export default class DvMedicalProfessionalInformation extends LightningElement {
  leadId;
  dvLeadInfo;
  recordTypeId;
  isRecipientSigner;
  showNewSignerInformation;
  mpTypeOptions;
  mpTypeSelection;
  isHealthcareTeam;
  dvSignerFirstName;
  dvSignerLastName;
  dvSignerEmail;
  dvSignerPhone;
  isShowModal;
  modalConfig;
  saveError;
  utils = new InputUtils();

  @api handleLoadMedicalProfessionalInformation(leadId) {
    this.leadId = leadId;
  }

  @api validateInput() {
    let isValid = true;
    let inputFields = this.template.querySelectorAll(
      "lightning-input, lightning-combobox"
    );
    isValid = this.utils.validateInputs(inputFields);
    if (isValid) {
      this.saveMedicalProfessionalInformation(false, false, true);
    }
    return isValid;
  }

  @wire(getLeadMedicalProfessionalInformation, { recordId: "$leadId" })
  lead({ data, error }) {
    if (data) {
      this.dvLeadInfo = data;
      this.recordTypeId = data.leadRecordTypeId;
      this.mpTypeSelection = data.practicingMpType;
      this.isHealthcareTeam = data.partOfHealthcareTeam;
      if (this.isHealthcareTeam === "No") {
        this.displayModal();
      } else {
        this.isShowModal = false;
      }
      if (data.changedDvSigner) {
        this.isRecipientSigner = "No";
        this.showNewSignerInformation = true;
        this.dvSignerFirstName = data.dvSignerFirstName;
        this.dvSignerLastName = data.dvSignerLastName;
        this.dvSignerPhone = data.dvSignerPhone;
        this.dvSignerEmail = data.dvSignerEmail;
      } else if (data.isPreviouslySaved) {
        this.isRecipientSigner = "Yes";
        this.showNewSignerInformation = false;
      } else {
        this.showNewSignerInformation = false;
      }
    } else if (error) {
      console.log(
        "Error occurred retrieving lead information: " + JSON.stringify(error)
      );
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "$recordTypeId",
    fieldApiName: MPTYPE_FIELD
  })
  setPicklistOptions({ error, data }) {
    if (data) {
      this.mpTypeOptions = data.values;
    } else if (error) {
      console.log("Error retrieving picklist values " + error);
    }
  }

  get dvRecipientLabel() {
    let stringLabel =
      "WILL " +
      this.dvLeadInfo.dvRecipient.toUpperCase() +
      " BE COMPLETING THIS DOCUMENT?";
    return stringLabel;
  }

  get yesNoOptions() {
    return [
      { label: "Yes", value: "Yes" },
      { label: "No", value: "No" }
    ];
  }

  displayModal() {
    this.isShowModal = true;
    this.modalConfig = {
      title: "Direct Knowledge of Patient's Condition",
      body:
        "This form should be completed by someone with direct knowledge of the patient's condition and who is part of the treating healthcare team.",
      negativeTitle: "Cancel Submission",
      positiveTitle: "Change Selection & Continue"
    };
  }

  copyToWrapper() {
    let tempWrapper = JSON.parse(JSON.stringify(this.dvLeadInfo));
    tempWrapper.dvSignerFirstName = this.dvSignerFirstName;
    tempWrapper.dvSignerLastName = this.dvSignerLastName;
    tempWrapper.dvSignerEmail = this.dvSignerEmail;
    tempWrapper.dvSignerPhone = this.dvSignerPhone;
    tempWrapper.practicingMpType = this.mpTypeSelection;
    tempWrapper.partOfHealthcareTeam = this.isHealthcareTeam;
    if (this.isRecipientSigner === "Yes") {
      tempWrapper.changedDvSigner = false;
    } else if (this.isRecipientSigner === "No") {
      tempWrapper.changedDvSigner = true;
    }
    this.dvLeadInfo = tempWrapper;
  }

  handleSignerChange(event) {
    this.isRecipientSigner = event.detail.value;
    if (this.isRecipientSigner === "No") {
      this.showNewSignerInformation = true;
    } else {
      this.showNewSignerInformation = false;
    }
    if (this.isRecipientSigner) {
      let inputIsSigner = this.template.querySelector(".signer");
      inputIsSigner.setCustomValidity("");
      inputIsSigner.reportValidity();
    }
  }

  handleFirstNameChange(event) {
    this.dvSignerFirstName = event.detail.value;
    if (this.dvSignerFirstName) {
      let inputFirstName = this.template.querySelector(".firstName");
      inputFirstName.setCustomValidity("");
      inputFirstName.reportValidity();
    }
  }

  handleLastNameChange(event) {
    this.dvSignerLastName = event.detail.value;
    if (this.dvSignerLastName) {
      let inputLastName = this.template.querySelector(".lastName");
      inputLastName.setCustomValidity("");
      inputLastName.reportValidity();
    }
  }

  handleEmailChange(event) {
    this.dvSignerEmail = event.detail.value;
    let check = this.utils.validateEmail(this.dvSignerEmail);
    if (check) {
      let inputEmail = this.template.querySelector(".email");
      inputEmail.setCustomValidity("");
      inputEmail.reportValidity();
    }
  }

  handlePhoneChange(event) {
    this.dvSignerPhone = this.utils.applyPhoneMask(event.target.value);
    if (this.dvSignerPhone.length === 14) {
      let phoneInput = this.template.querySelector(".phone");
      phoneInput.setCustomValidity("");
      phoneInput.reportValidity();
    }
  }

  handleMpTypeChange(event) {
    this.mpTypeSelection = event.detail.value;
    if (this.mpTypeSelection) {
      let inputMpType = this.template.querySelector(".mpType");
      inputMpType.setCustomValidity("");
      inputMpType.reportValidity();
    }
  }

  handleHealthcareTeamChange(event) {
    this.isHealthcareTeam = event.detail.value;
    if (this.isHealthcareTeam === "No") {
      this.displayModal();
    }
    if (this.isHealthcareTeam) {
      let inputHealthcareTeam = this.template.querySelector(".healthcareTeam");
      inputHealthcareTeam.setCustomValidity("");
      inputHealthcareTeam.reportValidity();
    }
  }

  handleModalEvent(event) {
    let modalButtonClicked = event.detail.modalAction;
    this.isShowModal = false;
    if (modalButtonClicked == "positive") {
      this.isHealthcareTeam = "";
    } else {
      this.dispatchEvent(new CustomEvent("showspinner", { detail: true }));
      this.copyToWrapper();
      saveLeadMedicalProfessionalInformation({
        dvMedicalInfoWrapper: this.dvLeadInfo
      })
        .then((result) => {
          this.dispatchEvent(
            new CustomEvent("cancelsubmit", {
              detail: {
                success: true
              }
            })
          );
        })
        .catch((error) => {
          this.saveError = error.body.message;
          this.dispatchEvent(
            new CustomEvent("cancelsubmit", {
              detail: {
                success: false,
                message: "An error occurred."
              }
            })
          );
        });
    }
  }

  handleSaveClick() {
    this.saveMedicalProfessionalInformation(true, false, false);
  }

  saveMedicalProfessionalInformation(showMessage, showSpinner, showNext) {
    this.dispatchEvent(new CustomEvent("showspinner", { detail: true }));
    this.copyToWrapper();
    saveLeadMedicalProfessionalInformation({
      dvMedicalInfoWrapper: this.dvLeadInfo
    })
      .then((result) => {
        this.dispatchEvent(
          new CustomEvent("savemedicalprofessionalinformationevent", {
            detail: {
              success: true,
              showMessage: showMessage,
              medicalProfessionalInformation: this.dvLeadInfo,
              showSpinner: showSpinner,
              showNext: showNext
            }
          })
        );
      })
      .catch((error) => {
        this.saveError = error.body.message;
        this.dispatchEvent(
          new CustomEvent("savemedicalprofessionalinformationevent", {
            detail: {
              success: false,
              message: "An error occurred while saving.",
              showSpinner: showSpinner
            }
          })
        );
      });
  }
}
