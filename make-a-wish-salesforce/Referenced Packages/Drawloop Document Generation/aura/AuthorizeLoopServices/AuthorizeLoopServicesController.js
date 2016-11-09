({
    onInit : function(component, event, helper) {
        if (!component.get('v.customizeApplication')) {
            component.set("v.authButtonDisabled", true);
            component.set("v.spinnerVisible", false);
        	return;
        }
        
        var action = component.get("c.fetchIntegrationUsername");
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var integrationUsername = response.getReturnValue();
                if (integrationUsername) {
                    component.set("v.authorizingUser", integrationUsername);
                    component.set("v.authorizedStatus", "Authorized");
                }
                component.set("v.needsAuthentication", !integrationUsername);
                component.set("v.authButtonDisabled", false);
            }
            else {
                var errors = response.getError();
                var message = 'Error: Unknown Error';
                if (errors && errors[0] && errors[0].message) {
                    message = 'Error: ' + errors[0].message;
                }
                component.getEvent('showError').setParams({
                    message: message
                }).fire();
            }
            component.set("v.spinnerVisible", false);
        })
        $A.enqueueAction(action);        
    },
	authorizeLoopServices : function(component, event, helper) {
        var unblockedWindow = window.open('', 'Salesforce Auth', 'height=811,width=680,location=0,status=0,titlebar=0');
        unblockedWindow.document.write('Loading...');
        
        var action = component.get("c.fetchPreOAuthData");
        action.setParams({
            domain: component.get('v.loopUrl')
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var parsedResponse = JSON.parse(response.getReturnValue());
                if (parsedResponse.isSuccess) {
                    unblockedWindow.location.href = parsedResponse.oAuthUrl;
                    component.set("v.oAuthUrl", parsedResponse.oAuthUrl);
                    component.set("v.isSandbox", parsedResponse.isSandbox);
                    
                    component.set("v.authButtonDisabled", false);
                }
                else {
                    unblockedWindow.close();
                    component.getEvent('showError').setParams({
                        message: parsedResponse.ErrorMessage
                    }).fire();
                }
            }
            else {
                var errors = response.getError();
                var message = 'Error: Unknown Error';
                if (errors && errors[0] && errors[0].message) {
                    message = 'Error: ' + errors[0].message;
                }
                component.getEvent('showError').setParams({
                    message: message
                }).fire();
            }
        })
        $A.enqueueAction(action);
        
	},
    handleOAuthSuccessful : function(component, event, helper) {
        if (!event.getParam("authorizingUser")) {
            component.set("v.authorizedStatus", "Unauthorized");
            component.set("v.authorizingUser", 'Authorization was denied');
            document.getElementById("authorizedUser").style.color = 'red';
        } else {
            //TODO:
            //We should not let the user do anything until this function finishes
            
            //This apex action should add the integration user to the our database, update the integration user custom settings, and return the integration username.
            var action = component.get("c.authorizeReports");
            action.setParams({
                domain: component.get('v.loopUrl')
            });
            action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    var parsedResponse = JSON.parse(response.getReturnValue());
                    if (parsedResponse.isSuccess) {
                        component.set("v.authorizedStatus", "Authorized");
                        component.set("v.authorizingUser", event.getParam("authorizingUser"));
                        var authorizedUser = document.getElementById("authorizedUser");
                        if (authorizedUser) {
	                        authorizedUser.style.color = 'black';
                        }
                        //TODO:
                        //If we've disabled the user, enable them at this point
                        
                        var moveToNextStep = component.getEvent("moveToNextStep");
                        moveToNextStep.setParams({success: true}).fire();
                    }
                    else {
                        component.getEvent('showError').setParams({
                            message: parsedResponse.ErrorMessage
                        }).fire();
                    }
                }
            });
            $A.enqueueAction(action);
        }
    }
})