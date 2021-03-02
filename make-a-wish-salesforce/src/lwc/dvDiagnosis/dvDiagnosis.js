/**
@description Diagnosis component for the Diagnosis Verification process
@author Michelle Cominotto, Make-A-Wish
@createdDate 02/18/2021
**/

import { LightningElement, api, wire } from "lwc";
import getLeadDvDiagnosis from "@salesforce/apex/DvDiagnosisController.getLeadDvDiagnosis";
import saveLeadDvDiagnosis from "@salesforce/apex/DvDiagnosisController.saveLeadDvDiagnosis";
//import findMedicalQuestions from "@salesforce/apex/DvDiagnosisController.findDiagnosisMedicalQuestionsByCondition";
import InputUtils from "c/inputUtils";

export default class DvDiagnosis extends LightningElement {
  leadId;
  dvDiagnosis;
  leadName;
  comatoseState;
  receivedDate;
  isShowModal = false;
  modalConfig;
  //primaryDiagnosis;
  //primaryDiagnosisMedicalQuestions = [];
  utils = new InputUtils();

  @api handleLoadDvDiagnosis(leadId) {
    this.leadId = leadId;
  }

  @api validateInput() {
    let isValid = true;
    let inputFields = this.template.querySelectorAll(
      "lightning-combobox, lightning-textarea"
    );
    isValid = this.utils.validateInputs(inputFields);
    if (isValid) {
      this.saveDiagnosis(false, true, true);
    }
    return isValid;
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

  /*get primaryDiagnosisLabel() {
    return "PRIMARY DIAGNOSIS";
  }

  get primaryDiagnosisHelpTextLabel() {
    return "Based on Make-A-Wish Eligibility Criteria";
  }*/

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
      let today = new Date();
      this.receivedDate = today.toISOString();
      let diagnosis = {
        leadId: this.leadId,
        comatoseVegetativeState: this.comatoseState,
        receivedDate: this.receivedDate
      };

      saveLeadDvDiagnosis({
        diagnosisWrapper: diagnosis
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
          this.dispatchEvent(
            new CustomEvent("cancelsubmit", {
              detail: {
                success: false,
                message: "Error saving diagnosis information."
              }
            })
          );
        });
    }
  }

  handleSaveClick() {
    this.saveDiagnosis(true, true, false);
  }

  saveDiagnosis(showMessage, showSpinner, showNext) {
    this.dispatchEvent(
      new CustomEvent("savediagnosisevent", {
        detail: {
          showSpinner: showSpinner
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
          new CustomEvent("savediagnosisevent", {
            detail: {
              success: true,
              showMessage: showMessage,
              showSpinner: false,
              showNext: showNext
            }
          })
        );
      })
      .catch((error) => {
        this.dispatchEvent(
          new CustomEvent("savediagnosisevent", {
            detail: {
              success: false,
              message: "An error occurred while saving.",
              showSpinner: false
            }
          })
        );
      });
  }

  /*handleDiagnosisChangeEvent(event) {
    const eventDetail = event.detail;
    if (eventDetail) {
      console.log("CD -> " + JSON.stringify(event.detail));
      if (eventDetail.conditionDescriptionId) {
        const conditionWrapper = {
          leadId: this.leadId,
          conditionDescriptionId: eventDetail.conditionDescriptionId
          // eventDetail.conditionDescriptionName;
          // eventDetail.icdCodeId;
          // eventDetail.icdCodeName;
          // eventDetail.icdCodeDescription;
        };

        findMedicalQuestions({
          conditionWrapper
        })
          .then((result) => {
            console.log(JSON.stringify(result));
            this.primaryDiagnosisMedicalQuestions = result;
          })
          .catch((error) => {
            console.log(
              "Error finding medical questions " + JSON.stringify(error)
            );
          });
      }
    }
  }

  handleChangeMedicalQuestion(event) {
    console.log("Id " + event.target.id);
    console.log("Key " + event.target.accessKey);
    console.log("Dataset " + JSON.stringify(event.target.dataset));
    console.log("Value " + event.target.value);
    console.log("Index " + event.target.dataset.id);
    // const value = event.target.value;
    // let primaryDiagnosisMedicalQuestionsCopy = [...this.primaryDiagnosisMedicalQuestions];
    // primaryDiagnosisMedicalQuestionsCopy[event.target.dataset.id].answer = value;
    // console.log('Index ' + JSON.stringify(primaryDiagnosisMedicalQuestionsCopy));
    // this.primaryDiagnosisMedicalQuestions = primaryDiagnosisMedicalQuestionsCopy;
  }

  get yesNoOptions() {
    return [
      { label: "Yes", value: "Yes" },
      { label: "No", value: "No" }
    ];
  }*/
}
