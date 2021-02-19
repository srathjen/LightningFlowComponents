/**
@description Medical Professional Information component for the Diagnosis Verification process
@author Michelle Cominotto, Make-A-Wish
@createdDate 02/08/2021
**/

import { LightningElement, api, wire, track } from "lwc";
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
  }

  handleFirstNameChange(event) {
    this.dvSignerFirstName = event.detail.value;
  }

  handleLastNameChange(event) {
    this.dvSignerLastName = event.detail.value;
  }

  handleEmailChange(event) {
    this.dvSignerEmail = event.detail.value;
  }

  handlePhoneChange(event) {
    this.dvSignerPhone = this.utils.applyPhoneMask(event.target.value);
  }

  handleMpTypeChange(event) {
    this.mpTypeSelection = event.detail.value;
  }

  handleHealthcareTeamChange(event) {
    this.isHealthcareTeam = event.detail.value;
    if (this.isHealthcareTeam === "No") {
      this.displayModal();
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
          this.dispatchEvent(new CustomEvent("cancelsubmit"));
        })
        .catch((error) => {
          this.saveError = error;
        });
    }
  }

  handleSaveClick(event) {
    this.dispatchEvent(new CustomEvent("showspinner", { detail: true }));
    this.copyToWrapper();
    saveLeadMedicalProfessionalInformation({
      dvMedicalInfoWrapper: this.dvLeadInfo
    })
      .then((result) => {
        this.dispatchEvent(
          new CustomEvent("savemedicalprofessionalinformationevent", {
            detail: {
              medicalProfessionalInformation: this.dvLeadInfo,
              showSpinner: false
            }
          })
        );
      })
      .catch((error) => {
        this.saveError = error;
      });
  }
}
