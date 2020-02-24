/**
 * Created by mnahar on 8/28/2019.
 */
({
    doInit : function(component, event, helper) {
        var action = component.get("c.getWishId");
        action.setParams({
            budgetId: component.get("v.recordId"),
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.wishId', response.getReturnValue());
            } else if (state === 'ERROR') {
                //this.handleErrors(response.getError());
            }
        });
        $A.enqueueAction(action);

        var actionURL = component.get("c.getBaseOrgURL");
        actionURL.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.baseURL', response.getReturnValue());
            } else if (state === 'ERROR') {
                //this.handleErrors(response.getError());
            }
        });
        $A.enqueueAction(actionURL);
    },

    handleErrors : function(errors) {
        // Configure error toast
        let toastParams = {
            title: "Error",
            message: "Unknown error", // Default error message
            type: "error"
        };
        // Pass the error message if any
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = errors[0].message;
        }
        // Fire error toast
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    },



    })