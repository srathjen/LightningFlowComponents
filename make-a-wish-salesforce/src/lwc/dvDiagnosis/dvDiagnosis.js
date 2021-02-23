/**
@description Diagnosis component for the Diagnosis Verification process
@author Michelle Cominotto, Make-A-Wish
@createdDate 02/18/2021
**/

import { LightningElement, api, wire } from "lwc";
import getLeadDvDiagnosis from "@salesforce/apex/DvDiagnosisController.getLeadDvDiagnosis";
import saveLeadDvDiagnosis from "@salesforce/apex/DvDiagnosisController.saveLeadDvDiagnosis";

export default class DvDiagnosis extends LightningElement {
  leadId;
  dvDiagnosis;
  leadName;
  comatoseState;
  isShowModal = false;
  modalConfig;

  @api handleLoadDvDiagnosis(leadId) {
    this.leadId = leadId;
  }

  @wire(getLeadDvDiagnosis, { recordId: "$leadId" })
  lead({ data, error }) {
    if (data) {
      this.dvDiagnosis = data;
      this.leadName = data.leadName;
      this.comatoseState = data.comatoseVegetativeState;
      if (this.comatoseState === "Yes") {
        this.displayModal();
      }
    } else if (error) {
      console.log(
        "Error occurred retrieving lead information: " + JSON.stringify(error)
      );
    }
  }

  get leadNameLabel() {
    return "ABOUT " + this.leadName;
  }

  get comatoseLabel() {
    return (
      "IS " +
      this.leadName.toUpperCase() +
      " IN A COMATOSE OR VEGETATIVE STATE?"
    );
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
      title:
        "Please confirm.<br>Is this child in a comatose or vegetative state?",
      body:
        "Children in a comatose or vegetative state are not eligible for Make-A-Wish. By " +
        "selecting “Yes” as your final choice, you acknowledge that this child is in a comatose " +
        "or vegetative state and does not meet our eligibility criteria; you will not need to complete " +
        "the Diagnosis Verification form any further for this child.",
      negativeTitle: "No",
      positiveTitle: "Yes"
    };
  }

  handleComatoseChange(event) {
    this.comatoseState = event.detail.value;
    if (this.comatoseState === "Yes") {
      this.displayModal();
    }
  }

  handleModalEvent(event) {
    let modalButtonClicked = event.detail.modalAction;
    this.isShowModal = false;
    if (modalButtonClicked === "negative") {
      this.comatoseState = "";
    } else {
      this.dispatchEvent(new CustomEvent("showspinner", { detail: true }));
      let diagnosis = {
        leadId: this.leadId,
        comatoseVegetativeState: this.comatoseState
      };

      saveLeadDvDiagnosis({
        diagnosisWrapper: diagnosis
      })
        .then((result) => {
          this.dispatchEvent(new CustomEvent("cancelsubmit"));
        })
        .catch((error) => {
          console.log("Error saving diagnosis " + JSON.stringify(error));
        });
    }
  }

  handleSaveClick(event) {
    this.dispatchEvent(
      new CustomEvent("savediagnosis", {
        detail: {
          showSpinner: true
        }
      })
    );
    let diagnosis = {
      leadId: this.leadId,
      comatoseVegetativeState: this.comatoseState
    };

    saveLeadDvDiagnosis({
      diagnosisWrapper: diagnosis
    })
      .then((result) => {
        this.dispatchEvent(
          new CustomEvent("savediagnosis", {
            detail: {
              showSpinner: false
            }
          })
        );
      })
      .catch((error) => {
        console.log("Error saving diagnosis " + JSON.stringify(error));
      });
  }
}
