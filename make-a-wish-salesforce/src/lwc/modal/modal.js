import { LightningElement, api } from "lwc";

export default class Modal extends LightningElement {
  @api modalConfig;

  handleModalAction(event) {
    this.dispatchEvent(
      new CustomEvent("modalactionevent", {
        detail: {
          modalAction: event.target.dataset.type,
        },
        bubbles: true,
        composed: true,
      })
    );
  }
}