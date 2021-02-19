import { LightningElement, api, wire } from "lwc";
import getPassword from "@salesforce/apex/DvLoginController.getLeadInfoByLeadId";

export default class DvLogin extends LightningElement {
  @api leadId;
  actualPassword;
  inputPassword;
  isLeadReviewed;

  @wire(getPassword, {
    leadId: "$leadId",
  })
  wiredRecord(result) {
    if (result.data) {
      this.actualPassword = result.data.formPassword;
      this.isLeadReviewed = result.data.isLeadReviewed;
    } else if (result.error) {
      console.error(result.error);
    }
  }

  handlePasswordFocus() {
    let searchCmp = this.template.querySelector(".login");
    searchCmp.setCustomValidity("");
  }

  handlePasswordChange(event) {
    this.inputPassword = event.target.value;
  }

  handleLogin() {
    let passwordInputComp = this.template.querySelector("lightning-input");
    if (this.actualPassword !== this.inputPassword) {
      passwordInputComp.setCustomValidity(
        "You have entered an incorrect password. Please try again, or contact chapter staff for access."
      );
      passwordInputComp.reportValidity();
    } else if (this.isLeadReviewed === true) {
      passwordInputComp.setCustomValidity("");
      this.fireLoginEvent(
        "This document has already been reviewed. Please contact chapter staff for access.",
        false
      );
    } else {
      this.fireLoginEvent("", true);
    }
  }

  fireLoginEvent(message, isLoginSuccess) {
    this.dispatchEvent(
      new CustomEvent("login", {
        detail: {
          isLoginSuccessful: isLoginSuccess,
          message: message,
        },
      })
    );
  }
}
