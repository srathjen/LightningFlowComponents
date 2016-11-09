({
    onInit : function(component, event, helper) {
        var domain = component.get("v.loopUrl");
        
        var checkAuthentication = component.get("c.checkAuthentication");
        checkAuthentication.setParams({
            domain: domain
        });
        checkAuthentication.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var parsedResponse = JSON.parse(response.getReturnValue());
                if (parsedResponse.isSuccess) {
                    var isAuthorized = parsedResponse.isAuthorized;
                    
                    component.set("v.isAuthorized", isAuthorized);
                    component.set("v.oAuthUrl", parsedResponse.oAuthUrl);
                    component.set("v.findSubOptionUrl", parsedResponse.findSubOptionUrl);
                    component.set("v.connectedAppsEnabled", parsedResponse.connectedAppsEnabled);
                    
                    if (isAuthorized) {
                        helper.load(component, component.get("v.sessionId"), component.get("v.loopUrl"));
                    }
                    else {
            			component.set("v.isLoading", false);
                    }
                }
                else {
                    helper.fireErrorEvent(component, parsedResponse.errorMessage);
                }
            }
            else {
                helper.fireErrorEvent(component, '');
            }
        });
        
        $A.enqueueAction(checkAuthentication);
    },
    startOAuth : function(component, event, helper) {
        if (event.currentTarget.id === "findSubOptions") {
            window.open(component.get("v.findSubOptionUrl"), "Salesforce Auth", "width=490, height=680");
        }
        else {
        	window.open(component.get("v.oAuthUrl"), "Salesforce Auth", "width=490, height=680");
        }
    },
    handleOAuthSuccessful : function(component, event, helper) {
        component.set("v.isAuthorized", true);
        helper.load(component, event.getParam("sessionId"), event.getParam("location"));
    },
    save : function(component) {
        var isStandard = component.get('v.isStandard');
        var scheduledDdp = isStandard ? component.get("v.standardScheduledDdp") : component.get("v.businessScheduledDdp");
        var workflowDdp = component.get("v.workflowDdp");
        var componentLibrary = component.get("v.componentLibrary");
        var massDdp = component.get("v.massDdp");
        
        var action = component.get("c.saveServices");
        action.setParams({
            "isStandard" : isStandard,
            "scheduledDdp" : scheduledDdp,
            "workflowDdp" : workflowDdp,
            "componentLibrary" : componentLibrary,
            "massDdp" : massDdp,
            "domain": component.get("v.loopUrl")
        });
        action.setCallback(this, function(response) {
            var moveToNextStep = component.getEvent("moveToNextStep");
            if (response.getState() === "SUCCESS") {
                var parsedResponse = JSON.parse(response.getReturnValue());
                if (parsedResponse.isSuccess) {
                    moveToNextStep.setParams({success: true}).fire();
                }
                else {
                    moveToNextStep.setParams({success: false}).fire();
                    component.getEvent('showError').setParams({
                        message: parsedResponse.errorMessage
                    }).fire();
                }
            } else {
                moveToNextStep.setParams({success: false}).fire();
                var error = response.getError();
                var message = 'There was a problem saving changes.';
                if (error && error[0] && error[0].message) {
					message = response.getError()[0].message;
                }
                component.getEvent('showError').setParams({
                    message: message
                }).fire();
            }
        });
        $A.enqueueAction(action);
    },
    toggleServiceLevel : function(component, event, helper) {
        var isStandard = component.get("v.isStandard");
        helper.clearServices(component);
        component.set("v.isStandard", !isStandard);
    },
    toggleStandardScheduledDdp : function(component) {
        var scheduledDdp = component.get("v.standardScheduledDdp");
        component.set("v.standardScheduledDdp", !scheduledDdp);
    },
    toggleBusinessScheduledDdp : function(component) {
        var scheduledDdp = component.get("v.businessScheduledDdp");
        component.set("v.businessScheduledDdp", !scheduledDdp);
    },
    toggleWorkflowDdp : function(component) {
        var workflowDdp = component.get("v.workflowDdp");
        component.set("v.workflowDdp", !workflowDdp);
    },
    toggleComponentLibrary : function(component) {
        var componentLibrary = component.get("v.componentLibrary");
        component.set("v.componentLibrary", !componentLibrary);
    },
    toggleMassDdp : function(component) {
        var massDdp = component.get("v.massDdp");
        component.set("v.massDdp", !massDdp);
    }
})