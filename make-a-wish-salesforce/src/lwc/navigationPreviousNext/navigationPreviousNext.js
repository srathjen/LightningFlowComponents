/**
@description Previous/Next navigation component, usages for paginating with previous/next.
@author Gustavo Mayer, Traction on Demand
@createdDate 08/Feb/2021
**/
import { LightningElement, api } from "lwc";

export default class NavigationPreviousNext extends LightningElement {
  hasPrevious = false;
  hasNext = false;
  _process;
  isNextStepBlocked = false;

  @api get process() {
    return this._process;
  }

  set process(value) {
    this._process = value;
    const currentStepId = value.currentStepId;
    const steps = value.steps;
    if (steps) {
      let firstItem = steps[0].id;
      let lastItem = steps[steps.length - 1].id;
      if (steps.length > 1) {
        if (steps.length > 1 && currentStepId === firstItem) {
          this.hasPrevious = false;
          this.hasNext = true;
        } else if (
          steps.length > 1 &&
          currentStepId !== firstItem &&
          currentStepId !== lastItem
        ) {
          this.hasPrevious = true;
          this.hasNext = true;
        } else if (steps.length > 1 && currentStepId === lastItem) {
          this.hasPrevious = true;
          this.hasNext = false;
        }
      } else if (steps.length === 1) {
        this.hasPrevious = false;
        this.hasNext = false;
      }
      // Determine next step disabled
      if (steps[currentStepId - 1].status === "incomplete") {
        this.isNextStepBlocked = true;
      } else if (steps[currentStepId - 1].status === "active") {
        this.isNextStepBlocked = false;
      } else if (steps[currentStepId - 1].status === "complete") {
        this.isNextStepBlocked = false;
      }
    }
  }

  handleNavigation(event) {
    let processUpdate = { ...this._process };
    if (event.target.value === "previous") {
      processUpdate.currentStepId = processUpdate.currentStepId - 1;
    } else if (event.target.value === "next") {
      processUpdate.currentStepId = processUpdate.currentStepId + 1;
    }
    const navigationStepEvent = new CustomEvent("navigationstepevent", {
      detail: {
        process: processUpdate,
      },
    });
    this.dispatchEvent(navigationStepEvent);
  }

  @api isContinuable(isContinuable) {
    this.isNextStepBlocked = !isContinuable;
  }
}