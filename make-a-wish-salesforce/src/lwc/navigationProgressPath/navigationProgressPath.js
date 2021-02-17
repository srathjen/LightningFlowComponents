/**
@description Path navigation component, usages for paginating with progress path.
@author Gustavo Mayer, Traction on Demand
@createdDate 08/Feb/2021
*/
import { LightningElement, api } from "lwc";

export default class ProgressBarSteps extends LightningElement {
  _process;
  progressBarSteps;

  @api get process() {
    return this._process;
  }

  set process(value) {
    this._process = value;
    let steps = [];
    value.steps.forEach((step) => {
      if (step.id === value.currentStepId) {
        steps.push({
          id: step.id,
          label: step.label,
          status: step.status,
          style: "slds-path__item slds-is-current",
        });
      } else if (step.id !== value.currentStepId) {
        steps.push({
          id: step.id,
          label: step.label,
          status: step.status,
          style: "slds-path__item slds-is-" + step.status,
        });
      }
    });
    this.progressBarSteps = steps;
  }

  handleNavigateToStep(event) {
    let navigateToStep = parseInt(event.target.dataset.id);
    let previousStep = this._process.steps[navigateToStep - 2];
    let targetStep = this._process.steps[navigateToStep - 1];
    if (targetStep.status === "incomplete") {
      const navigationStepEvent = new CustomEvent("navigationstepevent", {});
      this.dispatchEvent(navigationStepEvent);
    } else if (
      targetStep.status === "active" ||
      targetStep.status === "complete"
    ) {
      let steps = [];
      this._process.steps.forEach((step) => {
        if (step.id === navigateToStep) {
          steps.push({
            id: step.id,
            label: step.label,
            status: step.status,
            style: "slds-path__item slds-is-current",
          });
        } else if (step.id !== navigateToStep) {
          steps.push({
            id: step.id,
            label: step.label,
            status: step.status,
            style: "slds-path__item slds-is-" + step.status,
          });
        }
      });

      let processUpdate = { ...this._process };
      processUpdate.currentStepId = navigateToStep;
      processUpdate.steps = steps;
      const navigationStepEvent = new CustomEvent("navigationstepevent", {
        detail: {
          process: processUpdate,
        },
      });
      this.dispatchEvent(navigationStepEvent);
    }
  }
}