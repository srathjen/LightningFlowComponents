/**
@description Toast Notification component, usages where one.app is not available.
@author Gustavo Mayer, Traction on Demand
@createdDate 08/Feb/2020
*/
import { LightningElement, api } from "lwc";

export default class NotificationToast extends LightningElement {
  @api notificationConfig;

  autoCloseTime = 5000;

  @api
  showCustomNotice() {
    const toastModel = this.template.querySelector('[data-id="toastModel"]');
    toastModel.className = "slds-show";
    if (this.notificationConfig.autoClose) {
      if (
        (this.notificationConfig.autoCloseErrorWarning &&
          this.notificationConfig.variant !== "success") ||
        this.notificationConfig.variant === "success"
      ) {
        this.delayTimeout = setTimeout(() => {
          toastModel.className = "slds-hide";
        }, this.autoCloseTime);
      }
    }
  }

  closeModel() {
    const toastModel = this.template.querySelector('[data-id="toastModel"]');
    toastModel.className = "slds-hide";
  }

  get mainDivClass() {
    return (
      "slds-notify slds-notify_toast slds-theme_" +
      this.notificationConfig.variant
    );
  }

  get messageDivClass() {
    return (
      "slds-icon_container slds-icon-utility-" +
      this.notificationConfig.variant +
      " slds-icon-utility-success slds-m-right_small slds-no-flex slds-align-top"
    );
  }

  get iconName() {
    return "utility:" + this.notificationConfig.variant;
  }
}