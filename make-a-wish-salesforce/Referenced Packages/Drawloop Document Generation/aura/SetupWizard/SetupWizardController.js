({
    init : function(component, event, helper) {
        if (!helper.isLockerServiceActive()) {
            helper.updateContent(component);
            
            var complete = component.get("v.complete");
            var action = component.get("c.getCustomizeApplication");
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state !== "SUCCESS") {
                    component.getEvent('showError').setParams({
                        message: 'An unexpected error has occurred.'
                    }).fire();
                    component.set('v.customizeApplication', false);
                } else if (response.getReturnValue() !== true) {
                    component.set('v.alertText', 'You need the Customize Application permission to complete the setup and start generating documents. Contact your system administrator, or continue and complete steps that require this permission later.');
                    component.set('v.customizeApplication', false);
                }
            });
            $A.enqueueAction(action);
        }
        else {
            $A.util.addClass(component.find('pageContent'), 'hidden');
            $A.util.addClass(component.find('pageFooter'), 'hidden');
            $A.util.removeClass(component.find('lockerServiceMessage'), 'hidden');
        }
    },
    save : function(component, event, helper) {
        switch (component.get("v.step")) {
            case "Splash":
                helper.moveToNextStep(component, event, helper);
                break;
            case "Edition":
                component.set("v.busy", true);
                component.find("edition").save();
                break;
            case "Users":
                component.set("v.busy", true);
                component.find("setupUsers").save();
                break;
            case "Authorize":
                helper.moveToNextStep(component, event, helper);
                break;
            case "Integrations":
                helper.moveToNextStep(component, event, helper);
                break;
            case "Settings":
                component.set("v.busy", true);
                component.find("settings").save();
                break;
            case "Sample DDPs":
                component.set("v.busy", true);
                component.find("sampleDdps").save();
                break;
            case "Basic Buttons":
                component.set("v.busy", true);
                component.find("pageLayouts").save();
                break;
            default:
                break;
        }
    },
    moveToNextStep : function(component, event, helper) {
        if (event.getParam('success')) {
            helper.moveToNextStep(component, event, helper);
        } else {
            component.set('v.busy', false);
        }
    },
    skipStep : function(component, event, helper) {
        var text = event.target.textContent;
        if (text === 'Skip Wizard') {
            var action = component.get("c.completeSetupWizard");
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state !== "SUCCESS" || response.getReturnValue() !== "true") {
                    component.getEvent('showError').setParams({
                        message: 'An unexpected error has occurred.'
                    }).fire();
                } else {
                    window.location.reload();
                }
            });
            $A.enqueueAction(action);
        } else if (component.get("v.step") === "Basic Buttons") {
            helper.moveToNextStep(component, event, helper);
        } else {
            var stepsToSkip = 1;
            var steps = component.get("v.steps");
            if (component.get("v.step") === 'Authorize') {
                stepsToSkip = 2;
            }
            var nextStep = steps[steps.indexOf(component.get("v.step")) + stepsToSkip];
            component.set("v.step", nextStep);
            helper.updateContent(component);
        }
    },
    changeStep : function(component, event, helper) {
        var step = event.getParam("path");
        component.set("v.step", step);
        helper.updateContent(component);
        component.set('v.complete', false);
    },
    setSampleObjects : function(component, event, helper) {
        if (event.getParam('sampleType') === 'sampleDdps') {
            component.set('v.sampleDdpObjects', event.getParam('objectTypes'));
        } else if (event.getParam('sampleType') === 'layoutButtons') {
            component.set('v.layoutButtonObjects', event.getParam('objectTypes'));
        }
    },
    showError : function(component, event, helper) {
        var errorPrompt = component.find('errorPrompt');
        var title = event.getParam('title');
        var message = event.getParam('message');
        errorPrompt.showError(title, message);
    }
})