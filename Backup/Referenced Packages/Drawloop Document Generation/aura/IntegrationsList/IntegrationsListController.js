({
    doInit: function(component, event, helper) {
        helper.getIntegrationsList(component);
    },
    showDetails: function(component, event, helper) {
        //Get data via "data-data" attribute from button (button itself or icon's parentNode)
        var id = event.target.getAttribute("data-data") || event.target.parentNode.getAttribute("data-data")
        alert(id + " was passed");
    },
    deleteIntegration : function(component, event, helper) {
        helper.replaceLinkWithSpinner(component, event);

        var recordIdOrIntegrationName = event.target.getAttribute('data-data');
        var action = component.get("c.deleteIntegrationInfos");
        action.setParams({
            value: recordIdOrIntegrationName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue()) {
                    helper.getIntegrationsList(component);
                    var deleteIntegrationEvent = component.getEvent("deleteIntegration");
                    deleteIntegrationEvent.fire();
                } else {
                    component.getEvent('showError').setParams({
                        message: 'There was a problem deleting this integration.'
                    }).fire();
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                var message = 'Unknown error';
                if (errors && errors[0] && errors[0].message) {
                    message = 'Error message: ' + errors[0].message;
                }
                component.getEvent('showError').setParams({
                    message: message
                }).fire();
            }
        });
        $A.enqueueAction(action);        
    },
    editIntegration : function(component, event, helper) {
        helper.replaceLinkWithSpinner(component, event);
        var id = event.target.getAttribute("data-data");
        component.getEvent("editIntegration").setParams({
            id: id
        }).fire();
    },
    replaceSpinnersWithLinks : function(component, event) {
        var spinners = component.find('spinner');
        for (var i = 0; i < spinners.length; i++) {
            var spinner = spinners[i].getElement();
            if ($A.util.hasClass(spinner, 'inlineBlock')) {
                $A.util.addClass(spinner, 'hidden');
                $A.util.removeClass(spinner, 'inlineBlock');
                var link = spinner.previousSibling;
                link.style.display = 'inline-block';
            }
        }
    }
})