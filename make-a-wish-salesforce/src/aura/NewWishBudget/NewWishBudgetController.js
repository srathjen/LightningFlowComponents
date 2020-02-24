/**
 * Created by mnahar on 8/20/2019.
 */
({

    doInit: function (component, event, helper) {
        component.set("v.spinner", true);
        //To get Parent Case Id
        var pageRef = component.get("v.pageReference");
        var state = pageRef.state; // state holds any query params
        var base64Context = state.inContextOfRef;

        if (base64Context.startsWith("1\.")) {
            base64Context = base64Context.substring(2);
        }
        var addressableContext = JSON.parse(window.atob(base64Context));
        component.set("v.recordId", addressableContext.attributes.recordId);

        //Check if Case has any existing Wish Budget records
        var action = component.get("c.getWishBudgets");
        action.setParams({
            caseId: component.get("v.recordId"),
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === 'SUCCESS') {
                if (result !== undefined) {
                    if(result.Wish_Budget__r !== undefined){
                        for (var i = 0; i < result.Wish_Budget__r.length; i++) {
                            if (result.Wish_Budget__r[i].Budget_Approval_Status__c == 'Submitted') {
                                component.set("v.errorModal", true);
                                component.find("errorModal").open();
                                component.set("v.spinner", false);
                                return;
                            }
                        }
                        if (result.Wish_Budget__r.length > 0) {
                            component.set("v.confirmModal", true);
                            component.find("confirmModal").open();
                            component.set("v.spinner", false);
                            return;
                        }
                    }
                }
                helper.createRecord(component, event);
                component.set("v.spinner", false);
            } else if (state === 'ERROR') {
                this.handleErrors(response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    handleConfirm: function (component, event, helper) {
        component.set("v.confirmModal", false);
        component.find("confirmModal").close();
        helper.createRecord(component, event);
    },
    handleCancel: function (component, event, helper) {
        component.set("v.confirmModal", false);
        component.set("v.errorModal", false);
        var workspaceAPI = component.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function (response) {
            console.log('Isconsole' + response);
            if (response) {
                workspaceAPI.getFocusedTabInfo().then(function (response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({tabId: focusedTabId});
                })
                    .catch(function (error) {
                        console.log(error);
                    });
            } else {
                window.history.back();
            }
        })
    },
    handleErrors: function (errors) {
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
    }
})