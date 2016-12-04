({
    doInit : function(component, event, helper) {
    	helper.usersProfiles(component, event);
    },
    editSettings : function(component, event, helper) {
        helper.replaceLinkWithSpinner(component, event);
        var id = event.target.getAttribute("data-data");
        helper.isProfile(component, id);
        helper.loadDefaults(component, id);
        helper.onloadPTE(component, id, event);
    },
    newSettings : function(component, event, helper) {
        helper.loadAll(component, "Profile");
        helper.isProfile(component, "Profile");
        helper.onloadPTE(component, "New", event);
        component.set("v.recordId", "");
    },
    resetSelectedOption : function(component, event, helper) {
        component.set("v.selectedOption", "");
        helper.replaceSpinnersWithLinks(component);
    },
    optionChange : function(component, event, helper) {
        component.set("v.profileUserSelection", event.source.get("v.value"));
    },
    pteChange: function(component, event) {
        component.set("v.pauseToEditSelection", event.source.get("v.text"));
    },
    typeChange: function(component, event, helper) {
        var change = event.source.get("v.value");
        if (change === component.get("v.defaultType") && component.get("v.selectedOption") !== 'New') {
            component.set("v.userProfileOptions", component.get("v.defaultOptions"));
        } else {
            helper.loadAll(component, change);
        }
    },
    saveSettings : function(component, event, helper) {
        component.set('v.busy', true);
        var selection = component.get("v.profileUserSelection");
        var pauseToEdit = component.get("v.pauseToEditSelection");
        var recordId = component.get("v.recordId");
        if (!recordId) {
            recordId = "New";
        }
        var save = component.get("c.saveRecord");
        save.setParams({ 
            recordId : recordId,
            profileUserId : selection, 
            pte : pauseToEdit 
        });
        save.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                helper.usersProfiles(component);
            } else {
                component.set("v.selectedOption", "");
                component.set('v.busy', false);
            }
        });
        $A.enqueueAction(save);
    },
    deleteSettings : function(component, event, helper) {
        helper.replaceLinkWithSpinner(component, event);
        var recordId = event.target.getAttribute("data-data");
        var d = component.get("c.deleteRecord");
        d.setParams({ "recordId" : recordId });
        d.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                helper.usersProfiles(component);
            }
        });
        $A.enqueueAction(d);
    }
})