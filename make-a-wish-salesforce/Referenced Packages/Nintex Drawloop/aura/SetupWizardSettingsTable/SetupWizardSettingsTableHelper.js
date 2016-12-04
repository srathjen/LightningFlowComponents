({
	usersProfiles : function(component) {
		var action = component.get("c.currentUsersProfiles");
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var retVal = JSON.parse(response.getReturnValue());
                component.set("v.profileUsers", retVal);
                var hideSpinner = component.getEvent("hideSpinner");
				hideSpinner.fire();
                component.set("v.selectedOption", "");
            } else {
                component.getEvent('showError').setParams({
                    message: "An unknown error has occurred. Please contact Drawloop Support if this error persists."
                }).fire();
            }
            component.set('v.busy', false);
        });
		$A.enqueueAction(action);
	},
    loadDefaults : function(component, recordId) {
        var isProfile = component.get("c.isProfile");
        isProfile.setParams({ "selection" : recordId });
        isProfile.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var defaultVal = response.getReturnValue();
                component.set("v.defaultType", defaultVal);
                if (defaultVal === "Profile") {
                    component.find("profile").set("v.value", true);
                    component.find("user").set("v.value", false);
                } else {
                    component.find("profile").set("v.value", false);
                    component.find("user").set("v.value", true);
                }
            }
        });
        $A.enqueueAction(isProfile);
        
        var action = component.get("c.modalDefaultDropdownOptions");
        action.setParams({ "defaultSelection" : recordId });
        action.setCallback(this, function(response) {
            var retVal = JSON.parse(response.getReturnValue());
            component.set("v.userProfileOptions", retVal);
            component.set("v.defaultOptions", retVal);
        });
        $A.enqueueAction(action);
        component.set("v.profileUserSelection", recordId);
        component.set("v.recordId", recordId);
    },
    loadAll : function(component, selection) {
        var load = component.get("c.modalAlternateDropdownOptions");
        load.setParams({ "selection" : selection });
        load.setCallback(this, function(response) {
           var retVal = JSON.parse(response.getReturnValue());
           component.set("v.userProfileOptions", retVal);
           component.set("v.profileUserSelection", retVal[0].i);
        });
        $A.enqueueAction(load);
    },
    isProfile : function(component, recordId) {
        var isProfile = component.get("c.isProfile");
        isProfile.setParams({ "selection" : recordId });
        isProfile.setCallback(this, function(response) {
            var defaultVal = response.getReturnValue();
           	component.set("v.defaultType", defaultVal);
            if (defaultVal === "Profile") {
                component.find("profile").set("v.value", true);
            	component.find("user").set("v.value", false);
	        } else {
            	component.find("profile").set("v.value", false);
            	component.find("user").set("v.value", true);
    	    }
        });
        $A.enqueueAction(isProfile);
    },
    onloadPTE : function(component, recordId, event) {
        var currentPTEList = component.get("c.loadPauseToEdit");
        currentPTEList.setParams({ 
            "selected": recordId 
        });
        currentPTEList.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var result = response.getReturnValue();
                var tmpSelection = document.getElementsByClassName('radio');
                for (var i = 0; i < tmpSelection.length; i++) {
                    if (tmpSelection[i].value === result) {
                        tmpSelection[i].checked = true;
                    } else if (!result) {
                        if (tmpSelection[i].value === 'Use Organization-Wide') {
                            tmpSelection[i].checked = true;
                        }
                    } else {
                        tmpSelection[i].checked = false;
                    }
                }
                component.set("v.pauseToEditSelection", result);
                recordId === "New" ? component.set("v.selectedOption", "New") : component.set("v.selectedOption", "Edit");
                this.replaceSpinnersWithLinks(component);
            }
		});
        $A.enqueueAction(currentPTEList);
    },
    replaceLinkWithSpinner : function(component, event) {
        event.target.style.display = 'none';
        event.target.parentElement.nextSibling.style.display = 'inline-block';
    },
    replaceSpinnersWithLinks : function(component) {
        var spinners = component.find('spinner');
        for (var i = 0; i < spinners.length; i++) {
            var spinner = spinners[i].getElement();
            if (spinner.style.display !== 'none') {
                spinner.style.display = 'none';
            }
            spinner.previousSibling.firstChild.style.display = 'inline-block';
        }
    }
})