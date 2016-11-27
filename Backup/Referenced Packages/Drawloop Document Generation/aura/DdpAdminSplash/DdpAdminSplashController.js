({
    load : function(component, event, helper) {
        var hasContract = event.getParams().arguments.hasContract;
        var usedLicenses = event.getParams().arguments.usedLicenses;
        var daysRemainingInTrial = event.getParams().arguments.daysRemainingInTrial;
        var allowedLicenses = event.getParams().arguments.allowedLicenses;
        if (allowedLicenses < 0) {
            allowedLicenses = 'Unlimited';
        }
        if (!hasContract) {
            component.set("v.licenseButtonLabel", "Purchase Nintex Drawloop");
        } else {
            component.set("v.licenseButtonLabel", "Upgrade or Add Users");
        }
        component.set("v.hasContract", hasContract);
        component.set("v.usedLicenses", usedLicenses);
        component.set("v.daysRemainingInTrial", daysRemainingInTrial);
        component.set("v.allowedLicenses", allowedLicenses);
        component.set("v.isLoading", false);
    },
    redirectPage : function(component, event) {
        var label = event.currentTarget.id;
        var redirectEvent = component.getEvent("redirectPage");
        redirectEvent.setParams({
            "buttonName" : label
        });
        redirectEvent.fire();
    }
})